if not game:IsLoaded() then
    game.Loaded:Wait()
end

local environment = assert(getgenv, "<util> ~ Your exploit is not supported")()
local util = {
    version = "1.0.0",
    author = "3xjn",
    description = "A collection of useful utilities for Roblox.",
    website = "https://github.com/3xjn/utilities"
}
environment.util = util

local HttpService = game:GetService("HttpService")

if not isfolder("assets") then
    makefolder("assets")
end

local Directory = "assets/utilities"
util.Directory = Directory

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
    log = github .. "log.png",
    userhider = github .. "userhider.png",
}

util.Icons = Icons

-- Convert online assets to useable assets

for k, v in pairs(Icons) do
    local req = syn.request({
        Url = v,
        Method = "GET"
    })

    writefile(Directory .. "/" .. k .. ".png", req.Body)
    Icons[k] = getsynasset(Directory .. "/" .. k .. ".png")
end

local Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/3xjn/utilities/main/assets/MercuryFork.lua"))()

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
    ChatLogger = {
        Enabled = false
    },
    NameHighlight = {
        Enabled = false
    },
    Speed = 1,
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

util.Settings = Settings
util.pluralize = function(number, singular, plural)
    return number == 1 and singular or plural
end

util.UI = Mercury:Create({
    Name = "Utilities",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/3xjn/Utilities",
    Url = "utilities",
    Icon = Icons.hammer,
    HideKeybind = Settings.ToggleKeybind
})

function import(file)
    return loadstring(syn.request({
        Url = "https://raw.githubusercontent.com/3xjn/utilities/main/" .. file,
        Method = "GET"
    }).Body)()
end

import("modules/animation.lua")
import("modules/emotes.lua")
import("modules/acl.lua")
import("modules/antifling.lua")
import("modules/antiafk.lua")
import("modules/antikill.lua")
import("modules/chatlogger.lua")