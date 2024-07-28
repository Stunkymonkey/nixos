# network settings
_: {
  # hotfixes for dns settings
  networking.extraHosts =
    let
      serverle_ip = "192.168.178.60";
    in
    ''
      ${serverle_ip} stunkymonkey.de
      ${serverle_ip} automation.stunkymonkey.de
      ${serverle_ip} download.stunkymonkey.de
      ${serverle_ip} esphome.stunkymonkey.de
      ${serverle_ip} indexer.stunkymonkey.de
      ${serverle_ip} media.stunkymonkey.de
      ${serverle_ip} movies.stunkymonkey.de
      ${serverle_ip} series.stunkymonkey.de
      ${serverle_ip} subtitles.stunkymonkey.de
      ${serverle_ip} view.stunkymonkey.de
    '';
}
