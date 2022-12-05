<!-- Generated with Stardoc: http://skydoc.bazel.build -->

Public API re-exports

<a id="fennel_library"></a>

## fennel_library

<pre>
fennel_library(<a href="#fennel_library-name">name</a>, <a href="#fennel_library-deps">deps</a>, <a href="#fennel_library-macros">macros</a>, <a href="#fennel_library-preprocessor">preprocessor</a>, <a href="#fennel_library-srcs">srcs</a>, <a href="#fennel_library-strip_prefix">strip_prefix</a>)
</pre>

Library of fennel, compiled all src files into one big lua file

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fennel_library-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fennel_library-deps"></a>deps |  fennel deps   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | [] |
| <a id="fennel_library-macros"></a>macros |  fennel macros required for compilation, but will not be compiled into the library and left as .fnl files   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional | [] |
| <a id="fennel_library-preprocessor"></a>preprocessor |  Processes fennel files into a format suitable for passing to the fennel compiler without any extra magic flags that need passing   | <a href="https://bazel.build/concepts/labels">Label</a> | optional | None |
| <a id="fennel_library-srcs"></a>srcs |  fennel srcs   | <a href="https://bazel.build/concepts/labels">List of labels</a> | required |  |
| <a id="fennel_library-strip_prefix"></a>strip_prefix |  Strip prefix from files before compiling   | String | optional | "" |


<a id="aniseed_library"></a>

## aniseed_library

<pre>
aniseed_library(<a href="#aniseed_library-macros">macros</a>, <a href="#aniseed_library-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="aniseed_library-macros"></a>macros |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="aniseed_library-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="aniseed_test"></a>

## aniseed_test

<pre>
aniseed_test(<a href="#aniseed_test-deps">deps</a>, <a href="#aniseed_test-macros">macros</a>, <a href="#aniseed_test-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="aniseed_test-deps"></a>deps |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="aniseed_test-macros"></a>macros |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="aniseed_test-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="fennel_busted_test"></a>

## fennel_busted_test

<pre>
fennel_busted_test(<a href="#fennel_busted_test-deps">deps</a>, <a href="#fennel_busted_test-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="fennel_busted_test-deps"></a>deps |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="fennel_busted_test-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


<a id="fennel_luaunit_test"></a>

## fennel_luaunit_test

<pre>
fennel_luaunit_test(<a href="#fennel_luaunit_test-deps">deps</a>, <a href="#fennel_luaunit_test-kwargs">kwargs</a>)
</pre>



**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="fennel_luaunit_test-deps"></a>deps |  <p align="center"> - </p>   |  <code>[]</code> |
| <a id="fennel_luaunit_test-kwargs"></a>kwargs |  <p align="center"> - </p>   |  none |


