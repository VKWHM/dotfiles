{
  config,
  pkgs,
  ...
}: let
  user = "vkwhm";
in {
  imports = [
    ../../modules/darwin/home-manager.nix
    # ../../modules/shared
  ];

  nix = {
    package = pkgs.nix;

    settings = {
      trusted-users = ["@admin" "${user}"];
      # substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      # trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    gc = {
      automatic = true;
      interval = { Weekday = 1; Hour = 13; Minute = 30; };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };

  networking.applicationFirewall = {
    enableStealthMode = true;
  };

  system = {
    stateVersion = 6;

    defaults = {
      ".GlobalPreferences"."com.apple.sound.beep.sound" = "/System/Library/Sounds/Glass.aiff";
      ActivityMonitor.IconType = 2;
      CustomUserPreferences = {
        NSGlobalDomain = {
          TISRomanSwitchState = 1;
          WebKitDeveloperExtras = true;
          "com.apple.trackpad.scaling" = 1;
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.Safari" = {
          # Privacy: don’t send search queries to Apple
          UniversalSearchEnabled = false;
          SuppressSearchSuggestions = true;
          # Prevent Safari from opening ‘safe’ files automatically after downloading
          AutoOpenSafeDownloads = false;
          IncludeDevelopMenu = true;
          WebKitDeveloperExtrasEnabledPreferenceKey = true;
          WebContinuousSpellCheckingEnabled = true;
          WebAutomaticSpellingCorrectionEnabled = false;
          WebKitJavaEnabled = false;
        };
      };
      NSGlobalDomain = {
        AppleShowAllExtensions = true;
        AppleShowScrollBars = "WhenScrolling";

        KeyRepeat = 2; # Values: 120, 90, 60, 30, 12, 6, 2
        InitialKeyRepeat = 15; # Values: 120, 94, 68, 35, 25, 15

        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;

        "com.apple.mouse.tapBehavior" = 1;
      };
      SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

      # Window
      WindowManager = {
        GloballyEnabled = false;
        HideDesktop = false;
        StageManagerHideWidgets = false;
      };

      dock = {
        autohide = false;
        largesize = 64;
        launchanim = true;
        magnification = true;
        mineffect = "genie";
        minimize-to-application = true;
        mouse-over-hilite-stack = true;
        orientation = "bottom";
        tilesize = 48;
        wvous-bl-corner = 10;
        persistent-apps = [
          {app = "/System/Applications/App Store.app/";}
          {app = "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app/";}
          {app = "/System/Applications/Calendar.app/";}
          {app = "/System/Applications/System Settings.app/";}
          # { spacer = { small = true; }; }
          {app = "/System/Applications/Music.app/";}
          {app = "/System/Applications/Books.app/";}
          {app = "/System/Applications/Messages.app/";}
          {app = "/System/Applications/Facetime.app/";}
          # { spacer = { small = true; }; }
          {app = "/System/Applications/Mail.app/";}
          {app = "/Applications/WhatsApp.app/";}
          {app = "/Applications/Telegram.app/";}
          {spacer = {small = true;};}
          {app = "/Applications/Ghostty.app/";}
          {app = "/Applications/Obsidian.app/";}
          {app = "/Applications/Zed.app/";}
          {app = "/Applications/Firefox.app/";}
          {app = "/Applications/Burp Suite Community Edition.app/";}
          {app = "/Applications/Caido.app/";}
        ];
        persistent-others = [
          "${config.users.users.${user}.home}/Downloads"
          "${config.users.users.${user}.home}"
        ];
      };

      finder = {
        _FXSortFoldersFirst = true;
        FXPreferredViewStyle = "clmv";
        FXRemoveOldTrashItems = true;
        NewWindowTarget = "Home";
        ShowStatusBar = true;
        ShowPathbar = true;
      };

      hitoolbox.AppleFnUsageType = "Change Input Source";

      loginwindow.GuestEnabled = false;

      trackpad = {
        Clicking = true;
        TrackpadThreeFingerDrag = true;
        TrackpadThreeFingerTapGesture = 2;
      };
    };
    keyboard = {
      enableKeyMapping = true;
    };
    tools = {
      darwin-rebuild.enable = true;
      darwin-version.enable = true;
      darwin-uninstaller.enable = true;
      darwin-option.enable = true;
    };
  };
}
