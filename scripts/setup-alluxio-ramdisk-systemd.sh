#!/bin/bash
#
# SCRIPT:	setup-alluxio-ramdisk-systemd.sh
#
# USAGE:	bash ./setup-alluxio-ramdisk-systemd.sh
#
# NOTES:        - Only run this on Alluxio WORKER nodes
#               - This service mounts a ram disk as specified in the Alluxio configuration setup
#                 in $ALLUXIO_HOME/conf/alluxio-site.properties like this:
#                       alluxio.worker.tieredstore.level0.alias=MEM
#                       alluxio.worker.tieredstore.level0.dirs.path=/mnt/ramdisk
#               - Make sure ALLUXIO_HOME and JAVA_HOME are defined
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

# Only install this system service if a ramdisk MEM tier is specified in the alluxio configuration
#
alluxio_properties_file="$ALLUXIO_HOME/conf/alluxio-site.properties"
if [ ! -f $alluxio_properties_file ]; then
	fatal_error "Unable to find Alluxio properties file at: $alluxio_properties_file"
fi
found_ramdisk_setup=$(grep 'alluxio.worker.tieredstore' $alluxio_properties_file | grep dirs.path | cut -d'=' -f 2)
if [[ "$found_ramdisk_setup" != *"ramXX"* ]]; then
	fatal_error "Not installing this service because no ramdisk definition was found in $ALLUXIO_HOME/conf/alluxio-site.properties"
fi

#
# Configure systemd service for the Alluxio ramdisk mount command
#
echo " Setting up Alluxio ramdisk systemd service"
cat <<EOF > /etc/systemd/system/alluxio-ramdisk.service
[Unit]
Description=Alluxio ramdisk mount service - only runs once at boot time
Documentation=https://alluxio.io
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=$ALLUXIO_HOME
Environment="JAVA_HOME=$JAVA_HOME"
ExecStart=$ALLUXIO_HOME/bin/alluxio-mount.sh Mount local
RemainAfterExit=true
Type=oneshot

[Install]
WantedBy=multi-user.target
EOF

# Start the Alluxio ramdisk daemon
systemctl daemon-reload
systemctl enable alluxio-ramdisk
systemctl start alluxio-ramdisk

echo
echo " Use the following commands to diagnose errors:"
echo
echo "     systemctl status alluxio-ramdisk"
echo "     journalctl -fu alluxio-ramdisk"
echo "     journalctl -u  alluxio-ramdisk > /tmp/alluxio-ramdisk.out"
echo

# end of script
