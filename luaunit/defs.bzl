load("@rules_lua//lua:providers.bzl", "LuaLibrary")
load("@rules_lua//lua/private:lua_binary.bzl", "BASH_RLOCATION_FUNCTION", "hack_get_lua_path")
load("@rules_lua//fennel/private:fennel_library.bzl", "COMMON_ATTRS", "compile_fennel")

def luaunit_test_impl(ctx, srcs):
    out_executable = ctx.actions.declare_file(ctx.attr.name + "_test")

    lua_toolchain = ctx.toolchains["@rules_lua//lua:toolchain_type"].lua_info

    lua_path = lua_toolchain.target_tool[DefaultInfo].files_to_run.executable.short_path

    def _to_rloc_file(file):
        if file.short_path.startswith("../"):
            return file.short_path[3:]
        else:
            return ctx.workspace_name + "/" + file.short_path

        #    ctx.actions.expand_template(
        #        template = ctx.file._wrapper,
        #        output = out_executable,
        #        is_executable = True,
        #        substitutions = {
        #            "--[[LUA_PATH]]--": "#!{}".format(lua_toolchain.target_tool[DefaultInfo].files_to_run.executable.short_path),
        #            "--[[RUN]]--": ",".join(['"{}"'.format(_to_rloc_file(i)) for i in srcs]),
        #        },
        #    )

    ctx.actions.write(
        out_executable,
        BASH_RLOCATION_FUNCTION + hack_get_lua_path + """
preload=$(mktemp XXXXXX).lua
cat $(rlocation {wrapper}) > $preload
export LUA_PATH="$LUA_PATH;/tmp/?"

$(rlocation {lua_rloc}) -l $(basename ${{preload/.lua/}}) $(rlocation {srcs}) $@
            """.format(
            lua_rloc = _to_rloc_file(lua_toolchain.target_tool[DefaultInfo].files_to_run.executable),
            wrapper = _to_rloc_file(ctx.file._wrapper),
            srcs = " ".join([_to_rloc_file(i) for i in srcs]),
        ),
        is_executable = True,
    )

    runfiles = ctx.runfiles(files = srcs + ctx.files._wrapper + ctx.files._luaunit + ctx.files.deps + lua_toolchain.tool_files + ctx.files.data)

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
            default = "@lua_luaunit",
        ),
        "_runfiles_lib": attr.label(
            default = "@bazel_tools//tools/bash/runfiles",
        ),
        "_wrapper": attr.label(
            allow_single_file = True,
            default = "@rules_lua//lua/private:binary_wrapper.tmpl.lua",
        ),
    },
    toolchains = ["@rules_lua//lua:toolchain_type"],
)

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
            #            default = "@lua_luaunit",
        ),
        data = attr.label_list(
            doc = "extra files required to build the luarocks library",
            allow_files = True,
        ),
        **COMMON_ATTRS
    ),
    doc = "fennel luaunit test",
    toolchains = [
        "@rules_lua//fennel:toolchain_type",
        "@rules_lua//lua:toolchain_type",
    ],
)

def fennel_luaunit_test(deps = [], **kwargs):
    deps = deps  #+ ["@lua_luaunit"]
    _fennel_luaunit_test(deps = deps, **kwargs)
