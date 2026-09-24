local RigidBody = {}
RigidBody.__index = RigidBody

function RigidBody.new(opts)
    opts = opts or {}
    local self = setmetatable({}, RigidBody)

    self.isStatic = opts.isStatic or false
    self.useGravity = (opts.useGravity ~= false) and not self.isStatic
    self.mass = opts.mass or 1.0
    self.invMass = self.isStatic and 0 or (1.0 / self.mass)
    self.restitution = opts.restitution or 0.3
    self.friction = opts.friction or 0.9

    self.velocity = { x = 0, y = 0, z = 0 }

    return self
end

function RigidBody:addVelocity(x, y, z)
    self.velocity.x = self.velocity.x + x
    self.velocity.y = self.velocity.y + y
    self.velocity.z = self.velocity.z + z
end

function RigidBody:setVelocity(x, y, z)
    self.velocity.x, self.velocity.y, self.velocity.z = x, y, z
end

return RigidBody