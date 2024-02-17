<!-- Generated with Stardoc: http://skydoc.bazel.build -->

This module implements the language-specific toolchain rule.

<a id="lua_toolchain"></a>

## lua_toolchain

<pre>
lua_toolchain(<a href="#lua_toolchain-name">name</a>, <a href="#lua_toolchain-dev_files">dev_files</a>, <a href="#lua_toolchain-target_tool">target_tool</a>, <a href="#lua_toolchain-target_tool_path">target_tool_path</a>)
</pre>

Defines a lua compiler/runtime toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="lua_toolchain-dev_files"></a>dev_files |  lua output libs and include directories   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="lua_toolchain-target_tool"></a>target_tool |  A hermetically downloaded executable target for the target platform.   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="lua_toolchain-target_tool_path"></a>target_tool_path |  Path to an existing executable for the target platform.   | String | optional |  `""`  |


<a id="LuaInfo"></a>

## LuaInfo

<pre>
LuaInfo(<a href="#LuaInfo-target_tool">target_tool</a>, <a href="#LuaInfo-target_tool_path">target_tool_path</a>, <a href="#LuaInfo-tool_files">tool_files</a>, <a href="#LuaInfo-headers">headers</a>)
</pre>

Information about how to invoke the tool executable.

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="LuaInfo-target_tool"></a>target_tool |  label of generated lua path. Should prefer this over target_tool_path    |
| <a id="LuaInfo-target_tool_path"></a>target_tool_path |  absolute path to the tool executable for the target platform. should only be used if using system lua    |
| <a id="LuaInfo-tool_files"></a>tool_files |  Files required in runfiles to make the tool executable available.<br><br>May be empty if the target_tool_path points to a locally installed tool binary.    |
| <a id="LuaInfo-headers"></a>headers |  Lua header dir    |


