# Claude Code Max Connection Fix Summary

## Problem
Claudia was showing "Invalid API key · Please run /login" error even though:
1. Claude Code Max v1.0.56 was installed and authenticated at `/root/.bun/bin/claude`
2. User selected the system Claude in Settings UI
3. Authentication tokens were valid in `~/.claude/.credentials.json`

## Root Causes Found

### 1. Missing Installation Preference
- The `set_claude_binary_path` function only saved the binary path
- It didn't save the `claude_installation_preference` setting
- Without this preference, the system defaulted to "bundled"

### 2. Bundled Sidecar Priority Issue
- Even when preference was "system", the code still checked for bundled sidecar
- Lines 85-89 in `find_claude_binary` would return sidecar if available
- This caused Claudia to use the unauthenticated bundled Claude v1.0.41

### 3. Root Permission Issue
- The `--dangerously-skip-permissions` flag cannot be used with root/sudo
- This was causing additional errors when trying to execute Claude

## Fixes Applied

### 1. Updated `set_claude_binary_path` (agents.rs:1830)
```rust
// Now saves both settings in a transaction:
- claude_binary_path: The actual path
- claude_installation_preference: "system" or "bundled"
```

### 2. Fixed `find_claude_binary` Logic (claude_binary.rs:74-92)
```rust
// Now properly respects user preference:
- If preference is "system", skips bundled sidecar check
- Only uses bundled sidecar if no preference or preference is "bundled"
```

### 3. Removed Dangerous Flag (claude.rs)
- Removed `--dangerously-skip-permissions` from all execution commands
- This flag is incompatible with root user execution

## Verification Steps

1. Check database settings:
```bash
sqlite3 /root/.local/share/claudia.asterisk.so/agents.db \
  "SELECT * FROM app_settings WHERE key IN ('claude_binary_path', 'claude_installation_preference');"
```

Expected output:
```
claude_binary_path|/root/.bun/bin/claude
claude_installation_preference|system
```

2. Test Claude connection:
```bash
/root/.bun/bin/claude -p "Hello" --model sonnet --output-format json
```

3. Test in Claudia UI:
- Open http://localhost:1420/
- Select a project folder
- Type a test prompt
- Should work without "Invalid API key" error

## Technical Details

### Binary Versions
- System Claude: v1.0.56 (authenticated)
- Bundled Claude: v1.0.41 (not authenticated)

### File Locations
- System binary: `/root/.bun/bin/claude`
- Credentials: `~/.claude/.credentials.json`
- Database: `/root/.local/share/claudia.asterisk.so/agents.db`
- Bundled sidecar: `src-tauri/binaries/claude-code-x86_64-unknown-linux-gnu`

### Modified Files
1. `/mnt/d/claudia/src-tauri/src/commands/agents.rs`
2. `/mnt/d/claudia/src-tauri/src/claude_binary.rs`
3. `/mnt/d/claudia/src-tauri/src/commands/claude.rs`

## Next Steps

If the issue persists:
1. Check Tauri logs for which binary is being selected
2. Verify the process spawning is using the correct binary path
3. Check environment variables are properly passed to the subprocess