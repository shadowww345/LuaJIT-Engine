local ogl = require("gl")
local ffi = require("ffi")

local Shader = {}
Shader.__index = Shader

local function compile(shaderType, source)
    local shader = ogl.gl.glCreateShader(shaderType)
    local src = ffi.new("const char*[1]", {source})
    ogl.gl.glShaderSource(shader, 1, src, nil)
    ogl.gl.glCompileShader(shader)

    local status = ffi.new("GLint[1]")
    ogl.gl.glGetShaderiv(shader, ogl.GL_COMPILE_STATUS, status)
    if status[0] == 0 then
        local log = ffi.new("char[512]")
        ogl.gl.glGetShaderInfoLog(shader, 512, nil, log)
        error("Shader derleme hatası: " .. ffi.string(log))
    end
    return shader
end

function Shader.new(vertexSrc, fragmentSrc)
    local self = setmetatable({}, Shader)

    local vs = compile(ogl.GL_VERTEX_SHADER, vertexSrc)
    local fs = compile(ogl.GL_FRAGMENT_SHADER, fragmentSrc)

    local program = ogl.gl.glCreateProgram()
    ogl.gl.glAttachShader(program, vs)
    ogl.gl.glAttachShader(program, fs)
    ogl.gl.glLinkProgram(program)

    local linkStatus = ffi.new("GLint[1]")
    ogl.gl.glGetProgramiv(program, ogl.GL_LINK_STATUS, linkStatus)
    if linkStatus[0] == 0 then
        local log = ffi.new("char[512]")
        ogl.gl.glGetProgramInfoLog(program, 512, nil, log)
        error("Shader link hatası: " .. ffi.string(log))
    end

    ogl.gl.glDeleteShader(vs)
    ogl.gl.glDeleteShader(fs)

    self.program = program
    self.uniformCache = {}
    return self
end

function Shader:use()
    ogl.gl.glUseProgram(self.program)
end

function Shader:destroy()
    ogl.gl.glDeleteProgram(self.program)
end

function Shader:_location(name)
    local loc = self.uniformCache[name]
    if loc == nil then
        loc = ogl.gl.glGetUniformLocation(self.program, name)
        self.uniformCache[name] = loc
    end
    return loc
end

function Shader:setMat4(name, m)
    local ptr = m
    if type(m) == "table" then
        ptr = ffi.new("GLfloat[16]", m)
    end
    ogl.gl.glUniformMatrix4fv(self:_location(name), 1, ogl.GL_FALSE, ptr)
end

function Shader:setVec3(name, x, y, z)
    ogl.gl.glUniform3f(self:_location(name), x, y, z)
end

function Shader:setFloat(name, v)
    ogl.gl.glUniform1f(self:_location(name), v)
end

function Shader:setInt(name, v)
    ogl.gl.glUniform1i(self:_location(name), v)
end

function Shader:setBool(name, v)
    ogl.gl.glUniform1i(self:_location(name), v and 1 or 0)
end

return Shader