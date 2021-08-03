Prereqs:

1. You will need a domain! I used NameCheap to purchase my `.tools` domain for $7 per year. I have seen options as cheap 
2. You will need an [Oracle Cloud](https://www.oracle.com/cloud/) account - This will be used to create an Always Free cloud virtual machine, which will host the services we need. You will need to attach a credit card to your account. I used a [Privacy.com](https://privacy.com/) temporary card to ensure I wouldn't be charged accidentally at the end of the 30-day trial. The services used in this guide are under Oracle's Always Free category, so unless you exceed the 10TB monthly traffic alotment, you won't be charged.
3. You will need a [Cloudflare](https://www.cloudflare.com/) account - This will be used to manage the domain name after purchase. You will need to migrate your domain from the registrar you bought the domain from to Cloudflare.  
4. An SSH terminal (I use Tabby (formerly Terminus)). This will be used to log into and manage the Oracle Cloud virtual machine.

Steps:

1. Purchase a domain name from a domain registrar. I used NameCheap, which offered my `.tools` domain for $7 per year. Some top-level domains (TLDs) can be purchased for as little as $2-3 per year (such as `.xyz`, `.one`, or `.website`). Warning: these are usually 1-year special prices, and the price will increase significantly after the first year. 

2. Migrate your domain to Cloudflare. The Cloudflare docs have a [domain transfer guide](https://developers.cloudflare.com/registrar/domain-transfers/transfer-to-cloudflare), which addresses how to do this. This process may take up to 24 hours. Cloudflare won't like that you are importing the domain without any DNS records, but that's okay.

3. Create your Oracle Cloud virtual machine. If you've already created your Oracle Cloud account, go to the [Oracle Cloud portal](https://cloud.oracle.com). Then under the "Launch Resources" section, click "Create a VM instance". Most of the default settings are fine. Click "Change Image" and uncheck Oracle Linux, then check Cannonical Ubuntu, then click "Select Image". Under "Add SSH keys", download the private key for the instance by clicking the "Save Private Key" button. Finally, click "Create". You will need to wait a while for the instance to come online. 

4. Move your downloaded SSH key to your `.ssh` folder with `mkdir ~/.ssh/` and then `mv ~/Downloads/ssh-key-*.key ~/.ssh/`. If you already have a process for SSH key management, feel free to ignore this.

5. Once your Oracle Cloud VM is provisioned (created), SSH into it. Get its public IP address from the "Instance Access" section of the instance's details page. Then run `ssh -i ~/.ssh/ssh-key-<YOUR-KEY>.key ubuntu@<YOUR-INSTANCE-IP>`, replacing "<YOUR-KEY>" and "<YOUR-INSTANCE-IP>" with your key name and instance IP. (Tip: you can use tab to auto-complete the filename of the key). Then enter the command to connect to the instance.

6. Set up the VM with all the software we need. Now that we're in the terminal, you can just copy-paste commands to run. You can either run the following command (which is just a bunch of commands strung together), or run each command one at a time by following the lettered instructions below:

`sudo apt-get update && sudo apt-get upgrade -y && sudo apt-get -y install git docker docker-compose && sudo systemctl enable docker && sudo usermod -aG docker $USER && logout` OR:

a. Update the system with `sudo apt-get update && sudo apt-get upgrade -y`. 

b. Install Docker and Docker Compose with `sudo apt-get -y install git docker docker-compose`.

c. Enable the docker service within systemd with `sudo systemctl enable docker`.

d. Add your user to the docker group with `sudo usermod -aG docker $USER`.

e. Log out with `logout`.

7. Configure the VM firewall. On the "Compute -> Instances -> Instance Details" page, under "Instance Information -> Primary VNIC -> Subnet", click the link to the subnet's configuration page, then click on the default security list. Click "Add Ingress Rules", then "+ Another Ingress Rule" and fill out your ingress rules like this:

![Alt Text](https://github.com/jafner/cloud_tools/blob/main/ingress_rules.PNG?raw=true)

This will allow incoming traffic from the internet on ports 80 and 443 (the ports used by HTTP and HTTPS respectively). 

8. Configure the Cloudflare DNS records. After your domain has been transferred to Cloudflare, log into the [Cloudflare dashboard](https://dash.cloudflare.com) and click on your domain. Then click on the DNS button at the top, and click "Add record" with the following information:
    * Type: A
    * Name: 5e
    * IPv4 Address: <YOUR-INSTANCE-IP>
    * TTL: Auto
    * Proxy status: DNS only

This will route `5e.your.domain` to <YOUR-INSTANCE-IP>. You can change the name to whatever you prefer, or use @ to use the root domain (just `your.domain`) instead. I found that using Cloudflare's proxy interferes with acquiring certificates.

9. Log back into your VM and set up the services. Clone this repository onto the host with `git clone https://github.com/jafner/cloud_tools.git`, then move into the directory with `cd cloud_tools/`. Edit the file `.env` with your domain (including subdomain) and email. For example:

```
DOMAIN=5e.your.domain
EMAIL=youremail@gmail.com
```

Make the setup script executable, then run it with `chmod +x setup.sh && ./setup.sh`