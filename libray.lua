
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

-------------------------------------------------------------------------------
-- HELPER FUNCTIONS
-------------------------------------------------------------------------------
local function createTween(object, tweenInfo, goal)
return TweenService:Create(object, tweenInfo, goal)
end

local defaultTweenInfo = TweenInfo.new(
0.25,
Enum.EasingStyle.Quad,
Enum.EasingDirection.Out
)

local function tweenColor(object, newColor, duration)
local ti = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(object, ti, { BackgroundColor3 = newColor })
tween:Play()
return tween
end

local function tweenTransparency(object, newTransparency, duration)
local ti = TweenInfo.new(duration or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local tween = TweenService:Create(object, ti, { BackgroundTransparency = newTransparency })
tween:Play()
return tween
end

-- Round function for sliders, etc.
local function roundDecimals(num, places)
local mult = 10^(places or 0)
return math.floor(num * mult + 0.5) / mult
end

-------------------------------------------------------------------------------
-- THEME MANAGEMENT
-------------------------------------------------------------------------------
local Themes = {
Light = {
   MainBackground = Color3.fromRGB(240, 240, 240),
   SecondaryBackground = Color3.fromRGB(220, 220, 220),
   Accent = Color3.fromRGB(0, 162, 255),
   TextColor = Color3.fromRGB(30, 30, 30),
   PlaceholderColor = Color3.fromRGB(150, 150, 150),
},
Dark = {
   MainBackground = Color3.fromRGB(35, 35, 35),
   SecondaryBackground = Color3.fromRGB(50, 50, 50),
   Accent = Color3.fromRGB(255, 85, 85),
   TextColor = Color3.fromRGB(235, 235, 235),
   PlaceholderColor = Color3.fromRGB(160, 160, 160),
}
}

local CurrentTheme = Themes.Light

local function applyThemeToElement(element, elementType)
if elementType == "Window" then
   element.BackgroundColor3 = CurrentTheme.MainBackground
elseif elementType == "TabButton" then
   element.BackgroundColor3 = CurrentTheme.SecondaryBackground
elseif elementType == "TabScrollFrame" then
   element.BackgroundColor3 = CurrentTheme.MainBackground
elseif elementType == "Button" then
   element.BackgroundColor3 = CurrentTheme.SecondaryBackground
elseif elementType == "Toggle" then
   element.BackgroundColor3 = CurrentTheme.SecondaryBackground
elseif elementType == "Slider" then
   element.BackgroundColor3 = CurrentTheme.SecondaryBackground
elseif elementType == "Dropdown" then
   element.BackgroundColor3 = CurrentTheme.SecondaryBackground
elseif elementType == "ColorPicker" then
   element.BackgroundColor3 = CurrentTheme.SecondaryBackground
elseif elementType == "Notification" then
   element.BackgroundColor3 = CurrentTheme.MainBackground
end
end

-------------------------------------------------------------------------------
-- MAIN LIBRARY TABLE
-------------------------------------------------------------------------------
local Library = {}

-------------------------------------------------------------------------------
-- UI WINDOW CREATION
-------------------------------------------------------------------------------
Library.__index = Library

function Library.new(windowName)
local self = setmetatable({}, Library)

-- ScreenGui container
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BetterLibGUI_"..windowName
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Main window
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainWindow"
mainFrame.Size = UDim2.new(0, 500, 0, 400)
mainFrame.Position = UDim2.new(0.5, -250, 0.5, -200)
mainFrame.BorderSizePixel = 0
applyThemeToElement(mainFrame, "Window")
mainFrame.Parent = screenGui

-- Title bar
local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, 30)
titleBar.Position = UDim2.new(0, 0, 0, 0)
titleBar.BorderSizePixel = 0
applyThemeToElement(titleBar, "TabButton")
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -60, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = windowName
titleLabel.TextSize = 18
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextColor3 = CurrentTheme.TextColor
titleLabel.Parent = titleBar

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseButton"
closeBtn.Size = UDim2.new(0, 50, 1, 0)
closeBtn.Position = UDim2.new(1, -50, 0, 0)
closeBtn.BorderSizePixel = 0
closeBtn.Text = "X"
closeBtn.TextSize = 18
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextColor3 = CurrentTheme.TextColor
closeBtn.BackgroundColor3 = CurrentTheme.Accent
closeBtn.Parent = titleBar

-- Draggable behavior
local dragging = false
local dragOffset = Vector2.new(0, 0)

titleBar.InputBegan:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = true
      dragOffset = Vector2.new(input.Position.X, input.Position.Y)
      dragOffset = dragOffset - Vector2.new(mainFrame.AbsolutePosition.X, mainFrame.AbsolutePosition.Y)
   end
end)

titleBar.InputEnded:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.MouseButton1 then
      dragging = false
   end
end)

UserInputService.InputChanged:Connect(function(input)
   if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
      local delta = Vector2.new(input.Position.X, input.Position.Y) - dragOffset
      mainFrame.Position = UDim2.new(0, delta.X, 0, delta.Y)
   end
end)

closeBtn.MouseButton1Click:Connect(function()
   screenGui:Destroy()
end)

-- Tab container (left side)
local tabFrame = Instance.new("Frame")
tabFrame.Name = "Tabs"
tabFrame.Size = UDim2.new(0, 120, 1, -30)
tabFrame.Position = UDim2.new(0, 0, 0, 30)
tabFrame.BorderSizePixel = 0
applyThemeToElement(tabFrame, "TabButton")
tabFrame.Parent = mainFrame

local tabListLayout = Instance.new("UIListLayout")
tabListLayout.Parent = tabFrame
tabListLayout.FillDirection = Enum.FillDirection.Vertical
tabListLayout.Padding = UDim.new(0, 5)

-- Main container for tab content
local contentFrame = Instance.new("Frame")
contentFrame.Name = "ContentFrame"
contentFrame.Size = UDim2.new(1, -120, 1, -30)
contentFrame.Position = UDim2.new(0, 120, 0, 30)
contentFrame.BorderSizePixel = 0
applyThemeToElement(contentFrame, "TabScrollFrame")
contentFrame.Parent = mainFrame

-- Keep track of tabs
self.ScreenGui = screenGui
self.MainFrame = mainFrame
self.TitleBar = titleBar
self.TabFrame = tabFrame
self.ContentFrame = contentFrame
self.Tabs = {}
self.CurrentTab = nil

return self
end

function Library:CreateWindow(windowName)
return Library.new(windowName)
end

-------------------------------------------------------------------------------
-- TAB CREATION
-------------------------------------------------------------------------------
function Library:CreateTab(tabName)
local tabButton = Instance.new("TextButton")
tabButton.Name = tabName.."_TabButton"
tabButton.Size = UDim2.new(1, 0, 0, 30)
tabButton.BorderSizePixel = 0
tabButton.Text = tabName
tabButton.TextSize = 16
tabButton.Font = Enum.Font.Gotham
tabButton.TextColor3 = CurrentTheme.TextColor
applyThemeToElement(tabButton, "TabButton")
tabButton.Parent = self.TabFrame

local contentScroll = Instance.new("ScrollingFrame")
contentScroll.Name = tabName.."_Content"
contentScroll.Size = UDim2.new(1, 0, 1, 0)
contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
contentScroll.ScrollingDirection = Enum.ScrollingDirection.Y
contentScroll.BorderSizePixel = 0
contentScroll.Position = UDim2.new(0, 0, 0, 0)
applyThemeToElement(contentScroll, "TabScrollFrame")
contentScroll.Visible = false
contentScroll.Parent = self.ContentFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = contentScroll
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.Padding = UDim.new(0, 6)

listLayout.Changed:Connect(function()
   contentScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
end)

tabButton.MouseButton1Click:Connect(function()
   -- Hide all other tabs
   for _, tabData in pairs(self.Tabs) do
      tabData.Content.Visible = false
   end
   contentScroll.Visible = true
   self.CurrentTab = tabName
end)

local tabData = {
   Name = tabName,
   Button = tabButton,
   Content = contentScroll,
}

self.Tabs[tabName] = tabData
if not self.CurrentTab then
   self.CurrentTab = tabName
   contentScroll.Visible = true
end
return tabData
end

-------------------------------------------------------------------------------
-- ELEMENT CREATION HELPERS
-------------------------------------------------------------------------------
local function createBasicElement(parent, elementType, displayName)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, -20, 0, 30)
frame.BorderSizePixel = 0
applyThemeToElement(frame, elementType)
frame.Parent = parent

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0.5, 0, 1, 0)
label.BackgroundTransparency = 1
label.Text = displayName
label.TextSize = 14
label.Font = Enum.Font.Gotham
label.TextColor3 = CurrentTheme.TextColor
label.TextXAlignment = Enum.TextXAlignment.Left
label.Parent = frame

return frame, label
end

-------------------------------------------------------------------------------
-- BUTTON
-------------------------------------------------------------------------------
function Library:CreateButton(tabName, buttonText, callback)
local tabData = self.Tabs[tabName]
local frame, label = createBasicElement(tabData.Content, "Button", buttonText)

label.Position = UDim2.new(0, 10, 0, 0)

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0, 80, 0.8, 0)
btn.Position = UDim2.new(1, -90, 0.1, 0)
btn.BorderSizePixel = 0
btn.Text = "Click"
btn.TextSize = 14
btn.Font = Enum.Font.Gotham
btn.TextColor3 = CurrentTheme.TextColor
btn.BackgroundColor3 = CurrentTheme.Accent
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
   if callback then
      callback()
   end
end)

return btn
end

-------------------------------------------------------------------------------
-- TOGGLE
-------------------------------------------------------------------------------
function Library:CreateToggle(tabName, toggleText, defaultValue, callback)
local tabData = self.Tabs[tabName]
local frame, label = createBasicElement(tabData.Content, "Toggle", toggleText)

label.Position = UDim2.new(0, 10, 0, 0)

local toggleBtn = Instance.new("TextButton")
toggleBtn.Size = UDim2.new(0, 60, 0.8, 0)
toggleBtn.Position = UDim2.new(1, -70, 0.1, 0)
toggleBtn.BorderSizePixel = 0
toggleBtn.TextSize = 14
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextColor3 = CurrentTheme.TextColor
toggleBtn.Parent = frame

local isToggled = defaultValue or false
local function updateToggle()
   if isToggled then
      toggleBtn.Text = "ON"
      tweenColor(toggleBtn, CurrentTheme.Accent, 0.2)
   else
      toggleBtn.Text = "OFF"
      tweenColor(toggleBtn, CurrentTheme.SecondaryBackground, 0.2)
   end
end

updateToggle()

toggleBtn.MouseButton1Click:Connect(function()
   isToggled = not isToggled
   updateToggle()
   if callback then
      callback(isToggled)
   end
end)

return toggleBtn
end

-------------------------------------------------------------------------------
-- SLIDER
-------------------------------------------------------------------------------
function Library:CreateSlider(tabName, sliderText, minValue, maxValue, defaultValue, callback)
local tabData = self.Tabs[tabName]
local frame, label = createBasicElement(tabData.Content, "Slider", sliderText)

label.Position = UDim2.new(0, 10, 0, 0)

local sliderBar = Instance.new("Frame")
sliderBar.Size = UDim2.new(0, 150, 0.2, 0)
sliderBar.Position = UDim2.new(0, 10, 0.6, 0)
sliderBar.BorderSizePixel = 0
sliderBar.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
sliderBar.Parent = frame

local fillBar = Instance.new("Frame")
fillBar.Size = UDim2.new(0, 0, 1, 0)
fillBar.BorderSizePixel = 0
fillBar.BackgroundColor3 = CurrentTheme.Accent
fillBar.Parent = sliderBar

local handle = Instance.new("Frame")
handle.Size = UDim2.new(0, 10, 0, 20)
handle.Position = UDim2.new(0, -5, 0.5, -10)
handle.BorderSizePixel = 0
handle.BackgroundColor3 = CurrentTheme.Accent
handle.Parent = sliderBar

local valueLabel = Instance.new("TextLabel")
valueLabel.Size = UDim2.new(0, 50, 0.8, 0)
valueLabel.Position = UDim2.new(1, -60, 0.1, 0)
valueLabel.BackgroundTransparency = 1
valueLabel.TextSize = 14
valueLabel.Font = Enum.Font.GothamBold
valueLabel.TextColor3 = CurrentTheme.TextColor
valueLabel.Parent = frame

local sliding = false
local currentValue = defaultValue or minValue

local function updateSlider(posX)
   local sliderAbsPos = sliderBar.AbsolutePosition.X
   local sliderWidth = sliderBar.AbsoluteSize.X
   local relativeX = math.clamp(posX - sliderAbsPos, 0, sliderWidth)
   local percent = relativeX / sliderWidth
   local rawValue = (maxValue - minValue) * percent + minValue
   currentValue = math.clamp(math.floor(rawValue + 0.5), minValue, maxValue)

   fillBar.Size = UDim2.new(0, relativeX, 1, 0)
   handle.Position = UDim2.new(0, relativeX - 5, 0.5, -10)
   valueLabel.Text = tostring(currentValue)

   if callback then
      callback(currentValue)
   end
end

sliderBar.InputBegan:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.MouseButton1 then
      sliding = true
      updateSlider(input.Position.X)
   end
end)
sliderBar.InputEnded:Connect(function(input)
   if input.UserInputType == Enum.UserInputType.MouseButton1 then
      sliding = false
   end
end)

UserInputService.InputChanged:Connect(function(input)
   if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
      updateSlider(input.Position.X)
   end
end)

-- Initialize slider position
updateSlider(sliderBar.AbsolutePosition.X + ((defaultValue or minValue) - minValue)/
             (maxValue - minValue) * sliderBar.AbsoluteSize.X)

return frame
end

-------------------------------------------------------------------------------
-- DROPDOWN
-------------------------------------------------------------------------------
function Library:CreateDropdown(tabName, dropdownText, options, callback)
local tabData = self.Tabs[tabName]
local frame, label = createBasicElement(tabData.Content, "Dropdown", dropdownText)

label.Position = UDim2.new(0, 10, 0, 0)

local dropdownBtn = Instance.new("TextButton")
dropdownBtn.Size = UDim2.new(0, 120, 0.8, 0)
dropdownBtn.Position = UDim2.new(1, -130, 0.1, 0)
dropdownBtn.BorderSizePixel = 0
dropdownBtn.Text = "Select"
dropdownBtn.TextColor3 = CurrentTheme.TextColor
dropdownBtn.TextSize = 14
dropdownBtn.Font = Enum.Font.Gotham
dropdownBtn.BackgroundColor3 = CurrentTheme.Accent
dropdownBtn.Parent = frame

local dropdownFrame = Instance.new("Frame")
dropdownFrame.Size = UDim2.new(0, 120, 0, 0)
dropdownFrame.Position = UDim2.new(0, dropdownBtn.Position.X.Offset, 1, 0)
dropdownFrame.BorderSizePixel = 0
dropdownFrame.BackgroundColor3 = CurrentTheme.SecondaryBackground
dropdownFrame.Visible = false
dropdownFrame.Parent = frame

local ddListLayout = Instance.new("UIListLayout")
ddListLayout.Parent = dropdownFrame

local isOpen = false
local function toggleDropdown()
   isOpen = not isOpen
   dropdownFrame.Visible = isOpen
   if isOpen then
      -- Expand frame to fit items
      dropdownFrame.Size = UDim2.new(0, 120, 0, #options * 25)
   else
      dropdownFrame.Size = UDim2.new(0, 120, 0, 0)
   end
end

dropdownBtn.MouseButton1Click:Connect(toggleDropdown)

for _, opt in ipairs(options) do
   local optBtn = Instance.new("TextButton")
   optBtn.Size = UDim2.new(1, 0, 0, 25)
   optBtn.BorderSizePixel = 0
   optBtn.Text = opt
   optBtn.TextSize = 14
   optBtn.Font = Enum.Font.Gotham
   optBtn.TextColor3 = CurrentTheme.TextColor
   optBtn.BackgroundColor3 = CurrentTheme.SecondaryBackground
   optBtn.Parent = dropdownFrame

   optBtn.MouseButton1Click:Connect(function()
      dropdownBtn.Text = opt
      toggleDropdown()
      if callback then
         callback(opt)
      end
   end)
end

return dropdownBtn
end

-------------------------------------------------------------------------------
-- COLOR PICKER (Simple version)
-------------------------------------------------------------------------------
function Library:CreateColorPicker(tabName, pickerText, defaultColor, callback)
local tabData = self.Tabs[tabName]
local frame, label = createBasicElement(tabData.Content, "ColorPicker", pickerText)

label.Position = UDim2.new(0, 10, 0, 0)

local pickerBtn = Instance.new("TextButton")
pickerBtn.Size = UDim2.new(0, 40, 0.8, 0)
pickerBtn.Position = UDim2.new(1, -50, 0.1, 0)
pickerBtn.BorderSizePixel = 0
pickerBtn.Text = ""
pickerBtn.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255)
pickerBtn.Parent = frame

local function openPickerDialog()
   -- For brevity, we won’t code an entire RGB/HSV color selection GUI here.
   -- Instead, you could call a separate color picker module or create a small
   -- window of colored squares. Here’s just a quick illustration:

   local colorDialog = Instance.new("Frame")
   colorDialog.Size = UDim2.new(0, 200, 0, 80)
   colorDialog.Position = UDim2.new(0, frame.AbsolutePosition.X + 100, 0, frame.AbsolutePosition.Y)
   colorDialog.BorderSizePixel = 1
   colorDialog.BackgroundColor3 = CurrentTheme.SecondaryBackground
   colorDialog.Parent = self.MainFrame

   -- mini dismiss logic:
   local dismissBtn = Instance.new("TextButton")
   dismissBtn.Size = UDim2.new(0, 50, 0, 20)
   dismissBtn.Position = UDim2.new(1, -55, 0, 5)
   dismissBtn.BorderSizePixel = 0
   dismissBtn.Text = "Close"
   dismissBtn.Parent = colorDialog

   dismissBtn.MouseButton1Click:Connect(function()
      colorDialog:Destroy()
   end)

   -- example pre-defined colors:
   local sampleColors = {
      Color3.fromRGB(255, 0, 0),
      Color3.fromRGB(0, 255, 0),
      Color3.fromRGB(0, 0, 255),
      Color3.fromRGB(255, 255, 0),
      Color3.fromRGB(255, 255, 255),
      Color3.fromRGB(0, 0, 0),
   }

   local layout = Instance.new("UIListLayout")
   layout.FillDirection = Enum.FillDirection.Horizontal
   layout.Padding = UDim.new(0, 5)
   layout.Parent = colorDialog

   for _, c in ipairs(sampleColors) do
      local colorBox = Instance.new("TextButton")
      colorBox.Size = UDim2.new(0, 30, 0, 30)
      colorBox.BackgroundColor3 = c
      colorBox.Text = ""
      colorBox.Parent = colorDialog

      colorBox.MouseButton1Click:Connect(function()
         pickerBtn.BackgroundColor3 = c
         if callback then
            callback(c)
         end
      end)
   end
end

pickerBtn.MouseButton1Click:Connect(function()
   openPickerDialog()
end)

return pickerBtn
end

-------------------------------------------------------------------------------
-- NOTIFICATION MANAGER
-------------------------------------------------------------------------------
local NotificationManager = {}
NotificationManager.Notifs = {}

function NotificationManager:CreateNotification(message, duration)
local screenGui = playerGui:FindFirstChild("BetterLib_Notifications")
if not screenGui then
   screenGui = Instance.new("ScreenGui")
   screenGui.Name = "BetterLib_Notifications"
   screenGui.ResetOnSpawn = false
   screenGui.Parent = playerGui
end

local notifFrame = Instance.new("Frame")
notifFrame.Size = UDim2.new(0, 250, 0, 50)
notifFrame.Position = UDim2.new(1, -260, 0.8, 0)
notifFrame.BorderSizePixel = 0
applyThemeToElement(notifFrame, "Notification")
notifFrame.BackgroundTransparency = 0
notifFrame.Parent = screenGui

local notifLabel = Instance.new("TextLabel")
notifLabel.Size = UDim2.new(1, -10, 1, -10)
notifLabel.Position = UDim2.new(0, 5, 0, 5)
notifLabel.Text = message
notifLabel.TextColor3 = CurrentTheme.TextColor
notifLabel.Font = Enum.Font.Gotham
notifLabel.TextSize = 14
notifLabel.BackgroundTransparency = 1
notifLabel.Parent = notifFrame

table.insert(self.Notifs, notifFrame)

-- Slide in from the right
notifFrame.Position = UDim2.new(1, 10, 0.8, 0)
createTween(notifFrame, defaultTweenInfo, {Position = UDim2.new(1, -260, 0.8, 0)}):Play()

-- Adjust others to stack
for i, frame in ipairs(self.Notifs) do
   createTween(frame, defaultTweenInfo, {Position = UDim2.new(1, -260, 0.8, -(60*(i-1)))}):Play()
end

-- Automatic fade out
spawn(function()
   wait(duration or 3)
   createTween(notifFrame, defaultTweenInfo, {Position = UDim2.new(1, 10, 0.8, 0)}):Play()
   tweenTransparency(notifFrame, 1, 0.4)
   wait(0.5)
   notifFrame:Destroy()
   table.remove(self.Notifs, table.find(self.Notifs, notifFrame))
end)
end

-------------------------------------------------------------------------------
-- LIBRARY EXTRAS
-------------------------------------------------------------------------------
function Library:GetNotificationManager()
return NotificationManager
end

function Library:SetTheme(themeName)
if Themes[themeName] then
   CurrentTheme = Themes[themeName]
end
end
