load("//lua:providers.bzl", "LuaLibrary")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@aspect_bazel_lib//lib:paths.bzl", "to_rlocation_path", _default_location_function = "BASH_RLOCATION_FUNCTION")

# Bash helper function for looking up runfiles.
# See windows_utils.bzl for the cmd.exe equivalent.
# Vendored from
# https://github.com/bazelbuild/bazel/blob/master/tools/bash/runfiles/runfiles.bash
BASH_RLOCATION_FUNCTION = _default_location_function + r"""
function alocation {
  local P=$1
  if [[ "${P:0:1}" == "/" ]]; then
    echo "${P}"
  else
    echo "${PWD}/${P}"
  fi
}
"""

# Looks for lua dependencies for a lua binary (incl. tests!) and sets the lua path appropriately
hack_get_lua_path = """
set -e
set +u

export LUA_PATH="?;?.lua;?/init.lua"

if [ ! -z "$TEST_BINARY" ]; then
    test_binary_dir=$(dirname $TEST_BINARY)
    export LUA_PATH="$LUA_PATH;$test_binary_dir/?.lua"
fi

#export LUA_PATH="$LUA_PATH;$(realpath ..)/?.lua"
#export LUA_PATH="$LUA_PATH;$(realpath ..)/?/?.lua"
#export LUA_PATH="$LUA_PATH;$(realpath ..)/?/init.lua"

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
    lua_executable = lua_toolchain.target_tool[DefaultInfo].files_to_run.executable

    ctx.actions.write(
        out_executable,
        BASH_RLOCATION_FUNCTION + """
set -e
set +u
export LUA_PATH="$LUA_PATH;$(alocation $(dirname $(rlocation {wrapper})))/?.lua"
$(rlocation {lua_rloc}) -l binary_wrapper $(rlocation {tool}) $@
        """.format(
            lua_rloc = to_rlocation_path(ctx, lua_executable),
            tool = to_rlocation_path(ctx, ctx.file.tool),
            deps = [i.short_path for i in ctx.files.deps],
            wrapper = to_rlocation_path(ctx, ctx.file._wrapper),
        ),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = ctx.files.deps + ctx.files._wrapper + ctx.files.data + ctx.files.tool + lua_toolchain.tool_files + ctx.files._runfiles_lib)

    # propagate dependencies
    dep_runfiles = [t[DefaultInfo].default_runfiles for t in [r for r in ctx.attr.deps]]
    runfiles = runfiles.merge_all(dep_runfiles)
    runfiles = runfiles.merge(ctx.attr._runfiles_lib[DefaultInfo].default_runfiles)

    default = DefaultInfo(
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
        "_runfiles_lib": attr.label(
            allow_files = True,
            default = "@bazel_tools//tools/bash/runfiles",
        ),
        "_wrapper": attr.label(
            allow_single_file = True,
            default = "@rules_lua//lua/private:binary_wrapper.lua",
        ),
    },
    doc = "Lua binary target. Will run the given tool with the registered lua toolchain.",
    toolchains = [
        "//lua:toolchain_type",
    ],
    executable = True,
)
