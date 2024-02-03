"""Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies
"""

load("@com_github_michaelboulton_rules_lua//lua:defs.bzl", "github_dependency", "luarocks_dependency")
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

load("@com_github_michaelboulton_rules_lua//fennel:toolchain.bzl", "fennel_toolchain")

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
        version = "1.2.1-1",
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

# Wrapper macro around everything above, this is the primary API
def fennel_register_toolchains(name, version = "1.2.1", **kwargs):
    """Convenience macro for users which does typical setup.

    - create a repository exposing toolchains for each platform like "fennel_platforms"
    - register a toolchain pointing at each platform
    Users can avoid this macro and do these steps themselves, if they want more control.

    Args:
        name: base name for all created repos, like "fennel1_14"
        **kwargs: passed to each node_repositories call
    """

    native.register_toolchains(_fennel_register_toolchains(name, version, **kwargs))
