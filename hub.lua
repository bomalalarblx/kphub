local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Main GUI Setup
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KPHub"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- Toggle Variables
local guiVisible = true
local isDragging = false
local dragStart = nil
local startPos = nil

-- Main Container (Smaller and Centered)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 320, 0, 240)
mainFrame.Position = UDim2.new(0.5, -160, 0.5, -120)
mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

-- Add Blur/Rounded Corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 15)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(100, 150, 255)
stroke.Thickness = 2
stroke.Parent = mainFrame

-- Blur Background Effect
local blurFrame = Instance.new("Frame")
blurFrame.Name = "BlurBackground"
blurFrame.Size = UDim2.new(1, 0, 1, 0)
blurFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
blurFrame.BackgroundTransparency = 0.4
blurFrame.BorderSizePixel = 0
blurFrame.ZIndex = 0
blurFrame.Parent = screenGui
blurFrame.CanCollide = false

-- Title
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, 0, 0, 40)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "KP's Hub"
titleLabel.TextColor3 = Color3.fromRGB(100, 150, 255)
titleLabel.TextSize = 24
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Parent = mainFrame

-- Close Button
local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.Size = UDim2.new(0, 30, 0, 30)
closeButton.Position = UDim2.new(1, -35, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
closeButton.Text = "×"
closeButton.TextSize = 20
closeButton.Font = Enum.Font.GothamBold
closeButton.BorderSizePixel = 0
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 8)
closeCorner.Parent = closeButton

-- Buttons Container
local buttonsFrame = Instance.new("Frame")
buttonsFrame.Name = "ButtonsFrame"
buttonsFrame.Size = UDim2.new(1, -20, 0, 160)
buttonsFrame.Position = UDim2.new(0, 10, 0, 50)
buttonsFrame.BackgroundTransparency = 1
buttonsFrame.Parent = mainFrame

-- UIListLayout for buttons
local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 10)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.Parent = buttonsFrame

-- Main Button
local mainButton = Instance.new("TextButton")
mainButton.Name = "MainButton"
mainButton.Size = UDim2.new(1, 0, 0, 45)
mainButton.BackgroundColor3 = Color3.fromRGB(50, 100, 200)
mainButton.TextColor3 = Color3.fromRGB(255, 255, 255)
mainButton.Text = "Main"
mainButton.TextSize = 16
mainButton.Font = Enum.Font.GothamBold
mainButton.BorderSizePixel = 0
mainButton.Parent = buttonsFrame

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainButton

-- New Button
local newButton = Instance.new("TextButton")
newButton.Name = "NewButton"
newButton.Size = UDim2.new(1, 0, 0, 45)
newButton.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
newButton.TextColor3 = Color3.fromRGB(255, 255, 255)
newButton.Text = "New"
newButton.TextSize = 16
newButton.Font = Enum.Font.GothamBold
newButton.BorderSizePixel = 0
newButton.Parent = buttonsFrame

local newCorner = Instance.new("UICorner")
newCorner.CornerRadius = UDim.new(0, 10)
newCorner.Parent = newButton

-- Logo (Middle Left of Screen)
local logoFrame = Instance.new("Frame")
logoFrame.Name = "LogoButton"
logoFrame.Size = UDim2.new(0, 60, 0, 60)
logoFrame.Position = UDim2.new(0, 20, 0.5, -30)
logoFrame.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
logoFrame.BorderSizePixel = 0
logoFrame.Parent = screenGui

local logoCorner = Instance.new("UICorner")
logoCorner.CornerRadius = UDim.new(0, 12)
logoCorner.Parent = logoFrame

local logoText = Instance.new("TextLabel")
logoText.Size = UDim2.new(1, 0, 1, 0)
logoText.BackgroundTransparency = 1
logoText.Text = "KP"
logoText.TextColor3 = Color3.fromRGB(255, 255, 255)
logoText.TextSize = 20
logoText.Font = Enum.Font.GothamBold
logoText.Parent = logoFrame

-- Make Logo Interactive (Button)
local logoButton = Instance.new("TextButton")
logoButton.Name = "LogoClickButton"
logoButton.Size = UDim2.new(1, 0, 1, 0)
logoButton.BackgroundTransparency = 1
logoButton.Text = ""
logoButton.Parent = logoFrame

-- Dragging Functionality
local function startDrag()
	isDragging = true
	dragStart = UserInputService:GetMouseLocation()
	startPos = mainFrame.Position
end

local function stopDrag()
	isDragging = false
end

local function updateDrag()
	if isDragging then
		local currentMouse = UserInputService:GetMouseLocation()
		local delta = currentMouse - dragStart
		mainFrame.Position = startPos + UDim2.new(0, delta.X, 0, delta.Y)
	end
end

-- Title Dragging
titleLabel.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		startDrag()
	end
end)

titleLabel.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		stopDrag()
	end
end)

-- Button Hover Effects
local function setupButtonHover(button)
	local originalColor = button.BackgroundColor3
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(
			math.min(originalColor.R * 255 + 30, 255) / 255,
			math.min(originalColor.G * 255 + 30, 255) / 255,
			math.min(originalColor.B * 255 + 30, 255) / 255
		)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = originalColor
	end)
end

setupButtonHover(mainButton)
setupButtonHover(newButton)
setupButtonHover(closeButton)

-- Logo Hover Effect
logoFrame.MouseEnter:Connect(function()
	logoFrame.BackgroundColor3 = Color3.fromRGB(150, 180, 255)
end)

logoFrame.MouseLeave:Connect(function()
	logoFrame.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
end)

-- Button Click Events
mainButton.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/bomalalarblx/kphub/refs/heads/main/new.lua"))()
end)

newButton.MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://pastefy.app/G52r336D/raw"))()
end)

-- Close Button
closeButton.MouseButton1Click:Connect(function()
	guiVisible = false
	mainFrame.Visible = false
	blurFrame.Visible = false
end)

-- Logo Toggle
logoButton.MouseButton1Click:Connect(function()
	guiVisible = not guiVisible
	mainFrame.Visible = guiVisible
	blurFrame.Visible = guiVisible
end)

-- Mouse Movement for Dragging
UserInputService.InputChanged:Connect(function(input, gameProcessed)
	if input.UserInputType == Enum.UserInputType.MouseMovement then
		updateDrag()
	end
end)

-- INSERT Key Toggle
UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.Insert then
		guiVisible = not guiVisible
		mainFrame.Visible = guiVisible
		blurFrame.Visible = guiVisible
	end
end)

print("KP's Hub Loaded! Press INSERT to toggle or click the logo.")
