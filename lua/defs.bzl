"Public API re-exports"

load("//lua/private:lua_binary.bzl", _lua_binary = "lua_binary")
load("//lua/private:lua_library.bzl", _lua_library = "lua_library")
load(
    "//lua/private:lua_dependency.bzl",
    _github_dependency = "github_dependency",
    _lua_dependency = "lua_dependency",
    _luarocks_dependency = "luarocks_dependency",
    _luarocks_library = "luarocks_library",
)

lua_binary = _lua_binary
lua_library = _lua_library
luarocks_dependency = _luarocks_dependency
luarocks_library = _luarocks_library
github_dependency = _github_dependency
lua_dependency = _lua_dependency
