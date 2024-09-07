vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.opt.sessionoptions='buffers,localoptions'
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.undofile = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.guicursor = ''
vim.opt.mouse = 'cv'
vim.opt.updatetime = 250
vim.opt.laststatus = 3
vim.cmd.colorscheme('darcula-dark')

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
    {'windwp/nvim-autopairs'},
    {'rmagatti/auto-session'},
    {'lewis6991/gitsigns.nvim'},
    {'nvim-telescope/telescope.nvim'},
    {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    {'xiantang/darcula-dark.nvim'},
    {'echasnovski/mini.notify'},
    {'savq/paq-nvim'},
})

local lsp_on_attach = function()
    vim.diagnostic.config({signs = false, virtual_text = false})
    vim.api.nvim_create_autocmd('CursorHold', {
        pattern = {'*.go', 'go.mod', '*.tmpl'},
        callback = function()
            vim.diagnostic.open_float(nil, {focus=false})
        end,
    })
end

local lsp = require('lspconfig')
lsp.gopls.setup({
    on_attach =  function()
        lsp_on_attach()
        vim.api.nvim_create_autocmd('BufWritePre', {
            pattern = {'*.go'},
            callback = function()
                local params = vim.lsp.util.make_range_params()
                params.context = {only = {'source.organizeImports'}}
                local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params)
                for cid, res in pairs(result or {}) do
                    for _, r in pairs(res.result or {}) do
                        if r.edit then
                            vim.lsp.util.apply_workspace_edit(r.edit, 'utf-8')
                        end
                    end
                end
                vim.lsp.buf.format({async = false})
            end
        })
    end
})

local snippy = require('snippy')
snippy.setup({})

local cmp = require('cmp')
cmp.setup({
    performance = {debounce = 5, throttle = 5, max_view_entries = 7},
    mapping = cmp.mapping{
        ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif snippy.can_expand_or_advance() then
                snippy.expand_or_advance()
            else
                fallback()
            end
        end, {'i', 's'}),
        ['<C-d>'] = cmp.mapping.confirm({behavior = cmp.ConfirmBehavior.Insert, select = true}),
    },
    sources = {
        {name = 'snippy'},
        {name = 'nvim_lsp'},
        {name = 'nvim_lsp_signature_help'},
    },
})

require('nvim-treesitter.configs').setup({
    ensure_installed = {'go', 'gomod', 'gotmpl'},
    highlight = {enable = true},
})
require('auto-session').setup({auto_restore_last_session = true})
mini_notify = require('mini.notify')
mini_notify.setup({
    lsp_progress = {duration_last = 5000},
    window = {winblend = 0},
})
local notify_opts = {
    ERROR = {duration = 15000, hl_group = 'DiagnosticError'},
    WARN  = {duration = 15000, hl_group = 'DiagnosticWarn'},
    INFO  = {duration = 15000, hl_group = 'DiagnosticInfo'},
    DEBUG = {duration = 15000, hl_group = 'DiagnosticHint'},
    TRACE = {duration = 15000, hl_group = 'DiagnosticOk'},
    OFF   = {duration = 0, hl_group = 'MiniNotifyNormal'},
}
vim.notify = mini_notify.make_notify(notify_opts)
local telescope = require('telescope')
telescope.setup({
    defaults = {
        preview = {hide_on_startup = true},
        layout_config = {width = 0.90, height = 0.90},
    }
})
telescope.load_extension('fzf')
require('gitsigns').setup({current_line_blame = true})
require('nvim-autopairs').setup()

vim.keymap.set('n', 'fb', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', 'fc', '<cmd>Telescope oldfiles<CR>')
vim.keymap.set('n', 'ff', '<cmd>Telescope find_files<CR>')
vim.keymap.set('n', 'fs', '<cmd>Telescope current_buffer_fuzzy_find<CR>')
vim.keymap.set('n', 'fg', '<cmd>Telescope git_commits<CR>')
vim.keymap.set('n', 'fd', '<cmd>Telescope diagnostics<CR>')
vim.keymap.set('n', 'ft', '<cmd>Telescope lsp_definitions<CR>')
vim.keymap.set('n', 'FT', '<cmd>Telescope lsp_type_definitions<CR>')
vim.keymap.set('n', 'fr', '<cmd>Telescope lsp_references<CR>')
vim.keymap.set('n', 'FR', '<cmd>Telescope lsp_implementations<CR>')
vim.keymap.set('n', 'gw', '<cmd>Gitsigns next_hunk<CR><CR>')
vim.keymap.set('n', 'gs', '<cmd>Gitsigns prev_hunk<CR><CR>')
vim.keymap.set('n', 'gh', '<cmd>Gitsigns diffthis<CR>')
