local Mesh = require("mesh")

local OBJ = {}

local function vec3Normalize(x, y, z)
    local len = math.sqrt(x*x + y*y + z*z)
    if len < 1e-8 then return 0, 0, 0 end
    return x/len, y/len, z/len
end

local function vec3Cross(ax, ay, az, bx, by, bz)
    return ay*bz - az*by, az*bx - ax*bz, ax*by - ay*bx
end

local function parseFaceToken(tok)
    local vIdx, vtIdx, vnIdx = tok:match("^(%d+)/(%d*)/(%d*)$")
    if vIdx then
        return tonumber(vIdx), tonumber(vtIdx), tonumber(vnIdx)
    end
    vIdx, vtIdx = tok:match("^(%d+)/(%d+)$")
    if vIdx then
        return tonumber(vIdx), tonumber(vtIdx), nil
    end
    vIdx = tok:match("^(%d+)$")
    return tonumber(vIdx), nil, nil
end

function OBJ.parse(path, opts)
    opts = opts or {}
    local color = opts.color or {1.0, 1.0, 1.0}
    local cr, cg, cb = color[1], color[2], color[3]

    local f, err = io.open(path, "r")
    if not f then
        error("OBJ açılamadı: " .. path .. " (" .. tostring(err) .. ")")
    end

    local positions = {}
    local uvs = {}
    local normals = {}
    local hasNormals = false

    local rawFaces = {}

    for line in f:lines() do
        local tag, rest = line:match("^(%S+)%s+(.*)$")
        if tag == "v" then
            local x, y, z = rest:match("^(%S+)%s+(%S+)%s+(%S+)")
            positions[#positions+1] = tonumber(x)
            positions[#positions+1] = tonumber(y)
            positions[#positions+1] = tonumber(z)
        elseif tag == "vt" then
            local u, v = rest:match("^(%S+)%s+(%S+)")
            uvs[#uvs+1] = tonumber(u)
            uvs[#uvs+1] = 1.0 - tonumber(v)
        elseif tag == "vn" then
            local x, y, z = rest:match("^(%S+)%s+(%S+)%s+(%S+)")
            normals[#normals+1] = tonumber(x)
            normals[#normals+1] = tonumber(y)
            normals[#normals+1] = tonumber(z)
            hasNormals = true
        elseif tag == "f" then
            local face = {}
            for tok in rest:gmatch("%S+") do
                local vIdx, vtIdx, vnIdx = parseFaceToken(tok)
                face[#face+1] = { vIdx, vtIdx, vnIdx }
            end
            rawFaces[#rawFaces+1] = face
        end
    end
    f:close()

    local vertices = {}
    local indices = {}
    local vertexMap = {}

    local function getPos(vIdx)
        return positions[(vIdx-1)*3+1], positions[(vIdx-1)*3+2], positions[(vIdx-1)*3+3]
    end
    local function getUV(vtIdx)
        if not vtIdx then return 0, 0 end
        return uvs[(vtIdx-1)*2+1] or 0, uvs[(vtIdx-1)*2+2] or 0
    end
    local function getNormal(vnIdx)
        if not vnIdx then return nil end
        return normals[(vnIdx-1)*3+1], normals[(vnIdx-1)*3+2], normals[(vnIdx-1)*3+3]
    end

    local function emitVertex(px, py, pz, nx, ny, nz, u, v)
        local idx = #vertices / 11
        vertices[#vertices+1] = px
        vertices[#vertices+1] = py
        vertices[#vertices+1] = pz
        vertices[#vertices+1] = nx
        vertices[#vertices+1] = ny
        vertices[#vertices+1] = nz
        vertices[#vertices+1] = cr
        vertices[#vertices+1] = cg
        vertices[#vertices+1] = cb
        vertices[#vertices+1] = u
        vertices[#vertices+1] = v
        return idx
    end

    for _, face in ipairs(rawFaces) do
        if hasNormals then            local emitted = {}
            for _, tok in ipairs(face) do
                local vIdx, vtIdx, vnIdx = tok[1], tok[2], tok[3]
                local key = vIdx .. "/" .. (vtIdx or 0) .. "/" .. (vnIdx or 0)
                local existing = vertexMap[key]
                if not existing then
                    local px, py, pz = getPos(vIdx)
                    local u, v = getUV(vtIdx)
                    local nx, ny, nz = getNormal(vnIdx)
                    nx, ny, nz = nx or 0, ny or 1, nz or 0
                    existing = emitVertex(px, py, pz, nx, ny, nz, u, v)
                    vertexMap[key] = existing
                end
                emitted[#emitted+1] = existing
            end
            for i = 2, #emitted - 1 do
                indices[#indices+1] = emitted[1]
                indices[#indices+1] = emitted[i]
                indices[#indices+1] = emitted[i+1]
            end
        else
            local pts = {}
            for _, tok in ipairs(face) do
                local px, py, pz = getPos(tok[1])
                pts[#pts+1] = { px, py, pz, tok[2] }
            end
            for i = 2, #pts - 1 do
                local v0, v1, v2 = pts[1], pts[i], pts[i+1]
                local ux, uy, uz = v1[1]-v0[1], v1[2]-v0[2], v1[3]-v0[3]
                local wx, wy, wz = v2[1]-v0[1], v2[2]-v0[2], v2[3]-v0[3]
                local nx, ny, nz = vec3Normalize(vec3Cross(ux, uy, uz, wx, wy, wz))

                local i0 = emitVertex(v0[1], v0[2], v0[3], nx, ny, nz, getUV(v0[4]))
                local i1 = emitVertex(v1[1], v1[2], v1[3], nx, ny, nz, getUV(v1[4]))
                local i2 = emitVertex(v2[1], v2[2], v2[3], nx, ny, nz, getUV(v2[4]))
                indices[#indices+1] = i0
                indices[#indices+1] = i1
                indices[#indices+1] = i2
            end
        end
    end

    return {
        vertices = vertices,
        indices = indices,
        vertexCount = #vertices / 11,
    }
end

function OBJ.loadMesh(path, opts)
    local data = OBJ.parse(path, opts)
    return Mesh.new(data.vertices, data.indices), data
end

return OBJ