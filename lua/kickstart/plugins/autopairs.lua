-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  opts = {},

  config = function(_, opts)
    local npairs = require 'nvim-autopairs'
    npairs.setup(opts)
    local Rule = require 'nvim-autopairs.rule'
    npairs.add_rules {
      Rule('$', ' $', { 'typst', 'typ' }) -- or "*" for all
        :with_move()
        :use_key '$',
    }
  end,
}
