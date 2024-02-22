#!/usr/bin/env bash

dateStr=$(date +"%Y%m%d%H%M")
projectName="$dateStr-amplify-cra-$1"
profileName=$2 || "default"
awsRegion=$3

npx create-react-app@latest $projectName

cd $projectName

#amplify init --y

# amplify init the new project
old_ifs="$IFS"
IFS='|'
echo "Running amplify init"

REACTCONFIG="{\
\"SourceDir\":\"src\",\
\"DistributionDir\":\"build\",\
\"BuildCommand\":\"npm run-script build\",\
\"StartCommand\":\"npm run-script start\"\
}"
AWSCLOUDFORMATIONCONFIG="{\
\"configLevel\":\"project\",\
\"useProfile\":true,\
\"profileName\":\"${profileName}\",\
\"region\":\"${awsRegion}\"\
}"
AMPLIFY="{\
\"projectName\":\"${projectName}\",\
\"envName\":\"dev\",\
\"defaultEditor\":\"code\"\
}"
FRONTEND="{\
\"frontend\":\"javascript\",\
\"framework\":\"react\",\
\"config\":$REACTCONFIG\
}"
PROVIDERS="{\
\"awscloudformation\":$AWSCLOUDFORMATIONCONFIG\
}"

amplify init \
--amplify $AMPLIFY \
--frontend $FRONTEND \
--providers $PROVIDERS \
--yes

IFS=old_ifs

# initialize git and check in new files
echo "Initialize git and initial commit"
git init
git add .
git ci -am "initial commit $projectName"

echo ""
echo ""
echo ""
echo "Amplify project and initialized"
echo "cd $projectName"

