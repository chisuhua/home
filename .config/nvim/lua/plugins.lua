-- ~/.config/nvim/lua/plugins.lua
return {
  -- 🎨 主题
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        color_overrides = {
          mocha = {
            mauve = "#89dceb",
          },
        },
        background = {
          light = "latte",
          dark = "mocha",
        },
        transparent_background = true,
        term_colors = true,
        dim_inactive = {
          enabled = false,
          shade = "dark",
          percentage = 0.15,
        },
        no_italic = false,
        no_bold = false,
        styles = {
          comments = { "italic" },
          conditionals = { "italic" },
          loops = {},
          functions = { "bold" },
          keywords = {},
          strings = {},
          variables = {},
          numbers = {},
          booleans = {},
          properties = {},
          types = {},
          operators = {},
        },
        custom_highlights = {},
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- 🍪 瑞士军刀 UI 组件
  {
    "folke/snacks.nvim",
    event = "VeryLazy",
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = false },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      statusline = { enabled = true },
      smooth = { enabled = true },
      words = { enabled = true },
      picker = { enabled = true },
    },
  },

  -- ⌨️ 终端
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = true,
  },

  -- 💬 注释
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = true,
  },

  -- 📁 文件树
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    version = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("neo-tree").setup({})
    end,
  },

  -- 🔍 模糊查找
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-frecency.nvim",
    },
    cmd = "Telescope",
    keys = {
      { "<C-p>", "<cmd>Telescope frecency<cr>", desc = "Find frequent/recent files" },
      { "<C-t>", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")
      local use_fd = vim.fn.executable("fd") == 1

      telescope.setup({
        defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = "➤ ",
          path_display = { "truncate" },
          file_ignore_patterns = {
            "%.git/", "node_modules/", "%.cache/", "build/", "%.vscode/",
            "target/", "_build/", "dist/", "deps/", "%.next/", "out/",
          },
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
            horizontal = { width = 0.9, height = 0.85 },
            vertical = { mirror = false },
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-c>"] = actions.close,
            },
          },
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case"
          },
          find_command = use_fd and { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" } or nil,
        },
        pickers = {
          find_files = {
            find_command = use_fd and { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git", "--exclude", "node_modules" } or nil,
          },
          frecency = {
            show_scores = false,
            show_unindexed = true,
            ignore_patterns = { "%.git/", "node_modules/" },
          },
        },
      })
      require("telescope").load_extension("frecency")
    end,
  },

  -- 🔨 CMake
  {
    "Civitasv/cmake-tools.nvim",
    event = "VeryLazy",
    config = function()
      require("cmake-tools").setup({
        cmake_command = "cmake",
        cmake_build_directory = "build",
        cmake_build_type = "Debug",
        cmake_variants = {
          debug = { ["-DCMAKE_BUILD_TYPE"] = "Debug" },
          release = { ["-DCMAKE_BUILD_TYPE"] = "Release" },
        },
      })
    end,
  },

  -- 🧩 LSP + Mason
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "clangd", "cmake" },
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({ capabilities = capabilities })
          end,
          clangd = function()
            require("lspconfig").clangd.setup({
              capabilities = capabilities,
              cmd = {
                "clangd", "--background-index",
                "--header-insertion=iwyu",
                "--suggest-missing-includes",
                "--compile-commands-dir=build",
              },
              init_options = {
                clangd = { hints = { parameters = true, deducedTypes = true } },
                compilationDatabasePath = "build",
              },
            })
          end,
        },
      })
    end,
  },

  -- 💡 补全引擎（无 copilot）
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-l>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-e>"] = cmp.mapping.complete(),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  -- 🛠️ 格式化
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    config = function()
      require("conform").setup({
        formatters_by_ft = {
          cpp = { "clang-format" },
          c = { "clang-format" },
        },
        format_on_save = { timeout_ms = 1000 },
      })
    end,
  },

  -- 🐞 调试
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "mfussenegger/nvim-dap-python",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")
      dapui.setup()

      local codelldb_path = vim.fn.expand("~/.vscode-server/extensions/vadimcn.vscode-lldb-1.12.1/adapter/codelldb")
      local lldb_lib_path = vim.fn.expand("~/.vscode-server/extensions/vadimcn.vscode-lldb-1.12.1/lldb/lib")
      local has_codelldb = vim.fn.executable(codelldb_path) == 1

      if has_codelldb then
        dap.adapters.lldb = {
          type = "executable",
          command = codelldb_path,
          options = {
            env = {
              LD_LIBRARY_PATH = lldb_lib_path .. ":" .. (os.getenv("LD_LIBRARY_PATH") or ""),
            },
          },
        }
      end

      dap.configurations.cpp = {
        {
          name = "Debug CMake Target",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
        },
        {
          name = "Debug CMake (gdb)",
          type = "cppdbg",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/build/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          setupCommands = {
            { text = "-enable-pretty-printing", description = "Enable pretty-printing" },
          },
        },
      }

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end,
  },

  -- 🌲 Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = { "c", "cpp", "cmake", "bash" },
        auto_install = true,
        highlight = { enable = true },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
          },
        },
        textobjects = {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = "@class.inner",
            },
          },
        },
      })
    end,
  },

  -- 📊 Git 集成
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    config = function()
      require("gitsigns").setup({
        on_attach = function(bufnr)
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end
          map("n", "]c", function()
            if vim.wo.diff then return vim.cmd.normal({ "]c", bang = true }) end
            require("gitsigns").nav_hunk("next")
          end, "Next hunk")
          map("n", "[c", function()
            if vim.wo.diff then return vim.cmd.normal({ "[c", bang = true }) end
            require("gitsigns").nav_hunk("prev")
          end, "Prev hunk")
          map({ "o", "x" }, "ih", require("gitsigns").select_hunk, "Select inner hunk")
          map({ "o", "x" }, "ah", function()
            require("gitsigns").select_hunk({ include_headers = true })
          end, "Select a hunk")
        end,
        signcolumn = true,
        numhl = false,
        linehl = false,
        word_diff = false,
      })
    end,
  },
  {
    "sindrets/diffview.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    config = function()
      require("diffview").setup({
        keymaps = {
          view = {
            ["q"] = "<cmd>DiffviewClose<CR>",
            ["<tab>"] = "select_next_entry",
            ["<s-tab>"] = "select_prev_entry",
          },
          file_panel = {
            ["j"] = "next_entry",
            ["k"] = "prev_entry",
            ["o"] = "open_entry",
          },
        },
      })
    end,
  },
  {
    "f-person/git-blame.nvim",
    event = "BufRead",
    config = function()
      vim.g.gitblame_enabled = 0
    end,
  },

  -- 🔖 书签
  {
    "LintaoAmons/bookmarks.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "kkharji/sqlite.lua" },
    event = "VeryLazy",
    config = function()
      require("bookmarks").setup({
        sign = "🔖",
        hl = {
          name = "BookmarkSign",
          line = "CursorLine",
        },
        center_on_jump = true,
        persist = true,
      })
    end,
  },

  -- 🔖 文本高亮标记（vim-mark）
{
  "ZiYang-oyxy/vim-mark.nvim",
  opts = {
    mark_only = true,
    keymaps = { preset = "none" },
    ui = {
      search_progress_display = "statusline",
    },
  },
},

  -- 📋 剪贴板（osc52 支持远程）
  {
    "ojroques/nvim-osc52",
    event = "VeryLazy",
    config = function()
      require("osc52").setup({
        max_length = 100000,
        silent = true,
      })
    end,
  },

  -- 🔎 搜索高亮 lens
  {
    "kevinhwang91/nvim-hlslens",
    event = "VeryLazy",
    config = function()
      require("hlslens").setup({})
    end,
  },

  {
  "nickjvandyke/opencode.nvim",
  version = "*", -- Latest stable release
  dependencies = {
    {
      -- `snacks.nvim` integration is recommended, but optional
      ---@module "snacks" <- Loads `snacks.nvim` types for configuration intellisense
      "folke/snacks.nvim",
      optional = true,
      opts = {
        input = {}, -- Enhances `ask()`
        picker = { -- Enhances `select()`
          actions = {
            opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
          },
          win = {
            input = {
              keys = {
                ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
              },
            },
          },
        },
      },
    },
  },
  config = function()
    ---@type opencode.Opts
    vim.g.opencode_opts = {
    }

    vim.o.autoread = true
  end,
},

{
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {
    expand = 1,
    show_guide = true,
    sort = { "group", "alphanum" },
    layout = {
      width = { max = 80 },
      spacing = 3,
    },
    win = {
      border = "rounded",
    },
  },
  keys = {
    {
      "<leader>?",
      function()
        require("which-key").show({ global = false })
      end,
      desc = "Buffer Local Keymaps (which-key)",
    },
  },
  config = function()
    local wk = require("which-key")

    -- 注册分组（只定义 name，不定义具体操作，这样按下去会显示子菜单）
    wk.register({
      f = { name = "+Find" },
      g = { name = "+Git" },
      c = { name = "+Code" },
      d = { name = "+Debug" },
      w = { name = "+Window" },
      b = { name = "+Buffers" },
      m = { name = "+Marks" },
      t = { name = "+Terminal" },
      s = { name = "+Symbols" },
      q = { name = "+Quickfix" },
      e = { name = "+Explore" },
      o = { name = "+OpenCode" },
      ["/"] = { name = "+Comment" },
      n = { name = "+Search" },
      k = { name = "+CMake" },
      u = { name = "+UI" },
    }, { prefix = "<leader>" })

    -- 具体操作映射（嵌套在分组下）
    wk.register({
      -- Quit
      ["<leader>qq"] = { "<cmd>q<cr>", "Quit" },

      -- Window
      ["<leader>wv"] = { "<C-w>v", "Split vertical" },
      ["<leader>ws"] = { "<C-w>s", "Split horizontal" },
      ["<leader>wc"] = { "<C-w>c", "Close window" },
      ["<leader>w="] = { "<C-w>=", "Equalize sizes" },

      -- Buffer
      ["<leader>bd"] = { "<cmd>bd<cr>", "Close buffer" },

      -- Explore (Neotree)
      ["<leader>e"]  = { "<cmd>Neotree<cr>", "Toggle file tree" },

      -- Quickfix
      ["<leader>qc"] = { "<cmd>lua require('telescope.builtin').quickfix()<cr>", "Quickfix" },
      ["<leader>ql"] = { "<cmd>lua require('telescope.builtin').loclist()<cr>", "Loclist" },

      -- Code
      ["<leader>ca"] = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
      ["<leader>cD"] = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Go to definition" },
      ["<leader>cR"] = { "<cmd>lua vim.lsp.buf.references()<cr>", "Find references" },
      ["<leader>cT"] = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Go to type definition" },
      ["<leader>ci"] = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Go to implementation" },
      ["<leader>ch"] = { "<cmd>ClangdSwitchSourceHeader<cr>", "Switch source/header" },
      ["<leader>c]d"] = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" },
      ["<leader>c[d"] = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Prev Diagnostic" },

      -- Git (gitsigns)
      ["<leader>gs"] = { require("gitsigns").stage_hunk, "Stage hunk" },
      ["<leader>gr"] = { require("gitsigns").reset_hunk, "Reset hunk" },
      ["<leader>gS"] = { require("gitsigns").stage_buffer, "Stage buffer" },
      ["<leader>gR"] = { require("gitsigns").reset_buffer, "Reset buffer" },
      ["<leader>gp"] = { require("gitsigns").preview_hunk, "Preview hunk" },
      ["<leader>gi"] = { require("gitsigns").preview_hunk_inline, "Preview inline" },
      ["<leader>gq"] = { require("gitsigns").setqflist, "Quickfix hunks" },
      ["<leader>gd"] = { "<cmd>DiffviewOpen<cr>", "Diff view" },
      ["<leader>gh"] = { "<cmd>DiffviewFileHistory %<cr>", "File history" },
      ["<leader>gb"] = { "<cmd>GitBlameToggle<cr>", "Git blame" },

      -- Find (Telescope)
      ["<leader>ff"] = { "<cmd>Telescope find_files<cr>", "Find files" },
      ["<leader>fF"] = { "<cmd>Telescope find_all_files<cr>", "Find all files" },
      ["<leader>fg"] = { "<cmd>Telescope live_grep<cr>", "Live grep" },
      ["<leader>fb"] = { "<cmd>Telescope buffers<cr>", "Buffers" },
      ["<leader>fh"] = { "<cmd>Telescope help_tags<cr>", "Help" },

      -- Tabs
      ["<leader>tn"] = { "<cmd>tabnew<cr>", "New tab" },
      ["<leader>tc"] = { "<cmd>tabclose<cr>", "Close tab" },
      ["<leader>to"] = { "<cmd>tabonly<cr>", "Close other tabs" },
      ["<leader>t["] = { "<cmd>tabprevious<cr>", "Prev tab" },
      ["<leader>t]"] = { "<cmd>tabnext<cr>", "Next tab" },
      ["<leader>ta"] = { "<cmd>ToggleTerm direction=float<cr>", "Terminal" },

      -- Debug
      ["<leader>db"] = { "<cmd>lua require('dap').toggle_breakpoint()<cr>", "Toggle Breakpoint" },
      ["<leader>dB"] = { "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Condition: '))<cr>", "Conditional breakpoint" },
      ["<leader>dC"] = { "<cmd>lua require('dap').run_to_cursor()<cr>", "Run to cursor" },
      ["<leader>dk"] = { "<cmd>lua require('dap').clear_breakpoints()<cr>", "Clear breakpoints" },
      ["<leader>dl"] = { "<cmd>lua require('dap').list_breakpoints()<cr>", "List breakpoints" },
      ["<leader>dr"] = { "<cmd>lua require('dap').repl.open()<cr>", "Open REPL" },

      -- Marks (bookmarks.nvim)
      ["<leader>ma"] = { "<cmd>BookmarksAdd<cr>", "Add bookmark" },
      ["<leader>md"] = { "<cmd>BookmarksDelete<cr>", "Delete bookmark" },
      ["<leader>ml"] = { "<cmd>BookmarksList<cr>", "List bookmarks" },
      ["<leader>mn"] = { "<cmd>BookmarksNext<cr>", "Next bookmark" },
      ["<leader>mp"] = { "<cmd>BookmarksPrev<cr>", "Previous bookmark" },

      -- Marks (vim-mark.nvim)
      ["<leader>mm"] = { "<cmd>MarkToggle<cr>", "Toggle mark" },
      ["<leader>m,"] = { "<cmd>MarkSet<cr>", "Set next mark" },
      ["<leader>mj"] = { "<cmd>MarkNavNext<cr>", "Next mark" },
      ["<leader>mk"] = { "<cmd>MarkNavPrev<cr>", "Prev mark" },
      ["<leader>mc"] = { "<cmd>MarkClear<cr>", "Clear marks" },

      -- Symbols
      ["<leader>s:"] = { "<cmd>lua require('telescope.builtin').lsp_document_symbols({ symbol_type = { 'Class', 'Function', 'Struct' } })<cr>", "Doc symbols (filtered)" },
      ["<leader>sw"] = { "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", "Workspace symbols" },
      ["<leader>sd"] = { "<cmd>lua vim.lsp.buf.document_symbol()<cr>", "Document symbols" },
      ["<leader>st"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Doc symbols (TS)" },
      ["<leader>sT"] = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace symbols (TS)" },

      -- OpenCode
      ["<leader>oa"] = { function() require("opencode").ask("@this: ", { submit = true }) end, "Ask opencode" },
      ["<leader>ox"] = { function() require("opencode").select() end, "Execute action" },
      ["<leader>o."] = { function() require("opencode").toggle() end, "Toggle opencode" },
      ["<leader>og"] = { function() return require("opencode").operator("@this ") end, "Add range", expr = true },
      ["<leader>oG"] = { function() return require("opencode").operator("@this ") .. "_" end, "Add line", expr = true },
      ["<leader>ou"] = { function() require("opencode").command("session.half.page.up") end, "Scroll up" },
      ["<leader>od"] = { function() require("opencode").command("session.half.page.down") end, "Scroll down" },

      -- Comment
      ["<leader>/"] = { function() require("Comment.api").toggle.linewise.current() end, "Toggle comment" },
      ["<leader>c/"] = { function() require("Comment.api").toggle.blockwise.current() end, "Toggle block comment" },

      -- Search (hlslens)
      ["<leader>n"] = { function() require("hlslens").start() end, "Search lens next" },
      ["<leader>N"] = { function() require("hlslens").start(true) end, "Search lens prev" },

      -- CMake
      ["<leader>kk"] = { "<cmd>CMakeKill<cr>", "Kill CMake server" },
      ["<leader>kr"] = { "<cmd>CMakeReset<cr>", "Reset CMake" },
      ["<leader>kc"] = { "<cmd>CMakeClean<cr>", "Clean CMake" },
      ["<leader>kd"] = { "<cmd>CMakeDebug<cr>", "Debug CMake" },
      ["<leader>ks"] = { "<cmd>CMakeShowTargets<cr>", "Show targets" },

      -- UI (snacks.nvim)
      ["<leader>ub"] = { function() require("snacks").toggle("picker") end, "Toggle picker" },
      ["<leader>un"] = { function() require("snacks").toggle("notifier") end, "Toggle notifier" },
      ["<leader>uw"] = { function() require("snacks").toggle("words") end, "Toggle words" },
    })
  end,
}

  -- 🔑 which-key 快捷键提示
--   {
--     "folke/which-key.nvim",
--     event = "VeryLazy",
--     init = function()
--       vim.o.timeout = true
--       vim.o.timeoutlen = 300
--     end,
--     config = function()
--       local wk = require("which-key")
--       wk.setup({
--         show_guide = true,
--         expand = 0,
--         sort = { "group", "alphanum" },
--         layout = {
--           width = { max = 80 },
--           spacing = 3,
--         },
--         win = {
--           border = "rounded",
--         },
--       })
--
--       wk.register({
--         c = { name = "+Code" },
--         g = { name = "+Git" },
--         f = { name = "+Find" },
--         d = { name = "+Debug" },
--         s = { name = "+Symbols" },
--         t = { name = "+Tabs" },
--         w = { name = "+Window" },
--         b = { name = "+Buffers" },
--         m = { name = "+Marks/Bookmarks" },
--         q = { name = "+Quickfix" },
--
--         ["<leader>qq"] = { "<cmd>q<cr>", "Quit" },
--
--         ["<leader>qc"] = { "<cmd>lua require('telescope.builtin').quickfix()<cr>", "Quickfix" },
--         ["<leader>ql"] = { "<cmd>lua require('telescope.builtin').loclist()<cr>", "Loclist" },
--         ["<leader>e"]  = { "<cmd>Neotree<cr>", "Toggle file tree" },
--
--         ["<leader>ca"] = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
--         ["<leader>cp"] = {
--           function()
--             vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", false)
--             require("cmp").complete()
--           end,
--           "Insert & trigger completion"
--         },
--         ["<leader>cD"] = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Go to definition" },
--         ["<leader>cR"] = { "<cmd>lua vim.lsp.buf.references()<cr>", "Find references" },
--         ["<leader>cT"] = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Go to type definition" },
--         ["<leader>ci"] = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Go to implementation" },
--         ["<leader>ch"] = { "<cmd>ClangdSwitchSourceHeader<cr>", "Switch source/header" },
--         ["<leader>c]d"] = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" },
--         ["<leader>c[d"] = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Prev Diagnostic" },
--
--         ["<leader>wv"] = { "<C-w>v", "Split vertical" },
--         ["<leader>ws"] = { "<C-w>s", "Split horizontal" },
--         ["<leader>wc"] = { "<C-w>c", "Close window" },
--         ["<leader>w="] = { "<C-w>=", "Equalize sizes" },
--
--         ["<leader>bd"] = { "<cmd>bd<cr>", "Close buffer" },
--
--         ["<leader>ff"] = { "<cmd>Telescope find_files<cr>", "Find files" },
--         ["<leader>fF"] = { "<cmd>Telescope find_all_files<cr>", "Find all files" },
--         ["<leader>fg"] = { "<cmd>Telescope live_grep<cr>", "Live grep" },
--         ["<leader>fb"] = { "<cmd>Telescope buffers<cr>", "Buffers" },
--         ["<leader>fh"] = { "<cmd>Telescope help_tags<cr>", "Help" },
--
--         ["<leader>ma"] = { "<cmd>BookmarksAdd<cr>", "Add bookmark" },
--         ["<leader>md"] = { "<cmd>BookmarksDelete<cr>", "Delete bookmark" },
--         ["<leader>ml"] = { "<cmd>BookmarksList<cr>", "List bookmarks" },
--         ["<leader>mn"] = { "<cmd>BookmarksNext<cr>", "Next bookmark" },
--         ["<leader>mp"] = { "<cmd>BookmarksPrev<cr>", "Previous bookmark" },
--
--         ["<leader>mm"] = { "<cmd>MarkToggle<cr>", "Toggle mark" },
--         ["<leader>m,"] = { "<cmd>MarkSet<cr>", "Set next mark" },
--         ["<leader>mj"] = { "<cmd>MarkNavNext<cr>", "Next mark" },
--         ["<leader>mk"] = { "<cmd>MarkNavPrev<cr>", "Prev mark" },
--         ["<leader>mc"] = { "<cmd>MarkClear<cr>", "Clear marks" },
--
--         ["<leader>s:"] = { "<cmd>lua require('telescope.builtin').lsp_document_symbols({ symbol_type = { 'Class', 'Function', 'Struct' } })<cr>", "Document symbols (filtered)" },
--         ["<leader>sw"] = { "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", "Workspace symbols" },
--         ["<leader>sd"] = { "<cmd>lua vim.lsp.buf.document_symbol()<cr>", "Document symbols" },
--         ["<leader>st"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Doc symbols (TS)" },
--         ["<leader>sT"] = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace symbols (TS)" },
--
--         ["<leader>ta"] = { "<cmd>ToggleTerm direction=float<cr>", "Terminal" },
--         ["<leader>tn"] = { "<cmd>tabnew<cr>", "New tab" },
--         ["<leader>tc"] = { "<cmd>tabclose<cr>", "Close tab" },
--         ["<leader>to"] = { "<cmd>tabonly<cr>", "Close other tabs" },
--         ["<leader>t["] = { "<cmd>tabprevious<cr>", "Prev tab" },
--         ["<leader>t]"] = { "<cmd>tabnext<cr>", "Next tab" },
--
--         ["<leader>dB"] = { "<cmd>lua require('dap').set_breakpoint(vim.fn.input('Condition: '))<cr>", "Conditional breakpoint" },
--         ["<leader>dC"] = { "<cmd>lua require('dap').run_to_cursor()<cr>", "Run to cursor" },
--         ["<leader>db"] = { "<cmd>lua require('dap').toggle_breakpoint()<cr>", "Toggle Breakpoint" },
--         ["<leader>dk"] = { "<cmd>lua require('dap').clear_breakpoints()<cr>", "Clear breakpoints" },
--         ["<leader>dl"] = { "<cmd>lua require('dap').list_breakpoints()<cr>", "List breakpoints" },
--         ["<leader>dr"] = { "<cmd>lua require('dap').repl.open()<cr>", "Open REPL" },
--
--         ["<leader>gs"] = { "<cmd>lua require('gitsigns').stage_hunk()<cr>", "Stage hunk" },
--         ["<leader>gr"] = { "<cmd>lua require('gitsigns').reset_hunk()<cr>", "Reset hunk" },
--         ["<leader>gS"] = { "<cmd>lua require('gitsigns').stage_buffer()<cr>", "Stage buffer" },
--         ["<leader>gR"] = { "<cmd>lua require('gitsigns').reset_buffer()<cr>", "Reset buffer" },
--         ["<leader>gp"] = { "<cmd>lua require('gitsigns').preview_hunk()<cr>", "Preview hunk" },
--         ["<leader>gi"] = { "<cmd>lua require('gitsigns').preview_hunk_inline()<cr>", "Preview inline" },
--         ["<leader>gq"] = { "<cmd>lua require('gitsigns').setqflist()<cr>", "Quickfix hunks" },
--         ["<leader>gd"] = { "<cmd>DiffviewOpen<cr>", "Diff view" },
--         ["<leader>gh"] = { "<cmd>DiffviewFileHistory %<cr>", "File history" },
--         ["<leader>gb"] = { "<cmd>GitBlameToggle<cr>", "Git blame" },
--       }, { prefix = "<leader>" })
--     end,
--   },
}
