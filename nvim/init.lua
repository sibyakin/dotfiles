vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.opt.sessionoptions='buffers,curdir,winsize,winpos,localoptions'
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.undofile = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.guicursor = ''
vim.opt.mouse = 'cv'
vim.opt.scrolloff = 8
vim.opt.laststatus = 3
vim.opt.background = 'dark'
vim.cmd.colorscheme('vscode')

require('paq')({
    {'neovim/nvim-lspconfig'},
    {'nvim-lua/plenary.nvim'},
    {'nvim-tree/nvim-web-devicons'},
    {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
    {'dcampos/nvim-snippy'},
    {'dcampos/cmp-snippy'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-nvim-lsp-signature-help'},
    {'hrsh7th/nvim-cmp'},
    {'rmagatti/auto-session'},
    {'windwp/nvim-autopairs'},
    {'lewis6991/gitsigns.nvim'},
    {'echasnovski/mini.notify'},
    {'nvim-telescope/telescope.nvim'},
    {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    {'Mofiqul/vscode.nvim'},
    {'savq/paq-nvim'},
})

local set_status = function()
    local branch = vim.b.gitsigns_head
    if branch then
        vim.opt.statusline = string.format(' %s %s %s %s %s %s ', branch, '%F', '%r', '%=', '%{&ff}', '%{&fenc}')
    else 
        vim.opt.statusline = string.format(' %s %s %s %s %s ', '%F', '%r', '%=', '%{&ff}', '%{&fenc}')
    end
end
vim.api.nvim_create_autocmd({'BufNew', 'BufEnter', 'FocusGained'}, {callback = set_status})

local lsp_fix_imports_and_format = function()
    local params = vim.lsp.util.make_range_params()
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
    vim.keymap.set('n', 'fd', '<cmd>Telescope diagnostics<CR>')
    vim.keymap.set('n', 'FD', '<cmd>Telescope lsp_document_symbols<CR>')
    vim.keymap.set('n', 'fa', '<cmd>Telescope lsp_incoming_calls<CR>')
    vim.keymap.set('n', 'ft', '<cmd>Telescope lsp_definitions<CR>')
    vim.keymap.set('n', 'FT', '<cmd>Telescope lsp_type_definitions<CR>')
    vim.keymap.set('n', 'fr', '<cmd>Telescope lsp_references<CR>')
    vim.keymap.set('n', 'FR', '<cmd>Telescope lsp_implementations<CR>')
    vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = {'*.go'},
        callback = lsp_fix_imports_and_format,
    })
    vim.api.nvim_create_autocmd('CursorHold', {
        pattern = {'*.go', 'go.mod'},
        callback = lsp_show_diagnostics,
    })
    vim.opt.updatetime = 750
    vim.lsp.inlay_hint.enable()
    vim.cmd.hi('link LspInlayHint Comment')
end

require('lspconfig').gopls.setup({
    settings = {
        gopls = {
            gofumpt = true,
            hints = {
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
            },
        },
    },
    on_attach = lsp_on_attach(),
})

local snippy = require('snippy')
snippy.setup({})

local cmp = require('cmp')
cmp.setup({
    performance = {throttle = 10, debounce = 10, max_view_entries = 15},
    preselect = cmp.PreselectMode.None,
    mapping = cmp.mapping{
        [  '<Tab>'  ] = cmp.mapping.select_next_item(),
        [ '<S-Tab>' ] = cmp.mapping.select_prev_item(),
        [  '<C-d>'  ] = cmp.mapping.confirm({behavior = cmp.ConfirmBehavior.Insert, select = true}),
        ['<C-Space>'] = cmp.mapping(snippy.expand_or_advance),
    },
    sorting = {
        comparators = {
            cmp.config.compare.recently_used,
            cmp.config.compare.exact,
            cmp.config.compare.length,
            cmp.config.compare.sort_text,
        },
    },
    sources = {
        {name = 'snippy'},
        {name = 'nvim_lsp'},
        {name = 'nvim_lsp_signature_help'},
    },
    view = {entries = {selection_order = 'near_cursor', follow_cursor = true}},
})

require('auto-session').setup({})
require('nvim-autopairs').setup({})

require('nvim-treesitter.configs').setup({
    ensure_installed = {'go', 'gomod'},
    highlight = {enable = true},
})

local gitsigns_on_attach = function()
    vim.keymap.set('n', 'fg', '<cmd>Telescope git_bcommits<CR>')
    vim.keymap.set('n', 'FG', '<cmd>Telescope git_commits<CR>')
    set_status()
end

require('gitsigns').setup({
    current_line_blame = true,
    on_attach = gitsigns_on_attach,
})

mini_notify = require('mini.notify')
mini_notify.setup({window = {winblend = 0, max_width_share = 0.50}})
local notify_st = {duration = 15000, hl_group = 'Float'}
local notify_opts = {
    ERROR = notify_st, WARN = notify_st, INFO = notify_st, DEBUG = notify_st, TRACE = notify_st
}
vim.notify = mini_notify.make_notify(notify_opts)

local telescope_actions = require('telescope.actions')
local telescope = require('telescope')
telescope.setup({
    defaults = {
        layout_strategy = 'vertical',
        sorting_strategy = 'ascending',
        file_ignore_patterns = {'^.git/'},
        mappings = {i = {['<ESC>'] = telescope_actions.close}},
    },
})
telescope.load_extension('fzf')

vim.keymap.set('n', 'fb', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', 'fc', '<cmd>Telescope oldfiles<CR>')
vim.keymap.set('n', 'fs', '<cmd>Telescope current_buffer_fuzzy_find<CR>')
vim.keymap.set('n', 'ff', '<cmd>Telescope find_files no_ignore=true hidden=true<CR>')
