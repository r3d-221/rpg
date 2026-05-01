local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = ReplicatedStorage.Shared.Remotes
local getEnemyData = Remotes.getEnemyData
local enemySpawned = Remotes.enemySpawned

local UITemplates = ReplicatedStorage.UITemplates
local enemyUI = UITemplates.enemyUI
local EnemyData = require(ReplicatedStorage.Shared.Modules.EnemyData)

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
	local enemySubtype = data.enemySubtype or {}

	private.updateUI(info, level, configName, humanoid)
	private.updateTyping(info, enemyType, enemySubtype)
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

function private.updateTyping(info, enemyType, enemySubtype)
	local types = info:FindFirstChild("types")
	local typeIcon = types:FindFirstChild("type")
	local subtype1 = types:FindFirstChild("subtype1")
	local subtype2 = types:FindFirstChild("subtype2")

	typeIcon.Image = EnemyData.typingImages[enemyType]

	if #enemySubtype > 0 then
		subtype1.Visible = true
		subtype1.Image = EnemyData.typingImages[enemySubtype[1]]

		if #enemySubtype > 1 then
			subtype2.Visible = true
			subtype2.Image = EnemyData.typingImages[enemySubtype[2]]
		else
			subtype2.Visible = false
		end
	else
		subtype1.Visible = false
		subtype2.Visible = false
	end
end

return public
