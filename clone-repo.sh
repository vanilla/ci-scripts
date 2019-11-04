# #!/bin/bash
#
# Script for checking out our git repo.
# Fixes a few shortcomings of the built in `checkout script`.
#
# Get's rid of the `git reset --hard` to preserve default branch history.
# https://discuss.circleci.com/t/git-checkout-of-a-branch-destroys-local-reference-to-master/23781
# https://discuss.circleci.com/t/the-checkout-step-mangles-branches-messes-the-history/24975
set -e

# Add githubs known SSH key.
mkdir -p ~/.ssh

echo 'github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==' >> ~/.ssh/known_hosts

(umask 077; touch ~/.ssh/id_rsa)
chmod 0600 ~/.ssh/id_rsa
(cat <<EOF > ~/.ssh/id_rsa
$CHECKOUT_KEY
EOF
)

# use git+ssh instead of https
git config --global url."ssh://git@github.com".insteadOf "https://github.com" || true
git config --global gc.auto 0 || true

TARGET_DIR="$HOME/workspace/repo"

# Clone the repo.
if [ -e $TARGET_DIR/.git ]
then
    cd $TARGET_DIR
    echo "Setting origin to $CIRCLE_REPOSITORY_URL"
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
    LOCAL_REF=$CIRCLE_BRANCH
    if [[ $LOCAL_REF == pull* ]];
    then
        # branch names that start with "pull/" need to have "/head" appended to them.
        LOCAL_REF="${LOCAL_REF}/head"
    fi
    git fetch --force origin "${LOCAL_REF}:remotes/origin/${CIRCLE_BRANCH}"
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