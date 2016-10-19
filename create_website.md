
# Find TEAM ID
    jekyll-auth team_id --org epicentre-msf --team TEAM-NAME

# setup .env

# setup Heroku

## Automatic
    bundle exec jekyll-auth setup --client_id XXX --client_secret XXX --team_id XXX

NB: this doesn't work, need to setup manually


## Manually

    heroku config:set GITHUB_CLIENT_ID=XXX GITHUB_CLIENT_SECRET=XXX GITHUB_TEAM_ID=XXX

NB: you need to add _config.yml before `git push`

    git push heroku hk-pages:master
