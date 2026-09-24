local Mat4 = {}

function Mat4.identity()
    return {
        1,0,0,0,
        0,1,0,0,
        0,0,1,0,
        0,0,0,1,
    }
end

function Mat4.mul(a, b)
    local r = {}
    for col = 0, 3 do
        for row = 0, 3 do
            local sum = 0
            for k = 0, 3 do
                sum = sum + a[k*4 + row + 1] * b[col*4 + k + 1]
            end
            r[col*4 + row + 1] = sum
        end
    end
    return r
end

function Mat4.perspective(fovyRad, aspect, near, far)
    local f = 1.0 / math.tan(fovyRad / 2)
    local m = {}
    for i = 1, 16 do m[i] = 0 end
    m[1]  = f / aspect
    m[6]  = f
    m[11] = (far + near) / (near - far)
    m[12] = -1
    m[15] = (2 * far * near) / (near - far)
    return m
end

function Mat4.translate(x, y, z)
    local m = Mat4.identity()
    m[13] = x
    m[14] = y
    m[15] = z
    return m
end

function Mat4.rotateXY(angleX, angleY)
    local cx, sx = math.cos(angleX), math.sin(angleX)
    local cy, sy = math.cos(angleY), math.sin(angleY)

    local rx = {
        1, 0, 0, 0,
        0, cx, sx, 0,
        0, -sx, cx, 0,
        0, 0, 0, 1,
    }
    local ry = {
        cy, 0, -sy, 0,
        0, 1, 0, 0,
        sy, 0, cy, 0,
        0, 0, 0, 1,
    }
    return Mat4.mul(ry, rx)
end

return Mat4