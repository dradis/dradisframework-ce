# This class provides a flexible way to store user preferences using
# ActiveRecord's @serialize@ technique.
#
# This class is a bit of sugar on top of a standard `serialize :prefs, Hash`
# call as we can inspect the attributes and add additional logic without
# bloating the User model.
#
# The Class methods deal with ActiveRecord dump() and load(), and the Instance
# methods deal with user preferences.
#
# See:
#   http://viget.com/extend/how-i-used-activerecord-serialize-with-a-custom-data-type
#   http://ruby-journal.com/how-to-write-custom-serializer-for-activerecord-number-serialize/

class UserPreferences
  include ActiveModel::Conversion
  include ActiveModel::Validations

  DIGEST_FREQUENCIES = %w[none instant daily].freeze
  DIGEST_FREQUENCY_DEFAULT = 'instant'.freeze

  validates :digest_frequency,
    inclusion: {
      in: DIGEST_FREQUENCIES,
      digest_frequencies: "'#{DIGEST_FREQUENCIES.join("', '")}'"
    }

  # -- Class Methods ----------------------------------------------------------
  # Used for `serialize` method in ActiveRecord
  def self.dump(obj)
    return if obj.nil?

    unless obj.is_a?(self)
      raise ::ActiveRecord::SerializationTypeMismatch,
        "Attribute was supposed to be a #{self}, but was a #{obj.class}. -- #{obj.inspect}"
    end

    YAML.dump(obj)
  end

  def self.load(yaml)
    return self.new if self != Object && yaml.nil?
    return yaml unless yaml.is_a?(String) && yaml =~ /^---/

    obj = YAML.load(yaml)

    unless obj.is_a?(self) || obj.nil?
      raise SerializationTypeMismatch,
        "Attribute was supposed to be a #{self}, but was a #{obj.class}"
    end

    obj ||= self.new if self != Object

    # self.new(obj)
    obj
  end

  # -- Instance Methods -------------------------------------------------------

  # Preferences:
  #   digest_frequency - A user preference for how often they wish to receive
  #                      notification emails.
  #
  #   tours - This setting stores a dictionary of all the tours this user has
  #           seen. Since we can have multiple versions of each tour we need
  #           to be able to track what was the last version we presented to
  #           them. See TourRegistry class.
  ATTRIBUTES = %i[digest_frequency tours]
  attr_accessor *ATTRIBUTES

  def to_yaml_properties
    ATTRIBUTES.map { |attr| :"@#{attr}" }
  end

  def initialize(args={})
    @digest_frequency = args[:digest_frequency] || DIGEST_FREQUENCY_DEFAULT
    @tours = Hash.new { |hash, key| hash[key] = '0' }

    args.each do |key, value|
      if key.to_s =~ /\Atour_([\w_]*)\z/
        @tours[$1.to_sym] = value
      end
    end
  end

  # Needed for active model conversions, to work with form_with
  def persisted?
    true
  end

  TourRegistry::TOURS.keys.each do |tour|
    define_method "last_#{tour}" do
      @tours[tour]
    end

    define_method "last_#{tour}=" do |*args|
      @tours[tour] = args.first
    end
  end
end
