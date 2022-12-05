<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies


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
| <a id="fennel_repositories-repo_mapping"></a>repo_mapping |  A dictionary from local repository name to global repository name. This allows controls over workspace dependency resolution for dependencies of this repository.&lt;p&gt;For example, an entry <code>"@foo": "@bar"</code> declares that, for any time this repository depends on <code>@foo</code> (such as a dependency on <code>@foo//some:target</code>, it should actually resolve that dependency within globally-declared <code>@bar</code> (<code>@bar//some:target</code>).   | <a href="https://bazel.build/rules/lib/dict">Dictionary: String -> String</a> | required |  |
| <a id="fennel_repositories-version"></a>version |  -   | String | required |  |


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
| <a id="fennel_register_toolchains-version"></a>version |  <p align="center"> - </p>   |  <code>"1.2.1"</code> |
| <a id="fennel_register_toolchains-kwargs"></a>kwargs |  passed to each node_repositories call   |  none |


