load("//lua:providers.bzl", "LuaLibrary")
load("//lua/private:lua_tests.bzl", "busted_test_impl", "luaunit_test_impl")
load("//lua/private:lua_binary.bzl", "hack_get_lua_path")
load("@bazel_skylib//lib:paths.bzl", "paths")
load(":fennel_library.bzl", "COMMON_ATTRS", "compile_fennel")

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
            default = "@lua_luaunit",
        ),
        data = attr.label_list(
            doc = "extra files required to build the luarocks library",
            allow_files = True,
        ),
        **COMMON_ATTRS
    ),
    doc = "fennel luaunit test",
    toolchains = [
        "//fennel:toolchain_type",
        "//lua:toolchain_type",
    ],
)

def fennel_luaunit_test(deps = [], **kwargs):
    deps = deps + ["@lua_luaunit"]
    _fennel_luaunit_test(deps = deps, **kwargs)

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
        preprocessor = "@com_github_michaelboulton_rules_lua//fennel/private:aniseed_preprocessor.sh",
        **kwargs
    )

def _fennel_busted_test_impl(ctx):
    _, lua_provider, fennel_provider, runfiles = compile_fennel(
        ctx,
        ctx.files.srcs,
    )

    fennel_toolchain = ctx.toolchains["//fennel:toolchain_type"].fennel_info

    if ctx.attr.standalone:
        get_macro_prefix = """
        FENNEL_MACRO_PATH=""
        FENNEL_MACRO_PATH="$FENNEL_MACRO_PATH;./?.fnl;./?/init-macros.fnl;./?/init.fnl"
        FENNEL_MACRO_PATH="$FENNEL_MACRO_PATH;./external/?.fnl;./external/?/init-macros.fnl;./external/?/init.fnl"
        for m in {macro_paths}; do
            FENNEL_MACRO_PATH="$FENNEL_MACRO_PATH;$(dirname $(dirname $m))/?.fnl;$(dirname $m)/?.fnl;$(dirname $m)/?/init.fnl;$(dirname $m)/?/init-macros.fnl"
        done
        """.format(
            macro_paths = " ".join([m.short_path for m in ctx.files.macros]),
        )

        fennel_runner = get_macro_prefix + """
        for s in {src}; do
            {lua} <(cat << EOF
local fennel = require("fennel")
fennel["macro-path"] = "$FENNEL_MACRO_PATH"
debug.traceback = fennel.traceback;
fennel.install().dofile('$s');
EOF
) \
                --verbose \
                -Xoutput --color --output=utfTerminal \
                $@
        done
        """

        runfiles = runfiles.merge(ctx.runfiles(fennel_toolchain.tool_files + ctx.files.macros))

        return busted_test_impl(ctx, fennel_provider.fennel_files, fennel_runner, runfiles)
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

        return busted_test_impl(ctx, lua_provider.lua_files, lua_runner, runfiles)

_fennel_busted_test = rule(
    test = True,
    implementation = _fennel_busted_test_impl,
    attrs = dict(
        data = attr.label_list(
            allow_files = True,
        ),
        standalone = attr.bool(
            doc = "Whether this is a 'standalone' test or a normal test that sould be called with the busted cli",
            default = False,
        ),
        _busted = attr.label(
            allow_files = True,
            default = "@lua_busted//:lua_busted",
        ),
        **COMMON_ATTRS
    ),
    doc = "Fennel busted test",
    toolchains = [
        "//fennel:toolchain_type",
        "//lua:toolchain_type",
    ],
)

def fennel_busted_test(deps = [], **kwargs):
    deps = deps + ["@aniseed"]
    _fennel_busted_test(deps = deps, **kwargs)
