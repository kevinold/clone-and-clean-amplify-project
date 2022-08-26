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

newProjectDate=$(date +"%Y%m%d%H%M")
existingProjectDir=$1
existingProjectDirSuffix=$(echo $existingProjectDir | sed 's/^[0-9]*-//')
newProjectDir="$newProjectDate-$existingProjectDirSuffix"

echo "Cloning $existingProjectDir to $newProjectDir ..."

cp -R $existingProjectDir $newProjectDir

exit 2
cd $newProjectDir

rm -rf "amplify/#current-cloud-backend"

# get projectName from amplify/.config/project-config.json
existingProjectName=$(cat amplify/.config/project-config.json | jq -r '.projectName')
echo $existingProjectName

existingProjectDate=$(echo $existingProjectName | perl -lane 'print m/(\d{12})/')
echo $existingProjectDate

shortProjectName=$(echo $existingProjectName | perl -lane 'print m/\d{12}(.*)/')
newProjectName="$newProjectDate$shortProjectName"
echo $newProjectName

perl -pi -e "s/$existingProjectName/$newProjectName/g" $(find amplify -type f) 

#find . -name '*202208231425*' -execdir bash -c 'git mv $0 ${0/202208231425/202208251546}' {} \;
find . -name "*$existingProjectDate*" -execdir bash -c "git mv \$0 \${0/$existingProjectDate/$newProjectDate}" {} \;

rm -rf amplify/backend/amplify-meta.json
rm -rf amplify/team-provider-info.json
rm -rf amplify/.config/project-config.json
rm -rf amplify/.config/local-aws-info.json
rm -rf amplify/.config/local-env-info.json

amplify init --y

rm -rf .git
git init
git add .
git ci -am "initial commit $newProjectName"