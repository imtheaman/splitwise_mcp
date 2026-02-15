class GetCurrentUser < FastMcp::Tool
  description 'Get information about the currently authenticated Splitwise user'

  def call
    CLIENT.get_current_user
  end
end

class GetUser < FastMcp::Tool
  description 'Get information about a specific Splitwise user by ID'

  arguments do
    required(:user_id).filled(:integer).description("The user's ID")
  end

  def call(user_id:)
    CLIENT.get_user(user_id)
  end
end

class UpdateUser < FastMcp::Tool
  description 'Update a user profile (can only update the current user)'

  arguments do
    required(:user_id).filled(:integer).description("The user's ID")
    optional(:first_name).filled(:string).description('New first name')
    optional(:last_name).filled(:string).description('New last name')
    optional(:email).filled(:string).description('New email address')
    optional(:default_currency).filled(:string).description("Default currency code, e.g. 'USD'")
    optional(:locale).filled(:string).description("Locale code, e.g. 'en'")
  end

  def call(user_id:, **updates)
    Validators.email!(updates[:email]) if updates[:email]
    Validators.currency_code!(updates[:default_currency]) if updates[:default_currency]
    CLIENT.update_user(user_id, updates.compact)
  end
end
