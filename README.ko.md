# Slurm-local
Ansible playbook for Slurm clustering

## Ansible 머신 위치
1. 전용 Ansible 머신 (권장)
Ansible 머신이 필요하며 슬럼 노드에 SSH를 통해 접근할 수 있어야 합니다.

2. 슬럼 컨트롤러 노드를 Ansible 머신으로 사용
Ansible 머신 내에 슬럼 클러스터를 배포하고 슬럼 컨트롤러로 사용합니다.

## Air-gapped 환경 설치
- 지원 OS: Ubuntu 22.04
Ansible 머신은 로컬 저장소를 통해 필요한 패키지 설치를 위해 NFS 서버를 실행합니다.

## 환경 설정
### Ansible 머신 설정
1. Ansible 머신 설정에 필요한 패키지 다운로드
```
cd setup/scripts
bash download-ansible.sh
```

2. Ansible 머신에 업로드 (기본 소스 경로: `setup/scripts/offline_ansible`)

3. Ansible 설정 스크립트 실행
```
bash setup-ansible.sh
```

4. Ansible 설치 확인
```
source ansible/bin/activate

(ansible) $ pip list |grep ansible
ansible      9.8.0
ansible-core 2.16.9
```

5. Ansible 인벤토리 생성  
모든 호스트 그룹에 대하여 설정 필요
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

6. Ansible 호스트 ping 테스트
```
ansible -i inventory -m ping all
```

### Slurm 구성에 필요한 패키지 다운로드 및 로컬 레포 생성
1. 다운로드 스크립트 실행
```
bash download-slurm-pkgs-deb.sh
```

2. 패키지 인덱스 생성
```
bash setup-nfs-repo.sh
```

3. 인덱스 정보 확인
Filename이 ``./`` (상대경로)로 구성되어 있는지 확인
```
cat offline_repo/*/Packages |grep Filename
Filename: ./libnsl2_1.3.0-2build2_amd64.deb
Filename: ./libnuma-dev_2.0.14-3ubuntu2_amd64.deb
...
```

4. 다운로드된 패키지 위치 확인
```
ansible-machine:./slurm-local/setup/scripts/offline_repo
```

### NFS 서버 설정
1. `slurm-local` 저장소 (다운로드된 패키지 포함)를 NFS 서버 (기본 소스 경로: `setup/scripts/offline_repo`)에 복사

2. Ansible 변수 검토  
`# Air-gapped installation` 섹션 아래의 변수를 검토하고 수정
```
./group_vars/all.yml
```

### NVIDIA GPU 드라이버 및 CUDA 설치
CUDA runfile 스크립트를 다운로드하여 `nfs-server:/data/offline_repo/cuda*.runfile`에 복사
```
ansible -i inventory playbooks/nvidia-driver.yml
```

### Slurm 클러스터 설치
1. nfs-server에서 소스 패키지 다운로드
```
bash download-source-packages.sh

mv source-packages {{ repo_path_root }}
```

2. 플레이북 실행
```
ansible-playbook -i inventory playbooks/slurm-cluster.yml
```


## Notice

This project is derived from the original code released by NVIDIA Corporation
under the BSD 3-Clause License:
https://github.com/NVIDIA/deepops

All modifications from the original code are sonkadak, 2024.
See LICENSE for original license terms.

[README](ansible/slurm-local/README.md)

