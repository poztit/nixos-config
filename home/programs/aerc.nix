{
  programs.aerc = {
    enable = true;
    extraConfig = {
      general.unsafe-accounts-conf = true;
      ui = {
        index-columns = "date<25,flags>4,name<30,subject<*";
        timestamp-format = "Mon Jan _2 15:04:05 2006";
        sidebar-width = 25;
        dirlist-tree = true;
        sort = "from -r arrival";
        fuzzy-complete = true;
        threading-enabled = true;
        styleset-name = "modus";
      };
      viewer = {
        pager = "less -Rs";
        alternatives = "text/plain,text/html";
      };
      compose = {
        editor = "nvim";
        address-book-cmd = "khard email --parsable --remove-first-line --search-in-source-files '%s'";
      };
      filters = {
        "text/plain" = "colorize";
        "text/calendar" = "calendar";
        "message/delivery-status" = "colorize";
        "message/rfc822" = "colorize";
        "text/html" = "html | colorize";
        ".header" = "colorize";
      };
      templates = {
        quoted-reply = "quoted-reply";
        forwards = "forwards";
      };
    };
    templates = {
      quoted-reply = ''
        X-Mailer: aerc {{version}}

        On {{dateFormat (.OriginalDate | toLocal) "Mon Jan _2 15:04:05 2006"}}, {{(index .OriginalFrom 0).Address}} wrote:
        {{if eq .OriginalMIMEType "text/html"}}
        {{exec `/usr/local/libexec/aerc/filters/html` .OriginalText | quote}}
        {{else}}
        {{wrap 100 .OriginalText | trimSignature | quote}}
        {{end}}'';
      forwards = ''
        X-Mailer: aerc {{version}}

        Forwarded message from {{(index .OriginalFrom 0).Address}} on {{dateFormat .OriginalDate "Mon Jan _2 15:04:05 2006"}}:
        {{.OriginalText}}
        {{if eq .OriginalMIMEType "text/html"}}
        {{exec `/usr/local/libexec/aerc/filters/html` .OriginalText | quote}}
        {{else}}
        {{wrap 100 .OriginalText | trimSignature | quote}}
        {{end}}'';
    };
    stylesets.modus = ''
      *.default=true
      *.selected.bg=#303a6f
      default.bg=#0d0e1c
      default.fg=#ffffff
      dirlist_default.bg=#1d2235
      dirlist_default.selected.bg=#4a4f6a
      dirlist_unread.bold=true
      msglist_unread.bold=true
      border.bg=#61647b
      tab.bg=#4a4f6a
      tab.selected.bg=#0d0e1c
      tab.selected.bold=true
      statusline_default.bg=#484d67
      statusline_default.fg=#ffffff

      [viewer]
      url.fg=#2fafff
    '';
    extraBinds = ''
      # Binds are of the form <key sequence> = <command to run>
      # To use '=' in a key sequence, substitute it with "Eq": "<Ctrl+Eq>"
      # If you wish to bind #, you can wrap the key sequence in quotes: "#" = quit
      <C-p> = :prev-tab<Enter>
      <C-n> = :next-tab<Enter>
      <C-t> = :term<Enter>
      ? = :help keys<Enter>

      [messages]
      q = :quit<Enter>

      j = :next<Enter>
      <Down> = :next<Enter>
      <C-d> = :next 50%<Enter>
      <C-f> = :next 100%<Enter>
      <PgDn> = :next 100%<Enter>

      k = :prev<Enter>
      <Up> = :prev<Enter>
      <C-u> = :prev 50%<Enter>
      <C-b> = :prev 100%<Enter>
      <PgUp> = :prev 100%<Enter>
      g = :select 0<Enter>
      G = :select -1<Enter>

      J = :next-folder<Enter>
      K = :prev-folder<Enter>
      H = :collapse-folder<Enter>
      L = :expand-folder<Enter>

      v = :mark -t<Enter>
      V = :mark -v<Enter>

      T = :toggle-threads<Enter>

      <Enter> = :view<Enter>
      d = :prompt 'Really delete this message?' 'delete-message'<Enter>
      D = :delete<Enter>
      A = :archive flat<Enter>

      C = :compose<Enter>

      rr = :reply -a<Enter>
      rq = :reply -aq<Enter>
      Rr = :reply<Enter>
      Rq = :reply -q<Enter>

      c = :cf<space>
      $ = :term<space>
      ! = :term<space>
      | = :pipe<space>

      / = :search<space>
      \ = :filter<space>
      n = :next-result<Enter>
      N = :prev-result<Enter>
      <Esc> = :clear<Enter>

      [messages:folder=Drafts]
      <Enter> = :recall<Enter>

      [view]
      / = :toggle-key-passthrough<Enter>/
      q = :close<Enter>
      O = :open<Enter>
      S = :save<space>
      | = :pipe<space>
      D = :delete<Enter>
      A = :archive flat<Enter>

      <C-l> = :open-link <space>

      f = :forward<Enter>
      rr = :reply -a<Enter>
      rq = :reply -aq<Enter>
      Rr = :reply<Enter>
      Rq = :reply -q<Enter>

      H = :toggle-headers<Enter>
      <C-k> = :prev-part<Enter>
      <C-j> = :next-part<Enter>
      J = :next<Enter>
      K = :prev<Enter>

      [view::passthrough]
      $noinherit = true
      $ex = <C-x>
      <Esc> = :toggle-key-passthrough<Enter>

      [compose]
      # Keybindings used when the embedded terminal is not selected in the compose
      # view
      $noinherit = true
      $ex = <C-x>
      <C-k> = :prev-field<Enter>
      <C-j> = :next-field<Enter>
      <A-p> = :switch-account -p<Enter>
      <A-n> = :switch-account -n<Enter>
      <tab> = :next-field<Enter>
      <backtab> = :prev-field<Enter>
      <C-p> = :prev-tab<Enter>
      <C-n> = :next-tab<Enter>

      [compose::editor]
      # Keybindings used when the embedded terminal is selected in the compose view
      $noinherit = true
      $ex = <C-^>
      <C-k> = :prev-field<Enter>
      <C-j> = :next-field<Enter>
      <C-p> = :prev-tab<Enter>
      <C-n> = :next-tab<Enter>

      [compose::review]
      # Keybindings used when reviewing a message to be sent
      y = :send<Enter>
      n = :abort<Enter>
      v = :preview<Enter>
      p = :postpone<Enter>
      q = :choose -o d discard abort -o p postpone postpone<Enter>
      e = :edit<Enter>
      a = :attach<space>
      d = :detach<space>

      [terminal]
      $noinherit = true
      $ex = <C-x>

      <C-p> = :prev-tab<Enter>
      <C-n> = :next-tab<Enter>
    '';
  };
}
