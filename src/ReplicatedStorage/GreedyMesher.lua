local Mesher = {}

local function canMerge(part1: Instance, part2: Instance, excludeAxis: string, mergeProperties: Array<any>)
	local equalAxises = 0

	local equalPosAxises = 0

	for _, axisEnum in pairs(Enum.Axis:GetEnumItems()) do
		local axis = axisEnum.Name

		local diff = math.abs(part1.Position[axis] - part2.Position[axis])

		if diff <= 0.02 then
			equalPosAxises += 1

			if equalPosAxises == 2 then
				break
			end
		end
	end

	if equalPosAxises < 2 then
		return
	end

	for _, axisEnum in pairs(Enum.Axis:GetEnumItems()) do
		local axis = axisEnum.Name

		if axis == excludeAxis then
			continue
		end

		local diff = math.abs(part1.Size[axis] - part2.Size[axis])
		local isPartOfSameGroup = part1.Color == part2.Color and part1.Material == part2.Material --placeholder
		local orientationMatch = part1.Orientation == part2.Orientation

		if diff <= 0.1 and orientationMatch and isPartOfSameGroup then
			equalAxises += 1

			if equalAxises == 2 then
				return true
			end
		end
	end
end

function Mesher:MergeNearby(part: Instance, OP: OverlapParams, mergeProperties: Array<any>)
	if part.Parent then
		return
	end

	-- if no overlap params is supplied, merge with anything
	if not OP then
		OP = OverlapParams.new()
		OP.FilterType = Enum.RaycastFilterType.Whitelist
		OP.FilterDescendantsInstances = {workspace}
	end

	for _, axisEnum in pairs(Enum.Axis:GetEnumItems()) do
		local axis = axisEnum.Name

		local mult = -1

		local extend = CFrame.new(
			axis == "X" and part.Size.X / 2 * mult or 0,
			axis == "Y" and part.Size.Y / 2 * mult or 0,
			axis == "Z" and part.Size.Z / 2 * mult or 0
		)

		local origin = part.CFrame * extend

		local boundSize = mergeProperties.BoundSize or Vector3.new(0.001, 0.001, 0.001)
		local touching = workspace:GetPartBoundsInBox(origin, boundSize, OP)

		for i = 1, #touching do
			local touchPart = touching[i]

			if touchPart == part then
				continue
			end

			if not touchPart:IsA("Part") then
				continue
			end

			if not canMerge(part, touchPart, axis, mergeProperties) then
				continue
			end

			if mergeProperties.Filter then
				if not mergeProperties.Filter(part, touchPart, axis) then
					continue
				end
			end

			local mergeSize = Vector3.new(
				axis == "X" and touchPart.Size.X or 0,
				axis == "Y" and touchPart.Size.Y or 0,
				axis == "Z" and touchPart.Size.Z or 0
			)

			local mergePosition = Vector3.new(
				axis == "X" and -touchPart.Size.X / 2 or 0,
				axis == "Y" and -touchPart.Size.Y / 2 or 0,
				axis == "Z" and -touchPart.Size.Z / 2 or 0
			)

			part.CFrame *= CFrame.new(mergePosition)
			part.Size += mergeSize

			touchPart:Destroy()

			self:MergeNearby(part, OP, mergeProperties)

			return
		end
	end
end

function Mesher:MergeParts(parts: Array<Instance>, mergeProperties: Array<any>)
	local OP = OverlapParams.new()
	OP.FilterType = Enum.RaycastFilterType.Whitelist
	OP.FilterDescendantsInstances = {parts}

	for _, part in pairs(parts) do
		self:MergeNearby(part, OP, mergeProperties)
	end
end

return Mesher
