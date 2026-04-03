_: {
  _module.args.nixinate = {
    host = "playman.local";
    sshUser = "felix";
    buildOn = "remote";
    substituteOnTarget = true;
  };
}
