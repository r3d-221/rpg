local Players = game:GetService("Players")

local public = {}

function public.onStart() end

Players.PlayerAdded:Connect(function()
	-- give attributes
end)

return public
