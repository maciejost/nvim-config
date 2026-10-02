-- Run Claude through the sandbox launcher instead of a bare `claude`, mirroring
-- the claude-internet function in ~/.zshrc.
local sandbox = vim.fn.expand("~/.claude-sandbox")
local config_dir = sandbox .. "/config-internet"
local lock_dir = config_dir .. "/ide"

-- claude-internet.sh uses the blocklist profile, which (unlike the local/aws
-- ones) grants no localhost access at all, so every port has to be named up
-- front: 9001 for a dev server, plus the range claudecode.nvim picks its
-- websocket port from. It needs to be a range rather than one pinned port
-- because each Neovim instance starts its own server and names its lock file
-- after the port: on a shared port the second instance cannot bind, and the
-- first one to quit deletes the lock the other is still using.
local PORT_MIN, PORT_MAX = 10101, 10105

local flags = {
  sandbox .. "/claude-internet.sh",
  "--allow-localhost 9001",
}

for port = PORT_MIN, PORT_MAX do
  table.insert(flags, "--allow-localhost " .. port)
end

vim.list_extend(flags, {
  -- The lock file below carries the auth token Claude needs to open the
  -- websocket, and cplt blocks the config dir it sits in by default.
  "--allow-read " .. lock_dir,
  -- cplt passes only an env allowlist into the sandbox; these three are what
  -- claudecode.nvim sets to tell Claude where to connect back.
  "--pass-env CLAUDE_CODE_SSE_PORT",
  "--pass-env ENABLE_IDE_INTEGRATION",
  "--pass-env FORCE_CODE_TERMINAL",
  -- Skip the "Proceed? [y/N]" prompt; the configuration summary is still
  -- printed in the pane, so the launch stays auditable.
  "--yes",
  -- The launcher hands its arguments to cplt, so anything claudecode.nvim
  -- appends (--resume, --continue) needs this to reach Claude itself.
  "--",
})

-- Both terminal providers need this plain and absolute: the native one splits on
-- spaces and spawns without a shell, so quoting or `~` would end up literal.
local terminal_cmd = table.concat(flags, " ")

-- claudecode.nvim tests a candidate port with bind() alone, which on macOS
-- reports success even while another process is listening on it. It therefore
-- hands back a port that is already taken, dies on listen() with EADDRINUSE and
-- never retries, leaving that Neovim with no server for Claude to connect to.
-- Probing with listen() as well picks a port that is genuinely free.
local function free_port()
  for port = PORT_MIN, PORT_MAX do
    local probe = vim.uv.new_tcp()
    if probe then
      local ok, bound = pcall(function()
        return probe:bind("127.0.0.1", port) and probe:listen(1, function() end)
      end)
      probe:close()
      if ok and bound then
        return port
      end
    end
  end
  return PORT_MAX
end

-- The sandbox hides every process outside it, so `kill -0 <neovim pid>` fails
-- for Claude. It reads the pid out of the lock file, concludes the editor is
-- gone, deletes the lock as stale and then has no auth token to connect with.
-- Pid 0 means "my own process group", which is always alive, so the lock
-- survives and the handshake goes through.
local function keep_lock_from_looking_stale(path)
  local file = io.open(path, "r")
  if not file then
    return
  end
  local raw = file:read("*a")
  file:close()

  local decoded, data = pcall(vim.json.decode, raw)
  if not decoded or type(data) ~= "table" then
    return
  end
  data.pid = 0

  local encoded, json = pcall(vim.json.encode, data)
  if not encoded then
    return
  end
  file = io.open(path, "w")
  if not file then
    return
  end
  file:write(json)
  file:close()
end

-- The lock file is written once, when the server starts, but Claude only reads
-- it when it launches. A Neovim left running for days ends up advertising a
-- lock that Claude has since pruned - it treats an old one as stale - and the
-- pane then opens with nothing to connect to, which looks like "Claude ignores
-- my selection". Rewriting it immediately before each launch keeps it present
-- and current, whatever removed or aged out the previous one.
local function refresh_lock()
  local state = require("claudecode").state
  if not state.port or not state.auth_token then
    return
  end
  pcall(require("claudecode.lockfile").create, state.port, state.auth_token)
end

return {
  "coder/claudecode.nvim",
  init = function()
    -- claudecode.nvim derives its lock file directory from CLAUDE_CONFIG_DIR and
    -- caches it when the module loads, while the launcher forces the sandbox's
    -- own config dir. Without this the lock is written to ~/.claude/ide, where
    -- the sandboxed Claude never looks, and the IDE handshake never completes.
    vim.env.CLAUDE_CONFIG_DIR = config_dir
  end,
  opts = function(_, opts)
    -- Resolved on load rather than at startup, so the port is still free by the
    -- time the server binds it. Every port it can return is granted above.
    local port = free_port()
    opts.port_range = { min = port, max = port }
    opts.terminal_cmd = terminal_cmd
    -- Jump to the Claude pane after <leader>as instead of only making it
    -- visible, so the selection can be typed about straight away.
    opts.focus_after_send = true
    return opts
  end,
  config = function(_, opts)
    -- Patched before setup() so it also covers the lock written by a later
    -- :ClaudeCodeStart, not just the one setup() creates on startup.
    local lockfile = require("claudecode.lockfile")
    local create = lockfile.create
    lockfile.create = function(...)
      local ok, path, auth_token = create(...)
      if ok and type(path) == "string" then
        keep_lock_from_looking_stale(path)
      end
      return ok, path, auth_token
    end

    -- Every entry point that can spawn the Claude terminal, so the lock is
    -- fresh no matter which keymap got us here.
    local terminal = require("claudecode.terminal")
    for _, name in ipairs({
      "open",
      "simple_toggle",
      "focus_toggle",
      "toggle",
      "toggle_open_no_focus",
      "ensure_visible",
    }) do
      local original = terminal[name]
      if type(original) == "function" then
        terminal[name] = function(...)
          refresh_lock()
          return original(...)
        end
      end
    end

    require("claudecode").setup(opts)
  end,
}
