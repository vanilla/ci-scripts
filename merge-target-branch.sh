# #!/bin/bash
#
# Merges the target branch into our branch if possible.
# this ensures that all tests pass with the latest upstream changes
#
# https://ideas.circleci.com/ideas/CCI-I-431
set -e -o pipefail

# Fetch the target branch.
if [ -z $CI_PULL_REQUEST ]
then
  exit 0
fi

PR_NUMBER=${CI_PULL_REQUEST//*pull\//}

if [ -z "$PR_NUMBER" ]; then
    echo "Not a pull request. Skipping this step."
    exit
fi

if [[ -n ${PR_NUMBER} ]]
then
    url="https://api.github.com/repos/$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME/pulls/$PR_NUMBER"

    if [ -z "$GITHUB_TOKEN" ]; then
        # No github token. Assume we don't need authentication.
        CUSTOM_TARGET_BRANCH=$(
            curl "$url" | jq '.base.ref' | tr -d '"'
        )
    else
        # we have a github token. Make the request with authentication.
        CUSTOM_TARGET_BRANCH=$(
            curl -H  "Authorization: token $GITHUB_TOKEN" "$url" | jq '.base.ref' | tr -d '"'
        )
    fi
    echo "Found target branch $CUSTOM_TARGET_BRANCH".
    echo "CUSTOM_TARGET_BRANCH='$CUSTOM_TARGET_BRANCH'" >> $BASH_ENV
fi

cd $HOME/workspace/repo

# setup the github user
git config --global user.email $( git log --format='%ae' $CIRCLE_SHA1^! )
git config --global user.name $( git log --format='%an' $CIRCLE_SHA1^! )

# Merge target branch back into ourselves if we need to.
err=0
if [ -n "$CUSTOM_TARGET_BRANCH" ]
then
    (set -x && git fetch && git merge origin/$CUSTOM_TARGET_BRANCH --no-edit) || err=$?
fi

if [ "$err" -ne "0" ]
then
    echo -e "\033[0;31mERROR: Failed to merge your branch with target branch $CUSTOM_TARGET_BRANCH."
    echo -e "Please manually merge master into your branch, and push the changes to GitHub.\033[0m"
fi
exit $err
