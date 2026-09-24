local Transform = require("transform")
local RigidBody = require("rigidbody")
local Collider = require("collider")

local PlayerController = {}
PlayerController.__index = PlayerController
function PlayerController.new(opts)
    opts = opts or {}
    local self = setmetatable({}, PlayerController)

    local halfWidth  = opts.halfWidth or 0.35
    local halfHeight = opts.halfHeight or 0.9
    self.halfHeight = halfHeight
    self.eyeHeight = opts.eyeHeight or 1.6

    local feetX, feetY, feetZ = opts.x or 0, opts.y or 0, opts.z or 0
    self.transform = Transform.new({ x = feetX, y = feetY + halfHeight, z = feetZ })
    self.collider  = Collider.newBox(halfWidth, halfHeight, halfWidth)
    self.rigidbody = RigidBody.new({
        mass = opts.mass or 70,
        restitution = 0,
        friction = 0.85,
    })

    self.moveSpeed  = opts.moveSpeed or 4.5
    self.sprintMult = opts.sprintMult or 1.6
    self.jumpSpeed  = opts.jumpSpeed or 5.0

    return self
end

function PlayerController:update(dt, input, camera)
    camera:updateLook(input)

    local fx, fz = camera.frontX, camera.frontZ
    local flen = math.sqrt(fx*fx + fz*fz)
    if flen > 1e-6 then fx, fz = fx/flen, fz/flen else fx, fz = 0, 0 end

    local rx, rz = camera.rightX, camera.rightZ
    local rlen = math.sqrt(rx*rx + rz*rz)
    if rlen > 1e-6 then rx, rz = rx/rlen, rz/rlen else rx, rz = 0, 0 end

    local moveX, moveZ = 0, 0
    if input:isDown("W") then moveX = moveX + fx; moveZ = moveZ + fz end
    if input:isDown("S") then moveX = moveX - fx; moveZ = moveZ - fz end
    if input:isDown("D") then moveX = moveX + rx; moveZ = moveZ + rz end
    if input:isDown("A") then moveX = moveX - rx; moveZ = moveZ - rz end

    local mlen = math.sqrt(moveX*moveX + moveZ*moveZ)
    if mlen > 1e-6 then moveX, moveZ = moveX/mlen, moveZ/mlen end

    local speed = self.moveSpeed
    if input:isDown("LEFT_SHIFT") then speed = speed * self.sprintMult end

    self.rigidbody.velocity.x = moveX * speed
    self.rigidbody.velocity.z = moveZ * speed

    if input:wasPressed("SPACE") and self.rigidbody.isGrounded then
        self.rigidbody.velocity.y = self.jumpSpeed
    end
end

function PlayerController:syncCamera(camera)
    camera.posX = self.transform.x
    camera.posY = self.transform.y - self.halfHeight + self.eyeHeight
    camera.posZ = self.transform.z
end

return PlayerController