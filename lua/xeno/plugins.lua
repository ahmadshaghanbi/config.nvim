-- Completely disable netrw, useless piece of crap
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1

local packer = require "packer"

packer.init({
	git = {
		clone_timeout = 500
	}
})

packer.startup(function(use)
	use {
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		config = function()
			local neotree = require "neo-tree"
			neotree.setup {
				popup_border_style = "rounded",
				filesystem = {
					use_libuv_file_watcher = true,
					follow_current_file = {
						enabled = true,
						leave_dirs_open = false,
					},
				},
				buffers = {
					follow_current_file = {
						enabled = true, -- This will find and focus the file in the active buffer every time
						--							-- the current file is changed while the tree is open.
						leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
					},
				},
				respect_gitignore = true
			}

			vim.keymap.set('n', '<C-e>', "<CMD>Neotree toggle<CR>", { noremap = true, silent = true })
		end
	}

	use {
		"iamcco/markdown-preview.nvim",
		run = "cd app && npm install",
		setup = function()
			vim.g.mkdp_filetypes = { "markdown", "plaintext" }
		end,
		ft = "markdown"
	}

	use {
		"numToStr/FTerm.nvim",
		config = function()
			local fterm = require "FTerm"
			local cfg = {
				border = "double",
				dimensions = {
					height = 0.9,
					width = 0.9
				},
				blend = 10
			}

			local terms = { fterm:new(cfg) }
			local visible_terminal = nil
			local active_terminal  = terms[0]

			local getterm = function(n)
				if terms[n] == nil then
					terms[n] = fterm:new(cfg)
				end

				return terms[n]
			end

			local showterm = function(n)
				if visible_terminal ~= nil then
					visible_terminal:close()
					visible_terminal = nil
				end

				local term = getterm(n)
				visible_terminal = term
				active_terminal = term
				term:open()
			end

			local hideterm = function()
				if visible_terminal ~= nil then
					visible_terminal:close()
					active_terminal = visible_terminal
					visible_terminal = nil
				end
			end

			vim.api.nvim_create_user_command("FTermOpen", function(opts)
				local n = 0
				if opts ~= nil and opts.count > 0 then n = opts.count end
				showterm(n)
			end, { count = 0 })

			vim.api.nvim_create_user_command("FTermHide", hideterm, { })

			vim.api.nvim_create_user_command("FTermKill", function(opts)
				if opts == nil or opts.count == 0 then
					if active_terminal ~= nil then
						active_terminal:close(true)
					end
				else
					if terms[opts.count] ~= nil then terms[opts.count].close(true) end
				end
			end, { count = 0 })

			vim.api.nvim_create_user_command("FTermToggle", function(opts)
				if visible_terminal ~= nil then
					hideterm()
				end

				local n = 0
				if opts ~= nil and opts.count > 0 then n = opts.count end
				showterm(n)
			end, { count = 0 })

			vim.keymap.set('n', '<C-t>', function() getterm(0):toggle() end, { noremap = true, silent = true })
			vim.keymap.set('t', '<C-t>', function() getterm(0):toggle() end, { noremap = true, silent = true })
		end
	}

	use {
		"windwp/nvim-autopairs",
		config = function()
			require "nvim-autopairs".setup {}
		end
	}

	use {
		"VDuchauffour/neodark.nvim",
		config = function()
			vim.cmd "color neodarker"
		end
	}

	use {
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons", opt = true },
		config = function()
			require "lualine".setup {
				theme = "palenight"
			}
		end
	}

	use {
		"akinsho/bufferline.nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
		tag = "v4.*",
		config = function()
			require "bufferline".setup {
				options = {
					diagnostics = "nvim_lsp",
					numbers = "buffer_id",
					separator_style = "slant",
					indicator = {
						style = "underline"
					},
					offsets = {
						{
							filetype = "neo-tree",
							text = "File Explorer",
							text_align = "left",
							separator = true
						}
					},
					hover = {
						enabled = true,
						delay = 200,
						reveal = { 'close' }
					},
				}
			}
			vim.opt.laststatus = 3
		end
	}

	-- To trim trailing spaces on save
	use {
		"cappyzawa/trim.nvim",
		config = function()
			require('trim').setup {
				ft_blocklist = { "markdown" },

				-- if you want to ignore space of top
				patterns = {
					[[%s/\s\+$//e]],
					[[%s/\($\n\s*\)\+\%$//]],
					[[%s/\(\n\n\)\n\+/\1/]],
				},
			}
		end
	}

	-- TODO: Fix telescope
	use {
		"nvim-telescope/telescope.nvim",
		tag = "0.1.*",
		requires = {
			"nvim-lua/plenary.nvim",
		},
		config = function()
			vim.keymap.set('n', "<C-P>", ":Telescope find_files<CR>", { noremap = true, silent = true })
			vim.keymap.set('i', "<C-P>", "<esc>:Telescope find_files<CR>", { noremap = true, silent = true })
			vim.keymap.set('n', "<C-;>", "<esc>:Telescope grep_string<CR>", { noremap = true, silent = true })
			vim.keymap.set('i', "<C-;>", "<esc>:Telescope grep_string<CR>", { noremap = true, silent = true })
		end
	}

	use {
		"nvim-telescope/telescope-fzf-native.nvim",
		run = "make"
	}

	use {
		"nvim-treesitter/nvim-treesitter",
		tag = "v0.9.*",
		run = function()
			require("nvim-treesitter.install").update { with_sync = true }
		end,
		config = function()
			require "nvim-treesitter.configs".setup {
				ensure_installed = {
					"bash", --
					"c",
					"comment", --
					"cpp", --
					"css", --
					-- "disassembly", --
					"diff", --
					"glsl", --
					"html", --
					"hjson", --
					"javascript",
					"json",
					"json5", --
					"jsonc", --
					"latex", --
					"lua",
					"luadoc", --
					"make", --
					"markdown",
					"markdown_inline",
					"ninja", --
					"php", --
					"phpdoc", --
					-- "printf", --
					"python", --
					"regex", --
					"requirements", --
					"rust",
					"sql",
					-- "ssh-config", --
					"toml", --
					"typescript",
					"vim", --
					"vimdoc", --
					"wgsl", --
					"yaml", --
				},
				sync_install = false,
				auto_install = false,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = {
					enable = true
				},
				incremental_selection = {
					enable = true
				},
				-- BEGIN
				ignore_install = {},
				modules = {},
				update_strategy = ""
				-- END
			}

			vim.opt.foldmethod = "expr"
			vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
			vim.opt.foldenable = false
		end
	}

	use {
		"neovim/nvim-lspconfig",
		requires = {
			'hrsh7th/nvim-cmp',
			'hrsh7th/cmp-nvim-lsp',
			'hrsh7th/cmp-nvim-lsp-signature-help',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-path',
			'saadparwaiz1/cmp_luasnip',
			{ "L3MON4D3/LuaSnip", tag = "v2.3.0" },
			"b0o/SchemaStore.nvim",
			"jose-elias-alvarez/typescript.nvim"
		},
		config = function()
			local servers = {
				bashls        = {},
				clangd        = {},
				cmake         = {},
				emmet_language_server = {
					filetypes = { "css", "eruby", "html", "javascript", "javascriptreact", "less", "sass", "scss", "svelte", "pug", "typescriptreact", "vue" },
					init_options = {
						html = {
							options = {
								-- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
								["bem.enabled"] = true,
								["output.selfClosingStyle"] = "xhtml"
							},
						},
					}
				},
				eslint        = {},
				html          = {},
				jsonls        = {
					settings = {
						json = {
							schemas = require("schemastore").json.schemas(),
							validate = { enable = true }
						}
					}
				},
				phpactor      = {},
				pylsp         = {},
				rust_analyzer = {},
				-- I use lua only for nvim config, and this is the recommended config
				lua_ls        = {
					settings = {
						Lua = {
							runtime = {
								-- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
								version = "LuaJIT",
							},
							diagnostics = {
								-- Get the language server to recognize the `vim` global
								globals = { "vim" },
							},
							workspace = {
								-- Make the server aware of Neovim runtime files
								library = vim.api.nvim_get_runtime_file("", true),
							},
							-- Do NOT send telemetry data containing a randomized but unique identifier
							telemetry = {
								enable = false,
							},
						},
					}
				},
			}

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
			capabilities.textDocument.completion.completionItem.snippetSupport = true

			local on_attach = function(_, bufnr)
				-- Enable completion triggered by <c-x><c-o>
				vim.api.nvim_buf_set_option(bufnr, "omnifunc", "v:lua.vim.lsp.omnifunc")

				-- Mappings.
				-- See `:help vim.lsp.*` for documentation on any of the below functions
				local bufopts = { noremap = true, silent = true, buffer = bufnr }
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, bufopts)
				vim.keymap.set("n", "gD", vim.lsp.buf.declaration, bufopts)
				vim.keymap.set("n", "K", vim.lsp.buf.hover, bufopts)
				vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
				vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
				vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, bufopts)
				vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
				vim.keymap.set("n", "<space>wl", function()
					print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
				end, bufopts)
				vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, bufopts)
				vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
				vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, bufopts)
				vim.keymap.set("n", "gr", vim.lsp.buf.references, bufopts)
				--vim.keymap.set("n", "<space>f", vim.lsp.buf.formatting, bufopts)
			end

			for language, options in pairs(servers) do
				local conf = nil
				if next(options) == nil then
					conf = {
						on_attach = on_attach,
						settings = {},
						capabilities = capabilities
					}
				else
					local attach = options.on_attach or on_attach
					local settings = options.settings or {}
					local filetypes = options.filetypes
					local cap = options.capabilities or capabilities

					conf = { on_attach = attach, settings = settings, capabilities = cap }

					if filetypes then
						conf.filetypes = filetypes
					end
				end

				require("lspconfig")[language].setup(conf)
			end

			require("typescript").setup({
					-- prevent the plugin from creating Vim commands
					disable_commands = false,
					debug = false,
					go_to_source_definition = {
							fallback = true, -- fall back to standard LSP definition on failure
					},
					server = {
						on_attach = on_attach,
						settings = {},
						capabilities = capabilities
					},
			})
			local luasnip = require("luasnip")
			local cmp = require("cmp")
			cmp.setup {
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered()
				},
				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs( -4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					-- ['<C-Space>'] = cmp.mapping.complete(),
					['<CR>'] = cmp.mapping.confirm {
						-- behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					},
					['<Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
						elseif luasnip.expand_or_jumpable() then
							luasnip.expand_or_jump()
						else
							fallback()
						end
					end, { 'i', 's' }),
					['<S-Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif luasnip.jumpable( -1) then
							luasnip.jump( -1)
						else
							fallback()
						end
					end, { 'i', 's' }),
				}),
				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
				}, { { name = 'buffer' } }),
			}
		end
	}

	use {
		"tpope/vim-dadbod",
		requires = {
			"kristijanhusak/vim-dadbod-ui",
			"kristijanhusak/vim-dadbod-completion"
		},
		config = function()
				vim.api.nvim_create_autocmd("FileType", {
					pattern = {"sql", "mysql", "plsql"},
					callback = function() require("cmp").setup.buffer({ sources = {{ name = "vim-dadbod-completion" }} }) end
				})
				-- vim.cmd [[
				-- 	autocmd FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion'  } })
				-- ]]
		end
	}
end)
-- vim: ts=2 sw=2 noet
