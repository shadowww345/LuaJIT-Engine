local ogl = require("gl")
local ffi = require("ffi")

local Input = {}
Input.__index = Input

local WATCHED_KEYS = {
    "W", "A", "S", "D", "Q", "E", "R",
    "UP", "DOWN", "LEFT", "RIGHT",
    "SPACE", "ESCAPE", "LEFT_SHIFT", "LEFT_CONTROL",
}

local xbuf = ffi.new("double[1]")
local ybuf = ffi.new("double[1]")

function Input.new(window)
    local self = setmetatable({}, Input)
    self.window = window
    self.current = {}
    self.previous = {}

    self.keyCodes = {}
    for _, name in ipairs(WATCHED_KEYS) do
        local code = ogl.GLFW["GLFW_KEY_" .. name]
        if code then
            self.keyCodes[name] = code
            self.current[name] = false
            self.previous[name] = false
        end
    end

    -- Fare durumu
    self.mouseX, self.mouseY = 0, 0
    self.mouseDX, self.mouseDY = 0, 0
    self.firstMouse = true

    return self
end

function Input:update()
    for name, state in pairs(self.current) do
        self.previous[name] = state
    end
    
    for name, code in pairs(self.keyCodes) do
        self.current[name] = ogl.glfw.glfwGetKey(self.window, code) == ogl.GLFW.GLFW_PRESS
    end
    
    ogl.glfw.glfwGetCursorPos(self.window, xbuf, ybuf)
    local x, y = xbuf[0], ybuf[0]

    if self.firstMouse then
        self.mouseX, self.mouseY = x, y
        self.firstMouse = false
    end

    self.mouseDX = x - self.mouseX
    self.mouseDY = y - self.mouseY
    self.mouseX, self.mouseY = x, y
end

function Input:isDown(name)
    return self.current[name] == true
end

function Input:wasPressed(name)
    return self.current[name] == true and self.previous[name] == false
end

function Input:wasReleased(name)
    return self.current[name] == false and self.previous[name] == true
end

return Input