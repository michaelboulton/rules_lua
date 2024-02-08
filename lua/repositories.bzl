"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:git.bzl", "git_repository")
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("//lua/private:toolchains_repo.bzl", "PLATFORMS", "system_toolchains_repo", "toolchains_repo")
load("//lua/private:versions.bzl", "LUAJIT_VERSIONS", "LUA_VERSIONS")
load("//lua:toolchain.bzl", "lua_toolchain")

########
# Remaining content of the file is only used to support toolchains.
########
_DOC = "Fetch external tools needed for lua toolchain"
_ATTRS = {
    "platform": attr.string(mandatory = True, values = PLATFORMS.keys()),
}

def _lua_repo_impl(repository_ctx):
    build_content = """#Generated by lua/repositories.bzl
load("@rules_lua//lua:toolchain.bzl", "lua_toolchain")

lua_toolchain(
    name = "lua_toolchain",
    target_tool = "@lua_git//:lua",
    dev_files = ["@lua_git//:lua_make"],
)
"""

    # Base BUILD file for this repository
    repository_ctx.file("BUILD.bazel", build_content)

lua_repositories = repository_rule(
    _lua_repo_impl,
    doc = _DOC,
    attrs = _ATTRS,
)

# Wrapper macro around everything above, this is the primary API
def lua_register_toolchains(name = "lua", version = "v5.1.1", **kwargs):
    """Convenience macro for users which does typical setup.

    - create a repository for each built-in platform like "lua_linux_amd64" -
      this repository is lazily fetched when node is needed for that platform.
    - TODO: create a convenience repository for the host platform like "lua_host"
    - create a repository exposing toolchains for each platform like "lua_platforms"
    - register a toolchain pointing at each platform
    Users can avoid this macro and do these steps themselves, if they want more control.

    Args:
        name: base name for all created repos, like "lua1_14"
        **kwargs: passed to each node_repositories call
    """

    _lua_register_toolchains(name, version, **kwargs)

    for platform in PLATFORMS.keys():
        native.register_toolchains("@{}_toolchains//:{}_toolchain".format(name, platform))

def _lua_register_toolchains(name, version, **kwargs):
    if version not in LUA_VERSIONS:
        fail("Unknown lua version {}".format(version))

    git_repository(
        name = "lua_git",
        remote = "https://github.com/lua/lua.git",
        build_file = "@rules_lua//lua:lua.BUILD.bazel",
        patch_args = ["-p", "1"],
        **LUA_VERSIONS[version]
    )

    toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )

    for platform in PLATFORMS.keys():
        lua_repositories(
            name = name + "_" + platform,
            platform = platform,
            **kwargs
        )

# Wrapper macro around everything above, this is the primary API
def luajit_register_toolchains(name = "lua", version = "v2.1", **kwargs):
    """Convenience macro for users which does typical setup.

    - create a repository for each built-in platform like "lua_linux_amd64" -
      this repository is lazily fetched when node is needed for that platform.
    - TODO: create a convenience repository for the host platform like "lua_host"
    - create a repository exposing toolchains for each platform like "lua_platforms"
    - register a toolchain pointing at each platform
    Users can avoid this macro and do these steps themselves, if they want more control.

    Args:
        name: base name for all created repos, like "lua1_14"
        **kwargs: passed to each node_repositories call
    """

    _luajit_register_toolchains(name, version, **kwargs)

    for platform in PLATFORMS.keys():
        native.register_toolchains("@{}_toolchains//:{}_toolchain".format(name, platform))

def _luajit_register_toolchains(name = "lua", version = "v2.1", **kwargs):
    if version not in LUAJIT_VERSIONS:
        fail("Unknown luajit version {}".format(version))

    git_repository(
        name = "lua_git",
        shallow_since = "1664877857 +0200",
        patch_args = ["-p", "1"],
        remote = "https://github.com/LuaJIT/LuaJIT.git",
        build_file = "@rules_lua//lua:luajit.BUILD.bazel",
        **LUAJIT_VERSIONS[version]
    )

    for platform in PLATFORMS.keys():
        lua_repositories(
            name = name + "_" + platform,
            platform = platform,
            **kwargs
        )

    toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )

def _lua_system_repo_impl(repository_ctx):
    build_content = """#Generated by lua/repositories.bzl
load("@rules_lua//lua:toolchain.bzl", "lua_toolchain")

lua_toolchain(name = "lua_toolchain", target_tool_path = "{}")
""".format(repository_ctx.attr.target_tool_path)

    repository_ctx.file("BUILD.bazel", build_content)

lua_system_repositories = repository_rule(
    _lua_system_repo_impl,
    attrs = {
        "target_tool_path": attr.string(mandatory = True),
    },
)

def lua_register_system_toolchain(lua_path, name = "lua"):
    lua_system_repositories(name = name, target_tool_path = lua_path)
    native.register_toolchains("@{}_toolchains//:lua_toolchain".format(name))

    system_toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )

_lua_tag = tag_class(
    doc = "initialise lua toolchain",
    attrs = {
        "version": attr.string(
            default = "v5.1.1",
            doc = "version of SDK",
        ),
    },
)

_luajit_tag = tag_class(
    doc = "initialise luajit toolchain",
    attrs = {
        "version": attr.string(
            default = "v2.1",
            doc = "version of SDK",
        ),
    },
)

def _lua_toolchains_extension(mctx):
    for mod in mctx.modules:
        for lua in mod.tags.lua:
            name = "{}_lua_{}".format(mod.name, lua.version)
            _lua_register_toolchains(name, lua.version)
        for luajit in mod.tags.luajit:
            name = "luajit_{}".format(luajit.version)
            _luajit_register_toolchains(name, luajit.version)

lua_toolchains = module_extension(
    implementation = _lua_toolchains_extension,
    tag_classes = {
        "lua": _lua_tag,
        "luajit": _luajit_tag,
    },
)
