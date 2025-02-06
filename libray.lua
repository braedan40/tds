--------------------------------------------------------------------------------
-- ADVANCED ROBLOX VERSION WITH GUI, TWEEN, AND SMOOTH ANIMATIONS
--------------------------------------------------------------------------------

--// HOW TO USE THIS SCRIPT:
--  1) Create a LocalScript inside StarterPlayerScripts or StarterGui.
--  2) Copy the entire script below into that LocalScript.
--  3) Run the game and click the buttons / toggles to see animations,
--     smooth transitions, overlay modals, and more!

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")

-- The local player, so we can place GUIs in their PlayerGui
local localPlayer = Players.LocalPlayer
local playerGui   = localPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- CREATE OUR PRIMARY SCREEN GUI
--------------------------------------------------------------------------------
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AdvancedDemoGUI"
screenGui.ResetOnSpawn = false  -- Keep the GUI around if the character respawns
screenGui.Parent = playerGui

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS FOR SMOOTH TWEENING
--------------------------------------------------------------------------------

-- A generic tween function to help animate any property
local function createTween(instance, tweenInfo, goalProps)
	return TweenService:Create(instance, tweenInfo, goalProps)
end

-- Easing style/curve used frequently for consistent transitions
local slideInTweenInfo = TweenInfo.new(
	0.5,                      -- Duration in seconds
	Enum.EasingStyle.Quad,    -- Easing style
	Enum.EasingDirection.Out  -- Easing direction
)

local fadeInTweenInfo = TweenInfo.new(
	0.4,
	Enum.EasingStyle.Sine,
	Enum.EasingDirection.Out
)

--------------------------------------------------------------------------------
-- SIDEBAR MENU (WITH SLIDE AND FADE)
--------------------------------------------------------------------------------
local sidebarWidth = 250

local sidebarFrame = Instance.new("Frame")
sidebarFrame.Name = "SidebarFrame"
sidebarFrame.Size = UDim2.new(0, sidebarWidth, 1, 0)
sidebarFrame.Position = UDim2.new(0, -sidebarWidth, 0, 0)  -- initially hidden off-screen
sidebarFrame.BackgroundColor3 = Color3.fromRGB(35, 37, 39)
sidebarFrame.BorderSizePixel = 0
sidebarFrame.Parent = screenGui

-- Sidebar toggle button (Hamburger Menu)
local sidebarToggleBtn = Instance.new("TextButton")
sidebarToggleBtn.Name = "SidebarToggleBtn"
sidebarToggleBtn.Size = UDim2.new(0, 40, 0, 40)
sidebarToggleBtn.Position = UDim2.new(0, 10, 0, 10)
sidebarToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 47, 49)
sidebarToggleBtn.BorderSizePixel = 0
sidebarToggleBtn.Text = "≡"  -- simple "hamburger" icon
sidebarToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
sidebarToggleBtn.Font = Enum.Font.SourceSansBold
sidebarToggleBtn.TextSize = 20
sidebarToggleBtn.Parent = screenGui

-- Add a nice hover effect to the toggle button
local function hoverEffect(button)
	button.MouseEnter:Connect(function()
		createTween(button, fadeInTweenInfo, {BackgroundColor3 = Color3.fromRGB(60, 62, 64)}):Play()
	end)
	button.MouseLeave:Connect(function()
		createTween(button, fadeInTweenInfo, {BackgroundColor3 = Color3.fromRGB(45, 47, 49)}):Play()
	end)
end
hoverEffect(sidebarToggleBtn)

-- Toggle logic
local sidebarOpen = false
local function toggleSidebar()
	sidebarOpen = not sidebarOpen
	if sidebarOpen then
		-- Slide in
		createTween(sidebarFrame, slideInTweenInfo, {Position = UDim2.new(0, 0, 0, 0)}):Play()
	else
		-- Slide out
		createTween(sidebarFrame, slideInTweenInfo, {Position = UDim2.new(0, -sidebarWidth, 0, 0)}):Play()
	end
end

sidebarToggleBtn.MouseButton1Click:Connect(toggleSidebar)

--------------------------------------------------------------------------------
-- SIDEBAR CONTENTS
--------------------------------------------------------------------------------
local sidebarTitle = Instance.new("TextLabel")
sidebarTitle.Name = "SidebarTitle"
sidebarTitle.Size = UDim2.new(1, 0, 0, 50)
sidebarTitle.BackgroundColor3 = Color3.fromRGB(25, 27, 29)
sidebarTitle.BorderSizePixel = 0
sidebarTitle.Text = "Advanced Menu"
sidebarTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
sidebarTitle.Font = Enum.Font.GothamBold
sidebarTitle.TextSize = 20
sidebarTitle.Parent = sidebarFrame

-- UIListLayout for vertical organization
local sidebarListLayout = Instance.new("UIListLayout")
sidebarListLayout.FillDirection = Enum.FillDirection.Vertical
sidebarListLayout.Parent = sidebarFrame

--------------------------------------------------------------------------------
-- BUTTONS & TOGGLES (ANIMATED)
--------------------------------------------------------------------------------
local function createSidebarButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 40)
	btn.BackgroundColor3 = Color3.fromRGB(35, 37, 39)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = Color3.fromRGB(200, 200, 200)
	btn.Font = Enum.Font.SourceSansSemibold
	btn.TextSize = 18
	btn.Parent = sidebarFrame

	-- Hover effect
	btn.MouseEnter:Connect(function()
		createTween(btn, fadeInTweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 52, 54)}):Play()
	end)
	btn.MouseLeave:Connect(function()
		createTween(btn, fadeInTweenInfo, {BackgroundColor3 = Color3.fromRGB(35, 37, 39)}):Play()
	end)

	return btn
end

local function createSidebarToggle(text)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 40)
	frame.BackgroundColor3 = Color3.fromRGB(35, 37, 39)
	frame.BorderSizePixel = 0
	frame.Parent = sidebarFrame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0.7, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.Font = Enum.Font.SourceSans
	label.TextSize = 18
	label.Parent = frame

	local toggleBtn = Instance.new("TextButton")
	toggleBtn.Size = UDim2.new(0.3, -10, 0.8, 0)
	toggleBtn.Position = UDim2.new(0.7, 10, 0.1, 0)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
	toggleBtn.BorderSizePixel = 0
	toggleBtn.Text = "OFF"
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.Font = Enum.Font.SourceSansSemibold
	toggleBtn.TextSize = 18
	toggleBtn.Parent = frame

	-- Hover effect for the toggle's frame
	frame.MouseEnter:Connect(function()
		createTween(frame, fadeInTweenInfo, {BackgroundColor3 = Color3.fromRGB(50, 52, 54)}):Play()
	end)
	frame.MouseLeave:Connect(function()
		createTween(frame, fadeInTweenInfo, {BackgroundColor3 = Color3.fromRGB(35, 37, 39)}):Play()
	end)

	local isOn = false
	toggleBtn.MouseButton1Click:Connect(function()
		isOn = not isOn
		toggleBtn.Text = isOn and "ON" or "OFF"

		-- Fancy color tween
		if isOn then
			createTween(toggleBtn, slideInTweenInfo, {BackgroundColor3 = Color3.fromRGB(0, 170, 80)}):Play()
		else
			createTween(toggleBtn, slideInTweenInfo, {BackgroundColor3 = Color3.fromRGB(80, 80, 80)}):Play()
		end
	end)

	return frame
end

-- Create some example side menu entries
local dashBtn = createSidebarButton("Interactive Dashboard")
local navBtn  = createSidebarButton("Animated Navigation")
local feedBtn = createSidebarButton("Feedback Mechanisms")
local toggle1 = createSidebarToggle("Cool Toggle")
local toggle2 = createSidebarToggle("Another Toggle")

--------------------------------------------------------------------------------
-- MAIN CONTENT FRAME (SHOWING CARDS, EXAMPLES)
--------------------------------------------------------------------------------
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(1, 0, 1, 0)
mainFrame.Position = UDim2.new(0, 0, 0, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Title label at the top
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "TitleLabel"
titleLabel.Size = UDim2.new(1, -60, 0, 50)
titleLabel.Position = UDim2.new(0, 60, 0, 10)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "Advanced GUI Experience (Roblox Version)"
titleLabel.TextColor3 = Color3.fromRGB(20, 20, 20)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 24
titleLabel.Parent = mainFrame

--------------------------------------------------------------------------------
-- CARD CONTAINER
--------------------------------------------------------------------------------
local cardsContainer = Instance.new("Frame")
cardsContainer.Name = "CardsContainer"
cardsContainer.Size = UDim2.new(1, -40, 0, 200)
cardsContainer.Position = UDim2.new(0, 20, 0, 80)
cardsContainer.BackgroundTransparency = 1
cardsContainer.Parent = mainFrame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.FillDirection = Enum.FillDirection.Horizontal
uiListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
uiListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
uiListLayout.Padding = UDim.new(0, 15)
uiListLayout.Parent = cardsContainer

-- Example "cards"
local cards = {
	{
		Title = "Interactive Dashboard",
		Description = "Fluid, animated interactions with live data.",
		Color = Color3.fromRGB(52, 211, 153) -- #34D399
	},
	{
		Title = "Animated Navigation",
		Description = "Seamlessly slide through pages with transitions.",
		Color = Color3.fromRGB(59, 130, 246) -- #3B82F6
	},
	{
		Title = "Feedback Mechanisms",
		Description = "Hover + overlay animations that respond to user actions.",
		Color = Color3.fromRGB(245, 158, 11) -- #F59E0B
	},
	{
		Title = "Advanced Modals",
		Description = "Rich fading and sliding for alerts and dialogues.",
		Color = Color3.fromRGB(239, 68, 68) -- #EF4444
	},
}

local function createCard(card)
	local frame = Instance.new("Frame")
	frame.Name = "Card"
	frame.Size = UDim2.new(0, 250, 0, 150)
	frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	frame.BorderSizePixel = 0
	frame.Parent = cardsContainer

	-- "Stripe" at the top for color accent
	local stripe = Instance.new("Frame")
	stripe.Size = UDim2.new(1, 0, 0, 5)
	stripe.Position = UDim2.new(0, 0, 0, 0)
	stripe.BackgroundColor3 = card.Color
	stripe.BorderSizePixel = 0
	stripe.Parent = frame

	local title = Instance.new("TextLabel")
	title.Name = "CardTitle"
	title.Size = UDim2.new(1, -20, 0, 40)
	title.Position = UDim2.new(0, 10, 0, 15)
	title.BackgroundTransparency = 1
	title.Text = card.Title
	title.TextColor3 = card.Color
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.Parent = frame

	local desc = Instance.new("TextLabel")
	desc.Name = "CardDesc"
	desc.Size = UDim2.new(1, -20, 0, 40)
	desc.Position = UDim2.new(0, 10, 0, 65)
	desc.BackgroundTransparency = 1
	desc.Text = card.Description
	desc.TextColor3 = Color3.fromRGB(80, 80, 80)
	desc.Font = Enum.Font.Gotham
	desc.TextWrapped = true
	desc.TextSize = 16
	desc.Parent = frame

	-- Show Overlay Button
	local showOverlayBtn = Instance.new("TextButton")
	showOverlayBtn.Name = "ShowOverlayBtn"
	showOverlayBtn.Size = UDim2.new(0, 120, 0, 30)
	showOverlayBtn.Position = UDim2.new(0.5, -60, 1, -40)
	showOverlayBtn.BackgroundColor3 = card.Color
	showOverlayBtn.BorderSizePixel = 0
	showOverlayBtn.Text = "Show Overlay"
	showOverlayBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	showOverlayBtn.Font = Enum.Font.GothamSemibold
	showOverlayBtn.TextSize = 16
	showOverlayBtn.Parent = frame

	-- Hover effect for Show Overlay button
	showOverlayBtn.MouseEnter:Connect(function()
		createTween(showOverlayBtn, fadeInTweenInfo, {
			BackgroundColor3 = card.Color:lerp(Color3.fromRGB(255, 255, 255), 0.1)
		}):Play()
	end)
	showOverlayBtn.MouseLeave:Connect(function()
		createTween(showOverlayBtn, fadeInTweenInfo, {BackgroundColor3 = card.Color}):Play()
	end)

	return {
		Frame = frame,
		Button = showOverlayBtn
	}
end

local cardInstances = {}
for _, cData in ipairs(cards) do
	table.insert(cardInstances, createCard(cData))
end

--------------------------------------------------------------------------------
-- ADVANCED MODAL OVERLAY
--------------------------------------------------------------------------------
local overlayFrame = Instance.new("Frame")
overlayFrame.Name = "OverlayFrame"
overlayFrame.Size = UDim2.new(1, 0, 1, 0)
overlayFrame.Position = UDim2.new(0, 0, 0, 0)
overlayFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
overlayFrame.BackgroundTransparency = 0.5
overlayFrame.Visible = false
overlayFrame.BorderSizePixel = 0
overlayFrame.ZIndex = 10
overlayFrame.Parent = screenGui

-- This will be the modal's actual container
local modalContainer = Instance.new("Frame")
modalContainer.Name = "ModalContainer"
modalContainer.Size = UDim2.new(0, 400, 0, 200)
modalContainer.Position = UDim2.new(0.5, -200, 0.5, -100)
modalContainer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
modalContainer.BorderSizePixel = 0
modalContainer.ZIndex = 11
modalContainer.Parent = overlayFrame

local modalTitle = Instance.new("TextLabel")
modalTitle.Name = "ModalTitle"
modalTitle.Size = UDim2.new(1, 0, 0, 50)
modalTitle.Position = UDim2.new(0, 0, 0, 0)
modalTitle.BackgroundColor3 = Color3.fromRGB(240, 240, 240)
modalTitle.BorderSizePixel = 0
modalTitle.Text = "Animated Overlay"
modalTitle.TextColor3 = Color3.fromRGB(30, 30, 30)
modalTitle.Font = Enum.Font.GothamBold
modalTitle.TextSize = 20
modalTitle.ZIndex = 12
modalTitle.Parent = modalContainer

local modalBody = Instance.new("TextLabel")
modalBody.Name = "ModalBody"
modalBody.Size = UDim2.new(1, -40, 1, -60)
modalBody.Position = UDim2.new(0, 20, 0, 60)
modalBody.BackgroundTransparency = 1
modalBody.TextColor3 = Color3.fromRGB(100, 100, 100)
modalBody.Font = Enum.Font.Gotham
modalBody.TextSize = 16
modalBody.TextWrapped = true
modalBody.ZIndex = 12
modalBody.Text = "Overlay content here..."
modalBody.Parent = modalContainer

local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Size = UDim2.new(0, 80, 0, 30)
closeBtn.Position = UDim2.new(1, -90, 1, -40)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
closeBtn.BorderSizePixel = 0
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Text = "Close"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.ZIndex = 13
closeBtn.Parent = modalContainer

-- Hover effect for Close button
closeBtn.MouseEnter:Connect(function()
	createTween(closeBtn, fadeInTweenInfo, {BackgroundColor3 = Color3.fromRGB(230, 20, 20)}):Play()
end)
closeBtn.MouseLeave:Connect(function()
	createTween(closeBtn, fadeInTweenInfo, {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}):Play()
end)

local function showOverlay(message)
	overlayFrame.Visible = true
	modalBody.Text = message
	-- Start scale from smaller for a "pop in" effect
	modalContainer.Size = UDim2.new(0, 350, 0, 150)
	createTween(modalContainer, slideInTweenInfo, {
		Size = UDim2.new(0, 400, 0, 200)
	}):Play()
end

local function hideOverlay()
	-- Shrink out, then hide
	local tween = createTween(modalContainer, slideInTweenInfo, {
		Size = UDim2.new(0, 350, 0, 150)
	})
	tween.Completed:Connect(function()
		overlayFrame.Visible = false
	end)
	tween:Play()
end

closeBtn.MouseButton1Click:Connect(hideOverlay)

--------------------------------------------------------------------------------
-- OPEN OVERLAY WHEN "SHOW OVERLAY" BUTTON IS CLICKED
--------------------------------------------------------------------------------
local messages = {
	"This is the first tweened overlay message!",
	"Another overlay with smooth transitions!",
	"Enjoy sliding modals with advanced tween!"
}

for idx, cardObj in ipairs(cardInstances) do
	cardObj.Button.MouseButton1Click:Connect(function()
		local msgIndex = ((idx - 1) % #messages) + 1
		showOverlay(messages[msgIndex])
	end)
end

--------------------------------------------------------------------------------
-- OPTIONAL: FPS DISPLAY (MINIMAL), SIMILAR TO SNIPPET
--------------------------------------------------------------------------------
local fpsDisplay = Instance.new("TextLabel")
fpsDisplay.Size = UDim2.new(0, 60, 0, 25)
fpsDisplay.Position = UDim2.new(1, -70, 0, 10)
fpsDisplay.BackgroundTransparency = 0.4
fpsDisplay.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
fpsDisplay.BorderSizePixel = 0
fpsDisplay.Text = "FPS: 0"
fpsDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
fpsDisplay.Font = Enum.Font.SourceSansBold
fpsDisplay.TextSize = 16
fpsDisplay.Parent = screenGui

local lastTime = os.clock()
local frames = 0
RunService.RenderStepped:Connect(function()
	frames = frames + 1
	local currentTime = os.clock()
	if currentTime - lastTime >= 1 then
		local fps = frames / (currentTime - lastTime)
		fpsDisplay.Text = string.format("FPS: %d", fps)
		lastTime = currentTime
		frames = 0
	end
end)

--------------------------------------------------------------------------------
-- COMPLETE!  Enjoy your advanced (and long!) Roblox GUI version.
--------------------------------------------------------------------------------

-- Additional references:
-- [Roblox GUI Documentation](https://developer.roblox.com/en-us/articles/Guis)
-- [Developer Hub on TweenService](https://developer.roblox.com/en-us/articles/TweenService)

--------------------------------------------------------------------------------
-- END OF SCRIPT
--------------------------------------------------------------------------------
