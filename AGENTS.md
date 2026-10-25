# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Layout: four separate Bazel modules

- `/` — `rules_lua`: lua/luajit/fennel toolchains, `lua_library`, `lua_binary`, `luarocks_library`, fennel rules, and the `lua_dependency` extension for luarocks/GitHub deps.
- `luaunit/` (`rules_lua_luaunit`) and `busted/` (`rules_lua_busted`) — test rule modules that depend on `rules_lua` via `local_path_override`. Each has a small `tests/` package that runs standalone from its own directory.
- `examples/` — integration tests that pull in all three modules via `local_path_override`. This is the only place that exercises luajit builds, luarocks deps, busted and fennel end to end.

`.bazelignore` excludes all of them from the root, so `bazel test //...` at the root runs only the docs diff tests and `//fennel/tests`. Run the real tests from inside `examples/` (Bazel has no workspace-directory flag, so `cd examples` is needed).

## Commands

```sh
bazel test //...                                   # root: docs diff tests + fennel version tests
bazel run //docs:update                            # regenerate docs/*.md after changing any public .bzl docstring/attr
bazel run //:gazelle                               # regenerate bzl_library targets
cd examples && bazel test //...                    # integration tests
cd examples && bazel test //lua/busted_test:test_maths   # single test
prek run --files <files>                           # buildifier, buildifier-lint, prettier (stage files first)
```

- `.bazelversion` pins Bazel 9.3.1; `examples/.bazelversion` is a symlink to it. Bazel 8 must also keep working: test with `USE_BAZEL_VERSION=8.1.0 bazel test //...`. On Bazel 8, `//docs:update_2_test` and `//docs:update_6_test` fail because Bazel 8 adds a `repo_mapping` attr to repository rule docs; the checked-in docs match Bazel 9.
- Never edit any `MODULE.bazel.lock` by hand; let Bazel rewrite it.
- After changing a patch file (e.g. `lua/*.patch`), run `bazel shutdown` before rebuilding. Bazel does not re-fetch the patched repo until the server restarts.
- Commit messages are checked by commitizen (Conventional Commits).

## Architecture

**Lua is built from source.** The `lua_toolchains` extension (`lua/repositories.bzl`) downloads lua/luajit sources and builds them with rules_foreign_cc `make()` (`lua/*.BUILD.bazel`). `toolchains_repo.bzl` generates one `toolchain()` per entry in `PLATFORMS`, plus a `resolved_toolchain` alias; modules register them with `@<name>_toolchains//:all`. The `LuaInfo` toolchain exposes the binary plus the `make` install tree, whose `include` dir is used as `headers`.

**Runtime module resolution goes through `lua/private/binary_wrapper.lua`.** `lua_binary` writes a bash launcher that runs `lua -l binary_wrapper <tool>`. The wrapper reads the runfiles `_repo_mapping` and builds `package.path`/`cpath` from repos it treats as Lua deps. It also installs `package.searchers` that map a `require` of a module's top-level name to the mangled runfiles repo name. This logic depends on Bazel's canonical repo name format (`~` before Bazel 8, `+` after, and `<module>++<rule>+<name>` for `use_repo_rule` repos in Bazel 9), so check it whenever Bazel changes naming. `luarocks` itself (`lua/luarocks.BUILD.bazel`) runs through this same wrapper.

**Lua deps are built by luarocks inside a Bazel action.** `lua_dependency` (`lua/private/lua_dependency.bzl`) creates a repo per `luarocks`/`github` tag, with a `luarocks_library` target named after the canonical repo plus an alias with the short name. `luarocks_library` runs luarocks in a `run_shell` action against the lua toolchain's install tree, using the cc toolchain's compiler and linker (passed as absolute paths, because luarocks compiles from inside the unpacked rock). The output is a tree artifact laid out as `share/lua/<ver>` and `lib/lua/<ver>`. `out_binaries` are exposed through output groups and wrapped as `lua_binary` targets (`<bin>_bin`).

**Fennel** compiles `.fnl` to `.lua` at build time with the fennel toolchain, which is itself a luarocks dependency (`fennel/repositories.bzl`), so `fennel_*` rules need both the lua and fennel toolchains. `fennel_library` returns both `LuaLibrary` and `FennelLibrary`.

**C toolchain:** every module registers hermetic_cc_toolchain (zig); root, `examples` and `luaunit` register the glibc 2.28 toolchains ahead of the glibc 2.17 default. The host toolchain on new distros breaks BCR C deps (GNU ld 2.47 segfaults on `--start-lib`, glibc 2.44 headers break old gnulib).

- luajit's Makefile hardcodes `CC=gcc`, so it builds with `make -e`. The Lua 5.x makefiles also hardcode `gcc` and still use the host compiler.
- Never add a dependency that needs autoconf: it makes the build take a really, really long time. This covers rules_foreign_cc building make from source, and anything built on `rules_cc_autoconf`, e.g. BCR `readline`, `ncurses` and `sed`. Their configure checks run as hundreds of Bazel actions, once per configuration. So `examples`, `luaunit` and `busted` set rules_foreign_cc `tools.make(mode = "system")`, and the Lua 5.4.6 patch builds without readline.
- The root `.bazelrc` uses a prebuilt protoc for stardoc, because protoc built from source fails to link with zig's lld.
