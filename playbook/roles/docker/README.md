<!--
Maintainer:   jeffskinnerbox@yahoo.com / www.jeffskinnerbox.me
Version:      0.0.1
-->


<div align="center">
<img src="http://www.foxbyrd.com/wp-content/uploads/2018/02/file-4.jpg" title="These materials require additional work and are not ready for general use." align="center">
</div>


----


# Docker, Docker Compose, and Portainer Playbook

As the `pi` user do the following

```bash
# remove any old docker version
sudo apt-get -y remove docker docker-engine docker.io containerd runc
sudo snap remove docker docker-engine docker.io containerd runc

# download and add the gpg key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# add the docker repository
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# install the docker and docker-compose
sudo apt-get -y update
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose



# ------------------------ install portainer (as root) -------------------------
# start portainer in your browser via 'google-chrome http://localhost:9000'
# username is 'admin' and the password is 'changeme'.

# create the volume for storing persistent data
sudo docker volume create portainer_data

# install the portainer container (ports 8000 is for agents and 9000 for web ui)
sudo docker run -d -p 8000:8000 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

# install the portainer agent container
sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent
```

Now using your browser, log into portainer via this URL: `localhost:9000`.

### Step 2: Manage Multiple Hosts in Portainer
* [How to manage multiple Hosts in Portainer?](https://www.youtube.com/watch?v=kKDoPohpiNk&list=RDCMUCZNhwA1B5YqiY1nLzmM0ZRg&index=4)

### Step 2: Portainer Agent Deployment
Use the following Docker commands to deploy the Portainer Agent.
Agents are installed on Docker nodes being managed remotely by Portainer.
The agent is not needed on standalone hosts,
however it does provide additional functionality if used:

```bash
# install the portainer container
sudo docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent
```

### Step 3: Manage Proxmox Docker Containers via Desktop Portainer
We now want to connect the Proxmox based `docker-containers` so it can be monitored
and managed from my `desktop` Portainer.
This is enabled by the Portainer Agent we install in the previous step.

* To connect your `docker-containers` Portainer Agent,
you do the following on your `desktop` Portainer.
* Select **Environments** from the lefthand menu.
* Select the **Add envirnment** button at top left.
* Select **Agent** and for **Name** enter "pfSense Proxmox",
for **Environment URL** enter `192.168.1.69:9001`
for **Public IP** enter `192.168.1.69:9001`
* Select **Add environment** at the bottom left of the page.

Now if you select **Home** from the lefthand main menu,
you'll see both your local docker containers and the ones on Proxmox wher my pfSense is hosted.

Source:

* [Installing Portainer and Portainer Agent - An update to show you an easier way to manage Docker](https://www.youtube.com/watch?v=-LPaWq1_GF0)
* [Add ALL of your Docker Hosts to ONE Portainer Dashboard Using the Portainer Edge Agent](https://www.youtube.com/watch?v=8YmQoQ7gAg8)


