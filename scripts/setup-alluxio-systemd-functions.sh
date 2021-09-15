#
# SCRIPT: setup-alluxio-systemd-functions.sh
#

echo ""

function show_error {
	echo
	echo " $1"
	echo
}

function fatal_error {
	show_error "FATAL ERROR: ${1}. Exiting."
	exit -1
}

function check_env {

	# must be root user
	running_as=$(whoami)
	if [ "$running_as" == "" ] || [ "$running_as" != "root" ]; then
		fatal_error "Must be the root user to run this script"
	fi

	# only run on Linux
	os_name=$(uname -a)
	if [[ "$os_name" != *Linux* ]]; then
		fatal_error "This script can only be run on a Linux OS"
	fi

	# Check environment variables
	if [ "$ALLUXIO_HOME" == "" ]; then
		fatal_error "ALLUXIO_HOME environment vairable must be set"
	fi
	if [ "$JAVA_HOME" == "" ]; then
		fatal_error "JAVA_HOME environment vairable must be set"
	fi

	# Only run on systems that have systemd installed
	systemctl_cmd=$(which systemctl)
	if [ "$systemctl_cmd" == "" ]; then 
		fatal_error "Systemd doesn't appear to be installed. Command \"systemctl\" not found"
	fi
	if [ ! -d "/etc/systemd/system" ]; then
		fatal_error "Systemd doesn't appear to be installed at /etc/systemd/system/"
	fi

	# Check if the alluxio user and group are present
	userid=$(id alluxio)
	groupid=$(getent group alluxio)
	if [ "$userid" == "" ]; then
		fatal_error "Required user \"alluxio\" does not exist"
	fi
	if [ "$groupid" == "" ]; then
		fatal_error "Required user group \"alluxio\" does not exist"
	fi
}

