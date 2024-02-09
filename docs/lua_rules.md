<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="busted_test"></a>

## busted_test

<pre>
busted_test(<a href="#busted_test-name">name</a>, <a href="#busted_test-deps">deps</a>, <a href="#busted_test-srcs">srcs</a>, <a href="#busted_test-data">data</a>, <a href="#busted_test-standalone">standalone</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="busted_test-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="busted_test-deps"></a>deps |  runtime dependencies for test   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="busted_test-srcs"></a>srcs |  test sources   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="busted_test-data"></a>data |  extra files to be available at runtime   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="busted_test-standalone"></a>standalone |  Whether this is a 'standalone' test or a normal test that sould be called with the busted cli   | Boolean | optional |  `False`  |


<a id="lua_binary"></a>

## lua_binary

<pre>
lua_binary(<a href="#lua_binary-name">name</a>, <a href="#lua_binary-deps">deps</a>, <a href="#lua_binary-data">data</a>, <a href="#lua_binary-tool">tool</a>)
</pre>

Lua binary target. Will run the given tool with the registered lua toolchain.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="lua_binary-deps"></a>deps |  Runtime lua dependencies of target   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="lua_binary-data"></a>data |  extra files to be available at runtime   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
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
| <a id="lua_library-deps"></a>deps |  runtime lua deps for this library   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="lua_library-srcs"></a>srcs |  lua files   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="lua_library-strip_prefix"></a>strip_prefix |  prefix to strip off the sources (for example if the source is in a subfolder)   | String | optional |  `""`  |


<a id="luarocks_library"></a>

## luarocks_library

<pre>
luarocks_library(<a href="#luarocks_library-name">name</a>, <a href="#luarocks_library-deps">deps</a>, <a href="#luarocks_library-data">data</a>, <a href="#luarocks_library-extra_cflags">extra_cflags</a>, <a href="#luarocks_library-out_binaries">out_binaries</a>, <a href="#luarocks_library-srcrock">srcrock</a>)
</pre>

install a luarocks dependency from a rockspec or .src.rock file

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="luarocks_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="luarocks_library-deps"></a>deps |  Runtime lua dependencies   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="luarocks_library-data"></a>data |  extra files required to build the luarocks library   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="luarocks_library-extra_cflags"></a>extra_cflags |  extra CFLAGS to pass to compilation   | List of strings | optional |  `[]`  |
| <a id="luarocks_library-out_binaries"></a>out_binaries |  List of binaries which should be produced. These can be accessed in the same was as out_binaries in rules_foreign_cc.   | List of strings | optional |  `[]`  |
| <a id="luarocks_library-srcrock"></a>srcrock |  path to srcrock to install   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


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
| <a id="github_dependency-name"></a>name |  <p align="center"> - </p>   |  `None` |
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
| <a id="luarocks_dependency-name"></a>name |  <p align="center"> - </p>   |  `None` |
| <a id="luarocks_dependency-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="lua_dependency"></a>

## lua_dependency

<pre>
lua_dependency = use_extension("@rules_lua//lua:defs.bzl", "lua_dependency")
lua_dependency.luarocks(<a href="#lua_dependency.luarocks-dependency">dependency</a>, <a href="#lua_dependency.luarocks-extra_cflags">extra_cflags</a>, <a href="#lua_dependency.luarocks-out_binaries">out_binaries</a>, <a href="#lua_dependency.luarocks-sha256">sha256</a>, <a href="#lua_dependency.luarocks-user">user</a>, <a href="#lua_dependency.luarocks-version">version</a>)
lua_dependency.busted()
lua_dependency.github(<a href="#lua_dependency.github-deps">deps</a>, <a href="#lua_dependency.github-dependency">dependency</a>, <a href="#lua_dependency.github-extra_cflags">extra_cflags</a>, <a href="#lua_dependency.github-extra_fmt_vars">extra_fmt_vars</a>, <a href="#lua_dependency.github-out_binaries">out_binaries</a>, <a href="#lua_dependency.github-rockspec_path">rockspec_path</a>,
                      <a href="#lua_dependency.github-sha256">sha256</a>, <a href="#lua_dependency.github-tag">tag</a>, <a href="#lua_dependency.github-user">user</a>)
</pre>


**TAG CLASSES**

<a id="lua_dependency.luarocks"></a>

### luarocks

Fetch a dependency from luarocks

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_dependency.luarocks-dependency"></a>dependency |  name of dependency on luarocks   | String | required |  |
| <a id="lua_dependency.luarocks-extra_cflags"></a>extra_cflags |  extra CFLAGS to pass to compilation   | List of strings | optional |  `[]`  |
| <a id="lua_dependency.luarocks-out_binaries"></a>out_binaries |  List of binaries which should be produced   | List of strings | optional |  `[]`  |
| <a id="lua_dependency.luarocks-sha256"></a>sha256 |  sha256 of dependency   | String | optional |  `""`  |
| <a id="lua_dependency.luarocks-user"></a>user |  user on luarocks that uploaded the dependency   | String | required |  |
| <a id="lua_dependency.luarocks-version"></a>version |  version of dependency   | String | required |  |

<a id="lua_dependency.busted"></a>

### busted

get a version of busted

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |

<a id="lua_dependency.github"></a>

### github

Fetch a dependency from a url. Expects there to be a .rockspec file in the top level, or in the path specified by rockspec_path

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_dependency.github-deps"></a>deps |  lua deps   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="lua_dependency.github-dependency"></a>dependency |  name of dependency   | String | required |  |
| <a id="lua_dependency.github-extra_cflags"></a>extra_cflags |  extra CFLAGS to pass to compilation   | List of strings | optional |  `[]`  |
| <a id="lua_dependency.github-extra_fmt_vars"></a>extra_fmt_vars |  any extra things to pass to format external_dependency_template.   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  `{}`  |
| <a id="lua_dependency.github-out_binaries"></a>out_binaries |  binaries to produce   | List of strings | optional |  `[]`  |
| <a id="lua_dependency.github-rockspec_path"></a>rockspec_path |  Possible sub-path to rockspec path in the downloaded content. Defaults to the top level   | String | optional |  `""`  |
| <a id="lua_dependency.github-sha256"></a>sha256 |  expected hash   | String | optional |  `""`  |
| <a id="lua_dependency.github-tag"></a>tag |  tag on github   | String | required |  |
| <a id="lua_dependency.github-user"></a>user |  username on github that uploaded the dependency   | String | required |  |


