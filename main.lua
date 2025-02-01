local functions = {} 

function inlobby()
    return game.PlaceId == 5591597781 or game:GetService("Workspace"):FindFirstChild("Type") and game:GetService("Workspace").Type.Value == "Lobby"
end

function ingame()
    return game.PlaceId == 3260590327 or game:GetService("Workspace"):FindFirstChild("Type") and game:GetService("Workspace").Type.Value == "Game"
end

function waitwavetimer(wave, Timer)
    if ingame() then
        return game:GetService("ReplicatedStorage").State.Timer.Time
    end
end

functions.Map = function(MapName)
    -- Implement this function
end

functions.Place = function(Tower)
    if ingame() then
        local tabletower = tableinfo[Tower]
        if not tabletower then
            warn("Tower data not found!")
            return
        end

        local position = tabletower.Position or CFrame.new(0, 0, 0)
        local rotation = tabletower.Rotation or Vector3.new(0, 0, 0)

        local place
        repeat
            local args = {
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

functions.Upgrade = function(Tower)
    local towerInstance = workspace:FindFirstChild("Towers") and workspace.Towers:FindFirstChild(Tower)
    
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

return functions
