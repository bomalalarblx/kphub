-- Colors
local COLORS = {
    FrameBackgroundTransparency = 0.3,
    TextPurple = Color3.fromRGB(160, 90, 255),
}

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local uis = game:GetService("UserInputService")
local rs = game:GetService("RunService")

local gui = Instance.new("ScreenGui")
gui.Name = "MiniGui"
gui.Parent = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

-- Main frame (draggable)
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 350)
frame.Position = UDim2.new(0.5, -90, 0.5, -175)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BackgroundTransparency = COLORS.FrameBackgroundTransparency
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.Parent = gui

local uicorner = Instance.new("UICorner")
uicorner.CornerRadius = UDim.new(0, 14)
uicorner.Parent = frame

-- Drag logic
local dragging, dragStart, startPos
frame.Active = true
frame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
uis.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Toggle utility
local function createToggle(labelText, posY, default)
    local group = Instance.new("Frame")
    group.Size = UDim2.new(1, -20, 0, 38)
    group.Position = UDim2.new(0, 10, 0, posY)
    group.BackgroundTransparency = 1
    group.Parent = frame

    local lbl = Instance.new("TextLabel")
    lbl.Text = labelText
    lbl.Size = UDim2.new(0, 100, 0, 18)
    lbl.Position = UDim2.new(0, 0, 0, 8)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold
    lbl.TextColor3 = COLORS.TextPurple
    lbl.TextSize = 16
    lbl.Parent = group

    local toggleBase = Instance.new("Frame")
    toggleBase.Size = UDim2.new(0, 49, 0, 29)
    toggleBase.Position = UDim2.new(0, 108, 0, 4)
    toggleBase.BackgroundColor3 = Color3.fromRGB(56, 56, 56)
    toggleBase.BackgroundTransparency = 0.2
    toggleBase.Parent = group

    local baseCorner = Instance.new("UICorner")
    baseCorner.CornerRadius = UDim.new(1, 0)
    baseCorner.Parent = toggleBase

    local toggleBtn = Instance.new("Frame")
    toggleBtn.Size = UDim2.new(0, 25, 0, 25)
    toggleBtn.Position = UDim2.new(0, 2, 0, 2)
    toggleBtn.BackgroundColor3 = default and COLORS.TextPurple or Color3.fromRGB(60,60,60)
    toggleBtn.Parent = toggleBase

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = toggleBtn

    local toggled = default
    local function setTog(v)
        toggled = v
        if toggled then
            toggleBtn.BackgroundColor3 = COLORS.TextPurple
            toggleBtn.Position = UDim2.new(0, 20, 0, 2)
        else
            toggleBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
            toggleBtn.Position = UDim2.new(0, 2, 0, 2)
        end
    end

    toggleBase.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            setTog(not toggled)
        end
    end)

    setTog(default)
    return function()
        return toggled
    end, setTog
end

-- Title
local title = Instance.new("TextLabel")
title.Text = "Mini Menu"
title.Size = UDim2.new(0, 120, 0, 30)
title.Position = UDim2.new(0, 30, 0, 7)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextColor3 = COLORS.TextPurple
title.TextSize = 20
title.Parent = frame

-- Toggles (Silent Aim, Anti Lag below it)
local getAimbot, setAimbot       = createToggle("Aimbot", 38, false)
local getDesync, setDesync       = createToggle("Desync", 82, false)
local getSilentAim, setSilentAim = createToggle("Silent Aim", 126, false)
local getAntiLag, setAntiLag     = createToggle("Anti Lag", 170, false)

-- FOV Slider, circle & value display
local fovLabel = Instance.new("TextLabel")
fovLabel.Text = "FOV"
fovLabel.Size = UDim2.new(0, 40, 0, 18)
fovLabel.Position = UDim2.new(0, 10, 0, 214)
fovLabel.BackgroundTransparency = 1
fovLabel.Font = Enum.Font.GothamBold
fovLabel.TextColor3 = COLORS.TextPurple
fovLabel.TextSize = 16
fovLabel.Parent = frame

local fovSlider = Instance.new("Frame")
fovSlider.Size = UDim2.new(0, 115, 0, 18)
fovSlider.Position = UDim2.new(0, 55, 0, 216)
fovSlider.BackgroundColor3 = Color3.fromRGB(56,56,56)
fovSlider.BackgroundTransparency = 0.2
fovSlider.Parent = frame

local fovCorner = Instance.new("UICorner")
fovCorner.CornerRadius = UDim.new(1,0)
fovCorner.Parent = fovSlider

local sliderBtn = Instance.new("Frame")
sliderBtn.Size = UDim2.new(0, 13, 0, 22)
sliderBtn.Position = UDim2.new(0, 0, 0, -2)
sliderBtn.BackgroundColor3 = COLORS.TextPurple
sliderBtn.Parent = fovSlider

local sliderBtnCorner = Instance.new("UICorner")
sliderBtnCorner.CornerRadius = UDim.new(1, 0)
sliderBtnCorner.Parent = sliderBtn

-- Slider drag logic
local sliderDragging = false
local moveSlider = function(px)
    local sliderWidth = fovSlider.AbsoluteSize.X
    px = math.clamp(px, 0, sliderWidth)
    sliderBtn.Position = UDim2.new(0, px-7, 0, -2)
end

local function updateSliderFromInput(input)
    local mouseX = input.Position.X
    local sliderPosX = fovSlider.AbsolutePosition.X
    local sliderWidth = fovSlider.AbsoluteSize.X
    local relX = math.clamp(mouseX - sliderPosX, 0, sliderWidth)
    moveSlider(relX)
end

fovSlider.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        updateSliderFromInput(input)
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                sliderDragging = false
            end
        end)
    end
end)
sliderBtn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        sliderDragging = true
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                sliderDragging = false
            end
        end)
    end
end)
uis.InputChanged:Connect(function(input)
    if sliderDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        updateSliderFromInput(input)
    end
end)

-- FOV value & display
local function getFOV()
    local sliderWidth = fovSlider.AbsoluteSize.X
    local sliderPos = sliderBtn.Position.X.Offset + 7
    local val = math.clamp(sliderPos / sliderWidth, 0, 1)
    return math.floor(40 + (210 * val)) -- 40 to 250
end

local fovNumLabel = Instance.new("TextLabel")
fovNumLabel.Size = UDim2.new(0, 40, 0, 18)
fovNumLabel.Position = UDim2.new(0, 110, 0, 240)
fovNumLabel.BackgroundTransparency = 1
fovNumLabel.Font = Enum.Font.GothamBold
fovNumLabel.TextColor3 = COLORS.TextPurple
fovNumLabel.TextSize = 16
fovNumLabel.Text = tostring(getFOV())
fovNumLabel.Parent = frame

rs.RenderStepped:Connect(function()
    fovNumLabel.Text = tostring(getFOV())
end)

-- FOV circle display (image version)
local circle = Instance.new("ImageLabel")
circle.Name = "FOVCircle"
circle.Size = UDim2.new(0, 120, 0, 120)
circle.Position = UDim2.new(0.5, -60, 0.5, -60)
circle.BackgroundTransparency = 1
circle.Image = "rbxassetid://6684999095"
circle.ImageColor3 = COLORS.TextPurple
circle.Parent = gui

rs.RenderStepped:Connect(function()
    local size = getFOV()
    circle.Size = UDim2.new(0, size, 0, size)
    circle.Position = UDim2.new(0.5, -size/2, 0.5, -size/2)
    circle.ImageTransparency = 0.3
    circle.Visible = true
end)

-- Desync flags table
local desyncFlags = {
    {"LargeReplicatorEnabled9", "true"},
    {"GameNetDontSendRedundantNumTimes", "1"},
    {"MaxTimestepMultiplierAcceleration", "2147483647"},
    {"InterpolationFrameVelocityThresholdMillionth", "5"},
    {"CheckPVDifferencesForInterpolationMinRotVelThresholdRadsPerSecHundredth", "1"},
    {"TimestepArbiterVelocityCriteriaThresholdTwoDt", "2147483646"},
    {"GameNetPVHeaderLinearVelocityZeroCutoffExponent", "-5000"},
    {"TimestepArbiterHumanoidTurningVelThreshold", "1"},
    {"LargeReplicatorSerializeWrite4", "true"},
    {"SimExplicitlyCappedTimestepMultiplier", "2147483646"},
    {"InterpolationFrameRotVelocityThresholdMillionth", "5"},
    {"ServerMaxBandwith", "52"},
    {"LargeReplicatorSerializeRead3", "true"},
    {"GameNetDontSendRedundantDeltaPositionMillionth", "1"},
    {"PhysicsSenderMaxBandwidthBps", "20000"},
    {"CheckPVCachedVelThresholdPercent", "10"},
    {"NextGenReplicatorEnabledWrite4", "true"},
    {"LargeReplicatorWrite5", "true"},
    {"MaxMissedWorldStepsRemembered", "-2147483648"},
    {"StreamJobNOUVolumeCap", "2147483647"},
    {"CheckPVLinearVelocityIntegrateVsDeltaPositionThresholdPercent", "1"},
    {"DisableDPIScale", "true"},
    {"WorldStepMax", "30"},
    {"InterpolationFramePositionThresholdMillionth", "5"},
    {"MaxAcceptableUpdateDelay", "1"},
    {"TimestepArbiterOmegaThou", "1073741823"},
    {"CheckPVCachedRotVelThresholdPercent", "10"},
    {"StreamJobNOUVolumeLengthCap", "2147483647"},
    {"S2PhysicsSenderRate", "15000"},
    {"MaxTimestepMultiplierBuoyancy", "2147483647"},
    {"SimOwnedNOUCountThresholdMillionth", "2147483647"},
    {"ReplicationFocusNouExtentsSizeCutoffForPauseStuds", "2147483647"},
    {"LargeReplicatorRead5", "true"},
    {"CheckPVDifferencesForInterpolationMinVelThresholdStudsPerSecHundredth", "1"},
    {"MaxDataPacketPerSend", "2147483647"},
    {"MaxTimestepMultiplierContstraint", "2147483647"},
    {"DebugSendDistInSteps", "-2147483648"},
    {"GameNetPVHeaderRotationalVelocityZeroCutoffExponent", "-5000"},
    {"AngularVelociryLimit", "360"}
}

local function applyDesyncFlags()
    for _, entry in ipairs(desyncFlags) do
        pcall(function()
            setfflag(entry[1], entry[2])
        end)
    end
end

-- Improved Anti Lag: your requested implementation
local terrain = workspace:FindFirstChildWhichIsA("Terrain")
local antiLagConnection
local function runAntiLag()
    -- Terrain optimization
    if terrain then
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0
        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 1
    end
    -- Lighting
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 9e9
    -- Rendering quality (if possible)
    pcall(function() settings().Rendering.QualityLevel = 1 end)
    -- Set FPS cap
    pcall(function() if setfpscap then setfpscap(9999) end end)
    -- World parts optimization
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CastShadow = false
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
            v.BackSurface = Enum.SurfaceType.SmoothNoOutlines
            v.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
            v.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
            v.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
            v.RightSurface = Enum.SurfaceType.SmoothNoOutlines
            v.TopSurface = Enum.SurfaceType.SmoothNoOutlines
        elseif v:IsA("Decal") then
            v.Transparency = 1
            v.Texture = ""
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v.Lifetime = NumberRange.new(0)
        end
    end
    -- PostEffect (Lighting filters/shaders)
    for _, v in pairs(Lighting:GetDescendants()) do
        if v:IsA("PostEffect") then
            v.Enabled = false
        end
    end
    -- Remove stuff as added!
    if not antiLagConnection then
        antiLagConnection = workspace.DescendantAdded:Connect(function(child)
            task.spawn(function()
                if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                    RunService.Heartbeat:Wait()
                    child:Destroy()
                elseif child:IsA("BasePart") then
                    child.CastShadow = false
                end
            end)
        end)
    end
end

-- Silent Aim target function
local function getSilentAimTarget()
    local cam = workspace.CurrentCamera
    local mousePos = uis:GetMouseLocation()
    local minDistance = getFOV()
    local closest, closestDist = nil, minDistance

    for _, other in ipairs(game.Players:GetPlayers()) do
        if other ~= player and other.Character and other.Character:FindFirstChild("Head")
            and other.Character:FindFirstChild("Humanoid")
            and other.Character.Humanoid.Health > 0 then
            local head = other.Character.Head
            local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

-- Aimbot (manual camera)
local function getClosestTarget()
    local minDistance = getFOV()
    local cam = workspace.CurrentCamera
    local mousePos = uis:GetMouseLocation()
    local closest, closestDist = nil, minDistance

    for _, other in ipairs(game.Players:GetPlayers()) do
        if other ~= player and other.Character and other.Character:FindFirstChild("Head") then
            local head = other.Character.Head
            local screenPos, onScreen = cam:WorldToViewportPoint(head.Position)
            if onScreen then
                local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                if dist < closestDist then
                    closestDist = dist
                    closest = head
                end
            end
        end
    end
    return closest
end

-- Main update loop
rs.RenderStepped:Connect(function()
    if getAimbot() then
        local target = getClosestTarget()
        if target then
            workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, target.Position)
        end
    end
    if getDesync() then
        applyDesyncFlags()
    end
    if getAntiLag() then
        runAntiLag()
    end
end)

-- Expose silent aim for other scripts to use:
_G.GetSilentAimTarget = function()
    return getSilentAim() and getSilentAimTarget() or nil
end

-- Usage Example (in your gun script):
-- local target = _G.GetSilentAimTarget()
-- if target then aimPos = target.Position end
