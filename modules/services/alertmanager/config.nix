{
  global = {
    smtp_smarthost = "localhost:25";
    smtp_from = "server@buehler.rocks";
  };
  # templates = [ ];
  route = {
    receiver = "default";
    group_wait = "30s";
    group_interval = "5m";
    repeat_interval = "4h";
    routes = [ ];
  };
  receivers = [
    {
      name = "default";
      email_configs = [ { to = "server@buehler.rocks"; } ];
      webhook_configs = [
        {
          url = "http://localhost:4050/services/hooks/YWxlcnRtYW5hZ2VyX3NlcnZpY2U";
          send_resolved = true;
        }
      ];
    }
  ];
}
