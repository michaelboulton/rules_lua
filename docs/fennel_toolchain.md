<!-- Generated with Stardoc: http://skydoc.bazel.build -->

This module implements the language-specific toolchain rule.

<a id="fennel_toolchain"></a>

## fennel_toolchain

<pre>
fennel_toolchain(<a href="#fennel_toolchain-name">name</a>, <a href="#fennel_toolchain-extra_tool_files">extra_tool_files</a>, <a href="#fennel_toolchain-target_tool">target_tool</a>)
</pre>

Defines a fennel compiler/runtime toolchain.

For usage see https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.

**ATTRIBUTES**


| Name  | Description | Type | Mandatory | Default |
| :------------- | :------------- | :------------- | :------------- | :------------- |
| <a id="fennel_toolchain-name"></a>name |  A unique name for this target.   | <a href="https://bazel.build/concepts/labels#target-names">Name</a> | required |  |
| <a id="fennel_toolchain-extra_tool_files"></a>extra_tool_files |  -   | <a href="https://bazel.build/concepts/labels">List of labels</a> | optional |  `[]`  |
| <a id="fennel_toolchain-target_tool"></a>target_tool |  A hermetically downloaded executable target for the target platform.   | <a href="https://bazel.build/concepts/labels">Label</a> | required |  |


<a id="FennelInfo"></a>

## FennelInfo

<pre>
FennelInfo(<a href="#FennelInfo-target_tool">target_tool</a>, <a href="#FennelInfo-tool_files">tool_files</a>)
</pre>

Information about how to invoke the tool executable.

**FIELDS**


| Name  | Description |
| :------------- | :------------- |
| <a id="FennelInfo-target_tool"></a>target_tool |  Path to the tool executable for the target platform.    |
| <a id="FennelInfo-tool_files"></a>tool_files |  Files required in runfiles to make the tool executable available.<br><br>May be empty if the target_tool_path points to a locally installed tool binary.    |


