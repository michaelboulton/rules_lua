<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies

<a id="fennel_register_toolchains"></a>

## fennel_register_toolchains

<pre>
fennel_register_toolchains(<a href="#fennel_register_toolchains-name">name</a>, <a href="#fennel_register_toolchains-version">version</a>, <a href="#fennel_register_toolchains-kwargs">kwargs</a>)
</pre>

Convenience macro for users which does typical setup.

- create a repository exposing toolchains for each platform like "fennel_platforms"
- register a toolchain pointing at each platform
Users can avoid this macro and do these steps themselves, if they want more control.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="fennel_register_toolchains-name"></a>name |  base name for all created repos, like "fennel1_14"   |  none |
| <a id="fennel_register_toolchains-version"></a>version |  <p align="center"> - </p>   |  `"1.2.1"` |
| <a id="fennel_register_toolchains-kwargs"></a>kwargs |  passed to each node_repositories call   |  none |


<a id="fennel_repositories"></a>

## fennel_repositories

<pre>
fennel_repositories(<a href="#fennel_repositories-name">name</a>, <a href="#fennel_repositories-repo_mapping">repo_mapping</a>, <a href="#fennel_repositories-version">version</a>)
</pre>

Fetch external tools needed for fennel toolchain

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fennel_repositories-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fennel_repositories-repo_mapping"></a>repo_mapping |  In `WORKSPACE` context only: a dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.<br><br>For example, an entry `"@foo": "@bar"` declares that, for any time this repository depends on `@foo` (such as a dependency on `@foo//some:target`, it should actually resolve that dependency within globally-declared `@bar` (`@bar//some:target`).<br><br>This attribute is _not_ supported in `MODULE.bazel` context (when invoking a repository rule inside a module extension's implementation function).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | optional |  |
| <a id="fennel_repositories-version"></a>version |  -   | String | required |  |


<a id="fennel_toolchains"></a>

## fennel_toolchains

<pre>
fennel_toolchains = use_extension("@rules_lua//fennel:repositories.bzl", "fennel_toolchains")
fennel_toolchains.fennel(<a href="#fennel_toolchains.fennel-version">version</a>)
</pre>


**TAG CLASSES**

<a id="fennel_toolchains.fennel"></a>

### fennel

initialise fennel toolchain

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fennel_toolchains.fennel-version"></a>version |  version of SDK   | String | optional |  `"1.2.1"`  |


