local UI = util.UI
local Icons = util.Icons
local Settings = util.Settings
local saveSettings = util.saveSettings

local InteractionESP = UI:Tab({
    Name = "Interaction ESP",
    Icon = Icons.interaction
})

local Objects = {}

function updateEsp()
    for k, v in pairs(Objects) do
        if Settings.InteractionESP.Enabled[k.ClassName] then
            v.Visible = true
        else
            v.Visible = false
        end

        v.Color = Color3.fromRGB(unpack(Settings.InteractionESP.Colors[k.ClassName] or {255, 255, 255}))
    end
end

for className, enabled in pairs(Settings.InteractionESP.Enabled) do
    if className == true and enabled == true then continue end -- dumb fucking bug idk why it happens
    InteractionESP:Toggle({
        Name = className,
        StartingState = enabled,
        Description = ("Enable %s ESP"):format(className),
        Callback = function(state)
            Settings.InteractionESP.Enabled[enabled] = state
            updateEsp()
        end
    })
end

for className, color in pairs(Settings.InteractionESP.Colors) do
    InteractionESP:Colorpicker({
        Name = className,
        StartingColor = color,
        Description = ("Change %s ESP color"):format(className),
        Callback = function(color)
            Settings.InteractionESP.Colors[className] = {
                r = color.r,
                g = color.g,
                b = color.b
            }

            saveSettings()
            updateEsp()
        end
    })
end

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Blissful4992/ESPs/main/3D%20Drawing%20Api.lua"))()

game:GetService("RunService").RenderStepped:Connect(function()
    for k, Cube in pairs(Objects) do
        Cube.Size = k.Size
        Cube.Rotation = k.Rotation
        Cube.Position = k.Position

        -- Check for color
        local color = Settings.InteractionESP.Colors[k.ClassName]
        if color then
            Cube.Color = Color3.fromRGB(color[1], color[2], color[3])
        else
            Cube.Color = Color3.fromRGB(255, 255, 255)
        end

        Cube.Transparency = 0.5
        Cube.Thickness = 0.5
        Cube.Filled = false
        Cube.Visible = true
    end
end)

function add(v)
    for className, enabled in pairs(Settings.InteractionESP.Enabled) do
        if v:IsA(className) and v.Parent:IsA("BasePart") and enabled then
            Objects[v.Parent] = Library:New3DCube()
        end
    end
end

for _, v in pairs(game:GetDescendants()) do
    add(v)
end

game.DescendantAdded:Connect(add)