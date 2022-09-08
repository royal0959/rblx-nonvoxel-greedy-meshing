# rblx-nonvoxel-greedy-meshing
module for merging parts that don't need to be adhere to voxel grids

<h1>Functions</h1>
<code>Mesher:MergeNearby(part: Instance, OP: OverlapParams, mergeProperties: Array<any>)</code> <br>
Attempt to merge part with nearby compatible parts. OP and mergeProperties are optional, if an OverlapParams is not provided, part can merge with any parts in workspace

<br>Example:
<br><pre><code>mesher:MergeNearby(workspace.Part)</code></pre>

<hr> 

<code>Mesher:MergeParts(parts: Array<Instance>, mergeProperties: Array<any>)</code> <br>
Attempt to merge provided parts with eachother. mergeProperties is optional

<br>Example:
<br><pre><code>mesher:MergeParts(workspace.Folder:GetChildren())</code></pre>

<h1>Merge Properties</h1>
mergeProperties can be provided as a parameter in dictionary format to define merge rules and filter <br>
Currently, there are 2 merge properties:
<hr>
<code>mergeProperties.BoundSize: Vector3</code> <br>
Changes the size of collision bounds used to find parts to merge around a part, default is Vector3.new(0.001, 0.001, 0.001). Not recommendeded to be changed lest you know what you're doing
<hr>
<code>mergeProperties.Filter: function(part, touchPart, axis)</code> <br>
Defines extra criteria(s) for merging. If the function returns true, parts will not be merged and vice versa. Can be used for cases such as restricting specific marked parts from being merged <br><br>

Example:
<pre><code>
local disallowedName = "NO_MERGE"
local mergeProperties = {
	Filter = function(part, touchPart, axis)
		-- don't allow merge to go through if this check passes
		if part.Name == disallowedName or touchPart.Name == disallowedName then
			return false
		end
		
		return true
	end,
}

mesher:MergeParts(workspace.Folder:GetChildren(), mergeProperties)
</code></pre>
