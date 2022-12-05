<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="lua_binary"></a>

## lua_binary

<pre>
lua_binary(<a href="#lua_binary-name">name</a>, <a href="#lua_binary-data">data</a>, <a href="#lua_binary-deps">deps</a>, <a href="#lua_binary-tool">tool</a>)
</pre>

Lua binary target. Will run the given tool with the registered lua toolchain.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="lua_binary-data"></a>data |  extra files to be available at runtime   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | [] |
| <a id="lua_binary-deps"></a>deps |  Runtime lua dependencies of target   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | [] |
| <a id="lua_binary-tool"></a>tool |  lua file to run   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="lua_library"></a>

## lua_library

<pre>
lua_library(<a href="#lua_library-name">name</a>, <a href="#lua_library-deps">deps</a>, <a href="#lua_library-srcs">srcs</a>, <a href="#lua_library-strip_prefix">strip_prefix</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="lua_library-deps"></a>deps |  runtime lua deps for this library   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | [] |
| <a id="lua_library-srcs"></a>srcs |  lua files   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="lua_library-strip_prefix"></a>strip_prefix |  prefix to strip off the sources (for example if the source is in a subfolder)   | String | optional | "" |


<a id="luarocks_library"></a>

## luarocks_library

<pre>
luarocks_library(<a href="#luarocks_library-name">name</a>, <a href="#luarocks_library-data">data</a>, <a href="#luarocks_library-deps">deps</a>, <a href="#luarocks_library-out_binaries">out_binaries</a>, <a href="#luarocks_library-srcrock">srcrock</a>)
</pre>

install a luarocks dependency from a rockspec or .src.rock file

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="luarocks_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="luarocks_library-data"></a>data |  extra files required to build the luarocks library   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | [] |
| <a id="luarocks_library-deps"></a>deps |  Runtime lua dependencies   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | [] |
| <a id="luarocks_library-out_binaries"></a>out_binaries |  List of binaries which should be produced. These can be accessed in the same was as out_binaries in rules_foreign_cc.   | List of strings | optional | [] |
| <a id="luarocks_library-srcrock"></a>srcrock |  path to srcrock to install   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="luaunit_test"></a>

## luaunit_test

<pre>
luaunit_test(<a href="#luaunit_test-name">name</a>, <a href="#luaunit_test-deps">deps</a>, <a href="#luaunit_test-srcs">srcs</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="luaunit_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="luaunit_test-deps"></a>deps |  runtime dependencies for test   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | [] |
| <a id="luaunit_test-srcs"></a>srcs |  test sources   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |


<a id="github_dependency"></a>

## github_dependency

<pre>
github_dependency(<a href="#github_dependency-dependency">dependency</a>, <a href="#github_dependency-tag">tag</a>, <a href="#github_dependency-name">name</a>, <a href="#github_dependency-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="github_dependency-dependency"></a>dependency |  <p align="center"> - </p>   |  none |
| <a id="github_dependency-tag"></a>tag |  <p align="center"> - </p>   |  none |
| <a id="github_dependency-name"></a>name |  <p align="center"> - </p>   |  <code>None</code> |
| <a id="github_dependency-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="luarocks_dependency"></a>

## luarocks_dependency

<pre>
luarocks_dependency(<a href="#luarocks_dependency-dependency">dependency</a>, <a href="#luarocks_dependency-name">name</a>, <a href="#luarocks_dependency-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="luarocks_dependency-dependency"></a>dependency |  <p align="center"> - </p>   |  none |
| <a id="luarocks_dependency-name"></a>name |  <p align="center"> - </p>   |  <code>None</code> |
| <a id="luarocks_dependency-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


