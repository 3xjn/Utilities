local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local UI = util.UI
local Icons = util.Icons
local Directory = util.Directory

local pluralize = util.pluralize

local Animation = UI:Tab({
    Name = "Animation",
    Icon = Icons.animation
})

local animations = syn.request({
    Url = "https://raw.githubusercontent.com/3xjn/utilities/main/assets/animations.json",
    Method = "GET"
}).Body

animations = HttpService:JSONDecode(animations)

local animationNames = {}

for k, v in pairs(animations) do
    animationNames[#animationNames + 1] = k
end

table.sort(animationNames)

local paths = {
    "idle.Animation1",
    "idle.Animation2",
    "walk.WalkAnim",
    "run.RunAnim",
    "jump.JumpAnim",
    "climb.ClimbAnim",
    "fall.FallAnim"
}

local LocalPlayer = Players.LocalPlayer
local selectedAnimations;

if isfile(Directory .. "/animations.json") then
    selectedAnimations = HttpService:JSONDecode(readfile(Directory .. "/animations.json"))
else
    selectedAnimations = {}
end

function updateAnims()
    local Character = LocalPlayer.Character

    if not Character then
        return
    end

    local Humanoid = Character:FindFirstChildOfClass("Humanoid")

    if not Humanoid then
        return
    end

    if Humanoid.RigType ~= Enum.HumanoidRigType.R15 then
        return UI:Notification({
            Title = "Alert",
            Text = "Your character is not using the R15 rig.",
            Duration = 3,
            Icon = Icons.animation
        })
    end

    local Animate = Character:WaitForChild("Animate")

    if not Animate then
        return
    end

    for path, item in pairs(selectedAnimations) do
        -- go from item name to id
        -- get index of path in paths
        local index = table.find(paths, path)
        
        if index then
            local id = animations[item][index]
            local split = path:split(".")

            local animGroup = Animate:FindFirstChild(split[1])

            if animGroup then
                local anim = animGroup:FindFirstChild(split[2])

                anim.AnimationId = "rbxassetid://" .. id
            end
        end
    end

    writefile(Directory .. "/animations.json", HttpService:JSONEncode(selectedAnimations))
end

-- both # operator and table.getn are broken so we must use this disgusting workaround
local count = 0

for _, _ in pairs(selectedAnimations) do
    count = count + 1
end

if count > 0 then
    if LocalPlayer.Character then
        updateAnims()
        UI:Notification({
            Title = "Loaded",
            Text = ("%u %s loaded"):format(count, pluralize(count, "animation", "animations")),
            Duration = 3,
            Icon = Icons.animation
        })
    end
end

for _, v in pairs(paths) do
    local split = v:split(".")

    local name = split[2]:gsub("^%l", string.upper)
    Animation:Dropdown({
        Name = (name:match("Animation") and "Idle" .. name:sub(-1, -1)) or name,
        StartingText = selectedAnimations[v] or "Select...",
        Description = nil,
        Items = animationNames,
        Callback = function(item)
            selectedAnimations[v] = item
            updateAnims()

            UI:Notification({
                Title = "Animation Updated",
                Text = ("%s set to %s"):format(name, item),
                Duration = 3,
                Icon = Icons.animation
            })
        end
    })
end

LocalPlayer.CharacterAdded:Connect(updateAnims)