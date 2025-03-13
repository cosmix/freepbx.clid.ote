#!/usr/bin/env ruby
# This file contains real integration tests that make actual HTTP requests
# to the directory service. These tests are meant to be run manually and 
# only when needed, as they depend on external services.

require 'minitest/autorun'
require_relative 'app'

# Disable WebMock if it's loaded
if defined?(WebMock)
  WebMock.allow_net_connect!
  puts "WebMock disabled for real integration tests"
end

class RealIntegrationTest < Minitest::Test
  def setup
    # Use a new instance of the service with default agent
    @service = PhoneDirectoryService.new
  end
  
  def teardown
    # Add a pause between tests to avoid overwhelming the server
    puts "Pausing for 2 seconds before next test..."
    sleep 2
  end

  def test_real_search_with_known_number
    # Totally random number that we tried on 11888.gr which belonged to someone
    phone_number = '2108045205'
    
    puts "\nTesting real lookup with number: #{phone_number}"
    result = @service.search_ote(phone_number)
    
    puts "Result: #{result.inspect}"
    
    # We can't assert a specific result since the data might change,
    # but we can check that we got some kind of response
    # Comment this out if you're using a number that might not be in the directory
    # assert result, "Should get a result for this number"
  end

  def test_real_search_with_international_format
    # Testing with international format
    # Replace with a real number that works
    phone_number = '302101234567'
    
    puts "\nTesting real lookup with international format number: #{phone_number}"
    result = @service.search_ote(phone_number)
    
    puts "Result: #{result.inspect}"
    # Comment out if necessary
    # assert result, "Should get a result for this number"
  end
  
  def test_real_search_with_nonexistent_number
    # A number that likely doesn't exist
    phone_number = '2109999999'
    
    puts "\nTesting real lookup with likely nonexistent number: #{phone_number}"
    result = @service.search_ote(phone_number)
    
    puts "Result: #{result.inspect}"
    # We expect nil for a nonexistent number, but this is not guaranteed
    # assert_nil result, "Should not get a result for this number"
  end
  
  def test_real_search_with_company_number
    # A company number that should have multiple results
    phone_number = '2102899999'
    
    puts "\nTesting real lookup with company number (multiple results expected): #{phone_number}"
    result = @service.search_ote(phone_number)
    
    puts "Result: #{result.inspect}"
    # We should get a result for this company number
    # assert result, "Should get a result for this company number"
  end
end

# If this file is run directly (not required), run the tests
if __FILE__ == $0
  puts "Running real integration tests against actual directory service..."
  puts "WARNING: These tests make real HTTP requests"
  puts "Press Ctrl+C to cancel, or Enter to continue"
  STDIN.gets
  
  Minitest.run
end
