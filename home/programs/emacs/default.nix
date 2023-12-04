{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs29-pgtk;
    extraConfig = ''
              (org-babel-load-file (expand-file-name "config.org" user-emacs-directory))	
      	'';
  };

  xdg.configFile."emacs/config.org".source = ./config.org;

  services.emacs.enable = true;
}
