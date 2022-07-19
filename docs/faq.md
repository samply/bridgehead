## Pitfalls

### Hilfe mein Teiler ist nicht verfügbar
#### @Patrick
- [ ] TODO: Docker Override when DNS Entry for Host is not existent
### [Git Proxy Configuration](https://gist.github.com/evantoli/f8c23a37eb3558ab8765)

Unlike most other tools, git doesn't use the default proxy variables "http_proxy" and "https_proxy". To make git use a proxy, you will need to adjust the global git configuration:

``` shell
sudo git config --global http.proxy http://<your-proxy-host>:<your-proxy-port>;
sudo git config --global https.proxy http://<your-proxy-host>:<your-proxy-port>;
```
> NOTE: Some proxies may require user and password authentication. You can adjust the settings like this: "http://<your-proxy-user>:<your-proxy-user-password>@<your-proxy-host>:<your-proxy-port>".
> NOTE: It is also possible that a proxy requires https protocol, so you can replace this to.

You can check that the updated configuration with

``` shell
sudo git config --global --list;
```

### Docker Daemon Proxy Configuration

Docker has a background daemon, responsible for downloading images and starting them. To configure the proxy for this daemon, use the systemctl command:

``` shell
sudo systemctl edit docker
```

This will open your default editor allowing you to edit the docker system units configuration. Insert the following lines in the editor, replace <your-proxy-host> and <your-proxy-port> with the corresponding values for your machine and save the file:
``` conf
[Service]
Environment=HTTP_PROXY=http://<your-proxy-host>:<your-proxy-port>
Environment=HTTPS_PROXY=http://<your-proxy-host>:<your-proxy-port>
Environment=FTP_PROXY=http://<your-proxy-host>:<your-proxy-port>
```
> NOTE: Some proxies may require user and password authentication. You can adjust the settings like this: "http://<your-proxy-user>:<your-proxy-user-password>@<your-proxy-host>:<your-proxy-port>".
> NOTE: It is also possible that a proxy requires https protocol, so you can replace this to.

The file should now be at the location "/etc/systemd/system/docker.service.d/override.conf". You can proof check with
``` shell
cat /etc/systemd/system/docker.service.d/override.conf;
```

To make the configuration effective, you need to tell systemd to reload the configuration and restart the docker service:

``` shell
sudo systemctl daemon-reload;
sudo systemctl restart docker;
```
