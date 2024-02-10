load("@rules_lua//lua:providers.bzl", "LuaLibrary")
load("@rules_lua//lua/private:lua_binary.bzl", "BASH_RLOCATION_FUNCTION")
load("@rules_lua//fennel/private:fennel_library.bzl", "compile_fennel", FENNEL_ATTRS = "COMMON_ATTRS")
load("@aspect_bazel_lib//lib:paths.bzl", "to_rlocation_path")

def luaunit_test_impl(ctx, srcs):
    out_executable = ctx.actions.declare_file(ctx.attr.name + "_test")

    ctx.actions.write(
        out_executable,
        BASH_RLOCATION_FUNCTION + """
set -e
export TEST_FILES={srcs}
$(rlocation {runner}) $@
            """.format(
            runner = to_rlocation_path(ctx, ctx.file._runner),
            srcs = ",".join([to_rlocation_path(ctx, i) for i in srcs]),
        ),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = srcs + ctx.files._runner + ctx.files.deps + ctx.files.data)

    # propagate dependencies
    dep_runfiles = [t[DefaultInfo].default_runfiles for t in [r for r in ctx.attr.deps + [ctx.attr._runner]]]
    runfiles = runfiles.merge_all(dep_runfiles)
    runfiles = runfiles.merge(ctx.attr._runfiles_lib[DefaultInfo].default_runfiles)

    default = DefaultInfo(
        executable = out_executable,
        runfiles = runfiles,
    )

    return [
        default,
    ]

def _luaunit_test_impl(ctx):
    return luaunit_test_impl(ctx, ctx.files.srcs)

_luaunit_attrs = {
    "data": attr.label_list(
        doc = "extra files to be available at runtime",
        allow_files = True,
    ),
    "_runfiles_lib": attr.label(
        default = "@bazel_tools//tools/bash/runfiles",
    ),
    "_runner": attr.label(
        allow_single_file = True,
        default = "//:luaunit_runner_fennel",
    ),
}

luaunit_test = rule(
    implementation = _luaunit_test_impl,
    test = True,
    attrs = dict({
        "deps": attr.label_list(
            doc = "runtime dependencies for test",
            providers = [LuaLibrary],
        ),
        "srcs": attr.label_list(
            doc = "test sources",
            mandatory = True,
            allow_files = True,
        ),
    }, **_luaunit_attrs),
)

def _fennel_luaunit_test_impl(ctx):
    # Do this to ensure fennel is valid, and to get the runfiles in a nice format
    # We don't use the defaultinfo
    _, lua_provider, _, runfiles = compile_fennel(
        ctx,
        ctx.files.srcs,
    )

    return luaunit_test_impl(ctx, lua_provider.lua_files)

# FIXME: HACK: https://github.com/bazelbuild/starlark/issues/178
_fennel_test_attrs = dict(**_luaunit_attrs)
_fennel_test_attrs.update(**FENNEL_ATTRS)

_fennel_luaunit_test = rule(
    test = True,
    implementation = _fennel_luaunit_test_impl,
    attrs = _fennel_test_attrs,
    doc = "fennel luaunit test",
    toolchains = [
        "@rules_lua//fennel:toolchain_type",
        "@rules_lua//lua:toolchain_type",
    ],
)

def fennel_luaunit_test(deps = [], **kwargs):
    deps = deps  #+ ["@lua_luaunit"]
    _fennel_luaunit_test(deps = deps, **kwargs)
