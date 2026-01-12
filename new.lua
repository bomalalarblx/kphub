local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local PlayerGui = player:FindFirstChild("PlayerGui")

-- Define UI colors
local COLORS = {
    FrameBackgroundTransparency = 0.3, -- Semi-transparent background for sleek UI
    TextPurple = Color3.fromRGB(160, 90, 255), -- Neon purple color for all text
}

local screenGui

-- Function to remove previous UI
local function clearPreviousUI()
    if PlayerGui:FindFirstChild("BrainrotFinder") then
        PlayerGui.BrainrotFinder:Destroy()
    end
end

local function createDraggable(frame)
    local dragging, dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    frame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function createGui()
    if not PlayerGui then return end

    -- Clear previous UI
    clearPreviousUI()

    -- ScreenGui creation
    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrainrotFinder"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Global
    screenGui.Parent = PlayerGui

    -- Overlay creation (small bar design)
    local overlayWidth, overlayHeight = 280, 75 -- Compact dimensions
    local overlay = Instance.new("Frame")
    overlay.Size = UDim2.new(0, overlayWidth, 0, overlayHeight)
    overlay.Position = UDim2.new(0.5, -overlayWidth / 2, 0.1, 0) -- Middle above the screen
    overlay.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Dark background
    overlay.BackgroundTransparency = COLORS.FrameBackgroundTransparency -- Semi-transparent background
    overlay.BorderSizePixel = 0 -- No border
    overlay.ZIndex = 2
    overlay.Parent = screenGui

    -- Rounded corners
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10) -- Smooth rounded corners
    corner.Parent = overlay

    -- Title creation
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -20, 0, 25)
    title.Position = UDim2.new(0.5, -overlayWidth / 2, 0, 5)
    title.BackgroundTransparency = 1
    title.Text = "KP's Hub v1.0"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 20 -- Title font size
    title.TextColor3 = COLORS.TextPurple -- Static neon purple color
    title.TextXAlignment = Enum.TextXAlignment.Center -- Center alignment
    title.ZIndex = 3
    title.Parent = overlay

    -- Subtitle creation
    local subtitle = Instance.new("TextLabel")
    subtitle.Size = UDim2.new(1, -20, 0, 20)
    subtitle.Position = UDim2.new(0.5, -overlayWidth / 2, 0, 30)
    subtitle.BackgroundTransparency = 1
    subtitle.Text = "@playhero_ on discord"
    subtitle.Font = Enum.Font.Gotham
    subtitle.TextSize = 16 -- Subtitle font size
    subtitle.TextColor3 = COLORS.TextPurple -- Static neon purple color
    subtitle.TextXAlignment = Enum.TextXAlignment.Center -- Align text in the center
    subtitle.ZIndex = 3
    subtitle.Parent = overlay

    -- Info label for FPS and Ping
    local info = Instance.new("TextLabel")
    info.Size = UDim2.new(1, -20, 0, 20)
    info.Position = UDim2.new(0.5, -overlayWidth / 2, 0, 50)
    info.BackgroundTransparency = 1
    info.Font = Enum.Font.GothamBold
    info.TextSize = 16 -- Info font size
    info.TextColor3 = COLORS.TextPurple -- Static neon purple color
    info.TextXAlignment = Enum.TextXAlignment.Center -- Align text in the center
    info.ZIndex = 3
    info.Parent = overlay

    -- FPS and Ping tracking
    local frames = 0
    local last = tick()
    RunService.RenderStepped:Connect(function()
        frames += 1
        local now = tick()
        if now - last >= 1 then
            local fps = frames
            frames = 0
            last = now
            local rawPing = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
            local ping = math.floor(rawPing + 0.5)
            info.Text = "FPS: " .. fps .. "    PING: " .. ping .. "ms"
        end
    end)

    -- Make the overlay draggable
    createDraggable(overlay)
end

-- Initialize GUI
createGui()
wait(1)

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "KP's Hub v1.0 | @playhero_ on discord",
    SubTitle = "",
    TabWidth = 120,
    Size = UDim2.fromOffset(480, 360),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional
local Tabs = {
    PVP = Window:AddTab({ Title = "Combat", Icon = "" }),
    Player = Window:AddTab({ Title = "Player", Icon = "" }),
    Config = Window:AddTab({ Title = "Servers", Icon = "" }),
    FPS = Window:AddTab({ Title = "Optimizer", Icon = "" }),
    Main = Window:AddTab({ Title = "Universal", Icon = "" }),
    Settings = Window:AddTab({ Title = "Settings/Config", Icon = "" })
}

local Options = Fluent.Options

do
    Fluent:Notify({
        Title = "KP's Hub",
        Content = "Loaded",
        SubContent = "", -- Optional
        Duration = 0 -- Set to nil to make the notification not disappear
    })
    Tabs.PVP:AddButton({
         Title = "Target Strafe",
         Description = "",
         Callback = function()
           loadstring(game:HttpGet("https://raw.githubusercontent.com/bomalalarblx/.gg-kindperson/refs/heads/main/saygex"))()
        end
    })
    
    local Toggle = Tabs.PVP:AddToggle("MyToggle", {Title = "Aimbot(Testing)", Default = false })

    Toggle:OnChanged(function()
        print("Toggle changed:", Options.MyToggle.Value)
    end)

    Options.MyToggle:SetValue(false)
    Tabs.PVP:AddButton({
        Title = "FOV(Testing)",
        Description = "",
        Callback = function()
local Circle = Instance.new("ImageLabel")
Circle.Parent = FOVCircle
Circle.AnchorPoint = Vector2.new(0.5, 0.5)
Circle.Position = UDim2.new(0.5, 0, 0.5, 0)
Circle.Size = UDim2.new(1, 0, 1, 0)
Circle.BackgroundTransparency = 1
Circle.Image = "rbxassetid://4910799599" -- simple circle image
Circle.ImageColor3 = Color3.fromRGB(40, 200, 200)
Circle.ImageTransparency = 0.5

function setFOVRadius(radius)
    FOV_RADIUS = radius
    FOVCircle.Size = UDim2.new(0, FOV_RADIUS*2, 0, FOV_RADIUS*2)
end
    end
    })

    Tabs.Player:AddButton({
        Title = "Desync V1 (Key)",
        Description = "",
        Callback = function()
          loadstring(game:HttpGet("https://rawscripts.net/raw/The-Strongest-Battlegrounds-The-Strongest-Battleground-BEST-and-OP-Desync-Script-77180"))()
        end
    })
    Tabs.Player:AddButton({
       Title = "Desync V2",
       Description = "this could be detect",
       Callback = function()
setfflag("LargeReplicatorEnabled9", "true")
setfflag("GameNetDontSendRedundantNumTimes", "1")
setfflag("MaxTimestepMultiplierAcceleration", "2147483647")
setfflag("InterpolationFrameVelocityThresholdMillionth", "5")
setfflag("CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth", "1")
setfflag("TimestepArbiterVelocityCriteriaThresholdTwoDt", "2147483646")
setfflag("GameNetPVHeaderLinearVelocityZeroCutoffExponent", "-5000")
setfflag("TimestepArbiterHumanoidTurningVelThreshold", "1")
setfflag("LargeReplicatorSerializeWrite4", "true")
setfflag("SimExplicitlyCappedTimestepMultiplier", "2147483646")
setfflag("InterpolationFrameRotVelocityThresholdMillionth", "5")
setfflag("ServerMaxBandwith", "52")
setfflag("LargeReplicatorSerializeRead3", "true")
setfflag("GameNetDontSendRedundantDeltaPositionMillionth", "1")
setfflag("PhysicsSenderMaxBandwidthBps", "20000")
setfflag("CheckPVCachedVelThresholdPercent", "10")
setfflag("NextGenReplicatorEnabledWrite4", "true")
setfflag("LargeReplicatorWrite5", "true")
setfflag("MaxMissedWorldStepsRemembered", "-2147483648")
setfflag("StreamJobNOUVolumeCap", "2147483647")
setfflag("CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent", "1")
setfflag("DisableDPIScale", "true")
setfflag("WorldStepMax", "30")
setfflag("InterpolationFramePositionThresholdMillionth", "5")
setfflag("MaxAcceptableUpdateDelay", "1")
setfflag("TimestepArbiterOmegaThou", "1073741823")
setfflag("CheckPVCachedRotVelThresholdPercent", "10")
setfflag("StreamJobNOUVolumeLengthCap", "2147483647")
setfflag("S2PhysicsSenderRate", "15000")
setfflag("MaxTimestepMultiplierBuoyancy", "2147483647")
setfflag("SimOwnedNOUCountThresholdMillionth", "2147483647")
setfflag("ReplicationFocusNouExtentsSizeCutoffForPauseStuds", "2147483647")
setfflag("LargeReplicatorRead5", "true")
setfflag("CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth", "1")
setfflag("MaxDataPacketPerSend", "2147483647")
setfflag("MaxTimestepMultiplierContstraint", "2147483647")
setfflag("DebugSendDistInSteps", "-2147483648")
setfflag("GameNetPVHeaderRotationalVelocityZeroCutoffExponent", "-5000")
setfflag("AngularVelociryLimit", "360")
    end
    })
    Tabs.Player:AddButton({
        Title = "ESP Player Name",
        Description = "",
        Callback = function()
         local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

function createESP(player)
    if player == localPlayer then return end

    local character = player.Character or player.CharacterAdded:Wait()
    local head = character:WaitForChild("Head")

    local billboardGui = Instance.new("BillboardGui")
    billboardGui.Name = "ESP"
    billboardGui.Adornee = head
    billboardGui.Size = UDim2.new(0, 100, 0, 40)
    billboardGui.StudsOffset = Vector3.new(0, 2, 0)
    billboardGui.AlwaysOnTop = true

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 1, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = Color3.new(1, 0, 0)
    nameLabel.TextStrokeTransparency = 0.5
    nameLabel.TextScaled = true
    nameLabel.Parent = billboardGui

    billboardGui.Parent = head
end

-- Add ESP to all current players
for _, player in ipairs(Players:GetPlayers()) do
    createESP(player)
end

-- Add ESP to new players
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        createESP(player)
    end)
end)
  end
    })
    Tabs.Player:AddButton({
        Title = "Chams",
        Description = "",
        Callback = function()
         -- LocalScript (place it in StarterPlayer > StarterPlayerScripts)
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

-- Function to apply Chams to a character
local function applyChams(player)
    if player == localPlayer then return end

    local function onCharacterAdded(character)
        for _, part in pairs(character:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                local chamsPart = Instance.new("BoxHandleAdornment")
                chamsPart.Name = "Chams"
                chamsPart.Adornee = part
                chamsPart.AlwaysOnTop = true
                chamsPart.ZIndex = 10
                chamsPart.Size = part.Size + Vector3.new(0.1, 0.1, 0.1)
                chamsPart.Transparency = 0.4
                chamsPart.Color3 = Color3.fromRGB(0, 255, 255) -- Cyan glow
                chamsPart.Parent = part
            end
        end
    end

    -- Apply to already loaded character
    if player.Character then
        onCharacterAdded(player.Character)
    end

    -- Apply to future characters
    player.CharacterAdded:Connect(onCharacterAdded)
end

-- Apply chams to all existing players
for _, player in ipairs(Players:GetPlayers()) do
    applyChams(player)
end

-- Apply chams to new players
Players.PlayerAdded:Connect(applyChams)
    end
    })
    local Slider = Tabs.Player:AddSlider("Slider", {
        Title = "Walkspeed",
        Description = "",
        Default = 16,
        Min = 0,
        Max = 360,
        Rounding = 1,
        Callback = function(Value)
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    })
    Tabs.Player:AddButton({
        Title = "Infinite Jump",
        Description = "not working on game has ac",
        Callback = function()
          local player = game.Players.LocalPlayer
local userInput = game:GetService("UserInputService")
local humanoid = nil

local function onJumpRequest()
    if humanoid then
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

local function onCharacterAdded(char)
    humanoid = char:WaitForChild("Humanoid")
end

if player.Character then
    onCharacterAdded(player.Character)
end
player.CharacterAdded:Connect(onCharacterAdded)

userInput.JumpRequest:Connect(onJumpRequest)
    end
    })
    Tabs.Player:AddButton({
        Title = "Kill Roblox",
        Description = "",
        Callback = function()
          loadstring(game:HttpGet("https://youtube.com"))()
        end
    })
    Tabs.Config:AddButton({
        Title = "Hop Server",
        Description = "",
        Callback = function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Morples/Server-hop/refs/heads/main/Script"))()
        end
    })
    Tabs.Config:AddButton({
        Title = "Rejoin",
        Description = "",
        Callback = function()
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

function rejoinServer()
    local placeId = game.PlaceId
    local jobId = game.JobId
    TeleportService:TeleportToPlaceInstance(placeId, jobId, player)
end

-- Example usage: call rejoinServer() via a button or event
rejoinServer()
        end
    })
    Tabs.Config:AddButton({
        Title = "Job-ID Joiner",
        Description = "",
        Callback = function()
         --[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
-- Create the GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 300, 0, 150)
frame.Position = UDim2.new(0.5, -150, 0.5, -75)
frame.BackgroundColor3 = Color3.fromRGB(50, 50, 50) -- Grey background
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

-- Add rounded corners to the frame
local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, 8) -- Adjust corner radius as needed
uiCorner.Parent = frame

local title = Instance.new("TextLabel")
title.Text = "Join Server by Job ID"
title.Size = UDim2.new(1, 0, 0, 30)
title.Position = UDim2.new(0, 0, 0, 0)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40) -- Darker grey
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.FredokaOne -- Set font to Fredoka One
title.Parent = frame

-- Add rounded corners to the title
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 8)
titleCorner.Parent = title

local textBox = Instance.new("TextBox")
textBox.PlaceholderText = "Enter Job ID"
textBox.Size = UDim2.new(0.8, 0, 0, 30)
textBox.Position = UDim2.new(0.1, 0, 0.4, 0)
textBox.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
textBox.TextColor3 = Color3.fromRGB(0, 0, 0)
textBox.Font = Enum.Font.FredokaOne -- Set font to Fredoka One
textBox.Parent = frame

-- Add rounded corners to the text box
local textBoxCorner = Instance.new("UICorner")
textBoxCorner.CornerRadius = UDim.new(0, 8)
textBoxCorner.Parent = textBox

local joinButton = Instance.new("TextButton")
joinButton.Text = "Join Server"
joinButton.Size = UDim2.new(0.8, 0, 0, 30)
joinButton.Position = UDim2.new(0.1, 0, 0.7, 0)
joinButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
joinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
joinButton.Font = Enum.Font.FredokaOne -- Set font to Fredoka One
joinButton.Parent = frame

-- Add rounded corners to the button
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = joinButton

-- Function to join the server by Job ID
joinButton.MouseButton1Click:Connect(function()
    local jobId = textBox.Text
    if jobId and jobId ~= "" then
        game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, jobId)
    else
        print("Please enter a valid Job ID.")
    end
end)
        end
    })
    Tabs.FPS:AddButton({
        Title = "Uncapped 240 FPS",
        Description = "going over 240fps is not good",
        Callback = function()
         setfpscap(9999)
        end
    })
    Tabs.FPS:AddButton({
        Title = "Optimizer V1",
        Description = "",
        Callback = function()
  _G.Ignore = {}
_G.Settings = {
    Players = {
        ["Ignore Me"] = true,
        ["Ignore Others"] = true,
        ["Ignore Tools"] = true
    },
    Meshes = {
        NoMesh = false,
        NoTexture = false,
        Destroy = false
    },
    Images = {
        Invisible = true,
        Destroy = false
    },
    Explosions = {
        Smaller = true,
        Invisible = false, -- Not for PVP games
        Destroy = false -- Not for PVP games
    },
    Particles = {
        Invisible = true,
        Destroy = false
    },
    TextLabels = {
        LowerQuality = true,
        Invisible = false,
        Destroy = false
    },
    MeshParts = {
        LowerQuality = true,
        Invisible = true,
        NoTexture = true,
        NoMesh = true,
        Destroy = true
    },
    Other = {
        ["FPS Cap"] = 240, -- true to uncap
        ["No Camera Effects"] = true,
        ["No Clothes"] = true,
        ["Low Water Graphics"] = true,
        ["No Shadows"] = true,
        ["Low Rendering"] = true,    
        ["Low Quality Parts"] = true,
        ["Low Quality Models"] = true,
        ["Reset Materials"] = true,
    }
}
loadstring(game:HttpGet("https://raw.githubusercontent.com/CasperFlyModz/discord.gg-rips/main/FPSBooster.lua"))()
    end
    })
    Tabs.FPS:AddButton({
        Title = "White Texture",
        Description = "",
        Callback = function()
    -- Script to set assets, materials, and model textures to white
-- Author: Black-Sky

-- Function to set player avatar and clothes to white
local function makeAvatarWhite(player)
    if player.Character then
        -- Remove all accessories
        for _, accessory in ipairs(player.Character:GetChildren()) do
            if accessory:IsA("Accessory") then
                accessory:Destroy()
            end
        end

        -- Remove clothing
        for _, clothing in ipairs(player.Character:GetChildren()) do
            if clothing:IsA("Shirt") or clothing:IsA("Pants") or clothing:IsA("ShirtGraphic") then
                clothing:Destroy()
            end
        end

        -- Set body parts to white
        for _, part in ipairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Color = Color3.new(1, 1, 1) -- Set to white
                part.Material = Enum.Material.SmoothPlastic -- Use a simple material
            end
        end
    end
end

-- Function to make all textures white
local function makeTexturesWhite()
    for _, descendant in ipairs(workspace:GetDescendants()) do
        -- Make Texture objects white
        if descendant:IsA("Texture") then
            descendant.Texture = "rbxassetid://0" -- Set to a solid white texture (clear the texture asset)
        elseif descendant:IsA("Decal") then
            descendant.Color3 = Color3.new(1, 1, 1) -- Set decaled surface to white

        -- Make Material assets white
        elseif descendant:IsA("MeshPart") then
            descendant.TextureID = "" -- Remove any texture asset from MeshPart
            descendant.Material = Enum.Material.SmoothPlastic -- Set a uniform material
            descendant.Color = Color3.new(1, 1, 1) -- Make the MeshPart white

        -- Set BaseParts to appear white
        elseif descendant:IsA("BasePart") then
            descendant.Material = Enum.Material.SmoothPlastic -- Simplify material
            descendant.Color = Color3.new(1, 1, 1) -- Set the part to white
        end
    end
end

-- Connect to PlayerAdded to apply these changes to new players
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Make the player's avatar white when they spawn
        makeAvatarWhite(player)
    end)
end)

-- Make all textures in the workspace white
makeTexturesWhite()

-- Modify already-spawned players' avatars
for _, player in ipairs(game.Players:GetPlayers()) do
    if player.Character then
        makeAvatarWhite(player)
    end
end
end
    })
    Tabs.FPS:AddButton({
        Title = "Black Texture(V1)",
        Description = "",
        Callback = function()
         -- Script to set assets, materials, and model textures to black
-- Author: Black-Sky

-- Function to set player avatar and clothes to black
local function makeAvatarBlack(player)
    if player.Character then
        -- Remove all accessories
        for _, accessory in ipairs(player.Character:GetChildren()) do
            if accessory:IsA("Accessory") then
                accessory:Destroy()
            end
        end

        -- Remove clothing
        for _, clothing in ipairs(player.Character:GetChildren()) do
            if clothing:IsA("Shirt") or clothing:IsA("Pants") or clothing:IsA("ShirtGraphic") then
                clothing:Destroy()
            end
        end

        -- Set body parts to black
        for _, part in ipairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Color = Color3.new(0, 0, 0) -- Set to black
                part.Material = Enum.Material.SmoothPlastic -- Use a simple material
            end
        end
    end
end

-- Function to make all textures black
local function makeTexturesBlack()
    for _, descendant in ipairs(workspace:GetDescendants()) do
        -- Make Texture objects black
        if descendant:IsA("Texture") then
            descendant.Texture = "rbxassetid://0" -- Set to a solid black texture
        elseif descendant:IsA("Decal") then
            descendant.Color3 = Color3.new(0, 0, 0) -- Set decaled surface to black

        -- Make Material assets black
        elseif descendant:IsA("MeshPart") then
            descendant.TextureID = "" -- Remove any texture asset from MeshPart
            descendant.Material = Enum.Material.SmoothPlastic -- Set a uniform material
            descendant.Color = Color3.new(0, 0, 0) -- Make the MeshPart black

        -- Set BaseParts to appear black
        elseif descendant:IsA("BasePart") then
            descendant.Material = Enum.Material.SmoothPlastic -- Simplify material
            descendant.Color = Color3.new(0, 0, 0) -- Set the part to black
        end
    end
end

-- Connect to PlayerAdded to apply these changes to new players
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Make the player's avatar black when they spawn
        makeAvatarBlack(player)
    end)
end)

-- Make all textures in the workspace black
makeTexturesBlack()

-- Modify already-spawned players' avatars
for _, player in ipairs(game.Players:GetPlayers()) do
    if player.Character then
        makeAvatarBlack(player)
    end
end
    end
    })
    Tabs.FPS:AddButton({
        Title = "Black Texture(V2)",
        Description = "",
        Callback = function()
      -- Script to set assets, materials, and model textures to a brighter white
-- Author: Black-Sky

-- Function to set player avatar and clothes to bright white
local function makeAvatarBrightWhite(player)
    if player.Character then
        -- Remove all accessories
        for _, accessory in ipairs(player.Character:GetChildren()) do
            if accessory:IsA("Accessory") then
                accessory:Destroy()
            end
        end

        -- Remove clothing
        for _, clothing in ipairs(player.Character:GetChildren()) do
            if clothing:IsA("Shirt") or clothing:IsA("Pants") or clothing:IsA("ShirtGraphic") then
                clothing:Destroy()
            end
        end

        -- Set body parts to bright white
        for _, part in ipairs(player.Character:GetChildren()) do
            if part:IsA("BasePart") or part:IsA("MeshPart") then
                part.Color = Color3.new(1, 1, 1) -- Pure white
                part.Material = Enum.Material.Neon -- Use Neon for extra brightness
            end
        end
    end
end

-- Function to make all textures bright white
local function makeTexturesBrightWhite()
    for _, descendant in ipairs(workspace:GetDescendants()) do
        -- Make Texture objects bright white
        if descendant:IsA("Texture") then
            descendant.Texture = "rbxassetid://0" -- Clear the texture asset (solid bright white effect)
        elseif descendant:IsA("Decal") then
            descendant.Color3 = Color3.new(1, 1, 1) -- Set decal to bright white

        -- Make Material assets bright white
        elseif descendant:IsA("MeshPart") then
            descendant.TextureID = "" -- Remove any texture asset from MeshPart
            descendant.Material = Enum.Material.Neon -- Use Neon for bright effect
            descendant.Color = Color3.new(1, 1, 1) -- Make the MeshPart bright white

        -- Set BaseParts to appear bright white
        elseif descendant:IsA("BasePart") then
            descendant.Material = Enum.Material.Neon -- Simplify material to Neon (maximum brightness)
            descendant.Color = Color3.new(1, 1, 1) -- Set the part to bright white
        end
    end
end

-- Connect to PlayerAdded to apply these changes to new players
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        -- Make the player's avatar bright white when they spawn
        makeAvatarBrightWhite(player)
    end)
end)

-- Make all textures in the workspace bright white
makeTexturesBrightWhite()

-- Modify already-spawned players' avatars
for _, player in ipairs(game.Players:GetPlayers()) do
    if player.Character then
        makeAvatarBrightWhite(player)
    end
end
     end
     })
     Tabs.Main:AddButton({
        Title = "Infinite Yield",
        Description = "",
        Callback = function()
           loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/refs/heads/master/source"))()
    end
     })
    Tabs.Main:AddButton({
       Title = "Nameless Admin",
       Description = "",
       Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/refs/heads/main/Source.lua"))()
       end
  })
  Tabs.Main:AddButton({
       Title = "Silent Aim",
       Description = "",
       Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/bomalalarblx/blox/refs/heads/main/silentaimuniversal"))()
       end
  })
  Tabs.Main:AddButton({
       Title = "Universe Viewer",
       Description = "",
       Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Universe%20Viewer"))();
       end
  })
  Tabs.Main:AddButton({
       Title = "Yeet Gui(Fling)",
       Description = "",
       Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/Flacherflache/FE-Yeet-Gui/refs/heads/main/Script"))()
    end
  })
  Tabs.Main:AddButton({
       Title = "Fly Gui V3",
       Description = "",
       Callback = function()
         loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
       end
  })
   
end
-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)


Window:SelectTab(1)

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()
