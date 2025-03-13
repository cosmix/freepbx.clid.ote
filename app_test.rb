# Ensure the environment is set to test mode
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'json'
require_relative 'app'

# Try to load webmock but continue if it's not available
begin
  require 'webmock/minitest'
  WEBMOCK_AVAILABLE = true
  puts "WebMock loaded successfully"
rescue LoadError
  WEBMOCK_AVAILABLE = false
  puts "WebMock not available - integration tests will be skipped"
  puts "Run 'gem install webmock rack-test mocha' to enable all tests"
end

# Unit tests for PhoneDirectoryService
class PhoneDirectoryServiceTest < Minitest::Test
  def setup
    @service = PhoneDirectoryService.new
  end

  def test_normalize_phone_number_athens_format
    # Test Athens format (2XXXXXXXXX)
    assert_equal '2101234567', @service.normalize_phone_number('2101234567')

    # Test mobile format (69XXXXXXXX)
    assert_equal '6912345678', @service.normalize_phone_number('6912345678')
  end

  def test_normalize_phone_number_greek_format
    # Test international Greek format
    assert_equal '2101234567', @service.normalize_phone_number('302101234567')
  end

  def test_normalize_phone_number_invalid_format
    # Test invalid formats
    assert_nil @service.normalize_phone_number('invalid')
    assert_nil @service.normalize_phone_number('123456')
    assert_nil @service.normalize_phone_number(nil)
  end

  def test_extract_csrf_token
    # Test with valid cookie string
    cookies = 'csrftoken=abc123def456; other=value'
    assert_equal 'abc123def456', @service.extract_csrf_token(cookies)

    # Test with no csrf token
    assert_equal '1', @service.extract_csrf_token('other=value')

    # Test with nil
    assert_equal '1', @service.extract_csrf_token(nil)
  end

  def test_extract_name_from_response
    # Test with valid response
    valid_json = {
      'data' => {
        'wp' => [
          {
            'name' => {
              'first' => 'John',
              'last' => 'Doe'
            }
          }
        ]
      }
    }.to_json

    assert_equal 'John Doe', @service.extract_name_from_response(valid_json)

    # Test with first name only
    first_name_only = {
      'data' => {
        'wp' => [
          {
            'name' => {
              'first' => 'John',
              'last' => nil
            }
          }
        ]
      }
    }.to_json

    assert_equal 'John', @service.extract_name_from_response(first_name_only)

    # Test with last name only
    last_name_only = {
      'data' => {
        'wp' => [
          {
            'name' => {
              'first' => nil,
              'last' => 'Doe'
            }
          }
        ]
      }
    }.to_json

    assert_equal 'Doe', @service.extract_name_from_response(last_name_only)

    # Test with empty wp array
    empty_wp = {
      'data' => {
        'wp' => []
      }
    }.to_json

    assert_nil @service.extract_name_from_response(empty_wp)

    # Test with nil data
    nil_data = {
      'data' => nil
    }.to_json

    assert_nil @service.extract_name_from_response(nil_data)
  end

  def test_search_all_with_anonymous
    assert_nil @service.search_all('Anonymous')
  end

  def test_search_all_with_empty_string
    assert_nil @service.search_all('')
  end

  def test_search_all_with_nil
    assert_nil @service.search_all(nil)
  end
end

# Integration tests for PhoneDirectoryService
class PhoneDirectoryServiceIntegrationTest < Minitest::Test
  def setup
    skip "WebMock not available" unless defined?(WEBMOCK_AVAILABLE) && WEBMOCK_AVAILABLE

    # Setup a service with a test agent
    @test_agent = Mechanize.new
    @service = PhoneDirectoryService.new(@test_agent)

    # Base URL for mocking
    @base_url = PhoneDirectoryService::OTE_BASE_URL

    # Enable WebMock
    WebMock.enable!
  end

  def teardown
    WebMock.disable! if defined?(WEBMOCK_AVAILABLE) && WEBMOCK_AVAILABLE
  end

  def test_successful_search
    # Mock the initial request to get cookies/csrf token
    stub_request(:get, @base_url).
      to_return(
        status: 200,
        headers: { 'Set-Cookie' => 'csrftoken=mock_token;' }
      )

    # Mock the phone search request with a successful response
    search_url = "#{@base_url}/search/reverse/?phone=2101234567"
    stub_request(:get, search_url).
      to_return(
        status: 200,
        body: {
          'data' => {
            'wp' => [
              {
                'name' => {
                  'first' => 'Γιάννης',
                  'last' => 'Παπαδόπουλος'
                }
              }
            ]
          }
        }.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

    # Mock the transliteration to return a known value
    Transliterator.stub :gr_to_lat, 'Giannis Papadopoulos' do
      result = @service.search_ote('2101234567')
      assert_equal 'Giannis Papadopoulos', result
    end
  end

  def test_non_200_response
    # Mock the initial request to get cookies/csrf token
    stub_request(:get, @base_url).
      to_return(
        status: 200,
        headers: { 'Set-Cookie' => 'csrftoken=mock_token;' }
      )

    # Mock the phone search request with a non-200 response
    search_url = "#{@base_url}/search/reverse/?phone=2101234567"
    stub_request(:get, search_url).
      to_return(status: 404)

    result = @service.search_ote('2101234567')
    assert_nil result
  end

  def test_network_error
    # Mock a network error
    stub_request(:get, @base_url).
      to_raise(Mechanize::Error)

    result = @service.search_ote('2101234567')
    assert_nil result
  end

  def test_json_parse_error
    # Mock the initial request to get cookies/csrf token
    stub_request(:get, @base_url).
      to_return(
        status: 200,
        headers: { 'Set-Cookie' => 'csrftoken=mock_token;' }
      )

    # Mock the phone search request with an invalid JSON response
    search_url = "#{@base_url}/search/reverse/?phone=2101234567"
    stub_request(:get, search_url).
      to_return(
        status: 200,
        body: 'invalid json',
        headers: { 'Content-Type' => 'application/json' }
      )

    result = @service.search_ote('2101234567')
    assert_nil result
  end
end

# Try to load rack-test but continue if it's not available
begin
  require 'rack/test'
  RACK_TEST_AVAILABLE = true
  puts "Rack-Test loaded successfully"
rescue LoadError
  RACK_TEST_AVAILABLE = false
  puts "Rack-Test not available - Sinatra tests will be skipped"
  puts "Run 'gem install rack-test' to enable Sinatra tests"
end

# Sinatra application tests
class AppTest < Minitest::Test
  def setup
    skip "Rack-Test not available" unless defined?(RACK_TEST_AVAILABLE) && RACK_TEST_AVAILABLE

    # Include Rack::Test::Methods if available
    self.class.include Rack::Test::Methods if defined?(RACK_TEST_AVAILABLE) && RACK_TEST_AVAILABLE

    # Enable WebMock to ensure no real HTTP requests
    WebMock.enable! if defined?(WEBMOCK_AVAILABLE) && WEBMOCK_AVAILABLE
    
    # Create a mock for the phone service
    @mock_service = Minitest::Mock.new

    # Store the original service
    @original_phone_service = $phone_service if defined?($phone_service)

    # Replace the global phone service with our mock
    $phone_service = @mock_service
  end

  def app
    Sinatra::Application
  end

  def teardown
    # Restore the original phone service if it exists
    $phone_service = @original_phone_service if defined?(@original_phone_service)
    
    # Disable WebMock after the test
    WebMock.disable! if defined?(WEBMOCK_AVAILABLE) && WEBMOCK_AVAILABLE
  end

  def test_successful_lookup
    # Set expectations for the mock
    @mock_service.expect :search_all, 'John Doe', ['2101234567']

    # Make the request
    get '/', phone: '2101234567'

    # Assert the response
    assert_equal 200, last_response.status
    assert_equal 'John Doe', last_response.body
    @mock_service.verify
  end

  def test_not_found
    # Set expectations for the mock
    @mock_service.expect :search_all, nil, ['2101234567']

    # Make the request
    get '/', phone: '2101234567'

    # Assert the response
    assert_equal 404, last_response.status
    assert_equal '', last_response.body
    @mock_service.verify
  end

  def test_error_handling
    # Set expectations for the mock to raise an exception
    @mock_service.expect :search_all, nil do |phone|
      raise StandardError, 'Test error'
    end

    # Make the request
    get '/', phone: '2101234567'

    # Assert the response
    assert_equal 500, last_response.status
    assert_equal '', last_response.body
    @mock_service.verify
  end
end
