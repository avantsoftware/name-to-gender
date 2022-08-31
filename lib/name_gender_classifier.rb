require 'iconv'

module NameGenderClassifier
  # Return the gender(s) (probabilistically) for the informed name(s).
  #
  # @param [String, Array<String>, Array<Object>] arg Argument holding the first name(s) information(s).
  # @paran [Hash] options first_name_attribute: name of the method that returns the first name
  #                       gender_attribute: name of the method which will receive the gender assignment.
  #
  # @return [Symbol, Array<Symbol>, Array<Object>]
  def self.classify(arg, options = {})
    case arg
    when String
      most_probable_gender(arg)
    when Array
      if arg[0].is_a?(String)
        classify_array(arg)
      else
        classify_objects(arg, options)
      end
    end
  end

  # Return the genders (probabilistically) for the informed names.
  #
  # @param [Array<String>] array Array holding first names.
  #
  # @return [Array<Symbol>]
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
  # @param [Array<Object>] objects Array of objects holding first names.
  # @paran [Hash] options first_name_attribute: name of the method that returns the first name
  #                       gender_attribute: name of the method which will receive the gender assignment.
  #
  # @return [Array<Object>]
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

  # Remove whitespaces, secondary names, accents, digits and transform to lower case.
  def self.remove_unwanted_chars(name)
    Iconv.iconv('ascii//translit//ignore', 'utf-8', name.strip.split(' ')[0].downcase)[0].gsub(/\W+/, '')
  end
  private_class_method :remove_unwanted_chars

  def self.most_probable_gender(name, db = nil)
    name = remove_unwanted_chars(name)

    if fem_probability = db ? db[name]&.to_f : DatabaseManager.find(name)
      fem_probability >= 0.5 ? :female : :male
    else
      FallbackGenderDetector.guess_gender(name)
    end
  end
  private_class_method :most_probable_gender
end

require 'name_gender_classifier/database_manager'
require 'name_gender_classifier/fallback_gender_detector'
