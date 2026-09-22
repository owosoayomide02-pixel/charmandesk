--!strict
--[[
	Charmdesk HUD: Play, Shop, Prestige.
]]

local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local COSG = require(RS:WaitForChild("COSG"))
local Appearance = COSG.Appearance
local Catalog = COSG.Catalog
local Config = COSG.Config
local Economy = COSG.Economy
local Operators = COSG.Operators
local ShopRotation = COSG.ShopRotation

local remotes = RS:WaitForChild(COSG.Remotes.FolderName)
local ClickBatch = remotes:WaitForChild(COSG.Remotes.ClickBatch) :: RemoteEvent
local ProfileSync = remotes:WaitForChild(COSG.Remotes.ProfileSync) :: RemoteEvent
local BuyUpgrade = remotes:WaitForChild(COSG.Remotes.BuyUpgrade) :: RemoteFunction
local PrestigeFn = remotes:WaitForChild(COSG.Remotes.Prestige) :: RemoteFunction
local EquipFn = remotes:WaitForChild(COSG.Remotes.Equip) :: RemoteFunction
local StudioBuy = remotes:WaitForChild(COSG.Remotes.StudioBuy) :: RemoteFunction
local PreparePurchase = remotes:WaitForChild(COSG.Remotes.PreparePurchase) :: RemoteFunction

local snap: any = {
	glint = 0,
	runEarned = 0,
	clickLevel = 0,
	prestigeLevel = 0,
	prestigeMult = 1,
	clickPower = 1,
	clickCost = 12,
	prestigeNeed = Config.PrestigeNeed[1],
	operators = {},
	owned = {},
	equipped = Config.DefaultEquipped,
	studioShop = true,
}

local ownedSet: { [string]: boolean } = {}
local screen = "play"
local shopFilter = "all"
local pendingClicks = 0
local pendingCrits = 0
local comboPeak = 0
local combo = 0
local lastTap = 0
local comboPeakHold = 0

local function fmt(n: number): string
	if n >= 1000000 then
		return string.format("%.2fM", n / 1000000)
	end
	if n >= 1000 then
		return string.format("%.1fk", n / 1000)
	end
	return tostring(math.floor(n + 0.5))
end

local function owns(id: string): boolean
	return ownedSet[id] == true
end

local function applySnap(nextSnap: any)
	if type(nextSnap) ~= "table" then
		return
	end
	snap = nextSnap
	ownedSet = {}
	if type(snap.owned) == "table" then
		for _, id in snap.owned do
			ownedSet[id] = true
		end
	end
end

local gui = Instance.new("ScreenGui")
gui.Name = "CharmdeskHud"
gui.IgnoreGuiInset = true
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function mk(className: string, props: { [string]: any }, parent: Instance?): Instance
	local inst = Instance.new(className)
	for k, v in props do
		(inst :: any)[k] = v
	end
	if parent then
		inst.Parent = parent
	end
	return inst
end

local root = mk("Frame", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = Appearance.Ink,
	BorderSizePixel = 0,
}, gui) :: Frame

local top = mk("Frame", {
	Size = UDim2.new(1, 0, 0, 72),
	BackgroundColor3 = Appearance.InkRaised,
	BorderSizePixel = 0,
}, root) :: Frame

local glintLabel = mk("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 28),
	Size = UDim2.new(0.6, -16, 0, 36),
	Font = Enum.Font.GothamBold,
	Text = "0",
	TextColor3 = Appearance.Gold,
	TextSize = 28,
	TextXAlignment = Enum.TextXAlignment.Left,
}, top) :: TextLabel

local roomLabel = mk("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 8),
	Size = UDim2.new(0.6, -16, 0, 20),
	Font = Enum.Font.GothamMedium,
	Text = "Bedroom Desk",
	TextColor3 = Appearance.Muted,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Left,
}, top) :: TextLabel

local prestigeLabel = mk("TextLabel", {
	BackgroundTransparency = 1,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -16, 0, 24),
	Size = UDim2.fromOffset(140, 32),
	Font = Enum.Font.GothamMedium,
	Text = "P0 · 1.00×",
	TextColor3 = Appearance.Muted,
	TextSize = 14,
	TextXAlignment = Enum.TextXAlignment.Right,
}, top) :: TextLabel

local playPage = mk("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 72),
	Size = UDim2.new(1, 0, 1, -136),
}, root) :: Frame

local comboLabel = mk("TextLabel", {
	BackgroundTransparency = 1,
	Size = UDim2.new(1, 0, 0, 24),
	Position = UDim2.new(0, 0, 0.08, 0),
	Font = Enum.Font.GothamMedium,
	Text = "Combo 0",
	TextColor3 = Appearance.Mint,
	TextSize = 16,
}, playPage) :: TextLabel

local coreWrap = mk("TextButton", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.42),
	Size = UDim2.fromOffset(168, 168),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
}, playPage) :: TextButton

local coreRing = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(152, 152),
	BackgroundColor3 = Appearance.InkRaised,
	BorderSizePixel = 0,
}, coreWrap) :: Frame
mk("UICorner", { CornerRadius = UDim.new(1, 0) }, coreRing)

local coreGem = mk("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(84, 84),
	BackgroundColor3 = Appearance.Gold,
	BorderSizePixel = 0,
}, coreWrap) :: Frame
mk("UICorner", { CornerRadius = UDim.new(1, 0) }, coreGem)

local trailLabel = mk("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 0, 0.68, 0),
	Size = UDim2.new(1, 0, 0, 22),
	Font = Enum.Font.GothamMedium,
	Text = "First Spark",
	TextColor3 = Appearance.Muted,
	TextSize = 14,
}, playPage) :: TextLabel

local opsRow = mk("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.new(0, 12, 0.76, 0),
	Size = UDim2.new(1, -24, 0, 72),
}, playPage) :: Frame
mk("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	Padding = UDim.new(0, 8),
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
}, opsRow)

local upgradeBtn = mk("TextButton", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -8),
	Size = UDim2.new(0.86, 0, 0, 40),
	BackgroundColor3 = Appearance.Gold,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "Upgrade click",
	TextColor3 = Appearance.Ink,
	TextSize = 16,
	AutoButtonColor = false,
}, playPage) :: TextButton

local shopPage = mk("ScrollingFrame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 72),
	Size = UDim2.new(1, 0, 1, -136),
	Visible = false,
	CanvasSize = UDim2.fromOffset(0, 0),
	ScrollBarThickness = 4,
	BorderSizePixel = 0,
}, root) :: ScrollingFrame

local prestigePage = mk("Frame", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(0, 72),
	Size = UDim2.new(1, 0, 1, -136),
	Visible = false,
}, root) :: Frame

mk("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 12),
	Size = UDim2.new(1, -32, 0, 32),
	Font = Enum.Font.GothamBold,
	Text = "Pack the desk",
	TextColor3 = Appearance.Cream,
	TextSize = 22,
	TextXAlignment = Enum.TextXAlignment.Left,
}, prestigePage)

local prestigeBody = mk("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(16, 48),
	Size = UDim2.new(1, -32, 0, 120),
	Font = Enum.Font.GothamMedium,
	Text = "",
	TextColor3 = Appearance.Muted,
	TextSize = 16,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}, prestigePage) :: TextLabel

local shineBtn = mk("TextButton", {
	Position = UDim2.new(0.07, 0, 0.62, 0),
	Size = UDim2.new(0.86, 0, 0, 44),
	BackgroundColor3 = Appearance.Gold,
	BorderSizePixel = 0,
	Font = Enum.Font.GothamBold,
	Text = "Shine again",
	TextColor3 = Appearance.Ink,
	TextSize = 18,
	AutoButtonColor = false,
}, prestigePage) :: TextButton

local nav = mk("Frame", {
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),
	Size = UDim2.new(1, 0, 0, 64),
	BackgroundColor3 = Appearance.InkRaised,
	BorderSizePixel = 0,
}, root) :: Frame
mk("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 8),
}, nav)

local navBtns: { [string]: TextButton } = {}
local function navBtn(id: string, label: string)
	local b = mk("TextButton", {
		Size = UDim2.fromOffset(96, 40),
		BackgroundColor3 = Appearance.Ink,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = label,
		TextColor3 = Appearance.Cream,
		TextSize = 14,
		AutoButtonColor = false,
	}, nav) :: TextButton
	navBtns[id] = b
	b.MouseButton1Click:Connect(function()
		screen = id
		render()
	end)
end
navBtn("play", "Play")
navBtn("shop", "Shop")
navBtn("prestige", "Prestige")

local toast = mk("TextLabel", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 80),
	Size = UDim2.new(0.8, 0, 0, 28),
	BackgroundTransparency = 1,
	Font = Enum.Font.GothamMedium,
	Text = "",
	TextColor3 = Appearance.Mint,
	TextSize = 14,
	Visible = false,
}, root) :: TextLabel

local function flash(msg: string)
	toast.Text = msg
	toast.Visible = true
	task.delay(1.6, function()
		if toast.Text == msg then
			toast.Visible = false
		end
	end)
end

local buyCosmetic: (string) -> ()
local render: () -> ()

local function setScreen()
	playPage.Visible = screen == "play"
	shopPage.Visible = screen == "shop"
	prestigePage.Visible = screen == "prestige"
	for id, b in navBtns do
		b.BackgroundColor3 = if id == screen then Appearance.Cream else Appearance.Ink
		b.TextColor3 = if id == screen then Appearance.Ink else Appearance.Cream
	end
end

local function rebuildOps()
	for _, child in opsRow:GetChildren() do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
	for _, def in Operators.all() do
		if def.launch then
			local count = 0
			if type(snap.operators) == "table" then
				count = snap.operators[def.id] or 0
			end
			local cost = Economy.operatorCost(def.id, count) or 0
			local locked = snap.runEarned < def.unlockRunEarned
			local b = mk("TextButton", {
				Size = UDim2.fromOffset(86, 64),
				BackgroundColor3 = Appearance.Cream,
				BorderSizePixel = 0,
				Font = Enum.Font.GothamMedium,
				Text = def.name .. "\n×" .. tostring(count),
				TextColor3 = Appearance.Ink,
				TextSize = 11,
				AutoButtonColor = false,
			}, opsRow) :: TextButton
			if locked then
				b.BackgroundColor3 = Appearance.InkRaised
				b.TextColor3 = Appearance.Muted
			end
			b.MouseButton1Click:Connect(function()
				local res = BuyUpgrade:InvokeServer(def.id)
				if res and res.ok and res.snap then
					applySnap(res.snap)
					render()
				else
					flash(if locked then "Locked" else "Need " .. fmt(cost) .. " Glint")
				end
			end)
		end
	end
end

local function rebuildShop()
	for _, child in shopPage:GetChildren() do
		child:Destroy()
	end
	local y = 8
	local limited = ShopRotation.current(os.time())
	if limited then
		local feat = mk("Frame", {
			Position = UDim2.fromOffset(12, y),
			Size = UDim2.new(1, -24, 0, 96),
			BackgroundColor3 = Appearance.InkRaised,
			BorderSizePixel = 0,
		}, shopPage) :: Frame
		mk("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(10, 8),
			Size = UDim2.new(1, -20, 0, 16),
			Font = Enum.Font.GothamMedium,
			Text = "This week",
			TextColor3 = Appearance.Coral,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, feat)
		mk("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.fromOffset(10, 28),
			Size = UDim2.new(1, -20, 0, 22),
			Font = Enum.Font.GothamBold,
			Text = limited.name,
			TextColor3 = Appearance.Cream,
			TextSize = 18,
			TextXAlignment = Enum.TextXAlignment.Left,
		}, feat)
		local buyL = mk("TextButton", {
			Position = UDim2.fromOffset(10, 56),
			Size = UDim2.fromOffset(180, 28),
			BackgroundColor3 = Appearance.Gold,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Text = if snap.studioShop then "Get (Studio) " .. tostring(limited.priceRobux) .. " R$" else "Buy " .. tostring(limited.priceRobux) .. " R$",
			TextColor3 = Appearance.Ink,
			TextSize = 13,
			AutoButtonColor = false,
		}, feat) :: TextButton
		buyL.MouseButton1Click:Connect(function()
			buyCosmetic(limited.id)
		end)
		y += 108
	end

	local filters = { "all", "trail", "operator", "companion", "theme" }
	local fRow = mk("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.fromOffset(12, y),
		Size = UDim2.new(1, -24, 0, 32),
	}, shopPage)
	mk("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
	}, fRow)
	for _, f in filters do
		local b = mk("TextButton", {
			Size = UDim2.fromOffset(72, 28),
			BackgroundColor3 = if shopFilter == f then Appearance.Cream else Appearance.InkRaised,
			BorderSizePixel = 0,
			Font = Enum.Font.GothamMedium,
			Text = f,
			TextColor3 = if shopFilter == f then Appearance.Ink else Appearance.Cream,
			TextSize = 12,
			AutoButtonColor = false,
		}, fRow) :: TextButton
		b.MouseButton1Click:Connect(function()
			shopFilter = f
			rebuildShop()
		end)
	end
	y += 44

	local col = 0
	for _, row in Catalog.launchShop() do
		if shopFilter == "all" or row.type == shopFilter then
			local x = if col == 0 then 12 else 12 + ((shopPage.AbsoluteSize.X - 32) / 2) + 4
			if shopPage.AbsoluteSize.X < 10 then
				x = if col == 0 then 12 else 200
			end
			local w = (shopPage.AbsoluteSize.X > 10) and ((shopPage.AbsoluteSize.X - 32) / 2) or 170
			local pin = mk("TextButton", {
				Position = UDim2.fromOffset(math.floor(x), y),
				Size = UDim2.fromOffset(math.floor(w), 72),
				BackgroundColor3 = Appearance.InkRaised,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
			}, shopPage) :: TextButton
			if owns(row.id) then
				pin.BackgroundColor3 = Color3.fromRGB(32, 48, 42)
			end
			mk("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 8),
				Size = UDim2.new(1, -16, 0, 22),
				Font = Enum.Font.GothamMedium,
				Text = row.name,
				TextColor3 = Appearance.Cream,
				TextSize = 14,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextTruncate = Enum.TextTruncate.AtEnd,
			}, pin)
			mk("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(8, 34),
				Size = UDim2.new(1, -16, 0, 28),
				Font = Enum.Font.GothamMedium,
				Text = if owns(row.id) then "Owned · Equip" else (tostring(row.priceRobux) .. " R$"),
				TextColor3 = if owns(row.id) then Appearance.Mint else Appearance.Gold,
				TextSize = 13,
				TextXAlignment = Enum.TextXAlignment.Left,
			}, pin)
			local id = row.id
			pin.MouseButton1Click:Connect(function()
				if owns(id) then
					local res = EquipFn:InvokeServer(id)
					if res and res.ok and res.snap then
						applySnap(res.snap)
						flash("Equipped")
						render()
					end
				else
					buyCosmetic(id)
				end
			end)
			col = 1 - col
			if col == 0 then
				y += 80
			end
		end
	end
	if col == 1 then
		y += 80
	end
	shopPage.CanvasSize = UDim2.fromOffset(0, y + 16)
end

buyCosmetic = function(id: string)
	if snap.studioShop then
		local res = StudioBuy:InvokeServer(id)
		if res and res.ok and res.snap then
			applySnap(res.snap)
			flash("Added to desk")
			render()
		else
			flash(res and res.err or "Cannot buy")
		end
		return
	end
	local prep = PreparePurchase:InvokeServer(id)
	if prep and prep.ok and prep.productId and prep.productId > 0 then
		MarketplaceService:PromptProductPurchase(player, prep.productId)
	else
		flash("Create product IDs in Creator Hub first")
	end
end

render = function()
	setScreen()
	glintLabel.Text = fmt(snap.glint or 0)
	local themeId = (snap.equipped and snap.equipped.theme) or "theme_bedroom_desk"
	local themeRow = Catalog.get(themeId)
	roomLabel.Text = if themeRow then themeRow.name else "Charmdesk"
	root.BackgroundColor3 = Appearance.theme(themeId)
	prestigeLabel.Text = ("P%d · %.2f×"):format(snap.prestigeLevel or 0, snap.prestigeMult or 1)
	local trailId = (snap.equipped and snap.equipped.trail) or "trail_click_firstspark"
	local trailRow = Catalog.get(trailId)
	trailLabel.Text = if trailRow then trailRow.name else trailId
	coreGem.BackgroundColor3 = Appearance.trail(trailId)
	upgradeBtn.Text = "Upgrade click · " .. fmt(snap.clickCost or 0)
	local need = snap.prestigeNeed
	local earned = snap.runEarned or 0
	if need then
		local left = math.max(0, need - earned)
		prestigeBody.Text = ("Keep cosmetics and shards.\nReset Glint, click level, and Operators.\n\nThis run %s / %s\n%s Glint to shine."):format(
			fmt(earned),
			fmt(need),
			fmt(left)
		)
		shineBtn.AutoButtonColor = left == 0
		shineBtn.BackgroundColor3 = if left == 0 then Appearance.Gold else Appearance.InkRaised
		shineBtn.TextColor3 = if left == 0 then Appearance.Ink else Appearance.Muted
	else
		prestigeBody.Text = "You are at the current prestige cap."
	end
	rebuildOps()
	if screen == "shop" then
		rebuildShop()
	end
end

local function flush()
	if pendingClicks < 1 then
		return
	end
	ClickBatch:FireServer({
		clicks = pendingClicks,
		crits = pendingCrits,
		comboPeak = math.max(comboPeak, comboPeakHold),
	})
	pendingClicks = 0
	pendingCrits = 0
	comboPeak = 0
end

local function tap()
	local t = os.clock()
	if t - lastTap < (1 / Config.Click.MaxPerSecond) then
		return
	end
	combo = if (t - lastTap) < (Config.Click.ComboWindowMs / 1000) then combo + 1 else 1
	lastTap = t
	comboPeak = math.max(comboPeak, combo)
	comboPeakHold = math.max(comboPeakHold, combo)
	local chance = math.min(Config.Click.CritChanceCap, Config.Click.CritBase + math.floor(combo / 5) * Config.Click.CritPerComboTier)
	local crit = math.random() < chance
	pendingClicks += 1
	if crit then
		pendingCrits += 1
	end
	local gain = snap.clickPower or 1
	if combo >= 5 then
		gain = math.floor(gain * 1.25)
	end
	if combo >= 10 then
		gain = math.floor((snap.clickPower or 1) * 1.5)
	end
	if crit then
		gain *= Config.Click.CritClickMultiplier
	end
	snap.glint += gain
	snap.runEarned += gain
	comboLabel.Text = (if crit then "Crit · " else "") .. "Combo " .. tostring(combo)
	glintLabel.Text = fmt(snap.glint)
	if pendingClicks >= 20 then
		flush()
	end
end

coreWrap.MouseButton1Click:Connect(tap)
upgradeBtn.MouseButton1Click:Connect(function()
	local res = BuyUpgrade:InvokeServer("click")
	if res and res.ok and res.snap then
		applySnap(res.snap)
		render()
	else
		flash("Need " .. fmt(snap.clickCost or 0) .. " Glint")
	end
end)
shineBtn.MouseButton1Click:Connect(function()
	local res = PrestigeFn:InvokeServer()
	if res and res.ok and res.snap then
		applySnap(res.snap)
		flash("Prestiged. Cosmetics stayed.")
		render()
	else
		flash("Not enough Glint this run")
	end
end)

UIS.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		-- HUD button handles its own clicks; space still taps.
	end
	if input.KeyCode == Enum.KeyCode.Space then
		tap()
	end
end)

ProfileSync.OnClientEvent:Connect(function(nextSnap)
	applySnap(nextSnap)
	render()
end)

task.spawn(function()
	while true do
		task.wait(Config.Click.BatchSeconds)
		flush()
		if os.clock() - lastTap > 0.5 then
			combo = 0
			comboLabel.Text = "Combo 0"
		end
	end
end)

task.spawn(function()
	local folder = Workspace:WaitForChild("Charmdesk", 15)
	if not folder then
		return
	end
	local core = folder:WaitForChild("GlintCore", 8)
	if core and core:IsA("BasePart") then
		local det = core:FindFirstChildOfClass("ClickDetector")
		if det then
			det.MouseClick:Connect(function()
				tap()
			end)
		end
	end
end)

MarketplaceService.PromptProductPurchaseFinished:Connect(function(_userId, _productId, isPurchased)
	if isPurchased then
		flash("Purchase complete")
	end
end)

render()
