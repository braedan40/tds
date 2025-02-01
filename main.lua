local functions = {} 

function inlobby()
    return game.PlaceId == 5591597781 or game:GetService("Workspace"):FindFirstChild("Type") and game:GetService("Workspace").Type.Value == "Lobby"
end

function ingame()
    return game.PlaceId == 3260590327 or game:GetService("Workspace"):FindFirstChild("Type") and game:GetService("Workspace").Type.Value == "Game"
end
function waitwavetimer(wave, Timer)
    if ingame() then
        local gameState = require(game:GetService("ReplicatedStorage").Resources.Universal.GameState)
        local timer = game:GetService("ReplicatedStorage").State.Timer.Time.Value
        local wave = GameState["Wave"]
        if wave > wave and timer < Timer then
            return true
    end
end

functions.Map = function(MapName)
    -- Implement this function
end

functions.Place = function(Tower,wave,Timer)
    if ingame() then
        local tabletower = tableinfo[Tower]
        if not tabletower then
            warn("Tower data not found!")
            return
        end
        repeat task.wait() until waitwavetimer(wave,Timer)
        local position = tabletower.Position or CFrame.new(0, 0, 0)
        local rotation = tabletower.Rotation or Vector3.new(0, 0, 0)
 
        local place
        repeat
            place = args = {
                [1] = "Troops",
                [2] = "Place",
                [3] = {
                    ["Rotation"] = rotation,
                    ["Position"] = position
                },
                [4] = "Scout"
            }

            place = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
        until typeof(place) == "Instance"

        place.Name += 1  
    else
        return
    end
end

--[[functions.Select = function(Tower)
local towerInstance = workspace:FindFirstChild("Towers") and workspace.Towers:FindFirstChild(Tower)

if towerInstance then

local args = {
    [1] = "Streaming",
    [2] = "SelectTower", 
    [3] = "Set", -- name of tower
    [4] = { } -- name of skiin
}

game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
 end
end]]


functions.Upgrade = function(Tower,wave,Timer)
    local towerInstance = workspace:FindFirstChild("Towers") and workspace.Towers:FindFirstChild(Tower)
    repeat task.wait() until waitwavetimer(wave,Timer)
    if towerInstance then
        local args = {
            [1] = "Troops",
            [2] = "Upgrade",
            [3] = "Set",
            [4] = {
                ["Troop"] = towerInstance,
                ["Path"] = 1
            }
        }

        game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
    else
        warn("Tower not found!")
    end
end


functions.Sell = function(Tower)
    local towerInstance = workspace:FindFirstChild("Towers") and workspace.Towers:FindFirstChild(Tower)
    if towerInstance then
    
local args = {
    [1] = "Troops",
    [2] = "Sell",
    [3] = {
        ["Troop"] = tower
    }
}

game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
    end
end


functions.Skill = function(Tower)
    local towerInstance = workspace:FindFirstChild("Towers") and workspace.Towers:FindFirstChild(Tower)
    if towerInstance then
    
local args = {
    [1] = "Troops",
    [2] = "Abilities",
    [3] = "Activate",
    [4] = {
        ["Troop"] = workspace:WaitForChild("Towers"):WaitForChild("Commander"),
        ["Name"] = "Call Of Arms",
        ["Data"] = {}
    }
}

game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
    end
end

return functions
