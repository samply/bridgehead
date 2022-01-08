echo "Stoping systemd services and removing bridgehead"

source site.conf

systemctl stop bridgehead@"${project}".service
systemctl stop bridgehead-update@"${project}".timer
systemctl stop bridgehead-update@"${project}".service

sed -i -e "s|BRIDGEHEAD_PATH=.*||" /etc/environment

cd /etc/systemd/system/
rm bridgehead\@.service
rm bridgehead-update\@.timer
rm bridgehead-update\@.service

cd - 
