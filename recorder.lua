
local Library = loadstring(Game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()

local PhantomForcesWindow = Library:NewWindow("CW X | Recorder")

local KillingCheats = PhantomForcesWindow:NewSection("Functions")

KillingCheats:CreateToggle("Record", function(value)
print(value)
end)

KillingCheats:CreateButton("Auto Skip", function()
print("HI")
end)

local MessageBox = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/NotificationGUI/main/source.lua"))()


--[[
   MessageBoxIcons:
      • Question
      • Error
      • Warning

   MessageBoxButtons:
      • YesNo
      • OKCancel
      • OK
--]]
-- AnchorPoint is 0.5,0.5
MessageBox.Show({
    Position = UDim2.new(0.5, 0, 0.5, 0),
    Text = "Notification UI",
    Description = "Recorder CW X  | Successfully Loaded ✅\nMade by : Wolny/Constance\n",
    MessageBoxIcon = "Warning",
    MessageBoxButtons = "OK",
    Result = function(res)
    end
            })



