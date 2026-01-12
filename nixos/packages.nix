{ inputs, config, pkgs, pkgs-unstable, ... }:
{

  # Install firefox.
  programs = {
     nix-ld = {
      enable = true;
      libraries = with pkgs; [
        gtk3
        pango
        cairo
        harfbuzz
        atk
        gdk-pixbuf
        glib
        libepoxy
        fontconfig
      ];
    };
    firefox.enable = true;
    fish.enable = true;
    niri = {
      enable = true;
      package = pkgs-unstable.niri;
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-gtk3-1.1.07"
  ];


    # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget

  # niri
  fzf
  xwayland-satellite
  swayidle
  brightnessctl

  # apps
  firefox
  google-chrome
  kitty
  libreoffice-fresh
  telegram-desktop
  inkscape
  krita
  gimp
  darktable
  libsForQt5.xp-pen-deco-01-v2-driver

  #ortografia libreoffice
  hunspell
  hunspellDicts.es-mx
  hunspellDicts.es-any
  hunspellDicts.en-us
  hunspellDicts.en-us-large
  hyphen
  hyphenDicts.en-us
  mythes
  languagetool

  # gnome
  showtime
  papers
  loupe
  gnome-calculator
  simple-scan
  nautilus
  file-roller
  decibels
  gnome-text-editor
  gnome-calendar

  # utilidades
  curl
  wget
  git
  rar
  unrar
  p7zip
  zip
  unzip

  ] ++ (with pkgs-unstable; [

  # noctalia shell
  inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  # inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.override { calendarSupport = true; }
  cava
  cliphist
  kdePackages.polkit-kde-agent-1
  matugen
  wlsunset
  xdg-desktop-portal

  kdePackages.qt6ct
  nwg-look
  adw-gtk3

  (python3.withPackages (pyPkgs: with pyPkgs; [ pygobject3 ]))

  ]);

}
