local Camera = {}
Camera.__index = Camera

local rad = math.rad
local cos, sin = math.cos, math.sin

local function vec3_normalize(x, y, z)
    local len = math.sqrt(x*x + y*y + z*z)
    if len < 1e-6 then return 0, 0, 0 end
    return x / len, y / len, z / len
end

local function vec3_cross(ax, ay, az, bx, by, bz)
    return ay*bz - az*by, az*bx - ax*bz, ax*by - ay*bx
end

function Camera.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Camera)

    self.posX = opts.x or 0.0
    self.posY = opts.y or 0.0
    self.posZ = opts.z or 3.0

    self.yaw   = opts.yaw or -90.0
    self.pitch = opts.pitch or 0.0

    self.moveSpeed   = opts.moveSpeed or 3.0
    self.sprintMult  = opts.sprintMult or 2.5
    self.mouseSens   = opts.mouseSens or 0.10

    self.upX, self.upY, self.upZ = 0.0, 1.0, 0.0

    self:_updateVectors()
    return self
end

function Camera:_updateVectors()
    local yawR, pitchR = rad(self.yaw), rad(self.pitch)

    local fx = cos(yawR) * cos(pitchR)
    local fy = sin(pitchR)
    local fz = sin(yawR) * cos(pitchR)
    self.frontX, self.frontY, self.frontZ = vec3_normalize(fx, fy, fz)

    self.rightX, self.rightY, self.rightZ = vec3_normalize(
        vec3_cross(self.frontX, self.frontY, self.frontZ, 0, 1, 0)
    )
end

function Camera:updateLook(input)
    self.yaw   = self.yaw + input.mouseDX * self.mouseSens
    self.pitch = self.pitch - input.mouseDY * self.mouseSens

    if self.pitch > 89.0 then self.pitch = 89.0 end
    if self.pitch < -89.0 then self.pitch = -89.0 end

    self:_updateVectors()
end

function Camera:update(input, dt)
    self.yaw   = self.yaw + input.mouseDX * self.mouseSens
    self.pitch = self.pitch - input.mouseDY * self.mouseSens

    if self.pitch > 89.0 then self.pitch = 89.0 end
    if self.pitch < -89.0 then self.pitch = -89.0 end

    self:_updateVectors()

    local speed = self.moveSpeed
    if input:isDown("LEFT_SHIFT") then
        speed = speed * self.sprintMult
    end
    local d = speed * dt

    if input:isDown("W") then
        self.posX = self.posX + self.frontX * d
        self.posY = self.posY + self.frontY * d
        self.posZ = self.posZ + self.frontZ * d
    end
    if input:isDown("S") then
        self.posX = self.posX - self.frontX * d
        self.posY = self.posY - self.frontY * d
        self.posZ = self.posZ - self.frontZ * d
    end
    if input:isDown("A") then
        self.posX = self.posX - self.rightX * d
        self.posY = self.posY - self.rightY * d
        self.posZ = self.posZ - self.rightZ * d
    end
    if input:isDown("D") then
        self.posX = self.posX + self.rightX * d
        self.posY = self.posY + self.rightY * d
        self.posZ = self.posZ + self.rightZ * d
    end
    if input:isDown("SPACE") then
        self.posY = self.posY + d
    end
    if input:isDown("LEFT_CONTROL") then
        self.posY = self.posY - d
    end
end
function Camera:getViewMatrix()
    local eyeX, eyeY, eyeZ = self.posX, self.posY, self.posZ
    local cx, cy, cz = eyeX + self.frontX, eyeY + self.frontY, eyeZ + self.frontZ
    local fx, fy, fz = self.frontX, self.frontY, self.frontZ
    
    local sx, sy, sz = vec3_normalize(vec3_cross(fx, fy, fz, self.upX, self.upY, self.upZ))
    local ux, uy, uz = vec3_cross(sx, sy, sz, fx, fy, fz)
    return {
        sx,        ux,        -fx,       0,
        sy,        uy,        -fy,       0,
        sz,        uz,        -fz,       0,
        -(sx*eyeX + sy*eyeY + sz*eyeZ),
        -(ux*eyeX + uy*eyeY + uz*eyeZ),
         (fx*eyeX + fy*eyeY + fz*eyeZ),
        1,
    }
end

return Camera