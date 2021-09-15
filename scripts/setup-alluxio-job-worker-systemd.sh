#!/bin/bash
#
# SCRIPT:	setup-alluxio-job-worker-systemd.sh
#
# USAGE:	bash ./setup-alluxio-job-worker-systemd.sh
#
# NOTES:        - Only run this on Alluxio WORKER nodes
#               - Make sure ALLUXIO_HOME and JAVA_HOME are defined
#               - Make sure the alluxio user and alluxio group are defined
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
# Configure systemd service for the Alluxio job-worker daemon
#
echo " Setting up Alluxio job-worker systemd service"
cat <<EOF > /etc/systemd/system/alluxio-job-worker.service
[Unit]
Description=Alluxio job-worker service
Documentation=https://alluxio.io
After=alluxio-ramdisk.service

[Service]
User=alluxio
Group=alluxio
WorkingDirectory=$ALLUXIO_HOME
Environment="JAVA_HOME=$JAVA_HOME"
ExecStart=$ALLUXIO_HOME/bin/launch-process job-worker
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Start the Alluxio job-worker daemon
systemctl daemon-reload
systemctl enable alluxio-job-worker
systemctl start alluxio-job-worker

echo
echo " Use the following commands to diagnose errors:"
echo
echo "     systemctl status alluxio-job-worker"
echo "     journalctl -fu alluxio-job-worker"
echo "     journalctl -u  alluxio-job-worker > /tmp/alluxio-job-worker.out"
echo "     tail -f $ALLUXIO_HOME/logs/job-worker.log"
echo

# end of script


