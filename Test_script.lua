--// SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local player = Players.LocalPlayer

--// GUI
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "AimbotESP"
gui.ResetOnSpawn = false

--// BOTÃO DE ABRIR MENU (MÓVEL)
local openBtn = Instance.new("TextButton", gui)
openBtn.Size = UDim2.fromOffset(36,36)
openBtn.Position = UDim2.fromScale(0.92,0.55)
openBtn.Text = "🏹"
openBtn.Font = Enum.Font.GothamBlack
openBtn.TextSize = 20
openBtn.TextColor3 = Color3.new(1,1,1)
openBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
openBtn.Active = true
openBtn.Draggable = true
Instance.new("UICorner", openBtn).CornerRadius = UDim.new(1,0)

--// BOTÃO DA MIRA CENTRAL (MÓVEL)
local crossBtn = Instance.new("TextButton", gui)
crossBtn.Size = UDim2.fromOffset(36,36)
crossBtn.Position = UDim2.fromScale(0.92,0.62)
crossBtn.Text = "🎯"
crossBtn.Font = Enum.Font.GothamBlack
crossBtn.TextSize = 20
crossBtn.TextColor3 = Color3.new(1,1,1)
crossBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
crossBtn.Active = true
crossBtn.Draggable = true
Instance.new("UICorner", crossBtn).CornerRadius = UDim.new(1,0)

--// FRAME PRINCIPAL (MENOR E MÓVEL)
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(180,260)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)
frame.BorderSizePixel = 0
frame.Visible = false
frame.Active = true
frame.Draggable = true
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

--// TÍTULO
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.fromOffset(180,28)
title.Text = "☠️AIMBOT DO LARRY☠️🏹"
title.Font = Enum.Font.GothamBlack
title.TextSize = 14
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1

--// SCROLL
local scroll = Instance.new("ScrollingFrame", frame)
scroll.Position = UDim2.fromOffset(0,28)
scroll.Size = UDim2.fromOffset(180,232)
scroll.ScrollBarImageTransparency = 1
scroll.BackgroundTransparency = 1

--// FUNÇÃO BOTÃO
local function mkBtn(text,color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(150,28)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 12
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = color
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	return b
end

--// ESTADOS
local aiming = false
local espEnabled = false
local autoNearest = false
local targetPlayer = nil
local espObjects = {}
local playerButtons = {}
local crossEnabled = false -- mira independente

--// MIRA CENTRAL (IMAGEM FIXA)
local cross = Instance.new("ImageLabel", gui)
cross.Size = UDim2.fromOffset(40,40)
cross.AnchorPoint = Vector2.new(0.5,0.5) -- Mantenha como 0.5, 0.5 para centralizar o centro da imagem
cross.Position = UDim2.fromScale(0.5,0.5) -- Posição central da tela
cross.Image = "rbxassetid://17431027" -- <== NOVO ID DA IMAGEM
cross.BackgroundTransparency = 1
cross.Visible = false

-- ... (o resto do seu script) ...



-- Toggle da mira via botão próprio
crossBtn.MouseButton1Click:Connect(function()
	crossEnabled = not crossEnabled
	cross.Visible = crossEnabled
	crossBtn.BackgroundColor3 = crossEnabled and Color3.fromRGB(80,200,120) or Color3.fromRGB(30,30,30)
end)

--// PLAYER MAIS PRÓXIMO
local function getNearestPlayer()
	local myChar = player.Character
	if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
	local myPos = myChar.HumanoidRootPart.Position

	local closest, dist = nil, math.huge
	for _,p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local d = (p.Character.HumanoidRootPart.Position - myPos).Magnitude
			if d < dist then
				dist = d
				closest = p
			end
		end
	end
	return closest
end

--// AIMBOT
RunService.RenderStepped:Connect(function()
	if not aiming then return end
	if autoNearest then
		targetPlayer = getNearestPlayer()
	end
	if targetPlayer and targetPlayer.Character then
		local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			Camera.CFrame = CFrame.new(Camera.CFrame.Position, hrp.Position)
		end
	end
end)

--// ESP
local function clearESP()
	for _,v in pairs(espObjects) do
		v:Destroy()
	end
	espObjects = {}
end

local function createESPForPlayer(p)
	if p == player then return end

	local function addBox(char)
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if hrp then
			local box = Instance.new("BoxHandleAdornment")
			box.Adornee = hrp
			box.Size = Vector3.new(2,3,1)
			box.Color = BrickColor.new("Bright red")
			box.AlwaysOnTop = true
			box.Transparency = 0.7
			box.ZIndex = 10
			box.Parent = Camera

			local nameBill = Instance.new("BillboardGui")
			nameBill.Adornee = hrp
			nameBill.Size = UDim2.fromOffset(200,50)
			nameBill.StudsOffset = Vector3.new(0,2,0)
			nameBill.AlwaysOnTop = true
			nameBill.Parent = Camera

			local nameLabel = Instance.new("TextLabel", nameBill)
			nameLabel.Size = UDim2.fromScale(1,1)
			nameLabel.BackgroundTransparency = 1
			nameLabel.TextColor3 = Color3.new(1,1,1)
			nameLabel.Font = Enum.Font.GothamBold
			nameLabel.TextSize = 14

			local conn
			conn = RunService.RenderStepped:Connect(function()
				if not espEnabled or not char.Parent then
					box:Destroy()
					nameBill:Destroy()
					conn:Disconnect()
					return
				end
				local dist = (hrp.Position - player.Character.HumanoidRootPart.Position).Magnitude
				nameLabel.Text = p.Name.." ["..math.floor(dist).."m]"
			end)

			table.insert(espObjects, box)
			table.insert(espObjects, nameBill)
		end
	end

	if p.Character then addBox(p.Character) end
	p.CharacterAdded:Connect(addBox)
end

local function createESP()
	clearESP()
	if not espEnabled then return end
	for _,p in pairs(Players:GetPlayers()) do
		createESPForPlayer(p)
	end
end

--// CARREGA MENU
local function loadMenu()
	scroll:ClearAllChildren()
	playerButtons = {}
	local y = 10

	local aimbotBtn = mkBtn("AIMBOT: OFF", Color3.fromRGB(180,60,60))
	aimbotBtn.Position = UDim2.fromOffset(15,y)
	aimbotBtn.Parent = scroll
	aimbotBtn.MouseButton1Click:Connect(function()
		aiming = not aiming
		aimbotBtn.Text = aiming and "AIMBOT: ON" or "AIMBOT: OFF"
		cross.Visible = aiming and crossEnabled
	end)
	y += 36

	local autoBtn = mkBtn("AUTO MAIS PRÓXIMO", Color3.fromRGB(80,140,255))
	autoBtn.Position = UDim2.fromOffset(15,y)
	autoBtn.Parent = scroll
	autoBtn.MouseButton1Click:Connect(function()
		autoNearest = not autoNearest
	end)
	y += 36

	local espBtn = mkBtn("ESP: OFF", Color3.fromRGB(60,180,60))
	espBtn.Position = UDim2.fromOffset(15,y)
	espBtn.Parent = scroll
	espBtn.MouseButton1Click:Connect(function()
		espEnabled = not espEnabled
		espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
		if espEnabled then
			createESP()
		else
			clearESP()
		end
	end)
	y += 36

	local function addPlayerButton(p)
		if p == player then return end
		local b = mkBtn(p.Name, Color3.fromRGB(60,60,60))
		b.Position = UDim2.fromOffset(15,y)
		b.Parent = scroll
		b.MouseButton1Click:Connect(function()
			targetPlayer = p
			autoNearest = false
			aiming = true
			cross.Visible = crossEnabled
		end)
		playerButtons[p] = b
		y += 32
		scroll.CanvasSize = UDim2.new(0,0,0,y)
	end

	for _,p in pairs(Players:GetPlayers()) do
		addPlayerButton(p)
	end
	Players.PlayerAdded:Connect(addPlayerButton)
end

--// ABRIR / FECHAR MENU
openBtn.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
	if frame.Visible then
		loadMenu()
	end
end)
