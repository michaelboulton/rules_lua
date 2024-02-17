<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies

<a id="lua_register_system_toolchain"></a>

## lua_register_system_toolchain

<pre>
lua_register_system_toolchain(<a href="#lua_register_system_toolchain-lua_path">lua_path</a>, <a href="#lua_register_system_toolchain-name">name</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lua_register_system_toolchain-lua_path"></a>lua_path |  <p align="center"> - </p>   |  none |
| <a id="lua_register_system_toolchain-name"></a>name |  <p align="center"> - </p>   |  `"lua"` |


<a id="lua_repositories"></a>

## lua_repositories

<pre>
lua_repositories(<a href="#lua_repositories-name">name</a>, <a href="#lua_repositories-lua_repository_name">lua_repository_name</a>, <a href="#lua_repositories-platform">platform</a>, <a href="#lua_repositories-repo_mapping">repo_mapping</a>)
</pre>

Fetch external tools needed for lua toolchain

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_repositories-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="lua_repositories-lua_repository_name"></a>lua_repository_name |  -   | String | required |  |
| <a id="lua_repositories-platform"></a>platform |  -   | String | required |  |
| <a id="lua_repositories-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |


<a id="lua_system_repositories"></a>

## lua_system_repositories

<pre>
lua_system_repositories(<a href="#lua_system_repositories-name">name</a>, <a href="#lua_system_repositories-repo_mapping">repo_mapping</a>, <a href="#lua_system_repositories-target_tool_path">target_tool_path</a>)
</pre>

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_system_repositories-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="lua_system_repositories-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |
| <a id="lua_system_repositories-target_tool_path"></a>target_tool_path |  -   | String | required |  |


<a id="lua_toolchains"></a>

## lua_toolchains

<pre>
lua_toolchains = use_extension("@rules_lua//lua:repositories.bzl", "lua_toolchains")
lua_toolchains.lua(<a href="#lua_toolchains.lua-name">name</a>, <a href="#lua_toolchains.lua-version">version</a>)
lua_toolchains.luajit(<a href="#lua_toolchains.luajit-name">name</a>, <a href="#lua_toolchains.luajit-version">version</a>)
</pre>


**TAG CLASSES**

<a id="lua_toolchains.lua"></a>

### lua

initialise lua toolchain

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_toolchains.lua-name"></a>name |  register toolchain repo with this name   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | optional |  `"lua"`  |
| <a id="lua_toolchains.lua-version"></a>version |  version of lua SDK   | String | optional |  `"v5.1.1"`  |

<a id="lua_toolchains.luajit"></a>

### luajit

initialise luajit toolchain

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_toolchains.luajit-name"></a>name |  register toolchain repo with this name   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | optional |  `"luajit"`  |
| <a id="lua_toolchains.luajit-version"></a>version |  version of luajit SDK   | String | optional |  `"v2.1"`  |


