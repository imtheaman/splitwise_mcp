class GetComments < FastMcp::Tool
  description 'Get all comments on an expense'

  arguments do
    required(:expense_id).filled(:integer).description('The expense ID')
  end

  def call(expense_id:)
    CLIENT.get_comments(expense_id)
  end
end

class CreateComment < FastMcp::Tool
  description 'Add a comment to an expense'

  arguments do
    required(:expense_id).filled(:integer).description('The expense ID')
    required(:content).filled(:string).description('Comment text')
  end

  def call(expense_id:, content:)
    CLIENT.create_comment({ expense_id: expense_id, content: content })
  end
end

class DeleteComment < FastMcp::Tool
  description 'Delete a comment'

  arguments do
    required(:comment_id).filled(:integer).description('The comment ID')
  end

  def call(comment_id:)
    CLIENT.delete_comment(comment_id)
  end
end
