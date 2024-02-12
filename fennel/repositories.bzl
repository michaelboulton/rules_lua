"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@rules_lua//lua:defs.bzl", "github_dependency", "luarocks_dependency")
load("//fennel/private:toolchains_repo.bzl", "toolchains_repo")
load("//fennel/private:versions.bzl", "FENNEL_VERSIONS")

########
# Remaining content of the file is only used to support toolchains.
########
_DOC = "Fetch external tools needed for fennel toolchain"
_ATTRS = {
    "version": attr.string(mandatory = True, values = FENNEL_VERSIONS.keys()),
}

def _fennel_repo_impl(rctx):
    build_content = """
package(default_visibility = ["//visibility:public"])

load("@rules_lua//fennel:toolchain.bzl", "fennel_toolchain")

filegroup(
    name = "fennel_binary_group",
    srcs = ["@lua_fennel"],
    output_group = "fennel",
)

genrule(
    name = "fennel_binary",
    srcs = [":fennel_binary_group"],
    outs = ["fennel"],
    cmd = "set -ex; find .; cp $(locations fennel_binary_group) $@",
)

fennel_toolchain(name = "fennel_toolchain", target_tool = ":fennel", extra_tool_files = ["@lua_fennel"])
"""

    # Base BUILD file for this repository
    rctx.file("BUILD.bazel", build_content)

fennel_repositories = repository_rule(
    _fennel_repo_impl,
    doc = _DOC,
    attrs = _ATTRS,
)

def _fennel_register_toolchains(name, version, **kwargs):
    if version not in FENNEL_VERSIONS:
        fail("Unrecognised fennel version {}".format(version))

    #    fmt_vars = dict(
    #        version = version,
    #        rockspec_release = FENNEL_VERSIONS[version],
    #    )

    #    github_dependency(
    #        name = "lua_fennel",
    #        dependency = "fennel",
    #        tag = "{version}".format(**fmt_vars),
    #        user = "bakpakin",
    #        external_dependency_strip_template = "Fennel-{version}".format(**fmt_vars),
    #        version = "{version}-{rockspec_release}".format(**fmt_vars),
    #        rockspec_path = "rockspecs/fennel-{version}-{rockspec_release}.rockspec".format(**fmt_vars),
    #    )

    luarocks_dependency(
        name = "lua_fennel",
        sha256 = FENNEL_VERSIONS[version],
        dependency = "fennel",
        user = "technomancy",
        version = "{}-1".format(version),
        out_binaries = ["fennel"],
    )

    fennel_repositories(
        name = name,
        version = version,
        **kwargs
    )

    toolchains_repo(
        name = name + "_toolchains",
        user_repository_name = name,
    )

    return "@{}_toolchains//:fennel_toolchain".format(name)

_fennel_tag = tag_class(
    doc = "initialise fennel toolchain",
    attrs = {
        "name": attr.string(
            default = "fennel",
            doc = "register toolchain repo with this name",
        ),
        "version": attr.string(
            default = "1.2.1",
            doc = "version of SDK",
        ),
    },
)

def _fennel_toolchains_extension(mctx):
    def _verify_toolchain_name(mod, expected, name):
        if name != expected and not mod.is_root:
            fail("""\
            Only the root module may override the default name for the {} toolchains.
            This prevents conflicting registrations in the global namespace of external repos.
            """.format(expected))

    for mod in mctx.modules:
        for fennel in mod.tags.fennel:
            _verify_toolchain_name(mod, "fennel", fennel.name)

            _fennel_register_toolchains(fennel.name, fennel.version)

fennel_toolchains = module_extension(
    implementation = _fennel_toolchains_extension,
    tag_classes = {
        "fennel": _fennel_tag,
    },
)
