local function compileShader(shaderType, source)
    local shader = gl.glCreateShader(shaderType)
    local src = ffi.new("const char*[1]", {source})
    gl.glShaderSource(shader, 1, src, nil)
    gl.glCompileShader(shader)

    local status = ffi.new("GLint[1]")
    gl.glGetShaderiv(shader, GL_COMPILE_STATUS, status)
    if status[0] == 0 then
        local log = ffi.new("char[512]")
        gl.glGetShaderInfoLog(shader, 512, nil, log)
        error("Shader derleme hatası: " .. ffi.string(log))
    end
    return shader
end

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

local function toFFI(m)
    return ffi.new("GLfloat[16]", m)
end

local vertexShaderSrc = [[
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;

uniform mat4 uModel;
uniform mat4 uProj;

out vec3 vColor;

void main()
{
    gl_Position = uProj * uModel * vec4(aPos, 1.0);
    vColor = aColor;
}
]]

local fragmentShaderSrc = [[
#version 330 core
in vec3 vColor;
out vec4 FragColor;

void main()
{
    FragColor = vec4(vColor, 1.0);
}
]]

-- Window
glfw.glfwInit()
glfw.glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MAJOR, 3)
glfw.glfwWindowHint(GLFW.GLFW_CONTEXT_VERSION_MINOR, 3)
glfw.glfwWindowHint(GLFW.GLFW_OPENGL_PROFILE, GLFW.GLFW_OPENGL_CORE_PROFILE)

local WIDTH, HEIGHT = 800, 600
window = glfw.glfwCreateWindow(WIDTH, HEIGHT, "LuaJIT GL binding", nil, nil)

if window == nil then
    print("Failed to create window")
    glfw.glfwTerminate()
    return -1
end
glfw.glfwMakeContextCurrent(window)
glfw.glfwSwapInterval(1)

gl.glEnable(GL_DEPTH_TEST)
gl.glDepthFunc(GL_LESS)

local vertexShader = compileShader(GL_VERTEX_SHADER, vertexShaderSrc)
local fragmentShader = compileShader(GL_FRAGMENT_SHADER, fragmentShaderSrc)

local shaderProgram = gl.glCreateProgram()
gl.glAttachShader(shaderProgram, vertexShader)
gl.glAttachShader(shaderProgram, fragmentShader)
gl.glLinkProgram(shaderProgram)

local linkStatus = ffi.new("GLint[1]")
gl.glGetProgramiv(shaderProgram, GL_LINK_STATUS, linkStatus)
if linkStatus[0] == 0 then
    local log = ffi.new("char[512]")
    gl.glGetProgramInfoLog(shaderProgram, 512, nil, log)
end

gl.glDeleteShader(vertexShader)
gl.glDeleteShader(fragmentShader)

local modelLocation = gl.glGetUniformLocation(shaderProgram, "uModel")
local projLocation  = gl.glGetUniformLocation(shaderProgram, "uProj")

local vertices = ffi.new("GLfloat[48]", {
    -- x,    y,    z,     r,    g,    b
    -0.5, -0.5, -0.5,   1.0,  0.0,  0.0,
     0.5, -0.5, -0.5,   0.0,  1.0,  0.0,
     0.5,  0.5, -0.5,   0.0,  0.0,  1.0,
    -0.5,  0.5, -0.5,   1.0,  1.0,  0.0,
    -0.5, -0.5,  0.5,   1.0,  0.0,  1.0,
     0.5, -0.5,  0.5,   0.0,  1.0,  1.0,
     0.5,  0.5,  0.5,   1.0,  1.0,  1.0,
    -0.5,  0.5,  0.5,   0.2,  0.2,  0.2,
})

local indices = ffi.new("GLuint[36]", {
    0, 1, 2,   2, 3, 0,
    4, 5, 6,   6, 7, 4,
    4, 0, 3,   3, 7, 4,
    1, 5, 6,   6, 2, 1,
    3, 2, 6,   6, 7, 3,
    4, 5, 1,   1, 0, 4,
})

local VAO = ffi.new("GLuint[1]")
local VBO = ffi.new("GLuint[1]")
local EBO = ffi.new("GLuint[1]")

gl.glGenVertexArrays(1, VAO)
gl.glGenBuffers(1, VBO)
gl.glGenBuffers(1, EBO)

gl.glBindVertexArray(VAO[0])

gl.glBindBuffer(GL_ARRAY_BUFFER, VBO[0])
gl.glBufferData(GL_ARRAY_BUFFER, ffi.sizeof(vertices), vertices, GL_STATIC_DRAW)

gl.glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO[0])
gl.glBufferData(GL_ELEMENT_ARRAY_BUFFER, ffi.sizeof(indices), indices, GL_STATIC_DRAW)

gl.glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 6 * ffi.sizeof("GLfloat"), ffi.cast("void*", 0))
gl.glEnableVertexAttribArray(0)

gl.glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE, 6 * ffi.sizeof("GLfloat"), ffi.cast("void*", 3 * ffi.sizeof("GLfloat")))
gl.glEnableVertexAttribArray(1)

gl.glBindBuffer(GL_ARRAY_BUFFER, 0)
gl.glBindVertexArray(0)

local projMatrix = toFFI(Mat4.perspective(math.rad(45), WIDTH / HEIGHT, 0.1, 100.0))

local keyCallback = ffi.cast("GLFWkeyfun", function(win, key, scancode, action, mods)
    if key == GLFW.GLFW_KEY_ESCAPE and action == GLFW.GLFW_PRESS then
        glfw.glfwSetWindowShouldClose(win, GLFW.GLFW_TRUE)
    end
end)
glfw.glfwSetKeyCallback(window, keyCallback)

while glfw.glfwWindowShouldClose(window) == 0 do
    local time = glfw.glfwGetTime()

    gl.glClearColor(0.08, 0.08, 0.1, 1.0)
    gl.glClear(bit.bor(GL_COLOR_BUFFER_BIT, GL_DEPTH_BUFFER_BIT))

    gl.glUseProgram(shaderProgram)
    
    local rotation = Mat4.rotateXY(time * 0.7, time)
    local translation = Mat4.translate(0.0, 0.0, -3.0)
    local model = Mat4.mul(translation, rotation)

    gl.glUniformMatrix4fv(modelLocation, 1, GL_FALSE, toFFI(model))
    gl.glUniformMatrix4fv(projLocation, 1, GL_FALSE, projMatrix)

    gl.glBindVertexArray(VAO[0])
    gl.glDrawElements(GL_TRIANGLES, 36, GL_UNSIGNED_INT, nil)

    glfw.glfwSwapBuffers(window)
    glfw.glfwPollEvents()
end

gl.glDeleteVertexArrays(1, VAO)
gl.glDeleteBuffers(1, VBO)
gl.glDeleteBuffers(1, EBO)
gl.glDeleteProgram(shaderProgram)
keyCallback:free()

glfw.glfwDestroyWindow(window)
glfw.glfwTerminate()