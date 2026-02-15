class GetNotifications < FastMcp::Tool
  description 'Get recent notifications for the current user'

  arguments do
    optional(:updated_after).filled(:string).description('ISO 8601 datetime — only notifications after this time')
    optional(:limit).filled(:integer).description('Max notifications to return (0 for maximum)')
  end

  def call(updated_after: nil, limit: nil)
    Validators.iso_date!(updated_after) if updated_after
    params = {}
    params[:updated_after] = updated_after if updated_after
    params[:limit] = limit if limit
    CLIENT.get_notifications(params)
  end
end
