load("//lua:providers.bzl", "LuaLibrary")
load("//fennel:providers.bzl", "FennelLibrary")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("//lua/private:lua_binary.bzl", "BASH_RLOCATION_FUNCTION")

def lua_name_from_fnl(f):
    #return paths.replace_extension(f.short_path, ".lua")
    return paths.join(paths.dirname(f.short_path.replace(f.dirname + "/", "")), paths.replace_extension(f.basename, ".lua"))

def preprocessed_name_from_fnl(f):
    #    return paths.join(f.short_path.replace(f.root.path, ""), paths.replace_extension(f.basename, ".p.fnl"))
    return paths.join(paths.dirname(f.short_path.replace(f.dirname + "/", "")), paths.replace_extension(f.basename, ".p.fnl"))

def compile_fennel(ctx, fennel_files, strip_prefix = ""):
    if strip_prefix:
        stripped_files = []
        for file in fennel_files:
            suffix_removed = strip_prefix.removesuffix("/")
            slash_replaced = file.short_path.replace(suffix_removed + "/", "")
            stripped_files.append(ctx.actions.declare_file(slash_replaced))

        for src, dest in zip(ctx.files.srcs, stripped_files):
            ctx.actions.symlink(output = dest, target_file = src)

        fennel_files = stripped_files

    lua_outputs = {lua_name_from_fnl(f): ctx.actions.declare_file(lua_name_from_fnl(f)) for f in fennel_files}
    preprocessed_outputs = {preprocessed_name_from_fnl(f): ctx.actions.declare_file(preprocessed_name_from_fnl(f)) for f in fennel_files}
    #fail(lua_outputs)

    expected_outputs = dict()
    expected_outputs.update(**lua_outputs)
    expected_outputs.update(**preprocessed_outputs)

    lua_toolchain = ctx.toolchains["//lua:toolchain_type"].lua_info
    fennel_toolchain = ctx.toolchains["//fennel:toolchain_type"].fennel_info

    fennel_executable = fennel_toolchain.target_tool[DefaultInfo].files_to_run.executable

    for f in fennel_files:
        lua_output = lua_outputs[lua_name_from_fnl(f)]
        preprocessed_output = preprocessed_outputs[preprocessed_name_from_fnl(f)]

        if ctx.file.preprocessor:
            ctx.actions.run(
                outputs = [preprocessed_output],
                inputs = [f],
                executable = ctx.file.preprocessor,
                arguments = [f.path, preprocessed_output.path],
                progress_message = "preprocessing %{input}",
            )
        else:
            ctx.actions.symlink(
                output = preprocessed_output,
                target_file = f,
            )

        ctx.actions.run_shell(
            outputs = [lua_output],
            inputs = [f, preprocessed_output] +
                     fennel_files +
                     fennel_toolchain.tool_files +
                     lua_toolchain.tool_files +
                     ctx.files.macros,
            progress_message = "compiling %{input}",
            command = """
            set -e

            extra_macro_paths=""
            for m in {macro_paths}; do
                extra_macro_paths="$extra_macro_paths --add-macro-path $(dirname $m)/?.fnl"
                extra_macro_paths="$extra_macro_paths --add-macro-path $(dirname $(dirname $m))/?.fnl"
            done

            {fennel} \
                $extra_macro_paths \
                --compile \
                {preprocessed_output} > {lua_output}

            # Hack for aniseed
            sed -i -e '/ANISEED_DELETE_ME/d' {lua_output}
            """.format(
                fennel = fennel_executable.path,
                preprocessed_output = preprocessed_output.path,
                lua_output = lua_output.path,
                macro_paths = " ".join([m.path for m in ctx.files.macros]),
            ),
            tools = [fennel_executable],
        )

    # propagate dependencies
    runfiles = ctx.runfiles(ctx.files.deps)
    dep_runfiles = [t[DefaultInfo].default_runfiles for t in [r for r in ctx.attr.deps]]
    runfiles = runfiles.merge_all(dep_runfiles)

    lua_provider = LuaLibrary(
        lua_files = lua_outputs.values(),
    )

    fennel_provider = FennelLibrary(
        fennel_files = preprocessed_outputs.values(),
        macro_paths = ctx.files.macros,
    )

    default_provider = DefaultInfo(
        files = depset(expected_outputs.values()),
        runfiles = runfiles,
    )

    return default_provider, lua_provider, fennel_provider, runfiles

def _fennel_library_impl(ctx):
    default_provider, lua_provider, fennel_provider, _ = compile_fennel(
        ctx,
        ctx.files.srcs,
        ctx.attr.strip_prefix,
    )

    return [
        default_provider,
        lua_provider,
        fennel_provider,
    ]

COMMON_ATTRS = {
    "deps": attr.label_list(
        doc = "fennel deps",
        providers = [[LuaLibrary], [FennelLibrary]],
    ),
    "srcs": attr.label_list(
        doc = "fennel srcs",
        mandatory = True,
        allow_files = True,
    ),
    "macros": attr.label_list(
        doc = "fennel macros required for compilation, but will not be compiled into the library and left as .fnl files",
        allow_files = True,
    ),
    "preprocessor": attr.label(
        doc = "Processes fennel files into a format suitable for passing to the fennel compiler without any extra magic flags that need passing",
        allow_single_file = True,
    ),
}

_LIBRARY_RULE_ARGS = {
    "implementation": _fennel_library_impl,
    "attrs": dict(
        strip_prefix = attr.string(
            doc = "Strip prefix from files before compiling",
        ),
        **COMMON_ATTRS
    ),
    "toolchains": [
        "//fennel:toolchain_type",
        "//lua:toolchain_type",
    ],
}

fennel_library = rule(
    doc = "Library of fennel, compiled all src files into one big lua file",
    **_LIBRARY_RULE_ARGS
)

_aniseed_library = rule(
    doc = "Fennel library with aniseed 'module' semantics",
    **_LIBRARY_RULE_ARGS
)

def aniseed_library(macros = [], **kwargs):
    _aniseed_library(
        macros = macros + ["@aniseed//:aniseed_macros"],
        preprocessor = "@rules_lua//fennel/private:aniseed_preprocessor.sh",
        **kwargs
    )
