# #!/bin/bash
#
# Script for checking out our git repo.
# Fixes a few shortcomings of the built in `checkout script`.
#
# Get's rid of the `git reset --hard` to preserve default branch history.
# https://discuss.circleci.com/t/git-checkout-of-a-branch-destroys-local-reference-to-master/23781
# https://discuss.circleci.com/t/the-checkout-step-mangles-branches-messes-the-history/24975
set -e

# Clone the repo.
if [ -e $TARGET_DIR/.git ]
then
    cd $TARGET_DIR
    git remote set-url origin "$CIRCLE_REPOSITORY_URL" || true
else
    mkdir -p $TARGET_DIR
    cd $TARGET_DIR
    git clone "$CIRCLE_REPOSITORY_URL" .
fi

# Fetch the branch we need.
if [ -n "$CIRCLE_TAG" ]
then
    git fetch --force origin "refs/tags/${CIRCLE_TAG}"
else
    git fetch --force origin "${CIRCLE_BRANCH}:remotes/origin/${CIRCLE_BRANCH}"
fi

if [ -n "$CIRCLE_TAG" ]
then
    git checkout -q "$CIRCLE_TAG"
elif [ -n "$CIRCLE_BRANCH" ]
then
    git checkout -q "$CIRCLE_BRANCH"
fi
# Ensures the remote and local branch are in sync after the fetch (see above).
git reset --hard "$CIRCLE_SHA1"