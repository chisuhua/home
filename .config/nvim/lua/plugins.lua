-- ~/.config/nvim/lua/plugins.lua
return {
  -- 🔧 插件管理器 UI（可选）
  -- { "folke/lazy.nvim", cmd = "Lazy" },
    -- 🎨 主题
{
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000, -- 高优先级确保尽早加载 colorscheme
  config = function()
    require("catppuccin").setup({
      flavour = "mocha", -- 👈 默认就是 mocha，不依赖环境变量
      color_overrides = {
         mocha = {
           mauve = "#89dceb", -- 青色（类似 sky）
         }
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
      color_overrides = {},
      custom_highlights = {},
    })

    vim.cmd.colorscheme("catppuccin")
  end,
  },
  {
    "folke/snacks.nvim",
    event = "VeryLazy", -- 可选：延迟加载
    opts = {
      -- 可选配置，按需启用组件
      bigfile = { enabled = true },
      dashboard = { 
        enabled = false,
        content = {
          { "🚀 Quick Actions", "" },
          { "  Find File", "<C-p>", icon = "", desc = "Find files using Telescope" },
          { "󰈚  Recent Files", "<leader>fr", icon = "󰈚", desc = "Open recent files" },
          { "  Find Word", "<leader>/", icon = "", desc = "Search current word" },
          { "", "" },
          { "  Sessions", "<leader>fs", icon = "", desc = "Manage sessions" },
        }
      },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      statusline = { enabled = true },
      smooth = { enabled = true },
      words = { enabled = true },
      picker = { enabled = true },
      -- 更多选项见 https://github.com/folke/snacks.nvim#-usage
    },
  },
{
  "akinsho/toggleterm.nvim",
  version = "*",
  config = true,
},
	{
	  "numToStr/Comment.nvim",
	  event = "VeryLazy",
	  config = true,
	},
  -- 🧠 AI 补全
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = {
          enabled = false,
          auto_trigger = true,
          debounce = 75,
          -- keymap = { accept = "<C-l>" },
        },
        panel = { enabled = false },
      })
    end,
  },
  -- 🌳 文件树
  -- {
  --   "nvim-tree/nvim-tree.lua",
  -- lazy = false,
  -- dependencies = { "nvim-tree/nvim-web-devicons" },
  -- config = function()
  --   require("nvim-tree").setup({})  -- ← 必须有这一行！
  -- end,
  -- keys = { { "e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle file tree" } }
  -- },
  {
  "nvim-neo-tree/neo-tree.nvim",
  lazy = false,
  version = "v3.x",  -- 👈 关键：锁定 v3 分支（包含 3.30+）
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons", -- optional
  },
  config = function()
    require("neo-tree").setup({
      -- 你的配置
    })
  end,
  },
  {
    "GeorgesAlkhouri/nvim-aider",
    cmd = "Aider",
    -- Example key mappings for common actions:
    keys = {
      { "<leader>a/", "<cmd>Aider toggle<cr>", desc = "Toggle Aider" },
      { "<leader>as", "<cmd>Aider send<cr>", desc = "Send to Aider", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>Aider command<cr>", desc = "Aider Commands" },
      { "<leader>ab", "<cmd>Aider buffer<cr>", desc = "Send Buffer" },
      { "<leader>a+", "<cmd>Aider add<cr>", desc = "Add File" },
      { "<leader>a-", "<cmd>Aider drop<cr>", desc = "Drop File" },
      { "<leader>ar", "<cmd>Aider add readonly<cr>", desc = "Add Read-Only" },
      { "<leader>aR", "<cmd>Aider reset<cr>", desc = "Reset Session" },
      -- Example nvim-tree.lua integration if needed
      -- { "<leader>a+", "<cmd>AiderTreeAddFile<cr>", desc = "Add File from Tree to Aider", ft = "NvimTree" },
      -- { "<leader>a-", "<cmd>AiderTreeDropFile<cr>", desc = "Drop File from Tree from Aider", ft = "NvimTree" },
    },
    dependencies = {
      { "folke/snacks.nvim", version = ">=2.24.0" },
      --- The below dependencies are optional
      "catppuccin/nvim",
      "nvim-tree/nvim-tree.lua",
      --- Neo-tree integration
      {
        "nvim-neo-tree/neo-tree.nvim",
        opts = function(_, opts)
          -- Example mapping configuration (already set by default)
          -- opts.window = {
          --   mappings = {
          --     ["+"] = { "nvim_aider_add", desc = "add to aider" },
          --     ["-"] = { "nvim_aider_drop", desc = "drop from aider" }
          --     ["="] = { "nvim_aider_add_read_only", desc = "add read-only to aider" }
          --   }
          -- }
          require("nvim_aider.neo_tree").setup(opts)
        end,
      },
    },
    config = function()
      require("nvim_aider").setup({
      -- Command that executes Aider
      aider_cmd = "aider",
      -- Command line arguments passed to aider
      args = {
        "--model", "deepseek", "--api-key", "deepseek=sk-8fcbc9a1063c45d792b2903fa31baa1a",
        "--pretty",
        "--stream",
        "--chat-history-file", "aider_session.log"
      },
      -- Automatically reload buffers changed by Aider (requires vim.o.autoread = true)
      auto_reload = true,
      notifications = true,
      }) 
    end,
  },
  {
  "NickvanDyke/opencode.nvim",
	  dependencies = {
	    -- Recommended for `ask()` and `select()`.
	    -- Required for `snacks` provider.
	    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
	    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
	  },
	  config = function()
	    ---@type opencode.Opts
	    vim.g.opencode_opts = {
	      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
	    }

	    -- Required for `opts.events.reload`.
	    vim.o.autoread = true

	    -- Recommended/example keymaps.
      vim.keymap.set("n", "<leader>oq", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode.."})
      vim.keymap.set("n", "<leader>os", function() require("opencode").select() end, { desc = "Select opencode action with -" })
	    -- vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
	    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end,                          { desc = "Execute opencode action…" })
	    -- vim.keymap.set({ "n", "t" }, "<C-.>", function() require("opencode").toggle() end,                          { desc = "Toggle opencode" })

	    vim.keymap.set({ "n", "x" }, "go",  function() return require("opencode").operator("@this ") end,        { desc = "Add range to opencode", expr = true })
	    vim.keymap.set("n",          "gl", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })

      vim.keymap.set("n", "<leader>ao", function() require("opencode").toggle() end, { desc = "Toggle opencode panel" })


	    vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end,   { desc = "Scroll opencode up" })
	    vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })

	    -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
	    -- vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
	    -- vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
	  end,
  },

  -- 🔍 模糊查找
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope-frecency.nvim", -- 可选：高频文件
    },
    cmd = "Telescope",
    keys = {
      { "<C-p>", "<cmd>Telescope frecency<cr>", desc = "Find frequent/recent files (VS Code style)" },
      { "<C-t>", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
      { "<leader>fF", "<cmd>Telescope find_all_files<cr>", desc = "Find all files" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      -- 自动检测是否安装 fd，若未安装则回退到 find
      local has_fd, _ = pcall(require, "telescope.utils")
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
          -- 使用 fd 提升速度（如果可用）
          find_command = use_fd and { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git" } or nil,
        },
        pickers = {
          find_files = {
            -- 即使不用 frecency，find_files 也受益于 fd
            find_command = use_fd and { "fd", "--type", "f", "--hidden", "--follow", "--exclude", ".git", "--exclude", "node_modules" } or nil,
          },
          find_files_all = {
            find_command = use_fd and { "fd", "--type", "f", "--hidden", "--follow" } or nil,
            -- 显式清空 ignore_patterns（覆盖 defaults）
            file_ignore_patterns = {},
          },
          frecency = {
            show_scores = false,
            show_unindexed = true,
            ignore_patterns = { "%.git/", "node_modules/" },
          },
        },
        extensions = {
          frecency = {
            show_scores = false,
            show_unindexed = true,
          }
        }
      })
      require("telescope").load_extension("frecency")
    end,
  },

  -- 🧩 LSP + DAP + Mason
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
      ensure_installed = { "clangd" },
      handlers = {
        -- 全局默认 handler
        function(server_name)
          require("lspconfig")[server_name].setup({ capabilities = capabilities })
        end,
        -- clangd 特定配置
        clangd = function()
          require("lspconfig").clangd.setup({
            capabilities = capabilities,
            cmd = { "clangd", "--background-index", "--header-insertion=iwyu", "--suggest-missing-includes"},
            init_options = {
              clangd = {
                hints = { parameters = true, deducedTypes = true }
              }
            }
          })
        end,
      },
    })
  end,
  }, 
  -- 💡 补全引擎
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "zbirenbaum/copilot-cmp",
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
          ["<C-e>"] = cmp.mapping.complete(),  -- 按 Ctrl+E 唤出补全菜单
          ["<C-@>"] = cmp.mapping(function()
            cmp.complete({ config = { sources = { { name = "copilot" } } } })
          end),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          { name = "copilot" , group_index = 2},
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

      if vim.fn.executable(codelldb_path) == 1 then
        dap.adapters.lldb = {
          type = "executable",
          command = codelldb_path,
          options = {
            env = {
              LD_LIBRARY_PATH = lldb_lib_path .. ":" .. (os.getenv("LD_LIBRARY_PATH") or ""),
            },
          },
        }
      else
        vim.notify("❌ codelldb not found at: " .. codelldb_path, vim.log.levels.ERROR)
      end

      require("dap.ext.vscode").load_launchjs()

      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end

    end,
    keys = {
      { "<F5>", "<cmd>lua require'dap'.continue()<cr>", desc = "Debug: Start/Continue" },
      { "<F10>", "<cmd>lua require'dap'.step_over()<cr>", desc = "Debug: Step Over" },
      { "<F11>", "<cmd>lua require'dap'.step_into()<cr>", desc = "Debug: Step Into" },
      { "<F12>", "<cmd>lua require'dap'.step_out()<cr>", desc = "Debug: Step Out" },
      { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = "Debug: Toggle Breakpoint" },
    },
  },

  -- 🐞 调试
  -- {
  --   "mfussenegger/nvim-dap",
  --   dependencies = {
  --     "rcarriga/nvim-dap-ui",
  --     "theHamsta/nvim-dap-virtual-text",
  --     "mxsdev/nvim-dap-vscode-js",
  --   },
  --   config = function()
  --     local dap = require("dap")
  --     local dapui = require("dapui")
  --     require("dap.ext.vscode").load_launchjs()
  --     dapui.setup()
  --     dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
  --
  --     dap.adapters.codelldb = {
  --       type = "server",
  --       port = "${port}",
  --       executable = { command = "codelldb", args = { "--port", "${port}" } },
  --     }
  --     dap.adapters.cpp = {
  --       type = "executable",
  --       command = "/usr/bin/gdb",  -- 或 "gdb"
  --       args = { "--interpreter=dap" },             -- 关键：启用 DAP 模式
  --     }
  --     dap.configurations.cpp = {
  --     }
  --     dap.configurations.c = dap.configurations.cpp
  --   end,
  --   keys = {
  --     { "<F5>", "<cmd>lua require'dap'.continue()<cr>", desc = "Debug: Start/Continue" },
  --     { "<F10>", "<cmd>lua require'dap'.step_over()<cr>", desc = "Debug: Step Over" },
  --     { "<F11>", "<cmd>lua require'dap'.step_into()<cr>", desc = "Debug: Step Into" },
  --     { "<F12>", "<cmd>lua require'dap'.step_out()<cr>", desc = "Debug: Step Out" },
  --     { "<leader>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = "Debug: Toggle Breakpoint" },
  --   },
  -- },
  --
  -- 🌲 Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "VeryLazy",
    config = function()
      require("nvim-treesitter.config").setup({
        ensure_installed = { "c", "cpp", "cmake", "bash"},
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
  event = "VeryLazy", -- 或 "BufRead"，按需触发
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

        -- Hunk 操作
        map("n", "<leader>gs", require("gitsigns").stage_hunk, "Stage hunk")
        map("n", "<leader>gr", require("gitsigns").reset_hunk, "Reset hunk")
        map("n", "<leader>gS", require("gitsigns").stage_buffer, "Stage buffer")
        map("n", "<leader>gR", require("gitsigns").reset_buffer, "Reset buffer")

        -- 预览
        map("n", "<leader>gp", require("gitsigns").preview_hunk, "Preview hunk")
        map("n", "<leader>gi", require("gitsigns").preview_hunk_inline, "Preview hunk inline")

        -- 导航（智能兼容 diff 模式）
        map("n", "]c", function()
          if vim.wo.diff then return vim.cmd.normal({ "]c", bang = true }) end
          require("gitsigns").nav_hunk("next")
        end, "Next hunk")
        map("n", "[c", function()
          if vim.wo.diff then return vim.cmd.normal({ "[c", bang = true }) end
          require("gitsigns").nav_hunk("prev")
        end, "Prev hunk")

        -- 文本对象
        map({ "o", "x" }, "ih", require("gitsigns").select_hunk, "Select inner hunk")
        map({ "o", "x" }, "ah", function()
          require("gitsigns").select_hunk({ include_headers = true })
        end, "Select a hunk")

        -- Quickfix
        map("n", "<leader>gq", require("gitsigns").setqflist, "Set quickfix list")
      end,

      -- 可选：启用行号高亮、符号列等（按需开启）
      signcolumn = true,  -- 在 sign column 显示 + ~ _
      numhl = false,      -- 是否高亮行号（绿色/红色）
      linehl = false,     -- 是否高亮整行背景
      word_diff = false,  -- 是否启用单词级差异
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
          disable_defaults = true, -- 👈 确保不禁用默认
          -- file_panel = {
          --   -- ✅ 使用 actions 函数，不是字符串！
          --   { "n", "s", actions.toggle_stage_entry, { desc = "Stage/Unstage hunk" } },
          --   { "n", "S", actions.stage_all,           { desc = "Stage all" } },
          --   { "n", "U", actions.unstage_all,         { desc = "Unstage all" } },
          --   { "n", "r", actions.restore_entry,       { desc = "Restore file" } },
          --   { "n", "q", actions.close,               { desc = "Close panel" } },
          -- },
          -- -- 如果你想在 diff 文件内容窗口也用 s/r，加到 view:
          -- view = {
          --   { "n", "s", actions.toggle_stage_entry, { desc = "Stage hunk (in view)" } },
          --   { "n", "r", actions.restore_entry,      { desc = "Revert hunk (in view)" } },
          -- }
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
  {
  "kkharji/sqlite.lua",
  -- 通常作为依赖自动加载，但如果你要显式使用，可以加 lazy = false
  -- lazy = false, -- 可选：立即加载（一般不需要）
  },
  {
  "LintaoAmons/bookmarks.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  event = "VeryLazy", -- 按需加载，启动时不立即加载
  config = function()
    require("bookmarks").setup({
      -- 可选：自定义符号（默认是 '●'）
      -- sign = "", -- 你可以用其他图标，比如 "🔖"、"📌"、"◆" 等
      sign = "🔖",
      -- 自定义高亮组（可选）
      hl = {
        name = "BookmarkSign", -- 用于 sign column 的高亮
        line = "CursorLine",   -- 书签行的高亮（可设为 nil 禁用）
      },
      -- 是否在跳转后自动居中
      center_on_jump = true,
      -- 是否记住书签（跨会话持久化）
      persist = true,
      -- 书签保存路径（默认在 stdpath("data") 下）
      -- data_dir = vim.fn.stdpath("data") .. "/bookmarks",
    })
  end,
},
-- 🔑 快捷键提示
{
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 300  -- 保持 300ms 响应速度
  end,
  config = function()
    local wk = require("which-key")
    wk.setup({
      -- 可选：增强视觉体验
      -- icons = { group = "", separator = "" },
      -- layout = { spacing = 4 },
    })

    -- ✅ 第一步：注册所有主分组（含新增的 window 分组）
    wk.register({
      c = { name = "+Code" },       -- LSP/代码操作
      g = { name = "+Git" },        -- Git 集成
      f = { name = "+Find" },       -- 模糊查找
      d = { name = "+Debug" },      -- 调试
      s = { name = "+Symbols" },    -- 符号导航
      a = { name = "+AI" },         -- AI 工具
      t = { name = "+Tabs" },       -- 标签页
      w = { name = "+Window" },     -- 窗口管理分组
      b = { name = "+Buffers" },    -- 缓冲区管理
      m = { name = "+bookmarks" },  -- mark管理
    }, { prefix = "<leader>" })

    wk.register({
      -- 核心操作
      ["<leader>q"] = { "<cmd>q<cr>", "Quit" },
      -- ["<leader>e"] = { "<cmd>NvimTreeToggle<cr>", "Toggle file tree" },
      ["<leader>e"] = { "<cmd>Neotree<cr>", "Toggle file tree" },

      ["<leader>ca"] = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action (Fix)" },
      ["<leader>cp"] = {
        function()
          vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("i", true, false, true), "n", false)
          require("cmp").complete()
        end,
        "Insert & trigger completion"
      },
      ["<leader>]d"] = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" },
      ["<leader>[d"] = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Prev Diagnostic" },
      
      -- ✅ 窗口管理（必须归属到 <leader>w 分组）
      ["<leader>wv"] = { "<C-w>v", "Split vertical" },
      ["<leader>ws"] = { "<C-w>s", "Split horizontal" },
      ["<leader>wc"] = { "<C-w>c", "Close window" },
      ["<leader>w="] = { "<C-w>=", "Equalize sizes" },
      
      -- 缓冲区管理
      ["<leader>bb"] = { "<cmd>Telescope buffers<cr>", "Switch buffer" },
      ["<leader>bd"] = { "<cmd>bd<cr>", "Close buffer" },

      -- ✅ Bookmarks 命令（归属到 <leader>m 分组）
      ["<leader>ma"] = { "<cmd>BookmarksAdd<cr>", "Add bookmark" },
      ["<leader>md"] = { "<cmd>BookmarksDelete<cr>", "Delete bookmark" },
      ["<leader>ml"] = { "<cmd>BookmarksList<cr>", "List bookmarks" },
      ["<leader>mn"] = { "<cmd>BookmarksNext<cr>", "Next bookmark" },
      ["<leader>mp"] = { "<cmd>BookmarksPrev<cr>", "Previous bookmark" },

      
      -- 保留原有符号/调试等命令
      ["<leader>sw"] = { "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>", "Workspace symbols" },
      ["<leader>sd"] = { "<cmd>lua vim.lsp.buf.document_symbol()<cr>", "Document symbols" },
      ["<leader>st"] = { "<cmd>Telescope lsp_document_symbols<cr>", "Doc symbols (TS)" },
      ["<leader>sT"] = { "<cmd>Telescope lsp_workspace_symbols<cr>", "Workspace symbols (TS)" },
      -- ["<leader>gd"] = { "<cmd>DiffviewOpen<cr>", "Git diff" },
      -- ["<leader>gh"] = { "<cmd>DiffviewFileHistory %<cr>", "File history" },
      -- ["<leader>gb"] = { "<cmd>GitBlameToggle<cr>", "Git blame" },
      ["<leader>ta"] = { "<cmd>ToggleTerm direction=float<cr>", "terminal" },
      ["<leader>tn"] = { "<cmd>tabnew<cr>", "New tab" },
      ["<leader>tc"] = { "<cmd>tabclose<cr>", "Close tab" },
      ["<leader>to"] = { "<cmd>tabonly<cr>", "Close other tabs" },
      ["<leader>t["] = { "<cmd>tabprevious<cr>", "Prev tab" },
      ["<leader>t]"] = { "<cmd>tabnext<cr>", "Next tab" },
g = {
  name = "+Git",
  s = { "<cmd>lua require('gitsigns').stage_hunk()<cr>", "Stage hunk" },
  r = { "<cmd>lua require('gitsigns').reset_hunk()<cr>", "Reset hunk" },
  S = { "<cmd>lua require('gitsigns').stage_buffer()<cr>", "Stage buffer" },
  R = { "<cmd>lua require('gitsigns').reset_buffer()<cr>", "Reset buffer" },
  p = { "<cmd>lua require('gitsigns').preview_hunk()<cr>", "Preview hunk" },
  i = { "<cmd>lua require('gitsigns').preview_hunk_inline()<cr>", "Preview inline" },
  q = { "<cmd>lua require('gitsigns').setqflist()<cr>", "Quickfix hunks" },
  d = { "<cmd>DiffviewOpen<cr>", "Diff view" },
  h = { "<cmd>DiffviewFileHistory %<cr>", "File history" },
  b = { "<cmd>GitBlameToggle<cr>", "Git blame" },
},

    })
  end,
},
}
