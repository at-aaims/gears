#!/bin/bash
#
# Jupyterlab driver that picks a random port and spawns jupyter lab
# For stable & secure SSH jumphost destination, this script proxies this jupyter lab
# instance with a unix socket created in a private location
# Remote SSH port forwarding would use this unix socket to reach the random port
#
usage() {
	echo "usage: `basename $0` <cluster_name>"
}
if [ $# -lt 1 ]; then
	usage
	exit 1
fi
CLUSTER_NAME=${1}
WRKDIR=`realpath $(dirname $0)/..`
. ${WRKDIR}/bin/common.sh
ensure_tmpdir ${WRKDIR} ${CLUSTER_NAME}

# Check if we can spawn a host
echo "@ Attempting spawning jupyter on `hostname -f`"
if [ -e ${JUPYTER_HOST} ]; then
	echo "@ Jupyter is already running on `cat ${JUPYTER_HOST}`"
	ps -ef |grep ${USER}
	exit 1
fi
if [ ! -e ${CONDA_ENV} ]; then
	echo "@ Cannot find the conda environment ${CONDA_ENV}"
	exit 1
fi

# Ephemeral port
PORT=$(EPHEMERAL_PORT)

# Create a proxy unix socket by leveraging host based authentication
# The below connects to the same host again
# FIXME: Netcat should work better
SSHCFG=${JUPYTER_SOCKET}.cfg
LOOPBACK=`hostname -f`
cat <<EOF >${SSHCFG}
Host jupyter
  HostName ${LOOPBACK}
  LocalForward ${JUPYTER_SOCKET} 127.0.0.1:${PORT}
  HostbasedAuthentication yes
  EnableSSHKeysign yes
  GSSAPIAuthentication no
  SendEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
  SendEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
  SendEnv LC_IDENTIFICATION LC_ALL LANGUAGE
  SendEnv XMODIFIERS
  SendEnv SUDO_USER
EOF
rm -rf ${JUPYTER_SOCKET}
ssh -N -F ${SSHCFG} jupyter &
SSHPID=$!


# Launch the jupyterlab instance
. ${CONDA}
conda activate ${CONDA_ENV}
echo "@ Launching jupyterlab from `hostname -f`"
echo `hostname -f` > ${JUPYTER_HOST}
jupyter lab --no-browser --ip=127.0.0.1 --port=${PORT} 2>&1 | tee -a ${JUPYTER_LOG}

# CLeanup
kill ${SSHPID}
sleep 1
rm -rf ${JUPYTER_SOCKET} ${SSHCFG} ${JUPYTER_HOST} ${JUPYTER_LOG}
exit 0
