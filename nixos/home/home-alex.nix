{ config, pkgs, ... }:
{

  home.stateVersion = "25.11";

  imports = [ ];

  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
          set -g fish_greeting ""
        '';
      shellAliases = {
        shx = "sudo hx -c $HOME/.config/helix/config.toml";
        addkey = "ssh-add ~/.ssh/id_ed25519";
      };
      functions = {
        yy = ''
          set tmp (mktemp -t "yazi-cwd.XXXXXX")
        	yazi $argv --cwd-file="$tmp"
        	if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        		builtin cd -- "$cwd"
        	end
        	rm -f -- "$tmp"
          '';
      };
    };
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
        user = {
          name = "Alexander Gallardo";
          email = "alexander6432@gmail.com";
        };
        init = {
          defaultBranch = "main";
        };
        core = {
          editor = "hx";
        };
        pull = {
          rebase = false;
        };
        push = {
          autoSetupRemote = true;
        };
      };
    };
    ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "github.com" = {
          user = "git";
          identityFile = "~/.ssh/id_ed25519";
          identitiesOnly = true;
          extraOptions = {
            AddKeysToAgent = "yes";
          };
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

  # yazi
  fd
  ffmpeg
  imagemagick
  jq
  p7zip
  poppler
  resvg
  ripgrep
  trash-cli
  zoxide

  # apps
  ];
}
