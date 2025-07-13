import {
  BaseConfig,
  ConfigReturn,
  ContextBuilder,
  Dpp,
  Plugin,
} from "https://deno.land/x/dpp_vim@v0.1.0/types.ts";
import { Denops } from "https://deno.land/x/dpp_vim@v0.0.2/deps.ts";

type Toml = {
  hooks_file?: string;
  ftplugins?: Record<string, string>;
  plugins: Plugin[];
};

type LazyMakeStateResult = {
  plugins: Plugin[];
  stateLines: string[];
};

export class Config extends BaseConfig {
  override async config(args: {
    denops: Denops;
    contextBuilder: ContextBuilder;
    basePath: string;
    dpp: Dpp;
  }): Promise<ConfigReturn> {
    const hasNvim = args.denops.meta.host === "nvim";
    // const hasWindows = await fn.has(args.denops, "win32");

    args.contextBuilder.setGlobal({
      protocols: ["git"],
      protocolParams: {
        git: {
          enablePartialClone: true,
        },
      },
    });

    const [context, options] = await args.contextBuilder.get(args.denops);

    // Load toml plugins
    const tomls: Toml[] = [];
    for (
      const tomlFile of [
        "$BASE_DIR/dpp.toml",
        "$BASE_DIR/denops.toml",
      ]
    ) {
      const toml = await args.dpp.extAction(
        args.denops,
        context,
        options,
        "toml",
        "load",
        {
          path: tomlFile,
          options: {
            lazy: false,
          },
        },
      ) as Toml | undefined;

      if (toml) {
        tomls.push(toml);
      }
    }
    for (
      const tomlFile of [
        "$BASE_DIR/ddc.toml",
        "$BASE_DIR/ddu.toml",
        "$BASE_DIR/lazy.toml",
        hasNvim ? "$BASE_DIR/nvim.toml" : "$BASE_DIR/vim.toml",
      ]
    ) {
      const toml = await args.dpp.extAction(
        args.denops,
        context,
        options,
        "toml",
        "load",
        {
          path: tomlFile,
          options: {
            lazy: true,
          },
        },
      ) as Toml | undefined;

      if (toml) {
        tomls.push(toml);
      }
    }

    // Merge toml results
    const recordPlugins: Record<string, Plugin> = {};
    const ftplugins: Record<string, string> = {};
    const hooksFiles: string[] = [];
    for (const toml of tomls) {
      for (const plugin of toml.plugins) {
        recordPlugins[plugin.name] = plugin;
      }

      if (toml.ftplugins) {
        for (const filetype of Object.keys(toml.ftplugins)) {
          if (ftplugins[filetype]) {
            ftplugins[filetype] += `\n${toml.ftplugins[filetype]}`;
          } else {
            ftplugins[filetype] = toml.ftplugins[filetype];
          }
        }
      }

      if (toml.hooks_file) {
        hooksFiles.push(toml.hooks_file);
      }
    }

    // ローカルプラグインを優先させたいディレクトリのリスト
    // 上から順に優先度が高い（同名のプラグインがある場合、上のディレクトリが優先される）
    const localPluginDirs = [
      "~/ghq/github.com/i9wa4",
      "~/ghq/github.com/saccarosium",
    ];

    // 各ディレクトリからローカルプラグインを読み込む（逆順で処理）
    for (const directory of localPluginDirs.slice().reverse()) {
      const localPlugins = await args.dpp.extAction(
        args.denops,
        context,
        options,
        "local",
        "local",
        {
          directory: directory,
          options: {
            frozen: true,
            merged: false,
          },
        },
      ) as Plugin[] | undefined;

      if (localPlugins) {
        for (const plugin of localPlugins) {
          if (plugin.name in recordPlugins) {
            recordPlugins[plugin.name] = Object.assign(
              recordPlugins[plugin.name],
              plugin,
            );
          } else {
            recordPlugins[plugin.name] = plugin;
          }
        }
      }
    }

    const lazyResult = await args.dpp.extAction(
      args.denops,
      context,
      options,
      "lazy",
      "makeState",
      {
        plugins: Object.values(recordPlugins),
      },
    ) as LazyMakeStateResult | undefined;

    return {
      ftplugins,
      hooksFiles,
      plugins: lazyResult?.plugins ?? [],
      stateLines: lazyResult?.stateLines ?? [],
    };
  }
}
