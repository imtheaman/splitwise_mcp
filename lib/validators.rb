require 'date'

module Validators
  def self.required!(value, field_name)
    return unless value.nil? || (value.respond_to?(:empty?) && value.empty?)

    raise ValidationError.new("#{field_name} is required",
                              field: field_name)
  end

  def self.positive_number!(value, field_name)
    return if value.is_a?(Numeric) && value.positive?

    raise ValidationError.new("#{field_name} must be positive",
                              field: field_name)
  end

  def self.currency_code!(value)
    return if value.match?(/\A[A-Z]{3}\z/)

    raise ValidationError.new('Currency code must be 3 uppercase letters (e.g., USD)',
                              field: :currency_code)
  end

  def self.iso_date!(value)
    Date.iso8601(value)
  rescue Date::Error
    raise ValidationError.new('Date must be valid ISO 8601 format (e.g., 2024-01-15)', field: :date)
  end

  def self.email!(value)
    raise ValidationError.new('Invalid email format', field: :email) unless value.match?(/\A[^@\s]+@[^@\s]+\.[^@\s]+\z/)
  end

  def self.decimal_amount!(value, field_name)
    raise ValidationError.new("#{field_name} must be a decimal amount (e.g., '25.00')", field: field_name) unless value.match?(/\A\d+(\.\d{1,2})?\z/)
  end

  def self.in_range!(value, field_name, min: nil, max: nil)
    raise ValidationError.new("#{field_name} must be >= #{min}", field: field_name) if min && value < min
    raise ValidationError.new("#{field_name} must be <= #{max}", field: field_name) if max && value > max
  end

  def self.one_of!(value, field_name, choices)
    return if choices.include?(value)

    raise ValidationError.new("#{field_name} must be one of: #{choices.join(', ')}",
                              field: field_name)
  end
end
