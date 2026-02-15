class GetFriends < FastMcp::Tool
  description 'Get all Splitwise friends for the current user'

  def call
    CLIENT.get_friends
  end
end

class GetFriend < FastMcp::Tool
  description 'Get details about a specific friend including balance'

  arguments do
    required(:user_id).filled(:integer).description("The friend's user ID")
  end

  def call(user_id:)
    CLIENT.get_friend(user_id)
  end
end

class CreateFriend < FastMcp::Tool
  description 'Add a friend by email. If the user does not exist, first_name is required.'

  arguments do
    required(:user_email).filled(:string).description("Friend's email address")
    optional(:user_first_name).filled(:string).description("Friend's first name (required if user doesn't exist)")
    optional(:user_last_name).filled(:string).description("Friend's last name")
  end

  def call(user_email:, user_first_name: nil, user_last_name: nil)
    Validators.email!(user_email)
    data = { user_email: user_email }
    data[:user_first_name] = user_first_name if user_first_name
    data[:user_last_name] = user_last_name if user_last_name
    CLIENT.create_friend(data)
  end
end

class CreateFriends < FastMcp::Tool
  description 'Add multiple friends at once. Each entry needs an email; first_name is required if the user does not exist.'

  arguments do
    required(:users).array(:hash) do
      required(:email).filled(:string)
      optional(:first_name).filled(:string)
      optional(:last_name).filled(:string)
    end.description('Array of friends to add')
  end

  def call(users:)
    raise ValidationError.new("At least 1 user is required", field: :users) if users.empty?
    users.each_with_index { |u, i| Validators.email!(u[:email]) }
    CLIENT.create_friends({ users: users })
  end
end

class DeleteFriend < FastMcp::Tool
  description 'Remove a friendship with a user'

  arguments do
    required(:user_id).filled(:integer).description('User ID of the friend to remove')
  end

  def call(user_id:)
    CLIENT.delete_friend(user_id)
  end
end
