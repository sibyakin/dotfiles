vim.o.sessionoptions='blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.o.cmdheight = 0
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.number = true
vim.o.undofile = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.guicursor = ''
vim.o.mouse = 'cv'
vim.o.updatetime = 500
vim.cmd('command! W :w')
vim.cmd('command! Q :q')
vim.cmd('colo darcula-dark')

require('paq')({
    {'neovim/nvim-lspconfig'},
    {'nvim-lua/plenary.nvim'},
    {'nvim-tree/nvim-web-devicons'},
    {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
    {'nvim-lualine/lualine.nvim'},
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
    {'j-hui/fidget.nvim'},
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
    performance = {debounce = 10, throttle = 5, max_view_entries = 10},
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
        ['<C-d>'] = cmp.mapping.confirm({select = true}),
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
require('nvim-web-devicons').setup({default = true, strict = true})
require('lualine').setup({sections = {lualine_c = {{'filename', path = 1}}}})
require('fidget').setup({
    notification = {
        override_vim_notify = true,
        view = {stack_upwards = false}, 
        window = {winblend = 0},
    },
})
local telescope = require('telescope')
telescope.setup({defaults = {preview = {hide_on_startup = true}}})
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
