# firefox_profiles

Custom profiles for Mozilla Firefox 52.6.0 at Kali Rolling. A replacement for [install_root_ca.sh](ctfd-deployment/client_scripts/install_root_ca.sh) which is not working at clean Kali VMs (see #2).

Firefox profiles in this directory were created at a clean Kali VM by the first run of Firefox there.

- [firefox-CA](ctfd-deployment/client_scripts/firefox_profiles/firefox-CA/) is the default profile with [the NCL root CA certificate](ctfd-deployment/server_scripts/rootCA.pem).
- [firefox-CA-cs4238.ctf.ncl.sg](ctfd-deployment/client_scripts/firefox_profiles/firefox-CA-cs4238.ctf.ncl.sg/) is [firefox-CA](ctfd-deployment/client_scripts/firefox_profiles/firefox-CA/) with homepage set to https://cs4238.ctf.ncl.sg.

## Provisioning

1. Copy the selected Firefox profile to **users.ncl.sg:/proj/team/exp/node/**.

1. Add the following lines to the default NCL Kali VM provisioning script (**kaliXnY.conf.sh**):

~~~~
# Firefox configuration for NCL CTF server
# users:/proj/team/exp/node/ must be mounted as /vagrant
mkdir  ~/.mozilla
cp -r /vagrant/firefox ~/.mozilla
~~~~

1. Double check that the relevant **Vagrantfile** does not disable mounting of working directory */proj/team/exp/node* as */vagrant* in a Kali VM.

1. Enjoy the access to the CTFd server without any SSL certificate error!
