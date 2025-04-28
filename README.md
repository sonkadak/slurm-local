# Slurm-local
Ansible playbook for Slurm clustering

## Requirements
1. Dedicated ansible machine (recommanded)
Ansible machine is needed and can reach to slurm nodes via ssh

2. Slurm controller node as a ansible machine
Deploy slurm cluster within ansible machine as a slurm controller

## Air-gapped installation
- Supported OS: Ubuntu
Ansible machine runs NFS server with local repository for required package installation

### Prereuisite
#### Setup ansible machine
1. Prepare static packages to setup ansible machine
```
bash setup/scripts/download-ansible.sh

bash setup/scripts/download-nfs-ubuntu.sh
```

2. Copy static packages to ansible machine (default path: `setup/scripts/offline_ansible`)

3. Run setup script
```
bash setup/scripts/setup-ansible.sh
```
