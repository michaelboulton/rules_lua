"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
LUA_VERSIONS = {
    "v5.4.6": dict(
        sha256 = "d8f590bce037218157fc6b135f3830f37db127d71fa1969e1eff6cef82fe1887",
        urls = ["https://github.com/lua/lua/archive/refs/tags/v5.4.6.zip"],
        strip_prefix = "lua-v5.4.6",
        patches = ["@rules_lua//lua:0001-Add-install-target-v5.4.6.patch"],
    ),
    "v5.1.1": dict(
        sha256 = "a9f313dfd5599f7389fe2382689a64be48d07a2a7fcde9e699afb9aa2bfd8cc7",
        urls = ["https://github.com/lua/lua/archive/refs/tags/v5.1.1.zip"],
        strip_prefix = "lua-v5.1.1",
        patches = ["@rules_lua//lua:0001-Add-install-target-v5.1.1.patch"],
    ),
}

LUAJIT_VERSIONS = {
    "v2.1": dict(
        patches = ["@rules_lua//lua:0001-Install-luajit-as-lua-as-well.patch"],
    ),
}
