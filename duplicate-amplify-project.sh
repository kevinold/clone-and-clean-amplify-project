#!/usr/bin/env bash

if [ -z "$1" ]; then
  echo "Must supply existing Amplify project directory"
  exit 2;
fi

if [[ $1 == *".."* ]]; then
  echo "No relative paths to Amplify project."
  echo "Run this command from the directory above the Amplify project directory."
  exit 2;
fi

awsRegion=$2 || 'us-east-1'

newProjectDate=$(date +"%Y%m%d%H%M")
existingProjectDir=$1
existingProjectDirSuffix=$(echo $existingProjectDir | sed 's/^[0-9]*-//')
newProjectDir="$newProjectDate-$existingProjectDirSuffix"

echo "Cloning $existingProjectDir to $newProjectDir ..."

cp -R $existingProjectDir $newProjectDir

cd $newProjectDir

rm -rf node_modules

# get projectName from amplify/.config/project-config.json
existingProjectName=$(cat amplify/.config/project-config.json | jq -r '.projectName')
echo $existingProjectName

existingAwsRegion=$(cat amplify/team-provider-info.json | jq -r '.dev.awscloudformation.Region')
echo $existingAwsRegion

# get existing project date from existingProjectName
existingProjectDate=$(echo $existingProjectName | perl -lane 'print m/(\d{12})/')
echo $existingProjectDate

# get short project name from existingProjectName for use renaming/updating files and directories in /amplify
shortProjectName=$(echo $existingProjectName | perl -lane 'print m/\d{12}(.*)/')
newProjectName="$newProjectDate$shortProjectName"
echo $newProjectName

# remove .git directory
rm -rf .git

# remove amplify/#current-cloud-backend
echo "Removing amplify/#current-cloud-backend"
rm -rf "amplify/#current-cloud-backend"

echo "Migrating /amplify files to $newProjectDate ..."

# replace existing project name with new project name in /amplify filenames and file contents
perl -pi -e "s/$existingProjectName/$newProjectName/g" $(find amplify -type f) 

# replace existing project aws region with new project region in /amplify filenames and file contents
perl -pi -e "s/$existingAwsRegion/$awsRegion/g" $(find amplify -type f) 


# rename directories with existing project date to the new project date
# e.g. find . -name '*202208231425*' -execdir bash -c 'git mv $0 ${0/202208231425/202208251546}' {} \;
find . -name "*$existingProjectDate*" -execdir bash -c "mv \$0 \${0/$existingProjectDate/$newProjectDate}" {} \;

# remove project specific user/dynamically generated amplify files
echo "Removing project specific /amplify files"
rm -rf amplify/backend/amplify-meta.json
rm -rf amplify/team-provider-info.json
#rm -rf amplify/.config/project-config.json
#rm -rf amplify/.config/local-.json
rm -rf amplify/**/dist
rm -rf amplify/**/build
rm -rf amplify/backend/.temp
rm -rf src/aws-exports*

echo "Project cloned and cleaned"

npm install

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
\"profileName\":\"default\",\
\"region\":\"${awsRegion}\"\
}"
AMPLIFY="{\
\"projectName\":\"${shortProjectName}amplifyc\",\
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
git ci -am "initial commit $newProjectName"

echo ""
echo ""
echo ""
echo "Amplify project cloned and initialized"
echo "cd $newProjectDir"