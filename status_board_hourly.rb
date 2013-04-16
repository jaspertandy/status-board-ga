#!/usr/bin/env ruby

# status_board_hourly.rb
# Hilton Lipschitz 
# Twitter/ADN: @hiltmon 
# Web: http://www.hiltmon.com
# Use and modify freely, attribution appreciated
#
# Script to generate @panic status board files for Google Analytics web stats. This one generates a 
# line graph for a 24 hour window
#
# Run this regularly to update status board
#
# For how to set up, see http://www.hiltmon.com/blog/2013/04/10/google-analytics-for-status-board/

# Include the gems needed
require 'rubygems'
require 'gattica'
require 'date'
require 'json'

# Your Settings
google_email   = 'hiltmon@gmail.com'  # Your google login
google_pwd     = 'i_aint_sayin'   # Must be a single use password if 2 factor is set up
the_title      = "Hiltmon.Com Hourly" # The title of the Graph
file_name      = "hiltmonhourly"      # The file name to use (.CSV and .JSON)
dropbox_folder = "/Users/Hiltmon/Dropbox/Data" # The path to a folder on your local DropBox

# Configuration 
metrics = ['pageviews', 'visitors', 'newVisits']
colors = ['red', 'green', 'blue']
days_to_get = 7

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
    :start_date   => (Date.today - 1).to_s.split('T')[0],
    :end_date     => Date.today.to_s.split('T')[0],
    :dimensions   => ['date', 'hour'],
    :metrics      => metrics,
})

# Make the JSON file
graph = Hash.new
graph[:title] = the_title
graph[:type] = 'line'
index = 0
graph[:datasequences] = Array.new

metrics.each do |element|
  sequence = Hash.new
  sequence[:title] = element
  sequence_data = Array.new
  data.to_h['points'].each do |point|
    the_date = Date.parse(point.to_h["dimensions"].first[:date]).to_s.split('T')[0]
    the_hour = point.to_h["dimensions"][1][:hour]
    the_window = DateTime.parse("#{the_date} #{the_hour}:00 #{DateTime.now.strftime("%z")}") 
    next if the_window < (DateTime.now - 1)
    next if the_window > DateTime.now
    the_title = the_window.hour.to_s
    the_value = point.to_h["metrics"][index][element.to_sym]
    sequence_data << { :title => the_title, :value => the_value }
  end
  sequence[:datapoints] = sequence_data
  sequence[:color] = colors[index]
  index += 1
  graph[:datasequences] << sequence
end

File.open("#{dropbox_folder}/#{file_name}.json", "w") do |f|
  wrapper = Hash.new
  wrapper[:graph] = graph
  f.write wrapper.to_json
end
