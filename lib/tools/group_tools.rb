class GetGroups < FastMcp::Tool
  description 'Get all Splitwise groups for the current user'

  def call
    CLIENT.get_groups
  end
end

class GetGroup < FastMcp::Tool
  description 'Get details for a specific group including debts and members'

  arguments do
    required(:group_id).filled(:integer).description('The group ID')
  end

  def call(group_id:)
    CLIENT.get_group(group_id)
  end
end

class CreateGroup < FastMcp::Tool
  description 'Create a new Splitwise group'

  arguments do
    required(:name).filled(:string).description('Group name')
    optional(:group_type).filled(:string).description("Type: 'home', 'trip', 'couple', 'apartment', 'house', or 'other' (default)")
    optional(:simplify_by_default).filled(:bool).description('Simplify debts (default true)')
    optional(:users).array(:hash) do
      optional(:user_id).filled(:integer)
      optional(:first_name).filled(:string)
      optional(:last_name).filled(:string)
      optional(:email).filled(:string)
    end.description('Initial group members')
  end

  def call(name:, group_type: 'other', simplify_by_default: true, users: nil)
    Validators.one_of!(group_type, :group_type, %w[home trip couple apartment house other])
    if users
      users.each_with_index do |u, i|
        unless u[:user_id] || u[:email]
          raise ValidationError.new("users[#{i}] must have a user_id or email", field: :users)
        end
      end
    end
    data = { name: name, group_type: group_type, simplify_by_default: simplify_by_default }
    data[:users] = users if users
    CLIENT.create_group(data)
  end
end

class DeleteGroup < FastMcp::Tool
  description 'Delete a Splitwise group'

  arguments do
    required(:group_id).filled(:integer).description('ID of the group to delete')
  end

  def call(group_id:)
    CLIENT.delete_group(group_id)
  end
end

class AddUserToGroup < FastMcp::Tool
  description 'Add a user to a Splitwise group by user_id or email'

  arguments do
    required(:group_id).filled(:integer).description('Group ID')
    optional(:user_id).filled(:integer).description('User ID (if known)')
    optional(:email).filled(:string).description('Email (if user_id not provided)')
    optional(:first_name).filled(:string).description('First name (for new invites)')
    optional(:last_name).filled(:string).description('Last name (for new invites)')
  end

  def call(group_id:, user_id: nil, email: nil, first_name: nil, last_name: nil)
    raise ValidationError.new("Either user_id or email is required", field: :user_id) unless user_id || email
    if email && !user_id
      Validators.email!(email)
      Validators.required!(first_name, :first_name)
      Validators.required!(last_name, :last_name)
    end
    data = { group_id: group_id }
    data[:user_id] = user_id if user_id
    data[:email] = email if email
    data[:first_name] = first_name if first_name
    data[:last_name] = last_name if last_name
    CLIENT.add_user_to_group(data)
  end
end

class UndeleteGroup < FastMcp::Tool
  description 'Restore a previously deleted Splitwise group'

  arguments do
    required(:group_id).filled(:integer).description('ID of the group to restore')
  end

  def call(group_id:)
    CLIENT.undelete_group(group_id)
  end
end

class RemoveUserFromGroup < FastMcp::Tool
  description 'Remove a user from a Splitwise group'

  arguments do
    required(:group_id).filled(:integer).description('Group ID')
    required(:user_id).filled(:integer).description('User ID to remove')
  end

  def call(group_id:, user_id:)
    CLIENT.remove_user_from_group({ group_id: group_id, user_id: user_id })
  end
end
