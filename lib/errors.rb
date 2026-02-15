class SplitwiseApiError < StandardError
  attr_reader :status_code, :error_type, :details

  def initialize(message, status_code:, error_type:, details: {})
    @status_code = status_code
    @error_type = error_type
    @details = details
    super(message)
  end

  def self.for_status(status, body)
    msg = if body.is_a?(Hash)
            body['error'] || extract_errors(body['errors']) || body.to_s
          else
            body.to_s
          end

    case status
    when 401 then new("Authentication failed: #{msg}", status_code: 401, error_type: :authentication)
    when 403 then new("Authorization denied: #{msg}", status_code: 403, error_type: :authorization)
    when 404 then new("Not found: #{msg}", status_code: 404, error_type: :not_found)
    when 400 then new("Validation error: #{msg}", status_code: 400, error_type: :validation)
    when 429 then RateLimitError.new("Rate limited: #{msg}", retry_after: body.is_a?(Hash) ? body['retry_after'] : nil)
    else
      new("API error (#{status}): #{msg}", status_code: status, error_type: :server_error)
    end
  end

  def self.extract_errors(errors)
    return nil unless errors

    case errors
    when Hash
      errors.values.flatten.join(', ').then { |s| s.empty? ? nil : s }
    when Array
      errors.any? ? errors.join(', ') : nil
    else
      errors.to_s
    end
  end
end

class RateLimitError < SplitwiseApiError
  attr_reader :retry_after

  def initialize(message, retry_after: nil)
    @retry_after = retry_after
    super(message, status_code: 429, error_type: :rate_limit)
  end
end

class ValidationError < StandardError
  attr_reader :field, :details

  def initialize(message, field: nil, details: {})
    @field = field
    @details = details
    super(message)
  end
end
