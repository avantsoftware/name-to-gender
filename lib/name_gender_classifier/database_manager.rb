# frozen_string_literal: true

require 'gdbm'

module NameGenderClassifier
  # Uses GDBM database to retrieve gender classification from {DB_NAME}.
  module DatabaseManager
    # @return [String] the database location (which holds the classified names)
    DB_NAME = "#{Gem.loaded_specs['name_gender_classifier'].gem_dir}/lib/"\
              'name_gender_classifier/classified_names_pt-br.db'

    # Find in the database the value for a previously saved key. The key holds the first name
    # and the value the gender probability.
    #
    # @param key [String, Symbol] a key to be searched in the database
    #
    # @return [Float] the gender probability (value between 0 and 1, where 0 <= male < 0.5 <= female <= 1)
    def self.find(key)
      value = gdbm[key.to_s]
      gdbm.close
      @gdbm = nil

      value ? value.to_f : nil
    end

    # With a block { |db| ... } allow to read multiple records with a single database open request,
    # or return the database instance for a single read request.
    #
    # @yard [db] gives the database instance to the block
    # @return [GDBM, nil] the GDBM database instance or nil if used with a block
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
