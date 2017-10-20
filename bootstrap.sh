#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y build-essential ruby-dev git mongodb
sudo gem update --system
sudo gem install bundler
cd /vagrant
bundle install
bundle exec ruby app.rb
