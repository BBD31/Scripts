local config = {
    TeamCheck = false,
    FOV = 150,
    Smoothing = 1,
    AimPart = "Torso", -- Aim Part
}

-- Services
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- GUI
local FOVring = Drawing.new("Circle")
FOVring.Visible = false
FOVring.Thickness = 1.5
FOVring.Radius = config.FOV
FOVring.Transparency = 1
FOVring.Color = Color3.fromRGB(255, 255, 255)
FOVring.Position = workspace.CurrentCamera.ViewportSize / 2

-- Function to get the closest visible player
local function getClosestVisiblePlayer(camera)
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            local character = player.Character
            local targetPart = character and character:FindFirstChild(config.AimPart) -- Цільова частина
            if targetPart then
                -- Team Check
                if config.TeamCheck and player.Team == Players.LocalPlayer.Team then
                    continue
                end

                local partPosition = targetPart.Position
                local screenPosition, onScreen = camera:WorldToViewportPoint(partPosition)
                local distanceToCenter = (Vector2.new(screenPosition.X, screenPosition.Y) - camera.ViewportSize / 2).Magnitude

                if onScreen and distanceToCenter < config.FOV and distanceToCenter < closestDistance then
                    closestDistance = distanceToCenter
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

-- Aimbot toggle
local aimbotEnabled = false
local aimbotConnection = nil

local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    FOVring.Visible = aimbotEnabled

    if aimbotEnabled then
        -- Start aiming
        aimbotConnection = RunService.RenderStepped:Connect(function()
            local camera = workspace.CurrentCamera
            local closestPlayer = getClosestVisiblePlayer(camera)

            if closestPlayer then
                local targetPart = closestPlayer.Character:FindFirstChild(config.AimPart)
                if targetPart then
                    local partPosition = targetPart.Position
                    local smoothing = math.clamp(config.Smoothing, 0.01, 10)
                    local targetCFrame = CFrame.new(camera.CFrame.Position, partPosition)
                    camera.CFrame = camera.CFrame:Lerp(targetCFrame, 1 / smoothing)
                end
            end
        end)
    else
        -- Stop aiming
        if aimbotConnection then
            aimbotConnection:Disconnect()
            aimbotConnection = nil
        end
    end
end
toggleAimbot() -- toggle
