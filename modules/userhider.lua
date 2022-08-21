local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UI = util.UI
local Icons = util.Icons
local Directory = util.Directory

local UserHider = UI:Tab({
    Name = "User Hider",
    Icon = Icons.userhider
})

local visibleUsers = Players:GetPlayers()
-- remove LocalPlayer from list
visibleUsers[table.find(visibleUsers, Players.LocalPlayer)] = nil

local hiddenUsers = {}

function removeCharacter(player)
    local isHidden = table.find(hiddenUsers, player)
    local Character = player.Character

    if Character and isHidden then
        Character:Destroy()
    end

    player.CharacterAdded:Connect(function(character)
        isHidden = table.find(hiddenUsers, player)

        if isHidden then
            character:Destroy()
        end
    end)
end

local hideDropdown;
local showDropdown;

hideDropdown = UserHider:Dropdown({
    Name = "Hide",
    StartingText = "Select...",
    Description = "List of players who are visible",
    Items = visibleUsers,
    Callback = function(value)
        -- remove from visible list
        table.remove(visibleUsers, table.find(visibleUsers, value))
        hideDropdown:RemoveItems({
            value
        })

        -- add to hidden list
        table.insert(hiddenUsers, value)
        showDropdown:AddItems({
            value
        })

        -- remove character
        removeCharacter(value)
    end
})

showDropdown = UserHider:Dropdown({
    Name = "Show",
    StartingText = "Select...",
    Description = "List of players who are hidden",
    Items = hiddenUsers,
    Callback = function(value)
        -- remove from hidden list
        table.remove(hiddenUsers, table.find(hiddenUsers, value))
        showDropdown:RemoveItems({
            value
        })

        -- add to visible list
        table.insert(visibleUsers, value)
        hideDropdown:AddItems({
            value
        })
    end
})

for _, v in pairs(Players:GetPlayers()) do
    removeCharacter(v)
end

Players.PlayerAdded:Connect(function(player)
    removeCharacter(player)
end)

local Scroller = LocalPlayer.PlayerGui.Chat.Frame.ChatChannelParentFrame["Frame_MessageLogDisplay"].Scroller

Scroller.ChildAdded:Connect(function(child)
    local TextLabel = child:FindFirstChildOfClass("TextLabel")
    if not TextLabel then return end

    local TextButton = TextLabel.TextButton
    if not TextButton then return end

    local Name = TextButton.Text:sub(2, -3)
    local Player = Players:FindFirstChild(Name)

    if not Player then return end

    if table.find(hiddenUsers, Player) then
        task.wait()
        child:Destroy()
    end
end)