local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UI = util.UI
local Icons = util.Icons
local Settings = util.Settings

local ACL = UI:Tab({
    Name = "Anti Chat Logger",
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

local regexPatterns = {}
Settings.ACL.regexPatterns = regexPatterns

local emoteRegex = "^/e"

if Settings.ACL.allowEmotes then
    regexPatterns[#regexPatterns + 1] = emoteRegex
end

local removePattern;

ACL:Toggle({
    Name = "Allow Emotes",
    StartingState = Settings.ACL.allowEmotes,
    Description = "Allow messages starting with \"/e \" to be sent",
    Callback = function(state)
        Settings.ACL.allowEmotes = state

        local index = table.find(regexPatterns, emoteRegex)

        if state then
            if not index then
                regexPatterns[#regexPatterns + 1] = emoteRegex
            end
        else
            if index then
                table.remove(regexPatterns, index)
            end
        end

        UI:Notification({
            Title = "Settings",
            Text = "Allow emotes has been " .. (state and "enabled" or "disabled"),
            Duration = 3,
            Icon = Icons.chat
        })
    end
})

ACL:Textbox({
    Name = "Add Pattern",
    Callback = function(pattern)
        if pattern ~= "" and not table.find(regexPatterns, pattern) then
            regexPatterns[#regexPatterns + 1] = pattern
            removePattern:AddItems({
                pattern
            })

            UI:Notification({
                Title = "Settings",
                Text = ("Added `%s` to regex list"):format(pattern),
                Duration = 3,
                Icon = Icons.chat
            })
        end
    end
})

removePattern = ACL:Dropdown({
    Name = "Remove Pattern",
    StartingText = "Select...",
    Items = {},
    Callback = function(item)
        local find = table.find(regexPatterns, item)

        if find then
            table.remove(regexPatterns, find)
            removePattern:RemoveItems({
                item
            })
        end
    end
})

function acl()
    local PostMessage = require(LocalPlayer:WaitForChild("PlayerScripts", 1/0):WaitForChild("ChatScript", 1/0):WaitForChild("ChatMain", 1/0)).MessagePosted
    getgenv().MessageEvent = Instance.new("BindableEvent")

    local OldFunctionHook;
    local PostMessageHook = function(self, msg)
        local aclSettings = Settings.ACL
        if aclSettings.Enabled and not checkcaller() and self == PostMessage then
            for _, v in pairs(aclSettings.regexPatterns) do
                if msg:match(v) then
                    return OldFunctionHook(self, msg)
                end
            end

            
            return print("[ACL] " .. msg)
        end

        return OldFunctionHook(self, msg)
    end

    OldFunctionHook = hookfunction(PostMessage.fire, PostMessageHook)
    getgenv().OldFunctionHook = OldFunctionHook
end

if not StarterGui:GetCoreGuiEnabled(Enum.CoreGuiType.Chat) then
    local coreGuiChangedConnection;
    coreGuiChangedConnection = StarterGui.CoreGuiChangedSignal:Connect(function(coreGuiType, enabled)
        if not coreGuiType == Enum.CoreGuiType.Chat and not enabled then return end

        task.wait(2)
        acl()

        coreGuiChangedConnection:Disconnect()
    end)
else
    acl()
end