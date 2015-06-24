# What We’re Doing in This Tutorial

# Imagine that a friend of yours runs a non-profit org around political activism. 
# A number of people have registered for an upcoming event. She has asked for 
# your help in engaging these future attendees.

require 'csv'
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

# Converts zipcode to a clean 5-digit format; formats invalid zipcodes as '00000'.
def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

# Convert phone numbers to a clean 10-digit format; formats invalid #s as '0000000000'.
def clean_phone_number(phone)
  clean_phone = phone.to_s.scan(/\d/).join("")
  if clean_phone.length == 11
    if clean_phone[0] == "1"
      clean_phone.sub(/[1]/, "")
    else
      "0000000000"
    end
  elsif clean_phone.length != 10
    "0000000000"
  else
    clean_phone
  end
end

# Reads registration time/date information and converts it to a Ruby object.
def format_registration_time(date_time)
  format_time = DateTime.strptime(date_time, '%m/%d/%y %H:%M')
end

# Formats the list of legislators (using Sunlight library) by zipcode.
def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

# Creates thank you letters in html format and writes them to an 'output' directory.
def save_thank_you_letters(id, form_letter)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

# These arrays are created to hold each formatted hour/day read from the file.
hours = []
days = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  phone_number = clean_phone_number(row[:homephone])

  registration_formatted = format_registration_time(row[:regdate])
  hour = registration_formatted.hour
  hours.push(hour)

  day = registration_formatted.wday
  days.push(day)

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id, form_letter)
end

# Determines the maximum number of occurances of hour/day in each respective array.
peak_hour = hours.max_by { |i| hours.count(i) }
peak_day = days.max_by { |i| days.count(i) }
puts "The peak registration hour is: #{peak_hour}00."
puts "The peak registration day is: #{Date::DAYNAMES[peak_day]}."
