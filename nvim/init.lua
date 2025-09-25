require('paq')({
    {'savq/paq-nvim'},
    {'nvim-lua/plenary.nvim'},
    {'nvim-tree/nvim-web-devicons'},
    {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
    {'rmagatti/auto-session'},
    {'windwp/nvim-autopairs'},
    {'saghen/blink.cmp'},
    {'lewis6991/gitsigns.nvim'},
    {'echasnovski/mini.notify'},
    {'nvim-telescope/telescope.nvim'},
    {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    {'nvim-telescope/telescope-file-browser.nvim'},
    {'debugloop/telescope-undo.nvim'},
    {'stevearc/dressing.nvim'},
    {'doums/darcula'},
})

require('nvim-treesitter.configs').setup({
    ensure_installed = {'go', 'gomod', 'json', 'rust'},
    highlight = {enable = true},
})

require('auto-session').setup({})

local lsp_fix_imports_and_format = function()
    local params = vim.lsp.util.make_range_params(nil, 'utf-8')
    params.context = {only = {'source.organizeImports'}}
    local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 3000)
    for _, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          vim.lsp.util.apply_workspace_edit(r.edit, 'utf-8')
        end
      end
    end
    vim.lsp.buf.format({async = false})
end

local lsp_show_diagnostics = function()
    vim.diagnostic.open_float(nil, {focus = false})
end

local lsp_on_attach = function()
    vim.diagnostic.config({signs = false, virtual_text = false})
    vim.api.nvim_create_autocmd({'BufWritePre'}, {
        pattern = {'*.go', '*.rs'},
        callback = lsp_fix_imports_and_format,
    })
    vim.api.nvim_create_autocmd({'CursorHold'}, {
        pattern = {'*.go', 'go.mod', '*.lua', '*.rs'},
        callback = lsp_show_diagnostics,
    })
    vim.o.updatetime = 750
end

vim.lsp.config('lua_ls', {
    filetypes = {'lua'},
    cmd = {'lua-language-server'},
    on_init = lsp_on_attach,
    settings = {
        Lua = {
            diagnostics = {globals = {'vim', 'none'}},
            runtime = {version = 'LuaJIT'},
        },
    },
})
vim.lsp.config('gopls', {
    filetypes = {'go'},
    cmd = {'gopls'},
    on_init = lsp_on_attach,
})
vim.lsp.config('rust_analyzer', {
    filetypes = {'rust'},
    cmd = {'rust-analyzer'},
    on_init = lsp_on_attach,
})
vim.lsp.enable({'lua_ls', 'gopls', 'rust_analyzer'})

require('blink.cmp').setup({
    keymap = {
        preset = 'enter',
        ['<C-Space>'] = {'snippet_forward', 'fallback'},
        [  '<Tab>'  ] = {'select_next', 'snippet_forward', 'fallback'},
        [ '<S-Tab>' ] = {'select_prev', 'snippet_backward', 'fallback'},
        [  '<C-d>'  ] = {'select_and_accept', 'fallback'},
    },
    completion = {documentation = {auto_show = true}},
    signature = {enabled = true},
    fuzzy = {implementation = 'lua'},
    sources = {default = {'snippets', 'lsp'}},
})

require('nvim-autopairs').setup({})

require('gitsigns').setup({current_line_blame = true, current_line_blame_formatter = '<author_time:%R>, <author>'})

local mini_notify = require('mini.notify')
mini_notify.setup({
    content = {format = function(notif) return notif.msg end},
    window = {winblend = 0, max_width_share = 0.50},
})
local notify_st = {duration = 15000, hl_group = 'Float'}
local notify_opts = {
    ERROR = notify_st, WARN = notify_st, INFO = notify_st, DEBUG = notify_st, TRACE = notify_st
}
vim.notify = mini_notify.make_notify(notify_opts)

local telescope_layout = require('telescope.actions.layout')
local telescope_actions = require('telescope.actions')
local telescope = require('telescope')
telescope.setup({
    defaults = {
        layout_strategy = 'vertical',
        layout_config = {mirror = true, prompt_position = 'top'},
        sorting_strategy = 'ascending',
        file_ignore_patterns = {'^.git/'},
        mappings = {
            i = {
                ['<Esc>'] = telescope_actions.close,
                ['<Tab>'] = telescope_layout.toggle_preview,
            },
        },
        cache_picker = {num_pickers = 15},
    },
    pickers = {diagnostics = {path_display = 'hidden'}},
})
telescope.load_extension('fzf')
telescope.load_extension('undo')
telescope.load_extension('file_browser')

vim.o.sessionoptions='buffers,curdir,winsize,winpos,localoptions'
vim.o.showtabline = 0
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.number = true
vim.o.undofile = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.guicursor = ''
vim.o.pumheight = 9
vim.o.scrolloff = 10
vim.o.laststatus = 3
vim.o.background = 'dark'
vim.o.statusline = '%F%r %= %L lines %{&ff} %{&fenc}'
vim.o.clipboard = 'unnamedplus'
vim.o.mouse = 'cv'
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.mapleader = ' '
vim.keymap.set('n', 'HN', '<cmd>Gitsigns next_hunk<CR><CR>')
vim.keymap.set('n', 'HP', '<cmd>Gitsigns prev_hunk<CR><CR>')
vim.keymap.set('n', 'HD', '<cmd>Gitsigns diffthis<CR>')
vim.keymap.set('n', 'HR', '<cmd>Gitsigns reset_hunk<CR>')
vim.keymap.set('n', '<Leader>q', '<cmd>bdelete<CR>')
vim.keymap.set('n', '<Leader>b', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', '<Leader>o', '<cmd>Telescope oldfiles<CR>')
vim.keymap.set('n', '<Leader>s', '<cmd>Telescope current_buffer_fuzzy_find<CR>')
vim.keymap.set('n', '<Leader>f', '<cmd>Telescope find_files no_ignore=true hidden=true<CR>')
vim.keymap.set('n', '<Leader>m', '<cmd>Telescope marks<CR>')
vim.keymap.set('n', '<Leader>h', '<cmd>Telescope undo<CR>')
vim.keymap.set('n', '<Leader>w', '<cmd>Telescope file_browser<CR>')
vim.keymap.set('n', '<Leader>d', '<cmd>Telescope diagnostics no_sign=true<CR>')
vim.keymap.set('n', '<Leader>y', '<cmd>Telescope lsp_document_symbols<CR>')
vim.keymap.set('n', '<Leader>c', '<cmd>Telescope lsp_incoming_calls<CR>')
vim.keymap.set('n', '<Leader>e', '<cmd>Telescope lsp_definitions<CR>')
vim.keymap.set('n', '<Leader>t', '<cmd>Telescope lsp_type_definitions<CR>')
vim.keymap.set('n', '<Leader>r', '<cmd>Telescope lsp_references<CR>')
vim.keymap.set('n', '<Leader>i', '<cmd>Telescope lsp_implementations<CR>')
vim.keymap.set('n', '<Leader>a', vim.lsp.buf.code_action)
vim.keymap.set('n', '<Leader>n', vim.lsp.buf.rename)
vim.keymap.set('i', '<C-s>', vim.lsp.buf.signature_help)
vim.cmd.colorscheme('darcula')
vim.api.nvim_set_hl(0, 'SignColumn', {ctermbg = none})
vim.api.nvim_set_hl(0, 'LineNr', {ctermbg = none})
vim.lsp.set_log_level('OFF')
