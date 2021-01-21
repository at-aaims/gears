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

if [ -e ${JUPYTER_HOST} ] ; then
echo "@ Connecting to an existing jupyter server on ${JUPYTER_HOST}"
cat <<EOF >${SSHCFG}
Host jupyterproxy
  HostName `cat ${JUPYTER_HOST}`
  LocalForward ${PROXY_SOCKET} ${JUPYTER_SOCKET}
EOF
rm -rf ${PROXY_SOCKET}
ssh -F ${SSHCFG} jupyterproxy "tail -n +1 -f ${JUPYTER_LOG}"

else
echo "@ Connecting to a new login node"
cat <<EOF >${SSHCFG}
Host jupyterproxy
  HostName ${CLUSTER_NAME}
  LocalForward ${PROXY_SOCKET} ${JUPYTER_SOCKET}
EOF
rm -rf ${PROXY_SOCKET}
ssh -F ${SSHCFG} jupyterproxy ${WRKDIR}/bin/jupyter.sh ${CLUSTER_NAME}
fi
rm -rf ${PROXY_SOCKET} ${SSHCFG}
exit 0
