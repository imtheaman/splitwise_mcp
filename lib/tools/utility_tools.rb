class GetCategories < FastMcp::Tool
  description "Get all Splitwise expense categories and subcategories (cached 24h)"

  def call
    CLIENT.get_categories
  end
end

class GetCurrencies < FastMcp::Tool
  description "Get all supported currencies with codes and symbols (cached 24h)"

  def call
    CLIENT.get_currencies
  end
end
