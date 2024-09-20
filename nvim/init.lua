vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.opt.sessionoptions='blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
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
vim.opt.background = 'dark'
vim.cmd.colorscheme('darcula')
local statusline = {
  '%F',
  '%r',
  '%m',
  '%=',
  '%P',
}
vim.opt.statusline = table.concat(statusline, ' ')

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
    {'echasnovski/mini.notify'},
    {'nvim-telescope/telescope.nvim'},
    {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    {'doums/darcula'},
    {'savq/paq-nvim'},
})

local lsp_on_attach = function()
    vim.diagnostic.config({signs = false, virtual_text = false})
    vim.api.nvim_create_autocmd('CursorHold', {
        pattern = {'*.go', 'go.mod'},
        callback = function()
            vim.diagnostic.open_float(nil, {focus=false})
        end,
    })
end

local lsp = require('lspconfig')
lsp.gopls.setup({
    settings = {
        gopls = {
            analyses = {unusedvariable = true},
            gofumpt = true,
        },
    },
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
    performance = {throttle = 10, debounce = 10, max_view_entries = 10},
    preselect = cmp.PreselectMode.None,
    mapping = cmp.mapping{
        ['<C-e>'] = cmp.mapping.abort(),
        ['<Tab>'] = cmp.mapping(function()
            if cmp.visible() then
                cmp.select_next_item()
            elseif snippy.can_expand_or_advance() then
                snippy.expand_or_advance()
            end
        end, {'i', 's'}),
        ['<S-Tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), {'i', 's'}),
        ['<CR>'] = cmp.mapping.confirm({behavior = cmp.ConfirmBehavior.Insert, select = false}),
        ['<C-d>'] = cmp.mapping.confirm({behavior = cmp.ConfirmBehavior.Insert, select = true}),
    },
    sources = {
        {name = 'snippy'},
        {name = 'nvim_lsp'},
        {name = 'nvim_lsp_signature_help'},
    },
})

require('nvim-treesitter.configs').setup({
    ensure_installed = {'go', 'gomod'},
    highlight = {enable = true},
})
require('auto-session').setup({})
require('nvim-autopairs').setup({})
mini_notify = require('mini.notify')
mini_notify.setup({window = {winblend = 0, max_width_share = 0.50}})
local notify_opts = {
    ERROR = {duration = 15000, hl_group = 'DiagnosticError'},
    WARN  = {duration = 15000, hl_group = 'DiagnosticWarn'},
    INFO  = {duration = 15000, hl_group = 'DiagnosticInfo'},
    DEBUG = {duration = 15000, hl_group = 'DiagnosticHint'},
    TRACE = {duration = 15000, hl_group = 'DiagnosticOk'},
}
vim.notify = mini_notify.make_notify(notify_opts)
local telescope_actions = require('telescope.actions')
local telescope = require('telescope')
telescope.setup({
    defaults = {
        mappings = {
            i = {
                ['<ESC>'] = telescope_actions.close,
                ['<C-d>'] = telescope_actions.delete_buffer + telescope_actions.move_to_top,
            },
        },
        preview = false,
    }
})
telescope.load_extension('fzf')

vim.keymap.set('n', 'fb', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', 'fc', '<cmd>Telescope oldfiles<CR>')
vim.keymap.set('n', 'ff', '<cmd>Telescope find_files<CR>')
vim.keymap.set('n', 'fs', '<cmd>Telescope current_buffer_fuzzy_find<CR>')
vim.keymap.set('n', 'fd', '<cmd>Telescope diagnostics<CR>')
vim.keymap.set('n', 'FD', '<cmd>Telescope lsp_document_symbols<CR>')
vim.keymap.set('n', 'fa', '<cmd>Telescope lsp_incoming_calls<CR>')
vim.keymap.set('n', 'ft', '<cmd>Telescope lsp_definitions<CR>')
vim.keymap.set('n', 'FT', '<cmd>Telescope lsp_type_definitions<CR>')
vim.keymap.set('n', 'fr', '<cmd>Telescope lsp_references<CR>')
vim.keymap.set('n', 'FR', '<cmd>Telescope lsp_implementations<CR>')
