#!/bin/sh 

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

msg="rebuilding site `date`"
if [ $# -eq 1  ]
    then msg="$1"
    fi
"]]"

# push Hugo all
git add -A
git commit -m "$msg"
git push hugo master

# Build the project
hugo 

#Add public folder
cd public
git add -A

git commit -m "$msg"

git push siteio master

cd ..
