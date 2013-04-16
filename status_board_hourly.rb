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
require 'yaml'

DIR = File.expand_path File.dirname __FILE__

config = YAML.load_file "#{DIR}/config.yaml"
auth = config['auth']
meta = config['hourly']

# Configuration 
metrics = {
    pageviews: 'Page Views',
    visitors: 'Visitors',
    newVisits: 'New Visits'
}
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
    :start_date   => (Date.today - 1).to_s.split('T')[0],
    :end_date     => Date.today.to_s.split('T')[0],
    :dimensions   => ['date', 'hour'],
    :metrics      => metrics.keys,
})

# Make the JSON file
graph = Hash.new
graph[:title] = meta['title']
graph[:type] = meta['chart']
index = 0
graph[:datasequences] = Array.new

metrics.each do |element,label|
  sequence = Hash.new
  sequence[:title] = label
  sequence_data = Array.new
  data.to_h['points'].each do |point|
    the_date = Date.parse(point.to_h["dimensions"].first[:date]).to_s.split('T')[0]
    the_hour = point.to_h["dimensions"][1][:hour]
    the_window = DateTime.parse("#{the_date} #{the_hour}:00 #{DateTime.now.strftime("%z")}") 
    next if the_window < (DateTime.now - 1)
    next if the_window > DateTime.now
    the_title = "#{the_window.hour.to_s}:00"
    the_value = point.to_h["metrics"][index][element.to_sym]
    sequence_data << { :title => the_title, :value => the_value }
  end
  sequence[:datapoints] = sequence_data
  sequence[:color] = colors[index]
  index += 1
  graph[:datasequences] << sequence
end

File.open("#{meta['dir']}/#{meta['file']}.json", "w") do |f|
  wrapper = Hash.new
  wrapper[:graph] = graph
  f.write wrapper.to_json
end
