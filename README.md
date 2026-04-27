# Database Assistant MCP Server

A production-grade [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) server that provides safe, read-only database tools for AI assistants. Supports **SQLite** and **PostgreSQL**.

```
┌─────────────────────────────────────────────┐
│          MCP Host (Claude, VS Code, …)      │
│                                             │
│  "Show me the tables"                       │
│  "Query users older than 25"                │
│  "Explain this slow query"                  │
│  "Generate a migration to add email column" │
└─────────────┬───────────────────────────────┘
              │  MCP Protocol (JSON-RPC 2.0)
              ▼
┌─────────────────────────────────────────────┐
│       Database Assistant MCP Server         │
│                                             │
│  Tools:                                     │
│    • query          — safe SELECT execution │
│    • schema_inspect — tables/columns/FKs    │
│    • explain        — execution plans       │
│    • data_summary   — statistical summary   │
│    • generate_migration — NL → DDL scripts  │
│                                             │
│  Security:                                  │
│    AST validation → Read-only DB → Timeout  │
└─────────────┬───────────────────────────────┘
              │
              ▼
        ┌──────────┐    ┌────────────┐
        │  SQLite   │ or │ PostgreSQL │
        └──────────┘    └────────────┘
```

## Features

| Tool | Description |
|------|-------------|
| `query` | Execute safe, read-only SQL SELECT queries with row limits |
| `schema_inspect` | List tables, columns, types, primary keys, foreign keys, indexes |
| `explain` | Get query execution plans (EXPLAIN / EXPLAIN ANALYZE) |
| `data_summary` | Statistical summary — count, nulls, distinct, min/max, mean/median/stddev |
| `generate_migration` | Generate UP + DOWN migration SQL from natural language descriptions |

**Security**: 3-layer defense-in-depth — AST-based SQL validation (sqlglot), read-only database connections, query timeout + row limits.

## Quick Start

### 1. Install

```bash
# Clone and install
cd database-assistant-mcp
uv sync

# Seed a demo database
sqlite3 database.db < seed.sql
```

### 2. Test

```bash
uv run pytest
```

### 3. Run with MCP Inspector

```bash
uv run mcp dev src/db_assistant/server.py
```

Then open the Inspector UI and connect to test the tools interactively.

### 4. Claude Desktop Integration

Copy `claude_desktop_config.example.json` to your Claude Desktop config directory and update the paths:

- **macOS**: `~/Library/Application Support/Claude/claude_desktop_config.json`
- **Windows**: `%APPDATA%\Claude\claude_desktop_config.json`

### 5. VS Code / Copilot Integration

Add to your `.vscode/mcp.json`:

```json
{
  "servers": {
    "database-assistant": {
      "command": "uv",
      "args": ["--directory", "/path/to/database-assistant-mcp", "run", "db-assistant"],
      "env": {
        "DB_ASSISTANT_DB_TYPE": "sqlite",
        "DB_ASSISTANT_DB_PATH": "/path/to/database.db"
      }
    }
  }
}
```

## Configuration

Set via environment variables (or `.env` file):

| Variable | Default | Description |
|----------|---------|-------------|
| `DB_ASSISTANT_DB_TYPE` | `sqlite` | `sqlite` or `postgresql` |
| `DB_ASSISTANT_DB_PATH` | `database.db` | SQLite file path |
| `DB_ASSISTANT_DB_URL` | _(empty)_ | PostgreSQL connection URL |
| `DB_ASSISTANT_QUERY_TIMEOUT` | `30.0` | Query timeout in seconds |
| `DB_ASSISTANT_MAX_ROWS` | `1000` | Maximum rows returned per query |

## Architecture

### Security Model

1. **AST Validation** (`sqlglot`): Parses SQL into an Abstract Syntax Tree. Only `SELECT` at the root is allowed. Blocks DML, DDL, dangerous functions (`pg_sleep`, `load_extension`, `dblink`), and `INTO OUTFILE`/`LOAD DATA` clauses.
2. **Read-Only Connections**: SQLite opened in `?mode=ro`; PostgreSQL uses `default_transaction_read_only = ON`.
3. **Runtime Limits**: Configurable query timeout (default 30s) and row limit (default 1000) prevent resource exhaustion.

### Project Structure

```
src/db_assistant/
├── server.py               # FastMCP server — tools, resource, prompt
├── config.py               # Pydantic settings
├── db/
│   ├── engine.py           # DatabaseAdapter ABC
│   ├── sqlite_adapter.py   # SQLite (aiosqlite)
│   └── postgres_adapter.py # PostgreSQL (asyncpg)
├── tools/
│   ├── query.py            # query tool
│   ├── schema_inspect.py   # schema_inspect tool
│   ├── explain_query.py    # explain tool
│   ├── data_summary.py     # data_summary tool
│   └── generate_migration.py # generate_migration tool
└── security/
    └── sql_validator.py    # AST-based SQL validation
```

## Tech Stack

- **Python 3.12+** with async/await throughout
- **[MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)** (FastMCP) — protocol implementation
- **[sqlglot](https://github.com/tobymao/sqlglot)** — SQL AST parsing for injection prevention
- **aiosqlite** / **asyncpg** — async database drivers
- **pydantic-settings** — environment-based configuration
- **pytest + pytest-asyncio** — test suite

## License

MIT
