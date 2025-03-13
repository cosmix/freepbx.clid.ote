require 'rubygems'
require 'sinatra'
require 'mechanize'
require 'unicode_utils/downcase'
require 'unicode_utils/titlecase'
require 'json'
require 'logger'

require_relative 'transliterator'

# Create a logger
LOGGER = Logger.new(STDOUT)
LOGGER.level = Logger::INFO

# Regular expression constants
ATHENS_NUMBER_PATTERN = /^(2\d{9}|69\d{8})/
GREEK_NUMBER_PATTERN = /^30(\d*)/
CSRF_TOKEN_PATTERN = /csrftoken=(.*?);/

# Initialize a reusable Mechanize agent
AGENT = Mechanize.new.tap do |agent|
  agent.user_agent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/60.0.3112.101 Safari/537.36'
  agent.open_timeout = 5  # 5 seconds to open connection
  agent.read_timeout = 10 # 10 seconds to read data
end

# Phone Directory Service class to handle directory lookups
class PhoneDirectoryService
  OTE_BASE_URL = 'https://www.11888.gr'.freeze

  def initialize(agent = AGENT)
    @agent = agent
  end

  # Extract phone number from various formats
  def normalize_phone_number(phone_no)
    if (match = ATHENS_NUMBER_PATTERN.match(phone_no))
      return match[1]
    elsif (match = GREEK_NUMBER_PATTERN.match(phone_no))
      return match[1]
    end
    nil
  end

  # Get CSRF token from cookies
  def extract_csrf_token(cookies)
    if (matches = CSRF_TOKEN_PATTERN.match(cookies))
      matches[1]
    else
      '1' # Default value if token not found
    end
  end

  # Configure request headers
  def configure_request_headers(csrf_token)
    @agent.pre_connect_hooks << lambda do |_agent, request|
      request['X-Requested-With'] = 'XMLHttpRequest'
      request['Cookie'] = "csrftoken=#{csrf_token};"
      request['Accept'] = 'Accept: application/json, text/javascript, */*; q=0.01'
      request['Referer'] = OTE_BASE_URL
    end
  end

  # Parse response and extract name
  def extract_name_from_response(content)
    parsed = JSON.parse(content)
    
    # Early return if no data or empty white pages data
    return nil if parsed['data'].nil? || parsed['data']['wp'].nil? || parsed['data']['wp'].empty?
    
    name_comps = parsed['data']['wp'][0]['name']
    return nil unless name_comps
    
    # Build full name efficiently
    first = name_comps['first'] || ''
    last = name_comps['last'] || ''
    full_name = "#{first} #{last}".strip
    
    full_name.empty? ? nil : full_name
  end

  # Search OTE directory for a phone number
  def search_ote(phone_no)
    normalized_number = normalize_phone_number(phone_no)
    return nil unless normalized_number

    begin
      # Initial request to get cookies/csrf token
      page = @agent.get(OTE_BASE_URL)
      csrf_token = extract_csrf_token(page.header['Set-Cookie'])
      configure_request_headers(csrf_token)

      # Request for actual phone data
      search_url = "#{OTE_BASE_URL}/search/reverse/?phone=#{normalized_number}"
      response = @agent.get(search_url)

      if response.code != '200'
        LOGGER.warn("Non-200 response from OTE: #{response.code}")
        return nil
      end

      # Extract and format name
      full_name = extract_name_from_response(response.content)
      if full_name
        transliterated = Transliterator.gr_to_lat(CGI.escapeHTML(full_name))
        return transliterated.gsub(/\n/, ' - ')
      end
    rescue Mechanize::Error => e
      LOGGER.error("Mechanize error during OTE search: #{e.message}")
    rescue JSON::ParserError => e
      LOGGER.error("JSON parse error: #{e.message}")
    rescue StandardError => e
      LOGGER.error("Unexpected error in search_ote: #{e.class} - #{e.message}")
    end
    
    nil
  end

  # Search all directories for a phone number
  def search_all(phone_number)
    return nil if phone_number == 'Anonymous' || phone_number.nil? || phone_number.empty?
    
    search_ote(phone_number)
  end
end

# Create a service instance for the Sinatra routes and make it accessible
$phone_service = PhoneDirectoryService.new

# Helper method to access the phone service
helpers do
  def phone_service
    $phone_service
  end
end

# Sinatra routes
get '/' do
  content_type 'text/plain'
  
  begin
    result = phone_service.search_all(params[:phone])
    
    if result.nil? || result.empty?
      status 404
      ''
    else
      status 200
      result
    end
  rescue StandardError => e
    LOGGER.error("Error in route handler: #{e.message}")
    status 500
    ''
  end
end
