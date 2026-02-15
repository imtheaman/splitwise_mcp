#!/usr/bin/env ruby
require 'bundler/setup'
require 'dotenv/load'
require 'fast_mcp'

# Load core lib files first (order matters: errors/validators before tools)
%w[errors validators cache client resolver].each do |f|
  require File.join(__dir__, 'lib', f)
end
Dir[File.join(__dir__, 'lib', 'tools', '*.rb')].each { |f| require f }

auth_token = ENV['SPLITWISE_API_KEY'] || ENV['SPLITWISE_OAUTH_ACCESS_TOKEN']
abort("Set SPLITWISE_API_KEY or SPLITWISE_OAUTH_ACCESS_TOKEN in .env") unless auth_token

cache_ttl = (ENV['SPLITWISE_CACHE_TTL'] || 86_400).to_i
match_threshold = (ENV['SPLITWISE_MATCH_THRESHOLD'] || 70).to_i
resolver_cache_ttl = (ENV['SPLITWISE_RESOLVER_CACHE_TTL'] || 300).to_i

CLIENT = SplitwiseClient.new(auth_token, cache_ttl: cache_ttl)
RESOLVER = EntityResolver.new(CLIENT, threshold: match_threshold, cache_ttl: resolver_cache_ttl)

server = FastMcp::Server.new(name: 'splitwise-mcp', version: '1.0.0')

ALL_TOOLS = [
  GetCurrentUser, GetUser, UpdateUser,
  GetExpenses, GetExpense, CreateExpense, UpdateExpense, DeleteExpense, UndeleteExpense,
  GetGroups, GetGroup, CreateGroup, DeleteGroup, UndeleteGroup, AddUserToGroup, RemoveUserFromGroup,
  GetFriends, GetFriend, CreateFriend, CreateFriends, DeleteFriend,
  GetNotifications,
  ResolveFriend, ResolveGroup, ResolveCategory,
  GetComments, CreateComment, DeleteComment,
  GetCategories, GetCurrencies,
  AddTool, SubtractTool, MultiplyTool, DivideTool, ModuloTool
]

ALL_TOOLS.each { |tool| server.register_tool(tool) }

# Start (STDIO transport — used by Claude Desktop)
server.start
