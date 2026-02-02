{
  pkgs,
  username,
  ...
}: {
  # Nix settings
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      # Increase download buffer to avoid "download buffer is full" warning
      # Default: 64 MiB (64 * 1024 * 1024 = 67108864)
      download-buffer-size = 128 * 1024 * 1024; # 128 MiB
      # Allow user to use extra substituters (e.g., cache.numtide.com from flake inputs)
      trusted-users = ["root" username];
    };
    # Deduplicate files via hard links (scheduled, not per-build)
    # Note: auto-optimise-store is known to corrupt Nix Store on Darwin
    # Note: Disabled because large binaries are now Homebrew-managed,
    #       and scheduled optimise can cause syspolicyd high CPU
    # cf. https://github.com/nix-darwin/nix-darwin/issues/1252
    optimise.automatic = false;
    # Garbage collection (daily at noon, delete older than 1 day)
    # cf. https://mynixos.com/nix-darwin/option/nix.gc.interval
    gc = {
      automatic = true;
      interval = {
        Hour = 12;
        Minute = 0;
      };
      options = "--delete-older-than 1d";
    };
  };

  # Enable zsh (creates /etc/zshenv for nix-darwin environment)
  # Note: All features disabled - home-manager programs.zsh handles ~/.zshrc
  programs.zsh = {
    enable = true;
    # History is managed by home-manager programs.zsh.history
    # Completion (handled by zinit turbo mode)
    enableCompletion = false;
    enableBashCompletion = false;
    enableGlobalCompInit = false;
    # Prompt (handled by home-manager initExtra)
    promptInit = "";
    # Plugins (handled by zinit/zeno)
    enableSyntaxHighlighting = false;
    enableAutosuggestions = false;
    enableFzfCompletion = false;
    enableFzfHistory = false;
    enableFzfGit = false;
  };

  # System packages (CLI tools that need to be system-wide)
  # NOTE: GUI apps moved to Homebrew casks to avoid nix store bloat from generations
  environment.systemPackages = [
  ];

  # Fonts
  fonts.packages = [
    pkgs.udev-gothic
  ];

  # NOTE: Homebrew settings are in common/homebrew.nix
  # Host-specific casks are in hosts/<name>/casks.nix

  # Platform
  nixpkgs.hostPlatform = "aarch64-darwin";

  # ============================================================================
  # System settings (consolidated to avoid statix W20 warning)
  # ============================================================================
  system = {
    # Primary user (required for user-specific system.defaults options)
    primaryUser = username;

    # ==========================================================================
    # Keyboard
    # ==========================================================================
    keyboard = {
      enableKeyMapping = true;
      # Caps Lock -> Control (内蔵キーボード) [default: false]
      remapCapsLockToControl = true;
    };

    # ==========================================================================
    # macOS System Defaults
    # cf. https://i9wa4.github.io/blog/2024-06-17-setup-mac.html
    # ==========================================================================
    defaults = {
      # ------------------------------------------------------------------------
      # Dock
      # ------------------------------------------------------------------------
      dock = {
        # 画面上の位置 (left/bottom/right) [default: "bottom"]
        orientation = "left";
        # Dock を自動的に表示/非表示 [default: false]
        autohide = false;
        # アプリの提案と最近使用したアプリを Dock に表示 [default: true]
        show-recents = false;
        # 最新の使用状況に基づいて操作スペースを自動的に並べ替える [default: true]
        mru-spaces = false;
        # Dock アイコンサイズ (16-128) [default: 48]
        tilesize = 48;
      };

      # ------------------------------------------------------------------------
      # Finder
      # ------------------------------------------------------------------------
      finder = {
        # パスバーを表示 [default: false]
        ShowPathbar = true;
        # 拡張子を表示 [default: false]
        AppleShowAllExtensions = true;
        # Finder 終了メニューを表示 [default: false]
        QuitMenuItem = true;
        # デフォルトの表示形式 (icnv=アイコン, Nlsv=リスト, clmv=カラム, glyv=ギャラリー) [default: "icnv"]
        # FXPreferredViewStyle = "Nlsv";
        FXPreferredViewStyle = "icnv";
      };

      # ------------------------------------------------------------------------
      # Global Domain (NSGlobalDomain)
      # ------------------------------------------------------------------------
      NSGlobalDomain = {
        # キーリピート速度 (小さいほど速い) [default: 6]
        KeyRepeat = 2;
        # キーリピート開始までの時間 (小さいほど速い) [default: 25]
        InitialKeyRepeat = 15;
        # ナチュラルなスクロール [default: true]
        # Note: macOS では trackpad と mouse のスクロール方向を別々に設定できない
        # false = 従来の PC 方向 (マウスに合わせる)
        "com.apple.swipescrolldirection" = false;
        # 英字入力中にスペルを自動変換 [default: true]
        NSAutomaticSpellingCorrectionEnabled = false;
        # 文頭を自動的に大文字にする [default: true]
        NSAutomaticCapitalizationEnabled = false;
        # スマートダッシュを使用 [default: true]
        NSAutomaticDashSubstitutionEnabled = false;
        # スペースバーを2回押してピリオドを入力 [default: true]
        NSAutomaticPeriodSubstitutionEnabled = false;
        # スマート引用符を使用 [default: true]
        NSAutomaticQuoteSubstitutionEnabled = false;
        # インライン予測テキストを表示 [default: true]
        NSAutomaticInlinePredictionEnabled = false;
        # ウィンドウ開閉アニメーション [default: true]
        NSAutomaticWindowAnimationsEnabled = false;
        # トラックパッド速度 (0.0-3.0) [default: 1.0]
        "com.apple.trackpad.scaling" = 3.0;
      };

      # ------------------------------------------------------------------------
      # Trackpad
      # ------------------------------------------------------------------------
      trackpad = {
        # タップでクリック [default: false]
        Clicking = true;
        # 3本指のドラッグ (アクセシビリティ > ポインタコントロール > トラックパッドオプション) [default: false]
        TrackpadThreeFingerDrag = true;
      };

      # ------------------------------------------------------------------------
      # Menu Bar Clock
      # ------------------------------------------------------------------------
      menuExtraClock = {
        # 日付を表示 (0=表示しない, 1=数字, 2=曜日と日付) [default: 0]
        ShowDate = 1;
        # 曜日を表示 [default: false]
        ShowDayOfWeek = true;
        # 秒を表示 [default: false]
        ShowSeconds = true;
      };

      # ------------------------------------------------------------------------
      # Control Center
      # ------------------------------------------------------------------------
      controlcenter = {
        # Bluetooth をメニューバーに表示 [default: false]
        Bluetooth = true;
        # バッテリーの割合 (%) を表示 [default: false]
        BatteryShowPercentage = true;
      };

      # ------------------------------------------------------------------------
      # Custom User Preferences (settings not available as nix-darwin options)
      # ------------------------------------------------------------------------
      CustomUserPreferences = {
        # マウス速度 (0.0-3.0) [default: 1.0]
        # Note: NSGlobalDomain では設定できないため CustomUserPreferences を使用
        ".GlobalPreferences" = {
          "com.apple.mouse.scaling" = 2.0;
        };
        "com.apple.finder" = {
          # サイドバーを表示 [default: true]
          # ShowSidebar = true;
        };
        # 日本語入力 (ローマ字入力)
        "com.apple.inputmethod.Kotoeri" = {
          # ライブ変換 [default: 1 (ON)]
          JIMPrefLiveConversionKey = 0;
          # タイプミスを修正 [default: 0 (OFF)]
          JIMPrefAutocorrectionKey = 0;
        };
        # Spotlight 検索結果
        # Note: アプリのみ有効、その他は OFF
        "com.apple.Spotlight" = {
          orderedItems = [
            {
              enabled = 1;
              name = "APPLICATIONS";
            }
            {
              enabled = 0;
              name = "BOOKMARKS";
            }
            {
              enabled = 0;
              name = "CONTACT";
            }
            {
              enabled = 0;
              name = "DIRECTORIES";
            }
            {
              enabled = 0;
              name = "DOCUMENTS";
            }
            {
              enabled = 0;
              name = "EVENT_TODO";
            }
            {
              enabled = 0;
              name = "FONTS";
            }
            {
              enabled = 0;
              name = "IMAGES";
            }
            {
              enabled = 0;
              name = "MENU_CONVERSION";
            }
            {
              enabled = 0;
              name = "MENU_DEFINITION";
            }
            {
              enabled = 0;
              name = "MENU_EXPRESSION";
            }
            {
              enabled = 0;
              name = "MENU_OTHER";
            }
            {
              enabled = 0;
              name = "MENU_SPOTLIGHT_SUGGESTIONS";
            }
            {
              enabled = 0;
              name = "MESSAGES";
            }
            {
              enabled = 0;
              name = "MOVIES";
            }
            {
              enabled = 0;
              name = "MUSIC";
            }
            {
              enabled = 0;
              name = "PDF";
            }
            {
              enabled = 0;
              name = "PRESENTATIONS";
            }
            {
              enabled = 0;
              name = "SPREADSHEETS";
            }
            {
              enabled = 0;
              name = "SYSTEM_PREFS";
            }
            {
              enabled = 0;
              name = "TIPS";
            }
          ];
        };
        # 通知センター
        "com.apple.ncprefs" = {
          # プレビューを表示 (0=常に, 1=ロックされていないときのみ, 2=しない)
          content_visibility = 1;
        };
        # .DS_Store ファイルを作成しない
        "com.apple.desktopservices" = {
          # ネットワークドライブ [default: false]
          DSDontWriteNetworkStores = true;
          # USB ドライブ [default: false]
          DSDontWriteUSBStores = true;
        };
        # Mission Control キーボードショートカット
        # 118: デスクトップ1へ切り替え, 119: デスクトップ2, 120: デスクトップ3
        # parameters: (ASCII code, key code, modifier) / 524288 = Option (Alt)
        # "com.apple.symbolichotkeys" = {
        #   AppleSymbolicHotKeys = {
        #     "118" = { enabled = 1; value = { parameters = [ 49 18 524288 ]; type = "standard"; }; };
        #     "119" = { enabled = 1; value = { parameters = [ 50 19 524288 ]; type = "standard"; }; };
        #     "120" = { enabled = 1; value = { parameters = [ 51 20 524288 ]; type = "standard"; }; };
        #   };
        # };
      };
    };

    # ==========================================================================
    # Additional settings via defaults write (not supported by nix-darwin options)
    # Note: postUserActivation was removed, now using postActivation with sudo -u
    # ==========================================================================
    activationScripts.postActivation.text = ''
      # ------------------------------------------
      # Spotlight indexing control (runs as root)
      # Toggle by uncommenting the desired option
      # ------------------------------------------
      # Enable Spotlight indexing [default]
      mdutil -a -i on 2>/dev/null || true
      # Disable Spotlight indexing (saves ~500MB RAM)
      # mdutil -a -i off 2>/dev/null || true

      # ------------------------------------------
      # バッテリー: スリープ中もネットワーク接続を維持 [default: 1]
      # Note: Requires root (pmset)
      # ------------------------------------------
      pmset -a tcpkeepalive 1

      # Run as user (not root)
      sudo -u ${username} bash -c '
        # ------------------------------------------
        # Keyboard: Custom shortcuts [default: none]
        # ウィンドウ->移動とサイズ変更->右 Ctrl + Option + .
        # ウィンドウ->移動とサイズ変更->左 Ctrl + Option + ,
        # Note: dict-add requires activation script (cannot use CustomUserPreferences)
        # ------------------------------------------
        defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add \
          $'"'"'\033ウィンドウ\033移動とサイズ変更\033右'"'"' "^~."
        defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add \
          $'"'"'\033ウィンドウ\033移動とサイズ変更\033左'"'"' "^~,"

        # ------------------------------------------
        # Lock Screen: Screensaver idle time 30 min (1800 sec) [default: 1200]
        # Note: -currentHost required for per-machine settings
        # ------------------------------------------
        defaults -currentHost write com.apple.screensaver idleTime -int 1800
      '
    '';

    # Set Git commit hash for darwin-hierarchical versioning
    configurationRevision = null;

    # Used for backwards compatibility
    # cf. https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG
    stateVersion = 6;
  };

  # ============================================================================
  # Manual Settings Required (cannot be automated)
  # ============================================================================
  # The following settings require manual configuration via System Settings:
  #
  # - Spotlight
  #     - システムからの結果
  #         - アプリ ON
  #     - その他の項目はすべて OFF
  # - アクセシビリティ
  #     - ポインタコントロール
  #         - トラックパッドオプション
  #             - ドラッグにトラックパッドを使用 ON
  #             - ドラッグ方法 3本指のドラッグ
  # - ディスプレイ
  #     - True Tone OFF (内蔵ディスプレイ使用時に出現する設定項目)
  #     - Night Shift
  #         - カスタム 5:00-4:59
  #         - 色温度 中央と右端の間
  # - デスクトップと Dock
  #     - Dock
  #         - 画面上の位置 任意
  #         - Dock を自動的に表示/非表示 任意
  #         - アプリの提案と最近使用したアプリを Dock に表示 OFF
  # - 通知
  #     - 通知センター OFF
  #     - アプリケーションの通知 システム系以外は OFF
  # - ロック画面
  #     - 時間設定 30分
  # - プライバシーとセキュリティ
  #     - 画面収録とシステムオーディオ録音
  #         - Web ブラウザ
  #         - Zoom
  # - ユーザとグループ
  #     - 管理者
  # - マウス
  #     - ナチュラルなスクロール OFF
  # - トラックパッド
  #     - スクロールとズーム
  #         - ナチュラルなスクロール OFF
}
