{
  accounts.email.accounts = {
    "Personal" = {
      address = "francois@illien.org";
      userName = "francois%40illien.org";
      realName = "François ILLIEN";
      passwordCommand = "pass personal-email";
      primary = true;
      imap = {
        host = "mail.infomaniak.com";
        port = 993;
        tls.enable = true;
      };
      smtp = {
        host = "mail.infomaniak.com";
        port = 465;
        tls.enable = true;
      };
      aerc = {
        enable = true;
        smtpAuth = "login";
        extraAccounts = {
          archive = "Archives";
          folders-sort = "INBOX,mailing-lists,contrat@illien.org,achat@illien.org,Drafts,Sent,Trash,Junk,Archives";
        };
      };
      folders = {
        drafts = "Drafts";
        inbox = "INBOX";
        sent = "Sent";
        trash = "Trash";
      };
    };
    "Work" = {
      address = "francois.illien@etu.univ-nantes.fr";
      userName = "E186616T";
      realName = "François Illien";
      passwordCommand = "pass univ-nantes";
      imap = {
        host = "imaps.etu.univ-nantes.fr";
        tls.enable = true;
      };
      smtp = {
        host = "smtp.etu.univ-nantes.fr";
        tls.enable = true;
        tls.useStartTls = true;
      };
      aerc = {
        enable = true;
        smtpAuth = null;
        extraAccounts = {
          archive = "INBOX.Archives";
          postpone = "INBOX.Drafts";
          copy-to = "INBOX.Sent";
          signature-file = "/home/fillien/.config/aerc/univ-signature";
        };
      };
      folders = {
        drafts = "INBOX.Drafts";
        inbox = "INBOX";
        sent = "INBOX.Sent";
        trash = "INBOX.Trash";
      };
    };
  };
}
