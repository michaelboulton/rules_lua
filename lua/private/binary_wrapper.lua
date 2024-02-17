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
        -- rules_lua~override~lua_toolchains~lua_src,bazel_tools,bazel_tools
        -- rules_lua~override~lua_toolchains~lua_src,lua_src,rules_lua~override~lua_toolchains~lua_src
        -- rules_lua~override~lua_toolchains~lua_src,rules_lua,rules_lua~override
        -- rules_lua~override~lua_toolchains~luajit_v2.1_x86_64-unknown-linux-gnu,bazel_tools,bazel_tools
        -- rules_lua~override~lua_toolchains~luajit_v2.1_x86_64-unknown-linux-gnu,lua_src,rules_lua~override~lua_toolchains~lua_src
        -- rules_lua~override~lua_toolchains~luajit_v2.1_x86_64-unknown-linux-gnu,rules_lua,rules_lua~override
        for str in string.gmatch(line, "([^,]+)") do
            table.insert(t, str)
        end

        if #t == 2 then
            table.insert(t, 1, t[2])
        end

        table.insert(repo_mappings, t)

    end

    return repo_mappings
end

local _path_added = {}
--- Adds the given path to the existing LUA_PATH
local function add_to_path(s)
    if _path_added[s] ~= nil then
        return nil
    end
    _path_added[s] = true
    package.path = package.path .. ";" .. s
end

local _cpath_added = {}
--- Adds the given cpath to the existing LUA_CPATH
local function add_to_cpath(s)
    if _cpath_added[s] ~= nil then
        return nil
    end
    _cpath_added[s] = true
    package.cpath = package.cpath .. ";" .. s
end

local function is_relevant(repo_name)
    local is_lua_dependency = string.match(repo_name, "~lua_dependency~")
    local is_repo_rules = string.match(repo_name, "~_repo_rules~")

    return is_lua_dependency or is_repo_rules
end

local function read_lua_mappings()
    local repo_mappings = read_repo_mapping()

    local relevant = {}

    for i, repo_mapping in ipairs(repo_mappings) do
        if is_relevant(repo_mapping[1]) and string.match(repo_mapping[2], "lua.+") then
            relevant[repo_mapping[2]] = { repo_mapping[1], repo_mapping[3] }
        end
    end

    return relevant
end

package.path = ""
package.cpath = ""

if os.getenv("RUNFILES_DIR") then
    local function rlocation(workspace_relative)
        local runfiles_dir = os.getenv("RUNFILES_DIR")
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

    package.preload["runfiles"] = function()
        return {
            rlocation = rlocation
        }
    end

    local relevant = read_lua_mappings()
    local runfiles_dir = os.getenv("RUNFILES_DIR")

    for k, v in pairs(relevant) do
        add_to_path(runfiles_dir .. "/?.lua")
        add_to_path(runfiles_dir .. "/?/init.lua")

        local root = runfiles_dir .. "/" .. v[2] .. "/" .. v[2]

        -- FIXME: get luarocks install prefix
        add_to_path(root .. "/share/lua/5.1/?.lua")
        add_to_path(root .. "/share/lua/5.1/?/init.lua")
        add_to_cpath(root .. "/lib/lua/5.1/?.so")
    end

    -- Set up loader for mangled names
    local loaders = package.searchers
    if loaders == nil then
        loaders = package.loaders
    end

    table.insert(loaders, function(module_name)
        local real_module_toplevel_name = module_name:gsub("[.].+", "")

        --print("Trying to load " .. module_name)
        --for i, v in pairs(relevant) do
        --    print(i)
        --    print(v)
        --end
        --print(package.path)
        --print(package.cpath)

        local resolved
        if relevant[real_module_toplevel_name] then
            -- If there is a mapping
            resolved = module_name:gsub(real_module_toplevel_name, relevant[real_module_toplevel_name][2])
        else
            local with_prefix = "lua_" .. real_module_toplevel_name
            -- See if theres a dep with the lua_ prefix
            if not relevant[with_prefix] then
                -- no hope of a match
                return nil
            end

            resolved = relevant[with_prefix][2] .. "." .. module_name:gsub(real_module_toplevel_name, relevant[with_prefix][2])
            --resolved = relevant[with_prefix][2] ..".".. real_module_toplevel_name
        end

        local loaded = require(resolved)
        if loaded == nil then
            return nil
        end

        return function()
            return loaded
        end
    end)
elseif os.getenv("RUNFILES_MANIFEST_FILE") then
    local function rlocation(workspace_relative)
        error("not implemented")
    end

    package.preload["runfiles"] = function()
        return {
            rlocation = rlocation
        }
    end

    local relevant = read_lua_mappings()

    local inverted = {}
    for k, v in pairs(relevant) do
        -- This gets the 'canonical name of the source repo' which is probably correct
        inverted[v[1]] = k
    end

    for line in io.lines(os.getenv("RUNFILES_MANIFEST_FILE")) do
        local t = {}
        -- // a manifest file that maps logical runfile paths to absolute paths paths for the real files in Bazel's cache.
        -- eg:
        --_main/luaunit_runner.lua /home/michael/code/rules_lua/luaunit/luaunit_runner.lua
        --_main/luaunit_runner_exec /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-fastbuild/bin/luaunit_runner_exec
        --_repo_mapping /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-fastbuild/bin/luaunit_runner_exec.repo_mapping
        --bazel_tools/tools/bash/runfiles/runfiles.bash /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/external/bazel_tools/tools/bash/runfiles/runfiles.bash
        --rules_lua~override/lua/private/binary_wrapper.lua /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/external/rules_lua~override/lua/private/binary_wrapper.lua
        --rules_lua~override~_repo_rules~luarocks/admin/cache.lua /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-opt-exec-ST-13d3ddad9198/bin/external/rules_lua~override~_repo_rules~luarocks/admin/cache.lua
        --rules_lua~override~_repo_rules~luarocks/admin/cmd/add.lua /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-opt-exec-ST-13d3ddad9198/bin/external/rules_lua~override~_repo_rules~luarocks/admin/cmd/add.lua
        --rules_lua~override~_repo_rules~luarocks/type_check.lua /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-opt-exec-ST-13d3ddad9198/bin/external/rules_lua~override~_repo_rules~luarocks/type_check.lua
        --rules_lua~override~_repo_rules~luarocks/upload/api.lua /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-opt-exec-ST-13d3ddad9198/bin/external/rules_lua~override~_repo_rules~luarocks/upload/api.lua
        --rules_lua~override~_repo_rules~luarocks/upload/multipart.lua /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-opt-exec-ST-13d3ddad9198/bin/external/rules_lua~override~_repo_rules~luarocks/upload/multipart.lua
        --rules_lua~override~_repo_rules~luarocks/util.lua /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-opt-exec-ST-13d3ddad9198/bin/external/rules_lua~override~_repo_rules~luarocks/util.lua
        --rules_lua~override~lua_dependency~lua_luaunit/rules_lua~override~lua_dependency~lua_luaunit /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-fastbuild/bin/external/rules_lua~override~lua_dependency~lua_luaunit/rules_lua~override~lua_dependency~lua_luaunit
        --rules_lua~override~lua_toolchains~lua_src/lua /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-opt-exec-ST-13d3ddad9198/bin/external/rules_lua~override~lua_toolchains~lua_src/lua
        --rules_lua~override~lua_toolchains~lua_src/lua_make/bin/lua /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-opt-exec-ST-13d3ddad9198/bin/external/rules_lua~override~lua_toolchains~lua_src/lua_make/bin/lua
        --rules_lua~override~lua_toolchains~lua_src/lua_make/include /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-opt-exec-ST-13d3ddad9198/bin/external/rules_lua~override~lua_toolchains~lua_src/lua_make/include
        --rules_lua~override~lua_toolchains~lua_src/lua_make/lib/libluajit-5.1.a /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-opt-exec-ST-13d3ddad9198/bin/external/rules_lua~override~lua_toolchains~lua_src/lua_make/lib/libluajit-5.1.a
        --rules_lua~override~lua_toolchains~lua_src/lua_make/lib/libluajit-5.1.so.2.1.0 /home/michael/.cache/bazel/_bazel_michael/8b8e9136bd71c77bdacd15b930f72e19/execroot/_main/bazel-out/k8-opt-exec-ST-13d3ddad9198/bin/external/rules_lua~override~lua_toolchains~lua_src/lua_make/lib/libluajit-5.1.so.2.1.0

        for str in string.gmatch(line, "([^ ]+)") do
            table.insert(t, str)
        end

        local folder_name = string.gsub(t[1], "/.*", "")
        if inverted[folder_name] and is_relevant(folder_name) then
            local root = t[2]
            add_to_path(root .. "/?.lua")
            -- FIXME: get luarocks install prefix
            add_to_path(root .. "/share/lua/5.1/" .. "?.lua")
        end
    end
else
    error("J")
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
