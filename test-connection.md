# Claude Code Max Connection Test

## Test Steps:

1. Open Claudia UI in browser (http://localhost:1420/)
2. Click on a project folder (e.g., `/mnt/d/claudia`)
3. Type a simple prompt: "Hi, are you connected with Claude Code Max?"
4. Press Enter

## Expected Result:
- Claude should respond without "Invalid API key" error
- The response should come from the authenticated Claude Code Max (v1.0.56)

## Current Fix Applied:
- Updated `set_claude_binary_path` to save both:
  - `claude_binary_path`: `/root/.bun/bin/claude`
  - `claude_installation_preference`: `system`
- This ensures Claudia uses the authenticated system Claude instead of bundled sidecar

## Database Verification:
```sql
sqlite3 /root/.local/share/claudia.asterisk.so/agents.db "SELECT * FROM app_settings WHERE key IN ('claude_binary_path', 'claude_installation_preference');"
```

Result:
- claude_binary_path|/root/.bun/bin/claude
- claude_installation_preference|system