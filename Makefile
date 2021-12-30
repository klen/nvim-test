nvim-treesitter:
	git clone https://github.com/nvim-treesitter/nvim-treesitter.git --depth=1

.PHONY: test t
test t: nvim-treesitter
	vusted -C $(CURDIR)
