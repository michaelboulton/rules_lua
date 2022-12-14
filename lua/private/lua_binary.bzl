load("//lua:providers.bzl", "LuaLibrary")

# Looks for lua dependencies for a lua binary (incl. tests!) and sets the lua path appropriately
hack_get_lua_path = """
set -e

export LUA_PATH="?;?.lua;?/init.lua"

if [ ! -z "$TEST_BINARY" ]; then
    test_binary_dir=$(dirname $TEST_BINARY)
    export LUA_PATH="$LUA_PATH;$test_binary_dir/?.lua"
fi

export LUA_PATH="$LUA_PATH;$(realpath ..)/?.lua"
export LUA_PATH="$LUA_PATH;$(realpath ..)/?/?.lua"
export LUA_PATH="$LUA_PATH;$(realpath ..)/?/init.lua"

if ls -d ../lua* 2>/dev/null ; then
    for d in $(ls -d ../lua*/lua*); do
        d=$(realpath $d)
        # FIXME get lua version
        export LUA_PATH="$LUA_PATH;$d/lib/lua/5.1/?.lua"
        export LUA_CPATH="$LUA_CPATH;$d/lib/lua/5.1/?.so"
        export LUA_PATH="$LUA_PATH;$d/share/lua/5.1/?.lua"
        export LUA_PATH="$LUA_PATH;$d/share/lua/5.1/?/init.lua"
    done
fi
"""

def _lua_binary_impl(ctx):
    out_executable = ctx.actions.declare_file(ctx.attr.name + "_exec")

    lua_toolchain = ctx.toolchains["//lua:toolchain_type"].lua_info

    ctx.actions.write(
        out_executable,
        (hack_get_lua_path + """
        set -e
        {lua} {src} {args} $@
        """).format(
            lua = lua_toolchain.tool_files[0].short_path,
            lua_long = lua_toolchain.tool_files[0].path,
            src = ctx.file.tool.short_path,
            deps = [i.short_path for i in ctx.files.deps],
            args = " ".join(ctx.attr.args),
        ),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = ctx.files.deps + ctx.files.data + ctx.files.tool)

    # propagate dependencies
    dep_runfiles = [t[DefaultInfo].default_runfiles for t in [r for r in ctx.attr.deps]]
    runfiles = runfiles.merge_all(dep_runfiles)

    default = DefaultInfo(
        files = depset(lua_toolchain.tool_files + ctx.files.tool),
        executable = out_executable,
        runfiles = runfiles,
    )

    return [
        default,
    ]

lua_binary = rule(
    implementation = _lua_binary_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [LuaLibrary],
            doc = "Runtime lua dependencies of target",
        ),
        "data": attr.label_list(
            doc = "extra files to be available at runtime",
            allow_files = True,
        ),
        "tool": attr.label(
            doc = "lua file to run",
            allow_single_file = True,
            mandatory = True,
        ),
    },
    doc = "Lua binary target. Will run the given tool with the registered lua toolchain.",
    toolchains = [
        "//lua:toolchain_type",
    ],
    executable = True,
)
