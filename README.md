# mysql-test-env


## Requirements

```bash
# vagrant plugin install vagrant-hostmanager
```

### Vagrant version

Please make sure your `vagrant --version` is not

- `1.8.5`, it has a nasty bug: https://github.com/mitchellh/vagrant/issues/7642
- `1.8.5` and potentially `1.8.6`, because of likely bug: https://github.com/mitchellh/vagrant/issues/7668#issuecomment-239283322


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
