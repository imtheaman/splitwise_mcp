class GetExpenses < FastMcp::Tool
  description 'Get a list of expenses with optional filters'

  arguments do
    optional(:group_id).filled(:integer).description('Filter by group ID')
    optional(:friend_id).filled(:integer).description('Filter by friend ID')
    optional(:dated_after).filled(:string).description('ISO 8601 date — only expenses after this date')
    optional(:dated_before).filled(:string).description('ISO 8601 date — only expenses before this date')
    optional(:updated_after).filled(:string).description('ISO 8601 date — only expenses updated after')
    optional(:updated_before).filled(:string).description('ISO 8601 date — only expenses updated before')
    optional(:limit).filled(:integer).description('Max results (default 20)')
    optional(:offset).filled(:integer).description('Pagination offset (default 0)')
  end

  def call(**params)
    %i[dated_after dated_before updated_after updated_before].each do |key|
      Validators.iso_date!(params[key]) if params[key]
    end
    Validators.in_range!(params[:limit], :limit, min: 1) if params[:limit]
    params[:limit] ||= 20
    params[:offset] ||= 0
    CLIENT.get_expenses(params.compact)
  end
end

class GetExpense < FastMcp::Tool
  description 'Get detailed information about a specific expense'

  arguments do
    required(:expense_id).filled(:integer).description('The expense ID')
  end

  def call(expense_id:)
    CLIENT.get_expense(expense_id)
  end
end

class CreateExpense < FastMcp::Tool
  description 'Create a new expense in Splitwise. Either split equally within a group, or provide custom user splits.'

  arguments do
    required(:cost).filled(:string).description("Decimal amount as string, e.g. '25.00'")
    required(:description).filled(:string).description('What the expense is for')
    required(:group_id).filled(:integer).description('Group ID (use 0 for non-group expense)')
    optional(:currency_code).filled(:string).description("3-letter currency code, e.g. 'USD'")
    optional(:date).filled(:string).description('ISO 8601 datetime, e.g. 2024-01-15T10:30:00Z')
    optional(:category_id).filled(:integer).description('Expense category ID (must be a subcategory)')
    optional(:details).filled(:string).description('Long-form notes about the expense')
    optional(:repeat_interval).filled(:string).description("Repeat: 'never', 'weekly', 'fortnightly', 'monthly', or 'yearly'")
    optional(:split_equally).filled(:bool).description('Split equally among group members (default false). Requires group_id > 0')
    optional(:users).array(:hash) do
      required(:user_id).filled(:integer)
      required(:paid_share).filled(:string)
      required(:owed_share).filled(:string)
    end.description('Custom user splits with paid_share and owed_share as decimal strings')
  end

  def call(cost:, description:, group_id:, currency_code: 'USD', date: nil, category_id: nil,
           details: nil, repeat_interval: nil, split_equally: false, users: nil)
    Validators.decimal_amount!(cost, :cost)
    Validators.currency_code!(currency_code)
    Validators.iso_date!(date) if date
    Validators.one_of!(repeat_interval, :repeat_interval, %w[never weekly fortnightly monthly yearly]) if repeat_interval

    if split_equally && group_id == 0
      raise ValidationError.new("group_id must be > 0 when splitting equally", field: :group_id)
    end

    data = {
      cost: cost,
      description: description,
      group_id: group_id,
      currency_code: currency_code
    }
    data[:split_equally] = split_equally if split_equally
    data[:date] = date if date
    data[:category_id] = category_id if category_id
    data[:details] = details if details
    data[:repeat_interval] = repeat_interval if repeat_interval
    data[:users] = users if users
    CLIENT.create_expense(data)
  end
end

class UpdateExpense < FastMcp::Tool
  description 'Update an existing expense. Only include fields that are changing.'

  arguments do
    required(:expense_id).filled(:integer).description('ID of the expense to update')
    optional(:cost).filled(:string).description('New amount as decimal string')
    optional(:description).filled(:string).description('New description')
    optional(:date).filled(:string).description('New date (ISO 8601)')
    optional(:category_id).filled(:integer).description('New category ID')
    optional(:details).filled(:string).description('New notes')
    optional(:repeat_interval).filled(:string).description("Repeat: 'never', 'weekly', 'fortnightly', 'monthly', or 'yearly'")
    optional(:currency_code).filled(:string).description('New currency code')
    optional(:users).array(:hash) do
      required(:user_id).filled(:integer)
      required(:paid_share).filled(:string)
      required(:owed_share).filled(:string)
    end.description('Updated user splits (overwrites all existing splits)')
  end

  def call(expense_id:, **updates)
    Validators.decimal_amount!(updates[:cost], :cost) if updates[:cost]
    Validators.iso_date!(updates[:date]) if updates[:date]
    Validators.currency_code!(updates[:currency_code]) if updates[:currency_code]
    Validators.one_of!(updates[:repeat_interval], :repeat_interval, %w[never weekly fortnightly monthly yearly]) if updates[:repeat_interval]
    CLIENT.update_expense(expense_id, updates.compact)
  end
end

class DeleteExpense < FastMcp::Tool
  description 'Delete an expense'

  arguments do
    required(:expense_id).filled(:integer).description('ID of the expense to delete')
  end

  def call(expense_id:)
    CLIENT.delete_expense(expense_id)
  end
end

class UndeleteExpense < FastMcp::Tool
  description 'Restore a previously deleted expense'

  arguments do
    required(:expense_id).filled(:integer).description('ID of the expense to restore')
  end

  def call(expense_id:)
    CLIENT.undelete_expense(expense_id)
  end
end
