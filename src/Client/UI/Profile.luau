local LocalizationService = game:GetService("LocalizationService")
local public = {}
local private = {}

local profile
local class = "warrior"

local info
local assignablePointsAmount

local playerInfo
local classText
local rankText
local titleText

local stats
local healthAmount
local armorAmount
local luckAmount
local damageAmount
local critRateAmount
local critDamageAmount
local armorPierceAmount
local attackSpeedAmount
local cooldownReductionAmount

local statPoints
local healthStatPoint
local healthStatPointAmount
local healthStatPointAddButton
local armorStatPoint
local armorStatPointAmount
local armorStatPointAddButton
local damageStatPoint
local damageStatPointAmount
local damageStatPointAddButton
local critRateStatPoint
local critRateStatPointAmount
local critRateStatPointAddButton
local critDamageStatPoint
local critDamageStatPointAmount
local critDamageStatPointAddButton

local tabs
local statsTab
local statsTabText
local statsTabButton
local infoTab
local infoTabText
local infoTabButton
local statPointTab
local statPointTabText
local statPointTabButton

local equipmentsList
local weaponSlot
local weaponSlotGlow
local helmetSlot
local helmetSlotGlow
local chestplateSlot
local chestplateSlotGlow
local leggingsSlot
local leggingsSlotGlow
local bootsSlot
local bootsSlotGlow

local weaponSlotButton
local helmetSlotButton
local chestplateSlotButton
local leggingsSlotButton
local bootsSlotButton
local closeButton

function public.onStart(screenGui: ScreenGui)
	profile = screenGui:FindFirstChild("Profile")
	closeButton = profile:FindFirstChild("close"):FindFirstChild("button")
	equipmentsList = profile:FindFirstChild("equipments"):FindFirstChild("list")
	weaponSlot = equipmentsList:FindFirstChild("weapon_slot")
	weaponSlotButton = weaponSlot:FindFirstChild("button")
	weaponSlotGlow = weaponSlot:FindFirstChild("glow")
	helmetSlot = equipmentsList:FindFirstChild("helmet_slot")
	helmetSlotButton = helmetSlot:FindFirstChild("button")
	helmetSlotGlow = helmetSlot:FindFirstChild("glow")
	chestplateSlot = equipmentsList:FindFirstChild("chestplate_slot")
	chestplateSlotButton = chestplateSlot:FindFirstChild("button")
	chestplateSlotGlow = chestplateSlot:FindFirstChild("glow")
	leggingsSlot = equipmentsList:FindFirstChild("leggings_slot")
	leggingsSlotButton = weaponSlot:FindFirstChild("button")
	leggingsSlotGlow = leggingsSlot:FindFirstChild("glow")
	bootsSlot = equipmentsList:FindFirstChild("boots_slot")
	bootsSlotButton = bootsSlot:FindFirstChild("button")
	bootsSlotGlow = bootsSlot:FindFirstChild("glow")
	info = profile:FindFirstChild("info")
	assignablePointsAmount = info:FindFirstChild("assignable_points"):FindFirstChild("amount")
	playerInfo = info:FindFirstChild("player_info")
	classText = playerInfo:FindFirstChild("class"):FindFirstChild("text")
	rankText = playerInfo:FindFirstChild("rank"):FindFirstChild("text")
	titleText = playerInfo:FindFirstChild("title"):FindFirstChild("text")
	stats = info:FindFirstChild("stats")
	healthAmount = stats:FindFirstChild("health"):FindFirstChild("amount")
	armorAmount = stats:FindFirstChild("armor"):FindFirstChild("amount")
	luckAmount = stats:FindFirstChild("luck"):FindFirstChild("amount")
	damageAmount = stats:FindFirstChild("damage"):FindFirstChild("amount")
	critRateAmount = stats:FindFirstChild("crit_rate"):FindFirstChild("amount")
	critDamageAmount = stats:FindFirstChild("crit_damage"):FindFirstChild("amount")
	armorPierceAmount = stats:FindFirstChild("armor_pierce"):FindFirstChild("amount")
	attackSpeedAmount = stats:FindFirstChild("attack_speed"):FindFirstChild("amount")
	cooldownReductionAmount = stats:FindFirstChild("cooldown_reduction"):FindFirstChild("amount")
	statPoints = info:FindFirstChild("stat_point")
	healthStatPoint = statPoints:FindFirstChild("health")
	healthStatPointAmount = healthStatPoint:FindFirstChild("amount")
	healthStatPointAddButton = healthStatPoint:FindFirstChild("add_button"):FindFirstChild("button")
	armorStatPoint = statPoints:FindFirstChild("armor")
	armorStatPointAmount = armorStatPoint:FindFirstChild("amount")
	armorStatPointAddButton = armorStatPoint:FindFirstChild("add_button"):FindFirstChild("button")
	damageStatPoint = statPoints:FindFirstChild("damage")
	damageStatPointAmount = damageStatPoint:FindFirstChild("amount")
	damageStatPointAddButton = damageStatPoint:FindFirstChild("add_button"):FindFirstChild("button")
	critRateStatPoint = statPoints:FindFirstChild("crit_rate")
	critRateStatPointAmount = critRateStatPoint:FindFirstChild("amount")
	critRateStatPointAddButton = critRateStatPoint:FindFirstChild("add_button"):FindFirstChild("button")
	critDamageStatPoint = statPoints:FindFirstChild("crit_damage")
	critDamageStatPointAmount = critDamageStatPoint:FindFirstChild("amount")
	critDamageStatPointAddButton = critDamageStatPoint:FindFirstChild("add_button"):FindFirstChild("button")
	tabs = info:FindFirstChild("tabs")
	infoTab = tabs:FindFirstChild("info")
	infoTabText = infoTab:FindFirstChild("text")
	infoTabButton = infoTab:FindFirstChild("button")
	statsTab = tabs:FindFirstChild("stats")
	statsTabText = statsTab:FindFirstChild("text")
	statsTabButton = statsTab:FindFirstChild("button")
	statPointTab = tabs:FindFirstChild("stat_points")
	statsTabText = statPointTab:FindFirstChild("text")
	statPointTabButton = statPointTab:FindFirstChild("button")

	private.setupButtons()
end

function public.updateAll(data)
	private.updateClassLevel(data)
	private.updateEquipments(data)
	private.updateStatPoints(data)
	private.updateEquipments(data)
	private.updateStats(data)
	class = data.class
end

function private.updatePlayerInfo(data) end

function private.updateStatPoints(data) end

function private.updateEquipments(data) end

function private.updateStats(data)
	local Stats = data.classes[class].stats
	print(profile)
	print(info)
	print(stats)
	print(stats:FindFirstChild("health"))
	print(healthAmount)
	healthAmount.Text = Stats.health
	armorAmount.Text = Stats.armor
	luckAmount.Text = Stats.luck
	damageAmount.Text = Stats.damage
	critRateAmount.Text = Stats.critRate
	critDamageAmount.Text = Stats.critDamage
	armorPierceAmount.Text = Stats.armorPierce
	attackSpeedAmount.Text = Stats.attackSpeed
	cooldownReductionAmount.Text = Stats.cooldownReduction
end

function private.updateClassLevel(data) end

function private.setupButtons()
	closeButton.MouseButton1Click:Connect(function()
		profile.Visible = false
	end)

	weaponSlotButton.MouseButton1Click:Connect(function() end)
	helmetSlotButton.MouseButton1Click:Connect(function() end)
	chestplateSlotButton.MouseButton1Click:Connect(function() end)
	leggingsSlotButton.MouseButton1Click:Connect(function() end)
	bootsSlotButton.MouseButton1Click:Connect(function() end)

	healthStatPointAddButton.MouseButton1Click:Connect(function() end)
	armorStatPointAddButton.MouseButton1Click:Connect(function() end)
	damageStatPointAddButton.MouseButton1Click:Connect(function() end)
	critRateStatPointAddButton.MouseButton1Click:Connect(function() end)
	critDamageStatPointAddButton.MouseButton1Click:Connect(function() end)
end

function private.resetTabColor(tab)
	for _, child in tab:GetChildren() do
		if child:IsA("Frame") then
			child.BackgroundColor3 = Color3.fromHex("24201e")

			local label = child:FindFirstChildOfClass("TextLabel")
			if label then
				label.TextColor3 = Color3.fromHex("dcc9a9")
			end
		end
	end
end

return public
