{...}: {
  # EditorConfig is awesome: https://EditorConfig.org
  editorconfig = {
    enable = true;
    settings = {
      "*" = {
        charset = "utf-8";
        end_of_line = "lf";
        indent_size = 4;
        indent_style = "space";
        insert_final_newline = true;
        trim_trailing_whitespace = true;
      };
      "{*.{css,json,lua,mmd,sh,tf,tftpl,tfvars,toml,ts,vim,yaml,zshenv,zshrc},vimrc}" = {
        indent_size = 2;
      };
      "{*.go,Makefile}" = {
        indent_style = "tab";
      };
      "{*.{bat,cmd}}" = {
        end_of_line = "crlf";
      };
      "COMMIT_EDITMSG" = {
        indent_style = "space";
        tab_width = 8;
        max_line_length = 72;
      };
    };
  };
}
