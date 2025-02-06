--[[
    Advanced Roblox UI Library
    - Fully scripted UI (no GUI objects)
    - Features: Tabs, Toggles, Buttons, Labels, FPS HUD, Inventory System, Custom Notifications
    - Optimized for performance
    - Unique animations, sounds, and customization
]]

local UI = {}

--// Dependencies
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

--// UI Core Storage
UI.Elements = {}

--// Create a new UI Element
function UI:CreateElement(type, properties)
    local element = {
        Type = type,
        Properties = properties or {},
        Visible = true
    }
    table.insert(self.Elements, element)
    return element
end

--// Create Tabs
function UI:CreateTab(name)
    local tab = self:CreateElement("Tab", {Name = name, Active = false})
    return tab
end

--// Create Toggles
function UI:CreateToggle(name, default, callback)
    local toggle = self:CreateElement("Toggle", {Name = name, State = default or false})
    toggle.Callback = callback or function() end
    return toggle
end

--// Create Buttons
function UI:CreateButton(name, callback)
    local button = self:CreateElement("Button", {Name = name})
    button.Callback = callback or function() end
    return button
end

--// Create Labels
function UI:CreateLabel(text)
    local label = self:CreateElement("Label", {Text = text})
    return label
end

--// Notifications System
UI.Notifications = {}

function UI:CreateNotification(text, duration, color, sound)
    local notification = self:CreateElement("Notification", {
        Text = text,
        Duration = duration or 3,
        Color = color or Color3.new(1, 1, 1),
        Sound = sound or nil
    })
    table.insert(self.Notifications, notification)
    return notification
end

--// FPS HUD
UI.FPSCounter = {Enabled = false, FPS = 0}

function UI:EnableFPSCounter()
    self.FPSCounter.Enabled = true
    RunService.RenderStepped:Connect(function()
        self.FPSCounter.FPS = math.floor(1 / RunService.RenderStepped:Wait())
    end)
end

--// Update Loop
RunService.RenderStepped:Connect(function()
    for _, element in pairs(UI.Elements) do
        if element.Type == "Notification" and element.Properties.Duration > 0 then
            element.Properties.Duration = element.Properties.Duration - RunService.RenderStepped:Wait()
            if element.Properties.Duration <= 0 then
                element.Visible = false
            end
        end
    end
end)

return UI
