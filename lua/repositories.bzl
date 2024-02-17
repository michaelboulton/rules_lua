"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")
load("//lua/private:toolchains_repo.bzl", "PLATFORMS", "system_toolchains_repo", "toolchains_repo")
load("//lua/private:versions.bzl", "LUAJIT_VERSIONS", "LUA_VERSIONS")
load("//lua:toolchain.bzl", "lua_toolchain")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

########
# Remaining content of the file is only used to support toolchains.
########

def _lua_repo_impl(repository_ctx):
    build_content = """#Generated by lua/repositories.bzl
load("@rules_lua//lua:toolchain.bzl", "lua_toolchain")

lua_toolchain(
    name = "lua_toolchain",
    target_tool = "@{lua_repository_name}//:lua",
    dev_files = ["@{lua_repository_name}//:lua_make"],
)
""".format(
        lua_repository_name = repository_ctx.attr.lua_repository_name,
    )

    # Base BUILD file for this repository
    repository_ctx.file("BUILD.bazel", build_content)

lua_repositories = repository_rule(
    _lua_repo_impl,
    doc = "Fetch external tools needed for lua toolchain",
    attrs = {
        "platform": attr.string(
            mandatory = True,
            values = PLATFORMS.keys(),
        ),
        "lua_repository_name": attr.string(
            mandatory = True,
        ),
    },
)

def _lua_register_toolchains(name, version, lua_repository_name, **kwargs):
    toolchains_repo_name = name + "_toolchains"
    for platform in PLATFORMS.keys():
        lua_repositories(
            lua_repository_name = lua_repository_name,
            name = name + "_" + platform,
            platform = platform,
            **kwargs
        )

    toolchains_repo(
        name = toolchains_repo_name,
        user_repository_name = name,
    )

def _luajit_register_toolchains(name, version, luajit_repository_name, **kwargs):
    toolchains_repo_name = name + "_toolchains"
    for platform in PLATFORMS.keys():
        lua_repositories(
            name = name + "_" + platform,
            platform = platform,
            lua_repository_name = luajit_repository_name,
            **kwargs
        )

    toolchains_repo(
        name = toolchains_repo_name,
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

    system_toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )

_lua_tag = tag_class(
    doc = "initialise lua toolchain",
    attrs = {
        "name": attr.string(
            default = "lua",
            doc = "register toolchain repo with this name",
        ),
        "version": attr.string(
            default = "v5.1.1",
            values = LUA_VERSIONS.keys(),
            doc = "version of lua SDK",
        ),
    },
)

_luajit_tag = tag_class(
    doc = "initialise luajit toolchain",
    attrs = {
        "name": attr.string(
            default = "luajit",
            doc = "register toolchain repo with this name",
        ),
        "version": attr.string(
            default = "v2.1",
            values = LUAJIT_VERSIONS.keys(),
            doc = "version of luajit SDK",
        ),
    },
)

def _lua_toolchains_extension(mctx):
    def _verify_toolchain_name(mod, expected, name):
        if name != expected and not mod.is_root:
            fail("""\
            Only the root module may override the default name for the {} toolchains.
            This prevents conflicting registrations in the global namespace of external repos.
            """.format(expected))

    lua_versions = {}
    luajit_versions = {}
    for mod in mctx.modules:
        for lua in mod.tags.lua:
            _verify_toolchain_name(mod, "lua", lua.name)
            lua_versions[lua.version] = None
        for luajit in mod.tags.luajit:
            _verify_toolchain_name(mod, "luajit", luajit.name)
            luajit_versions[luajit.version] = None

    for luajit_version in luajit_versions:
        luajit_repository_name = "luajit_src_{version}".format(version = luajit_version)

        http_archive(
            name = luajit_repository_name,
            patch_args = ["-p", "1"],
            **LUAJIT_VERSIONS[luajit_version]
        )

        _verify_toolchain_name(mod, "luajit", luajit.name)

        _luajit_register_toolchains(luajit.name, luajit.version, luajit_repository_name)

    for lua_version in lua_versions:
        lua_repository_name = "lua_src_{version}".format(version = lua_version)

        http_archive(
            name = lua_repository_name,
            patch_args = ["-p", "1"],
            **LUA_VERSIONS[lua_version]
        )

        _lua_register_toolchains(lua.name, lua.version, lua_repository_name)

lua_toolchains = module_extension(
    implementation = _lua_toolchains_extension,
    tag_classes = {
        "lua": _lua_tag,
        "luajit": _luajit_tag,
    },
)
