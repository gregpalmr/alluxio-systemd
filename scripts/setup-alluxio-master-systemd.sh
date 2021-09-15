#!/bin/bash
#
# SCRIPT:	setup-alluxio-master-systemd.sh
#
# USAGE:	bash ./setup-alluxio-master-systemd.sh
#
# NOTES:        - Only run this on Alluxio MASTER nodes
#               - Make sure ALLUXIO_HOME and JAVA_HOME are defined
#               - Make sure the alluxio user and alluxio group are define
#

# Import bash functions
if [ -f ./setup-alluxio-systemd-functions.sh ]; then
        source ./setup-alluxio-systemd-functions.sh
else
        echo; echo " FATAL ERROR: Unable to import Bash function file: ./setup-alluxio-systemd-functions.sh. Exiting."; echo
        exit;
fi

#
# MAIN
#

check_env

#
# Configure systemd service for the Alluxio master daemon
#
echo " Setting up Alluxio master systemd service"
cat <<EOF > /etc/systemd/system/alluxio-master.service
[Unit]
Description=Alluxio master service
Documentation=https://alluxio.io
After=network.target

[Service]
User=alluxio
Group=alluxio
WorkingDirectory=$ALLUXIO_HOME
Environment="JAVA_HOME=$JAVA_HOME"
ExecStart=$ALLUXIO_HOME/bin/launch-process master
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Start the Alluxio master daemon
systemctl daemon-reload
systemctl enable alluxio-master
systemctl start alluxio-master

echo
echo " Use the following commands to diagnose errors:"
echo
echo "     systemctl status alluxio-master"
echo "     journalctl -fu alluxio-master"
echo "     journalctl -u  alluxio-master > /tmp/alluxio-master.out"
echo "     tail -f $ALLUXIO_HOME/logs/master.log"
echo

# end of script


