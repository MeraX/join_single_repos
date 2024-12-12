#!/bin/bash
set -x

mkdir anemoi
cd anemoi

git init .
# repo must not be empty before merging trees
touch .gitignore
git add .gitignore
git commit -m "initial commit"
../merge_repos.sh

git checkout -b develop

#git remote add graphs https://github.com/ecmwf/anemoi-graphs
#git remote add models  https://github.com/ecmwf/anemoi-models
#git fetch graphs
#git fetch models

#
# continue the work on the feature/torch-support branch of graphs
###
git checkout -b graphs/feature/torch-support
git reset --hard 0d93a60ac10f104a13bdff7bbe74c014adcbba41 # we need a predictable state of this branch
# create some new file
echo test > src/anemoi/graphs/edges/test
git add src/anemoi/graphs/edges/test
git commit -m "Add some new file in my old graphs feature branch"

git merge develop # simple merge conflict by new file
git add graphs/src/anemoi/graphs/edges/test
git commit --no-edit

# change the file completely
echo "total rewrite" > graphs/src/anemoi/graphs/edges/test
git add graphs/src/anemoi/graphs/edges/test
git commit -m "total rewrite of test in graphs of mono"

#
# Continue the work on the docs/refactor branch of graphs
###
git checkout -b graphs/docs/refactor
git reset --hard d753ab7d130de87bd8105e6521b26be7732bafc3 # we need a predictable state of this branch
git merge develop # has simple conflict due to removed files (graphs/docs/cli/{create,describe,inspect}.rst)
git rm graphs/docs/cli/create.rst graphs/docs/cli/describe.rst graphs/docs/cli/inspect.rst
git add graphs/docs/graphs/post_processor.rst
git commit --no-edit

git checkout develop
# emulate accepting a PR
git merge --no-ff graphs/feature/torch-support --no-edit


#
# Develop a new feature directly in develop
###
echo "important change in graphs" >> graphs/CHANGELOG.md
echo "important change in models" >> models/CHANGELOG.md
echo "important change in training" >> training/CHANGELOG.md
git add */CHANGELOG.md
git commit -m "Add something important to the Trinity" # this is a change like from squashed PR

#
# Merge some older single branch
###
git merge --no-ff graphs/docs/refactor --no-edit # emulate accepting another PR

#
# Create some feature mono-branch
###
git checkout -b "feature/training_graphs" develop~3 # branch off of the commit that introduced all 3 singles to the mono repo
sed -i '1,10s/^/insert something important in the first 10 lines of graphs CHANGELOG /' graphs/CHANGELOG.md
sed -i '1,10s/^/insert something important in the first 10 lines of training CHANGELOG /' training/CHANGELOG.md
git rm graphs/docs/conf.py
git add graphs/CHANGELOG.md training/CHANGELOG.md
git commit -m "Add something important to graphs and training and remote graphs index"
git merge develop --no-edit # make sure that feature branch is up-to-date

#
# Merge new mono PR
###
git checkout develop # prepare for merge
git merge --no-ff feature/training_graphs  --no-edit


#
# Push changes to single for release workflow
###
cd ..
git clone https://github.com/ecmwf/anemoi-graphs
cd anemoi-graphs
git reset --hard ffda24b3024ae877792c4ec7174483bb45ebe83f # reset develop to the state when the mono was created
git checkout HEAD^0 # detach head to enabling pushing into this single repo

cd ../anemoi
git remote add graphs-single ../anemoi-graphs
git subtree push --prefix=graphs/ graphs-single develop



# NOT RECOMMENDED: emulate changelog update with release notes,
cd ../anemoi-graphs
git checkout develop # attach HEAD
echo "New release!!!" >> CHANGELOG.md
git add CHANGELOG.md
git commit -m "Happy new release"

cd ../anemoi
git fetch graphs-single develop
git merge graphs-single/develop
git add