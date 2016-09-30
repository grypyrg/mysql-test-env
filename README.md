# mysql-test-env


## Requirements

```bash
# vagrant plugin install vagrant-hostmanager
```

## How To Run

### Create Symlink

```bash
ln -s Vagrantfile.plam_tutorial_group_replication.rb Vagrantfile
```

### Create VMs

```bash
vagrant up --parallel --no-provision
```

### Provision

```bash
vagrant provision
```
