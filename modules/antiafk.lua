local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UI = util.UI
local Icons = util.Icons
local Settings = util.Settings

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