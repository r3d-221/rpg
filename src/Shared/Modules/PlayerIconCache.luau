local Players = game:GetService("Players")

local ICON_TYPE = Enum.ThumbnailType.HeadShot
local ICON_SIZE = Enum.ThumbnailSize.Size420x420

local cache: { [number]: string } = {}
local public = {}

function public.onStart()
	for _, p in Players:GetPlayers() do
		public.get(p.UserId, function() end)
	end

	Players.PlayerAdded:Connect(function(p)
		public.get(p.UserId, function() end)
	end)
end

function public.get(userId: number, onLoaded: (imageId: string) -> ())
	if cache[userId] then
		onLoaded(cache[userId])
		return
	end

	task.spawn(function()
		local ok, imageId = pcall(Players.GetUserThumbnailAsync, Players, userId, ICON_TYPE, ICON_SIZE)
		if ok and imageId then
			cache[userId] = imageId
			onLoaded(imageId)
		end
	end)
end

return public
