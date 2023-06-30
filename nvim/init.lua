vim.opt.expandtab = true
vim.opt.ignorecase = true
vim.opt.number = true
vim.opt.showmode = false
vim.opt.termguicolors = true
vim.opt.undofile = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.background = 'dark'
vim.opt.guicursor = ''
vim.opt.mouse = 'cv'
vim.opt.updatetime = 10000
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.lsp.set_log_level('off')

local snippy = require('snippy')
snippy.setup({})

local lsp = require('lspconfig')
local lsp_utils = require('lspconfig/util')
local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
local lsp_on_attach = function()
    vim.opt.updatetime = 1000
    vim.diagnostic.config({virtual_text = false})
    vim.keymap.set('n', 'dw', '<cmd>lua vim.diagnostic.goto_next()<CR>')
    vim.keymap.set('n', 'ds', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    vim.keymap.set('n', 'fd', '<cmd>Telescope diagnostics<CR>')
    vim.keymap.set('n', 'ft', '<cmd>Telescope lsp_type_definitions<CR>')
    vim.keymap.set('n', 'FT', '<cmd>Telescope lsp_definitions<CR>')
    vim.keymap.set('n', 'fr', '<cmd>Telescope lsp_references<CR>')
    vim.api.nvim_create_autocmd('CursorHold', {
        pattern = {'*.go', '*.rs'},
        callback = function()
            vim.diagnostic.open_float(nil, {focus=false})
        end,
    })
    vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = {'*.go', '*.rs'},
        callback = function()
            vim.lsp.buf.format({bufnr = bufnr})
        end,
    })
end
local gopls_on_attach = function()
    lsp_on_attach()
    vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = {'*.go'},
        callback = function()
            local params = vim.lsp.util.make_range_params(nil, vim.lsp.util._get_offset_encoding())
            params.context = {only = {'source.organizeImports'}}
            local result = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 1000)
            for _, res in pairs(result or {}) do
                for _, r in pairs(res.result or {}) do
                    if r.edit then
                        vim.lsp.util.apply_workspace_edit(r.edit, vim.lsp.util._get_offset_encoding())
                    else
                        vim.lsp.buf.execute_command(r.command)
                    end
                end
            end
        end,
    })
end
lsp.gopls.setup({
    filetypes = {'go', 'tmpl'},
    capabilities = lsp_capabilities,
    on_attach = gopls_on_attach,
    root_dir = lsp_utils.root_pattern('go.mod'),
    settings = {
        gopls = {
            analyses = {
                fieldalignment = true,
                nilness = true,
                shadow = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
            },
        },
    },
    single_file_support = true,
})
lsp.rust_analyzer.setup({
    capabilities = lsp_capabilities,
    on_attach = lsp_on_attach,
    settings = {
        ['rust_analyzer'] = {
            cargo = {
                allFeatures = true,
            },
            checkOnSave = {
                allFeatures = true,
                command = 'clippy',
            },
        },
    },
})

local cmp = require('cmp')
cmp.setup({
    snippet = {
        expand = function(args)
            snippy.expand_snippet(args.body)
        end,
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-w>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif snippy.can_expand_or_advance() then
                snippy.expand_or_advance()
            else
                fallback()
            end
        end, {'i', 's'}),
        ['<C-s>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif snippy.can_jump(-1) then
                snippy.previous()
            else
                fallback()
            end
        end, {'i', 's'}),
        ['<C-d>'] = cmp.mapping.confirm({select = true}),
        ['<CR>'] = cmp.mapping.confirm({select = false}),
    }),
    sources = {
        {name = 'snippy'},
        {name = 'nvim_lsp'},
        {name = 'nvim_lsp_signature_help'}
    },
})

require('nvim-treesitter.configs').setup({
    ensure_installed = {'go', 'json', 'lua', 'python', 'rust'},
    sync_install = false,
    auto_install = false,
    highlight = {enable = true},
})

require('nvim-autopairs').setup()
require('nvim-web-devicons').setup()
require('lualine').setup({options = {theme = 'gruvbox-material'}})

require('gitsigns').setup({
    numhl = true,
    watch_gitdir = {
        interval = 5000,
    },
    current_line_blame = true,
    current_line_blame_opts = {
        delay = 5000,
        ignore_whitespace = true,
    },
    current_line_blame_formatter = '<author>: <summary>',
    on_attach = function(bufnr)
        vim.keymap.set('n', 'ga', '<cmd>Gitsigns attach<CR>')
        vim.keymap.set('n', 'gd', '<cmd>Gitsigns detach<CR>')
        vim.keymap.set('n', 'gr', '<cmd>Gitsigns refresh<CR>')
        vim.keymap.set('n', 'gw', '<cmd>Gitsigns next_hunk<CR>')
        vim.keymap.set('n', 'gs', '<cmd>Gitsigns prev_hunk<CR>')
        vim.keymap.set('n', 'gh', '<cmd>Gitsigns preview_hunk_inline<CR>')
    end,
})

local telescope_h = math.min(vim.o.lines, 50)
local telescope_w = math.min(vim.o.columns, 160)
require('telescope').setup({
    defaults = {
        layout_strategy = 'vertical',
        layout_config = {
            height = telescope_h,
            width = telescope_w,
        },
    },
    pickers = {
        diagnostics = {previewer = false, line_width = telescope_w-50},
        oldfiles = {previewer = false},
    },
    extensions = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = 'ignore_case',
        },
        file_browser = {hijack_netwrw = true}},
})
require('telescope').load_extension('fzf')
require('telescope').load_extension('file_browser')
vim.keymap.set('n', 'fc', '<cmd>Telescope command_history<CR>')
vim.keymap.set('n', 'FC', '<cmd>Telescope commands<CR>')
vim.keymap.set('n', 'fb', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', 'FB', '<cmd>Telescope oldfiles<CR>')
vim.keymap.set('n', 'ff', '<cmd>Telescope find_files<CR>')
vim.keymap.set('n', 'FF', '<cmd>Telescope file_browser<CR>')
vim.keymap.set('n', 'fg', '<cmd>Telescope git_commits<CR>')
vim.keymap.set('n', 'fk', '<cmd>Telescope keymaps<CR>')
vim.keymap.set('n', 'fs', '<cmd>Telescope current_buffer_fuzzy_find<CR>')
vim.keymap.set('n', 'FS', '<cmd>Telescope live_grep<CR>')

vim.cmd('colo tender')
vim.cmd('command! Q :q')

require('packer').startup(function(use)
    use {{'nvim-lua/plenary.nvim'},
        {'dcampos/nvim-snippy'},
        {'dcampos/cmp-snippy'},
        {'neovim/nvim-lspconfig'},
        {'hrsh7th/cmp-nvim-lsp'},
        {'hrsh7th/cmp-nvim-lsp-signature-help'},
        {'hrsh7th/nvim-cmp'},
        {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate'},
        {'windwp/nvim-autopairs'},
        {'nvim-tree/nvim-web-devicons'},
        {'nvim-lualine/lualine.nvim'},
        {'lewis6991/gitsigns.nvim'},
        {'nvim-telescope/telescope.nvim'},
        {'nvim-telescope/telescope-fzf-native.nvim', run = 'make'},
        {'nvim-telescope/telescope-file-browser.nvim'},
        {'jacoborus/tender.vim'},
        {'wbthomason/packer.nvim'}}
end)
