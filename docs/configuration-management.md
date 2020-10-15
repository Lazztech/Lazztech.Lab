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

