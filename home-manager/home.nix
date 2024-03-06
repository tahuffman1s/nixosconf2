{ lib, config, pkgs, ... }: {

  # Set state versions for packages.
  home.stateVersion = "23.11";

  # Allow unfree packages for VsCode.
  nixpkgs.config.allowUnfree = true;

  # Import NUR for easily setting firefox extensions.
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  # Setup NerdFonts
  fonts.fontconfig.enable = true;
  home.packages = [
    (pkgs.nerdfonts.override { fonts = [ "Hack" "FiraCode" ]; })
  ];

  /* This is where I define program configurations. Most people take a modular approach, 
    and import them I prefer to have them all in one file. */

  # VsCode
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;
    enableExtensionUpdateCheck = true;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      vscodevim.vim
      esbenp.prettier-vscode
      ms-vscode.cpptools
      ms-dotnettools.csharp
      ms-python.python
      eamodio.gitlens
      oderwat.indent-rainbow
      jnoortheen.nix-ide
      foxundermoon.shell-format
    ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      {
        name = "remote-ssh-edit";
        publisher = "ms-vscode-remote";
        version = "0.47.2";
        sha256 = "1hp6gjh4xp2m1xlm1jsdzxw9d8frkiidhph6nvl24d0h8z34w49g";
      }
      {
        name = "code-d";
        publisher = "webfreak";
        version = "0.23.2";
        sha256 = "v/Dck4gE9kRkfIWPAkUmPqewyTVVKrBgAjpNuCROClE=";
      }
      {
        name = "breeze";
        publisher = "kde";
        version = "0.0.4";
        sha256 = "3kFeBPBXhta8U9gollO6+anMmmE8OD3vDlVvsMbBtoU=";
      }
    ];
    userSettings = {
      "window.autoDetectColorScheme" = true;
      "window.menuBarVisibility" = "toggle";
      "workbench.colorTheme" = "Breeze Dark";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "rnix-lsp";
      "editor.formatOnPaste" = true;
      "editor.formatOnSave" = true;
      "git.autofetch" = true;
      "git.confirmSync" = false;
      "git.enableSmartCommit" = true;
      "security.workspace.trust.untrustedFiles" = "open";
    };
  };

  # Firefox
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      OfferToSaveLogins = false;
      OfferToSaveLoginsDefault = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      FirefoxHome = {
        TopSites = false;
        SponsoredTopSites = false;
        Highlights = false;
        Pocket = false;
        SponsoredPocket = false;
        Snippets = false;
        Locked = true;
      };
      SearchEngines = {
        PreventInstalls = true;
      };
      DisableFormHistory = false;
    };
    profiles = {
      default = {
        extensions = with pkgs.nur.repos.rycee.firefox-addons; [
          ublock-origin
          proton-pass
          privacy-badger
          clearurls
        ];
        search = {
          force = true;
          default = "StartPage";
          engines = {
            "StartPage" = {
              urls = [{ template = "https://www.startpage.com/sp/search?q={searchTerms}"; }];
              iconUpdateURL = "https://www.startpage.com/sp/cdn/favicons/favicon--default.ico";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@sp" ];
            };
            "Brave" = {
              urls = [{ template = "https://search.brave.com/search?q={searchTerms}"; }];
              iconUpdateURL = "https://cdn.icon-icons.com/icons2/2552/PNG/512/brave_browser_logo_icon_153013.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@br" ];
            };
            "Proton DB" = {
              urls = [{ template = "https://www.protondb.com/search?q={searchTerms}"; }];
              iconUpdateURL = "https://www.protondb.com/sites/protondb/images/site-logo.svg";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@pr" ];
            };
            "Nix Packages" = {
              urls = [{
                template = "https://search.nixos.org/packages";
                params = [
                  { name = "type"; value = "packages"; }
                  { name = "query"; value = "{searchTerms}"; }
                ];
              }];
              icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
              definedAliases = [ "@np" ];
            };
            "NixOS Wiki" = {
              urls = [{ template = "https://nixos.wiki/index.php?search={searchTerms}"; }];
              iconUpdateURL = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000;
              definedAliases = [ "@nw" ];
            };
            "DuckDuckGo".metaData.alias = "@dg";
            "Wikipedia (en)".metaData.alias = "@wiki";
            "Google".metaData.hidden = true;
            "Amazon.com".metaData.hidden = true;
            "Bing".metaData.hidden = true;
            "eBay".metaData.hidden = true;
          };
        };
      };
    };
  };

  # Zsh
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -l";
      update = "sudo nixos-rebuild switch";
      wipegarbage = "sudo nix-collect-garbage && sudo nix-collect-garbage -d && sudo nixos-rebuild switch";
      fixmonitors = "nvidia-settings --assign CurrentMetaMode=\"DP-4: 2560x1440_165 +2560+0 { ForceFullCompositionPipeline = On } , DP-2: 2560x1440_165 +0+0\" && xrandr --output DP-2 --primary";
      fixmenu = "rm ~/.cache/ksycoca6_* -rf && kbuildsycoca6";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [ "git" ];
    };
    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
      {
        name = "powerlevel10k-config";
        src = lib.cleanSource ../p10k;
        file = "p10k.zsh";
      }
    ];
  };
}
