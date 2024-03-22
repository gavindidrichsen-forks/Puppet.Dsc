# winrm

## Description

WinRM is a Microsoft protocol that allows remote management of Windows machines over a network.  It is also the most common transport when using bolt to configure a windows server.  Unfortunately, setting up `winrm` on a new windows server can be both tedious and troublesome: miss a step and it may not work as expected.

The `setup_winrm.ps1` automates this process and performs the following tasks:

* Checks if the WinRM service is running and starts it if it's not.
* Configures WinRM for remote management.
* Checks if a firewall rule for WinRM exists and creates it if it doesn't.

## Usage

### Configure winrm

```powershell
# set the execution policy (you may or may not need this)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# run the script
.\setup_winrm.ps1
```

Note that running this script against one user on the windows server will enable winrm connection for all.

### Verify winrm

From another server, do a sanity test against your windows server to ensure that the un-encrypted winrm port `5985` is listening:

```bash
telnet <WINDOWS_IP> 5985
```

A successful connection to port 5985 will look something like:

```bash
➜  csharp_usage git:(development) telnet 192.168.85.2 5985
Trying 192.168.85.2...
Connected to 192.168.85.2.
Escape character is '^]'.
^CConnection closed by foreign host.
➜  csharp_usage git:(development) 
```

Note that `winrm` also has an encrypted port `5986` but this requires different steps to fully configure.

See also the [Appendix](#verifying-winrm-with-python) for a more detailed winrm verification.

## Appendix

### Verifying winrm with python

Unfortunately, there doesn't seem to be a command-line tool like ``ssh`` for ``winrm``.  There is, however, a python library 
called [pywinrm](https://super-devops.readthedocs.io/en/latest/winrm.html) that can be used to make a `winrm` connection and gather target server information.  For example, the following script

```python
import winrm
import os

# specify the Windows host details
host = os.getenv('WINRM_HOST')
username = os.getenv('WINRM_USERNAME')
password = os.getenv('WINRM_PASSWORD')

# create a WinRM session
session = winrm.Session(host, auth=(username, password))

# execute a command
result = session.run_cmd('ipconfig')

# print the output
print(result.std_out.decode())
```

will produce something like the following on a successful connection:

```bash
➜  test_winrm_connection git:(development) python test_winrm_connection.py 

Windows IP Configuration


Ethernet adapter Ethernet:

   Connection-specific DNS Suffix  . : 
   IPv6 Address. . . . . . . . . . . : fd3a:ce6c:5189:4040:43f4:f109:a1ff:b325
   Temporary IPv6 Address. . . . . . : fd3a:ce6c:5189:4040:3c42:634d:eb43:d8cc
   Link-local IPv6 Address . . . . . : fe80::528b:7e4f:1f5a:eace%11
   IPv4 Address. . . . . . . . . . . : 192.168.85.2
   Subnet Mask . . . . . . . . . . . : 255.255.255.0
   Default Gateway . . . . . . . . . : 192.168.85.1

➜  test_winrm_connection git:(development) 
```
