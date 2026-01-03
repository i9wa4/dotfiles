{
  pkgs,
  username,
  ...
}: {
  # Primary user (required for user-specific system.defaults options)
  system.primaryUser = username;

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
      interval = { Weekday = 0; Hour = 3; Minute = 0; };
      options = "--delete-older-than 7d";
    };
  };

  # Enable zsh (creates /etc/zshenv for nix-darwin environment)
  programs.zsh.enable = true;

  # System packages
  environment.systemPackages = [
    pkgs.vim
    # GUI applications (via brew-nix overlay, symlinked to /Applications/Nix Apps/)
    # NOTE: google-chrome, openvpn-connect are managed via Homebrew due to hash mismatch/xar issues
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
  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = true;
      upgrade = true;
    };
    casks = [
      # NOTE: Only apps with brew-nix issues (hash mismatch/xar errors) go here
      "google-chrome"
      "openvpn-connect"
    ];
  };

  # ============================================================================
  # Keyboard
  # ============================================================================
  system.keyboard = {
    enableKeyMapping = true;
    # Caps Lock -> Control (内蔵キーボード) [default: false]
    remapCapsLockToControl = true;
  };

  # ============================================================================
  # macOS System Defaults
  # cf. https://i9wa4.github.io/blog/2024-06-17-setup-mac.html
  # ============================================================================

  system.defaults = {
    # --------------------------------------------------------------------------
    # Dock
    # --------------------------------------------------------------------------
    dock = {
      # 画面上の位置 (left/bottom/right) [default: "bottom"]
      orientation = "left";
      # Dock を自動的に表示/非表示 [default: false]
      autohide = false;
      # アプリの提案と最近使用したアプリを Dock に表示 [default: true]
      show-recents = false;
      # 最新の使用状況に基づいて操作スペースを自動的に並べ替える [default: true]
      mru-spaces = false;
    };

    # --------------------------------------------------------------------------
    # Finder
    # --------------------------------------------------------------------------
    finder = {
      # パスバーを表示 [default: false]
      ShowPathbar = true;
      # 拡張子を表示 [default: false]
      AppleShowAllExtensions = true;
      # Finder 終了メニューを表示 [default: false]
      QuitMenuItem = true;
      # デフォルトの表示形式 (icnv=アイコン, Nlsv=リスト, clmv=カラム, glyv=ギャラリー) [default: "icnv"]
      FXPreferredViewStyle = "Nlsv";
    };

    # --------------------------------------------------------------------------
    # Global Domain (NSGlobalDomain)
    # --------------------------------------------------------------------------
    NSGlobalDomain = {
      # キーリピート速度 (小さいほど速い) [default: 6]
      KeyRepeat = 2;
      # キーリピート開始までの時間 (小さいほど速い) [default: 25]
      InitialKeyRepeat = 15;
      # ナチュラルなスクロール [default: true]
      # "com.apple.swipescrolldirection" = false;
      "com.apple.swipescrolldirection" = true;
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
      # トラックパッド速度 (0.0-3.0) [default: 1.0]
      "com.apple.trackpad.scaling" = 3.0;
    };

    # --------------------------------------------------------------------------
    # Trackpad
    # --------------------------------------------------------------------------
    trackpad = {
      # タップでクリック [default: false]
      Clicking = true;
      # 3本指のドラッグ (アクセシビリティ > ポインタコントロール > トラックパッドオプション) [default: false]
      TrackpadThreeFingerDrag = true;
    };

    # --------------------------------------------------------------------------
    # Menu Bar Clock
    # --------------------------------------------------------------------------
    menuExtraClock = {
      # 日付を表示 (0=表示しない, 1=数字, 2=曜日と日付) [default: 0]
      ShowDate = 1;
      # 曜日を表示 [default: false]
      ShowDayOfWeek = true;
      # 秒を表示 [default: false]
      ShowSeconds = true;
    };

    # --------------------------------------------------------------------------
    # Control Center
    # --------------------------------------------------------------------------
    controlcenter = {
      # Bluetooth をメニューバーに表示 [default: false]
      Bluetooth = true;
      # バッテリーの割合 (%) を表示 [default: false]
      BatteryShowPercentage = true;
    };

    # --------------------------------------------------------------------------
    # Custom User Preferences (settings not available as nix-darwin options)
    # --------------------------------------------------------------------------
    CustomUserPreferences = {
      "com.apple.finder" = {
        # サイドバーを表示 [default: true]
        ShowSidebar = true;
      };
      "com.apple.WindowManager" = {
        # 壁紙をクリックしてデスクトップを表示 [default: true (常に)]
        # false = ステージマネージャー使用時のみ
        EnableStandardClickToShowDesktop = true;
      };
      # 日本語入力 (ローマ字入力)
      "com.apple.inputmethod.Kotoeri" = {
        # ライブ変換 [default: 1 (ON)]
        JIMPrefLiveConversionKey = 0;
        # タイプミスを修正 [default: 0 (OFF)]
        JIMPrefAutocorrectionKey = 1;
      };
      # Spotlight 検索結果
      # Note: アプリのみ有効、その他は OFF
      "com.apple.Spotlight" = {
        orderedItems = [
          { enabled = 1; name = "APPLICATIONS"; }
          { enabled = 0; name = "MENU_EXPRESSION"; }
          { enabled = 0; name = "CONTACT"; }
          { enabled = 0; name = "MENU_CONVERSION"; }
          { enabled = 0; name = "MENU_DEFINITION"; }
          { enabled = 0; name = "DOCUMENTS"; }
          { enabled = 0; name = "EVENT_TODO"; }
          { enabled = 0; name = "DIRECTORIES"; }
          { enabled = 0; name = "FONTS"; }
          { enabled = 0; name = "IMAGES"; }
          { enabled = 0; name = "MESSAGES"; }
          { enabled = 0; name = "MOVIES"; }
          { enabled = 0; name = "MUSIC"; }
          { enabled = 0; name = "MENU_OTHER"; }
          { enabled = 0; name = "PDF"; }
          { enabled = 0; name = "PRESENTATIONS"; }
          { enabled = 0; name = "MENU_SPOTLIGHT_SUGGESTIONS"; }
          { enabled = 0; name = "SPREADSHEETS"; }
          { enabled = 0; name = "SYSTEM_PREFS"; }
          { enabled = 0; name = "TIPS"; }
          { enabled = 0; name = "BOOKMARKS"; }
        ];
      };
      # Mission Control キーボードショートカット
      # 118: デスクトップ1へ切り替え, 119: デスクトップ2, 120: デスクトップ3
      # parameters: (ASCII code, key code, modifier) / 524288 = Option (Alt)
      "com.apple.symbolichotkeys" = {
        AppleSymbolicHotKeys = {
          "118" = { enabled = 1; value = { parameters = [ 49 18 524288 ]; type = "standard"; }; };
          "119" = { enabled = 1; value = { parameters = [ 50 19 524288 ]; type = "standard"; }; };
          "120" = { enabled = 1; value = { parameters = [ 51 20 524288 ]; type = "standard"; }; };
        };
      };
    };
  };

  # ============================================================================
  # Additional settings via defaults write (not supported by nix-darwin options)
  # Note: postUserActivation was removed, now using postActivation with sudo -u
  # ============================================================================
  system.activationScripts.postActivation.text = ''
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
      # Finder: Reset icon view settings to defaults
      # Prevents accidental changes from persisting
      # Note: delete + complex plist requires activation script
      # ------------------------------------------
      defaults delete com.apple.finder FK_DefaultIconViewSettings 2>/dev/null || true
      defaults write com.apple.finder StandardViewSettings -dict-add IconViewSettings "
        <dict>
          <key>arrangeBy</key><string>none</string>
          <key>gridSpacing</key><integer>54</integer>
          <key>iconSize</key><integer>64</integer>
          <key>labelOnBottom</key><true/>
          <key>showIconPreview</key><true/>
          <key>showItemInfo</key><false/>
          <key>textSize</key><integer>12</integer>
          <key>viewOptionsVersion</key><integer>1</integer>
        </dict>
      "
    '
  '';

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
  #     - Night Shift
  #         - カスタム 5:00-4:59
  #         - 色温度 中央と右端の間
  # - 通知
  #     - 通知センター
  #         - プレビューを表示 ロックされていないときのみ表示
  #         - 通知を表示 OFF
  # - ロック画面
  #     - 時間設定 30分
  # - プライバシーとセキュリティ
  #     - 画面収録とシステムオーディオ録音
  #         - Web ブラウザ
  #         - Zoom
  # - キーボード
  #     - 音声入力 OFF

  # Set Git commit hash for darwin-hierarchical versioning
  system.configurationRevision = null;

  # Used for backwards compatibility
  # cf. https://github.com/nix-darwin/nix-darwin/blob/master/CHANGELOG
  system.stateVersion = 6;

  # Platform
  nixpkgs.hostPlatform = "aarch64-darwin";
}
