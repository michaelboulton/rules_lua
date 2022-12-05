load("//lua:providers.bzl", "LuaLibrary")

hack_get_lua_path = """
set -e

test_binary_dir=$(dirname $TEST_BINARY)
export LUA_PATH="?;?.lua;$test_binary_dir/?.lua"

export LUA_PATH="$LUA_PATH;$(realpath ..)/?/?.lua"
export LUA_PATH="$LUA_PATH;$(realpath ..)/?/init.lua"

for d in $(ls -d ../lua*/lua*); do
    d=$(realpath $d)
    # FIXME get lua version
    export LUA_PATH="$LUA_PATH;$d/lib/lua/5.1/?.lua"
    export LUA_CPATH="$LUA_CPATH;$d/lib/lua/5.1/?.so"
    export LUA_PATH="$LUA_PATH;$d/share/lua/5.1/?.lua"
    export LUA_PATH="$LUA_PATH;$d/share/lua/5.1/?/init.lua"
done
"""

def _luaunit_test_impl(ctx):
    lua_toolchain = ctx.toolchains["//lua:toolchain_type"].lua_info

    out_executable = ctx.actions.declare_file(ctx.attr.name + "_test")
    ctx.actions.write(
        out_executable,
        """
        set -e
        {lua} {src} $@
        """.format(
            lua = lua_toolchain.tool_files[0].short_path,
            src = " ".join([i.short_path for i in ctx.files.srcs]),
        ),
        is_executable = True,
    )

    default = DefaultInfo(
        executable = out_executable,
        runfiles = ctx.runfiles(ctx.files.srcs + ctx.files.deps, transitive_files = depset(lua_toolchain.tool_files)),
    )

    return [
        default,
    ]

luaunit_test = rule(
    implementation = _luaunit_test_impl,
    test = True,
    attrs = {
        "deps": attr.label_list(
            doc = "runtime dependencies for test",
            providers = [LuaLibrary],
        ),
        "srcs": attr.label_list(
            doc = "test sources",
            mandatory = True,
        ),
        "_luaunit": attr.label(
            default = "@lua_luaunit",
        ),
    },
)

def busted_test_impl(ctx, lua_files, busted_run, extra_runfiles = None):
    lua_toolchain = ctx.toolchains["//lua:toolchain_type"].lua_info
    out_executable = ctx.actions.declare_file(ctx.attr.name + "_test")

    ctx.actions.write(
        out_executable,
        (hack_get_lua_path + busted_run).format(
            lua = lua_toolchain.tool_files[0].short_path,
            src = " ".join([i.short_path for i in lua_files]),
            busted_dir = ctx.files._busted[0].short_path,
        ),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = ctx.files.deps + ctx.files._busted + lua_files + lua_toolchain.tool_files + ctx.files.data)

    # propagate dependencies
    dep_runfiles = [t[DefaultInfo].default_runfiles for t in [r for r in ctx.attr.deps + [ctx.attr._busted]]]
    runfiles = runfiles.merge_all(dep_runfiles)
    runfiles = runfiles.merge(extra_runfiles)

    default = DefaultInfo(
        executable = out_executable,
        runfiles = runfiles,
    )

    return [
        default,
    ]

def _busted_test_impl(ctx):
    if ctx.attr.standalone:
        lua_runner = """
        for s in {src}; do
            base=$s
            base=$(basename $s)
            base=${{base/.lua/}}
            modname=${{base//\\//.}}

            {lua} -- $s \
                --verbose \
                -Xoutput --color --output=utfTerminal \
                $@
        done
        """
    else:
        lua_runner = """
        for s in {src}; do
            base=$s
            base=$(basename $s)
            base=${{base/.lua/}}
            modname=${{base//\\//.}}

            {lua} -- {busted_dir}/bin/busted . \
                --verbose \
                -Xoutput --color --output=utfTerminal \
                --pattern $modname $@
        done
        """

    return busted_test_impl(ctx, ctx.files.srcs, lua_runner)

busted_test = rule(
    implementation = _busted_test_impl,
    test = True,
    attrs = {
        "deps": attr.label_list(
            doc = "runtime dependencies for test",
            providers = [LuaLibrary],
        ),
        "standalone": attr.bool(
            doc = "Whether this is a 'standalone' test or a normal test that sould be called with the busted cli",
            default = False,
        ),
        "srcs": attr.label_list(
            doc = "test sources",
            mandatory = True,
        ),
        "_busted": attr.label(
            allow_files = True,
            default = "@lua_busted//:lua_busted",
        ),
    },
)
