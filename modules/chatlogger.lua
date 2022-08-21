local UI = util.UI
local Icons = util.Icons
local Settings = util.Settings

local ChatLogger = UI:Tab({
    Name = "ChatLogger",
    Icon = Icons.log
})

ChatLogger:Toggle({
    Name = "Chat Logger",
    StartingState = Settings.ChatLogger.Enabled,
    Description = "Logs chat messages to a file",
    Callback = function(state)
        Settings.ChatLogger.Enabled = state
        UI:Notification({
            Title = "Settings",
            Text = state and "Chat Logger has been enabled" or "Chat Logger has been disabled",
            Duration = 3,
            Icon = Icons.log
        })
    end
})

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local date = os.date("%m-%d-%Y")
local Filename = ("chatlogs/[%s] %s.txt"):format(date, MarketplaceService:GetProductInfo(game.PlaceId).Name)

if not isfolder("chatlogs") then
    makefolder("chatlogs")
end

local chatEvents = game:GetService("ReplicatedStorage"):WaitForChild("DefaultChatSystemChatEvents")
local messageDoneFiltering = chatEvents:WaitForChild("OnMessageDoneFiltering")

messageDoneFiltering.OnClientEvent:Connect(function(message)
    if not Settings.ChatLogger.Enabled then return end

    -- update filename if it's a new day
    if date ~= os.date("%m-%d-%Y") then
        date = os.date("%m-%d-%Y")
        Filename = ("chatlogs/[%s] %s.txt"):format(date, MarketplaceService:GetProductInfo(game.PlaceId).Name)

        if not isfile(Filename) then
            writefile(Filename, "")
        end
    end

	local player = Players:FindFirstChild(message.FromSpeaker)
	local message = message.Message or ""

	if player then
        if not isfile(Filename) then
            writefile(Filename, "")
        end

        -- if this is first entry, do not append a newline
        if readfile(Filename) == "" then
            writefile(Filename, ("%s - %s: %s"):format(os.date("%I:%M %p"), player.Name, message))
        else
            appendfile(Filename, ("\n%s - %s: %s"):format(os.date("%I:%M %p"), player.Name, message))
        end
	end
end)