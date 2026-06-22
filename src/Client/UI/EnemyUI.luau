local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Shared.Remotes
local getEnemyData = Remotes.getEnemyData
local enemySpawned = Remotes.enemySpawned

local UITemplates = ReplicatedStorage.UITemplates
local enemyUI = UITemplates.enemyUI
local EnemyUIData = require(ReplicatedStorage.Shared.Modules.EnemyUIData)

local private = {}
local public = {}

function public.onStart()
	local existing = getEnemyData:InvokeServer()
	for _, entry in existing do
		task.spawn(private.setupUI, entry.enemy, entry.data)
	end

	enemySpawned.OnClientEvent:Connect(function(enemy, data)
		task.spawn(private.setupUI, enemy, data)
	end)
end

function private.setupUI(enemy, data)
	local humanoid = enemy:FindFirstChildOfClass("Humanoid") or enemy:WaitForChild("Humanoid", 5)
	if not humanoid then
		warn("Humanoid not found for enemy:", enemy.Name)
		return
	end

	local uiClone = enemyUI:Clone()
	uiClone.Parent = enemy
	local info = uiClone:FindFirstChild("info")

	local level = data.level or 1
	local configName = data.name or "zombie"
	local enemyType = data.enemyType or "melee"

	private.updateUI(info, level, configName, humanoid)
	private.updateTyping(info, enemyType)
end

function private.updateUI(info, level, name, humanoid)
	local levelText = info:FindFirstChild("level")
	local nameText = info:FindFirstChild("name")

	levelText.Text = "Lvl: " .. tostring(level)
	nameText.Text = name

	private.updateHealth(info, humanoid.Health, humanoid.MaxHealth)

	humanoid.HealthChanged:Connect(function(newHealth)
		private.updateHealth(info, newHealth, humanoid.MaxHealth)
	end)
end

function private.updateHealth(info, newHealth, maxHealth)
	local healthBar = info:FindFirstChild("healthBar")
	local currentHealthBar = healthBar:FindFirstChild("currentHealthBar")
	local healthText = healthBar:FindFirstChild("health")

	local ratio = newHealth / maxHealth
	currentHealthBar.Size = UDim2.fromScale(ratio, 1)
	healthText.Text = math.floor(newHealth) .. " / " .. math.floor(maxHealth)
end

function private.updateTyping(info, enemyType)
	local type = info:FindFirstChild("type")
	local typeIcon = type:FindFirstChild("typeIcon")
	typeIcon.Image = EnemyUIData.typingImages[enemyType]
end

return public
