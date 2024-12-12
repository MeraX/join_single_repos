#
# Clone the joined repository
###
git clone https://github.com/ecmwf/anemoi-core

# Set the uri or path of the repo that contains your feature branch
ORIGINAL_REPO="https://github.com/ecmwf/anemoi-training"
ORIGINAL_REPO="$HOME/my_anemoi_dev/anemoi-training"

# choose name of package (single repository): "training", "graphs" or "models"
PACKAGE=trainig
#PACKAGE=graphs
#PACKAGE=models

# branch name in your old single repo
BRANCH_NAME=my_feature_branch

# Name used to point to your original single remote
SINGLE_REMOTE_NAME="TEMP_anemoi-$PACKAGE"

# Branch name in the new joined repository.
# You may choose your own name or use one of our suggestions:
BRANCH_NAME_JOINED=$BRANCH_NAME
#BRANCH_NAME_JOINED=${PACKAGE}_${BRANCH_NAME}


#
# Do the Git Magic
###
git checkout -b "$BRANCH_NAME"

git remote add "${SINGLE_REMOTE_NAME}" "${ORIGINAL_REPO}"
git subtree pull --prefix=${PACKAGE} "${SINGLE_REMOTE_NAME}" "${BRANCH_NAME_JOINED}"
git remote remove "$SINGLE_REMOTE_NAME"
