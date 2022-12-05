# FIXME: Most places that take a lualibrary as a dep should also allow taking a ccinfo and have paths set accordingly.

LuaLibrary = provider(
    doc = "Collection of lua files",
    fields = {
        "lua_files": "Lua files",
    },
)
