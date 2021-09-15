#!/bin/bash
#
# SCRIPT:	setup-alluxio-proxy-systemd.sh
#
# USAGE:	bash ./setup-alluxio-proxy-systemd.sh
#
# NOTES:        Only run this on Alluxio MASTER nodes
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
# Configure systemd service for the Alluxio proxy daemon
#     NOTE: Only run this on the Alluxio MASTER nodes
#           Make sure ALLUXIO_HOME and JAVA_HOME are defined
#
echo " Setting up Alluxio proxy systemd service"
cat <<EOF > /etc/systemd/system/alluxio-proxy.service
[Unit]
Description=Alluxio proxy service
Documentation=https://alluxio.io
After=network.target

[Service]
User=alluxio
Group=alluxio
WorkingDirectory=$ALLUXIO_HOME
Environment="JAVA_HOME=$JAVA_HOME"
ExecStart=$ALLUXIO_HOME/bin/launch-process proxy
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Start the Alluxio proxy daemon
systemctl daemon-reload
systemctl enable alluxio-proxy
systemctl start alluxio-proxy

echo
echo " Use the following commands to diagnose errors:"
echo
echo "     systemctl status alluxio-proxy"
echo "     journalctl -fu alluxio-proxy"
echo "     journalctl -u  alluxio-proxy > /tmp/alluxio-proxy.out"
echo "     tail -f $ALLUXIO_HOME/logs/proxy.log"
echo

# end of script
