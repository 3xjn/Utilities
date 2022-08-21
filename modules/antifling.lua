local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UI = util.UI
local Icons = util.Icons
local Settings = util.Settings

local AntiFling = UI:Tab({
    Name = "Anti Fling",
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
    Name = "Anti Fling",
    StartingState = Settings.AntiFling.Enabled,
    Description = "Disable collisions with other players",
    Callback = function(state)
        Settings.AntiFling.Enabled = state
        PhysicsService:CollisionGroupSetCollidable("Players", "Players", not state)
    
        UI:Notification({
            Title = "Settings",
            Text = state and "Anti Fling has been enabled" or "AntiFling has been disabled",
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
        pcall(function()
            PhysicsService:CollisionGroupSetCollidable("Players", "Friends", state)
        end)

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