local OBJ = require("obj")
local Mesh = require("mesh")

local KeyframeMesh = {}
KeyframeMesh.__index = KeyframeMesh

local FLOATS_PER_VERTEX = 11
function KeyframeMesh.new(framePaths, opts)
    opts = opts or {}
    local self = setmetatable({}, KeyframeMesh)

    assert(#framePaths >= 1, "KeyframeMesh: en az 1 frame gerekli")

    self.fps = opts.fps or 10
    self.loop = (opts.loop ~= false)
    self.time = 0
    self.frames = {}
    
    local base = OBJ.parse(framePaths[1], { color = opts.color })
    self.indices = base.indices
    self.vertexCount = base.vertexCount
    self.baseVertices = base.vertices

    self.frames[1] = self:_extractPositions(base.vertices)

    for i = 2, #framePaths do
        local frameData = OBJ.parse(framePaths[i], { color = opts.color })
        if frameData.vertexCount ~= self.vertexCount then
            error(string.format(
                "KeyframeMesh: '%s' dosyasının vertex sayısı (%d) ilk frame ile (%d) uyuşmuyor. "
                .. "Tüm frame'ler aynı topolojiye sahip olmalı.",
                framePaths[i], frameData.vertexCount, self.vertexCount))
        end
        self.frames[i] = self:_extractPositions(frameData.vertices)
    end

    self.mesh = Mesh.new(base.vertices, base.indices, true)

    self.workBuffer = {}
    for i = 1, #self.baseVertices do self.workBuffer[i] = self.baseVertices[i] end

    return self
end

function KeyframeMesh:_extractPositions(flatVertices)
    local positions = {}
    for i = 0, self.vertexCount - 1 do
        positions[i*3+1] = flatVertices[i*FLOATS_PER_VERTEX+1]
        positions[i*3+2] = flatVertices[i*FLOATS_PER_VERTEX+2]
        positions[i*3+3] = flatVertices[i*FLOATS_PER_VERTEX+3]
    end
    return positions
end

function KeyframeMesh:update(dt)
    local frameCount = #self.frames
    if frameCount <= 1 then return end

    self.time = self.time + dt
    local totalDuration = frameCount / self.fps

    local t
    if self.loop then
        t = (self.time % totalDuration) / totalDuration
    else
        t = math.min(self.time / totalDuration, 1.0)
    end

    local floatFrame = t * frameCount
    local frameA = math.floor(floatFrame) % frameCount
    local frameB = (frameA + 1) % frameCount
    local lerp = floatFrame - math.floor(floatFrame)

    local posA = self.frames[frameA + 1]
    local posB = self.frames[frameB + 1]

    for i = 0, self.vertexCount - 1 do
        local ax, ay, az = posA[i*3+1], posA[i*3+2], posA[i*3+3]
        local bx, by, bz = posB[i*3+1], posB[i*3+2], posB[i*3+3]

        local base = i * FLOATS_PER_VERTEX
        self.workBuffer[base+1] = ax + (bx - ax) * lerp
        self.workBuffer[base+2] = ay + (by - ay) * lerp
        self.workBuffer[base+3] = az + (bz - az) * lerp
    end

    self.mesh:updateVertices(self.workBuffer)
end

function KeyframeMesh:draw()
    self.mesh:draw()
end

function KeyframeMesh:destroy()
    self.mesh:destroy()
end

return KeyframeMesh