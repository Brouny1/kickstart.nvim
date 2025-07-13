-- vim:foldmethod=marker
-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

return {
  -- Does what it says.
  { 'tzachar/highlight-undo.nvim', opts = {} },
  -- great rust tool
  { 'simrat39/rust-tools.nvim', ft = { 'rust' }, opts = {} },

  -- Scala Metals {{{
  -- Scala metals start
  {
    'scalameta/nvim-metals',
    dependencies = {
      'nvim-lua/plenary.nvim',
    },
    ft = { 'scala', 'sbt', 'java' },
    opts = function()
      local metals_config = require('metals').bare_config()

      -- "off" will enable LSP progress notifications by Metals and you'll need
      -- to ensure you have a plugin like fidget.nvim installed to handle them.
      metals_config.init_options.statusBarProvider = 'off'

      -- metals_config.capabilities = require('blink.cmp').get_lsp_capabilities()

      metals_config.on_attach = function(client, bufnr)
        -- your on_attach function
      end

      return metals_config
    end,
    config = function(self, metals_config)
      local nvim_metals_group = vim.api.nvim_create_augroup('nvim-metals', { clear = true })
      vim.api.nvim_create_autocmd('FileType', {
        pattern = self.ft,
        callback = function()
          require('metals').initialize_or_attach(metals_config)
        end,

        group = nvim_metals_group,
      })
    end,
  },
  -- Scala metals end }}}

  -- VimTex {{{
  {
    'lervag/vimtex',
    lazy = false, -- we don't want to lazy load VimTeX
    -- tag = "v2.15", -- uncomment to pin to a specific release
    init = function()
      -- VimTeX configuration goes here, e.g.
      vim.g.vimtex_view_method = 'zathura'
      vim.g.vimtex_imaps_enabled = false
      vim.opt.conceallevel = 2
      -- vim.g.vimtex_syntax_conceal = { math_bounds = 0 }
    end,
  },
  -- }}}

  -- Typst Preview {{{
  {
    'chomosuke/typst-preview.nvim',
    -- lazy = false, -- or ft = 'typst'
    ft = 'typst',
    version = '1.*',
    opts = {

      -- Setting this true will enable logging debug information to
      -- `vim.fn.stdpath 'data' .. '/typst-preview/log.txt'`
      debug = false,

      -- Custom format string to open the output link provided with %s
      -- Example: open_cmd = 'firefox %s -P typst-preview --class typst-preview'
      open_cmd = nil,

      -- Custom port to open the preview server. Default is random.
      -- Example: port = 8000
      -- port = 0,

      -- Setting this to 'always' will invert black and white in the preview
      -- Setting this to 'auto' will invert depending if the browser has enable
      -- dark mode
      -- Setting this to '{"rest": "<option>","image": "<option>"}' will apply
      -- your choice of color inversion to images and everything else
      -- separately.
      invert_colors = 'never',

      -- Whether the preview will follow the cursor in the source file
      follow_cursor = true,

      -- Provide the path to binaries for dependencies.
      -- Setting this will skip the download of the binary by the plugin.
      -- Warning: Be aware that your version might be older than the one
      -- required.
      dependencies_bin = {
        ['tinymist'] = 'tinymist',
        ['websocat'] = nil,
      },

      -- A list of extra arguments (or nil) to be passed to previewer.
      -- For example, extra_args = { "--input=ver=draft", "--ignore-system-fonts" }
      extra_args = nil,

      -- This function will be called to determine the root of the typst project
      get_root = function(path_of_main_file)
        local root = os.getenv 'TYPST_ROOT'
        if root then
          return root
        end
        return vim.fn.fnamemodify(path_of_main_file, ':p:h')
      end,

      -- This function will be called to determine the main file of the typst
      -- project.
      get_main_file = function(path_of_buffer)
        return path_of_buffer
      end,
    }, -- lazy.nvim will implicitly calls `setup {}`
  },

  -- Typst Preview }}}
}
