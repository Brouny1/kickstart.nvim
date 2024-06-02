-- my own telescope config

local builtin = require 'telescope.builtin'
return {
  vim.keymap.set('n', '<leader>ff', builtin.find_files, {}),
}
