# enabled system services
{ ... }:
{
  my.system = {
    avahi.enable = true;
    docker.enable = true;
  };
}
