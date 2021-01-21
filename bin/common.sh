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

# Gears Environment
WRKDIR=${WRKDIR:-`pwd`}
PROXY_SOCKET=${WRKDIR}/run/${CLUSTER_NAME}/socket
ARCH=`uname -m`
JUPYTER_SOCKET=${WRKDIR}/run/${CLUSTER_NAME}/jupyter.socket
JUPYTER_HOST=${WRKDIR}/run/${CLUSTER_NAME}/hostname
export TMP_BASE=${WRKDIR}/.tmp
export TMP_DIR=${TMP_BASE}/`hostname -f`
export JUPYTER_LOG=${WRKDIR}/run/${CLUSTER_NAME}/log
export CONDA=${CONDA:-/sw/aaims/miniconda3/python3.8/${ARCH}/etc/profile.d/conda.sh}
export CONDA_ENV=${WRKDIR}/.gears.${CLUSTER_NAME}

#Dask 
export DASK_ROOT_CONFIG=${WRKDIR}/etc/dask
export DASK_LABEXTENSION__FACTORY__KWARGS__LOCAL_DIRECTORY=${TMP_DIR}
export DASK_TEMPORARY_DIRECTORY=${TMP_DIR}

# Helper functions
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
