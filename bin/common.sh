cluster_name() {
    SN=`hostname -f`
    case ${SN} in
    login*.summit.olcf.ornl.gov)
        echo "summit";;
    andes-login*.olcf.ornl.gov)
        echo "andes";;
    jupyter*)
        echo "jupyter";;
    esac
}

WRKDIR=${WRKDIR:-`pwd`}
PROXY_SOCKET=${WRKDIR}/run/${CLUSTER_NAME}/socket
ARCH=`uname -m`
JUPYTER_SOCKET=${WRKDIR}/run/${CLUSTER_NAME}/jupyter.socket
JUPYTER_HOST=${WRKDIR}/run/${CLUSTER_NAME}/hostname
JUPYTER_LOG=${WRKDIR}/run/${CLUSTER_NAME}/log
CONDA=${CONDA:-/sw/aaims/miniconda3/python3.8/${ARCH}/etc/profile.d/conda.sh}
CONDA_ENV=${WRKDIR}/.gears.${CLUSTER_NAME}

ensure_tmpdir() {
    WRKDIR=$1
    CLUSTER_NAME=$2
    mkdir -p ${WRKDIR}/run/${CLUSTER_NAME}
    chmod 700 ${WRKDIR}/run
    chmod 700 ${WRKDIR}/run/${CLUSTER_NAME}
}

function EPHEMERAL_PORT() {
	LOW_BOUND=49152
	RANGE=16384
	while true; do
		CANDIDATE=$[$LOW_BOUND + ($RANDOM % $RANGE)]
		(echo "" >/dev/tcp/127.0.0.1/${CANDIDATE}) >/dev/null 2>&1
		if [ $? -ne 0 ]; then
			echo $CANDIDATE
			break
		fi
	done
}
