require 'rubygems'
require 'sinatra'
require 'mechanize'
require 'unicode_utils/downcase'
require 'unicode_utils/titlecase'
require 'json'

require_relative 'transliterator'

def searchOTE(phoneNo)
  athensNo = /^(2\d{9}|69\d{8})/
  greekNo = /^30(\d*)/

  match = athensNo.match phoneNo

  match = greekNo.match phoneNo if match.nil?

  return if match.nil?

  pageurl = 'https://www.11888.gr'

  a = Mechanize.new
  a.user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36'
  page = a.get(pageurl)
  cookies = page.header['Set-Cookie']

  # Get the CSRF token.
  tokenRE = /csrftoken=(.*?);/

  csrftoken = '1'
  csrftokenMatches = tokenRE.match cookies

  csrftoken = csrftokenMatches[1] unless csrftokenMatches.nil?

  a.pre_connect_hooks << lambda do |_agent, request|
    request['X-Requested-With'] = 'XMLHttpRequest'
    request['Cookie'] = 'csrftoken=' + csrftoken + ';'
    request['Accept'] = 'Accept: application/json, text/javascript, */*; q=0.01'
    request['Referer'] = 'https://www.11888.gr'
  end

  pageurl = 'https://www.11888.gr/search/reverse/?phone=' + match[1]

  # Second call for the actual data (returned in JSON)
  page = a.get(pageurl)

  begin
    parsed = JSON.parse(page.content)
    unless parsed['data']['wp'].empty?
      nameComps = parsed['data']['wp'][0]['name']
      fullName = "#{nameComps['first'] || ''} #{nameComps['last']}"
      fullName.strip!
    end
  rescue JSON::ParserError
    fullName = nil
  end

  Transliterator.gr_to_lat(CGI.escapeHTML(fullName)).gsub(/\n/, ' - ') unless fullName.nil?
end

def searchAll(phoneNumber)
  content_type 'text/plain'

  return if phoneNumber == 'Anonymous'

  res = searchOTE(phoneNumber)
  res.to_s
end

get '/' do
  searchAll(params[:phone]).to_s
end
