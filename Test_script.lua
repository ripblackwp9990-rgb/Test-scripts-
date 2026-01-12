--// SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--// PERSONAGEM
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

--// BOTÃO
local button = script.Parent
button.Font = Enum.Font.GothamBold
button.TextSize = 14
button.TextColor3 = Color3.new(1,1,1)

--// ESTADOS
-- 1 = OFF
-- 2 = LOCK
-- 3 = AIM
local state = 1

_G.MobileShiftlock = false
local offset = CFrame.new(1.75, 0, 0)

--// FUNÇÃO TEXTO
local function updateText()
	if state == 1 then
		button.Text = "Shiftlock (OFF)"
		button.BackgroundColor3 = Color3.fromRGB(80,80,80)
	elseif state == 2 then
		button.Text = "Shiftlock (LOCK)"
		button.BackgroundColor3 = Color3.fromRGB(0,170,0)
	elseif state == 3 then
		button.Text = "Shiftlock (AIM)"
		button.BackgroundColor3 = Color3.fromRGB(170,0,170)
	end
end

updateText()

--// CLICK
button.MouseButton1Click:Connect(function()
	state += 1
	if state > 3 then
		state = 1
	end
	updateText()
end)

--// LOOP
RunService.RenderStepped:Connect(function()
	if state == 1 then
		-- OFF
		_G.MobileShiftlock = false
		UserGameSettings.RotationType = Enum.RotationType.MovementRelative
		humanoid.AutoRotate = true

	elseif state == 2 then
		-- LOCK (Shiftlock normal)
		_G.MobileShiftlock = true
		UserGameSettings.RotationType = Enum.RotationType.CameraRelative
		humanoid.AutoRotate = false
		camera.CFrame = camera.CFrame * offset

	elseif state == 3 then
		-- AIM (Shiftlock de mira)
		_G.MobileShiftlock = true
		UserGameSettings.RotationType = Enum.RotationType.CameraRelative
		humanoid.AutoRotate = false

		-- trava câmera reta
		camera.CFrame = CFrame.new(
			camera.CFrame.Position,
			camera.CFrame.Position + camera.CFrame.LookVector
		)
	end
end)
