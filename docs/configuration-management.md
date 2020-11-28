# Configuration Management

Configuration of the host operating system(s) is automated with Ansible for repeatability.

- [Ansible 101 Medium article](https://medium.com/@denot/ansible-101-d6dc9f86df0a)
- [Ansible Linux Automation Video](https://www.youtube.com/watch?v=5hycyr-8EKs&t=126s)
- [Ansible Network Automation](https://www.youtube.com/watch?v=OWKPxAgh9DU)

## Installing Ansible

```bash
# install ansible
brew install ansible
```

```bash
# install sshpass
brew install hudochenkov/sshpass/sshpass
```

## Deploying Ansible Playbooks

Ansible by convention looks in a set of directories for configuration files. We'll be working of the ansible behavior of checking the current directory for picking up configuration details.

> Changes can be made and used in a configuration file which will be processed in the following order:
> 
> - ANSIBLE_CONFIG (an environment variable)
> - ansible.cfg (in the current directory)
> - .ansible.cfg (in the home directory)
> - /etc/ansible/ansible.cfg

```bash
# verify ansible picks up configuration files

# from within this repo
cd ansible/
# verify that ansible then picks up the configurations in the working directory it's run from
ansible --version
WARNING: Executing a script that is loading libcrypto in an unsafe way. This will fail in a future version of macOS. Set the LIBRESSL_REDIRECT_STUB_ABORT=1 in the environment to force this into an error.
ansible 2.7.0.dev0
  config file = /Users/gianlazzarini/Documents/Development/Lazztech.Infrastructure/ansible/ansible.cfg
  configured module search path = [u'/Users/gianlazzarini/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /Library/Python/2.7/site-packages/ansible
  executable location = /usr/local/bin/ansible
  python version = 2.7.16 (default, Apr 17 2020, 18:29:03) [GCC 4.2.1 Compatible Apple LLVM 11.0.3 (clang-1103.0.29.20) (-macos10.15-objc-
```

```bash
# deploy nomad jobs
cd ansible/
ansible-playbook playbooks/nomad-jobs.yml
```

## Hashistack

Install roles listed in the requirements.yml from Ansible galaxy
```bash
ansible gianlazzarini$ ansible-galaxy install --roles-path roles -r requirements.yml
```

```bash
ansible gianlazzarini$ ansible-playbook playbooks/hashistack.yml
```

# ansible / unifi
- https://www.reddit.com/r/ansible/comments/9ghaak/ubiquiti_unifi_controller_facts_new_ansible_module/
- https://fiercesw.com/blog/giving-back-contributing-to-open-source-software