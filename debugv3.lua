local Config = getgenv().Config
assert(Config, "Config not found. Please run the loader.")

local TEAM_NAME      = Config.TEAM_NAME
local TARGET_RACE    = Config.TARGET_RACE
local CHECK_INTERVAL = Config.CHECK_INTERVAL
local Banana_key     = Config.Banana_key

local FRAG_ROLL_RACE = Config.FRAG_ROLL_RACE
local FRAG_PULL      = Config.FRAG_PULL
local ENABLE_ROLL_RACE = Config.ENABLE_ROLL_RACE

local function SCRIPT_A(race, key)
	getgenv().Config = {
	["f7b39f4f-f811-4a8e-8b73-b352567cc2cf"] = true,
	["b0ed83e0-399c-4e3f-80d3-c3fb7d8242bf"] = true,
	["aefc8138-1d14-4cde-b91a-5fcd90448eac"] = true,
	["5f76706b-0cd1-40c2-9e0c-f1971b032fd6"] = true,
	["24d5d7ac-204c-49d5-8d24-e2ba861ad152"] = true,
	["Auto Finish Train Draco Quest"] = false,
	["Auto Dodge Skill Seabeast"] = false,
	["c24385cb-c4a5-428c-acea-a41e532bb429"] = true,
	["1c651b1c-f7ff-4d8c-8d71-1b0af4c5de93"] = true,
	["ea166fcf-708f-4556-93ce-980ce9393026"] = true,
	["e0573f95-e29c-46fc-80e0-ea3c72555d52"] = true,
	["Ignore Craft Volcanic Magnet"] = false,
	["Auto Trade Azure Ember"] = false,
	["18d3e9ae-4e44-4dba-a57c-fa019356dcdd"] = true,
	["Value Speed Fly Boat"] = 3,
	["Auto Upgrade Gun Inventory"] = false,
	["Fully Event Prehistoric Island"] = false,
	["Auto Aimbot Gun"] = false,
	["Auto New World"] = false,
	["Drive Boat To Hydra"] = false,
	["Auto Summon Soul Ember"] = false,
	["Summon Dough King"] = false,
	["Auto Store Fruit"] = false,
	["b8dff701-6974-47c6-8922-a1579d6f59ab"] = true,
	["Auto Sell Fishing"] = false,
	["Auto Get Fully Cyborg"] = false,
	["Use Click M1 Skull Guitar Leviathan"] = false,
	["ESP Island"] = false,
	["Multi Find Leviathan"] = false,
	["Auto Buy Boat Beast Hunter"] = false,
	["Auto Get Rainbow Haki"] = false,
	["Boost Fps"] = false,
	["148fe9d6-7b4c-4c00-9b67-cfd76175c81b"] = true,
	["Random Devil Fruit [ Summer Token ]"] = false,
	["Auto Spawn Kitsune Island"] = false,
	["3d19767d-3858-428c-841d-7bb7e5ec5549"] = true,
	["Change JumpPower"] = false,
	["5632df90-ddea-46d6-9899-8d77ab94c3e7"] = true,
	["Hop Server Elite Hunter"] = false,
	["Auto Upgrade Sword Inventory"] = false,
	["Random Devil Fruit"] = false,
	["Auto Aimbot"] = false,
	["Teleport Y"] = false,
	["ad3940da-8a01-4014-893e-8c1101a04a0a"] = true,
	["Auto Tween To Event Fishing Spot"] = false,
	["Noclip"] = false,
	["Hop Find Katakuri"] = false,
	["Use Dragonstorm For Sea Event"] = false,
	["Auto Touch Pad Haki"] = false,
	["Attack Dough King"] = false,
	["Auto Yoru Mini"] = false,
	["Tween Safe if have Items"] = false,
	["Auto Get Ghoul"] = false,
	["79ed782e-7773-4e70-a752-f843b683a7d8"] = true,
	["dbf80f38-b98c-477f-917e-8f9d9792dd9f"] = true,
	["Auto Finish Train Quest"] = false,
	["9219f102-5b9c-49a9-96a1-8dfec2bd1eb6"] = true,
	["Auto Chest Hop"] = false,
	["Auto Get Cyborg"] = false,
	["Auto Turn On V3 Near Door"] = false,
	["5b69f1eb-9d2f-48f7-9e46-305db2e95006"] = true,
	["Auto Factory"] = false,
	["White Screen"] = false,
	["e2d69679-0d36-4c81-a023-eeccd746cde6"] = true,
	["Auto Dodge Skill Terrorshark"] = false,
	["09e67cae-c523-42ca-881b-ac9df2d8d985"] = true,
	["e14e2671-5540-487e-b0c0-0bab911f3934"] = true,
	["Farm Observation [ Hop Server ]"] = false,
	["76d5a1be-0db6-4bc1-9746-08dbdc85efa8"] = true,
	["Kill Mob"] = false,
	["Auto TTK"] = false,
	["7f1d5a55-b845-4546-a86e-fca8d526e558"] = true,
	["Use Click M1 Fruit Leviathan"] = false,
	["Auto Raid"] = false,
	["% Health Player"] = 40,
	["Teleport Player"] = false,
	["8272f009-2224-41fa-aaaf-071093cc2162"] = true,
	["Auto Quest [Katakuri/Bone/Tyrant]"] = false,
	["Kill Boss"] = false,
	["40b5da36-4f25-4112-a95c-373e0cadba8f"] = true,
	["596e004f-a7d6-4c79-a013-ea5cbd1d8067"] = true,
	["Auto Click"] = false,
	["Teleport Boat Other CFrame if Rough Sea"] = false,
	["dbf45129-2278-468b-9cfd-ba7c53d5b3ea"] = true,
	["Speed Boat Auto Drive"] = 300,
	["Auto Collect Berry"] = false,
	["Auto Buy Gear Draco"] = false,
	["3a67ff58-58e2-4e01-87ea-198ee0216ae9"] = true,
	["1070d2ca-2ccf-49ae-9862-0bf2f8e94c90"] = true,
	["Teleport To Kitsune Island"] = false,
	["Time Hop Server"] = 10,
	["d4a5733b-b380-4c47-b1c0-05d78f4b40ac"] = true,
	["Will Back When over 10km"] = false,
	["Use Portal Teleport"] = false,
	["29f3815d-2270-4f5b-9484-0378ed8ff70e"] = true,
	["Select Skills Gun"] = {
		["Z"] = true,
		["X"] = true
	},
	["Auto Find Leviathan"] = false,
	["Value Collect Chest to Hop"] = 20,
	["Auto Sea Event"] = false,
	["Auto Stats"] = false,
	["eec8dffb-04ef-4d24-93f9-709f46353b6d"] = true,
	["2a6e554c-298f-493a-8f19-9c85fa58390d"] = true,
	["dec0c787-a478-4b43-8f9d-fab8fd582280"] = true,
	["d6f9d7a8-62b5-4a85-b5b5-b077bd301481"] = true,
	["Kill Aura With DragonStorm"] = false,
	["Auto Quest Dragon Hunter"] = false,
	["Remove Notifications"] = false,
	["Use Click M1 Skull Guitar For Sea Event"] = false,
	["Auto CDK"] = false,
	["Auto Crafting Volcanic Magnet"] = false,
	["41ffe321-9b95-4593-8773-66f5ae517153"] = true,
	["Hop Sever Raid"] = false,
	["Hop Find Dough King"] = false,
	["Speed Tween"] = 350,
	["cffa602a-eced-4340-9446-b8733f264c9a"] = true,
	["Attack Darkbeard"] = false,
	["No Frog"] = false,
	["Auto Dodge Skill Mobs"] = false,
	["65fddf8d-0268-4e69-b46d-7cec3d486af2"] = true,
	["Auto Turn On V3"] = false,
	["Tween Boat To Frozen Dimension"] = false,
	["e52b4b01-2d1c-43ad-8bb9-44334e7bf82b"] = true,
	["Distance Teleport Y"] = 800,
	["d5df3c85-1531-4ff5-913c-c685151eabd5"] = true,
	["Select Method Farm"] = "Farm Katakuri",
	["Just Use Skill when Player Active Ken"] = false,
	["7659fc04-3df8-41f2-b53f-5f4505ccfee9"] = true,
	["Auto Start Leviathan"] = false,
	["ESP Berry"] = false,
	["Ignore Collect Bone"] = false,
	["Change WalkSpeed"] = false,
	["Kill Aura Mob Halloween"] = false,
	["Auto Fishing"] = false,
	["Auto Quest Dojo Trainer"] = false,
	["Auto Tushita"] = false,
	["Ignore Craft Volcanic Magnet Draco"] = false,
	["Auto Destroy IDK"] = false,
	["Select Skills Sword"] = {
		["Z"] = true,
		["X"] = true
	},
	["5afaf96f-afcc-4e9b-a397-94be0d925e37"] = true,
	["Fully Trial Draco"] = false,
	["a0511110-eb07-4b09-974a-0b313912d828"] = true,
	["Auto Trial"] = false,
	["Account Buy Chip"] = false,
	["1f02870f-295f-4142-a189-015285f2445d"] = true,
	["2e4be0af-42d5-434b-adcd-0ba48ac58766"] = true,
	["Kill players When complete Trial"] = false,
	["Use skill fast dont hold"] = false,
	["8e7eec0d-3304-4f23-aa82-c4de25654312"] = true,
	["4c76bc86-5b48-470a-96c2-2d956379b392"] = true,
	["Auto Collect Bone"] = false,
	["Webhook Find Prehistoric Island"] = false,
	["Use Click M1 Fruit For Sea Event"] = false,
	["Hop Server Find Boss"] = false,
	["Auto Accept Quest Fishing"] = false,
	["Value Speed Boat"] = 200,
	["bddbdcf9-6679-4515-927f-dd6149b0e1b4"] = true,
	["Values Azure Ember"] = 10,
	["Auto Turn On V4"] = false,
	["Auto Fire Shoot Heart Leviathan"] = false,
	["dcb7aa7c-a210-4bef-a24d-aeba25d4de1a"] = true,
	["Auto Buy Haki Color"] = false,
	["c39e010a-a31f-4b65-968d-6ab21b5ca978"] = true,
	["Input JumpPower"] = 200,
	["Auto Pull Lever"] = false,
	["91a94ed3-9e63-4231-a6a9-ea0f10074799"] = true,
	["Hop Server Kitsune Island"] = false,
	["Walk On Water "] = true,
	["Account Pick Slot Raid"] = false,
	["7db9f5cb-ca12-45f0-a049-f3712c946ebf"] = true,
	["Spam Join"] = false,
	["53008ccd-60ae-4a38-996e-ccd758014e15"] = true,
	["Auto Farm Mastery 600 Sword In Inventory"] = false,
	["2fd69165-01e1-49da-ae68-b1f2b4eb7e59"] = true,
	["Auto Reset Character"] = false,
	["Auto Yama"] = false,
	["Hop Server [ Haki color or Legendary Sword]"] = false,
	["Auto Yoru Mini (Hop Server)"] = false,
	["a12e3e4b-9ae8-4ee9-9f3d-dbbb802a05e8"] = true,
	["Summon Darkbeard"] = false,
	["2dede9cd-789a-4830-a8b4-a2387d4407e6"] = true,
	["def45387-3c52-4108-972d-14ced2b926dd"] = true,
	["c4f39e50-132c-4f5f-a487-eb4c9260d1be"] = true,
	["e44b3672-0f27-412f-8796-c57a6cc8ccad"] = true,
	["Buy Blox Fruit Sniper Shop"] = false,
	["c38e206e-bab3-4c7e-8194-e60c2fc15466"] = true,
	["333ae971-345b-4b2b-b152-9f4f9c57aa3e"] = true,
	["c2787218-a631-4f2e-b650-abcaa9d888d9"] = true,
	["Auto Trade Bone"] = false,
	["Auto Summon Rip Indra"] = false,
	["Summon Soul Reaper"] = false,
	["Auto Buy Spy"] = false,
	["Auto Slap Battle"] = false,
	["9b7cf0fb-2118-4769-9c70-73a184b3cceb"] = true,
	["Auto Collect Egg"] = false,
	["Auto Get Cyborg Hop Collect Chest"] = false,
	["Tween Until Have Sea Event"] = false,
	["Auto Open Chest"] = false,
	["0af95a38-2345-4c3e-baf1-44a4fec98dd0"] = true,
	["Attack Multi Segments Leviathan"] = false,
	["3d7c9ae8-9558-4efa-b1e5-c36166940da5"] = true,
	["c6a58c18-e443-4e13-bcd4-6cdda59fceb5"] = true,
	["3ee0a5b3-f589-4805-8a15-65d289796859"] = true,
	["Auto Saber"] = false,
	["Webhook Store Fruit"] = false,
	["Change Speed Boat"] = false,
	["0772a898-d45f-4ad5-b38d-bae50d874f71"] = true,
	["Auto Buy Chip and Attack Law"] = false,
	["c37b3a30-cbd0-44b2-9783-fe3c61c94878"] = true,
	["2dbe8e5e-8702-4b70-846a-adf89a4a90a3"] = true,
	["Reset Character Buy Boat"] = false,
	["Auto Third World"] = false,
	["Auto Buy Legendary Sword"] = false,
	["Distance Farm Aura"] = 300,
	["Auto UP Observation V2"] = false,
	["Auto Soul Guitar"] = false,
	["52019e25-bfff-4433-bbb4-ad9b43f25943"] = true,
	["Hop Find Darkbeard"] = false,
	["7aaad928-8be8-478d-884f-eab34f3687ce"] = true,
	["Attack No Animation "] = true,
	["f60edda8-7056-4f96-b7c7-ad9ec3d5fe30"] = true,
	["35a625b6-f0d2-42ff-988b-810bc8891555"] = true,
	["562c52c0-5356-4ea0-928d-65b33b03256a"] = true,
	["Auto Attack Leviathan"] = false,
	["15407b9f-f1a3-4eb4-92b8-cc8da4411bc7"] = true,
	["Auto Change Dragonstorm With Skull Guitar"] = false,
	["Farm Mastery"] = false,
	["Auto Attack All Mob and Boss"] = false,
	["Multi Trial"] = false,
	["Auto Load Script"] = false,
	["ESP Fruit"] = false,
	["Auto Upgrade Race V2-V3"] = true,
	["Drive Boat To Tiki"] = false,
	["Auto Farm Mastery 600 Melees"] = false,
	["2635e1f2-9a07-4bc4-8aa0-9c11d7ab6f5e"] = true,
	["Fly Boat"] = false,
	["47cd1594-c36e-4ab3-b272-725b6bfc70ef"] = true,
	["Hop Server [Trial Or Pull Lever]"] = false,
	["Use Your Boat Beast Hunter"] = false,
	["Select Skills Blox Fruit"] = {
		["X"] = true,
		["C"] = true,
		["Z"] = true,
		["V"] = true,
		["F"] = true
	},
	["Select Skills Melee"] = {
		["X"] = true,
		["C"] = true,
		["Z"] = true
	},
	["Bring Mob Count"] = 2,
	["Teleport Frozen Dimension"] = false,
	["Auto Turn On Buso"] = true,
	["Black Screen"] = false,
	["Stack Train With Trial Race"] = false,
	["Auto Repair Ur Ship"] = false,
	["Ignore Attack Katakuri"] = false,
	["Hop Server Get Ghoul"] = false,
	["Webhook Find Leviathan"] = false,
	["1c8e8e9a-7342-4a25-8243-06ccab20111d"] = true,
	["401c40eb-7b59-4290-ad8f-3e3d094bc886"] = true,
	["Auto rejoin Disconnect"] = false,
	["Kill All Boss"] = false,
	["Auto Awake Fruit"] = false,
	["Bring Mob"] = true,
	["Start Farm"] = false,
	["ESP Player"] = false,
	["Hop Find Berry"] = false,
	["c54f33ff-4f3a-4810-9d32-a466979ac551"] = true,
	["8655ca2f-6b35-44fd-9a0e-20bf4810b425"] = true,
	["Attack Soul Reaper"] = false,
	["Auto Gacha Event Halloween"] = false,
	["2fbb3b52-7909-4eb3-9378-e2f3429087a4"] = true,
	["aac7b0bd-6cc8-4395-8f67-d73d3ccd48fe"] = true,
	["1f30cf62-fa66-4d0e-924f-b2b484419425"] = true,
	["Webhook Destroy IDK"] = false,
	["Auto Find Mirage"] = false,
	["Auto Choose Gears"] = false,
	["a24cefc8-de42-494a-a2d5-08ad766dfe7d"] = true,
	["Auto Event Prehistoric Island"] = false,
	["Teleport To Fruit [ Hop Server ]"] = false,
	["Webhook Find Mirage"] = false,
	["7260a8b3-2b3e-4bfd-9429-3463f66e4b9b"] = true,
	["Auto Elite Hunter"] = false,
	["b6393eee-60db-40e0-8596-b752e95db4df"] = true,
	["Auto Collect Soul Ember"] = false,
	["45365bcd-a7ca-4cc0-8a79-3f01057ddf92"] = true,
	["Health %"] = 40,
	["Noti Profile"] = false,
	["Get Fruit In Inventory Low Beli"] = false,
	["Attack Rip Indra"] = false,
	["Farm Material"] = false,
	["Ping Discord"] = false,
	["68b79f5d-5e69-4463-b674-23cb2b23c83b"] = true,
	["Teleport Acient Clock"] = false,
	["Teleport To Fruit"] = false,
	["b2fde85e-1c91-4542-9995-4f9c285e1fb2"] = true,
	["4f29017a-47b8-40ec-8886-b981eea86520"] = true,
	["9b0fb160-8e43-4695-b36e-1f8baf235cc2"] = true,
	["Farm Observation"] = false,
	["f04de7a5-86d7-4c29-89f8-268099f4e415"] = true,
	["Auto Turn On Observation"] = false,
	["Auto Sea Event With Friend"] = false,
	["71437111-4c11-433e-b086-4d1fe0726567"] = true,
	["48e636f1-bd9a-45aa-81df-3828d9f5906f"] = true,
	["Auto Chest"] = false,
	["90b1d12a-620d-4d7f-960f-12cab282a8f3"] = true,
	["4d831890-23d6-4dbc-8b47-8bf398a92f89"] = true,
	["Auto Trial Draco"] = false,
	["Auto Pirate Raid"] = false,
	["Auto Craft Item Shark Anchor"] = false,
	["Use Skill when Kill Player"] = false,
	["be0c88ff-f966-4cef-a7d4-9d1cbe5e6cd1"] = true,
	["Change Size Reel"] = false,
	["d81a0de1-3ffe-4d04-bb59-240ad4a8c12d"] = true,
	["9204a3e8-c1d7-4a8c-ab3a-4db17622d89c"] = true,
	["Auto Event Halloween"] = false,
	["Input WalkSpeed"] = 200,
	["3db22cb1-98e5-4808-bb1f-43ed41948b29"] = true,
	["c582228f-3a58-4e94-a09f-36c3cc39f92b"] = true,
	["0709e2f7-5aba-4dd0-bc78-d3289cfe185e"] = true,
	["a0e0d738-fff9-446c-921b-f4d484182faf"] = true,
	["Auto Find Prehistoric Island"] = false,
	["Auto Buy Gear"] = false,
	["b53297e9-f130-4375-ad29-46ac46e43527"] = true,
	["ec93a59e-c704-49d7-9a28-ab1093d597b4"] = true,
	["a0402a09-e2ce-44be-8563-37a6171890e8"] = true,
	["Value Damage Multi Segments"] = 30000,
	["Auto Multi Raid"] = false,
	["Auto Upgrade Race V2-V3 Draco"] = false,
	["1cc0a6bb-210a-4aa1-9278-7952e7977ec0"] = true,
	["Select Team"] = "Pirate"
}
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer 
getgenv().Key = Banana_key
loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))()
end

local function SCRIPT_B(race, key)
-- =========================
-- BANANA (CHẠY 1 LẦN)
-- =========================

task.spawn(function()
    local success, err = pcall(function()

        repeat task.wait() until game:IsLoaded()
        repeat task.wait() until game.Players.LocalPlayer

        	getgenv().Config = {
	["Auto Join Dungeon"] = false,
	["Auto Fire Shoot Heart Leviathan"] = false,
	["Select Method Aimbot"] = "Target nearest Player",
	["Noti Profile"] = false,
	["Teleport To Fruit"] = false,
	["Tween Until Have Sea Event"] = true,
	["No Frog"] = false,
	["Auto Dodge Skill Mobs"] = false,
	["Ignore Craft Volcanic Magnet"] = false,
	["Auto Trade Azure Ember"] = false,
	["Auto Present Event"] = false,
	["Auto Turn On V3"] = false,
	["Tween Boat To Frozen Dimension"] = false,
	["Change Size Reel"] = false,
	["Auto Aimbot Gun"] = false,
	["Distance Teleport Y"] = 800,
	["Auto New World"] = false,
	["Select Method Farm"] = "Farm Katakuri",
	["Drive Boat To Hydra"] = false,
	["Auto Store Gift"] = false,
	["Summon Dough King"] = false,
	["Auto Store Fruit"] = false,
	["Auto Start Leviathan"] = false,
	["Auto Sell Fishing"] = false,
	["ESP Berry"] = false,
	["Auto Farm Mastery 600 Melees"] = false,
	["Ignore Collect Bone"] = false,
	["Change WalkSpeed"] = false,
	["ESP Island"] = false,
	["Auto Pull Lever"] = true,
	["Reset Teleport"] = false,
	["Auto Buy Spy"] = false,
	["Auto Buy Boat Beast Hunter"] = false,
	["Ignore Craft Volcanic Magnet Draco"] = false,
	["Auto Destroy IDK"] = false,
	["Select Skills Sword"] = {
		["Z"] = true,
		["X"] = true
	},
	["Auto Get Rainbow Haki"] = false,
	["Boost Fps"] = false,
	["Select Material"] = "Scrap Metal",
	["Auto Spawn Kitsune Island"] = false,
	["Fully Trial Draco"] = false,
	["Change JumpPower"] = false,
	["Account Buy Chip"] = false,
	["Select Team"] = "Pirate",
	["Auto Attack Dungeon"] = false,
	["Fully Event Prehistoric Island"] = false,
	["ESP Player"] = false,
	["Hop Server Elite Hunter"] = false,
	["Auto Upgrade Sword Inventory"] = false,
	["Random Devil Fruit"] = false,
	["Use skill fast dont hold"] = false,
	["Speed Tween"] = 350,
	["Auto Trial Draco"] = false,
	["Attack Darkbeard"] = false,
	["Auto Turn On Observation"] = false,
	["Auto Collect Bone"] = false,
	["Webhook Find Prehistoric Island"] = false,
	["Value Damage Multi Segments"] = 30000,
	["Hop Server [ Haki color or Legendary Sword]"] = false,
	["Account Pick Slot Raid"] = false,
	["Use Click M1 Fruit For Sea Event"] = false,
	["Hop Sever Raid"] = false,
	["Auto Open Gift"] = false,
	["Teleport Y"] = false,
	["Auto Get Cyborg Hop Collect Chest"] = false,
	["Use Your Boat Beast Hunter"] = false,
	["Values Azure Ember"] = 10,
	["Auto Turn On V4"] = false,
	["Hop Find Katakuri"] = false,
	["Min Player Join Dungeon"] = 2,
	["Use Dragonstorm For Sea Event"] = false,
	["Auto Yoru Mini (Hop Server)"] = false,
	["Input JumpPower"] = 90,
	["Select Zone"] = "Zone 6",
	["Auto Touch Pad Haki"] = false,
	["Hop Server Kitsune Island"] = false,
	["Walk On Water "] = false,
	["Auto Pick Card Dungeon"] = false,
	["Webhook Find Mirage"] = false,
	["Auto Yoru Mini"] = false,
	["Spam Join"] = false,
	["Auto Farm Mastery 600 Sword In Inventory"] = false,
	["Summon Soul Reaper"] = false,
	["Tween Safe if have Items"] = false,
	["Auto Yama"] = false,
	["Select Weapons Fix Lava"] = {
		["Gun"] = false,
		["Sword"] = true,
		["Melee"] = true,
		["Blox Fruit"] = false
	},
	["Auto Get Ghoul"] = false,
	["Summon Darkbeard"] = false,
	["Select Method Kill Golem"] = "Click M1",
	["Auto Summon Soul Ember"] = false,
	["Auto Finish Train Quest"] = false,
	["Webhook Find Leviathan"] = false,
	["Auto Summon Rip Indra"] = false,
	["Buy Blox Fruit Sniper Shop"] = false,
	["Auto Buy Haki Color"] = false,
	["Value Speed Boat"] = 200,
	["Select Card Priority"] = {
		[1] = "Lifesteal",
		[2] = "HYPER!",
		[3] = "Melee",
		[4] = "Defense",
		[5] = "Armor",
		[6] = "Overflow",
		[7] = "Fruit",
		[8] = "All Cooldowns",
		[9] = "Sword",
		[10] = "Gun",
		[11] = "Sniper",
		[12] = "Fruit M1 Speed"
	},
	["Auto Trade Bone"] = false,
	["Auto Chest Hop"] = false,
	["Auto Get Cyborg"] = false,
	["Auto Finish Train Draco Quest"] = false,
	["Auto Turn On V3 Near Door"] = false,
	["Auto Aimbot"] = false,
	["Random Devil Fruit [ Winter ]"] = false,
	["Input WalkSpeed"] = 156.2,
	["Auto Fishing"] = false,
	["Auto Open Chest"] = false,
	["Auto Factory"] = false,
	["Attack Multi Segments Leviathan"] = false,
	["Auto Get Fully Cyborg"] = false,
	["White Screen"] = false,
	["Select Method Farm Mastery"] = "Blox Fruit",
	["Auto Saber"] = false,
	["Kill players When complete Trial"] = false,
	["Change Speed Boat"] = false,
	["Value Speed Fly Boat"] = 3,
	["Auto Buy Chip and Attack Law"] = false,
	["Attack Dough King"] = false,
	["Attack No Animation "] = true,
	["Auto Collect Egg"] = false,
	["Select Weapon Kill Golem"] = "Melee",
	["Farm Observation [ Hop Server ]"] = false,
	["Distance Farm Aura"] = 300,
	["Auto UP Observation V2"] = false,
	["Auto Soul Guitar"] = false,
	["Farm Mastery"] = false,
	["Hop Find Darkbeard"] = false,
	["Kill Mob"] = false,
	["Auto Translate"] = false,
	["Auto TTK"] = false,
	["Auto Turn On Buso"] = true,
	["Auto Upgrade Race V2-V3"] = false,
	["Auto Find Leviathan"] = false,
	["Select Skills Gun"] = {
		["Z"] = true,
		["X"] = true
	},
	["% Health Player"] = 40,
	["QuestDojo"] = false,
	["Use Click M1 Fruit Leviathan"] = false,
	["Multi Trial"] = false,
	["Auto Load Script"] = true,
	["Auto Attack Leviathan"] = false,
	["Auto Buy Legendary Sword"] = false,
	["Drive Boat To Tiki"] = false,
	["Will Back When over 10km"] = true,
	["Health %"] = 100,
	["Teleport Player"] = false,
	["Auto Attack All Mob and Boss"] = false,
	["Hop Server [Trial Or Pull Lever]"] = true,
	["Auto Collect Soul Ember"] = false,
	["Select Skills Blox Fruit"] = {
		["X"] = true,
		["C"] = true,
		["Z"] = false,
		["V"] = false,
		["F"] = false
	},
	["Select Boat"] = "Beast Hunter",
	["Bring Mob Count"] = 6,
	["Teleport Frozen Dimension"] = false,
	["Auto Third World"] = false,
	["Auto Event Prehistoric Island"] = false,
	["Use Portal Teleport"] = true,
	["Auto Repair Ur Ship"] = false,
	["Ignore Attack Katakuri"] = false,
	["Hop Server Get Ghoul"] = false,
	["Kill Boss"] = false,
	["Auto Find Mirage"] = false,
	["Stack Train With Trial Race"] = false,
	["Auto rejoin Disconnect"] = false,
	["Auto Click"] = false,
	["Auto Awake Fruit"] = false,
	["Select Weapons Use Skill"] = {
		["Sword"] = true,
		["Blox Fruit"] = true,
		["Melee"] = true,
		["Gun"] = true
	},
	["Bring Mob"] = true,
	["Farm Observation"] = false,
	["Hop Find Berry"] = false,
	["Teleport To Fruit [ Hop Server ]"] = false,
	["Auto Collect Berry"] = false,
	["Black Screen"] = false,
	["Get Fruit In Inventory Low Beli"] = false,
	["Start Farm"] = false,
	["Auto Quest [Katakuri/Bone/Tyrant]"] = false,
	["Teleport Boat Other CFrame if Rough Sea"] = false,
	["Webhook Destroy IDK"] = false,
	["Speed Boat Auto Drive"] = 300,
	["Auto Choose Gears"] = false,
	["Auto Pirate Raid"] = false,
	["Select Sea Events"] = {
		["SeaBeast"] = false,
		["Terrorshark"] = true,
		["Ship"] = false
	},
	["Auto Buy Gear Draco"] = false,
	["Account Start Dungeon"] = false,
	["Attack Soul Reaper"] = false,
	["Auto Elite Hunter"] = false,
	["Teleport To Kitsune Island"] = false,
	["ESP Fruit"] = false,
	["Time Hop Server"] = 10,
	["Auto Change Dragonstorm With Skull Guitar"] = false,
	["Teleport Acient Clock"] = false,
	["Select Skills Melee"] = {
		["X"] = true,
		["C"] = true,
		["Z"] = true
	},
	["Attack Rip Indra"] = false,
	["Fly Boat"] = false,
	["Ping Discord"] = false,
	["Value Collect Chest to Hop"] = 20,
	["Farm Material"] = false,
	["Auto Raid"] = false,
	["Reset Character Buy Boat"] = false,
	["Auto Sea Event"] = false,
	["Auto Stats"] = false,
	["Auto Dodge Skill Terrorshark"] = false,
	["Webhook Store Fruit"] = false,
	["Select Weapon Dungeon"] = "Melee",
	["Auto Sea Event With Friend"] = false,
	["Use Click M1 Skull Guitar Leviathan"] = false,
	["Auto Slap Battle"] = false,
	["Auto Chest"] = false,
	["Auto Dodge Skill Seabeast"] = false,
	["Auto Quest Dojo Trainer"] = false,
	["Kill Aura With DragonStorm"] = false,
	["Auto Tushita"] = false,
	["Auto Craft Item Shark Anchor"] = false,
	["Use Skill when Kill Player"] = false,
	["Auto Trial"] = false,
	["Auto Quest Dragon Hunter"] = false,
	["Auto Reset Character"] = false,
	["Remove Notifications"] = false,
	["Use Click M1 Skull Guitar For Sea Event"] = false,
	["Auto CDK"] = false,
	["Auto Crafting Volcanic Magnet"] = false,
	["Noclip"] = false,
	["Auto Tween To Event Fishing Spot"] = false,
	["Kill All Boss"] = false,
	["Auto Find Prehistoric Island"] = false,
	["Auto Buy Gear"] = false,
	["Auto Upgrade Gun Inventory"] = false,
	["Auto Multi Raid"] = false,
	["Hop Find Dough King"] = false,
	["Just Use Skill when Player Active Ken"] = false,
	["Multi Find Leviathan"] = false,
	["Auto Upgrade Race V2-V3 Draco"] = false,
	["Auto Accept Quest Fishing"] = false,
	["Hop Server Find Boss"] = false
}
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer 
getgenv().Key = Banana_key
loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))()
    end)

    if not success then
        warn("Banana error:", err)
    end
end)


-- =========================
-- SEA 3 LOOP (30 GIÂY)
-- =========================

task.spawn(function()
    while true do
        local success, err = pcall(function()
            loadstring(game:HttpGet(
                "https://raw.githubusercontent.com/phongdeptraur/pho/refs/heads/main/tpsea3.lua"
            ))()
        end)

        if not success then
            warn("Sea3 error:", err)
        else
            print("Sea3 executed")
        end

        task.wait(10)
    end
end)

end

local function SCRIPT_C(race, key)
	local player = game.Players.LocalPlayer -- Chỉ dùng trong LocalScript
-- Hoặc xác định player trong Server Script thông qua sự kiện

player:Kick("Đã lên V3")
end

local function SCRIPT_D(race, targetRace)
	-- Chọn Race bạn muốn dừng lại: "Human", "Fishman", "Skypiea", "Mink"
local TargetRace = targetRace

local function GetCurrentRace()
    return game.Players.LocalPlayer.Data.Race.Value
end

local function AutoReroll()
    local remote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")
    
    while GetCurrentRace() ~= TargetRace do
        local fragments = game.Players.LocalPlayer.Data.Fragments.Value
        
        if fragments < 3000 then
            print("Dừng lại: Không đủ 3,000 Fragments!")
            break
        end

        print("Race hiện tại: " .. GetCurrentRace() .. ". Đang đổi tiếp...")
        
        -- Thực hiện lệnh đổi Race từ NPC Tort
        remote:InvokeServer("BlackbeardReward", "Reroll", "2")
        
        -- Chờ một chút để tránh bị hệ thống Anti-cheat phát hiện spam
        task.wait(1.5) 
        
        if GetCurrentRace() == TargetRace then
            print("Chúc mừng! Bạn đã đạt được Race: " .. TargetRace)
            break
        end
    end
end

-- Bắt đầu chạy
AutoReroll()
end

local function SCRIPT_E(race)
	local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local buyRemote = game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_")

-- Cấu hình
local speed = 350
local tpPos = Vector3.new(-5021.03, 314.56, -3195.72) -- Điểm TP đệm

-- Danh sách Place ID Sea 3
local sea3Places = {
    [100117331123089] = true,
    [7449423635] = true
}

-- Xác định tọa độ đích cuối cùng
local finalPos
if sea3Places[game.PlaceId] then
    finalPos = Vector3.new(-4975.19, 314.56, -3223.04)
else
    finalPos = Vector3.new(-2601.75, 239.11, -10314.71)
end

-- HÀM THỰC HIỆN
local function startProcess()

    -- Nếu ở Sea 3 thì mới dùng TP đệm
    if sea3Places[game.PlaceId] then
        
        print("Đang cố gắng TP đến điểm đệm...")
        
        local distToTp = math.huge
        
        repeat
            rootPart.CFrame = CFrame.new(tpPos)
            task.wait(0.5)
            distToTp = (rootPart.Position - tpPos).Magnitude
            
            if distToTp > 10 then
                print("Phát hiện Lag Back tại điểm đệm! Đang thử lại...")
            end
            
        until distToTp <= 10

        print("Đã đứng vững tại điểm đệm. Đợi 1 giây trước khi Tween...")
        task.wait(1)

    else
        print("Không phải Sea 3 -> Bỏ bước TP đệm, tween thẳng.")
    end


    -- ===== BƯỚC TWEEN =====
    
    local distance = (rootPart.Position - finalPos).Magnitude
    local duration = distance / speed
    
    local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = CFrame.new(finalPos)})
    
    local bv = Instance.new("BodyVelocity")
    bv.Velocity = Vector3.new(0,0,0)
    bv.MaxForce = Vector3.new(9e9,9e9,9e9)
    bv.Parent = rootPart
    
    tween:Play()
    
    tween.Completed:Connect(function()
        bv:Destroy()
        task.wait(0.5)
        
        local finalDist = (rootPart.Position - finalPos).Magnitude
        
        if finalDist > 10 then
            print("Lag Back khi Tween! Thực hiện lại...")
            startProcess()
        else
            print("Đã đến đích. Đang mua Sharkman...")
            
            if buyRemote then
                buyRemote:InvokeServer("BuySharkmanKarate")
            end
        end
    end)

end

-- Kích hoạt script
startProcess()
end

-- ✅ F chạy 1 lần và khóa toàn bộ route còn lại
local function SCRIPT_F(race, targetRace, fragments)
	getgenv().Config = {
	["f7b39f4f-f811-4a8e-8b73-b352567cc2cf"] = true,
	["b0ed83e0-399c-4e3f-80d3-c3fb7d8242bf"] = true,
	["aefc8138-1d14-4cde-b91a-5fcd90448eac"] = true,
	["5f76706b-0cd1-40c2-9e0c-f1971b032fd6"] = true,
	["24d5d7ac-204c-49d5-8d24-e2ba861ad152"] = true,
	["Auto Finish Train Draco Quest"] = false,
	["Auto Dodge Skill Seabeast"] = false,
	["c24385cb-c4a5-428c-acea-a41e532bb429"] = true,
	["ea166fcf-708f-4556-93ce-980ce9393026"] = true,
	["e0573f95-e29c-46fc-80e0-ea3c72555d52"] = true,
	["Ignore Craft Volcanic Magnet"] = false,
	["Auto Trade Azure Ember"] = false,
	["18d3e9ae-4e44-4dba-a57c-fa019356dcdd"] = true,
	["Value Speed Fly Boat"] = 3,
	["Auto Upgrade Gun Inventory"] = false,
	["Fully Event Prehistoric Island"] = false,
	["Auto Aimbot Gun"] = false,
	["Auto New World"] = false,
	["Drive Boat To Hydra"] = false,
	["Auto Summon Soul Ember"] = false,
	["Summon Dough King"] = false,
	["Auto Store Fruit"] = false,
	["b8dff701-6974-47c6-8922-a1579d6f59ab"] = true,
	["Auto Sell Fishing"] = false,
	["Auto Get Fully Cyborg"] = false,
	["Use Click M1 Skull Guitar Leviathan"] = false,
	["ESP Island"] = false,
	["Multi Find Leviathan"] = false,
	["Auto Buy Boat Beast Hunter"] = false,
	["Auto Get Rainbow Haki"] = false,
	["Boost Fps"] = false,
	["148fe9d6-7b4c-4c00-9b67-cfd76175c81b"] = true,
	["Random Devil Fruit [ Summer Token ]"] = false,
	["Auto Spawn Kitsune Island"] = false,
	["3d19767d-3858-428c-841d-7bb7e5ec5549"] = true,
	["Change JumpPower"] = false,
	["5632df90-ddea-46d6-9899-8d77ab94c3e7"] = true,
	["Hop Server Elite Hunter"] = false,
	["Auto Upgrade Sword Inventory"] = false,
	["Random Devil Fruit"] = false,
	["Auto Aimbot"] = false,
	["Teleport Y"] = false,
	["ad3940da-8a01-4014-893e-8c1101a04a0a"] = true,
	["Auto Tween To Event Fishing Spot"] = false,
	["Noclip"] = false,
	["Hop Find Katakuri"] = true,
	["Use Dragonstorm For Sea Event"] = false,
	["Auto Touch Pad Haki"] = false,
	["Attack Dough King"] = false,
	["Auto Yoru Mini"] = false,
	["Tween Safe if have Items"] = false,
	["Auto Get Ghoul"] = false,
	["Auto Finish Train Quest"] = false,
	["9219f102-5b9c-49a9-96a1-8dfec2bd1eb6"] = true,
	["Auto Chest Hop"] = false,
	["Auto Get Cyborg"] = false,
	["Auto Turn On V3 Near Door"] = false,
	["5b69f1eb-9d2f-48f7-9e46-305db2e95006"] = true,
	["Auto Factory"] = false,
	["White Screen"] = false,
	["Auto Dodge Skill Terrorshark"] = false,
	["Farm Observation [ Hop Server ]"] = false,
	["Kill Mob"] = false,
	["Auto TTK"] = false,
	["7f1d5a55-b845-4546-a86e-fca8d526e558"] = true,
	["Use Click M1 Fruit Leviathan"] = false,
	["Auto Raid"] = false,
	["% Health Player"] = 40,
	["Teleport Player"] = false,
	["Auto Quest [Katakuri/Bone/Tyrant]"] = false,
	["Kill Boss"] = false,
	["596e004f-a7d6-4c79-a013-ea5cbd1d8067"] = true,
	["Auto Click"] = false,
	["Teleport Boat Other CFrame if Rough Sea"] = false,
	["Speed Boat Auto Drive"] = 300,
	["Auto Collect Berry"] = false,
	["Auto Buy Gear Draco"] = false,
	["1070d2ca-2ccf-49ae-9862-0bf2f8e94c90"] = true,
	["Teleport To Kitsune Island"] = false,
	["Time Hop Server"] = 10,
	["d4a5733b-b380-4c47-b1c0-05d78f4b40ac"] = true,
	["Will Back When over 10km"] = false,
	["Use Portal Teleport"] = false,
	["29f3815d-2270-4f5b-9484-0378ed8ff70e"] = true,
	["Select Skills Gun"] = {
		["X"] = true,
		["Z"] = true
	},
	["Auto Find Leviathan"] = false,
	["Value Collect Chest to Hop"] = 20,
	["Auto Sea Event"] = false,
	["Auto Stats"] = false,
	["eec8dffb-04ef-4d24-93f9-709f46353b6d"] = true,
	["d6f9d7a8-62b5-4a85-b5b5-b077bd301481"] = true,
	["Kill Aura With DragonStorm"] = false,
	["Auto Quest Dragon Hunter"] = false,
	["Remove Notifications"] = false,
	["Use Click M1 Skull Guitar For Sea Event"] = false,
	["Auto CDK"] = false,
	["Auto Crafting Volcanic Magnet"] = false,
	["41ffe321-9b95-4593-8773-66f5ae517153"] = true,
	["Hop Sever Raid"] = false,
	["Hop Find Dough King"] = false,
	["Speed Tween"] = 350,
	["cffa602a-eced-4340-9446-b8733f264c9a"] = true,
	["Auto Join Dungeon"] = false,
	["Attack Darkbeard"] = false,
	["No Frog"] = false,
	["Auto Dodge Skill Mobs"] = false,
	["65fddf8d-0268-4e69-b46d-7cec3d486af2"] = true,
	["Auto Turn On V3"] = false,
	["Tween Boat To Frozen Dimension"] = false,
	["e52b4b01-2d1c-43ad-8bb9-44334e7bf82b"] = true,
	["Distance Teleport Y"] = 800,
	["Select Method Farm"] = "Farm Katakuri",
	["Just Use Skill when Player Active Ken"] = false,
	["7659fc04-3df8-41f2-b53f-5f4505ccfee9"] = true,
	["Auto Start Leviathan"] = false,
	["ESP Berry"] = false,
	["Ignore Collect Bone"] = false,
	["Change WalkSpeed"] = false,
	["Kill Aura Mob Halloween"] = false,
	["Auto Fishing"] = false,
	["Auto Quest Dojo Trainer"] = false,
	["Auto Tushita"] = false,
	["Ignore Craft Volcanic Magnet Draco"] = false,
	["Auto Destroy IDK"] = false,
	["Select Skills Sword"] = {
		["X"] = true,
		["Z"] = true
	},
	["5afaf96f-afcc-4e9b-a397-94be0d925e37"] = true,
	["Fully Trial Draco"] = false,
	["Auto Trial"] = false,
	["Account Buy Chip"] = false,
	["1f02870f-295f-4142-a189-015285f2445d"] = true,
	["Kill players When complete Trial"] = false,
	["Use skill fast dont hold"] = false,
	["8e7eec0d-3304-4f23-aa82-c4de25654312"] = true,
	["4c76bc86-5b48-470a-96c2-2d956379b392"] = true,
	["Auto Collect Bone"] = false,
	["Webhook Find Prehistoric Island"] = false,
	["Use Click M1 Fruit For Sea Event"] = false,
	["Values Azure Ember"] = 10,
	["Auto Turn On V4"] = false,
	["dcb7aa7c-a210-4bef-a24d-aeba25d4de1a"] = true,
	["Input WalkSpeed"] = 200,
	["Hop Server Kitsune Island"] = false,
	["Walk On Water "] = true,
	["Auto Pick Card Dungeon"] = false,
	["Spam Join"] = false,
	["Auto Farm Mastery 600 Sword In Inventory"] = false,
	["Summon Soul Reaper"] = false,
	["Auto Yama"] = false,
	["Summon Darkbeard"] = false,
	["Value Speed Boat"] = 200,
	["Auto Pull Lever"] = false,
	["Auto Attack Dungeon"] = false,
	["Auto Summon Rip Indra"] = false,
	["Reset Teleport"] = true,
	["333ae971-345b-4b2b-b152-9f4f9c57aa3e"] = true,
	["9b7cf0fb-2118-4769-9c70-73a184b3cceb"] = true,
	["Auto Trade Bone"] = false,
	["2dbe8e5e-8702-4b70-846a-adf89a4a90a3"] = true,
	["Auto Yoru Mini (Hop Server)"] = false,
	["4d831890-23d6-4dbc-8b47-8bf398a92f89"] = true,
	["c2787218-a631-4f2e-b650-abcaa9d888d9"] = true,
	["Auto Pirate Raid"] = false,
	["0af95a38-2345-4c3e-baf1-44a4fec98dd0"] = true,
	["c37b3a30-cbd0-44b2-9783-fe3c61c94878"] = true,
	["c582228f-3a58-4e94-a09f-36c3cc39f92b"] = true,
	["Auto Open Chest"] = false,
	["Farm Observation"] = false,
	["Attack Multi Segments Leviathan"] = false,
	["35a625b6-f0d2-42ff-988b-810bc8891555"] = true,
	["0772a898-d45f-4ad5-b38d-bae50d874f71"] = true,
	["3ee0a5b3-f589-4805-8a15-65d289796859"] = true,
	["Auto Saber"] = false,
	["Auto Collect Egg"] = false,
	["Change Speed Boat"] = false,
	["a24cefc8-de42-494a-a2d5-08ad766dfe7d"] = true,
	["Auto Buy Chip and Attack Law"] = false,
	["Noti Profile"] = false,
	["Teleport To Fruit"] = false,
	["Auto Turn On Observation"] = false,
	["4f29017a-47b8-40ec-8886-b981eea86520"] = true,
	["15407b9f-f1a3-4eb4-92b8-cc8da4411bc7"] = true,
	["Distance Farm Aura"] = 300,
	["Auto UP Observation V2"] = false,
	["Auto Soul Guitar"] = false,
	["Auto Trial Draco"] = false,
	["Hop Find Darkbeard"] = false,
	["7aaad928-8be8-478d-884f-eab34f3687ce"] = true,
	["Auto Translate"] = false,
	["a0e0d738-fff9-446c-921b-f4d484182faf"] = true,
	["def45387-3c52-4108-972d-14ced2b926dd"] = true,
	["Use Your Boat Beast Hunter"] = false,
	["Auto Buy Spy"] = false,
	["Auto Load Script"] = true,
	["Buy Blox Fruit Sniper Shop"] = false,
	["Farm Mastery"] = false,
	["e44b3672-0f27-412f-8796-c57a6cc8ccad"] = true,
	["Multi Trial"] = false,
	["Auto Turn On Buso"] = true,
	["Auto Buy Haki Color"] = false,
	["Auto Upgrade Race V2-V3"] = false,
	["Drive Boat To Tiki"] = false,
	["8655ca2f-6b35-44fd-9a0e-20bf4810b425"] = true,
	["2635e1f2-9a07-4bc4-8aa0-9c11d7ab6f5e"] = true,
	["Attack Soul Reaper"] = false,
	["Black Screen"] = false,
	["Hop Server [Trial Or Pull Lever]"] = false,
	["b2fde85e-1c91-4542-9995-4f9c285e1fb2"] = true,
	["Select Skills Blox Fruit"] = {
		["X"] = true,
		["C"] = true,
		["Z"] = true,
		["F"] = true,
		["V"] = true
	},
	["Stack Train With Trial Race"] = false,
	["Bring Mob Count"] = 2,
	["Teleport To Fruit [ Hop Server ]"] = false,
	["Auto Awake Fruit"] = false,
	["Auto Event Prehistoric Island"] = false,
	["Value Damage Multi Segments"] = 30000,
	["Auto Repair Ur Ship"] = false,
	["Ignore Attack Katakuri"] = false,
	["Account Start Dungeon"] = false,
	["Teleport Frozen Dimension"] = false,
	["1c8e8e9a-7342-4a25-8243-06ccab20111d"] = true,
	["401c40eb-7b59-4290-ad8f-3e3d094bc886"] = true,
	["Auto rejoin Disconnect"] = false,
	["Fly Boat"] = false,
	["Auto Find Mirage"] = false,
	["Bring Mob"] = true,
	["Input JumpPower"] = 200,
	["Select Skills Melee"] = {
		["X"] = true,
		["C"] = true,
		["Z"] = true
	},
	["Hop Find Berry"] = false,
	["Get Fruit In Inventory Low Beli"] = false,
	["Health %"] = 40,
	["c54f33ff-4f3a-4810-9d32-a466979ac551"] = true,
	["Auto Collect Soul Ember"] = false,
	["Start Farm"] = true,
	["aac7b0bd-6cc8-4395-8f67-d73d3ccd48fe"] = true,
	["1f30cf62-fa66-4d0e-924f-b2b484419425"] = true,
	["Webhook Destroy IDK"] = false,
	["Auto Gacha Event Halloween"] = false,
	["Auto Choose Gears"] = false,
	["Webhook Find Leviathan"] = false,
	["Kill All Boss"] = false,
	["Change Size Reel"] = false,
	["ESP Player"] = false,
	["Hop Server [ Haki color or Legendary Sword]"] = false,
	["Auto Elite Hunter"] = false,
	["Auto Event Halloween"] = false,
	["ESP Fruit"] = false,
	["Auto Attack All Mob and Boss"] = false,
	["Auto Change Dragonstorm With Skull Guitar"] = false,
	["Auto Reset Character"] = false,
	["Auto Attack Leviathan"] = false,
	["Attack Rip Indra"] = false,
	["Farm Material"] = false,
	["Ping Discord"] = false,
	["Hop Server Get Ghoul"] = false,
	["Auto Fire Shoot Heart Leviathan"] = false,
	["Webhook Find Mirage"] = false,
	["Reset Character Buy Boat"] = false,
	["Account Pick Slot Raid"] = false,
	["Auto Multi Raid"] = false,
	["2fbb3b52-7909-4eb3-9378-e2f3429087a4"] = true,
	["Webhook Store Fruit"] = false,
	["Auto Farm Mastery 600 Melees"] = false,
	["Auto Sea Event With Friend"] = false,
	["91a94ed3-9e63-4231-a6a9-ea0f10074799"] = true,
	["48e636f1-bd9a-45aa-81df-3828d9f5906f"] = true,
	["Auto Chest"] = false,
	["Auto Third World"] = false,
	["Teleport Acient Clock"] = false,
	["Attack No Animation "] = true,
	["3d7c9ae8-9558-4efa-b1e5-c36166940da5"] = true,
	["Auto Craft Item Shark Anchor"] = false,
	["Use Skill when Kill Player"] = false,
	["Auto Buy Legendary Sword"] = false,
	["Auto Slap Battle"] = false,
	["Tween Until Have Sea Event"] = false,
	["9204a3e8-c1d7-4a8c-ab3a-4db17622d89c"] = true,
	["9b0fb160-8e43-4695-b36e-1f8baf235cc2"] = true,
	["Auto Get Cyborg Hop Collect Chest"] = false,
	["c39e010a-a31f-4b65-968d-6ab21b5ca978"] = true,
	["2fd69165-01e1-49da-ae68-b1f2b4eb7e59"] = true,
	["90b1d12a-620d-4d7f-960f-12cab282a8f3"] = true,
	["7db9f5cb-ca12-45f0-a049-f3712c946ebf"] = true,
	["Auto Find Prehistoric Island"] = false,
	["Auto Buy Gear"] = false,
	["53008ccd-60ae-4a38-996e-ccd758014e15"] = true,
	["ec93a59e-c704-49d7-9a28-ab1093d597b4"] = true,
	["7260a8b3-2b3e-4bfd-9429-3463f66e4b9b"] = true,
	["Random Devil Fruit [ Winter ]"] = false,
	["Min Player Join Dungeon"] = 2,
	["Auto Upgrade Race V2-V3 Draco"] = false,
	["Auto Accept Quest Fishing"] = false,
	["Hop Server Find Boss"] = false
}
repeat wait() until game:IsLoaded() and game.Players.LocalPlayer 
repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players and game.Players.LocalPlayer

local Players = game:GetService("Players")
local lp = Players.LocalPlayer


local ALLOWED = {
    [100117331123089] = true,
    [7449423635] = true,
}


local function runScriptA()
    
repeat wait() until game:IsLoaded()

local player = game.Players.LocalPlayer


local function TeleportToSea3()
    
    game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("TravelZou")
end


TeleportToSea3()

    warn("[A] Script A executed (invalid PlaceId)")
end


local currentPlaceId = game.PlaceId

if not ALLOWED[currentPlaceId] then
    warn("[PLACE] Invalid PlaceId =", currentPlaceId, "-> run Script A")
    runScriptA()
else
    warn("[PLACE] Valid PlaceId =", currentPlaceId, "-> skip Script A")
end
wait(2)
getgenv().Key = Banana_key
loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaHub.lua"))() 

end

repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players and game.Players.LocalPlayer

local Players           = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui           = game:GetService("CoreGui")

local lp    = Players.LocalPlayer
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

wait(5)
task.spawn(function()
	task.wait(1)
	pcall(function()
		CommF:InvokeServer("SetTeam", TEAM_NAME)
	end)
end)


repeat task.wait() until lp.Character
repeat task.wait() until lp.Character:FindFirstChild("HumanoidRootPart")
repeat task.wait() until lp:FindFirstChild("Backpack")


pcall(function()
	if CoreGui:FindFirstChild("RaceV3RouterUI") then
		CoreGui.RaceV3RouterUI:Destroy()
	end
end)

local gui = Instance.new("ScreenGui", CoreGui)
gui.Name = "RaceV3RouterUI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromOffset(360, 180)
frame.Position = UDim2.fromOffset(20, 140)
frame.BackgroundColor3 = Color3.fromRGB(22,22,26)
frame.BorderSizePixel = 0
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

local function label(text, y, h, size)
	local l = Instance.new("TextLabel", frame)
	l.Size = UDim2.new(1,-12,0,h)
	l.Position = UDim2.fromOffset(6,y)
	l.BackgroundTransparency = 1
	l.Font = Enum.Font.Gotham
	l.TextSize = size
	l.TextColor3 = Color3.fromRGB(220,230,255)
	l.TextXAlignment = Enum.TextXAlignment.Left
	l.TextWrapped = true
	l.Text = text
	return l
end

label("Race / V3 Router (ONE-SHOT A~E, TERMINAL F)", 6, 26, 14)
local status = label("Status: Ready", 38, 22, 13)
local mode   = label("Mode: Idle", 62, 60, 12)
local function DEBUG(msg)
	print("[DEBUG]", msg)
	mode.Text = "Mode: " .. tostring(msg)
end

local function STATUS(msg)
	print("[STATUS]", msg)
	status.Text = "Status: " .. tostring(msg)
end

local unload = Instance.new("TextButton", frame)
unload.Size = UDim2.fromOffset(90, 28)
unload.Position = UDim2.new(1, -100, 1, -36)
unload.Text = "UNLOAD"
unload.Font = Enum.Font.GothamBold
unload.TextSize = 12
unload.BackgroundColor3 = Color3.fromRGB(160,60,60)
unload.TextColor3 = Color3.fromRGB(255,230,230)
unload.BorderSizePixel = 0
Instance.new("UICorner", unload).CornerRadius = UDim.new(0,8)


local function getRace()
	return lp:WaitForChild("Data"):WaitForChild("Race").Value
end

local function getFragments()
	local f = lp:WaitForChild("Data"):FindFirstChild("Fragments")
	return f and f.Value or 0
end

local function backpackHas(name)
	return lp.Backpack:FindFirstChild(name) ~= nil
end

local V3_SKILL = {
	Human   = "Last Resort",
	Mink    = "Agility",
	Fishman = "Water Body",
	Shark   = "Water Body",
	Angel   = "Heavenly Blood",
	Ghoul   = "Domain Expansion",
	Cyborg  = "Energy Core",
}

local function detectV3(race)
	local key = V3_SKILL[race]
	if not key then return false, nil end
	if lp.Backpack:FindFirstChild(key) or lp.Character:FindFirstChild(key) then
		return true, key
	end
	return false, key
end

local RUNNING      = true
local F_TERMINATED = false


local ranA, ranB, ranC, ranD, ranE, ranF = false, false, false, false, false, false


local initialChecked = false
local lastV3State = nil

local function runOnce(tag, flagName, fn, ...)
	status.Text = "Status: " .. tag

	local already = false
	if flagName == "A" then already = ranA
	elseif flagName == "B" then already = ranB
	elseif flagName == "C" then already = ranC
	elseif flagName == "D" then already = ranD
	elseif flagName == "E" then already = ranE
	elseif flagName == "F" then already = ranF
	end

	if already then
		status.Text = "Status: Skipped " .. tag .. " (already ran)"
		return false
	end

	if flagName == "A" then ranA = true
	elseif flagName == "B" then ranB = true
	elseif flagName == "C" then ranC = true
	elseif flagName == "D" then ranD = true
	elseif flagName == "E" then ranE = true
	elseif flagName == "F" then ranF = true
	end

	status.Text = "Status: Running " .. tag .. " (one-shot)"
	DEBUG("Running route " .. tag)

	pcall(fn, ...)
	return true
end

unload.MouseButton1Click:Connect(function()
	DEBUG("Script unloaded")
	RUNNING = false
	gui:Destroy()
end)

while RUNNING do
	DEBUG("Main loop running")

	if F_TERMINATED then
		mode.Text = "Mode: TERMINATED (F) — no more routes"
		task.wait(1)
		continue
	end

local realRace  = getRace()
local frags     = getFragments()

DEBUG("Race=" .. tostring(realRace) .. " | Frags=" .. tostring(frags))

-- Nếu bật ENABLE_ROLL_RACE thì coi như đã đạt target
local race = realRace



	local needF = false

-- Nếu roll đang bật và đang sai race
if ENABLE_ROLL_RACE and race ~= TARGET_RACE then
    needF = (frags < FRAG_ROLL_RACE)
end

-- Nếu đã đúng race (hoặc roll bị tắt)
if race == TARGET_RACE or not ENABLE_ROLL_RACE then
    needF = (frags < FRAG_PULL)
end

if needF then
	DEBUG("Entering ROUTE F")

	mode.Text = "Mode: F (terminal) | race=" .. race .. " | frags=" .. tostring(frags)
		runOnce("F", "F", SCRIPT_F, race, TARGET_RACE, frags)
		F_TERMINATED = true
		task.wait(CHECK_INTERVAL)
		continue
	end

	if TARGET_RACE == "Fishman" then
		local isFish = (race == "Fishman" or race == "Shark")
		if isFish and not backpackHas("Sharkman Karate") then
			mode.Text = "Mode: E (Fishman missing Sharkman Karate)"
			runOnce("E", "E", SCRIPT_E, race)
			task.wait(CHECK_INTERVAL)
			continue
		end
	end


if race ~= TARGET_RACE then

    -- Nếu roll bị tắt → coi như đã đạt race
    if not ENABLE_ROLL_RACE then
        mode.Text = "Mode: Roll Disabled (Treat as Target)"
        -- không continue ở đây
    else
        -- Roll đang bật
        if frags < FRAG_ROLL_RACE then
            mode.Text = "Mode: F (Not enough frag to roll)"
            runOnce("F", "F", SCRIPT_F, race, TARGET_RACE, frags)
        else
            mode.Text = "Mode: D (Rolling race)"
            runOnce("D", "D", SCRIPT_D, race, TARGET_RACE)
        end

        task.wait(CHECK_INTERVAL)
        continue
    end
end


	local isV3Now, key = detectV3(race)

	if not initialChecked then
		initialChecked = true
		lastV3State = isV3Now

		if isV3Now then
			mode.Text = "Mode: B (V3 initial)"
			runOnce("B", "B", SCRIPT_B, race, key)
		else
			mode.Text = "Mode: A (NOT V3 initial)"
			runOnce("A", "A", SCRIPT_A, race, key)
		end

		task.wait(CHECK_INTERVAL)
		continue
	end

	-- transition: NOT V3 -> V3 => C (one-shot)
	if (isV3Now == true) and (lastV3State == false) then
		mode.Text = "Mode: C (became V3)"
		runOnce("C", "C", SCRIPT_C, race, key)
	elseif isV3Now then
		mode.Text = "Mode: B (V3)"
		runOnce("B", "B", SCRIPT_B, race, key)
	else
		mode.Text = "Mode: A (NOT V3)"
		runOnce("A", "A", SCRIPT_A, race, key)
	end

	lastV3State = isV3Now
	task.wait(CHECK_INTERVAL)
end
