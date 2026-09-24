local Mat4 = require("mat4")

local Transform = {}
Transform.__index = Transform

function Transform.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Transform)

    self.x, self.y, self.z = opts.x or 0, opts.y or 0, opts.z or 0
    self.rotX, self.rotY = opts.rotX or 0, opts.rotY or 0 -- radyan
    self.scale = opts.scale or 1.0

    return self
end

function Transform:getMatrix()
    local rotation    = Mat4.rotateXY(self.rotX, self.rotY)
    local translation = Mat4.translate(self.x, self.y, self.z)

    if self.scale ~= 1.0 then
        local s = self.scale
        local scaleM = {
            s, 0, 0, 0,
            0, s, 0, 0,
            0, 0, s, 0,
            0, 0, 0, 1,
        }
        return Mat4.mul(translation, Mat4.mul(rotation, scaleM))
    end

    return Mat4.mul(translation, rotation)
end

return Transform