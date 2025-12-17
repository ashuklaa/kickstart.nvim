return {
	{
		"neovim/nvim-lspconfig",
		dependencies = { { "saghen/blink.cmp" } },
		config = function()
			local capabilities = require("blink.cmp").get_lsp_capabilities()

			-- Make sure workspace table exists
			capabilities.workspace = capabilities.workspace or {}
			-- And the didChangeWatchedFiles subtable
			capabilities.workspace.didChangeWatchedFiles =
				vim.tbl_deep_extend("force", capabilities.workspace.didChangeWatchedFiles or {}, {
					dynamicRegistration = true,
				})
			vim.lsp.config("sourcekit", {
				capabilities = capabilities,
				root_dir = function(_, callback)
					callback(
						require("lspconfig.util").root_pattern("Package.swift")(vim.fn.getcwd())
							or require("lspconfig.util").find_git_ancestor(vim.fn.getcwd())
					)
				end,
				cmd = {
					vim.trim(vim.fn.system("xcrun -f sourcekit-lsp")),
				},
				filetypes = { "swift" },
				root_markers = { "Package.swift", ".git", ".xcodeproj" },
			})

			vim.lsp.enable({
				"lua_ls",
				"gopls",
				"gleam",
				"eslint",
				"ts_ls",
				"pylsp",
				"sourcekit",
				"emmet_language_server",
				"tailwindcss",
			})

			vim.lsp.config.ts_ls = {
				filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
				on_attach = function(client, bufnr)
					client.server_capabilities.documentFormattingProvider = false
				end,
			}
		end,
	},
	{
		"stevearc/conform.nvim",
		opts = {
			formatters_by_ft = {
				lua = { "stylua", "lua_ls" },
				javascript = { "prettierd", "prettier", "eslint", stop_after_first = true },
				typescript = { "prettierd", "prettier", "eslint", stop_after_first = true },
				javascriptreact = { "prettierd", "prettier", "eslint", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", "eslint", stop_after_first = true },
				python = { "autopep8" },
				swift = { "swiftformat" },
			},

			format_on_save = {
				lsp_format = "fallback",
				timeout_ms = 500,
			},
			log_level = vim.log.levels.ERROR,
			notify_on_error = true,
			notify_no_formatters = true,
		},
	},
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			require("nvim-treesitter.configs").setup({
				auto_install = true,
				highlight = { enable = true },
				indent = { enable = true },
				ensure_installed = {
					"lua",
					"go",
					"vim",
					"vimdoc",
					"bash",
					"python",
					"javascript",
					"typescript",
					"swift",
				},
			})
		end,
	},
}
