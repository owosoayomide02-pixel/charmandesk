--!strict
--[[
	Session cache + UpdateAsync. Receipts always go through update() so
	offline ProcessReceipt retries still persist.
]]

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local COSG = require(RS:WaitForChild("COSG"))

local Config = COSG.Config
local ProfileTemplate = COSG.ProfileTemplate

local store = DataStoreService:GetDataStore(Config.Stores.Player)
local cache: { [number]: any } = {}

local Profile = {}

function Profile.getCached(userId: number): any?
	return cache[userId]
end

function Profile.hydrate(raw: any, userId: number)
	return ProfileTemplate.hydrate(raw, userId)
end

function Profile.update(userId: number, mutator: (any) -> ()): (boolean, string?)
	local ok, err = pcall(function()
		store:UpdateAsync(Config.Keys.player(userId), function(old)
			local data = Profile.hydrate(old, userId)
			mutator(data)
			data.v = Config.SCHEMA_VERSION
			cache[userId] = data
			return data
		end)
	end)
	if ok then
		return true, nil
	end
	return false, tostring(err)
end

function Profile.load(userId: number): (any?, string?)
	if cache[userId] then
		return cache[userId], nil
	end
	local ok, result = pcall(function()
		return store:GetAsync(Config.Keys.player(userId))
	end)
	if not ok then
		return nil, tostring(result)
	end
	local data = Profile.hydrate(result, userId)
	data.lastLogin = os.time()
	cache[userId] = data
	return data, nil
end

function Profile.save(userId: number): (boolean, string?)
	local data = cache[userId]
	if not data then
		return false, "no_session"
	end
	return Profile.update(userId, function(fresh)
		for key, value in data do
			fresh[key] = value
		end
	end)
end

function Profile.release(userId: number)
	if cache[userId] then
		Profile.save(userId)
	end
	cache[userId] = nil
end

function Profile.bind()
	Players.PlayerAdded:Connect(function(player)
		local data, err = Profile.load(player.UserId)
		if not data then
			warn("[COSG] load failed", player.UserId, err)
		end
	end)
	Players.PlayerRemoving:Connect(function(player)
		Profile.release(player.UserId)
	end)
	game:BindToClose(function()
		for _, player in Players:GetPlayers() do
			Profile.release(player.UserId)
		end
	end)
end

return Profile
