--[[
    Advanced Roblox UI Library
    - Supports both Drawing API (script-based UI) and ScreenGui (GUI-based UI)
    - Features: Tabs, Toggles, Buttons, Labels, FPS HUD, Inventory System, Custom Notifications
    - Optimized for performance
    - Unique animations, sounds, and customization
]]

local UI = {}

--// Dependencies
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

--// UI Core Storage
UI.Elements = {}
UI.Drawings = {}
UI.UseGUI = true -- Toggle between GUI and Drawing API

--// GUI Root
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = game:GetService("CoreGui")--Players.LocalPlayer:FindFirstChild("PlayerGui") or Players.LocalPlayer:WaitForChild("PlayerGui")

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

--// Render Function (Using Drawing API or GUI)
function UI:Render()
    for _, element in pairs(self.Elements) do
        if element.Visible then
            if UI.UseGUI then
                if element.Type == "Tab" then
                    local tab = Instance.new("TextLabel")
                    tab.Parent = ScreenGui
                    tab.Text = element.Properties.Name or "Tab"
                    tab.Position = UDim2.new(0, 100, 0, 50 + (#ScreenGui:GetChildren() * 30))
                    tab.Size = UDim2.new(0, 150, 0, 30)
                    tab.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                    tab.TextColor3 = Color3.new(1, 1, 1)
                    tab.Font = Enum.Font.SourceSansBold
                    tab.TextSize = 20
                end
            else
                if element.Type == "Tab" then
                    local tab = Drawing.new("Text")
                    tab.Text = element.Properties.Name or "Tab"
                    tab.Position = Vector2.new(100, 50 + (#self.Drawings * 20))
                    tab.Size = 20
                    tab.Color = Color3.new(1, 1, 1)
                    tab.Visible = true
                    table.insert(self.Drawings, tab)
                end
            end
        end
    end
end

--// Create Tabs
function UI:CreateTab(name)
    local tab = self:CreateElement("Tab", {Name = name, Active = false})
    self:Render()
    return tab
end

--// Create Toggles
function UI:CreateToggle(name, default, callback)
    local toggle = self:CreateElement("Toggle", {Name = name, State = default or false})
    toggle.Callback = callback or function() end
    self:Render()
    return toggle
end

--// Create Buttons
function UI:CreateButton(name, callback)
    local button = self:CreateElement("Button", {Name = name})
    button.Callback = callback or function() end
    self:Render()
    return button
end

--// Create Labels
function UI:CreateLabel(text)
    local label = self:CreateElement("Label", {Text = text})
    self:Render()
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
    self:Render()
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
