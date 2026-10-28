# Project description and goals:
Use Nexus server deployed on Digital Ocean, publish packages and automate the process.

## Project tasks:
1. create a new npm hosted repository with a new blob store
2. create a new user and grant him access to the npm repository
3. build and publish NodeJS tar from lab 5
4. create a new maven hosted repository
5. create a new user and grant him access to the maven repository
6. build and publish the jar file to the new repository from lab 4
7. create a new user for droplet server that has access to both repositories
8. using Nexus Rest API fetch the download URL info for the latest NodeJS app artifact
9. run a command to download the latest artifact and run the artifact on the server
10. automate the process with scripts and deploy it to the server

## Pre-requisites and fixes
1. node and npm installed locally and on the remote server
2. gradle and java installed locally
2. in Nexus UI  →  Administration → Security → Realms → move npm Bearer Token Realm to Active → Save. This is needed since npm login (step 3) generates npm token, saved in `~/.npmrc` file. This allows token authentication.

## Commands used :
### Task 3:
* Login to npm repo on Nexus
```npm login --registry=http://<IP of your droplet>:8081/repository/<your repo name>/ --auth-type=legacy```
When prompted, provide username and password from task 2.
* Publish the NodeJS tar file ```npm publish --registry=http://<IP of your droplet>:8081/repository/<your repo name>/ bootcamp-node-project-1.0.0.tgz```

### Task 6 
#### general note - read the logs of each command, the items in this part are based on the outputs, errors and needed fixes
* clean the gradle build 
``` 
cd java-app
gradle clean
```
* create `gradle.properties` file to contain user and password from task 5
* add to the file `build.gradle` following blocks
  * ```apply plugin: 'maven-publish'```
  * 
  ``` 
  publishing {
    publications {
        create("maven", MavenPublication) {
            artifact("build/libs/java-app-$version" + ".jar") {
                extension = 'jar'
            }
        }
    }

    repositories {
        maven {
            name = 'nexus'
            url = "http://<your droplet IP>:8081/repository/maven-repo/"
            allowInsecureProtocol = true
            credentials {
                username = project.repoUser
                password = project.repoPassword
            }
        }
    }
  }
  ```

  * modify `version = '1.0.0'` so it will not contain snapshot
  * run `gradle build` and `gradle publish`
### Task 8 - 9
* add permissions `nx-search-read` to the user from task 7
* Get the download url by running `curl -u user:password -X GET 'http://<your droplet ip>:8081/service/rest/v1/search/assets?repository=<your npm repo name>'`
* Download the NodeJS app artifact by running `wget <downloadUrl>`
* Unpack the artifact and run it 
  ``` 
  tar xf <artifact name>.tgz
  cd package
  npm install
  node server.js 
  ```
* Browse to the droplet IP using the port that NodeJS app is listening

### Task 10
automate the process of download and running the NodeJS app on the remote server - `download-execute-nodejs-app.sh`
```
scp -i <full path to your ssh key> <path to the script> root@<your droplet IP>:/root
ssh -i <full path to your ssh key> root@<your droplet IP>
chmod +x download-execute-nodejs-app.sh
./download-execute-nodejs-app.sh
```

## Clean up
Destroy the droplet