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
    block = github .. "block.png",
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

local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/3xjn/Utilities/main/assets/MercuryFork.lua"))()

local templateSettings = {
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
    AntiKill = {
        AntiVoid = false,
        AntiTKill = false
    },
    ToggleKeybind = "Enum.KeyCode.RightAlt"
}

if not isfile(Directory .. "/settings.json") then
    writefile(Directory .. "/settings.json", HttpService:JSONEncode(templateSettings))
end

local Settings = HttpService:JSONDecode(readfile(Directory .. "/settings.json"))

-- check if there are any new settings that need to be added to the saved settings
for k, v in pairs(templateSettings) do
    if not Settings[k] then
        Settings[k] = v
    end
end

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

local animations = syn.request({
    Url = "https://raw.githubusercontent.com/3xjn/utilities/main/assets/animations.json",
    Method = "GET"
}).Body

animations = HttpService:JSONDecode(animations)

local animationNames = {}

for k, v in pairs(animations) do
    animationNames[#animationNames + 1] = k
end

table.sort(animationNames)

local paths = {
    "idle.Animation1",
    "idle.Animation2",
    "walk.WalkAnim",
    "run.RunAnim",
    "jump.JumpAnim",
    "climb.ClimbAnim",
    "fall.FallAnim"
}

local LocalPlayer = Players.LocalPlayer
local selectedAnimations;

if isfile(Directory .. "/animations.json") then
    selectedAnimations = HttpService:JSONDecode(readfile(Directory .. "/animations.json"))
else
    selectedAnimations = {}
end

function aUpdate(firstLoad)
    local Character = LocalPlayer.Character

    if not Character then
        return
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    if Humanoid.RigType ~= Enum.HumanoidRigType.R15 then 
        return UI:Notification({
            Title = "Alert",
            Text = "Your character is not using the R15 rig.",
            Duration = 3,
            Icon = Icons.animation
        })
    end

    local Animate = Character:WaitForChild("Animate")

    if not Animate then
        return
    end

    for path, item in pairs(selectedAnimations) do
        -- go from item name to id
        -- get index of path in paths
        local index = table.find(paths, path)
        
        if index then
            local id = animations[item][index]
            local split = path:split(".")

            Animate[split[1]][split[2]].AnimationId = "rbxassetid://" .. id

            if not firstLoad then
                UI:Notification({
                    Title = "Animation Updated",
                    Text = item .. " - " .. path,
                    Duration = 3,
                    Icon = Icons.animation
                })
            end
        end
    end

    writefile(Directory .. "/animations.json", HttpService:JSONEncode(selectedAnimations))
end

function pluralize(number, singular, plural)
    if number == 1 then
        return singular
    end

    return plural
end

-- both # operator and table.getn are broken so we must use this disgusting workaround
local count = 0

for _, _ in pairs(selectedAnimations) do
    count = count + 1
end

if count > 0 then
    if LocalPlayer.Character then
        aUpdate(true)
        UI:Notification({
            Title = "Loaded",
            Text = ("%u %s loaded"):format(count, pluralize(count, "animation", "animations")),
            Duration = 3,
            Icon = Icons.animation
        })
    end
end

LocalPlayer.CharacterAdded:Connect(aUpdate)

for k, v in pairs(paths) do
    local split = v:split(".")

    local name = split[2]:gsub("^%l", string.upper) .. (i or "")
    Animation:Dropdown({
        Name = name,
        StartingText = selectedAnimations[v] or "Select...",
        Description = nil,
        Items = animationNames,
        Callback = function(item)
            selectedAnimations[v] = item
            aUpdate()
        end
    })
end

local Emotes = UI:Tab({
    Name = "Emotes",
    Icon = Icons.emotes
})

function eUpdate()
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
    eUpdate()

    UI:Notification({
        Title = "Loaded",
        Text = ("%u %s loaded"):format(#Settings.Emotes, pluralize(#Settings.Emotes, "emote", "emotes")),
        Duration = 3,
        Icon = Icons.emotes
    })
end

for i=1, 8 do
    Emotes:Textbox({
        Name = "Emote" .. i,
        Placeholder = Settings.Emotes[i] or "Select...",
        Callback = function(text)
            local isDigit = tonumber(text)

            if isDigit then
                Settings.Emotes[i] = isDigit
                print(isDigit)
                eUpdate()
            end

            UI:Notification({
                Title = "Updated",
                Text = "Successfully set emote " .. i .. " to " .. text,
                Duration = 3,
                Icon = Icons.emotes
            })
        end
    })
end

eUpdate()
LocalPlayer.CharacterAdded:Connect(eUpdate)

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

        UI:Notification({
            Title = "Settings",
            Text = state and "ACL has been enabled" or "ACL has been disabled",
            Duration = 3,
            Icon = Icons.chat
        })
    end
})

ACL:Toggle({
    Name = "Allow Emotes",
    StartingState = Settings.ACL.allowEmotes,
    Description = "Allow messages starting with \"/e \" to be sent",
    Callback = function(state)
        Settings.ACL.allowEmotes = state

        UI:Notification({
            Title = "Settings",
            Text = "Allow emotes has been " .. (state and "enabled" or "disabled"),
            Duration = 3,
            Icon = Icons.chat
        })
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
    
        UI:Notification({
            Title = "Settings",
            Text = state and "AntiFling has been enabled" or "AntiFling has been disabled",
            Duration = 3,
            Icon = Icons.speed
        })
    end
})

AntiFling:Toggle({
    Name = "Ignore Friends",
    StartingState = Settings.AntiFling.ignoreFriends,
    Description = "Enable collisions with friends",
    Callback = function(state)
        Settings.AntiFling.ignoreFriends = state
        PhysicsService:CollisionGroupSetCollidable("Players", "Friends", state)

        UI:Notification({
            Title = "Settings",
            Text = "Ignore friends has been " .. (state and "enabled" or "disabled"),
            Duration = 3,
            Icon = Icons.speed
        })
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

        UI:Notification({
            Title = "Settings",
            Text = state and "AntiAfk has been enabled" or "AntiAfk has been disabled",
            Duration = 3,
            Icon = Icons.sleep
        })
    end
})

local AntiKill = UI:Tab({
    Name = "AntiKill",
    Icon = Icons.block
})

AntiKill:Toggle({
    Name = "Anti Void",
    StartingState = Settings.AntiKill.AntiVoid,
    Description = "Stop people from void killing you",
    Callback = function(state)
        Settings.AntiKill.AntiVoid = state

        UI:Notification({
            Title = "Settings",
            Text = state and "AntiVoid has been enabled" or "AntiVoid has been disabled",
            Duration = 3,
            Icon = Icons.block
        })
    end
})

local Tools = {}

local Players = game:GetService("Players")
function ToolCheck(Tool: Tool)
    if not Tool:IsA("Tool") then return end

    -- check if tool is descendant of player backpack or player's character
    local owner;

    for _, v in pairs(Players:GetPlayers()) do
        if Tool:IsDescendantOf(v.Backpack) or Tool:IsDescendantOf(v.Character) then
            owner = v
            break
        end
    end

    if not owner then return end

    Tools[Tool] = {
        owner = owner,
    }
end

for _, v in pairs(game:GetDescendants()) do
    ToolCheck(v)
end 

game.DescendantAdded:Connect(function(descendant)
    ToolCheck(descendant)
end)

local LocalPlayer = Players.LocalPlayer

function antivoid(character)
    character.ChildAdded:Connect(function(child)
        if not Settings.AntiKill.AntiVoid then return end
        task.wait()
        -- make sure you're not the owner of the tool
        if Tools[child] and Tools[child].owner ~= LocalPlayer then
            child:Destroy()
        end
    end)
end

antivoid(LocalPlayer.Character)
LocalPlayer.CharacterAdded:Connect(antivoid)

AntiKill:Button({
    Name = "Anti Tool Kill",
    Description = "Stop people from killing you with tools",
    Callback = function()
        LocalPlayer.Character.Humanoid.Sit = true
        LocalPlayer.Character.Humanoid:SetStateEnabled("Seated", false)
    end
})