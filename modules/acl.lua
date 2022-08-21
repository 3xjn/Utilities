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