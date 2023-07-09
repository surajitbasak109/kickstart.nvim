return {
  'goolord/alpha-nvim',
  dependencies = {
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
  },
  config = function()
    require('alpha').setup(require('alpha.themes.dashboard').config)
  end,
}
