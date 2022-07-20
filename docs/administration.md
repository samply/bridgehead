## Managing your Bridgehead

> TODO: Rewrite this section (restart, stop, uninstall, manual updates)

### On a Server

#### Start

This will start a not running bridgehead system unit:
``` shell
sudo systemctl start bridgehead@<dktk/c4/gbn>
```

#### Stop

This will stop a running bridgehead system unit:
``` shell
sudo systemctl stop bridgehead@<dktk/c4/gbn>
```

#### Update

This will update bridgehead system unit:
``` shell
sudo systemctl start bridgehead-update@<dktk/c4/gbn>
```

#### Remove the Bridgehead System Units

If, for some reason you want to remove the installed bridgehead units, we added a command to [bridgehead](./bridgehead):
``` shell
sudo /srv/docker/bridgehead/bridgehead uninstall <project>
```

### Connector Administration

The Connector administration panel allows you to set many of the parameters regulating your Bridgehead. Most especially, it is the place where you can register your site with the Sample Locator. To access this page, proceed as follows:

* Open the Connector page: https://<hostname>/<project>-connector/
* In the "Local components" box, click the "Samply Share" button.
* A new page will be opened, where you will need to log in using the administrator credentials (admin/adminpass by default).
* After log in, you will be taken to the administration dashboard, allowing you to configure the Connector.
* If this is the first time you have logged in as an administrator, you are strongly recommended to set a more secure password! You can use the "Users" button on the dashboard to do this.


### Systemd service configuration

For a server, we highly recommend that you install the system units for managing the bridgehead, provided by us. You can do this by executing the [bridgehead](./bridgehead) script:
``` shell
sudo /srv/docker/bridgehead/bridgehead install <Project>
```

This will install the systemd units to run and update the bridghead.

Finally, you need to configure your sites secrets. These are places as configuration for each bridgehead system unit. Refer to the section for your specific project:

For Every project you need to set the proxy this way, if you have one. This is done with the ```systemctl edit``` comand.

``` shell
sudo systemctl edit bridgehead@<project>.service;
sudo systemctl edit bridgehead-update@<project>.service;
```

``` conf
[Service]
Environment=http_proxy=<proxy-url>
Environment=https_proxy=<proxy-url>
```

### HTTPS Access

We advise to use https for all service of your bridgehead. HTTPS is enabled on default. For starting the bridghead you need a ssl certificate. You can either create it yourself or get a signed one. You need to drop the certificates in /certs.

The bridgehead create one autotmatic on the first start. However, it will be unsigned and we recomend to get a signed one.

