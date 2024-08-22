vim.opt.cmdheight = 0
vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.undofile = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.guicursor = ''
vim.opt.mouse = 'cv'
vim.opt.updatetime = 500
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.lsp.set_log_level(vim.log.levels.WARN)
vim.cmd('colo tender')
vim.cmd('command! Q :q')

local lsp_on_attach = function()
    vim.diagnostic.config({signs = false, virtual_text = false, underline = false})
    vim.keymap.set('n', 'fd', '<cmd>Telescope diagnostics<CR>')
    vim.keymap.set('n', 'ft', '<cmd>Telescope lsp_definitions<CR>')
    vim.keymap.set('n', 'FT', '<cmd>Telescope lsp_type_definitions<CR>')
    vim.keymap.set('n', 'fr', '<cmd>Telescope lsp_references<CR>')
    vim.keymap.set('n', 'FR', '<cmd>Telescope lsp_implementations<CR>')
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
                            local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or 'utf-16'
                            vim.lsp.util.apply_workspace_edit(r.edit, enc)
                        end
                    end
                end
                vim.lsp.buf.format({async = false})
            end
        })
        vim.api.nvim_create_autocmd('CursorHold', {
            pattern = {'*.go'},
            callback = function()
                vim.diagnostic.open_float(nil, {focus=false, scope='line'})
            end,
        })
    end
})

local snippy = require('snippy')
snippy.setup({})

local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            snippy.expand_snippet(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
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
    }),
    sources = {
        {name = 'snippy'},
        {name = 'nvim_lsp'},
        {name = 'nvim_lsp_signature_help'},
    },
})

require('nvim-treesitter.configs').setup({
    ensure_installed = {'vim', 'vimdoc', 'lua', 'go', 'gomod'},
    highlight = {enable = true},
})
require('nvim-web-devicons').setup()
require('nvim-autopairs').setup()

require('lualine').setup({
    options = {theme = 'gruvbox-material'},
    sections = {
        lualine_b = {'branch', 'diff', {'diagnostics', sources = {'nvim_workspace_diagnostic'}}},
        lualine_c = {{'filename', path = 1, shorting_target = 100}},
        lualine_x = {'filetype'},
    },
})


local telescope = require('telescope')
telescope.setup({
    defaults = {preview = false},
    pickers = {diagnostics = {line_width = 0.60}},
})
telescope.load_extension('fzf')
vim.keymap.set('n', 'fb', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', 'FB', '<cmd>Telescope oldfiles<CR>')
vim.keymap.set('n', 'ff', '<cmd>Telescope find_files<CR>')
vim.keymap.set('n', 'fs', '<cmd>Telescope current_buffer_fuzzy_find<CR>')

require('gitsigns').setup({
    numhl = true,
    current_line_blame = true,
    on_attach = function(bufnr)
        vim.keymap.set('n', 'gw', '<cmd>Gitsigns next_hunk<CR>')
        vim.keymap.set('n', 'gs', '<cmd>Gitsigns prev_hunk<CR>')
        vim.keymap.set('n', 'gh', '<cmd>Gitsigns preview_hunk_inline<CR>')
        vim.keymap.set('n', 'fg', '<cmd>Telescope git_commits<CR>')
    end,
})

require('paq')({
    {'savq/paq-nvim'},
    {'nvim-lua/plenary.nvim'},
    {'nvim-tree/nvim-web-devicons'},
    {'nvim-lualine/lualine.nvim'},
    {'neovim/nvim-lspconfig'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'hrsh7th/cmp-nvim-lsp-signature-help'},
    {'dcampos/nvim-snippy'},
    {'dcampos/cmp-snippy'},
    {'hrsh7th/nvim-cmp'},
    {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
    {'windwp/nvim-autopairs'},
    {'lewis6991/gitsigns.nvim'},
    {'nvim-telescope/telescope.nvim'},
    {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    {'jacoborus/tender.vim'},
})
