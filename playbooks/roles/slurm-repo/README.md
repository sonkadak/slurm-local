# Slurm Local Repository Role

This role sets up an NFS-based local repository for Slurm packages in an air-gapped environment.

## Prerequisites

In an air-gapped environment, NFS packages must be installed manually before running this role.

### Required Packages for NFS Server
```bash
# From common role package directory:
dpkg -i nfs-kernel-server*.deb nfs-common*.deb rpcbind*.deb keyutils*.deb
```

### Required Packages for NFS Clients
```bash
# From common role package directory:
dpkg -i nfs-common*.deb rpcbind*.deb keyutils*.deb
```

## Installation Steps

1. First, install required packages manually as shown above
2. Run the playbook:
   ```bash
   ansible-playbook playbooks/configure-local-repo.yml
   ```

## Role Variables

See defaults/main.yml for configuration options.

## Dependencies

- Requires packages from common role
- Manual package installation required in air-gapped environment
