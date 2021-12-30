nvim-treesitter:
	git clone https://github.com/nvim-treesitter/nvim-treesitter.git --depth=1

test t: nvim-treesitter
	echo $(CURDIR)
	vusted --shuffle
.PHONY: test t
