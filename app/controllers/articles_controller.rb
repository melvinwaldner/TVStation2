require 'net/http'
require 'csv'
require 'icalendar'
require 'open-uri'
require 'nokogiri'

class ArticlesController < ApplicationController
  helper_method :truncate_title

  def index
    url = 'https://api.openweathermap.org/data/2.5/weather?lat=47.486614&lon=7.733427&units=metric&appid=2cd6c916e89c89f156c3ee6332d5bd03'
    uri = URI(url)
    res = Net::HTTP.get_response(uri)
    @data = JSON.parse(res.body)

    url2 = 'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/liestal?unitGroup=metric&key=WMGTGTC8KQ68VLT8C62HQJCMW&contentType=json'
    uri2 = URI(url2)
    res2 = Net::HTTP.get_response(uri2)
    @data2 = JSON.parse(res2.body)

    @days = @data2["days"]

    url3 = 'https://newsapi.org/v2/top-headlines?country=ch&apiKey=5198179471974a11ba335b68f308f387'
    uri3 = URI(url3)
    res3 = Net::HTTP.get_response(uri3)
    @data3 = JSON.parse(res3.body)

    @news = @data3["articles"]

    @i_news = @news.select { |item| item["author"] == "SRF News" or item["author"] == "Polizei Basel-Landschaft" or item["author"] == "Tages-Anzeiger" or item["author"] == "Neue Zürcher Zeitung - NZZ" }

    file_path = Rails.public_path.join('calendar.txt')
    calendar_file = File.read(file_path)
    calendar = Icalendar::Calendar.parse(calendar_file).first
    
    @events = calendar.events.select { |event| event.dtend >= DateTime.now }
    
    @location = @events.first.location

    file_path2 = Rails.public_path.join('calendar2.txt')
    calendar_file2 = File.read(file_path2)
    calendar2 = Icalendar::Calendar.parse(calendar_file2).first
    
    @events2 = calendar2.events.select { |event2| event2.dtend >= DateTime.now }
    
    @location2 = @events2.first.location

    def truncate_title(title, author, max_length = 110)
      truncated_title = title[0, max_length].strip
      truncated_title += "..." if truncated_title != title.strip
      truncated_title.gsub!(author, '')
      truncated_title.gsub!(/— Baselland\.ch/i, '')
      truncated_title.gsub!(/-\s*\z/, '')
      truncated_title.strip
    end
  end
end
