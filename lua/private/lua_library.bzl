load("//lua:providers.bzl", "LuaLibrary")

def _lua_library_impl(ctx):
    if ctx.attr.strip_prefix == None:
        lua_files = ctx.files.srcs
    else:
        lua_files = []
        for file in ctx.files.srcs:
            lua_files.append(ctx.actions.declare_file(file.short_path.replace(ctx.attr.strip_prefix.removesuffix("/") + "/", "")))
        ctx.actions.run_shell(
            outputs = lua_files,
            inputs = ctx.files.srcs,
            command = "\n".join(
                ["cp {src} {dest}".format(
                    src = src.path,
                    dest = dest.path,
                ) for src, dest in zip(ctx.files.srcs, lua_files)],
            ),
        )

    runfiles = ctx.runfiles(files = ctx.files.deps)

    # propagate dependencies
    dep_runfiles = [t[DefaultInfo].default_runfiles for t in [r for r in ctx.attr.deps]]
    runfiles = runfiles.merge_all(dep_runfiles)

    default = DefaultInfo(
        files = depset(lua_files),
        runfiles = runfiles,
    )

    lua_library = LuaLibrary(
        lua_files = lua_files,
    )

    return [
        lua_library,
        default,
    ]

lua_library = rule(
    implementation = _lua_library_impl,
    attrs = {
        "srcs": attr.label_list(
            allow_files = True,
            doc = "lua files",
            mandatory = True,
        ),
        "deps": attr.label_list(
            doc = "runtime lua deps for this library",
            providers = [LuaLibrary],
        ),
        "strip_prefix": attr.string(
            doc = "prefix to strip off the sources (for example if the source is in a subfolder)",
        ),
    },
)
