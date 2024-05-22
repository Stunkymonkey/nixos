_: {
  _module.args.nixinate = {
    host = "buehler.rocks";
    sshUser = "felix";
    buildOn = "remote";
    substituteOnTarget = true;
  };
}
