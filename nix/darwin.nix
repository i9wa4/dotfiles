{
  pkgs,
  username,
  ...
}: {
  # Nix settings
  nix = {
    settings.experimental-features = "nix-command flakes";
    # Deduplicate files via hard links (scheduled, not per-build)
    # Note: auto-optimise-store is known to corrupt Nix Store on Darwin
    # cf. https://github.com/nix-darwin/nix-darwin/issues/1252
    optimise.automatic = true;
    # Garbage collection (weekly on Sunday, delete older than 7 days)
    # cf. https://mynixos.com/nix-darwin/option/nix.gc.interval
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 3;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };
  };

  # Enable zsh (creates /etc/zshenv for nix-darwin environment)
  programs.zsh.enable = true;

  # System packages
  environment.systemPackages = [
    pkgs.vim
    # GUI applications (via brew-nix overlay, symlinked to /Applications/Nix Apps/)
    # NOTE: google-chrome, openvpn-connect are in Homebrew (hash mismatch/xar errors)
    pkgs.brewCasks.drawio
    pkgs.brewCasks.visual-studio-code
    pkgs.brewCasks.wezterm
    pkgs.brewCasks.zoom
  ];

  # Fonts
  fonts.packages = [
    pkgs.udev-gothic
  ];

  # Homebrew (only for apps with frequent updates / hash issues)
  # NOTE: Currently all GUI apps are managed via brew-nix
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
    };
    casks = [
      # Add apps here if brew-nix has issues (hash mismatch/xar errors)
      "google-chrome"
      "openvpn-connect"
    ];
  };

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
        # マウス速度 (0.0-3.0) [default: 1.0]
        "com.apple.mouse.scaling" = 2.0;
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
      # Run as user (not root)
      sudo -u ${username} bash -c '
        # ------------------------------------------
        # Keyboard: Custom shortcuts [default: none]
        # ウィンドウ->移動とサイズ変更->右 Ctrl + Cmd + L
        # ウィンドウ->移動とサイズ変更->左 Ctrl + Cmd + H
        # Note: dict-add requires activation script (cannot use CustomUserPreferences)
        # ------------------------------------------
        defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add \
          $'"'"'\033ウィンドウ\033移動とサイズ変更\033右'"'"' "@^l"
        defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add \
          $'"'"'\033ウィンドウ\033移動とサイズ変更\033左'"'"' "@^h"

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
  # cf. https://i9wa4.github.io/blog/2024-06-17-setup-mac.html
  #
  # - バッテリー
  #     - バッテリーの状態
  #         - バッテリー充電の最適化
  # - ディスプレイ
  #     - 内蔵ディスプレイ 1900 x 1200
  #     - Night Shift
  #         - カスタム 5:00-4:59
  #         - 色温度 中央と右端の間
  # - 通知
  #     - 通知センター
  #         - 通知を表示
  #             - ディスプレイがスリープ中のとき OFF
  #             - 画面がロックされているとき OFF
  #             - ディスプレイをミラーリング中または共有中 通知オフ
  # - プライバシーとセキュリティ
  #     - 画面収録とシステムオーディオ録音
  #         - Web ブラウザ
  #         - Zoom
  # - キーボード
  #     - 音声入力 OFF
}
