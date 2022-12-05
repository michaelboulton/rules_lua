"Public API re-exports"

load(
    "//fennel/private:fennel_library.bzl",
    _aniseed_library = "aniseed_library",
    _fennel_library = "fennel_library",
)
load(
    "//fennel/private:fennel_test.bzl",
    _aniseed_test = "aniseed_test",
    _fennel_busted_test = "fennel_busted_test",
    _fennel_luaunit_test = "fennel_luaunit_test",
)

fennel_library = _fennel_library
fennel_luaunit_test = _fennel_luaunit_test
aniseed_library = _aniseed_library
aniseed_test = _aniseed_test
fennel_busted_test = _fennel_busted_test
