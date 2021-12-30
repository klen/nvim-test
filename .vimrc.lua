require("nvim-test.runners.busted"):setup {
  command = "vusted",
  args = " --helper=spec/lua/conftest.lua",
}
