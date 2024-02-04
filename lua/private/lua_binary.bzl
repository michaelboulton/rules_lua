load("//lua:providers.bzl", "LuaLibrary")
load("@bazel_skylib//lib:paths.bzl", "paths")

# Bash helper function for looking up runfiles.
# See windows_utils.bzl for the cmd.exe equivalent.
# Vendored from
# https://github.com/bazelbuild/bazel/blob/master/tools/bash/runfiles/runfiles.bash
BASH_RLOCATION_FUNCTION = r"""
# --- begin runfiles.bash initialization v2 ---
set -uo pipefail; f=bazel_tools/tools/bash/runfiles/runfiles.bash
source "${RUNFILES_DIR:-/dev/null}/$f" 2>/dev/null || \
source "$(grep -sm1 "^$f " "${RUNFILES_MANIFEST_FILE:-/dev/null}" | cut -f2- -d' ')" 2>/dev/null || \
source "$0.runfiles/$f" 2>/dev/null || \
source "$(grep -sm1 "^$f " "$0.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
source "$(grep -sm1 "^$f " "$0.exe.runfiles_manifest" | cut -f2- -d' ')" 2>/dev/null || \
{ echo>&2 "ERROR: cannot find $f"; exit 1; }; f=; set -e
# --- end runfiles.bash initialization v2 ---
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

def _lua_path_for_deps(ctx):
    """Set up a dir with symlinks to lua deps"""
    return """
mkdir _%NAME%_deps

while read p; do
  split=(${p//,/ })
  ln -s $(pwd)/$(rlocation)/${split[0]} _%NAME%_deps/${split[1]}
done < <(cat $(rlocation _repo_mapping) | grep rules_lua | grep -v toolchain)

export LUA_PATH="$LUA_PATH;_%NAME%_deps/?.lua"
export LUA_PATH="$LUA_PATH;_%NAME%_deps/?/?.lua"
export LUA_PATH="$LUA_PATH;_%NAME%_deps/?/init.lua"
""".replace("%NAME%", ctx.attr.name)

def _lua_binary_impl(ctx):
    out_executable = ctx.actions.declare_file(ctx.attr.name + "_exec")

    lua_toolchain = ctx.toolchains["//lua:toolchain_type"].lua_info

    lua_path = lua_toolchain.target_tool[DefaultInfo].files_to_run.executable.short_path

    def _to_rloc_file(file):
        if file.short_path.startswith("../"):
            return file.short_path[3:]
        else:
            return ctx.workspace_name + "/" + file.short_path

    ctx.actions.write(
        out_executable,
        BASH_RLOCATION_FUNCTION + hack_get_lua_path + _lua_path_for_deps(ctx) + """
$(rlocation {lua_rloc}) $(rlocation {tool}) {args} $@
        """.format(
            lua_rloc = _to_rloc_file(lua_toolchain.target_tool[DefaultInfo].files_to_run.executable),
            lua = lua_path,
            tool = _to_rloc_file(ctx.file.tool),
            deps = [i.short_path for i in ctx.files.deps],
            args = " ".join(ctx.attr.args),
        ),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = ctx.files.deps + ctx.files.data + ctx.files.tool + lua_toolchain.tool_files + ctx.files._runfiles_lib)

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
            default = "@bazel_tools//tools/bash/runfiles",
        ),
    },
    doc = "Lua binary target. Will run the given tool with the registered lua toolchain.",
    toolchains = [
        "//lua:toolchain_type",
    ],
    executable = True,
)
