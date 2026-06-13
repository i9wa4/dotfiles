{
  pkgs,
  lib,
  username,
  commonNixSettings,
  ...
}:
let
  skhdConfig = ''
    # App switching: Alt + 1/2/3
    alt - 1 : open -a "kitty"
    alt - 2 : open -a "Google Chrome"
    alt - 3 : open -a "Obsidian"
  '';
  homebrewThirdPartyTaps = [
    "asmvik/formulae"
  ];
  homebrewBrews = [
    "asmvik/formulae/skhd"
  ];
in
{
  nixpkgs = {
    # Allow unfree packages (e.g., terraform with BSL license)
    config.allowUnfree = true;
    hostPlatform = "aarch64-darwin";
    overlays = [
      # TODO: Revert once nixpkgs-25.11-darwin ships a working direnv build.
      # WORKAROUND: direnv-2.37.1 checkPhase hangs at `fish ./test/direnv-test.fish`
      # in the Nix sandbox on aarch64-darwin, blocking darwin-rebuild switch.
      # Reproduced on multiple MacBooks. Runtime binary is fine; only the
      # upstream post-build test suite is broken, so skipping doCheck is safe.
      (_: prev: {
        direnv = prev.direnv.overrideAttrs (_: {
          doCheck = false;
        });
      })
    ];
  };

  # Nix settings
  nix = {
    settings = commonNixSettings // {
      experimental-features = "nix-command flakes";
      # Allow user to use extra substituters
      trusted-users = [
        "root"
        username
      ];
    };
    # Deduplicate files via hard links (scheduled, not per-build)
    # Note: auto-optimise-store is known to corrupt Nix Store on Darwin
    # Note: Disabled because large binaries are now Homebrew-managed,
    #       and scheduled optimise can cause syspolicyd high CPU
    # cf. `https://github.com/nix-darwin/nix-darwin/issues/1252`
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
  # NOTE: All features disabled - home-manager zsh.nix handles user config
  programs.zsh = {
    enable = true;
    enableCompletion = false;
    enableBashCompletion = false;
    enableGlobalCompInit = false;
    promptInit = "";
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

  # skhd: hotkey daemon for app switching.
  #
  # Run the Homebrew binary from a stable path. When skhd is launched directly
  # from the Nix store, nixpkgs updates can change the executable path and make
  # macOS TCC ask for Accessibility permission again.
  #
  # If Accessibility must be granted manually, add the resolved Cellar binary
  # (for example `/opt/homebrew/Cellar/skhd/<version>/bin/skhd`) instead of the
  # `/opt/homebrew/bin/skhd` symlink. A Homebrew skhd version upgrade may still
  # require granting the new Cellar binary once, but regular Nix updates will
  # no longer rotate the executable path.
  environment.etc."skhdrc".text = skhdConfig;
  launchd.user.agents.skhd = {
    serviceConfig = {
      ProgramArguments = [
        "/opt/homebrew/bin/skhd"
        "-c"
        "/etc/skhdrc"
      ];
      KeepAlive = true;
      RunAtLoad = true;
      ProcessType = "Interactive";
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
      };
    };
  };

  # Fonts
  fonts.packages = [
    pkgs.udev-gothic
  ];

  # Homebrew 5 requires explicit trust for non-official taps.
  system.activationScripts.extraActivation.text = lib.mkAfter ''
    if [ -x /opt/homebrew/bin/brew ]; then
      echo >&2 "trusting Homebrew taps..."
      ${lib.concatMapStringsSep "\n" (tap: ''
        sudo \
          --user=${lib.escapeShellArg username} \
          --set-home \
          env HOMEBREW_NO_AUTO_UPDATE=1 PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
          /opt/homebrew/bin/brew tap ${lib.escapeShellArg tap} >/dev/null
        sudo \
          --user=${lib.escapeShellArg username} \
          --set-home \
          env HOMEBREW_NO_AUTO_UPDATE=1 PATH="/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin" \
          /opt/homebrew/bin/brew trust --tap ${lib.escapeShellArg tap} >/dev/null
      '') homebrewThirdPartyTaps}
    fi
  '';

  # Homebrew
  # Allow activation-time metadata updates so Homebrew's cask API and portable
  # Ruby stay in sync before `brew bundle` resolves casks. Keep upgrades
  # disabled so `nix run '.#switch'` does not force app version bumps.
  homebrew = {
    enable = true;
    taps = homebrewThirdPartyTaps;
    brews = homebrewBrews;
    onActivation = {
      autoUpdate = true;
      upgrade = false;
      # Remove formulae/casks not listed in configuration
      cleanup = "uninstall";
      # Homebrew 4.7 requires an explicit confirmation mode with --cleanup.
      extraFlags = [ "--force-cleanup" ];
    };
  };

  # Power management
  power.sleep = {
    computer = "never"; # Idle time until the computer sleeps; "never" disables computer sleep.
    display = 30; # Idle time in minutes until displays sleep.
  };

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
      # Remap the Caps Lock key to Control.
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
        # Position of the dock on screen. The default is "bottom".
        orientation = "left";
        # Automatically hide and show the dock. The default is false.
        autohide = false;
        # Show recent applications in the dock. The default is true.
        show-recents = false;
        # Automatically rearrange spaces based on most recent use. The default is true.
        mru-spaces = false;
        # Size of the icons in the dock. The default is 64.
        tilesize = 48;
      };

      # ------------------------------------------------------------------------
      # Finder
      # ------------------------------------------------------------------------
      finder = {
        # Show path breadcrumbs in Finder windows. The default is false.
        ShowPathbar = true;
        # Always show file extensions. The default is false.
        AppleShowAllExtensions = true;
        # Allow quitting Finder. The default is false.
        QuitMenuItem = true;
      };

      # ------------------------------------------------------------------------
      # Global Domain (NSGlobalDomain)
      # ------------------------------------------------------------------------
      NSGlobalDomain = {
        # How fast a key repeats once it starts.
        KeyRepeat = 2;
        # How long a key must be held before it starts repeating.
        InitialKeyRepeat = 25;
        # Enable "Natural" scrolling direction. The default is true.
        # Note: macOS does not expose separate trackpad and mouse scrolling direction settings.
        # false = traditional PC-style scrolling direction.
        "com.apple.swipescrolldirection" = false;
        # Enable automatic spelling correction. The default is true.
        NSAutomaticSpellingCorrectionEnabled = false;
        # Enable automatic capitalization. The default is true.
        NSAutomaticCapitalizationEnabled = false;
        # Enable smart dash substitution. The default is true.
        NSAutomaticDashSubstitutionEnabled = false;
        # Enable smart period substitution. The default is true.
        NSAutomaticPeriodSubstitutionEnabled = false;
        # Enable smart quote substitution. The default is true.
        NSAutomaticQuoteSubstitutionEnabled = false;
        # Enable inline predictive text. The default is true.
        NSAutomaticInlinePredictionEnabled = false;
        # Animate opening and closing of windows and popovers. The default is true.
        NSAutomaticWindowAnimationsEnabled = false;
        # Trackpad tracking speed (0.0-3.0).
        "com.apple.trackpad.scaling" = 3.0;
      };

      # ------------------------------------------------------------------------
      # Trackpad
      # ------------------------------------------------------------------------
      trackpad = {
        # Enable tap to click. The default is false.
        Clicking = true;
        # Enable three-finger drag. The default is false.
        TrackpadThreeFingerDrag = true;
      };

      # ------------------------------------------------------------------------
      # Menu Bar Clock
      # ------------------------------------------------------------------------
      menuExtraClock = {
        # Show the full date. 0 = When space allows, 1 = Always, 2 = Never. Default is null.
        ShowDate = 1;
        # Show the day of the week. Default is null.
        ShowDayOfWeek = true;
        # Show the clock with second precision. Default is null.
        ShowSeconds = true;
      };

      # ------------------------------------------------------------------------
      # Control Center
      # ------------------------------------------------------------------------
      controlcenter = {
        # Show a Bluetooth control in the menu bar. Default is null.
        Bluetooth = true;
        # Show a battery percentage in the menu bar. Default is null.
        BatteryShowPercentage = true;
      };

      # ------------------------------------------------------------------------
      # Custom User Preferences (settings not available as nix-darwin options)
      # ------------------------------------------------------------------------
      CustomUserPreferences = {
        # Mouse tracking speed (0.0-3.0).
        # Note: Use CustomUserPreferences because this key does not work under NSGlobalDomain.
        ".GlobalPreferences" = {
          "com.apple.mouse.scaling" = 2.0;
        };
        # Accessibility > Display
        "com.apple.Accessibility" = {
          # Color Filters: Grayscale.
          GrayscaleDisplay = 1;
          # Differentiate without color.
          DifferentiateWithoutColor = 1;
          # Dim flashing lights.
          PhotosensitiveMitigation = 1;
          # Display button shapes.
          ButtonShapesEnabled = 1;
        };
        "com.apple.universalaccess" = {
          # Color Filters: Grayscale.
          grayscale = true;
          # Differentiate without color.
          differentiateWithoutColor = true;
          # Increase contrast.
          increaseContrast = false;
          # Show toolbar button shapes.
          showToolbarButtonShapes = false;
        };
        "com.apple.mediaaccessibility" = {
          # Enable color filters.
          "__Color__-MADisplayFilterCategoryEnabled" = 1;
          # Color filter type: Grayscale.
          "__Color__-MADisplayFilterType" = 1;
          # Color filter intensity slider.
          MADisplayFilterGrayscaleCorrectionIntensity = 0.5;
        };
        # Spotlight search results
        # Note: Enable only Applications; disable all other result categories.
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
        # Notification Center
        "com.apple.ncprefs" = {
          # Show previews. 0 = Always, 1 = When unlocked, 2 = Never.
          content_visibility = 1;
        };
        # Dictation
        "com.apple.HIToolbox" = {
          # Enable Dictation.
          AppleDictationAutoEnable = 1;
        };
        # Do not create .DS_Store files.
        "com.apple.desktopservices" = {
          # Network drives.
          DSDontWriteNetworkStores = true;
          # USB drives.
          DSDontWriteUSBStores = true;
        };
        # Mission Control keyboard shortcuts
        # 118: Switch to Desktop 1, 119: Switch to Desktop 2, 120: Switch to Desktop 3
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
        # Window > Move & Resize > Right: Ctrl + Option + .
        # Window > Move & Resize > Left: Ctrl + Option + ,
        # Note: dict-add requires activation script (cannot use CustomUserPreferences)
        # ------------------------------------------
        defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add \
          $'"'"'\033ウィンドウ\033移動とサイズ変更\033右'"'"' "^~."
        defaults write NSGlobalDomain NSUserKeyEquivalents -dict-add \
          $'"'"'\033ウィンドウ\033移動とサイズ変更\033左'"'"' "^~,"

        # ------------------------------------------
        # Dictation: press the Globe key twice to start Dictation.
        # Note: dict-add updates only key 164, preserving other shortcuts.
        # Note: macOS 26 uses a modifier hotkey entry for Fn/Globe twice.
        # ------------------------------------------
        defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "164" \
          '"'"'<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>262144</integer><integer>9223372036854775807</integer></array><key>type</key><string>modifier</string></dict></dict>'"'"'

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
  # - バッテリー
  #     - 充電
  #         - 充電上限 95%
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
