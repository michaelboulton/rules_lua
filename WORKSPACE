workspace(
    name = "com_github_michaelboulton_rules_lua",
)

load(":internal_deps.bzl", "rules_lua_internal_deps")

# Fetch deps needed only locally for development
rules_lua_internal_deps()

load("//:deps.bzl", "rules_lua_dependencies")

# Fetch dependencies which users need as well
rules_lua_dependencies()

# For running our own unit tests
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

############################################
# Gazelle, for generating bzl_library targets
load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")
load("@bazel_gazelle//:deps.bzl", "gazelle_dependencies")

go_rules_dependencies()

go_register_toolchains(version = "1.19.2")

gazelle_dependencies()
