--------------------------------------------------------------------------------
-- Define local functions and variables
--------------------------------------------------------------------------------

local functions = {}
local PlaceNameradd = 0  -- Added to keep track of placements if needed elsewhere.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TeleportService = game:GetService("TeleportService")

-- OPTIONAL: Define RemoteEvent if you haven’t elsewhere:
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent") 
local RemoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")

-- OPTIONAL: If needed, define "LocalPlayer" for TeleportService
local LocalPlayer = Players.LocalPlayer

--------------------------------------------------------------------------------
-- Example placeholders for printing methods (adjust as needed)
--------------------------------------------------------------------------------

local function ConsoleInfo(msg)
	print("[ConsoleInfo]: " .. msg)
end

local function prints(...)
	print(...)
end

--------------------------------------------------------------------------------
-- Dynamically retrieves a key for secure remote function calls
--------------------------------------------------------------------------------
--[[local function getDynamicKey()
    local dynamicKey = "DynamicKey_Generated_or_Fetched"
    if not dynamicKey then
        error("Failed to retrieve dynamic key.")
    end
    return dynamicKey
end

--------------------------------------------------------------------------------
-- Wrapper to invoke a RemoteFunction on ReplicatedStorage
--------------------------------------------------------------------------------
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
end]]

--------------------------------------------------------------------------------
-- Utility functions to detect if we are in lobby or in a game
--------------------------------------------------------------------------------
function inlobby()
    return game.PlaceId == 3260590327 
        or (
            game:GetService("Workspace"):FindFirstChild("Type") 
            and game:GetService("Workspace").Type.Value == "Lobby"
        )
end

function ingame()
    return game.PlaceId == 5591597781 
        or (
            game:GetService("Workspace"):FindFirstChild("Type") 
            and game:GetService("Workspace").Type.Value == "Game"
        )
end

--------------------------------------------------------------------------------
-- Simple function for wave timer wait adjustments
--------------------------------------------------------------------------------
function TimerWait(Number)
    -- The function returns a fractional wait offset
    return (Number - math.floor(Number) - 0.13) + 0.5
end

--------------------------------------------------------------------------------
-- Convert minutes and seconds to a total count of seconds
--------------------------------------------------------------------------------
function TotalOfSec(Minute, Second)
    return (Minute * 60) + math.ceil(Second)
end

--------------------------------------------------------------------------------
-- Wait for wave timer
--------------------------------------------------------------------------------
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
   -- return true
end

--------------------------------------------------------------------------------
-- "Loadout" function
--------------------------------------------------------------------------------

-- Retrieves towers info from the game (inventory data)
function GetTowersInfo()
    local GetResult
    task.delay(6, function()
        if not type(GetResult) == "table" then
            GetResult = {}
            prints("Can't Get Towers Information From Game")
        end
    end)
    repeat 
        task.wait()
        GetResult = RemoteFunction:InvokeServer("Session", "Search", "Inventory.Troops")
    until type(GetResult) == "table"
    return GetResult
end

-- Primary loadout function
functions.Loadout = function(self, params)
    --[[local tableinfo = params
    local TotalTowers = tableinfo
    local GoldenTowers = tableinfo["Golden"] or {}
  -- Instead of 'LoadoutProps = self.Loadout', do:
local LoadoutProps = self.LoadoutProps

-- Now LoadoutProps is a table:
    local AllowEquip = tableinfo["AllowEquip"] or false
    local SkipCheck = tableinfo["SkipCheck"] or false

    LoadoutProps.AllowTeleport = (typeof(LoadoutProps.AllowTeleport) == "boolean") 
    local TroopsOwned = GetTowersInfo()

    -- Cancel any coroutines in LoadoutProps
    for i, v in pairs(LoadoutProps) do
        if typeof(v):lower():find("thread") then
            task.cancel(v)
        end
    end

    -- If already in the game place, validate that towers are equipped
    if ingame() then
        for _, towerName in ipairs(TotalTowers) do
            if not (TroopsOwned[towerName] and TroopsOwned[towerName].Equipped) then
                prints("Loadout", towerName, TroopsOwned[towerName] and TroopsOwned[towerName].Equipped)
                ConsoleInfo("Tower \"" .. towerName .. "\" did not equip. Rejoining to Lobby.")
                task.wait(1)
                TeleportService:Teleport(3260590327, LocalPlayer)
                return
            end
        end
        return
    end

    -- If not in the correct place, spawn a task to check for missing towers & equip them
    self.Loadout.Task = task.spawn(function()
        
        if not SkipCheck then
            local MissingTowers = {}
            for _, towerName in ipairs(TotalTowers) do
                if not TroopsOwned[towerName] then
                    table.insert(MissingTowers, towerName)
                end
            end

            -- Try to purchase missing towers
            if #MissingTowers > 0 then
                LoadoutProps.AllowTeleport = false
                
                repeat
                    TroopsOwned = GetTowersInfo()  -- Refresh tower info
                    for i, towerName in pairs(MissingTowers) do
                        if not TroopsOwned[towerName] then
                            local BoughtCheck, BoughtMsg = RemoteFunction:InvokeServer("Shop", "Purchase", "tower", towerName)
                            if BoughtCheck 
                               or (type(BoughtMsg) == "string" and string.find(BoughtMsg, "Player already has tower")) 
                            then
                                print(towerName .. ": Bought")
                            else
                                local TowerPriceStat = require(ReplicatedStorage.Content.Tower[towerName].Stats).Properties.Price
                                local priceVal = tostring(TowerPriceStat.Value)
                                local currencyType = (tonumber(TowerPriceStat.Type) < 3) and "Coins" or "Gems"

                                print(towerName .. ": Need " .. priceVal .. " " .. currencyType)
                            end
                        else
                            MissingTowers[i] = nil
                        end
                    end
                    task.wait(0.5)
                until #MissingTowers == 0
            end
        end

        LoadoutProps.AllowTeleport = true

        -- If allowed, actually equip the specified towers
        if AllowEquip then
            TroopsOwned = GetTowersInfo()  -- Update after any purchases

            -- Unequip everything first
            for towerName, towerData in pairs(TroopsOwned) do
                if towerData.Equipped then
                    RemoteEvent:FireServer("Inventory", "Unequip", "Tower", towerName)
                end
            end

            -- Now equip user’s requested towers
            for i, towerName in ipairs(TotalTowers) do
                RemoteEvent:FireServer("Inventory", "Equip", "tower", towerName)

                local isGolden = table.find(GoldenTowers, towerName)
                
                -- OPTIONAL: If you have a UI table, update text
                if UI and UI.TowersStatus and UI.TowersStatus[i] then
                    UI.TowersStatus[i].Text = (isGolden and "[Golden] " or "") .. towerName
                end

                -- Equip or unequip golden perks
                if TroopsOwned[towerName] 
                   and TroopsOwned[towerName].GoldenPerks 
                   and not isGolden 
                then
                    RemoteEvent:FireServer("Inventory", "Unequip", "Golden", towerName)
                elseif isGolden then
                    RemoteEvent:FireServer("Inventory", "Equip", "Golden", towerName)
                end
            end
        end
    end)]]
end

--------------------------------------------------------------------------------
-- Example usage for "Loadout" (commented-out demonstration)
--------------------------------------------------------------------------------
--[[
local myModule = {}
myModule.Loadout = {}

Loadout(myModule, {
    "TowerA", "TowerB", Golden = {"TowerA"}, AllowEquip = true, SkipCheck = false
})
--]]

--------------------------------------------------------------------------------
-- "Map" function (handles choosing an elevator or match setup)
--------------------------------------------------------------------------------
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
                        -- Move player to the elevator (define 'moveTo' in your code if needed)
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
                        ["difficulty"] = mode,  -- 'mode' not defined in snippet, placeholder
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
                                    ["difficulty"] = mode,  -- 'mode' not defined in snippet, placeholder
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
        -- If we’re already in game, just check the map
        if game:GetService("ReplicatedStorage").State.Map == MapName then
            return true -- The map matched
        end
    end
end
functions.Mode = function(self,params)
if ingame() then
local DiffTable = {
        ["Easy"] = "Easy",
        ["Casual"] = "Casual",
        ["Intermediate"] = "Intermediate",
        ["Molten"] = "Molten",
        ["Fallen"] = "Fallen"
    }
    local ModeName = DiffTable[params.Name] or params.Name
local HasDifficultyVotedGUI =  game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("ReactGameDifficulty"):WaitForChild("Frame"):WaitForChild("buttons")
if game:GetService("ReplicatedStorage").State.Difficulty == ModeName then
return true
		else
repeat task.wait() until HasDifficultyVotedGUI
local args = {
    [1] = "Difficulty",
    [2] = "Vote",
    [3] = ModeName
}

game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
task.wait(1)
local args = {
    [1] = "Difficulty",
    [2] = "Ready"
}

game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))

		end
end
--------------------------------------------------------------------------------
-- Place function
--------------------------------------------------------------------------------
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
    if not game:GetService("ReplicatedStorage").Assets.Troops:FindFirstChild(Tower) then
				local args = {
    [1] = "Streaming",
    [2] = "SelectTower",
    [3] = Tower,
    [4] = "Default"
}

game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvent"):FireServer(unpack(args))
repeat task.wait() until game:GetService("ReplicatedStorage").Assets.Troops:FindFirstChild(Tower)
end
    -- Wait for wave timer
    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    PlaceNameradd += 1

    local placementResult
    repeat
        placementResult = game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(
            "Troops",
            "Place",
            {
                ["Position"] = Position,
                ["Rotation"] = Rotation
            },
            Tower
        )
    until typeof(placementResult) == "Instance"

    -- Rename the placed tower
    placementResult.Name = PlaceNameradd

    --[[
    -- Alternate usage example:
    repeat
        placementResult = invokeRemote({
            "Troops",
            "Place",
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

--------------------------------------------------------------------------------
-- Upgrade function
--------------------------------------------------------------------------------
functions.Upgrade = function(self, params)
    local Tower = params["TowerName"]
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

--------------------------------------------------------------------------------
-- Sell function
--------------------------------------------------------------------------------
functions.Sell = function(self, params)
    local Tower = params["TowerName"]
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    -- Wait for wave timer
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

--------------------------------------------------------------------------------
-- Skill/Ability function
--------------------------------------------------------------------------------
functions.Skill = function(self, params)
    local Tower = params["TowerName"]
    local AbilityName = params["AbilityName"] or "SkillName"
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    -- Wait for wave timer
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

--------------------------------------------------------------------------------
-- Skip function
--------------------------------------------------------------------------------
functions.Skip = function(self, params)
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    -- Wait for wave timer
    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    local args = {
        [1] = "Voting",
        [2] = "Skip"
    }
    game:GetService("ReplicatedStorage"):WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
end
end

return functions 
