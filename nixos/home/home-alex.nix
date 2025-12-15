{ inputs, config, pkgs, pkgs-unstable, ... }:
{

  home.stateVersion = "25.11";

  imports = [
    ./alex/fish.nix
  ];

  services.polkit-gnome.enable = true;

  programs = {
    starship = {
      enable = true;
    };
    zoxide = {
      enable = true;
      enableFishIntegration = true;
    };
    yazi = {
      enable = true;
    };
    git = {
      enable = true;
      settings = {
        user.name = "Alexander Gallardo";
        user.email = "alexander6432@gmail.com";
        init.defaultBranch = "main";
        core.editor = "hx";
        pull.rebase = false;
        push.autoSetupRemote = true;
      };
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      extraConfig = ''
        AddKeysToAgent yes
      '';
      matchBlocks = {
        "*" = {
          identitiesOnly = true;
        };
        "github.com" = {
           user = "git";
           identityFile = "~/.ssh/id_ed25519";
        };
      };
    };
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs
        obs-backgroundremoval
        obs-move-transition
        obs-pipewire-audio-capture
        obs-shaderfilter
        obs-composite-blur
      ];
    };
    vscode = {
      enable = true;
      package = pkgs.vscode;
    };
  };

  services.ssh-agent.enable = true;

  home.packages = with pkgs; [

  # terminal
  bat
  fastfetch
  htop
  lazygit
  tree
  wl-clipboard

  # yazi
  fd
  ffmpeg
  imagemagick
  jq
  poppler
  resvg
  ripgrep
  trash-cli

  # apps
  gnome-disk-utility
  microsoft-edge
  zoom-us
  ventoy-full-gtk
  webex
  droidcam

  ] ++ (with pkgs-unstable; [

  # helix
  helix
  bash-language-server
  fish-lsp
  kdlfmt
  nil
  nixd
  taplo
  tombi
  vscode-json-languageserver

  ]);
}
