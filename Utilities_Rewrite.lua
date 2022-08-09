-- if getgenv().utilities then
--     return
-- end

-- wait for game to load
if not game:IsLoaded() then
    game.Loaded:Wait()
end

getgenv().utilities = true

local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local CoreGui = game:GetService("CoreGui")

local Mercury;

if isfile("mercury_fork.lua") then
    Mercury = loadstring(readfile("mercury_fork.lua"))()
else
    Mercury = loadstring(game:HttpGet("https://raw.githubusercontent.com/deeeity/mercury-lib/master/src.lua"))()
end

local UI = Mercury:Create({
    Name = "Utilities",
    Size = UDim2.fromOffset(600, 400),
    Theme = Mercury.Themes.Dark,
    Link = "https://github.com/3xjn/Utilities",
})