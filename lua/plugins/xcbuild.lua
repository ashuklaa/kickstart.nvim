-- Utility: run xcodebuild asynchronously and stream output
local function run_xcodebuild()
	local cmd = {
		"xcodebuild",
		"-workspace",
		"FinGuardian.xcodeproj/project.xcworkspace",
		"-scheme",
		"FinGuardian",
		"-destination",
		"platform=iOS Simulator,name=iPhone 17 Pro",
		"build",
	}

	-- Open a split window for build logs
	vim.cmd("botright 15split | enew")
	local buf = vim.api.nvim_get_current_buf()
	vim.bo[buf].buftype = "nofile"
	vim.bo[buf].bufhidden = "wipe"
	vim.bo[buf].swapfile = false

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Running xcodebuild..." })

	local append = function(_, data)
		if data then
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
		end
	end

	-- async job
	vim.fn.jobstart(cmd, {
		stdout_buffered = false,
		stderr_buffered = false,
		on_stdout = append,
		on_stderr = append,
		on_exit = function(_, code)
			vim.api.nvim_buf_set_lines(buf, -1, -1, false, {
				"",
				"---------------------------------------",
				"xcodebuild finished with exit code: " .. code,
			})
			-- Optional: restart LSP afterwards
			vim.cmd("LspRestart")
		end,
	})
end

-- Create a :XcodeBuild command
vim.api.nvim_create_user_command("XcodeBuild", run_xcodebuild, {})

-- <leader>xb mapping
vim.keymap.set("n", "<leader>xb", ":XcodeBuild<CR>", {
	noremap = true,
	silent = true,
	desc = "Build using xcodebuild",
})
return {
	{
		"wojciech-kulik/xcodebuild.nvim",
		dependencies = {
			-- Uncomment a picker that you want to use, snacks.nvim might be additionally
			-- useful to show previews and failing snapshots.

			-- You must select at least one:
			"nvim-telescope/telescope.nvim",

			"MunifTanjim/nui.nvim",
			"stevearc/oil.nvim", -- (optional) to manage project files
			"nvim-treesitter/nvim-treesitter", -- (optional) for Quick tests support (required Swift parser)
		},
		opts = {},
	},
}
