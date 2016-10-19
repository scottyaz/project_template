#!/bin/bash

# switch branches to hk-pages
git checkout hk-pages

# copy from website directory to root of orphaned branch
cp -R website/* .

# add all commit and push
# note that if there are new directories etc we will need to manually add them for now
git add .
git commit -m "auto-commit to hk-pages"
git push origin hk-pages

# push to heroku
git push heroku hk-pages:master

# open website
heroku open

# change back to master branch
git checkout master
