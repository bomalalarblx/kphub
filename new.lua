repeat wait() until game:IsLoaded() 

--[[
manh yeu oiiii
--]]
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Stats = game:GetService("Stats")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Clear previous UI instances by name (call this at the top)
local function clearPreviousUI(names)
    names = names or {}
    -- Clear from PlayerGui
    pcall(function()
        for _, name in ipairs(names) do
            for _, child in ipairs(playerGui:GetChildren()) do
                if child and child.Name == name then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end)
    -- Clear from CoreGui (some scripts may place GUI there)
    pcall(function()
        for _, name in ipairs(names) do
            for _, child in ipairs(CoreGui:GetChildren()) do
                if child and child.Name == name then
                    pcall(function() child:Destroy() end)
                end
            end
        end
    end)
end

-- Names of UIs this script creates
clearPreviousUI({
    "KP_Hub_UI",
    "RejoinUI",
    "ServerHopUI",
    "LeftCtrlUI",
    "AntiErrorUI"
})

-- Helper to create instances quickly
local function new(className, props)
    local obj = Instance.new(className)
    if props then
        for k, v in pairs(props) do
            if k == "Parent" then
                obj.Parent = v
            else
                pcall(function() obj[k] = v end)
            end
        end
    end
    return obj
end

--------------------------------------------------------------------------------
-- KP Hub status bar (top-center)
--------------------------------------------------------------------------------
do
    -- Root ScreenGui
    local screenGui = new("ScreenGui", {
        Name = "KP_Hub_UI",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    -- BindableEvent for ping updates
    local pingEvent = new("BindableEvent", { Parent = screenGui, Name = "KP_Hub_PingUpdated" })

    local WIDTH = 440
    local HEIGHT = 50

    local container = new("Frame", {
        Name = "Container",
        Parent = screenGui,
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.02, 0),
        Size = UDim2.new(0, WIDTH, 0, HEIGHT),
        BackgroundColor3 = Color3.fromRGB(10, 10, 10),
        BorderSizePixel = 0,
        ClipsDescendants = true,
    })
    new("UICorner", { Parent = container, CornerRadius = UDim.new(0, 10) })
    new("UIStroke", { Parent = container, Color = Color3.fromRGB(28,28,28), Thickness = 1, Transparency = 0.2 })
    new("UIGradient", {
        Parent = container,
        Color = ColorSequence.new{
            ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 14, 70)),
            ColorSequenceKeypoint.new(0.55, Color3.fromRGB(12,12,12)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 40, 16)),
        },
        Rotation = 0,
    })

    -- Left icon
    local icon = new("Frame", {
        Parent = container,
        Position = UDim2.new(0, 8, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.new(0, 28, 0, 24),
        BackgroundColor3 = Color3.fromRGB(88, 52, 190),
        BorderSizePixel = 0,
    })
    new("UICorner", { Parent = icon, CornerRadius = UDim.new(0, 6) })
    new("UIStroke", { Parent = icon, Color = Color3.fromRGB(62,38,142), Thickness = 1 })
    new("TextLabel", {
        Parent = icon,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "K",
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(235,235,255),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    -- Left text: title / link / subtitle
    local leftBlock = new("Frame", {
        Parent = container,
        Position = UDim2.new(0, 44, 0, 0),
        Size = UDim2.new(0, 260, 1, 0),
        BackgroundTransparency = 1,
    })
    new("TextLabel", {
        Parent = leftBlock,
        Position = UDim2.new(0, 0, 0, 2),
        Size = UDim2.new(1, 0, 0.55, 0),
        BackgroundTransparency = 1,
        Text = "KP's Hub v2.0",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Color3.fromRGB(200, 110, 255),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    new("TextLabel", {
        Parent = leftBlock,
        Position = UDim2.new(0, 190, 0, 2),
        Size = UDim2.new(0, 80, 0.55, 0),
        BackgroundTransparency = 1,
        Text = "dc; @playhero_",
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextColor3 = Color3.fromRGB(210, 100, 230),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })
    new("TextLabel", {
        Parent = leftBlock,
        Position = UDim2.new(0, 0, 0.55, 0),
        Size = UDim2.new(1, 0, 0.45, 0),
        BackgroundTransparency = 1,
        Text = "@d_cuong0 & @playhero_",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = Color3.fromRGB(170,170,170),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    })

    -- Right stats area (FPS + PING)
    local statsFrame = new("Frame", {
        Parent = container,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.new(0, 150, 0, HEIGHT - 6),
        BackgroundTransparency = 1,
    })
    new("UIListLayout", {
        Parent = statsFrame,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 0),
    })

    local function statLabel(initial)
        return new("TextLabel", {
            Parent = statsFrame,
            Size = UDim2.new(1, 0, 0.5, 0),
            BackgroundTransparency = 1,
            Text = initial,
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Color3.fromRGB(78, 255, 166), -- default green
            TextXAlignment = Enum.TextXAlignment.Right,
            TextYAlignment = Enum.TextYAlignment.Center,
        })
    end

    local fpsLabel = statLabel("FPS: 0")
    local pingLabel = statLabel("PING: 0ms") -- always numeric

    -- Close overlay (icon click closes)
    local closeBtn = new("TextButton", {
        Parent = icon,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
    })
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(container, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {BackgroundTransparency = 1}):Play()
        TweenService:Create(container, TweenInfo.new(0.18, Enum.EasingStyle.Quad), {Position = container.Position + UDim2.new(0,0,0,-8)}):Play()
        delay(0.18, function()
            if screenGui and screenGui.Parent then
                screenGui:Destroy()
            end
        end)
    end)


    -- FPS and Ping tracking (updates once per second)
    local frames = 0
    local last = tick()

    RunService.RenderStepped:Connect(function()
        frames = frames + 1
        local now = tick()
        if now - last >= 1 then
            local fps = frames
            frames = 0
            last = now

            -- Attempt to read the server ping from Stats
            local rawPing = 0
            pcall(function()
                -- Stats.Network.ServerStatsItem["Data Ping"]:GetValue() returns ping in ms
                local serverStats = Stats.Network and Stats.Network.ServerStatsItem
                if serverStats and serverStats["Data Ping"] then
                    rawPing = serverStats["Data Ping"]:GetValue()
                else
                    rawPing = 0
                end
            end)

            local ping = math.floor(rawPing + 0.5)

            -- Update UI labels
            fpsLabel.Text = "FPS: " .. tostring(fps)
            pingLabel.Text = "PING: " .. tostring(ping) .. "ms"

            -- Visual ping color (no circle)
            if ping <= 100 then
                TweenService:Create(pingLabel, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(78,255,166)}):Play()
            elseif ping <= 200 then
                TweenService:Create(pingLabel, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(255,200,70)}):Play()
            else
                TweenService:Create(pingLabel, TweenInfo.new(0.12), {TextColor3 = Color3.fromRGB(255,90,90)}):Play()
            end

            -- Expose numeric ping as Player attribute and fire bindable event
            pcall(function()
                player:SetAttribute("KP_Hub_PingAvg", ping)
                pingEvent:Fire(ping)
            end)
        end
    end)

    -- Entrance animation
    container.BackgroundTransparency = 1
    container.Position = UDim2.new(0.5, 0, 0.02, -8)
    TweenService:Create(container, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0,
        Position = UDim2.new(0.5, 0, 0.02, 0)
    }):Play()
end

--------------------------------------------------------------------------------
-- Rejoin button (middle-right)
--------------------------------------------------------------------------------
do
    local screenGui = new("ScreenGui", {
        Name = "RejoinUI",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local BUTTON_WIDTH = 140
    local BUTTON_HEIGHT = 34
    local RIGHT_OFFSET = -12
    local BG_COLOR = Color3.fromRGB(12, 12, 12)
    local BG_HOVER = Color3.fromRGB(26, 26, 26)
    local TEXT_COLOR = Color3.fromRGB(255, 90, 90)

    local btn = new("TextButton", {
        Name = "RejoinButton",
        Parent = screenGui,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, RIGHT_OFFSET, 0.5, 0),
        Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT),
        BackgroundColor3 = BG_COLOR,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "Rejoin",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = TEXT_COLOR,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    new("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 8) })
    new("UIStroke", { Parent = btn, Color = Color3.fromRGB(22,22,22), Thickness = 1, Transparency = 0.2 })

    local shadow = new("Frame", {
        Name = "Shadow",
        Parent = screenGui,
        AnchorPoint = btn.AnchorPoint,
        Position = btn.Position,
        Size = btn.Size,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        ZIndex = btn.ZIndex - 1,
    })
    new("UICorner", { Parent = shadow, CornerRadius = UDim.new(0, 8) })
    btn:GetPropertyChangedSignal("Position"):Connect(function() shadow.Position = btn.Position end)
    btn:GetPropertyChangedSignal("Size"):Connect(function() shadow.Size = btn.Size end)

    local hoverTweenParams = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local pressTweenParams = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, hoverTweenParams, {BackgroundColor3 = BG_HOVER}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, hoverTweenParams, {BackgroundColor3 = BG_COLOR}):Play()
    end)

    local function rejoin()
        local success, err = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, player)
        end)
        if not success then
            warn("Rejoin failed:", err)
        end
    end

    local busy = false
    btn.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true

        local pressTween = TweenService:Create(btn, pressTweenParams, {
            BackgroundTransparency = 0,
            TextTransparency = 0,
        })
        local scaleGoals = {Size = UDim2.new(0, BUTTON_WIDTH - 6, 0, BUTTON_HEIGHT - 4)}
        local scaleTween = TweenService:Create(btn, pressTweenParams, scaleGoals)
        scaleTween:Play()
        pressTween:Play()

        rejoin()

        wait(0.12)

        TweenService:Create(btn, pressTweenParams, {Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT), BackgroundColor3 = BG_HOVER}):Play()

        delay(0.5, function() busy = false end)
    end)

    btn.BackgroundTransparency = 1
    btn.Position = UDim2.new(1, RIGHT_OFFSET, 0.5, -8)
    TweenService:Create(btn, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0,
        Position = UDim2.new(1, RIGHT_OFFSET, 0.5, 0),
    }):Play()
end

--------------------------------------------------------------------------------
-- Server Hop button (below Rejoin) - uses provided server hop implementation
--------------------------------------------------------------------------------
do
    local screenGui = new("ScreenGui", {
        Name = "ServerHopUI",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local BUTTON_WIDTH = 140
    local BUTTON_HEIGHT = 34
    local RIGHT_OFFSET = -12
    local BG_COLOR = Color3.fromRGB(12, 12, 12)
    local BG_HOVER = Color3.fromRGB(26, 26, 26)
    local TEXT_COLOR = Color3.fromRGB(255, 90, 90)
    local VERTICAL_SPACING = 10

    local btn = new("TextButton", {
        Name = "ServerHopButton",
        Parent = screenGui,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, RIGHT_OFFSET, 0.5, BUTTON_HEIGHT + VERTICAL_SPACING),
        Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT),
        BackgroundColor3 = BG_COLOR,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "Server Hop",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = TEXT_COLOR,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    new("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 8) })
    new("UIStroke", { Parent = btn, Color = Color3.fromRGB(22,22,22), Thickness = 1, Transparency = 0.2 })

    local shadow = new("Frame", {
        Name = "Shadow",
        Parent = screenGui,
        AnchorPoint = btn.AnchorPoint,
        Position = btn.Position,
        Size = btn.Size,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        ZIndex = btn.ZIndex - 1,
    })
    new("UICorner", { Parent = shadow, CornerRadius = UDim.new(0, 8) })

    btn:GetPropertyChangedSignal("Position"):Connect(function() shadow.Position = btn.Position end)
    btn:GetPropertyChangedSignal("Size"):Connect(function() shadow.Size = btn.Size end)

    local hoverTweenParams = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local pressTweenParams = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, hoverTweenParams, {BackgroundColor3 = BG_HOVER}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, hoverTweenParams, {BackgroundColor3 = BG_COLOR}):Play()
    end)

    -- Server hop implementation you gave (kept intact and used when button clicked)
    local function runProvidedServerHop()
        -- The script uses exploit-only file IO APIs (readfile/writefile/delfile) and game:HttpGet
        -- Wrap everything in pcall to avoid hard errors on environments where those functions are unavailable.
        pcall(function()
            local PlaceID = game.PlaceId
            local AllIDs = {}
            local foundAnything = ""
            local actualHour = os.date("!*t").hour
            local Deleted = false
            local File = pcall(function()
                AllIDs = HttpService:JSONDecode(readfile("NotSameServers.json"))
            end)
            if not File then
                table.insert(AllIDs, actualHour)
                pcall(function()
                    writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                end)
            end

            local function TPReturner()
                local Site
                if foundAnything == "" then
                    Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. tostring(PlaceID) .. '/servers/Public?sortOrder=Asc&limit=100'))
                else
                    Site = HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. tostring(PlaceID) .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. tostring(foundAnything)))
                end
                local ID = ""
                if Site and Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
                    foundAnything = Site.nextPageCursor
                end
                local num = 0
                for i,v in pairs((Site and Site.data) or {}) do
                    local Possible = true
                    ID = tostring(v.id)
                    if tonumber(v.maxPlayers) > tonumber(v.playing) then
                        for _,Existing in pairs(AllIDs) do
                            if num ~= 0 then
                                if ID == tostring(Existing) then
                                    Possible = false
                                end
                            else
                                if tonumber(actualHour) ~= tonumber(Existing) then
                                    pcall(function()
                                        delfile("NotSameServers.json")
                                        AllIDs = {}
                                        table.insert(AllIDs, actualHour)
                                    end)
                                end
                            end
                            num = num + 1
                        end
                        if Possible == true then
                            table.insert(AllIDs, ID)
                            wait()
                            pcall(function()
                                writefile("NotSameServers.json", HttpService:JSONEncode(AllIDs))
                                wait()
                                TeleportService:TeleportToPlaceInstance(PlaceID, ID, player)
                            end)
                            wait(4)
                        end
                    end
                end
            end

            local function TeleportLoop()
                while true do
                    wait()
                    pcall(function()
                        TPReturner()
                        if foundAnything ~= "" then
                            TPReturner()
                        end
                    end)
                end
            end

            -- Start the teleport loop in a spawned thread so UI doesn't freeze.
            task.spawn(function()
                TeleportLoop()
            end)
        end)
    end

    -- Click handling with debounce and press animation
    local busy = false
    btn.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true

        local scaleTween = TweenService:Create(btn, pressTweenParams, {Size = UDim2.new(0, BUTTON_WIDTH - 6, 0, BUTTON_HEIGHT - 4)})
        scaleTween:Play()

        -- Execute the provided server-hop function
        runProvidedServerHop()

        delay(0.12, function()
            TweenService:Create(btn, pressTweenParams, {Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT), BackgroundColor3 = BG_HOVER}):Play()
        end)

        delay(0.6, function() busy = false end)
    end)

    btn.BackgroundTransparency = 1
    btn.Position = UDim2.new(1, RIGHT_OFFSET, 0.5, BUTTON_HEIGHT + VERTICAL_SPACING - 8)
    TweenService:Create(btn, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0,
        Position = UDim2.new(1, RIGHT_OFFSET, 0.5, BUTTON_HEIGHT + VERTICAL_SPACING)
    }):Play()
end

--------------------------------------------------------------------------------
-- LeftCtrl replacement: simple action binder (above Rejoin)
-- (Synthesizing OS key presses is not allowed — this fires a BindableEvent and sets an attribute.)
--------------------------------------------------------------------------------
do
    local screenGui = new("ScreenGui", {
        Name = "LeftCtrlUI",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local BUTTON_WIDTH = 140
    local BUTTON_HEIGHT = 34
    local RIGHT_OFFSET = -12
    local BG_COLOR = Color3.fromRGB(12, 12, 12)
    local BG_HOVER = Color3.fromRGB(26, 26, 26)
    local TEXT_COLOR = Color3.fromRGB(255, 90, 90)
    local VERTICAL_SPACING = 10

    local btn = new("TextButton", {
        Name = "LeftCtrlButton",
        Parent = screenGui,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, RIGHT_OFFSET, 0.5, -(BUTTON_HEIGHT + VERTICAL_SPACING)),
        Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT),
        BackgroundColor3 = BG_COLOR,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "LeftCtrl",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = TEXT_COLOR,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })

    new("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 8) })
    new("UIStroke", { Parent = btn, Color = Color3.fromRGB(22,22,22), Thickness = 1, Transparency = 0.2 })

    local shadow = new("Frame", {
        Name = "Shadow",
        Parent = screenGui,
        AnchorPoint = btn.AnchorPoint,
        Position = btn.Position,
        Size = btn.Size,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        ZIndex = btn.ZIndex - 1,
    })
    new("UICorner", { Parent = shadow, CornerRadius = UDim.new(0, 8) })
    btn:GetPropertyChangedSignal("Position"):Connect(function() shadow.Position = btn.Position end)
    btn:GetPropertyChangedSignal("Size"):Connect(function() shadow.Size = btn.Size end)

    local hoverTweenParams = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local pressTweenParams = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, hoverTweenParams, {BackgroundColor3 = BG_HOVER}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, hoverTweenParams, {BackgroundColor3 = BG_COLOR}):Play()
    end)

    local leftCtrlEvent = new("BindableEvent", { Parent = screenGui, Name = "LeftCtrlClicked" })

    local function leftCtrlAction()
        local ts = tick()
        pcall(function() player:SetAttribute("LeftCtrl_LastClicked", ts) end)
        pcall(function() leftCtrlEvent:Fire(player, ts) end)
        warn("[LeftCtrl] Button clicked by", player.Name)
    end

    local busy = false
    btn.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true

        local press = TweenService:Create(btn, pressTweenParams, {Size = UDim2.new(0, BUTTON_WIDTH - 6, 0, BUTTON_HEIGHT - 4)})
        press:Play()

        leftCtrlAction()

        delay(0.12, function()
            TweenService:Create(btn, pressTweenParams, {Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT), BackgroundColor3 = BG_HOVER}):Play()
        end)

        delay(0.5, function() busy = false end)
    end)

    btn.BackgroundTransparency = 1
    btn.Position = UDim2.new(1, RIGHT_OFFSET, 0.5, -(BUTTON_HEIGHT + VERTICAL_SPACING) - 8)
    TweenService:Create(btn, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0,
        Position = UDim2.new(1, RIGHT_OFFSET, 0.5, -(BUTTON_HEIGHT + VERTICAL_SPACING))
    }):Play()
end

--------------------------------------------------------------------------------
-- Anti-Error toggle (above Rejoin, clears teleport errors)
--------------------------------------------------------------------------------
do
    local screenGui = new("ScreenGui", {
        Name = "AntiErrorUI",
        Parent = playerGui,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    })

    local BUTTON_WIDTH = 140
    local BUTTON_HEIGHT = 34
    local RIGHT_OFFSET = -12
    local BG_COLOR = Color3.fromRGB(12, 12, 12)
    local BG_HOVER = Color3.fromRGB(26, 26, 26)
    local TEXT_COLOR = Color3.fromRGB(255, 90, 90)
    local VERTICAL_SPACING = 10

    local btn = new("TextButton", {
        Name = "AntiErrorButton",
        Parent = screenGui,
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, RIGHT_OFFSET, 0.5, -(BUTTON_HEIGHT + VERTICAL_SPACING)),
        Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT),
        BackgroundColor3 = BG_COLOR,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "Anti-Error: OFF",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = TEXT_COLOR,
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
    })
    new("UICorner", { Parent = btn, CornerRadius = UDim.new(0, 8) })
    new("UIStroke", { Parent = btn, Color = Color3.fromRGB(22,22,22), Thickness = 1, Transparency = 0.2 })

    local shadow = new("Frame", {
        Name = "Shadow",
        Parent = screenGui,
        AnchorPoint = btn.AnchorPoint,
        Position = btn.Position,
        Size = btn.Size,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        ZIndex = btn.ZIndex - 1,
    })
    new("UICorner", { Parent = shadow, CornerRadius = UDim.new(0, 8) })
    btn:GetPropertyChangedSignal("Position"):Connect(function() shadow.Position = btn.Position end)
    btn:GetPropertyChangedSignal("Size"):Connect(function() shadow.Size = btn.Size end)

    local hoverTweenParams = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local pressTweenParams = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, hoverTweenParams, {BackgroundColor3 = BG_HOVER}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, hoverTweenParams, {BackgroundColor3 = BG_COLOR}):Play()
    end)

    local LOOK_FOR = {
        "teleport failed",
        "server is full",
        "error code: 772"
    }

    local function textMatches(s)
        if not s or s == "" then return false end
        local lower = tostring(s):lower()
        for _, pat in ipairs(LOOK_FOR) do
            if lower:find(pat, 1, true) then
                return true
            end
        end
        return false
    end

    local function removeContainer(guiObject)
        if not guiObject or not guiObject.Parent then return end
        local ancestor = guiObject
        while ancestor and not ancestor:IsA("ScreenGui") and ancestor.Parent do
            ancestor = ancestor.Parent
        end
        local target = (ancestor and ancestor:IsA("ScreenGui")) and ancestor or guiObject.Parent
        pcall(function() if target and target.Destroy then target:Destroy() end end)
    end

    local function inspect(obj)
        pcall(function()
            if not obj then return end
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                if textMatches(obj.Text) then
                    removeContainer(obj)
                    return
                end
            end
            if obj.Name and textMatches(obj.Name) then
                removeContainer(obj)
                return
            end
        end)
    end

    local active = false
    local descAddedConn = nil
    local scanTask = nil

    local function startMonitor()
        if active then return end
        active = true

        -- Initial scan
        pcall(function()
            for _, desc in ipairs(CoreGui:GetDescendants()) do
                inspect(desc)
            end
        end)

        -- React when new GUI elements appear
        descAddedConn = CoreGui.DescendantAdded:Connect(function(desc)
            -- small wait to allow nested text to populate before inspection
            task.wait(0.02)
            inspect(desc)
            pcall(function()
                for _, c in ipairs(desc:GetDescendants()) do
                    inspect(c)
                end
            end)
        end)

        -- Periodic fallback scan
        scanTask = task.spawn(function()
            while active do
                task.wait(0.5)
                pcall(function()
                    for _, desc in ipairs(CoreGui:GetDescendants()) do
                        inspect(desc)
                    end
                end)
            end
        end)
    end

    local function stopMonitor()
        if not active then return end
        active = false
        if descAddedConn then
            pcall(function() descAddedConn:Disconnect() end)
            descAddedConn = nil
        end
        -- scanTask will naturally finish since active is false
    end

    local function setActive(on)
        if on then
            startMonitor()
            btn.Text = "Anti-Error: ON"
            btn.TextColor3 = Color3.fromRGB(120, 255, 140)
        else
            stopMonitor()
            btn.Text = "Anti-Error: OFF"
            btn.TextColor3 = TEXT_COLOR
        end
    end

    local busy = false
    btn.MouseButton1Click:Connect(function()
        if busy then return end
        busy = true

        setActive(not active)

        local press = TweenService:Create(btn, pressTweenParams, {Size = UDim2.new(0, BUTTON_WIDTH - 6, 0, BUTTON_HEIGHT - 4)})
        press:Play()
        delay(0.12, function()
            TweenService:Create(btn, pressTweenParams, {Size = UDim2.new(0, BUTTON_WIDTH, 0, BUTTON_HEIGHT), BackgroundColor3 = BG_HOVER}):Play()
        end)

        delay(0.35, function() busy = false end)
    end)

    btn.BackgroundTransparency = 1
    btn.Position = UDim2.new(1, RIGHT_OFFSET, 0.5, -(BUTTON_HEIGHT + VERTICAL_SPACING) - 8)
    TweenService:Create(btn, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
        BackgroundTransparency = 0,
        Position = UDim2.new(1, RIGHT_OFFSET, 0.5, -(BUTTON_HEIGHT + VERTICAL_SPACING))
    }):Play()

    -- Expose a BindableEvent and attribute so other local scripts can check the state if desired
    local event = new("BindableEvent", { Parent = screenGui, Name = "AntiErrorToggled" })
    btn.Changed:Connect(function(prop)
        if prop == "Text" then
            pcall(function() event:Fire(active) end)
        end
    end)

    -- Start disabled by default
    setActive(false)
end

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
    Title = "KP's Hub v2.0 | @playhero_ on discord",
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

local WalkInput = Tabs.Player:AddInput("WalkspeedInput", {
    Title = "Walkspeed Input",
    Default = tostring(state.Walkspeed), -- Default value as string
    Placeholder = "Enter walkspeed",
    Numeric = true, -- Ensures the input only accepts numbers
    Finished = true, -- Only trigger the callback when the input is complete
    Callback = function(value)
        local walkSpeedValue = tonumber(value)
        if walkSpeedValue then
            state.Walkspeed = walkSpeedValue
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                pcall(function() hum.WalkSpeed = walkSpeedValue end)
            end
            WalkSlider:SetValue(walkSpeedValue) -- Sync the slider with the input value
        else
            notify("Error", "Please enter a valid number for walkspeed!", 4)
        end
    end
})

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
Tabs.Player:AddButton({
    Title = "Desync(Patched)",
    Description = "",
    Callback = function()
        -- list of flags to apply
        local flags = {
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
            {"AngularVelociryLimit", "360"},
        }

        local applied = 0
        for _, pair in ipairs(flags) do
            local name, value = pair[1], pair[2]
            local ok, err = pcall(function()
                -- setfflag may not be available in all environments; wrap in pcall
                if type(setfflag) == "function" then
                    setfflag(name, value)
                else
                    error("setfflag unavailable")
                end
            end)
            if ok then
                applied = applied + 1
            end
        end

        -- Use notify() from the main script if available, otherwise attempt Fluent notify
        pcall(function()
            if type(notify) == "function" then
                notify("Desync", ("Applied %d/%d flags"):format(applied, #flags), 4)
            elseif Fluent and type(Fluent.Notify) == "function" then
                Fluent:Notify({ Title = "Desync", Content = ("Applied %d/%d flags"):format(applied, #flags), Duration = 4 })
            else
                print(("Desync: applied %d/%d flags"):format(applied, #flags))
            end
        end)
    end
})
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
Tabs.FPS:AddButton({ Title = "Uncapped 240 FPS", Description = "Set FPS cap to 240 (recommended)", Callback = function() setFPSCap(9999) end })
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

local ACCancellerToggle = Tabs.Player:AddToggle("ACCancellerPacket", {
    Title = "ACCanceller Packet",
    Default = false,
    Callback = function(isEnabled)
        if isEnabled then
            -- Start intercepting movement-related packets
            task.spawn(function()
                local mt = getrawmetatable(game) -- Get the raw metatable of the game
                local oldNamecall = mt.__namecall -- Backup the original __namecall metamethod
                
                setreadonly(mt, false) -- Allow modification to the metatable

                mt.__namecall = function(self, ...)
                    local args = { ... }
                    local method = getnamecallmethod() -- Get the method being called
                    
                    -- Intercept movement packets (e.g., walkspeed, jumppower, flying packets, etc.)
                    if tostring(method) == "FireServer" or tostring(method) == "InvokeServer" then
                        local remoteName = tostring(self)
                        if remoteName == "WalkSpeed" or remoteName == "JumpPower" or remoteName == "Fly" then
                            -- Block/ignore the movement packet
                            return -- Cancel the function call entirely
                        end
                    end

                    return oldNamecall(self, ...) -- Fall back to default behavior for other packets
                end

                setreadonly(mt, true) -- Lock the metatable after modification
            end)
        else
            -- Reverse and reset the metatable
            local mt = getrawmetatable(game)
            if mt then
                setreadonly(mt, false)
                mt.__namecall = rawget(mt, "__original__namecall") or mt.__namecall
                setreadonly(mt, true)
            end
        end
    end
})

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
