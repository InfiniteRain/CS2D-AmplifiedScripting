return                      

{
	cs2dCommands = {
		"addhook",
		"ai_aim",
		"ai_attack",
		"ai_build",
		"ai_buy",
		"ai_debug",
		"ai_drop",
		"ai_findtarget",
		"ai_freeline",
		"ai_goto",
		"ai_iattack",
		"ai_move",
		"ai_radio",
		"ai_reload",
		"ai_respawn",
		"ai_rotate",
		"ai_say",
		"ai_sayteam",
		"ai_selectweapon",
		"ai_spray",
		"ai_use",
		"closehostage",
		"closeitems",
		"closeobjects",
		"entity",
		"entitylist",
		"freehook",
		"freeimage",
		"freetimer",
		"funcs",
		"game",
		"hostage",
		"image",
		"imagealpha",
		"imageblend",
		"imagecolor",
		"imagehitzone",
		"imagepos",
		"imagescale",
		"inentityzone",
		"item",
		"itemtype",
		"map",
		"menu",
		"msg",
		"msg2",
		"object",
		"objectat",
		"parse",
		"player",
		"playerweapons",
		"projectile",
		"projectilelist",
		"randomentity",
		"randomhostage",
		"reqcld",
		"setentityaistate",
		"sethookstate",
		"stats",
		"tile",
		"timer",
		"tween_alpha",
		"tween_color",
		"tween_move",
		"tween_rotate",
		"tween_rotateconstantly",
		"tween_scale",
		"vars"
	},
	
	cs2dHooks = {
		["always"] = {},
		["attack"] = {player = {1}},
		["attack2"] = {player = {1}},
		["bombdefuse"] = {player = {1}},
		["bombexplode"] = {player = {1}},
		["bombplant"] = {player = {1}},
		["break"] = {player = {3}},
		["build"] = {player = {1}, dynObject = {6}},
		["buildattempt"] = {player = {1}},
		["buy"] = {player = {1}, itemType = {2}},
		["clientdata"] = {player = {1}, reqcldMode = {2}},
		["collect"] = {player = {1}, --[[item = {2},]] itemType = {3}},
		-- During the collect hook, the passed "iid" parameted always represents an item which no
		-- longer exists (because it was collected by a player). So I made this hook return the
		-- ID of the collected item rather than the instance of item (which won't work anyway).
		["die"] = {player = {1, 2}, itemType = {3}, dynObject = {6}},
		["dominate"] = {player = {1}},
		["drop"] = {player = {1}, --[[item = {2},]] itemType = {3}},
		-- During the drop hook, the passed "iid" parameted always represents an item which doesn't
		-- yet exist (because it is still on the ground). So I made this hook return the ID of the
		-- dropped item rather than the instance of item (which won't work anyway).
		["endround"] = {},
		["flagcapture"] = {player = {1}},
		["flagtake"] = {player = {1}},
		["flashlight"] = {player = {1}},
		["hit"] = {player = {1, 2}, itemType = {3}, dynObject = {7}},
		["hitzone"] = {image = {1}, player = {2}, dynObject = {3}, itemType = {4}},
		["hostagerescue"] = {player = {1}},
		["join"] = {player = {1}},
		["kill"] = {player = {1, 2}, itemType = {3}, dynObject = {6}},
		["leave"] = {player = {1}},
		["log"] = {},
		["mapchange"] = {},
		["menu"] = {player = {1}},
		["minute"] = {},
		["move"] = {player = {1}},
		["movetile"] = {player = {1}},
		["ms100"] = {},
		["name"] = {player = {1}},
		["objectdamage"] = {dynObject = {1}, player = {3}},
		["objectkill"] = {dynObject = {1}, player = {2}},
		["objectupgrade"] = {dynObject = {1}, player = {2}},
		["parse"] = {},
		["projectile"] = {player = {1}, itemType = {2}},
		["radio"] = {player = {1}},
		["rcon"] = {player = {2}},
		["reload"] = {player = {1}},
		["say"] = {player = {1}},
		["sayteam"] = {player = {1}},
		["second"] = {},
		["select"] = {player = {1}, itemType = {2}},
		["serveraction"] = {player = {1}},
		["shieldhit"] = {player = {1, 2}, itemType = {3}, dynObject = {5}},
		["spawn"] = {player = {1}},
		["spray"] = {player = {1}},
		["startround"] = {},
		["startround_prespawn"] = {},
		["suicide"] = {player = {1}},
		["team"] = {player = {1}},
		["trigger"] = {},
		["triggerentity"] = {entity = {{1, 2}}},
		["use"] = {player = {1}},
		["usebutton"] = {player = {1}, entity = {{2, 3}}},
		["vipescape"] = {player = {1}},
		["vote"] = {player = {1}},
		["walkover"] = {player = {1}, item = {2}, itemType = {3}}
	},
	
	cs2dItemTypes = {
		--["<name>"] = {<typeID>, <passive>, <rightClickType>, <projectile>}
		["usp"] = {1, false, "silencer", false},
		["glock"] = {2, false, "burst", false},
		["deagle"] = {3, false, "none", false},
		["p228"] = {4, false, "none", false},
		["elite"] = {5, false, "none", false},
		["fiveseven"] = {6, false, "none", false},
		["m3"] = {10, false, "none", false},
		["xm1014"] = {11, false, "none", false},
		["mp5"] = {20, false, "none", false},
		["tmp"] = {21, false, "none", false},
		["p90"] = {22, false, "none", false},
		["mac10"] = {23, false, "none", false},
		["ump45"] = {24, false, "none", false},
		["ak47"] = {30, false, "none", false},
		["sg552"] = {31, false, "1scope", false},
		["m4a1"] = {32, false, "silencer", false},
		["aug"] = {33, false, "1scope", false},
		["scout"] = {34, false, "2scopes", false},
		["awp"] = {35, false, "2scopes", false},
		["g3sg1"] = {36, false, "2scopes", false},
		["sg550"] = {37, false, "2scopes", false},
		["galil"] = {38, false, "none", false},
		["famas"] = {39, false, "burst", false},
		["fnf2000"] = {91, false, "none", false},
		["m249"] = {40, false, "none", false},
		["laser"] = {45, false, "other", false},
		["flamethrower"] = {46, false, "none", false},
		["rpglauncher"] = {47, false, "none", true},
		["rocketlauncher"] = {48, false, "none", true},
		["grenadelauncher"] = {49, false, "none", true},
		["portalgun"] = {88, false, "other", false},
		["m134"] = {90, false, "none", false},
		["knife"] = {50, false, "attack", false},
		["machete"] = {69, false, "none", false},
		["wrench"] = {74, false, "other", false},
		["claw"] = {78, false, "attack", false},
		["chainsaw"] = {85, false, "none", false},
		["he"] = {51, false, "none", true},
		["flashbang"] = {52, false, "none", true},
		["smokegrenade"] = {53, false, "none", true},
		["flare"] = {54, false, "none", true},
		["gasgrenade"] = {72, false, "none", true},
		["molotovcocktail"] = {73, false, "none", true},
		["snowball"] = {74, false, "none", true},
		["airstrike"] = {76, false, "none", true},
		["gutbomb"] = {86, false, "none", true},
		["satchelcharge"] = {89, false, "none", true},
		["mine"] = {77, false, "none", false},
		["lasermine"] = {87, false, "none", false},
		["tacticalshield"] = {41, false, "none", false},
		["defusekit"] = {56, true, "none", false},
		["kevlar"] = {57, true, "none", false},
		["kevlarhelm"] = {58, true, "none", false},
		["nightvision"] = {59, true, "none", false},
		["gasmask"] = {60, true, "none", false},
		["primaryammo"] = {61, true, "none", false},
		["secondaryammo"] = {62, true, "none", false},
		["bomb"] = {55, true, "none", false},
		["plantedbomb"] = {63, true, "none", false},
		["medkit"] = {64, true, "none", false},
		["bandage"] = {65, true, "none", false},
		["coins"] = {66, true, "none", false},
		["money"] = {67, true, "none", false},
		["gold"] = {68, true, "none", false},
		["redflag"] = {70, true, "none", false},
		["blueflag"] = {71, true, "none", false},
		["lightarmor"] = {79, true, "none", false},
		["armor"] = {80, true, "none", false},
		["heavyarmor"] = {81, true, "none", false},
		["medicarmor"] = {82, true, "none", false},
		["superarmor"] = {83, true, "none", false},
		["stealthsuit"] = {84, true, "none", false}
	},
	
	cs2dDynamicObjectTypes = {
		["barricade"] = 1,
		["barbedwire"] = 2,
		["walli"] = 3,
		["wallii"] = 4,
		["walliii"] = 5,
		["gatefield"] = 6,
		["dispenser"] = 7,
		["turret"] = 8,
		["supply"] = 9,
		["buildplace"] = 10,
		["dualturret"] = 11,
		["tripleturret"] = 12,
		["teleportentrance"] = 13,
		["teleportexit"] = 14,
		["supersupply"] = 15,
		["mine"] = 20,
		["lasermine"] = 21,
		["orangeportal"] = 22,
		["blueportal"] = 23,
		["npc"] = 30,
		["image"] = 40
	},
	
	cs2dEntityTypes = {
		["Info_T"] = 0,
		["Info_CT"] = 1,
		["Info_VIP"] = 2,
		["Info_Hostage"] = 3,
		["Info_RescuePoint"] = 4,
		["Info_BombSpot"] = 5,
		["Info_EscapePoint"] = 6,
		["Info_Animation"] = 8,
		["Info_Storm"] = 9,
		["Info_TileFX"] = 10,
		["Info_NoBuying"] = 11,
		["Info_NoWeapons"] = 12,
		["Info_NoFOW"] = 13,
		["Info_Quake"] = 14,
		["Info_CTF_Flag"] = 15,
		["Info_OldRender"] = 16,
		["Info_Dom_Point"] = 17,
		["Info_NoBuildings"] = 18,
		["Info_BotNode"] = 19,
		["Info_TeamGate"] = 20,
		["Env_Item"] = 21,
		["Env_Sprite"] = 22,
		["Env_Sound"] = 23,
		["Env_Decal"] = 24,
		["Env_Breakable"] = 25,
		["Env_Explode"] = 26,
		["Env_Hurt"] = 27,
		["Env_Image"] = 28,
		["Env_Object"] = 29,
		["Env_Building"] = 30,
		["Env_NPC"] = 31,
		["Env_Room"] = 32,
		["Env_Light"] = 33,
		["Env_LightStripe"] = 34,
		["Gen_Particles"] = 50,
		["Gen_Sprites"] = 51,
		["Gen_Weather"] = 52,
		["Gen_FX"] = 53,
		["Func_Teleport"] = 70,
		["Func_DynWall"] = 71,
		["Func_Message"] = 72,
		["Func_GameAction"] = 73,
		["Info_NoWeather"] = 80,
		["Trigger_Start"] = 90,
		["Trigger_Move"] = 91,
		["Trigger_Hit"] = 92,
		["Trigger_Use"] = 93,
		["Trigger_Delay"] = 94,
		["Trigger_Once"] = 95,
		["Trigger_If"] = 96
	}
}