class ResolveFriend < FastMcp::Tool
  description 'Find a friend by name using fuzzy matching. Use this before other tools when you have a name but need an ID.'

  arguments do
    required(:query).filled(:string).description('Friend name or partial name')
    optional(:threshold).filled(:integer).description('Match score threshold 0-100 (default from config)')
  end

  def call(query:, threshold: nil)
    args = { threshold: threshold }.compact
    RESOLVER.resolve_friend(query, **args)
  end
end

class ResolveGroup < FastMcp::Tool
  description 'Find a group by name using fuzzy matching'

  arguments do
    required(:query).filled(:string).description('Group name or partial name')
    optional(:threshold).filled(:integer).description('Match score threshold 0-100 (default from config)')
  end

  def call(query:, threshold: nil)
    args = { threshold: threshold }.compact
    RESOLVER.resolve_group(query, **args)
  end
end

class ResolveCategory < FastMcp::Tool
  description 'Find an expense category by name using fuzzy matching'

  arguments do
    required(:query).filled(:string).description('Category name or partial name')
    optional(:threshold).filled(:integer).description('Match score threshold 0-100 (default from config)')
  end

  def call(query:, threshold: nil)
    args = { threshold: threshold }.compact
    RESOLVER.resolve_category(query, **args)
  end
end
