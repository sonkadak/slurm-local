# Slurm-local
Ansible playbook for Slurm clustering

## Ansible machine location
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
cd setup/scripts
bash download-ansible.sh
```

2. Copy static packages to ansible machine (default source path: `setup/scripts/offline_ansible`)

3. Run setup script
```
bash setup-ansible.sh
```

4. Verify ansible environment
```
source ansible/bin/activate

(ansible) $ pip list |grep ansible
ansible      9.8.0
ansible-core 2.16.9
```

5. Create ansible inventory  
All host groups must be configured
```
vi slurm-local/inventory

[controller]
slurm-ctlr ansible_host=slurm-ctlr ansible_user=root

[compute]
gpu-1 ansible_host=gpu-1 ansible_user=root

[nfs-server]
#localhost ansible_connection=local
slurm-ctlr ansible_host=slurm-ctlr ansible_user=root

[nfs-client]
gpu-1 ansible_host=gpu-1 ansible_user=root
```

6. Check the ansible hosts are reachable
```
ansible -i inventory -m ping all
```

### Download required packages for slurm cluster
1. Run download scripts
```
bash download-slurm-pkgs-deb.sh
```

2. Create package index
```
bash setup-nfs-repo.sh
```

3. Review index info
Filename must start with '`./`'
```
cat offline_repo/*/Packages |grep Filename
Filename: ./libnsl2_1.3.0-2build2_amd64.deb
Filename: ./libnuma-dev_2.0.14-3ubuntu2_amd64.deb
...
```

4. Downloaded packages location
```
ansible-machine:./slurm-local/setup/scripts/offline_repo
```

### Setup NFS Server
1. Copy `slurm-local` repository (including downloaded packages) to host which is the NFS server (default source path: `setup/scripts/offline_repo`)

2.  Configure ansible variables
Configure and review var file under the `# Air-gapped installation` section.  
All values under this section must be checked before run playbook.
```
./group_vars/all.yml
```

2. Run NFS configuration playbook
> Update nfs-server group in `inventory` before run playbook
```
ansible-playbook -i inventory playbooks/config-nfs-server.yml
```

#### Install NVIDIA GPU Driver and CUDA
Download cuda runfile script and copy it to in the `nfs-server:/data/offline_repo/cuda*.runfile`
```
ansible-playbook -i inventory playbooks/nvidia-driver.yml
```

### Install slurm cluster
1. download source packages on the nfs-server
```
bash download-source-packages.sh

mv source-packages {{ repo_path_root }}
```

2. Run playbook
```
ansible-playbook -i inventory playbooks/slurm-cluster.yml
```


## Notice

This project is derived from the original code released by NVIDIA Corporation
under the BSD 3-Clause License:
https://github.com/NVIDIA/deepops

All modifications from the original code are sonkadak, 2024.
See LICENSE for original license terms.

[README.Korean](ansible/slurm-local/README.ko.md)
