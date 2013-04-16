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

# Your Settings
google_email   = 'hiltmon@gmail.com'  # Your google login
google_pwd     = 'i_aint_sayin'   # Must be a single use password if 2 factor is set up
the_title      = "Hiltmon.Com Top Pages Today"
file_name      = "hiltmonpages"       # The file name to use (Assumes .CSV)
dropbox_folder = "/Users/Hiltmon/Dropbox/Data" # The path to a folder on your local DropBox

# Configuration
metrics = ['pageviews'] #, 'uniquePageviews', 'newVisits']
colors = ['red', 'green', 'blue']

# Login
ga = Gattica.new({ 
    :email => google_email, 
    :password => google_pwd
})


# Get a list of accounts
accounts = ga.accounts

# Choose the first account
ga.profile_id = accounts.first.profile_id
# ga.profile_id = accounts[1].profile_id # OR second account

# Get the data
data = ga.get({ 
    :start_date   => Date.today.to_s.split('T')[0],
    :end_date     => Date.today.to_s.split('T')[0],
    :dimensions   => ['pageTitle'],
    :metrics      => metrics,
    :sort         => ['-pageviews']
})

# # Make the CSV file
File.open("#{dropbox_folder}/#{file_name}.csv", "w") do |f|
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
