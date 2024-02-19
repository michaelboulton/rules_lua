load("@aspect_bazel_lib//lib:paths.bzl", "to_rlocation_path")
load("@rules_lua//lua:defs.bzl", "BASH_RLOCATION_FUNCTION")
load("@rules_lua//lua:providers.bzl", "LuaLibrary")

def busted_test_impl(ctx, srcs):
    out_executable = ctx.actions.declare_file(ctx.attr.name + "_test")

    ctx.actions.write(
        out_executable,
        BASH_RLOCATION_FUNCTION + """
set -e
$(rlocation {runner}) \
    --verbose \
    -Xoutput --color --output=utfTerminal \
    $(rlocation {srcs}) $@
            """.format(
            runner = to_rlocation_path(ctx, ctx.file._busted),
            srcs = " ".join([to_rlocation_path(ctx, i) for i in srcs]),
        ),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = srcs + ctx.files._busted + ctx.files.deps + ctx.files.data)

    # propagate dependencies
    dep_runfiles = [t[DefaultInfo].default_runfiles for t in [r for r in ctx.attr.deps + [ctx.attr._busted]]]
    runfiles = runfiles.merge_all(dep_runfiles)
    runfiles = runfiles.merge(ctx.attr._runfiles_lib[DefaultInfo].default_runfiles)

    default = DefaultInfo(
        executable = out_executable,
        runfiles = runfiles,
    )

    return [
        default,
    ]

def _busted_test_impl(ctx):
    return busted_test_impl(ctx, ctx.files.srcs)

busted_test = rule(
    implementation = _busted_test_impl,
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
            allow_files = True,
            mandatory = True,
        ),
        "_runfiles_lib": attr.label(
            default = "@bazel_tools//tools/bash/runfiles",
        ),
        "_busted": attr.label(
            allow_single_file = True,
            cfg = "exec",
            executable = True,
            default = "@lua_busted//:busted_bin",
        ),
    },
)
