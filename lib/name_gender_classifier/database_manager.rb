# frozen_string_literal: true

require 'gdbm'

module NameGenderClassifier
  module DatabaseManager
    DB_NAME = 'lib/name_gender_classifier/classified_names_pt-br.db'

    def self.find(key)
      value = gdbm[key.to_s]
      gdbm.close
      @gdbm = nil

      value ? value.to_f : nil
    end

    def self.gdbm
      @gdbm ||= GDBM.new(DB_NAME)

      if block_given?
        yield(@gdbm)

        @gdbm.close
        @gdbm = nil
      else
        @gdbm
      end
    end
  end
end
