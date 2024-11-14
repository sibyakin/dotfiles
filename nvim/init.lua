require('paq')({
    {'savq/paq-nvim'},
    {'nvim-lua/plenary.nvim'},
    {'nvim-tree/nvim-web-devicons'},
    {'nvim-treesitter/nvim-treesitter', build = ':TSUpdate'},
    {'rmagatti/auto-session'},
    {'neovim/nvim-lspconfig'},
    {'dcampos/nvim-snippy'},
    {'dcampos/cmp-snippy'},
    {'hrsh7th/cmp-nvim-lsp'},
    {'iguanacucumber/magazine.nvim', as = 'nvim-cmp'},
    {'windwp/nvim-autopairs'},
    {'lewis6991/gitsigns.nvim'},
    {'echasnovski/mini.notify'},
    {'nvim-telescope/telescope.nvim'},
    {'nvim-telescope/telescope-fzf-native.nvim', build = 'make'},
    {'debugloop/telescope-undo.nvim'},
    {'stevearc/dressing.nvim'},
    {'sibyakin/rasmus.nvim'},
})

require('nvim-treesitter.configs').setup({
    ensure_installed = {'go', 'gomod'},
    highlight = {enable = true},
})

require('auto-session').setup({})

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
    vim.api.nvim_create_autocmd({'BufWritePre'}, {
        pattern = {'*.go'},
        callback = lsp_fix_imports_and_format,
    })
    vim.api.nvim_create_autocmd({'CursorHold'}, {
        pattern = {'*.go', 'go.mod'},
        callback = lsp_show_diagnostics,
    })
    vim.o.updatetime = 750
end

require('lspconfig').gopls.setup({
    settings = {
        gopls = {
            analyses = {
                shadow = true,
                unusedvariable = true,
                useany = true,
            },
            gofumpt = true,
        },
    },
    on_attach = lsp_on_attach(),
})

local snippy = require('snippy')
snippy.setup({})

local cmp = require('cmp')
cmp.setup({
    preselect = cmp.PreselectMode.None,
    mapping = cmp.mapping{
        ['<C-Space>'] = snippy.expand_or_advance,
        [  '<Tab>'  ] = cmp.mapping.select_next_item({behavior = cmp.SelectBehavior.Select}),
        [ '<S-Tab>' ] = cmp.mapping.select_prev_item({behavior = cmp.SelectBehavior.Select}),
        [  '<C-d>'  ] = cmp.mapping.confirm({select = true}),
    },
    matching = {
        disallow_fuzzy_matching = true,
        disallow_fullfuzzy_matching = true,
        disallow_partial_matching = true,
    },
    sorting = {
        comparators = {
            cmp.config.compare.recently_used,
            cmp.config.compare.exact,
            cmp.config.compare.length,
            cmp.config.compare.locality,
        },
    },
    sources = {
        {name = 'snippy', keyword_length = 2},
        {name = 'nvim_lsp', keyword_length = 2},
    },
    view = {entries = {follow_cursor = true}},
})

require('nvim-autopairs').setup({})

require('gitsigns').setup({current_line_blame = true})

mini_notify = require('mini.notify')
mini_notify.setup({
    content = {format = function(notif) return notif.msg end},
    window = {winblend = 0, max_width_share = 0.60},
    lsp_progress = {enable = false},
})
local notify_st = {duration = 10000, hl_group = 'Float'}
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
        preview = {hide_on_startup = true},
        cache_picker = {num_pickers = 15},
    },
    pickers = {diagnostics = {path_display = 'hidden'}},
})
telescope.load_extension('fzf')
telescope.load_extension('undo')

vim.o.sessionoptions='buffers,curdir,winsize,winpos,localoptions'
vim.o.showtabline = 0
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.number = true
vim.o.undofile = true
vim.o.shiftwidth = 4
vim.o.tabstop = 4
vim.o.guicursor = ''
vim.o.mouse = 'cv'
vim.o.pumheight = 7
vim.o.scrolloff = 8
vim.o.laststatus = 3
vim.o.background = 'dark'
vim.o.statusline = '%F %r %= %{&ff} %{&fenc}'
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.rasmus_italic_comments = false
vim.g.rasmus_transparent = true
vim.g.mapleader = ' '
vim.keymap.set('n', '<Leader>q', '<cmd>bdelete<CR>')
vim.keymap.set('n', '<Leader>b', '<cmd>Telescope buffers<CR>')
vim.keymap.set('n', '<Leader>o', '<cmd>Telescope oldfiles<CR>')
vim.keymap.set('n', '<Leader>s', '<cmd>Telescope current_buffer_fuzzy_find<CR>')
vim.keymap.set('n', '<Leader>f', '<cmd>Telescope find_files no_ignore=true hidden=true<CR>')
vim.keymap.set('n', '<Leader>h', '<cmd>Telescope undo<CR>')
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
vim.cmd.colorscheme('rasmus')
vim.api.nvim_set_hl(0, 'GitSignsCurrentLineBlame', {link = 'Comment'})
