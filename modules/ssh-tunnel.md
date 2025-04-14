# SSH Tunnel Module

This module enables SSH tunneling capabilities for the Bridgehead installation.
The primary use case for this is to connect bridgehead components that are hosted externally due to security concerns.
To connect the new components to the locally running bridgehead infra one is supposed to write a docker-compose.override.yml changing the urls to point to the corresponding forwarded port of the ssh-tunnel container.

## Configuration Variables

- `ENABLE_SSH_TUNNEL`: Required to enable the module
- `SSH_TUNNEL_USERNAME`: Username for SSH connection
- `SSH_TUNNEL_HOST`: Target host for SSH tunnel
- `SSH_TUNNEL_PORT`: SSH port (defaults to 22)

## Configuration Files

The module requires the following files to be present:

- `/etc/bridgehead/ssh-tunnel.conf`: SSH tunnel configuration file. Detailed information can be found [here](https://github.com/samply/ssh-tunnel?tab=readme-ov-file#configuration).
- `/etc/bridgehead/pki/ssh-tunnel.priv.pem`: The SSH private key used to connect to the `SSH_TUNNEL_HOST`. **Passphrases for the key are not supported!**