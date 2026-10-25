"Public API re-exports"

load(
    "//fennel/private:fennel_binary.bzl",
    _fennel_binary = "fennel_binary",
)
load(
    "//fennel/private:fennel_library.bzl",
    _fennel_library = "fennel_library",
)

fennel_library = _fennel_library
fennel_binary = _fennel_binary
