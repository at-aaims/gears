#
# Common environment variables
#

export ACCOUNT=gen150
export ARCH=`uname -m`
export USER=`whoami`

# Replicate the OLCF environment variables as a convention
export MEMBERWORK=/gpfs/alpine/scratch/${USER}
export PROJWORK=/gpfs/alpine/proj-shared

# Gears Environment
WRKDIR=${WRKDIR:-`pwd`}
SCRATCHDIR_BASE=/gpfs/alpine/scratch/${USER}/${ACCOUNT}/.gears
PROXY_SOCKET=${WRKDIR}/run/${CLUSTER_NAME}/socket
JUPYTER_SOCKET=${WRKDIR}/run/${CLUSTER_NAME}/jupyter.socket
JUPYTER_HOST=${WRKDIR}/run/${CLUSTER_NAME}/hostname
export JUPYTER_LOG=${WRKDIR}/run/${CLUSTER_NAME}/log
export CONDA=${CONDA:-/sw/aaims/miniconda3/python3.8/${ARCH}/etc/profile.d/conda.sh}
export CONDA_ENV=${WRKDIR}/.gears.${CLUSTER_NAME}

# Dask 
export DASK_ROOT_CONFIG=${WRKDIR}/etc/dask
export DASK_TEMPORARY_DIRECTORY=${SCRATCHDIR_BASE}/dask
export DASK_LABEXTENSION__FACTORY__KWARGS__LOCAL_DIRECTORY=${DASK_TEMPORARY_DIRECTORY}

# Jupyterlab environments
export JUPYTER_LAUNCHDIR=${WRKDIR}/.launchdir

# Helper functions
cluster_name() {
	# Cluster context identifier
	SN=`hostname -f`
	case ${SN} in
	login*.summit.olcf.ornl.gov)
		echo "summit";;
	andes-login*.olcf.ornl.gov)
		echo "andes";;
	dtn*.ccs.ornl.gov)
		echo "dtn";;
	jupyter*)
		echo "jupyter";;
	esac
}

ensure_tmpdir() {
	# ensure a gears tmpdir
	WRKDIR=$1
	CLUSTER_NAME=$2
	# TMPDIR in gears
	mkdir -p ${WRKDIR}/run/${CLUSTER_NAME}
	chmod 700 ${WRKDIR}/run
	chmod 700 ${WRKDIR}/run/${CLUSTER_NAME}
	echo "${WRKDIR}/run/${CLUSTER_NAME}"
}

ensure_scratchdir() {
	# ensure a gears scratchspace on GPFS
	CLUSTER_NAME=$1
	# SCRATCHDIR in GPFS Scratch space
	mkdir -p ${SCRATCHDIR_BASE}/run/${CLUSTER_NAME}
	chmod 700 ${SCRATCHDIR_BASE}
	echo "${SCRATCHDIR_BASE}/run/${CLUSTER_NAME}"
}

ensure_local_tmpdir() {
	# ensure a node local temporary directory and link it to 
	# somewhere we can use
	rm -rf ${TMP_DIR}
	mkdir -p ${TMP_BASE}
	export LOCAL_TMP_DIR=`mktemp -d`
	ln -s ${LOCAL_TMP_DIR} ${TMP_DIR}
}

EPHEMERAL_PORT() {
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

ensure_jupyter_launchdir() {
	mkdir -p ${JUPYTER_LAUNCHDIR}/ccs
	if [ ! -e ${JUPYTER_LAUNCHDIR}/scratch ]; then
		ln -s /gpfs/alpine/scratch/${USER} ${JUPYTER_LAUNCHDIR}/scratch;
	fi
	if [ ! -e ${JUPYTER_LAUNCHDIR}/proj-shared ]; then
		ln -s /gpfs/alpine/proj-shared ${JUPYTER_LAUNCHDIR}/proj-shared;
	fi
	if [ ! -e ${JUPYTER_LAUNCHDIR}/ccs/home ]; then
		ln -s /ccs/home/${USER} ${JUPYTER_LAUNCHDIR}/ccs/home
	fi
}
