
local Library = loadstring(Game:HttpGet("https://raw.githubusercontent.com/bloodball/-back-ups-for-libs/main/wizard"))()

local PhantomForcesWindow = Library:NewWindow("CW X | Recorder")

local KillingCheats = PhantomForcesWindow:NewSection("Functions")

KillingCheats:CreateToggle("Record", function(value)
print(value)
end)

KillingCheats:CreateButton("Auto Skip", function()
print("HI")
end)

