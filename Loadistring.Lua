-- Carregando Rayfield
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "Runix V2",
   LoadingTitle = "Loading Runix",
   LoadingSubtitle = "by Sadz7",
   ShowText = "Hub",
   Theme = "Amethyst",
   ToggleUIKeybind = "G",
   ConfigurationSaving = { Enabled = true, FolderName = nil, FileName = "Runix Hub" }
})

-- Criando abas
local MainTab = Window:CreateTab("Main", 4483362458)
local OPTab = Window:CreateTab("OP", 4483362458)

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Configuração
local config = {
    ESP_Enabled = false,
    Team_Check = true,
    Hitbox_Enabled = false,
    Hitbox_Size = 7,
    Aimbot_Enabled = false,
    FOV_Radius = 150,
    Smoothness = 0.25,
    KillAura_Enabled = false,
    SpeedHack_Enabled = false,
    WalkSpeed = 30
}

-- ======================
--      FUNÇÕES
-- ======================

-- ESP
local function ESP_Player(player)
    if player == LocalPlayer then return end
    if config.Team_Check and player.Team == LocalPlayer.Team then return end
    if LocalPlayer.Team == nil then return end

    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local highlight = char:FindFirstChild("RunixESP")
    if not highlight then
        highlight = Instance.new("Highlight", char)
        highlight.Name = "RunixESP"
        highlight.FillTransparency = 0.6
        highlight.OutlineTransparency = 0.2
        highlight.OutlineColor = Color3.fromRGB(255,255,255)
    end
    highlight.FillColor = player.Team and player.Team.TeamColor and player.Team.TeamColor.Color or Color3.fromRGB(255,80,80)
    highlight.Enabled = config.ESP_Enabled
end

local function RemoveESP(player)
    if player.Character then
        local highlight = player.Character:FindFirstChild("RunixESP")
        if highlight then highlight.Enabled = false end
    end
end

local function SetupPlayer(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if config.ESP_Enabled then ESP_Player(player) else RemoveESP(player) end
    end)
end

for _,player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        SetupPlayer(player)
        if player.Character then ESP_Player(player) end
    end
end
Players.PlayerAdded:Connect(SetupPlayer)

-- HITBOX (normal + OP Hitbox)
local function UpdateHitboxes()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            if config.Hitbox_Enabled and (not config.Team_Check or player.Team ~= LocalPlayer.Team) then
                hrp.Size = Vector3.new(config.Hitbox_Size, config.Hitbox_Size, config.Hitbox_Size)
                hrp.Transparency = 0.6
                hrp.Material = Enum.Material.ForceField
            else
                hrp.Size = Vector3.new(2,2,1)
                hrp.Transparency = 1
                hrp.Material = Enum.Material.Plastic
            end
            hrp.CanCollide = false
        end
    end
end
RunService.Heartbeat:Connect(UpdateHitboxes)

-- SPEED HACK
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        local humanoid = LocalPlayer.Character.Humanoid

        if config.SpeedHack_Enabled then
            humanoid.WalkSpeed = config.WalkSpeed
        else
            humanoid.WalkSpeed = 16
        end
    end
end)

-- AIMBOT
local fovCircle = Drawing.new("Circle")
fovCircle.Color = Color3.fromRGB(255,255,0)
fovCircle.Thickness = 1
fovCircle.NumSides = 64
fovCircle.Radius = config.FOV_Radius
fovCircle.Filled = false
fovCircle.Transparency = 1
fovCircle.Visible = false

local function GetClosestEnemy()
    local closest = nil
    local shortestDist = config.FOV_Radius
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            if not config.Team_Check or player.Team ~= LocalPlayer.Team then
                local pos, onScreen = Camera:WorldToViewportPoint(player.Character.HumanoidRootPart.Position)
                if onScreen then
                    local dist = (Vector2.new(pos.X,pos.Y)-mousePos).Magnitude
                    if dist < shortestDist then
                        closest = player
                        shortestDist = dist
                    end
                end
            end
        end
    end
    return closest
end

RunService.RenderStepped:Connect(function()
    fovCircle.Position = UserInputService:GetMouseLocation()
    fovCircle.Radius = config.FOV_Radius
    fovCircle.Visible = config.Aimbot_Enabled

    if config.Aimbot_Enabled then
        local target = GetClosestEnemy()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            local targetPos, _ = Camera:WorldToViewportPoint(target.Character.Head.Position)
            local mousePos = UserInputService:GetMouseLocation()
            local newPos = mousePos:Lerp(Vector2.new(targetPos.X,targetPos.Y), config.Smoothness)
            mousemoverel(newPos.X - mousePos.X, newPos.Y - mousePos.Y)
        end
    end
end)

-- ======================
--      GUI
-- ======================

-- Main Tab GUI
local ESP_Toggle = MainTab:CreateToggle({
   Name = "ESP",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
       config.ESP_Enabled = Value
   end
})

local Team_Toggle = MainTab:CreateToggle({
   Name = "Team Check",
   CurrentValue = true,
   Flag = "TEAM",
   Callback = function(Value)
       config.Team_Check = Value
   end
})

local Hitbox_Slider = MainTab:CreateSlider({
   Name = "Hitbox Size",
   Range = {5,20},
   Increment = 1,
   Suffix = "Studs",
   CurrentValue = 7,
   Flag = "HITBOX",
   Callback = function(Value)
       config.Hitbox_Size = Value
       config.Hitbox_Enabled = true
   end
})

local Aimbot_Toggle = MainTab:CreateToggle({
   Name = "Aimbot",
   CurrentValue = false,
   Flag = "AIM",
   Callback = function(Value)
       config.Aimbot_Enabled = Value
   end
})

local FOV_Slider = MainTab:CreateSlider({
   Name = "FOV",
   Range = {50,100},
   Increment = 5,
   Suffix = "px",
   CurrentValue = 150,
   Flag = "FOV",
   Callback = function(Value)
       config.FOV_Radius = Value
   end
})

-- Speed Hack
local Speed_Toggle = MainTab:CreateToggle({
    Name = "Speed Hack",
    CurrentValue = false,
    Flag = "SPEED",
    Callback = function(Value)
        config.SpeedHack_Enabled = Value
    end
})

local Speed_Slider = MainTab:CreateSlider({
    Name = "Speed Value",
    Range = {30,65},
    Increment = 1,
    Suffix = "WalkSpeed",
    CurrentValue = 30,
    Flag = "SPEEDVAL",
    Callback = function(Value)
        config.WalkSpeed = Value
    end
})

-- OP Tab GUI
local OP_Hitbox_Toggle = OPTab:CreateToggle({
   Name = "OP Hitbox",
   CurrentValue = false,
   Flag = "OPHITBOX",
   Callback = function(Value)
       config.KillAura_Enabled = Value
       if Value then
           config.Hitbox_Enabled = true
           config.Hitbox_Size = 100
       else
           config.Hitbox_Enabled = false
           config.Hitbox_Size = 7
       end
   end
})

print("✅ Runix V2 carregado com Speed Hack máximo de 65 e OP Hitbox!")
