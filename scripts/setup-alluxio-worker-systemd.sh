#!/bin/bash
#
# SCRIPT:	setup-alluxio-worker-systemd.sh
#
# USAGE:	bash ./setup-alluxio-worker-systemd.sh
#
# NOTES:        - Only run this on Alluxio WORKER nodes
#               - This service requires the ramdisk to already be mounted by root
#                    See: setup-alluxio-ramdisk-systemd.sh
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
# Configure systemd service for the Alluxio worker daemon
#
echo " Setting up Alluxio worker systemd service"
cat <<EOF > /etc/systemd/system/alluxio-worker.service
[Unit]
Description=Alluxio worker service
Documentation=https://alluxio.io
After=alluxio-ramdisk.service

[Service]
User=alluxio
Group=alluxio
WorkingDirectory=$ALLUXIO_HOME
Environment="JAVA_HOME=$JAVA_HOME"
ExecStart=$ALLUXIO_HOME/bin/launch-process worker NoMount
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Start the Alluxio worker daemon
systemctl daemon-reload
systemctl enable alluxio-worker
systemctl start alluxio-worker

echo
echo " Use the following commands to diagnose errors:"
echo
echo "     systemctl status alluxio-worker"
echo "     journalctl -fu alluxio-worker"
echo "     journalctl -u  alluxio-worker > /tmp/alluxio-worker.out"
echo "     tail -f $ALLUXIO_HOME/logs/worker.log"
echo

# end of script


