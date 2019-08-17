
# Merges the target branch into our branch if possible.
# this ensures that all tests pass with the latest upstream changes
#
# https://ideas.circleci.com/ideas/CCI-I-431
set -eu -o pipefail
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