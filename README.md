# Splitwise MCP Server

Ruby MCP server exposing 35 Splitwise API tools for Claude Desktop via the [Model Context Protocol](https://modelcontextprotocol.io).

## Prerequisites

- Ruby 3.x
- Bundler

## Installation

```bash
git clone https://github.com/your-username/splitwise-mcp.git
cd splitwise-mcp
bundle install
cp .env.example .env
```

Edit `.env` and add your Splitwise API key.

## Getting Your API Key

1. Register an app at https://secure.splitwise.com/apps
2. On your app's details page, generate a personal API key
3. Alternatively, use an OAuth 2.0 access token

## Configuration

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `SPLITWISE_API_KEY` | Yes* | — | Personal API key |
| `SPLITWISE_OAUTH_ACCESS_TOKEN` | Yes* | — | OAuth 2.0 access token |
| `SPLITWISE_CACHE_TTL` | No | `86400` | Cache TTL in seconds |
| `SPLITWISE_MATCH_THRESHOLD` | No | `70` | Fuzzy match threshold (0–100) |
| `SPLITWISE_RESOLVER_CACHE_TTL` | No | `300` | Resolver cache TTL in seconds |

\* One of `SPLITWISE_API_KEY` or `SPLITWISE_OAUTH_ACCESS_TOKEN` is required.

## Claude Code Setup

Add this to your `~/.mcp.json`:

```json
{
  "mcpServers": {
    "splitwise_mcp": {
      "command": "ruby",
      args: [server.rb],
      "cwd": "/path/to/splitwise-mcp",
      "env": {
        "SPLITWISE_API_KEY": "YOUR_API_KEY"
      }
    }
  }
}
```

## Claude Desktop Setup

Add this to your `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "splitwise_mcp": {
      "command": "ruby",
      "args": ["server.rb"],
      "cwd": "/path/to/splitwise-mcp",
      env: {
        "SPLITWISE_API_KEY": "YOUR_API_KEY"
      }
    }
  }
}
```

## MCP Inspector

Test tools interactively with the MCP Inspector:

```bash
npx @modelcontextprotocol/inspector ruby server.rb
```

## Available Tools (35)

| Category | Tools |
|----------|-------|
| **Users** (3) | `GetCurrentUser`, `GetUser`, `UpdateUser` |
| **Expenses** (6) | `GetExpenses`, `GetExpense`, `CreateExpense`, `UpdateExpense`, `DeleteExpense`, `UndeleteExpense` |
| **Groups** (7) | `GetGroups`, `GetGroup`, `CreateGroup`, `DeleteGroup`, `UndeleteGroup`, `AddUserToGroup`, `RemoveUserFromGroup` |
| **Friends** (5) | `GetFriends`, `GetFriend`, `CreateFriend`, `CreateFriends`, `DeleteFriend` |
| **Comments** (3) | `GetComments`, `CreateComment`, `DeleteComment` |
| **Notifications** (1) | `GetNotifications` |
| **Resolution** (3) | `ResolveFriend`, `ResolveGroup`, `ResolveCategory` |
| **Utilities** (2) | `GetCategories`, `GetCurrencies` |
| **Arithmetic** (5) | `AddTool`, `SubtractTool`, `MultiplyTool`, `DivideTool`, `ModuloTool` |

## Project Structure

```
splitwise-mcp/
├── server.rb                        # Entry point — registers tools, starts MCP server
├── Gemfile                          # Dependencies
├── .env.example                     # Environment variable template
├── openapi.json                     # Splitwise OpenAPI spec (reference)
└── lib/
    ├── cache.rb                     # In-memory TTL cache
    ├── client.rb                    # Splitwise HTTP client
    ├── errors.rb                    # Custom error classes
    ├── resolver.rb                  # Fuzzy name-to-ID resolution
    ├── validators.rb                # Input validation helpers
    └── tools/
        ├── arithmetic_tools.rb      # Add, Subtract, Multiply, Divide, Modulo
        ├── comment_tools.rb         # GetComments, CreateComment, DeleteComment
        ├── expense_tools.rb         # CRUD + undelete for expenses
        ├── friend_tools.rb          # CRUD for friends
        ├── group_tools.rb           # CRUD + member management for groups
        ├── notification_tools.rb    # GetNotifications
        ├── resolution_tools.rb      # ResolveFriend, ResolveGroup, ResolveCategory
        ├── user_tools.rb            # GetCurrentUser, GetUser, UpdateUser
        └── utility_tools.rb         # GetCategories, GetCurrencies
```
