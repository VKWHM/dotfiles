{ config, pkgs, ... }:

let user = "whoami"; in

{
  imports = [
    ../../modules/darwin/home-manager.nix
    # ../../modules/shared
  ];

  nix = {
    package = pkgs.nix;

    settings = {
      trusted-users = [ "@admin" "${user}" ];
      # substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      # trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };

    gc = {
      automatic = true;
      interval = { Weekday = 1; Hour = 3; Minute = 30; };
      options = "--delete-older-than 30d";
    };

    extraOptions = ''
      experimental-features = nix-command flakes
    '';
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
        GloballyEnabled = true;
        HideDesktop = false;
        StageManagerHideWidgets = true;
      };

      # Firwall
      alf = {
        globalstate = 1;
        stealthenabled = 1;
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
      };
    };
    keyboard = {
      enableKeyMapping = true;
      # remapCapsLockToControl = true;
      remapCapsLockToControl = false;
    };
    tools = {
      darwin-rebuild.enable = true;
      darwin-version.enable = true;
      darwin-uninstaller.enable = true;
      darwin-option.enable = true;
    };
  };
}
