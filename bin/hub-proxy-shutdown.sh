#!/bin/bash
#
# Tunnel from hub.ccs.ornl.gov to a certain login node
# This script assumes local & remote has the same file system
#
usage() {
	echo "usage: `basename $0` <cluster_name>"
}
if [ $# -lt 1 ]; then
	usage
	exit 1
fi
CLUSTER_NAME=${1}
BINDIR=`realpath $(dirname $0)`
WRKDIR=`realpath ${BINDIR}/..`
. ${WRKDIR}/bin/common.sh
ensure_tmpdir ${WRKDIR} ${CLUSTER_NAME}

# Create a proxy unix socket by leveraging host based authentication
# The below connects to the same host again
# FIXME: Netcat should work better
SSHCFG=${PROXY_SOCKET}.cfg

if [ ! -e ${JUPYTER_HOST} ]; then
    echo "@ There is no jupter lab instances running... I hope..."
    exit 0
fi
echo "@ Signalling jupyter lab instance on ${HN} to stop"

HN=`cat ${JUPYTER_HOST}`
ssh ${HN} killall jupyter-lab
sleep 3
exit 0
