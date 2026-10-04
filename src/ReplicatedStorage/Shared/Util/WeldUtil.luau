--[[
	WeldUtil
	Welds every part of a model/accessory/tool to one root part, keeping their current
	positions. This is why models can be edited freely in Studio: welds are rebuilt here.
]]

local WeldUtil = {}

-- Welds all BaseParts under `container` to `root`. Set `unanchor` to let it move with physics.
function WeldUtil.weldTo(container: Instance, root: BasePart, unanchor: boolean?)
	for _, descendant in container:GetDescendants() do
		if descendant:IsA("BasePart") and descendant ~= root then
			local weld = Instance.new("WeldConstraint")
			weld.Name = "AutoWeld"
			weld.Part0 = root
			weld.Part1 = descendant
			weld.Parent = descendant
			if unanchor then
				descendant.Anchored = false
			end
		end
	end
	if unanchor then
		root.Anchored = false
	end
end

-- Removes welds previously created by weldTo (e.g. before re-welding an edited model).
function WeldUtil.clear(container: Instance)
	for _, descendant in container:GetDescendants() do
		if descendant:IsA("WeldConstraint") and descendant.Name == "AutoWeld" then
			descendant:Destroy()
		end
	end
end

return WeldUtil
