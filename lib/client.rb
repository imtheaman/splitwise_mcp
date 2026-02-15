require 'faraday'

class SplitwiseClient
  BASE_URL = 'https://secure.splitwise.com/api/v3.0'

  def initialize(auth_token, cache_ttl: 86_400)
    @cache = Cache.new(ttl: cache_ttl)
    @conn = Faraday.new(url: BASE_URL) do |f|
      f.request :json
      f.response :json
      f.headers['Authorization'] = "Bearer #{auth_token}"
      f.headers['Accept'] = 'application/json'
      f.options.timeout = 30
    end
  end

  private

  def get(path, params = {})
    res = @conn.get(path, params)
    handle_response(res)
  rescue Faraday::ConnectionFailed => e
    raise SplitwiseApiError.new("Connection failed: #{e.message}", status_code: 0, error_type: :connection)
  rescue Faraday::TimeoutError
    raise SplitwiseApiError.new("Request timed out", status_code: 0, error_type: :timeout)
  end

  def post(path, body = {})
    res = @conn.post(path, flatten_data(body))
    handle_response(res)
  rescue Faraday::ConnectionFailed => e
    raise SplitwiseApiError.new("Connection failed: #{e.message}", status_code: 0, error_type: :connection)
  rescue Faraday::TimeoutError
    raise SplitwiseApiError.new("Request timed out", status_code: 0, error_type: :timeout)
  end

  def handle_response(res)
    raise SplitwiseApiError.for_status(res.status, res.body) unless res.success?

    res.body
  end

  def check_success!(result)
    return result unless result.is_a?(Hash)

    errors = result['errors']
    has_errors = case errors
                 when Hash then errors.values.flatten.any?
                 when Array then errors.any?
                 else false
                 end

    if has_errors || result['success'] == false
      msg = SplitwiseApiError.extract_errors(errors) || 'Operation failed'
      raise SplitwiseApiError.new(msg, status_code: 200, error_type: :api_error)
    end

    result
  end

  def flatten_data(data, prefix = nil)
    result = {}
    case data
    when Hash
      data.each do |key, value|
        full_key = prefix ? "#{prefix}__#{key}" : key.to_s
        if value.is_a?(Hash) || value.is_a?(Array)
          result.merge!(flatten_data(value, full_key))
        else
          result[full_key] = value
        end
      end
    when Array
      data.each_with_index do |item, index|
        result.merge!(flatten_data(item, "#{prefix}__#{index}"))
      end
    else
      result[prefix] = data
    end
    result
  end

  public

  # ====== Users =====
  def get_current_user
    get('get_current_user')
  end

  def get_user(user_id)
    get("get_user/#{user_id}")
  end

  def update_user(user_id, data)
    check_success!(post("update_user/#{user_id}", data))
  end

  # ====== Expenses =====
  def get_expenses(params = {})
    get('get_expenses', params)
  end

  def get_expense(expense_id)
    get("get_expense/#{expense_id}")
  end

  def create_expense(data)
    check_success!(post('create_expense', data))
  end

  def update_expense(expense_id, data)
    check_success!(post("update_expense/#{expense_id}", data))
  end

  def delete_expense(expense_id)
    check_success!(post("delete_expense/#{expense_id}"))
  end

  def undelete_expense(expense_id)
    check_success!(post("undelete_expense/#{expense_id}"))
  end

  # ====== Groups =====
  def get_groups
    get('get_groups')
  end

  def get_group(group_id)
    get("get_group/#{group_id}")
  end

  def create_group(data)
    check_success!(post('create_group', data))
  end

  def delete_group(group_id)
    check_success!(post("delete_group/#{group_id}"))
  end

  def undelete_group(group_id)
    check_success!(post("undelete_group/#{group_id}"))
  end

  def add_user_to_group(data)
    check_success!(post('add_user_to_group', data))
  end

  def remove_user_from_group(data)
    check_success!(post('remove_user_from_group', data))
  end

  # ====== Friends =====
  def get_friends
    get('get_friends')
  end

  def get_friend(user_id)
    get("get_friend/#{user_id}")
  end

  def create_friend(data)
    check_success!(post('create_friend', data))
  end

  def create_friends(data)
    check_success!(post('create_friends', data))
  end

  def delete_friend(user_id)
    check_success!(post("delete_friend/#{user_id}"))
  end

  # ====== Comments =====
  def get_comments(expense_id)
    get('get_comments', { expense_id: expense_id })
  end

  def create_comment(data)
    check_success!(post('create_comment', data))
  end

  def delete_comment(comment_id)
    check_success!(post("delete_comment/#{comment_id}"))
  end

  # ====== Notifications =====
  def get_notifications(params = {})
    get('get_notifications', params)
  end

  # ====== Other =====
  def get_categories
    @cache.fetch(:categories) { get('get_categories') }
  end

  def get_currencies
    @cache.fetch(:currencies) { get('get_currencies') }
  end
end
