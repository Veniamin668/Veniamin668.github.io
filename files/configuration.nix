{ config, lib, pkgs, ... }:

{
  imports = [ 
    ./hardware-configuration.nix 
  ];

  # Настройка загрузчика GRUB для старого BIOS (Legacy)
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda"; # ЗАМЕНИТЕ на ваш диск, если он называется иначе!

  # Использование свежего ядра (как вы и хотели)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Настройка сети и NetworkManager (интернет по кабелю и Wi-Fi)
  networking.hostName = "nixoser"; 
  networking.networkmanager.enable = true;

  # Настройка времени и локализации (язык системы и консоли)
  time.timeZone = "Asia/Yekaterinburg"; # Замените на свой часовой пояс, если нужно
  i18n.defaultLocale = "ru_RU.UTF-8";

  console = {
    font = "Lat2-Terminus16";
    keyMap = "ru"; # Раскладка в консоли по умолчанию
  };

  # Разрешаем установку проприетарных драйверов (нужно для некоторых Wi-Fi модулей)
  nixpkgs.config.allowUnfree = true;

  # Создание основного пользователя
  users.users.venik = { # Вместо "student" можно написать ваш ник латиницей
    isNormalUser = true;
    description = "NixOS Learner";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ]; # wheel дает права sudo
  };

  # Базовый набор программ, чтобы не остаться в пустой консоли
  environment.systemPackages = with pkgs; [
    vim
    nano
    wget
    curl
    git
    htop # Красивый монитор ресурсов
    pciutils # Утилита lspci для проверки железа
    fastfetch
    openssh
    btop
    mc
    smartmontools
    aria2
    darkhttpd
    python3Minimal
    fzf
    bat
    iperf3
    cmatrix
  ];

  # Автоматическая копия конфига в готовую систему (полезно при обучении)
  system.copySystemConfiguration = true;

  # Оставляем вашу версию системы (не менять)
  system.stateVersion = "26.05"; 
  services.openssh.enable = true;
  swapDevices = [ { device = "/swapfile"; size = 2048; } ];
  services.openssh.settings.PermitRootLogin = "yes";
  zramSwap.enable = true;
  services.logind.settings.Login.HandleLidSwitch = "ignore";
  networking.firewall.enable = false;
}
