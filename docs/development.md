### On Developers Machine

For developers, we provide additional scripts for starting and stopping the specif bridgehead:

#### Start or stop

This command starts a specified bridgehead. Choose between "dktk", "c4" and "gbn".
``` shell
/srv/docker/bridgehead/bridgehead start <dktk/c4/gbn>
```

#### Stop

This command stops a specified bridgehead. Choose between "dktk", "c4" and "gbn".
``` shell
/srv/docker/bridgehead/bridgehead stop <dktk/c4/gbn>
```

#### Update

This shell script updates the configuration for all bridgeheads installed on your system.
``` shell
/srv/docker/bridgehead/bridgehead update
```
> NOTE: If you want to regularly update your developing instance, you can create a CRON job that executes this script.

