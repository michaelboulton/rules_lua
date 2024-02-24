load("//lua/private:lua_binary.bzl", "BASH_RLOCATION_FUNCTION")
load("//lua:providers.bzl", "LuaLibrary")
load("//fennel:providers.bzl", "FennelLibrary")
load("@aspect_bazel_lib//lib:paths.bzl", "to_rlocation_path")

def _fennel_binary_impl(ctx):
    out_executable = ctx.actions.declare_file(ctx.attr.name + "_exec")

    lua_toolchain = ctx.toolchains["//lua:toolchain_type"].lua_info
    lua_executable = lua_toolchain.target_tool[DefaultInfo].files_to_run.executable

    fennel_toolchain = ctx.toolchains["//fennel:toolchain_type"].fennel_info
    fennel_executable = fennel_toolchain.target_tool[DefaultInfo].files_to_run.executable

    ctx.actions.write(
        out_executable,
        BASH_RLOCATION_FUNCTION + """
set -e
set +u
export LUA_PATH="$LUA_PATH;$(alocation $(dirname $(rlocation {wrapper})))/?.lua"
$(rlocation {lua_rloc}) -l binary_wrapper $(rlocation {fennel_rloc}) $(rlocation {tool}) $@
        """.format(
            lua_rloc = to_rlocation_path(ctx, lua_executable),
            fennel_rloc = to_rlocation_path(ctx, fennel_executable),
            tool = to_rlocation_path(ctx, ctx.file.tool),
            deps = [i.short_path for i in ctx.files.deps],
            wrapper = to_rlocation_path(ctx, ctx.file._wrapper),
        ),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = ctx.files.deps + ctx.files._wrapper + ctx.files.data + ctx.files.tool + fennel_toolchain.tool_files + lua_toolchain.tool_files + ctx.files._runfiles_lib)

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

fennel_binary = rule(
    implementation = _fennel_binary_impl,
    attrs = {
        "deps": attr.label_list(
            providers = [[LuaLibrary], [FennelLibrary]],
            doc = "Runtime dependencies of target",
        ),
        "data": attr.label_list(
            doc = "extra files to be available at runtime",
            allow_files = True,
        ),
        "tool": attr.label(
            doc = "fennel file to run",
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
    doc = "Fennel binary target. Will run the given tool with the registered fennel toolchain.",
    toolchains = [
        "//lua:toolchain_type",
        "//fennel:toolchain_type",
    ],
    executable = True,
)
