-- Claude Code IDE integration (community plugin, same protocol as the
-- official VS Code / JetBrains extensions). Needs the `claude` CLI on PATH.
-- See https://github.com/coder/claudecode.nvim
return {
  'coder/claudecode.nvim',
  dependencies = { 'folke/snacks.nvim' },
  opts = {},
  keys = {
    { '<leader>C', nil, desc = '[C]laude Code' },
    { '<leader>Cc', '<cmd>ClaudeCode<cr>', desc = '[C]laude: toggle' },
    { '<leader>Cf', '<cmd>ClaudeCodeFocus<cr>', desc = '[C]laude: [f]ocus' },
    { '<leader>Cr', '<cmd>ClaudeCode --resume<cr>', desc = '[C]laude: [r]esume session' },
    { '<leader>Cb', '<cmd>ClaudeCodeAdd %<cr>', desc = '[C]laude: add current [b]uffer' },
    { '<leader>Cs', '<cmd>ClaudeCodeSend<cr>', mode = 'v', desc = '[C]laude: [s]end selection' },
    -- Inside Neo-tree: add the file under the cursor to Claude's context
    { '<leader>Cs', '<cmd>ClaudeCodeTreeAdd<cr>', ft = 'neo-tree', desc = '[C]laude: add file' },
    { '<leader>Ca', '<cmd>ClaudeCodeDiffAccept<cr>', desc = '[C]laude: [a]ccept diff' },
    { '<leader>Cd', '<cmd>ClaudeCodeDiffDeny<cr>', desc = '[C]laude: [d]eny diff' },
  },
}
