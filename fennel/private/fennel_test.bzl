load("//lua:providers.bzl", "LuaLibrary")
load("//lua/private:lua_binary.bzl", "hack_get_lua_path")
load(":fennel_library.bzl", "COMMON_ATTRS", "compile_fennel")

def _aniseed_test_impl(ctx):
    _, lua_provider, _, runfiles = compile_fennel(
        ctx,
        ctx.files.srcs,
    )

    lua_toolchain = ctx.toolchains["//lua:toolchain_type"].lua_info
    fennel_toolchain = ctx.toolchains["//fennel:toolchain_type"].fennel_info

    out_executable = ctx.actions.declare_file(ctx.attr.name + "_test")

    ctx.actions.write(
        out_executable,
        (hack_get_lua_path + """
        for s in {src}; do
            base=$s
            base=${{base/.lua/}}
            base=${{base/.fnl/}}
            modname=${{base//\\//.}}

            {lua} -l $modname -- {wrapper} {args}
        done
        """).format(
            lua = lua_toolchain.tool_files[0].short_path,
            fennel = fennel_toolchain.tool_files[0].short_path,
            src = " ".join([i.short_path for i in lua_provider.lua_files]),
            wrapper = ctx.file._wrapper.short_path,
            args = " ".join(ctx.attr.args),
        ),
        is_executable = True,
    )

    test_extra_runfiles = ctx.runfiles(ctx.files.data + ctx.files._wrapper + lua_toolchain.tool_files + lua_provider.lua_files)
    runfiles = runfiles.merge(test_extra_runfiles)

    default = DefaultInfo(
        executable = out_executable,
        runfiles = runfiles,
    )

    return [
        default,
    ]

_aniseed_test = rule(
    test = True,
    implementation = _aniseed_test_impl,
    attrs = dict(
        data = attr.label_list(
            allow_files = True,
        ),
        _wrapper = attr.label(
            allow_single_file = True,
            default = "//fennel/private:init_aniseed_tests.lua",
        ),
        **COMMON_ATTRS
    ),
    doc = "Test using aniseed.test",
    toolchains = [
        "//fennel:toolchain_type",
        "//lua:toolchain_type",
    ],
)

def aniseed_test(deps = [], macros = [], **kwargs):
    deps = deps + ["@aniseed"]
    _aniseed_test(
        deps = deps,
        macros = macros + ["@aniseed//:aniseed_macros"],
        preprocessor = "@rules_lua//fennel/private:aniseed_preprocessor.sh",
        **kwargs
    )
