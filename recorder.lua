local folderName = "CW X Recorder"
local recorderFolder = game.Workspace:FindFirstChild(folderName)

if not recorderFolder then
    recorderFolder = Instance.new("Folder")
    recorderFolder.Name = folderName
    recorderFolder.Parent = game.Workspace
end

local function loadContent(url)
    local success, response = pcall(function()
        return game:GetService("HttpService"):GetAsync(url)
    end)

    if success then
        return response
    else
        warn("Failed to load content from URL.")
        return nil
    end
end

local function recordPlacement(data)
    local recorderData = Instance.new("StringValue")
    recorderData.Name = "PlacementData" .. tostring(math.random(10000, 99999))
    recorderData.Value = data
    recorderData.Parent = recorderFolder
end

local url = "https://raw.githubusercontent.com/braedan40/tds/refs/heads/main/main.lua"
local content = loadContent(url)

if content then
    recordPlacement(content)
    print("Recording has been saved successfully!")
else
    print("Failed to load and record content.")
end

local Library = loadstring(Game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()
local PhantomForcesWindow = Library:NewWindow("CW X | Recorder")
local KillingCheats = PhantomForcesWindow:NewSection("Functions")

local isRecording = false
KillingCheats:CreateToggle("Record", function(value)
    isRecording = value
    if isRecording then
        print("Recording started.")
    else
        print("Recording stopped.")
    end
end)

KillingCheats:CreateButton("Auto Skip", function()
    print("HI")
end)

local MessageBox = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/NotificationGUI/main/source.lua"))()

MessageBox.Show({
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Text = "Notification UI",
    Description = "Recorder CW X  | Successfully Loaded ✅\nMade by : Wolny/Constance\n",
    MessageBoxIcon = "Warning",
    MessageBoxButtons = "OK",
    Result = function(res)
    end
})
