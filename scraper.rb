#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape_list(term, url)
  puts "Fetching Parliament #{term}"
  noko = noko_for(url)
  noko.css('#mytable tbody tr').each do |row|
    tds = row.css('td')
    data = { 
      name: tds[2].text.strip,
      party: (term == 13) ? tds[3].text.strip : 'unknown',
      area: tds[term == 13 ? 4 : 3].text.strip,
      term: term,
      source: url,
    }
    ScraperWiki.save_sqlite([:name, :term], data)
  end
end

# Current
scrape_list(13, 'http://www.parlimen.gov.my/ahli-dewan.html?uweb=dr&')

# Historic
(1..12).each do |term|
  scrape_list(term, 'http://www.parlimen.gov.my/ahli-dewan.html?uweb=dr&arkib=yes&vol=%d' % term)
end
