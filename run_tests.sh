#!/usr/bin/env bash
# Run the unit and integration tests

echo "=== Phone Directory Service Test Suite ==="
echo

# Check if required gems are installed
echo "Checking for test dependencies..."
ruby -e "begin; require 'webmock'; puts 'WebMock: Installed ✓'; rescue LoadError; puts 'WebMock: Not installed ✗'; end"
ruby -e "begin; require 'rack/test'; puts 'Rack-Test: Installed ✓'; rescue LoadError; puts 'Rack-Test: Not installed ✗'; end"
ruby -e "begin; require 'mocha/minitest'; puts 'Mocha: Installed ✓'; rescue LoadError; puts 'Mocha: Not installed ✗'; end"
echo

echo "Running tests (some tests may be skipped if dependencies are missing)..."
echo "Basic unit tests will still run regardless of missing dependencies."
echo

ruby app_test.rb

echo
echo "To run real integration tests against the actual directory service:"
echo "  ./real_integration_test.rb"
echo
echo "To install all test dependencies:"
echo "  gem install webmock rack-test mocha"
echo
