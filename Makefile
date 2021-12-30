nvim-treesitter:
	git clone https://github.com/nvim-treesitter/nvim-treesitter.git --depth=1

LUA_PATH := $(LUA_PATH):$(CURDIR)
test t: nvim-treesitter
	@echo $(CURDIR)
	vusted \
		--shuffle --lpath="./?.lua;./?/?.lua;./?/init.lua" \
		--helper=$(CURDIR)/spec/lua/conftest.lua
.PHONY: test t
