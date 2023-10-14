import {
  BaseConfig,
  ContextBuilder,
  Dpp,
  Plugin,
} from "https://deno.land/x/dpp_vim@v0.0.2/types.ts";
import { Denops, fn } from "https://deno.land/x/dpp_vim@v0.0.2/deps.ts";

export class Config extends BaseConfig {
  override async config(args: {
    denops: Denops;
    contextBuilder: ContextBuilder;
    basePath: string;
    dpp: Dpp;
  }): Promise<{
    plugins: Plugin[];
    stateLines: string[];
  }> {
    args.contextBuilder.setGlobal({
      protocols: ["git"],
    });

    const [context, options] = await args.contextBuilder.get(args.denops);

    const tomlPlugins = await args.dpp.extAction(
      args.denops,
      context,
      options,
      "toml",
      "load",
      {
        path: "$HOME/.vim/dein/dein_lazy.toml",
        options: {
          lazy: true,
        },
      },
    ) as Plugin[];

    const recordPlugins: Record<string, Plugin> = {};
    for (const plugin of tomlPlugins) {
      recordPlugins[plugin.name] = plugin;
    }

    const localPlugins = await args.dpp.extAction(
      args.denops,
      context,
      options,
      "local",
      "local",
      {
        directory: "~/work",
        options: {
          frozen: true,
          merged: false,
        },
      },
    ) as Plugin[];

    // Merge localPlugins
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

    const stateLines = await args.dpp.extAction(
      args.denops,
      context,
      options,
      "lazy",
      "makeState",
      {
        plugins: Object.values(recordPlugins),
      },
    ) as string[];

    return {
      plugins: Object.values(recordPlugins),
      stateLines,
    };
  }
}
