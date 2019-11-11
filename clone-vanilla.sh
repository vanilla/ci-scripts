# #!/bin/bash
#
# Clone the vanilla repo for running tests against it.
set -e

TARGET_DIR="$HOME/workspace/vanilla"

# Clone the repo.
git clone git@github.com:vanilla/vanilla.git $TARGET_DIR
cd $TARGET_DIR

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
ln -s $HOME/workspace/repo/plugins/* .

cd $HOME/workspace/vanilla/applications
ln -s $HOME/workspace/repo/applications/* .