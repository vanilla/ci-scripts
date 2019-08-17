# #!/bin/bash
#
# Script for creating an environmental variable for the target branch.
# CircleCI idea to provide this automatically: https://ideas.circleci.com/ideas/CCI-I-894
# Saves the env variable into

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