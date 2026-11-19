--============================================================
-- DIG A VILLAIN! — ServerMain
-- TEMPAT: ServerScriptService (sebagai Script, nama bebas)
-- Semua logika server game ada di file ini.
--============================================================

--=================== KONFIGURASI (EDIT DI SINI) ===================
local CONFIG = {
	OwnerUserId = 0,          -- << ISI UserID Roblox KAMU di sini (angka). Selama 0, perk creator nonaktif.
	CreatorName = "Sang Creator", -- nama yang tampil di patung & pengumuman
	PassIds = {               -- << ISI ID Game Pass setelah pass dibuat di Creator Dashboard (0 = belum ada, tombol beli disembunyikan)
		Bloodmoon = 0,
		Galaxy = 0,
		Nameless = 0,
	},
	UseDataStore = true,      -- simpan progres pemain (aktif setelah game dipublish & API Studio dinyalakan)
	MaxPlayersNote = "Set Max Players = 12 di Game Settings agar semua pemain kebagian home.",
}
--==================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")
local MarketplaceService = game:GetService("MarketplaceService")
local Lighting = game:GetService("Lighting")

math.randomseed(os.time())

--=================== DATA: TIER VILLAIN ===================
-- weight = peluang dasar (total 100), coin = hadiah koin, xp = hadiah XP
local TIERS = {
	{ name = "COMMON",    rgb = {170,170,170}, weight = 31,  coin = 10,    xp = 5   },
	{ name = "UNCOMMON",  rgb = {90,200,90},   weight = 24,  coin = 25,    xp = 8   },
	{ name = "RARE",      rgb = {60,130,255},  weight = 17,  coin = 60,    xp = 15  },
	{ name = "EPIC",      rgb = {170,80,255},  weight = 11,  coin = 150,   xp = 30  },
	{ name = "LEGENDARY", rgb = {255,190,0},   weight = 7.5, coin = 400,   xp = 60  },
	{ name = "MYTHIC",    rgb = {255,60,60},   weight = 4.5, coin = 1000,  xp = 120 },
	{ name = "DIVINE",    rgb = {255,240,200}, weight = 2.7, coin = 2500,  xp = 200 },
	{ name = "COSMIC",    rgb = {200,80,255},  weight = 1.5, coin = 6000,  xp = 350 },
	{ name = "404",   rgb = {40,40,40},    weight = 0.8, coin = 15000, xp = 600 },
}
local function tierColor(i) local c = TIERS[i].rgb return Color3.fromRGB(c[1], c[2], c[3]) end

-- Skala ukuran tubuh villain per tier (makin langka = makin raksasa)
local TIER_SCALE = { 0.8, 0.9, 1.0, 1.15, 1.35, 1.55, 1.8, 2.1, 2.5 }
local function villainScale(def, shiny)
	local s = TIER_SCALE[def.tier]
	if shiny then s = s * 1.1 end
	return s
end

--=================== DATA: VILLAIN (22) ===================
-- body = warna tubuh RGB. Aksesori ditentukan tier (lihat buildVillainModel).
local VILLAINS = {
	{ name = "Grave Imp",                    tier = 1, body = {120,120,120} },
	{ name = "Ash Stalker",                  tier = 1, body = {100,100,112} },
	{ name = "Rotfang",                      tier = 1, body = {110,130,100} },
	{ name = "Crypt Raider",                 tier = 2, body = {80,160,80}   },
	{ name = "Shadow Prowler",               tier = 2, body = {60,140,90}   },
	{ name = "Bone Collector",               tier = 2, body = {205,205,195} },
	{ name = "Night Howler",                 tier = 3, body = {50,100,220}  },
	{ name = "Venom Duchess",                tier = 3, body = {40,180,120}  },
	{ name = "Iron Jailer",                  tier = 3, body = {95,95,105}   },
	{ name = "Dread Knight",                 tier = 4, body = {120,50,200}  },
	{ name = "Soul Harvester",               tier = 4, body = {90,40,160}   },
	{ name = "Crimson Executioner",          tier = 4, body = {160,40,60}   },
	{ name = "Lord Malachar",                tier = 5, body = {220,170,0}   },
	{ name = "Nyx, Queen of the Hollow",     tier = 5, body = {45,45,65}    },
	{ name = "Azgorath, Devourer of Tombs",  tier = 6, body = {200,40,30}   },
	{ name = "Morvain the Deathless",        tier = 6, body = {150,150,160} },
	{ name = "Serath the Fallen Seraph",     tier = 7, body = {240,230,200} },
	{ name = "Malachai, Herald of Ruin",     tier = 7, body = {230,200,120} },
	{ name = "Xathra the Voidmother",        tier = 8, body = {80,20,120}   },
	{ name = "N'Zhal, Eater of Stars",       tier = 8, body = {25,25,45}    },
	{ name = "HE WHO WAITS BELOW",           tier = 9, body = {15,15,15}    },
}
-- Tambahan roster: total keseluruhan 60 villain
local EXTRA_VILLAINS = {
	{ name = "Tomb Rat",                     tier = 1, body = {105,95,90}   },
	{ name = "Carrion Imp",                  tier = 1, body = {130,115,80}  },
	{ name = "Grave Crawler",                tier = 1, body = {95,110,95}   },
	{ name = "Dusk Lurker",                  tier = 1, body = {85,85,100}   },
	{ name = "Rot Zombie",                   tier = 1, body = {120,140,105} },
	{ name = "Pit Hound",                    tier = 1, body = {115,90,75}   },
	{ name = "Mud Fiend",                    tier = 1, body = {125,100,70}  },
	{ name = "Bone Gnawer",                  tier = 1, body = {180,175,160} },
	{ name = "Sewer Ghoul",                  tier = 1, body = {100,125,110} },
	{ name = "Crypt Warden",                 tier = 2, body = {70,150,90}   },
	{ name = "Shadow Thief",                 tier = 2, body = {55,120,80}   },
	{ name = "Grave Witch",                  tier = 2, body = {90,170,110}  },
	{ name = "Iron Ghoul",                   tier = 2, body = {130,135,140} },
	{ name = "Plague Bearer",                tier = 2, body = {140,175,80}  },
	{ name = "Soul Snatcher",                tier = 2, body = {65,155,130}  },
	{ name = "Marsh Hag",                    tier = 2, body = {85,145,100}  },
	{ name = "Blood Countess",               tier = 3, body = {170,40,70}   },
	{ name = "Headless Rider",               tier = 3, body = {60,60,80}    },
	{ name = "Crypt Assassin",               tier = 3, body = {45,90,200}   },
	{ name = "Storm Witch",                  tier = 3, body = {80,140,230}  },
	{ name = "Obsidian Golem",               tier = 3, body = {50,50,60}    },
	{ name = "Wraith Captain",               tier = 3, body = {140,190,230} },
	{ name = "Doom Herald",                  tier = 4, body = {140,60,190}  },
	{ name = "Void Knight",                  tier = 4, body = {70,30,130}   },
	{ name = "Doctor Pestilence",            tier = 4, body = {100,160,120} },
	{ name = "The Iron Maiden",              tier = 4, body = {150,150,160} },
	{ name = "Nightmare Duchess",            tier = 4, body = {130,40,170}  },
	{ name = "Emperor Vane the Cruel",       tier = 5, body = {200,150,30}  },
	{ name = "Sylvara, Queen of Thorns",     tier = 5, body = {60,140,60}   },
	{ name = "Grimaldus the Undying King",   tier = 5, body = {190,185,170} },
	{ name = "Lady Vesper, the Widow Queen", tier = 5, body = {80,60,110}   },
	{ name = "Lilith, Mother of Graves",     tier = 6, body = {170,30,90}   },
	{ name = "Fenris the Chainbreaker",      tier = 6, body = {110,110,125} },
	{ name = "Zarathos, Flame of the Pit",   tier = 6, body = {230,110,30}  },
	{ name = "Azrael the Death Angel",       tier = 7, body = {200,200,215} },
	{ name = "Uriel the Fallen Flame",       tier = 7, body = {245,180,90}  },
	{ name = "Sagraath, the Star-Eater Maw", tier = 8, body = {100,30,150}  },
	{ name = "KHA'ZURATH, EATER OF NAMES",   tier = 9, body = {40,20,25}    },
	{ name = "THE HOLLOW GOD",               tier = 9, body = {30,30,40}    },
}
for _, v in ipairs(EXTRA_VILLAINS) do table.insert(VILLAINS, v) end
table.sort(VILLAINS, function(a, b) return a.tier < b.tier end)

local VILLAIN_BY_NAME = {}
for _, v in ipairs(VILLAINS) do VILLAIN_BY_NAME[v.name] = v end

--=================== DATA: TANAH (5 zona) ===================
-- needClaw = indeks cakar minimum (dari daftar CLAWS koin) untuk bisa menggali
-- boost = pengali peluang untuk tier >= boostFrom
local SOILS = {
	{ name = "Tanah Lunak", rgb = {150,110,70},  needClaw = 1, digMult = 1.0, boostFrom = 99, boost = 1  },
	{ name = "Tanah Keras", rgb = {110,75,45},   needClaw = 3, digMult = 1.3, boostFrom = 4,  boost = 2  },
	{ name = "Tanah Batu",  rgb = {120,120,125}, needClaw = 4, digMult = 1.6, boostFrom = 4,  boost = 3  },
	{ name = "Tanah Magma", rgb = {70,35,35},    needClaw = 6, digMult = 2.0, boostFrom = 5,  boost = 5  },
	{ name = "Tanah Void",  rgb = {45,25,70},    needClaw = 8, digMult = 2.5, boostFrom = 9,  boost = 10 },
}

--=================== DATA: CAKAR ===================
-- kind: "coin" (beli pakai koin) | "robux" (Game Pass) | "creator" (khusus pemilik game)
-- power = tier tanah tertinggi yang bisa digali (1..5)
local CLAWS = {
	{ id = "rusty",    name = "Rusty Claw",        tier = 1, kind = "coin", price = 0,      dig = 3.0, luck = 0.00, power = 1 },
	{ id = "iron",     name = "Iron Claw",         tier = 2, kind = "coin", price = 150,    dig = 2.6, luck = 0.02, power = 1 },
	{ id = "steel",    name = "Steel Claw",        tier = 3, kind = "coin", price = 600,    dig = 2.2, luck = 0.05, power = 2 },
	{ id = "obsidian", name = "Obsidian Claw",     tier = 4, kind = "coin", price = 2000,   dig = 1.8, luck = 0.09, power = 3 },
	{ id = "royal",    name = "Royal Gold Claw",   tier = 5, kind = "coin", price = 6000,   dig = 1.5, luck = 0.14, power = 3 },
	{ id = "dragon",   name = "Dragon Claw",       tier = 6, kind = "coin", price = 15000,  dig = 1.2, luck = 0.20, power = 4 },
	{ id = "seraphim", name = "Seraphim Claw",     tier = 7, kind = "coin", price = 40000,  dig = 1.0, luck = 0.27, power = 4 },
	{ id = "void",     name = "Void Ripper",       tier = 8, kind = "coin", price = 100000, dig = 0.8, luck = 0.35, power = 5 },
	{ id = "nameless", name = "The Nameless Claw", tier = 9, kind = "coin", price = 250000, dig = 0.6, luck = 0.50, power = 5 },
	{ id = "bloodmoon", name = "Bloodmoon Claw",   tier = 6, kind = "robux", robux = 199, passKey = "Bloodmoon", dig = 1.0, luck = 0.30, power = 4 },
	{ id = "galaxy",    name = "Galaxy Ripper",    tier = 8, kind = "robux", robux = 499, passKey = "Galaxy",    dig = 0.7, luck = 0.45, power = 5 },
	{ id = "godhand",   name = "Hand of the Nameless", tier = 9, kind = "robux", robux = 999, passKey = "Nameless", dig = 0.5, luck = 0.60, power = 5 },
	{ id = "creator",   name = "Creator's Hand",   tier = 9, kind = "creator", dig = 0.3, luck = 1.00, power = 5 },
}
local CLAW_BY_ID = {}
for _, c in ipairs(CLAWS) do CLAW_BY_ID[c.id] = c end

-- Gelar untuk kelengkapan koleksi per tier
local TITLES = { "Pemburu Pemula", "Penggali Ulung", "Pemburu Langka", "Pemburu Epik", "Pemburu Legenda",
	"Pemburu Mitos", "Pemburu Dewa", "Pemburu Kosmik", "Penakluk 404" }

local GIFT_UNLOCK_LEVEL = 10
local GIFT_COOLDOWN = 60
local PLOT_RESPAWN = 15
local FLEE_TIERS = 6        -- tier >= ini villainnya kabur & harus ditangkap
local FLEE_TIME = 10

--=================== REMOTES ===================
local function makeRemote(class, name)
	local r = Instance.new(class) r.Name = name r.Parent = ReplicatedStorage return r
end
local RE_Notify   = makeRemote("RemoteEvent", "DAV_Notify")    -- server -> 1 client: toast
local RE_Reveal   = makeRemote("RemoteEvent", "DAV_Reveal")    -- server -> 1 client: banner reveal
local RE_Announce = makeRemote("RemoteEvent", "DAV_Announce")  -- server -> semua: pengumuman besar
local RE_Push     = makeRemote("RemoteEvent", "DAV_Push")      -- server -> 1 client: state terbaru
local RE_Action   = makeRemote("RemoteEvent", "DAV_Action")    -- client -> server: aksi GUI
local RF_State    = makeRemote("RemoteFunction", "DAV_State")  -- client -> server: ambil katalog + state

local function notify(player, text) RE_Notify:FireClient(player, text) end
local function announce(text) RE_Announce:FireAllClients(text) end
local function isCreator(player) return CONFIG.OwnerUserId ~= 0 and player.UserId == CONFIG.OwnerUserId end

--=================== DATA PEMAIN ===================
local function defaultData()
	return {
		coins = 0, xp = 0, level = 1, totalDigs = 0,
		clawsOwned = { rusty = true }, clawEquipped = "rusty",
		collection = {},              -- [namaVillain] = { n = jumlah normal, s = jumlah shiny }
		displayed = { ped = {}, throne = nil }, -- key villain: "Nama" atau "Nama|S" (shiny)
		completedTiers = {},          -- [tier] = true
		giftReadyAt = 0,
	}
end

local playerData = {}   -- [player] = data
local playerHome = {}   -- [player] = homeIndex

local function xpNeed(level) return 50 * level end

local function colCount(data, name)
	local c = data.collection[name]
	if not c then return 0, 0 end
	return c.n or 0, c.s or 0
end

local function displayedCount(data, key)
	local n = 0
	for _, k in pairs(data.displayed.ped) do if k == key then n += 1 end end
	if data.displayed.throne == key then n += 1 end
	return n
end

local function availableCount(data, name, shiny)
	local n, s = colCount(data, name)
	local total = shiny and s or n
	return total - displayedCount(data, shiny and (name .. "|S") or name)
end

local function addXP(player, amount)
	local data = playerData[player] if not data then return end
	if isCreator(player) then amount = amount * 5 end
	data.xp += amount
	while data.xp >= xpNeed(data.level) do
		data.xp -= xpNeed(data.level)
		data.level += 1
		notify(player, "🎉 LEVEL UP! Kamu sekarang Level " .. data.level ..
			(data.level == GIFT_UNLOCK_LEVEL and " — Fitur GIFT villain TERBUKA!" or ""))
		updateOverhead(player)
	end
end

local function addCoins(player, amount)
	local data = playerData[player] if not data then return end
	if isCreator(player) then amount = amount * 5 end
	data.coins += amount
	local ls = player:FindFirstChild("leaderstats")
	if ls and ls:FindFirstChild("Koin") then ls.Koin.Value = data.coins end
end

function checkTierCompletion(player, tier)
	local data = playerData[player] if not data then return end
	if data.completedTiers[tier] then return end
	for _, v in ipairs(VILLAINS) do
		if v.tier == tier then
			local n, s = colCount(data, v.name)
			if n + s == 0 then return end
		end
	end
	data.completedTiers[tier] = true
	local bonus = 500 * tier * tier
	data.coins += bonus
	local ls = player:FindFirstChild("leaderstats")
	if ls and ls:FindFirstChild("Koin") then ls.Koin.Value = data.coins end
	notify(player, "🏆 KOLEKSI TIER " .. TIERS[tier].name .. " LENGKAP! Bonus +" .. bonus ..
		" koin & gelar baru: " .. TITLES[tier])
	updateOverhead(player)
end

-- State yang dikirim ke client (GUI)
local function snapshot(player)
	local data = playerData[player] if not data then return nil end
	return {
		coins = data.coins, xp = data.xp, level = data.level, xpNeed = xpNeed(data.level),
		totalDigs = data.totalDigs,
		clawsOwned = data.clawsOwned, clawEquipped = data.clawEquipped,
		collection = data.collection, displayed = data.displayed,
		completedTiers = data.completedTiers,
		isCreator = isCreator(player),
		giftLeft = math.max(0, data.giftReadyAt - os.time()),
	}
end

local function pushState(player)
	local s = snapshot(player)
	if s then RE_Push:FireClient(player, s) end
end

local function catalog()
	return { tiers = TIERS, villains = VILLAINS, claws = CLAWS, soils = SOILS,
		titles = TITLES, giftLevel = GIFT_UNLOCK_LEVEL, passIds = CONFIG.PassIds }
end

RF_State.OnServerInvoke = function(player)
	return { catalog = catalog(), state = snapshot(player) }
end

--=================== PEMBANGUN DUNIA ===================
local world = Instance.new("Folder") world.Name = "DAV_World" world.Parent = workspace

local function part(parent, size, pos, color, material, name)
	local p = Instance.new("Part")
	p.Size = size p.Position = pos p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = true p.TopSurface = Enum.SurfaceType.Smooth p.BottomSurface = Enum.SurfaceType.Smooth
	if name then p.Name = name end
	p.Parent = parent
	return p
end

local function sign(parent, size, pos, text, textColor, bgColor, fontSize)
	local p = part(parent, size, pos, bgColor or Color3.fromRGB(40, 32, 55), Enum.Material.SmoothPlastic)
	local gui = Instance.new("SurfaceGui") gui.Face = Enum.NormalId.Front gui.Parent = p
	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1) label.BackgroundTransparency = 1
	label.Text = text label.TextColor3 = textColor or Color3.fromRGB(255, 255, 255)
	label.Font = Enum.Font.FredokaOne label.TextScaled = true
	label.Parent = gui
	return p
end

-- Tanah dasar & plaza
part(world, Vector3.new(260, 2, 260), Vector3.new(0, -1, 0), Color3.fromRGB(88, 148, 74), Enum.Material.Grass, "Ground")
part(world, Vector3.new(46, 0.4, 46), Vector3.new(0, 0.2, 30), Color3.fromRGB(150, 145, 140), Enum.Material.Cobblestone, "Plaza")

local spawn = Instance.new("SpawnLocation")
spawn.Size = Vector3.new(8, 1, 8) spawn.Position = Vector3.new(0, 0.7, 38)
spawn.Color = Color3.fromRGB(60, 50, 90) spawn.Anchored = true spawn.Neutral = true
spawn.Parent = world

sign(world, Vector3.new(30, 7, 1), Vector3.new(0, 6, 16), "⛏️ DIG A VILLAIN! 👑",
	Color3.fromRGB(255, 210, 60), Color3.fromRGB(35, 25, 60))
sign(world, Vector3.new(24, 5, 1), Vector3.new(-20, 4.5, 20),
	"GALI TANAHNYA…\nVILLAIN-NYA RAHASIA!", Color3.fromRGB(255, 255, 255), Color3.fromRGB(70, 45, 30))

-- Papan peringkat
local board = sign(world, Vector3.new(20, 11, 1), Vector3.new(17, 6.5, 17), "🏆 PAPAN PERINGKAT",
	Color3.fromRGB(255, 255, 255), Color3.fromRGB(30, 30, 45))
local boardLabel = board:FindFirstChildOfClass("SurfaceGui"):FindFirstChildOfClass("TextLabel")
boardLabel.TextScaled = false boardLabel.TextSize = 26 boardLabel.TextYAlignment = Enum.TextYAlignment.Top

-- Patung creator
do
	local base = part(world, Vector3.new(6, 2, 6), Vector3.new(-14, 1.2, 30), Color3.fromRGB(120, 110, 130), Enum.Material.Marble)
	local statue = Instance.new("Model") statue.Name = "CreatorStatue" statue.Parent = world
	part(statue, Vector3.new(1, 2.4, 1), Vector3.new(-14.8, 3.4, 30), Color3.fromRGB(255, 190, 0), Enum.Material.Metal)
	part(statue, Vector3.new(1, 2.4, 1), Vector3.new(-13.2, 3.4, 30), Color3.fromRGB(255, 190, 0), Enum.Material.Metal)
	part(statue, Vector3.new(2.6, 2.6, 1.2), Vector3.new(-14, 6, 30), Color3.fromRGB(255, 200, 40), Enum.Material.Metal)
	part(statue, Vector3.new(2.8, 0.8, 1.3), Vector3.new(-14, 7.7, 30), Color3.fromRGB(255, 215, 0), Enum.Material.Metal) -- mahkota
	part(statue, Vector3.new(1.6, 1.6, 1.6), Vector3.new(-14, 8.6, 30), Color3.fromRGB(255, 220, 90), Enum.Material.Metal)
	sign(world, Vector3.new(10, 2.4, 0.6), Vector3.new(-14, 1.6, 26.6),
		"👑 " .. CONFIG.CreatorName .. " 👑\nPembuat Game Ini", Color3.fromRGB(255, 220, 90), Color3.fromRGB(45, 35, 15))
end

-- Stand toko (klik / pencet E untuk membuka toko)
local shopPart = part(world, Vector3.new(6, 4, 6), Vector3.new(12, 2.2, 34), Color3.fromRGB(140, 90, 40), Enum.Material.Wood, "ShopStand")
sign(world, Vector3.new(10, 3, 0.6), Vector3.new(12, 6.5, 31), "🦾 TOKO CAKAR", Color3.fromRGB(120, 220, 255), Color3.fromRGB(30, 40, 60))
local shopPrompt = Instance.new("ProximityPrompt")
shopPrompt.ActionText = "Buka Toko" shopPrompt.ObjectText = "Toko Cakar"
shopPrompt.HoldDuration = 0 shopPrompt.MaxActivationDistance = 12
shopPrompt.Parent = shopPart

--=================== MODEL VILLAIN ===================
local glowModels = {} -- model-model yang jubahnya berganti warna pelangi (SHINY)
local darkGlowModels = {} -- model tier 404: aura gelap berdenyut (ungu pekat menyala)

local function bodyColorOf(def, shiny)
	if shiny then return Color3.fromRGB(255, 205, 40) end
	return Color3.fromRGB(def.body[1], def.body[2], def.body[3])
end

-- Membangun model villain sederhana dari Part. opts: { shiny=bool, scale=number }
function buildVillainModel(def, opts)
	opts = opts or {}
	local shiny = opts.shiny or false
	local s = opts.scale or villainScale(def, shiny)
	local model = Instance.new("Model") model.Name = def.name
	local bc = bodyColorOf(def, shiny)
	local dark = Color3.fromRGB(35, 35, 45)
	local function mp(size, offset, color, material)
		local p = Instance.new("Part")
		p.Size = size * s p.Color = color p.Material = material or Enum.Material.SmoothPlastic
		p.Anchored = true p.CanCollide = false
		p.CFrame = CFrame.new(offset * s)
		p.Parent = model
		return p
	end
	mp(Vector3.new(0.85, 1.1, 0.85), Vector3.new(-0.5, 0.55, 0), dark)            -- kaki kiri
	mp(Vector3.new(0.85, 1.1, 0.85), Vector3.new(0.5, 0.55, 0), dark)             -- kaki kanan
	local torso = mp(Vector3.new(2, 2, 1), Vector3.new(0, 2.1, 0), bc)            -- badan
	mp(Vector3.new(0.8, 2, 0.8), Vector3.new(-1.45, 2.1, 0), bc)                  -- lengan kiri
	mp(Vector3.new(0.8, 2, 0.8), Vector3.new(1.45, 2.1, 0), bc)                   -- lengan kanan
	mp(Vector3.new(1.3, 1.3, 1.3), Vector3.new(0, 3.75, 0), Color3.fromRGB(255, 204, 153)) -- kepala
	mp(Vector3.new(0.22, 0.22, 0.1), Vector3.new(-0.3, 3.85, -0.68), Color3.fromRGB(20, 20, 20)) -- mata
	mp(Vector3.new(0.22, 0.22, 0.1), Vector3.new(0.3, 3.85, -0.68), Color3.fromRGB(20, 20, 20))
	local tier = def.tier
	local gold = Color3.fromRGB(255, 195, 0)
	if tier == 2 or tier == 3 then
		mp(Vector3.new(1.5, 0.35, 1.5), Vector3.new(0, 4.55, 0), tierColor(tier)) -- topi/helm
	elseif tier == 4 or tier == 6 or tier == 8 then
		mp(Vector3.new(0.35, 0.9, 0.35), Vector3.new(-0.65, 4.8, 0), dark)        -- tanduk
		mp(Vector3.new(0.35, 0.9, 0.35), Vector3.new(0.65, 4.8, 0), dark)
	elseif tier == 5 or tier == 9 then
		mp(Vector3.new(1.6, 0.5, 1.6), Vector3.new(0, 4.6, 0), tier == 9 and dark or gold) -- mahkota
		mp(Vector3.new(0.3, 0.5, 0.3), Vector3.new(-0.6, 4.95, 0), tier == 9 and dark or gold)
		mp(Vector3.new(0.3, 0.5, 0.3), Vector3.new(0, 5.05, 0), tier == 9 and dark or gold)
		mp(Vector3.new(0.3, 0.5, 0.3), Vector3.new(0.6, 4.95, 0), tier == 9 and dark or gold)
	elseif tier == 7 then
		mp(Vector3.new(1.7, 1.1, 0.25), Vector3.new(-1.6, 3.4, 0.45), Color3.fromRGB(245, 240, 225)) -- sayap
		mp(Vector3.new(1.7, 1.1, 0.25), Vector3.new(1.6, 3.4, 0.45), Color3.fromRGB(245, 240, 225))
	end
	if tier >= 6 then
		local cape = mp(Vector3.new(2.1, 2.6, 0.2), Vector3.new(0, 2.2, 0.65),
			tier == 9 and Color3.fromRGB(255, 0, 128) or tierColor(tier), Enum.Material.Neon)
		cape.Name = "Cape"
	end
	-- Aura untuk SEMUA villain: cincin cahaya di kaki + cahaya warna tier (makin tinggi tier makin kuat)
	local ring = mp(Vector3.new(0.15, 3.4, 3.4), Vector3.new(0, 0.12, 0),
		shiny and Color3.fromRGB(255, 210, 60) or tierColor(tier), Enum.Material.Neon)
	ring.Shape = Enum.PartType.Cylinder
	ring.CFrame = CFrame.new(0, 0.12 * s, 0) * CFrame.Angles(0, 0, math.pi / 2)
	ring.Transparency = 0.35
	ring.Name = "AuraRing"
	local light = Instance.new("PointLight")
	light.Color = shiny and Color3.fromRGB(255, 210, 60) or tierColor(tier)
	light.Range = 6 + tier light.Brightness = 0.5 + tier * 0.18 light.Parent = torso
	if tier >= 4 then
		local sp = Instance.new("Sparkles")
		sp.SparkleColor = shiny and Color3.fromRGB(255, 215, 0) or tierColor(tier)
		sp.Parent = torso
	end
	if tier == 9 and not shiny then
		-- Aura khusus 404: GELAP tapi MENYALA — asap hitam-ungu naik dari tubuh + cahaya ungu pekat
		ring.Color = Color3.fromRGB(60, 0, 90) ring.Transparency = 0.25
		light.Color = Color3.fromRGB(150, 60, 255) light.Brightness = 2.2 light.Range = 13
		local smoke = Instance.new("ParticleEmitter")
		smoke.Name = "DarkAura"
		smoke.Texture = "rbxasset://textures/particles/smoke_main.dds"
		smoke.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 8, 25)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(90, 0, 130)),
		})
		smoke.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0.55),
			NumberSequenceKeypoint.new(0.5, 0.35),
			NumberSequenceKeypoint.new(1, 1),
		})
		smoke.Size = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 2.2),
			NumberSequenceKeypoint.new(1, 4.5),
		})
		smoke.Rate = 16 smoke.Lifetime = NumberRange.new(1.2, 2.2)
		smoke.Speed = NumberRange.new(1.5, 3) smoke.SpreadAngle = Vector2.new(180, 180)
		smoke.Parent = torso
	end
	if shiny then table.insert(glowModels, model)
	elseif tier == 9 then table.insert(darkGlowModels, model) end
	model.PrimaryPart = torso
	return model
end

-- Papan nama di atas model villain (dipakai saat reveal & pajangan)
local function namePlate(model, def, shiny, scale)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromScale(7, 2.2) gui.StudsOffset = Vector3.new(0, 3.6 * (scale or 1), 0)
	gui.AlwaysOnTop = true
	local l1 = Instance.new("TextLabel")
	l1.Size = UDim2.fromScale(1, 0.55) l1.BackgroundTransparency = 1
	l1.Text = (shiny and "✨ SHINY " or "") .. def.name
	l1.TextColor3 = Color3.fromRGB(255, 255, 255) l1.Font = Enum.Font.FredokaOne
	l1.TextScaled = true l1.Parent = gui
	local l2 = Instance.new("TextLabel")
	l2.Size = UDim2.fromScale(1, 0.45) l2.Position = UDim2.fromScale(0, 0.55)
	l2.BackgroundTransparency = 1
	l2.Text = TIERS[def.tier].name l2.TextColor3 = tierColor(def.tier)
	l2.Font = Enum.Font.FredokaOne l2.TextScaled = true l2.Parent = gui
	gui.Adornee = model.PrimaryPart
	gui.Parent = model
end

-- Loop warna pelangi untuk model SHINY + denyut aura gelap untuk model 404
task.spawn(function()
	local hue = 0
	while true do
		hue = (hue + 0.02) % 1
		for i = #glowModels, 1, -1 do
			local m = glowModels[i]
			if not m.Parent then table.remove(glowModels, i)
			else
				local cape = m:FindFirstChild("Cape")
				if cape then cape.Color = Color3.fromHSV(hue, 0.85, 1) end
				local ring = m:FindFirstChild("AuraRing")
				if ring then ring.Color = Color3.fromHSV(hue, 0.85, 1) end
			end
		end
		-- Aura 404 berdenyut: ungu pekat yang menyala-memudar seperti napas
		local pulse = 0.25 + 0.75 * (0.5 + 0.5 * math.sin(os.clock() * 2.4))
		local dark = Color3.fromHSV(0.78, 0.9, pulse)
		for i = #darkGlowModels, 1, -1 do
			local m = darkGlowModels[i]
			if not m.Parent then table.remove(darkGlowModels, i)
			else
				local ring = m:FindFirstChild("AuraRing")
				if ring then ring.Color = dark end
				local cape = m:FindFirstChild("Cape")
				if cape then cape.Color = dark end
			end
		end
		task.wait(0.15)
	end
end)

--=================== ZONA TANAH & PETAK ===================
local plots = {}
local zoneLayout = { -- { jumlah petak, posisi tengah zona }
	{ count = 12, center = Vector3.new(-52, 0, -18) },
	{ count = 10, center = Vector3.new(0, 0, -52) },
	{ count = 8,  center = Vector3.new(52, 0, -18) },
	{ count = 6,  center = Vector3.new(30, 0, -88) },
	{ count = 4,  center = Vector3.new(-30, 0, -88) },
}
for zi, zl in ipairs(zoneLayout) do
	local soil = SOILS[zi]
	local zoneFolder = Instance.new("Folder") zoneFolder.Name = "Zone" .. zi zoneFolder.Parent = world
	part(zoneFolder, Vector3.new(38, 0.5, 30), zl.center + Vector3.new(0, 0.05, 0),
		Color3.fromRGB(soil.rgb[1], soil.rgb[2], soil.rgb[3]), Enum.Material.Ground, "ZoneFloor")
	local s = sign(zoneFolder, Vector3.new(16, 4.5, 0.8), zl.center + Vector3.new(0, 4, 16.5),
		soil.name .. (zi > 1 and ("\nButuh: " .. CLAWS[soil.needClaw].name .. "+") or ""),
		Color3.fromRGB(255, 255, 255), Color3.fromRGB(soil.rgb[1] // 2, soil.rgb[2] // 2, soil.rgb[3] // 2))
	local cols = math.ceil(math.sqrt(zl.count * 1.4))
	local idx = 0
	for row = 0, 9 do
		for col = 0, cols - 1 do
			if idx >= zl.count then break end
			idx += 1
			local pos = zl.center + Vector3.new((col - (cols - 1) / 2) * 8, 0, (row - 1.5) * 8)
			local baseP = part(zoneFolder, Vector3.new(6.6, 0.8, 6.6), pos + Vector3.new(0, 0.45, 0),
				Color3.fromRGB(soil.rgb[1], soil.rgb[2], soil.rgb[3]), Enum.Material.Ground)
			local mound = part(zoneFolder, Vector3.new(5.4, 1.1, 5.4), pos + Vector3.new(0, 1.35, 0),
				Color3.fromRGB(math.min(255, soil.rgb[1] + 25), math.min(255, soil.rgb[2] + 20), math.min(255, soil.rgb[3] + 15)),
				Enum.Material.Ground, "Mound")
			local prompt = Instance.new("ProximityPrompt")
			prompt.ActionText = "Gali!" prompt.ObjectText = soil.name
			prompt.HoldDuration = 0 prompt.MaxActivationDistance = 10
			prompt.Parent = mound
			local plot = { zone = zi, pos = pos + Vector3.new(0, 0.85, 0), mound = mound, base = baseP,
				prompt = prompt, state = "ready", golden = false }
			table.insert(plots, plot)
			prompt.Triggered:Connect(function(player) onDigStart(player, plot) end)
		end
		if idx >= zl.count then break end
	end
end

--=================== HOME PEMAIN ===================
local HOMES = 12
local homes = {}
for i = 1, HOMES do
	local angle = (i - 1) / HOMES * math.pi * 2
	local cx = math.cos(angle) * 108
	local cz = -10 + math.sin(angle) * 100
	local folder = Instance.new("Folder") folder.Name = "Home" .. i folder.Parent = world
	local center = Vector3.new(cx, 0, cz)
	part(folder, Vector3.new(34, 0.6, 30), center + Vector3.new(0, 0.3, 0),
		Color3.fromRGB(105, 100, 115), Enum.Material.Slate, "HomeFloor")
	local signP = sign(folder, Vector3.new(14, 3.4, 0.6), center + Vector3.new(0, 3, 15.2),
		"🏠 Home Kosong", Color3.fromRGB(255, 255, 255), Color3.fromRGB(60, 55, 75))
	local signLabel = signP:FindFirstChildOfClass("SurfaceGui"):FindFirstChildOfClass("TextLabel")
	-- Posisi pedestal (relatif ke tengah home): 8 standar + 8 ekstra khusus creator + takhta
	local pedPos = {}
	for r = 0, 1 do for c = 0, 3 do
		table.insert(pedPos, Vector3.new(-9 + c * 6, 0, -6 + r * 6))
	end end
	for c = 0, 7 do table.insert(pedPos, Vector3.new(-10.5 + c * 3, 0, 7)) end
	local peds = {}
	for pi, off in ipairs(pedPos) do
		local pp = part(folder, Vector3.new(2.4, 1.6, 2.4), center + off + Vector3.new(0, 0.8, 0),
			Color3.fromRGB(130, 125, 140), Enum.Material.Marble, "Ped" .. pi)
		pp:SetAttribute("HomeIndex", i) pp:SetAttribute("Slot", pi)
		peds[pi] = pp
	end
	local throne = part(folder, Vector3.new(4.5, 2.6, 4.5), center + Vector3.new(0, 1.3, -12),
		Color3.fromRGB(255, 190, 0), Enum.Material.Metal, "Throne")
	homes[i] = { folder = folder, center = center, signLabel = signLabel, peds = peds,
		throne = throne, owner = nil, displayFolder = nil }
	local df = Instance.new("Folder") df.Name = "Displays" df.Parent = folder
	homes[i].displayFolder = df
end

local function placeModel(model, groundPos, scale)
	local s = scale or 1
	model:PivotTo(CFrame.new(groundPos.X, groundPos.Y + 2.1 * s, groundPos.Z))
end

-- Bangun ulang pajangan villain di home seorang pemain dari datanya
local function refreshHome(player)
	local data = playerData[player] local hi = playerHome[player]
	if not data or not hi then return end
	local home = homes[hi]
	home.displayFolder:ClearAllChildren()
	local function spawnDisplay(key, groundPos, baseScale, cap)
		if not key then return end
		local shiny = key:sub(-2) == "|S"
		local name = shiny and key:sub(1, -3) or key
		local def = VILLAIN_BY_NAME[name] if not def then return end
		local scale = math.min(baseScale * villainScale(def, shiny), cap)
		local model = buildVillainModel(def, { shiny = shiny, scale = scale })
		namePlate(model, def, shiny, scale)
		model.Parent = home.displayFolder
		placeModel(model, groundPos, scale)
	end
	local maxPed = isCreator(player) and 16 or 8
	for slot, key in pairs(data.displayed.ped) do
		if slot <= maxPed and home.peds[slot] then
			spawnDisplay(key, home.peds[slot].Position + Vector3.new(0, 1.6, 0), 0.8, 1.6)
		end
	end
	if data.displayed.throne then
		spawnDisplay(data.displayed.throne, home.throne.Position + Vector3.new(0, 2.6, 0), 1.15, 2.3)
	end
end

-- Penghasilan pasif dari penjaga yang dipajang (per menit)
local function guardRatePerMin(player)
	local data = playerData[player] if not data then return 0 end
	local total = 0
	local function rateOf(key, mult)
		local shiny = key:sub(-2) == "|S"
		local name = shiny and key:sub(1, -3) or key
		local def = VILLAIN_BY_NAME[name] if not def then return end
		local r = math.max(1, math.floor(TIERS[def.tier].coin / 50))
		if shiny then r = r * 10 end
		total += r * mult
	end
	for _, key in pairs(data.displayed.ped) do rateOf(key, 1) end
	if data.displayed.throne then rateOf(data.displayed.throne, 2) end
	return total
end

task.spawn(function()
	while true do
		task.wait(60)
		for player, data in pairs(playerData) do
			local rate = guardRatePerMin(player)
			if rate > 0 then
				addCoins(player, rate)
				notify(player, "👑 Penjagamu menghasilkan +" .. rate .. " koin (pasif per menit)")
				pushState(player)
			end
		end
	end
end)

--=================== GELAR DI ATAS KEPALA ===================
function updateOverhead(player)
	local data = playerData[player] if not data then return end
	local char = player.Character if not char then return end
	local head = char:FindFirstChild("Head") if not head then return end
	local gui = head:FindFirstChild("DAV_Title")
	if not gui then
		gui = Instance.new("BillboardGui")
		gui.Name = "DAV_Title" gui.Size = UDim2.fromScale(8, 1.2)
		gui.StudsOffset = Vector3.new(0, 3.2, 0) gui.AlwaysOnTop = true
		local l = Instance.new("TextLabel")
		l.Name = "Label" l.Size = UDim2.fromScale(1, 1) l.BackgroundTransparency = 1
		l.Font = Enum.Font.FredokaOne l.TextScaled = true l.Parent = gui
		gui.Parent = head
	end
	local label = gui:FindFirstChild("Label")
	if isCreator(player) then
		label.Text = "👑 THE CREATOR 👑" label.TextColor3 = Color3.fromRGB(255, 210, 60)
	else
		local best = 0
		for t in pairs(data.completedTiers) do if t > best then best = t end end
		label.Text = best > 0 and ("⚔️ " .. TITLES[best]) or ""
		label.TextColor3 = Color3.fromRGB(200, 220, 255)
	end
	-- Aura creator: cahaya emas + sparkles
	if isCreator(player) then
		local torso = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso")
		if torso and not torso:FindFirstChild("DAV_Aura") then
			local light = Instance.new("PointLight")
			light.Name = "DAV_Aura" light.Color = Color3.fromRGB(255, 210, 80)
			light.Range = 12 light.Brightness = 2 light.Parent = torso
			local sp = Instance.new("Sparkles") sp.SparkleColor = Color3.fromRGB(255, 215, 0) sp.Parent = torso
		end
	end
end

--=================== LOGIKA MENGGALI ===================
local function rollVillain(soil, claw, golden)
	local weights = {}
	local total = 0
	for t, tier in ipairs(TIERS) do
		local w = tier.weight
		if t >= soil.boostFrom then w = w * soil.boost end
		if golden and t >= 5 then w = w * 4 end
		w = w * (1 + claw.luck * (t - 1) / 3)
		weights[t] = w total += w
	end
	local r = math.random() * total
	local acc = 0 local chosenTier = 1
	for t = 1, #TIERS do
		acc += weights[t]
		if r <= acc then chosenTier = t break end
	end
	local pool = {}
	for _, v in ipairs(VILLAINS) do if v.tier == chosenTier then table.insert(pool, v) end end
	local def = pool[math.random(1, #pool)]
	local shiny = math.random() < 0.01
	return def, shiny
end

local function grantVillain(player, def, shiny)
	local data = playerData[player] if not data then return end
	local c = data.collection[def.name] or { n = 0, s = 0 }
	if shiny then c.s += 1 else c.n += 1 end
	data.collection[def.name] = c
	local coins = TIERS[def.tier].coin
	if shiny then coins = coins * 10 end
	addCoins(player, coins)
	addXP(player, TIERS[def.tier].xp)
	checkTierCompletion(player, def.tier)
	return coins
end

local function setPlotReady(plot)
	plot.state = "ready"
	plot.mound.Visible = true
	plot.prompt.Enabled = true
end

local function plotCooldown(plot)
	plot.state = "cooldown"
	plot.mound.Visible = false
	plot.prompt.Enabled = false
	task.delay(PLOT_RESPAWN, function() setPlotReady(plot) end)
end

-- Fase kabur untuk villain tier tinggi: harus ditangkap penggali dalam FLEE_TIME detik
local function fleePhase(player, plot, model, def, shiny)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "TANGKAP!" prompt.ObjectText = def.name
	prompt.HoldDuration = 0 prompt.MaxActivationDistance = 9
	prompt.Parent = model.PrimaryPart
	local caught = false
	local conn = prompt.Triggered:Connect(function(p)
		if p == player then caught = true end
	end)
	local origin = plot.pos
	local deadline = os.clock() + FLEE_TIME
	while os.clock() < deadline and not caught and model.Parent do
		local target = origin + Vector3.new(math.random(-11, 11), 0, math.random(-11, 11))
		local start = model:GetPivot().Position
		local t0 = os.clock()
		while os.clock() - t0 < 0.7 and not caught do
			local a = math.min(1, (os.clock() - t0) / 0.7)
			local pos = start:Lerp(Vector3.new(target.X, start.Y, target.Z), a)
			model:PivotTo(CFrame.new(pos))
			task.wait(0.05)
		end
	end
	conn:Disconnect()
	prompt:Destroy()
	return caught
end

local function revealAndCollect(player, plot, def, shiny)
	local data = playerData[player] if not data then plotCooldown(plot) return end
	plot.state = "revealing"
	plot.mound.Visible = false
	plot.prompt.Enabled = false
	local vs = villainScale(def, shiny)
	local model = buildVillainModel(def, { shiny = shiny, scale = vs })
	namePlate(model, def, shiny, vs)
	model.Parent = workspace
	-- Muncul dari dalam tanah
	local groundY = plot.pos.Y
	local bury = 4.6 * vs
	for a = 0, 1, 0.12 do
		placeModel(model, Vector3.new(plot.pos.X, groundY - bury * (1 - a), plot.pos.Z), vs)
		task.wait(0.04)
	end
	placeModel(model, Vector3.new(plot.pos.X, groundY, plot.pos.Z), vs)
	local fleeing = def.tier >= FLEE_TIERS
	RE_Reveal:FireClient(player, { name = def.name, tier = def.tier, shiny = shiny, fleeing = fleeing, coins = 0 })
	if fleeing then
		notify(player, "🏃 " .. def.name .. " KABUR! Tangkap dia dalam " .. FLEE_TIME .. " detik!")
		local caught = fleePhase(player, plot, model, def, shiny)
		if caught then
			local coins = grantVillain(player, def, shiny)
			notify(player, "🎯 KETANGKAP! +" .. coins .. " koin dari " .. def.name)
			RE_Reveal:FireClient(player, { name = def.name, tier = def.tier, shiny = shiny, fleeing = false, coins = coins, caught = true })
		else
			notify(player, "💨 Yah, " .. def.name .. " berhasil kabur balik ke tanah…")
		end
	else
		local coins = grantVillain(player, def, shiny)
		RE_Reveal:FireClient(player, { name = def.name, tier = def.tier, shiny = shiny, fleeing = false, coins = coins, caught = true })
		-- Lompat-lompat senang sebentar
		for i = 1, 3 do
			placeModel(model, Vector3.new(plot.pos.X, groundY + 0.7, plot.pos.Z), vs) task.wait(0.16)
			placeModel(model, Vector3.new(plot.pos.X, groundY, plot.pos.Z), vs) task.wait(0.16)
		end
		task.wait(1.2)
	end
	-- Tenggelam kembali
	for a = 0, 1, 0.15 do
		placeModel(model, Vector3.new(plot.pos.X, groundY - bury * a, plot.pos.Z), vs)
		task.wait(0.04)
	end
	model:Destroy()
	pushState(player)
	plotCooldown(plot)
end

function onDigStart(player, plot)
	local data = playerData[player] if not data then return end
	if plot.state ~= "ready" then return end
	if plot.diggingBy then return end
	local soil = SOILS[plot.zone]
	local claw = CLAW_BY_ID[data.clawEquipped]
	-- Syarat tanah: power cakar harus >= tier zona tanah (zona 1..5 -> power 1..5)
	local needPower = plot.zone
	if claw.power < needPower then
		notify(player, "⛔ Cakarmu kurang kuat untuk " .. soil.name .. "! Butuh cakar dengan Power " .. needPower .. " (sekarang " .. claw.power .. ").")
		return
	end
	plot.diggingBy = player
	plot.state = "digging"
	plot.prompt.Enabled = false
	local digTime = claw.dig * soil.digMult
	-- Billboard progres gali
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromScale(5, 0.8) gui.StudsOffset = Vector3.new(0, 3.4, 0) gui.AlwaysOnTop = true
	local bg = Instance.new("Frame") bg.Size = UDim2.fromScale(1, 0.5) bg.Position = UDim2.fromScale(0, 0.25)
	bg.BackgroundColor3 = Color3.fromRGB(30, 30, 30) bg.BorderSizePixel = 0 bg.Parent = gui
	local bar = Instance.new("Frame") bar.Name = "Bar" bar.Size = UDim2.fromScale(0, 1)
	bar.BackgroundColor3 = Color3.fromRGB(255, 190, 60) bar.BorderSizePixel = 0 bar.Parent = bg
	gui.Adornee = plot.mound gui.Parent = plot.mound
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local t0 = os.clock()
	local cancelled = false
	while os.clock() - t0 < digTime do
		if not playerData[player] or not hrp or not hrp.Parent then cancelled = true break end
		if (hrp.Position - plot.pos).Magnitude > 14 then cancelled = true break end
		bar.Size = UDim2.fromScale(math.min(1, (os.clock() - t0) / digTime), 1)
		plot.mound.Position = plot.mound.Position + Vector3.new(math.random(-3, 3) / 100, 0, math.random(-3, 3) / 100)
		task.wait(0.08)
	end
	gui:Destroy()
	plot.mound.Position = Vector3.new(plot.pos.X, plot.pos.Y + 0.5, plot.pos.Z) -- kembalikan gundukan ke posisi awal
	plot.diggingBy = nil
	if cancelled then
		plot.state = "ready" plot.prompt.Enabled = true
		notify(player, "Penggalian batal — kamu menjauh dari petak.")
		return
	end
	data.totalDigs += 1
	local def, shiny = rollVillain(soil, claw, plot.golden)
	if plot.golden then plot.golden = false end
	revealAndCollect(player, plot, def, shiny)
end

-- Event Petak Emas acak
task.spawn(function()
	while true do
		task.wait(math.random(120, 240))
		local ready = {}
		for _, p in ipairs(plots) do if p.state == "ready" and not p.golden then table.insert(ready, p) end end
		if #ready > 0 then
			local plot = ready[math.random(1, #ready)]
			plot.golden = true
			local oldColor = plot.mound.Color
			plot.mound.Color = Color3.fromRGB(255, 205, 40)
			plot.mound.Material = Enum.Material.Neon
			announce("✨ PETAK EMAS muncul di " .. SOILS[plot.zone].name .. "! Peluang tier tingginya naik 4× lipat selama 45 detik!")
			task.delay(45, function()
				if plot.golden then
					plot.golden = false
					plot.mound.Color = oldColor
					plot.mound.Material = Enum.Material.Ground
				else
					plot.mound.Color = oldColor
					plot.mound.Material = Enum.Material.Ground
				end
			end)
		end
	end
end)

-- Toko: prompt membuka GUI toko di client
shopPrompt.Triggered:Connect(function(player)
	RE_Notify:FireClient(player, "__OPEN_SHOP__")
end)

--=================== AKSI DARI CLIENT (GUI) ===================
local function directCoins(player, amount)
	local data = playerData[player] if not data then return end
	data.coins = math.max(0, data.coins + amount)
	local ls = player:FindFirstChild("leaderstats")
	if ls and ls:FindFirstChild("Koin") then ls.Koin.Value = data.coins end
end

RE_Action.OnServerEvent:Connect(function(player, action)
	local data = playerData[player] if not data or type(action) ~= "table" then return end
	local kind = action.type

	if kind == "buyClaw" then
		local claw = CLAW_BY_ID[action.id]
		if not claw or claw.kind ~= "coin" then return end
		if data.clawsOwned[claw.id] then notify(player, "Kamu sudah punya cakar ini.") return end
		-- Syarat berurutan: harus punya cakar koin tepat sebelumnya
		local coinList = {}
		for _, c in ipairs(CLAWS) do if c.kind == "coin" then table.insert(coinList, c) end end
		local myIdx = nil
		for i, c in ipairs(coinList) do if c.id == claw.id then myIdx = i end end
		if myIdx and myIdx > 1 and not data.clawsOwned[coinList[myIdx - 1].id] then
			notify(player, "⛔ Beli dulu cakar sebelumnya: " .. coinList[myIdx - 1].name)
			return
		end
		if data.coins < claw.price then
			notify(player, "💸 Koin kurang! Butuh " .. claw.price .. ", punyamu " .. data.coins .. ".")
			return
		end
		directCoins(player, -claw.price)
		data.clawsOwned[claw.id] = true
		data.clawEquipped = claw.id
		notify(player, "🦾 Kamu membeli & memakai " .. claw.name .. "!")
		pushState(player)

	elseif kind == "equipClaw" then
		if data.clawsOwned[action.id] then
			data.clawEquipped = action.id
			notify(player, "Cakar dipakai: " .. CLAW_BY_ID[action.id].name)
			pushState(player)
		end

	elseif kind == "promptPass" then
		local claw = CLAW_BY_ID[action.id]
		if not claw or claw.kind ~= "robux" then return end
		local passId = CONFIG.PassIds[claw.passKey]
		if not passId or passId == 0 then
			notify(player, "Cakar Robux ini belum tersedia (Game Pass belum dibuat).")
			return
		end
		MarketplaceService:PromptGamePassPurchase(player, passId)

	elseif kind == "display" then
		local key = action.key
		local shiny = key:sub(-2) == "|S"
		local name = shiny and key:sub(1, -3) or key
		if not VILLAIN_BY_NAME[name] then return end
		if availableCount(data, name, shiny) <= 0 then
			notify(player, "Tidak ada salinan bebas untuk dipajang (sudah terpajang semua / tidak punya).")
			return
		end
		if action.slot == "throne" then
			data.displayed.throne = key
		else
			local maxPed = isCreator(player) and 16 or 8
			local used = {}
			for s in pairs(data.displayed.ped) do used[s] = true end
			local placed = false
			for s = 1, maxPed do
				if not used[s] then data.displayed.ped[s] = key placed = true break end
			end
			if not placed then notify(player, "Pedestal penuh! Copot dulu salah satu pajangan.") return end
		end
		refreshHome(player)
		notify(player, "👑 " .. name .. (shiny and " ✨SHINY" or "") .. " sekarang berjaga di home-mu!")
		pushState(player)

	elseif kind == "undisplay" then
		if action.slot == "throne" then data.displayed.throne = nil
		elseif type(action.slot) == "number" then data.displayed.ped[action.slot] = nil end
		refreshHome(player)
		pushState(player)

	elseif kind == "fuse" then
		local name = action.name
		local def = VILLAIN_BY_NAME[name] if not def then return end
		if availableCount(data, name, false) < 3 then
			notify(player, "Butuh 3 salinan bebas (tidak terpajang) untuk fusion.")
			return
		end
		local c = data.collection[name] c.n -= 3
		local newTier = math.min(9, def.tier + 1)
		local pool = {}
		for _, v in ipairs(VILLAINS) do if v.tier == newTier then table.insert(pool, v) end end
		local got = pool[math.random(1, #pool)]
		local cc = data.collection[got.name] or { n = 0, s = 0 }
		cc.n += 1 data.collection[got.name] = cc
		notify(player, "🧬 FUSION BERHASIL! 3× " .. name .. " → " .. got.name .. " (" .. TIERS[newTier].name .. ")!")
		checkTierCompletion(player, newTier)
		pushState(player)

	elseif kind == "sell" then
		local key = action.key
		local shiny = key:sub(-2) == "|S"
		local name = shiny and key:sub(1, -3) or key
		local def = VILLAIN_BY_NAME[name] if not def then return end
		if availableCount(data, name, shiny) <= 0 then
			notify(player, "Tidak ada salinan bebas untuk dijual.")
			return
		end
		local c = data.collection[name]
		if shiny then c.s -= 1 else c.n -= 1 end
		local price = shiny and TIERS[def.tier].coin * 5 or math.floor(TIERS[def.tier].coin / 2)
		directCoins(player, price)
		notify(player, "💰 Terjual: " .. name .. (shiny and " ✨" or "") .. " seharga " .. price .. " koin.")
		pushState(player)

	elseif kind == "gift" then
		local key = action.key
		local shiny = key:sub(-2) == "|S"
		local name = shiny and key:sub(1, -3) or key
		if not VILLAIN_BY_NAME[name] then return end
		if data.level < GIFT_UNLOCK_LEVEL then
			notify(player, "🔒 Gift terbuka di Level " .. GIFT_UNLOCK_LEVEL .. ".")
			return
		end
		if os.time() < data.giftReadyAt then
			notify(player, "⏳ Tunggu " .. (data.giftReadyAt - os.time()) .. " detik sebelum gift lagi.")
			return
		end
		local target = Players:GetPlayerByUserId(action.target or 0)
		if not target or target == player or not playerData[target] then
			notify(player, "Pemain tujuan tidak ditemukan.")
			return
		end
		if availableCount(data, name, shiny) <= 0 then
			notify(player, "Tidak ada salinan bebas untuk di-gift (yang terpajang tidak bisa di-gift).")
			return
		end
		local c = data.collection[name]
		if shiny then c.s -= 1 else c.n -= 1 end
		local tc = playerData[target].collection[name] or { n = 0, s = 0 }
		if shiny then tc.s += 1 else tc.n += 1 end
		playerData[target].collection[name] = tc
		data.giftReadyAt = os.time() + GIFT_COOLDOWN
		notify(player, "🎁 Kamu mengirim " .. name .. (shiny and " ✨SHINY" or "") .. " ke " .. target.DisplayName .. "!")
		notify(target, "🎁 Kamu menerima GIFT: " .. name .. " (" .. TIERS[VILLAIN_BY_NAME[name].tier].name .. ") dari " .. player.DisplayName .. "!")
		checkTierCompletion(target, VILLAIN_BY_NAME[name].tier)
		pushState(player) pushState(target)

	elseif kind == "creatorSpawn" and isCreator(player) then
		local tier = math.clamp(action.tier or 1, 1, 9)
		local pool = {}
		for _, v in ipairs(VILLAINS) do if v.tier == tier then table.insert(pool, v) end end
		local def = pool[math.random(1, #pool)]
		local coins = grantVillain(player, def, action.shiny or false)
		notify(player, "👑 [Creator] Spawn: " .. def.name .. " masuk koleksimu (+" .. coins .. " koin).")
		pushState(player)

	elseif kind == "creatorCoins" and isCreator(player) then
		directCoins(player, 50000)
		notify(player, "👑 [Creator] +50.000 koin.")
		pushState(player)

	elseif kind == "creatorAnnounce" and isCreator(player) then
		local text = tostring(action.text or ""):sub(1, 120)
		if #text > 0 then announce("📣 " .. CONFIG.CreatorName .. ": " .. text) end

	elseif kind == "creatorDayNight" and isCreator(player) then
		if Lighting.ClockTime > 6 and Lighting.ClockTime < 18 then Lighting.ClockTime = 0.2
		else Lighting.ClockTime = 14 end
		notify(player, "👑 [Creator] Waktu diganti.")

	elseif kind == "creatorTeleport" and isCreator(player) then
		local target = Players:GetPlayerByUserId(action.target or 0)
		local myChar = player.Character local tChar = target and target.Character
		if myChar and tChar and myChar:FindFirstChild("HumanoidRootPart") and tChar:FindFirstChild("HumanoidRootPart") then
			myChar.HumanoidRootPart.CFrame = tChar.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
		end

	elseif kind == "creatorGive" and isCreator(player) then
		local target = Players:GetPlayerByUserId(action.target or 0)
		if target and playerData[target] then
			directCoins(target, 10000)
			notify(target, "👑 Sang Creator memberimu +10.000 koin!")
			notify(player, "👑 [Creator] +10.000 koin terkirim ke " .. target.DisplayName .. ".")
			pushState(target)
		end
	end
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, purchased)
	if not purchased then return end
	for _, claw in ipairs(CLAWS) do
		if claw.kind == "robux" and CONFIG.PassIds[claw.passKey] == passId then
			local data = playerData[player] if not data then return end
			data.clawsOwned[claw.id] = true
			data.clawEquipped = claw.id
			notify(player, "🦾 Selamat! " .. claw.name .. " sekarang milikmu & langsung dipakai!")
			pushState(player)
		end
	end
end)

--=================== DATASTORE ===================
local store = nil
if CONFIG.UseDataStore then
	local ok, result = pcall(function() return DataStoreService:GetDataStore("DAV_Data_v1") end)
	if ok then store = result end
end

local function serialize(data)
	local ped = {}
	for k, v in pairs(data.displayed.ped) do ped[tostring(k)] = v end
	local tiers = {}
	for k, v in pairs(data.completedTiers) do tiers[tostring(k)] = v end
	return { coins = data.coins, xp = data.xp, level = data.level, totalDigs = data.totalDigs,
		clawsOwned = data.clawsOwned, clawEquipped = data.clawEquipped, collection = data.collection,
		displayed = { ped = ped, throne = data.displayed.throne }, completedTiers = tiers }
end

local function deserialize(saved)
	local data = defaultData()
	if type(saved) ~= "table" then return data end
	for k in pairs(data) do if saved[k] ~= nil then data[k] = saved[k] end end
	local ped = {}
	if saved.displayed and saved.displayed.ped then
		for k, v in pairs(saved.displayed.ped) do ped[tonumber(k) or k] = v end
	end
	data.displayed = { ped = ped, throne = saved.displayed and saved.displayed.throne or nil }
	local tiers = {}
	if saved.completedTiers then
		for k, v in pairs(saved.completedTiers) do tiers[tonumber(k) or k] = v end
	end
	data.completedTiers = tiers
	return data
end

local function savePlayer(player)
	if not store then return end
	local data = playerData[player] if not data then return end
	pcall(function() store:SetAsync("u_" .. player.UserId, serialize(data)) end)
end

--=================== PEMAIN MASUK / KELUAR ===================
Players.PlayerAdded:Connect(function(player)
	local data = defaultData()
	if store then
		local ok, saved = pcall(function() return store:GetAsync("u_" .. player.UserId) end)
		if ok and saved then data = deserialize(saved) end
	end
	if isCreator(player) then data.clawsOwned["creator"] = true end
	-- Cek kepemilikan Game Pass cakar Robux
	for _, claw in ipairs(CLAWS) do
		if claw.kind == "robux" then
			local passId = CONFIG.PassIds[claw.passKey]
			if passId and passId ~= 0 then
				local ok, owns = pcall(function()
					return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
				end)
				if ok and owns then data.clawsOwned[claw.id] = true end
			end
		end
	end
	playerData[player] = data

	local ls = Instance.new("Folder") ls.Name = "leaderstats" ls.Parent = player
	local koin = Instance.new("IntValue") koin.Name = "Koin" koin.Value = data.coins koin.Parent = ls
	local lvl = Instance.new("IntValue") lvl.Name = "Level" lvl.Value = data.level lvl.Parent = ls

	-- Klaim home kosong
	for i, home in ipairs(homes) do
		if not home.owner then
			home.owner = player playerHome[player] = i
			home.signLabel.Text = "🏠 Home " .. player.DisplayName
			break
		end
	end
	refreshHome(player)

	player.CharacterAdded:Connect(function()
		task.wait(1)
		updateOverhead(player)
		local ls2 = player:FindFirstChild("leaderstats")
		if ls2 and ls2:FindFirstChild("Level") then ls2.Level.Value = playerData[player] and playerData[player].level or 1 end
	end)

	if isCreator(player) then
		task.delay(3, function()
			announce("👑 Sang Creator telah tiba! Selamat datang, " .. player.DisplayName .. "! 👑")
		end)
	end
	pushState(player)
end)

Players.PlayerRemoving:Connect(function(player)
	savePlayer(player)
	local hi = playerHome[player]
	if hi and homes[hi] then
		homes[hi].owner = nil
		homes[hi].signLabel.Text = "🏠 Home Kosong"
		homes[hi].displayFolder:ClearAllChildren()
	end
	playerHome[player] = nil
	playerData[player] = nil
end)

game:BindToClose(function()
	for player in pairs(playerData) do savePlayer(player) end
end)

task.spawn(function()
	while true do
		task.wait(300)
		for player in pairs(playerData) do savePlayer(player) end
	end
end)

-- Level di leaderstats ikut naik
task.spawn(function()
	while true do
		task.wait(5)
		for player, data in pairs(playerData) do
			local ls = player:FindFirstChild("leaderstats")
			if ls and ls:FindFirstChild("Level") then ls.Level.Value = data.level end
		end
	end
end)

-- Papan peringkat (update tiap 30 detik)
task.spawn(function()
	while true do
		local lines = { "🏆 PAPAN PERINGKAT 🏆", "", "— Koin Terbanyak —" }
		local ranked = {}
		for player, data in pairs(playerData) do
			table.insert(ranked, { name = player.DisplayName, coins = data.coins, data = data })
		end
		table.sort(ranked, function(a, b) return a.coins > b.coins end)
		for i = 1, math.min(5, #ranked) do
			lines[#lines + 1] = i .. ". " .. ranked[i].name .. " — " .. ranked[i].coins .. " koin"
		end
		lines[#lines + 1] = ""
		lines[#lines + 1] = "— Pemburu 404 —"
		local hunters = {}
		for _, r in ipairs(ranked) do
			local cnt = 0
			for _, v in ipairs(VILLAINS) do
				if v.tier == 9 then local n, s = colCount(r.data, v.name) cnt += n + s end
			end
			if cnt > 0 then table.insert(hunters, { name = r.name, cnt = cnt }) end
		end
		table.sort(hunters, function(a, b) return a.cnt > b.cnt end)
		if #hunters == 0 then lines[#lines + 1] = "(belum ada yang menemukan 404)"
		else
			for i = 1, math.min(5, #hunters) do
				lines[#lines + 1] = i .. ". " .. hunters[i].name .. " — " .. hunters[i].cnt .. "× 404"
			end
		end
		boardLabel.Text = table.concat(lines, "\n")
		task.wait(30)
	end
end)

print("[DIG A VILLAIN] Server siap. Petak tanah:", #plots, "| Home:", #homes)
