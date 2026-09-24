local Material = {}
Material.__index = Material

function Material.new(opts)
    opts = opts or {}
    local self = setmetatable({}, Material)
    self.texture = opts.texture
    self.tint = opts.tint or {1.0, 1.0, 1.0}
    return self
end

function Material:apply(shader)
    local t = self.tint
    shader:setVec3("uTint", t[1], t[2], t[3])

    if self.texture then
        self.texture:bind(0)
        shader:setInt("uTexture", 0)
        shader:setBool("uUseTexture", true)
    else
        shader:setBool("uUseTexture", false)
    end
end

return Material