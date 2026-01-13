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
    title.Text = "KP's Hub v1.5"
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
local function safeLoad(url)
    local ok, res = pcall(function()
        return loadstring(game:HttpGet(url))()
    end)
    if ok then return res end
    return nil
end

local Fluent = safeLoad("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua")
if not Fluent then
    -- Minimal Fluent shim so the script doesn't error if the real module couldn't be fetched.
    Fluent = {}

    function Fluent:Notify(_) end

    function Fluent:CreateWindow(_)
        -- Minimal stub window implementing methods used by the script.
        local stubWindow = {}

        function stubWindow:AddTab(_)
            local tab = {}
            function tab:AddToggle(_, _) return { OnChanged = function() end, SetValue = function() end } end
            function tab:AddInput(_, _) return { Value = "", OnChanged = function() end } end
            function tab:AddButton(_) end
            function tab:AddDropdown(_, _) return { OnChanged = function() end, GetValues = function() return {} end, SetValues = function() end, SetValue = function() end } end
            function tab:AddSlider(_, _) return { SetValue = function() end } end
            return tab
        end

        function stubWindow:SelectTab() end
        return stubWindow
    end

    -- Provide Unloaded event shim with Connect method
    Fluent.Unloaded = { Connect = function() end }

    function Fluent:Unload() end
end

local SaveManager = safeLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua")
if not SaveManager then
    SaveManager = {}
    function SaveManager:SetLibrary(_) end
    function SaveManager:IgnoreThemeSettings() end
    function SaveManager:SetIgnoreIndexes(_) end
    function SaveManager:SetFolder(_) end
    function SaveManager:BuildConfigSection(_) end
end

local InterfaceManager = safeLoad("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua")
if not InterfaceManager then
    InterfaceManager = {}
    function InterfaceManager:SetLibrary(_) end
    function InterfaceManager:SetFolder(_) end
    function InterfaceManager:BuildInterfaceSection(_) end
end

-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- small helper
local function safeCall(fn, ...)
    local ok, err = pcall(fn, ...)
    return ok, err
end

-- helper to safely call SetValue / Set on controls
local function safeSetControlValue(control, value)
    if not control then return end
    -- prefer method calls
    if type(control.SetValue) == "function" then
        pcall(control.SetValue, control, value)
        return
    end
    if type(control.Set) == "function" then
        pcall(control.Set, control, value)
        return
    end
    -- property assignment if present
    if rawget(control, "Value") ~= nil then
        pcall(function() control.Value = value end)
        return
    end
    -- fallback: try to set key directly
    pcall(function() control.Value = value end)
end

-- helper to safely register OnChanged-like callbacks (avoids calling nil)
local function safeOnChanged(control, cb)
    if not control or type(cb) ~= "function" then return end
    -- common: colon-call OnChanged
    if type(control.OnChanged) == "function" then
        pcall(function() control:OnChanged(cb) end)
        return
    end
    -- alternative name
    if type(control.OnChange) == "function" then
        pcall(function() control:OnChange(cb) end)
        return
    end
    -- some UIs expose SetCallback or Callback properties
    if type(control.SetCallback) == "function" then
        pcall(function() control:SetCallback(cb) end)
        return
    end
    if control.Callback == nil then
        pcall(function() control.Callback = cb end)
        return
    end
    -- try Connect if it's an event-like
    if control and type(control.Connect) == "function" then
        pcall(function() control:Connect(cb) end)
        return
    end
end

-- Window (Fluent)
local Window = Fluent:CreateWindow({
    Title = "KP's Hub v1.5 | @playhero_ on discord",
    SubTitle = "",
    TabWidth = 120,
    Size = UDim2.fromOffset(480, 360),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl
})

local Tabs = {
    PVP = Window:AddTab({ Title = "Combat" }),
    Player = Window:AddTab({ Title = "Player" }),
    Config = Window:AddTab({ Title = "Servers" }),
    FPS = Window:AddTab({ Title = "Optimizer" }),
    Main = Window:AddTab({ Title = "Universal" }),
    Settings = Window:AddTab({ Title = "Settings/Config" })
}

-- Shared state
local state = {
    Aimbot = false,
    SilentAim = false,
    TriggerBot = false,
    FOV = 150,
    CrosshairId = "",
    StrafeTarget = nil,
    StrafeActive = false,
    Walkspeed = 16,
    Jumppower = 50,
    Gravity = workspace.Gravity,
    Fly = false,
    ESP = false,
    Chams = false,
    Tracer = false,
    SelectedPlayer = nil,
    Tweening = false,
    DisableAnims = false,
    AntiAFK = false,
    FPSBoost = false
}

local function notify(title, content, duration)
    if type(Fluent.Notify) == "function" then
        Fluent:Notify({ Title = title, Content = tostring(content), Duration = duration or 4 })
    end
end

-- Utilities
local function isAlive(plr)
    if not plr then return false end
    local char = plr.Character
    if not char then return false end
    local hum = char:FindFirstChildOfClass("Humanoid")
    return hum and hum.Health > 0
end

local function headOf(plr)
    if not plr or not plr.Character then return nil end
    return plr.Character:FindFirstChild("Head")
end

local function playerNameList()
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(t, p.Name) end
    end
    return t
end

-- Dropdown compatibility helper
local function createDropdown(tab, id, params)
    local tryFns = {
        function() if type(tab.AddDropdown) == "function" then return tab:AddDropdown(id, params) end end,
        function() if type(tab.AddSelector) == "function" then return tab:AddSelector(id, params) end end,
        function() if type(tab.AddList) == "function" then return tab:AddList(id, params) end end,
        function() if type(tab.AddCombo) == "function" then return tab:AddCombo(id, params) end end,
        function() if type(tab.AddOption) == "function" then return tab:AddOption(id, params) end end,
    }

    for _, fn in ipairs(tryFns) do
        local ok, res = pcall(fn)
        if ok and res ~= nil then
            -- adapt API names
            if type(res.OnChanged) ~= "function" and type(res.OnChange) == "function" then res.OnChanged = res.OnChange end
            if type(res.GetValues) ~= "function" and type(res.GetOptions) == "function" then res.GetValues = function() return res:GetOptions() end end
            if type(res.SetValues) ~= "function" then
                if type(res.SetOptions) == "function" then res.SetValues = function(_, v) return res:SetOptions(v) end
                elseif type(res.Update) == "function" then res.SetValues = function(_, v) return res:Update(v) end end
            end
            if type(res.SetValue) ~= "function" and type(res.Set) == "function" then res.SetValue = function(_, v) return res:Set(v) end end
            return res
        end
    end

    -- fallback stub to avoid runtime errors
    local stub = {}
    stub._values = params and params.Values or {}
    function stub:OnChanged(_) end
    function stub:GetValues() return stub._values end
    function stub:SetValues(vals) stub._values = vals end
    function stub:SetValue(v) stub.Value = v end
    function stub:GetValue() return stub.Value end
    return stub
end

local function getDropdownCurrentValue(dropdown)
    if not dropdown then return nil end
    local ok, val
    if type(dropdown.GetValue) == "function" then ok, val = pcall(dropdown.GetValue, dropdown); if ok and val then return val end end
    if dropdown.Value ~= nil then return dropdown.Value end
    if type(dropdown.GetValues) == "function" then ok, val = pcall(dropdown.GetValues, dropdown); if ok and type(val) == "table" and #val > 0 then return val[1] end end
    if type(dropdown.GetOptions) == "function" then ok, val = pcall(dropdown.GetOptions, dropdown); if ok and type(val) == "table" and #val > 0 then return val[1] end end
    return nil
end

-- Silent Aim helper
local function findSilentTarget(maxFOV)
    local cam = workspace.CurrentCamera
    local mousePos = UserInputService:GetMouseLocation()
    local bestHead = nil
    local bestDist = maxFOV or state.FOV
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and isAlive(plr) then
            local head = headOf(plr)
            if head then
                local sp, on = cam:WorldToViewportPoint(head.Position)
                if on then
                    local dist = (Vector2.new(sp.X, sp.Y) - mousePos).Magnitude
                    if dist < bestDist then bestDist = dist; bestHead = head end
                end
            end
        end
    end
    return bestHead
end

_G.KPHub_GetSilentAimTarget = function()
    if not state.SilentAim then return nil end
    return findSilentTarget(state.FOV)
end

-- Aimbot (camera lerp)
local aimbotConnection
local function startAimbot()
    if aimbotConnection then return end
    aimbotConnection = RunService.Heartbeat:Connect(function(dt)
        if not state.Aimbot then return end
        local target = findSilentTarget(state.FOV)
        if target and Camera then
            local goal = CFrame.new(Camera.CFrame.Position, target.Position)
            local smooth = 0.6
            Camera.CFrame = Camera.CFrame:Lerp(goal, math.clamp(smooth * dt * 60, 0, 1))
        end
    end)
end
local function stopAimbot() if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end end

-- TriggerBot
local lastTrigger = 0
local triggerConnection
local function getEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, v in ipairs(char:GetChildren()) do
        if v:IsA("Tool") then
            return v
        end
    end
    return nil
end

local function triggerTick()
    local now = tick()
    if now - lastTrigger < 0.1 then
        return
    end

    local cam = workspace.CurrentCamera
    local ray = cam:ScreenPointToRay(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    params.FilterType = Enum.RaycastFilterType.Blacklist

    local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
    if not res or not res.Instance then return end

    local model = res.Instance:FindFirstAncestorOfClass("Model")
    local hum = model and model:FindFirstChildOfClass("Humanoid")
    local targetPlayer = hum and Players:GetPlayerFromCharacter(model)
    if targetPlayer and targetPlayer ~= LocalPlayer then
        local tool = getEquippedTool()
        if tool then
            pcall(function() tool:Activate() end)
            lastTrigger = now
        end
    end
end

local function startTriggerBot()
    if triggerConnection then return end
    triggerConnection = RunService.RenderStepped:Connect(function()
        if state.TriggerBot then
            triggerTick()
        end
    end)
end
local function stopTriggerBot() if triggerConnection then triggerConnection:Disconnect(); triggerConnection = nil end end

-- Crosshair GUI
local CrossGui = Instance.new("ScreenGui")
CrossGui.Name = "KPHub_Crosshair"
CrossGui.ResetOnSpawn = false
CrossGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local CrossImg = Instance.new("ImageLabel")
CrossImg.Size = UDim2.fromOffset(32, 32)
CrossImg.AnchorPoint = Vector2.new(0.5, 0.5)
CrossImg.Position = UDim2.new(0.5, 0, 0.5, 0)
CrossImg.BackgroundTransparency = 1
CrossImg.Parent = CrossGui
CrossImg.Visible = false

local function setCrosshair(id)
    if not id or id == "" then
        CrossImg.Visible = false
        state.CrosshairId = ""
        return
    end
    state.CrosshairId = tostring(id)
    CrossImg.Image = ("rbxassetid://%s"):format(state.CrosshairId)
    CrossImg.Visible = true
end

-- Strafe (movement around target)
local strafeThread
local function startStrafe(radius, speed)
    if state.StrafeActive then return end
    if not state.StrafeTarget then return end

    state.StrafeActive = true
    local targetName = state.StrafeTarget
    strafeThread = task.spawn(function()
        local t0 = tick()
        while state.StrafeActive do
            local tp = Players:FindFirstChild(targetName)
            if not tp or not isAlive(tp) or not LocalPlayer.Character then
                state.StrafeActive = false
                break
            end

            local targetHRP = tp.Character and tp.Character:FindFirstChild("HumanoidRootPart")
            local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not (targetHRP and myHRP) then
                state.StrafeActive = false
                break
            end

            local elapsed = tick() - t0
            local angle = elapsed * speed
            local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
            local goalPos = targetHRP.Position + offset

            pcall(function()
                myHRP.CFrame = myHRP.CFrame:Lerp(CFrame.new(goalPos.X, goalPos.Y + 1.5, goalPos.Z), 0.35)
            end)

            task.wait(0.03)
        end

        state.StrafeActive = false
    end)
end
local function stopStrafe() state.StrafeActive = false end

-- Fly (BodyVelocity)
local flyState = { enabled = false, body = nil }
local flyConn
local function startFly()
    if flyState.enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end

    flyState.enabled = true
    hum.PlatformStand = true

    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.P = 1250
    bv.Parent = hrp
    flyState.body = bv

    flyConn = RunService.RenderStepped:Connect(function()
        if not flyState.enabled then return end
        local camC = Camera.CFrame
        local move = Vector3.new()

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + camC.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - camC.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - camC.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + camC.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0, 1, 0) end

        if move.Magnitude > 0 then
            move = move.Unit * 50
        end

        pcall(function()
            if flyState.body then flyState.body.Velocity = move end
        end)
    end)
end
local function stopFly()
    flyState.enabled = false
    if flyConn then flyConn:Disconnect(); flyConn = nil end
    if flyState.body then pcall(function() flyState.body:Destroy() end); flyState.body = nil end
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.PlatformStand = false end) end
end

-- ESP / Chams / Tracer management (independent)
local billboardItems = {}
local chamItems = {}
local tracerItems = {}

local function createBillboard(plr)
    if billboardItems[plr] then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "KPHubESP"
    billboard.AlwaysOnTop = true
    billboard.Size = UDim2.new(0, 120, 0, 40)
    billboard.ExtentsOffset = Vector3.new(0, 2, 0)
    billboard.Parent = CrossGui

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Font = Enum.Font.GothamBold
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextScaled = true
    label.Text = plr.Name
    label.Parent = billboard

    billboardItems[plr] = { billboard = billboard, label = label }
end

local function removeBillboard(plr)
    local it = billboardItems[plr]
    if not it then return end
    pcall(function() if it.billboard then it.billboard:Destroy() end end)
    billboardItems[plr] = nil
end

local function createCham(plr)
    if chamItems[plr] then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "KPHubCham"
    highlight.Enabled = false
    highlight.FillColor = Color3.fromRGB(160, 90, 255)
    highlight.OutlineColor = Color3.new(0, 0, 0)
    highlight.Parent = workspace
    chamItems[plr] = { highlight = highlight }
end

local function removeCham(plr)
    local it = chamItems[plr]
    if not it then return end
    pcall(function() if it.highlight then it.highlight:Destroy() end end)
    chamItems[plr] = nil
end

local function createTracer(plr)
    if tracerItems[plr] then return end
    local line = nil
    if Drawing and Drawing.new then
        line = Drawing.new("Line")
        line.Visible = false
        line.Color = Color3.fromRGB(160, 90, 255)
        line.Thickness = 1.5
        line.Transparency = 0.6
    end
    tracerItems[plr] = { tracer = line }
end

local function removeTracer(plr)
    local it = tracerItems[plr]
    if not it then return end
    pcall(function() if it.tracer and Drawing then it.tracer:Remove() end end)
    tracerItems[plr] = nil
end

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        createBillboard(p)
        createCham(p)
        createTracer(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p ~= LocalPlayer then
        createBillboard(p)
        createCham(p)
        createTracer(p)
    end
end)

Players.PlayerRemoving:Connect(function(p)
    removeBillboard(p)
    removeCham(p)
    removeTracer(p)
end)

local espRenderConn
local function startESPLoop()
    if espRenderConn then return end
    espRenderConn = RunService.RenderStepped:Connect(function()
        for plr, it in pairs(billboardItems) do
            local head = headOf(plr)
            pcall(function()
                if it.billboard then
                    it.billboard.Adornee = head
                    it.billboard.Enabled = state.ESP
                    it.label.Text = plr.Name
                end
            end)
        end

        for plr, it in pairs(chamItems) do
            pcall(function()
                if it.highlight then
                    if plr.Character and state.Chams then
                        it.highlight.Enabled = true
                        it.highlight.Adornee = plr.Character
                    else
                        it.highlight.Enabled = false
                        it.highlight.Adornee = nil
                    end
                end
            end)
        end

        for plr, it in pairs(tracerItems) do
            local head = headOf(plr)
            if it.tracer then
                if state.Tracer and head and Camera then
                    local sp, on = Camera:WorldToViewportPoint(head.Position)
                    if on then
                        it.tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                        it.tracer.To = Vector2.new(sp.X, sp.Y)
                        it.tracer.Visible = true
                    else
                        it.tracer.Visible = false
                    end
                else
                    it.tracer.Visible = false
                end
            end
        end
    end)
end

local function stopESPLoop()
    if espRenderConn then
        espRenderConn:Disconnect()
        espRenderConn = nil
    end
end

-- Disable animations (aggressive)
local animConns = {}

local function stopHumanoidTracks(hum)
    if not hum then return end
    pcall(function()
        for _, track in ipairs(hum:GetPlayingAnimationTracks()) do
            pcall(function() track:Stop() end)
        end
    end)
end

local function attachAnimHandlers(plr, hum)
    if animConns[plr] then return end
    local char = plr.Character
    if not char then return end

    local function disableAnimator(a)
        pcall(function() a.Disabled = true end)
    end

    local animator = hum:FindFirstChildOfClass("Animator")
    if animator then disableAnimator(animator) end

    stopHumanoidTracks(hum)

    local runningConn = hum.Running:Connect(function(speed)
        stopHumanoidTracks(hum)
    end)

    local stateConn = hum.StateChanged:Connect(function(_, newState)
        -- stop on any state change to be aggressive
        stopHumanoidTracks(hum)
    end)

    local descConn = char.DescendantAdded:Connect(function(desc)
        if desc:IsA("Animator") then disableAnimator(desc) end
        if desc:IsA("Animation") then
            pcall(function() if desc.AnimationId then desc.AnimationId = "" end end)
        end
    end)

    animConns[plr] = { runningConn, stateConn, descConn }
end

local function detachAnimHandlers(plr)
    local conns = animConns[plr]
    if not conns then return end
    for _, c in ipairs(conns) do pcall(function() c:Disconnect() end) end
    animConns[plr] = nil

    local char = plr.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            local animator = hum:FindFirstChildOfClass("Animator")
            if animator then pcall(function() animator.Disabled = false end) end
        end
    end
end

local function setDisableAnimations(toggle)
    state.DisableAnims = toggle
    for _, plr in ipairs(Players:GetPlayers()) do
        local char = plr.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if toggle then attachAnimHandlers(plr, hum) else detachAnimHandlers(plr) end
            end
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and state.DisableAnims then attachAnimHandlers(p, hum) end
    end)
end)

-- Anti AFK
local antiAfkConn = nil
local function setAntiAFK(toggle)
    state.AntiAFK = toggle
    if toggle then
        if not antiAfkConn then
            antiAfkConn = LocalPlayer.Idled:Connect(function()
                local vu = game:GetService("VirtualUser")
                vu:Button2Down(Vector2.new(0,0))
                task.wait(1)
                vu:Button2Up(Vector2.new(0,0))
            end)
        end
    else
        if antiAfkConn then antiAfkConn:Disconnect(); antiAfkConn = nil end
    end
end

-- Tween
local function tweenTo(targetName)
    if not targetName then return end
    local target = Players:FindFirstChild(targetName)
    if not target or not target.Character then return end
    local targetHRP = target.Character:FindFirstChild("HumanoidRootPart")
    local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not (targetHRP and myHRP) then return end
    state.Tweening = true
    local dest = targetHRP.CFrame * CFrame.new(0,0,-5)
    local ok, tweener = pcall(function()
        return TweenService:Create(myHRP, TweenInfo.new(1.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = dest })
    end)
    if ok and tweener then tweener:Play(); tweener.Completed:Wait() end
    state.Tweening = false
end

-- Servers helper functions
local function joinJobById(jobId)
    if not jobId or jobId == "" then return end
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, LocalPlayer) end)
end

local function rejoin()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer) end)
end

local function serverHop_local()
    if not pcall(function() return HttpService.GetAsync end) then return end
    task.spawn(function()
        local cursor = nil
        local found = nil
        for page = 1, 6 do
            local url
            if cursor then
                url = ("https://games.roblox.com/v1/games/%s/servers/Public?cursor=%s&limit=100"):format(tostring(game.PlaceId), tostring(cursor))
            else
                url = ("https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100"):format(tostring(game.PlaceId))
            end
            local ok, body = pcall(HttpService.GetAsync, HttpService, url)
            if not ok or not body then break end
            local ok2, res = pcall(HttpService.JSONDecode, HttpService, body)
            if not ok2 or not res or not res.data then break end
            for _, server in ipairs(res.data) do
                if server.id ~= game.JobId and (server.playing or 0) < (server.maxPlayers or 16) then
                    found = server.id
                    break
                end
            end
            if found then break end
            cursor = res.nextPageCursor
            if not cursor then break end
        end
        if found then pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, found, LocalPlayer) end) end
    end)
end

-- Optimizer / Anti-lag
local fpsLoop = nil
local function setFPSCap(num)
    if type(num) ~= "number" then return end
    if fpsLoop then pcall(function() task.cancel(fpsLoop) end); fpsLoop = nil end
    if setfpscap and type(setfpscap) == "function" then pcall(function() setfpscap(num) end); return end
    fpsLoop = task.spawn(function()
        local last = os.clock()
        while true do
            local now = os.clock()
            local interval = 1 / num
            if now - last < interval then
                task.wait(interval - (now - last))
                last = last + interval
            else
                last = now
            end
            task.wait()
        end
    end)
end

local antiTag = "_KPHub_AntiLagConn"
local function runAntiLag()
    local terrain = workspace:FindFirstChildWhichIsA("Terrain")
    if terrain then
        pcall(function()
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
        end)
    end

    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
        Lighting.FogStart = 9e9
        pcall(function() settings().Rendering.QualityLevel = 1 end)
    end)

    setFPSCap(9999)

    for _, v in ipairs(game:GetDescendants()) do
        if v:IsA("BasePart") then
            pcall(function()
                v.CastShadow = false
                v.Material = Enum.Material.Plastic
                v.Reflectance = 0
                v.BackSurface = Enum.SurfaceType.SmoothNoOutlines
                v.BottomSurface = Enum.SurfaceType.SmoothNoOutlines
                v.FrontSurface = Enum.SurfaceType.SmoothNoOutlines
                v.LeftSurface = Enum.SurfaceType.SmoothNoOutlines
                v.RightSurface = Enum.SurfaceType.SmoothNoOutlines
                v.TopSurface = Enum.SurfaceType.SmoothNoOutlines
            end)
        elseif v:IsA("Decal") then
            pcall(function() v.Transparency = 1; v.Texture = "" end)
        elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
            pcall(function() v.Lifetime = NumberRange.new(0) end)
        end
    end

    for _, effect in ipairs(Lighting:GetDescendants()) do
        if effect:IsA("PostEffect") then
            pcall(function() effect.Enabled = false end)
        end
    end

    if not workspace:FindFirstChild(antiTag) then
        local tag = Instance.new("BoolValue")
        tag.Name = antiTag
        tag.Parent = workspace

        workspace.DescendantAdded:Connect(function(child)
            task.spawn(function()
                task.wait()
                if child:IsA("ForceField") or child:IsA("Sparkles") or child:IsA("Smoke") or child:IsA("Fire") or child:IsA("Beam") then
                    pcall(function() child:Destroy() end)
                elseif child:IsA("BasePart") then
                    pcall(function() child.CastShadow = false end)
                elseif child:IsA("Decal") then
                    pcall(function() child.Transparency = 1; child.Texture = "" end)
                end
            end)
        end)
    end
end

-- UI Wiring (use safeOnChanged for all callbacks to avoid nil-call)
local StrafeDropdown = createDropdown(Tabs.PVP, "Strafe", { Title = "Strafe", Values = playerNameList(), Multi = false, Default = nil })
safeOnChanged(StrafeDropdown, function(val) state.StrafeTarget = val end)

local StrafeToggle = Tabs.PVP:AddToggle("StrafeEm", { Title = "Strafe em", Default = false })
safeOnChanged(StrafeToggle, function(val)
    if val then
        if not state.StrafeTarget then
            local cur = getDropdownCurrentValue(StrafeDropdown)
            if cur and cur ~= "" then
                state.StrafeTarget = cur
            else
                local names = playerNameList()
                if #names > 0 then
                    state.StrafeTarget = names[1]
                    safeSetControlValue(StrafeDropdown, names[1])
                end
            end
        end
        if not state.StrafeTarget then
            safeSetControlValue(StrafeToggle, false)
            return
        end
        startStrafe(6,5)
    else
        stopStrafe()
    end
end)

Tabs.PVP:AddButton({ Title = "Update Players", Callback = function()
    local names = playerNameList()
    pcall(function() if StrafeDropdown.SetValues then StrafeDropdown:SetValues(names) elseif StrafeDropdown.SetOptions then StrafeDropdown:SetOptions(names) else rawset(StrafeDropdown, "_values", names) end end)
    pcall(function() if PlayerDropdown and PlayerDropdown.SetValues then PlayerDropdown:SetValues(names) elseif PlayerDropdown and PlayerDropdown.SetOptions then PlayerDropdown:SetOptions(names) end end)
end })

local AimbotToggle = Tabs.PVP:AddToggle("Aimbot", { Title = "Aimbot", Default = false })
safeOnChanged(AimbotToggle, function(val) state.Aimbot = val; if val then startAimbot() else stopAimbot() end end)

local SilentToggle = Tabs.PVP:AddToggle("SilentAim", { Title = "Silent Aim", Default = false })
safeOnChanged(SilentToggle, function(val) state.SilentAim = val end)

local TriggerToggle = Tabs.PVP:AddToggle("TriggerBot", { Title = "TriggerBot", Default = false })
safeOnChanged(TriggerToggle, function(val) state.TriggerBot = val; if val then startTriggerBot() else stopTriggerBot() end end)

local CrossInput = Tabs.PVP:AddInput("Crosshair", { Title = "Crosshair", Default = "", Placeholder = "Asset id", Numeric = true, Finished = true, Callback = function(v) setCrosshair(v) end })
Tabs.PVP:AddButton({
    Title = "Change Crosshair",
    Callback = function()
        local id = CrossInput.Value
        if not id or id == "" or not tonumber(id) then return end
        setCrosshair(id)
    end
})

-- Player tab
local PlayerDropdown = createDropdown(Tabs.Player, "PlayerSelect", { Title = "Player", Values = playerNameList(), Multi = false, Default = nil })
safeOnChanged(PlayerDropdown, function(val) state.SelectedPlayer = val end)

local TweenToggle = Tabs.Player:AddToggle("Tween", { Title = "Tween", Default = false })
safeOnChanged(TweenToggle, function(val)
    if val then
        if not state.SelectedPlayer then
            local cur = getDropdownCurrentValue(PlayerDropdown)
            if cur and cur ~= "" then state.SelectedPlayer = cur
            else local names = playerNameList(); if #names > 0 then state.SelectedPlayer = names[1]; safeSetControlValue(PlayerDropdown, names[1]) end end
        end
        if not state.SelectedPlayer then safeSetControlValue(TweenToggle, false); return end
        tweenTo(state.SelectedPlayer)
        safeSetControlValue(TweenToggle, false)
    end
end)

Tabs.Player:AddButton({ Title = "Update Players", Callback = function()
    local names = playerNameList()
    pcall(function() if StrafeDropdown.SetValues then StrafeDropdown:SetValues(names) elseif StrafeDropdown.SetOptions then StrafeDropdown:SetOptions(names) end end)
    pcall(function() if PlayerDropdown.SetValues then PlayerDropdown:SetValues(names) elseif PlayerDropdown.SetOptions then PlayerDropdown:SetOptions(names) end end)
end })

local WalkSlider = Tabs.Player:AddSlider("Walkspeed", { Title = "Walkspeed", Default = 16, Min = 0, Max = 360, Rounding = 1, Callback = function(v)
    state.Walkspeed = v
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.WalkSpeed = v end) end
end })
WalkSlider:SetValue(16)

local JumpSlider = Tabs.Player:AddSlider("Jumppower", { Title = "Jumppower", Default = 50, Min = 0, Max = 500, Rounding = 1, Callback = function(v)
    state.Jumppower = v
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.JumpPower = v end) end
end })
JumpSlider:SetValue(50)

local GravSlider = Tabs.Player:AddSlider("Gravity", { Title = "Gravity", Default = workspace.Gravity, Min = 0, Max = 200, Rounding = 1, Callback = function(v)
    state.Gravity = v
    pcall(function() workspace.Gravity = v end)
end })
GravSlider:SetValue(workspace.Gravity)

local FlyToggle = Tabs.Player:AddToggle("Fly", { Title = "Fly", Default = false })
safeOnChanged(FlyToggle, function(val) state.Fly = val; if val then startFly() else stopFly() end end)

local ESPToggle = Tabs.Player:AddToggle("ESP", { Title = "ESP", Default = false })
safeOnChanged(ESPToggle, function(val)
    state.ESP = val
    if val then
        for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createBillboard(p) end end
        startESPLoop()
    else
        stopESPLoop()
        for p,_ in pairs(billboardItems) do removeBillboard(p) end
    end
end)

local ChamsToggle = Tabs.Player:AddToggle("Chams", { Title = "Chams", Default = false })
safeOnChanged(ChamsToggle, function(val)
    state.Chams = val
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createCham(p) end end
    if not espRenderConn then startESPLoop() end
end)

local TracerToggle = Tabs.Player:AddToggle("Tracer", { Title = "Tracer", Default = false })
safeOnChanged(TracerToggle, function(val)
    state.Tracer = val
    for _, p in ipairs(Players:GetPlayers()) do if p ~= LocalPlayer then createTracer(p) end end
    if not espRenderConn then startESPLoop() end
end)

local DisableAnimsToggle = Tabs.Player:AddToggle("DisableAnims", { Title = "Disable Animations", Default = false })
safeOnChanged(DisableAnimsToggle, function(val) setDisableAnimations(val) end)

local AntiAFKToggle = Tabs.Player:AddToggle("AntiAFK", { Title = "Anti AFK", Default = false })
safeOnChanged(AntiAFKToggle, function(val) setAntiAFK(val) end)

-- Universal tab: add external tools
Tabs.Main:AddButton({
    Title = "Infinite Yield",
    Description = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/refs/heads/master/source"))()
        end)
    end
})

Tabs.Main:AddButton({
    Title = "Nameless Admin",
    Description = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/Nameless-Admin/refs/heads/main/Source.lua"))()
        end)
    end
})

Tabs.Main:AddButton({
    Title = "Silent Aim",
    Description = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/bomalalarblx/blox/refs/heads/main/silentaimuniversal"))()
        end)
    end
})

Tabs.Main:AddButton({
    Title = "Universe Viewer",
    Description = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ltseverydayyou/uuuuuuu/main/Universe%20Viewer"))()
        end)
    end
})

Tabs.Main:AddButton({
    Title = "Yeet Gui(Fling)",
    Description = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Flacherflache/FE-Yeet-Gui/refs/heads/main/Script"))()
        end)
    end
})

Tabs.Main:AddButton({
    Title = "Fly Gui V3",
    Description = "",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
        end)
    end
})

-- Servers tab UI
local JobInput = Tabs.Config:AddInput("JobIDInput", { Title = "JobID", Default = "", Placeholder = "Enter Job ID", Numeric = false })
Tabs.Config:AddButton({ Title = "Join JobID", Callback = function() joinJobById(JobInput.Value) end })
Tabs.Config:AddButton({
    Title = "Server Hop",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/Morples/Server-hop/refs/heads/main/Script"))()
        end)
    end
})
Tabs.Config:AddButton({ Title = "Rejoin", Callback = rejoin })

-- Optimizer UI
Tabs.FPS:AddButton({ Title = "Uncapped 240 FPS", Description = "Set FPS cap to 240 (recommended)", Callback = function() setFPSCap(240) end })
local AntiLagToggle = Tabs.FPS:AddToggle("AntiLag", { Title = "Anti-Lag", Default = false })
safeOnChanged(AntiLagToggle, function(val) if val then runAntiLag() end end)

-- Character spawn handling: reapply settings and handlers
LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(0.5)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum.WalkSpeed = state.Walkspeed
            hum.JumpPower = state.Jumppower
        end)
        if state.DisableAnims then attachAnimHandlers(LocalPlayer, hum) end
    end
end)

-- Save / Interface managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("KPsHub")
SaveManager:SetFolder("KPsHub/GameConfigs")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

-- Safe Fluent.Unloaded hookup
local function safeConnectUnloaded(fn)
    if not Fluent then return end
    local u = Fluent.Unloaded
    if u and type(u.Connect) == "function" then
        pcall(function() u:Connect(fn) end)
        return
    end
    if type(Fluent.Unloaded) == "function" then
        pcall(function() Fluent.Unloaded(fn) end)
        return
    end
end

-- Cleanup on unload
safeConnectUnloaded(function()
    pcall(function() if stopAimbot then stopAimbot() end end)
    pcall(function() if stopTriggerBot then stopTriggerBot() end end)
    pcall(function() if stopStrafe then stopStrafe() end end)
    pcall(function() if stopFly then stopFly() end end)
    pcall(function() if setAntiAFK then setAntiAFK(false) end end)
    pcall(function() if setDisableAnimations then setDisableAnimations(false) end end)
    if fpsLoop then pcall(function() task.cancel(fpsLoop) end); fpsLoop = nil end
end)

return true
