
--------------------------------------------------------------------------------
-- ULTRA-ADVANCED UI LIBRARY (DEMO)
--------------------------------------------------------------------------------
-- Save this in a LocalScript (e.g., StarterPlayerScripts) or load via ModuleScript:
-- Example: 
-- local UltraLib = loadstring(game:HttpGet("https://example.com/YourRawFile.lua"))()
-- local myUI = UltraLib:CreateWindow("My Great UI")

-- Inspired by [libray.lua](https://raw.githubusercontent.com/braedan40/tds/refs/heads/main/libray.lua) 
-- but extensively expanded and improved for demonstration.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- 1. HELPER FUNCTIONS (TWEEN WRAPPERS, ROUNDING, etc.)
--------------------------------------------------------------------------------

local function createTween(obj, tweenInfo, goal)
    return TweenService:Create(obj, tweenInfo, goal)
end

-- For consistent tween durations.
local defaultTweenInfo = TweenInfo.new(
    0.3,                             -- Duration
    Enum.EasingStyle.Quad,           -- Easing style
    Enum.EasingDirection.Out,        -- Easing direction
    0,                               -- Repeat count (0 = no repeat)
    false,                           -- Reverses
    0                                -- Delay
)

local function tweenBackgroundColor(obj, newColor, duration)
    local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, { BackgroundColor3 = newColor })
    tween:Play()
    return tween
end

local function tweenTextColor(obj, newColor, duration)
    local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, { TextColor3 = newColor })
    tween:Play()
    return tween
end

local function tweenTransparency(obj, newTransparency, duration)
    local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(obj, info, { BackgroundTransparency = newTransparency })
    tween:Play()
    return tween
end

-- Round a value to a certain number of decimal places.
local function roundValue(num, places)
    places = places or 0
    local mult = 10 ^ places
    return math.floor(num * mult + 0.5) / mult
end

--------------------------------------------------------------------------------
-- 2. THEMING SYSTEM
--------------------------------------------------------------------------------
-- A few built-in themes. You can add more or define them on the fly.
local Themes = {
    ["Dark"] = {
        MainBackground = Color3.fromRGB(35, 35, 35),
        SecondaryBackground = Color3.fromRGB(50, 50, 50),
        Accent = Color3.fromRGB(255, 85, 85),
        TextColor = Color3.fromRGB(235, 235, 235),
        InactiveTextColor = Color3.fromRGB(160, 160, 160),
        PlaceholderColor = Color3.fromRGB(150, 150, 150),
        OutlineColor = Color3.fromRGB(15, 15, 15),
    },
    ["Light"] = {
        MainBackground = Color3.fromRGB(245, 245, 245),
        SecondaryBackground = Color3.fromRGB(220, 220, 220),
        Accent = Color3.fromRGB(0, 162, 255),
        TextColor = Color3.fromRGB(30, 30, 30),
        InactiveTextColor = Color3.fromRGB(80, 80, 80),
        PlaceholderColor = Color3.fromRGB(120, 120, 120),
        OutlineColor = Color3.fromRGB(200, 200, 200),
    },
    ["Midnight"] = {
        MainBackground = Color3.fromRGB(20, 20, 30),
        SecondaryBackground = Color3.fromRGB(40, 40, 55),
        Accent = Color3.fromRGB(150, 0, 200),
        TextColor = Color3.fromRGB(220, 220, 255),
        InactiveTextColor = Color3.fromRGB(120, 120, 160),
        PlaceholderColor = Color3.fromRGB(100, 100, 140),
        OutlineColor = Color3.fromRGB(10, 10, 20),
    },
}

-- We’ll store the currently active theme in each window’s data,
-- allowing multiple windows to use different themes if desired.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 3. LIBRARY MAIN TABLE
--------------------------------------------------------------------------------
local UltraLib = {}
UltraLib.__index = UltraLib

-- For managing multiple windows. Each window has its own sub-table:
-- {
--    ScreenGui = <ScreenGui object>,
--    MainFrame = <Frame for the window>,
--    TitleBar = <title bar frame>,
--    Theme = <a table of theme colors>,
--    ...
-- }
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- 4. WINDOW CREATION
--------------------------------------------------------------------------------

function UltraLib:CreateWindow(windowTitle, themeName)
    -- Create a new table to represent this window’s data
    local windowData = {}
    setmetatable(windowData, UltraLib)

    -- Validate theme or pick default
    if Themes[themeName] then
        windowData.Theme = Themes[themeName]
    else
        windowData.Theme = Themes["Dark"]  -- default
    end

    -- Create ScreenGui container
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "UltraLibGUI_" .. windowTitle
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Main window
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = UDim2.new(0, 520, 0, 400)
    mainFrame.Position = UDim2.new(0.5, -260, 0.5, -200)
    mainFrame.BackgroundColor3 = windowData.Theme.MainBackground
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui

    -- Optional outline (thin frame) to better define window edges
    local outlineFrame = Instance.new("Frame")
    outlineFrame.Name = "Outline"
    outlineFrame.Size = UDim2.new(1, 2, 1, 2)
    outlineFrame.Position = UDim2.new(0, -1, 0, -1)
    outlineFrame.BorderSizePixel = 0
    outlineFrame.BackgroundColor3 = windowData.Theme.OutlineColor
    outlineFrame.ZIndex = -1
    outlineFrame.Parent = mainFrame

    -- Title bar
    local titleBarHeight = 30
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, titleBarHeight)
    titleBar.BackgroundColor3 = windowData.Theme.SecondaryBackground
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = windowTitle
    titleLabel.TextColor3 = windowData.Theme.TextColor
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar

    -- Close button
    local closeButton = Instance.new("TextButton")
    closeButton.Name = "CloseButton"
    closeButton.Size = UDim2.new(0, 60, 1, 0)
    closeButton.Position = UDim2.new(1, -60, 0, 0)
    closeButton.BackgroundColor3 = windowData.Theme.Accent
    closeButton.BorderSizePixel = 0
    closeButton.Text = "X"
    closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextSize = 18
    closeButton.Parent = titleBar

    -- Draggable logic
    local dragging = false
    local dragOffset = Vector2.new(0, 0)

    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mousePos = input.Position
            dragOffset = Vector2.new(mousePos.X, mousePos.Y)
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

    closeButton.MouseButton1Click:Connect(function()
        -- Animate closing
        createTween(mainFrame, defaultTweenInfo, {
            Size = UDim2.new(0, 520, 0, 0), 
            BackgroundTransparency = 1
        }):Play()
        wait(0.3)
        screenGui:Destroy()
    end)

    -- Resizable corner “grip”
    local resizeZone = Instance.new("Frame")
    resizeZone.Name = "ResizeZone"
    resizeZone.Size = UDim2.new(0, 20, 0, 20)
    resizeZone.AnchorPoint = Vector2.new(1, 1)
    resizeZone.Position = UDim2.new(1, 0, 1, 0)
    resizeZone.BackgroundColor3 = windowData.Theme.SecondaryBackground
    resizeZone.BorderSizePixel = 0
    resizeZone.Parent = mainFrame

    local resizing = false
    local initialSize = Vector2.new(0, 0)
    local initialPos = Vector2.new(0, 0)

    resizeZone.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            initialSize = Vector2.new(mainFrame.AbsoluteSize.X, mainFrame.AbsoluteSize.Y)
            initialPos = Vector2.new(input.Position.X, input.Position.Y)
        end
    end)

    resizeZone.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if resizing and input.UserInputType == Enum.UserInputType.MouseMovement then
            local newX = initialSize.X + (input.Position.X - initialPos.X)
            local newY = initialSize.Y + (input.Position.Y - initialPos.Y)
            mainFrame.Size = UDim2.new(0, math.max(300, newX), 0, math.max(200, newY))
        end
    end)

    -- Container frame for tab buttons
    local tabButtonBar = Instance.new("Frame")
    tabButtonBar.Name = "TabButtonBar"
    tabButtonBar.Size = UDim2.new(1, 0, 0, 30)
    tabButtonBar.Position = UDim2.new(0, 0, 0, titleBarHeight)
    tabButtonBar.BackgroundColor3 = windowData.Theme.MainBackground
    tabButtonBar.BorderSizePixel = 0
    tabButtonBar.Parent = mainFrame

    local tabButtonLayout = Instance.new("UIListLayout")
    tabButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    tabButtonLayout.Padding = UDim.new(0, 5)
    tabButtonLayout.Parent = tabButtonBar

    -- “Page” container
    local pagesFrame = Instance.new("Frame")
    pagesFrame.Name = "Pages"
    pagesFrame.Size = UDim2.new(1, 0, 1, -(titleBarHeight + tabButtonBar.Size.Y.Offset))
    pagesFrame.Position = UDim2.new(0, 0, 0, titleBarHeight + tabButtonBar.Size.Y.Offset)
    pagesFrame.BackgroundColor3 = windowData.Theme.SecondaryBackground
    pagesFrame.BorderSizePixel = 0
    pagesFrame.Parent = mainFrame

    -- Fields to track in window data
    windowData.ScreenGui = screenGui
    windowData.MainFrame = mainFrame
    windowData.TitleBar = titleBar
    windowData.TabButtonBar = tabButtonBar
    windowData.PagesFrame = pagesFrame
    windowData.Tabs = {}         -- { [tabName] = { Button = <btn>, Container = <scrollFrame> } }
    windowData.CurrentTab = nil

    return windowData
end

--------------------------------------------------------------------------------
-- 5. TAB CREATION
--------------------------------------------------------------------------------
function UltraLib:CreateTab(tabName)
    local tabButton = Instance.new("TextButton")
    tabButton.Name = "TabButton_" .. tabName
    tabButton.Size = UDim2.new(0, 100, 1, 0)
    tabButton.BackgroundColor3 = self.Theme.SecondaryBackground
    tabButton.BorderSizePixel = 0
    tabButton.Text = tabName
    tabButton.TextColor3 = self.Theme.TextColor
    tabButton.Font = Enum.Font.GothamBold
    tabButton.TextSize = 14
    tabButton.Parent = self.TabButtonBar

    -- Hover effect
    tabButton.MouseEnter:Connect(function()
        tweenBackgroundColor(tabButton, self.Theme.Accent, 0.2)
        tweenTextColor(tabButton, Color3.fromRGB(255, 255, 255), 0.2)
    end)
    tabButton.MouseLeave:Connect(function()
        if self.CurrentTab ~= tabName then
            tweenBackgroundColor(tabButton, self.Theme.SecondaryBackground, 0.2)
            tweenTextColor(tabButton, self.Theme.TextColor, 0.2)
        end
    end)

    -- ScrollingFrame for content
    local contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "Content_" .. tabName
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    contentFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    contentFrame.ScrollBarThickness = 6
    contentFrame.BackgroundColor3 = self.Theme.MainBackground
    contentFrame.BorderSizePixel = 0
    contentFrame.Visible = false
    contentFrame.Parent = self.PagesFrame

    -- UIListLayout inside contentFrame
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 6)
    listLayout.Parent = contentFrame

    listLayout.Changed:Connect(function()
        contentFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 10)
    end)

    -- Click behavior
    tabButton.MouseButton1Click:Connect(function()
        -- Hide all other tabs
        for name, data in pairs(self.Tabs) do
            data.Container.Visible = false
            if data.Button ~= tabButton then
                tweenBackgroundColor(data.Button, self.Theme.SecondaryBackground, 0.2)
                tweenTextColor(data.Button, self.Theme.TextColor, 0.2)
            end
        end

        -- Show this tab
        contentFrame.Visible = true
        self.CurrentTab = tabName

        -- Mark this tab as active visually
        tweenBackgroundColor(tabButton, self.Theme.Accent, 0.2)
        tweenTextColor(tabButton, Color3.fromRGB(255, 255, 255), 0.2)
    end)

    -- Save tab info
    self.Tabs[tabName] = {
        Button = tabButton,
        Container = contentFrame,
        Layout = listLayout
    }

    -- If no current tab set yet, select this one
    if not self.CurrentTab then
        self.CurrentTab = tabName
        contentFrame.Visible = true
        tweenBackgroundColor(tabButton, self.Theme.Accent, 0.2)
        tweenTextColor(tabButton, Color3.fromRGB(255, 255, 255), 0.2)
    end

    return self.Tabs[tabName]
end

--------------------------------------------------------------------------------
-- Quick UI Element Builder Helper
--------------------------------------------------------------------------------
local function createBaseElement(parent, theme, elementHeight)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, elementHeight)
    frame.BackgroundColor3 = theme.SecondaryBackground
    frame.BorderSizePixel = 0
    frame.Parent = parent

    return frame
end

--------------------------------------------------------------------------------
-- 6. BASIC ELEMENTS: BUTTON
--------------------------------------------------------------------------------
function UltraLib:CreateButton(tabName, buttonText, callback)
    local tabData = self.Tabs[tabName]
    if not tabData then return end

    local parent = tabData.Container
    local theme = self.Theme
    local element = createBaseElement(parent, theme, 30)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.BackgroundTransparency = 1
    btn.Text = buttonText
    btn.TextSize = 14
    btn.Font = Enum.Font.Gotham
    btn.TextColor3 = theme.TextColor
    btn.Parent = element

    btn.MouseEnter:Connect(function()
        tweenBackgroundColor(element, theme.Accent, 0.2)
        tweenTextColor(btn, Color3.fromRGB(255, 255, 255), 0.2)
    end)
    btn.MouseLeave:Connect(function()
        tweenBackgroundColor(element, theme.SecondaryBackground, 0.2)
        tweenTextColor(btn, theme.TextColor, 0.2)
    end)

    btn.MouseButton1Click:Connect(function()
        if callback then
            callback()
        end
    end)
end

--------------------------------------------------------------------------------
-- 7. TOGGLE
--------------------------------------------------------------------------------
function UltraLib:CreateToggle(tabName, toggleText, defaultValue, callback)
    local tabData = self.Tabs[tabName]
    if not tabData then return end

    local parent = tabData.Container
    local theme = self.Theme
    local element = createBaseElement(parent, theme, 30)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = toggleText
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextColor3 = theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = element

    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleButton"
    toggleBtn.Size = UDim2.new(0.3, -5, 0.8, 0)
    toggleBtn.Position = UDim2.new(0.7, 5, 0.1, 0)
    toggleBtn.BackgroundColor3 = theme.InactiveTextColor
    toggleBtn.BorderSizePixel = 0
    toggleBtn.TextSize = 14
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Parent = element

    local isOn = defaultValue or false

    local function updateToggleState()
        if isOn then
            toggleBtn.Text = "ON"
            tweenBackgroundColor(toggleBtn, theme.Accent, 0.2)
        else
            toggleBtn.Text = "OFF"
            tweenBackgroundColor(toggleBtn, theme.InactiveTextColor, 0.2)
        end
    end

    updateToggleState()

    toggleBtn.MouseButton1Click:Connect(function()
        isOn = not isOn
        updateToggleState()
        if callback then
            callback(isOn)
        end
    end)
end

--------------------------------------------------------------------------------
-- 8. SLIDER
--------------------------------------------------------------------------------
function UltraLib:CreateSlider(tabName, sliderText, minValue, maxValue, defaultValue, callback)
    local tabData = self.Tabs[tabName]
    if not tabData then return end

    local parent = tabData.Container
    local theme = self.Theme
    local element = createBaseElement(parent, theme, 40)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = sliderText
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextColor3 = theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = element

    local sliderFrame = Instance.new("Frame")
    sliderFrame.Name = "SliderFrame"
    sliderFrame.Size = UDim2.new(0.5, -10, 0.4, 0)
    sliderFrame.Position = UDim2.new(0.5, 5, 0.3, 0)
    sliderFrame.BackgroundColor3 = theme.MainBackground
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = element

    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = sliderFrame

    local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 10, 0, sliderFrame.AbsoluteSize.Y)
    handle.BackgroundColor3 = theme.Accent
    handle.BorderSizePixel = 0
    handle.Parent = sliderFrame

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 40, 1, 0)
    valueLabel.Position = UDim2.new(1, 5, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.TextSize = 14
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextColor3 = theme.TextColor
    valueLabel.Text = tostring(defaultValue or minValue)
    valueLabel.Parent = element

    local sliderDragging = false
    local currentValue = defaultValue or minValue

    local function updateSlider(inputX)
        local sliderAbsPos = sliderFrame.AbsolutePosition.X
        local sliderWidth = sliderFrame.AbsoluteSize.X
        local relativeX = math.clamp(inputX - sliderAbsPos, 0, sliderWidth)
        local pct = relativeX / sliderWidth
        local newValue = minValue + (maxValue - minValue) * pct
        newValue = roundValue(newValue, 0)
        currentValue = newValue
        fill.Size = UDim2.new(pct, 0, 1, 0)
        handle.Position = UDim2.new(0, math.max(0, relativeX - handle.AbsoluteSize.X/2), 0, 0)
        valueLabel.Text = tostring(currentValue)
        if callback then
            callback(currentValue)
        end
    end

    sliderFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = true
            updateSlider(input.Position.X)
        end
    end)

    sliderFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            sliderDragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateSlider(input.Position.X)
        end
    end)

    -- Initialize slider
    local initPct = ( (defaultValue or minValue) - minValue ) / (maxValue - minValue)
    fill.Size = UDim2.new(initPct, 0, 1, 0)
    handle.Position = UDim2.new(initPct, -5, 0, 0)
    currentValue = defaultValue or minValue
end

--------------------------------------------------------------------------------
-- 9. DROPDOWN
--------------------------------------------------------------------------------
function UltraLib:CreateDropdown(tabName, dropdownText, options, callback)
    local tabData = self.Tabs[tabName]
    if not tabData then return end

    local parent = tabData.Container
    local theme = self.Theme
    local element = createBaseElement(parent, theme, 30)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = dropdownText
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextColor3 = theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = element

    local ddButton = Instance.new("TextButton")
    ddButton.Name = "DropdownButton"
    ddButton.Size = UDim2.new(0.4, -5, 0.8, 0)
    ddButton.Position = UDim2.new(0.6, 5, 0.1, 0)
    ddButton.BackgroundColor3 = theme.Accent
    ddButton.BorderSizePixel = 0
    ddButton.TextSize = 14
    ddButton.Font = Enum.Font.GothamBold
    ddButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ddButton.Text = "Select"
    ddButton.Parent = element

    local dropdownFrame = Instance.new("Frame")
    dropdownFrame.Name = "DropdownFrame"
    dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
    dropdownFrame.Position = UDim2.new(0, 0, 1, 0)
    dropdownFrame.BorderSizePixel = 0
    dropdownFrame.BackgroundColor3 = theme.MainBackground
    dropdownFrame.Visible = false
    dropdownFrame.Parent = element

    local ddLayout = Instance.new("UIListLayout")
    ddLayout.Parent = dropdownFrame

    local isOpen = false
    local function toggleDropdown()
        isOpen = not isOpen
        dropdownFrame.Visible = isOpen
        if isOpen then
            local itemCount = #options
            dropdownFrame.Size = UDim2.new(1, 0, 0, itemCount * 25)
        else
            dropdownFrame.Size = UDim2.new(1, 0, 0, 0)
        end
    end

    ddButton.MouseButton1Click:Connect(toggleDropdown)

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 25)
        optBtn.BackgroundColor3 = theme.SecondaryBackground
        optBtn.BorderSizePixel = 0
        optBtn.Font = Enum.Font.Gotham
        optBtn.Text = tostring(opt)
        optBtn.TextSize = 14
        optBtn.TextColor3 = theme.TextColor
        optBtn.Parent = dropdownFrame

        optBtn.MouseButton1Click:Connect(function()
            ddButton.Text = optBtn.Text
            toggleDropdown()
            if callback then
                callback(optBtn.Text)
            end
        end)
    end
end

--------------------------------------------------------------------------------
-- 10. TEXTBOX
--------------------------------------------------------------------------------
function UltraLib:CreateTextBox(tabName, labelText, placeholderText, callback)
    local tabData = self.Tabs[tabName]
    if not tabData then return end

    local parent = tabData.Container
    local theme = self.Theme
    local element = createBaseElement(parent, theme, 30)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = labelText
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextColor3 = theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = element

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.6, -5, 0.8, 0)
    box.Position = UDim2.new(0.4, 5, 0.1, 0)
    box.BackgroundColor3 = theme.MainBackground
    box.BorderSizePixel = 0
    box.PlaceholderText = placeholderText
    box.PlaceholderColor3 = theme.PlaceholderColor
    box.TextSize = 14
    box.Font = Enum.Font.Gotham
    box.TextColor3 = theme.TextColor
    box.Text = ""
    box.Parent = element

    box.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            if callback then
                callback(box.Text)
            end
        end
    end)
end

--------------------------------------------------------------------------------
-- 11. KEYBIND DETECTOR
--------------------------------------------------------------------------------
function UltraLib:CreateKeybind(tabName, bindText, defaultKey, callback)
    local tabData = self.Tabs[tabName]
    if not tabData then return end

    local parent = tabData.Container
    local theme = self.Theme
    local element = createBaseElement(parent, theme, 30)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = bindText
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextColor3 = theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = element

    local bindBtn = Instance.new("TextButton")
    bindBtn.Name = "BindButton"
    bindBtn.Size = UDim2.new(0.3, -5, 0.8, 0)
    bindBtn.Position = UDim2.new(0.7, 5, 0.1, 0)
    bindBtn.BackgroundColor3 = theme.Accent
    bindBtn.BorderSizePixel = 0
    bindBtn.TextSize = 14
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    bindBtn.Text = defaultKey and defaultKey.Name or "None"
    bindBtn.Parent = element

    local isBinding = false
    local currentKey = defaultKey

    bindBtn.MouseButton1Click:Connect(function()
        if not isBinding then
            isBinding = true
            bindBtn.Text = "Press Key"
        end
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if isBinding then
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                currentKey = input.KeyCode
                bindBtn.Text = currentKey.Name
                isBinding = false
                if callback then
                    callback(currentKey)
                end
            end
        else
            if currentKey and input.KeyCode == currentKey then
                -- Fire the callback
                if callback then
                    callback(currentKey)
                end
            end
        end
    end)
end

--------------------------------------------------------------------------------
-- 12. COLOR PICKER (Simple version with optional advanced expansions)
--------------------------------------------------------------------------------
function UltraLib:CreateColorPicker(tabName, pickerLabel, defaultColor, callback)
    local tabData = self.Tabs[tabName]
    if not tabData then return end

    local parent = tabData.Container
    local theme = self.Theme
    local element = createBaseElement(parent, theme, 30)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = pickerLabel
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextColor3 = theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = element

    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0.3, -5, 0.8, 0)
    colorBtn.Position = UDim2.new(0.7, 5, 0.1, 0)
    colorBtn.BackgroundColor3 = defaultColor or Color3.fromRGB(255, 255, 255)
    colorBtn.BorderSizePixel = 0
    colorBtn.Text = ""
    colorBtn.Parent = element

    local function openColorDialog()
        -- Minimal example with some sample squares:
        local dialog = Instance.new("Frame")
        dialog.Size = UDim2.new(0, 200, 0, 80)
        dialog.Position = UDim2.new(0, colorBtn.AbsolutePosition.X, 0, colorBtn.AbsolutePosition.Y + 30)
        dialog.BackgroundColor3 = theme.SecondaryBackground
        dialog.BorderSizePixel = 0
        dialog.Parent = self.MainFrame

        local layout = Instance.new("UIListLayout")
        layout.FillDirection = Enum.FillDirection.Horizontal
        layout.Padding = UDim.new(0, 5)
        layout.Parent = dialog

        local colorSamples = {
            Color3.fromRGB(255, 0, 0),
            Color3.fromRGB(0, 255, 0),
            Color3.fromRGB(0, 0, 255),
            Color3.fromRGB(255, 255, 255),
            Color3.fromRGB(0, 0, 0),
            theme.Accent,
        }

        for _, c in ipairs(colorSamples) do
            local swatch = Instance.new("TextButton")
            swatch.Size = UDim2.new(0, 30, 0, 30)
            swatch.BackgroundColor3 = c
            swatch.Text = ""
            swatch.Parent = dialog

            swatch.MouseButton1Click:Connect(function()
                colorBtn.BackgroundColor3 = c
                dialog:Destroy()
                if callback then
                    callback(c)
                end
            end)
        end
    end

    colorBtn.MouseButton1Click:Connect(openColorDialog)
end

--------------------------------------------------------------------------------
-- 13. PROGRESS BAR
--------------------------------------------------------------------------------
function UltraLib:CreateProgressBar(tabName, barText, initialValue, maxValue)
    local tabData = self.Tabs[tabName]
    if not tabData then return end

    local parent = tabData.Container
    local theme = self.Theme
    local element = createBaseElement(parent, theme, 30)

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.3, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = barText
    label.TextSize = 14
    label.Font = Enum.Font.Gotham
    label.TextColor3 = theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = element

    local barFrame = Instance.new("Frame")
    barFrame.Size = UDim2.new(0.7, -10, 0.6, 0)
    barFrame.Position = UDim2.new(0.3, 10, 0.2, 0)
    barFrame.BackgroundColor3 = theme.MainBackground
    barFrame.BorderSizePixel = 0
    barFrame.Parent = element

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = barFrame

    local currentValue = initialValue or 0

    local function setProgress(val)
        if not maxValue or maxValue <= 0 then maxValue = 100 end
        val = math.clamp(val, 0, maxValue)
        currentValue = val
        local pct = val / maxValue
        createTween(fill, defaultTweenInfo, { Size = UDim2.new(pct, 0, 1, 0) }):Play()
    end

    setProgress(currentValue)

    return {
        SetProgress = setProgress
    }
end

--------------------------------------------------------------------------------
-- 14. NESTED SUB-TABS (Optional demonstration)
--------------------------------------------------------------------------------
function UltraLib:CreateSubTab(parentTabName, subTabName)
    -- This “sub-tab” example will create an additional frame under the parent’s content,
    -- with its own internal tab system. In a real library, you might implement a more
    -- integrated approach. This is just to show advanced hierarchical UI.

    local parentData = self.Tabs[parentTabName]
    if not parentData then return end

    local subTabButtonBar = Instance.new("Frame")
    subTabButtonBar.Size = UDim2.new(1, 0, 0, 25)
    subTabButtonBar.BackgroundColor3 = self.Theme.MainBackground
    subTabButtonBar.BorderSizePixel = 0
    subTabButtonBar.Parent = parentData.Container

    local subButtonLayout = Instance.new("UIListLayout")
    subButtonLayout.FillDirection = Enum.FillDirection.Horizontal
    subButtonLayout.Padding = UDim.new(0, 3)
    subButtonLayout.Parent = subTabButtonBar

    local subTabContent = Instance.new("Frame")
    subTabContent.Size = UDim2.new(1, 0, 0, 120)
    subTabContent.BackgroundColor3 = self.Theme.SecondaryBackground
    subTabContent.BorderSizePixel = 0
    subTabContent.Visible = false
    subTabContent.Parent = parentData.Container

    local subTabBtn = Instance.new("TextButton")
    subTabBtn.Size = UDim2.new(0, 80, 1, 0)
    subTabBtn.BackgroundColor3 = self.Theme.SecondaryBackground
    subTabBtn.BorderSizePixel = 0
    subTabBtn.Text = subTabName
    subTabBtn.TextColor3 = self.Theme.TextColor
    subTabBtn.TextSize = 14
    subTabBtn.Font = Enum.Font.GothamBold
    subTabBtn.Parent = subTabButtonBar

    subTabBtn.MouseButton1Click:Connect(function()
        subTabContent.Visible = not subTabContent.Visible
    end)

    -- Return the content frame so you can place more UI inside it.
    return subTabContent
end

--------------------------------------------------------------------------------
-- 15. GLOBAL HOTKEY TOGGLE FOR ENTIRE UI
--------------------------------------------------------------------------------
local globalToggleKey = Enum.KeyCode.RightShift
local uiVisible = true

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == globalToggleKey then
        uiVisible = not uiVisible
        for _, gui in ipairs(playerGui:GetChildren()) do
            if gui:IsA("ScreenGui") and gui.Name:match("^UltraLibGUI_") then
                gui.Enabled = uiVisible
            end
        end
    end
end)

--------------------------------------------------------------------------------
-- 16. NOTIFICATION SYSTEM
--------------------------------------------------------------------------------
local NotificationManager = {}
NotificationManager.__index = NotificationManager
NotificationManager.ActiveNotifications = {}

function NotificationManager:Notify(msg, theme)
    local screenGui = playerGui:FindFirstChild("UltraLib_Notifications")
    if not screenGui then
        screenGui = Instance.new("ScreenGui")
        screenGui.Name = "UltraLib_Notifications"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = playerGui
    end

    -- Create a notification frame
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(0, 250, 0, 35)
    notifFrame.Position = UDim2.new(1, 260, 0.7, 0) -- offscreen to right
    notifFrame.BackgroundColor3 = theme and theme.MainBackground or Themes.Dark.MainBackground
    notifFrame.BorderSizePixel = 0
    notifFrame.Parent = screenGui

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 5, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = msg
    label.TextColor3 = theme and theme.TextColor or Themes.Dark.TextColor
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = notifFrame

    table.insert(self.ActiveNotifications, notifFrame)

    -- Slide in animation
    createTween(notifFrame, defaultTweenInfo, {Position = UDim2.new(1, -260, 0.7, 0)}):Play()

    -- Stack them
    for i, frame in ipairs(self.ActiveNotifications) do
        createTween(frame, defaultTweenInfo, {
            Position = UDim2.new(1, -260, 0.7, (i-1)*40)
        }):Play()
    end

    -- Fade out after 4 seconds
    spawn(function()
        wait(4)
        createTween(notifFrame, defaultTweenInfo, {Position = UDim2.new(1, 260, 0.7, 0)}):Play()
        tweenTransparency(notifFrame, 1, 0.4)
        wait(0.4)
        notifFrame:Destroy()
        table.remove(self.ActiveNotifications, table.find(self.ActiveNotifications, notifFrame))
    end)
end

local GlobalNotifier = setmetatable({}, NotificationManager)

function UltraLib:GetNotifier()
    return GlobalNotifier
end

--------------------------------------------------------------------------------
-- 17. DEMO / EXAMPLE USAGE
--------------------------------------------------------------------------------
--[[
local myUI = UltraLib:CreateWindow("Test UI", "Midnight")
myUI:CreateTab("Main")
myUI:CreateTab("Extra")

-- Button
myUI:CreateButton("Main", "Hello Button", function()
    print("Hello pressed!")
end)

-- Toggle
myUI:CreateToggle("Main", "Enable Something", false, function(newVal)
    print("Toggled:", newVal)
end)

-- Slider
myUI:CreateSlider("Main", "Volume", 0, 100, 50, function(val)
    print("Slider changed:", val)
end)

-- Dropdown
myUI:CreateDropdown("Main", "Select Option", {"Option1", "Option2", "Option3"}, function(selected)
    print("Dropdown selected:", selected)
end)

-- TextBox
myUI:CreateTextBox("Main", "Enter Name:", "Type here...", function(txt)
    print("TextBox input:", txt)
end)

-- Keybind
myUI:CreateKeybind("Main", "Secret Keybind", Enum.KeyCode.M, function(key)
    print("Keybind pressed:", key)
end)

-- Color Picker
myUI:CreateColorPicker("Main", "Choose Color", Color3.fromRGB(128, 128, 255), function(clr)
    print("Color selected:", clr)
end)

-- Progress Bar example
local prog = myUI:CreateProgressBar("Extra", "Loading", 0, 100)
spawn(function()
    for i=1,100 do
        prog.SetProgress(i)
        wait(0.02)
    end
end)

-- Sub tab example
local subTabFrame = myUI:CreateSubTab("Extra", "More Settings")
-- Add UI inside subTabFrame as you wish

-- Send a notification
local Notif = myUI:GetNotifier()
Notif:Notify("Welcome to UltraLib!", myUI.Theme)

-- If you have multiple windows, create them:
local secondUI = UltraLib:CreateWindow("Second UI", "Light")
secondUI:CreateTab("Settings")
secondUI:CreateButton("Settings", "Do Something", function()
    print("Second UI button clicked!")
end)

-- Press RightShift to toggle all UltraLib GUIs
-- End of Demo
]]--

--------------------------------------------------------------------------------
-- 18. RETURN ULTRALIB
--------------------------------------------------------------------------------
return UltraLib

--------------------------------------------------------------------------------
-- END OF ULTRA-ADVANCED UI LIBRARY
--------------------------------------------------------------------------------

