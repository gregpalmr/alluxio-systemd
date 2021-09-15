# alluxio-systemd
Setup Alluxio daemons to run automatically on boot-up using systemd

## Introduction

This git repo contains scripts that setup the Linux systemd configuration to automatically start the Alluxio master node daemons and the worker node daemons.

## Prerequisites

To use these scripts you must meet the following requirements:

- Be running on a Linux server
- Have systemd installed and running (see https://systemd.io/)
- Have Alluxio install and configured (see https://docs.alluxio.io/os/user/stable/en/deploy/Running-Alluxio-On-a-Cluster.html)
- Be logged in as the root user or as a user that has SUDO privilages
- Have an "alluxio" user that is a member of the "alluxio" group
- Have the JAVA_HOME envrionment variable pointing to the valid Java 1.8 JVM environment
- Have the ALLUXIO_HOME environment variable pointing to the main directory where Alluxio was installed

## Usage

### Step 1. Clone this repo

Download this repo's source files  by using the `git clone` command or by downloading the repo zip file.

     $ git clone https://github.com/gregpalmr/alluxio-systemd

     $ cd alluxio-systemd

### Step 2. Install the Alluxio systemd services on the MASTER nodes

On all of your Alluxio master nodes, run these scripts:

     $ cd scripts

     $ bash setup-alluxio-master-systemd.sh

     $ bash setup-alluxio-job-master-systemd.sh

     $ bash setup-alluxio-proxy-systemd.sh

### Step 3. Install the Alluxio systemd services on the WORKER nodes

On all of your Alluxio worker nodes, run these scripts:

     $ setup-alluxio-ramdisk-systemd.sh

     $ setup-alluxio-worker-systemd.sh

     $ setup-alluxio-job-worker-systemd.sh

     $ setup-alluxio-proxy-systemd.sh

### Step 4. Restart the Alluxio nodes

Restart all of your Alluxio master nodes and worker nodes. When completed, log into each node and see if the Alluxio systemd services are running correctly. 

Use these commands on the master nodes:

     $ sysetmctl status alluxio-master

     $ sysetmctl status alluxio-job-master

     $ sysetmctl status alluxio-proxy

Use these commands on the worker nodes:

     $ systemctl status alluxio-worker

     $ systemctl status alluxio-job-worker

     $ systemctl status alluxio-proxy

If you see any errors, you can view the complete systemd errors using the command:

     $ journalctl -u <unit name>

For example:

     $ journalctl -u alluxio-master

You can also view the Alluxio error logs at $ALLUXIO_HOME/logs/.

---

Please direct questions or comments to: greg.palmer@alluxio.com

