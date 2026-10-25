<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Declare runtime dependencies

These are needed for local dev, and users must install them as well.
See https://docs.bazel.build/versions/main/skylark/deploying.html#dependencies

<a id="fennel_repositories"></a>

## fennel_repositories

<pre>
load("@rules_lua//fennel:repositories.bzl", "fennel_repositories")

fennel_repositories(<a href="#fennel_repositories-name">name</a>, <a href="#fennel_repositories-version">version</a>)
</pre>

Fetch external tools needed for fennel toolchain

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fennel_repositories-name"></a>name |  A unique name for this repository.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fennel_repositories-version"></a>version |  -   | String | required |  |


<a id="fennel_toolchains"></a>

## fennel_toolchains

<pre>
fennel_toolchains = use_extension("@rules_lua//fennel:repositories.bzl", "fennel_toolchains")
fennel_toolchains.fennel(<a href="#fennel_toolchains.fennel-name">name</a>, <a href="#fennel_toolchains.fennel-version">version</a>)
</pre>


**TAG CLASSES**

<a id="fennel_toolchains.fennel"></a>

### fennel

initialise fennel toolchain

**Attributes**

| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fennel_toolchains.fennel-name"></a>name |  register toolchain repo with this name   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | optional |  `"fennel"`  |
| <a id="fennel_toolchains.fennel-version"></a>version |  version of SDK   | String | optional |  `"1.4.0"`  |


