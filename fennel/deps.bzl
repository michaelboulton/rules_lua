load("@bazel_tools//tools/build_defs/repo:http.bzl", _http_archive = "http_archive")
load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")

def http_archive(name, **kwargs):
    maybe(_http_archive, name = name, **kwargs)

def aniseed_dependencies():
    http_archive(
        name = "aniseed",
        sha256 = "81dd1fe9d61c70999dbb3e56b5b660cf09ed7667a711a744146376ca49fa3b3a",
        strip_prefix = "aniseed-3.31.0",
        url = "https://github.com/Olical/aniseed/archive/refs/tags/v3.31.0.tar.gz",
        build_file_content = """
alias(
    name = "aniseed_exp",
    actual = "//fnl/aniseed",
)

alias(
    name = "aniseed_macros",
    actual = "//fnl/aniseed:aniseed_macros",
    visibility = ["//visibility:public"],
)

load("@rules_lua//fennel:defs.bzl", "aniseed_library")

aniseed_library(
    name = "aniseed",
    srcs = [":aniseed_exp"],
    visibility = ["//visibility:public"],
    strip_prefix = "aniseed/fnl",
)

        """,
        patch_args = ["-p", "1"],
        patches = ["@rules_lua//fennel:0001-Add-build-file.patch"],
    )
