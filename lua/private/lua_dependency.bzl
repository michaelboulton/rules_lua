load("//lua:providers.bzl", "LuaLibrary")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")

GITHUB_TEMPLATE = "https://github.com/{user}/{dependency}/archive/refs/tags/{tag}.tar.gz"
GITHUB_PREFIX_TEMPLATE = "{dependency}-{short_tag}"

def _shorten_name(cacnonical_name):
    return cacnonical_name.split("~")[-1]

def _download_rockspec(
        rctx,
        url,
        fmt_vars,
        external_dependency_strip_template,
        out_binaries = [],
        deps = [],
        sha256 = "",
        rockspec_path = None):
    if url.endswith(".rockspec"):
        rctx.download(
            url,
            sha256 = sha256,
        )
    else:
        rctx.download_and_extract(
            url,
            sha256 = sha256,
            stripPrefix = external_dependency_strip_template.format(**fmt_vars),
        )

    rockspec_path = rockspec_path or "{dependency}-{version}.rockspec".format(**fmt_vars)

    build_content = """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all_files",
    srcs = glob(["**/*"], exclude=["**/* *"]),
)

load("@rules_lua//lua:defs.bzl", "luarocks_library", "lua_binary")

luarocks_library(
    name = "{name}",
    srcrock = "{rockspec_path}",
    deps = {deps},
    data = [":all_files"],
    extra_cflags = [{extra_cflags}],
    out_binaries = [{out_binaries}],
)

alias(
    name = "{short_name}",
    actual = "{name}",
)
""".format(
        deps = str([str(i) for i in deps]),
        out_binaries = ", ".join(['"{}"'.format(c) for c in out_binaries]),
        rockspec_path = rockspec_path,
        **fmt_vars
    )

    out_binary_content = """

filegroup(
    name = "{bin_name}_bin_group",
    srcs = ["{name}"],
    output_group = "{bin_name}",
)

genrule(
    name = "{bin_name}_bin_gen",
    srcs = [":{bin_name}_bin_group"],
    outs = ["{bin_name}_bin"],
    cmd = "cat $< > $@",
    visibility = ["//visibility:public"],
)
    """

    for bin_name in out_binaries:
        build_content += out_binary_content.format(
            bin_name = bin_name,
            **fmt_vars
        )

    return build_content

def _get_fmt_vars(name, attrs):
    tag = getattr(attrs, "tag", None)
    fmt_vars = dict(
        name = name,
        version = getattr(attrs, "version", tag),
        user = attrs.user,
        short_name = _shorten_name(name),
        tag = tag,
        dependency = attrs.dependency,
        extra_cflags = ", ".join(['"{}"'.format(c) for c in attrs.extra_cflags]),
    )

    if hasattr(attrs, "extra_fmt_vars"):
        fmt_vars.update(**attrs.extra_fmt_vars)

    return fmt_vars

def _luarocks_repository_impl(rctx):
    fmt_vars = _get_fmt_vars(rctx.attr.name, rctx.attr)

    rock_path = "{dependency}-{version}.src.rock".format(**fmt_vars)

    result = rctx.download(
        "https://luarocks.org/manifests/{user}/{dependency}-{version}.src.rock".format(**fmt_vars),
        allow_fail = True,
        output = rock_path,
        sha256 = rctx.attr.sha256,
    )

    if result.success:
        if rctx.attr.sha256 == "":
            print("""HINT: Add 'sha256 = "{sha256}"' to the luarocks_dependency for {user}/{dependency} to get a reproducible download""".format(sha256 = result.sha256, **fmt_vars))

        build_content = """
package(default_visibility = ["//visibility:public"])

load("@rules_lua//lua:defs.bzl", "luarocks_library")

filegroup(
    name = "rockspec",
    srcs = ["{dependency}-{version}.src.rock"],
)

luarocks_library(
    name = "{name}",
    srcrock = ":{dependency}-{version}.src.rock",
    deps = {deps},
    out_binaries = {out_binaries},
    extra_cflags = [{extra_cflags}],
)

alias(
    name = "{short_name}",
    actual = "{name}",
)
""".format(
            deps = str([str(i) for i in rctx.attr.deps]),
            out_binaries = str([str(i) for i in rctx.attr.out_binaries]),
            **fmt_vars
        )
    else:
        fail("luarocks_dependency can only be used for dependencies which have a .src.rock file available. Use github_dependency, external_dependnecy, or download the file yourself in the WORKSPACE and use luarocks_dependency directly.")

    rctx.file("BUILD.bazel", build_content)

luarocks_repository = repository_rule(
    _luarocks_repository_impl,
    doc = "Fetch a dependency from luarocks",
    attrs = {
        "extra_cflags": attr.string_list(
            doc = "extra CFLAGS to pass to compilation",
        ),
        "dependency": attr.string(
            doc = "name of dependency on luarocks",
            mandatory = True,
        ),
        "user": attr.string(
            doc = "user on luarocks that uploaded the dependency",
            mandatory = True,
        ),
        "version": attr.string(
            doc = "version of dependency",
            mandatory = True,
        ),
        "sha256": attr.string(
            doc = "sha256 of dependency",
            # mandatory = True,
        ),
        "deps": attr.label_list(
            doc = "lua deps",
            providers = [LuaLibrary],
        ),
        "out_binaries": attr.string_list(
            doc = "List of binaries which should be produced",
        ),
    },
)

def luarocks_dependency(dependency, name = None, **kwargs):
    if name == None:
        name = "lua_{}".format(dependency)

    luarocks_repository(
        name = name,
        dependency = dependency,
        **kwargs
    )

def _external_repository_impl(rctx):
    fmt_vars = _get_fmt_vars(rctx.attr.name, rctx.attr)

    build_content = _download_rockspec(
        rctx,
        rctx.attr.external_dependency_template.format(**fmt_vars),
        fmt_vars,
        rctx.attr.external_dependency_strip_template,
        out_binaries = rctx.attr.out_binaries,
        deps = rctx.attr.deps,
        sha256 = rctx.attr.sha256,
        rockspec_path = rctx.attr.rockspec_path,
    )

    rctx.file("BUILD.bazel", build_content)

external_repository = repository_rule(
    _external_repository_impl,
    doc = "Fetch a dependency from a url. Expects there to be a .rockspec file in the top level, or in the path specified by rockspec_path",
    attrs = {
        "dependency": attr.string(
            doc = "name of dependency",
            mandatory = True,
        ),
        "user": attr.string(
            doc = "user on luarocks that uploaded the dependency",
            mandatory = True,
        ),
        "version": attr.string(
            doc = "version of dependency",
            mandatory = True,
        ),
        "out_binaries": attr.string_list(
            doc = "binaries to produce",
        ),
        "sha256": attr.string(
            doc = "sha256 of dependency",
            # mandatory = True,
        ),
        "external_dependency_template": attr.string(
            doc = "template to download from git",
        ),
        "external_dependency_strip_template": attr.string(
            doc = "strip prefix of dependency archive, if present",
        ),
        "extra_fmt_vars": attr.string_dict(
            doc = "any extra things to pass to format external_dependency_template.",
        ),
        "rockspec_path": attr.string(
            doc = "Possible sub-path to rockspec path in the downloaded content. Defaults to the top level",
        ),
        "deps": attr.label_list(
            doc = "lua deps",
            providers = [LuaLibrary],
        ),
        "extra_cflags": attr.string_list(
            doc = "extra CFLAGS to pass to compilation",
        ),
    },
)

def external_dependency(dependency, name = None, **kwargs):
    if name == None:
        name = "lua_{}".format(dependency)

    external_repository(
        name = name,
        dependency = dependency,
        **kwargs
    )

def github_dependency(dependency, tag, name = None, **kwargs):
    if name == None:
        name = "lua_{}".format(dependency)

    if kwargs.pop("external_dependency_template", None):
        fail("cannot specify external_dependency_template with github_dependency")

    strip_template = kwargs.pop("external_dependency_strip_template", GITHUB_PREFIX_TEMPLATE)

    extra_fmt_vars = dict(
        short_tag = tag.removeprefix("v"),
        tag = tag,
    )
    extra_fmt_vars.update(kwargs.pop("extra_fmt_vars", {}))

    external_repository(
        name = name,
        external_dependency_template = GITHUB_TEMPLATE,
        external_dependency_strip_template = strip_template,
        dependency = dependency,
        extra_fmt_vars = extra_fmt_vars,
        version = kwargs.pop("version", tag),
        **kwargs
    )

    return name

def _luarocks_library_impl(ctx):
    lua_files = ctx.actions.declare_directory(ctx.attr.name)
    lua_toolchain = ctx.toolchains["@rules_lua//lua:toolchain_type"].lua_info

    cc_toolchain = find_cpp_toolchain(ctx)

    out_binaries = {}
    all_out_binaries = []
    for b in ctx.attr.out_binaries:
        binary_out = ctx.actions.declare_file(b)
        out_binaries[b] = depset([binary_out])
        all_out_binaries.append(binary_out)

    ctx.actions.run_shell(
        outputs = [lua_files] + all_out_binaries,
        inputs = [ctx.file.srcrock] +
                 ctx.files.data +
                 ctx.files.deps +
                 lua_toolchain.tool_files +
                 cc_toolchain.all_files.to_list(),
        command =
            """
set -e

tmpcfg=$(mktemp).lua
cat > $tmpcfg << EOF
variables = {{
   LUA_BINDIR = "$(realpath {lua_headers}/../bin)",
   LUA_INCDIR = "$(realpath {lua_headers}/*)",
   LUA_LIBDIR = "$(realpath {lua_headers}/../lib)",
   LUA_DIR = "$(realpath {lua_headers}/..)",
}}
EOF
export LUAROCKS_CONFIG=$tmpcfg

{luarocks} init --output .
# FIXME does this need to be a toolchain too?
{luarocks} config --scope project variables.UNZIP /bin/unzip
{luarocks} config --scope project variables.MD5SUM /bin/md5sum
{luarocks} config --scope project variables.CC {compiler}
{luarocks} config --scope project variables.LD {linker}
{luarocks} config --scope project gcc_rpath 'false'
{luarocks} config --scope project variables.CFLAGS -- "-fPIC {extra_cflags}"

if ! [[ "{src}" =~ .*.rockspec ]]; then
    {luarocks} unpack {src}
    {luarocks} install --no-doc --no-manifest --deps-mode none {src}
else
    cp -s -r $(realpath external/{name})/* .
    {luarocks} make --no-doc --no-manifest --deps-mode none {src}
fi

cp -r -L ./lua_modules/* {outpath}

for out_binary in {out_binaries_paths}; do
    cp {outpath}/bin/$(basename $out_binary) $out_binary
done
        """.format(
                lua_headers = (lua_toolchain.headers.path),
                name = ctx.attr.name,
                lexec = ctx.executable._luarocks.path,
                src = ctx.file.srcrock.path,
                compiler = cc_toolchain.compiler_executable,
                linker = cc_toolchain.ld_executable,
                luarocks = ctx.executable._luarocks.path,
                outpath = lua_files.path,
                out_binaries_paths = " ".join([o.path for o in all_out_binaries]),
                extra_cflags = " ".join(ctx.attr.extra_cflags),
            ),
        toolchain = "@rules_lua//lua:toolchain_type",
        tools = [ctx.executable._luarocks],
    )

    runfiles = ctx.runfiles(files = ctx.files.deps)

    # propagate dependencies
    dep_runfiles = [t[DefaultInfo].default_runfiles for t in [r for r in ctx.attr.deps]]
    runfiles = runfiles.merge_all(dep_runfiles)
    runfiles = runfiles.merge(ctx.attr._luarocks.data_runfiles)

    default = DefaultInfo(
        files = depset([lua_files] + all_out_binaries),
        runfiles = runfiles,
    )

    output_groups = OutputGroupInfo(
        **out_binaries
    )

    luarocks_library = LuaLibrary(
        lua_files = [lua_files],
    )

    return [
        default,
        output_groups,
        luarocks_library,
    ]

luarocks_library = rule(
    implementation = _luarocks_library_impl,
    attrs = {
        "srcrock": attr.label(
            doc = "path to srcrock to install",
            mandatory = True,
            allow_single_file = True,
        ),
        "deps": attr.label_list(
            doc = "Runtime lua dependencies",
            providers = [LuaLibrary],
        ),
        "data": attr.label_list(
            doc = "extra files required to build the luarocks library",
            allow_files = True,
        ),
        "out_binaries": attr.string_list(
            doc = "List of binaries which should be produced. These can be accessed in the same was as out_binaries in rules_foreign_cc.",
        ),
        "_luarocks": attr.label(
            doc = "luarocks",
            default = "@luarocks//:luarocks",
            cfg = "exec",
            executable = True,
        ),
        "_cc_toolchain": attr.label(
            default = Label("@bazel_tools//tools/cpp:current_cc_toolchain"),
        ),
        "extra_cflags": attr.string_list(
            doc = "extra CFLAGS to pass to compilation",
        ),
    },
    toolchains = [
        "@rules_lua//lua:toolchain_type",
        "@bazel_tools//tools/cpp:toolchain_type",
    ],
    doc = "install a luarocks dependency from a rockspec or .src.rock file",
)

_luarocks_tag = tag_class(
    doc = "Fetch a dependency from luarocks",
    attrs = {
        "extra_cflags": attr.string_list(
            doc = "extra CFLAGS to pass to compilation",
        ),
        "sha256": attr.string(
            doc = "sha256 of dependency",
            # mandatory = True,
        ),
        "dependency": attr.string(
            doc = "name of dependency on luarocks",
            mandatory = True,
        ),
        "user": attr.string(
            doc = "user on luarocks that uploaded the dependency",
            mandatory = True,
        ),
        "version": attr.string(
            doc = "version of dependency",
            mandatory = True,
        ),
        "out_binaries": attr.string_list(
            doc = "List of binaries which should be produced",
        ),
    },
)

_github_tag_attrs = {
    "dependency": attr.string(
        doc = "name of dependency",
        mandatory = True,
    ),
    "sha256": attr.string(
        doc = "expected hash",
    ),
    "user": attr.string(
        doc = "username on github that uploaded the dependency",
        mandatory = True,
    ),
    "tag": attr.string(
        doc = "tag on github",
        mandatory = True,
        # TODO: Allow hash as well
    ),
    "extra_fmt_vars": attr.string_dict(
        doc = "any extra things to pass to format external_dependency_template.",
    ),
    "rockspec_path": attr.string(
        doc = "Possible sub-path to rockspec path in the downloaded content. Defaults to the top level",
    ),
    "deps": attr.label_list(
        doc = "lua deps",
        providers = [LuaLibrary],
    ),
    "extra_cflags": attr.string_list(
        doc = "extra CFLAGS to pass to compilation",
    ),
    "out_binaries": attr.string_list(
        doc = "binaries to produce",
    ),
}

_github_tag = tag_class(
    doc = "Fetch a dependency from a url. Expects there to be a .rockspec file in the top level, or in the path specified by rockspec_path",
    attrs = _github_tag_attrs,
)

def _lua_dependency_impl(mctx):
    deps = []

    # TODO: There should be something which parses rockspecs use luarocks, or recursively, instead of defining all of these
    #  https://bazel.build/external/migration#integrate-package-manager
    for mod in mctx.modules:
        for github in mod.tags.github:
            p = {k: getattr(github, k) for k in _github_tag_attrs}
            github_dependency(**p)
        for luarocks in mod.tags.luarocks:
            p = {k: getattr(luarocks, k) for k in _luarocks_tag_attrs}
            luarocks_dependency(**p)

lua_dependency = module_extension(
    implementation = _lua_dependency_impl,
    tag_classes = {
        "luarocks": _luarocks_tag,
        "github": _github_tag,
    },
)
