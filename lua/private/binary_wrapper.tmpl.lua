--[[LUA_PATH]]--


local function read_repo_mapping()
    local repo_mappings = {}

    for line in io.lines(os.getenv("RUNFILES_REPO_MAPPING")) do
        local t = {}
        -- // Each line of the repository mapping manifest has the form:
        -- // canonical name of source repo,apparent name of target repo,target repo runfiles directory
        -- eg:
        -- ,__main__,_main
        -- ,bazel_tools,bazel_tools
        -- ,lua_luaunit,rules_lua~override~lua_dependency~lua_luaunit
        -- ,rules_lua,rules_lua~override
        -- ,rules_lua_luaunit,_main
        -- bazel_tools,bazel_tools,bazel_tools
        -- bazel_tools~cc_configure_extension~local_config_cc,bazel_tools,bazel_tools
        -- bazel_tools~xcode_configure_extension~local_config_xcode,bazel_tools,bazel_tools
        -- platforms,bazel_tools,bazel_tools
        -- rules_foreign_cc~0.10.1,bazel_tools,bazel_tools
        -- rules_foreign_cc~0.10.1~tools~gnumake_src,bazel_tools,bazel_tools
        -- rules_foreign_cc~0.10.1~tools~rules_foreign_cc_framework_toolchain_linux,bazel_tools,bazel_tools
        -- rules_lua~override,bazel_tools,bazel_tools
        -- rules_lua~override,rules_lua,rules_lua~override
        -- rules_lua~override~_repo_rules~luarocks,bazel_tools,bazel_tools
        -- rules_lua~override~_repo_rules~luarocks,rules_lua,rules_lua~override
        -- rules_lua~override~lua_dependency~lua_luaunit,bazel_tools,bazel_tools
        -- rules_lua~override~lua_dependency~lua_luaunit,lua_luaunit,rules_lua~override~lua_dependency~lua_luaunit
        -- rules_lua~override~lua_dependency~lua_luaunit,rules_lua,rules_lua~override
        -- rules_lua~override~lua_toolchains~lua_git,bazel_tools,bazel_tools
        -- rules_lua~override~lua_toolchains~lua_git,lua_git,rules_lua~override~lua_toolchains~lua_git
        -- rules_lua~override~lua_toolchains~lua_git,rules_lua,rules_lua~override
        -- rules_lua~override~lua_toolchains~luajit_v2.1_x86_64-unknown-linux-gnu,bazel_tools,bazel_tools
        -- rules_lua~override~lua_toolchains~luajit_v2.1_x86_64-unknown-linux-gnu,lua_git,rules_lua~override~lua_toolchains~lua_git
        -- rules_lua~override~lua_toolchains~luajit_v2.1_x86_64-unknown-linux-gnu,rules_lua,rules_lua~override
        for str in string.gmatch(line, "([^,]+)") do
            table.insert(t, str)
        end

        if #t > 2 then
            table.insert(repo_mappings, t)
        end
    end

    return repo_mappings
end

local function read_lua_mappings()
    local repo_mappings = read_repo_mapping()

    local relevant = {}

    for i, repo_mapping in ipairs(repo_mappings) do
        if string.match(repo_mapping[1], "~lua_dependency~") and string.match(repo_mapping[2], "lua_.+") then
            relevant[repo_mapping[2]] = { repo_mapping[1], repo_mapping[3] }
        end
    end

    return relevant
end

local runfiles_dir = os.getenv("RUNFILES_DIR")
if runfiles_dir then
    local relevant = read_lua_mappings()

    for k, v in pairs(relevant) do
        local root = runfiles_dir .. "/" .. v[2] .. "/" .. v[1] .. "/share/lua/5.1/"
        local function add_to_path(s)
            package.path = package.path .. ";" .. s
        end

        print("LOADING")
        print(root)

        add_to_path(root .. "?.lua")
    end
else
    error("NONRUNFINE")
end

local function rlocation(workspace_relative)
    local resolved = runfiles_dir .. "/" .. "_main" .. "/" .. workspace_relative

    return resolved

    --local relevant = read_repo_mapping()
    --local prefix = string.gsub(workspace_relative, "/.+", "")
    --for k, v in ipairs(relevant) do
    --    print(v[1] .. ": " .. v[2])
    --end
    --
    --for str in string.gmatch(workspace_relative, "([^,]+)") do
    --    if relevant[str] then
    --        break
    --    end
    --
    --    error("file not found: " .. workspace_relative)
    --end
end

local runfiles = {
    rlocation = rlocation
}

package.preload["runfiles"] = function()
    return runfiles
end

--for i, file in ipairs({
--    --[[RUN]]--
--}) do
--    local loc = rlocation(file)
--    print(loc)
--    print(loc)
--    print(loc)
--    print(loc)
--    io.lines(loc)
--    local chunk = loadfile(loc)
--    chunk("-content_image", "content_image", "-output_image", "output_image")
--end

return {}