-- Install Rust
-- Install Cargo
-- Install rust-analyzer with rustup component add rust-analyzer
-- Install rust-fmt with rustup component add rust-fmt
-- Add rust-analyzer to path if needed. To check, type which rust-analyzer

-- Basic settings
vim.opt.number = true
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.background = 'dark'

-- Enable autocompletion
vim.opt.completeopt = {'menu', 'menuone', 'noselect'}
vim.opt.updatetime = 300

-- Limit completion height 
vim.o.pumheight = 10 -- Adjust the number as needed


-- Helper function to find project root
local function find_root_dir()
  local cwd = vim.fn.getcwd()
  local root_files = {'Cargo.toml', 'rust-project.json'}
  for _, file in ipairs(root_files) do
    local found = vim.fn.findfile(file, cwd .. ';')
    if found ~= '' then
      return vim.fn.fnamemodify(found, ':h')
    end
  end
  return cwd
end

-- LSP setup
local on_attach = function(client, bufnr)
  -- Set omnifunc for the buffer
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Enable automatic popup of completion menu
  vim.cmd[[
    augroup LspAutocomplete
      autocmd!
      autocmd CursorHoldI,CursorMovedI <buffer> lua vim.lsp.omnifunc(1, 1)
    augroup END
  ]]

  print("LSP attached and omnifunc set")
end

-- Configure rust_analyzer
local rust_analyzer_config = {
  name = 'rust_analyzer',
  cmd = {'rust-analyzer'},
  root_dir = find_root_dir(),
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = true,
      },
      cargo = {
        allFeatures = true,
      },
    }
  },
  on_attach = on_attach,
}

-- Rust file detection and LSP attachment
vim.api.nvim_create_autocmd("FileType", {
  pattern = "rust",
  callback = function()
    vim.opt_local.formatprg = "rustfmt"
    -- Set omnifunc directly for Rust files
    vim.opt_local.omnifunc = 'v:lua.vim.lsp.omnifunc'
    -- Attempt to start rust_analyzer if it's not already running
    if vim.fn.executable('rust-analyzer') == 1 then
      local client_id = vim.lsp.start_client(rust_analyzer_config)
      if client_id then
        vim.lsp.buf_attach_client(0, client_id)
        print("rust-analyzer started and attached")
      else
        print("Failed to start rust-analyzer")
      end
    else
      print("rust-analyzer not found. Please install it.")
    end
  end
})

-- Set leader key
vim.g.mapleader = " "

vim.cmd [[colorscheme zaibatsu]]
