#!/bin/bash
## NOTE: this script runs at the start of functional test
## use this to load any configuration before the functional test 
## TIPS: avoid modifying the .project_automation/functional_test/entrypoint.sh
## migrate any customization you did on entrypoint.sh to this helper script
echo "Executing Pre-Entrypoint Helpers"

#********** Project Path *************
PROJECT_PATH=${BASE_PATH}/project
PROJECT_TYPE_PATH=${BASE_PATH}/projecttype
cd ${PROJECT_PATH}

#********** GitHub SSH Key *************
export AWS_DEFAULT_REGION=us-east-1
GITHUB_SSH_KEY=`aws secretsmanager get-secret-value --secret-id /abp/github/functional/ssh_key | jq -r ".SecretString"`
mkdir -p ~/.ssh
echo "Host *" >> ~/.ssh/config
echo "StrictHostKeyChecking no" >> ~/.ssh/config
echo "UserKnownHostsFile=/dev/null" >> ~/.ssh/config
echo "$GITHUB_SSH_KEY" > ~/.ssh/ssh_key
echo -e "\n\n" >>  ~/.ssh/ssh_key
chmod 600 ~/.ssh/ssh_key
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/ssh_key
ssh -T git@github.com
echo "SSH Key Added"