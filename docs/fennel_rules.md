<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="fennel_binary"></a>

## fennel_binary

<pre>
fennel_binary(<a href="#fennel_binary-name">name</a>, <a href="#fennel_binary-deps">deps</a>, <a href="#fennel_binary-data">data</a>, <a href="#fennel_binary-tool">tool</a>)
</pre>

Fennel binary target. Will run the given tool with the registered fennel toolchain.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fennel_binary-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fennel_binary-deps"></a>deps |  Runtime dependencies of target   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fennel_binary-data"></a>data |  extra files to be available at runtime   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fennel_binary-tool"></a>tool |  fennel file to run   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="fennel_library"></a>

## fennel_library

<pre>
fennel_library(<a href="#fennel_library-name">name</a>, <a href="#fennel_library-deps">deps</a>, <a href="#fennel_library-srcs">srcs</a>, <a href="#fennel_library-macros">macros</a>, <a href="#fennel_library-preprocessor">preprocessor</a>, <a href="#fennel_library-strip_prefix">strip_prefix</a>)
</pre>

Library of fennel, compiled all src files into one big lua file

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fennel_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fennel_library-deps"></a>deps |  fennel deps   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fennel_library-srcs"></a>srcs |  fennel srcs   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="fennel_library-macros"></a>macros |  fennel macros required for compilation, but will not be compiled into the library and left as .fnl files   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fennel_library-preprocessor"></a>preprocessor |  Processes fennel files into a format suitable for passing to the fennel compiler without any extra magic flags that need passing   | <a href="https://bazel.build/concepts/labels">Label</a> | optional |  `None`  |
| <a id="fennel_library-strip_prefix"></a>strip_prefix |  Strip prefix from files before compiling   | String | optional |  `""`  |


