# Bazel rules for Lua

See [the example project](/examples) for usage

## Usage

```starlark
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "f7be3474d42aae265405a592bb7da8e171919d74c16f082a5457840f06054728",
    urls = [
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.2.1/bazel-skylib-1.2.1.tar.gz",
    ],
)

# Load skylib dependencies
load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

# Load lua rules
local_repository(
    name = "com_github_michaelboulton_rules_lua",
    path = "..",
)

load("@com_github_michaelboulton_rules_lua//:deps.bzl", "rules_lua_dependencies")

# Load default dependencies
rules_lua_dependencies()


# Optional: Initialise rules_foreign_cc dependencies for building luarocks packages
load("@rules_foreign_cc//foreign_cc:repositories.bzl", "rules_foreign_cc_dependencies")

rules_foreign_cc_dependencies()


# Optional: Load dependencies for busted. If you want to use busted_test you need to download all its dependencies - this will download them all for you. 
load("@com_github_michaelboulton_rules_lua//:deps.bzl", "busted_test_dependencies")

busted_test_dependencies()


load("@com_github_michaelboulton_rules_lua//lua:repositories.bzl", "lua_register_system_toolchain", "lua_register_toolchains", "luajit_register_toolchains")

# Register normal lua toolchain
# lua_register_toolchains()

# Register luajit toolchain
luajit_register_toolchains()

# Register system lua
# lua_register_system_toolchain("/usr/bin/lua")

```

## NOTES

If you want to use lua toolchains, you must also use https://github.com/bazelbuild/rules_foreign_cc/
and register the toolchains in your workspace.
