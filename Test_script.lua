-- LocalScript (ANIMATION CONTROLLER + TOOL PRIORITY)

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ===== CONFIG =====
local WALK_SPEED = 16
local RUN_SPEED = 24

local IDLE_ID = "rbxassetid://IDLE_ID"
local WALK_ID = "rbxassetid://WALK_ID"
local RUN_ID  = "rbxassetid://127429124578905"
local JUMP_ID = "rbxassetid://JUMP_ID"
local FALL_ID = "rbxassetid://FALL_ID"

local FADE = 0.25

-- Tool priority (padrão ligado)
local TOOL_PRIORITY = true

-- ===== FUNÇÕES DE COMANDO =====
_G.tool_on = function()
	TOOL_PRIORITY = true
	print("Tool priority: ON")
end

_G.tool_off = function()
	TOOL_PRIORITY = false
	print("Tool priority: OFF")
end

-- ===== MAIN =====
local function onCharacterAdded(character)
	local humanoid = character:WaitForChild("Humanoid")

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	-- ===== ANIMAÇÕES =====
	local function loadAnim(id, priority, looped)
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		local track = animator:LoadAnimation(anim)
		track.Priority = priority
		track.Looped = looped
		return track
	end

	local idle = loadAnim(IDLE_ID, Enum.AnimationPriority.Idle, true)
	local walk = loadAnim(WALK_ID, Enum.AnimationPriority.Movement, true)
	local run  = loadAnim(RUN_ID,  Enum.AnimationPriority.Movement, true)
	local jump = loadAnim(JUMP_ID, Enum.AnimationPriority.Action, false)
	local fall = loadAnim(FALL_ID, Enum.AnimationPriority.Action, true)

	local function stopAll(except)
		for _,track in pairs({idle, walk, run, jump, fall}) do
			if track ~= except and track.IsPlaying then
				track:Stop(FADE)
			end
		end
	end

	RunService.RenderStepped:Connect(function()
		local state = humanoid:GetState()
		local moving = humanoid.MoveDirection.Magnitude > 0
		local speed = humanoid.WalkSpeed
		local holdingTool = character:FindFirstChildOfClass("Tool") ~= nil

		-- ===== TOOL PRIORITY =====
		if TOOL_PRIORITY and holdingTool then
			-- só bloqueia animações de MOVIMENTO
			if walk.IsPlaying then walk:Stop(FADE) end
			if run.IsPlaying then run:Stop(FADE) end
		end

		-- ===== JUMP =====
		if state == Enum.HumanoidStateType.Jumping then
			stopAll(jump)
			if not jump.IsPlaying then
				jump:Play(FADE)
			end
			return
		end

		-- ===== FALL =====
		if state == Enum.HumanoidStateType.Freefall then
			stopAll(fall)
			if not fall.IsPlaying then
				fall:Play(FADE)
			end
			return
		end

		-- ===== RUN =====
		if speed == RUN_SPEED and moving then
			if not (TOOL_PRIORITY and holdingTool) then
				stopAll(run)
				if not run.IsPlaying then
					run:Play(FADE)
				end
			end
			return
		end

		-- ===== WALK =====
		if speed == WALK_SPEED and moving then
			if not (TOOL_PRIORITY and holdingTool) then
				stopAll(walk)
				if not walk.IsPlaying then
					walk:Play(FADE)
				end
			end
			return
		end

		-- ===== IDLE =====
		if not moving then
			stopAll(idle)
			if not idle.IsPlaying then
				idle:Play(FADE)
			end
		end
	end)
end

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)
