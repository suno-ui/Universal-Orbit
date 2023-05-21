local game = game
if not game:IsLoaded() then
    local Loaded = game.Loaded
    Loaded:Wait()
end

local _L = {}
local args = {}

_L.timestamp = tick()

local players = game:GetService("Players") or game.Players
local localPlayer = players.LocalPlayer
local prefix = "?"

getgenv().isOrbiting = false

local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local center = rootPart.Position
local distance = 10
local angle = math.pi / 2

local function matchUser(searchString)
    if not searchString then
        return
    end

    local found = {}

    for _, player in ipairs(players:GetPlayers()) do
        if string.find(string.lower(player.Name), string.lower(searchString)) or string.find(string.lower(player.DisplayName), string.lower(searchString)) then
            table.insert(found, player)
        end
    end

    if #found > 0 then
        return found[1]
    else
        return nil
    end
end

local function orbit(user)
    getgenv().isOrbiting = true

    if not user then
      return
    else
        coroutine.wrap(function()
            while wait() do
                if not getgenv().isOrbiting then
                    break
                end

                local angular = tick() * angle
                local center = user.Character.HumanoidRootPart.Position

                local x = center.X + distance * math.cos(angular)
                local y = center.Y
                local z = center.Z + distance * math.sin(angular)

                rootPart.CFrame = CFrame.new(Vector3.new(x, y, z))
                rootPart.CFrame = CFrame.new(rootPart.Position, center)
            end
        end)()
    end
end

local function userChat(send, message)
    game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer(message, send)
end

local function Command(command)
    return args[1] == prefix .. command
end

local function onChatted(message)
    if not message then
        return
    end

    args = {}

    for arg in message:gmatch("%S+") do
        table.insert(args, arg)
    end

    if Command("orbit") then
        local target = matchUser(args[2])
        orbit(target)
    end

    if Command("stop") then
        getgenv().isOrbiting = false
    end
end

localPlayer.Chatted:Connect(onChatted)

local function onScriptLoaded()
    userChat("All", "Loaded in " .. string.format("%.5f", tick() - _L.timestamp) .. " seconds. See more projects on GitHub from suno-ui")
end

if game:IsLoaded() then
    onScriptLoaded()
end
