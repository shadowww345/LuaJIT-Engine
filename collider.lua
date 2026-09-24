local Collider = {}

function Collider.newBox(hx, hy, hz)
    return { type = "box", hx = hx, hy = hy, hz = hz }
end

function Collider.newSphere(radius)
    return { type = "sphere", radius = radius }
end

return Collider