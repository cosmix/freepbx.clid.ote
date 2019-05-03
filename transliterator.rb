require 'unicode_utils/downcase'
require 'unicode_utils/titlecase'

module Transliterator
  GreekChars = Array['α', 'β', 'γ', 'δ', 'ε', 'ζ', 'η', 'θ', 'ι', 'κ', 'λ', 'μ', 'ν', 'ξ', 'ο', 'π', 'ρ', 'σ', 'τ', 'υ', 'φ', 'χ', 'ψ', 'ω', 'ς']
  LatinChars = Array['a', 'v', 'g', 'd', 'e', 'z', 'i', 'th', 'i', 'k', 'l', 'm', 'n', 'x', 'o', 'p', 'r', 's', 't', 'i', 'f', 'ch', 'ps', 'o', 's']
  SpecChars = Array['ο', 'α', 'ε']

  def self.grToLat(inString)
    outString = ''
    inString = UnicodeUtils.downcase(inString)

    specCharFound = nil

    inString.each_char do |ch|
      if GreekChars.include?(ch)

        if !specCharFound.nil?
          if specCharFound == 'ο'
            if ch == 'υ'
              outString += 'u'
              specCharFound = nil
              next
            end
          elsif specCharFound == 'α'
            if ch == 'υ'
              outString += 'f'
              specCharFound = nil
              next
            elsif ch == 'ι'
              outString += 'e'
              specCharFound = nil
              next
            end
          elsif specCharFound == 'ε'
            if ch == 'υ'
              outString += 'f'
              specCharFound = nil
              next
            end
          end

          outString += LatinChars[GreekChars.index(ch)]
          specCharFound = nil

        else
          specCharFound = ch if SpecChars.include?(ch)
          outString += LatinChars[GreekChars.index(ch)]
        end
      else
        outString += ch
      end
    end
    UnicodeUtils.titlecase(outString)
  end
end
