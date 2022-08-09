-- if getgenv().utilities then
--     return
-- end

-- wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

getgenv().utilities = true

local HttpService = game:GetService("HttpService")

if not isfolder("assets") then
    makefolder("assets")
end

local Directory = "assets/utilities"

if not isfolder(Directory) then
    makefolder(Directory)
end

if not isfile(Directory .. "/emotes.json") then
    writefile(Directory .. "/emotes.json", "[]")
end 

-- We load all the assets from github

local github = "https://raw.githubusercontent.com/3xjn/utilities/main/assets/"
local Icons = {
    hammer = github .. "hammer.png",
    animation = github .. "animation.png",
    emotes = github .. "emotes.png",
    chat = github .. "chat.png",
    speed = github .. "speed.png",
    sleep = github .. "sleep.png",
}

-- Convert online assets to useable assets

for k, v in pairs(Icons) do
    local req = syn.request({
        Url = v,
        Method = "GET"
    })

    writefile(Directory .. "/" .. k .. ".png", req.Body)
    Icons[k] = getsynasset(Directory .. "/" .. k .. ".png")
end

local Mercury;

if isfile("mercury_fork.lua") then
    Mercury = loadstring(readfile("mercury_fork.lua"))()
else
    Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
end

if not isfile(Directory .. "/settings.json") then
    writefile(Directory .. "/settings.json", HttpService:JSONEncode({
        Animation = {},
        Emotes = {},
        ACL = {
            Enabled = true,
            allowEmotes = true,
        },
        AntiFling = {
            Enabled = false,
            ignoreFriends = true
        },
        AntiAfk = {
            Enabled = false
        },
        ToggleKeybind = "Enum.KeyCode.RightAlt"
    }))
end

local Settings = HttpService:JSONDecode(readfile(Directory .. "/settings.json"))

-- Parse Toggle Keybind
local Keybind = Settings.ToggleKeybind:split(".")

if Keybind[1] == "Enum" then
    Settings.ToggleKeybind = Enum[Keybind[2]][Keybind[3]]
end

local UI = Mercury:Create({
    Name = "Utilities",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/3xjn/Utilities",
    Url = "utilities",
    Icon = Icons.hammer,
    HideKeybind = Settings.ToggleKeybind
})


local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

local Animation = UI:Tab({
    Name = "Animation",
    Icon = Icons.animation
})

-- local paths = {
--     idle = {
--         "Animation1",
--         "Animation2"
--     },
--     walk = "WalkAnim",
--     run = "RunAnim",
--     jump = "JumpAnim",
--     climb = "ClimbAnim",
--     fall = "FallAnim"
-- }

-- local animations = syn.request({
--     Url = "https://raw.githubusercontent.com/3xjn/utilities/main/assets/animations.json",
--     Method = "GET"
-- }).Body

-- animations = HttpService:JSONDecode(animations)

-- local animationNames = {}

-- for k, v in pairs(animations) do
--     animationNames[#animationNames + 1] = k
-- end

-- table.sort(animationNames)

-- local LocalPlayer = Players.LocalPlayer
-- local selectAnimations = {
-- }

-- for k, v in pairs(paths) do
--     local function create(name, i)
--         Animation:Dropdown({
--             Name = name:gsub("^%l", string.upper) .. i or "",
--             StartingText = "Select...",
--             Description = nil,
--             Items = animationNames,
--             Callback = function(item)
                
--             end
--         })
--     end

--     if type(v) == "table" then
--         for i, _ in pairs(v) do
--             create(k, i)
--         end
--     else
--         create(k)
--     end
-- end

local Emotes = UI:Tab({
    Name = "Emotes",
    Icon = Icons.emotes
})

function update()
    writefile(Directory .. "/emotes.json", HttpService:JSONEncode(Settings.Emotes))
    
    local Character = LocalPlayer.Character
    if not Character then return end

    local Humanoid = Character:WaitForChild("Humanoid")
    local HumanoidDescription = Humanoid:WaitForChild("HumanoidDescription", 1/0)

    local emoteTable = {}
    local equippedEmotes = {}

    for _, v in pairs(Settings.Emotes) do
        local name = MarketplaceService:GetProductInfo(v).Name
        emoteTable[name] = {v}
        table.insert(equippedEmotes, name)
    end

    HumanoidDescription:SetEmotes(emoteTable)
    HumanoidDescription:SetEquippedEmotes(equippedEmotes)
    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, true)
end

Settings.Emotes = HttpService:JSONDecode(readfile(Directory .. "/emotes.json")) or {}

if #Settings.Emotes > 0 then
    update()
end

for i=1, 8 do
    Emotes:Textbox({
        Name = "Emote" .. i,
        StartingText = "Select...",
        Callback = function(text)
            local isDigit = tonumber(text)

            if isDigit then
                Settings.Emotes[i] = isDigit
                print(isDigit)
                update()
            end

            -- Mercury:Notification({
            --     Title = "Alert",
            --     Text = "Successfully set emote " .. i .. " to " .. text,
            --     Duration = 3
            -- })
        end
    })
end

update()
LocalPlayer.CharacterAdded:Connect(update)

local ACL = UI:Tab({
    Name = "ACL",
    Icon = Icons.chat
})

ACL:Toggle({
    Name = "ACL",
    StartingState = Settings.ACL.Enabled,
    Description = "Disable chat logging on the server",
    Callback = function(state)
        Settings.ACL.Enabled = state

        -- Mercury:Notification({
        --     Title = "Alert",
        --     Text = state and "ACL has been enabled" or "ACL has been disabled",
        --     Duration = 3
        -- })
    end
})

ACL:Toggle({
    Name = "Allow Emotes",
    StartingState = Settings.ACL.allowEmotes,
    Description = "Allow messages starting with \"/e \" to be sent",
    Callback = function(state)
        Settings.ACL.allowEmotes = state
    end
})

local PostMessage = require(LocalPlayer:WaitForChild("PlayerScripts", 1/0):WaitForChild("ChatScript", 1/0):WaitForChild("ChatMain", 1/0)).MessagePosted
getgenv().MessageEvent = Instance.new("BindableEvent")

local OldFunctionHook;
local PostMessageHook = function(self, msg)
    local aclSettings = Settings.ACL
    if aclSettings.Enabled and not checkcaller() and self == PostMessage then
        if aclSettings.allowEmotes and msg:sub(1, 3) == "/e " then
            return OldFunctionHook(self, msg)
        end
        
        return print("[ACL] " .. msg)
    end

    -- -- print aclSettings.Enabled and not checkcaller() and self == PostMessage and (not aclSettings.allowEmotes and msg:sub(1, 3) == "/e ")
    -- print(tostring(aclSettings.Enabled) .. " " .. tostring(not checkcaller()) .. " " .. tostring(self == PostMessage) .. " " .. tostring(not aclSettings.allowEmotes) .. " " .. tostring(msg:sub(1, 3) == "/e "))
    return OldFunctionHook(self, msg)
end

OldFunctionHook = hookfunction(PostMessage.fire, PostMessageHook)
getgenv().OldFunctionHook = OldFunctionHook

local AntiFling = UI:Tab({
    Name = "AntiFling",
    Icon = Icons.speed
})

loadstring(game:HttpGet("https://raw.githubusercontent.com/LegoHacker1337/legohacks/main/PhysicsServiceOnClient.lua"))()

local PhysicsService = game:GetService("PhysicsService")
pcall(function()
    PhysicsService:CreateCollisionGroup("Players")
    PhysicsService:CreateCollisionGroup("Friends")
    PhysicsService:CollisionGroupSetCollidable("Players", "Players", not Settings.AntiFling.Enabled)
    PhysicsService:CollisionGroupSetCollidable("Players", "Friends", Settings.AntiFling.ignoreFriends)
end)


AntiFling:Toggle({
    Name = "AntiFling",
    StartingState = Settings.AntiFling.Enabled,
    Description = "Disable collisions with other players",
    Callback = function(state)
        Settings.AntiFling.Enabled = state
        PhysicsService:CollisionGroupSetCollidable("Players", "Players", not state)
    end
})

AntiFling:Toggle({
    Name = "Ignore Friends",
    StartingState = Settings.AntiFling.ignoreFriends,
    Description = "Enable collisions with friends",
    Callback = function(state)
        Settings.AntiFling.ignoreFriends = state
        PhysicsService:CollisionGroupSetCollidable("Players", "Friends", state)
    end
})

local function OnCharacterAdded(Character, isFriends)
    coroutine.resume(coroutine.create(function()
        Character:WaitForChild("HumanoidRootPart", 1/0)
        task.wait()
        for i,v in pairs(Character:GetDescendants()) do
            if v:IsA("BasePart") then
                if isFriends then
                    PhysicsService:SetPartCollisionGroup(v, "Friends")
                else
                    PhysicsService:SetPartCollisionGroup(v, "Players")
                end
            end
        end
    end))
end

local function OnPlayerAdded(Player)
    Player.CharacterAdded:Connect(OnCharacterAdded)
    if Player.Character then
        OnCharacterAdded(Player.Character, Player:IsFriendsWith(LocalPlayer.UserId))
    end
end

Players.PlayerAdded:Connect(OnPlayerAdded)

for i,v in pairs(Players:GetPlayers()) do
    OnPlayerAdded(v)
end

local AntiAfk = UI:Tab({
    Name = "AntiAfk",
    Icon = Icons.sleep
})

AntiAfk:Toggle({
    Name = "AntiAfk",
    StartingState = Settings.AntiAfk.Enabled,
    Description = "Disable AFK kick",
    Callback = function(state)
        Settings.AntiAfk.Enabled = state

        if state then
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do
                v:Disable()
            end
        else
            for _, v in pairs(getconnections(LocalPlayer.Idled)) do
                v:Enable()
            end
        end
    end
})