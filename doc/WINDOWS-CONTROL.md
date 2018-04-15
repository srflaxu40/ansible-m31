# windows-control

* A Power Shell script encapsulates these directions.  You can setup WinRM and open the proper ports for Ansible by running 
  the script located in the _ansible-m31/bin_ directory.
  * Copy it to a Power Shell that was opened in Adminstrator mode and run the following:
```
winrm quickconfig
./ConfigureWinRmForRemoting.ps1
```

* Modern Ansible can interact with Windows 10 / Server 2016 in a few varieties:
  * Enable Developer Mode and Windows Subsystem Linux and run Ansible as you would on a _nix_ box.
  * _Normal Way_ - Install WinRM, enable your flavor of authentication, and control your Windows Machines.
    * I used basic auth for development purposes.

* To enable WinRM, follow the [Ansible WinRM Setup](http://docs.ansible.com/ansible/latest/user_guide/windows_setup.html#winrm-setup) instructions.
* I recommend you setup a service to ensure it starts up any time your server reboots, etc.
* Also, I recommend you enable the automatic configuration of WinRM Listeners as outlined in [this document](https://www.infrasightlabs.com/how-to-enable-winrm-on-windows-servers-clients#configure_winrm_listener).

---

* Test your connection with ansible ad-hoc:
```
ansible johnson-windows -m win_ping  -i hosts --extra-vars "ansible_password=******"
```
