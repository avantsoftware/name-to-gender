require 'iconv'

# Gender detector for first names.
module NameGenderClassifier
  # Return the gender(s) (probabilistically) for the informed name(s). If arg is [String, Symbol],
  # then the gender [String] is returned. If arg is [Array<String>, Array<Symbol>], then an array
  # [Array<String>] with the genders is returned. If arg is [Array<Object>], then an array with the
  # same objects [Array<Object>] and the newly assigned gender is returned.
  #
  # @param arg [String, Symbol, Array<String>, Array<Symbol>, Array<Object>] argument holding first
  #   name(s) information(s).
  # @paran options [Hash] first_name_attribute: name of the method that returns the first name,
  #                       gender_attribute: name of the method which will receive the gender assignment.
  #
  # @return [String, Array<String>, Array<Object>] the gender classification for the passed first names
  def self.classify(arg, options = {})
    case arg
    when String, Symbol
      most_probable_gender(arg)
    when Array
      if arg[0].is_a?(String) || arg[0].is_a?(Symbol)
        classify_array(arg)
      else
        classify_objects(arg, options)
      end
    end
  end

  # Return the genders (probabilistically) for the informed names.
  #
  # @param array [Array<String>, Array<Symbol>] see {NameGenderClassifier.classify}
  #
  # @return [Array<String>] see {NameGenderClassifier.classify}
  def self.classify_array(array)
    result = []
    DatabaseManager.gdbm do |db|
      array.each do |name|
        next unless name

        result << most_probable_gender(name, db)
      end
    end

    result
  end

  # For each object in the array, it tries to classify the gender for object.first_name or
  # object.name (or equivalent method) and save it on object.gender (or equivalent method).
  #
  # @param objects [Array<Object>] see {NameGenderClassifier.classify}
  # @param options see {NameGenderClassifier.classify}
  #
  # @return [Array<Object>] the objects with the assigned genders
  def self.classify_objects(objects, options = {})
    gender_attribute = options.fetch(:gender_attribute, 'gender')
    first_name_attribute = options.fetch(:first_name_attribute, nil)
    gender_attribute_assignment = "#{gender_attribute}="
    if first_name_attribute.nil?
      first_name_attribute = :first_name if defined?(objects[0].first_name)
      first_name_attribute = :name if defined?(objects[0].name)

      if first_name_attribute.nil?
        puts 'The object doesn\'t have the methods \'name\' nor \'first_name\'. '\
            'Use #classify(arg, first_name_attribute: nil, gender_attribute: nil) '\
            'to inform which methods to lookup.'

        return objects
      end
    end

    DatabaseManager.gdbm do |db|
      objects.each do |object|
        next unless name = object.public_send(first_name_attribute)

        object.public_send(gender_attribute_assignment, most_probable_gender(name, db))
      end
    end

    objects
  end

  # Remove whitespaces, secondary names, accents, digits and transform to string and lower case.
  def self.remove_unwanted_chars(name)
    Iconv.iconv('ascii//translit//ignore', 'utf-8', name.to_s.strip.split(' ')[0].downcase)[0].gsub(/\W+/, '')
  end
  private_class_method :remove_unwanted_chars

  # @return [String, nil] the gender of the informed name
  def self.most_probable_gender(name, db = nil)
    name = remove_unwanted_chars(name)

    if fem_probability = db ? db[name]&.to_f : DatabaseManager.find(name)
      fem_probability >= 0.5 ? 'female' : 'male'
    else
      FallbackGenderDetector.guess_gender(name)
    end
  end
  private_class_method :most_probable_gender
end

require 'name_gender_classifier/database_manager'
require 'name_gender_classifier/fallback_gender_detector'
