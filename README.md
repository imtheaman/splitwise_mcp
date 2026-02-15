# Splitwise MCP Server

Ruby MCP server exposing 35 Splitwise API tools via the [Model Context Protocol](https://modelcontextprotocol.io). Works with any MCP-compatible client — Claude Code, Claude Desktop, Cursor, and more.

## Prerequisites

- Ruby 3.x
- Bundler

## Installation

```bash
git clone https://github.com/imtheaman/splitwise_mcp.git
cd splitwise_mcp
bundle install
cp .env.example .env   # optional — only needed for MCP Inspector / standalone use
```

If using `.env`, edit it and add your Splitwise API key. When using an MCP client (Claude Code, Cursor, etc.), you can pass the key via the `"env"` block in the client config instead.

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
      "args": ["server.rb"],
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
      "env": {
        "SPLITWISE_API_KEY": "YOUR_API_KEY"
      }
    }
  }
}
```

## Cursor Setup

Add this to your project-level `.cursor/mcp.json` or global `~/.cursor/mcp.json`:

```json
{
  "mcpServers": {
    "splitwise_mcp": {
      "command": "ruby",
      "args": ["server.rb"],
      "cwd": "/path/to/splitwise-mcp",
      "env": {
        "SPLITWISE_API_KEY": "YOUR_API_KEY"
      }
    }
  }
}
```

## Prompt Examples

Here are some example prompts you can use with this MCP server:

```
"How much does John owe me?"

"Here's the bill image — split it between me, John, and Sarah in the NYC Trip group. I had the burger, John had pasta, and Sarah had the salad"

"Show me all expenses from last month in the Roommates group"

"Create a new group called 'Goa Trip' and add john@example.com and sarah@example.com"

"Delete the duplicate lunch expense from yesterday"

"What are my recent notifications?"

"Show me my balance with Sarah"

"Here's a photo of the receipt — read it and add the expense split between me and my roommates"
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
