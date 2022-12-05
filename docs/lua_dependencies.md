<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies


<a id="lua_repositories"></a>

## lua_repositories

<pre>
lua_repositories(<a href="#lua_repositories-name">name</a>, <a href="#lua_repositories-platform">platform</a>, <a href="#lua_repositories-repo_mapping">repo_mapping</a>)
</pre>

Fetch external tools needed for lua toolchain

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_repositories-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="lua_repositories-platform"></a>platform |  -   | String | required |  |
| <a id="lua_repositories-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |


<a id="lua_system_repositories"></a>

## lua_system_repositories

<pre>
lua_system_repositories(<a href="#lua_system_repositories-name">name</a>, <a href="#lua_system_repositories-repo_mapping">repo_mapping</a>, <a href="#lua_system_repositories-target_tool_path">target_tool_path</a>)
</pre>



**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="lua_system_repositories-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="lua_system_repositories-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="lua_system_repositories-target_tool_path"></a>target_tool_path |  -   | String | required |  |


<a id="lua_register_system_toolchain"></a>

## lua_register_system_toolchain

<pre>
lua_register_system_toolchain(<a href="#lua_register_system_toolchain-lua_path">lua_path</a>, <a href="#lua_register_system_toolchain-name">name</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lua_register_system_toolchain-lua_path"></a>lua_path |  <p align="center"> - </p>   |  none |
| <a id="lua_register_system_toolchain-name"></a>name |  <p align="center"> - </p>   |  <code>"lua"</code> |


<a id="lua_register_toolchains"></a>

## lua_register_toolchains

<pre>
lua_register_toolchains(<a href="#lua_register_toolchains-name">name</a>, <a href="#lua_register_toolchains-version">version</a>, <a href="#lua_register_toolchains-kwargs">kwargs</a>)
</pre>

Convenience macro for users which does typical setup.

- create a repository for each built-in platform like "lua_linux_amd64" -
  this repository is lazily fetched when node is needed for that platform.
- TODO: create a convenience repository for the host platform like "lua_host"
- create a repository exposing toolchains for each platform like "lua_platforms"
- register a toolchain pointing at each platform
Users can avoid this macro and do these steps themselves, if they want more control.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="lua_register_toolchains-name"></a>name |  base name for all created repos, like "lua1_14"   |  <code>"lua"</code> |
| <a id="lua_register_toolchains-version"></a>version |  <p align="center"> - </p>   |  <code>"v5.1.1"</code> |
| <a id="lua_register_toolchains-kwargs"></a>kwargs |  passed to each node_repositories call   |  none |


<a id="luajit_register_toolchains"></a>

## luajit_register_toolchains

<pre>
luajit_register_toolchains(<a href="#luajit_register_toolchains-name">name</a>, <a href="#luajit_register_toolchains-version">version</a>, <a href="#luajit_register_toolchains-kwargs">kwargs</a>)
</pre>

Convenience macro for users which does typical setup.

- create a repository for each built-in platform like "lua_linux_amd64" -
  this repository is lazily fetched when node is needed for that platform.
- TODO: create a convenience repository for the host platform like "lua_host"
- create a repository exposing toolchains for each platform like "lua_platforms"
- register a toolchain pointing at each platform
Users can avoid this macro and do these steps themselves, if they want more control.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="luajit_register_toolchains-name"></a>name |  base name for all created repos, like "lua1_14"   |  <code>"lua"</code> |
| <a id="luajit_register_toolchains-version"></a>version |  <p align="center"> - </p>   |  <code>"v2.1"</code> |
| <a id="luajit_register_toolchains-kwargs"></a>kwargs |  passed to each node_repositories call   |  none |


