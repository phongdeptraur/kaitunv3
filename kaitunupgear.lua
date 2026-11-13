--[[
    ========================================================================================
    6V4 AUTO UPGEAR ORCHESTRATOR - PRODUCTION RELEASE
    ========================================================================================
    Orchestration: Antigravity Swarm Architecture (Coordinator, Coder, Debugger, Fixer)
    Target: All-in-one Blox Fruits Race Awakening (V4) fully autonomous orchestration.
    Environment: Autoexec execution across all accounts (3 Support Accounts + 22 Clone Accounts).

    COMPLETE SPECIFICATION & ARCHITECTURAL HIGHLIGHTS:
    1. Sea & Progression Handling:
       - Detects Sea 2 vs Sea 3 automatically.
       - Missing V3 in Sea 3: Teleports to Sea 2 (TravelDressrosa) where Arowe NPC is located.
       - In Sea 2: Executes race-specific V3 script until V3 ability tool is acquired.
       - Returns to Sea 3 (TravelZou) to pull Temple lever (CheckTempleDoor).
       - Executes race pull lever script if lever is unpulled.
    2. Support Architecture:
       - Waits for Clones to discover Moon servers; coordinates on designated main server.
       - Strict Verification: Verifies EXACTLY 2 eligible supports + at least 1 clone are present
         in game:GetService("Players") before running Maru V4 hub.
       - Anti-3-Support conflict: If >= 3 supports enter a server, the redundant 3rd support
         (or duplicate race support) immediately clears moon state and hops low to Great Tree.
       - Moon Protection: Support NEVER jumps to backup server while moon in current server is active!
         Once main server moon concludes (ST.m == 0), Support seamlessly switches to the backup moon server.
    3. Clone Consensus Architecture:
       - 2-Moon Consensus: Backup server must end >5 minutes after main OR be near full moon (m == 1).
       - Hopping loop: Clones keep hopping low until 2 moon servers are confirmed in the swarm lock.
       - Dead Time Window: Real-world time X:00:00 to X:09:59 idles at Great Tree (stops hopping).
       - State Transition Refresh: Automatically triggers hop low when transitioning train -> trial
         (ready for moon) or trial -> train (needs training server) to prevent stale state.
       - Maru V4 execution once in server with confirmed supports and full moon.
    4. In-Game Door Tracking (Zero V3 Trigger):
       - Pure 3D Euclidean distance check (< 35 studs to door CFrame).
       - Strictly DOES NOT trigger race V3 ability (no key presses, no ability remote activations).
       - Tracks door arrival timestamps directly in heartbeat status (no per-server file bloat).
    5. Synchronization & Anti-Collision:
       - Uses minimal sync files (st_<Name>.json, moon_lock.json, bl.json).
       - Dedicated atomic train lock (train_lock_<JobId>.json) prevents multiple accounts from
         colliding or training in the same server simultaneously.
    6. Modern Sleek GUI:
       - High-definition dark card GUI (530x390px, rounded corners, subtle border, header divider).
       - Live displays: accurate Tier V4 (Data.Race.C/Tier), live remote train status (UpgradeRace Check),
         locked support race, target race, current race, V3 status, pull lever status, moon countdown,
         and formatted color-coded account roster.
    7. Robustness & Debug Tracing:
       - Abundant [6V4-DEBUG] logs and warnings for easy real-time diagnosis.
       - Noclip & AntiGravity tweening without anchoring HumanoidRootPart; continuous stall recovery.
       - Safe pcalls, timeouts, and multi-environment executor compatibility (getgenv, _G, firesignal).
    ========================================================================================
--]]

-- ========================================================================================
-- 1. CONFIGURATION & ROSTER
-- ========================================================================================
local CFG = {
    OneRaceMode   = true,     -- true = Chỉ up 1 Race chỉ định | false = Up đủ 6 Race (6V4)
    TargetOneRace = "cyborg", -- Race chỉ định khi bật OneRaceMode ("cyborg", "ghoul", "fishman", "skypiea", "mink", "human")
    Supports = {
        {"AvaHawkToxic2024", "mink"},
        {"R0gu3GigaM00n2011", "skypiea"},
        {"PrimalDarkSlime64", "ghoul"}
    }, -- {Account Name, Locked Race}
    Clones = {
        "CarrieMathis79",
        "Baylee_q4n",
        "LoganHero1233",
        "Rapid34722Keeper",
        "PamelaHaze23",
        "Julio_v7rh",
        "Sab3r_Turbo1630",
        "Mustafa_Gh0st7682",
        "MysticCrystalEcho57",
        "JaydenFox42745",
        "Julian_Queen91",
        "Lisa_Specter5542",
        "LegendaryPetraBlade5",
        "JohnSunNov13122",
        "MegaMyersGhost90922",
        "J3llyOm3ga8672",
        "SentinelMinerRogue",
        "Mystic21578Ranger",
        "Nic0Cyber1704",
        "NathalieAlvarez13",
        "IsabellaFox1722",
        "LeoReaper3494",
        "Pulse_Miner201274",
        "Saber_Lava2433",
        "ProSolomonStudio985",
        "Mavis_wsr8",
        "RuneSparkly1547",
        "Raven_MysticRunner55",
        "NoobFrankDev10771",
        "Salma_Delta3304",
        "SophiaKnight202366",
        "MustafaEchoRunner851",
        "Sara_Pixel7522",
        "Rift_Chaos9641",
        "PixelSonicPanda20172",
        "Silent10786Pilot",
        "TurboPixelBlade74",
        "SimonX7602",
        "AlphaBrendan415",
        "Amara_Nova8177",
        "Adam_VortexX1757",
        "AddisonOpa91530",
        "AriaStreamPrimal2004",
        "Chandlerhk5",
        "AlayaSalas526",
        "Apex63413Avenger",
        "Andrew_Snare5651",
        "Abigail_Lion1230",
        "Bradshaw_Sloan56115",
        "SKAT3R_Pinky",
        "Saber_Destroyer2006",
        "Salma_St3llarHunt3r8",
        "SamarDark820",
        "SanderBosse2007"
    } -- 54 Clone accounts to awaken V4
}

local ORDER = {"cyborg", "ghoul", "fishman", "skypiea", "mink", "human"}

-- Wait for Roblox engine and LocalPlayer initialization
repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer

-- Service References
local function GetService(name) return game:GetService(name) end
local Players           = GetService("Players")
local ReplicatedStorage = GetService("ReplicatedStorage")
local HttpService       = GetService("HttpService")
local VirtualUser       = GetService("VirtualUser")
local Lighting          = GetService("Lighting")
local TweenService      = GetService("TweenService")
local RunService        = GetService("RunService")
local Workspace         = workspace

local LocalPlayer = Players.LocalPlayer
local PlayerName  = LocalPlayer.Name
local PROGRESS_DIR = "6V4Progress"
pcall(makefolder, PROGRESS_DIR)

local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes", 15)
local CommF_        = RemotesFolder and RemotesFolder:WaitForChild("CommF_", 15)

-- Sea Place IDs
local SEA3_IDS = {[7449423635] = true, [100117331123089] = true}
local SEA2_IDS = {[4442272183] = true, [79091703265657] = true}

-- Spatial Coordinates
local GREAT_TREE_POS = Vector3.new(2262.59, 21.69, -6462.95)
local TEMPLE_DOORS = {
    mink    = Vector3.new(29020.66, 14889.43, -379.27),
    fishman = Vector3.new(28224.06, 14889.43, -210.59),
    cyborg  = Vector3.new(28492.41, 14894.43, -422.11),
    skypiea = Vector3.new(28967.41, 14918.08, 234.31),
    ghoul   = Vector3.new(28672.72, 14889.13, 454.60),
    human   = Vector3.new(29237.29, 14889.43, -206.95),
}

-- V3 Pull Scripts Repository & Mapping
local V3_BASE_URL = "https://raw.githubusercontent.com/phongdeptraur/kaitunv3/refs/heads/main/"
local V3_SCRIPTS = {
    human   = "autohumanv3pull",
    cyborg  = "kaituncyv3pull",
    fishman = "kaitunfishV3pull",
    ghoul   = "kaitunghoulv3pull",
    mink    = "kaitunminkV3pull",
    skypiea = "kaitunskypieav3pull"
}

local RACE_ABILITIES = {
    human   = "Last Resort",
    mink    = "Agility",
    fishman = "Water Body",
    skypiea = "Heavenly Blood",
    ghoul   = "Heightened Senses",
    cyborg  = "Energy Core"
}

-- Roster Indexing
local SUPPORTS_MAP, CLONES_MAP, ALL_ROSTER = {}, {}, {}
for _, s in ipairs(CFG.Supports) do
    SUPPORTS_MAP[s[1]] = s[2]
    table.insert(ALL_ROSTER, s[1])
end
for _, c in ipairs(CFG.Clones) do
    CLONES_MAP[c] = true
    table.insert(ALL_ROSTER, c)
end

-- Roster Gatekeeper
if not (SUPPORTS_MAP[PlayerName] or CLONES_MAP[PlayerName]) then
    print(string.format("[6V4-DEBUG][INIT] Account %s is not in Support or Clone list. Exiting orchestrator.", PlayerName))
    return
end

-- Global Orchestrator State Reset
getgenv().V4Stop = true
task.wait(1.0)
getgenv().V4Stop = false
getgenv().V4Hub  = nil

local function IsStopped() return getgenv().V4Stop == true end
local function InSea3() return SEA3_IDS[game.PlaceId] == true end
local function InSea2() return SEA2_IDS[game.PlaceId] == true end

local FRAG_MINIMUM        = 3000
local DEFAULT_GRAVITY     = Workspace.Gravity > 0 and Workspace.Gravity or 196.2

-- ========================================================================================
-- 2. LOGGING & DEBUG UTILITIES
-- ========================================================================================
local function DebugLog(tag, msg, ...)
    local formatted = string.format(msg, ...)
    print(string.format("[6V4-DEBUG][%s] %s", tag, formatted))
end

local function DebugWarn(tag, msg, ...)
    local formatted = string.format(msg, ...)
    warn(string.format("[6V4-DEBUG][%s] %s", tag, formatted))
end

-- ========================================================================================
-- 3. FILE SYSTEM & SYNC HELPERS (MINIMAL DISK FOOTPRINT)
-- ========================================================================================
local function SafeReadJson(path)
    local ok, res = pcall(function()
        if not isfile(path) then return nil end
        return HttpService:JSONDecode(readfile(path))
    end)
    return (ok and type(res) == "table") and res or {}
end

-- Đọc JSON có retry khi file đang được cửa sổ khác ghi; trả về (data, true) nếu thành công, (nil, false) nếu file đang bận
local function SafeReadJsonStrict(path, maxRetries)
    local exists = false
    pcall(function() exists = isfile(path) end)
    if not exists then
        return {}, true
    end

    local attempts = maxRetries or 4
    for i = 1, attempts do
        local ok, res = pcall(function()
            local raw = readfile(path)
            if type(raw) ~= "string" or raw == "" then
                return nil
            end
            return HttpService:JSONDecode(raw)
        end)
        if ok and type(res) == "table" then
            return res, true
        end
        if i < attempts then
            task.wait(0.02)
        end
    end
    return nil, false
end

local function SafeWriteJson(path, data)
    pcall(function()
        writefile(path, HttpService:JSONEncode(data))
    end)
end

-- Player & Character Accessors
local function GetRoot()
    local char = LocalPlayer.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function GetHumanoid()
    local char = LocalPlayer.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetCurrentRace()
    local data = LocalPlayer:FindFirstChild("Data")
    local r = data and data:FindFirstChild("Race")
    return r and tostring(r.Value):lower() or ""
end

-- Cache Helper with TTL
local memoryCache = {}
local function GetCached(key, ttl, fetchFunc)
    local entry = memoryCache[key]
    if entry and (os.clock() - entry.time < ttl) then
        return entry.value
    end
    local val = fetchFunc()
    memoryCache[key] = {time = os.clock(), value = val}
    return val
end

-- Safe Remote Invocation with Timeout
local function InvokeCFTimeout(timeoutSec, ...)
    if not CommF_ then return false, "No CommF_ remote" end
    local args = {...}
    local completed, ok, response = false, false, nil
    task.spawn(function()
        ok, response = pcall(function()
            return CommF_:InvokeServer(table.unpack(args))
        end)
        completed = true
    end)
    local t0 = os.clock()
    local limit = timeoutSec or 3.5
    while not completed and (os.clock() - t0 < limit) and not IsStopped() do
        task.wait(0.05)
    end
    if not completed then
        return false, "Remote invocation timed out"
    end
    return ok, response
end

-- ========================================================================================
-- 4. STATE INITIALIZATION & HEARTBEAT
-- ========================================================================================
local STATUS_FILE     = PROGRESS_DIR .. "/st_" .. PlayerName .. ".json"
local MOON_LOCK_FILE  = PROGRESS_DIR .. "/moon_lock.json"
local BLACKLIST_FILE  = PROGRESS_DIR .. "/bl.json"
local TRAIN_LOCK_FILE = PROGRESS_DIR .. "/train_lock_" .. game.JobId .. ".json"

local prevST = SafeReadJson(STATUS_FILE)
local ST = {
    sup      = SUPPORTS_MAP[PlayerName] ~= nil,
    race     = prevST.race or "",
    j        = game.JobId,
    rdy      = false,
    sr       = false,
    v3       = prevST.v3 or false,
    pull     = prevST.pull or false,
    tn       = false,               -- Checked directly via remote in current server
    ts       = "Chưa kiểm tra",      -- Description of trial status
    dn       = false,
    m        = 0,                   -- Moon state: 0 (none), 1 (near full), 2 (full moon)
    me       = 0,                   -- Minutes remaining until moon ends
    np       = 1,                   -- Number of players in server
    door     = false,               -- Account presence at race door
    doorTime = 0,                   -- Arrival timestamp at door (replaces door_arr file)
    ph       = "init",              -- Current orchestrator phase
    t        = os.time(),           -- Heartbeat timestamp
    jt       = os.time()            -- Join server timestamp
}

local isHopping = false
local eventTimers = {start = 0, done = 0}
local v3CacheRace = (prevST.v3 and prevST.race) or nil
local pullCache   = prevST.pull or false
local currentActiveHelpers   = {}
local totalReportedMoons     = 0
local failedJoinJobs         = {}

-- State transition tracker for train <-> trial hop low refresh
local previousTrainedState = nil

-- Check real-world dead time window (X:00:00 to X:09:59)
local function IsMoonDeadTimeWindow()
    local dt = os.date("*t")
    return dt and dt.min >= 0 and dt.min <= 9
end

-- ========================================================================================
-- 5. TRAIN ANTI-COLLISION LOCK (DEDICATED PER-SERVER ATOMIC LOCK)
-- ========================================================================================
local function ClaimTrainLock()
    local lock = SafeReadJson(TRAIN_LOCK_FILE)
    local now = os.time()
    if lock.user and lock.user ~= PlayerName and (now - (lock.t or 0) < 35) then
        DebugWarn("TRAIN-LOCK", "Server %s train lock is held by %s (%d sec ago). Cannot train here!",
            game.JobId, lock.user, now - (lock.t or 0))
        return false
    end
    SafeWriteJson(TRAIN_LOCK_FILE, {user = PlayerName, t = now})
    return true
end

local function UpdateTrainLockHeartbeat()
    local lock = SafeReadJson(TRAIN_LOCK_FILE)
    if lock.user == PlayerName then
        lock.t = os.time()
        SafeWriteJson(TRAIN_LOCK_FILE, lock)
    end
end

local function ReleaseTrainLock()
    local lock = SafeReadJson(TRAIN_LOCK_FILE)
    if lock.user == PlayerName then
        pcall(delfile, TRAIN_LOCK_FILE)
        DebugLog("TRAIN-LOCK", "Released train lock for server %s", game.JobId)
    end
end

-- ========================================================================================
-- 6. SEA TRAVEL (TRAVELZOU / TRAVELDRESSROSA)
-- ========================================================================================
local lastTravelAttempt = 0

local function TravelToSea3()
    ST.ph = "travel_sea3"
    ReleaseTrainLock()
    if os.clock() - lastTravelAttempt < 6 then return end
    lastTravelAttempt = os.clock()
    DebugLog("SEA-TRAVEL", "Requesting travel to Sea 3 (TravelZou)...")
    task.spawn(function()
        pcall(function()
            if CommF_ then CommF_:InvokeServer("TravelZou") end
        end)
    end)
end

local function TravelToSea2()
    ST.ph = "travel_sea2"
    ReleaseTrainLock()
    if os.clock() - lastTravelAttempt < 6 then return end
    lastTravelAttempt = os.clock()
    DebugLog("SEA-TRAVEL", "Account requires V3 quest (Arowe NPC). Traveling to Sea 2 (TravelDressrosa)...")
    task.spawn(function()
        pcall(function()
            if CommF_ then CommF_:InvokeServer("TravelDressrosa") end
        end)
    end)
end

-- ========================================================================================
-- 7. PROGRESSION AUDIT: TIER V4, TRAIN, V3 & PULL LEVER
-- ========================================================================================

-- Live Train Check directly via CommF_:InvokeServer("UpgradeRace", "Check")
local TrialApp = {
    RawCode     = nil,
    TrialStatus = "Chưa kiểm tra",
    IsTrained   = false,
    HasChecked  = false
}

local function UpdateTrialStatus()
    if not InSea3() then
        TrialApp.HasChecked  = false
        TrialApp.IsTrained   = false
        TrialApp.TrialStatus = "Chưa kiểm tra (chưa ở Sea 3)"
        return false
    end

    while not IsStopped() and InSea3() do
        local ok, res = InvokeCFTimeout(6.0, "UpgradeRace", "Check")
        if ok then
            -- In Blox Fruits: res == 0 or nil implies Ready for Trial (trained). Other values imply need training.
            if res == 0 or res == "0" or res == nil or res == "nil" then
                TrialApp.RawCode     = 0
                TrialApp.IsTrained   = true
                TrialApp.TrialStatus = "Ready for Trial [" .. tostring(res or "nil") .. "]"
            else
                TrialApp.RawCode     = res
                TrialApp.IsTrained   = false
                TrialApp.TrialStatus = "Need Training [" .. tostring(res) .. "]"
            end
            TrialApp.HasChecked = true
            ST.tn = TrialApp.IsTrained
            ST.ts = TrialApp.TrialStatus
            return true
        end

        DebugWarn("TRAIN-CHECK", "Check train chưa có kết quả (%s). Đang thử lại...", tostring(res))

        -- Nếu trước đó đã check thành công trong server này rồi thì giữ nguyên kết quả cũ, không ghi đè false khi lag
        if TrialApp.HasChecked then
            return true
        end

        TrialApp.RawCode     = "Wait"
        TrialApp.TrialStatus = "Đang chờ kết quả check train (" .. tostring(res) .. ")..."
        ST.ts = TrialApp.TrialStatus
        task.wait(1.0)
    end

    return TrialApp.HasChecked
end

local lastTrainCheckClock = 0
local function CheckTrained(force)
    if not InSea3() then
        TrialApp.HasChecked = false
        return false, false
    end
    local now = os.clock()
    if force or (not TrialApp.HasChecked) or (now - lastTrainCheckClock >= 2.5) then
        lastTrainCheckClock = now
        UpdateTrialStatus()
    end
    ST.ts = TrialApp.TrialStatus
    return TrialApp.IsTrained, TrialApp.HasChecked
end

-- Live Tier V4 Extraction: strictly reads Data.Race.C or Data.Race.Tier (DO NOT use Data.RaceTier!)
local function ExtractLiveV4Tier()
    local tier = "0"
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("Race") then
            local raceFolder = data.Race
            if raceFolder:FindFirstChild("C") then
                tier = tostring(raceFolder.C.Value)
            elseif raceFolder:FindFirstChild("Tier") then
                tier = tostring(raceFolder.Tier.Value)
            end
        elseif LocalPlayer:GetAttribute("Tier") then
            tier = tostring(LocalPlayer:GetAttribute("Tier"))
        end
    end)
    return tonumber(tier) or 0
end

local function GetFragments()
    local data = LocalPlayer:FindFirstChild("Data")
    local f = data and (data:FindFirstChild("Fragments") or data:FindFirstChild("Fragment"))
    return f and tonumber(f.Value) or 0
end

-- V3 check: verifies presence of the race ability tool in Backpack or Character
local function HasRaceV3()
    local r = GetCurrentRace()
    local ability = RACE_ABILITIES[r]
    if not ability then return false end

    local backpack = LocalPlayer:FindFirstChild("Backpack")
    local char = LocalPlayer.Character
    if (backpack and backpack:FindFirstChild(ability)) or (char and char:FindFirstChild(ability)) then
        v3CacheRace = r
        return true
    end
    if v3CacheRace == r then
        return true
    end
    return false
end

-- Pull lever and ready state check
local function IsAccountReady(requiredRace)
    local curRace = GetCurrentRace()
    if curRace ~= requiredRace then
        return false
    end

    local hum = GetHumanoid()
    local alive = hum and hum.Health > 0 and GetRoot() ~= nil
    if HasRaceV3() then
        ST.v3 = true
    elseif alive and LocalPlayer.Team ~= nil then
        ST.v3 = (v3CacheRace == requiredRace)
    end

    if InSea3() then
        local pulled = GetCached("check_lever", 6, function()
            local ok, res = InvokeCFTimeout(3.0, "CheckTempleDoor")
            return ok and res == true
        end)
        if pulled then
            pullCache = true
        end
        ST.pull = pullCache
    else
        ST.pull = pullCache
    end

    return (curRace == requiredRace) and ST.v3 and ST.pull
end

-- ========================================================================================
-- 8. SMOOTH MOON TIMING & SERVER BLACKLISTING
-- ========================================================================================
local BASE_TICK_RATE = 1 / 60
local anchorClock, anchorTime = nil, nil
local firstMoonChecked = false
local moonRejectedShortMoon = false
local currentMoonLabel = "Không có full moon"

local function BlacklistCurrentServer()
    local bl = SafeReadJson(BLACKLIST_FILE)
    bl[game.JobId] = os.time() + 600 -- 10 minute blacklist
    SafeWriteJson(BLACKLIST_FILE, bl)
    DebugLog("BLACKLIST", "Server %s blacklisted for 10 minutes", game.JobId)
end

local function GetSmoothClockTime()
    local rawClock = Lighting.ClockTime
    local now = os.clock()
    if not anchorClock or not anchorTime then
        anchorClock, anchorTime = rawClock, now
        return rawClock
    end
    local predicted = (anchorClock + (now - anchorTime) * BASE_TICK_RATE) % 24
    local diff = (rawClock - predicted + 12) % 24 - 12
    if math.abs(diff) > 0.25 then
        anchorClock, anchorTime = rawClock, now
        return rawClock
    else
        anchorClock = (anchorClock + diff * 0.05) % 24
        return (anchorClock + (now - anchorTime) * BASE_TICK_RATE) % 24
    end
end

local function HasTwoSupportsInServer(targetRace)
    local tr = targetRace or ST.tr
    if not tr or tr == "" then return false end
    local count = 0
    local usedRaces = {}
    for _, sInfo in ipairs(CFG.Supports) do
        local sName, sRace = sInfo[1], sInfo[2]
        if sRace ~= tr and not usedRaces[sRace] and Players:FindFirstChild(sName) then
            local st = SafeReadJson(PROGRESS_DIR .. "/st_" .. sName .. ".json")
            if type(st) == "table" and st.rdy == true and st.tn == true
                and st.ph ~= "train" and st.ph ~= "frag" and st.ph ~= "v3"
                and st.ph ~= "travel_sea3" and st.ph ~= "travel_sea2" then
                count = count + 1
                usedRaces[sRace] = true
            end
        end
    end
    return count >= 2
end

-- Returns: moonState (0=none, 1=near full, 2=full), remainingMinutes
local function CheckMoon()
    if not InSea3() then
        currentMoonLabel = "Đang ở Sea 2 (chỉ check Moon ở Sea 3)"
        return 0, 0
    end

    local sky = Lighting:FindFirstChildOfClass("Sky")
    if not sky then
        currentMoonLabel = "Đang chờ Sky load..."
        return 0, 0
    end

    local clock = GetSmoothClockTime()
    if not tostring(sky.MoonTextureId):find("9709149431") then
        firstMoonChecked = true
        currentMoonLabel = "Không có full moon"
        return 0, 0
    end

    local has2SupsHere = HasTwoSupportsInServer()
    if has2SupsHere and moonRejectedShortMoon then
        moonRejectedShortMoon = false
    end

    if moonRejectedShortMoon then
        if SUPPORTS_MAP[PlayerName] then
            currentMoonLabel = "Full Moon dưới 5p -> Bỏ qua (Support đứng chờ Moon mới)"
        else
            currentMoonLabel = "Full Moon dưới 5p -> Đã blacklist & đang hop"
        end
        return 0, 0
    end

    -- Full moon active during night hours (>= 18:00 or < 05:00)
    if clock >= 18 or clock < 5 then
        local endMin = (5 - clock) % 24
        if not firstMoonChecked then
            firstMoonChecked = true
            if endMin < 5 and not has2SupsHere then
                moonRejectedShortMoon = true
                BlacklistCurrentServer()
                DebugWarn("MOON", "Full Moon has only %.1f minutes left (< 5m). Rejecting server %s", endMin, game.JobId)
                currentMoonLabel = string.format("Full Moon còn %.1fp (dưới 5p) -> Bỏ qua!", endMin)
                return 0, 0
            end
        end
        currentMoonLabel = string.format("FULL MOON đang diễn ra! Còn %.1f phút", endMin)
        return 2, endMin
    end

    -- Approaching sunset (near full moon)
    local minToSunset = (18 - clock) % 24
    firstMoonChecked = true
    if minToSunset < 5 then
        local totalRemaining = minToSunset + 11
        currentMoonLabel = string.format("NEAR FULL MOON: còn %.1fp tối (tổng %.1fp)", minToSunset, totalRemaining)
        return 1, totalRemaining
    end

    currentMoonLabel = string.format("Full moon đã qua (còn %.1f phút mới tối)", minToSunset)
    return 0, 0
end

-- Force reset character helper for Support when trial completes
local isResettingCharacter = false
local function ForceResetCharacter()
    if isResettingCharacter then return end
    isResettingCharacter = true
    task.spawn(function()
        DebugLog("SUPPORT-RESET", "Resetting character after trial completion...")
        local t0 = os.clock()
        repeat
            pcall(function()
                local char = LocalPlayer.Character
                if char then
                    local hum = char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Health = 0 end
                    char:BreakJoints()
                end
            end)
            task.wait(0.15)
            local humNow = GetHumanoid()
        until IsStopped() or (os.clock() - t0 > 4) or (not humNow or humNow.Health <= 0)
        task.wait(2.5)
        isResettingCharacter = false
    end)
end

-- Notification watcher for trial start & completion
local processedNotifs = {}
task.spawn(function()
    while task.wait(0.15) and not IsStopped() do
        pcall(function()
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if not pg then return end
            local notifGui = pg:FindFirstChild("Notifications") or pg
            for _, label in ipairs(notifGui:GetDescendants()) do
                if label:IsA("TextLabel") then
                    local text = label.Text:lower():gsub("<[^>]->", "")
                    local isVisible = label.Visible and label.TextTransparency < 0.9
                    local key = text .. tostring(isVisible)
                    if processedNotifs[label] ~= key then
                        processedNotifs[label] = key
                        if isVisible then
                            if text:find("trials starting in") then
                                eventTimers.start = os.clock()
                                DebugLog("EVENT", "Trial starting detected!")
                            elseif text:find("all trials have been completed") or text:find("there can only be one") then
                                eventTimers.done = os.clock()
                                lastTrainCheckClock = 0 -- Force immediate re-check of train status
                                DebugLog("EVENT", "Trial completed detected! Clearing V4Hub and resetting.")
                                if SUPPORTS_MAP[PlayerName] then
                                    if getgenv().V4Hub == "gear" then
                                        getgenv().V4Hub = nil
                                        if type(getgenv().config) == "table" then
                                            getgenv().config.Enabled = false
                                        end
                                        if getgenv().AutoV4Cleanup then
                                            pcall(getgenv().AutoV4Cleanup)
                                        end
                                    end
                                    ForceResetCharacter()
                                else
                                    task.delay(8, function()
                                        if getgenv().V4Hub == "gear" then
                                            getgenv().V4Hub = nil
                                            if type(getgenv().config) == "table" then
                                                getgenv().config.Enabled = false
                                            end
                                            if getgenv().AutoV4Cleanup then
                                                pcall(getgenv().AutoV4Cleanup)
                                            end
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

-- ========================================================================================
-- 9. IN-GAME DOOR CHECKING (STRICTLY NO AUTO V3 ABILITY ACTIVATION)
-- ========================================================================================
-- This function verifies if an account is standing in front of its race temple door.
-- IMPORTANT: Pure geometric distance check (< 35 studs). Strictly DOES NOT trigger V3!
local function IsAccAtDoorInGame(accName, targetRace)
    if not InSea3() then return false end
    local plr = Players:FindFirstChild(accName)
    if not plr then return false end
    local char = plr.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not (hrp and hum and hum.Health > 0) then return false end

    local expectedRace = SUPPORTS_MAP[accName]
    if not expectedRace then
        local data = plr:FindFirstChild("Data")
        local r = data and data:FindFirstChild("Race")
        expectedRace = (r and tostring(r.Value):lower()) or targetRace
    end

    if expectedRace and TEMPLE_DOORS[expectedRace] then
        if (hrp.Position - TEMPLE_DOORS[expectedRace]).Magnitude < 35 then
            return true, expectedRace
        end
    end

    for rName, dPos in pairs(TEMPLE_DOORS) do
        if (hrp.Position - dPos).Magnitude < 35 then
            return true, rName
        end
    end
    return false
end

-- Support eligibility audit
local function IsSupportEligible(sName, statusObj, targetRace)
    local sRace = SUPPORTS_MAP[sName]
    if not sRace or sRace == targetRace then return false end
    if not statusObj then return false end
    if not statusObj.rdy then return false end
    if statusObj.tn ~= true then return false end
    if statusObj.ph == "train" or statusObj.ph == "frag" or statusObj.ph == "v3" or statusObj.ph == "travel_sea3" or statusObj.ph == "travel_sea2" then
        return false
    end
    return true
end

-- ========================================================================================
-- 10. SWARM COORDINATION & MOON ARBITRATION (2-SERVER CONSENSUS)
-- ========================================================================================
local lastValidOthersCache = {}
local function GetOthersStatus(ttl)
    local map = {}
    local now = os.time()
    for _, name in ipairs(ALL_ROSTER) do
        if name ~= PlayerName then
            local s, ok = SafeReadJsonStrict(PROGRESS_DIR .. "/st_" .. name .. ".json", 2)
            if ok and type(s) == "table" and s.t then
                lastValidOthersCache[name] = s
            else
                s = lastValidOthersCache[name]
            end
            if type(s) == "table" and s.t and (now - s.t < ttl) then
                map[name] = s
            end
        end
    end
    map[PlayerName] = ST
    return map
end

-- Detects 3 supports in current server and determines if LocalPlayer is the redundant 3rd support
local function CheckThreeSupportsInCurrentServer(others, targetRace, cleanSups)
    local supsInServer = {}
    for _, sInfo in ipairs(CFG.Supports) do
        local sName = sInfo[1]
        local st = others and others[sName]
        if Players:FindFirstChild(sName) ~= nil or (st and st.j == game.JobId) then
            table.insert(supsInServer, sName)
        end
    end

    if #supsInServer < 3 then
        return false, false
    end

    -- If LocalPlayer is a Support, determine if we are the redundant 3rd support
    if SUPPORTS_MAP[PlayerName] then
        -- 1. If our race matches target race, we cannot support
        if SUPPORTS_MAP[PlayerName] == targetRace then
            return true, true
        end
        -- 2. If cleanSups is locked to 2 other supports, we must leave
        if type(cleanSups) == "table" and #cleanSups == 2 and not table.find(cleanSups, PlayerName) then
            return true, true
        end
        -- 3. Fallback priority check
        local keptSups = {}
        for _, sInfo in ipairs(CFG.Supports) do
            local sName, sRace = sInfo[1], sInfo[2]
            if sRace ~= targetRace and #keptSups < 2 then
                table.insert(keptSups, sName)
            end
        end
        if not table.find(keptSups, PlayerName) then
            return true, true
        end
    end

    return true, false
end

-- Moon server coordinator: selects main server + valid backup server (>5 min or near full moon)
local function CoordinateMoonServer(others, targetRace)
    local now = os.time()
    local lock = SafeReadJson(MOON_LOCK_FILE)
    local bl   = SafeReadJson(BLACKLIST_FILE)

    -- Un-blacklist current server if we are in Sea 3 with active moon
    if InSea3() and ST.m > 0 and not moonRejectedShortMoon and (bl[game.JobId] or 0) >= now then
        bl[game.JobId] = nil
        SafeWriteJson(BLACKLIST_FILE, bl)
    end

    local serverMoons = {}
    local serverEnds  = {}
    local serverSups  = {}
    local currentServerDead = InSea3() and (ST.m == 0 or moonRejectedShortMoon)

    for accName, s in pairs(others) do
        if (s.m or 0) > 0 and s.j and s.j ~= "" and (bl[s.j] or 0) < now and not (currentServerDead and s.j == game.JobId) then
            serverMoons[s.j] = math.max(serverMoons[s.j] or 0, s.m)
            serverEnds[s.j]  = math.max(serverEnds[s.j] or 0, tonumber(s.me) or 0)
            if s.sup and IsSupportEligible(accName, s, targetRace) then
                serverSups[s.j] = (serverSups[s.j] or 0) + 1
            else
                serverSups[s.j] = serverSups[s.j] or 0
            end
        end
    end

    if InSea3() and ST.m > 0 and game.JobId ~= "" and not moonRejectedShortMoon then
        serverMoons[game.JobId] = math.max(serverMoons[game.JobId] or 0, ST.m)
        serverEnds[game.JobId]  = math.max(serverEnds[game.JobId] or 0, tonumber(ST.me) or 0)
        serverSups[game.JobId]  = serverSups[game.JobId] or 0
    end

    local sortedMoonJobs = {}
    for j in pairs(serverMoons) do
        table.insert(sortedMoonJobs, j)
    end
    table.sort(sortedMoonJobs, function(a, b)
        local spA = math.min(serverSups[a] or 0, 2)
        local spB = math.min(serverSups[b] or 0, 2)
        if spA ~= spB then return spA > spB end
        if serverMoons[a] ~= serverMoons[b] then return serverMoons[a] > serverMoons[b] end
        if (serverEnds[a] or 0) ~= (serverEnds[b] or 0) then return (serverEnds[a] or 0) > (serverEnds[b] or 0) end
        return a < b
    end)

    local bestJob = sortedMoonJobs[1]
    local targetJob = nil
    if lock.j and serverMoons[lock.j] and lock.tr == targetRace
        and not ((serverSups[lock.j] or 0) < 2 and bestJob and (serverSups[bestJob] or 0) >= 2) then
        targetJob = lock.j
    else
        targetJob = bestJob
    end

    local mainEndMinutes = targetJob and (serverEnds[targetJob] or 0) or 0

    -- Backup server validation: MUST end >5 minutes after main server OR be near full moon (m == 1)
    local function IsValidBackupServer(j)
        if not j or j == targetJob or not serverMoons[j] then return false end
        local bEnd  = serverEnds[j] or 0
        local bMoon = serverMoons[j] or 0
        return (bEnd >= (mainEndMinutes + 5.0)) or (bMoon == 1)
    end

    local backupJob = nil
    if lock.bj and IsValidBackupServer(lock.bj) and lock.tr == targetRace then
        backupJob = lock.bj
    else
        local bestBackup, bestEnd = nil, -1
        for _, j in ipairs(sortedMoonJobs) do
            if IsValidBackupServer(j) then
                local e = serverEnds[j] or 0
                if e > bestEnd then
                    bestEnd = e
                    bestBackup = j
                end
            end
        end
        backupJob = bestBackup
    end

    local totalMoonCount = (targetJob and 1 or 0) + (backupJob and 1 or 0)
    totalReportedMoons = totalMoonCount

    -- Designate 2 distinct supports for targetJob
    local cleanSups, usedRaces = {}, {}

    if targetJob then
        for _, sInfo in ipairs(CFG.Supports) do
            local sName, sRace = sInfo[1], sInfo[2]
            local st = others[sName]
            if IsSupportEligible(sName, st, targetRace) and st.j == targetJob and not usedRaces[sRace] and #cleanSups < 2 then
                table.insert(cleanSups, sName)
                usedRaces[sRace] = true
            end
        end
    end

    local previousLockedSups = (type(lock.sups) == "table" and lock.tr == targetRace) and lock.sups or {}
    for _, sName in ipairs(previousLockedSups) do
        local sRace = SUPPORTS_MAP[sName]
        local st = others[sName]
        if sRace and IsSupportEligible(sName, st, targetRace) and not usedRaces[sRace] and not table.find(cleanSups, sName) and #cleanSups < 2 then
            table.insert(cleanSups, sName)
            usedRaces[sRace] = true
        end
    end

    for _, sInfo in ipairs(CFG.Supports) do
        local sName, sRace = sInfo[1], sInfo[2]
        local st = others[sName]
        if IsSupportEligible(sName, st, targetRace) and not usedRaces[sRace] and not table.find(cleanSups, sName) and #cleanSups < 2 then
            table.insert(cleanSups, sName)
            usedRaces[sRace] = true
        end
    end

    if SUPPORTS_MAP[PlayerName] and IsSupportEligible(PlayerName, ST, targetRace) and not usedRaces[SUPPORTS_MAP[PlayerName]] and not table.find(cleanSups, PlayerName) and #cleanSups < 2 then
        table.insert(cleanSups, PlayerName)
        usedRaces[SUPPORTS_MAP[PlayerName]] = true
    end

    -- If no targetJob available, invalidate lock file so stale IDs don't linger!
    if not targetJob then
        SafeWriteJson(MOON_LOCK_FILE, {t = now, tr = targetRace, mc = 0, sups = cleanSups})
        local isReg = table.find(cleanSups, PlayerName) ~= nil
        return nil, isReg, false, 0, cleanSups, nil, 0, nil
    end

    -- Designate 1 account to hold the backup moon server
    local backupHolder = nil
    if backupJob then
        if lock.bh and others[lock.bh] and others[lock.bh].j == backupJob and (others[lock.bh].m or 0) > 0 and not table.find(cleanSups, lock.bh) then
            backupHolder = lock.bh
        else
            local candidates = {}
            for accName, s in pairs(others) do
                if s.j == backupJob and (s.m or 0) > 0 and not table.find(cleanSups, accName) then
                    table.insert(candidates, accName)
                end
            end
            table.sort(candidates, function(a, b)
                if (SUPPORTS_MAP[a] ~= nil) ~= (SUPPORTS_MAP[b] ~= nil) then
                    return SUPPORTS_MAP[a] ~= nil
                end
                return a < b
            end)
            backupHolder = candidates[1]
        end
    end

    lock = {
        j    = targetJob,
        bj   = backupJob,
        bh   = backupHolder,
        mc   = totalMoonCount,
        tr   = targetRace,
        sups = cleanSups,
        t    = now
    }
    SafeWriteJson(MOON_LOCK_FILE, lock)

    local supsInTargetServer = 0
    for _, sName in ipairs(cleanSups) do
        local st = others[sName]
        if st and st.j == targetJob and IsSupportEligible(sName, st, targetRace) then
            supsInTargetServer = supsInTargetServer + 1
        end
    end

    local isRegisteredSupport = table.find(cleanSups, PlayerName) ~= nil
    local clonesCanJoin = (supsInTargetServer == 2)

    return targetJob, isRegisteredSupport, clonesCanJoin, supsInTargetServer, cleanSups, backupJob, totalMoonCount, backupHolder
end

-- ========================================================================================
-- 11. SERVER HOPPING & TELEPORTATION
-- ========================================================================================
local function TeleportToServer(jobId, isSpamMode)
    if not InSea3() then
        return TravelToSea3()
    end
    local targetId = tostring(jobId or "")
    if targetId == "" or targetId == game.JobId then return true end

    -- Support guard: do not join a server that already has 2 supports
    if SUPPORTS_MAP[PlayerName] then
        local others = GetOthersStatus(25)
        local countInTarget = 0
        for _, sInfo in ipairs(CFG.Supports) do
            local sName = sInfo[1]
            if sName ~= PlayerName and others[sName] and others[sName].j == targetId then
                countInTarget = countInTarget + 1
            end
        end
        if countInTarget >= 2 then
            DebugWarn("SUPPORT-JOIN", "Target server %s already has %d supports. Aborting join.", targetId, countInTarget)
            return false
        end
    end

    ReleaseTrainLock()
    ST.t = os.time()
    SafeWriteJson(STATUS_FILE, ST)

    DebugLog("TELEPORT", "Invoking teleport to JobId: %s", targetId)
    pcall(function()
        local sb = ReplicatedStorage:FindFirstChild("__ServerBrowser") or ReplicatedStorage:WaitForChild("__ServerBrowser", 5)
        if sb then
            sb:InvokeServer("teleport", targetId)
        end
    end)
    task.wait(4.5)

    if CLONES_MAP[PlayerName] and game.JobId ~= targetId then
        if not isSpamMode then
            failedJoinJobs[targetId] = true
        end
        return false
    end
    return game.JobId == targetId
end

-- Check if active hopping should be interrupted to join a moon server
local function CheckHopInterruptForMoon()
    if not InSea3() then return "stop" end

    if SUPPORTS_MAP[PlayerName] then
        local others = GetOthersStatus(25)
        local targetJob, isRegSup, _, _, cleanSups = CoordinateMoonServer(others, ST.tr)
        local has3Sups, amExtraSup = CheckThreeSupportsInCurrentServer(others, ST.tr, cleanSups)
        if has3Sups and amExtraSup then
            return nil -- Redundant support continues hopping away
        end
        if ST.m > 0 and not moonRejectedShortMoon then
            return "stop"
        end
        if ST.tr and targetJob and targetJob ~= game.JobId and isRegSup then
            return "join", targetJob, true
        end
        return "stop"
    end

    if IsMoonDeadTimeWindow() then
        return "stop"
    end

    if not ST.tr then return nil end
    if ST.m == 2 and HasTwoSupportsInServer(ST.tr) then
        return "stop"
    end

    local others = GetOthersStatus(25)
    local targetJob, isRegSup, clonesCanJoin, _, _, backupJob, totalMoons, backupHolder = CoordinateMoonServer(others, ST.tr)

    if backupJob and (game.JobId == backupJob or PlayerName == backupHolder) then
        return "stop"
    end

    local hasValidBackup = (backupJob ~= nil and totalMoons >= 2)

    if targetJob and targetJob ~= game.JobId then
        if CLONES_MAP[PlayerName] and not ST.dn and clonesCanJoin and PlayerName ~= backupHolder then
            if hasValidBackup or not failedJoinJobs[targetJob] then
                return "join", targetJob, hasValidBackup
            end
        end
    end

    if not moonRejectedShortMoon and (game.JobId == targetJob or game.JobId == backupJob) then
        return "stop"
    end

    if CLONES_MAP[PlayerName] and totalMoons >= 2 then
        return "stop"
    end

    return nil
end

local function HopLowServer(allowCancelForMoon, forceLeave3Sup)
    if SUPPORTS_MAP[PlayerName] and allowCancelForMoon and not forceLeave3Sup then
        return
    end
    if SUPPORTS_MAP[PlayerName] and InSea3() and ST.m > 0 and not moonRejectedShortMoon and getgenv().V4Hub == "gear" and not forceLeave3Sup then
        return
    end
    if isHopping then return end

    if allowCancelForMoon then
        local action, targetJob, spamMode = CheckHopInterruptForMoon()
        if action == "join" and targetJob then
            ST.ph = "join"
            if TeleportToServer(targetJob, spamMode) then return end
            if spamMode then return end
        elseif action == "stop" then
            return
        end
    end

    isHopping = true
    ReleaseTrainLock()

    if InSea3() and (ST.m == 0 or moonRejectedShortMoon) and not forceLeave3Sup then
        BlacklistCurrentServer()
    end

    -- Explicitly clear moon state so leaving support does not advertise stale moon to swarm!
    ST.m  = 0
    ST.me = 0
    ST.t  = os.time()
    SafeWriteJson(STATUS_FILE, ST)

    task.spawn(function()
        DebugLog("HOP", "Starting low player server query loop...")
        while not IsStopped() do
            if allowCancelForMoon and not forceLeave3Sup then
                local action, targetJob, spamMode = CheckHopInterruptForMoon()
                if action == "join" and targetJob then
                    isHopping = false
                    ST.ph = "join"
                    TeleportToServer(targetJob, spamMode)
                    return
                elseif action == "stop" then
                    isHopping = false
                    return
                end
            end

            local bl = SafeReadJson(BLACKLIST_FILE)
            local serverBrowser = ReplicatedStorage:FindFirstChild("__ServerBrowser") or ReplicatedStorage:WaitForChild("__ServerBrowser", 5)
            local serverPool, completedBatches = {}, 0

            if serverBrowser then
                for page = 1, 100 do
                    task.delay(page * 0.02, function()
                        local ok, res = pcall(function() return serverBrowser:InvokeServer(page) end)
                        if ok and type(res) == "table" then
                            for id, info in pairs(res) do
                                if type(info) == "table" and id ~= game.JobId and (bl[id] or 0) < os.time() and not failedJoinJobs[id] then
                                    serverPool[id] = tonumber(info.Count) or 99
                                end
                            end
                        end
                        completedBatches = completedBatches + 1
                    end)
                end

                local deadline = os.clock() + 8.5
                repeat task.wait(0.1) until completedBatches >= 100 or os.clock() > deadline

                local sortedServers = {}
                for id, count in pairs(serverPool) do
                    table.insert(sortedServers, {id, count})
                end
                table.sort(sortedServers, function(a, b) return a[2] < b[2] end)

                for _ = 1, math.min(#sortedServers, 6) do
                    if allowCancelForMoon and not forceLeave3Sup then
                        local action, targetJob, spamMode = CheckHopInterruptForMoon()
                        if action == "join" and targetJob then
                            isHopping = false
                            ST.ph = "join"
                            TeleportToServer(targetJob, spamMode)
                            return
                        elseif action == "stop" then
                            isHopping = false
                            return
                        end
                    end

                    if #sortedServers == 0 then break end
                    local choice = table.remove(sortedServers, math.random(1, math.min(#sortedServers, 3)))
                    local chosenJob = tostring(choice[1] or "")
                    ST.t = os.time()
                    SafeWriteJson(STATUS_FILE, ST)
                    if chosenJob ~= "" and chosenJob ~= game.JobId then
                        DebugLog("HOP", "Attempting hop to Job: %s (Players: %d)", chosenJob, choice[2])
                        pcall(function()
                            serverBrowser:InvokeServer("teleport", chosenJob)
                        end)
                    end
                    task.wait(6.5)
                end
            end
            task.wait(2.5)
        end
        isHopping = false
    end)
end

-- ========================================================================================
-- 12. SAFE MOVEMENT & TWEENING (NOCLIP & ANTIGRAVITY - NEVER ANCHOR ROOT)
-- ========================================================================================
local activeTween = nil
local isMovePhysicsActive = false

local function SetMovePhysics(enable)
    isMovePhysicsActive = enable
    if enable then
        Workspace.Gravity = 0
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                if hum.Sit then hum.Sit = false end
                hum:ChangeState(Enum.HumanoidStateType.Physics)
            end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Anchored = false
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Anchored = false
                    part.CanCollide = false
                end
            end
        end
    else
        Workspace.Gravity = DEFAULT_GRAVITY
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum and hum:GetState() == Enum.HumanoidStateType.Physics then
                hum:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.Anchored = false
                root.AssemblyLinearVelocity = Vector3.zero
                root.AssemblyAngularVelocity = Vector3.zero
            end
        end
    end
end

-- Continuous Stepped physics enforcement during movement
RunService.Stepped:Connect(function()
    if IsStopped() or not isMovePhysicsActive then return end
    Workspace.Gravity = 0
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum and hum.Sit then hum.Sit = false end
    local root = char:FindFirstChild("HumanoidRootPart")
    if root then
        if root.Anchored then root.Anchored = false end
        root.AssemblyLinearVelocity = Vector3.zero
        root.AssemblyAngularVelocity = Vector3.zero
    end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if part.Anchored then part.Anchored = false end
            if part.CanCollide then part.CanCollide = false end
        end
    end
end)

local function RecoverToVerifiedSpot()
    if activeTween then
        pcall(function() activeTween:Cancel() end)
        activeTween = nil
    end
    SetMovePhysics(false)
    local tStart = os.clock()
    local lastPos = GetRoot() and GetRoot().Position or nil
    local stableCount = 0

    while (os.clock() - tStart < 1.2) and not IsStopped() and not getgenv().V4Hub do
        task.wait(0.1)
        local root = GetRoot()
        if not root then break end
        root.Anchored = false
        if lastPos and (root.Position - lastPos).Magnitude < 2.5 then
            stableCount = stableCount + 1
            if stableCount >= 4 and (os.clock() - tStart >= 0.5) then
                break
            end
        else
            stableCount = 0
        end
        lastPos = root.Position
    end
end

local function SafeTween(destination, abortFn)
    if getgenv().V4Hub then
        HopLowServer(false)
        return false
    end

    local speed = 240 -- Studs per second
    local maxRetries = 8

    for attempt = 1, maxRetries do
        if IsStopped() or getgenv().V4Hub or (abortFn and abortFn()) then
            SetMovePhysics(false)
            if getgenv().V4Hub then HopLowServer(false) end
            return false
        end

        local root = GetRoot()
        local hum  = GetHumanoid()
        if not (root and hum and hum.Health > 0) then
            SetMovePhysics(false)
            return false
        end

        if activeTween then
            pcall(function() activeTween:Cancel() end)
            activeTween = nil
        end

        SetMovePhysics(true)
        local startPos = root.Position
        local distance = (startPos - destination).Magnitude
        if distance <= 12 then
            root.CFrame = CFrame.new(destination)
            SetMovePhysics(false)
            return true
        end

        local duration = distance / speed
        local tw = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = CFrame.new(destination)})
        activeTween = tw
        tw:Play()

        local twStartTime = os.clock()
        local lastCheckTime = twStartTime
        local lastCheckPos = startPos
        local minDistance = distance
        local rubberbandDetected = false

        while tw.PlaybackState == Enum.PlaybackState.Playing do
            if IsStopped() or getgenv().V4Hub or (abortFn and abortFn()) then
                pcall(function() tw:Cancel() end)
                activeTween = nil
                SetMovePhysics(false)
                if getgenv().V4Hub then HopLowServer(false) end
                return false
            end

            local curRoot, curHum = GetRoot(), GetHumanoid()
            if not (curRoot and curHum and curHum.Health > 0) then
                pcall(function() tw:Cancel() end)
                activeTween = nil
                SetMovePhysics(false)
                return false
            end

            local currentPos = curRoot.Position
            local currentDist = (currentPos - destination).Magnitude
            if currentDist <= 8 then
                break
            end

            if currentDist < minDistance then
                minDistance = currentDist
            end

            local elapsed = os.clock() - twStartTime
            local alpha = math.clamp(elapsed / duration, 0, 1)
            local expectedPos = startPos:Lerp(destination, alpha)

            if (currentDist - minDistance > 18) or (currentPos - expectedPos).Magnitude > 35 then
                rubberbandDetected = true
                DebugWarn("TWEEN", "Rubberbanding detected! Distance jump: %.1f", (currentDist - minDistance))
                break
            end

            if os.clock() - lastCheckTime >= 0.45 then
                local expectedStep = speed * (os.clock() - lastCheckTime)
                local actualStep = (currentPos - lastCheckPos).Magnitude
                local progress = (lastCheckPos - destination).Magnitude - currentDist
                if actualStep < expectedStep * 0.35 or progress < expectedStep * 0.35 then
                    rubberbandDetected = true
                    DebugWarn("TWEEN", "Stall detected! Recovering...")
                    break
                end
                lastCheckTime = os.clock()
                lastCheckPos = currentPos
            end

            task.wait(0.03)
        end

        if rubberbandDetected then
            RecoverToVerifiedSpot()
        else
            pcall(function() tw:Cancel() end)
            activeTween = nil
            root = GetRoot()
            if root and (root.Position - destination).Magnitude <= 20 then
                root.CFrame = CFrame.new(destination)
                root.AssemblyLinearVelocity = Vector3.zero
                SetMovePhysics(false)
                return true
            end
            RecoverToVerifiedSpot()
        end
    end

    SetMovePhysics(false)
    return false
end

local function MoveToGreatTree()
    if getgenv().V4Hub then HopLowServer(false) return end
    if not InSea3() then return TravelToSea3() end
    ST.ph = "idle"
    local root = GetRoot()
    if root and (root.Position - GREAT_TREE_POS).Magnitude > 150 then
        DebugLog("MOVE", "Moving character to Great Tree safe spot...")
        local abortForSupportMoon = nil
        if SUPPORTS_MAP[PlayerName] and ST.tr and SUPPORTS_MAP[PlayerName] ~= ST.tr then
            abortForSupportMoon = function()
                if ST.m > 0 and not moonRejectedShortMoon then return false end
                local othersNow = GetOthersStatus(25)
                local tJob, isReg, _, _, _, bJob = CoordinateMoonServer(othersNow, ST.tr)
                return (tJob ~= nil and tJob ~= game.JobId and isReg) or (bJob ~= nil and bJob ~= game.JobId)
            end
        end
        SafeTween(GREAT_TREE_POS, abortForSupportMoon)
    end
end

-- ========================================================================================
-- 13. EXTERNAL SCRIPT HUBS (TRAIN, V3, MARU GEAR)
-- ========================================================================================
local function WriteRealKidConfig(options)
    for _, prefix in ipairs({"", "workspace/"}) do
        pcall(makefolder, prefix .. "RealKidHub")
        for _, sub in ipairs({"save", "save2"}) do
            pcall(makefolder, prefix .. "RealKidHub/" .. sub)
            local path = prefix .. "RealKidHub/" .. sub .. "/" .. PlayerName .. ".json"
            local config = SafeReadJson(path)
            for k, v in pairs(options) do
                config[k] = v
            end
            SafeWriteJson(path, config)
        end
    end
end

local function LoadExternalScript(url)
    DebugLog("SCRIPT-LOAD", "Fetching script from: %s", url)
    local ok, source = pcall(function() return game:HttpGet(url) end)
    if not ok or type(source) ~= "string" or #source < 10 then
        error("HttpGet failed for " .. tostring(url))
    end
    local compiled, err = loadstring(source)
    if not compiled then
        error("loadstring compilation failed: " .. tostring(err))
    end
    return compiled()
end

local function RunHub(hubName, hubFunc)
    if getgenv().V4Hub then
        if getgenv().V4Hub ~= hubName then
            DebugWarn("HUB", "Different hub (%s) already active. Hopping server...", getgenv().V4Hub)
            HopLowServer(false)
        end
        return
    end
    SetMovePhysics(false)
    getgenv().V4Hub = hubName
    DebugLog("HUB", "Starting hub task: %s", hubName)
    task.spawn(function()
        local ok, err = pcall(hubFunc)
        if not ok then
            DebugWarn("HUB", "Hub [%s] encountered error: %s", tostring(hubName), tostring(err))
            task.wait(2.5)
            if getgenv().V4Hub == hubName then
                getgenv().V4Hub = nil
            end
        end
    end)
end

local function RunTrain()
    WriteRealKidConfig({
        AutoTrainV4           = true,
        AutoBuyV4Gear         = true,
        AutoCompleteTrialRace = false,
        AutoChooseV4Gear      = false,
        ResetAfterTrial       = false,
        AutoPullLever         = false,
        AutoUpgradeRaceV3     = false,
    })
    LoadExternalScript("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua")
end

local function RunKaitunV4(twoSupports, cloneList)
    local helpers = {}
    if type(twoSupports) == "table" and #twoSupports > 0 then
        for _, sName in ipairs(twoSupports) do
            table.insert(helpers, sName)
        end
    else
        for _, sInfo in ipairs(CFG.Supports) do
            if sInfo[2] ~= ST.tr then
                table.insert(helpers, sInfo[1])
            end
        end
    end

    local farms = {}
    if type(cloneList) == "table" and #cloneList > 0 then
        for _, cName in ipairs(cloneList) do
            table.insert(farms, cName)
        end
    else
        for _, cName in ipairs(CFG.Clones) do
            if not (ST.tr and isfile(PROGRESS_DIR .. "/c_" .. ST.tr .. "_" .. cName .. ".txt")) then
                table.insert(farms, cName)
            end
        end
    end

    DebugLog("KAITUN-V4", "Configuring KaitunV4 with Main: %s | Help: %s", table.concat(farms, ", "), table.concat(helpers, ", "))

    getgenv().config = {
        Enabled = true,
        TweenSpeed = 190,
        AutoTrial = true,
        AutoUpgradeRace = true,
        Main = {
            Account = farms,
            Tier = 5,
            Gear = "A-B-A", -- A = Red (Alpha), B = Blue (Omega)
        },
        Help = {
            Account = helpers,
            Reset = true
        }
    }

    LoadExternalScript("https://raw.githubusercontent.com/phongdeptraur/kaitunv3/refs/heads/main/kaitunV4")
end

-- Progression tracking helpers
local function GetCurrentTargetRace()
    if CFG.OneRaceMode then
        local singleRace = tostring(CFG.TargetOneRace or ""):lower()
        local foundIdx = 1
        for idx, rName in ipairs(ORDER) do
            if rName == singleRace then
                foundIdx = idx
                break
            end
        end
        if singleRace ~= "" and not isfile(PROGRESS_DIR .. "/" .. foundIdx .. "race-" .. singleRace .. ".txt") then
            return foundIdx, singleRace
        end
        return nil, nil
    end

    for index, raceName in ipairs(ORDER) do
        if not isfile(PROGRESS_DIR .. "/" .. index .. "race-" .. raceName .. ".txt") then
            return index, raceName
        end
    end
    return nil, nil
end

local function CheckRaceCompletion(raceIndex, raceName)
    for _, cloneName in ipairs(CFG.Clones) do
        if not isfile(PROGRESS_DIR .. "/c_" .. raceName .. "_" .. cloneName .. ".txt") then
            return
        end
    end
    local record = os.date() .. " | All Clones Done: " .. table.concat(CFG.Clones, ",")
    writefile(PROGRESS_DIR .. "/" .. raceIndex .. "race-" .. raceName .. ".txt", record)
    DebugLog("PROGRESSION", "RACE %s FULLY COMPLETED BY ALL CLONES!", raceName:upper())
end

local farmSyncFolderChanged = false
local lastFarmSyncAttempt   = 0

local function TriggerFarmSyncChangeFolder(reason)
    if farmSyncFolderChanged then return true end
    if os.clock() - lastFarmSyncAttempt < 10 then return false end
    lastFarmSyncAttempt = os.clock()

    local client = getgenv().client
    if not (client and type(client.ChangeToFolder) == "function") then
        DebugWarn("FARMSYNC", "getgenv().client:ChangeToFolder không khả dụng (%s)", tostring(reason))
        return false
    end

    DebugLog("FARMSYNC", "Đang gọi ChangeToFolder (%s)...", tostring(reason))
    local ok, changed = pcall(function()
        return client:ChangeToFolder(
            "4cc982f47cb8a8d5a1eb047a9f8a6f62fcc9f0c86634e2c2f94986413a0bb9e9",
            "ce4065db203afa7fe3b3540002b8cbe33336f37c9c7bed933b34d8962d472bf1",
            true,
            nil
        )
    end)

    if ok and changed then
        farmSyncFolderChanged = true
        DebugLog("FARMSYNC", "ChangeToFolder thành công! (%s)", tostring(reason))
        return true
    end

    DebugWarn("FARMSYNC", "ChangeToFolder trả về: ok=%s, changed=%s", tostring(ok), tostring(changed))
    return false
end

-- ========================================================================================
-- 14. MODERN ENHANCED GUI (SLEEK CARD LAYOUT, CRISP TYPOGRAPHY, RICH STATUS BADGES)
-- ========================================================================================
local PHASE_DESCRIPTIONS = {
    init          = "Khởi tạo hệ thống",
    boot          = "Chọn team Marines & tải dữ liệu nhân vật",
    check_train   = "Đang kiểm tra trạng thái Train (chờ kết quả remote)...",
    v3            = "Đang chạy script V3 + Pull cho race",
    train         = "Đang chạy RealKid Hub: Auto Train & Buy Gear",
    frag          = "Đang chạy script farm Fragment (dưới 3000)",
    travel_sea3   = "Hoàn thành Sea 2 -> Đang dịch chuyển về Sea 3",
    travel_sea2   = "Cần làm V3 -> Đang dịch chuyển sang Sea 2",
    hunt          = "Clone đang hop server ít người tìm Moon",
    join          = "Đang join vào server Moon chính",
    spam_join     = "Đã đủ 2 server Moon -> Spam join server chính để Up Gear",
    wait2sp       = "Đang ở server Moon, chờ đủ 2 Support vào",
    hold_backup   = "Đang giữ server Moon dự phòng (> 5p hoặc Near Moon)",
    idle_moon_off = "Phút X:00 - X:09 (Nghỉ Moon) -> Dừng hop & đứng nghỉ",
    canhmoon      = "Support đang chờ clone tìm thấy Moon",
    sp_extra      = "Support dư (hoặc trùng race): Đang chờ ở Great Tree",
    leave_3sp     = "Phát hiện 3 Support trong server -> Đang hop rời đi!",
    idle          = "Đang đứng chờ an toàn tại Great Tree",
    gear          = "Đang chạy KaitunV4 để Up Gear",
    one_race_done = "ĐÃ XONG 1 RACE CHỈ ĐỊNH -> ĐANG ĐỨNG IDLE Ở GREAT TREE",
    all_done      = "TẤT CẢ 6 RACE ĐÃ HOÀN THÀNH V4!"
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "6V4_ModernUI"
screenGui.ResetOnSpawn = false

local mainCard = Instance.new("Frame")
mainCard.Name = "MainCard"
mainCard.Size = UDim2.new(0, 530, 0, 390)
mainCard.Position = UDim2.new(0, 15, 0, 45)
mainCard.BackgroundColor3 = Color3.fromRGB(15, 17, 23)
mainCard.BorderSizePixel = 0
mainCard.Active = true
mainCard.Draggable = false
mainCard.Parent = screenGui

local cardCorner = Instance.new("UICorner")
cardCorner.CornerRadius = UDim.new(0, 10)
cardCorner.Parent = mainCard

local cardStroke = Instance.new("UIStroke")
cardStroke.Color = Color3.fromRGB(38, 44, 62)
cardStroke.Thickness = 1.2
cardStroke.Parent = mainCard

-- Header Bar
local headerFrame = Instance.new("Frame")
headerFrame.Size = UDim2.new(1, 0, 0, 38)
headerFrame.BackgroundColor3 = Color3.fromRGB(22, 25, 36)
headerFrame.BorderSizePixel = 0
headerFrame.Parent = mainCard

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 10)
headerCorner.Parent = headerFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 12, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 13
titleLabel.TextColor3 = Color3.fromRGB(0, 204, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Text = "⚡ 6V4 AUTOMATION - RACE AWAKENING"
titleLabel.Parent = headerFrame

-- Custom drag handler: chỉ di chuyển UI khi đang giữ chuột trái trên thanh tiêu đề
local UserInputService = GetService("UserInputService")
local isDraggingUI = false
local dragStartPos = nil
local cardStartPos = nil

headerFrame.Active = true
headerFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingUI = true
        dragStartPos = input.Position
        cardStartPos = mainCard.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not isDraggingUI then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        if not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
            isDraggingUI = false
            return
        end
        local delta = input.Position - dragStartPos
        mainCard.Position = UDim2.new(
            cardStartPos.X.Scale,
            cardStartPos.X.Offset + delta.X,
            cardStartPos.Y.Scale,
            cardStartPos.Y.Offset + delta.Y
        )
    elseif input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStartPos
        mainCard.Position = UDim2.new(
            cardStartPos.X.Scale,
            cardStartPos.X.Offset + delta.X,
            cardStartPos.Y.Scale,
            cardStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        isDraggingUI = false
    end
end)

UserInputService.WindowFocusReleased:Connect(function()
    isDraggingUI = false
end)

-- Subtle Separator Line
local separator = Instance.new("Frame")
separator.Size = UDim2.new(1, -24, 0, 1)
separator.Position = UDim2.new(0, 12, 0, 42)
separator.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
separator.BorderSizePixel = 0
separator.Parent = mainCard

-- Content Label with RichText
local contentLabel = Instance.new("TextLabel")
contentLabel.Size = UDim2.new(1, -24, 1, -90)
contentLabel.Position = UDim2.new(0, 12, 0, 48)
contentLabel.BackgroundTransparency = 1
contentLabel.Font = Enum.Font.GothamMedium
contentLabel.TextSize = 12
contentLabel.TextColor3 = Color3.fromRGB(225, 230, 240)
contentLabel.TextXAlignment = Enum.TextXAlignment.Left
contentLabel.TextYAlignment = Enum.TextYAlignment.Top
contentLabel.RichText = true
contentLabel.TextWrapped = true
contentLabel.Parent = mainCard

-- Unload Button
local unloadButton = Instance.new("TextButton")
unloadButton.Size = UDim2.new(1, -24, 0, 30)
unloadButton.Position = UDim2.new(0, 12, 1, -38)
unloadButton.BackgroundColor3 = Color3.fromRGB(180, 45, 45)
unloadButton.Font = Enum.Font.GothamBold
unloadButton.TextSize = 12
unloadButton.TextColor3 = Color3.fromRGB(255, 255, 255)
unloadButton.Text = "DỪNG TOÀN BỘ SCRIPT (UNLOAD)"
unloadButton.Parent = mainCard

local btnCorner = Instance.new("UICorner")
btnCorner.CornerRadius = UDim.new(0, 6)
btnCorner.Parent = unloadButton

unloadButton.MouseButton1Click:Connect(function()
    DebugWarn("GUI", "Unload requested by user. Terminating script...")
    getgenv().V4Stop = true
    getgenv().V4Hub = nil
    if type(getgenv().config) == "table" then
        getgenv().config.Enabled = false
    end
    if getgenv().AutoV4Cleanup then
        pcall(getgenv().AutoV4Cleanup)
    end
    ReleaseTrainLock()
    if activeTween then pcall(function() activeTween:Cancel() end) end
    SetMovePhysics(false)
    pcall(delfile, STATUS_FILE)
    screenGui:Destroy()
end)

-- Mount GUI to CoreGui or gethui
screenGui.Parent = (gethui and gethui()) or GetService("CoreGui")

-- Anti-AFK protection
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- ========================================================================================
-- 15. BOOT SEQUENCE: TEAM SELECTION & CHARACTER READINESS
-- ========================================================================================
local isBootCompleted = false
ST.ph = "boot"

task.spawn(function()
    DebugLog("BOOT", "Initializing boot sequence: Selecting Marines team...")
    getgenv().Team = "Marines"
    while not IsStopped() do
        if LocalPlayer.Team and tostring(LocalPlayer.Team) ~= "Neutral" then break end
        task.spawn(function()
            if CommF_ then pcall(function() CommF_:InvokeServer("SetTeam", "Marines") end) end
        end)
        pcall(function()
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            if not pg then return end
            for _, uiName in ipairs({"Main", "Main (minimal)"}) do
                local mainGui = pg:FindFirstChild(uiName)
                local chooseTeam = mainGui and mainGui:FindFirstChild("ChooseTeam")
                local container = chooseTeam and chooseTeam:FindFirstChild("Container")
                local marines = container and container:FindFirstChild("Marines")
                local frame = marines and marines:FindFirstChild("Frame")
                local btn = frame and (frame:FindFirstChild("TextButton") or frame:FindFirstChildOfClass("TextButton"))
                if btn then
                    if getconnections then
                        for _, sig in ipairs({btn.MouseButton1Click, btn.Activated}) do
                            for _, conn in ipairs(getconnections(sig)) do
                                pcall(function() conn.Function() end)
                            end
                        end
                    elseif firesignal then
                        firesignal(btn.MouseButton1Click)
                    end
                end
            end
        end)
        task.wait(0.5)
    end

    DebugLog("BOOT", "Waiting for Character and Data to load...")
    while not IsStopped() do
        local char = LocalPlayer.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local data = LocalPlayer:FindFirstChild("Data")
        local hasFrag = data and (data:FindFirstChild("Fragments") or data:FindFirstChild("Fragment"))
        if char and char:FindFirstChild("HumanoidRootPart") and hum and hum.Health > 0
            and LocalPlayer:FindFirstChild("Backpack") and data and data:FindFirstChild("Race")
            and data:FindFirstChild("Level") and hasFrag then
            break
        end
        task.wait(0.3)
    end
    task.wait(3.0)

    if InSea3() then
        ST.ph = "check_train"
        UpdateTrialStatus()
        if IsStopped() then return end
        ST.tn = TrialApp.IsTrained
        ST.ts = TrialApp.TrialStatus
        previousTrainedState = ST.tn
    end

    isBootCompleted = true
    ST.ph = "init"
    DebugLog("BOOT", "Boot sequence complete! Account is fully loaded.")
end)

-- ========================================================================================
-- 16. IN-GAME DOOR & ROSTER STATE EVALUATOR
-- ========================================================================================
local function GetRosterDoorAndServerState(targetRace, others)
    local supsAtDoor = {}
    local clonesAtDoor = {}
    local coloredAccountList = {}

    -- Identify earliest clone at door by reading doorTime from heartbeats
    local earliestClone = nil
    local earliestTime  = math.huge

    for _, cName in ipairs(CFG.Clones) do
        local isPresent = Players:FindFirstChild(cName) ~= nil
        local atDoor = IsAccAtDoorInGame(cName, targetRace)
        local cStatus = others and others[cName]

        if isPresent then
            if atDoor then
                table.insert(clonesAtDoor, cName)
                local tArrival = (cStatus and cStatus.doorTime and cStatus.doorTime > 0) and cStatus.doorTime or math.huge
                if tArrival < earliestTime or (tArrival == earliestTime and (not earliestClone or cName < earliestClone)) then
                    earliestTime = tArrival
                    earliestClone = cName
                end
            end
        end
    end

    -- Format Support entries
    for _, sInfo in ipairs(CFG.Supports) do
        local sName, sRace = sInfo[1], sInfo[2]
        if Players:FindFirstChild(sName) then
            if IsAccAtDoorInGame(sName, targetRace) then
                table.insert(supsAtDoor, sName)
                table.insert(coloredAccountList, string.format('<font color="#00CCFF">%s [SP-%s: Ở CỬA]</font>', sName, sRace:upper()))
            else
                table.insert(coloredAccountList, string.format('<font color="#FFBB33">%s [SP-%s]</font>', sName, sRace:upper()))
            end
        end
    end

    -- Format Clone entries
    for _, cName in ipairs(CFG.Clones) do
        if Players:FindFirstChild(cName) then
            if table.find(clonesAtDoor, cName) then
                local isStar = (cName == earliestClone) and " ★ [ƯU TIÊN]" or " [Ở CỬA]"
                table.insert(coloredAccountList, string.format('<font color="#00FF88"><b>%s%s</b></font>', cName, isStar))
            else
                table.insert(coloredAccountList, string.format('<font color="#CCCCCC">%s</font>', cName))
            end
        end
    end

    return supsAtDoor, clonesAtDoor, earliestClone, coloredAccountList
end

-- ========================================================================================
-- 17. LIVE GUI REFRESH & HEARTBEAT BACKGROUND LOOP
-- ========================================================================================
task.spawn(function()
    while task.wait(0.5) and not IsStopped() do
        ST.j  = game.JobId
        ST.t  = os.time()
        ST.np = #Players:GetPlayers()
        ST.race = GetCurrentRace()

        if not isHopping then
            local mState, mEnd = 0, 0
            pcall(function() mState, mEnd = CheckMoon() end)
            ST.m  = mState or 0
            ST.me = mEnd or 0
        end

        ST.frag = GetFragments()
        ST.tier = ExtractLiveV4Tier()

        local atDoorNow = IsAccAtDoorInGame(PlayerName, ST.tr)
        if atDoorNow then
            if not ST.door or (ST.doorTime or 0) == 0 then
                ST.doorTime = os.time()
            end
            ST.door = true
        else
            ST.door = false
            ST.doorTime = 0
        end

        -- Keep atomic train lock heartbeat fresh if currently training
        if ST.ph == "train" then
            UpdateTrainLockHeartbeat()
        end

        SafeWriteJson(STATUS_FILE, ST)

        -- Update GUI content
        pcall(function()
            local others = GetOthersStatus(25)
            local targetRace = ST.tr or "?"
            local lockedSupportRace = SUPPORTS_MAP[PlayerName] and SUPPORTS_MAP[PlayerName]:upper() or "Không (Clone)"
            local _, _, _, coloredList = GetRosterDoorAndServerState(targetRace, others)
            local accountListFormatted = (#coloredList > 0) and table.concat(coloredList, ", ") or "Chưa có acc nào khác trong server"

            local completedClonesCount = 0
            for _, c in ipairs(CFG.Clones) do
                if ST.tr and isfile(PROGRESS_DIR .. "/c_" .. ST.tr .. "_" .. c .. ".txt") then
                    completedClonesCount = completedClonesCount + 1
                end
            end

            local seaTitle = InSea3() and "Sea 3" or (InSea2() and "Sea 2" or "Sea 1")
            local trainBadge = ST.tn
                and string.format('<font color="#00FF88"><b>ĐÃ TRAIN</b></font> (%s)', tostring(ST.ts))
                or string.format('<font color="#FF9900"><b>CẦN TRAIN</b></font> (%s)', tostring(ST.ts))

            local v3Badge = ST.v3
                and '<font color="#00FF88"><b>ĐÃ CÓ V3</b></font>'
                or '<font color="#FF4444"><b>CHƯA CÓ V3</b></font>'

            local pullBadge = ST.pull
                and '<font color="#00FF88"><b>ĐÃ PULL</b></font>'
                or '<font color="#FF4444"><b>CHƯA PULL</b></font>'

            local doorBadge = ST.door
                and '<font color="#00FF88"><b>ĐÃ ĐẾN CỬA</b></font>'
                or '<font color="#AAAAAA">Chưa đến cửa</font>'

            local helpersBadge = (#currentActiveHelpers == 2)
                and string.format('<font color="#00CCFF">%s, %s</font>', currentActiveHelpers[1], currentActiveHelpers[2])
                or '<font color="#AAAAAA">Chưa khóa đủ 2 SP</font>'

            local modeBadge = CFG.OneRaceMode
                and string.format("<font color='#FF66FF'><b>1 RACE (%s)</b></font>", tostring(CFG.TargetOneRace or "?"):upper())
                or "<font color='#00FF88'><b>6V4</b></font>"

            local reqFragDisplay = FRAG_MINIMUM

            local function EscapeRichText(str)
                return tostring(str or ""):gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
            end

            local safeTrialStatus = EscapeRichText(ST.ts)
            local safeMoonLabel   = EscapeRichText(currentMoonLabel)
            local safePhaseDesc   = EscapeRichText(PHASE_DESCRIPTIONS[ST.ph] or tostring(ST.ph))

            local trainBadgeSafe = (InSea3() and not TrialApp.HasChecked)
                and string.format('<font color="#00CCFF"><b>ĐANG KIỂM TRA...</b></font> (%s)', safeTrialStatus)
                or (ST.tn
                    and string.format('<font color="#00FF88"><b>ĐÃ TRAIN</b></font> (%s)', safeTrialStatus)
                    or string.format('<font color="#FF9900"><b>CẦN TRAIN</b></font> (%s)', safeTrialStatus))

            contentLabel.RichText = true
            contentLabel.Text = table.concat({
                string.format("<b>Acc:</b> <font color='#FFFFFF'>%s</font> | <b>Role:</b> %s | <b>Vị trí:</b> %s",
                    EscapeRichText(PlayerName), SUPPORTS_MAP[PlayerName] and ("Support [Khóa: " .. SUPPORTS_MAP[PlayerName]:upper() .. "]") or "Clone Up Gear", seaTitle),
                string.format("<b>Tier V4:</b> <font color='#00FF88'><b>%d</b></font> | <b>Train:</b> %s", ST.tier, trainBadgeSafe),
                string.format("<b>Chế độ:</b> %s | <b>Race:</b> %s | <b>Target:</b> <font color='#00CCFF'><b>%s</b></font>",
                    modeBadge, ST.race ~= "" and EscapeRichText(ST.race:upper()) or "Loading...", EscapeRichText(tostring(targetRace):upper())),
                string.format("<b>V3:</b> %s | <b>Pull Đòn Bẩy:</b> %s | <b>Ở Cửa:</b> %s",
                    v3Badge, pullBadge, doorBadge),
                string.format("<b>Fragment:</b> %d / %d (%s) | <b>2 Support đã chọn:</b> %s",
                    ST.frag, reqFragDisplay, ST.frag >= reqFragDisplay and '<font color="#00FF88">Đủ</font>' or '<font color="#FF4444">Thiếu</font>', helpersBadge),
                string.format("<b>Mặt trăng:</b> %s | <b>Số server trăng:</b> <font color='#00FF88'><b>%d/2</b></font>", safeMoonLabel, totalReportedMoons),
                string.format("<b>Trạng thái:</b> <font color='#FFFF77'><b>%s</b></font> | <b>Đang hop:</b> %s",
                    safePhaseDesc, isHopping and "Có" or "Không"),
                string.format("<b>Tiến độ V4 (%s):</b> <font color='#00FF88'><b>%d/%d</b></font>",
                    EscapeRichText(tostring(targetRace):upper()), completedClonesCount, #CFG.Clones),
                "<b>Acc trong server:</b> " .. accountListFormatted
            }, "\n")
        end)
    end
end)

-- ========================================================================================
-- 18. STATE TRANSITION REFRESH (TRAIN <-> TRIAL HOP LOW)
-- ========================================================================================
local function CheckStateTransition(isTrained)
    if previousTrainedState == nil then
        previousTrainedState = isTrained
        return false
    end

    if previousTrainedState ~= isTrained then
        if not previousTrainedState and isTrained then
            -- Transition: train -> trial (finished training, ready for trial)
            DebugLog("TRANSITION", "State transition: TRAIN -> TRIAL (Trained is now TRUE). Hopping low to search for moon servers...")
            previousTrainedState = isTrained
            HopLowServer(false)
            return true
        elseif previousTrainedState and not isTrained then
            -- Transition: trial -> train (finished trial, needs training)
            DebugLog("TRANSITION", "State transition: TRIAL -> TRAIN (Trained is now FALSE). Hopping low to find training server...")
            previousTrainedState = isTrained
            HopLowServer(false)
            return true
        end
    end
    return false
end

-- ========================================================================================
-- 19. MAIN ORCHESTRATOR DECISION ENGINE
-- ========================================================================================
local function TickOrchestrator()
    if isHopping or not isBootCompleted then return end

    local targetIndex, targetRace = GetCurrentTargetRace()
    if not targetIndex then
        ST.rdy = false
        ST.m   = 0
        ST.me  = 0
        ReleaseTrainLock()
        if CFG.OneRaceMode then
            ST.tr = tostring(CFG.TargetOneRace or ""):lower()
            if getgenv().V4Hub then
                getgenv().V4Hub = nil
            end
            ST.ph = "one_race_done"
            SafeWriteJson(STATUS_FILE, ST)
            TriggerFarmSyncChangeFolder("Hoàn thành toàn bộ chế độ 1 Race: " .. ST.tr)
            MoveToGreatTree()
            return
        end
        ST.ph = "all_done"
        SafeWriteJson(STATUS_FILE, ST)
        TriggerFarmSyncChangeFolder("Hoàn thành toàn bộ 6V4")
        getgenv().V4Stop = true
        DebugLog("MAIN", "All 6 races awakened! Orchestrator terminating cleanly.")
        return
    end
    ST.tr = targetRace
    CheckRaceCompletion(targetIndex, targetRace)

    local hum = GetHumanoid()
    if not (hum and hum.Health > 0 and GetRoot() and LocalPlayer:FindFirstChild("Backpack")) then
        return
    end

    local moonState, moonEndMinutes = CheckMoon()
    ST.m  = moonState
    ST.me = moonEndMinutes

    -- Continuous Train check via live remote (bắt buộc ra kết quả mới tính bước tiếp theo)
    local isCurrentlyTrained, hasValidTrainResult = CheckTrained()
    if InSea3() and not hasValidTrainResult then
        ST.ph  = "check_train"
        ST.rdy = false
        SafeWriteJson(STATUS_FILE, ST)
        return
    end
    ST.tn = isCurrentlyTrained

    -- Check if LocalPlayer clone finished current target race
    local cloneDoneFile = PROGRESS_DIR .. "/c_" .. targetRace .. "_" .. PlayerName .. ".txt"
    if InSea3() and CLONES_MAP[PlayerName] and not isfile(cloneDoneFile) and GetCurrentRace() == targetRace then
        local liveTier = ExtractLiveV4Tier()
        if liveTier >= 6 or (liveTier == 5 and not ST.tn) then
            writefile(cloneDoneFile, os.date())
            DebugLog("MAIN", "Clone %s completed race %s (Tier: %d)!", PlayerName, targetRace, liveTier)
        end
    end
    ST.dn = CLONES_MAP[PlayerName] and isfile(cloneDoneFile) or false

    local requiredRace = SUPPORTS_MAP[PlayerName] or targetRace
    local isFragDeficient = (GetFragments() < FRAG_MINIMUM)
    local isRaceReady = IsAccountReady(requiredRace)
    ST.sr = isRaceReady and not isFragDeficient

    -- If Clone is done with this race, idle at Great Tree
    if ST.dn and (CFG.OneRaceMode or not isFragDeficient) then
        if getgenv().V4Hub == "gear" then
            getgenv().V4Hub = nil
            if type(getgenv().config) == "table" then
                getgenv().config.Enabled = false
            end
            if getgenv().AutoV4Cleanup then
                pcall(getgenv().AutoV4Cleanup)
            end
        end
        ST.rdy = false
        ReleaseTrainLock()
        SafeWriteJson(STATUS_FILE, ST)
        if CFG.OneRaceMode then
            TriggerFarmSyncChangeFolder("Clone FG race target: " .. tostring(targetRace))
        end
        if not InSea3() then
            return TravelToSea3()
        end
        return MoveToGreatTree()
    end

    -- Khi thiếu V3 hoặc chưa Pull đòn bẩy: không can thiệp gì cả, chỉ chạy script V3 Pull để tự làm hết
    if not isRaceReady then
        ST.ph  = "v3"
        ST.rdy = false
        ReleaseTrainLock()
        SafeWriteJson(STATUS_FILE, ST)
        if getgenv().V4Hub and getgenv().V4Hub ~= "v3" then
            getgenv().V4Hub = nil
        end
        RunHub("v3", function() LoadExternalScript(V3_BASE_URL .. V3_SCRIPTS[requiredRace]) end)
        return
    end

    -- Check state transition hop (train <-> trial)
    if InSea3() and CheckStateTransition(isCurrentlyTrained) then
        return
    end

    -- ====================================================================================
    -- ANTI-3-SUPPORT CHECK IN CURRENT SERVER
    -- ====================================================================================
    if SUPPORTS_MAP[PlayerName] then
        local othersCheck = GetOthersStatus(25)
        local _, _, _, _, cleanSupsCheck = CoordinateMoonServer(othersCheck, targetRace)
        local has3Sups, amExtraSup = CheckThreeSupportsInCurrentServer(othersCheck, targetRace, cleanSupsCheck)
        if has3Sups and amExtraSup then
            ST.ph = "leave_3sp"
            DebugWarn("ANTI-3SP", "3 Supports detected in server! LocalPlayer is redundant 3rd support. Leaving immediately...")
            return HopLowServer(false, true)
        end
    end

    -- ====================================================================================
    -- SEA 2 HANDLING (Khi đã đủ V3 + Pull nhưng đang ở Sea 2)
    -- ====================================================================================
    if not InSea3() then
        ST.rdy = false
        ReleaseTrainLock()
        SafeWriteJson(STATUS_FILE, ST)

        if isFragDeficient then
            ST.ph = "frag"
            local activeHub = getgenv().V4Hub
            if activeHub and activeHub ~= "frag" then return HopLowServer(false) end
            RunHub("frag", function() LoadExternalScript(V3_BASE_URL .. "autofarmfragment") end)
            return
        end

        -- Prereqs satisfied in Sea 2 -> Travel to Sea 3
        return TravelToSea3()
    end

    -- ====================================================================================
    -- PREREQUISITE AUDIT: FRAGMENT OR TRAINING
    -- ====================================================================================
    local pendingRequirement = isFragDeficient and "frag" or (not ST.tn) and "train" or nil

    if pendingRequirement then
        ST.ph  = pendingRequirement
        ST.rdy = false
        SafeWriteJson(STATUS_FILE, ST)

        local others = GetOthersStatus(25)
        local _, _, _, _, cleanSups = CoordinateMoonServer(others, targetRace)
        currentActiveHelpers = (#cleanSups == 2) and cleanSups or {}

        -- Train Anti-Collision Check: Claim atomic lock before training!
        if pendingRequirement == "train" then
            if not ClaimTrainLock() then
                return HopLowServer(false)
            end
        else
            ReleaseTrainLock()
        end

        local activeHub = getgenv().V4Hub
        if activeHub and activeHub ~= pendingRequirement then
            return HopLowServer(false)
        end

        if pendingRequirement == "frag" then
            RunHub("frag", function() LoadExternalScript(V3_BASE_URL .. "autofarmfragment") end)
        elseif pendingRequirement == "train" then
            RunHub("train", RunTrain)
        elseif pendingRequirement == "v3" then
            RunHub("v3", function() LoadExternalScript(V3_BASE_URL .. V3_SCRIPTS[requiredRace]) end)
        end
        return
    end

    -- Prerequisites fully satisfied: account is ready for trials!
    ReleaseTrainLock()
    ST.rdy = true
    SafeWriteJson(STATUS_FILE, ST)

    local others = GetOthersStatus(25)
    local targetJob, isRegisteredSup, clonesCanJoin, supsInTargetServer, cleanSups, backupJob, totalMoons, backupHolder = CoordinateMoonServer(others, targetRace)
    currentActiveHelpers = (#cleanSups == 2) and cleanSups or {}

    if getgenv().V4Hub and getgenv().V4Hub ~= "gear" then
        return HopLowServer(false)
    end

    -- ====================================================================================
    -- SUPPORT WORKFLOW (WAIT FOR CLONE MOON, STRICT 2 SP + 1 CLONE VERIFICATION, NEVER HOP ACTIVE MOON)
    -- ====================================================================================
    if SUPPORTS_MAP[PlayerName] then
        -- 1. Anti-3-Support conflict resolution
        local has3Sups, amExtraSup = CheckThreeSupportsInCurrentServer(others, targetRace, cleanSups)
        if has3Sups and amExtraSup then
            ST.ph = "leave_3sp"
            return HopLowServer(false, true)
        end

        -- 2. If Support has duplicate race of target race, idle at Great Tree
        if SUPPORTS_MAP[PlayerName] == targetRace then
            if getgenv().V4Hub == "gear" then return HopLowServer(false) end
            MoveToGreatTree()
            ST.ph = "sp_extra"
            return
        end

        -- 3. If holding backup moon server, stay put
        if backupJob and game.JobId == backupJob and ST.m > 0 and not isRegisteredSup then
            if getgenv().V4Hub == "gear" then return HopLowServer(false) end
            MoveToGreatTree()
            ST.ph = "hold_backup"
            return
        end

        -- 4. In active moon server: verify EXACTLY 2 Supports + 1 Clone are physically in game before RealKid V4!
        if ST.m > 0 and not moonRejectedShortMoon then
            local presentSups = {}
            for _, sInfo in ipairs(CFG.Supports) do
                local sName = sInfo[1]
                if Players:FindFirstChild(sName) and IsSupportEligible(sName, others[sName], targetRace) then
                    table.insert(presentSups, sName)
                end
            end

            local presentClones = {}
            for _, cName in ipairs(CFG.Clones) do
                if Players:FindFirstChild(cName) and not (others[cName] and others[cName].dn) then
                    table.insert(presentClones, cName)
                end
            end

            -- STRICT VERIFICATION: Exactly 2 supports + at least 1 clone present in game.Players
            local hasExactly2Supports = (#presentSups == 2)
            local hasAtLeast1Clone   = (#presentClones >= 1)

            if hasExactly2Supports and hasAtLeast1Clone and ST.m == 2 and table.find(presentSups, PlayerName) then
                ST.ph = "gear"
                RunHub("gear", function() RunKaitunV4(presentSups, presentClones) end)
                return
            end

            if not getgenv().V4Hub then
                MoveToGreatTree()
                if game.JobId == targetJob then
                    ST.ph = (not hasExactly2Supports) and "wait2sp" or "canhmoon"
                elseif game.JobId == backupJob then
                    ST.ph = "hold_backup"
                else
                    ST.ph = "canhmoon"
                end
            end
            return
        end

        -- 5. Current server moon has ended (ST.m == 0 or rejected). Clear gear hub first!
        if getgenv().V4Hub == "gear" then
            getgenv().V4Hub = nil
            if type(getgenv().config) == "table" then
                getgenv().config.Enabled = false
            end
            if getgenv().AutoV4Cleanup then
                pcall(getgenv().AutoV4Cleanup)
            end
        end

        -- Join clone's main moon server immediately if registered
        if targetJob and isRegisteredSup and game.JobId ~= targetJob then
            if getgenv().V4Hub then return HopLowServer(false) end
            ST.ph = "join"
            DebugLog("SUPPORT", "Joining Moon server %s immediately!", targetJob)
            return TeleportToServer(targetJob, true)
        end

        -- Otherwise if a valid backup moon server exists, jump directly to it!
        if backupJob and backupJob ~= game.JobId then
            if getgenv().V4Hub then return HopLowServer(false) end
            ST.ph = "join"
            DebugLog("SUPPORT", "Main moon ended! Switching to backup moon server %s...", backupJob)
            return TeleportToServer(backupJob, true)
        end

        MoveToGreatTree()
        ST.ph = isRegisteredSup and "canhmoon" or "sp_extra"
        return
    end

    -- ====================================================================================
    -- CLONE WORKFLOW (2 MOON SERVERS REQUIRED, DEAD TIME WINDOW, STATE REFRESH HOP)
    -- ====================================================================================
    -- 1. Dead time window check: X:00 to X:09:59 idle and stop hopping
    if IsMoonDeadTimeWindow() and ST.m == 0 then
        if getgenv().V4Hub == "gear" then return HopLowServer(false) end
        MoveToGreatTree()
        ST.ph = "idle_moon_off"
        return
    end

    if moonRejectedShortMoon then
        BlacklistCurrentServer()
        if IsMoonDeadTimeWindow() then
            MoveToGreatTree()
            ST.ph = "idle_moon_off"
            return
        end
        ST.ph = "hunt"
        return HopLowServer(true)
    end

    if CLONES_MAP[PlayerName] then
        -- Ưu tiên chạy RealKid V4 ngay nếu đang ở server Full Moon (m == 2) có sẵn 2 Support hợp lệ
        if ST.m == 2 then
            local directSups = {}
            for _, sInfo in ipairs(CFG.Supports) do
                local sName = sInfo[1]
                if Players:FindFirstChild(sName) and IsSupportEligible(sName, others[sName], targetRace) then
                    table.insert(directSups, sName)
                end
            end
            if #directSups == 2 then
                local directClones = {}
                for _, cName in ipairs(CFG.Clones) do
                    if Players:FindFirstChild(cName) and not (others[cName] and others[cName].dn) then
                        table.insert(directClones, cName)
                    end
                end
                if table.find(directClones, PlayerName) then
                    ST.ph = "gear"
                    RunHub("gear", function() RunKaitunV4(directSups, directClones) end)
                    return
                end
            end
        end

        -- 2. Backup holder holding backup server
        if backupJob and (game.JobId == backupJob or PlayerName == backupHolder) and ST.m > 0 then
            if getgenv().V4Hub == "gear" then return HopLowServer(false) end
            MoveToGreatTree()
            ST.ph = "hold_backup"
            return
        end

        -- 3. In Main Moon Server
        if targetJob then
            if game.JobId == targetJob then
                if clonesCanJoin then
                    local presentSups = {}
                    for _, sInfo in ipairs(CFG.Supports) do
                        local sName = sInfo[1]
                        if Players:FindFirstChild(sName) and IsSupportEligible(sName, others[sName], targetRace) then
                            table.insert(presentSups, sName)
                        end
                    end

                    local presentClones = {}
                    for _, cName in ipairs(CFG.Clones) do
                        if Players:FindFirstChild(cName) and not (others[cName] and others[cName].dn) then
                            table.insert(presentClones, cName)
                        end
                    end

                    -- Verify 2 supports + 1 clone present and moon is full (m == 2)
                    if (#presentSups == 2) and (#presentClones >= 1) and ST.m == 2 and table.find(presentClones, PlayerName) then
                        ST.ph = "gear"
                        RunHub("gear", function() RunKaitunV4(presentSups, presentClones) end)
                        return
                    end

                    if getgenv().V4Hub == "gear" and ST.m ~= 2 then
                        getgenv().V4Hub = nil
                        if type(getgenv().config) == "table" then
                            getgenv().config.Enabled = false
                        end
                        if getgenv().AutoV4Cleanup then
                            pcall(getgenv().AutoV4Cleanup)
                        end
                        return HopLowServer(false)
                    end
                    if not getgenv().V4Hub then
                        MoveToGreatTree()
                    end
                    return
                else
                    MoveToGreatTree()
                    ST.ph = "wait2sp"
                    return
                end
            else
                -- Not yet in targetJob: check if 2 moon servers found
                local hasValidBackup = (backupJob ~= nil and totalMoons >= 2)
                if hasValidBackup then
                    if getgenv().V4Hub then return HopLowServer(false) end
                    if clonesCanJoin then
                        ST.ph = "spam_join"
                        TeleportToServer(targetJob, true)
                        return
                    else
                        MoveToGreatTree()
                        ST.ph = "wait2sp"
                        return
                    end
                else
                    -- Less than 2 moon servers: keep hunting low servers until 2 moon servers confirmed!
                    if clonesCanJoin and not failedJoinJobs[targetJob] then
                        if getgenv().V4Hub then return HopLowServer(false) end
                        ST.ph = "join"
                        if TeleportToServer(targetJob, false) then return end
                    end
                end
            end
        end
    end

    if getgenv().V4Hub == "gear" then
        getgenv().V4Hub = nil
        return HopLowServer(false)
    end

    if ST.m > 0 and (game.JobId == targetJob or game.JobId == backupJob) then
        MoveToGreatTree()
        ST.ph = (game.JobId == targetJob) and "wait2sp" or "hold_backup"
        return
    end

    if IsMoonDeadTimeWindow() then
        MoveToGreatTree()
        ST.ph = "idle_moon_off"
        return
    end

    -- Rate-limit initial hop on join
    if (os.time() - ST.jt < 4) and not (targetJob and failedJoinJobs[targetJob]) then
        return
    end

    -- Keep hopping low to discover moon servers until 2 moon servers are confirmed
    ST.ph = "hunt"
    return HopLowServer(true)
end

-- ========================================================================================
-- 20. MAIN LOOP STARTUP
-- ========================================================================================
DebugLog("INIT", "6V4 Auto Upgear Orchestrator initialized successfully for account %s.", PlayerName)
while task.wait(0.5) and not IsStopped() do
    local ok, err = pcall(TickOrchestrator)
    if not ok then
        DebugWarn("MAIN-LOOP", "Unhandled exception in tick loop: %s", tostring(err))
    end
end
