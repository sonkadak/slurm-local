# Slurm-local
Ansible playbook for Slurm clustering

## Requirements
1. Dedicated ansible machine (recommanded)
Ansible machine is needed and can reach to slurm nodes via ssh

2. Slurm controller node as a ansible machine
Deploy slurm cluster within ansible machine as a slurm controller

## Air-gapped installation
- Supported OS: Ubuntu 22.04
Ansible machine runs NFS server with local repository for required package installation

### Prereuisite
#### Setup ansible machine
1. Prepare static packages to setup ansible machine
```
bash setup/scripts/download-ansible.sh
```

2. Copy static packages to ansible machine (default source path: `setup/scripts/offline_ansible`)

3. Run setup script
```
bash setup/scripts/setup-ansible.sh
```

#### Setup NFS Server
1. Run download script to download NFS packages
```
bash setup/scripts/download-nfs-ubuntu.sh
```

2. Copy Packages to host which has NFS server role (default source path: `setup/scripts/offline_nfs`)

3. Run NFS configuration playbook
> Update nfs-server group in `inventory` before run playbook
```
ansible-playbook playbooks/config-nfs-server.yml
```

## Notice

This project is derived from the original code released by NVIDIA Corporation
under the BSD 3-Clause License:
https://github.com/NVIDIA/deepops

All modifications from the original code are sonkadak, 2024.
See LICENSE for original license terms.
