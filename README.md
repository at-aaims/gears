Gears
=====

OLCF Site specific gears for data analytics for interactive data analytics.

(Data Analytics) Gears is a set of tools to help perform large scale data analytics on ORNL's
OLCF resources.  The goal is to address commonly known issues specific to site
(OLCF) configurations.  The goal feature set of gears are as the following:


* Jupyter Lab
  - Support to spawn and maintain a jupyterlab server on a login node
  - Minimize daily manual login steps by persisting backend SSH tunnels to
    jupyterlab server
* Dask
  - Dask related jupyter extensions, plugins, configurations and examples
    performing large scale interactive data analysis using on-demand OLCF
    compute resources (i.e., adaptive Dask worker pools)
* DVC
  - Data management supporting scripts and configurations 
* Git based data analysis workspace
  - Provides tools and templates that enables git-based data analysis
    workspaces that manages configurations
* OLCF center-wide filesystem and HPSS system
  - Data movement and management job scripts and tools that implements
    a pre-defined convention that suits OLCF use
* Conda environments
  - Provides a minimal conda environment and a set of scripts that can support
    multiple conda custom environments underneath
* Shared use
  - Multiple individuals in a small team setting can safely use the
    functionality above without stepping on each other (i.e., port collisions)

The target system for this script is mainly the Andes cluster at OLCF.
Support for other systems are planned.

# Installation

Below uses the Andes cluster as an example.

## Prerequisites

* conda or miniconda (currently provided via /sw/aaims/miniconda3/python3.8/x86\_64)
* OpenSSH version above 6.7 to support unix socket forwarding
* GNU make 3.8 and above

## Install gears and the conda environment on your home directory (NFS)

Gears should be installed in a known location within user's home directory.

```
# Login to the external SSH jump host (make hop 1)
$ ssh <nccs_account>@hub.ccs.ornl.gov

# Login to the internal SSH hop to a login node (make hop 2)
# If done on other machines, a similar step is required on their login nodes
$ ssh andes

# Install gears
$ cd $HOME
$ git clone https://code.ornl.gov/wg8/gears

# Create the conda environment for gears on Andes
$ cd ./gears
$ make init

# Create a jupyterlab password (will be stored in ~/.jupyter/jupyter_server_config.json)
$ make password
...

# hub.ccs.ornl.gov shares your home directory
$ hostname
hub.ccs.ornl.gov
$ cd ~/gears
$ make help
...
```

## Setup SSH port forwarding on your laptop

Open the SSH client configuration on your laptop and add port forward entry.

```
$ vi ~/.ssh/config
```

Assuming user is 'user' & gears location is /ccs/home/user/gears, below is an
example ssh configuration entry for your laptop or personal computer.

```
# ~/.ssh/ssh_config
Host andes-jupyter
  User <nccs_account>
  LocalForward 38888 /ccs/home/<nccs_account>/gears/run/andes.sck
```

The above excerpt with the right information could be acquired by utilizing the
gears script.

```
# Go to hub.ccs.ornl.gov
$ ssh <nccs_account>@hub.ccs.ornl.gov

# From hub.ccs.ornl.gov
$ cd ~/gears
$ make ssh-config
Host andes-jupyter
  User <nccs_account>
  LocalForward 38888 /ccs/home/<nccs_account>/gears/run/andes.sck
$
```

You can copy the output as-is and paste it into the local ssh client
configuration file (~/.ssh/config).


## Starting the backend ssh connection and the jupyter server

This should be a once in a while endeavor.
Persisting the connection is achieved using tmux or screen.
(example below uses tmux).

```
# Login to the external SSH jump host (make hop 1)
$ ssh <nccs_account>@hub.ccs.ornl.gov
... Requires manual PASSCODE input...
$ cd ~/gears

# Spawn and persist the backend tunnel (the hop 2)
# Example spawns a new tmux session but you can use your own
# or either use another terminal session manager
$ tmux new-session -d -s make andes-lab
... Requires manual PASSCODE input...
```

After above, you should be able to access the jupyterlab server from your
laptop by accessing 'http://localhost:38888' via your favorite web browser.


## Reconnecting to an existing jupyter server

Session towards hub.ccs.ornl.gov is limited to 24 hours, but the backend hop 2
from hub.ccs.ornl.gov to the cluster is not limited.
If you've left the session running in the backend, you can revisit this
existing session by repeating hop 1.

```
# Login to the external SSH jump host (make hop 1)
$ ssh <nccs_account>@hub.ccs.ornl.gov
$ cd ~/gears
$ make andes-lab
... No passcode input but port forwarding reestablished ...
```

After above, you should be able to access the jupyterlab server from your
laptop by accessing 'http://localhost:38888' via your favorite web browser.



# Maintaining Jupyter lab on login nodes

Gears provide utility scripts that enables you to maintain (leave it running)
a jupyterlab server on the login node of an OLCF HPC cluster (i.e., Summit or Andes).
Also, this repo provides you means to limit the number of manual authentications
necessary to access the jupyter server.

## Use cases of jupyterlab servers on HPC login nodes.

For various reasons, there are needs to maintain a jupyterlab server on a login
node. 
(Note that the below are based on prior experience. Not the official OLCF policy of use).

Main purpose is to provide an easy access point for interactive sessions towards on-demand Dask worker pools that grows and shrinks depending on workload or demand (i.e., Dask Adaptive).

Since the jupyter server session is spawned on a shared resource, most of the
computations should be "offloaded" to the compute nodes.  Compute & memory
usage for the jupyter server and python kernels should be minimal to smaller
scale data examination or visualization. 

## SSH hop support

Without gears, a user would need to go through multiple hops and use the RSA
FOB key multiple times to reach a login node (total two times).
Also, the default TCP port 8000 is a well known port where collision can
happen.

* Hop 1: laptop or pc: ssh <nccs\_acount>@hub.ccs.ornl.gov
* Hop 2: Login to cluster (i.e., Andes): ssh andes
* HPC cluster login node: Spawn Jupyter
* HPC compute nodes: On demand workers spawned from Jupyter server (i.e., Dask)

The approach here is to persist hop 2 and the jupyter server on the login node,
enabling users to repeat only hop 1 in the common case.
Here, the jupyter server would run on a random TCP port but will be proxied
with a UNIX socket that located on a well known fixed location in the user's
home directory.



# Interactive Dask sessions on an HPC cluster

TBD

# DVC based data management

TBD

# Git workspaces powered by gears

TBD

# Conda environments

TBD

