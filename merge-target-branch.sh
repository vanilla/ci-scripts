# #!/bin/bash
#
# Merges the target branch into our branch if possible.
# this ensures that all tests pass with the latest upstream changes
#
# https://ideas.circleci.com/ideas/CCI-I-431
set -eu -o pipefail

# Fetch the target branch.
PR_NUMBER=${CI_PULL_REQUEST//*pull\//}
if [ -z "$PR_NUMBER" ]; then
    echo "Not a pull request. Skipping this step."
    exit
fi

if [[ -n ${PR_NUMBER} ]]
then
    sudo apt-get update && sudo apt-get install -y jq
    url="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/$PR_NUMBER?access_token=$GITHUB_TOKEN"
    target_branch=$(
        curl "$url" | jq '.base.ref' | tr -d '"'
    )
    echo "Found target branch $target_branch".
    echo "CUSTOM_TARGET_BRANCH='$target_branch'" >> $BASH_ENV
fi

cd $TARGET_DIR
# Merge target branch back into ourselves if we need to.
err=0
if [ -n "$CUSTOM_TARGET_BRANCH" ]
then
    (set -x && git merge $CUSTOM_TARGET_BRANCH) || err=$?
fi

if [ "$err" -ne "0" ]
then
    echo -e "\033[0;31mERROR: Failed to merge your branch with target branch $CUSTOM_TARGET_BRANCH."
    echo -e "Please manually merge master into your branch, and push the changes to GitHub.\033[0m"
fi
exit $err