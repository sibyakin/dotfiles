vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.opt.sessionoptions='blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
vim.opt.statusline = table.concat({' %F', '%r', '%=', '%{&fileformat}', '%{&fileencoding} '}, ' ')
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.undofile = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.guicursor = ''
vim.opt.mouse = 'cv'
vim.opt.laststatus = 3
vim.opt.background = 'dark'
vim.cmd.colorscheme('darcula')

require('paq')({
    {'neovim/nvim-lspconfig'},
    {'nvim-lua/plenary.nvim'},
    {'nvim-tree/nvim-web-devicons'},
    {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
    {'dcampos/nvim-snippy'},
    {'dcampos/cmp-snippy'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-nvim-lsp-signature-help'},
    {'yioneko/nvim-cmp', branch = 'perf'},
    {'rmagatti/auto-session'},
    {'windwp/nvim-autopairs'},
    {'lewis6991/gitsigns.nvim'},
    {'echasnovski/mini.notify'},
    {'nvim-telescope/telescope.nvim'},
    {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    {'doums/darcula'},
    {'savq/paq-nvim'},
})

local lsp_params = vim.lsp.util.make_range_params()
lsp_params.context = {only = {'source.organizeImports'}}

local lsp_fix_imports_and_format = function()
    local response = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', lsp_params, 3000)
    for _, v in pairs(response[1].result or {}) do
        if v.edit then vim.lsp.util.apply_workspace_edit(v.edit, 'utf-8') end
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
    vim.opt.updatetime = 250
end

require('lspconfig').gopls.setup({
    settings = {gopls = {gofumpt = true}},
    on_attach = lsp_on_attach(),
})

local snippy = require('snippy')
snippy.setup({})

local cmp = require('cmp')
cmp.setup({
    performance = {throttle = 5, debounce = 5, max_view_entries = 10},
    preselect = cmp.PreselectMode.None,
    mapping = cmp.mapping{
        [  '<Tab>'  ] = cmp.mapping.select_next_item(),
        [ '<S-Tab>' ] = cmp.mapping.select_prev_item(),
        [  '<C-d>'  ] = cmp.mapping.confirm({behavior = cmp.ConfirmBehavior.Insert, select = true}),
        ['<C-Space>'] = cmp.mapping(snippy.expand_or_advance),
    },
    sources = {
        {name = 'snippy', keyword_length = 2},
        {name = 'nvim_lsp', keyword_length = 3},
        {name = 'nvim_lsp_signature_help', keyword_length = 3},
    },
})

require('auto-session').setup({})
require('nvim-autopairs').setup({})

require('nvim-treesitter.configs').setup({
    ensure_installed = {'go', 'gomod'},
    highlight = {enable = true},
})

require('gitsigns').setup({signcolumn = false, numhl = true, current_line_blame = true})

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
        mappings = {i = {['<ESC>'] = telescope_actions.close}},
        preview = false,
    }
})
telescope.load_extension('fzf')

vim.keymap.set('n', 'fb', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', 'fc', '<cmd>Telescope oldfiles<CR>')
vim.keymap.set('n', 'ff', '<cmd>Telescope find_files<CR>')
vim.keymap.set('n', 'fs', '<cmd>Telescope current_buffer_fuzzy_find<CR>')
