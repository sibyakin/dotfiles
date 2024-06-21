vim.opt.cmdheight = 0
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
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0
vim.lsp.set_log_level(vim.log.levels.WARN)
vim.cmd('colo tender')
vim.cmd('command! Q :q')

local lsp_on_attach = function()
    vim.opt.updatetime = 750
    vim.diagnostic.config({virtual_text = false})
    vim.keymap.set('n', 'dn', '<cmd>lua vim.diagnostic.goto_next()<CR>')
    vim.keymap.set('n', 'dp', '<cmd>lua vim.diagnostic.goto_prev()<CR>')
    vim.keymap.set('n', 'fd', '<cmd>Telescope diagnostics<CR>')
    vim.keymap.set('n', 'FT', '<cmd>Telescope lsp_type_definitions<CR>')
    vim.keymap.set('n', 'ft', '<cmd>Telescope lsp_definitions<CR>')
    vim.keymap.set('n', 'fr', '<cmd>Telescope lsp_references<CR>')
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
    vim.api.nvim_create_autocmd('BufWritePre', {
        pattern = {'*.go'},
        callback = function()
            vim.lsp.buf.format({bufnr = bufnr})
        end,
    })
    vim.api.nvim_create_autocmd('CursorHold', {
        pattern = {'*.go'},
        callback = function()
            vim.diagnostic.open_float(nil, {focus=false})
        end,
    })
end

local lsp = require('lspconfig')
lsp.gopls.setup({
    on_attach = gopls_on_attach,
})
lsp.golangci_lint_ls.setup({
    cmd = { 'golangci-lint-langserver', '-nolintername' },
    init_options = {
        command = {'golangci-lint', 'run', '-E', 'bidichk', '-E', 'bodyclose', '-E', 'decorder', '-E', 'dupl', '-E', 'dupword', '-E', 'errname', '-E', 'errorlint', '-E', 'forcetypeassert', '-E', 'goconst', '-E', 'godox', '-E', 'goprintffuncname', '-E', 'intrange', '-E', 'nilerr', '-E', 'nilnil', '-E', 'perfsprint', '-E', 'prealloc', '-E', 'predeclared', '-E', 'sloglint', '-E', 'sqlclosecheck', '-E', 'unconvert', '-E', 'usestdlibvars', '-E', 'wastedassign', '-E', 'wrapcheck', '--out-format', 'json'},
    },
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
    },
})

require('nvim-treesitter.configs').setup({
    ensure_installed = {'go', 'gomod', 'lua'},
    highlight = {enable = true},
})

require('nvim-autopairs').setup()

require('gitsigns').setup({
    numhl = true,
    current_line_blame = true,
    current_line_blame_formatter = '<author>: <summary>',
    on_attach = function(bufnr)
        vim.keymap.set('n', 'ga', '<cmd>Gitsigns attach<CR>')
        vim.keymap.set('n', 'gd', '<cmd>Gitsigns detach<CR>')
        vim.keymap.set('n', 'gr', '<cmd>Gitsigns refresh<CR>')
        vim.keymap.set('n', 'gw', '<cmd>Gitsigns next_hunk<CR>')
        vim.keymap.set('n', 'gs', '<cmd>Gitsigns prev_hunk<CR>')
        vim.keymap.set('n', 'gh', '<cmd>Gitsigns preview_hunk_inline<CR>')
        vim.keymap.set('n', 'fg', '<cmd>Telescope git_commits<CR>')
    end,
})

require('telescope').setup({
    defaults = {
        layout_strategy = 'vertical',
        layout_config = {width = 0.85, height = 0.95, preview_height = 0.65},
    },
    pickers = {diagnostics = {line_width = 0.65}},
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
vim.keymap.set('n', 'fk', '<cmd>Telescope keymaps<CR>')
vim.keymap.set('n', 'fs', '<cmd>Telescope current_buffer_fuzzy_find<CR>')

require('nvim-web-devicons').setup()
require('lualine').setup({options = {icons_enabled = true, theme = 'gruvbox-material'}})

require('paq')({
    {'savq/paq-nvim'},
    {'nvim-lua/plenary.nvim'},
    {'nvim-tree/nvim-web-devicons', pin = true},
    {'nvim-lualine/lualine.nvim'},
    {'neovim/nvim-lspconfig'},
    {'nametake/golangci-lint-langserver'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'dcampos/nvim-snippy'},
    {'dcampos/cmp-snippy'},
    {'hrsh7th/nvim-cmp'},
    {'nvim-treesitter/nvim-treesitter', build = ':TSUpdateSync'},
    {'windwp/nvim-autopairs'},
    {'lewis6991/gitsigns.nvim'},
    {'nvim-telescope/telescope.nvim'},
    {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    {'nvim-telescope/telescope-file-browser.nvim'},
    {'jacoborus/tender.vim'},
})

