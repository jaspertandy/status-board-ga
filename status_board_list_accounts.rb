#!/usr/bin/env ruby

# status_board_list_accounts.rb
# Hilton Lipschitz 
# Twitter/ADN: @hiltmon 
# Web: http://www.hiltmon.com
# Use and modify freely, attribution appreciated
#
# Script to list Google Analytics accounts
#
# For how to set up, see http://www.hiltmon.com/blog/2013/04/10/google-analytics-for-status-board/

# Include the gems needed
require 'rubygems'
require 'gattica'

# Your Settings
google_email   = 'hiltmon@gmail.com'  # Your google login
google_pwd     = 'i_aint_sayin'   # Must be a single use password if 2 factor is set up

# Login
ga = Gattica.new({ 
    :email => google_email, 
    :password => google_pwd
})

# Get a list of accounts
accounts = ga.accounts

count = 0
accounts.each do |account|
  puts "#{count}: #{account.title}"
  count += 1
end
