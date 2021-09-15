#!/bin/bash
#
# SCRIPT:	setup-alluxio-job-master-systemd.sh
#
# USAGE:	bash ./setup-alluxio-job-master-systemd.sh
#
# NOTES:	Only run this on Alluxio MASTER nodes
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
echo

check_env

#
# Configure systemd service for the Alluxio job_master daemon
#
#     NOTE: Only run this on the Alluxio MASTER nodes
#           Make sure ALLUXIO_HOME and JAVA_HOME are defined
#
echo " Setting up Alluxio job master systemd service"
cat <<EOF > /etc/systemd/system/alluxio-job-master.service
[Unit]
Description=Alluxio job master service
Documentation=https://alluxio.io
After=network.target

[Service]
User=alluxio
Group=alluxio
WorkingDirectory=$ALLUXIO_HOME
Environment="JAVA_HOME=$JAVA_HOME"
ExecStart=$ALLUXIO_HOME/bin/launch-process job_master 
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Start the Alluxio job_master daemon
systemctl daemon-reload
systemctl enable alluxio-job-master
systemctl start alluxio-job-master

echo
echo " Use the following commands to diagnose errors:"
echo
echo "     systemctl status alluxio-job-master"
echo "     journalctl -fu alluxio-job-master"
echo "     journalctl -u  alluxio-job-master > /tmp/alluxio-job-master.out"
echo "     tail -f $ALLUXIO_HOME/logs/job_master.log"
echo

# end of script
