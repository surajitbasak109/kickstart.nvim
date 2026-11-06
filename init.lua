--[[
  Personal Neovim config, based on kickstart.nvim.
  Requires Neovim 0.11+ (written for 0.12).

  Layout of this file:
    1. Leader key
    2. Options
    3. Keymaps
    4. Autocommands
    5. Plugin manager (lazy.nvim) bootstrap
    6. Plugins (each plugin's config lives inside its own spec)

  Extra plugins live in `lua/custom/plugins/*.lua`.
  Run `:checkhealth` and `:Lazy` if something looks wrong.
--]]

-- [[ 1. Leader ]]
-- Must be set before lazy.nvim loads plugins, or they will use the wrong leader.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- [[ 2. Options ]]  See `:help vim.o`
local o = vim.o
o.hlsearch = false
o.number = true
o.mouse = 'a'
o.breakindent = true
o.undofile = true
o.ignorecase = true -- case-insensitive search...
o.smartcase = true -- ...unless the pattern has a capital or \C
o.signcolumn = 'yes'
o.updatetime = 250
o.timeoutlen = 300
o.completeopt = 'menuone,noselect'
o.termguicolors = true

-- Share the clipboard with the OS. Scheduled so the clipboard provider
-- lookup doesn't slow down startup.
vim.schedule(function()
  o.clipboard = 'unnamedplus'
end)

-- [[ 3. Keymaps ]]  See `:help vim.keymap.set()`
local map = vim.keymap.set

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Move by visual line when lines wrap (but keep counts like `5j` working)
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostics. `[d` / `]d` are built into Neovim 0.10+.
map('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Diagnostic icons in the sign column (needs a Nerd Font). Neo-tree uses them too.
vim.diagnostic.config {
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '\u{f057}',
      [vim.diagnostic.severity.WARN] = '\u{f071}',
      [vim.diagnostic.severity.INFO] = '\u{f05a}',
      [vim.diagnostic.severity.HINT] = '\u{f0335}',
    },
  },
}

-- [[ 4. Autocommands ]]
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- [[ 5. Bootstrap lazy.nvim ]]  See `:help lazy.nvim.txt`
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Returns a function that calls a Telescope picker. Used in keymaps so
-- Telescope only loads the first time one of them is pressed.
local function telescope(picker, opts)
  return function()
    require('telescope.builtin')[picker](opts)
  end
end

-- [[ 6. Plugins ]]
require('lazy').setup({
  -- Git
  'tpope/vim-fugitive',
  'tpope/vim-rhubarb',

  -- Detect tabstop and shiftwidth automatically
  'tpope/vim-sleuth',

  -- Neovim API types/completion for lua_ls (replaces the deprecated neodev.nvim).
  -- This is what fixes "undefined global `vim`".
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  { -- LSP
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = {
      { 'mason-org/mason.nvim', opts = {} },
      'mason-org/mason-lspconfig.nvim',
      { 'j-hui/fidget.nvim', opts = {} }, -- LSP progress messages
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      -- Buffer-local keymaps, set whenever any LSP attaches to a buffer.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('UserLspAttach', { clear = true }),
        callback = function(event)
          local function nmap(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

          nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
          nmap('gr', telescope 'lsp_references', '[G]oto [R]eferences')
          nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
          nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
          nmap('<leader>ds', telescope 'lsp_document_symbols', '[D]ocument [S]ymbols')
          nmap('<leader>ws', telescope 'lsp_dynamic_workspace_symbols', '[W]orkspace [S]ymbols')

          nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
          nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

          nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
          nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
          nmap('<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
          end, '[W]orkspace [L]ist Folders')

          vim.api.nvim_buf_create_user_command(event.buf, 'Format', function()
            vim.lsp.buf.format()
          end, { desc = 'Format current buffer with LSP' })
        end,
      })

      -- Language servers to install and enable.
      -- Each value is passed straight to `vim.lsp.config()`, so it can hold
      -- `settings`, `filetypes`, `cmd`, etc. See `:help lsp-config`.
      local servers = {
        -- JS/TS linting + quick fixes; uses each project's own eslint config
        eslint = {},
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = 'Replace' },
              telemetry = { enable = false },
            },
          },
        },
      }

      -- Defaults shared by every server: advertise nvim-cmp's completion capabilities.
      vim.lsp.config('*', {
        capabilities = require('cmp_nvim_lsp').default_capabilities(),
      })

      for name, config in pairs(servers) do
        vim.lsp.config(name, config)
      end

      local server_names = vim.tbl_keys(servers)
      require('mason-lspconfig').setup {
        ensure_installed = server_names,
        automatic_enable = false, -- enable only what's listed above
      }
      vim.lsp.enable(server_names)

      -- Laravel LSP (installed via `composer global require laravel/lsp`, not Mason,
      -- so it is enabled here rather than in the `servers` table above).
      -- nvim-lspconfig supplies its cmd/filetypes/root_dir.
      vim.lsp.enable 'laravel_lsp'
    end,
  },

  { -- Autocompletion
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        dependencies = { 'rafamadriz/friendly-snippets' },
        config = function()
          require('luasnip.loaders.from_vscode').lazy_load()
        end,
      },
      'saadparwaiz1/cmp_luasnip',
      'hrsh7th/cmp-nvim-lsp',
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'

      cmp.setup {
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete {},
          ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          },
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_locally_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.locally_jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        },
        sources = {
          { name = 'lazydev', group_index = 0 }, -- Neovim API completion in Lua files
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
        },
      }
    end,
  },

  -- Shows pending keybinds
  { 'folke/which-key.nvim', event = 'VeryLazy', opts = {} },

  { -- Git signs in the gutter + hunk navigation
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require 'gitsigns'
        local function bmap(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
        end
        bmap('<leader>gp', function() gs.nav_hunk 'prev' end, '[G]o to [P]revious Hunk')
        bmap('<leader>gn', function() gs.nav_hunk 'next' end, '[G]o to [N]ext Hunk')
        bmap('<leader>ph', gs.preview_hunk, '[P]review [H]unk')
      end,
    },
  },

  { -- Colorscheme
    'navarasu/onedark.nvim',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme 'onedark'
    end,
  },

  { -- Statusline
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    opts = {
      options = {
        icons_enabled = false,
        theme = 'onedark',
        component_separators = '|',
        section_separators = '',
      },
    },
  },

  { -- Indent guides
    'lukas-reineke/indent-blankline.nvim',
    main = 'ibl',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      indent = { char = '┊' },
      whitespace = { remove_blankline_trail = false },
    },
  },

  -- NOTE: Comment.nvim removed: `gc` / `gcc` commenting is built into Neovim 0.10+.

  { -- Fuzzy finder (loads on first keypress or :Telescope)
    'nvim-telescope/telescope.nvim',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
    },
    keys = {
      { '<leader>?', telescope 'oldfiles', desc = '[?] Find recently opened files' },
      { '<leader><space>', telescope 'buffers', desc = '[ ] Find existing buffers' },
      {
        '<leader>/',
        function()
          local builtin = require 'telescope.builtin'
          builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        desc = '[/] Fuzzily search in current buffer',
      },
      { '<leader>gf', telescope 'git_files', desc = 'Search [G]it [F]iles' },
      { '<leader>sf', telescope 'find_files', desc = '[S]earch [F]iles' },
      { '<leader>sh', telescope 'help_tags', desc = '[S]earch [H]elp' },
      { '<leader>sw', telescope 'grep_string', desc = '[S]earch current [W]ord' },
      { '<leader>sg', telescope 'live_grep', desc = '[S]earch by [G]rep' },
      { '<leader>sd', telescope 'diagnostics', desc = '[S]earch [D]iagnostics' },
    },
    config = function()
      local ts = require 'telescope'
      ts.setup {
        defaults = {
          mappings = {
            i = {
              ['<C-u>'] = false,
              ['<C-d>'] = false,
            },
          },
        },
      }
      pcall(ts.load_extension, 'fzf')
    end,
  },

  { -- Treesitter: highlight, edit, and navigate code.
    -- Pinned to `master`: the default `main` branch is a rewrite with a
    -- different setup API, and this config uses the `master` API.
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs',
    dependencies = {
      { 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'master' },
    },
    opts = {
      ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim', 'php', 'php_only', 'html', 'blade' },
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<M-space>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
          goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
          goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
          goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
        },
        swap = {
          enable = true,
          swap_next = { ['<leader>a'] = '@parameter.inner' },
          swap_previous = { ['<leader>A'] = '@parameter.inner' },
        },
      },
    },
  },

  -- Optional kickstart extras:
  -- require 'kickstart.plugins.autoformat',
  -- require 'kickstart.plugins.debug',

  -- Your own plugins from `lua/custom/plugins/*.lua`
  { import = 'custom.plugins' },
}, {
  install = { colorscheme = { 'onedark' } },
  change_detection = { notify = false },
  performance = {
    rtp = {
      -- Built-in plugins you most likely never use; skipping them speeds up startup.
      disabled_plugins = { 'gzip', 'tarPlugin', 'tohtml', 'tutor', 'zipPlugin' },
    },
  },
})

-- vim: ts=2 sts=2 sw=2 et
