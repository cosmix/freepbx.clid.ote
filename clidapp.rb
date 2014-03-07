# encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'mechanize'
require "unicode_utils/downcase"
require "unicode_utils/titlecase"

GreekChars = Array['α','β','γ','δ','ε','ζ','η','θ','ι','κ','λ','μ','ν','ξ','ο','π','ρ','σ','τ','υ','φ','χ','ψ','ω','ς']
LatinChars = Array['a','v','g','d','e','z','i','th','i','k','l','m','n','x','o','p','r','s','t','i','f','ch','ps','o','s']
SpecChars = Array['ο','α','ε']


class XmlParser < Mechanize::File
  attr_reader :xml
  def initialize(uri = nil, response = nil, body = nil, code = nil)
    @xml = Nokogiri::XML(body)
    super uri, response, body, code
  end
end


def transl(inString)
  outString = ""
  inString = UnicodeUtils.downcase(inString)

  specCharFound = nil

  inString.each_char do |ch|
    if (GreekChars.include?(ch))

      if (specCharFound != nil)
        if (specCharFound == "ο")
          if (ch == "υ")
            outString += "u"
            specCharFound = nil
            next
          end
        elsif (specCharFound == "α")
          if (ch == "υ")
            outString += "f"
            specCharFound = nil
            next
          elsif (ch == "ι")
            outString += "e"
            specCharFound = nil
            next
          end
        elsif (specCharFound == "ε")
          if (ch == "υ")
            outString += "f"
            specCharFound = nil
            next
          end
        end

        outString += LatinChars[GreekChars.index(ch)]
        specCharFound = nil

      else 
        if (SpecChars.include?(ch))
          specCharFound = ch
        end
        outString += LatinChars[GreekChars.index(ch)]
      end
    else
      outString += ch
    end	
  end
  UnicodeUtils.titlecase(outString)
end


def searchOTE(phoneNo)
  athensNo = /^(21\d{8})/
  greekNo = /^30(\d*)/

  match = athensNo.match phoneNo

  if (match == nil)
    match = greekNo.match phoneNo
  end


  if (match != nil) 
    pageurl = "http://11888.ote.gr/web/guest/white-pages/search?who=" + match[1]

    a = Mechanize.new
    page = a.get(pageurl)

    result = page.parser.xpath("//*[@id=\"_whitepagessearchportlet_WAR_yellowpagesportlet_fm\"]/div[3]/div[3]/div/div[1]/div[1]/h3").to_s

    filterRegEx = /<h3>(.*)<span><\/span>/mi

    filtResult = filterRegEx.match result

    if (filtResult != nil)
      "[OTE] " + transl(filtResult[1]).gsub(/<\/?.*?>/,'').gsub(/\n/,' - ')
    end
  end
end


def searchAll(phoneNumber) 

  content_type 'text/plain'

  # add calls to higher-priority search result functions here.

  if (phoneNumber == "Anonymous")
    return

  if (res == nil)
    res = searchOTE(phoneNumber)
  end

  "#{res}"
end



get '/' do 

  "#{searchAll(params[:phone])}"

end