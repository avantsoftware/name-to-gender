# frozen_string_literal: true

module NameGenderClassifier
  module FallbackGenderDetector
    LOCALE = 'PT_BR'

    PT_BR_MALE_SUFFIXES = %w[ard as el eu ex iz is o on or os ur us rge me pe se re vi].freeze
    PT_BR_FEMALE_SUFFIXES = %w[a ais are ari eis eme ere ese iko ime ire yse ise isse
                               oko uko ume quel bel cao ce de dis le li lis liz lse ne
                               nis nge ris riz sse].freeze

    def self.guess_gender(name)
      return :female if const_get("#{LOCALE}_FEMALE_SUFFIXES").any? { |t| name.end_with?(t) }
      return :male if const_get("#{LOCALE}_MALE_SUFFIXES").any? { |t| name.end_with?(t) }
    end
  end
end
