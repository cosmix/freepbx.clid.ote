freepbx.clid.ote
================

This is a trivial `Sinatra`-based service using `Mechanize` to scrape caller id data from OTE's (Hellenic Telecommunications Corporation) public 11888.gr web site and render it as plain text, in a manner that is usable by the clid module of FreePBX.

Installation
============

Note that the current version of this script is dockerized. You will, obviously, require Docker to build the image and run the container.

If you prefer to do this the old-fashioned way (say for development purposes), you can use `bundler` to get the appropriate gems installed on your system. Depending on your needs/volume of requests, you may want to setup something simple or a more elaborate setup with `nginx` or `haproxy` in front of multiple instances etc. All the dependencies are available as gems and you will be able to install everything you need using the provided `Gemfile`.

Usage
=====

To use this from FreePBX, you will first have to set it up as an http-based provider in the clid module. It has been tested under FreePBX 2.10 and 11 but it should also work in previous (and future) versions, as long as the clid module maintains support for http-based providers.

_Note that FreePBX caches known numbers in Asterisk's internal database and consults that **before** hitting the CLID providers. You will need to purge 'previously seen' numbers from the database if you want to debug this script's function. You can do that by using `database del cidname [phone number]` in the Asterisk console._
