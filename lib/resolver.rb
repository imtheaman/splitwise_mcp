require 'amatch'

class EntityResolver
  def initialize(client, threshold: 70, cache_ttl: 300)
    @client = client
    @threshold = threshold
    @cache = Cache.new(ttl: cache_ttl)
  end

  def resolve_friend(query, threshold: @threshold)
    friends = @cache.fetch(:friends) { fetch_friends_list }
    fuzzy_search(query, friends, threshold) { |f| "#{f['first_name']} #{f['last_name']}".strip }
  end

  def resolve_group(query, threshold: @threshold)
    groups = @cache.fetch(:groups) { fetch_groups_list }
    fuzzy_search(query, groups, threshold) { |g| g['name'] }
  end

  def resolve_category(query, threshold: @threshold)
    categories = @cache.fetch(:categories) { fetch_all_categories }
    fuzzy_search(query, categories, threshold) { |c| c['name'] }
  end

  private

  def fetch_friends_list
    result = @client.get_friends
    result['friends'] || []
  end

  def fetch_groups_list
    result = @client.get_groups
    result['groups'] || []
  end

  def fetch_all_categories
    result = @client.get_categories
    cats = result['categories'] || []
    cats.flat_map { |c| [c] + (c['subcategories'] || []) }
  end

  def fuzzy_search(query, items, threshold)
    results = items.map do |item|
      name = yield(item)
      score = similarity_score(query.downcase, name.downcase)
      { item: item, name: name, score: score }
    end
    results
      .select { |r| r[:score] >= threshold }
      .sort_by { |r| -r[:score] }
      .map { |r| { id: r[:item]['id'], name: r[:name], match_score: r[:score] } }
  end

  def similarity_score(a, b)
    a_sorted = a.split.sort.join(' ')
    b_sorted = b.split.sort.join(' ')
    (Amatch::JaroWinkler.new(a_sorted).match(b_sorted) * 100).round
  end
end
