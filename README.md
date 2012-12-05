freepbx.clid.ote
================

This is a basic Sinatra-based script using Mechanize to scrape caller id data from OTE's (Hellenic Telecommunications Corporation) public 11888.gr web site (formerly whitepages.gr) and be used as an http source for the clid module of FreePBX.

Installation 
============

Setup your favourite web server on your intranet/public box and make sure it can properly run Ruby scripts. Depending on your needs, you may want to setup something simple or a more elaborate setup. Apache or nginx with Passenger or Unicorn are pretty typical. You will also need Sinatra and Mechanize. The former is a "DSL for quickly creating web applications in Ruby with minimal effort". Mechanize is a "library for automating interaction with websites". For transliteration Unicode Utils are also used. All those libraries are available as gems.

Usage
=====

You can set this up as an http-based provider for the clid module in FreePBX. It has been tested under FreePBX 2.10, but it should also work in previous versions, as long as the clid module supports http-based providers.

License
=======

This script is licensed under the [MIT License](http://opensource.org/licenses/MIT)

Copyright (C) 2012 Cosmix.org
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.