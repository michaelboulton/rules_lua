load("@rules_lua//lua:providers.bzl", "LuaLibrary")
load("@rules_lua//lua/private:lua_binary.bzl", "hack_get_lua_path")
load("@rules_lua//fennel/private:fennel_library.bzl", "COMMON_ATTRS", "compile_fennel")

def luaunit_test_impl(ctx, srcs):
    lua_toolchain = ctx.toolchains["//lua:toolchain_type"].lua_info

    out_executable = ctx.actions.declare_file(ctx.attr.name + "_test")
    ctx.actions.write(
        out_executable,
        (hack_get_lua_path + """
        set -e

        {lua} {src} $@
        """).format(
            lua = lua_toolchain.tool_files[0].short_path,
            src = " ".join([i.short_path for i in srcs]),
        ),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = srcs + ctx.files.deps + lua_toolchain.tool_files + ctx.files.data)

    # propagate dependencies
    dep_runfiles = [t[DefaultInfo].default_runfiles for t in [r for r in ctx.attr.deps + [ctx.attr._luaunit]]]
    runfiles = runfiles.merge_all(dep_runfiles)

    default = DefaultInfo(
        executable = out_executable,
        runfiles = runfiles,
    )

    return [
        default,
    ]

def _luaunit_test_impl(ctx):
    return luaunit_test_impl(ctx, ctx.files.srcs)

luaunit_test = rule(
    implementation = _luaunit_test_impl,
    test = True,
    attrs = {
        "deps": attr.label_list(
            doc = "runtime dependencies for test",
            providers = [LuaLibrary],
        ),
        "data": attr.label_list(
            doc = "extra files to be available at runtime",
            allow_files = True,
        ),
        "srcs": attr.label_list(
            doc = "test sources",
            mandatory = True,
            allow_files = True,
        ),
        "_luaunit": attr.label(
            #            default = "@lua_luaunit",
        ),
    },
    toolchains = ["@rules_lua//lua:toolchain_type"],
)

def _fennel_luaunit_test_impl(ctx):
    # Do this to ensure fennel is valid, and to get the runfiles in a nice format
    # We don't use the defaultinfo
    _, lua_provider, _, runfiles = compile_fennel(
        ctx,
        ctx.files.srcs,
    )

    return luaunit_test_impl(ctx, lua_provider.lua_files)

_fennel_luaunit_test = rule(
    test = True,
    implementation = _fennel_luaunit_test_impl,
    attrs = dict(
        _luaunit = attr.label(
            #            default = "@lua_luaunit",
        ),
        data = attr.label_list(
            doc = "extra files required to build the luarocks library",
            allow_files = True,
        ),
        **COMMON_ATTRS
    ),
    doc = "fennel luaunit test",
    toolchains = [
        "@rules_lua//fennel:toolchain_type",
        "@rules_lua//lua:toolchain_type",
    ],
)

def fennel_luaunit_test(deps = [], **kwargs):
    deps = deps  #+ ["@lua_luaunit"]
    _fennel_luaunit_test(deps = deps, **kwargs)
