# #!/bin/bash
#
# Clone the vanilla repo for running tests against it.
set -e

TARGET_DIR="$HOME/workspace/vanilla"

# Clone the repo.
git clone git@github.com:vanilla/vanilla.git $TARGET_DIR
cd $TARGET_DIR

$repo_target=${CUSTOM_TARGET_BRANCH: -$CIRCLE_BRANCH)

# When our target branch is a release branch
# We want to use the same target branch
if [[ $repo_target == "release/*" ]]
then
    git checkout $repo_target
fi

## Temporary workaround until we have our circle config on master
git checkout feature/no-travis

cd $HOME/workspace/vanilla/plugins
ln -s $HOME/workspace/repo/plugins/* .

cd $HOME/workspace/vanilla/applications
ln -s $HOME/workspace/repo/applications/* .