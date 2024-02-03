load("//lua:providers.bzl", "LuaLibrary")
load("@bazel_skylib//lib:paths.bzl", "paths")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load(":lua_binary.bzl", "hack_get_lua_path")

GITHUB_TEMPLATE = "https://github.com/{user}/{dependency}/archive/refs/tags/{tag}.tar.gz"
GITHUB_PREFIX_TEMPLATE = "{dependency}-{short_tag}"

def _download_rockspec(rctx, url, fmt_vars):
    rockspec_path = "{dependency}-{version}.rockspec".format(**fmt_vars)

    if rctx.attr.rockspec_path != "":
        rockspec_path = rctx.attr.rockspec_path

    if url.endswith(".rockspec"):
        rctx.download(
            url,
            sha256 = rctx.attr.sha256,
        )
    else:
        rctx.download_and_extract(
            url,
            sha256 = rctx.attr.sha256,
            stripPrefix = rctx.attr.external_dependency_strip_template.format(**fmt_vars),
        )

    build_content = """
package(default_visibility = ["//visibility:public"])

filegroup(
    name = "all_files",
    srcs = glob(["**/*"], exclude=["**/* *"]),
)

load("@com_github_michaelboulton_rules_lua//lua:defs.bzl", "luarocks_library")

luarocks_library(
    name = "{name}",
    srcrock = "{rockspec_path}",
    deps = {deps},
    data = [":all_files"],
    extra_cflags = [{extra_cflags}],

)""".format(
        deps = str([str(i) for i in rctx.attr.deps]),
        rockspec_path = rockspec_path,
        **fmt_vars
    )

    return build_content

def _get_fmt_vars(rctx):
    fmt_vars = dict(
        name = rctx.attr.name,
        version = rctx.attr.version,
        user = rctx.attr.user,
        dependency = rctx.attr.dependency,
        extra_cflags = ", ".join(['"{}"'.format(c) for c in rctx.attr.extra_cflags]),
    )

    if hasattr(rctx.attr, "extra_fmt_vars"):
        fmt_vars.update(**rctx.attr.extra_fmt_vars)

    return fmt_vars

def _luarocks_repository_impl(rctx):
    fmt_vars = _get_fmt_vars(rctx)

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

load("@com_github_michaelboulton_rules_lua//lua:defs.bzl", "luarocks_library")

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
)""".format(
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
    fmt_vars = _get_fmt_vars(rctx)

    build_content = _download_rockspec(rctx, rctx.attr.external_dependency_template.format(**fmt_vars), fmt_vars)

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

    if kwargs.get("external_dependency_template"):
        fail("cannot specify external_dependency_template with github_dependency")

    strip_template = kwargs.pop("external_dependency_strip_template", GITHUB_PREFIX_TEMPLATE)

    extra_fmt_vars = kwargs.pop("extra_fmt_vars", {})
    extra_fmt_vars.update(
        short_tag = tag.removeprefix("v"),
        tag = tag,
    )
    external_repository(
        name = name,
        external_dependency_template = GITHUB_TEMPLATE,
        external_dependency_strip_template = strip_template,
        dependency = dependency,
        extra_fmt_vars = extra_fmt_vars,
        **kwargs
    )

def _luarocks_library_impl(ctx):
    lua_files = ctx.actions.declare_directory(ctx.attr.name)
    lua_toolchain = ctx.toolchains["@com_github_michaelboulton_rules_lua//lua:toolchain_type"].lua_info

    cc_toolchain = find_cpp_toolchain(ctx)

    lua_path = paths.join(ctx.var["BINDIR"], ctx.var["lua_BIN"])

    out_binaries = {}
    all_out_binaries = []
    for b in ctx.attr.out_binaries:
        binary_out = ctx.actions.declare_file(b)
        out_binaries[b] = depset([binary_out])
        all_out_binaries.append(binary_out)

    ctx.actions.run_shell(
        outputs = [lua_files] + all_out_binaries,
        inputs = [ctx.file.srcrock] + ctx.files.data + lua_toolchain.tool_files + ctx.files._luarocks + ctx.files._luarocks_libs + ctx.files.deps + cc_toolchain.all_files.to_list(),
        command = (hack_get_lua_path + """
        real_include=$(realpath $(dirname {lua})/include)

        export LUA_PATH="?;?.lua;$(realpath $(pwd)/..)/?.lua{extra_lua_paths}"
        export LUA_INCDIR=$(pwd)/include

        {lua} {luarocks} init --output .
        {lua} {luarocks} config --scope project variables.LUA_INCDIR $real_include
        # FIXME does this need to be a toolchain too?
        {lua} {luarocks} config --scope project variables.UNZIP /bin/unzip
        {lua} {luarocks} config --scope project variables.MD5SUM /bin/md5sum
        {lua} {luarocks} config --scope project variables.CC {compiler}
        {lua} {luarocks} config --scope project variables.LD {linker}
        {lua} {luarocks} config --scope project gcc_rpath 'false'
        {lua} {luarocks} config --scope project variables.CFLAGS -- "-fPIC {extra_cflags}"

        if ! [[ "{src}" =~ .*.rockspec ]]; then
            {lua} {luarocks} unpack {src}
            {lua} {luarocks} install --no-doc --no-manifest --deps-mode none {src}
        else
            cp -s -r $(realpath external/{name})/* .
            {lua} {luarocks} make --no-doc --no-manifest --deps-mode none {src}
        fi

        cp -r -L ./lua_modules/* {outpath}

        for out_binary in {out_binaries_paths}; do
            cp {outpath}/bin/$(basename $out_binary) $out_binary
        done
        """).format(
            extra_lua_paths = ";$(pwd)/{}/?.lua".format(paths.join(ctx.var["BINDIR"], "external")),
            lua = lua_path,
            name = ctx.attr.name,
            src = ctx.file.srcrock.path,
            compiler = cc_toolchain.compiler_executable,
            linker = cc_toolchain.ld_executable,
            # FIXME: some wy to find this programatically?
            luarocks = "external/luarocks/src/bin/luarocks",
            outpath = lua_files.path,
            out_binaries_paths = " ".join([o.path for o in all_out_binaries]),
            extra_cflags = " ".join(ctx.attr.extra_cflags),
        ),
    )

    runfiles = ctx.runfiles(files = ctx.files.deps)

    # propagate dependencies
    dep_runfiles = [t[DefaultInfo].default_runfiles for t in [r for r in ctx.attr.deps]]
    runfiles = runfiles.merge_all(dep_runfiles)

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
        ),
        "_luarocks_libs": attr.label(
            doc = "luarocks libs",
            default = "@luarocks//:luarocks_lib",
        ),
        "_cc_toolchain": attr.label(default = Label("@bazel_tools//tools/cpp:current_cc_toolchain")),
        "extra_cflags": attr.string_list(
            doc = "extra CFLAGS to pass to compilation",
        ),
    },
    toolchains = [
        "@com_github_michaelboulton_rules_lua//lua:toolchain_type",
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

def _lua_dependency_impl(mctx):
    #    artifacts = []
    #    for mod in mctx.modules:
    #        artifacts += [_to_artifact(artifact) for artifact in mod.tags.artifact]

    for m in mctx.luarocks:
        _luarocks_repository_impl(mctx)

lua_dependendency = module_extension(
    implementation = _lua_dependency_impl,
    tag_classes = {
        "luarocks": _luarocks_tag,
    },
)
