--============================================================
-- DIG A VILLAIN! — ClientMain
-- TEMPAT: StarterPlayer > StarterPlayerScripts (sebagai LocalScript)
-- Semua tampilan (GUI) game ada di file ini.
--============================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local RE_Notify = ReplicatedStorage:WaitForChild("DAV_Notify")
local RE_Reveal = ReplicatedStorage:WaitForChild("DAV_Reveal")
local RE_Announce = ReplicatedStorage:WaitForChild("DAV_Announce")
local RE_Push = ReplicatedStorage:WaitForChild("DAV_Push")
local RE_Action = ReplicatedStorage:WaitForChild("DAV_Action")
local RF_State = ReplicatedStorage:WaitForChild("DAV_State")

local init = RF_State:InvokeServer()
local CAT = init.catalog
local ST = init.state

local function rgb(a) return Color3.fromRGB(a[1], a[2], a[3]) end
local function tierOf(villainName)
	for _, v in ipairs(CAT.villains) do if v.name == villainName then return v.tier end end
	return 1
end
local function act(t) RE_Action:FireServer(t) end

--=================== KERANGKA GUI ===================
local gui = Instance.new("ScreenGui")
gui.Name = "DAV_GUI" gui.ResetOnSpawn = false gui.Parent = playerGui

local function frame(parent, size, pos, color, transparency)
	local f = Instance.new("Frame")
	f.Size = size f.Position = pos f.BackgroundColor3 = color
	f.BackgroundTransparency = transparency or 0 f.BorderSizePixel = 0
	f.Parent = parent
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 10) c.Parent = f
	return f
end
local function label(parent, size, pos, text, color, textSize, align)
	local l = Instance.new("TextLabel")
	l.Size = size l.Position = pos l.BackgroundTransparency = 1
	l.Text = text l.TextColor3 = color or Color3.fromRGB(255, 255, 255)
	l.Font = Enum.Font.FredokaOne l.TextSize = textSize or 18
	l.TextXAlignment = align or Enum.TextXAlignment.Left
	l.Parent = parent
	return l
end
local function button(parent, size, pos, text, color, textSize)
	local b = Instance.new("TextButton")
	b.Size = size b.Position = pos b.BackgroundColor3 = color
	b.Text = text b.TextColor3 = Color3.fromRGB(255, 255, 255)
	b.Font = Enum.Font.FredokaOne b.TextSize = textSize or 16
	b.BorderSizePixel = 0 b.AutoButtonColor = true
	local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 8) c.Parent = b
	b.Parent = parent
	return b
end

-- HUD kiri atas
local hud = frame(gui, UDim2.fromOffset(250, 108), UDim2.fromOffset(12, 12), Color3.fromRGB(25, 22, 40), 0.15)
local coinsLabel = label(hud, UDim2.fromScale(1, 0.3), UDim2.fromOffset(12, 4), "🪙 0", Color3.fromRGB(255, 215, 90), 22)
local levelLabel = label(hud, UDim2.fromScale(1, 0.26), UDim2.fromOffset(12, 38), "⭐ Level 1", Color3.fromRGB(190, 220, 255), 17)
local xpBg = frame(hud, UDim2.fromOffset(226, 12), UDim2.fromOffset(12, 64), Color3.fromRGB(15, 13, 25), 0)
local xpBar = frame(xpBg, UDim2.fromScale(0, 1), UDim2.fromScale(0, 0), Color3.fromRGB(120, 220, 120), 0)
local clawLabel = label(hud, UDim2.fromScale(1, 0.24), UDim2.fromOffset(12, 80), "🦾 Rusty Claw", Color3.fromRGB(220, 200, 255), 15)

-- Tombol kanan atas
local btnCollection = button(gui, UDim2.fromOffset(130, 42), UDim2.new(1, -142, 0, 12), "📖 Koleksi", Color3.fromRGB(90, 60, 160))
local btnShop = button(gui, UDim2.fromOffset(130, 42), UDim2.new(1, -142, 0, 62), "🦾 Toko", Color3.fromRGB(40, 110, 160))
local btnCreator = button(gui, UDim2.fromOffset(130, 42), UDim2.new(1, -142, 0, 112), "👑 Creator", Color3.fromRGB(190, 140, 20))
btnCreator.Visible = false

-- Toast bawah
local toastLabel = label(gui, UDim2.new(0.8, 0, 0, 34), UDim2.new(0.1, 0, 1, -90), "",
	Color3.fromRGB(255, 255, 255), 20, Enum.TextXAlignment.Center)
toastLabel.TextStrokeTransparency = 0.4 toastLabel.Visible = false
local toastToken = 0
local function toast(text)
	toastToken += 1
	local my = toastToken
	toastLabel.Text = text toastLabel.Visible = true
	task.delay(3.2, function() if toastToken == my then toastLabel.Visible = false end end)
end

-- Pengumuman besar
local announceLabel = label(gui, UDim2.new(0.9, 0, 0, 60), UDim2.new(0.05, 0, 0, 90), "",
	Color3.fromRGB(255, 215, 90), 34, Enum.TextXAlignment.Center)
announceLabel.TextStrokeTransparency = 0.2 announceLabel.Visible = false
local annToken = 0
local function bigAnnounce(text)
	annToken += 1
	local my = annToken
	announceLabel.Text = text announceLabel.Visible = true
	task.delay(4.5, function() if annToken == my then announceLabel.Visible = false end end)
end

-- Banner reveal di tengah
local banner = frame(gui, UDim2.fromOffset(430, 150), UDim2.new(0.5, -215, 0.32, 0), Color3.fromRGB(30, 25, 50), 0.05)
banner.Visible = false
local bannerTier = label(banner, UDim2.fromScale(1, 0.3), UDim2.fromOffset(0, 8), "", nil, 24, Enum.TextXAlignment.Center)
local bannerName = label(banner, UDim2.fromScale(1, 0.38), UDim2.fromOffset(0, 48), "", nil, 32, Enum.TextXAlignment.Center)
local bannerCoins = label(banner, UDim2.fromScale(1, 0.26), UDim2.fromOffset(0, 106), "", Color3.fromRGB(255, 215, 90), 22, Enum.TextXAlignment.Center)
local bannerToken = 0
local function showBanner(tierName, tierColor, name, sub, dur)
	bannerToken += 1
	local my = bannerToken
	bannerTier.Text = tierName bannerTier.TextColor3 = tierColor
	bannerName.Text = name
	bannerCoins.Text = sub
	banner.Visible = true
	banner.Position = UDim2.new(0.5, -215, 0.32, 0)
	task.delay(dur or 3.4, function() if bannerToken == my then banner.Visible = false end end)
end

local function shakeCamera(intensity, dur)
	local cam = workspace.CurrentCamera
	if not cam then return end
	local t0 = os.clock()
	task.spawn(function()
		while os.clock() - t0 < dur do
			cam.CFrame = cam.CFrame * CFrame.new(
				(math.random() - 0.5) * intensity, (math.random() - 0.5) * intensity, 0)
			task.wait(0.03)
		end
	end)
end

--=================== PANEL UMUM ===================
local function makePanel(title, w, h)
	local p = frame(gui, UDim2.fromOffset(w, h), UDim2.new(0.5, -w / 2, 0.5, -h / 2), Color3.fromRGB(28, 25, 45), 0.03)
	p.Visible = false p.ZIndex = 5
	label(p, UDim2.new(1, -60, 0, 40), UDim2.fromOffset(16, 6), title, Color3.fromRGB(255, 255, 255), 24)
	local close = button(p, UDim2.fromOffset(38, 38), UDim2.new(1, -46, 0, 6), "✕", Color3.fromRGB(170, 50, 50), 18)
	close.ZIndex = 6
	close.MouseButton1Click:Connect(function() p.Visible = false end)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -24, 1, -96) scroll.Position = UDim2.fromOffset(12, 52)
	scroll.BackgroundTransparency = 1 scroll.BorderSizePixel = 0
	scroll.CanvasSize = UDim2.fromScale(0, 0) scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollBarThickness = 6 scroll.ZIndex = 5 scroll.Parent = p
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 6) layout.SortOrder = Enum.SortOrder.LayoutOrder layout.Parent = scroll
	return p, scroll
end

local function rowFrame(scroll, h, color)
	local f = frame(scroll, UDim2.new(1, -8, 0, h), UDim2.fromScale(0, 0), color or Color3.fromRGB(40, 37, 60), 0)
	f.ZIndex = 6
	return f
end

-- Hitungan salinan bebas (tidak terpajang) — cermin logika server
local function displayedCount(key)
	local n = 0
	for _, k in pairs(ST.displayed.ped) do if k == key then n += 1 end end
	if ST.displayed.throne == key then n += 1 end
	return n
end
local function avail(name, shiny)
	local c = ST.collection[name]
	local total = 0
	if c then total = shiny and (c.s or 0) or (c.n or 0) end
	return total - displayedCount(shiny and (name .. "|S") or name)
end

--=================== PANEL KOLEKSI ===================
local colPanel, colScroll = makePanel("📖 Koleksi Villain", 660, 470)
local giftPanel, giftScroll = makePanel("🎁 Pilih Penerima Gift", 380, 420)
local pendingGiftKey = nil

local function openGiftPicker(key)
	pendingGiftKey = key
	for _, ch in ipairs(giftScroll:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			local row = rowFrame(giftScroll, 44)
			local b = button(row, UDim2.new(1, -16, 1, -10), UDim2.fromOffset(8, 5),
				"🎁 Kirim ke " .. p.DisplayName, Color3.fromRGB(60, 130, 80), 16)
			b.ZIndex = 7
			local uid = p.UserId
			b.MouseButton1Click:Connect(function()
				act({ type = "gift", key = pendingGiftKey, target = uid })
				giftPanel.Visible = false
			end)
		end
	end
	giftPanel.Visible = true
end

local function refreshCollection()
	if not ST or not CAT then return end
	for _, ch in ipairs(colScroll:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	-- Bagian pajangan saat ini
	local dispRow = rowFrame(colScroll, 40, Color3.fromRGB(70, 58, 30))
	label(dispRow, UDim2.new(1, -16, 1, 0), UDim2.fromOffset(10, 0),
		"👑 Pajangan di home (penjaga = koin pasif/menit, takhta ×2):", Color3.fromRGB(255, 225, 140), 15)
	local anyDisp = false
	local function dispLine(text, slot)
		anyDisp = true
		local row = rowFrame(colScroll, 38)
		label(row, UDim2.new(1, -110, 1, 0), UDim2.fromOffset(10, 0), text, nil, 15)
		local b = button(row, UDim2.fromOffset(84, 28), UDim2.new(1, -94, 0, 5), "Copot", Color3.fromRGB(150, 60, 60), 14)
		b.ZIndex = 7
		b.MouseButton1Click:Connect(function() act({ type = "undisplay", slot = slot }) end)
	end
	if ST.displayed.throne then dispLine("👑 TAKHTA: " .. ST.displayed.throne:gsub("|S", " ✨"), "throne") end
	local slots = {}
	for s in pairs(ST.displayed.ped) do table.insert(slots, s) end
	table.sort(slots)
	for _, s in ipairs(slots) do dispLine("🛡️ Pedestal " .. s .. ": " .. ST.displayed.ped[s]:gsub("|S", " ✨"), s) end
	if not anyDisp then
		local row = rowFrame(colScroll, 34)
		label(row, UDim2.new(1, -16, 1, 0), UDim2.fromOffset(10, 0), "(belum ada yang dipajang)", Color3.fromRGB(170, 170, 180), 14)
	end
	-- Daftar semua villain
	for _, v in ipairs(CAT.villains) do
		local tier = CAT.tiers[v.tier]
		local c = ST.collection[v.name]
		local n = c and (c.n or 0) or 0
		local s = c and (c.s or 0) or 0
		local found = (n + s) > 0
		local row = rowFrame(colScroll, 64)
		local dot = frame(row, UDim2.fromOffset(16, 16), UDim2.fromOffset(10, 10), rgb(tier.rgb), 0)
		dot.ZIndex = 7
		label(row, UDim2.fromOffset(330, 26), UDim2.fromOffset(34, 4),
			found and v.name or "???", found and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 150), 17)
		label(row, UDim2.fromOffset(330, 22), UDim2.fromOffset(34, 32),
			tier.name .. " • " .. tier.coin .. " koin" .. (found and (" • ×" .. n .. (s > 0 and (" • ✨×" .. s) or "")) or ""),
			rgb(tier.rgb), 13)
		if found then
			local bx = 348
			local function smallBtn(text, color, w, fn)
				local b = button(row, UDim2.fromOffset(w, 26), UDim2.fromOffset(bx, 6), text, color, 12)
				b.ZIndex = 7 bx += w + 5
				b.MouseButton1Click:Connect(fn)
				return b
			end
			local hasNormal = avail(v.name, false) > 0
			local hasShiny = avail(v.name, true) > 0
			if hasNormal or hasShiny then
				smallBtn("Pajang", Color3.fromRGB(80, 110, 190), 62, function()
					act({ type = "display", key = hasNormal and v.name or (v.name .. "|S") })
				end)
				smallBtn("Takhta", Color3.fromRGB(190, 140, 20), 58, function()
					act({ type = "display", key = hasNormal and v.name or (v.name .. "|S"), slot = "throne" })
				end)
				smallBtn("Jual", Color3.fromRGB(60, 140, 90), 46, function()
					act({ type = "sell", key = hasNormal and v.name or (v.name .. "|S") })
				end)
				smallBtn("Gift", Color3.fromRGB(160, 80, 160), 46, function()
					if ST.level < CAT.giftLevel then
						toast("🔒 Gift terbuka di Level " .. CAT.giftLevel .. " (levelmu " .. ST.level .. ")")
					else
						openGiftPicker(hasNormal and v.name or (v.name .. "|S"))
					end
				end)
			end
			if avail(v.name, false) >= 3 and v.tier < 9 then
				local fb = button(row, UDim2.fromOffset(120, 24), UDim2.fromOffset(348, 35),
					"🧬 Fusion (3→naik tier)", Color3.fromRGB(150, 70, 190), 12)
				fb.ZIndex = 7
				fb.MouseButton1Click:Connect(function() act({ type = "fuse", name = v.name }) end)
			end
		end
	end
end

btnCollection.MouseButton1Click:Connect(function()
	colPanel.Visible = not colPanel.Visible
	if colPanel.Visible then refreshCollection() end
end)

--=================== PANEL TOKO ===================
local shopPanel, shopScroll = makePanel("🦾 Toko Cakar", 620, 470)
local shopTab = "coin"
local tabCoinBtn = button(shopPanel, UDim2.fromOffset(150, 34), UDim2.fromOffset(12, 466 - 44), "🪙 Cakar Koin", Color3.fromRGB(90, 90, 120), 15)
local tabRobuxBtn = button(shopPanel, UDim2.fromOffset(150, 34), UDim2.fromOffset(170, 466 - 44), "💎 Cakar Robux", Color3.fromRGB(90, 90, 120), 15)
tabCoinBtn.ZIndex = 6 tabRobuxBtn.ZIndex = 6
tabCoinBtn.MouseButton1Click:Connect(function() shopTab = "coin" refreshShop() end)
tabRobuxBtn.MouseButton1Click:Connect(function() shopTab = "robux" refreshShop() end)

function refreshShop()
	if not ST or not CAT then return end
	tabCoinBtn.BackgroundColor3 = shopTab == "coin" and Color3.fromRGB(60, 130, 80) or Color3.fromRGB(90, 90, 120)
	tabRobuxBtn.BackgroundColor3 = shopTab == "robux" and Color3.fromRGB(60, 130, 80) or Color3.fromRGB(90, 90, 120)
	for _, ch in ipairs(shopScroll:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	for _, claw in ipairs(CAT.claws) do
		local show = (shopTab == "coin" and (claw.kind == "coin" or (claw.kind == "creator" and ST.clawsOwned[claw.id])))
			or (shopTab == "robux" and claw.kind == "robux")
		if show then
			local tier = CAT.tiers[claw.tier]
			local row = rowFrame(shopScroll, 58)
			local dot = frame(row, UDim2.fromOffset(16, 16), UDim2.fromOffset(10, 10), rgb(tier.rgb), 0)
			dot.ZIndex = 7
			label(row, UDim2.fromOffset(300, 26), UDim2.fromOffset(34, 4), claw.name, nil, 17)
			label(row, UDim2.fromOffset(330, 22), UDim2.fromOffset(34, 30),
				"⚡ " .. claw.dig .. " dtk • 🍀 Luck +" .. math.floor(claw.luck * 100) .. "% • 💪 Power " .. claw.power,
				Color3.fromRGB(190, 200, 220), 13)
			local owned = ST.clawsOwned[claw.id]
			local equipped = ST.clawEquipped == claw.id
			if equipped then
				label(row, UDim2.fromOffset(120, 30), UDim2.new(1, -140, 0, 14), "✅ Dipakai", Color3.fromRGB(140, 230, 140), 15)
			elseif owned then
				local b = button(row, UDim2.fromOffset(110, 32), UDim2.new(1, -122, 0, 13), "Pakai", Color3.fromRGB(80, 110, 190), 15)
				b.ZIndex = 7
				local cid = claw.id
				b.MouseButton1Click:Connect(function() act({ type = "equipClaw", id = cid }) end)
			elseif claw.kind == "robux" then
				local passId = CAT.passIds[claw.passKey]
				if passId and passId ~= 0 then
					local b = button(row, UDim2.fromOffset(130, 32), UDim2.new(1, -142, 0, 13),
						"Beli " .. claw.robux .. " R$", Color3.fromRGB(170, 60, 160), 15)
					b.ZIndex = 7
					local cid = claw.id
					b.MouseButton1Click:Connect(function() act({ type = "promptPass", id = cid }) end)
				else
					label(row, UDim2.fromOffset(150, 30), UDim2.new(1, -160, 0, 14), "Segera hadir", Color3.fromRGB(170, 170, 180), 14)
				end
			else
				local b = button(row, UDim2.fromOffset(130, 32), UDim2.new(1, -142, 0, 13),
					"Beli " .. claw.price .. " 🪙", Color3.fromRGB(60, 140, 90), 15)
				b.ZIndex = 7
				local cid = claw.id
				b.MouseButton1Click:Connect(function() act({ type = "buyClaw", id = cid }) end)
			end
		end
	end
end

btnShop.MouseButton1Click:Connect(function()
	shopPanel.Visible = not shopPanel.Visible
	if shopPanel.Visible then refreshShop() end
end)

--=================== PANEL CREATOR ===================
local creatorPanel, creatorScroll = makePanel("👑 Panel Creator", 560, 470)
local function refreshCreator()
	if not CAT then return end
	for _, ch in ipairs(creatorScroll:GetChildren()) do
		if ch:IsA("Frame") then ch:Destroy() end
	end
	local row1 = rowFrame(creatorScroll, 44)
	label(row1, UDim2.fromOffset(180, 30), UDim2.fromOffset(10, 7), "Spawn villain tier:", nil, 15)
	local bx = 170
	for t = 1, 9 do
		local b = button(row1, UDim2.fromOffset(34, 30), UDim2.fromOffset(bx, 7), tostring(t), rgb(CAT.tiers[t].rgb), 14)
		b.ZIndex = 7 bx += 39
		local tt = t
		b.MouseButton1Click:Connect(function() act({ type = "creatorSpawn", tier = tt }) end)
	end
	local row2 = rowFrame(creatorScroll, 44)
	local bc = button(row2, UDim2.fromOffset(170, 30), UDim2.fromOffset(10, 7), "💰 +50.000 Koin", Color3.fromRGB(60, 140, 90), 14)
	bc.ZIndex = 7
	bc.MouseButton1Click:Connect(function() act({ type = "creatorCoins" }) end)
	local bd = button(row2, UDim2.fromOffset(170, 30), UDim2.fromOffset(190, 7), "🌗 Siang / Malam", Color3.fromRGB(80, 90, 160), 14)
	bd.ZIndex = 7
	bd.MouseButton1Click:Connect(function() act({ type = "creatorDayNight" }) end)
	local row3 = rowFrame(creatorScroll, 52)
	local box = Instance.new("TextBox")
	box.Size = UDim2.fromOffset(330, 34) box.Position = UDim2.fromOffset(10, 9)
	box.PlaceholderText = "Tulis pengumuman server…" box.Text = ""
	box.Font = Enum.Font.FredokaOne box.TextSize = 15
	box.BackgroundColor3 = Color3.fromRGB(20, 18, 35) box.TextColor3 = Color3.fromRGB(255, 255, 255)
	box.ZIndex = 7 box.Parent = row3
	local ba = button(row3, UDim2.fromOffset(130, 34), UDim2.fromOffset(350, 9), "📣 Umumkan", Color3.fromRGB(190, 120, 30), 14)
	ba.ZIndex = 7
	ba.MouseButton1Click:Connect(function()
		if #box.Text > 0 then act({ type = "creatorAnnounce", text = box.Text }) box.Text = "" end
	end)
	local rowH = rowFrame(creatorScroll, 36, Color3.fromRGB(50, 45, 70))
	label(rowH, UDim2.new(1, -16, 1, 0), UDim2.fromOffset(10, 0), "Pemain lain — ketuk: teleport ke dia • tombol kanan: beri 10rb koin", Color3.fromRGB(200, 210, 230), 13)
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= player then
			local row = rowFrame(creatorScroll, 42)
			label(row, UDim2.fromOffset(220, 30), UDim2.fromOffset(10, 6), "👤 " .. p.DisplayName, nil, 15)
			local uid = p.UserId
			local bt = button(row, UDim2.fromOffset(130, 28), UDim2.fromOffset(250, 7), "Teleport", Color3.fromRGB(80, 110, 190), 13)
			bt.ZIndex = 7
			bt.MouseButton1Click:Connect(function() act({ type = "creatorTeleport", target = uid }) end)
			local bg2 = button(row, UDim2.fromOffset(130, 28), UDim2.fromOffset(390, 7), "💰 +10rb", Color3.fromRGB(60, 140, 90), 13)
			bg2.ZIndex = 7
			bg2.MouseButton1Click:Connect(function() act({ type = "creatorGive", target = uid }) end)
		end
	end
end
btnCreator.MouseButton1Click:Connect(function()
	creatorPanel.Visible = not creatorPanel.Visible
	if creatorPanel.Visible then refreshCreator() end
end)

--=================== REFRESH & EVENT ===================
local function refreshHUD()
	if not ST or not CAT then return end
	coinsLabel.Text = "🪙 " .. ST.coins
	levelLabel.Text = "⭐ Level " .. ST.level .. (ST.level >= CAT.giftLevel and " • 🎁 Gift ON" or "")
	xpBar.Size = UDim2.fromScale(math.clamp(ST.xp / math.max(1, ST.xpNeed), 0, 1), 1)
	for _, claw in ipairs(CAT.claws) do
		if claw.id == ST.clawEquipped then clawLabel.Text = "🦾 " .. claw.name break end
	end
	btnCreator.Visible = ST.isCreator == true
end

RE_Push.OnClientEvent:Connect(function(state)
	ST = state
	refreshHUD()
	if colPanel.Visible then refreshCollection() end
	if shopPanel.Visible then refreshShop() end
end)

RE_Notify.OnClientEvent:Connect(function(text)
	if text == "__OPEN_SHOP__" then
		shopPanel.Visible = true refreshShop()
	else
		toast(text)
	end
end)

RE_Announce.OnClientEvent:Connect(function(text) bigAnnounce(text) end)

RE_Reveal.OnClientEvent:Connect(function(data)
	local tier = CAT.tiers[data.tier]
	if data.fleeing then
		showBanner(tier.name, rgb(tier.rgb), "🏃 " .. data.name .. " KABUR!", "Tangkap dia sebelum balik ke tanah!", 2.6)
		shakeCamera(0.25, 0.4)
	elseif data.caught then
		showBanner(tier.name, rgb(tier.rgb), (data.shiny and "✨ SHINY " or "") .. data.name,
			"+" .. data.coins .. " koin!", data.tier >= 5 and 4.5 or 3.2)
		if data.tier >= 5 then shakeCamera(0.35, 0.55) end
	end
end)

refreshHUD()
