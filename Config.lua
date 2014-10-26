local AddonName, Abu = ...
local path = 'Interface\\AddOns\\AbuEssentials\\Textures\\'

--[[
	[1] = path..'Font\\Atarian.ttf',
	[2] = path..'Font\\Defused.ttf',
	[3] = path..'Font\\AccPrec.ttf',
	[4] = path..'Font\\ExpresswayFree.ttf',
--]]

Abu.Config = {
	Auras = {
		buffSize = 36,
		debuffSize = 48,
		fontSize = 14,
	},
	Colors = {
		Frame = 	{ 0.5, 0.5, 0.4 },
		Border = 	{ 0.9, 0.9, 0.8 },
		Interrupt = { .9, .8, .2 },
	},
	Fonts = {
		Damage = path..'Font\\Defused.ttf',
		Normal = path..'Font\\ExpresswayFree.ttf',
		Actionbar = path..'Font\\AccPrec.ttf',
	},
	Statusbar = {
		Normal = path..'statusbarTex.tga',
		Light = path.."tex.tga",
	},
	IconTextures = {
		Normal = path..'Border\\textureNormal',
		Background = path..'Border\\textureBackground',
		Highlight = path..'Border\\textureHighlight',
		Checked = path..'Border\\textureChecked',
		Pushed = path..'Border\\texturePushed',
		Shadow = path..'Border\\textureShadow',
		White = path..'Border\\textureWhite',
		Debuff = path..'Border\\textureDebuff',
		Flash = nil,
	},
	Actionbar = {
		PrintBindings = false,
		showKeybinds = false,
		fontSize = 19,
		HideStanceBar = {
			['DEATHKNIGHT'] = false,
			['DRUID'] = false,
			['HUNTER'] = false,
			['MAGE'] = false,
			['MONK'] = false,
			['PALADIN'] = false,
			['PRIEST'] = false,
			['ROGUE'] = false,
			['SHAMAN'] = false,
			['WARLOCK'] = false,
			['WARRIOR'] = true,
		},
		fadeOutBars = {
			['MultiBarLeft'] = true,
			['MultiBarRight'] = true,
			['MultiBarBottomRight'] = false,
		},
	},
	ActionbarPaging = { -- Change bar on different conditions, like tons of macros would do
		-- 1	(Primary) Action Bar 1
		-- 2	(Primary) Action Bar 2
		-- 3	Right Bar
		-- 4	Right Bar 2
		-- 5	Bottom Right Bar
		-- 6	Bottom Left Bar
		-- 7	Druid Cat Form/Rogue Stealth/Warrior Battle Stance/Priest Shadowform/Monk Fierce Tiger
		-- 8	Warrior Defensive Stance/Rogue Shadow Dance/Monk Sturdy Ox
		-- 9	Druid Bear Form/Warrior Berserker Stance/Monk Wise Serpent
		-- 10	Druid Moonkin Form
		['MONK']    = '[help]2;[mod:alt]2;1',
		['PRIEST']  = '[help]2;[mod:alt]2;1',
		['PALADIN'] = '[help]2;[mod:alt]2;1',
		['SHAMAN']  = '[help]2;[mod:alt]2;1',
		['DRUID']   = '[help,nostance:1/2/3/4]2;[mod:alt]2;[stance:2]7;[stance:1]9;',
		--['ROGUE']   = '[stance:1]7;[stance:3]7;1',
	},
	Chat = {
		disableFade = true,
		chatOutline = false,

		enableHyperlinkTooltip = true, 
		enableBorderColoring = true,

		tab = {
			fontSize = 12,
			fontOutline = true, 
			normalColor = {1, 1, 1},
			flashColor = {1, 0, 1},
			selectedColor = {0, 0.75, 1},
		},
	},
	Nameplate = {
		width = 105,
		height = 8,
		gap = 7,
		cbheight = 8,
	},
	Tooltip = {
		ShowTitle = false,
		RoleIcon = true,
		ShowGuildRanks = true,
		FontSize = 13,
		Position = {'BOTTOMRIGHT', UIParent, 'BOTTOMRIGHT', -57, 190},
	},
	Vendor = {
		AutoRepair = true,
		SellGreyCrap = true,
		BuyEssentials = true,
	},
	AuraList = {
		BLACKLIST = {
			['DRUID'] = { },
			['HUNTER'] = { },
			['MAGE'] = {
				[116] = true, -- frostbolt debuff
				[132210] = true, -- pyromaniac
			},
			['DEATHKNIGHT'] = { },
			['WARRIOR'] = {
				[113746] = true, -- weakened armour
				[1160] = true,   -- demoralizing shout
				[115767] = true, -- deep wounds; td
				[469] = true,    -- commanding shout
				[6673] = true,   -- battle shout
				[115804] = true, -- mortal WOUNDS
				[81326] = true,  -- Physical invul
			},
			['PALADIN'] = { },
			['WARLOCK'] = { },
			['SHAMAN'] = { -- 5.2 COMPLETE
				[63685] = true,  -- frost shock root
				[51490] = true,  -- thunderstorm slow
				[61882] = true,  -- earthquake
				
				[3600] = true,   -- earthbind totem passive
				[64695] = true,   -- earthgrap totem root
				[116947] = true,   -- earthgrap totem slow
			},
			['PRIEST'] = { },
			['ROGUE'] = {
				[113952] = true, --Paralytic Poison"
				[93068] = true, --Master Poisoner
				[3409] = true,  --Crippling Poison
				},
			['MONK'] = { },
		},
		ALL = {
			[25046] = true,  -- Arcane Torrent
			[69179] = true,  -- Arcane Torrent
			[23333] = true,  -- Horde Flag
			[28730] = true,  -- Arcane Torrent
			[50613] = true,  -- Arcane Torrent
			[34976] = true,  -- Netherstorm Flag
			[80483] = true,  -- Arcane Torrent
			[20549] = true,  -- War Stomp
			[23335] = true,  -- Alliance Flag
			[107079] = true,  -- Quaking Palm
			[129597] = true,  -- Arcane Torrent
		},
	},
}