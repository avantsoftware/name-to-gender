# frozen_string_literal: true

module NameGenderClassifier
  # If no match is found in the database, this module is called to predict the
  # gender based on the first name suffix.
  module FallbackGenderDetector
    # @return [String] the locale
    LOCALE = 'PT_BR'

    # @return [String] male suffix terminations for pt-br
    PT_BR_MALE_SUFFIXES = %w[ard as el eu ex iz is o on or os ur us rge me pe se re vi].freeze
    # @return [String] female suffix terminations for pt-br
    PT_BR_FEMALE_SUFFIXES = %w[a ais are ari eis eme ere ese iko ime ire yse ise isse
                               oko uko ume quel bel cao ce de dis le li lis liz lse ne
                               nis nge ris riz sse].freeze

    # Try to guess the gender based on first name suffix.
    #
    # @param name [String] first name
    #
    # @return [String] the gender
    def self.guess_gender(name)
      return 'female' if const_get("#{LOCALE}_FEMALE_SUFFIXES").any? { |t| name.end_with?(t) }
      return 'male' if const_get("#{LOCALE}_MALE_SUFFIXES").any? { |t| name.end_with?(t) }
    end
  end
end
