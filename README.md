# Slurm-local
Ansible playbook for Slurm clustering

## RequirementsConfigure ansible variables
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

#### Download required packages for slurm cluster
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

#### Configure ansible variables
Configure and review var file under the `# Air-gapped installation` section.  
All values under this section must be checked before run playbook.
```
./group_vars/all.yml
```


#### Setup NFS Server
1. Copy `slurm-local` repository (including downloaded packages) to host which is the NFS server (default source path: `setup/scripts/offline_repo`)

2. Run NFS configuration playbook
> Update nfs-server group in `inventory` before run playbook
```
ansible-playbook playbooks/config-nfs-server.yml
```

#### Install NVIDIA GPU Driver and CUDA
Run playbook
```
ansible-playbook playbooks/nvidia-driver.yml
```

## Notice

This project is derived from the original code released by NVIDIA Corporation
under the BSD 3-Clause License:
https://github.com/NVIDIA/deepops

All modifications from the original code are sonkadak, 2024.
See LICENSE for original license terms.
