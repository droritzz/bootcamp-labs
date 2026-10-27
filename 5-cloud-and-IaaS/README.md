# Project description and goals:
Pack a NodeJS app and deploy it on a server on Digital Ocean

## Project tasks:
1. Pack a NodeJS app
2. Raise and configure an Ubuntu server on Digital Ocean
3. Deploy the app on the remote server

## Prerequisites:
1. Account on [Digital Ocean](https://www.digitalocean.com/)
2. local tools: ssh, NodeJS, Gradle
3. Example [app](https://gitlab.com/twn-devops-bootcamp/latest/05-cloud/cloud-basics-exercises)

### Steps:
1. Pack the application
```angular2html
cd app
npm pack
```
   Verify artifact was created
```angular2html
ls app
bootcamp-node-project-1.0.0.tgz  images  index.html  package-lock.json  package.json  server.js  server.test.js
```

2. *If you have an existing pair of SSH keys skip this step.*
```angular2html
ssh-keygen
```
Follow the prompts to create a new pair of keys and store it on your local machine. Keep the private key and mind the public key - you'll need it in the next steps

3. Raise an Ubuntu server on Digital Ocean
   * Create an account/login into the existing account. 
   * Navigate to Droplets and create a new Droplet (server).
   * Choose the Region closest to you geographically.
   * Choose an Ubuntu image
   * Choose the Regular Droplet plan
   * In the Authentication choose SSH keys
     * If you already have a pair, you may use them - select the key in the options.
     * If you do not have an SSH key, click on Add SSH key
       * Paste the public key created in step 2
       * give your key a name so you'll be able to recognize it
   * Click on create droplet, your droplet will be ready after a few minutes
   * Navigate to Networking and choose Firewalls tab
   * Create a Firewall
     * outbound rule may remain open to all
     * edit the inbound rules:
       * allow ssh (port 22) from your IP only
   * Attach your droplet to the Firewall

4. Configure an Ubuntu server on Digital Ocean
   * Connect to your droplet using ssh ``` ssh -i <full path to your ssh key> root@<Iyour droplet IP>```
   * On the remote server:
     * Install NodeJS and npm 
     ``` 
     apt update
     apt install nodejs npm
     npm --version
     node --version
     ```
5. Deploy the app on the server
   * From your local machine run to copy the app
     ```
     scp -i <full path to your ssh key> <full path to your package from step 1> root@<your droplet IP>:/root
   * Connect to the machine using ssh
   * Unpack the package ``` tar xf bootcamp-node-project-1.0.0.tgx```
   * Run the NodeJS app
     ```
     cd package
     npm install
     node server.js
     ```
   * Note the port the application is running and adjust your inbound Firewall rules accordingly
   * Browse to the IP of the droplet to the UI of the app ```ip:port```
6. Clean up
   * stop the app and exit the droplet
   * destroy the droplet


