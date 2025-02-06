--------------------------------------------------------------------------------
-- Module: functions.lua
--------------------------------------------------------------------------------
local functions = {}

--------------------------------------------------------------------------------
-- Services & Local Variables
--------------------------------------------------------------------------------
local PlaceNameradd = 0  -- Tracks placements if needed elsewhere

local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PathfindingService = game:GetService("PathfindingService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- Example RemoteEvents/RemoteFunctions if they exist in ReplicatedStorage
local RemoteEvent = ReplicatedStorage:WaitForChild("RemoteEvent")
local RemoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")

--------------------------------------------------------------------------------
-- Example Logging Functions
--------------------------------------------------------------------------------
local function ConsoleInfo(msg)
	print("[ConsoleInfo]: " .. msg)
end

local function prints(...)
	print(...)
end

--------------------------------------------------------------------------------
-- Move Character Using Pathfinding
--------------------------------------------------------------------------------
local function moveTo(target)
    local path = PathfindingService:CreatePath()
    path:ComputeAsync(rootPart.Position, target.Position)

    if path.Status == Enum.PathStatus.Success then
        local waypoints = path:GetWaypoints()
        for _, waypoint in ipairs(waypoints) do
            humanoid:MoveTo(waypoint.Position)
            humanoid.MoveToFinished:Wait()
            if waypoint.Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end
        end
    else
        warn("Path not found or obstructed.")
    end
end

--------------------------------------------------------------------------------
-- Check if in Lobby or In-Game
--------------------------------------------------------------------------------
function inlobby()
    return game.PlaceId == 3260590327 
        or (
            workspace:FindFirstChild("Type") 
            and workspace.Type.Value == "Lobby"
        )
end

function ingame()
    return game.PlaceId == 5591597781 
        or (
            workspace:FindFirstChild("Type") 
            and workspace.Type.Value == "Game"
        )
end

--------------------------------------------------------------------------------
-- Timer Utility
--------------------------------------------------------------------------------
function TimerWait(Number)
    -- Returns a fractional wait offset
    return (Number - math.floor(Number) - 0.13) + 0.5
end

function TotalOfSec(Minute, Second)
    return (Minute * 60) + math.ceil(Second)
end

function waitwavetimer(Wave, Min, Sec, InWave)
    if ingame() then
        local gameState = require(ReplicatedStorage.Resources.Universal.GameState)
        local RSTimer = ReplicatedStorage:WaitForChild("State"):WaitForChild("Timer"):WaitForChild("Time")
        local currentWave = gameState["Wave"]
        local targetTime = TotalOfSec(Min, Sec)

        if (RSTimer.Value - targetTime) < -1 then
            return true
        end

        local Timer = 0
        repeat
            task.wait()
            Timer = RSTimer.Value - targetTime
        until Timer <= 1

        game:GetService("RunService").Heartbeat:Wait(TimerWait(Sec))
        return true
    end
end

--------------------------------------------------------------------------------
-- Towers / Inventory Info
--------------------------------------------------------------------------------
local function GetTowersInfo()
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

--------------------------------------------------------------------------------
-- Loadout Function
--------------------------------------------------------------------------------
functions.Loadout = function(self, params)
    -- Example usage of parameters
    local TotalTowers = params
    local GoldenTowers = params["Golden"] or {}
    local AllowEquip = params["AllowEquip"] or false
    local SkipCheck = params["SkipCheck"] or false
    local TroopsOwned = GetTowersInfo()

    -- If we’re already in the game place, validate that towers are equipped
    if ingame() then
        for _, towerName in ipairs(TotalTowers) do
            if not (TroopsOwned[towerName] and TroopsOwned[towerName].Equipped) then
                prints("Loadout", towerName, TroopsOwned[towerName] and TroopsOwned[towerName].Equipped)
                ConsoleInfo("Tower \"" .. towerName .. "\" did not equip. Rejoining to Lobby.")
                task.wait(1)
                TeleportService:Teleport(3260590327, player)
                return
            end
        end
        return
    end

    -- If not in game, spawn a task to check for missing towers & equip them
    task.spawn(function()
        if not SkipCheck then
            local MissingTowers = {}
            for _, towerName in ipairs(TotalTowers) do
                if not TroopsOwned[towerName] then
                    table.insert(MissingTowers, towerName)
                end
            end
            if #MissingTowers > 0 then
                repeat
                    TroopsOwned = GetTowersInfo()
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

        -- If allowed, equip the specified towers
        if AllowEquip then
            TroopsOwned = GetTowersInfo()

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
                -- If you have a UI, you could do:
                -- if UI and UI.TowersStatus and UI.TowersStatus[i] then
                --     UI.TowersStatus[i].Text = (isGolden and "[Golden] " or "") .. towerName
                -- end

                if TroopsOwned[towerName] 
                   and TroopsOwned[towerName].GoldenPerks 
                   and not isGolden then
                    RemoteEvent:FireServer("Inventory", "Unequip", "Golden", towerName)
                elseif isGolden then
                    RemoteEvent:FireServer("Inventory", "Equip", "Golden", towerName)
                end
            end
        end
    end)
end

--------------------------------------------------------------------------------
-- Map Function
--------------------------------------------------------------------------------
functions.Map = function(MapName, bool, Type)
    if inlobby() then
        if not getgenv().Matchmaking then
            if getgenv().legitmode == true then
                for _, elevator in pairs(workspace.Elevators:GetChildren()) do
                    local elevatorMap = elevator:GetAttribute("Map")
                    local playerCount = elevator:GetAttribute("Players")
                    local elevatorType = elevator:GetAttribute("Type")

                    if table.find(MapName, elevatorMap)
                       and playerCount < 1
                       and elevator:FindFirstChild("Touch")
                       and elevatorType == Type
                    then
                        moveTo(elevator.Touch.Position)
                    elseif playerCount > 2 then
                        player.Character.HumanoidRootPart.CFrame =
                            player.Character.HumanoidRootPart.CFrame * CFrame.new(15, 6, 23.2)

                        ReplicatedStorage
                            :WaitForChild("Network")
                            :WaitForChild("Elevators")
                            :WaitForChild("Leave")
                            :InvokeServer()
                    end
                end
            else
                -- Not legit mode
                for _, elevator in pairs(workspace.Elevators:GetChildren()) do
                    local elevatorMap = elevator:GetAttribute("Map")
                    local playerCount = elevator:GetAttribute("Players")

                    if table.find(MapName, elevatorMap) and playerCount < 1 then
                        ReplicatedStorage
                            :WaitForChild("Network")
                            :WaitForChild("Elevators")
                            :WaitForChild("RF:Enter")
                            :InvokeServer(elevator)
                    elseif playerCount > 2 then
                        ReplicatedStorage
                            :WaitForChild("Network")
                            :WaitForChild("Elevators")
                            :WaitForChild("RF:Leave")
                            :InvokeServer()
                    end
                end
            end

        -------------------------------------------------------------------
        -- Matchmaking
        -------------------------------------------------------------------
        elseif getgenv().Matchmaking then
            if inlobby() then
                local RemoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")
                RemoteFunction:InvokeServer("Multiplayer", "single_create")

                -- “mode” here must be defined if you actually need it:
                local args = {
                    [1] = "Multiplayer",
                    [2] = "v2:start",
                    [3] = {
                        ["difficulty"] = (getgenv().mode or "Normal"),
                        ["mode"] = Type,
                        ["count"] = 1
                    }
                }
                RemoteFunction:InvokeServer(unpack(args))

            elseif ingame() then
                for _ = 1, 4 do
                    -- Possibly do something in the match
                end
                repeat
                    game:GetService("RunService").Heartbeat:Wait()
                until workspace:FindFirstChild("IntermissionLobby")

                -- Voting logic for the map
                for i = 1, 4 do
                    local assignedMap = workspace:GetAttribute("Map" .. i)
                    if assignedMap and table.find(MapName, assignedMap) then
                        moveTo(workspace.IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position)
                        local voteArgs = {
                            [1] = "LobbyVoting",
                            [2] = "Vote",
                            [3] = MapName,
                            [4] = workspace.IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position
                        }
                        ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer(unpack(voteArgs))
                    else
                        ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer("LobbyVoting", "Veto")
                        task.wait(5)

                        local newMapCheck = workspace:GetAttribute("Map" .. i)
                        if newMapCheck and table.find(MapName, newMapCheck) then
                            moveTo(workspace.IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position)
                            local newVoteArgs = {
                                [1] = "LobbyVoting",
                                [2] = "Vote",
                                [3] = MapName,
                                [4] = workspace.IntermissionLobby.Boards.Board[i].Hitboxes.VotePlatform.Position
                            }
                            ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer(unpack(newVoteArgs))
                        else
                            local RemoteFunction = ReplicatedStorage:WaitForChild("RemoteFunction")
                            RemoteFunction:InvokeServer("Multiplayer", "single_create")

                            local retryArgs = {
                                [1] = "Multiplayer",
                                [2] = "v2:start",
                                [3] = {
                                    ["difficulty"] = (getgenv().mode or "Normal"),
                                    ["mode"] = Type,
                                    ["count"] = 1
                                }
                            }
                            RemoteFunction:InvokeServer(unpack(retryArgs))
                        end
                    end
                end
            end
        end

    elseif ingame() then
        -- If already in game, check the map
        if ReplicatedStorage:FindFirstChild("State") and ReplicatedStorage.State.Map == MapName then
            return true
        end
    end
end

--------------------------------------------------------------------------------
-- Mode Function
--------------------------------------------------------------------------------
functions.Mode = function(self, params)
    if ingame() then
        local DiffTable = {
            ["Easy"] = "Easy",
            ["Casual"] = "Casual",
            ["Intermediate"] = "Intermediate",
            ["Molten"] = "Molten",
            ["Fallen"] = "Fallen"
        }
        local ModeName = DiffTable[params.Name] or params.Name

        local HasDifficultyVotedGUI = player.PlayerGui
            :WaitForChild("ReactGameDifficulty")
            :WaitForChild("Frame")
            :WaitForChild("buttons")

        if ReplicatedStorage.State.Difficulty == ModeName then
            return true
        else
            repeat task.wait() until HasDifficultyVotedGUI
            local argsVote = {
                [1] = "Difficulty",
                [2] = "Vote",
                [3] = ModeName
            }
            ReplicatedStorage:WaitForChild("RemoteFunction"):InvokeServer(unpack(argsVote))

            task.wait(1)
            local argsReady = {
                [1] = "Difficulty",
                [2] = "Ready"
            }
            ReplicatedStorage:WaitForChild("RemoteFunction"):InvokeServer(unpack(argsReady))
        end
    end
end

--------------------------------------------------------------------------------
-- Place Function
--------------------------------------------------------------------------------
functions.Place = function(self, params)
    if not ingame() then
        warn("Not in game, cannot place tower.")
        return
    end

    local Tower = params["TowerName"]
    local Position = params["Position"] or Vector3.new(0, 0, 0)
    local Rotation = params["Rotation"] or CFrame.new(0, 0, 0)
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    -- Make sure the tower is actually loaded in ReplicatedStorage (some scripts do dynamic loading)
    if not ReplicatedStorage.Assets.Troops:FindFirstChild(Tower) then
        local args = {
            [1] = "Streaming",
            [2] = "SelectTower",
            [3] = Tower,
            [4] = "Default"
        }
        ReplicatedStorage:WaitForChild("RemoteEvent"):FireServer(unpack(args))
        repeat 
            task.wait() 
        until ReplicatedStorage.Assets.Troops:FindFirstChild(Tower)
    end

    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    -- Instead of += 1, use standard Lua increment
    PlaceNameradd = PlaceNameradd + 1

    local placementResult
    repeat
        placementResult = ReplicatedStorage:WaitForChild("RemoteFunction"):InvokeServer(
            "Troops",
            "Place",
            {
                ["Position"] = Position,
                ["Rotation"] = Rotation
            },
            Tower
        )
        task.wait()
    until typeof(placementResult) == "Instance"

    placementResult.Name = PlaceNameradd
end

--------------------------------------------------------------------------------
-- Upgrade Function
--------------------------------------------------------------------------------
functions.Upgrade = function(self, params)
    local Tower = params["TowerIndex"]
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    local args = {
        [1] = "Troops",
        [2] = "Upgrade",
        [3] = "Set",
        [4] = {
            ["Troop"] = workspace.Towers:FindFirstChild(Tower),
            ["Path"] = 1
        }
    }
    ReplicatedStorage:WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
end

--------------------------------------------------------------------------------
-- Sell Function
--------------------------------------------------------------------------------
functions.Sell = function(self, params)
    local Tower = params["TowerName"]
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    local args = {
        [1] = "Troops",
        [2] = "Sell",
        [3] = {
            ["Troop"] = workspace.Towers:FindFirstChild(Tower)
        }
    }
    ReplicatedStorage:WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
end

--------------------------------------------------------------------------------
-- Skill/Ability Function
--------------------------------------------------------------------------------
functions.Skill = function(self, params)
    local Tower = params["TowerName"]
    local AbilityName = params["AbilityName"] or "SkillName"
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    local args = {
        [1] = "Troops",
        [2] = "Abilities",
        [3] = "Activate",
        [4] = {
            ["Troop"] = workspace.Towers:FindFirstChild(Tower),
            ["Name"] = AbilityName,
            ["Data"] = {}
        }
    }
    ReplicatedStorage:WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
end

--------------------------------------------------------------------------------
-- Skip Function
--------------------------------------------------------------------------------
functions.Skip = function(self, params)
    local Wave, Min, Sec, InWave = params["Wave"] or 0, params["Minute"] or 0, params["Second"] or 0, params["InBetween"] or false

    repeat task.wait() until waitwavetimer(Wave, Min, Sec, InWave)

    local args = {
        [1] = "Voting",
        [2] = "Skip"
    }
    ReplicatedStorage:WaitForChild("RemoteFunction"):InvokeServer(unpack(args))
end

--------------------------------------------------------------------------------
-- Return the module
--------------------------------------------------------------------------------
return functions
