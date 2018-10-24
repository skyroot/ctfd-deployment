# Firefox profiles for Kali

Custom profiles for Mozilla Firefox 52.6.0 at Kali Rolling. A replacement for [install_root_ca.sh](../install_root_ca.sh) which is not working at clean Kali VMs, see [issue 2](https://github.com/nus-ncl/ctfd-deployment/issues/2).

Firefox profiles in this directory were created at a clean Kali VM by the first run of Firefox there.

- [firefox-CA](firefox-CA/) is the default profile with [the NCL root CA certificate](../../server_scripts/rootCA.pem).
- [firefox-CA-cs4238.ctf.ncl.sg](firefox-CA-cs4238.ctf.ncl.sg/) is [firefox-CA](firefox-CA/) with homepage set to https://cs4238.ctf.ncl.sg.
- [firefox-CA-simple](firefox-CA-simple/) has a smaller profile size with homepage set to https://ctf.ncl.sg and fixes the issue with the previous two CA working on certain machines.

## Provisioning

1. Copy the selected Firefox profile to **users.ncl.sg:/proj/team/exp/node/**.
1. Rename the folder with profile **firefox-CA** to **firefox**.
1. Add the following lines to the default NCL Kali VM provisioning script (**kaliXnY.conf.sh**):
    ~~~~
    # Firefox configuration for NCL CTF server
    # users:/proj/team/exp/node/ must be mounted as /vagrant
    mkdir  ~/.mozilla
    cp -r /vagrant/firefox ~/.mozilla
    ~~~~
    
    **for firefox-CA-simple**
    ~~~
    update_conf "10.64.0.19 [ctf_web_address]" "/etc/hosts"
    mkdir -p ~/.mozilla
    sudo cp -r /vagrant/firefox ~/.mozilla/
    sudo sed -i 's|\("browser.startup.homepage",\) "\(.*\)"|\1 "https://[ctf_web_address]"|' ~/.mozilla/firefox/*.default/prefs.js
    ~~~
1. Double check that the relevant **Vagrantfile** does not disable mounting of working directory */proj/team/exp/node* as */vagrant* in a Kali VM.
1. Enjoy the access to the CTFd server without any SSL certificate error!
