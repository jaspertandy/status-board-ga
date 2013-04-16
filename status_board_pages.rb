#!/usr/bin/env ruby

# status_board_pages.rb
# Hilton Lipschitz
# Twitter/ADN: @hiltmon 
# Web: http://www.hiltmon.com
# Use and modify freely, attribution appreciated
#
# Script to generate @panic status board files for Google Analytics web stats
#
# Run this regularly to update status board
#
# For how to set up, see http://www.hiltmon.com/blog/2013/04/10/top-pages-in-status-board/

# Include the gem
require 'rubygems'
require 'gattica'
require 'date'
require 'json'

DIR = File.expand_path File.dirname __FILE__

config = YAML.load_file "#{DIR}/config.yaml"
auth = config['auth']
meta = config['pages']

# Configuration
metrics = ['pageviews'] #, 'uniquePageviews', 'newVisits']
colors = ['red', 'green', 'blue']

# Login
ga = Gattica.new({ 
    :email => auth['email'], 
    :password => auth['password']
})

# Get a list of accounts
accounts = ga.accounts

if meta['profile'] == nil
    ga.profile_id = accounts.first.profile_id
else
    ga.profile_id = meta['profile']
end

# Get the data
data = ga.get({ 
    :start_date   => Date.today.to_s.split('T')[0],
    :end_date     => Date.today.to_s.split('T')[0],
    :dimensions   => ['pageTitle'],
    :metrics      => metrics,
    :sort         => ['-pageviews']
})

# # Make the CSV file
File.open("#{meta['dir']}/#{meta['file']}.csv", "w") do |f|
  f.write "20%, 80%\n"
  count = 0
  data.to_h['points'].each do |point|
    the_page = point.to_h["dimensions"].first[:pageTitle].gsub(',', '').gsub(' - The Hiltmon', '')
    the_data = point.to_h["metrics"].map { |e| e.values.first }
    f.write the_data.join(',') + "," + the_page + "\n"
    count += 1
    break if count >= 20
  end
end
