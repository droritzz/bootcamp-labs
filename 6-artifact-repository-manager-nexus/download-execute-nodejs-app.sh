#!/usr/bin/env bash

# -------------- User note -----------------------
# This script downloads and executes a Node.js application from a Nexus repository.
# It requires the following arguments in order:
# 1. Nexus username
# 2. Nexus password
# 3. Nexus IP
# 4. Repository name
# If any of these arguments are not provided, the script will prompt the user for input.
# This script will download the artifact to the path where the script is executed (home directory).
# This script is for the bootcamp purpose only, 
#it assumes the download of the NodeJS application artifact and all the commands are for the NodeJS application only.
# Usage: ./download-execute-nodejs-app.sh <Nexus username> <Nexus password> <Nexus IP> <Repository name>
# Example: ./download-execute-nodejs-app.sh admin admin 127.0.0.1 my-repo
# --------------------------------------------

nexusUserName=$1
nexusUserPassword=$2
nexusIP=$3
repositoryName=$4

nexusUrl="http://$nexusIP:8081/service/rest/v1/search/assets?repository=${repositoryName}&sort=version"

tools=("jq" "node" "npm" "wget" "curl" "tar")

function get_input_from_user(){
  read -p "Enter Nexus username: " nexusUserName
  read -sp "Enter Nexus password: " nexusUserPassword
  echo
  read -p "Enter Nexus IP: " nexusIP
  read -p "Enter repository name: " repositoryName
  nexusUrl="http://$nexusIP:8081/service/rest/v1/search/assets?repository=${repositoryName}&sort=version"
}

function validate_tools(){
  for tool in "${tools[@]}"; do
    which $tool > /dev/null 2>&1
    if [[ $? != 0 ]]; then
      sudo apt install -y $tool
    fi
  done
}

function download_artifact(){
  downloadUrl=$(curl -s -u $nexusUserName:$nexusUserPassword "$nexusUrl" | jq -r '.items[0].downloadUrl')
  if [[ -z "$downloadUrl" ]]; then
    echo "Download URL is empty. Exiting."
    exit 1
  fi
  wget -q $downloadUrl
}


function execute_nodejs_app(){
  artifactName=$(basename "$downloadUrl")
  if [[ -f "$artifactName" ]]; then
    tar xf "$artifactName"
    cd package
    npm install
    node server.js &
  else
    echo "Artifact not found. Exiting."
    exit 1
  fi
}

# Main script execution 
if [[ -z "$nexusUserName" || -z "$nexusUserPassword" || -z "$nexusIP" || -z "$repositoryName" ]]; then
  get_input_from_user
fi

validate_tools
download_artifact
execute_nodejs_app  
