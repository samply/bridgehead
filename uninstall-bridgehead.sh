echo "Stoping systemd services and removing bridgehead"

source site.conf

systemctl stop bridgehead@"${project}".service
systemctl stop bridgehead-update@"${project}".timer
