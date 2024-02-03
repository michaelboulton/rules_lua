load("@rules_lua//lua:providers.bzl", "LuaLibrary")
load("@rules_lua//private:lua_binary.bzl", "hack_get_lua_path")

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
    toolchains = ["@com_github_michaelboulton_rules_lua//lua:toolchain_type"],
)
