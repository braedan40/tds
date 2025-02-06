-- Define local functions and variables
local functions = {}
local PlaceNameradd = 0  -- Added to keep track of placements if needed elsewhere.

-- Dynamically retrieves a key for secure remote function calls
local function getDynamicKey()
    local dynamicKey = "DynamicKey_Generated_or_Fetched"
    if not dynamicKey then
        error("Failed to retrieve dynamic key.")
    end
    return dynamicKey
end

-- Wrapper to invoke a RemoteFunction on ReplicatedStorage
local function invokeRemote(args)
    local RemoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction")
    local dynamicKey = getDynamicKey()
    table.insert(args, 1, dynamicKey)
    local success, result = pcall(function()
        return RemoteFunction:InvokeServer(unpack(args))
    end)
    if not success then
        warn("RemoteFunction invocation failed: ", result)
    end
    return result
end

-- Utility functions to detect if we are in lobby or in a game
function inlobby()
    return game.PlaceId == 5591597781 
        or (game:GetService("Workspace"):FindFirstChild("Type") 
        and game:GetService("Workspace").Type.Value == "Lobby")
end

function ingame()
    return game.PlaceId == 3260590327 
        or (game:GetService("Workspace"):FindFirstChild("Type") 
        and game:GetService("Workspace").Type.Value == "Game")
end

-- Simple function for wave timer wait adjustments
function TimerWait(Number)
    return (Number - math.floor(Number) - 0.13) + 0.5
end

-- Convert minutes and seconds to a total count of seconds
function TotalOfSec(Minute, Second)
    return (Minute * 60) + math.ceil(Second)
end

-- Wait for wave timer
function waitwavetimer(Wave, Min, Sec, InWave)
    if ingame() then
        local gameState = require(game:GetService("ReplicatedStorage").Resources.Universal.GameState)
        local RSTimer = game:GetService("ReplicatedStorage"):WaitForChild("State"):WaitForChild("Timer"):WaitForChild("Time")
        local currentWave = gameState["Wave"]
        local targetTime = TotalOfSec(Min, Sec)

        -- If time is already below threshold, immediately return
        if (RSTimer.Value - targetTime) < -1 then
            return true
        end

        -- Wait until the timer is within 1 second of the target
        local Timer = 0
        repeat
            task.wait()
            Timer = RSTimer.Value - targetTime
        until Timer <= 1

        -- Wait an extra fraction (TimerWait) to approach the exact second
        game:GetService("RunService").Heartbeat:Wait(TimerWait(Sec))
        return true
    end
    return true
end

-------------------------------------------------------------------
-- Main functions table
-------------------------------------------------------------------

-- Map function: handles choosing an elevator or match setup
functions.Loadout = function(self, p1)
    local RemoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction")
    local TeleportService = game:GetService("TeleportService")
    local tableinfo = p1
    local TotalTowers = tableinfo
    local GoldenTowers = tableinfo["Golden"] or {}
    local LoadoutProps = self.Loadout
    local AllowEquip = tableinfo["AllowEquip"] or false
    local SkipCheck = tableinfo["SkipCheck"] or false
    LoadoutProps.AllowTeleport = type(LoadoutProps.AllowTeleport) == "boolean" and LoadoutProps.AllowTeleport or false
    local TroopsOwned = GetTowersInfo()
    for i,v in next, LoadoutProps do
        if string.find(typeof(v):lower(),"thread") then
            task.cancel(v)
        end
    end

    if CheckPlace() then
        for i,v in ipairs(TotalTowers) do
            if not (TroopsOwned[v] and TroopsOwned[v].Equipped) then
                prints("Loadout",v,TroopsOwned[v] and TroopsOwned[v].Equipped)
                ConsoleInfo(`Tower "{v}" Didn't Equipped. Rejoining To Lobby`)
                task.wait(1)
                --TeleportHandler(3260590327,2,7)
                TeleportService:Teleport(3260590327, LocalPlayer) --Do instant teleport maybe avoid detect place wrong tower
                return
            end
        end
        --ConsoleInfo("Loadout Selected: \""..table.concat(TotalTowers, "\", \"").."\"")
        return
    end
    --UI.EquipStatus:SetText("Troops Loadout: Equipping")

    self.Loadout.Task = task.spawn(function()
        if not SkipCheck then
            local MissingTowers = {}
            for i,v in ipairs(TotalTowers) do
                if not TroopsOwned[v] then
                    table.insert(MissingTowers,v)
                end
            end
            if #MissingTowers ~= 0 then
            --UI.EquipStatus:SetText("Troops Loadout: Missing")
            LoadoutProps.AllowTeleport = false
                repeat
                    TroopsOwned = GetTowersInfo()
                    for i,v in next, MissingTowers do
                        if not TroopsOwned[v] then
                            if true then
                                local BoughtCheck, BoughtMsg = RemoteFunction:InvokeServer("Shop", "Purchase", "tower",v)
                                if BoughtCheck or (type(BoughtMsg) == "string" and string.find(BoughtMsg,"Player already has tower")) then
                                    print(v..": Bought")
                                    --UI.TowersStatus[i].Text = v..": Bought"
                                else
                                    local TowerPriceStat = require(game:GetService("ReplicatedStorage").Content.Tower[v].Stats).Properties.Price
                                    local Price = tostring(TowerPriceStat.Value)
                                    local TypePrice = if tonumber(TowerPriceStat.Type) < 3 then "Coins" else "Gems"
                                    print(v..": Need "..Price.." "..TypePrice)
                                    --UI.TowersStatus[i].Text = v..": Need "..Price.." "..TypePrice
                                end
                            else
                                print(v..": Missing")
                                --UI.TowersStatus[i].Text = v..": Missing"
                            end
                        else
                            MissingTowers[i] = nil
                        end
                    end
                    task.wait(.5)
                until #MissingTowers == 0
            end
        end
        LoadoutProps.AllowTeleport = true
        if AllowEquip then
            local TroopsOwned = GetTowersInfo()
            for i,v in next, TroopsOwned do
                if v.Equipped then
                    RemoteEvent:FireServer("Inventory","Unequip","Tower",i)
                end
            end

            for i,v in ipairs(TotalTowers) do
                RemoteEvent:FireServer("Inventory", "Equip", "tower",v)
                local GoldenCheck = table.find(GoldenTowers,v)
                UI.TowersStatus[i].Text = (GoldenCheck and "[Golden] " or "")..v
                if TroopsOwned[v].GoldenPerks and not GoldenCheck then
                    RemoteEvent:FireServer("Inventory", "Unequip", "Golden", v)
                elseif GoldenCheck then
                    RemoteEvent:FireServer("Inventory", "Equip", "Golden", v)
                end
            end
            --UI.EquipStatus:SetText("Troops Loadout: Equipped")
            --ConsoleInfo("Loadout Selected: \""..table.concat(TotalTowers, "\", \"").."\"")
        end
    end)
end
functions.Map = function(MapName, bool, Type)
    if inlobby() then
        if not getgenv().Matchmaking then
            if getgenv().legitmode == true then
                for _, elevator in pairs(game:GetService("Workspace").Elevators:GetChildren()) do
                    local elevatorMap = elevator:GetAttribute("Map")
                    local playerCount = elevator:GetAttribute("Players")
                    local elevatorType = elevator:GetAttribute("Type")

                    if table.find(MapName, elevatorMap)
                        and playerCount < 1
                        and elevator:FindFirstChild("Touch")
                        and elevatorType == Type
                    then
                        -- Move player to the elevator
                        moveTo(elevator.Touch.Position)
                    elseif playerCount > 2 then
                        -- Move away from overcrowded elevator, then leave
                        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame =
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame
                            * CFrame.new(15, 6, 23.2)

                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Network")
                            :WaitForChild("Elevators")
                            :WaitForChild("Leave")
                            :InvokeServer()
                    end
                end
            else
                -- Not legit mode
                for _, elevator in pairs(game:GetService("Workspace").Elevators:GetChildren()) do
                    local elevatorMap = elevator:GetAttribute("Map")
                    local playerCount = elevator:GetAttribute("Players")

                    if table.find(MapName, elevatorMap) and playerCount < 1 then
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Network")
                            :WaitForChild("Elevators")
                            :WaitForChild("RF:Enter")
                            :InvokeServer(elevator)
                    elseif playerCount > 2 then
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("Network")
                            :WaitForChild("Elevators")
                            :WaitForChild("RF:Leave")
                            :InvokeServer()
                    end
                end
            end

        -------------------------------------------------------------------
        -- If matchmaking is enabled
        -------------------------------------------------------------------
        elseif getgenv().Matchmaking then
            -- If still in lobby, create a matchmaking instance
            if inlobby() then
                local RemoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction")
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
                    -- Possibly do something while in the match
                end

                repeat
                    game:GetService("RunService").Heartbeat:Wait()
                until game:GetService("Workspace"):FindFirstChild("IntermissionLobby")

                -- Voting logic for the map
                for i = 1, 4 do
                    local assignedMap = game:GetService("Workspace"):GetAttribute("Map" .. i)
                    if assignedMap and table.find(MapName, assignedMap) then
                        moveTo(game:GetService("Workspace").IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position)
                        local args = {
                            [1] = "LobbyVoting",
                            [2] = "Vote",
                            [3] = MapName,
                            [4] = game:GetService("Workspace").IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position
                        }
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
                    else
                        -- Veto, wait, re-check, or restart matchmaking
                        game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer("LobbyVoting", "Veto")
                        game:GetService("RunService").Heartbeat:Wait(5)

                        local newMapCheck = game:GetService("Workspace"):GetAttribute("Map" .. i)
                        if newMapCheck and table.find(MapName, newMapCheck) then
                            moveTo(game:GetService("Workspace").IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position)
                            local args = {
                                [1] = "LobbyVoting",
                                [2] = "Vote",
                                [3] = MapName,
                                [4] = game:GetService("Workspace").IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position
                            }
                            game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
                        else
                            local RemoteFunction = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction")
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
                            -- Go back to matchmaking if necessary
                        end
                    end
                end
            end
        end
    -------------------------------------------------------------------
    elseif ingame() then
        if game:GetService("ReplicatedStorage").State.Map == MapName then
            return true -- The map matched
        end
    end
end

-------------------------------------------------------------------
-- Place function
-------------------------------------------------------------------
functions.Place = function(self, params)
    -- Helper check for ingame() to unify usage
    local function isGame()
        return ingame()
    end

    if not isGame() then
        warn("Not in game, cannot place tower.")
        return
    end

    local Tower = params["TowerName"]
    local Position = params["Position"] or Vector3.new(0, 0, 0)
    local Rotation = params["Rotation"] or CFrame.new(0, 0, 0)
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    -- Wait for wave timer
    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    PlaceNameradd += 1

    local placementResult
    repeat
        placementResult = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(
            "Troops",
            "Pl\208\176ce",
            {
                ["Position"] = Position,
                ["Rotation"] = Rotation
            },
            Tower
        )
    until typeof(placementResult) == "Instance"

    -- Rename the tower
    placementResult.Name = PlaceNameradd

    -- Alternate remote usage example (commented out):
    --[[
    repeat
        placementResult = invokeRemote({
            "Troops",
            "Pl\208\176ce",
            {
                ["Position"] = Position,
                ["Rotation"] = Rotation
            },
            Tower
        })
    until typeof(placementResult) == "Instance"

    if placementResult then
        placementResult.Name = PlaceNameradd
    else
        warn("Failed to place the tower: ", Tower)
    end
    --]]
end

-------------------------------------------------------------------
-- Upgrade function
-------------------------------------------------------------------
functions.Upgrade = function(self, params)
    local Tower = params["TowerName"]
    local Position = params["Position"] or Vector3.new(0, 0, 0)
    local Rotation = params["Rotation"] or CFrame.new(0, 0, 0)
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    -- Wait for wave timer
    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    local args = {
        [1] = "Troops",
        [2] = "Upgrade",
        [3] = "Set",
        [4] = {
            ["Troop"] = game:GetService("Workspace").Towers:FindFirstChild(Tower),
            ["Path"] = 1
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
end

-------------------------------------------------------------------
-- Sell function
-------------------------------------------------------------------
functions.Sell = function(self, params)
    local Tower = params["TowerName"]
    local Position = params["Position"] or Vector3.new(0, 0, 0)
    local Rotation = params["Rotation"] or CFrame.new(0, 0, 0)
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    local args = {
        [1] = "Troops",
        [2] = "Sell",
        [3] = {
            ["Troop"] = game:GetService("Workspace").Towers:FindFirstChild(Tower)
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
end

-------------------------------------------------------------------
-- Skill/Ability function
-------------------------------------------------------------------
functions.Skill = function(self, params)
    local Tower = params["TowerName"]
    local AbilityName = params["AbilityName"] or "SkillName"  -- If needed
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    local args = {
        [1] = "Troops",
        [2] = "Abilities",
        [3] = "Activate",
        [4] = {
            ["Troop"] = game:GetService("Workspace").Towers:FindFirstChild(Tower),
            ["Name"] = AbilityName,
            ["Data"] = {}
        }
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
end

-------------------------------------------------------------------
-- Skip function
-------------------------------------------------------------------
functions.Skip = function(self, params)
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    local args = {
        [1] = "Voting",
        [2] = "Skip"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
end

-------------------------------------------------------------------
-- Return the table containing all functions
-------------------------------------------------------------------
return functions
