require 'unicode_utils/downcase'
require 'unicode_utils/titlecase'

module Transliterator
  GREEK_TO_LATIN = {
    # Basic mappings
    'α' => 'a', 'β' => 'b', 'γ' => 'g', 'δ' => 'd', 'ε' => 'e',
    'ζ' => 'z', 'η' => 'i', 'θ' => 'th', 'ι' => 'i', 'κ' => 'k',
    'λ' => 'l', 'μ' => 'm', 'ν' => 'n', 'ξ' => 'x', 'ο' => 'o',
    'π' => 'p', 'ρ' => 'r', 'σ' => 's', 'τ' => 't', 'υ' => 'y',
    'φ' => 'f', 'χ' => 'ch', 'ψ' => 'ps', 'ω' => 'o', 'ς' => 's'
  }.freeze
  # Special rules for DIPTHONGS followed by specific characters
  # Including 'ευ' and 'αυ' cases based on the next character

  DIPTHONGS = {
    'ευ' => { 'default' => 'ef', 'exceptions' => 'ev' },
    'αυ' => { 'default' => 'af', 'exceptions' => 'av' }
  }.freeze

  VOWELS = %w[α ε η ι ο υ ω].freeze

  def self.gr_to_lat(in_string) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    out_string = ''
    normalized_string = UnicodeUtils.downcase(in_string).unicode_normalize(:nfd).gsub(/[\u0300-\u036f]/, '')

    i = 0
    while i < normalized_string.length
      ch = normalized_string[i]
      next_ch = normalized_string[i + 1] || ''

      # Handle DIPTHONGS
      diphthong_handled = false
      DIPTHONGS.each do |diphthong, rules|
        next unless (ch + next_ch).start_with?(diphthong)

        out_string += if i + 2 < normalized_string.length && VOWELS.include?(normalized_string[i + 2])
                        rules['exceptions']
                      else
                        rules['default']
                      end
        i += 2 # Skip the next character as part of diphthong
        diphthong_handled = true
        break
      end

      unless diphthong_handled
        if GREEK_TO_LATIN[ch]
          out_string += GREEK_TO_LATIN[ch]
          i += 1
        else
          out_string += ch
          i += 1
        end
      end
    end

    UnicodeUtils.titlecase(out_string)
  end
end
