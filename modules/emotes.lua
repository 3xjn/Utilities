local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local UI = util.UI
local Icons = util.Icons
local Settings = util.Settings
local Directory = util.Directory

local pluralize = util.pluralize

local Emotes = UI:Tab({
    Name = "Emotes",
    Icon = Icons.emotes
})

function updateEmotes()
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
    updateEmotes()

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
                updateEmotes()

                UI:Notification({
                    Title = "Updated",
                    Text = "Successfully set emote " .. i .. " to " .. text,
                    Duration = 3,
                    Icon = Icons.emotes
                })
            else
                UI:Notification({
                    Title = "Error",
                    Text = "Invalid emote id",
                    Duration = 3,
                    Icon = Icons.emotes
                })
            end
        end
    })
end

Emotes:Slider({
    Name = "Speed",
    Default = 1,
    Min = 0,
    Max = 9999,
    Callback = function(value)
        local Character = LocalPlayer.Character

        if not Character then UI:Notification({
            Title = "Error",
            Text = "No character found.",
            Duration = 3,
            Icon = Icons.emotes
        }) return end

        local Humanoid = Character:WaitForChild("Humanoid")

        if not Humanoid then UI:Notification({
            Title = "Error",
            Text = "No humanoid found.",
            Duration = 3,
            Icon = Icons.emotes
        }) return end

        local Animate = Character:WaitForChild("Animate")

        if not Animate then UI:Notification({
            Title = "Error",
            Text = "No animate found.",
            Duration = 3,
            Icon = Icons.emotes
        }) return end

        local senv = getsenv(Animate)
        local setAnimationSpeed = senv.setAnimationSpeed

        setAnimationSpeed(value)
    end
})

updateEmotes()
LocalPlayer.CharacterAdded:Connect(updateEmotes)