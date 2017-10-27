#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y build-essential ruby-dev git mongodb rubygems rerun
#export PATH=$PATH:/opt/vagrant_ruby/bin/
gem update --system
gem install bundler
cd /vagrant
bundle install
#bundle exec ruby app.rb
rackup --host 0.0.0.0 -p 8000
