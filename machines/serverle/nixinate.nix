_: {
  _module.args.nixinate = {
    host = "serverle.local";
    sshUser = "felix";
    buildOn = "remote";
    substituteOnTarget = true;
  };
}
