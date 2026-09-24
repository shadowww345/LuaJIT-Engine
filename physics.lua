local Physics = {}
Physics.__index = Physics

function Physics.newWorld(opts)
    opts = opts or {}
    local self = setmetatable({}, Physics)
    local g = opts.gravity or { 0, -9.81, 0 }
    self.gravity = { x = g[1], y = g[2], z = g[3] }
    self.bodies = {}
    return self
end

function Physics:addBody(obj)
    assert(obj.transform and obj.rigidbody and obj.collider, "Physics:addBody: transform/rigidbody/collider gerekli")
    table.insert(self.bodies, obj)
end

local function worldAABB(obj)
    local t, c = obj.transform, obj.collider
    return t.x - c.hx, t.y - c.hy, t.z - c.hz,   t.x + c.hx, t.y + c.hy, t.z + c.hz
end

local function resolveBoxBox(a, b)
    local aMinX, aMinY, aMinZ, aMaxX, aMaxY, aMaxZ = worldAABB(a)
    local bMinX, bMinY, bMinZ, bMaxX, bMaxY, bMaxZ = worldAABB(b)

    local overlapX = math.min(aMaxX, bMaxX) - math.max(aMinX, bMinX)
    local overlapY = math.min(aMaxY, bMaxY) - math.max(aMinY, bMinY)
    local overlapZ = math.min(aMaxZ, bMaxZ) - math.max(aMinZ, bMinZ)

    if overlapX <= 0 or overlapY <= 0 or overlapZ <= 0 then return end
    local rbA, rbB = a.rigidbody, b.rigidbody
    local totalInvMass = rbA.invMass + rbB.invMass
    if totalInvMass == 0 then return end

    if overlapX <= overlapY and overlapX <= overlapZ then
        local dir = (a.transform.x < b.transform.x) and -1 or 1
        local pushA = dir * overlapX * (rbA.invMass / totalInvMass)
        local pushB = -dir * overlapX * (rbB.invMass / totalInvMass)
        a.transform.x = a.transform.x + pushA
        b.transform.x = b.transform.x + pushB
        local rel = rbA.velocity.x - rbB.velocity.x
        if rel * dir < 0 then
            local restitution = math.min(rbA.restitution, rbB.restitution)
            local impulse = -(1 + restitution) * rel / totalInvMass
            rbA.velocity.x = rbA.velocity.x + impulse * rbA.invMass
            rbB.velocity.x = rbB.velocity.x - impulse * rbB.invMass
        end
    elseif overlapY <= overlapX and overlapY <= overlapZ then
        local dir = (a.transform.y < b.transform.y) and -1 or 1
        local pushA = dir * overlapY * (rbA.invMass / totalInvMass)
        local pushB = -dir * overlapY * (rbB.invMass / totalInvMass)
        a.transform.y = a.transform.y + pushA
        b.transform.y = b.transform.y + pushB

        if a.transform.y > b.transform.y then
            if not rbA.isStatic then rbA.isGrounded = true end
        else
            if not rbB.isStatic then rbB.isGrounded = true end
        end

        local rel = rbA.velocity.y - rbB.velocity.y
        if rel * dir < 0 then
            local restitution = math.min(rbA.restitution, rbB.restitution)
            local impulse = -(1 + restitution) * rel / totalInvMass
            rbA.velocity.y = rbA.velocity.y + impulse * rbA.invMass
            rbB.velocity.y = rbB.velocity.y - impulse * rbB.invMass
            if dir == 1 and rbA.invMass > 0 then
                rbA.velocity.x = rbA.velocity.x * rbA.friction
                rbA.velocity.z = rbA.velocity.z * rbA.friction
            elseif dir == -1 and rbB.invMass > 0 then
                rbB.velocity.x = rbB.velocity.x * rbB.friction
                rbB.velocity.z = rbB.velocity.z * rbB.friction
            end
        end
    else
        local dir = (a.transform.z < b.transform.z) and -1 or 1
        local pushA = dir * overlapZ * (rbA.invMass / totalInvMass)
        local pushB = -dir * overlapZ * (rbB.invMass / totalInvMass)
        a.transform.z = a.transform.z + pushA
        b.transform.z = b.transform.z + pushB
        local rel = rbA.velocity.z - rbB.velocity.z
        if rel * dir < 0 then
            local restitution = math.min(rbA.restitution, rbB.restitution)
            local impulse = -(1 + restitution) * rel / totalInvMass
            rbA.velocity.z = rbA.velocity.z + impulse * rbA.invMass
            rbB.velocity.z = rbB.velocity.z - impulse * rbB.invMass
        end
    end
end

local function resolveSphereSphere(a, b)
    local dx = b.transform.x - a.transform.x
    local dy = b.transform.y - a.transform.y
    local dz = b.transform.z - a.transform.z
    local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
    local minDist = a.collider.radius + b.collider.radius

    if dist >= minDist or dist < 1e-6 then return end

    local nx, ny, nz = dx/dist, dy/dist, dz/dist
    local penetration = minDist - dist

    local rbA, rbB = a.rigidbody, b.rigidbody
    local totalInvMass = rbA.invMass + rbB.invMass
    if totalInvMass == 0 then return end

    a.transform.x = a.transform.x - nx * penetration * (rbA.invMass / totalInvMass)
    a.transform.y = a.transform.y - ny * penetration * (rbA.invMass / totalInvMass)
    a.transform.z = a.transform.z - nz * penetration * (rbA.invMass / totalInvMass)
    b.transform.x = b.transform.x + nx * penetration * (rbB.invMass / totalInvMass)
    b.transform.y = b.transform.y + ny * penetration * (rbB.invMass / totalInvMass)
    b.transform.z = b.transform.z + nz * penetration * (rbB.invMass / totalInvMass)

    local rvx = rbB.velocity.x - rbA.velocity.x
    local rvy = rbB.velocity.y - rbA.velocity.y
    local rvz = rbB.velocity.z - rbA.velocity.z
    local velAlongNormal = rvx*nx + rvy*ny + rvz*nz
    if velAlongNormal > 0 then return end

    local restitution = math.min(rbA.restitution, rbB.restitution)
    local j = -(1 + restitution) * velAlongNormal / totalInvMass

    rbA.velocity.x = rbA.velocity.x - j * rbA.invMass * nx
    rbA.velocity.y = rbA.velocity.y - j * rbA.invMass * ny
    rbA.velocity.z = rbA.velocity.z - j * rbA.invMass * nz
    rbB.velocity.x = rbB.velocity.x + j * rbB.invMass * nx
    rbB.velocity.y = rbB.velocity.y + j * rbB.invMass * ny
    rbB.velocity.z = rbB.velocity.z + j * rbB.invMass * nz
end

local function resolveSphereBox(sphereObj, boxObj)
    local sMinX, sMinY, sMinZ
    local bMinX, bMinY, bMinZ, bMaxX, bMaxY, bMaxZ = worldAABB(boxObj)

    local sx, sy, sz = sphereObj.transform.x, sphereObj.transform.y, sphereObj.transform.z
    local closestX = math.max(bMinX, math.min(sx, bMaxX))
    local closestY = math.max(bMinY, math.min(sy, bMaxY))
    local closestZ = math.max(bMinZ, math.min(sz, bMaxZ))

    local dx, dy, dz = sx - closestX, sy - closestY, sz - closestZ
    local dist = math.sqrt(dx*dx + dy*dy + dz*dz)
    local radius = sphereObj.collider.radius

    if dist >= radius or dist < 1e-6 then return end

    local nx, ny, nz = dx/dist, dy/dist, dz/dist
    local penetration = radius - dist

    local rbS, rbB = sphereObj.rigidbody, boxObj.rigidbody
    local totalInvMass = rbS.invMass + rbB.invMass
    if totalInvMass == 0 then return end

    sphereObj.transform.x = sphereObj.transform.x + nx * penetration * (rbS.invMass / totalInvMass)
    sphereObj.transform.y = sphereObj.transform.y + ny * penetration * (rbS.invMass / totalInvMass)
    sphereObj.transform.z = sphereObj.transform.z + nz * penetration * (rbS.invMass / totalInvMass)
    boxObj.transform.x = boxObj.transform.x - nx * penetration * (rbB.invMass / totalInvMass)
    boxObj.transform.y = boxObj.transform.y - ny * penetration * (rbB.invMass / totalInvMass)
    boxObj.transform.z = boxObj.transform.z - nz * penetration * (rbB.invMass / totalInvMass)

    local velAlongNormal = rbS.velocity.x*nx + rbS.velocity.y*ny + rbS.velocity.z*nz
    if velAlongNormal < 0 then
        local restitution = math.min(rbS.restitution, rbB.restitution)
        local j = -(1 + restitution) * velAlongNormal
        rbS.velocity.x = rbS.velocity.x + j * nx
        rbS.velocity.y = rbS.velocity.y + j * ny
        rbS.velocity.z = rbS.velocity.z + j * nz

        if ny > 0.7 then
            rbS.velocity.x = rbS.velocity.x * rbS.friction
            rbS.velocity.z = rbS.velocity.z * rbS.friction
            if not rbS.isStatic then rbS.isGrounded = true end
        end
    end
end

local MAX_DT = 1/30

function Physics:step(dt)
    dt = math.min(dt, MAX_DT)
    for _, obj in ipairs(self.bodies) do
        if obj.rigidbody and not obj.rigidbody.isStatic then
            obj.rigidbody.isGrounded = false
        end
    end
    
    for _, obj in ipairs(self.bodies) do
        local rb = obj.rigidbody
        if not rb.isStatic then
            if rb.useGravity then
                rb.velocity.x = rb.velocity.x + self.gravity.x * dt
                rb.velocity.y = rb.velocity.y + self.gravity.y * dt
                rb.velocity.z = rb.velocity.z + self.gravity.z * dt
            end
            obj.transform.x = obj.transform.x + rb.velocity.x * dt
            obj.transform.y = obj.transform.y + rb.velocity.y * dt
            obj.transform.z = obj.transform.z + rb.velocity.z * dt
        end
    end
    local n = #self.bodies
    for i = 1, n do
        for j = i + 1, n do
            local a, b = self.bodies[i], self.bodies[j]
            if not (a.rigidbody.isStatic and b.rigidbody.isStatic) then
                local ta, tb = a.collider.type, b.collider.type
                if ta == "box" and tb == "box" then
                    resolveBoxBox(a, b)
                elseif ta == "sphere" and tb == "sphere" then
                    resolveSphereSphere(a, b)
                elseif ta == "sphere" and tb == "box" then
                    resolveSphereBox(a, b)
                elseif ta == "box" and tb == "sphere" then
                    resolveSphereBox(b, a)
                end
            end
        end
    end
end

return Physics