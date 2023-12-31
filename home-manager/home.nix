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
    mutableExtensionsDir = true;
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
      dracula-theme.theme-dracula
    ];
    userSettings = {
      "window.autoDetectColorScheme" = true;
      "window.titleBarStyle" = "custom";
      "workbench.colorTheme" = "Dracula";
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "rnix-lsp";
      "editor.formatOnPaste" = true;
      "editor.formatOnSave" = true;
      "git.autofetch" = true;
      "git.confirmSync" = false;
      "git.enableSmartCommit" = true;
    };
  };

  # Firefox
  programs.firefox = {
    enable = true;
    package = pkgs.firefox;
    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
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
          default = "Brave";
          engines = {
            "Brave" = {
              urls = [{ template = "https://search.brave.com/search?q={searchTerms}"; }];
              iconUpdateURL = "https://cdn.icon-icons.com/icons2/2552/PNG/512/brave_browser_logo_icon_153013.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = [ "@br" ];
            };
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
    ];
  };
}
