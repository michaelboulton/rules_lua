load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//lua:defs.bzl", _github_dependency = "github_dependency", _luarocks_dependency = "luarocks_dependency")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

# WARNING: any changes in this function may be BREAKING CHANGES for users
# because we'll fetch a dependency which may be different from one that
# they were previously fetching later in their WORKSPACE setup, and now
# ours took precedence. Such breakages are challenging for users, so any
# changes in this function should be marked as BREAKING in the commit message
# and released only in semver majors.
# This is all fixed by bzlmod, so we just tolerate it for now.
def rules_lua_dependencies():
    # The minimal version of bazel_skylib we require
    http_archive(
        name = "bazel_skylib",
        sha256 = "f7be3474d42aae265405a592bb7da8e171919d74c16f082a5457840f06054728",
        urls = [
            "https://github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
        ],
    )

    http_archive(
        name = "bazel_gazelle",
        sha256 = "de69a09dc70417580aabf20a28619bb3ef60d038470c7cf8442fafcf627c21cb",
        urls = [
            "https://mirror.bazel.build/github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
            "https://github.com/bazelbuild/bazel-gazelle/releases/download/v0.24.0/bazel-gazelle-v0.24.0.tar.gz",
        ],
    )

    http_archive(
        name = "aspect_bazel_lib",
        sha256 = "1cbbf62315d303c8083d5019a4657623d4f58e925fb51bdc8a41bad4a131f5c9",
        strip_prefix = "bazel-lib-1.8.1",
        url = "https://github.com/aspect-build/bazel-lib/archive/refs/tags/v1.8.1.tar.gz",
    )

    http_archive(
        name = "rules_foreign_cc",
        sha256 = "2a4d07cd64b0719b39a7c12218a3e507672b82a97b98c6a89d38565894cf7c51",
        strip_prefix = "rules_foreign_cc-0.9.0",
        url = "https://github.com/bazelbuild/rules_foreign_cc/archive/refs/tags/0.9.0.tar.gz",
    )

    http_archive(
        name = "luarocks",
        sha256 = "ffafd83b1c42aa38042166a59ac3b618c838ce4e63f4ace9d961a5679ef58253",
        urls = ["https://luarocks.org/releases/luarocks-3.9.1.tar.gz"],
        strip_prefix = "luarocks-3.9.1",
        build_file = "@com_github_michaelboulton_rules_lua//lua:luarocks.BUILD.bazel",
    )

def luarocks_dependency(name, **kwargs):
    maybe(_luarocks_dependency, name = name, **kwargs)

def github_dependency(name, **kwargs):
    maybe(_github_dependency, name = name, **kwargs)

def luaunit_test_dependencies():
    github_dependency(
        name = "lua_luaunit",
        dependency = "luaunit",
        tag = "LUAUNIT_V3_4",
        user = "bluebird75",
        version = "3.4-1",
    )

def busted_test_dependencies():
    luarocks_dependency(
        name = "lua_busted",
        dependency = "busted",
        sha256 = "251a848525c743b3ead74d77a125551946fc57ddd20441109d2c9ed912d8ccd4",
        user = "lunarmodules",
        version = "2.1.1-1",
        deps = [
            "@lua_penlight",
            "@lua_term",
            "@lua_luasystem",
            "@lua_mediator",
            "@lua_say",
            "@lua_dkjson",
            "@lua_lua_cliargs",
            "@lua_luassert",
            "@lua_ansicolors",
        ],
    )

    luarocks_dependency(
        name = "lua_penlight",
        sha256 = "fa028f7057cad49cdb84acdd9fe362f090734329ceca8cc6abb2d95d43b91835",
        dependency = "penlight",
        user = "tieske",
        version = "1.13.1-1",
        deps = ["@lua_luafilesystem"],
    )

    luarocks_dependency(
        name = "lua_luafilesystem",
        dependency = "luafilesystem",
        sha256 = "576270a55752894254c2cba0d49d73595d37ec4ea8a75e557fdae7aff80e19cf",
        user = "hisham",
        version = "1.8.0-1",
    )

    luarocks_dependency(
        name = "lua_luasystem",
        dependency = "luasystem",
        sha256 = "d1c706d48efc7279d33f5ea123acb4d27e2ee93e364bedbe07f2c9c8d0ad3d24",
        user = "olim",
        version = "0.2.1-0",
    )

    luarocks_dependency(
        name = "lua_lua_cliargs",
        sha256 = "3c79981292aab72dbfba9eb5c006bb37c5f42ee73d7062b15fdd840c00b70d63",
        dependency = "lua_cliargs",
        user = "amireh",
        version = "3.0-2",
    )

    luarocks_dependency(
        name = "lua_say",
        dependency = "say",
        user = "lunarmodules",
        version = "1.4.1-3",
        sha256 = "90a1c0253ec38d6628007eef0b424d0707d0f3e0442fce478a627111eb02bb07",
    )

    luarocks_dependency(
        name = "lua_luassert",
        sha256 = "146a7b2ec8e0cadf7dbca6dc993debcd2090e0e4fdf5c632d9f4ec20670357dd",
        dependency = "luassert",
        user = "lunarmodules",
        version = "1.9.0-1",
    )

    luarocks_dependency(
        name = "lua_ansicolors",
        sha256 = "df6126501af3b9b944019164a08aed91377d82e6845c24432769140f12c815d6",
        dependency = "ansicolors",
        user = "kikito",
        version = "1.0.2-3",
    )

    luarocks_dependency(
        name = "lua_dkjson",
        dependency = "dkjson",
        sha256 = "e4ba15f2a85f84ffc7f628157a4ad16b2b04ba05eb44a2e5956fa46bd104125e",
        user = "dhkolf",
        version = "2.6-1",
    )

    github_dependency(
        name = "lua_term",
        dependency = "lua-term",
        tag = "0.07",
        user = "hoelzro",
        version = "0.7-1",
    )

    github_dependency(
        name = "lua_mediator",
        dependency = "mediator_lua",
        tag = "v1.1.2-0",
        user = "Olivine-Labs",
        version = "1.1.2-0",
    )
