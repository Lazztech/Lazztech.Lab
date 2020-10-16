# Configuration Management

Configuration of the host operating system(s) is automated with Ansible for repeatability.

- [Ansible 101 Medium article](https://medium.com/@denot/ansible-101-d6dc9f86df0a)
- [Ansible Linux Automation Video](https://www.youtube.com/watch?v=5hycyr-8EKs&t=126s)
- [Ansible Network Automation](https://www.youtube.com/watch?v=OWKPxAgh9DU)

```
# Debian/Ubuntu:
apt-get install python-pip

# RedHat/CentOS/Fedora:
yum install python-pip

# MacOSX (more info):
sudo easy_install pip

# Windows: Unfortunately Ansible does not work on Windows, but you can easily setup an Linux virtual machine with Vagrant and SSH into it.
```

```
# install ansible
pip install ansible
ansible --help
```

```
sudo mkdir /etc/ansible
```

```bash
# setup ansible hosts/inventory file
sudo tee /etc/ansible/hosts <<EOF
[localhost]
127.0.0.1

[micro8]
192.168.1.11

[udm]
192.168.1.1
EOF
```

```bash
# setup ansible config file
sudo tee ~/ansible.cfg <<EOF
[defaults]
inventory = hosts
remote_user = root
host_key_checking = False
ansible_user=root
EOF
```

```bash
# configure UDM
cd playbooks/
ansible-playbook udm.yml
```

# ansible / unifi
- https://www.reddit.com/r/ansible/comments/9ghaak/ubiquiti_unifi_controller_facts_new_ansible_module/
- https://fiercesw.com/blog/giving-back-contributing-to-open-source-software