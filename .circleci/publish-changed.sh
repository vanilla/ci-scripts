#!/bin/bash

set -x
set -e -f -o pipefail

DIR=`dirname "$0"`
REPO_ROOT=$(cd "$DIR/../" && pwd)
IS_DEV=false

if [ "$1" == "--dev" ]; then
    echo "Publishing in Developer Mode"
    IS_DEV=true
elif [ -z "$CIRCLE_TOKEN" ]; then
    echo "No CIRCLE_TOKEN environmental variable found."
    exit 1
fi

diffedYmlOutput=$(git diff --name-only -- '*.yml' )
diffedArrayFiles=($(echo $diffedYmlOutput | tr " " "\n"))

if [ -n $CIRCLE_BRANCH ]; then
    currentBranch=$CIRCLE_BRANCH
elif [ -n $CIRCLE_SHA1 ]; then
    currentBranch=$CIRCLE_BRANCH
else
    currentBranch=$(git rev-parse --abbrev-ref HEAD)
fi

function yaml2json() {
    ruby -ryaml -rjson -e 'puts JSON.pretty_generate(YAML.load(ARGF))' $*
}

# Print each value of the array by using the loop
for yamlFile in "${diffedArrayFiles[@]}";
do
    # echo $yamlFile
    fileName="$REPO_ROOT/$yamlFile"
    echo $fileName
    fileContents=$(cat "$fileName")
    json=$(cat "$fileName" | yaml2json)
    version=$(echo $json | jq -r ".publishVersion")
    name=$(echo $json | jq -r ".name")

    if [ $IS_DEV == true ]; then
        tag="$name@dev:$currentBranch"
    else
        tag="$name@$version"
    fi

    echo ""
    echo "======= Publishing $name ======"
    echo "New version: $tag"
    echo ""


    if [ -z "$CIRCLE_TOKEN" ]; then
        circleci orb publish $fileName $tag
    else
        circleci orb publish $fileName $tag --token "$CIRCLE_TOKEN"
    fi
done