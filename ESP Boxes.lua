local toggleKey = "E" -- bind
local espEnabled = false

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera


local espBoxes = {}


local function getTeamColor(player)
    if player.Team then
        return player.TeamColor.Color 
    else
        return Color3.new(1, 0, 0) -- color
    end
end

local function createBox(player)
    if espBoxes[player] then return end 

    local box = Drawing.new("Square")
    box.Color = getTeamColor(player) 
    box.Thickness = 1 -- хз можна менять
    box.Filled = false -- хз
    box.Visible = false
    espBoxes[player] = box
end

local function updateBox(player)
    if not espEnabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        if espBoxes[player] then
            espBoxes[player].Visible = false
        end
        return
    end

    if player == LocalPlayer then
        if espBoxes[player] then
            espBoxes[player].Visible = false
        end
        return
    end

    if teamCheckEnabled and player.Team == LocalPlayer.Team then
        if espBoxes[player] then
            espBoxes[player].Visible = true
        end
    end

    local rootPart = player.Character.HumanoidRootPart
    local rootPos, onScreen = Camera:WorldToViewportPoint(rootPart.Position)

    local box = espBoxes[player]
    if onScreen then
        box.Color = getTeamColor(player) 
        local size = Vector2.new(2000 / rootPos.Z, 3000 / rootPos.Z) 
        box.Size = size
        box.Position = Vector2.new(rootPos.X - size.X / 2, rootPos.Y - size.Y / 2)
        box.Visible = true
    else
        box.Visible = false
    end
end

local function clearBoxes()
    for _, box in pairs(espBoxes) do
        if box then
            box:Remove()
        end
    end
    espBoxes = {}
end

local function toggleESP()
    espEnabled = not espEnabled
    if not espEnabled then
        clearBoxes()
    else
        for _, player in ipairs(Players:GetPlayers()) do
            createBox(player)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if espEnabled then
            createBox(player)
        end
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    if espBoxes[player] then
        espBoxes[player]:Remove()
        espBoxes[player] = nil
    end
end)

game:GetService("RunService").RenderStepped:Connect(function()
    if espEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            updateBox(player)
        end
    end
end)

game:GetService("UserInputService").InputBegan:Connect(function(input, isProcessed)
    if isProcessed then return end
    if input.KeyCode == Enum.KeyCode[toggleKey] then
        toggleESP()
    end
end)
