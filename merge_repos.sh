#!/bin/bash
set -ex
merge_repo() {
    local repo_url="https://github.com/ecmwf/anemoi-$1"
    local target_subtree=$1
    local ref="${2-develop}"  # Default to 'develop'

    echo "Merging repository from $repo_url into $target_subtree"

    git subtree add --prefix "$1" "$repo_url" "$ref"

    # add remotes for local exploration
    git remote add "$target_subtree" "$repo_url"
    git fetch "$target_subtree"

    echo "Successfully merged $target_subtree"
}

# Example usage:
# ./merge_repos.sh

# Replace these with your actual repository names
merge_repo graphs ffda24b3024ae877792c4ec7174483bb45ebe83f
merge_repo models f58124ee7b88fa658d341a2ad6d6064379826171
merge_repo training 5c4ac3fae6ec7bc5d5b70836a88aba979a59730b
# merge_repo utils
# merge_repo docs
# merge_repo datasets
# merge_repo docs
# merge_repo registry
# merge_repo inference

# Optional: Clean up and optimize the repository
#git gc --aggressive --prune=now


# Discussion notes:
# * package Version declaration with named tags.
#       releases depend on tags
#
#  * extract subtree changes to single repo for release?
#      release via single repo? (just locally in the CI runner or via a private repo on GH?)
#
#  * Mechanism to tag PRs according to the affected subpackage
#  * Can PR tags be used to filter changes in the generation of release notes?
#
#  * generation of change log per release mechanism?
#   https://docs.github.com/en/repositories/releasing-projects-on-github/automatically-generated-release-notes
#
# There is no need to transfer all single branches into mono, as they would not have the mono/develop branch merge in automatically. Rather provide a how-to-transition
#
# How to transition a singe repo branch into the mono repo?
#   1. merge with single/develop
#   2. merge mono/develop into single
#       Conflicts with deleted or new files, should be easy to resolve if known if deleted or added.
