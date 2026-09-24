local ogl = require("gl")
local ffi = require("ffi")

local Texture = {}
Texture.__index = Texture

local GL_TEXTURE_2D        = 0x0DE1
local GL_RGB               = 0x1907
local GL_UNSIGNED_BYTE     = 0x1401
local GL_TEXTURE_MIN_FILTER= 0x2801
local GL_TEXTURE_MAG_FILTER= 0x2800
local GL_TEXTURE_WRAP_S    = 0x2802
local GL_TEXTURE_WRAP_T    = 0x2803
local GL_LINEAR            = 0x2601
local GL_LINEAR_MIPMAP_LINEAR = 0x2703
local GL_REPEAT            = 0x2901
local GL_TEXTURE0          = 0x84C0

local function u16(s, i)
    local a, b = s:byte(i, i+1)
    return a + b*256
end

local function u32(s, i)
    local a, b, c, d = s:byte(i, i+3)
    return a + b*256 + c*65536 + d*16777216
end

local function i32(s, i)
    local v = u32(s, i)
    if v >= 0x80000000 then v = v - 0x100000000 end
    return v
end

local function loadBMP(path)
    local f, err = io.open(path, "rb")
    if not f then
        error("BMP opening error: " .. path .. " (" .. tostring(err) .. ")")
    end
    local data = f:read("*a")
    f:close()

    if data:sub(1, 2) ~= "BM" then
        error("invalid bmp header: " .. path)
    end

    local pixelOffset   = u32(data, 11)
    local headerSize    = u32(data, 15)
    local width         = i32(data, 19)
    local heightRaw     = i32(data, 23)
    local bpp           = u16(data, 29)
    local compression   = u32(data, 31)

    if compression ~= 0 then
        error("Only uncompressed bmp's supported: " .. path)
    end
    if bpp ~= 24 and bpp ~= 32 then
        error("Only 24 bit or 32 bit bmp's supported: " .. bpp .. "-bit): " .. path)
    end

    local topDown = heightRaw < 0
    local height = math.abs(heightRaw)
    local bytesPerPixel = bpp / 8
    local rowSize = math.floor((bpp * width + 31) / 32) * 4
    local rowDataSize = width * bytesPerPixel
    local pixels = ffi.new("uint8_t[?]", width * height * 3)

    for row = 0, height - 1 do
        local srcRow = topDown and (height - 1 - row) or row
        local rowStart = pixelOffset + srcRow * rowSize + 1

        for col = 0, width - 1 do
            local srcIdx = rowStart + col * bytesPerPixel
            local b = data:byte(srcIdx)
            local g = data:byte(srcIdx + 1)
            local r = data:byte(srcIdx + 2)

            local dstIdx = (row * width + col) * 3
            pixels[dstIdx]     = r
            pixels[dstIdx + 1] = g
            pixels[dstIdx + 2] = b
        end
    end

    return pixels, width, height
end

function Texture.new(path, opts)
    opts = opts or {}
    local self = setmetatable({}, Texture)

    local pixels, width, height = loadBMP(path)

    local id = ffi.new("GLuint[1]")
    ogl.gl.glGenTextures(1, id)
    ogl.gl.glBindTexture(GL_TEXTURE_2D, id[0])

    local wrap = (opts.repeatWrap == false) and 0x812F --[[GL_CLAMP_TO_EDGE]] or GL_REPEAT
    ogl.gl.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, wrap)
    ogl.gl.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, wrap)
    ogl.gl.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR)
    ogl.gl.glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR)

    ogl.gl.glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, width, height, 0, GL_RGB, GL_UNSIGNED_BYTE, pixels)

    ogl.gl.glBindTexture(GL_TEXTURE_2D, 0)

    self.id = id
    self.width, self.height = width, height
    return self
end

function Texture:bind(unit)
    unit = unit or 0
    ogl.gl.glActiveTexture(GL_TEXTURE0 + unit)
    ogl.gl.glBindTexture(GL_TEXTURE_2D, self.id[0])
end

function Texture:destroy()
    ogl.gl.glDeleteTextures(1, self.id)
end

return Texture