local ogl = require("gl")
local ffi = require("ffi")
local bit = require("bit")
local Input = require("input")
local Camera = require("camera")
local Mat4 = require("mat4")
local Mesh = require("mesh")
local Transform = require("transform")
local Shader = require("shader")
local Texture = require("texture")
local Material = require("material")
local OBJ = require("obj")
local KeyframeMesh = require("keyframe_mesh")
local RigidBody = require("rigidbody")
local Collider = require("collider")
local Physics = require("physics")
local PlayerController = require("player_controller")
local aten= ffi.load("atenaudio")
ffi.cdef[[
   int set_volume(int volume);
   float get_volume();
   int set_channels(int channels);
   int get_channels();
   int set_samplerate(int samplerate);
   int get_samplerate();
   int set_loop(int enabled);
   int get_loop();
   int stop_loop();
   int stop_sound();
   int stop_engine();
   int reverb(float roomsize,float damp,float wet,float dry,float width);
   int playsound(const char *format,const char *name);
   int ateninit();
   void reverb_init(void);

void reverb_set_roomsize(float value);
void reverb_set_damp(float value);
void reverb_set_wet(float value);
void reverb_set_dry(float value);
void reverb_set_width(float value);
void reverb_process_replace_stereo(float *interleaved, int nframes, int channels);
]]
local function toFFI(m)
    return ffi.new("GLfloat[16]", m)
end

local vertexShaderSrc = [[
#version 330 core
layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aNormal;
layout (location = 2) in vec3 aColor;
layout (location = 3) in vec2 aUV;

uniform mat4 uModel;
uniform mat4 uView;
uniform mat4 uProj;

out vec3 vColor;
out vec2 vUV;
out vec3 vNormal;

void main()
{
    gl_Position = uProj * uView * uModel * vec4(aPos, 1.0);
    vColor = aColor;
    vUV = aUV;
    vNormal = mat3(uModel) * aNormal;
}
]]

local fragmentShaderSrc = [[
#version 330 core
in vec3 vColor;
in vec2 vUV;
in vec3 vNormal;
out vec4 FragColor;

uniform sampler2D uTexture;
uniform bool uUseTexture;
uniform vec3 uTint;

uniform vec3 uLightDir;
uniform vec3 uLightColor;
uniform vec3 uAmbient;

void main()
{
    vec3 baseColor;
    if (uUseTexture) {
        baseColor = texture(uTexture, vUV).rgb;
    } else {
        baseColor = vColor;
    }

    vec3 norm = normalize(vNormal);
    float diff = max(dot(norm, -uLightDir), 0.0);
    vec3 lighting = uAmbient + diff * uLightColor;

    FragColor = vec4(baseColor * uTint * lighting, 1.0);
}
]]

-- Window
ogl.glfw.glfwInit()
ogl.glfw.glfwWindowHint(ogl.GLFW.GLFW_CONTEXT_VERSION_MAJOR, 3)
ogl.glfw.glfwWindowHint(ogl.GLFW.GLFW_CONTEXT_VERSION_MINOR, 3)
ogl.glfw.glfwWindowHint(ogl.GLFW.GLFW_OPENGL_PROFILE, ogl.GLFW.GLFW_OPENGL_CORE_PROFILE)

local WIDTH, HEIGHT = 2560, 1920
local window = ogl.glfw.glfwCreateWindow(WIDTH, HEIGHT, "LuaJIT GL binding", nil, nil)

if window == nil then
    print("Failed to create window")
    ogl.glfw.glfwTerminate()
    return -1
end
ogl.glfw.glfwMakeContextCurrent(window)
ogl.glfw.glfwSwapInterval(1)

ogl.gl.glEnable(ogl.GL_DEPTH_TEST)
ogl.gl.glDepthFunc(ogl.GL_LESS)

local shader = Shader.new(vertexShaderSrc, fragmentShaderSrc)

local projMatrix = toFFI(Mat4.perspective(math.rad(90), WIDTH / HEIGHT, 0.1, 100.0))

local keyCallback = ffi.cast("GLFWkeyfun", function(win, key, scancode, action, mods)
    if key == ogl.GLFW.GLFW_KEY_ESCAPE and action == ogl.GLFW.GLFW_PRESS then
        ogl.glfw.glfwSetWindowShouldClose(win, ogl.GLFW.GLFW_TRUE)
    end
end)
ogl.glfw.glfwSetKeyCallback(window, keyCallback)

local input = Input.new(window)
ogl.glfw.glfwSetInputMode(window, ogl.GLFW.GLFW_CURSOR, ogl.GLFW.GLFW_CURSOR_DISABLED)

local camera = Camera.new({ x = 0.0, y = 0.0, z = 3.0 })
local lightDirX, lightDirY, lightDirZ
do
    local x, y, z = -0.4, -1.0, -0.3
    local len = math.sqrt(x*x + y*y + z*z)
    lightDirX, lightDirY, lightDirZ = x/len, y/len, z/len
end

local cubeMesh   = Mesh.newCube()
local planeMesh  = Mesh.newPlane(20.0, 1.0, 1.0, 1.0, 4)
local pyramidMesh = Mesh.newPyramid(1.2, 1.5)
local sphereMesh  = Mesh.newSphere(0.7, 20, 16)

local scene = {
    { mesh = planeMesh, transform = Transform.new({ x = 0.0, y = -1.5, z = -5.0 }),
      material = Material.new({ tint = {0.5, 0.5, 0.55} }) },
    { mesh = cubeMesh, transform = Transform.new({ x = 0.0, y = 0.0, z = -3.0 }),
      material = Material.new({ tint = {0.85, 0.85, 0.9} }) },
    { mesh = cubeMesh, transform = Transform.new({ x = 2.5, y = 0.0, z = -5.0, scale = 0.5 }),
      material = Material.new({ tint = {1.0, 0.6, 0.6} }) },
    { mesh = cubeMesh, transform = Transform.new({ x = -2.5, y = 1.0, z = -6.0, scale = 1.5 }),
      material = Material.new({ tint = {0.6, 0.8, 1.0} }) },
    { mesh = pyramidMesh, transform = Transform.new({ x = 4.0, y = -1.5, z = -8.0 }),
      material = Material.new() },
    { mesh = sphereMesh, transform = Transform.new({ x = -4.0, y = -0.8, z = -7.0 }),
      material = Material.new({ tint = {0.4, 0.8, 1.0} }) },
}

local rotatingCubeObj = scene[2] 

scene[1].rigidbody = RigidBody.new({ isStatic = true })
scene[1].collider  = Collider.newBox(10, 0.05, 10)

local fallingCubeObj = {
    mesh = cubeMesh,
    transform = Transform.new({ x = -1.0, y = 5.0, z = -4.0 }),
    material = Material.new({ tint = {1.0, 0.5, 0.3} }),
    rigidbody = RigidBody.new({ mass = 1.0, restitution = 0.35, friction = 0.9 }),
    collider = Collider.newBox(0.5, 0.5, 0.5),
}
table.insert(scene, fallingCubeObj)

local fallingCubeObj2 = {
    mesh = cubeMesh,
    transform = Transform.new({ x = -1.0, y = 1.0, z = -3.0 }),
    material = Material.new({ tint = {1.4, 0.3, 0.1} }),
    rigidbody = RigidBody.new({ mass = 4.0, restitution = 0.56, friction = 0.2 }),
    collider = Collider.newBox(0.5, 0.5, 0.5),
}
table.insert(scene, fallingCubeObj2)

local bouncingSphereObj = {
    mesh = sphereMesh,
    transform = Transform.new({ x = 1.0, y = 7.0, z = -4.0 }),
    material = Material.new({ tint = {0.3, 1.0, 0.5} }),
    rigidbody = RigidBody.new({ mass = 0.8, restitution = 0.75, friction = 0.95 }),
    collider = Collider.newSphere(0.7),
}
table.insert(scene, bouncingSphereObj)

local physicsWorld = Physics.newWorld({ gravity = {0, -9.81, 0} })
physicsWorld:addBody(scene[1])
physicsWorld:addBody(fallingCubeObj)
physicsWorld:addBody(fallingCubeObj2)
physicsWorld:addBody(bouncingSphereObj)

local player = PlayerController.new({ x = 0.0, y = 1.0, z = 3.0 })
physicsWorld:addBody(player)

local physicsResetState = {
    { obj = fallingCubeObj, x = fallingCubeObj.transform.x, y = fallingCubeObj.transform.y, z = fallingCubeObj.transform.z },
    { obj = bouncingSphereObj, x = bouncingSphereObj.transform.x, y = bouncingSphereObj.transform.y, z = bouncingSphereObj.transform.z },
}

local TexturePath = "texture.bmp"
local TexOk, nTexture = pcall(Texture.new, TexturePath)
if TexOk then
    scene[1].material.texture = nTexture
    print("Texture Loaded: " .. TexturePath)
else
    print("Texture not found" .. TexturePath)
end

--local objModelPath = "model.obj"
--local objOk, objMesh = pcall(OBJ.loadMesh, objModelPath, { color = {0.8, 0.8, 0.8} })
--if objOk then
    --table.insert(scene, {
        --mesh = objMesh,
        --transform = Transform.new({ x = 6.0, y = -1.0, z = -6.0, scale = 1.0 }),
        --material = Material.new(),
    --})
    --print("OBJ loaded: " .. objModelPath)
--else
   --print("OBJ not found" .. objModelPath)
--end

--local animFramePaths = {
    --"walk_00.obj",
    --"walk_01.obj",
    --"walk_02.obj",
    --"walk_03.obj",
--}
--local animOk, animatedMesh = pcall(KeyframeMesh.new, animFramePaths, { fps = 8, color = {0.9, 0.7, 0.3} })
--if animOk then
    --table.insert(scene, {
        --mesh = animatedMesh,
        --transform = Transform.new({ x = -6.0, y = -1.0, z = -6.0 }),
        --material = Material.new(),
    --})
    --print("Animation loaded (" .. #animFramePaths .. " frame).")
--else
    --print("Animation loaded.")
--end
aten.ateninit()
local lastTime = ogl.glfw.glfwGetTime()

local footstepTimer = 0
local FOOTSTEP_INTERVAL = 0.55
local FOOTSTEP_INTERVAL_SPRINT = 0.40 
local footsteps = {"foot.wav","foot1.wav","foot2.wav","foot3.wav"}
while ogl.glfw.glfwWindowShouldClose(window) == 0 do
    local currentTime = ogl.glfw.glfwGetTime()
    local dt = currentTime - lastTime
    lastTime = currentTime

    ogl.glfw.glfwPollEvents()
    input:update()
    player:update(dt, input, camera)

    local isMoving = input:isDown("W") or input:isDown("A") or input:isDown("S") or input:isDown("D") or input:isDown("SPACE")
    if isMoving and player.rigidbody.isGrounded then
        footstepTimer = footstepTimer - dt
        if footstepTimer <= 0 then
            local random_index = math.random(#footsteps)
            aten.playsound("wav", footsteps[random_index])
            aten.reverb(0.6,0.3,0.35,0.6,1.0)
            local interval = input:isDown("LEFT_SHIFT") and FOOTSTEP_INTERVAL_SPRINT or FOOTSTEP_INTERVAL
            footstepTimer = interval
        end
    else
        footstepTimer = 0
    end
    if input:wasPressed("R") then
        for _, state in ipairs(physicsResetState) do
            state.obj.transform.x, state.obj.transform.y, state.obj.transform.z = state.x, state.y, state.z
            state.obj.rigidbody:setVelocity(0, 0, 0)
        end
        player.transform.x, player.transform.y, player.transform.z = 0.0, 1.0 + player.halfHeight, 3.0
        player.rigidbody:setVelocity(0, 0, 0)
    end
    
    physicsWorld:step(dt)
    player:syncCamera(camera)

    ogl.gl.glClearColor(0.08, 0.08, 0.1, 1.0)
    ogl.gl.glClear(bit.bor(ogl.GL_COLOR_BUFFER_BIT, ogl.GL_DEPTH_BUFFER_BIT))

    shader:use()

    local view = camera:getViewMatrix()
    shader:setMat4("uView", toFFI(view))
    shader:setMat4("uProj", projMatrix)
    
    shader:setVec3("uLightDir", lightDirX, lightDirY, lightDirZ)
    shader:setVec3("uLightColor", 0.9, 0.88, 0.8)
    shader:setVec3("uAmbient", 0.18, 0.18, 0.2)
    for _, obj in ipairs(scene) do
        if obj == rotatingCubeObj then
            obj.transform.rotX = currentTime * 0.7
            obj.transform.rotY = currentTime
        end

        if obj.mesh.update then
            obj.mesh:update(dt)
        end

        local model = obj.transform:getMatrix()
        shader:setMat4("uModel", toFFI(model))
        obj.material:apply(shader)
        obj.mesh:draw()
    end

    ogl.glfw.glfwSwapBuffers(window)
end

cubeMesh:destroy()
planeMesh:destroy()
pyramidMesh:destroy()
sphereMesh:destroy()
if brickTexOk then brickTexture:destroy() end
if objOk then objMesh:destroy() end
if animOk then animatedMesh:destroy() end
shader:destroy()
keyCallback:free()

ogl.glfw.glfwDestroyWindow(window)
aten.stop_engine()
ogl.glfw.glfwTerminate()