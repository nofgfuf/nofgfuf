--[[
	Mover
	Physics handles on the character's HumanoidRootPart used by the parkour moves:
	  setPlaneVelocity(v)  push horizontally (gravity still works)  - slide, dive, roll
	  hold(cframe)         pin the character in place / move it along - ledge hang, climb
]]

local Mover = {}
Mover.__index = Mover

function Mover.new(root: BasePart)
	local self = setmetatable({}, Mover)

	local attachment = Instance.new("Attachment")
	attachment.Name = "MovementAttachment"
	attachment.Parent = root

	local velocity = Instance.new("LinearVelocity")
	velocity.Name = "MovementVelocity"
	velocity.Attachment0 = attachment
	velocity.RelativeTo = Enum.ActuatorRelativeTo.World
	velocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
	velocity.PrimaryTangentAxis = Vector3.xAxis
	velocity.SecondaryTangentAxis = Vector3.zAxis
	velocity.MaxForce = 100000
	velocity.Enabled = false
	velocity.Parent = root

	local position = Instance.new("AlignPosition")
	position.Name = "MovementHoldPosition"
	position.Mode = Enum.PositionAlignmentMode.OneAttachment
	position.Attachment0 = attachment
	position.RigidityEnabled = true
	position.Enabled = false
	position.Parent = root

	local orientation = Instance.new("AlignOrientation")
	orientation.Name = "MovementHoldOrientation"
	orientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	orientation.Attachment0 = attachment
	orientation.RigidityEnabled = true
	orientation.Enabled = false
	orientation.Parent = root

	self.velocity = velocity
	self.position = position
	self.orientation = orientation
	return self
end

function Mover:setPlaneVelocity(v: Vector3)
	self.velocity.PlaneVelocity = Vector2.new(v.X, v.Z)
	self.velocity.Enabled = true
end

function Mover:clearVelocity()
	self.velocity.Enabled = false
end

function Mover:hold(cframe: CFrame)
	self.position.Position = cframe.Position
	self.orientation.CFrame = cframe
	self.position.Enabled = true
	self.orientation.Enabled = true
end

function Mover:release()
	self.position.Enabled = false
	self.orientation.Enabled = false
end

return Mover
