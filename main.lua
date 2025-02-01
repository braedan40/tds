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
   if inlobby() then


        if not getgenv().Matchmaking then

            if getgenv().legitmode == true then
                for _, elevator in pairs(game:GetService("Workspace").Elevators:GetChildren()) do
                    local elevatorMap = elevator:GetAttribute("Map")
                    local playerCount = elevator:GetAttribute("Players")
                    local elevatorType = elevator:GetAttribute("Type")


                    if table.find(Map, elevatorMap)
                       and playerCount < 1
                       and elevator:FindFirstChild("Touch")
                       and elevatorType == Type
                    then
                        moveTo(elevator.Touch.Position)
                    elseif playerCount > 2 then
                        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame =
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame * CFrame.new(15, 6, 23.2)

                        -- This call “Leave”
                        game:GetService("ReplicatedStorage"):WaitForChild("Network"):WaitForChild("Elevators"):WaitForChild("Leave"):InvokeServer()
                    end
                end

            else

                for _, elevator in pairs(game:GetService("Workspace").Elevators:GetChildren()) do
                    local elevatorMap = elevator:GetAttribute("Map")
                    local playerCount = elevator:GetAttribute("Players")

                    if table.find(Map, elevatorMap) and playerCount < 1 then
                        ReplicatedStorage:WaitForChild("Network"):WaitForChild("Elevators"):WaitForChild("RF:Enter"):InvokeServer(elevator)
                    elseif playerCount > 2 then
                        ReplicatedStorage:WaitForChild("Network"):WaitForChild("Elevators"):WaitForChild("RF:Leave"):InvokeServer()
                    end
                end
            end


        elseif getgenv().Matchmaking then
            if inlobby() then

                RemoteFunction:InvokeServer("Multiplayer", "single_create")
                local args = {
                [1] = "Multiplayer",
                [2] = "v2:start",
                [3] = {
                ["difficulty"] = mode,
                ["mode"] = Type,
                ["count"] = 1
             }
         }

RemoteFunction:InvokeServer(unpack(args))

            elseif ingame() then
                for i = 1, 4 do

                end

                repeat
                    game:GetService("RunService").Heartbeat:Wait()
                until game:GetService("Workspace"):FindFirstChild("IntermissionLobby")


                for i = 1, 4 do
                    local assignedMap = game:GetService("Workspace"):GetAttribute("Map" .. i)
                    if assignedMap and table.find(Map, assignedMap) then
                        moveTo(game:GetService("Workspace").IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position)
                        local args = {
                            [1] = "LobbyVoting",
                            [2] = "Vote",
                            [3] = Map,
                            [4] = game:GetService("Workspace").IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position
                        }
                        ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer(unpack(args))
                    else
                        RemoteEvent:FireServer("LobbyVoting", "Veto")
                        game:GetService("RunService").Heartbeat:Wait(5)

                        local newMapCheck = game:GetService("Workspace"):GetAttribute("Map" .. i)
                        if newMapCheck and table.find(Map, newMapCheck) then
                            moveTo(game:GetService("Workspace").IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position)
                            local args = {
                                [1] = "LobbyVoting",
                                [2] = "Vote",
                                [3] = Map,
                                [4] = game:GetService("Workspace").IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position
                            }
                            ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer(unpack(args))
                        else
                            RemoteFunction:InvokeServer("Multiplayer", "single_create")
                        local args = {
                [1] = "Multiplayer",
                [2] = "v2:start",
                [3] = {
                ["difficulty"] = mode,
                ["mode"] = Type,
                ["count"] = 1
             }
         }

RemoteFunction:InvokeServer(unpack(args))
-- yeah go back to matchmaking again or i can made it leave
                        end
                    end
                end
            end
        end


    elseif ingame() then
    if game:GetService("ReplicatedStorage").State.Map == Map then
        return true --print("Map Matched..") -- yeah for function.place
    end
end

functions.Place = function(Tower, wave, Timer)
    if ingame() then
        local tabletower = tableinfo[Tower]
        if not tabletower then
            warn("Tower data not found!")
            return
        end
        
        local position = tabletower.Position or CFrame.new(0, 0, 0)
        local rotation = tabletower.Rotation or Vector3.new(0, 0, 0)
        
        repeat
            task.wait()
        until waitwavetimer(wave, Timer)
        
        local place
        repeat
            local args = {
                [1] = "Troops",
                [2] = "Pl\208\176ce",
                [3] = {
                    ["Rotation"] = rotation,
                    ["Position"] = position
                },
                [4] = "Scout"
            }
            place = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
        until typeof(place) == "Instance"
        
        place.Name += 1 --place.Name .. "1"
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


functions.Skill = function(Tower,wave,Timer,Abilityname)
    local towerInstance = workspace:FindFirstChild("Towers") and workspace.Towers:FindFirstChild(Tower)
    if towerInstance then
    repeat task.wait() until waitwavetimer(wave, Timer)
local args = {
    [1] = "Troops",
    [2] = "Abilities",
    [3] = "Activate",
    [4] = {
        ["Troop"] = Tower,
        ["Name"] = AbilityName,
        ["Data"] = {}
    }
}

game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
    end
end
functions.Skip = function(wave,Timer)
            repeat task.wait() until waitwavetimer(wave,Timer)
        local args = {
    [1] = "Voting",
    [2] = "Skip"
}

game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))

        end
return functions
