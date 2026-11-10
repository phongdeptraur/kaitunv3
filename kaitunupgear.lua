-- // ==============================================================================
-- // AXIOM KERNEL: RACE V4 KAITUN & MULTI-PAIR COORDINATION ENGINE [REVISION 6]
-- // Update: Account-Specific Target Auto-Mapping Table (FG = Full Gear, 1G = 1 Gear)
-- // Top-Deck Config: Auto-selects mode per username, fallback to base config if unlisted
-- // ==============================================================================
local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    repeat
        task.wait(0.05)
        LocalPlayer = Players.LocalPlayer
    until LocalPlayer
end
local myName = tostring(LocalPlayer.Name)
-- // =========================================================================
-- // CONFIG LOADER: NHẬN CONFIG TỪ BÊN NGOÀI LOADSTRING HOẶC FALLBACK MẶC ĐỊNH
-- // [AXIOM UPDATE]: XÓA BỎ 1G & CHANGE ACCOUNT - CHỈ DUY NHẤT UP FULL GEAR (FG)
-- // =========================================================================
local ExtConfig = getgenv().AxiomConfig or _G.AxiomConfig or {}

-- Danh sách Clone chỉ up duy nhất Full Gear (FG)
local ACCOUNTS_POOL = ExtConfig.CloneAccounts or ExtConfig.Clones or {
    "ChaosPrismNinja27", "CarterSlime200867", "ChillPrimal201611", "Chl0eEch0201829",
    "Circuit_OM3GA200551", "CircuitF0xRaven2002", "ChaseVoidMiner2014", "ClawZap201263",
    "Chloe_Hyper11", "Craz3_Phant0mRunn3r4", "ChrisDavis8rlc", "ChillRavenEcho53",
    "CrystalMaxCraft40", "CyberNinja200838", "DaltonEspinoza099", "Dani3lMysticIc32014",
    "DanielDaviseold", "Dalal_Sparkly1156", "DavidDavisdsia", "DavidMiller3i38"
}

local ACCOUNT_GEAR_TARGET_MAP = {}
for _, name in ipairs(ACCOUNTS_POOL) do
    ACCOUNT_GEAR_TARGET_MAP[name] = { Mode = "FG" }
end

local mappedTarget = ACCOUNT_GEAR_TARGET_MAP[myName] or { Mode = "FG" }
local targetMode = "FG"

-- Vô hiệu hóa hoàn toàn cơ chế Change Account
getgenv().ChangeAccountSettings = {
    ["Full Gear"]        = true,
    ["1 Gear"]           = false,
    ChangeWithoutReplace = false,
    Disabled             = true
}
-- // =========================================================================
-- // INSTANCE PURGE & RUNTIME INITIALIZATION
-- // =========================================================================
if getgenv().AxiomV4KaitunSuite then
    pcall(function() getgenv().AxiomV4KaitunSuite:Unload() end)
    task.wait(0.1)
end
repeat task.wait() until game:IsLoaded()
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local HttpService = cloneref(game:GetService("HttpService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))
local Lighting = cloneref(game:GetService("Lighting"))
-- [AXIOM FIX]: Auto Select Team (Marines) upon Script Execution
local function AutoSelectTeam()
    getgenv().Team = "Marines"
    local function FireTeamSelect()
        pcall(function()
            local remotes = ReplicatedStorage:FindFirstChild("Remotes")
            local commF = remotes and remotes:FindFirstChild("CommF_")
            if not commF then
                commF = ReplicatedStorage:WaitForChild("Remotes", 5):WaitForChild("CommF_", 5)
            end
            if commF then
                commF:InvokeServer("SetTeam", "Marines")
            end
        end)
        pcall(function()
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            local mainGui = playerGui and playerGui:FindFirstChild("Main")
            local chooseTeam = mainGui and mainGui:FindFirstChild("ChooseTeam")
            if chooseTeam and chooseTeam.Visible then
                local container = chooseTeam:FindFirstChild("Container")
                local marineFrame = container and container:FindFirstChild("Marines")
                local btnFrame = marineFrame and marineFrame:FindFirstChild("Frame")
                local textBtn = btnFrame and btnFrame:FindFirstChild("TextButton")
                if textBtn then
                    if typeof(firesignal) == "function" then
                        firesignal(textBtn.MouseButton1Click)
                        firesignal(textBtn.Activated)
                    elseif typeof(getconnections) == "function" then
                        for _, conn in pairs(getconnections(textBtn.MouseButton1Click)) do
                            conn.Function()
                        end
                        for _, conn in pairs(getconnections(textBtn.Activated)) do
                            conn.Function()
                        end
                    end
                end
            end
        end)
    end
    FireTeamSelect()
    task.spawn(function()
        for _ = 1, 25 do
            local currentTeam = LocalPlayer.Team
            if currentTeam and currentTeam.Name ~= "" and currentTeam.Name ~= "Neutral" then
                break
            end
            FireTeamSelect()
            task.wait(0.4)
        end
    end)
end
AutoSelectTeam()
-- [AXIOM FIX]: Wait for Character, RootPart and Player Data & Fragments to fully replicate
local function WaitForCharacterAndData()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart", 20)
    local data = LocalPlayer:WaitForChild("Data", 20)
    if data then
        for _ = 1, 100 do
            if data:FindFirstChild("Fragments") or data:FindFirstChild("Fragment") then
                break
            end
            task.wait(0.1)
        end
    end
    return char, hrp, data
end
pcall(WaitForCharacterAndData)
for _ = 1, 150 do
    if LocalPlayer and LocalPlayer:FindFirstChild("Data") and (LocalPlayer.Data:FindFirstChild("Fragments") or LocalPlayer.Data:FindFirstChild("Fragment")) then break end
    task.wait(0.1)
end
local serverJoinTimestamp = os.time()
-- // =========================================================================
-- // SUPPORT ACCOUNTS MATRIX (NHẬN TỪ CONFIG BÊN NGOÀI HOẶC FALLBACK MẶC ĐỊNH)
-- // =========================================================================
local DEFAULT_MAIN_PAIRS_MAP = {
    ["XxScarlettCodexX2020"] = { PairId = 1, Role = "1.1", TargetRace = "ghoul", Partner = "pxqmvtrka" },
    ["pxqmvtrka"]            = { PairId = 1, Role = "1.2", TargetRace = "skypiea", Partner = "XxScarlettCodexX2020" },

    ["FayeMaraz38"]          = { PairId = 2, Role = "2.1", TargetRace = "ghoul", Partner = "znwfhkjbc" },
    ["znwfhkjbc"]            = { PairId = 2, Role = "2.2", TargetRace = "skypiea", Partner = "FayeMaraz38" },

    ["OliviaGlitchStormyYT"] = { PairId = 3, Role = "3.1", TargetRace = "ghoul", Partner = "qvtxmrpka" },
    ["qvtxmrpka"]            = { PairId = 3, Role = "3.2", TargetRace = "skypiea", Partner = "OliviaGlitchStormyYT" },
}
local MAIN_PAIRS_MAP = ExtConfig.SupportAccounts or ExtConfig.Supports or ExtConfig.MainPairs or DEFAULT_MAIN_PAIRS_MAP
local isMainAccount = (MAIN_PAIRS_MAP[myName] ~= nil and MAIN_PAIRS_MAP[myName].PairId > 0)
local myMainInfo = isMainAccount and MAIN_PAIRS_MAP[myName] or nil
local App = {
    UIMounted = false,
    FragmentsLoaded = false,
    Running = true,
    IsMain = isMainAccount,
    MainInfo = myMainInfo,
    AccountRole = isMainAccount and string.format("Main %s", myMainInfo.Role) or "Clone",
    CurrentActivity = "Khởi tạo hệ thống V4 Kaitun...",
    IsHopping = false,
    IsChangingAccount = false,
    ActiveHub = "None",
    FullMoonDetected = false,
    CurrentSea = 0,
    PlayerRace = "Unknown",
    PlayerTier = "0",
    TrialStatus = "Checking...",
    RawTrialCode = "?",
    IsTrained = false,
    PreviousTrainedState = nil,
    IsReadyAtDoor = false,
    CurrentDoorDistance = 9999,
    Threads = {},
    Connections = {},
    Instances = {}
}
getgenv().AxiomV4KaitunSuite = App
-- // =========================================================================
-- // TỌA ĐỘ CHÍNH XÁC CỦA TỪNG CỔNG TỘC (DOOR WAYPOINTS)
-- // =========================================================================
local RACE_DOOR_POSITIONS = {
    ["mink"]    = Vector3.new(29020.66015625, 14889.426757812, -379.2682800293),
    ["fishman"] = Vector3.new(28224.056640625, 14889.426757812, -210.58720397949),
    ["cyborg"]  = Vector3.new(28492.4140625, 14894.426757812, -422.11001586914),
    ["skypiea"] = Vector3.new(28967.408203125, 14918.075195312, 234.31198120117),
    ["ghoul"]   = Vector3.new(28672.720703125, 14889.127929688, 454.59616088867),
    ["human"]   = Vector3.new(29237.294921875, 14889.426757812, -206.94955444336)
}
local TEMPLE_ENTRANCE_V3 = Vector3.new(28286.35546875, 14895.301757812, 102.62469482422)
local SIGNAL_FILE = "Axiom_V4_FullMoon_Signals.json"
local TRAIN_SESSION_FILE = "Axiom_V4_Train_Sessions.json"
-- // =========================================================================
-- // AXIOM HEADLESS LOW-PLAYER SERVER HOP ENGINE
-- // Parallel 100-Page Server Browser Scanner & Direct Teleport Pipeline
-- // Zero UI // Instant Execution // Auto Low-Server Join & Exit
-- // =========================================================================
local HopCFG = {
    MaxPages       = 100,
    MaxPlayers     = 8,
    PageRetries    = 3,
    PageStartDelay = 0.02,
    RetryDelay     = 0.2,
    ScanTimeout    = 8,
    BrowserWait    = 1.25,
    TeleportWait   = 6
}

local VisitedServers = getgenv().Axiom_VisitedJobs or {}
getgenv().Axiom_VisitedJobs = VisitedServers
table.insert(VisitedServers, tostring(game.JobId))

local TP = { StartedAt = 0, FailedAt = 0, Failure = "" }

pcall(function()
    TeleportService.TeleportInitFailed:Connect(function(player, result, message)
        if player ~= LocalPlayer then return end
        TP.FailedAt = os.clock()
        TP.Failure = tostring(result and result.Name or result) .. " | " .. tostring(message or "")
    end)

    LocalPlayer.OnTeleport:Connect(function(state)
        local name = ""
        pcall(function() name = state.Name end)
        if name == "Failed" then
            TP.FailedAt = os.clock()
            TP.Failure = "OnTeleport: Failed"
        else
            TP.StartedAt = os.clock()
        end
    end)
end)

local function ScanBrowserPages()
    local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
    if not browser then return nil end

    local byJob = {}
    local completed = 0

    for page = 1, HopCFG.MaxPages do
        task.delay((page - 1) * HopCFG.PageStartDelay, function()
            local servers
            for attempt = 1, HopCFG.PageRetries do
                local ok, result = pcall(function() return browser:InvokeServer(page) end)
                if ok and type(result) == "table" then
                    servers = result
                    break
                end
                if attempt < HopCFG.PageRetries then task.wait(HopCFG.RetryDelay) end
            end

            if type(servers) == "table" then
                for jobId, data in pairs(servers) do
                    if type(data) == "table" then
                        local count = tonumber(data.Count) or 99
                        local id = tostring(jobId)
                        if id ~= tostring(game.JobId) and not table.find(VisitedServers, id) and count <= HopCFG.MaxPlayers then
                            local oldData = byJob[id]
                            if not oldData or count < oldData.Count then
                                byJob[id] = { JobId = id, Count = count, Region = tostring(data.Region or "Unknown") }
                            end
                        end
                    end
                end
            end
            completed = completed + 1
        end)
    end

    local deadline = os.clock() + HopCFG.ScanTimeout
    repeat task.wait(0.03) until completed >= HopCFG.MaxPages or os.clock() >= deadline

    local pool = {}
    for _, server in pairs(byJob) do pool[#pool + 1] = server end

    table.sort(pool, function(a, b)
        if a.Count == b.Count then return a.JobId < b.JobId end
        return a.Count < b.Count
    end)
    return pool
end

local function WaitTeleportState(duration)
    local deadline = os.clock() + duration
    repeat
        if TP.FailedAt > 0 then return "failed" end
        if TP.StartedAt > 0 then return "started" end
        task.wait(0.05)
    until os.clock() >= deadline
    return "timeout"
end

local function AttemptServerJoin(server)
    TP.StartedAt = 0
    TP.FailedAt = 0
    TP.Failure = ""

    table.insert(VisitedServers, server.JobId)
    warn(string.format("[AXIOM HOP] Attempting to join Job: %s (Players: %d)...", server.JobId, server.Count))

    local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
    local invoked = false
    if browser then
        invoked = pcall(function() browser:InvokeServer("teleport", server.JobId) end)
    end

    local state
    if invoked then state = WaitTeleportState(HopCFG.BrowserWait) end

    if not invoked or state ~= "started" then
        if state == "failed" then return false end
        local ok = pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, server.JobId, LocalPlayer)
        end)
        if not ok then return false end
        state = WaitTeleportState(HopCFG.TeleportWait)
    end

    if state == "started" then
        warn("[AXIOM HOP] Teleport handshake initiated successfully.")
        local deadline = os.clock() + 10
        repeat
            if TP.FailedAt > 0 then return false end
            task.wait(0.1)
        until os.clock() >= deadline
        if TP.FailedAt == 0 then return true end
    end
    return false
end

local function TriggerLowServerHop(force)
    -- [AXIOM GATE]: Tuyệt đối cấm Main x.2 hop server! Main x.1 được phép hop low khi trùng Main x.1 khác hoặc force hop!
    if App and App.IsMain and myMainInfo and myMainInfo.Role and myMainInfo.Role:sub(-1) == "2" then
        warn("[AXIOM GATE] ⛔ Chặn tuyệt đối: Main x.2 không được phép hop server! Chỉ có nhiệm vụ join theo x.1!")
        return false
    end
    if App and App.IsHopping and not force then
        if (os.time() - (App.LastHopTime or 0)) < 12 then
            return false
        end
    end
    if App then
        App.IsHopping = true
        App.LastHopTime = os.time()
        App.CurrentActivity = "🚀 Kích hoạt Headless Low-Player Server Hop (≤ 8 Players)..."
    end
    task.spawn(function()
        local pool = ScanBrowserPages()
        if pool and #pool > 0 then
            warn(string.format("[AXIOM HOP] Found %d low-player servers. Initiating connection...", #pool))
            for _, server in ipairs(pool) do
                if AttemptServerJoin(server) then
                    return
                end
            end
        end

        -- Fallback Roblox Public Game API Query
        warn("[AXIOM HOP] Querying Roblox Public Server API fallback...")
        local okApi, response = pcall(function()
            local url = string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId)
            return game:HttpGet(url)
        end)

        if okApi and response then
            local okJson, data = pcall(function() return HttpService:JSONDecode(response) end)
            if okJson and data and data.data then
                for _, sData in ipairs(data.data) do
                    if sData.playing and sData.playing <= HopCFG.MaxPlayers and tostring(sData.id) ~= tostring(game.JobId) and not table.find(VisitedServers, tostring(sData.id)) then
                        if AttemptServerJoin({ JobId = tostring(sData.id), Count = sData.playing }) then
                            return
                        end
                    end
                end
            end
        end
        if App then App.IsHopping = false end
    end)
    return true
end
getgenv().TriggerLowServerHop = TriggerLowServerHop
getgenv().ScanBrowserPages = ScanBrowserPages
getgenv().AttemptServerJoin = AttemptServerJoin
-- // =========================================================================
-- // =========================================================================
-- // AUTO TRAVEL SEA 3 ENGINE (PLACE IDS: 7449423635, 100117331123089)
-- // [AXIOM]: Tự động nhận diện Sea và kích hoạt TravelZou sang Sea 3 tức thì
-- // =========================================================================
local SEA3_PLACE_IDS = {
    [7449423635] = true,
    [100117331123089] = true,
}
local function CheckAndTravelSea3(): boolean
    if not SEA3_PLACE_IDS[game.PlaceId] then
        App.CurrentActivity = "🚢 Không ở Sea 3! Đang tự động dịch chuyển sang Sea 3 (TravelZou)..."
        pcall(function()
            local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
            commF:InvokeServer("TravelZou")
        end)
        return false
    end
    return true
end
task.spawn(function()
    while not SEA3_PLACE_IDS[game.PlaceId] do
        CheckAndTravelSea3()
        task.wait(4)
    end
end)
-- // CORE TELEMETRY & REAL-TIME DOOR PROXIMITY ENGINE
-- // =========================================================================
local function CleanRaceStr(str: string): string
    local clean = tostring(str or ""):match("^%s*(.-)%s*$"):lower()
    if clean == "rabbit" then return "mink" end
    if clean == "shark" then return "fishman" end
    if clean == "angel" or clean == "sky" then return "skypiea" end
    return clean
end
local function GetCurrentRace(): string
    local data = LocalPlayer and LocalPlayer:FindFirstChild("Data")
    local r = data and data:FindFirstChild("Race")
    return r and tostring(r.Value) or "Unknown"
end
local function GetPlayerFragments(): number
    local frags = 0
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        local f = data and (data:FindFirstChild("Fragments") or data:FindFirstChild("Fragment"))
        if f then
            frags = tonumber(f.Value) or 0
            App.FragmentsLoaded = true
        end
    end)
    return frags
end
local function GetDoorPosition(raceStr: string): Vector3?
    local clean = CleanRaceStr(raceStr)
    return RACE_DOOR_POSITIONS[clean]
end
-- // -------------------------------------------------------------------------
-- // TELEMETRY & TIER EXTRACTION ENGINE (REVISION 19 SPEC: DATA.RACE.C.VALUE + 0.2S WATCHER)
-- // -------------------------------------------------------------------------
local function ExtractLiveV4Tier(): string
    local tier = "0"
    pcall(function()
        local data = LocalPlayer:FindFirstChild("Data")
        if data and data:FindFirstChild("Race") then
            local raceFolder = data.Race
            -- [AXIOM FIX]: Chi lay gia tri C hoac Tier nam ben trong Race folder (V4 Gears)
            -- Tuyet doi KHONG fallback ra Data.RaceTier (vi do la cap Race V1-V3 = 3 gay hieu nham dat Tier >= 1)
            if raceFolder:FindFirstChild("C") then
                tier = tostring(raceFolder.C.Value)
            elseif raceFolder:FindFirstChild("Tier") then
                tier = tostring(raceFolder.Tier.Value)
            end
        elseif LocalPlayer:GetAttribute("Tier") then
            tier = tostring(LocalPlayer:GetAttribute("Tier"))
        end
    end)
    return tier
end
-- // ==============================================================================
-- // AXIOM TELEMETRY KERNEL: REMOTE COMMF_ UPGRADERACE CHECK & NORMALIZER
-- // ==============================================================================
local function UpdateTrialStatus()
    local Rep = game:GetService("ReplicatedStorage")

    local ok, res = pcall(function()
        return Rep.Remotes.CommF_:InvokeServer("UpgradeRace", "Check")
    end)

    if not ok then
        App.RawTrialCode = "Err"
        App.TrialStatus = "Check Err: " .. tostring(res)
        App.IsTrained = false
        return
    end

    -- [AXIOM TRAIN CHECK]: 0 hoặc nil => Ready for Train (Đã train), trường hợp còn lại => Chưa train (Need Training)
    if res == 0 or res == "0" or res == nil or res == "nil" then
        App.RawTrialCode = 0
        App.IsTrained = true
        App.TrialStatus = "Ready for Train [" .. tostring(res or "nil") .. "]"
    else
        App.RawTrialCode = res
        App.IsTrained = false
        App.TrialStatus = "Need Training [" .. tostring(res) .. "]"
    end
end
-- // [AXIOM TRAINED NORMALIZER]: 0 HOẶC nil => ĐÃ TRAIN (Ready for Train), khác 0 HOẶC nil => CHƯA TRAIN
local function IsAccountTrained()
    local c = App.RawTrialCode
    local trained = (c == 0 or c == "0" or c == nil or c == "nil" or App.IsTrained == true)
    App.IsTrained = trained
    return trained
end
-- // [SAFE WRAPPERS]: Chặn đứng lỗi 'attempt to call a nil value' tại Line 3570
local function CheckTrainingState()
    UpdateTrialStatus()
    return App.TrialStatus
end

local function FastTeleportTo(jobId, placeId, callback)
    if not jobId or jobId == "" or tostring(jobId) == tostring(game.JobId) then
        return
    end
    local targetJob = tostring(jobId)
    local targetPlace = placeId or game.PlaceId
    warn(string.format("[AXIOM TELEPORT] 🚀 [FastTeleportTo] Kích hoạt kết nối JobId: %s...", targetJob:sub(1, 14)))
    
    pcall(function()
        local sb = ReplicatedStorage:FindFirstChild("__ServerBrowser")
        if sb then sb:InvokeServer("teleport", targetJob) end
    end)
    
    task.wait(0.25)
    
    local ok, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(targetPlace, targetJob, LocalPlayer)
    end)
    if not ok then
        pcall(function()
            game:GetService("TeleportService"):TeleportToPlaceInstance(targetPlace, targetJob, LocalPlayer)
        end)
    end
    
    if callback then pcall(callback) end
end
getgenv().FastTeleportTo = FastTeleportTo

local function CheckFullMoonActive(): boolean
    local ok, res = pcall(function()
        local sky = Lighting:FindFirstChildOfClass("Sky") or Lighting:FindFirstChild("Sky")
        local moonTex = sky and sky.MoonTextureId or ""
        local clock = Lighting.ClockTime
        local isNight = (clock >= 17.5 or clock <= 5.5)
        if Lighting:FindFirstChild("FullMoon") or Lighting:GetAttribute("FullMoon") == true then
            return true
        end
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        if commF then
            local okRemote, status = pcall(function() return commF:InvokeServer("CheckFullMoon") end)
            if okRemote and (status == true or status == 1 or tostring(status) == "true") then
                return true
            end
        end
        if isNight and string.find(moonTex, "9709149431") then
            return true
        end
        return false
    end)
    return (ok and res == true)
end

-- Vòng lặp cập nhật khoảng cách cửa tức thời theo thời gian thực (≤ 30 studs)
local doorProximityWatcherThread = task.spawn(function()
    while App.Running do
        pcall(function()
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local race = GetCurrentRace()
            local doorPos = GetDoorPosition(race)
            if root and doorPos then
                local dist = (root.Position - doorPos).Magnitude
                App.CurrentDoorDistance = math.floor(dist * 10) / 10
                App.IsReadyAtDoor = (dist <= 30)
            else
                App.CurrentDoorDistance = 9999
                App.IsReadyAtDoor = false
            end
        end)
        task.wait(0.2)
    end
end)
table.insert(App.Threads, doorProximityWatcherThread)

-- [AXIOM UPDATE]: ĐÃ XÓA TOÀN BỘ CƠ CHẾ CHANGE ACCOUNT & 1 GEAR (CHỈ UP FULL GEAR & KHÔNG ĐỔI ACC)
local function ExecuteChangeAccount(reason: string)
    -- Đã vô hiệu hóa hoàn toàn cơ chế Change Account theo yêu cầu
    return
end

local function CheckAccountSwitchConditions()
    -- Không bao giờ đổi Account, kể cả khi đạt Full Gear
    return
end

local function LaunchNightHubCakePrince()
    if not App.UIMounted or not App.FragmentsLoaded or not (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) then return end
    local rawCode = App.RawTrialCode
    if rawCode == 0 or rawCode == 5 or tostring(rawCode) == "0" or tostring(rawCode) == "5" then return end
    if App.HubLaunched or App.NightHubCakePrinceLaunched or App.IsLaunchingHub then return end
    if getgenv().Axiom_HubLaunched or getgenv().Axiom_NightHubLaunched or getgenv().Axiom_IsLaunchingHub then return end
    App.IsLaunchingHub = true
    getgenv().Axiom_IsLaunchingHub = true
    App.HubLaunched = true
    App.NightHubCakePrinceLaunched = true
    App.ActiveHub = "Night Hub [Cake Prince - Frag Farm]"
    getgenv().Axiom_HubLaunched = true
    getgenv().Axiom_NightHubLaunched = true
    getgenv().Axiom_ActiveHub = "Night Hub [Cake Prince - Frag Farm]"
    App.IsLaunchingHub = false
    getgenv().Axiom_IsLaunchingHub = false
    App.CurrentActivity = "🍰 [Need Train & Frag < 3k] Đang chạy Night Hub [Cake Prince] cày Fragments..."
    local targetKey = "NightHub_c5Rz2UiC1t8E"
    if isfolder and makefolder and writefile and readfile and isfile then
        if not isfolder("NightHub") then makefolder("NightHub") end
        if isfile("NightHub/key.txt") then
            if readfile("NightHub/key.txt"):match("^%s*(.-)%s*$") ~= targetKey then
                writefile("NightHub/key.txt", targetKey)
                task.wait(0.5)
            end
        else
            writefile("NightHub/key.txt", targetKey)
            task.wait(0.5)
        end
        if not isfolder("Night Hub") then makefolder("Night Hub") end
        if not isfolder("Night Hub/Hop Boss") then makefolder("Night Hub/Hop Boss") end
        local cfg = {
            ["Enable Fast Attack"] = true,
            ["Select Tool"] = "Melee",
            ["Auto Buso"] = true,
            ["Select Theme"] = "Dark",
            ["Tween Speed"] = "250",
            ["Auto Hop Fullmoon"] = false,
            ["Auto Hop Mirage Island"] = false,
            ["Select Boss"] = "Cake Prince",
            ["Auto Hop Find Boss"] = true,
            ["Start Farm Boss"] = true
        }
        local cfgFile = "Night Hub/Hop Boss/Night-" .. tostring(LocalPlayer.Name) .. "-Settings.json"
        writefile(cfgFile, HttpService:JSONEncode(cfg))
    end
    getgenv().Team = "Marines"
    loadstring(game:HttpGet("https://raw.githubusercontent.com/WhiteX1208/Scripts/refs/heads/main/HopScript.luau"))()
end

local function LaunchRealKidHopFullMoon()
    if App.RealKidHopFullMoonLaunched or getgenv().Axiom_RealKidHopFullMoonLaunched then return true end
    App.RealKidHopFullMoonLaunched = true
    getgenv().Axiom_RealKidHopFullMoonLaunched = true
    App.RealKidHopLaunchTime = os.clock()
    App.ActiveHub = "RealKid Hop [Full Moon]"
    getgenv().Axiom_ActiveHub = "RealKid Hop [Full Moon]"
    App.CurrentActivity = "🌕 Đang chạy RealKid Hop để tìm Full Moon..."
    warn("[AXIOM HUB] Khởi chạy RealKid Hop Full Moon...")

    local userId = tostring(LocalPlayer.UserId)
    local candidatePaths = {
        "RealKidHop_" .. userId .. ".json",
        "workspace/RealKidHop_" .. userId .. ".json"
    }

    local configData = {
        ["RaceV4Enabled"] = false,
        ["WeaponCategory"] = "Melee",
        ["SearchEnabled"] = true,
        ["GhostFruitEnabled"] = false,
        ["PortalEnabled"] = true,
        ["AttackEnabled"] = true,
        ["DebugEnabled"] = false,
        ["FruitEnabled"] = false,
        ["RandomEnabled"] = false,
        ["Destination"] = "Full Moon",
        ["RaidEnabled"] = false,
        ["GunHeight"] = 35,
        ["FruitWebhookEnabled"] = false,
        ["WebhookEnabled"] = false,
        ["RaceV3Enabled"] = false,
        ["BerryEnabled"] = false,
        ["AuraEnabled"] = true,
        ["SearchPause"] = 5,
        ["BossEnabled"] = false,
        ["StoreEnabled"] = true,
        ["KenEnabled"] = false,
        ["WebhookAddress"] = "",
        ["AttackHeight"] = 30,
        ["MovementSpeed"] = 200,
        ["InitialSide"] = "Marines",
        ["VisitedJobs"] = {
            ["ee552099-a308-457b-bf04-dea1ec4568a5"] = true
        },
        ["AutoLoadEnabled"] = false,
        ["Language"] = "Tiếng Việt"
    }

    local encoded = HttpService:JSONEncode(configData)
    pcall(function()
        if writefile then
            for _, p in ipairs(candidatePaths) do
                pcall(writefile, p, encoded)
            end
            if makefolder then
                pcall(makefolder, "realkidhop")
                pcall(makefolder, "workspace/realkidhop")
            end
            pcall(writefile, "realkidhop/config.json", encoded)
            pcall(writefile, "workspace/realkidhop/config.json", encoded)
        end
    end)
    warn(string.format("[AXIOM REALKID HOP] ✅ Đã lưu config Full Moon khóa cứng VisitedJobs vào workspace/RealKidHop_%s.json!", userId))

    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/RealKidHop.lua"))()
        end)
        if not ok then
            warn("[AXIOM HUB] RealKid Hop Load Error: " .. tostring(err))
        end
    end)
    return true
end
getgenv().LaunchRealKidHopFullMoon = LaunchRealKidHopFullMoon

local function HopNightHubFullMoonLow()
    return TriggerLowServerHop(true)
end
getgenv().HopNightHubFullMoonLow = HopNightHubFullMoonLow

local function ExecuteHop(reason)
    return TriggerLowServerHop(true)
end
getgenv().ExecuteHop = ExecuteHop
-- // =========================================================================
-- // EXACT LAUNCHER (MARU HUB KAITUN V4 ENGINE)
-- // [AXIOM]: Tích hợp cấu hình Maru Hub Kaitun V4 độc lập, loại bỏ hoàn toàn RealKid
-- // =========================================================================
-- // [AXIOM GATE]: CHỈ CHO PHÉP MARU V4 CHẠY KHI ĐÃ TRAIN XONG (READY UP GEAR) & VÀO SERVER FULL MOON MAIN
-- // [AXIOM GATE]: CẢ MAIN VÀ CLONE: BẮT BUỘC ĐÃ TRAIN VÀ Ở TRONG SERVER FULL MOON MỚI CHẠY MARU V4
-- // ==============================================================================
-- // AXIOM REALKID ENGINE: BASE CONFIG & AUTHORITATIVE WORKSPACE WRITERS
-- // [HOISTED FIX]: Đưa toàn bộ Config & Hàm ghi file lên trước các luồng Dispatcher
-- // Đảm bảo ghi chuẩn \workspace\RealKidHub\save2\<Username>.json & \workspace\RealKidHop_<UserId>.json
-- // ==============================================================================
local REALKID_BASE_CONFIG = {
    ["EspSeaEventIsland"] = false,
    ["UpgradeDragonTalon"] = false,
    ["ChangeTransparencyCanSee"] = false,
    ["LeviathanMultiCannon"] = false,
    ["RemoveHitVFX"] = false,
    ["ValueDamageMultiSegments"] = 30000,
    ["SafeMode"] = false,
    ["AutoTrainV4"] = false,
    ["TweenSpeedV4"] = 190,
    ["auto_ghoul_v1"] = false,
    ["AutoMelee"] = false,
    ["SelectBoatTarget"] = "My Boat",
    ["farm_m1_gun_sea"] = false,
    ["DungeonAccountStart"] = false,
    ["EspFlower"] = false,
    ["prehistoric_skull_guitar"] = false,
    ["AutoV3Target_Toggle"] = false,
    ["selected_fighting_style"] = "Black Leg",
    ["ResetAfterTrial"] = false,
    ["AutoFindKitsuneIsland"] = false,
    ["AutoCollectGear"] = false,
    ["RemoveDeathRespawnVFX"] = false,
    ["auto_farm_ectoplasm"] = false,
    ["AutoTpAncientClock"] = false,
    ["selected_team"] = "Marines",
    ["AutoSwords"] = false,
    ["AutoFindMirageIsland"] = false,
    ["MasterySword"] = false,
    ["FastAttackPlayers"] = true,
    ["TeleportToPlayer"] = false,
    ["ResetVolcanoAfterCollectingLoot"] = false,
    ["AutoEliteQuest"] = false,
    ["AutoDojoTrainer"] = false,
    ["AutoDracoFully"] = false,
    ["account_pick_slot_raid"] = false,
    ["AutoStackDarkbeard"] = false,
    ["auto_pirate_raid"] = false,
    ["autotwfruits"] = false,
    ["AcceptRainbowQuest"] = false,
    ["auto_farm_sea_event"] = false,
    ["AutoRelicDragoTrial"] = false,
    ["DisableNotify"] = false,
    ["discord_notice_mirage"] = false,
    ["AutoSlapDodgeAABB"] = false,
    ["selected_sea_events"] = {},
    ["ChooseSeaLevel"] = "Lv 1",
    ["AzureEmberToTrade"] = 1,
    ["AutoRemoveSkyFog"] = false,
    ["AutoUnlockedDonSwan"] = false,
    ["ignore_cake_prince"] = false,
    ["AutoTrainDragoV4"] = false,
    ["AutoTpAncientOne"] = false,
    ["SpectatePlayer"] = false,
    ["Berry"] = false,
    ["AutoHopChest"] = false,
    ["RandomAround"] = false,
    ["AutoLookAtMoon"] = false,
    ["card_selection"] = {},
    ["farm_height_2"] = 30,
    ["EspAdvancedFruitsDealer"] = false,
    ["AntiAFK"] = true,
    ["discord_notice_spy"] = false,
    ["AutoCollectDragonEggs"] = false,
    ["AutoYamaCDK"] = false,
    ["auto_farm_nearest_range"] = 500,
    ["JumpPowerSliderV2"] = 50,
    ["EspAuraColourDealers"] = false,
    ["AutoCraftEnchantScroll"] = false,
    ["EspChests"] = false,
    ["AutoAwakening"] = false,
    ["auto_zou_quest"] = false,
    ["AutoFarmObservationHop"] = false,
    ["auto_dragon_hunter"] = false,
    ["raidnew"] = false,
    ["AutoBloxFruit"] = false,
    ["MagicFruits"] = false,
    ["AutoGun"] = false,
    ["global_skill_hold_z"] = 10,
    ["AutoPhoenixDungeon"] = false,
    ["Select_Boss_Farm"] = "",
    ["EspIslandLocation"] = false,
    ["auto_travel_dressrosa"] = false,
    ["AutoPickDungeonCards"] = false,
    ["BringMobMax"] = "6",
    ["SelectedV4Gear2"] = "Alpha",
    ["RaceV4Aura"] = false,
    ["auto_raid_law"] = false,
    ["global_skill_hold_x"] = 10,
    ["AutoTeleportBarista"] = false,
    ["AutoResetWhenCompleteVolcano"] = false,
    ["AutoTushitaSword"] = false,
    ["AutoValkyrie"] = false,
    ["attack_method_golem"] = "Attack",
    ["auto_farm_materials"] = false,
    ["global_skill_hold_c"] = 10,
    ["AutoCollectDinoBones"] = false,
    ["AttackMultiSegmentsLeviathan"] = false,
    ["discord_ping_mode"] = "Không ping",
    ["PvPAimRadius"] = 150,
    ["EspGears"] = false,
    ["AutoUpgradeRaceV3"] = false,
    ["global_skill_keys"] = {"Z", "X", "C"},
    ["AutoDriveToHydraIsland"] = false,
    ["auto_buy_style"] = false,
    ["AutoFireShootHeartLeviathan"] = false,
    ["JumpPower"] = false,
    ["auto_cyborg"] = false,
    ["AutoCollectAzureEmber"] = false,
    ["global_skill_weapons"] = {"Melee", "Sword", "Blox Fruit", "Gun"},
    ["AutoSwanGlasses"] = false,
    ["AutoStartRaid"] = false,
    ["DungeonAutoJoin"] = false,
    ["Initialize"] = true,
    ["AutoEscapeRoughSea"] = false,
    ["GoToSharkmanNPC"] = false,
    ["AutoRengokuSword"] = false,
    ["auto_low_cpu_once"] = false,
    ["EnchantScrollType"] = "CommonScroll",
    ["discord_notice_stored_fruit"] = false,
    ["AutoChooseV4Gear"] = false,
    ["AutoKeyRengoku"] = false,
    ["auto_farm_general"] = false,
    ["AutoFindLeviathan"] = false,
    ["AutoFindPrehistoricIsland"] = false,
    ["AutoTryLuck"] = false,
    ["WalkSpeed"] = false,
    ["AutoDefense"] = false,
    ["HopBerry"] = false,
    ["AutoSerpentBow"] = false,
    ["TweenToDragoTrials"] = false,
    ["FarmMastery_G"] = false,
    ["auto_patch_prehistoric"] = false,
    ["BusuAura"] = true,
    ["AutoDragoV3"] = false,
    ["accept_quests"] = false,
    ["Chest"] = false,
    ["auto_citizen_quest"] = false,
    ["AutoTravel"] = false,
    ["AutoBuyHakiRecipes"] = false,
    ["toggle_portal_tp"] = true,
    ["AutoTweenHighestPoint"] = false,
    ["auto_farm_nearest"] = false,
    ["AutoTradeAzureEmber"] = false,
    ["AutoBuyLegendary"] = false,
    ["discord_fruit_rarities"] = {"Common", "Uncommon", "Rare", "Legendary", "Mythical"},
    ["DungeonMinPlayers"] = 2,
    ["AutoPrayGravestone"] = false,
    ["AutoSkullGuitar"] = false,
    ["discord_notice_prehistoric"] = false,
    ["auto_load_script"] = false,
    ["AutoDragoV2"] = false,
    ["multi_raid_players"] = {},
    ["StopWhenChalice"] = true,
    ["AutoCraftVolcanicMagnet"] = false,
    ["BringMode"] = "400",
    ["auto_farm_tyrant"] = false,
    ["AutoSellFish"] = false,
    ["EspFruits"] = false,
    ["auto_factory_raid"] = false,
    ["global_skill_hold_f"] = 10,
    ["AutoBuyChipFruit"] = false,
    ["AutoLeiAccessory"] = false,
    ["AutoGetCDK"] = false,
    ["EspPlayers"] = false,
    ["weapon_choice"] = "Melee",
    ["WalkSpeedSliderV2"] = 100,
    ["discord_notice_frozen"] = false,
    ["auto_training_dummy"] = false,
    ["AutoRainbowColors"] = false,
    ["auto_farm_leviathan"] = false,
    ["AutoSelectDungeon"] = false,
    ["auto_sea_event_friend"] = false,
    ["discord_notice_profile"] = false,
    ["tyrant_skull_guitar"] = false,
    ["AutoCompleteTrialRace"] = true,
    ["AutoSoulReaper"] = false,
    ["SelectedV4GearSlot"] = "Auto",
    ["AutoUnlockedPuzzle"] = false,
    ["AutoDarkBladeV3"] = false,
    ["AutoYamaSword"] = false,
    ["AutoHopSecretHint"] = false,
    ["KenAura2"] = false,
    ["AutoTeleportToShrineActived"] = false,
    ["auto_bartilo_quest"] = false,
    ["farm_m1_fruit_sea"] = false,
    ["RaceV3Aura"] = false,
    ["AutoStoreFruitFlag"] = false,
    ["MaxChestHop"] = 45,
    ["AutoBuyFruitsFlag"] = false,
    ["AutoSpawnPrehistoricIsland"] = true,
    ["BoatSpeedV7"] = "220",
    ["AutoBigmom"] = false,
    ["global_skill_hold_v"] = 10,
    ["AutoSailBoat"] = false,
    ["AutoCanvendishSword"] = false,
    ["ChooseBoats"] = "MarineGrandBrigade",
    ["DungeonDifficulty"] = "Normal",
    ["AutoMidnightBlade"] = false,
    ["AutoRandomBones"] = false,
    ["AutoHiddenQuest"] = false,
    ["TweenToLegendarySwordDealer"] = false,
    ["AutoTeleportFrozenDimension"] = false,
    ["AutoUnlockDoughDungeon"] = false,
    ["AutoFarmMaterialSkullGuitar"] = false,
    ["auto_destroy_lava"] = true,
    ["auto_mastery_fruits"] = false,
    ["EspLegendarySword"] = false,
    ["AutoDragoV1"] = false,
    ["EspBerries"] = false,
    ["global_skill_delay"] = 100,
    ["AutoDarkbeard"] = false,
    ["AutoBuyV4Gear"] = false,
    ["auto_multi_raid"] = false,
    ["autoshootgun"] = true,
    ["AutoObservationV2"] = false,
    ["AutoTushitaCDK"] = false,
    ["BaitSelection"] = "Basic Bait",
    ["AutoMirror"] = false,
    ["AutoCollectMirageChest"] = false,
    ["AutoBossToggle"] = false,
    ["AutoDriveToTikiOutport"] = false,
    ["AutoFarmObservation"] = false,
    ["selected_farm_target"] = "Auto Level",
    ["mastery_health_percent"] = 30,
    ["AutoSpawnRipIndra"] = false,
    ["Bringmob"] = true,
    ["hopantirs"] = false,
    ["AutoTwinHooks"] = false,
    ["auto_break_bottle"] = false,
    ["RodSelection"] = "Fishing Rod",
    ["AutoTweenAdvancedFruitDealer"] = false,
    ["AutoTweenEventFishingSpot"] = false,
    ["AutoKillPlayerAfterTrial"] = true,
    ["SwapDragoRace"] = false,
    ["AutoPullLever"] = false,
    ["AutoOpenMenuHopFarm"] = false,
    ["AutoResetLostBoat"] = false,
    ["AutoPrehistoricFully"] = false,
    ["AutoQuestBoss"] = false,
}

-- [AXIOM FIX]: Ghi file config AutoTrainV4 trực tiếp vào cả RealKidHub/save2 và workspace/RealKidHub/save2
local function SyncRealKidConfig(overrides)
    if not (writefile and HttpService) then return end
    pcall(function()
        local myAccName = tostring(LocalPlayer.Name)
        if makefolder then
            pcall(makefolder, "RealKidHub")
            pcall(makefolder, "RealKidHub/save")
            pcall(makefolder, "RealKidHub/save2")
            pcall(makefolder, "workspace/RealKidHub")
            pcall(makefolder, "workspace/RealKidHub/save")
            pcall(makefolder, "workspace/RealKidHub/save2")
        end
        local candidatePaths = {
            "RealKidHub/save/" .. myAccName .. ".json",
            "workspace/RealKidHub/save/" .. myAccName .. ".json",
            "RealKidHub/save2/" .. myAccName .. ".json",
            "workspace/RealKidHub/save2/" .. myAccName .. ".json"
        }
        local currentCfg = {}
        for _, p in ipairs(candidatePaths) do
            if isfile and isfile(p) then
                local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(p)) end)
                if ok and type(decoded) == "table" then
                    currentCfg = decoded
                    break
                end
            end
        end
        for k, v in pairs(REALKID_BASE_CONFIG) do
            if currentCfg[k] == nil then
                currentCfg[k] = v
            end
        end
        if type(overrides) == "table" then
            for k, v in pairs(overrides) do
                currentCfg[k] = v
            end
        end
        currentCfg["AutoPullLever"] = false
        currentCfg["AutoUpgradeRaceV3"] = false

        local encoded = HttpService:JSONEncode(currentCfg)
        for _, p in ipairs(candidatePaths) do
            pcall(writefile, p, encoded)
        end
        warn(string.format("[AXIOM REALKID] ✅ Đã lưu config RealKid (AutoTrainV4 = %s | AutoCompleteTrial = %s | Reset = %s | Kill = %s) cho %s!",
            tostring(currentCfg["AutoTrainV4"]),
            tostring(currentCfg["AutoCompleteTrialRace"]),
            tostring(currentCfg["ResetAfterTrial"]),
            tostring(currentCfg["AutoKillPlayerAfterTrial"]),
            myAccName))
    end)
end
getgenv().SyncRealKidConfig = SyncRealKidConfig

-- // =========================================================================
-- // [AXIOM REALKID V4 DYNAMIC CONFIG GENERATOR]
-- // Clone đã train: AutoComplete = true, AutoKill = true, AutoTrain = false
-- // Clone chưa train: AutoComplete = false, AutoTrain = true
-- // Main đã train: AutoComplete = true, ResetAfterTrial = true, AutoTrain = false
-- // Main chưa train: AutoComplete = false, AutoTrain = true
-- // =========================================================================
local function GetRealKidV4Config(isMain, isTrained)
    if isMain then
        if isTrained then
            return {
                ["AutoCompleteTrialRace"] = true,
                ["ResetAfterTrial"] = true,
                ["AutoKillPlayerAfterTrial"] = false,
                ["AutoTrainV4"] = false,
                ["AutoPullLever"] = false,
                ["AutoUpgradeRaceV3"] = false
            }
        else
            return {
                ["AutoCompleteTrialRace"] = false,
                ["ResetAfterTrial"] = false,
                ["AutoKillPlayerAfterTrial"] = false,
                ["AutoTrainV4"] = true,
                ["AutoPullLever"] = false,
                ["AutoUpgradeRaceV3"] = false
            }
        end
    else
        if isTrained then
            return {
                ["AutoCompleteTrialRace"] = true,
                ["AutoKillPlayerAfterTrial"] = true,
                ["ResetAfterTrial"] = false,
                ["AutoTrainV4"] = false,
                ["AutoPullLever"] = false,
                ["AutoUpgradeRaceV3"] = false
            }
        else
            return {
                ["AutoCompleteTrialRace"] = false,
                ["AutoKillPlayerAfterTrial"] = false,
                ["ResetAfterTrial"] = false,
                ["AutoTrainV4"] = true,
                ["AutoPullLever"] = false,
                ["AutoUpgradeRaceV3"] = false
            }
        end
    end
end

local function LaunchRealKidV4(force)
    local isTrained = IsAccountTrained()
    if isTrained then
        return LaunchMaruHubV4()
    end
    local isMain = App.IsMain or false
    local cfg = GetRealKidV4Config(isMain, false)
    return LaunchRealKidMain(cfg)
end

-- [AXIOM FIX]: Ghi file config RealKid Hop trực tiếp vào cả RealKidHop_<UserId>.json và workspace/RealKidHop_<UserId>.json
local function saveRealKidHopConfig(destination)
    destination = destination or "Cake Prince"
    local userId = tostring(LocalPlayer.UserId)
    local candidatePaths = {
        "RealKidHop_" .. userId .. ".json",
        "workspace/RealKidHop_" .. userId .. ".json"
    }

    local existingVisited = { ["09ca0d4c-8139-4079-a7d6-673f4830c30b"] = true }
    for _, p in ipairs(candidatePaths) do
        if isfile and isfile(p) then
            local success, raw = pcall(readfile, p)
            if success and raw and #raw > 0 then
                local ok, decoded = pcall(function() return HttpService:JSONDecode(raw) end)
                if ok and type(decoded) == "table" and type(decoded.VisitedJobs) == "table" then
                    for k, v in pairs(decoded.VisitedJobs) do
                        existingVisited[k] = v
                    end
                    break
                end
            end
        end
    end

    local isServer4Hours = (destination == "Server 4 Hours")
    local configData = {
        RaceV4Enabled = false,
        WeaponCategory = "Melee",
        SearchEnabled = true,
        GhostFruitEnabled = false,
        PortalEnabled = true,
        AttackEnabled = true,
        DebugEnabled = false,
        FruitEnabled = false,
        RandomEnabled = false,
        Destination = destination,
        RaidEnabled = false,
        GunHeight = 35,
        FruitWebhookEnabled = false,
        WebhookEnabled = false,
        RaceV3Enabled = false,
        BerryEnabled = false,
        AuraEnabled = true,
        SearchPause = isServer4Hours and 10 or 5,
        BossEnabled = not isServer4Hours,
        StoreEnabled = true,
        KenEnabled = false,
        WebhookAddress = "",
        AttackHeight = 30,
        MovementSpeed = 200,
        InitialSide = "Marines",
        VisitedJobs = existingVisited,
        AutoLoadEnabled = false,
        Language = "Tiếng Việt"
    }

    local encoded = HttpService:JSONEncode(configData)
    pcall(function()
        if writefile then
            for _, p in ipairs(candidatePaths) do
                pcall(writefile, p, encoded)
            end
            if makefolder then
                pcall(makefolder, "realkidhop")
                pcall(makefolder, "workspace/realkidhop")
            end
            pcall(writefile, "realkidhop/config.json", encoded)
            pcall(writefile, "workspace/realkidhop/config.json", encoded)
        end
    end)
    warn(string.format("[AXIOM REALKID HOP] ✅ Đã lưu config Destination = '%s' cho UserId %s vào %s!", destination, userId, candidatePaths[1]))
    return configData
end
getgenv().saveRealKidHopConfig = saveRealKidHopConfig

-- // KHỞI CHẠY REALKID MAIN (ĐỘC QUYỀN HUẤN LUYỆN V4)
-- // ==============================================================================
-- // AXIOM MARU HUB V4 CONTROLLER (TRIAL & UP V4 ENGINE)
-- // ==============================================================================
local function LaunchMaruHubV4()
    if App.MaruV4Launched or getgenv().Axiom_MaruV4Launched then 
        return true 
    end

    App.MaruV4Launched = true
    getgenv().Axiom_MaruV4Launched = true
    App.ActiveHub = "Maru Hub V4"
    getgenv().Axiom_ActiveHub = "Maru Hub V4"
    App.CurrentActivity = "👑 Đang chạy Maru Hub V4 để Up V4 / Làm Trial..."
    warn("[AXIOM HUB] Khởi chạy Maru Hub V4 qua Luarmor loader...")

    -- Cấu hình chuẩn Settings_V4 (Đã loại bỏ toàn bộ comment ngoại ngữ)
    _G.Settings_V4 = {
        ["LockTiers"] = 10,
        ["Lever"] = false,
        ["InVIPServ"] = false,
        ["HelperNameList"] = (function()
            local list = {}
            for accName, _ in pairs(MAIN_PAIRS_MAP) do
                table.insert(list, accName)
            end
            return list
        end)(),
        ["RaceSettings"] = {
            ["Enabled"] = false,
            ["RaceTarget"] = {"Mink"}
        },
        ["V4FarmList"] = ACCOUNTS_POOL,
        ["AutoFindFarmList"] = false,
        ["RandomFruit"] = false,
        ["RandomFruitStore"] = true,
        ["TaskAfterTier10"] = function() end
    }

    task.spawn(function()
        local ok, err = pcall(function()
            script_key = "MDGBmlZnYdQirbNXZGMVVNjGRJguNXqS";
            loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/a09d5e9d4ac343cd8fd069e6d3865ba9.lua"))()
        end)
        if not ok then
            warn("[AXIOM HUB] Lỗi nạp Maru Hub V4: " .. tostring(err))
        end
    end)
    return true
end
getgenv().LaunchMaruHubV4 = LaunchMaruHubV4

local function LaunchRealKidMain(configOverrides)
    -- [AXIOM HARD GUARD]: REALKID MAIN CHỈ ĐƯỢC CHẠY ĐỂ TRAIN!
    -- NẾU ĐÃ TRAIN XONG -> TUYỆT ĐỐI CẤM REALKID MAIN, CHUYỂN NGAY SANG MARU HUB V4!
    local isTrained = IsAccountTrained()
    if isTrained then
        warn("[AXIOM GATE] ⛔ Tài khoản ĐÃ TRAIN (Ready for Trial)! Chặn RealKid Main, kích hoạt Maru Hub V4!")
        if CheckFullMoonActive() then
            return LaunchMaruHubV4()
        end
        return false
    end
    if App.CurrentTreeTween then
        pcall(function() App.CurrentTreeTween:Cancel() end)
        App.CurrentTreeTween = nil
    end
    App.IsTreeTweening = false

    if App.RealKidMainLaunched or getgenv().Axiom_RealKidMainLaunched then
        if type(configOverrides) == "table" then
            SyncRealKidConfig(configOverrides)
        end
        return true
    end
    -- [AXIOM COEXISTENCE]: RealKid Hop va RealKid Main chay doc lap chong len nhau
    -- Neu can chay ca 2 thi chay RealKid Hop truoc, 5s sau moi chay RealKid Main
    if App.RealKidHopLaunchTime and (os.clock() - App.RealKidHopLaunchTime < 5) then
        local remWait = 5 - (os.clock() - App.RealKidHopLaunchTime)
        if remWait > 0 then
            warn(string.format("[AXIOM PIPELINE] ⏳ RealKid Hop vừa chạy! Chờ %.1fs để khởi chạy tiếp RealKid Main...", remWait))
            task.wait(remWait)
        end
    end
    App.RealKidMainLaunched = true
    getgenv().Axiom_RealKidMainLaunched = true
    App.ActiveHub = "RealKid Main"
    getgenv().Axiom_ActiveHub = "RealKid Main"
    App.CurrentActivity = "🏋️ Đang chạy RealKid Main (AutoTrainV4 = true)..."
    warn("[AXIOM HUB] Khởi chạy RealKid Main với AutoTrainV4...")
    local cfg = {
        ["AutoTrainV4"] = true,
        ["AutoPullLever"] = false,
        ["AutoUpgradeRaceV3"] = false
    }
    if type(configOverrides) == "table" then
        for k, v in pairs(configOverrides) do cfg[k] = v end
    end
    SyncRealKidConfig(cfg)
    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua"))()
        end)
        if not ok then
            warn("[AXIOM HUB] RealKid Main Load Error: " .. tostring(err))
        end
    end)
    return true
end
getgenv().LaunchRealKidMain = LaunchRealKidMain

-- // KHỞI CHẠY REALKID HOP (ĐỘC QUYỀN FARM FRAG CAKE PRINCE)
local function LaunchRealKidHopCakePrince()
    if App.HubLaunched and (App.ActiveHub == "RealKid Hop" or App.RealKidHopLaunched) then return true end
    if App.HubLaunched or App.RealKidHopLaunched or App.IsLaunchingHub or getgenv().Axiom_HubLaunched or getgenv().Axiom_IsLaunchingHub then
        if App.ActiveHub ~= "RealKid Hop" and getgenv().Axiom_ActiveHub ~= "RealKid Hop" then
            warn("[AXIOM HUB] Đang chạy hub khác (" .. tostring(App.ActiveHub) .. ") -> Buộc Hop để nạp RealKid Hop sạch!")
            ExecuteHop("Chuyển Hub -> RealKid Hop Cake Prince (Hop Reset)")
        end
        return false
    end
    App.IsLaunchingHub = true
    getgenv().Axiom_IsLaunchingHub = true
    App.HubLaunched = true
    App.RealKidHopLaunched = true
    App.ActiveHub = "RealKid Hop"
    getgenv().Axiom_HubLaunched = true
    getgenv().Axiom_RealKidHopLaunched = true
    getgenv().Axiom_ActiveHub = "RealKid Hop"
    App.IsLaunchingHub = false
    getgenv().Axiom_IsLaunchingHub = false
    App.CurrentActivity = "🍰 Đang chạy RealKid Hop (Cake Prince)..."
    warn("[AXIOM HUB] Khởi chạy RealKid Hop Cake Prince...")
    saveRealKidHopConfig("Cake Prince")
    task.spawn(function()
        local ok, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/RealKidHop.lua"))()
        end)
        if not ok then
            warn("[AXIOM HUB] RealKid Hop Load Error: " .. tostring(err))
        end
    end)
    return true
end
getgenv().LaunchRealKidHopCakePrince = LaunchRealKidHopCakePrince

-- // =========================================================================
-- // =========================================================================
-- // [MARU HUB V4 ROUTER KERNEL]
-- // RealKid Main CHỈ dùng Train V4. Đã Train xong -> Chạy Maru Hub V4!
-- // =========================================================================
local function CanLaunchMaruHubV4()
    local isFullMoon = CheckFullMoonActive()
    return (isFullMoon == true)
end
local CanLaunchRealKidV4 = CanLaunchMaruHubV4
-- // =========================================================================
-- // CƠ CHẾ CHỐNG TRÙNG SERVER TRAIN V4
-- // =========================================================================
local function ManageTrainServerCollisions()
    -- [AXIOM FIX]: Các account Main (x.1 & x.2) tuyệt đối không né tránh nhau, không tự hop khi thấy nhau!
    if App.IsMain or App.IsHopping or App.IsTrained then return end
    -- 1. Nếu Clone đang cần train V4 mà ở chung server với BẤT KỲ acc Main nào -> Hop Low Server
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and MAIN_PAIRS_MAP[plr.Name] and MAIN_PAIRS_MAP[plr.Name].PairId > 0 then
            App.CurrentActivity = string.format("⚠️ [Trùng Server Main] Phát hiện Main %s đang trong server! Đang Hop...", plr.Name)
            TriggerLowServerHop()
            return
        end
    end
    -- 2. Nếu ở chung với Clone khác cũng đang train V4 -> So sánh thời gian vào server (JoinTime)
    if not App.IsMain and isfile and writefile and readfile and HttpService then
        pcall(function()
            local sessions = {}
            if isfile(TRAIN_SESSION_FILE) then
                local ok, data = pcall(function() return HttpService:JSONDecode(readfile(TRAIN_SESSION_FILE)) end)
                if ok and type(data) == "table" then sessions = data end
            end
            local now = os.time()
            for name, info in pairs(sessions) do
                if type(info) == "table" and (not info.Heartbeat or (now - info.Heartbeat > 25)) then
                    sessions[name] = nil
                end
            end
            for name, info in pairs(sessions) do
                if name ~= myName and type(info) == "table" and info.JobId == tostring(game.JobId) and info.IsTraining then
                    local otherJoin = tonumber(info.JoinTime) or 0
                    if otherJoin < serverJoinTimestamp or (otherJoin == serverJoinTimestamp and myName > name) then
                        App.CurrentActivity = string.format("⚠️ [Trùng Server Clone Train] Clone %s vào trước! Mình vào sau -> Đang Hop...", name)
                        TriggerLowServerHop()
                        return
                    end
                end
            end
            sessions[myName] = {
                JobId = tostring(game.JobId),
                JoinTime = serverJoinTimestamp,
                IsTraining = true,
                Heartbeat = now
            }
            writefile(TRAIN_SESSION_FILE, HttpService:JSONEncode(sessions))
        end)
    end
end
-- // =========================================================================
-- // INTER-PROCESS COMMUNICATION (IPC) ENGINE (DISK SIGNALS + 5-MIN TTL)
-- // =========================================================================
local function ReadSignals(): table
    if not (isfile and readfile and HttpService and isfile(SIGNAL_FILE)) then return {} end
    local ok, res = pcall(function()
        return HttpService:JSONDecode(readfile(SIGNAL_FILE))
    end)
    return (ok and type(res) == "table") and res or {}
end
local function WriteSignals(data: table)
    if not (writefile and HttpService) then return end
    pcall(function()
        writefile(SIGNAL_FILE, HttpService:JSONEncode(data))
    end)
end
local function CleanExpiredSignals()
    local signals = ReadSignals()
    local now = os.time()
    local modified = false
    for pairId, info in pairs(signals) do
        if info.UpdatedAt and (now - info.UpdatedAt > 300) then
            signals[pairId] = nil
            modified = true
        end
    end
    if modified then WriteSignals(signals) end
end
-- // =========================================================================
-- // CƠ CHẾ CHỐNG TRÙNG SERVER FULL MOON TUYỆT ĐỐI CHO TẤT CẢ MAIN ACCOUNTS
-- // Không cho phép >= 2 Main khác cặp cùng ở trong 1 server Full Moon.
-- // Nếu phát hiện bất kỳ Main lạ nào -> Lập tức Hop server Full Moon Night Hub khác!
-- // =========================================================================
local function CheckMainFullMoonCollision(): boolean
    if not (App.IsMain and myMainInfo) then return false end
    -- [AXIOM GATE]: Tuyệt đối cấm Main x.2 kiểm tra collision và hop server!
    local isHost1 = (myMainInfo.Role and myMainInfo.Role:sub(-1) == "1")
    if not isHost1 then return false end
    if App.IsHopping then return true end
    if not CheckFullMoonActive() then return false end

    local function HandleCollisionHop()
        warn("[AXIOM COLLISION] ⚠️ Phát hiện trùng Main x.1 khác trong server Full Moon! Tiến hành Hop Low ngay...")
        TriggerLowServerHop(true)
    end

    local myJob = tostring(game.JobId)
    local partnerName = myMainInfo.Partner
    -- 1. Quét danh sách người chơi: nếu có Main khác ngoài Partner -> Collision
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and MAIN_PAIRS_MAP[plr.Name] and plr.Name ~= partnerName then
            App.CurrentActivity = string.format("⚠️ [Trùng Main Full Moon] Phát hiện Main khác (%s)! Đang hop...", plr.Name)
            HandleCollisionHop()
            return true
        end
    end
    -- 2. Quét IPC signals: nếu server này đã bị 1 cặp Main khác đăng ký trước
    local signals = ReadSignals()
    for pId, sig in pairs(signals) do
        if type(sig) == "table" and tostring(pId) ~= tostring(myMainInfo.PairId) and sig.JobId == myJob then
            local otherJoin = tonumber(sig.JoinTime) or tonumber(sig.UpdatedAt) or 0
            if serverJoinTimestamp > otherJoin or (serverJoinTimestamp == otherJoin and myName > tostring(sig.HostMain)) then
                App.CurrentActivity = string.format("⚠️ [Trùng Signal Full Moon] Cặp %s đã claim trước! Đang hop...", tostring(pId))
                HandleCollisionHop()
                return true
            end
        end
    end
    return false
end
local CheckMainX1FullMoonCollision = CheckMainFullMoonCollision
-- // =========================================================================
-- // ZERO-DELAY PIPELINE: BẮN TÍN HIỆU NGAY KHI MAIN X.1 TÌM THẤY & JOIN THÀNH CÔNG
-- // =========================================================================
local function BroadcastHostFound(pairId: number, targetJobId: string, playerCount: number)
    local signals = ReadSignals()
    local partnerName = myMainInfo and myMainInfo.Partner or ""
    local partnerAccEntry = MAIN_PAIRS_MAP[partnerName]
    local hostRace = CleanRaceStr(GetCurrentRace())
    local partnerRace = CleanRaceStr(partnerAccEntry and partnerAccEntry.TargetRace or "")
    signals[tostring(pairId)] = {
        PairId = pairId,
        HostMain = myName,
        PartnerMain = partnerName,
        HostRace = hostRace,
        PartnerRace = partnerRace,
        JobId = targetJobId,
        PlayerCount = playerCount or 1,
        HostJoined = false,
        PartnerJoined = false,
        AllowClones = false,
        IsOpen = true,
        JoinTime = os.time(),
        UpdatedAt = os.time()
    }
    WriteSignals(signals)
end
local function BroadcastHostJoined(pairId: number, targetJobId: string)
    local signals = ReadSignals()
    local pIdStr = tostring(pairId)
    if signals[pIdStr] and signals[pIdStr].JobId == targetJobId then
        signals[pIdStr].HostJoined = true
        signals[pIdStr].UpdatedAt = os.time()
        WriteSignals(signals)
    end
end
local function BroadcastPartnerJoined(pairId: number, targetJobId: string)
    local signals = ReadSignals()
    local pIdStr = tostring(pairId)
    if signals[pIdStr] and signals[pIdStr].JobId == targetJobId then
        signals[pIdStr].PartnerJoined = true
        signals[pIdStr].AllowClones = false -- [AXIOM FIX]: Tuyệt đối không mở Clone tại đây! Chỉ mở khi cả 2 Main đồng thời có mặt và có Full Moon!
        signals[pIdStr].UpdatedAt = os.time()
        WriteSignals(signals)
    end
end
local function BroadcastFullMoonSignal(pairId: number, isHost1: boolean)
    if CheckMainFullMoonCollision and CheckMainFullMoonCollision() then return end
    local signals = ReadSignals()
    local myJob = tostring(game.JobId)
    local currentCount = #Players:GetPlayers()
    local now = os.time()
    local pIdStr = tostring(pairId)
    local partnerName = myMainInfo and myMainInfo.Partner or ""
    local partnerPlayer = Players:FindFirstChild(partnerName)
    local isPartnerInServer = (partnerPlayer ~= nil)
    local hasFM = CheckFullMoonActive()
    local curSig = signals[pIdStr] or {}
    curSig.PairId = pairId
    curSig.HostMain = isHost1 and myName or (curSig.HostMain or partnerName)
    curSig.PartnerMain = isHost1 and partnerName or myName
    local partnerAccEntry = MAIN_PAIRS_MAP[partnerName]
    curSig.HostRace = CleanRaceStr(GetCurrentRace())
    curSig.PartnerRace = CleanRaceStr(partnerAccEntry and partnerAccEntry.TargetRace or "")
    curSig.JobId = myJob
    curSig.PlayerCount = currentCount
    curSig.HostJoined = true
    -- [CHỐT CHẶN CLONE]: Tuyệt đối không mở Clone khi x.2 chưa thực sự có mặt trong server!
    -- Chỉ khi cả 2 Main đồng thời có mặt VÀ Full Moon đang active thì mới mở AllowClones = true!
    if isPartnerInServer and hasFM then
        curSig.PartnerJoined = true
        curSig.BothMainsPresent = true
        curSig.AllowClones = true
    else
        curSig.PartnerJoined = false
        curSig.BothMainsPresent = false
        curSig.AllowClones = false
    end
    curSig.IsOpen = (currentCount < 12)
    curSig.UpdatedAt = now
    signals[pIdStr] = curSig
    WriteSignals(signals)
end
-- // =========================================================================
-- // TELEPORTATION & MOVEMENT ENGINE
-- // =========================================================================
local function TeleportToJobId(JOB_ID)
    repeat task.wait() until game:IsLoaded()
    if JOB_ID and JOB_ID ~= "" and tostring(JOB_ID) ~= tostring(game.JobId) then
        FastTeleportTo(JOB_ID)
    end
end
getgenv().TeleportToJobId = TeleportToJobId
local function DirectTween(targetCF: CFrame)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    local dist = (root.Position - targetCF.Position).Magnitude
    if dist <= 5 then
        root.CFrame = targetCF
        return
    end
    local dur = math.clamp(dist / 170, 0.4, 15)
    local tw = cloneref(game:GetService("TweenService")):Create(root, TweenInfo.new(dur, Enum.EasingStyle.Linear), { CFrame = targetCF })
    tw:Play()
    tw.Completed:Wait()
    root.CFrame = targetCF
end
local function EnterTempleRemote()
    pcall(function()
        local stash = ReplicatedStorage:FindFirstChild("MapStash")
        if stash and stash:FindFirstChild("Temple of Time") then
            local map = workspace:FindFirstChild("Map")
            if map and not map:FindFirstChild("Temple of Time") then
                stash["Temple of Time"]:Clone().Parent = map
            end
        end
    end)
    pcall(function()
        local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
        commF:InvokeServer("requestEntrance", TEMPLE_ENTRANCE_V3)
    end)
end
local function TweenToRaceDoor()
    local race = CleanRaceStr(GetCurrentRace())
    local doorPos = GetDoorPosition(race)
    if not doorPos then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if root and root.Position.Y < 10000 then
        EnterTempleRemote()
        task.wait(1)
    end
    DirectTween(CFrame.new(doorPos))
end
-- // =========================================================================
-- // MAIN ACCOUNT ARBITRATION & FULL MOON HUNTING
-- // [AXIOM FIX]: Tách luồng chuyên trách Host (x.1) và Follower (x.2)
-- // Main x.2 chủ động liên tục bắt sóng JobId của x.1 để join ngay lập tức!
-- // =========================================================================
local mainCoordinationThread = task.spawn(function()
    -- [SYNC LOCK] Wait until Character, UI and Fragments are loaded
    repeat
        task.wait(0.1)
    until App.UIMounted and App.FragmentsLoaded and (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and App.RawTrialCode ~= "?"
    while App.Running do
        if App.IsMain and myMainInfo then
            local isHost = (myMainInfo.Role:sub(-1) == "1")
            local pairId = myMainInfo.PairId
            local partnerName = myMainInfo.Partner
            local hasFM = CheckFullMoonActive()
            App.FullMoonDetected = hasFM
            if isHost then
                -- [AXIOM]: Main x.1 luon luon chay RealKid Hop moi server
                if not App.RealKidHopFullMoonLaunched then
                    LaunchRealKidHopFullMoon()
                end
                App.MainX1CakePrinceMode = false
                App.NightHubCakePrinceLaunched = false
                if hasFM then
                    if CheckMainFullMoonCollision and CheckMainFullMoonCollision() then
                        task.wait(3)
                    else
                        if App then App.FullMoonCheckedInitial = true end
                        _G.FullMoonCheckedInitial = true
                        BroadcastFullMoonSignal(pairId, true)
                        local partnerPlayer = Players:FindFirstChild(partnerName)
                        if not partnerPlayer then
                            App.CurrentActivity = string.format("🌕 [Main %s] Có Full Moon! Đã phát tín hiệu JobId cho x.2...", myMainInfo.Role)
                        else
                            App.CurrentActivity = string.format("🎉 Cả 2 Main cặp %d đã có mặt tại server Full Moon!", pairId)
                        end
                        local isTrained = IsAccountTrained()
                        if isTrained then
                            LaunchMaruHubV4()
                        else
                            local curFrags = GetPlayerFragments()
                            if curFrags >= 3000 then
                                LaunchRealKidMain(GetRealKidV4Config(true, false))
                            else
                                LaunchRealKidHopCakePrince()
                            end
                        end
                    end
                else
                    App.CurrentActivity = string.format("🌑 [Main %s] Server không có Full Moon! RealKid Hop đang tìm Full Moon...", myMainInfo.Role)
                end
            else
                -- [MAIN X.2 - FOLLOWER]: Không chạy Night Hub, kiểm tra sự hiện diện của Partner x.1
                -- [AXIOM FIX]: Chủ động đảm bảo Maru Hub V4 luôn được kích hoạt (trừ khi cần farm Cake Prince)
                local curFrags = GetPlayerFragments()
                local rawCode = App.RawTrialCode
                -- [AXIOM UPDATE]: RawCode 0 hoặc 5 (Max Tier Achieved) đều là Ready for Trial
                local isReadyTrial = (rawCode == 0 or rawCode == 5 or tostring(rawCode) == "0" or tostring(rawCode) == "5")
                local isNeedTrain = (rawCode ~= nil and not isReadyTrial and rawCode ~= "?")
                if isNeedTrain then
                    if curFrags < 3000 then
                        LaunchRealKidHopCakePrince()
                    else
                        LaunchRealKidMain(GetRealKidV4Config(true, false))
                    end
                    App.CurrentActivity = string.format("🏋️ [Main %s] %s -> Đang chạy RealKid Main AutoTrainV4...", myMainInfo.Role, tostring(App.TrialStatus))
                else
                    if hasFM then
                        LaunchMaruHubV4()
                    end
                end
                -- [AXIOM PIPELINE X.2]: Main x.2 tuyệt đối không kiểm tra collision hay hop server, chỉ bám theo x.1
                local partnerPlayer = Players:FindFirstChild(partnerName)
                if partnerPlayer then
                    if hasFM then
                        App.CurrentActivity = string.format("🎉 Cả 2 Main cặp %d đã có mặt tại server Full Moon! Mở cửa cho Clone...", pairId)
                        BroadcastFullMoonSignal(pairId, false)
                    else
                        App.CurrentActivity = string.format("⚠️ Cả 2 Main cặp %d cùng server nhưng KHÔNG CÓ Full Moon! Không tính Full Moon & không mở Clone...", pairId)
                    end
                else
                    -- [FAST PIPELINE X.2]: Bắt sóng JobId của x.1 ngay cả khi x.1 đang load!
                    local signals = ReadSignals()
                    local pairSignal = signals[tostring(pairId)]
                    if pairSignal and pairSignal.JobId and (os.time() - (pairSignal.UpdatedAt or 0) <= 300) then
                        if pairSignal.JobId ~= tostring(game.JobId) then
                            App.CurrentActivity = string.format("🚀 [Main %s] x.1 báo đã join %s! x.2 đang join theo (chưa mở Clone)...", myMainInfo.Role, pairSignal.JobId:sub(1, 14))
                            FastTeleportTo(pairSignal.JobId)
                            task.wait(5)
                        end
                    else
                        App.CurrentActivity = string.format("⏳ [Main %s] Đang chờ x.1 phát tín hiệu server Full Moon API ít người...", myMainInfo.Role)
                    end
                end
            end
        end
        task.wait(2)
    end
end)
table.insert(App.Threads, mainCoordinationThread)
-- // =========================================================================
-- // CLONE SWARM ENGINE (STRICT DISTINCT-RACE FILTERING & ANTI-LOOP LOCK)
-- // [AXIOM FIX]: Khóa cứng Clone khi đã ở server Full Moon cùng Main.
-- // Tuyệt đối không nhảy server khác tránh loop vô hạn giữa 2 server Full Moon!
-- // =========================================================================
local cloneSwarmThread = task.spawn(function()
    while App.Running do
        if not App.IsMain then
            local rawCode = App.RawTrialCode
            local isChecking = (App.TrialStatus == "Checking..." or App.TrialStatus == "Check Failed (Retrying...)" or rawCode == "?")
            local isReadyTrial = not isChecking and (rawCode == 0 or rawCode == 5 or rawCode == nil or tostring(rawCode) == "0" or tostring(rawCode) == "5" or string.find(tostring(App.TrialStatus), "Ready for Trial") ~= nil or string.find(tostring(App.TrialStatus), "Max Tier Achieved") ~= nil)
            local isNeedTrain = not isChecking and not isReadyTrial
            local curFrags = GetPlayerFragments()
            -- [AXIOM PROTOCOL]: Chỉ chạy Cake Prince khi Need Train VÀ Frag < 3k! Còn raw code 0 thì KHÔNG chạy!
            if isNeedTrain and curFrags < 3000 then
                App.CurrentActivity = string.format("🍰 [Clone %s] Need Train & Frag thấp (<3000: %d) -> Khóa sóng Full Moon, chỉ chạy Night Hub Cake Prince...", CleanRaceStr(GetCurrentRace()):upper(), curFrags)
                if not App.NightHubCakePrinceLaunched and App.UIMounted and App.FragmentsLoaded then
                    LaunchNightHubCakePrince()
                end
            else
                CleanExpiredSignals()
                local signals = ReadSignals()
                local myRace = CleanRaceStr(GetCurrentRace())
                local hasFM = CheckFullMoonActive()
                -- Kiểm tra sự hiện diện thực tế của Main trong server hiện tại
                local currentMainInServer = nil
                for mName, _ in pairs(MAIN_PAIRS_MAP) do
                    local p = Players:FindFirstChild(mName)
                    if p then
                        currentMainInServer = p
                        break
                    end
                end
                local rawCode = App.RawTrialCode
                local isChecking = (App.TrialStatus == "Checking..." or App.TrialStatus == "Check Failed (Retrying...)" or rawCode == "?")
                local isReadyTrial = not isChecking and (rawCode == 0 or rawCode == 5 or rawCode == nil or tostring(rawCode) == "0" or tostring(rawCode) == "5" or string.find(tostring(App.TrialStatus), "Ready for Trial") ~= nil or string.find(tostring(App.TrialStatus), "Max Tier Achieved") ~= nil)
                local isNeedTrain = not isChecking and not isReadyTrial
                -- [ĐIỀU KIỆN 1]: Đang need train mà đang trong server Full Moon với Main -> Hop Low ngay lập tức
                if isNeedTrain and hasFM and currentMainInServer then
                    App.CurrentActivity = string.format("⚠️ [Clone %s] Đang Need Train (%s) ở server Full Moon cùng Main (%s)! Tiến hành Hop Low...", myRace:upper(), tostring(App.TrialStatus), currentMainInServer.Name)
                    TriggerLowServerHop()
                    task.wait(5)
                -- [ĐIỀU KIỆN 2]: Đang need train -> Hoàn toàn ngắt nhận tín hiệu, đợi Maru farm đến khi Ready Trial (raw code = 0)
                elseif isNeedTrain then
                    if curFrags < 3000 then
                        LaunchRealKidHopCakePrince()
                    else
                        LaunchRealKidMain(GetRealKidV4Config(false, false))
                    end
                    App.CurrentActivity = string.format("🏋️ [Clone %s] %s -> Đang chạy RealKid Main AutoTrainV4...", myRace:upper(), tostring(App.TrialStatus))
                -- [ĐIỀU KIỆN 3]: Khi đã Ready Trial (raw code = 0) -> Mới tiếp tục bắt sóng tín hiệu Full Moon từ các Main
                elseif isReadyTrial then
                    local function IsAnyHubActive()
                        local g = getgenv and getgenv() or _G
                        if App and (App.IsRealKidMainRunning or App.IsRealKidHopRunning or App.IsRealKidRunning or App.ActiveHub or App.IsHubRunning) then
                            return true
                        end
                        if g then
                            if g.RealKidLoaded or g.realkid or g.RealKidHub or g.realkid_loaded or g.RealKidMainLoaded then return true end
                            if g.WazureLoaded or g.Wazure or g.WazureHub then return true end
                            if g.BananaLoaded or g.BananaHub then return true end
                            if g.HohoLoaded or g.HohoHub then return true end
                            if g.RedzLoaded or g.RedzHub then return true end
                            if g.MukuroLoaded or g.MukuroHub or g.MaruLoaded then return true end
                            if g.HubLoaded or g.CurrentHub or g.ActiveHub then return true end
                        end
                        return false
                    end

                    local char = LocalPlayer.Character
                    local root = char and char:FindFirstChild("HumanoidRootPart")
                    local GREAT_TREE_CF = CFrame.new(2281.81, 25.86, -6486.29)
                    local curTreeDist = root and math.floor((root.Position - GREAT_TREE_CF.Position).Magnitude) or 9999

                    -- Kiểm tra xem Clone đã ở trong server Full Moon cùng Main hay chưa
                    if currentMainInServer and hasFM then
                        if curTreeDist > 150 then
                            -- Clones duy trì vị trí tại Great Tree (chỉ khi chưa bật hub nào)
                            if IsAnyHubActive() then
                                if App.CurrentTreeTween then
                                    pcall(function() App.CurrentTreeTween:Cancel() end)
                                    App.CurrentTreeTween = nil
                                end
                                App.IsTreeTweening = false
                            else
                                if not App.IsTreeTweening then
                                    App.IsTreeTweening = true
                                    pcall(function()
                                        toTarget(GREAT_TREE_CF)
                                    end)
                                    App.IsTreeTweening = false
                                end
                            end
                        else
                            if App.CurrentTreeTween then
                                pcall(function() App.CurrentTreeTween:Cancel() end)
                                App.CurrentTreeTween = nil
                            end
                            App.IsTreeTweening = false
                            App.CurrentActivity = string.format("🌕 [Clone %s] Đã đến Great Tree & Ở server Full Moon cùng Main (%s)! Kích hoạt Maru Hub V4...", myRace:upper(), currentMainInServer.Name)
                            LaunchMaruHubV4()
                        end
                    else
                        local targetSignal = nil
                        -- [SIMULTANEOUS CLONE JOIN]: Chỉ khi AllowClones = true (cả 2 Main đã có mặt & Full Moon) mới join!
                        for _, sig in pairs(signals) do
                            if sig.AllowClones and sig.IsOpen and (os.time() - (sig.UpdatedAt or 0) <= 300) then
                                local hostRace = CleanRaceStr(sig.HostRace)
                                local partnerRace = CleanRaceStr(sig.PartnerRace)
                                if myRace == hostRace or myRace == partnerRace then
                                    -- Trùng tộc với Main -> bỏ qua
                                else
                                    if sig.JobId ~= tostring(game.JobId) then
                                        targetSignal = sig
                                        break
                                    end
                                end
                            end
                        end
                        if targetSignal then
                            if App.CurrentTreeTween then
                                pcall(function() App.CurrentTreeTween:Cancel() end)
                                App.CurrentTreeTween = nil
                            end
                            App.IsTreeTweening = false
                            App.CurrentActivity = string.format("⚡ [Clone %s] Nhận lệnh x.2 mở cửa! Toàn bộ Clone join đồng loạt: %s...", myRace:upper(), targetSignal.JobId:sub(1, 14))
                            TeleportToJobId(targetSignal.JobId)
                            task.wait(6)
                        else
                            local statusPrefix = currentMainInServer and string.format("Ở server Main (%s)", currentMainInServer.Name) or "Chờ tín hiệu Main x.2"
                            App.CurrentActivity = string.format("⏳ [Clone %s] Ready Trial [0] | Tree: %dm! %s...", myRace:upper(), curTreeDist, statusPrefix)
                        end
                    end
                else
                    App.CurrentActivity = string.format("⏳ [Clone %s] Đang kiểm tra trạng thái Trial...", myRace:upper())
                end
            end
        end
        task.wait(3)
    end
end)
table.insert(App.Threads, cloneSwarmThread)
-- // =========================================================================
-- // AXIOM KERNEL: SYNCHRONIZED RACE V3 AUTO-ACTIVATION & TRIAL PROXIMITY WATCHER
-- // Cơ chế bật V3 đồng loạt khi cả 3 acc (2 Main + 1 Clone đến sớm nhất) vào cổng.
-- // Sau khi bật V3, nếu quá 15s không teleport vào Trial room -> Reset nhân vật.
-- // =========================================================================
local isV3Executing = false
local v3SyncThread = task.spawn(function()
    while App.Running do
        pcall(function()
            if isV3Executing then return end
            local char = LocalPlayer.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not (root and hum and hum.Health > 0) then return end

            local myNearDoor, myDoorDist = IsPlayerNearDoor(LocalPlayer)
            if not myNearDoor then
                if CloneDoorArrivalTimes[myName] then
                    CloneDoorArrivalTimes[myName] = nil
                end
                return
            end

            if not CloneDoorArrivalTimes[myName] then
                CloneDoorArrivalTimes[myName] = os.time()
                pcall(function()
                    if writefile and HttpService then
                        local arrivals = {}
                        if isfile and isfile(DOOR_ARRIVAL_FILE) then
                            local ok, dec = pcall(function() return HttpService:JSONDecode(readfile(DOOR_ARRIVAL_FILE)) end)
                            if ok and type(dec) == "table" then arrivals = dec end
                        end
                        arrivals[myName] = os.time()
                        writefile(DOOR_ARRIVAL_FILE, HttpService:JSONEncode(arrivals))
                    end
                end)
            end

            -- 1. Quét tìm Main accounts trong server
            local mainsInServer = {}
            for _, plr in ipairs(Players:GetPlayers()) do
                if MAIN_PAIRS_MAP[plr.Name] and MAIN_PAIRS_MAP[plr.Name].PairId > 0 then
                    table.insert(mainsInServer, plr)
                end
            end

            if #mainsInServer < 2 then return end

            local main1Near = IsPlayerNearDoor(mainsInServer[1])
            local main2Near = IsPlayerNearDoor(mainsInServer[2])
            if not (main1Near and main2Near) then return end

            -- 2. Quét tìm Clone đang ở cổng và sắp xếp theo mốc thời gian đến sớm nhất
            local clonesAtDoor = {}
            local fileArrivals = {}
            pcall(function()
                if isfile and readfile and HttpService and isfile(DOOR_ARRIVAL_FILE) then
                    local ok, dec = pcall(function() return HttpService:JSONDecode(readfile(DOOR_ARRIVAL_FILE)) end)
                    if ok and type(dec) == "table" then fileArrivals = dec end
                end
            end)

            for _, plr in ipairs(Players:GetPlayers()) do
                if not MAIN_PAIRS_MAP[plr.Name] and (ACCOUNT_GEAR_TARGET_MAP[plr.Name] or (plr == LocalPlayer and not App.IsMain)) then
                    local cNear = IsPlayerNearDoor(plr)
                    if cNear then
                        if not CloneDoorArrivalTimes[plr.Name] then
                            CloneDoorArrivalTimes[plr.Name] = fileArrivals[plr.Name] or os.time()
                        end
                        table.insert(clonesAtDoor, plr)
                    else
                        CloneDoorArrivalTimes[plr.Name] = nil
                    end
                end
            end

            if #clonesAtDoor == 0 then return end

            table.sort(clonesAtDoor, function(a, b)
                local tA = fileArrivals[a.Name] or CloneDoorArrivalTimes[a.Name] or 9999999999
                local tB = fileArrivals[b.Name] or CloneDoorArrivalTimes[b.Name] or 9999999999
                if tA == tB then return a.Name < b.Name end
                return tA < tB
            end)

            local chosenClone = clonesAtDoor[1]

            local isEligible = false
            if App.IsMain then
                isEligible = true
            elseif chosenClone and chosenClone.Name == myName then
                isEligible = true
            end

            if not isEligible then return end

            -- Kích hoạt Race V3 đồng loạt khi đủ 2 Main + 1 Clone ưu tiên
            isV3Executing = true
            App.CurrentActivity = string.format("⚡ [V3 ENGINE] 2 Main (%s, %s) + Clone (%s) đã vào cổng! Kích hoạt V3...", mainsInServer[1].Name, mainsInServer[2].Name, chosenClone.Name)
            warn(string.format("[AXIOM V3] ⚡ Bật tộc V3 đồng loạt với 2 Main và Clone %s!", chosenClone.Name))

            local startPos = root.Position

            pcall(function()
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game)
                task.wait(0.05)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.T, false, game)
            end)
            pcall(function()
                local commE = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommE")
                if commE then commE:FireServer("ActivateAbility") end
            end)
            pcall(function()
                local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if commF then commF:InvokeServer("ActivateAbility") end
            end)

            -- Chờ tối đa 15s: nếu không biến ra khỏi cửa -> Reset nhân vật
            local v3TriggerTime = os.clock()
            local teleported = false
            while (os.clock() - v3TriggerTime) < 15 do
                task.wait(0.5)
                local currentC = LocalPlayer.Character
                local currentR = currentC and currentC:FindFirstChild("HumanoidRootPart")
                if currentR then
                    local dist = (currentR.Position - startPos).Magnitude
                    if dist > 40 then
                        teleported = true
                        App.CurrentActivity = "🎉 Đã teleport vào phòng Trial thành công!"
                        warn("[AXIOM V3] ✅ Đã biến vào phòng Trial thành công!")
                        break
                    end
                else
                    teleported = true
                    break
                end
            end

            if not teleported then
                App.CurrentActivity = "⚠️ Sau 15s bật V3 không biến vào Trial! Đang tiến hành Reset nhân vật..."
                warn("[AXIOM V3] ⚠️ Sau 15s không biến ra khỏi cửa! Thực hiện Reset nhân vật...")
                local deadC = LocalPlayer.Character
                local deadH = deadC and deadC:FindFirstChildOfClass("Humanoid")
                if deadH then deadH.Health = 0 end
                pcall(function() if deadC then deadC:BreakJoints() end end)
                task.wait(6)
            end
            isV3Executing = false
        end)
        task.wait(1)
    end
end)
table.insert(App.Threads, v3SyncThread)
-- // =========================================================================
-- // MASTER STATE DISPATCHER (NIGHT HUB & MARU HUB KAITUN V4 CONTROLLER)
-- // [AXIOM UPDATE]: Xóa bỏ toàn bộ RealKid, bỏ phân nhánh tier/train phức tạp.
-- // Main x.1: Luôn chạy Night Hub trước, chờ 5s rồi kích hoạt Maru Hub V4.
-- // Main x.2 & Clone: Vào game là phang thẳng Maru Hub Kaitun V4.
-- // =========================================================================
local stateDispatcherThread = task.spawn(function()
    -- [SYNC LOCK] Wait until UI is mounted, Character loaded, and telemetry is verified (with 8s timeout)
    local syncDeadline = os.clock() + 8
    repeat
        task.wait(0.1)
        if App.RawTrialCode == "?" then pcall(UpdateTrialStatus) end
    until ((App.UIMounted and (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")) and App.RawTrialCode ~= "?") or os.clock() >= syncDeadline)
    -- Đồng bộ Telemetry trước khi rẽ nhánh Hub
    for _ = 1, 20 do
        if App.RawTrialCode ~= "?" and App.TrialStatus ~= "Checking..." then break end
        pcall(UpdateTrialStatus)
        task.wait(0.2)
    end
    local isHost1 = (App.IsMain and myMainInfo and (myMainInfo.Role:sub(-1) == "1"))
    local rawCode = App.RawTrialCode
    local isReadyTrial = (rawCode == 0 or rawCode == 5 or tostring(rawCode) == "0" or tostring(rawCode) == "5")
    local isNeedTrain = (rawCode ~= nil and not isReadyTrial and rawCode ~= "?")
    local isLowFrag = (GetPlayerFragments() < 3000)
    -- [QUY TẮC MỚI]: Chỉ chạy Cake Prince khi Need Train (raw code khác 0 và nil) VÀ frag < 3k!
    -- Còn raw code 0 thì KHÔNG cần chạy Cake Prince!
    if isNeedTrain then
        if isLowFrag then
            LaunchRealKidHopCakePrince()
        else
            local isMain = App.IsMain or false
            LaunchRealKidMain(GetRealKidV4Config(isMain, false))
        end
        App.CurrentActivity = string.format("🏋️ [Train V4] %s -> Đang chạy RealKid Main AutoTrainV4...", tostring(App.TrialStatus))
    else
        if isHost1 then
            App.MainX1CakePrinceMode = false
            LaunchRealKidHopFullMoon()
            local initFM = CheckFullMoonActive()
            App.FullMoonDetected = initFM
            if initFM then
                App.FullMoonCheckedInitial = true
                _G.FullMoonCheckedInitial = true
                BroadcastFullMoonSignal(myMainInfo.PairId, true)
                LaunchMaruHubV4()
            end
        else
            if CheckFullMoonActive() then
                LaunchMaruHubV4()
            end
        end
    end
    while App.Running do
        if not CheckAndTravelSea3() then
            task.wait(3)
        else
            App.TrialStatus = CheckTrainingState()
            CheckAccountSwitchConditions()
            local rawCode = App.RawTrialCode
            local isReadyTrial = (rawCode == 0 or rawCode == 5 or tostring(rawCode) == "0" or tostring(rawCode) == "5")
            local isNeedTrain = (rawCode ~= nil and not isReadyTrial and rawCode ~= "?")
            local isLowFrag = (GetPlayerFragments() < 3000)
            local hasFM = CheckFullMoonActive()
            App.FullMoonDetected = hasFM
            if isNeedTrain and isLowFrag then
                -- Khi Need Train VÀ Frag < 3k: Chạy Cake Prince cày frag
                if isHost1 then App.MainX1CakePrinceMode = true end
                if not App.NightHubCakePrinceLaunched then
                    LaunchNightHubCakePrince()
                end
            else
                -- Khi Ready Trial [0] HOẶC Frag >= 3k:
                if isHost1 then
                    if not App.RealKidHopFullMoonLaunched then
                        LaunchRealKidHopFullMoon()
                    end
                    if hasFM then
                        if not (CheckMainX1FullMoonCollision and CheckMainX1FullMoonCollision()) then
                            if App then App.FullMoonCheckedInitial = true end
                            _G.FullMoonCheckedInitial = true
                            App.CurrentActivity = string.format("🌕 [Main %s] Có Full Moon! Giữ tín hiệu & Kích hoạt Maru Hub V4...", myMainInfo.Role)
                            App.MainX1CakePrinceMode = false
                            App.NightHubCakePrinceLaunched = false
                            BroadcastFullMoonSignal(myMainInfo.PairId, true)
                            LaunchMaruHubV4()
                        end
                    else
                        App.CurrentActivity = "🌕 [Main x.1] Đang chạy RealKid Hop tìm Full Moon..."
                        App.MainX1CakePrinceMode = false
                        App.NightHubCakePrinceLaunched = false
                    end
                else
                    if hasFM then
                        LaunchMaruHubV4()
                    end
                end
            end
            -- [AXIOM AUTO HOP]: Main x.1 độc quyền RealKid Hop Full Moon; Clone hop low khi quá 15p
            if not hasFM and not App.IsHopping and not App.IsChangingAccount and not App.NightHubCakePrinceLaunched and not (isHost1 and App.MainX1CakePrinceMode) then
                if isHost1 then
                    App.CurrentActivity = "🌕 Server không có Full Moon! Chạy RealKid Hop Full Moon..."
                    LaunchRealKidHopFullMoon()
                elseif not App.IsMain and (os.time() - serverJoinTimestamp >= 900) then
                    App.CurrentActivity = string.format("⏰ Đã ở server %d phút (quá 15p)! Đang Hop Low Server...", math.floor((os.time() - serverJoinTimestamp) / 60))
                    TriggerLowServerHop()
                end
            end
        end
        task.wait(2)
    end
end)
table.insert(App.Threads, stateDispatcherThread)
-- // [AXIOM]: Đã xóa bỏ hoàn toàn cơ chế Auto-Relaunch Night Hub chu kỳ 1 phút.
-- // Main x.1 chỉ chạy duy nhất 1 lần lúc vào game theo đúng thiết lập nguyên bản.
-- // =========================================================================
-- // CONTROL HUD & RADAR UI (EXPANDED SERVER STATUS & CLONE SWARM RADAR)
-- // =========================================================================
local function PurgeOldUI()
    for _, path in ipairs({ typeof(gethui) == "function" and gethui(), CoreGui, LocalPlayer:FindFirstChild("PlayerGui") }) do
        pcall(function()
            if path and path:FindFirstChild("AxiomV4KaitunDeckUI") then
                path.AxiomV4KaitunDeckUI:Destroy()
            end
        end)
    end
end
PurgeOldUI()
-- // [AXIOM PROXIMITY & TELEMETRY RADAR]
local CloneDoorArrivalTimes = {}
local DOOR_ARRIVAL_FILE = "Axiom_V4_Door_Arrivals.json"

local function IsPlayerNearDoor(plr)
    if not plr then return false, 9999 end
    local char = plr.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false, 9999 end
    local minDist = 9999
    for _, doorPos in pairs(RACE_DOOR_POSITIONS) do
        local d = (root.Position - doorPos).Magnitude
        if d < minDist then minDist = d end
        if d <= 30 then
            return true, d
        end
    end
    return false, minDist
end

-- Hàm nhận diện chính xác toàn bộ Clone chạy cùng bộ script đang có mặt trong server
local function GetServerClones(): {string}
    local clones = {}
    local seen = {}
    for _, plr in ipairs(Players:GetPlayers()) do
        if not MAIN_PAIRS_MAP[plr.Name] and (ACCOUNT_GEAR_TARGET_MAP[plr.Name] or (plr == LocalPlayer and not App.IsMain)) then
            seen[plr.Name] = true
            local nearDoor = IsPlayerNearDoor(plr)
            local col = nearDoor and "#00FF78" or "#FFD278"
            local meTag = (plr == LocalPlayer) and " [Me]" or ""
            local formattedName = string.format('<font color="%s">%s%s</font>', col, plr.Name, meTag)
            table.insert(clones, formattedName)
        end
    end
    pcall(function()
        if isfile and readfile and HttpService and isfile(TRAIN_SESSION_FILE) then
            local ok, sessions = pcall(function() return HttpService:JSONDecode(readfile(TRAIN_SESSION_FILE)) end)
            if ok and type(sessions) == "table" then
                local currentJob = tostring(game.JobId)
                for name, info in pairs(sessions) do
                    if type(info) == "table" and info.JobId == currentJob and not MAIN_PAIRS_MAP[name] and not seen[name] then
                        local p = Players:FindFirstChild(name)
                        if p then
                            seen[name] = true
                            local nearDoor = IsPlayerNearDoor(p)
                            local col = nearDoor and "#00FF78" or "#FFD278"
                            local meTag = (name == myName) and " [Me]" or ""
                            local formattedName = string.format('<font color="%s">%s%s</font>', col, name, meTag)
                            table.insert(clones, formattedName)
                        end
                    end
                end
            end
        end
    end)
    return clones
end

-- Hàm nhận diện và kiểm tra Partner chung server
local function GetServerPartners(): {string}
    local partners = {}
    local seen = {}
    if App.IsMain and myMainInfo then
        local pName = myMainInfo.Partner
        local pPlr = Players:FindFirstChild(pName)
        if pPlr then
            local nearDoor = IsPlayerNearDoor(pPlr)
            local col = nearDoor and "#00FF78" or "#FFD278"
            table.insert(partners, string.format('<font color="%s">%s [Đã vào]</font>', col, pName))
        else
            table.insert(partners, string.format('<font color="#FF5555">%s [Chưa vào]</font>', pName))
        end
    else
        local targetPairId = nil
        for _, plr in ipairs(Players:GetPlayers()) do
            if MAIN_PAIRS_MAP[plr.Name] and MAIN_PAIRS_MAP[plr.Name].PairId > 0 then
                targetPairId = MAIN_PAIRS_MAP[plr.Name].PairId
                break
            end
        end
        if targetPairId then
            for mName, mInfo in pairs(MAIN_PAIRS_MAP) do
                if mInfo.PairId == targetPairId and not seen[mName] then
                    seen[mName] = true
                    local pPlr = Players:FindFirstChild(mName)
                    if pPlr then
                        local nearDoor = IsPlayerNearDoor(pPlr)
                        local col = nearDoor and "#00FF78" or "#FFD278"
                        table.insert(partners, string.format('<font color="%s">%s [Đã vào]</font>', col, mName))
                    else
                        table.insert(partners, string.format('<font color="#FF5555">%s [Chưa vào]</font>', mName))
                    end
                end
            end
        else
            for mName, _ in pairs(MAIN_PAIRS_MAP) do
                local pPlr = Players:FindFirstChild(mName)
                if pPlr and not seen[mName] then
                    seen[mName] = true
                    local nearDoor = IsPlayerNearDoor(pPlr)
                    local col = nearDoor and "#00FF78" or "#FFD278"
                    table.insert(partners, string.format('<font color="%s">%s [Đã vào]</font>', col, mName))
                end
            end
            if #partners == 0 then
                table.insert(partners, '<font color="#FF5555">Chưa có Main nào</font>')
            end
        end
    end
    return partners
end
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AxiomV4KaitunDeckUI"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999999999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
local function MountGuiSafely(gui)
    local mounted = false
    if typeof(gethui) == "function" then
        mounted = pcall(function() gui.Parent = gethui() end)
    end
    if not mounted and CoreGui then
        mounted = pcall(function() gui.Parent = CoreGui end)
    end
    if not mounted and LocalPlayer then
        pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui", 5) end)
    end
end
MountGuiSafely(screenGui)
    App.UIMounted = true
    pcall(GetPlayerFragments)
table.insert(App.Instances, screenGui)
local mainCard = Instance.new("Frame", screenGui)
mainCard.Name = "MainCard"
mainCard.Size = UDim2.new(0, 440, 0, 436)
mainCard.Position = UDim2.new(0.5, -220, 0.5, -218)
mainCard.BackgroundColor3 = Color3.fromRGB(12, 16, 22)
mainCard.BorderSizePixel = 0
Instance.new("UICorner", mainCard).CornerRadius = UDim.new(0, 10)
local stroke = Instance.new("UIStroke", mainCard)
stroke.Color = Color3.fromRGB(0, 210, 255)
stroke.Thickness = 1.6
local title = Instance.new("TextLabel", mainCard)
title.Size = UDim2.new(1, -180, 0, 30)
title.Position = UDim2.new(0, 10, 0, 6)
title.BackgroundTransparency = 1
title.Text = "AXIOM // V4 RADAR & REAL-TIME PROXIMITY KERNEL"
title.TextColor3 = Color3.fromRGB(0, 220, 255)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 13
title.TextXAlignment = Enum.TextXAlignment.Left

-- [AXIOM UI]: Timer 45p đếm ngược & Kick nếu ở 1 server quá 45 phút
local lblTimer = Instance.new("TextLabel", mainCard)
lblTimer.Name = "ServerTimerLabel"
lblTimer.Size = UDim2.new(0, 85, 0, 30)
lblTimer.Position = UDim2.new(1, -170, 0, 6)
lblTimer.BackgroundTransparency = 1
lblTimer.TextColor3 = Color3.fromRGB(255, 200, 80)
lblTimer.Font = Enum.Font.SourceSansBold
lblTimer.TextSize = 12
lblTimer.TextXAlignment = Enum.TextXAlignment.Right
lblTimer.Text = "⏱️ 45:00"

-- [AXIOM UI]: Hiển thị Ping thời gian thực ở góc phải UI Header
local lblPing = Instance.new("TextLabel", mainCard)
lblPing.Name = "PingLabel"
lblPing.Size = UDim2.new(0, 80, 0, 30)
lblPing.Position = UDim2.new(1, -85, 0, 6)
lblPing.BackgroundTransparency = 1
lblPing.TextColor3 = Color3.fromRGB(0, 255, 180)
lblPing.Font = Enum.Font.SourceSansBold
lblPing.TextSize = 12
lblPing.TextXAlignment = Enum.TextXAlignment.Right
lblPing.Text = "📶 -- ms"
-- Dragging logic
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainCard.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
local dragConn = UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        mainCard.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)
table.insert(App.Connections, dragConn)
local telemetryBox = Instance.new("Frame", mainCard)
telemetryBox.Size = UDim2.new(1, -20, 0, 280)
telemetryBox.Position = UDim2.new(0, 10, 0, 40)
telemetryBox.BackgroundColor3 = Color3.fromRGB(18, 24, 34)
Instance.new("UICorner", telemetryBox).CornerRadius = UDim.new(0, 8)
local function MakeHudLabel(yPos, color)
    local lbl = Instance.new("TextLabel", telemetryBox)
    lbl.Size = UDim2.new(1, -16, 0, 18)
    lbl.Position = UDim2.new(0, 8, 0, yPos)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = color
    lbl.Font = Enum.Font.SourceSansBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    return lbl
end
local lblRole         = MakeHudLabel(6, Color3.fromRGB(255, 215, 0))
local lblRace         = MakeHudLabel(24, Color3.fromRGB(0, 255, 180))
local lblFilter       = MakeHudLabel(42, Color3.fromRGB(255, 170, 0))
local lblFullMoon     = MakeHudLabel(60, Color3.fromRGB(255, 120, 220))
local lblTrial        = MakeHudLabel(78, Color3.fromRGB(120, 200, 255))
local lblDoor         = MakeHudLabel(96, Color3.fromRGB(255, 150, 50))
local lblChange       = MakeHudLabel(114, Color3.fromRGB(150, 220, 255))
local lblChangeStatus = MakeHudLabel(132, Color3.fromRGB(255, 215, 0))
local lblActive       = MakeHudLabel(150, Color3.fromRGB(0, 220, 255))
local lblServer       = MakeHudLabel(168, Color3.fromRGB(130, 220, 255))
local lblClones       = MakeHudLabel(186, Color3.fromRGB(255, 210, 120))
lblClones.RichText   = true
local lblPartners     = MakeHudLabel(204, Color3.fromRGB(255, 210, 120))
lblPartners.RichText = true
local lblActivity = Instance.new("TextLabel", telemetryBox)
lblActivity.Size = UDim2.new(1, -16, 0, 48)
lblActivity.Position = UDim2.new(0, 8, 0, 224)
lblActivity.BackgroundTransparency = 1
lblActivity.TextColor3 = Color3.fromRGB(220, 230, 245)
lblActivity.Font = Enum.Font.SourceSans
lblActivity.TextSize = 11
lblActivity.TextWrapped = true
lblActivity.TextXAlignment = Enum.TextXAlignment.Left
lblActivity.TextYAlignment = Enum.TextYAlignment.Top
-- Action Buttons
local function MakeButton(yPos, text, color, cb)
    local btn = Instance.new("TextButton", mainCard)
    btn.Size = UDim2.new(1, -20, 0, 30)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = color
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 12
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    btn.MouseButton1Click:Connect(function() pcall(cb) end)
    return btn
end
MakeButton(326, "🌕 CHẠY REALKID HOP FULL MOON", Color3.fromRGB(0, 140, 95), function() LaunchRealKidHopFullMoon() end)
MakeButton(360, "🌐 HOP SERVER LOW (BÌNH THƯỜNG)", Color3.fromRGB(45, 80, 150), function()
    TriggerLowServerHop()
end)
local btnUnload = MakeButton(394, "⛔ DỪNG VÀ UNLOAD AXIOM V4 SUITE", Color3.fromRGB(180, 35, 45), function()
    App:Unload()
end)
-- [AXIOM PING GUARD ENGINE]: 1s cập nhật 1 lần, kick nếu đứng 1 giá trị quá 5s (kể cả thấp hay cao)
local pingWatcherThread = task.spawn(function()
    local lastPing = nil
    local frozenSeconds = 0
    while App.Running do
        pcall(function()
            local okPing, pingVal = pcall(function()
                return math.round(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue())
            end)
            if okPing and typeof(pingVal) == "number" then
                if lastPing ~= nil and pingVal == lastPing then
                    frozenSeconds = frozenSeconds + 1
                    if frozenSeconds >= 5 then
                        game.Players.LocalPlayer:Kick(string.format("\n[AXIOM PING GUARD]\nPing bị đứng yên tại %d ms quá 5 giây!\nNgay lập tức Kick để làm mới kết nối.", pingVal))
                        return
                    end
                else
                    lastPing = pingVal
                    frozenSeconds = 0
                end
                if lblPing then
                    local pColor = (pingVal < 150) and Color3.fromRGB(0, 255, 180) or ((pingVal < 500) and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 60, 60))
                    lblPing.TextColor3 = pColor
                    lblPing.Text = string.format("📶 %d ms", pingVal)
                end
            end
        end)
        task.wait(1)
    end
end)
table.insert(App.Threads, pingWatcherThread)

-- UI Telemetry Thread
local uiThread = task.spawn(function()
    while App.Running do
        pcall(function()
            -- [AXIOM 45M SERVER TIMER & KICK]: Đếm ngược 45 phút & Kick nếu ở quá 45 phút trong 1 server
            local maxServerSec = 45 * 60
            local elapsedSec = os.time() - serverJoinTimestamp
            local remSec = math.max(0, maxServerSec - elapsedSec)
            if elapsedSec >= maxServerSec then
                (LocalPlayer or game:GetService("Players").LocalPlayer):Kick(string.format("\n[AXIOM SERVER GUARD]\nĐã ở trong server quá 45 phút (%d giây)!\nNgay lập tức Kick để làm mới phiên kết nối.", elapsedSec))
                return
            end
            if lblTimer then
                local tMin = math.floor(remSec / 60)
                local tSec = remSec % 60
                local tColor = (remSec > 600) and Color3.fromRGB(255, 200, 80) or ((remSec > 180) and Color3.fromRGB(255, 140, 50) or Color3.fromRGB(255, 60, 60))
                lblTimer.TextColor3 = tColor
                lblTimer.Text = string.format("⏱️ %02d:%02d", tMin, tSec)
            end

            App.PlayerRace = GetCurrentRace()
            App.PlayerTier = ExtractLiveV4Tier()
            local partnerStr = (myMainInfo and myMainInfo.Partner) or "None"
            local liveTierNum = tonumber(App.PlayerTier) or 0
            local isT0 = (App.PlayerTier == "0" or liveTierNum == 0)
            local isOver5 = (App.IsMain and liveTierNum > 5)
            local tierTag = isOver5 and "[Tier > 5 -> Bỏ qua Train ✅]" or (isT0 and "[Tier 0 -> Bỏ qua Train ✅]" or "")
            lblRole.Text = string.format("👑 Vai trò: %s (Partner: %s)", App.AccountRole, partnerStr)
            lblRace.Text = string.format("🧬 Tộc: %s | Tier V4: %s | %s", tostring(App.PlayerRace), tostring(App.PlayerTier), tostring(App.TrialStatus))
            if App.IsMain and myMainInfo then
                local partnerAccEntry = MAIN_PAIRS_MAP[myMainInfo.Partner]
                local pRace = partnerAccEntry and partnerAccEntry.TargetRace or "Khác"
                lblFilter.Text = string.format("🔒 Bộ lọc tín hiệu: Main %s + %s (Chặn clone cùng tộc)", myMainInfo.TargetRace, pRace)
            else
                lblFilter.Text = string.format("🛡️ Bộ lọc Clone: Chỉ join server khác tộc %s", CleanRaceStr(App.PlayerRace):upper())
            end
            -- [AXIOM UI MOON & DAY/NIGHT COUNTDOWN]: Tính toán thời gian thực tế còn lại cho đến khi trời tối/sáng
            local clockVal = Lighting.ClockTime
            local isDayTime = (clockVal >= 6 and clockVal < 18)
            local cycleSec = math.round((isDayTime and (18 - clockVal) or ((clockVal >= 18 and 30 or 6) - clockVal)) * 50)
            local cycleMin = math.floor(cycleSec / 60)
            local cycleSecRem = cycleSec % 60
            local cycleStateStr = isDayTime and "☀️ Ngày" or "🌙 Đêm"
            local nextStateStr = isDayTime and "Tối" or "Sáng"
            local cycleCountdownStr = string.format("%s (còn %dp %02ds -> %s)", cycleStateStr, cycleMin, cycleSecRem, nextStateStr)
            lblFullMoon.Text = string.format("🌕 Trăng rằm: %s | %s", App.FullMoonDetected and "YES ✅" or "NO ❌", cycleCountdownStr)
            local curFrags = GetPlayerFragments()
            local fragAlert = (curFrags < 3000) and "⚠️ THẤP (<3k)" or "✅ ĐỦ"
            lblTrial.Text = string.format("📊 Trạng thái: %s | Frag: %d (%s)", tostring(App.TrialStatus), curFrags, fragAlert)
            -- Hiển thị trực tiếp khoảng cách đến cổng theo thời gian thực
            if App.CurrentDoorDistance <= 30 then
                lblDoor.Text = string.format("🚪 Cổng tộc: ĐÃ Ở NGAY CỬA (<30 studs: %.1fm) ✅", App.CurrentDoorDistance)
                lblDoor.TextColor3 = Color3.fromRGB(0, 255, 120)
            else
                lblDoor.Text = string.format("🚪 Cổng tộc: Chưa vào vị trí (Hiện cách: %.1f studs) ❌", App.CurrentDoorDistance)
                lblDoor.TextColor3 = Color3.fromRGB(255, 120, 80)
            end
            lblChange.Text = "🔄 Chế độ Gear: Khóa cứng Full Gear (FG)"
            lblChangeStatus.Text = "📌 Trạng thái đổi: Đã tắt (Không đổi Acc sau khi xong FG)"
            lblChangeStatus.TextColor3 = Color3.fromRGB(0, 255, 180)
            lblActive.Text = "⚙️ Hub hiện tại: " .. tostring(App.ActiveHub)
            -- [UI SERVER STATUS MỚI]: Job ID & Số player trong server /12
            local currentJobId = tostring(game.JobId)
            local playerCount = #Players:GetPlayers()
            lblServer.Text = string.format("🌐 Job ID: %s | Số Player: %d/12", currentJobId, playerCount)
            -- [UI CLONE RADAR MỚI]: Danh sách Clone cùng chạy script đã join server
            local cloneList = GetServerClones()
            local cloneStr = (#cloneList > 0) and table.concat(cloneList, ", ") or "Chưa có Clone nào"
            lblClones.Text = string.format("👥 Clones chung script (%d): %s", #cloneList, cloneStr)
            -- [UI PARTNER STATUS MỚI]: Hiển thị Partner chung server đã vào chưa
            local partnerList = GetServerPartners()
            local partnerStr = (#partnerList > 0) and table.concat(partnerList, ", ") or '<font color="#FF5555">Chưa vào</font>'
            lblPartners.Text = string.format("🤝 Partner chung server (%d): %s", #partnerList, partnerStr)
            lblActivity.Text = "Chi tiết: " .. tostring(App.CurrentActivity)
        end)
        task.wait(0.3)
    end
end)
table.insert(App.Threads, uiThread)
-- // =========================================================================
-- // [SLOW CÀY THUÊ] REALTIME TELEMETRY ENGINE & 3-STATE ACTION PIPELINE
-- // =========================================================================
local SLOW_TARGET_ACCOUNTS = {
    ["ZapChaseCircuit75"] = "skypiea",
    ["Slime4XBlast81864"] = "skypiea",
    ["FlameUvStarX176320"] = "skypiea",
    ["y3t7StealthDragonHD"] = "skypiea",
    ["WijtskeQuintel2001"] = "skypiea",
    ["C3l3stialOgMirag3P15"] = "skypiea",
    ["OwenClawHawk2024"] = "skypiea",
    ["Hyperrere_6037"] = "skypiea",
    ["LiamHaz3202250"] = "skypiea",
    ["XzCookied0FlamelzX16"] = "skypiea",
    ["PhilipSuarez831"] = "skypiea",
    ["EzraPix3lat3dDark"] = "skypiea",
    ["OliverC00kieDuck"] = "skypiea",
    ["LneaFirgngeedeyn_656"] = "skypiea",
    ["Xz_DragonGWOblivione"] = "skypiea",
    ["SJkHcriypera_3563"] = "skypiea",
    ["EmeaeMSetamgxr_512"] = "skypiea",
    ["OrbitzcEchoBladeccTh"] = "skypiea",
    ["XxSparklyByt3Z3roxX"] = "skypiea",
    ["XxIsaacArrowxX15"] = "skypiea",
    ["VortexDarkChaos80"] = "skypiea",
    ["SandyFord43"] = "skypiea",
    ["T0xicDMCyberB1893"] = "skypiea",
    ["chareeObsessed9"] = "skypiea",
    ["HeruyZropSeep_4025"] = "skypiea",
    ["J3llybYEcho5YStorm15"] = "skypiea",
    ["HunterStarryMoon2008"] = "skypiea",
    ["JonathonHammond78"] = "skypiea",
    ["VoidLionViper2008"] = "skypiea",
    ["CactusSalazar70"] = "skypiea",
}
local function SlowCheckV2(): boolean
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local commF = remotes and remotes:FindFirstChild("CommF_")
    if not commF then return false end
    local ok, res = pcall(function() return commF:InvokeServer("Alchemist", "1") end)
    return ok and tonumber(res) == -2 or false
end
local function SlowCheckV3(): boolean
    local skills = { "energy core", "water body", "heavenly blood", "agility", "last resort", "heightened senses" }
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    for _, skill in ipairs(skills) do
        if char then
            for _, item in ipairs(char:GetChildren()) do
                if item.Name:lower():find(skill, 1, true) then return true end
            end
        end
        if bp then
            for _, item in ipairs(bp:GetChildren()) do
                if item.Name:lower():find(skill, 1, true) then return true end
            end
        end
    end
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    local mainGui = pGui and pGui:FindFirstChild("Main")
    local sFrame = mainGui and mainGui:FindFirstChild("Skills")
    if sFrame and (sFrame:FindFirstChild("Race") or sFrame:FindFirstChild("RaceSkill")) then
        return true
    end
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local commF = remotes and remotes:FindFirstChild("CommF_")
    if commF then
        local ok, res = pcall(function() return commF:InvokeServer("Wenlocktoad", "1") end)
        return ok and tonumber(res) == -2 or false
    end
    return false
end
local function SlowCheckLever(): boolean
    local remotes = ReplicatedStorage:FindFirstChild("Remotes")
    local commF = remotes and remotes:FindFirstChild("CommF_")
    if not commF then return false end
    local ok, res = pcall(function() return commF:InvokeServer("CheckTempleDoor") end)
    return ok and (res == true or res == 1 or tostring(res) == "true") or false
end
-- BẮT BUỘC CHỈ CÓ 3 TRẠNG THÁI DUY NHẤT TRÊN WEB THEO YÊU CẦU
local function GetSlowActionState(curRace: string, targetRace: string, isV3: boolean): string
    curRace = CleanRaceStr(curRace)
    targetRace = CleanRaceStr(targetRace)
    if targetRace ~= "" and curRace ~= targetRace then
        return "đang get race target"
    elseif not isV3 then
        return "đang up V3 targer race"
    else
        return "đang pull lever"
    end
end
local function PushSlowCayThueTelemetry()
    local myAccName = tostring(LocalPlayer.Name)
    local dataFolder = LocalPlayer:FindFirstChild("Data")
    local curRace = dataFolder and dataFolder:FindFirstChild("Race") and tostring(dataFolder.Race.Value) or GetCurrentRace()
    local targetRace = SLOW_TARGET_ACCOUNTS[myAccName] or (myMainInfo and myMainInfo.TargetRace) or ""
    local isV2 = SlowCheckV2()
    local isV3 = SlowCheckV3()
    local isLever = SlowCheckLever()
    local tierV4 = tostring(ExtractLiveV4Tier())
    local statusTrain = tostring(App.TrialStatus or "Unknown")
    local actionState = GetSlowActionState(curRace, targetRace, isV3)
    local frag = GetPlayerFragments()
    local beli = dataFolder and dataFolder:FindFirstChild("Beli") and tonumber(dataFolder.Beli.Value) or 0
    local telemetryData = {
        username      = myAccName,
        target_race   = targetRace ~= "" and targetRace or "Chưa set",
        current_race  = curRace,
        is_v2         = isV2,
        is_v3         = isV3,
        pull_lever    = isLever,
        v4_tier       = tierV4,
        status_train  = statusTrain,
        action        = actionState,
        fragments     = frag,
        beli          = beli,
        is_main       = (App.IsMain == true),
        account_role  = App.AccountRole or "Clone",
        updated_at    = os.time()
    }
    local payloadJson = HttpService:JSONEncode(telemetryData)
    -- 1. Đẩy trực tiếp qua Local Web Server API
    pcall(function()
        local req = (syn and syn.request) or (http and http.request) or http_request or request
        if req then
            req({
                Url = "http://127.0.0.1:8080/api/telemetry",
                Method = "POST",
                Headers = { ["Content-Type"] = "application/json" },
                Body = payloadJson
            })
        end
    end)
    -- 2. Ghi trực tiếp vào file hệ thống máy theo username
    pcall(function()
        if writefile then
            pcall(function() writefile("C:/Users/1/Desktop/slowcaythue/" .. myAccName .. ".txt", payloadJson) end)
            pcall(function() writefile("slowcaythue/" .. myAccName .. ".txt", payloadJson) end)
        end
    end)
end
-- Vòng lặp bắn dữ liệu viễn trắc định kỳ mỗi 5 giây
task.spawn(function()
    task.wait(4)
    while App.Running do
        pcall(PushSlowCayThueTelemetry)
        task.wait(5)
    end
end)
-- // =========================================================================
-- // CLEAN UNLOAD ENGINE
-- // =========================================================================
function App:Unload()
    self.Running = false
    self.IsHopping = false
    pcall(function()
        if isfile and readfile and writefile and HttpService and isfile(TRAIN_SESSION_FILE) then
            local ok, sessions = pcall(function() return HttpService:JSONDecode(readfile(TRAIN_SESSION_FILE)) end)
            if ok and type(sessions) == "table" then
                sessions[myName] = nil
                writefile(TRAIN_SESSION_FILE, HttpService:JSONEncode(sessions))
            end
        end
    end)
    for _, conn in ipairs(self.Connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            pcall(function() conn:Disconnect() end)
        end
    end
    table.clear(self.Connections)
    for _, th in ipairs(self.Threads) do
        if th and coroutine.status(th) ~= "dead" then
            pcall(task.cancel, th)
        end
    end
    table.clear(self.Threads)
    for _, inst in ipairs(self.Instances) do
        pcall(function() inst:Destroy() end)
    end
    table.clear(self.Instances)
    getgenv().AxiomV4KaitunSuite = nil
end
-- // [AXIOM]: Toàn bộ RealKid Engine đã được chuyển lên trên trước các luồng điều phối.
