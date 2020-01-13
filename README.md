# Bulk Resetting Mattermost Passwords

## Problem

You need to reset all email users passwords and send a password reset email

## Solution

1. Make sure Ruby and the bundler gem are installed on your server
2. Check out this repository onto your Mattermost server
2. Copy `sample.conf.yaml` to `conf.yaml` and change the config values to match
3. Run `bundle install` in this directory to install the required Rubygem
4. Run `ruby main.rb`

## Discussion

This script is useful if you've recently migrated your Mattermost server using the [Bulk Export Tool](https://docs.mattermost.com/administration/bulk-export.html). Because passwords are not included in the migration, this will remind every user who is set for email authentication 