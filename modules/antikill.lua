local Players = game:GetService("Players")

local UI = util.UI
local Icons = util.Icons
local Settings = util.Settings

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