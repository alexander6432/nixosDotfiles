{ config, pkgs, pkgs-unstable, ... }:
{

  home.stateVersion = "25.11";

  imports = [
    ./alex/fish.nix
  ];

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
