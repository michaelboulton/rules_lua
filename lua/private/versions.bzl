"""Mirror of release info

TODO: generate this file from GitHub API"""

# The integrity hashes can be computed with
# shasum -b -a 384 [downloaded file] | awk '{ print $1 }' | xxd -r -p | base64
LUA_VERSIONS = {
    "v5.4.4": dict(
        commit = "5d708c3f9cae12820e415d4f89c9eacbe2ab964b",
        shallow_since = "1642072503 -0300",
        patches = ["@com_github_michaelboulton_rules_lua//lua:0001-Add-install-target.patch"],
    ),
    "v5.1.1": dict(
        commit = "98194db4295726069137d13b8d24fca8cbf892b6",
        shallow_since = "1149874274 -0300",
        patches = ["@com_github_michaelboulton_rules_lua//lua:0001-Add-install-target-v5.1.1.patch"],
    ),
}

LUAJIT_VERSIONS = {
    "v2.1": dict(
        commit = "6c4826f12c4d33b8b978004bc681eb1eef2be977",
        patches = ["@com_github_michaelboulton_rules_lua//lua:0001-Install-luajit-as-lua-as-well.patch"],
    ),
}
