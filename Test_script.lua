--// SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

--// CHARACTER
local function getChar()
	local char = player.Character or player.CharacterAdded:Wait()
	local hrp = char:WaitForChild("HumanoidRootPart")
	local hum = char:WaitForChild("Humanoid")
	return char, hrp, hum
end

--// GUI
local gui = Instance.new("ScreenGui")
gui.Name = "LarryHubDEV"
gui.ResetOnSpawn = false
gui.Parent = game.CoreGui

--// BOTÃO ☠️
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.fromOffset(40,40)
toggle.Position = UDim2.fromScale(0.92,0.08)
toggle.Text = "☠️"
toggle.TextSize = 22
toggle.Font = Enum.Font.GothamBlack
toggle.TextColor3 = Color3.new(1,1,1)
toggle.BackgroundColor3 = Color3.fromRGB(20,20,20)
toggle.Active = true
toggle.Draggable = true
toggle.Parent = gui
Instance.new("UICorner", toggle).CornerRadius = UDim.new(0,8)

--// FRAME PRINCIPAL (altura reduzida 10%)
local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(260,297) -- altura 330*0.9
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.fromScale(0.62,0.5)
frame.BackgroundColor3 = Color3.fromRGB(30,30,30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

--// TÍTULO
local title = Instance.new("TextLabel")
title.Size = UDim2.fromOffset(260,32)
title.Text = "☠️ LARRY HUB DEV ☠️"
title.Font = Enum.Font.GothamBlack
title.TextSize = 15
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundTransparency = 1
title.Parent = frame

--// SCROLLING FRAME
local scroll = Instance.new("ScrollingFrame")
scroll.Position = UDim2.fromOffset(0,32)
scroll.Size = UDim2.fromOffset(260,268)
scroll.CanvasSize = UDim2.new(0,0,0,0)
scroll.ScrollBarImageTransparency = 1
scroll.BackgroundTransparency = 1
scroll.Parent = frame

--// FUNÇÃO BOTÃO
local function mkBtn(text,color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromOffset(230,34)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = color
	Instance.new("UICorner", b).CornerRadius = UDim.new(0,10)
	return b
end

--// BOTÕES
local buttons = {}
buttons[#buttons+1] = mkBtn("SETAR POSIÇÃO", Color3.fromRGB(0,170,255))
buttons[#buttons+1] = mkBtn("IR ATÉ POSIÇÃO (TP)", Color3.fromRGB(0,200,120))  -- TP
buttons[#buttons+1] = mkBtn("IR ATÉ POSIÇÃO (TWEEN)", Color3.fromRGB(80,200,120)) -- Tween verde
buttons[#buttons+1] = mkBtn("NOCLIP: OFF", Color3.fromRGB(200,80,80))
buttons[#buttons+1] = mkBtn("ANTI RAGDOLL: OFF", Color3.fromRGB(200,80,80))
buttons[#buttons+1] = mkBtn("SPEED 1x", Color3.fromRGB(120,120,255))
buttons[#buttons+1] = mkBtn("TOOLS: OFF", Color3.fromRGB(180,120,60))
buttons[#buttons+1] = mkBtn("Infinite Yield", Color3.fromRGB(128,128,128))
buttons[#buttons+1] = mkBtn("KILL AURA: OFF", Color3.fromRGB(200,80,80))  -- KILL AURA OFF/ON


--// POSICIONA BOTÕES DINAMICAMENTE NO SCROLL
for i,btn in ipairs(buttons) do
	btn.Position = UDim2.fromOffset(15, 10 + (i-1)*44)
	btn.Parent = scroll
end
scroll.CanvasSize = UDim2.new(0,0,0,10 + #buttons*44)

--// SALVAR POSIÇÃO
local savedCF
buttons[1].MouseButton1Click:Connect(function()
	local _,hrp = getChar()
	savedCF = hrp.CFrame
end)

--// IR ATÉ POSIÇÃO (TP) - Teleporte instantâneo
buttons[2].MouseButton1Click:Connect(function()
	if not savedCF then return end
	local _,hrp = getChar()
	hrp.CFrame = savedCF
end)

--// VARIÁVEL DE VELOCIDADE DO TWEEN (studs por segundo)
local tweenSpeed = 250 -- você pode alterar esse valor manualmente

--// IR ATÉ POSIÇÃO (TWEEN) - velocidade controlada por você
buttons[3].MouseButton1Click:Connect(function()
	if not savedCF then return end
	local _, hrp = getChar()
	
	-- distância entre a posição atual e a posição salva
	local dist = (hrp.Position - savedCF.Position).Magnitude
	
	-- calcula a duração com base na velocidade que você define
	local duration = dist / tweenSpeed
	if duration == 0 then return end -- evita tween instantâneo se na mesma posição
	
	local tweenInfo = TweenInfo.new(
		duration,
		Enum.EasingStyle.Linear,
		Enum.EasingDirection.Out
	)
	
	local goal = {CFrame = savedCF}
	local tween = TweenService:Create(hrp, tweenInfo, goal)
	tween:Play()
end)

--// NOCLIP
local noclip = false
RunService.Stepped:Connect(function()
	if not noclip then return end
	for _,v in pairs(player.Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end)
buttons[4].MouseButton1Click:Connect(function()
	noclip = not noclip
	buttons[4].Text = noclip and "NOCLIP: ON" or "NOCLIP: OFF"
end)

--// ANTI RAGDOLL
local antiRag = false
RunService.Heartbeat:Connect(function()
	if not antiRag then return end
	local _,_,hum = getChar()
	hum.PlatformStand = false
	hum:ChangeState(Enum.HumanoidStateType.Running)
end)
buttons[5].MouseButton1Click:Connect(function()
	antiRag = not antiRag
	buttons[5].Text = antiRag and "ANTI RAGDOLL: ON" or "ANTI RAGDOLL: OFF"
end)

--// SPEED
local speed = 1
local base = 16
local function updateSpeed()
	local next = speed + 1
	if next > 5 then next = 1 end
	buttons[6].Text = "SPEED "..speed.."x (PRÓXIMO "..next.."x)"
	local _,_,hum = getChar()
	hum.WalkSpeed = base * speed
end
updateSpeed()
buttons[6].MouseButton1Click:Connect(function()
	speed += 1
	if speed > 5 then speed = 1 end
	updateSpeed()
end)

--// TOOLS FRAME
local toolsFrame = Instance.new("Frame")
toolsFrame.Size = UDim2.fromOffset(260,297)
toolsFrame.AnchorPoint = Vector2.new(0.5,0.5)
toolsFrame.BackgroundColor3 = Color3.fromRGB(25,25,25)
toolsFrame.BorderSizePixel = 0
toolsFrame.Visible = false
toolsFrame.Parent = gui
Instance.new("UICorner", toolsFrame).CornerRadius = UDim.new(0,12)

--// SEARCH
local search = Instance.new("TextBox")
search.Size = UDim2.fromOffset(230,30)
search.Position = UDim2.fromOffset(15,12)
search.PlaceholderText = "Buscar tool..."
search.Font = Enum.Font.Gotham
search.TextSize = 13
search.TextColor3 = Color3.new(1,1,1)
search.BackgroundColor3 = Color3.fromRGB(45,45,45)
search.Parent = toolsFrame
Instance.new("UICorner", search).CornerRadius = UDim.new(0,8)

--// SCROLL TOOLS
local toolsScroll = Instance.new("ScrollingFrame")
toolsScroll.Position = UDim2.fromOffset(0,50)
toolsScroll.Size = UDim2.fromOffset(260,243) -- altura 270*0.9
toolsScroll.CanvasSize = UDim2.new(0,0,0,0)
toolsScroll.ScrollBarImageTransparency = 1
toolsScroll.BackgroundTransparency = 1
toolsScroll.Parent = toolsFrame

--// ALINHAMENTO FRAME TOOLS
local function alignToolsFrame()
	toolsFrame.Position = UDim2.new(
		frame.Position.X.Scale,
		frame.Position.X.Offset - frame.AbsoluteSize.X - 14,
		frame.Position.Y.Scale,
		frame.Position.Y.Offset
	)
end
frame:GetPropertyChangedSignal("Position"):Connect(alignToolsFrame)
frame:GetPropertyChangedSignal("Size"):Connect(alignToolsFrame)
alignToolsFrame()

--// TOGGLE HUB
toggle.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
	if not frame.Visible then
		toolsFrame.Visible = false
		buttons[7].Text = "TOOLS: OFF"
	end
end)

--// TOOLS SYSTEM
local function loadTools(filter)
	toolsScroll:ClearAllChildren()
	local y = 0
	for _,obj in pairs(game:GetDescendants()) do
		if obj:IsA("Tool") and (not filter or obj.Name:lower():find(filter)) then
			local b = Instance.new("TextButton")
			b.Size = UDim2.fromOffset(230,30)
			b.Position = UDim2.fromOffset(15,y)
			b.Text = obj.Name
			b.Font = Enum.Font.Gotham
			b.TextSize = 13
			b.TextColor3 = Color3.new(1,1,1)
			b.BackgroundColor3 = Color3.fromRGB(60,60,60)
			b.Parent = toolsScroll
			Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
			b.MouseButton1Click:Connect(function()
				obj:Clone().Parent = player.Backpack
			end)
			y += 35
		end
	end
	toolsScroll.CanvasSize = UDim2.new(0,0,0,y)
end

buttons[7].MouseButton1Click:Connect(function()
	toolsFrame.Visible = not toolsFrame.Visible
	buttons[7].Text = toolsFrame.Visible and "TOOLS: ON" or "TOOLS: OFF"
	if toolsFrame.Visible then
		loadTools()
		alignToolsFrame()
	end
end)

search:GetPropertyChangedSignal("Text"):Connect(function()
	loadTools(search.Text:lower())
end)

--// INFINITE YIELD
buttons[8].MouseButton1Click:Connect(function()
	loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
end)

--// KILL AURA (dano em área)
local killAura = false
local damage = 100000 -- Dano de 100k

-- Função para aplicar dano
local function applyKillAura()
    if not killAura then return end  -- Se o Kill Aura estiver desligado, não faz nada
    local char, hrp = getChar()

    for _, target in pairs(workspace:GetChildren()) do
        if target:IsA("Model") and target ~= char and target:FindFirstChild("Humanoid") then
            local humanoid = target:FindFirstChild("Humanoid")
            local distance = (hrp.Position - target.PrimaryPart.Position).Magnitude

            if distance <= 20 then  -- Área de efeito
                humanoid:TakeDamage(damage)
            end
        end
    end
end

-- Atualizar Kill Aura
RunService.Heartbeat:Connect(function()
    applyKillAura()
end)

--// ATIVAR/DESATIVAR KILL AURA
buttons[9].MouseButton1Click:Connect(function()
    killAura = not killAura
    buttons[9].Text = killAura and "KILL AURA: ON" or "KILL AURA: OFF"
end)
