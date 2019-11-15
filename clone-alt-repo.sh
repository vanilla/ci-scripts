# #!/bin/bash
#
# Script from cloning a secondary vanilla repo (not the main circleci one).
set -e

REPO=$1
TARGET_DIR="$HOME/workspace/$REPO"

# Clone the internal repo with the OAuth token according to github's doc.
# https://github.blog/2012-09-21-easier-builds-and-deployments-using-git-over-https-and-oauth/
#
# We do a pull instead of a clone
# to prevent our token from ever being written in cleartext to disk.
mkdir $TARGET_DIR
cd $TARGET_DIR
git init
git remote add origin "https://$GITHUB_TOKEN@github.com/vanilla/$REPO.git"
git fetch --all
git reset --hard origin/master

repo_target=$CIRCLE_BRANCH

if [[ -n $CUSTOM_TARGET_BRANCH ]];
then
    repo_target=$CUSTOM_TARGET_BRANCH
fi

# When our target branch is a release branch
# We want to use the same target branch
if [[ $repo_target == release* ]]
then
    echo "Using vanilla release branch: $repo_target"
    git checkout $repo_target
else
    echo "Repository target is $repo_target"
fi

cd $HOME/workspace/vanilla/plugins
ln -s $HOME/workspace/$REPO/plugins/* .
