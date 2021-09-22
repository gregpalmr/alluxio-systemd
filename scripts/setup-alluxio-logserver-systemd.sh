#!/bin/bash
#
# SCRIPT:	setup-alluxio-logserver-systemd.sh
#
# USAGE:	bash ./setup-alluxio-logserver-systemd.sh
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

# Check if the required ALLUXIO_LOGSERVER_HOSTNAME env variable is defined
if [ ! -f "$ALLUXIO_HOME/conf/alluxio-env.sh" ]; then
	fatal_error "$ALLUXIO_HOME/conf/alluxio-env.sh file not found. Needed for installing logserver"
else
	logs_server=$(grep '^ALLUXIO_LOGSERVER_HOSTNAME' $ALLUXIO_HOME/conf/alluxio-env.sh | cut --delimiter='=' --fields=2 )
	if [ "$logs_server" == "" ]; then
		fatal_error "A valid log server name or ip address not found in \$ALLUXIO_LOGSERVER_HOSTNAME variable in $ALLUXIO_HOME/conf/alluxio-env.sh file not found. Needed for installing logserver"
	fi
fi

#
# Configure systemd service for the Alluxio logserver daemon
#
echo " Setting up Alluxio logserver systemd service"
cat <<EOF > /etc/systemd/system/alluxio-logserver.service
[Unit]
Description=Alluxio logserver service
Documentation=https://alluxio.io
After=network.target

[Service]
User=alluxio
Group=alluxio
WorkingDirectory=$ALLUXIO_HOME
Environment="JAVA_HOME=$JAVA_HOME"
ExecStart=$ALLUXIO_HOME/bin/launch-process logserver
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# Start the Alluxio logserver daemon
systemctl daemon-reload
systemctl enable alluxio-logserver
systemctl start alluxio-logserver

echo
echo " Use the following commands to diagnose errors:"
echo
echo "     systemctl status alluxio-logserver"
echo "     journalctl -fu alluxio-logserver"
echo "     journalctl -u  alluxio-logserver > /tmp/alluxio-logserver.out"
echo "     tail -f $ALLUXIO_HOME/logs/logserver.log"
echo

# end of script


