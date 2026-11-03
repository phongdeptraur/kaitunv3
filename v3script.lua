-- // ==============================================================================
-- // AXIOM KERNEL: RAM & FARMSYNC CHANGETOFOLDER INTEROP ENGINE [SHA256 MAPPED]
-- // ==============================================================================
local _cloneref = cloneref or function(o) return o end
local _Players = _cloneref(game:GetService("Players"))
local _LocalPlayer = _Players.LocalPlayer

-- // [AXIOM INTEROP] GATE RESOURCE CHECK CHO SEA 2 UPRACE
local function CanTeleportToSea2ForUprace()
    local _data = (LocalPlayer or _LocalPlayer) and (LocalPlayer or _LocalPlayer):FindFirstChild("Data")
    local _curFrag = (_data and _data:FindFirstChild("Fragments") and _data.Fragments.Value) or 0
    local _curBeli = (_data and _data:FindFirstChild("Beli") and _data.Beli.Value) or 0
    -- Yêu cầu Uprace V2/V3: Phải đủ cả Frag >= 13k VÀ Beli >= 2.5m mới được qua Sea 2
    -- Nếu thiếu Beli (< 2.5m) HOẶC thiếu Frag (< 13k) -> return false để sang/ở lại Sea 3 cày Cake Queen/Prince
    if _curFrag < 13000 or _curBeli < 2500000 then
        return false, _curFrag, _curBeli
    end
    return true, _curFrag, _curBeli
end

-- Hash chuẩn xác của Profile THUE2, SP_GEAR và THUE
local DEFAULT_FROM_FOLDER = "0782f566d2c22369def0046e987e35403cdd29ee1054ff69b09092e4ba75dd3d"
local DEFAULT_TO_FOLDER   = "4cc982f47cb8a8d5a1eb047a9f8a6f62fcc9f0c86634e2c2f94986413a0bb9e9"

local FOLDER_CONFIG_PRESETS = {
    ["THUE2"] = {
        Name = "THUE2",
        From = "0782f566d2c22369def0046e987e35403cdd29ee1054ff69b09092e4ba75dd3d",
        To   = "4cc982f47cb8a8d5a1eb047a9f8a6f62fcc9f0c86634e2c2f94986413a0bb9e9",
        ChangeWithoutReplace = true,
        ConfigId = nil
    },
    ["SP_GEAR"] = {
        Name = "SP_GEAR",
        From = "d5952c77dedf9a5a0e4f3bdbb821bdcc3f79ed06b5a17b01a622310b457972bc",
        To   = "0d7d7058222dadd3b113bfc164b43b11f2611a938f5e2b367573f65a74d1d8ad"
    },
    ["THUE"] = {
        Name = "THUE",
        From = "c680b88b2f806a74392077952f299e211777f2831d05fec57ead7a2fac7d4600",
        To   = "70122fb9172898e10cc09bcd2c0f12fc3331f6e589f91ec7471e5d3278afeaa4"
    }
}
getgenv().FOLDER_CONFIG_PRESETS = FOLDER_CONFIG_PRESETS

-- Danh sách tài khoản cơ sở chỉ định folder (SP_GEAR & THUE)
local BASE_THUE2_ACCOUNTS = {
    -- 3 Ghoul -> SP_GEAR
    ["XxScarlettCodexX2020"] = "SP_GEAR",
    ["OliviaGlitchStormyYT"] = "SP_GEAR",
    ["xfnwjbcla"] = "SP_GEAR",
    -- 20 Ghoul -> THUE
    ["ChaosPrismNinja27"] = "THUE",
    ["CarterSlime200867"] = "THUE",
    ["ChillPrimal201611"] = "THUE",
    ["Chl0eEch0201829"] = "THUE",
    ["Circuit_OM3GA200551"] = "THUE",
    ["CircuitF0xRaven2002"] = "THUE",
    ["ChaseVoidMiner2014"] = "THUE",
    ["ClawZap201263"] = "THUE",
    ["Chloe_Hyper11"] = "THUE",
    ["Craz3_Phant0mRunn3r4"] = "THUE",
    ["ChrisDavis8rlc"] = "THUE",
    ["ChillRavenEcho53"] = "THUE",
    ["CrystalMaxCraft40"] = "THUE",
    ["CyberNinja200838"] = "THUE",
    ["DaltonEspinoza099"] = "THUE",
    ["Dani3lMysticIc32014"] = "THUE",
    ["DanielDaviseold"] = "THUE",
    ["Dalal_Sparkly1156"] = "THUE",
    ["DavidDavisdsia"] = "THUE",
    ["DavidMiller3i38"] = "THUE",
}

local function ResolveAccountFolder(accName)
    accName = tostring(accName or "")
    local folderMap = (typeof(ACCOUNT_FOLDER_MAP) == "table" and ACCOUNT_FOLDER_MAP) or (typeof(getgenv().ACCOUNT_FOLDER_MAP) == "table" and getgenv().ACCOUNT_FOLDER_MAP)
    if folderMap and folderMap[accName] then
        return folderMap[accName]
    end
    if BASE_THUE2_ACCOUNTS and BASE_THUE2_ACCOUNTS[accName] then
        return (type(BASE_THUE2_ACCOUNTS[accName]) == "string" and BASE_THUE2_ACCOUNTS[accName]) or "SP_GEAR"
    end
    -- Tất cả tài khoản mặc định nhận folder SP_GEAR
    return "SP_GEAR"
end

local _initName = tostring((_LocalPlayer and _LocalPlayer.Name) or "")
local _initFolder = ResolveAccountFolder(_initName)
local _initCfg = FOLDER_CONFIG_PRESETS[_initFolder] or FOLDER_CONFIG_PRESETS["SP_GEAR"]

getgenv().ChangeAccountSettings = {
    FromFolder = _initCfg.From,
    TargetFolder = _initCfg.To,
    TargetName = _initName,
    ChangeWithoutReplace = true,
    ConfigId = nil,
    FolderName = _initFolder
}

local function GetActiveFolderConfig()
    local lp = _LocalPlayer or (Players and Players.LocalPlayer) or (game:GetService("Players") and game:GetService("Players").LocalPlayer)
    local myAccName = tostring((lp and lp.Name) or "")

    -- ƯU TIÊN SỐ 1: Định tuyến trực tiếp theo tên tài khoản đã khóa cứng
    local folderKey = ResolveAccountFolder(myAccName)
    local presets = (typeof(FOLDER_CONFIG_PRESETS) == "table" and FOLDER_CONFIG_PRESETS) or (typeof(getgenv().FOLDER_CONFIG_PRESETS) == "table" and getgenv().FOLDER_CONFIG_PRESETS)
    local p = presets and (presets[folderKey] or presets["THUE2"] or presets["THUE"] or presets["SP_GEAR"])

    if p then
        local fromF = p.CurrentFolder or p.From
        local toF = p.TargetFolder or p.To
        if fromF and toF and fromF ~= "Kaitun" and toF ~= "Done" then
            return fromF, toF, (p.ChangeWithoutReplace ~= nil and p.ChangeWithoutReplace or true), p.ConfigId, p.Name or folderKey
        end
    end

    -- Fallback chuẩn xác theo đúng folderKey của tài khoản
    if folderKey == "THUE2" then
        return "0782f566d2c22369def0046e987e35403cdd29ee1054ff69b09092e4ba75dd3d", "4cc982f47cb8a8d5a1eb047a9f8a6f62fcc9f0c86634e2c2f94986413a0bb9e9", true, nil, "THUE2"
    elseif folderKey == "SP_GEAR" then
        return "d5952c77dedf9a5a0e4f3bdbb821bdcc3f79ed06b5a17b01a622310b457972bc", "0d7d7058222dadd3b113bfc164b43b11f2611a938f5e2b367573f65a74d1d8ad", true, nil, "SP_GEAR"
    else
        return "c680b88b2f806a74392077952f299e211777f2831d05fec57ead7a2fac7d4600", "70122fb9172898e10cc09bcd2c0f12fc3331f6e589f91ec7471e5d3278afeaa4", true, nil, "THUE"
    end
end

local function ExecuteChangeAccount(reason)
    if App and App.IsChangingAccount then return end
    if App then App.IsChangingAccount = true end

    local lp = _LocalPlayer or (Players and Players.LocalPlayer) or (game:GetService("Players") and game:GetService("Players").LocalPlayer)
    local myAccName = tostring((lp and lp.Name) or "")
    local fromFolder, targetFolder, changeWithoutReplace, configId, folderName = GetActiveFolderConfig()
    if typeof(getgenv().ChangeAccountSettings) == "table" then
        getgenv().ChangeAccountSettings.FromFolder = fromFolder
        getgenv().ChangeAccountSettings.TargetFolder = targetFolder
        getgenv().ChangeAccountSettings.TargetName = myAccName
        getgenv().ChangeAccountSettings.FolderName = folderName
    end

    local reasonTag = (reason and tostring(reason) ~= "") and (" (" .. tostring(reason) .. ")") or ""
    if App and App.SetStatus then
        App.SetStatus(string.format("Đổi acc -> %s [%s]%s", tostring(folderName), tostring(myAccName), reasonTag))
    end
    warn(string.format("[AXIOM RAM INTEROP] Initiating ChangeToFolder for '%s'%s: [%s] -> [%s] (Profile: %s)",
        myAccName, reasonTag, tostring(fromFolder), tostring(targetFolder), tostring(folderName)))

    local cl = getgenv().client or getgenv().Client
    local dispatched = false

    if cl and typeof(cl.ChangeToFolder) == "function" then
        pcall(function()
            if configId ~= nil then
                cl:ChangeToFolder(fromFolder, targetFolder, changeWithoutReplace, configId)
            else
                local ok = pcall(function() cl:ChangeToFolder(fromFolder, targetFolder, changeWithoutReplace) end)
                if not ok then
                    cl:ChangeToFolder(fromFolder, targetFolder, changeWithoutReplace, nil)
                end
            end
            dispatched = true
        end)
    elseif typeof(getgenv().ChangeToFolder) == "function" then
        pcall(function()
            if configId ~= nil then
                getgenv().ChangeToFolder(fromFolder, targetFolder, changeWithoutReplace, configId)
            else
                local ok = pcall(function() getgenv().ChangeToFolder(fromFolder, targetFolder, changeWithoutReplace) end)
                if not ok then
                    getgenv().ChangeToFolder(fromFolder, targetFolder, changeWithoutReplace, nil)
                end
            end
            dispatched = true
        end)
    end

    -- Hoàn tất gửi gói tin tới FarmSync API ngay lập tức
    task.wait(0.3)

    if App and typeof(App.Unload) == "function" then
        pcall(function() App:Unload() end)
    end

    -- Gọi game:Shutdown() chính thức để RAM/FarmSync chuyển Instance sang Acc tiếp theo
    pcall(function()
        game:Shutdown()
    end)

    task.wait(2)
    -- Fallback kick nếu tiến trình game vẫn còn tồn tại
    if lp then
        lp:Kick(string.format("[AXIOM] Account '%s' moved to [%s]. Instance terminated.", myAccName, tostring(folderName)))
    end
end
getgenv().ExecuteChangeAccount = ExecuteChangeAccount

-- // AXIOM KERNEL: FULLY AUTONOMOUS KAITUN MULTI-HUB CONTROLLER [PATCHED V3 DETECTOR]
-- // Engines: RealKid Hub (Patched V3, Lever & Race V4 Engine)
-- // [NIGHT HUB PURGED]: Toàn bộ Night Hub Hop API đã được gỡ bỏ sạch sẽ
-- // Core Fix: Multi-Tier V3 State Engine (Local File Cache + RaceEnergy UI + Temple Door + Wenlocktoad)
if getgenv().AxiomKaitunSuite then
    pcall(function() getgenv().AxiomKaitunSuite:Unload() end)

    task.wait(0.1)
end

repeat task.wait() until game:IsLoaded()

local cloneref = cloneref or function(o) return o end
local Players = cloneref(game:GetService("Players"))
local ReplicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local HttpService = cloneref(game:GetService("HttpService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local UserInputService = cloneref(game:GetService("UserInputService"))
local LocalPlayer = Players.LocalPlayer

repeat task.wait(0.05) until LocalPlayer and LocalPlayer:FindFirstChild("Data")

-- // CẤU HÌNH TỔNG & KHÓA CỨNG TỘC THEO TỪNG TÀI KHOẢN (ACCOUNT RACE LOCK TABLE)
local ACCOUNTS_POOL = {
    -- 3 Ghoul (SP_GEAR)
    "XxScarlettCodexX2020",
    "OliviaGlitchStormyYT",
    "xfnwjbcla",
    -- 20 Ghoul (THUE)
    "ChaosPrismNinja27",
    "CarterSlime200867",
    "ChillPrimal201611",
    "Chl0eEch0201829",
    "Circuit_OM3GA200551",
    "CircuitF0xRaven2002",
    "ChaseVoidMiner2014",
    "ClawZap201263",
    "Chloe_Hyper11",
    "Craz3_Phant0mRunn3r4",
    "ChrisDavis8rlc",
    "ChillRavenEcho53",
    "CrystalMaxCraft40",
    "CyberNinja200838",
    "DaltonEspinoza099",
    "Dani3lMysticIc32014",
    "DanielDaviseold",
    "Dalal_Sparkly1156",
    "DavidDavisdsia",
    "DavidMiller3i38",
}

local ACCOUNT_RACE_MAP = {
    -- 3 Ghoul (SP_GEAR)
    ["XxScarlettCodexX2020"]    = "ghoul",
    ["OliviaGlitchStormyYT"]    = "ghoul",
    ["xfnwjbcla"]               = "ghoul",
    -- 20 Ghoul (THUE)
    ["ChaosPrismNinja27"]       = "ghoul",
    ["CarterSlime200867"]       = "ghoul",
    ["ChillPrimal201611"]       = "ghoul",
    ["Chl0eEch0201829"]         = "ghoul",
    ["Circuit_OM3GA200551"]     = "ghoul",
    ["CircuitF0xRaven2002"]     = "ghoul",
    ["ChaseVoidMiner2014"]      = "ghoul",
    ["ClawZap201263"]           = "ghoul",
    ["Chloe_Hyper11"]           = "ghoul",
    ["Craz3_Phant0mRunn3r4"]    = "ghoul",
    ["ChrisDavis8rlc"]          = "ghoul",
    ["ChillRavenEcho53"]        = "ghoul",
    ["CrystalMaxCraft40"]       = "ghoul",
    ["CyberNinja200838"]        = "ghoul",
    ["DaltonEspinoza099"]       = "ghoul",
    ["Dani3lMysticIc32014"]     = "ghoul",
    ["DanielDaviseold"]         = "ghoul",
    ["Dalal_Sparkly1156"]       = "ghoul",
    ["DavidDavisdsia"]          = "ghoul",
    ["DavidMiller3i38"]         = "ghoul",
}

local ACCOUNT_FOLDER_MAP = {
    -- 3 Ghoul -> SP_GEAR
    ["XxScarlettCodexX2020"]    = "SP_GEAR",
    ["OliviaGlitchStormyYT"]    = "SP_GEAR",
    ["xfnwjbcla"]               = "SP_GEAR",
    -- 20 Ghoul -> THUE
    ["ChaosPrismNinja27"]       = "THUE",
    ["CarterSlime200867"]       = "THUE",
    ["ChillPrimal201611"]       = "THUE",
    ["Chl0eEch0201829"]         = "THUE",
    ["Circuit_OM3GA200551"]     = "THUE",
    ["CircuitF0xRaven2002"]     = "THUE",
    ["ChaseVoidMiner2014"]      = "THUE",
    ["ClawZap201263"]           = "THUE",
    ["Chloe_Hyper11"]           = "THUE",
    ["Craz3_Phant0mRunn3r4"]    = "THUE",
    ["ChrisDavis8rlc"]          = "THUE",
    ["ChillRavenEcho53"]        = "THUE",
    ["CrystalMaxCraft40"]       = "THUE",
    ["CyberNinja200838"]        = "THUE",
    ["DaltonEspinoza099"]       = "THUE",
    ["Dani3lMysticIc32014"]     = "THUE",
    ["DanielDaviseold"]         = "THUE",
    ["Dalal_Sparkly1156"]       = "THUE",
    ["DavidDavisdsia"]          = "THUE",
    ["DavidMiller3i38"]         = "THUE",
}

local FOLDER_CONFIG_PRESETS = {
    ["THUE2"] = {
        Name = "THUE2",
        From = "0782f566d2c22369def0046e987e35403cdd29ee1054ff69b09092e4ba75dd3d",
        To   = "4cc982f47cb8a8d5a1eb047a9f8a6f62fcc9f0c86634e2c2f94986413a0bb9e9",
        ChangeWithoutReplace = true,
        ConfigId = nil
    },
    ["SP_GEAR"] = {
        Name = "SP_GEAR",
        From = "d5952c77dedf9a5a0e4f3bdbb821bdcc3f79ed06b5a17b01a622310b457972bc",
        To   = "0d7d7058222dadd3b113bfc164b43b11f2611a938f5e2b367573f65a74d1d8ad"
    },
    ["THUE"] = {
        Name = "THUE",
        From = "c680b88b2f806a74392077952f299e211777f2831d05fec57ead7a2fac7d4600",
        To   = "70122fb9172898e10cc09bcd2c0f12fc3331f6e589f91ec7471e5d3278afeaa4"
    }
}

getgenv().ACCOUNT_FOLDER_MAP = ACCOUNT_FOLDER_MAP
getgenv().FOLDER_CONFIG_PRESETS = FOLDER_CONFIG_PRESETS

local activeFolderKey = (LocalPlayer and ACCOUNT_FOLDER_MAP[LocalPlayer.Name]) or "SP_GEAR"
local activeFolderCfg = FOLDER_CONFIG_PRESETS[activeFolderKey] or FOLDER_CONFIG_PRESETS["SP_GEAR"]

local lockedAccountRace = LocalPlayer and ACCOUNT_RACE_MAP[LocalPlayer.Name] or nil

getgenv().Config = {
    TargetRace = lockedAccountRace, -- ĐÃ XÓA RACE CƠ BẢN (nil nếu không nằm trong danh sách)

    AutoChangeAccount = true,
    ChangeAccountConfig = {
        FolderName = activeFolderCfg.Name or activeFolderKey,
        CurrentFolder = activeFolderCfg.CurrentFolder or activeFolderCfg.From,
        TargetFolder  = activeFolderCfg.TargetFolder or activeFolderCfg.To,
        ChangeWithoutReplace = true,
        ConfigId = nil,
    }
}

local TARGET_RACE = (typeof(getgenv().Config) == "table" and getgenv().Config.TargetRace) or lockedAccountRace
local App = {
    Running = true,
    TargetRace = TARGET_RACE,
    ActiveHub = nil,
    ActiveMainHub = nil,
    ActiveHopHub = nil,
    ActiveConfig = nil,
    HubLaunched = false,
    HasV2Confirmed = false,
    HasV3Confirmed = false,
    InitialFragChecked = false,
    InitialFragValue = 0,
    InitialV2Checked = false,
    CurrentActivity = (TARGET_RACE and TARGET_RACE ~= "") and "Khởi tạo hệ thống viễn trắc..." or "ko có race được set, vui lòng chỉnh race trong script",
    CoopRole = "none", -- "uprace" | "helprace" | "solo"

    CoopPeerWaiting = false,
    Connections = {},
    Threads = {},
    Instances = {}
}

getgenv().AxiomKaitunSuite = App

-- // RealKid Active State Watcher (Real-time Dual Hub State Sync)
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            local coreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
            local pGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
            local hasMain = false
            local hasHop = false

            if coreGui then
                for _, name in ipairs({"RealKid", "realkid", "RealKidHub", "RealKid Hub"}) do
                    if coreGui:FindFirstChild(name) then hasMain = true break end
                end
                for _, name in ipairs({"RealKidHop", "RealKid_Hop", "realkidhop"}) do
                    if coreGui:FindFirstChild(name) then hasHop = true break end
                end
            end

            if pGui then
                for _, name in ipairs({"RealKid", "realkid", "RealKidHub", "RealKid Hub"}) do
                    if pGui:FindFirstChild(name) then hasMain = true break end
                end
                for _, name in ipairs({"RealKidHop", "RealKid_Hop", "realkidhop"}) do
                    if pGui:FindFirstChild(name) then hasHop = true break end
                end
            end

            if getgenv().RealKidLoaded or getgenv().realkid or getgenv().RealKidHub then hasMain = true end
            if getgenv().realkidhop or getgenv().RealKidHop then hasHop = true end

            if hasMain then
                App.HubLaunched = true
                App.ActiveMainHub = "RealKid Main"
                if not App.ActiveHub or App.ActiveHub == "NONE" or App.ActiveHub == "" then
                    App.ActiveHub = "RealKid Main"
                end
            end
            if hasHop then
                App.HubLaunched = true
                App.ActiveHopHub = "RealKid Hop"
            end
        end)
    end
end)

-- // Telemetry Core Getters (Hoisted for Global Scope Safety)
local function CleanRaceStr(str: string): string

    return tostring(str or ""):match("^%s*(.-)%s*$"):lower()
end

local function GetCurrentRace(): string
    local data = LocalPlayer and LocalPlayer:FindFirstChild("Data")
    local r = data and data:FindFirstChild("Race")

    return r and tostring(r.Value) or "Unknown"
end

local function GetFragments(): number
    local data = LocalPlayer and LocalPlayer:FindFirstChild("Data")
    local f = data and data:FindFirstChild("Fragments")

    return f and tonumber(f.Value) or 0
end

local function GetBeli(): number
    local data = LocalPlayer and LocalPlayer:FindFirstChild("Data")
    local b = data and data:FindFirstChild("Beli")

    return b and tonumber(b.Value) or 0
end

-- Forward declarations for hoisted telemetry checkers
local CheckRaceV2, CheckCyborgV3
local PurgeMyCoopSession
local EvaluateCoopRoles
local ExecuteCoopV3Tick

local COOP_SACRIFICE_POS = Vector3.new(-389.69, 40.99, 31.59)
local COOP_SESSION_FILE  = "Axiom_Coop_Sessions.json"
local COOP_HEARTBEAT_TTL = 120

local function NormalizeCoopRaceGroup(rStr)
    local s = CleanRaceStr(rStr or "")
    if s:find("sky") or s:find("angel") then return "skypiea" end
    if s:find("ghoul") then return "ghoul" end
    return s
end

local function IsCoopSupportedRace(rStr)
    local g = NormalizeCoopRaceGroup(rStr)
    return (g == "skypiea" or g == "ghoul")
end

PurgeMyCoopSession = function()
    if App then
        App.CoopRole = "none"
        App.CoopEnable = false
        App.CoopSTT = nil
        App.CurrentHelperPeer = nil
        App.AssignedHelperName = nil
        App.CoopTargetPeer = nil
        App.HasV3Confirmed = true
    end

    pcall(function()
        local myName = tostring(LocalPlayer.Name)
        local myGroup = NormalizeCoopRaceGroup(App and App.TargetRace or TARGET_RACE or GetCurrentRace())
        local now = os.time()

        if isfile and writefile and readfile and HttpService and isfile(COOP_SESSION_FILE) then
            local ok, data = pcall(function() return HttpService:JSONDecode(readfile(COOP_SESSION_FILE)) end)
            if ok and type(data) == "table" then
                data[myName] = {
                    Name = myName,
                    Role = "none",
                    CoopEnable = false,
                    TargetRace = myGroup,
                    Race = NormalizeCoopRaceGroup(GetCurrentRace()),
                    HasV2 = true,
                    HasV3 = true,
                    Sea = (GetCurrentSea and GetCurrentSea()) or "Unknown",
                    JobId = tostring(game.JobId),
                    PlayerCount = #Players:GetPlayers(),
                    Heartbeat = now,
                    UpdatedAt = now
                }
                writefile(COOP_SESSION_FILE, HttpService:JSONEncode(data))
            end
        end

        local cFolder = workspace:FindFirstChild("AxiomCoopPresence")
        local myNode = cFolder and cFolder:FindFirstChild(myName)
        if myNode then myNode:Destroy() end
    end)
end

local function HasAnyUpRaceInSessions(): (boolean, string?, table?)
    local myGroup = NormalizeCoopRaceGroup(App and App.TargetRace or TARGET_RACE or "")
    if not IsCoopSupportedRace(myGroup) then return false, nil, nil end

    local myName = tostring(LocalPlayer.Name)
    local now = os.time()

    if isfile and readfile and HttpService and isfile(COOP_SESSION_FILE) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(COOP_SESSION_FILE)) end)
        if ok and type(data) == "table" then
            for name, info in pairs(data) do
                if name ~= myName and type(info) == "table" then
                    local lastHb = tonumber(info.Heartbeat) or tonumber(info.UpdatedAt) or 0
                    if (now - lastHb) <= COOP_HEARTBEAT_TTL then
                        local peerGroup = NormalizeCoopRaceGroup(info.TargetRace or info.Race or "")
                        if peerGroup == myGroup and info.HasV3 ~= true and info.CoopEnable == true then
                            if info.Role == "uprace" or info.HasV2 == true then
                                return true, name, info
                            end
                        end
                    end
                end
            end
        end
    end
    return false, nil, nil
end

local function HasPeerNeedingHelp(): (boolean, string?, table?)
    return HasAnyUpRaceInSessions()
end

local function IsEligibleForCoop(): boolean
    local myGroup = NormalizeCoopRaceGroup(App and App.TargetRace or TARGET_RACE or "")
    if not IsCoopSupportedRace(myGroup) then return false end

    local curGroup = NormalizeCoopRaceGroup(GetCurrentRace and GetCurrentRace() or "")
    if curGroup ~= myGroup then return false end

    local hasV2 = (App and App.HasV2Confirmed) or (CheckRaceV2 and CheckRaceV2())
    if not hasV2 then return false end

    local hasV3 = (App and App.HasV3Confirmed) or (CheckCyborgV3 and CheckCyborgV3())
    if hasV3 then
        local needHelp = HasPeerNeedingHelp()
        return (needHelp == true)
    end

    return true
end

-- // [AXIOM DUAL RACE AUTO-LATCH ENGINE]
local function SyncDualTargetRace()
    local cur = CleanRaceStr(GetCurrentRace())
    local rawTarget = CleanRaceStr(App and App.TargetRace or TARGET_RACE or "")
    local isDualMinkSky = (rawTarget == "mink/sky" or rawTarget == "sky/mink" or (rawTarget:find("mink") and (rawTarget:find("sky") or rawTarget:find("angel"))))
    local isDualMinkHuman = (rawTarget == "mink/human" or rawTarget == "human/mink" or (rawTarget:find("mink") and rawTarget:find("human")))

    if isDualMinkSky then
        if cur:find("mink") or cur:find("rabbit") then
            App.TargetRace = "mink"

            TARGET_RACE = "mink"

            if typeof(getgenv().Config) == "table" then getgenv().Config.TargetRace = "mink" end
        elseif cur:find("sky") or cur:find("angel") then
            App.TargetRace = "skypiea"

            TARGET_RACE = "skypiea"

            if typeof(getgenv().Config) == "table" then getgenv().Config.TargetRace = "skypiea" end
        end
    elseif isDualMinkHuman then
        if cur:find("mink") or cur:find("rabbit") then
            App.TargetRace = "mink"

            TARGET_RACE = "mink"

            if typeof(getgenv().Config) == "table" then getgenv().Config.TargetRace = "mink" end
        elseif cur:find("human") then
            App.TargetRace = "human"

            TARGET_RACE = "human"

            if typeof(getgenv().Config) == "table" then getgenv().Config.TargetRace = "human" end
        end
    end
end

local function IsTargetRace(): boolean

    if SyncDualTargetRace then SyncDualTargetRace() end

    local cur = CleanRaceStr(GetCurrentRace())
    local target = CleanRaceStr(App.TargetRace or TARGET_RACE)

    if target == "human/mink" or target == "mink/human" or target == "human_mink" or target == "mink_human" or (target:find("human") and target:find("mink")) then
        return cur == "human" or cur == "mink" or cur == "rabbit"
    elseif target == "mink/sky" or target == "sky/mink" or target == "mink_sky" or target == "sky_mink" or (target:find("mink") and (target:find("sky") or target:find("angel"))) then
        return cur == "mink" or cur == "rabbit" or cur == "skypiea" or cur == "angel"
    elseif target == "mink" or target == "rabbit" then
        return cur == "mink" or cur == "rabbit"
    elseif target == "fishman" or target == "shark" then
        return cur == "fishman" or cur == "shark"
    elseif target == "skypiea" or target == "sky" or target == "angel" then
        return cur == "skypiea" or cur == "angel"
    elseif target == "human" then
        return cur == "human"
    elseif target == "cyborg" then
        return cur == "cyborg"
    elseif target == "ghoul" then
        return cur == "ghoul"
    end

    return cur == target
end

local function RerollRace()

    App.CurrentActivity = string.format("🎲 [Reroll Race] Đã đủ 13k Frag! Đang roll tìm tộc %s (3000F)...", tostring(App.TargetRace or TARGET_RACE))

    pcall(function()

        local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

        commF:InvokeServer("BlackbeardReward", "Reroll", "1")

        task.wait(0.5)

        commF:InvokeServer("BlackbeardReward", "Reroll", "2")
    end)

    task.wait(1.5)
end

-- // GEOGRAPHIC REGIONS & PLACE IDS
local SEA_PLACES = {
    Sea2 = { [4442272183] = true, [79091703265657] = true },
    Sea3 = { [100117331123089] = true, [7449423635] = true }
}

local function IsSea2(): boolean

    return SEA_PLACES.Sea2[game.PlaceId] == true
end

local function IsSea3(): boolean

    return SEA_PLACES.Sea3[game.PlaceId] == true
end

local function GetCurrentSea(): string

    if IsSea2() then return "Sea 2 (Dressrosa)" end

    if IsSea3() then return "Sea 3 (Zou)" end

    if game.PlaceId == 2753915549 then return "Sea 1" end

    return "Unknown (" .. tostring(game.PlaceId) .. ")"
end

-- // ==============================================================================
-- // AXIOM KERNEL: CROSS-INSTANCE SERVER ANTI-COLLISION & HEARTBEAT ENGINE [V3 MULTI-RACE]
-- // SUPPORTED RACES: CYBORG, MINK (RABBIT), HUMAN DURING SEA 2 V2 & V3 PROGRESSION
-- // SHARED REGISTRY: Axiom_Sea2_V3_Sessions.json // ZERO SAME-SERVER DUPLICATES
-- // ==============================================================================

local _HttpService = cloneref(game:GetService("HttpService"))
local _Players = cloneref(game:GetService("Players"))
local _LocalPlayer = _Players.LocalPlayer

local V3_SESSION_FILE = "Axiom_Sea2_V3_Sessions.json"
local CYBORG_SESSION_FILE = V3_SESSION_FILE -- Alias tương thích ngược hoàn toàn
local serverJoinEpoch = os.time()
_G.serverJoinEpoch = _G.serverJoinEpoch or serverJoinEpoch

-- Helper: Chuẩn hóa tên race
local function NormalizeRaceName(race)
    return string.lower(tostring(race or "")):gsub("%s+", "")
end

-- Helper: Kiểm tra race có thuộc diện kiểm soát đụng độ Sea 2 V3 không
local function IsV3AntiCollisionEligible(race)
    local r = NormalizeRaceName(race)
    return (r == "cyborg" or r == "mink" or r == "rabbit" or r == "human")
end

-- Helper: Kiểm tra account có đang ở Sea 2 và đang trong tiến trình V2/V3 không
local function IsActiveInSea2V3()
    local isSea2 = (game.PlaceId == 4442272183)
    if not isSea2 then
        if typeof(GetSea) == "function" and GetSea() == 2 then isSea2 = true end
        if typeof(IsSea2) == "function" and IsSea2() then isSea2 = true end
    end
    if not isSea2 then return false end

    local myTarget = NormalizeRaceName(App and App.TargetRace or TARGET_RACE or "")
    if not IsV3AntiCollisionEligible(myTarget) then return false end

    -- Nếu đã hoàn thành V3 rồi thì không cần khóa anti-collision V3 nữa
    if App and (App.V3Completed == true or App.HasV3 == true or App.V3Done == true) then
        return false
    end
    if typeof(CheckCyborgV3) == "function" and myTarget == "cyborg" and CheckCyborgV3() then
        return false
    end
    if typeof(HasRaceV3) == "function" and HasRaceV3() then
        return false
    end
    if typeof(HasV3) == "function" and HasV3() then
        return false
    end

    return true
end

-- Helper: Đọc dữ liệu session từ file JSON
local function ReadV3Sessions()
    if not isfile or not isfile(V3_SESSION_FILE) then return {} end
    local success, content = pcall(readfile, V3_SESSION_FILE)
    if not success or not content or content == "" then return {} end
    local ok, data = pcall(function()
        return _HttpService:JSONDecode(content)
    end)
    if ok and typeof(data) == "table" then
        return data
    end
    return {}
end

-- Helper: Ghi dữ liệu session vào file JSON
local function WriteV3Sessions(sessions)
    if not writefile then return end
    pcall(function()
        writefile(V3_SESSION_FILE, _HttpService:JSONEncode(sessions))
    end)
end

-- Helper: Dọn dẹp session quá hạn (> 45 giây)
local function CleanStaleV3Sessions(sessions)
    local now = os.time()
    local cleaned = {}
    for name, s in pairs(sessions) do
        if typeof(s) == "table" and (now - (s.LastSeen or 0)) < 45 then
            cleaned[name] = s
        end
    end
    return cleaned
end

-- Broadcast Heartbeat: Ghi nhận trạng thái acc vào registry (kèm JoinTime xác thực thứ tự vào server)
local function BroadcastV3Heartbeat(reservedJobId)
    local sessions = CleanStaleV3Sessions(ReadV3Sessions())
    local myName = _LocalPlayer.Name

    if not IsActiveInSea2V3() then
        if sessions[myName] then
            sessions[myName] = nil
            WriteV3Sessions(sessions)
        end
        return
    end

    local myTarget = NormalizeRaceName(App and App.TargetRace or TARGET_RACE or "")
    local curJob = tostring(game.JobId or "")
    local prevSession = sessions[myName]
    local myJoin = (prevSession and prevSession.JobId == curJob and tonumber(prevSession.JoinTime)) or serverJoinEpoch or os.time()

    sessions[myName] = {
        JobId = curJob,
        Race = myTarget,
        LastSeen = os.time(),
        Heartbeat = os.time(),
        JoinTime = myJoin,
        PlaceId = game.PlaceId,
        ReservedJob = reservedJobId or (prevSession and prevSession.ReservedJob) or ""
    }
    WriteV3Sessions(sessions)
end
getgenv().BroadcastV3Heartbeat = BroadcastV3Heartbeat

-- Kiểm tra Server JobId có đang bị acc V3 khác chiếm đóng hoặc đặt chỗ trước không
local function IsJobOccupiedByAnotherV3Account(jobId)
    if not jobId or jobId == "" then return false end
    if not IsActiveInSea2V3() then return false end

    local sessions = CleanStaleV3Sessions(ReadV3Sessions())
    local myName = _LocalPlayer.Name

    for name, s in pairs(sessions) do
        if name ~= myName and typeof(s) == "table" then
            if IsV3AntiCollisionEligible(s.Race) then
                if s.JobId == jobId or s.ReservedJob == jobId then
                    return true, name, s.Race
                end
            end
        end
    end
    return false
end

-- Đặt chỗ server trước khi hop để chống xung đột cùng lúc
local function ReserveV3Job(targetJobId)
    if not targetJobId or targetJobId == "" then return end
    BroadcastV3Heartbeat(targetJobId)
end

-- Quét đụng độ tức thì nếu lỡ vào chung server: Chỉ acc vào sau mới hop
local function CheckSameServerCollision()
    if not IsActiveInSea2V3() then return false end
    if not game.JobId or game.JobId == "" then return false end

    local sessions = CleanStaleV3Sessions(ReadV3Sessions())
    local myName = _LocalPlayer.Name
    local curJob = tostring(game.JobId)
    local myJoin = (sessions[myName] and tonumber(sessions[myName].JoinTime)) or serverJoinEpoch or os.time()

    for name, s in pairs(sessions) do
        if name ~= myName and typeof(s) == "table" and IsV3AntiCollisionEligible(s.Race) then
            if tostring(s.JobId) == curJob then
                local otherJoin = tonumber(s.JoinTime) or tonumber(s.LastSeen) or tonumber(s.Heartbeat) or 0
                -- [AXIOM FIX]: Chỉ acc vào sau mới hop, acc vào trước giữ server tránh loop vô hạn
                if myJoin > otherJoin or (myJoin == otherJoin and myName > name) then
                    warn(string.format("[AXIOM ANTI-COLLISION] ⚠️ Trùng server Sea 2 V3 (%%s & %%s)! Mình vào sau (%%d > %%d) -> Hop Low Server...", myName, name, myJoin, otherJoin))
                    if App then
                        App.CurrentActivity = string.format("⚠️ [Anti-Collision] Trùng server V3 với %%s (mình vào sau) -> Đang Hop...", name)
                    end
                    if TriggerLowServerHop then
                        TriggerLowServerHop(true)
                    end
                    return true
                else
                    warn(string.format("[AXIOM ANTI-COLLISION] 🛡️ Trùng server Sea 2 V3 (%%s & %%s)! Mình vào trước (%%d <= %%d) -> Giữ server, nhường %%s hop...", myName, name, myJoin, otherJoin, name))
                end
            end
        end
    end
    return false
end

-- Aliases tương thích ngược hoàn toàn với code cũ
local IsJobOccupiedByAnotherCyborgAccount = IsJobOccupiedByAnotherV3Account
local BroadcastCyborgHeartbeat = BroadcastV3Heartbeat
local ReserveCyborgJob = ReserveV3Job

-- [AXIOM FIX]: Log session ngay lập tức khi load để các acc khác nhận diện mình ngay
pcall(function()
    BroadcastV3Heartbeat()
    CheckSameServerCollision()
end)

-- Khởi động vòng lặp nền giám sát đụng độ và duy trì heartbeat
task.spawn(function()
    while task.wait(3) do
        pcall(function()
            BroadcastV3Heartbeat()
            CheckSameServerCollision()
        end)
    end
end)
-- // ==============================================================================
local _HttpService = cloneref and cloneref(game:GetService("HttpService")) or game:GetService("HttpService")
local _TeleportService = cloneref and cloneref(game:GetService("TeleportService")) or game:GetService("TeleportService")
local CYBORG_SESSION_FILE = "Axiom_Sea2_V3_Sessions.json"
local VISITED_SERVERS_FILE = "Axiom_LowHop_Visited.json"
local VISITED_EXPIRY_SECONDS = 900
local SESSION_HEARTBEAT_TIMEOUT = 120

local function ReadJsonSafe(filename, defaultVal)
    if not (isfile and isfile(filename)) then return defaultVal or {} end
    local ok, raw = pcall(readfile, filename)
    if not ok or not raw or raw == "" then return defaultVal or {} end
    local okDecode, decoded = pcall(function() return _HttpService:JSONDecode(raw) end)
    if okDecode and type(decoded) == "table" then return decoded end
    return defaultVal or {}
end

local function WriteJsonSafe(filename, data)
    if not writefile then return false end
    local okEncode, raw = pcall(function() return _HttpService:JSONEncode(data) end)
    if not okEncode or not raw then return false end
    local okWrite = pcall(writefile, filename, raw)
    return okWrite
end

local function LoadVisitedServersPersistent()
    local visitedMap = ReadJsonSafe(VISITED_SERVERS_FILE, {})
    local now = os.time()
    local list = {}
    for jobId, timestamp in pairs(visitedMap) do
        if type(timestamp) == "number" and (now - timestamp) < VISITED_EXPIRY_SECONDS then
            table.insert(list, tostring(jobId))
        end
    end
    return list
end

local function MarkServerVisitedPersistent(jobId)
    if not jobId or jobId == "" then return end
    local visitedMap = ReadJsonSafe(VISITED_SERVERS_FILE, {})
    local now = os.time()
    local cleanedMap = {}
    for jId, ts in pairs(visitedMap) do
        if type(ts) == "number" and (now - ts) < VISITED_EXPIRY_SECONDS then
            cleanedMap[tostring(jId)] = ts
        end
    end
    cleanedMap[tostring(jobId)] = now
    WriteJsonSafe(VISITED_SERVERS_FILE, cleanedMap)
end

local function IsJobOccupiedByAnotherCyborg(jobId)
    if not jobId or jobId == "" then return false, "" end
    local targetJob = tostring(jobId)
    local myName = (_LocalPlayer and _LocalPlayer.Name) or (LocalPlayer and LocalPlayer.Name) or ""
    local now = os.time()

    -- 1. Check persistent visited blacklist
    local visitedMap = ReadJsonSafe(VISITED_SERVERS_FILE, {})
    if visitedMap[targetJob] and (now - visitedMap[targetJob]) < VISITED_EXPIRY_SECONDS then
        return true, "Visited Server"
    end

    -- 2. Check active cross-account session claims & reservations
    local sessions = ReadJsonSafe(CYBORG_SESSION_FILE, {})
    for accName, sessionInfo in pairs(sessions) do
        if tostring(accName) ~= myName and type(sessionInfo) == "table" then
            local activeJob = tostring(sessionInfo.JobId or "")
            local reservedJob = tostring(sessionInfo.ReservedJobId or "")
            local lastSeen = tonumber(sessionInfo.Heartbeat or 0)
            if (activeJob == targetJob or reservedJob == targetJob) and lastSeen and (now - lastSeen) <= SESSION_HEARTBEAT_TIMEOUT then
                return true, tostring(accName)
            end
        end
    end

    return false, ""
end

local function ReserveJobIdForTeleport(jobId)
    local lp = _LocalPlayer or LocalPlayer
    if not lp or not jobId or jobId == "" then return end
    local myName = lp.Name
    local now = os.time()
    local sessions = ReadJsonSafe(CYBORG_SESSION_FILE, {})
    sessions[myName] = sessions[myName] or {}
    sessions[myName].JobId = tostring(game.JobId)
    sessions[myName].ReservedJobId = tostring(jobId)
    sessions[myName].Heartbeat = now
    sessions[myName].Target = "cyborg"
    sessions[myName].Timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ", now)
    WriteJsonSafe(CYBORG_SESSION_FILE, sessions)
end

-- // [AXIOM CYBORG SAME-SERVER COLLISION RESOLVER]
-- // Quét liên tục: Nếu phát hiện có bất kỳ acc Cyborg nào khác trong cùng JobId -> Chỉ acc vào sau mới Hop!
task.spawn(function()
    task.wait(5)
    while true do
        pcall(function()
            if (App and (App.CoopRole == "helprace" or App.CoopRole == "uprace" or App.CoopEnable == true)) or (IsEligibleForCoop and IsEligibleForCoop()) then
                return
            end
            local myTargetRace = CleanRaceStr and CleanRaceStr(App and App.TargetRace or TARGET_RACE or "") or ""
            if myTargetRace ~= "cyborg" then return end
            local curJob = tostring(game.JobId)
            if curJob and curJob ~= "" then
                local myName = (_LocalPlayer and _LocalPlayer.Name) or (LocalPlayer and LocalPlayer.Name) or ""
                local now = os.time()
                local sessions = ReadJsonSafe(CYBORG_SESSION_FILE, {})
                local duplicates = {}
                local myJoin = (sessions[myName] and tonumber(sessions[myName].JoinTime)) or serverJoinEpoch or now

                for accName, sInfo in pairs(sessions) do
                    if type(sInfo) == "table" and tostring(accName) ~= myName then
                        local sJob = tostring(sInfo.JobId or "")
                        local sHb = tonumber(sInfo.Heartbeat or sInfo.LastSeen or 0)
                        if sJob == curJob and (now - sHb) <= SESSION_HEARTBEAT_TIMEOUT then
                            local otherJoin = tonumber(sInfo.JoinTime) or tonumber(sInfo.Heartbeat) or tonumber(sInfo.LastSeen) or 0
                            if myJoin > otherJoin or (myJoin == otherJoin and myName > tostring(accName)) then
                                table.insert(duplicates, tostring(accName))
                            end
                        end
                    end
                end

                if #duplicates > 0 then
                    warn(string.format("[AXIOM ANTI-COLLISION] ⚠️ Phát hiện trùng JobId %%s với Cyborg (%%s) và mình vào sau! Lập tức Hop Low Server...", curJob, table.concat(duplicates, ", ")))
                    MarkServerVisitedPersistent(curJob)
                    if TriggerLowServerHop then
                        TriggerLowServerHop(true)
                    end
                end
            end
        end)
        task.wait(4)
    end
end)

local function BroadcastCyborgHeartbeat()
    local lp = _LocalPlayer or LocalPlayer
    if not (lp and game.JobId and game.JobId ~= "") then return end
    local myTargetRace = CleanRaceStr and CleanRaceStr(App and App.TargetRace or TARGET_RACE or "") or ""
    if myTargetRace ~= "cyborg" then return end
    local myName = lp.Name
    local now = os.time()
    local sessions = ReadJsonSafe(CYBORG_SESSION_FILE, {})
    local curJob = tostring(game.JobId)
    local prevSession = sessions[myName]
    local myJoin = (prevSession and prevSession.JobId == curJob and tonumber(prevSession.JoinTime)) or serverJoinEpoch or now

    sessions[myName] = {
        JobId = curJob,
        PlaceId = game.PlaceId,
        Heartbeat = now,
        LastSeen = now,
        JoinTime = myJoin,
        Race = "cyborg",
        Target = "cyborg",
        Timestamp = os.date("!%%Y-%%m-%%dT%%H:%%M:%%SZ", now)
    }

    for accName, sessionInfo in pairs(sessions) do
        if type(sessionInfo) == "table" then
            local hb = tonumber(sessionInfo.Heartbeat or 0)
            if (now - hb) > SESSION_HEARTBEAT_TIMEOUT then
                sessions[accName] = nil
            end
        end
    end

    WriteJsonSafe(CYBORG_SESSION_FILE, sessions)
end

local function UnregisterCyborgSession()
    local lp = _LocalPlayer or LocalPlayer
    if not lp then return end
    local myName = lp.Name
    local sessions = ReadJsonSafe(CYBORG_SESSION_FILE, {})
    if sessions[myName] then
        sessions[myName] = nil
        WriteJsonSafe(CYBORG_SESSION_FILE, sessions)
    end
end

-- Continuous background heartbeat broadcaster
task.spawn(function()
    while true do
        pcall(BroadcastCyborgHeartbeat)
        task.wait(5)
    end
end)

-- Auto-register current instance as visited
pcall(function()
    if game.JobId and game.JobId ~= "" then
        MarkServerVisitedPersistent(game.JobId)
    end
end)

-- // AXIOM HEADLESS LOW-PLAYER SERVER HOP ENGINE (CONTROLLED ON-DEMAND ENGINE)
-- // Parallel 100-Page Scanner // Zero UI // Teleport State Machine
local TriggerLowServerHop

do
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

    local VisitedServers = LoadVisitedServersPersistent()
    local TP = { StartedAt = 0, FailedAt = 0, Failure = "" }
    local lastHopAttempt = 0
    local isHoppingActive = false

    TeleportService.TeleportInitFailed:Connect(function(player, result, message)

        if player ~= LocalPlayer then return end

        TP.FailedAt = os.clock()

        TP.Failure = tostring(result and result.Name or result) .. " | " .. tostring(message or "")

        isHoppingActive = false

        if App then App.IsHopping = false end
    end)

    LocalPlayer.OnTeleport:Connect(function(state)

        local name = ""

        pcall(function() name = state.Name end)

        if name == "Failed" then
            TP.FailedAt = os.clock()

            TP.Failure = "OnTeleport: Failed"

            isHoppingActive = false

            if App then App.IsHopping = false end
        else
            TP.StartedAt = os.clock()
        end
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

        -- [CYBORG ANTI-COLLISION CHECK]: Khi hop low, quét xem server chuẩn bị hop có bị trùng với acc Cyborg nào đang chạy ko
        local myTargetRace = CleanRaceStr and CleanRaceStr(App and App.TargetRace or TARGET_RACE or "") or ""

        if myTargetRace == "cyborg" or (IsSea2 and IsSea2() and myTargetRace:find("cyborg")) then
            local isOccupied, occupiedAcc = IsJobOccupiedByAnotherCyborg(server.JobId)

            if isOccupied then
                warn(string.format("[AXIOM HOP] ⚠️ Bỏ qua JobId %s vì trùng với acc Cyborg đang chạy (%s)!", tostring(server.JobId), tostring(occupiedAcc)))

                return false
            end
        end

        table.insert(VisitedServers, server.JobId)
        MarkServerVisitedPersistent(server.JobId)
        pcall(function() if ReserveJobIdForTeleport then ReserveJobIdForTeleport(server.JobId) end end)

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
        end

        return false
    end

    -- // Binds on-demand trigger: only hops when explicitly invoked
    TriggerLowServerHop = function(force)

        -- [AXIOM ZERO-HOP PULL LEVER LOCK]: Khi pull thi tuyet doi khong hop voi bat ki gia nao ca
        if App and (App.IsPullingLever or App.ActiveConfig == "PullLever") then
            warn("[AXIOM HOP] ⛔ Dang trong trang thai Pull Lever -> Tuyet doi khong hop server voi bat ky gia nao!")
            return
        end

        if (os.clock() - lastHopAttempt < 5) and not force then return end

        if isHoppingActive and not force then return end

        if App and App.IsHopping and not force then return end

        lastHopAttempt = os.clock()

        isHoppingActive = true

        if App then App.IsHopping = true end

        task.spawn(function()

            local pool = ScanBrowserPages()

            if pool and #pool > 0 then
                warn(string.format("[AXIOM HOP] Found %d low-player servers. Initiating connection...", #pool))

                for _, server in ipairs(pool) do
                    if AttemptServerJoin(server) then return end
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
                            if AttemptServerJoin({ JobId = tostring(sData.id), Count = sData.playing }) then return end
                        end
                    end
                end
            end

            warn("[AXIOM HOP] Teleport cycle finished without transition. Releasing lock.")

            task.wait(2)

            isHoppingActive = false

            if App then App.IsHopping = false end
        end)
    end

    getgenv().TriggerLowServerHop = TriggerLowServerHop
end

-- // DATA TELEMETRY & SYSTEM STATE
local function EnsurePirates()
    local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    local attempts = 0

    while tostring(LocalPlayer.Team) ~= "Pirates" and attempts < 15 do
        if commF then
            pcall(function()

                commF:InvokeServer("SetTeam", "Pirates")

                commF:InvokeServer("SetTeam2", "Pirates")
            end)
        end

        task.wait(0.5)

        attempts = attempts + 1
    end

    return tostring(LocalPlayer.Team) == "Pirates"
end

local function EnsureMarines()

    if SyncDualTargetRace then SyncDualTargetRace() end

    -- [CHỐT CHẶN COOP PIRATES]: Nếu là acc Coop Sea 2, bắt buộc chọn Pirates trước và tuyệt đối không qua Marines
    if IsSea2 and IsSea2() and IsEligibleForCoop and IsEligibleForCoop() then
        EnsurePirates()

        return
    end

    -- 1. Mới vào chọn Marines trước nếu đang Neutral
    if not LocalPlayer.Team or tostring(LocalPlayer.Team) == "Neutral" then
        pcall(function()

            local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

            commF:InvokeServer("SetTeam2", "Marines")
        end)

        task.wait(0.5)
    end
end

EnsureMarines()

-- // [AXIOM GATEKEEPER]: Đợi nhân vật load xong hoàn toàn, delay đúng 0.5s là chạy route ngay lập tức
local function WaitForCharacterLoaded()
    local char = LocalPlayer.Character

    while not (char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid")) do
        task.wait(0.05)

        if not LocalPlayer.Team or tostring(LocalPlayer.Team) == "Neutral" then
            EnsureMarines()
        end

        char = LocalPlayer.Character
    end

    task.wait(0.5)
end

WaitForCharacterLoaded()

-- // Throttled Temple Door Check (Non-blocking & Sea 3 Protected)
local lastLeverCheck = 0
local cachedLeverStatus = false
local function CheckLeverPulled(): boolean

    if not IsSea3() then return false end

    if cachedLeverStatus == true then return true end

    if os.clock() - lastLeverCheck < 0.5 then return cachedLeverStatus end

    lastLeverCheck = os.clock()

    local ok, res = pcall(function()
        local remotes = ReplicatedStorage:FindFirstChild("Remotes")
        local commF = remotes and remotes:FindFirstChild("CommF_")

        if not commF then return false end

        local resDoor = commF:InvokeServer("CheckTempleDoor")

        return (resDoor == true or resDoor == 1 or tostring(resDoor) == "true")
    end)

    if ok and res == true then
        cachedLeverStatus = true
    end

    return cachedLeverStatus
end

-- // AUTO RACE V3 VERIFICATION ENGINE (QUÉT ĐÚNG SKILL V3 CỦA TỘC MỤC TIÊU)
TARGET_V3_SKILLS = {
    ["cyborg"]   = "energy core",
    ["fishman"]  = "water body",
    ["shark"]    = "water body",
    ["skypiea"]  = "heavenly blood",
    ["sky"]      = "heavenly blood",
    ["angel"]    = "heavenly blood",
    ["mink"]     = "agility",
    ["rabbit"]   = "agility",
    ["human"]    = "last resort",
    ["ghoul"]    = "heightened senses",
}

local function HasTargetV3Skill(): boolean
    local curKey = CleanRaceStr(GetCurrentRace())
    local targetKey = CleanRaceStr(App.TargetRace or TARGET_RACE)
    local targetSkill = TARGET_V3_SKILLS[targetKey] or TARGET_V3_SKILLS[curKey]

    if not targetSkill then return false end

    -- 1. Quét Backpack tìm đúng skill V3 của tộc mục tiêu
    local bp = LocalPlayer:FindFirstChild("Backpack")

    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            local iLow = item.Name:lower()

            if iLow == targetSkill or iLow:find(targetSkill, 1, true) then
                return true
            end
        end
    end

    -- 2. Quét Character (đang cầm trên tay)
    local char = LocalPlayer.Character

    if char then
        for _, item in ipairs(char:GetChildren()) do
            local iLow = item.Name:lower()

            if iLow == targetSkill or iLow:find(targetSkill, 1, true) then
                return true
            end
        end
    end

    return false
end

CheckCyborgV3 = function(): boolean

    -- 1. Phải là đúng tộc mục tiêu trước tiên
    if not IsTargetRace() then
        return false
    end

    -- 2. Cờ bộ nhớ đã xác thực trong phiên hiện tại
    if App.HasV3Confirmed then
        return true
    end

    -- // [AXIOM GUARD]: Không quét skill khi nhân vật chưa load xong
    local char = LocalPlayer.Character

    if not (char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChildOfClass("Humanoid")) then
        return App.HasV3Confirmed or false
    end

    -- 3. Đọc cache file theo đúng tộc mục tiêu đã hoàn tất
    -- 4. Quét trực tiếp Backpack & Character tìm đúng skill V3 của tộc mục tiêu
    if HasTargetV3Skill() then
        App.HasV3Confirmed = true

        if PurgeMyCoopSession then PurgeMyCoopSession() end

        return true
    end

    -- 5. Quét container Skills trong PlayerGui.Main (phím T chiêu thức tộc)
    local pGui = LocalPlayer:FindFirstChild("PlayerGui")
    local mainGui = pGui and pGui:FindFirstChild("Main")
    local skills = mainGui and mainGui:FindFirstChild("Skills")

    if skills and (skills:FindFirstChild("Race") or skills:FindFirstChild("RaceSkill")) then
        App.HasV3Confirmed = true

        if PurgeMyCoopSession then PurgeMyCoopSession() end

        return true
    end

    -- 6. Truy vấn NPC Wenlocktoad khi ở Sea 2 (trả về -2 là đã xong nhiệm vụ V3, có throttle chống nghẽn mạng)
    if IsSea2() and (os.clock() - (App._lastWenlockCheck or 0) >= 3.0) then
        App._lastWenlockCheck = os.clock()

        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")

        if commF then
            local ok, res = pcall(function() return commF:InvokeServer("Wenlocktoad", "1") end)

            if ok and tonumber(res) == -2 then
                App.HasV3Confirmed = true

        if PurgeMyCoopSession then PurgeMyCoopSession() end

                return true
            end
        end
    end

    return false
end

-- Lưu Frag lần đầu khi join server
task.spawn(function()

    for _ = 1, 50 do
        local f = GetFragments()

        if f > 0 or LocalPlayer:FindFirstChild("Data") then
            App.InitialFragValue = f

            App.InitialFragChecked = true

            break
        end

        task.wait(0.1)
    end
end)

-- // ==============================================================================
-- // [OLD COOP ELECTION PATCH PURGED - HANDLED BY UNIFIED COOP V3 ENGINE]

-- // [AXIOM CYBORG PIPELINE]: LAW RAID & COLLECTIONSERVICE CHEST HARVESTER
-- // Speed: 170 studs/sec (strictly enforced, zero teleportation)
-- // Chest Pipeline: CollectionService ('_ChestTagged') + GetPivot() + IsDisabled attribute validation
-- // Telemetry: Core Brain / Microchip sniffer + persistent collection counter
local RunService = cloneref(game:GetService("RunService"))
local TweenService = cloneref(game:GetService("TweenService"))
local VirtualUser = cloneref(game:GetService("VirtualUser"))
local Workspace = cloneref(game:GetService("Workspace"))
local CollectionService = cloneref(game:GetService("CollectionService"))
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local CommF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
local EnemiesFolder = Workspace:WaitForChild("Enemies")

-- [[ RUNTIME SYSTEM STATE ]]
getgenv().Axiom_State = getgenv().Axiom_State or {
    AutoLaw = false,
    CoreBrainLocked = false,
    FarmDistance = 25,
    TweenSpeed = 170,
    ActiveTween = nil,
    LastNotification = "None",
    NotificationStatus = "Normal",
    Connections = {},
    Threads = {},
    Instances = {}
}

local State = getgenv().Axiom_State

-- [[ UNLOAD & ENGINE TEARDOWN ]]
local function TerminateAll()

    State.AutoLaw = false

    if State.ActiveTween then
        pcall(function() State.ActiveTween:Cancel() end)

        State.ActiveTween = nil
    end

    for _, conn in ipairs(State.Connections) do
        pcall(function() conn:Disconnect() end)
    end

    table.clear(State.Connections)

    for _, th in ipairs(State.Threads) do
        pcall(function() task.cancel(th) end)
    end

    table.clear(State.Threads)

    for _, inst in ipairs(State.Instances) do
        pcall(function() inst:Destroy() end)
    end

    table.clear(State.Instances)

    local char = LocalPlayer.Character

    if char and char:FindFirstChild("HumanoidRootPart") then
        local bv = char.HumanoidRootPart:FindFirstChild("AxiomFlightStabilizer")

        if bv then bv:Destroy() end
    end
end

-- [[ FLIGHT STABILIZER & COLLISION BYPASS ]]
local function GetStabilizer(hrp)
    local bv = hrp:FindFirstChild("AxiomFlightStabilizer")

    if not bv then
        bv = Instance.new("BodyVelocity")

        bv.Name = "AxiomFlightStabilizer"

        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

        bv.Velocity = Vector3.zero

        bv.Parent = hrp

        table.insert(State.Instances, bv)
    end

    return bv
end

local function BypassCollisions()
    local char = LocalPlayer.Character

    if not char then return end

    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end

local noclipConn = RunService.Stepped:Connect(function()

    if State.AutoLaw then
        BypassCollisions()
    end
end)

table.insert(State.Connections, noclipConn)

-- [[ DYNAMIC 170 STUD/S VECTOR TWEEN ]]
local function DynamicTween(targetCFrame)
    local char = LocalPlayer.Character

    if not char then return end

    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hrp then return end

    local stabilizer = GetStabilizer(hrp)

    stabilizer.Velocity = Vector3.zero

    local currentPos = hrp.Position
    local targetPos = targetCFrame.Position
    local distance = (targetPos - currentPos).Magnitude

    if distance < 1.5 then
        if State.ActiveTween then
            State.ActiveTween:Cancel()

            State.ActiveTween = nil
        end

        return
    end

    local duration = distance / 170 -- Khóa cứng 170 stud/s tuyệt đối

    if State.ActiveTween then
        State.ActiveTween:Cancel()

        State.ActiveTween = nil
    end

    local tweenInfo = TweenInfo.new(
        duration,
        Enum.EasingStyle.Linear,
        Enum.EasingDirection.Out
    )

    State.ActiveTween = TweenService:Create(hrp, tweenInfo, {CFrame = targetCFrame})

    State.ActiveTween:Play()
end

-- [[ REMOTES & INTERACTION PRIMITIVES ]]
local function BuyMicrochip()

    State.SupplyCoreBrainReady = false

    pcall(function()

        CommF:InvokeServer("BlackbeardReward", "Microchip", "1")
    end)

    task.wait(0.2)

    return CommF:InvokeServer("BlackbeardReward", "Microchip", "2")
end

local function FireRaidPedestal()
    local button = Workspace:FindFirstChild("Map")

        and Workspace.Map:FindFirstChild("CircleIsland")

        and Workspace.Map.CircleIsland:FindFirstChild("RaidSummon")

        and Workspace.Map.CircleIsland.RaidSummon:FindFirstChild("Button")

        and Workspace.Map.CircleIsland.RaidSummon.Button:FindFirstChild("Main")

    if button and button:FindFirstChild("ClickDetector") then
        fireclickdetector(button.ClickDetector)

        return true
    end

    return false
end

local function HasMicrochip()

    if typeof(HasToolItem) == "function" then
        local has = HasToolItem("microchip")

        if has then return true end
    end

    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    if char and (char:FindFirstChild("Microchip") or char:FindFirstChild("Order Microchip")) then
        return true
    end

    if backpack and (backpack:FindFirstChild("Microchip") or backpack:FindFirstChild("Order Microchip")) then
        return true
    end

    return false
end

-- [[ COMBAT CORE ]]
local G = {}

function G.GetconnectedEnemy(targetName)

    local candidates = {}

    for _, enemy in ipairs(EnemiesFolder:GetChildren()) do
        if enemy.Name == targetName or string.find(enemy.Name, targetName) then
            local hum = enemy:FindFirstChildOfClass("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")

            if hum and hrp and hum.Health > 0 then
                table.insert(candidates, enemy)
            end
        end
    end

    if #candidates == 0 then
        local spawns = Workspace:FindFirstChild("_WorldOrigin") and Workspace._WorldOrigin:FindFirstChild("EnemySpawns")

        if spawns then
            for _, spawner in ipairs(spawns:GetChildren()) do
                if string.find(spawner.Name, targetName) then
                    local enemy = EnemiesFolder:FindFirstChild(spawner.Name)

                    if enemy then
                        local hum = enemy:FindFirstChildOfClass("Humanoid")
                        local hrp = enemy:FindFirstChild("HumanoidRootPart")

                        if hum and hrp and hum.Health > 0 then
                            table.insert(candidates, enemy)
                        end
                    end
                end
            end
        end
    end

    local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local myPos = myHrp and myHrp.Position or Vector3.zero

    table.sort(candidates, function(a, b)

        return (a.HumanoidRootPart.Position - myPos).Magnitude < (b.HumanoidRootPart.Position - myPos).Magnitude
    end)

    return candidates[1]
end

function G.EquipWeapon()

    local char = LocalPlayer.Character
    local backpack = LocalPlayer:FindFirstChild("Backpack")

    if not char or not backpack then return end

    local currentTool = char:FindFirstChildOfClass("Tool")

    if not currentTool then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword") then
                char.Humanoid:EquipTool(item)

                break
            end
        end
    end
end

function G.kill(target)

    if not target or not target:FindFirstChild("HumanoidRootPart") then return end

    local hum = target:FindFirstChildOfClass("Humanoid")
    local hrp = target.HumanoidRootPart

    if not hum or hum.Health <= 0 then return end

    G.EquipWeapon()

    local targetCFrame = hrp.CFrame * CFrame.new(0, State.FarmDistance, 0) * CFrame.Angles(math.rad(-90), 0, 0)

    DynamicTween(targetCFrame)

    pcall(function()

        VirtualUser:CaptureController()

        VirtualUser:Button1Down(Vector2.new(1000, 1000))
    end)

    pcall(function()

        ReplicatedStorage.Remotes.Validator:FireServer(math.floor(Workspace:GetServerTimeNow()))

        local net = ReplicatedStorage:FindFirstChild("Net")

        if net and net:FindFirstChild("RE/RegisterAttack") then
            net["RE/RegisterAttack"]:FireServer(0)
        end
    end)
end

-- [[ DISPATCH CYCLE ]]
local lastPedestalFire = 0
local lastBuyChipAttempt = 0

raidThread = task.spawn(function()

    while true do
        task.wait(0.05)

        if State.AutoLaw then
            pcall(function()

                local law = G.GetconnectedEnemy("Order")

                if law then
                    -- Law đang sống: Tập trung tiêu diệt Law
                    G.kill(law)
                else
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    local pedestalCFrame = CFrame.new(-6473, 250, -4493)

                    if HasMicrochip() then
                        -- ĐÃ CÓ CHIP: Cầm Microchip trên tay, bay tới Pedestal và kích hoạt raid
                        State.SupplyCoreBrainReady = false

                        if EquipToolByName then EquipToolByName("microchip") end

                        if hrp then
                            local dist = (hrp.Position - pedestalCFrame.Position).Magnitude

                            if dist > 8 then
                                DynamicTween(pedestalCFrame)
                            else
                                if EquipToolByName then EquipToolByName("microchip") end

                                FireRaidPedestal()

                                task.wait(0.5)
                            end
                        end
                    else
                        -- CHƯA CÓ CHIP:
                        -- Chỉ mua chip khi đã nhận được tín hiệu 'Core Brain' từ Pedestal
                        if State.SupplyCoreBrainReady and (os.clock() - lastBuyChipAttempt >= 3) then
                            lastBuyChipAttempt = os.clock()

                            State.SupplyCoreBrainReady = false

                            App.CurrentActivity = "🎟️ [Law] Thấy 'Supply Core Brain' -> Mua 1 Microchip..."

                            BuyMicrochip()

                            task.wait(1.0)
                        else
                            -- Chưa có cờ ready: Về Pedestal click mỗi 5s cho đến khi hiện thông báo
                            if hrp then
                                local dist = (hrp.Position - pedestalCFrame.Position).Magnitude

                                if dist > 8 then
                                    DynamicTween(pedestalCFrame)
                                else
                                    if os.clock() - lastPedestalFire >= 5 then
                                        lastPedestalFire = os.clock()

                                        App.CurrentActivity = "🔘 [Law] Đang click Pedestal chờ 'Supply Core Brain' (mỗi 5s)..."

                                        FireRaidPedestal()

                                        task.wait(0.3)

                                        pcall(function()

                                            local pGui = LocalPlayer:FindFirstChild("PlayerGui")

                                            if pGui then
                                                for _, desc in ipairs(pGui:GetDescendants()) do
                                                    if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Text and desc.Text ~= "" then
                                                        ParseNotificationString(desc.Text)
                                                    end
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
    end
end)

table.insert(State.Threads, raidThread)

-- [[ HEADLESS BACKGROUND ENGINE ]]
-- Secondary GUI excised. All Law Raid, Chest Farming, and Core Brain telemetry execute headlessly in background.
local function ParseNotificationString(text)
    if not text or type(text) ~= "string" then return end
    local lower = string.lower(text)
    State.LastNotification = text

    if string.find(lower, "core brain") then
        State.CoreBrainLocked = true
        State.NotificationStatus = "CORE_BRAIN_REQUIRED"
        State.SupplyCoreBrainReady = true

        -- [CHỐT CHẶN BỆ LAW -> HOP]: Bệ báo 'Supply Core Brain' trong khi RealKid đang chạy -> LẬP TỨC HOP LOW!
        if App.HubLaunched and (App.ActiveHub == "RealKid Hub" or App.ActiveConfig == "CyborgFist" or getgenv().RealKidLoaded or getgenv().realkid) then
            App.CurrentActivity = "🚨 [Bệ Law: Supply Core Brain] Bệ báo Core Brain khi RealKid đang chạy -> Lập tức Hop Low Server..."
            warn("[AXIOM CYBORG] Pedestal reported Supply Core Brain while RealKid is active! Triggering instant Low Server Hop...")
            if TriggerLowServerHop then
                TriggerLowServerHop(true)
            end
        end
    elseif string.find(lower, "microchip") or string.find(lower, "fist of darkness") then
        if not State.CoreBrainLocked then
            State.NotificationStatus = "MICROCHIP_MISSING"
        end
    end
end

table.insert(App.Threads, autoBuyCyborgThread)

-- [PEDESTAL AUTO-CLICK PURGED: Handled exclusively by RealKid]

-- [CYBORG JUMP THREAD PURGED]

-- // =============================================================================
-- // [AXIOM HOISTED REALKID CONFIG ENGINE & STRICT SEQUENTIAL LAUNCHER]
-- // RealKid Main first -> Verify loaded -> Strict 20s countdown -> RealKid Hop
-- // Auto Cyborg: True | Destination: Server 4 Hours | SearchEnabled: True
-- // =============================================================================
local function saveRealKidHopConfig(destination)
    destination = destination or "Cake Prince"
    local lp = LocalPlayer or (Players and Players.LocalPlayer) or (game:GetService("Players") and game:GetService("Players").LocalPlayer)
    local userId = tostring(lp and lp.UserId or "")
    local isServer4Hours = (destination == "Server 4 Hours" or destination == "Server 4 hour" or destination == "server 4 hour")

    local existingVisited = { ["09ca0d4c-8139-4079-a7d6-673f4830c30b"] = true }
    local candidateReadPaths = {
        "RealKidHop_" .. userId .. ".json",
        "workspace/RealKidHop_" .. userId .. ".json",
        "realkidhop/config.json",
        "RealKidHop.json"
    }
    for _, p in ipairs(candidateReadPaths) do
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

    local configData = {
        ["RaceV4Enabled"] = false,
        ["WeaponCategory"] = "Melee",
        ["SearchEnabled"] = true,
        ["SearchEnable"] = true,
        ["searchenable"] = true,
        ["AutoHop"] = true,
        ["GhostFruitEnabled"] = false,
        ["PortalEnabled"] = true,
        ["AttackEnabled"] = true,
        ["DebugEnabled"] = false,
        ["FruitEnabled"] = false,
        ["RandomEnabled"] = false,
        ["Destination"] = destination,
        ["RaidEnabled"] = false,
        ["GunHeight"] = 35,
        ["FruitWebhookEnabled"] = false,
        ["WebhookEnabled"] = false,
        ["RaceV3Enabled"] = false,
        ["BerryEnabled"] = false,
        ["AuraEnabled"] = true,
        ["SearchPause"] = isServer4Hours and 10 or 5,
        ["BossEnabled"] = not isServer4Hours,
        ["StoreEnabled"] = true,
        ["KenEnabled"] = false,
        ["WebhookAddress"] = "",
        ["AttackHeight"] = 30,
        ["MovementSpeed"] = 200,
        ["InitialSide"] = "Marines",
        ["VisitedJobs"] = existingVisited,
        ["AutoLoadEnabled"] = false,
        ["Language"] = "Tiếng Việt"
    }

    local encoded = HttpService:JSONEncode(configData)
    pcall(function()
        if writefile then
            if userId ~= "" then
                writefile("RealKidHop_" .. userId .. ".json", encoded)
                pcall(writefile, "workspace/RealKidHop_" .. userId .. ".json", encoded)
            end
            writefile("RealKidHop.json", encoded)
            pcall(writefile, "workspace/RealKidHop.json", encoded)

            local hopFolder = "realkidhop"
            if makefolder and not isfolder(hopFolder) then
                pcall(makefolder, hopFolder)
            end
            pcall(writefile, hopFolder .. "/config.json", encoded)

            local hopFolder2 = "RealKidHop"
            if makefolder and not isfolder(hopFolder2) then
                pcall(makefolder, hopFolder2)
            end
            pcall(writefile, hopFolder2 .. "/config.json", encoded)
        end
    end)

    getgenv().realkidhop = configData
    getgenv().realkidhop["Enable"] = true
    getgenv().realkidhop["SearchEnabled"] = true
    getgenv().realkidhop["Destination"] = destination
    return configData
end
getgenv().saveRealKidHopConfig = saveRealKidHopConfig

local _AxiomDualLauncherActive = false
local function LaunchCyborgRealKid()
    if _AxiomDualLauncherActive then return end
    if App.HubLaunched and (App.ActiveMainHub == "RealKid Main" or App.ActiveHub == "RealKid Main" or App.ActiveHub == "RealKid Hub") then
        return
    end

    _AxiomDualLauncherActive = true
    App.HubLaunched = true
    App.ActiveMainHub = "RealKid Main"
    App.ActiveHub = "RealKid Main"
    App.ActiveConfig = "CyborgFist"

    -- Cấu hình RealKid Main: auto_cyborg = true
    pcall(function()
        if typeof(SyncRealKidConfig) == "function" then
            SyncRealKidConfig({
                ["auto_cyborg"] = true,
                ["AutoLaw"] = false,
                ["AutoUpgradeRaceV3"] = false,
    ["auto_ghoul_v1"] = false,
                ["AutoPullLever"] = false
            })
        end
    end)

    -- KHỞI CHẠY ĐỘC QUYỀN REALKID MAIN (TUYỆT ĐỐI KHÔNG CHẠY REALKID HOP KHI GET CYBORG)
    task.spawn(function()
        App.CurrentActivity = "🤖 [RealKid Main] Đang khởi chạy RealKid Main..."
        warn("[AXIOM HUB] >>> Launching RealKid Main exclusively for Cyborg (No RealKid Hop)...")

        -- Luau Luraph Debug Bridge
        local safeDebug = debug or getgenv().debug or (getrenv and getrenv().debug) or {}
        if type(safeDebug) ~= "table" then safeDebug = {} end
        if not safeDebug.getinfo then safeDebug.getinfo = function() return {} end end
        if not safeDebug.traceback then safeDebug.traceback = function(...) return tostring(...) end end
        getgenv().debug = safeDebug
        pcall(function()
            if getfenv then
                getfenv(0).debug = safeDebug
                getfenv(1).debug = safeDebug
            end
        end)

        local okMain, errMain = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua"))()
        end)
        if not okMain then
            warn("[AXIOM HUB] RealKid Main Load Error: " .. tostring(errMain))
        else
            warn("[AXIOM HUB] RealKid Main loaded successfully.")
            App.CurrentActivity = "🤖 [RealKid Main] Đang farm Cyborg (Chỉ chạy Main)..."
        end
    end)
end
getgenv().LaunchCyborgRealKid = LaunchCyborgRealKid
local _AxiomGhoulLauncherActive = false
local function LaunchGhoulRealKid()
    if _AxiomGhoulLauncherActive then return end
    if App.HubLaunched and (App.ActiveMainHub == "RealKid Main" or App.ActiveHub == "RealKid Main" or App.ActiveHub == "RealKid Hub") then
        return
    end
    _AxiomGhoulLauncherActive = true
    App.HubLaunched = true
    App.ActiveMainHub = "RealKid Main"
    App.ActiveHub = "RealKid Main"
    App.ActiveConfig = "GhoulV1"
    -- Cấu hình RealKid Main: auto_ghoul_v1 = true
    pcall(function()
        if typeof(SyncRealKidConfig) == "function" then
            SyncRealKidConfig({
                ["auto_ghoul_v1"] = true,
                ["AutoLaw"] = false,
                ["AutoUpgradeRaceV3"] = false,
                ["AutoPullLever"] = false
            })
        end
    end)
    -- KHỞI CHẠY ĐỘC QUYỀN REALKID MAIN (AUTO GHOUL V1)
    task.spawn(function()
        App.CurrentActivity = "👻 [RealKid Main] Đang khởi chạy RealKid Main để lấy Ghoul V1..."
        warn("[AXIOM HUB] >>> Launching RealKid Main exclusively for Ghoul V1 (auto_ghoul_v1 = true)...")
        local safeDebug = debug or getgenv().debug or (getrenv and getrenv().debug) or {}
        if type(safeDebug) ~= "table" then safeDebug = {} end
        if not safeDebug.getinfo then safeDebug.getinfo = function() return {} end end
        if not safeDebug.traceback then safeDebug.traceback = function(...) return tostring(...) end end
        getgenv().debug = safeDebug
        pcall(function()
            if getfenv then
                getfenv(0).debug = safeDebug
                getfenv(1).debug = safeDebug
            end
        end)
        local okMain, errMain = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua"))()
        end)
        if not okMain then
            warn("[AXIOM HUB] RealKid Main Load Error: " .. tostring(errMain))
        else
            warn("[AXIOM HUB] RealKid Main loaded successfully.")
            App.CurrentActivity = "👻 [RealKid Main] Đang chạy auto_ghoul_v1 để lấy tộc Ghoul..."
        end
    end)
end
getgenv().LaunchGhoulRealKid = LaunchGhoulRealKid

-- 4. Điều phối viên tự động Cyborg: RealKid Auto Cyborg + Click bệ Law sniffer
-- [CYBORG PEDESTAL CONTROLLER PURGED: Handled exclusively by RealKid]

-- // CHECK RACE V2 & 5S AUTO BUY BOAT CHO TỘC CÁ (FISHMAN V2)
CheckRaceV2 = function(): boolean

    -- 1. Đã xác nhận V2 trong session hiện tại -> Tuyệt đối không invoke remote nữa
    if App.HasV2Confirmed then
        return true
    end

    -- 2. Đã có V3 thì hiển nhiên đã V2
    if App.HasV3Confirmed or (CheckCyborgV3 and CheckCyborgV3()) then
        App.HasV2Confirmed = true

        return true
    end

    -- 3. Kiểm tra chuẩn xác qua NPC Alchemist (CommF_ 'Alchemist', '1')
    -- CHỈ KHI status == -2 MỚI LÀ DONE V2! Bất kỳ số nào khác đều là CHƯA V2
    if IsSea2 and IsSea2() then
        local now = tick()

        if not App._lastV2Check or (now - App._lastV2Check >= 3) then
            App._lastV2Check = now

            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")

            if commF then
                local ok, res = pcall(function() return commF:InvokeServer("Alchemist", "1") end)

                if ok and res ~= nil then
                    local status = tonumber(res)

                    if status == -2 then
                        App.HasV2Confirmed = true

                        return true
                    else
                        App.HasV2Confirmed = false

                        return false
                    end
                else
                    -- Không nhận được phản hồi (lag mạng / server chưa nạp): Không throttle 3s để retry ngay
                    App._lastV2Check = 0
                end
            end
        end
    end

    return (App.HasV2Confirmed == true)
end

-- // [AXIOM RACE V2/V3 PRE-LOAD ENGINE]: CHỐT CHẶN TẢI TRẠNG THÁI V2 TRƯỚC KHI CHẠY HUB
-- // Ngăn chặn tuyệt đối việc kích hoạt Hub trước khi nạp xong dữ liệu V2 từ máy chủ
local function EnsureRaceV2Loaded()

    App.CurrentActivity = "Sẵn sàng điều phối tác vụ"

    -- Phase 1: Thẩm vấn V3 trước (Nếu đã V3 thì chắc chắn 100% đã có V2)
    for _ = 1, 15 do
        if CheckCyborgV3 and CheckCyborgV3() then
            App.HasV3Confirmed = true

            App.HasV2Confirmed = true

            App.InitialV2Checked = true

            return true
        end

        task.wait(0.2)
    end

    -- Phase 2: Tại Sea 2, thẩm vấn liên tục NPC Alchemist cho đến khi có phản hồi chính xác
    if IsSea2 and IsSea2() then
        local commF = ReplicatedStorage:WaitForChild("Remotes", 10) and ReplicatedStorage.Remotes:WaitForChild("CommF_", 10)

        if commF then
            for attempt = 1, 20 do
                local ok, res = pcall(function()

                    return commF:InvokeServer("Alchemist", "1")
                end)

                if ok and res ~= nil then
                    local status = tonumber(res)

                    if status == -2 then
                        App.HasV2Confirmed = true
                    else
                        App.HasV2Confirmed = false
                    end

                    App.InitialV2Checked = true

                    return (App.HasV2Confirmed == true)
                end

                task.wait(0.3)
            end
        end
    end

    -- Phase 3: Fallback an toàn mở khóa hệ thống
    App.InitialV2Checked = true
    App.CurrentActivity = "✅ [Hệ thống] Đã nạp xong trạng thái Race! Bắt đầu điều phối..."

    return (App.HasV2Confirmed == true)
end

task.spawn(function()

    EnsureRaceV2Loaded()
end)

autoBuyBoatFishThread = task.spawn(function()

    while App.Running do
        local targetKey = CleanRaceStr(App.TargetRace or TARGET_RACE)
        local curKey = CleanRaceStr(GetCurrentRace())
        local isFishTarget = (targetKey == "fishman" or targetKey == "shark")
        local isFishCur = (curKey == "fishman" or curKey == "shark")

        if isFishTarget and isFishCur and CheckRaceV2() then
            pcall(function()

                local args = {
                    "BuyBoat",
                    "MarineBrigade"
                }

                game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("CommF_"):InvokeServer(unpack(args))
            end)
        end

        task.wait(30)
    end
end)

table.insert(App.Threads, autoBuyBoatFishThread)

-- // [REPLACED BY AXIOM LAW & CHEST AUTO-CLICK PEDESTAL ENGINE]
-- // TRANSIT CONTROLLERS (SEA 2 / SEA 3)
local StoreHeldFruit
local function TravelToSea2(reason: string?)
    local reasonText = (reason and reason ~= "") and (" [Lý do: " .. tostring(reason) .. "]") or ""

    App.CurrentActivity = "🌊 Đang di chuyển sang Sea 2 (Dressrosa)..." .. reasonText

    local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    pcall(function() commF:InvokeServer("TravelDressrosa") end)

    task.wait(3)

    if not IsSea2() then
        TeleportService:Teleport(4442272183, LocalPlayer)
    end
end

local function TravelToSea3(reason: string?)

    if CleanRaceStr(App.TargetRace or TARGET_RACE) == "cyborg" and StoreHeldFruit then StoreHeldFruit() end

    local reasonText = (reason and reason ~= "") and (" [Lý do: " .. tostring(reason) .. "]") or ""

    App.CurrentActivity = "🌊 Đang di chuyển sang Sea 3 (Zou)..." .. reasonText

    local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
    local ok, res = pcall(function()

        return commF:InvokeServer("TravelZou")
    end)

    -- Kiểm tra nếu server trả về phản hồi bị vướng trạng thái combat PVP
    local resStr = tostring(res or "")

    if string.find(resStr:upper(), "PVP") then
        App.CurrentActivity = "⚔️ Bị vướng combat PVP khi qua Sea 3! Kích hoạt Hop Low Server..."

        TriggerLowServerHop()

        return
    end

    task.wait(3)

    if not IsSea3() then
        TeleportService:Teleport(7449423635, LocalPlayer)
    end
end

-- // FRUIT LOGISTICS & V3 AUTO-SUBMITTER [PATCHED INVENTORY VALIDATOR]
-- // Specs: Real Treasure Storage Query ("getInventoryFruits") + Trash-Fruit Priority + Zero-Spam Guard
local function IsFruitTool(item: Instance): boolean
    if not item or not item:IsA("Tool") then return false end
    if item.ToolTip == "Melee" or item.ToolTip == "Sword" or item.ToolTip == "Gun" then return false end

    local nonFruits = {
        ["fist of darkness"] = true, ["core brain"] = true, ["microchip"] = true,
        ["god's chalice"] = true, ["sweet chalice"] = true, ["flower 1"] = true,
        ["flower 2"] = true, ["flower 3"] = true, ["library key"] = true,
        ["water key"] = true, ["key"] = true, ["torch"] = true, ["hellfire torch"] = true
    }

    local lowerName = item.Name:lower()
    if nonFruits[lowerName] then return false end

    if item.ToolTip == "Blox Fruit" or string.find(lowerName, "fruit") or item:GetAttribute("Fruit") or item:FindFirstChild("Fruit") then
        return true
    end

    return false
end

local function GetHeldFruit(): Tool?
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")

    if char then
        for _, item in ipairs(char:GetChildren()) do
            if IsFruitTool(item) then return item end
        end
    end

    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if IsFruitTool(item) then return item end
        end
    end

    return nil
end

local function EquipHeldFruit(): Tool?
    local fruit = GetHeldFruit()

    if fruit and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and fruit.Parent ~= LocalPlayer.Character then
            hum:EquipTool(fruit)
            task.wait(0.5)
        end
    end

    return GetHeldFruit()
end

-- Danh sách độ ưu tiên trái cùi/rẻ tiền để nộp Wenlocktoad (tránh ăn/nộp nhầm trái xịn)
local TRASH_FRUIT_PREFERENCE = {
    "rocket", "spin", "blade", "spring", "bomb", "smoke", "spike", "flame", "falcon", "ice", "sand", "dark", "diamond", "light", "rubber", "barrier", "ghost", "magma"
}

-- Quét chính xác kho Fruit Storage ("getInventoryFruits") - Tuyệt đối không query shop đại lý
local function GetStoredFruitsList(): table
    local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
    if not commF then return {} end

    local validFruits = {}

    -- Tầng 1: Kho Treasure Storage chính thức của Blox Fruits
    local ok1, fruitData = pcall(function()
        return commF:InvokeServer("getInventoryFruits")
    end)

    if ok1 and type(fruitData) == "table" then
        for k, v in pairs(fruitData) do
            if type(v) == "table" then
                local fId = v.fruit or v.Fruit or v.id or v.Name or v.Value
                local count = v.Count or v.count or v.Quantity or v.quantity or v.Amount or v.amount or 1
                if fId and type(fId) == "string" and fId ~= "" and fId ~= "Table" and (tonumber(count) or 1) > 0 then
                    table.insert(validFruits, tostring(fId))
                end
            elseif type(v) == "string" and v ~= "" and v ~= "Table" then
                table.insert(validFruits, v)
            elseif type(k) == "string" and k ~= "" and tonumber(k) == nil and type(v) == "number" and v > 0 then
                table.insert(validFruits, k)
            end
        end
    end

    -- Tầng 2: Fallback qua container "getInventory" nếu tầng 1 trống
    if #validFruits == 0 then
        local ok2, invData = pcall(function()
            return commF:InvokeServer("getInventory")
        end)
        if ok2 and type(invData) == "table" then
            for _, v in pairs(invData) do
                if type(v) == "table" then
                    local itemType = tostring(v.Type or v.type or ""):lower()
                    local itemName = tostring(v.Name or v.name or v.fruit or ""):lower()
                    if itemType:find("fruit") or itemName:find("fruit") or itemName:find("-") then
                        local fId = v.fruit or v.Fruit or v.id or v.Name
                        local count = v.Count or v.count or v.Quantity or v.quantity or 1
                        if fId and type(fId) == "string" and fId ~= "" and (tonumber(count) or 1) > 0 then
                            table.insert(validFruits, tostring(fId))
                        end
                    end
                end
            end
        end
    end

    return validFruits
end

local function GetAvailableInventoryFruit(): string?
    local stored = GetStoredFruitsList()
    if not stored or #stored == 0 then
        return nil
    end

    -- Ưu tiên chọn trái cùi nhất có trong kho trước
    for _, pref in ipairs(TRASH_FRUIT_PREFERENCE) do
        for _, fName in ipairs(stored) do
            if string.find(string.lower(fName), pref, 1, true) then
                return fName
            end
        end
    end

    return stored[1]
end

local _lastLoadFruitTime = 0
local function LoadAnyFruit(): boolean
    -- Chống spam remote liên tục
    if os.clock() - _lastLoadFruitTime < 2.0 then
        return false
    end
    _lastLoadFruitTime = os.clock()

    local fruitName = GetAvailableInventoryFruit()
    if not fruitName then
        return false
    end

    local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    -- Thử load với định dạng tên gốc
    pcall(function()
        commF:InvokeServer("LoadFruit", fruitName)
    end)

    task.wait(0.5)

    -- Nếu chưa ra tay, thử load với định dạng chuẩn gạch nối (Ví dụ: "Rocket-Rocket")
    if not GetHeldFruit() then
        local clean = string.gsub(fruitName, "%s*[Ff]ruit.*", "")
        clean = string.gsub(clean, "^%s*(.-)%s*$", "%1")
        local altId = clean .. "-" .. clean
        pcall(function()
            commF:InvokeServer("LoadFruit", altId)
        end)
    end

    task.wait(0.8)
    return GetHeldFruit() ~= nil
end

local function TryStoreTool(item: Tool)
    if not item or not item.Parent or not IsFruitTool(item) then return end

    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if hum and item.Parent ~= char then
        pcall(function() hum:EquipTool(item) end)
        task.wait(0.25)
    end

    local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")
    local name = item.Name
    local clean = string.gsub(name, "%s*[Ff]ruit.*", "")
    clean = string.gsub(clean, "^%s*(.-)%s*$", "%1")
    local fId = clean .. "-" .. clean

    pcall(function() commF:InvokeServer("StoreFruit", fId, item) end)
    pcall(function() commF:InvokeServer("StoreFruit", name, item) end)
    task.wait(0.2)
end

StoreHeldFruit = function()
    local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    for _ = 1, 3 do
        if LocalPlayer.Character then
            for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
                if IsFruitTool(item) then TryStoreTool(item) end
            end
        end

        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp then
            for _, item in ipairs(bp:GetChildren()) do
                if IsFruitTool(item) then TryStoreTool(item) end
            end
        end

        task.wait(0.3)
        if not GetHeldFruit() then break end
    end
end

local function ExecuteRaceV3TurnIn(): boolean
    local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

    if GetBeli() < 2000000 then return false end

    local okStatus, resStatus = pcall(function() return commF:InvokeServer("Wenlocktoad", "1") end)
    local raceStatus = (okStatus and tonumber(resStatus)) or -99

    if raceStatus == -2 then
        App.HasV3Confirmed = true
        if PurgeMyCoopSession then PurgeMyCoopSession() end
        return true
    end

    if raceStatus == 0 then
        if not App._wenlockQuestAccepted then
            App.CurrentActivity = "📜 [V3] Nhận nhiệm vụ từ Wenlocktoad..."
            pcall(function() commF:InvokeServer("Wenlocktoad", "2") end)
            App._wenlockQuestAccepted = true
        end
        return false
    end

    if raceStatus == 1 then
        local isCyborgTarget = CleanRaceStr(App.TargetRace or TARGET_RACE) == "cyborg"

        if isCyborgTarget then
            local held = GetHeldFruit()

            if not held then
                local availableStored = GetAvailableInventoryFruit()
                if availableStored then
                    App.CurrentActivity = string.format("🍎 [V3 Cyborg] Tìm thấy trái '%s' trong kho! Đang lấy ra...", tostring(availableStored))
                    LoadAnyFruit()
                    task.wait(1)
                    held = GetHeldFruit()
                else
                    App.CurrentActivity = "⚠️ [V3 Cyborg] Không có Fruit trong túi đồ & kho lưu trữ! Cần có 1 trái ác quỷ để nộp..."
                    task.wait(2)
                    return false
                end
            end

            if held then
                App.CurrentActivity = string.format("🍎 [V3 Cyborg] Cầm trái '%s' nộp cho Wenlocktoad...", tostring(held.Name))
                EquipHeldFruit()
                task.wait(0.5)

                pcall(function() commF:InvokeServer("Wenlocktoad", "3") end)
                task.wait(1)

                StoreHeldFruit()

                local done = CheckCyborgV3()
                if done then
                    App.HasV3Confirmed = true
                    if PurgeMyCoopSession then PurgeMyCoopSession() end
                end

                return done
            end
        else
            -- Các tộc khác không nộp Fruit cho Wenlocktoad
            pcall(function() commF:InvokeServer("Wenlocktoad", "3") end)
            task.wait(1)

            local done = CheckCyborgV3()
            if done then
                App.HasV3Confirmed = true
                if PurgeMyCoopSession then PurgeMyCoopSession() end
            end

            return done
        end
    end

    return false
end

-- // 24/7 CONTINUOUS HEADLESS FAST ATTACK ENGINE (KILL AURA - CHẠY NGẦM KHÔNG UI)
local FastAttackRuntime = {
    Active = true, -- Chạy ngầm 24/7 liên tục không cần UI

    AttackRadius = 55,
    AutoBuso = true,
    ObfuscatedRemote = nil :: RemoteEvent?,
    RemoteId = nil :: number?,
}

-- Remote Signature Scraper
local function ResolveDynamicRemote()
    local searchContainers = {
        ReplicatedStorage:FindFirstChild("Util"),
        ReplicatedStorage:FindFirstChild("Common"),
        ReplicatedStorage:FindFirstChild("Remotes"),
        ReplicatedStorage:FindFirstChild("Assets"),
        ReplicatedStorage:FindFirstChild("FX"),
    }

    for _, container in ipairs(searchContainers) do
        if container then
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                    FastAttackRuntime.ObfuscatedRemote = child

                    FastAttackRuntime.RemoteId = child:GetAttribute("Id")

                    return
                end
            end

            local conn = container.ChildAdded:Connect(function(child)

                if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                    FastAttackRuntime.ObfuscatedRemote = child

                    FastAttackRuntime.RemoteId = child:GetAttribute("Id")
                end
            end)

            table.insert(App.Connections, conn)
        end
    end
end

ResolveDynamicRemote()

local function EnsureCombatCharacter()

    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

local function EquipCombatTool()
    local char = EnsureCombatCharacter()

    if not char then return nil end

    local equipped = char:FindFirstChildOfClass("Tool")

    if equipped and (equipped.ToolTip == "Melee" or equipped.ToolTip == "Sword") then
        return equipped
    end

    -- Không cướp slot cầm Fruit nếu đang trong tiến trình nộp trái cho Wenlocktoad
    if equipped and IsFruitTool and IsFruitTool(equipped) then
        return nil
    end

    local bp = LocalPlayer:FindFirstChild("Backpack")

    if bp then
        for _, item in ipairs(bp:GetChildren()) do
            if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword") then
                local hum = char:FindFirstChildOfClass("Humanoid")

                if hum then
                    hum:EquipTool(item)

                    return item
                end
            end
        end
    end

    return nil
end

local function EnsureFastAttackBuso()
    local char = EnsureCombatCharacter()

    if FastAttackRuntime.AutoBuso and char and not char:FindFirstChild("HasBuso") then
        pcall(function()

            local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

            commF:InvokeServer("Buso")
        end)
    end
end

local function ShouldPauseFastAttack()
    -- [AXIOM HOTFIX]: Nhường quyền FastAttack cho ExecuteFastAttack247 khi đang chạy GetMM (Valkyrie & Mirror)
    if getgenv()._AxiomBossFarm and getgenv()._AxiomBossFarm.IsRunning and getgenv()._AxiomBossFarm.Enabled then
        return true
    end

    if not IsEligibleForCoop() then return false end

    if App.CoopRole == "helprace" then return true end

    if IsSea2() and CheckRaceV2() and not CheckCyborgV3() then
        return true
    end

    return false
end

-- Fast Attack Pipeline
local function ExecuteFastAttack()

    if ShouldPauseFastAttack() then return end

    local char = EnsureCombatCharacter()

    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")

    if not root then return end

    local enemiesFolder = workspace:FindFirstChild("Enemies")

    if not enemiesFolder then return end

    local hitParts = {}
    local primaryTargetHead: Instance? = nil

    for _, mob in ipairs(enemiesFolder:GetChildren()) do
        local mobRoot = mob:FindFirstChild("HumanoidRootPart")
        local mobHum = mob:FindFirstChildOfClass("Humanoid")

        if mob ~= char and mobRoot and mobHum and mobHum.Health > 0 then
            local distance = (root.Position - mobRoot.Position).Magnitude

            if distance <= FastAttackRuntime.AttackRadius then
                for _, part in ipairs(mob:GetChildren()) do
                    if part:IsA("BasePart") then
                        table.insert(hitParts, { mob, part })
                    end
                end

                if not primaryTargetHead and mob:FindFirstChild("Head") then
                    primaryTargetHead = mob.Head
                end
            end
        end
    end

    if #hitParts == 0 then return end

    local activeTool = EquipCombatTool()

    if not activeTool then return end

    EnsureFastAttackBuso()

    local netModules = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")

    if not netModules then return end

    local regAttack = netModules:FindFirstChild("RE/RegisterAttack")
    local regHit = netModules:FindFirstChild("RE/RegisterHit")

    if regAttack and regAttack:IsA("RemoteEvent") then
        regAttack:FireServer()
    end

    local callHash = tostring(LocalPlayer.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)

    if regHit and regHit:IsA("RemoteEvent") and primaryTargetHead then
        regHit:FireServer(primaryTargetHead, hitParts, {}, callHash)
    end

    -- Obfuscated hash remote validation
    if FastAttackRuntime.ObfuscatedRemote and FastAttackRuntime.RemoteId and primaryTargetHead then
        local obfuscatedKey = string.gsub("RE/RegisterHit", ".", function(c)

            return string.char(bit32.bxor(string.byte(c), math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1))
        end)

        local seedVal = 0

        pcall(function()

            seedVal = netModules.seed:InvokeServer() * 2
        end)

        local payloadHash = bit32.bxor(FastAttackRuntime.RemoteId + 909090, seedVal)

        pcall(function()

            FastAttackRuntime.ObfuscatedRemote:FireServer(obfuscatedKey, payloadHash, primaryTargetHead, hitParts)
        end)
    end
end

-- Background 24/7 Continuous Attack Cycle (Tự phục hồi & chống tắt ngầm)
fastAttackCycleThread = task.spawn(function()

    while App.Running do
        if not ShouldPauseFastAttack() then
            FastAttackRuntime.Active = true

            pcall(ExecuteFastAttack)
        else
            FastAttackRuntime.Active = false
        end

        task.wait(0.08)
    end
end)

table.insert(App.Threads, fastAttackCycleThread)

-- // CURSED SHIP (GHOST SHIP) NAVIGATION & REAL-TIME GHOUL ENGINE
-- // Cổng Cursed Ship: CFrame.new(-6496.90, 89.04, -116.51) (Workspace.Map.GhostShip.Teleport)
-- // Khoang trong Cursed Ship: Vector3.new(1009.89, 125.09, 32912.96) (Bán kính <= 3000 studs)
CURSED_SHIP_INTERIOR_POS = Vector3.new(1009.89, 125.09, 32912.96)

CURSED_SHIP_DOOR_CF = CFrame.new(-6496.90, 89.04, -116.51)

local function TweenToCursedShipDoor()
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local root = char:WaitForChild("HumanoidRootPart", 5)

    if not root then return end

    local doorPart = workspace:FindFirstChild("Map")

        and workspace.Map:FindFirstChild("GhostShip")

        and workspace.Map.GhostShip:FindFirstChild("Teleport")

    local targetCF = doorPart and doorPart.CFrame or CURSED_SHIP_DOOR_CF
    local dist = (root.Position - targetCF.Position).Magnitude

    if dist > 3 then
        root.Anchored = false

        local duration = math.max(dist / 170, 0.1)
        local ts = cloneref(game:GetService("TweenService"))
        local tw = ts:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCF })

        tw:Play()

        tw.Completed:Wait()
    end

    -- Unanchor ngay sau khi tween đến điểm cổng Cursed Ship
    root.Anchored = false

    -- Kích hoạt TouchPart để game thực hiện chuyển scene vào trong Cursed Ship
    if doorPart and firetouchinterest then
        pcall(function()

            firetouchinterest(root, doorPart, 0)

            task.wait(0.05)

            firetouchinterest(root, doorPart, 1)
        end)
    end

    task.wait(0.8)
end

-- // ĐIỂM RA GHOST SHIP INTERIOR: TWEEN THOÁT KHỎI TÀU MA TRƯỚC KHI ĐI COOP / RA NGOÀI
GHOST_SHIP_INTERIOR_EXIT_CF = CFrame.new(920.48, 154.90, 32838.96)

-- // GIÁM SÁT THỜI GIAN THỰC: CÓ GHOUL TRONG KHI HUB ĐANG CHẠY -> HOP LOW SERVER NGAY LẬP TỨC
ghoulHopWatcherThread = task.spawn(function()

    while App.Running do
        pcall(function()

            if App.HubLaunched and (App.ActiveHub == "NightHub_Ghoul" or App.ActiveHub == "RealKid_Ghoul" or App.ActiveConfig == "GhoulV1") then
                local cur = CleanRaceStr(GetCurrentRace())

                if cur:find("ghoul") then
                    App.CurrentActivity = "🎉 [Ghoul Monitor] Đã có tộc Ghoul trong khi Hub đang chạy! Hop Low Server..."

                    TriggerLowServerHop(true)
                end
            end
        end)

        task.wait(0.5)
    end
end)

table.insert(App.Threads, ghoulHopWatcherThread)

-- // [OLD COOP HEALTH WATCHDOG PURGED - INTEGRATED INTO UNIFIED COOP V3 ENGINE]

-- // AXIOM NATIVE ENGINES: CHACHA20 HOP API // PORTAL ROUTER // AUTO V2-V3 // LEVER
-- // -------------------------------------------------------------------------
-- // 1. PORTAL FAST-TRAVEL & 170 STUDS/S NAVIGATION ENGINE
-- // -------------------------------------------------------------------------
PORTAL_NETWORK = {
    [1] = {
        { Name = "Skypiea Cloud Gate", Gate = Vector3.new(-6024.18, 5471.35, 2218.09), RemoteExit = Vector3.new(-4166.61, 1093.70, -347.16), ExitArrival = Vector3.new(-4166.61, 1093.70, -347.16) },
        { Name = "Underwater Whirlpool", Gate = Vector3.new(4041.83, -3.07, -1810.55), RemoteExit = Vector3.new(61167.36, -2.93, 1950.91), ExitArrival = Vector3.new(61167.36, 18.50, 1950.91) }
    },
    [2] = {
        { Name = "Graveyard -> Cursed Ship", Gate = Vector3.new(-6501.28, 83.46, -124.42), RemoteExit = Vector3.new(922.89, 125.36, 32843.34), ExitArrival = Vector3.new(922.89, 125.36, 32843.34) },
        { Name = "Cursed Ship -> Graveyard", Gate = Vector3.new(922.89, 125.36, 32843.34), RemoteExit = Vector3.new(-6501.28, 83.46, -124.42), ExitArrival = Vector3.new(-6501.28, 83.46, -124.42) }
    },
    [3] = {
        { Name = "Castle -> Mansion Portal", Gate = Vector3.new(-5059.82, 326.79, -3192.29), RemoteExit = Vector3.new(-12463.60, 386.62, -7566.08), ExitArrival = Vector3.new(-12463.60, 386.62, -7566.08) },
        { Name = "Mansion -> Castle Portal", Gate = Vector3.new(-12463.60, 386.62, -7566.08), RemoteExit = Vector3.new(-5059.82, 326.79, -3192.29), ExitArrival = Vector3.new(-5059.82, 326.79, -3192.29) },
        { Name = "Castle -> Tiki Outpost", Gate = Vector3.new(-5095.44, 316.79, -3175.76), RemoteExit = Vector3.new(-16800.35, 60.26, 290.22), ExitArrival = Vector3.new(-16800.35, 60.26, 290.22) },
        { Name = "Tiki -> Castle Portal", Gate = Vector3.new(-16800.35, 60.26, 290.22), RemoteExit = Vector3.new(-5095.44, 316.79, -3175.76), ExitArrival = Vector3.new(-5095.44, 316.79, -3175.76) },
        { Name = "Hydra Waterfall -> Castle", Gate = Vector3.new(5650.95, 1025.57, -350.38), RemoteExit = Vector3.new(-5027.03, 326.79, -3206.70), ExitArrival = Vector3.new(-5027.03, 326.79, -3206.70) }
    }
}

local function CalculateOptimalPortalRoute(targetPos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not root then return nil end

    local currentPos = root.Position
    local directDist = (targetPos - currentPos).Magnitude
    local curSeaNum = IsSea3() and 3 or (IsSea2() and 2 or 1)
    local portals = PORTAL_NETWORK[curSeaNum] or {}
    local bestPortal = nil
    local bestTotalDist = directDist

    for _, portal in ipairs(portals) do
        local distToGate = (portal.Gate - currentPos).Magnitude
        local distFromExit = (targetPos - portal.ExitArrival).Magnitude
        local totalWithPortal = distToGate + distFromExit

        if totalWithPortal < (bestTotalDist - 600) then
            bestTotalDist = totalWithPortal

            bestPortal = portal
        end
    end

    return bestPortal
end

local function DirectLinearFlight(targetCFrame)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")

    if not root then return end

    local stabilizer = GetStabilizer(root)

    stabilizer.Velocity = Vector3.zero

    local dist = (targetCFrame.Position - root.Position).Magnitude

    if dist < 1.5 then return end

    local duration = math.clamp(dist / 170, 0.05, 500)
    local tw = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = targetCFrame })

    tw:Play()

    tw.Completed:Wait()

    stabilizer.Velocity = Vector3.zero
end

local function SmartNavigate(targetCFrame)
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

    if not root then return end

    local targetPos = targetCFrame.Position
    local bestPortal = CalculateOptimalPortalRoute(targetPos)

    if bestPortal then
        -- Bay vào cổng
        DirectLinearFlight(CFrame.new(bestPortal.Gate + Vector3.new(0, 3, 0)))

        -- Gọi remote kích hoạt cổng
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")

        if commF then
            pcall(function()

                commF:InvokeServer("requestEntrance", bestPortal.RemoteExit)
            end)
        end

        local waitLimit = 0

        repeat
            task.wait(0.1)

            waitLimit = waitLimit + 1
        until (root.Position - bestPortal.Gate).Magnitude > 200 or waitLimit > 25
    end

    -- Bay tiếp đoạn cuối tới đích
    DirectLinearFlight(targetCFrame)
end

-- // -------------------------------------------------------------------------
-- // 2. [NIGHT HUB HOP API PURGED - NATIVE REALKID & LOW HOP DELEGATION]
-- // -------------------------------------------------------------------------
-- // -------------------------------------------------------------------------
-- // 3. AUTO FARM FRAGMENT: CAKE QUEEN / PRINCE VIA REALKID HOP ENGINE
-- // [STRICT SINGLE-HUB GATE]: 1 SERVER CHỈ CHẠY 1 HUB, ĐỔI HUB BUỘC PHẢI HOP
-- // -------------------------------------------------------------------------
-- // 3. AUTO FARM FRAGMENT: CAKE QUEEN / PRINCE VIA REALKID HOP ENGINE
-- // [STRICT SINGLE-HUB GATE]: 1 SERVER CHỈ CHẠY 1 HUB, ĐỔI HUB BUỘC PHẢI HOP
-- // -------------------------------------------------------------------------
local function saveRealKidHopConfig(destination)
    destination = destination or "Cake Prince"
    local userId = tostring(LocalPlayer.UserId)
    local fileName = "RealKidHop_" .. userId .. ".json"
    local possiblePaths = { fileName, "workspace/" .. fileName }

    local existingVisited = { ["09ca0d4c-8139-4079-a7d6-673f4830c30b"] = true }
    for _, p in ipairs(possiblePaths) do
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
            writefile(fileName, encoded)
            pcall(writefile, "workspace/" .. fileName, encoded)

            local hopFolder = "realkidhop"
            if makefolder and not isfolder(hopFolder) then
                pcall(makefolder, hopFolder)
            end
            pcall(writefile, hopFolder .. "/config.json", encoded)
        end
    end)
    return configData
end

local function LaunchRealKidHopCakeQueen()
    local desiredHub = "RealKid Hop"
    local desiredConfig = "CakePrince"

    saveRealKidHopConfig("Cake Prince")

    -- 1. Nếu chưa có Hub nào chạy trên server này: Khởi chạy độc quyền
    if not App.HubLaunched then
        App.HubLaunched = true
        App.ActiveHub = desiredHub
        App.ActiveConfig = desiredConfig
        App.CurrentActivity = "Đang chạy RealKid Hop (Cake Queen/Prince)..."
        task.spawn(function()
            -- Luau Luraph Debug Bridge
            local safeDebug = debug or getgenv().debug or (getrenv and getrenv().debug) or {}
            if type(safeDebug) ~= "table" then safeDebug = {} end
            if not safeDebug.getinfo then safeDebug.getinfo = function() return {} end end
            if not safeDebug.traceback then safeDebug.traceback = function(...) return tostring(...) end end
            getgenv().debug = safeDebug
            pcall(function()
                if getfenv then
                    getfenv(0).debug = safeDebug
                    getfenv(1).debug = safeDebug
                end
            end)

            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/RealKidHop.lua"))()
            end)
            if not ok then
                warn("[AXIOM HUB] RealKid Hop LoadString Error: " .. tostring(err))
            end
        end)
        return true
    end

    -- 2. Nếu đã chạy đúng RealKid Hop -> Giữ nguyên, không load đè
    if (App.ActiveHub == desiredHub or App.ActiveHub == "RealKid Hop") and App.ActiveConfig == desiredConfig then
        App.HubLaunched = true
        App.ActiveHub = desiredHub
        return true
    end

    -- 3. Khác Hub hoặc khác Config Profile -> TUYỆT ĐỐI KHÔNG CHẠY ĐÈ, BẮT BUỘC HOP SERVER!
    App.CurrentActivity = string.format("🔄 [Đổi Hub/Config] Đang chạy %s (%s) -> Cần %s (%s)! Hop Server...",
        tostring(App.ActiveHub), tostring(App.ActiveConfig), desiredHub, desiredConfig)
    warn(string.format("[AXIOM HUB] ⚠️ Tuyệt đối không chạy đè! Đang chạy [%s : %s], yêu cầu [%s : %s] -> Hop Server...",
        tostring(App.ActiveHub), tostring(App.ActiveConfig), desiredHub, desiredConfig))
    if TriggerLowServerHop then
        TriggerLowServerHop(true)
    end
    task.wait(5)
    return false
end

local function ProcessFragmentFarmCakeQueen()
    if not IsSea3() then
        TravelToSea3("Cần farm Frag tại Sea 3 (Cake Queen / Cake Prince)")
        return
    end

    App.CurrentActivity = "👑 [Cake Prince/Queen] Khởi động RealKid Hop farm Frag..."
    LaunchRealKidHopCakeQueen()
end

-- // =============================================================================

local REALKID_BASE_CONFIG = {
    ["EspSeaEventIsland"] = false,
    ["UpgradeDragonTalon"] = false,
    ["ChangeTransparencyCanSee"] = false,
    ["LeviathanMultiCannon"] = false,
    ["RemoveHitVFX"] = false,
    ["ValueDamageMultiSegments"] = 30000,
    ["AutoStartRaid"] = false,
    ["AutoTrainV4"] = false,
    ["SpectatePlayer"] = false,
    ["AutoMelee"] = false,
    ["AttackMultiSegmentsLeviathan"] = false,
    ["farm_m1_gun_sea"] = false,
    ["DungeonAccountStart"] = false,
    ["global_skill_hold_c"] = 10,
    ["AutoV3Target_Toggle"] = false,
    ["selected_fighting_style"] = "Black Leg",
    ["ResetAfterTrial"] = false,
    ["AutoFindKitsuneIsland"] = false,
    ["AutoCollectGear"] = false,
    ["RemoveDeathRespawnVFX"] = false,
    ["AutoTpAncientClock"] = false,
    ["selected_team"] = "Marines",
    ["AutoSwords"] = false,
    ["auto_multi_raid"] = false,
    ["AutoEliteQuest"] = false,
    ["autoshootgun"] = true,
    ["AutoDracoFully"] = false,
    ["BaitSelection"] = "Basic Bait",
    ["auto_pirate_raid"] = false,
    ["auto_farm_sea_event"] = false,
    ["AutoAwakening"] = false,
    ["AutoSlapDodgeAABB"] = false,
    ["EspChests"] = false,
    ["ChooseSeaLevel"] = "Lv 1",
    ["AzureEmberToTrade"] = 1,
    ["AutoTpAncientOne"] = false,
    ["Berry"] = false,
    ["AutoHopChest"] = false,
    ["AutoLookAtMoon"] = false,
    ["card_selection"] = {},
    ["account_pick_slot_raid"] = false,
    ["Bringmob"] = true,
    ["AcceptRainbowQuest"] = false,
    ["AutoCollectDragonEggs"] = false,
    ["AutoYamaCDK"] = false,
    ["JumpPowerSliderV2"] = 50,
    ["AutoCraftEnchantScroll"] = false,
    ["auto_zou_quest"] = false,
    ["AutoFarmObservationHop"] = false,
    ["auto_dragon_hunter"] = false,
    ["SwapDragoRace"] = false,
    ["global_skill_hold_z"] = 10,
    ["AutoPhoenixDungeon"] = false,
    ["Select_Boss_Farm"] = "",
    ["attack_method_golem"] = "Attack",
    ["AutoPickDungeonCards"] = false,
    ["EspAuraColourDealers"] = false,
    ["SelectedV4Gear2"] = "Alpha",
    ["RaceV4Aura"] = false,
    ["global_skill_hold_x"] = 10,
    ["ignore_cake_prince"] = false,
    ["AutoRemoveSkyFog"] = false,
    ["AutoResetWhenCompleteVolcano"] = false,
    ["AntiAFK"] = true,
    ["AutoValkyrie"] = false,
    ["AutoRelicDragoTrial"] = false,
    ["SafeMode"] = false,
    ["autotwfruits"] = false,
    ["EspAdvancedFruitsDealer"] = false,
    ["DisableNotify"] = false,
    ["AutoTrainDragoV4"] = false,
    ["RandomAround"] = false,
    ["EspGears"] = false,
    ["AutoTushitaSword"] = false,
    ["global_skill_keys"] = {"Z", "X", "C"},
    ["AutoDriveToHydraIsland"] = false,
    ["auto_buy_style"] = false,
    ["auto_farm_materials"] = false,
    ["JumpPower"] = false,
    ["auto_patch_prehistoric"] = false,
    ["selected_sea_events"] = {},
    ["discord_notice_mirage"] = false,
    ["AutoBuyV4Gear"] = false,
    ["AutoStackDarkbeard"] = false,
    ["DungeonAutoJoin"] = false,
    ["auto_mastery_fruits"] = false,
    ["AutoEscapeRoughSea"] = false,
    ["farm_height_2"] = 30,
    ["auto_farm_nearest_range"] = 500,
    ["auto_low_cpu_once"] = false,
    ["SelectBoatTarget"] = "My Boat",
    ["EspIslandLocation"] = false,
    ["EspBerries"] = false,
    ["TeleportToPlayer"] = false,
    ["auto_farm_general"] = false,
    ["raidnew"] = false,
    ["MagicFruits"] = false,
    ["toggle_portal_tp"] = true,
    ["WalkSpeed"] = false,
    ["AutoDefense"] = false,
    ["auto_destroy_lava"] = true,
    ["AutoSerpentBow"] = false,
    ["TweenToDragoTrials"] = false,
    ["FarmMastery_G"] = false,
    ["AutoFindLeviathan"] = false,
    ["BusuAura"] = true,
    ["EnchantScrollType"] = "CommonScroll",
    ["accept_quests"] = false,
    ["Chest"] = false,
    ["auto_citizen_quest"] = false,
    ["AutoTravel"] = false,
    ["AutoCanvendishSword"] = false,
    ["auto_travel_dressrosa"] = false,
    ["AutoTweenHighestPoint"] = false,
    ["TweenSpeedV4"] = 190,
    ["AutoTradeAzureEmber"] = false,
    ["AutoChooseV4Gear"] = false,
    ["AutoFindPrehistoricIsland"] = false,
    ["auto_load_script"] = false,
    ["AutoPrayGravestone"] = false,
    ["ResetVolcanoAfterCollectingLoot"] = false,
    ["discord_notice_prehistoric"] = false,
    ["auto_farm_nearest"] = false,
    ["AutoDragoV2"] = false,
    ["multi_raid_players"] = {},
    ["StopWhenChalice"] = true,
    ["global_skill_hold_v"] = 10,
    ["BringMode"] = "400",
    ["auto_farm_tyrant"] = false,
    ["AutoSellFish"] = false,
    ["AutoCollectDinoBones"] = false,
    ["auto_factory_raid"] = false,
    ["global_skill_hold_f"] = 10,
    ["AutoBuyChipFruit"] = false,
    ["AutoBloxFruit"] = false,
    ["AutoGetCDK"] = false,
    ["EspPlayers"] = false,
    ["weapon_choice"] = "Melee",
    ["AutoSkullGuitar"] = false,
    ["discord_notice_frozen"] = false,
    ["auto_training_dummy"] = false,
    ["EspFruits"] = false,
    ["auto_farm_leviathan"] = false,
    ["AutoSelectDungeon"] = false,
    ["auto_sea_event_friend"] = false,
    ["AutoSpawnPrehistoricIsland"] = true,
    ["ChooseBoats"] = "MarineGrandBrigade",
    ["AutoRainbowColors"] = false,
    ["AutoCraftVolcanicMagnet"] = false,
    ["AutoSoulReaper"] = false,
    ["AutoUnlockedPuzzle"] = false,
    ["AutoDragoV3"] = false,
    ["farm_m1_fruit_sea"] = false,
    ["AutoBuyFruitsFlag"] = false,
    ["KenAura2"] = false,
    ["AutoTeleportToShrineActived"] = false,
    ["Initialize"] = true,
    ["RaceV3Aura"] = false,
    ["tyrant_skull_guitar"] = false,
    ["AutoStoreFruitFlag"] = false,
    ["MaxChestHop"] = 45,
    ["AutoLeiAccessory"] = false,
    ["BoatSpeedV7"] = "220",
    ["DungeonMinPlayers"] = 2,
    ["AutoBigmom"] = false,
    ["AutoCompleteTrialRace"] = false,
    ["AutoSailBoat"] = false,
    ["SelectedV4GearSlot"] = "Auto",
    ["AutoTweenAdvancedFruitDealer"] = false,
    ["DungeonDifficulty"] = "Normal",
    ["global_skill_weapons"] = {"Melee", "Sword", "Blox Fruit", "Gun"},
    ["AutoRandomBones"] = false,
    ["AutoPullLever"] = false,
    ["selected_farm_target"] = "Auto Level",
    ["AutoTeleportFrozenDimension"] = false,
    ["AutoUnlockDoughDungeon"] = false,
    ["AutoFarmMaterialSkullGuitar"] = false,
    ["AutoFindMirageIsland"] = false,
    ["AutoYamaSword"] = false,
    ["AutoHiddenQuest"] = false,
    ["AutoDragoV1"] = false,
    ["WalkSpeedSliderV2"] = 100,
    ["AutoTeleportBarista"] = false,
    ["AutoTryLuck"] = false,
    ["global_skill_delay"] = 100,
    ["GoToSharkmanNPC"] = false,
    ["AutoGun"] = false,
    ["AutoObservationV2"] = false,
    ["AutoTushitaCDK"] = false,
    ["HopBerry"] = false,
    ["AutoMirror"] = false,
    ["AutoCollectMirageChest"] = false,
    ["AutoBossToggle"] = false,
    ["AutoDriveToTikiOutport"] = false,
    ["AutoFarmObservation"] = false,
    ["AutoDojoTrainer"] = false,
    ["mastery_health_percent"] = 30,
    ["AutoSpawnRipIndra"] = false,
    ["AutoOpenMenuHopFarm"] = false,
    ["hopantirs"] = false,
    ["AutoTwinHooks"] = false,
    ["auto_break_bottle"] = false,
    ["RodSelection"] = "Fishing Rod",
    ["AutoFireShootHeartLeviathan"] = false,
    ["AutoTweenEventFishingSpot"] = false,
    ["AutoKillPlayerAfterTrial"] = false,
    ["AutoCollectAzureEmber"] = false,
    ["MasterySword"] = false,
    ["BringMobMax"] = "6",
    ["AutoResetLostBoat"] = false,
    ["AutoPrehistoricFully"] = false,
    ["AutoQuestBoss"] = false,
    ["AutoUpgradeRaceV3"] = false
}

SyncRealKidConfig = SyncRealKidConfig or function(overrides)
    if not (writefile and HttpService) then return end
    pcall(function()
        if makefolder then
            pcall(function() makefolder("RealKidHub") end)
            pcall(function() makefolder("RealKidHub/save2") end)
        end
        local myName = tostring(LocalPlayer.Name)
        local targetFile = "RealKidHub/save2/" .. myName .. ".json"
        local currentCfg = {}
        if isfile and isfile(targetFile) then
            local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(targetFile)) end)
            if ok and type(decoded) == "table" then currentCfg = decoded end
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

        writefile(targetFile, HttpService:JSONEncode(currentCfg))
    end)
end

-- // =============================================================================
-- // [AXIOM REALKID RUNTIME DETECTOR & TELEMETRY AUTO-SYNC]
-- // Quét liên tục CoreGui/PlayerGui: Nếu thấy GUI RealKid -> Tự động nhận diện Active Hub
-- // =============================================================================
task.spawn(function()
    while App.Running do
        pcall(function()
            local coreGui = cloneref and cloneref(game:GetService("CoreGui")) or game:GetService("CoreGui")
            local pGui = LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui")
            local foundHub = nil

            if coreGui then
                for _, name in ipairs({"RealKid Hub", "RealKid", "RealKidHub", "RealKidHop", "RealKid_Hop"}) do
                    local g = coreGui:FindFirstChild(name)
                    if g and g:IsA("ScreenGui") and g.Enabled ~= false then
                        foundHub = name:find("Hop") and "RealKid Hop" or "RealKid Hub"
                        break
                    end
                end
                if not foundHub then
                    for _, g in ipairs(coreGui:GetChildren()) do
                        if g:IsA("ScreenGui") and g.Enabled ~= false and g.Name:lower():find("realkid") then
                            foundHub = g.Name:lower():find("hop") and "RealKid Hop" or "RealKid Hub"
                            break
                        end
                    end
                end
            end

            if not foundHub and pGui then
                for _, g in ipairs(pGui:GetChildren()) do
                    if g:IsA("ScreenGui") and g.Enabled ~= false and g.Name:lower():find("realkid") then
                        foundHub = g.Name:lower():find("hop") and "RealKid Hop" or "RealKid Hub"
                        break
                    end
                end
            end

            if not foundHub then
                if getgenv().RealKid or getgenv().RealKidHub then
                    foundHub = "RealKid Hub"
                elseif getgenv().RealKidHop then
                    foundHub = "RealKid Hop"
                end
            end

            if foundHub then
                App.HubLaunched = true
                if not App.ActiveHub or App.ActiveHub == "NONE" or App.ActiveHub == "" or App.ActiveHub == "NONE (Sẵn sàng)" then
                    App.ActiveHub = foundHub
                end
            end
        end)
        task.wait(1)
    end
end)

local function LaunchRealKidHub(profileName, configTag)
    local desiredHub = "RealKid Hub"
    local desiredConfig = configTag or "Default"

    -- 1. Nếu chưa có Hub nào chạy trên server này: Khởi chạy độc quyền
    if not App.HubLaunched then
        App.HubLaunched = true
        App.ActiveHub = desiredHub
        App.ActiveConfig = desiredConfig
        App.CurrentActivity = "Đang chạy RealKid Hub (" .. tostring(profileName) .. ")..."
        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua"))()
            end)
            if not ok then
                warn("[AXIOM HUB] RealKid LoadString Error: " .. tostring(err))
            end
        end)
        return true
    end

    -- 2. Nếu đã chạy đúng RealKid và đúng Config Profile -> Giữ nguyên, không load đè
    if (App.ActiveHub == desiredHub or App.ActiveHub == "RealKid" or App.ActiveHub == "RealKid Hub") and App.ActiveConfig == desiredConfig then
        App.HubLaunched = true
        App.ActiveHub = desiredHub
        return true
    end

    -- 3. Khác Hub hoặc khác Config Profile -> TUYỆT ĐỐI KHÔNG CHẠY ĐÈ, BẮT BUỘC HOP SERVER!
    App.CurrentActivity = string.format("🔄 [Đổi Hub/Config] Đang chạy %s (%s) -> Cần %s (%s)! Hop Server...",
        tostring(App.ActiveHub), tostring(App.ActiveConfig), desiredHub, desiredConfig)
    warn(string.format("[AXIOM HUB] ⚠️ Tuyệt đối không chạy đè! Đang chạy [%s : %s], yêu cầu [%s : %s] -> Hop Server...",
        tostring(App.ActiveHub), tostring(App.ActiveConfig), desiredHub, desiredConfig))
    if TriggerLowServerHop then
        TriggerLowServerHop(true)
    end
    task.wait(5)
    return false
end

-- // =============================================================================
-- // [SEA 2 REALKID RACE V2 / V3 DELEGATION & CYBORG FRUIT GUARD]
-- // =============================================================================
-- // [AXIOM CYBORG FRUIT STORAGE WATCHDOG]
-- // Nếu phát hiện Backpack hoặc Character đang chứa Fruit quá 5s -> Tự động StoreFruit vào kho ngay
task.spawn(function()
    local fruitDetectedStart = 0
    while App.Running do
        task.wait(1)
        pcall(function()
            local targetKey = CleanRaceStr(App.TargetRace or TARGET_RACE or "")
            if targetKey == "cyborg" then
                local hasFruit = false
                if GetHeldFruit and GetHeldFruit() then
                    hasFruit = true
                else
                    local bp = LocalPlayer and LocalPlayer:FindFirstChild("Backpack")
                    if bp and IsFruitTool then
                        for _, item in ipairs(bp:GetChildren()) do
                            if IsFruitTool(item) then
                                hasFruit = true
                                break
                            end
                        end
                    end
                end

                if hasFruit then
                    if fruitDetectedStart == 0 then
                        fruitDetectedStart = os.clock()
                    elseif (os.clock() - fruitDetectedStart) >= 5 then
                        warn("[AXIOM FRUIT GUARD] 🍎 Phát hiện Fruit trong túi đồ quá 5s! Tiến hành cất vào kho (StoreFruit)...")
                        if StoreHeldFruit then
                            StoreHeldFruit()
                        end
                        fruitDetectedStart = 0
                    end
                else
                    fruitDetectedStart = 0
                end
            else
                fruitDetectedStart = 0
            end
        end)
    end
end)

local function ProcessRealKidSea2()
    if not IsSea2() then
        TravelToSea2("Cần làm V2/V3 Race tại Sea 2")
        return
    end

    -- [AXIOM FIX]: Log session V3 tức thì khi vào quy trình V2/V3 Sea 2
    if BroadcastV3Heartbeat then pcall(BroadcastV3Heartbeat) end
    if CheckSameServerCollision and CheckSameServerCollision() then return end
    local targetKey = CleanRaceStr(App.TargetRace or TARGET_RACE)
    local curKey = CleanRaceStr(GetCurrentRace())
    local isCyborgTarget = (targetKey == "cyborg")
    local isGhoulOrSkyTarget = (targetKey:find("ghoul") or targetKey:find("sky") or targetKey:find("angel")) ~= nil

    -- 1. NHÁNH GHOUL / SKYPIEA: CHỈ UPGRADE TỚI V2 BẰNG REALKID
    if isGhoulOrSkyTarget then
        if not CheckRaceV2() then
            App.CurrentActivity = "🌸 [Sea 2] Đang chạy RealKid Hub để lấy V2 cho " .. tostring(targetKey) .. "..."
            SyncRealKidConfig({
                ["AutoUpgradeRaceV3"] = true,
                ["AutoPullLever"] = false
            })
            LaunchRealKidHub("Sea 2 Ghoul/Sky Upgrade V2", "UpgradeV2")
            return
        else
            -- ĐÃ ĐẠT V2: DỪNG REALKID NGAY LẬP TỨC -> HOP SERVER VÀ CHẠY COOP V3 (TUYỆT ĐỐI KHÔNG BẬT REALKID)
            if App.HubLaunched and App.ActiveHub == "RealKid" then
                App.CurrentActivity = "🎉 [V2 Confirmed] Đã xong V2! Hop Server để khởi động Co-op V3 (Tắt RealKid)..."
                TriggerLowServerHop(true)
                task.wait(3)
                return
            end
            -- Co-op V3 thread sẽ tự động điều phối UpRace / HelpRace
            return
        end
    end

    -- 2. NHÁNH CYBORG & CÁC TỘC KHÁC: UPGRADE V2 & V3 VỚI REALKID
    if isCyborgTarget then
        -- Chưa có tộc Cyborg: Tiếp tục cơ chế Auto Law / Auto Chest lấy Core Brain & Fist
        if curKey ~= "cyborg" then
            return
        end

        -- Đã có tộc Cyborg: Kiểm tra trạng thái V3
        if not CheckCyborgV3() then
            App.CurrentActivity = "⚡ [Sea 2 Cyborg] Đang chạy RealKid Main AutoUpgradeRaceV3 & AutoBuyFruitsFlag..."
            SyncRealKidConfig({
                ["AutoBuyFruitsFlag"] = true,
                ["AutoUpgradeRaceV3"] = true,
                ["AutoPullLever"] = false
            })
            LaunchRealKidHub("Sea 2 Cyborg Upgrade V3", "UpgradeV3")

            -- Hỗ trợ nạp trái cho Wenlocktoad nếu RealKid chưa tự động nạp
            pcall(function()
                if ExecuteRaceV3TurnIn then ExecuteRaceV3TurnIn() end
            end)
            return
        else
            -- ĐÃ HOÀN TẤT V3 CYBORG: NẾU CÓ TRÁI TRONG TÚI PHẢI STORE RỒI MỚI SANG SEA 3!
            App.CurrentActivity = "🎉 [Cyborg V3] Đã đạt V3! Kiểm tra Fruit trong túi đồ..."
            if StoreHeldFruit then
                StoreHeldFruit()
            end
            task.wait(0.5)

            if GetHeldFruit and GetHeldFruit() then
                App.CurrentActivity = "🍎 [Cyborg V3] Đang cất giữ Fruit vào kho trước khi qua Sea 3..."
                if StoreHeldFruit then StoreHeldFruit() end
                task.wait(1)
            end

            App.CurrentActivity = "🌊 [Cyborg V3] Hoàn tất V3 & cất Fruit -> Di chuyển sang Sea 3..."
            TravelToSea3("Đã xong Cyborg V3 và cất giữ Fruit an toàn")
            return
        end
    else
        -- Các tộc khác (Fishman, Mink, Human)
        if not CheckCyborgV3() then
            App.CurrentActivity = "⚡ [Sea 2] Đang chạy RealKid Hub AutoUpgradeRaceV3 cho " .. tostring(targetKey) .. "..."
            SyncRealKidConfig({
                ["AutoUpgradeRaceV3"] = true,
                ["AutoPullLever"] = false
            })
            LaunchRealKidHub("Sea 2 Race Upgrade V3", "UpgradeV3")
        else
            TravelToSea3("Đã hoàn tất Race V3 -> Di chuyển sang Sea 3")
        end
    end
end

-- // [SEA 3 REALKID PULL LEVER & RACE V4 PROGRESS STATE MACHINE]
-- // Specs:
-- //   1. Khoa cung khong hop: App.IsPullingLever = true
-- //   2. CheckLeverPulled(): Keo can xong -> DOI ACC NGAY LAP TUC (Zero Delay)
-- //   3. RaceV4Progress State Machine:
-- //      - response == 1: remote CommF_ "RaceV4Progress", "Begin"
-- //      - response == 2: tween 170 stud/s den (3033, 2281, -7324) + Antigravity -> remote CommF_ "RaceV4Progress", "Teleport"
-- //      - response == 3: remote CommF_ "RaceV4Progress", "Continue"
-- //      - response == 4: Chay RealKid Main voi config AutoFindMirageIsland = false, AutoLookAtMoon = false, AutoCollectGear = false
-- // =============================================================================
-- // ==============================================================================
-- // AXIOM ENGINE: ADVANCED MULTI-SOURCE INVENTORY RESOLVER & DUAL-BOSS PIPELINE
-- // TARGETS: MIRROR FRACTAL (DOUGH KING) & VALKYRIE HELM (RIP INDRA)
-- // FEATURES: IRS CLIENT CACHE | LOAF MIRROR SEQUENCE | CHACHA20 HOP | NO CHANGE ACC
-- // ==============================================================================
local MM_Inventory
local MM_Engine

do
    local request_ = request or http_request or (syn and syn.request) or (fluxus and fluxus.request) or (Krnl and Krnl.request)

    if getgenv()._AxiomBossFarm then
        pcall(function() getgenv()._AxiomBossFarm:Unload() end)
        task.wait(0.1)
    end

    local CONFIG = {
        Sea1PlaceId     = 2753915549,
        Sea2PlaceId     = 4442272183,
        Sea3PlaceId     = 7449423635,
        TweenSpeed      = 170,
        HoverDistanceY  = 18,
        MaxHopPlayers   = 11,
        HopTimeout      = 3,
        ArrivalRadius   = 350,
        BaseUrl         = "http://163.223.9.144/boss",
        CipherPrefix    = "NIGHTHUB|",
        MasterKeyHex    = "8992d555ed7846a562b058523100fbd0e59b5f6f28e98003230ffb4d9db60411",
        VisitedFile     = "Axiom_VisitedServers.json"
    }

    local POS_LOAF = Vector3.new(-2145.4, 36.68, -11895)
    local POS_CASTLE = Vector3.new(-5085.24, 314.52, -3156.28)
    local CF_MIRROR_TARGET = CFrame.new(-2151.8, 149.3, -12404.9)
    local POS_DOUGH_ALTAR = Vector3.new(-2147.2, 70.2, -12375.8)
    local POS_SUBMERGE_CENTER = Vector3.new(11190.48, -2102.58, 9841.79)
    local POS_SUBMERGE_TELEPORT = Vector3.new(11425.40, -2154.92, 9728.05)
    local TweenToPosition -- [AXIOM FORWARD DECLARATION]
    local EnsureZoneArrivalBeforeHop -- [AXIOM FORWARD DECLARATION]

    local PlaceId = game.PlaceId
    local SEA_BY_PLACE = {
        [2753915549]       = 1,
        [4442272183]       = 2,
        [79091703265657]   = 2,
        [7449423635]       = 3,
        [100117331123089]  = 3
    }

    local CURRENT_SEA = SEA_BY_PLACE[PlaceId] or (function()
        if PlaceId == 4442272183 or PlaceId == 79091703265657 then return 2 end
        if PlaceId == 7449423635 or PlaceId == 100117331123089 then return 3 end
        return 1
    end)()

    local function GetCommF()
        local rem = ReplicatedStorage:FindFirstChild("Remotes")
        if rem and rem:FindFirstChild("CommF_") then
            return rem.CommF_
        end
        return ReplicatedStorage:FindFirstChild("CommF_")
    end

    local TARGET_ENDPOINTS = {
        ["Dough King"] = { "DoughKing", "Dough_King" },
        ["Rip Indra"]  = { "RipIndra", "Indra", "rip_indra" }
    }

    local Engine = {
        Enabled             = false, -- Chỉ kích hoạt khi tới bước Pull Lever mà thiếu Mirror/Valk
        IsRunning           = true,
        IsHopping           = false,
        IsTweening          = false,
        MirrorTeleported    = false,
        HasArrivedAtCastle  = false,
        HasArrivedAtLoaf    = false,
        CurrentCombatTarget = nil,
        CurrentTween        = nil,
        VisitedServers      = {},
        Connections         = {},
        Threads             = {},
        Instances           = {},
        StatusLabel         = setmetatable({ Text = "", TextColor3 = Color3.fromRGB(0, 200, 255) }, {
            __newindex = function(t, k, v)
                rawset(t, k, v)
                if k == "Text" and App then
                    local cleanText = tostring(v):gsub("^Trạng thái:%s*", "")
                    App.CurrentActivity = cleanText
                end
            end
        }),
        DoughStatusLabel    = { Text = "", TextColor3 = Color3.new(1, 1, 1) },
        IndraStatusLabel    = { Text = "", TextColor3 = Color3.new(1, 1, 1) },
        FractalLabel        = { Text = "", TextColor3 = Color3.new(1, 1, 1) },
        ValkyrieLabel       = { Text = "", TextColor3 = Color3.new(1, 1, 1) }
    }
    getgenv()._AxiomBossFarm = Engine
    MM_Engine = Engine

    -- ==============================================================================
    -- [MULTI-SOURCE ULTRA-FAST INVENTORY ENGINE]
    -- ==============================================================================
    local Inventory = {
        Weapons = {},
        Materials = {},
        PermanentOwned = {
            Valkyrie = false,
            Fractal  = false
        },
        LastScanTick = 0
    }
    MM_Inventory = Inventory

    local function SafeRequire(inst)
        if not inst or not inst:IsA("ModuleScript") then return nil end
        local ok, res = pcall(require, inst)
        return ok and res or nil
    end

    function Inventory:FastScan()
        local now = os.clock()
        if now - self.LastScanTick < 1.0 then return end
        self.LastScanTick = now

        local char = LocalPlayer.Character
        local bp = LocalPlayer:FindFirstChild("Backpack")

        -- 1. Microsecond Check trên Character & Backpack
        if char then
            for _, item in ipairs(char:GetChildren()) do
                local low = item.Name:lower()
                if low:find("valkyrie") then self.PermanentOwned.Valkyrie = true end
                if low:find("fractal") or low:find("mirror") then self.PermanentOwned.Fractal = true end
            end
        end

        if bp then
            for _, item in ipairs(bp:GetChildren()) do
                local low = item.Name:lower()
                if low:find("valkyrie") then self.PermanentOwned.Valkyrie = true end
                if low:find("fractal") or low:find("mirror") then self.PermanentOwned.Fractal = true end
            end
        end

        if self.PermanentOwned.Valkyrie and self.PermanentOwned.Fractal then
            return
        end

        -- 2. Đọc Cache Client từ ItemReplicationService
        pcall(function()
            local irsInst = ReplicatedStorage:FindFirstChild("ItemReplicationService")
            local cfgInst = ReplicatedStorage:FindFirstChild("ItemConfig")
            local IRS = SafeRequire(irsInst)
            local CfgStorage = cfgInst and cfgInst:FindFirstChild("Storage") and SafeRequire(cfgInst.Storage)
            local KeysModule = irsInst and irsInst:FindFirstChild("KEYS") and SafeRequire(irsInst.KEYS)

            if IRS and IRS._UserCache then
                local userItems = IRS._UserCache[LocalPlayer.UserId]
                if userItems and typeof(userItems.GetItems) == "function" then
                    local quantityKey = KeysModule and KeysModule.QUANTITY or "Quantity"
                    local quantities = userItems:GetItems(quantityKey)

                    if quantities then
                        for _, itemEntry in pairs(quantities) do
                            local itemId = tostring(itemEntry.ItemId or "")
                            local label = itemId

                            if CfgStorage and typeof(CfgStorage.match) == "function" then
                                pcall(function()
                                    local matchData = CfgStorage.match(itemId):unwrap()
                                    if matchData and matchData.Index then
                                        label = matchData.Index.DebugLabel or matchData.Index.StorageKey or label
                                    end
                                end)
                            end

                            label = label:gsub(" %[.-%]", "")
                            local lowLabel = label:lower()
                            local lowId = itemId:lower()

                            if lowLabel:find("valkyrie") or lowId:find("valkyrie") then self.PermanentOwned.Valkyrie = true end
                            if lowLabel:find("fractal") or lowLabel:find("mirror") or lowId:find("fractal") or lowId:find("mirror") then self.PermanentOwned.Fractal = true end
                        end
                    end
                end
            end
        end)

        -- 3. Gọi Remote Server nếu cả 2 phương thức trên chưa xác nhận
        if not (self.PermanentOwned.Valkyrie and self.PermanentOwned.Fractal) then
            pcall(function()
                local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
                if commF then
                    local invList = commF:InvokeServer("getInventory")
                    if typeof(invList) == "table" then
                        for _, item in pairs(invList) do
                            local name = tostring(item.Name or item.Item or ""):lower()
                            if name:find("valkyrie") then self.PermanentOwned.Valkyrie = true end
                            if name:find("fractal") or name:find("mirror") then self.PermanentOwned.Fractal = true end
                        end
                    end
                end
            end)
        end
    end

    function Inventory:HasItem(target)
        target = target:lower()
        if target:find("valkyrie") and self.PermanentOwned.Valkyrie then return true end
        if target:find("fractal") and self.PermanentOwned.Fractal then return true end
        self:FastScan()
        if target:find("valkyrie") and self.PermanentOwned.Valkyrie then return true end
        if target:find("fractal") and self.PermanentOwned.Fractal then return true end
        return false
    end

    -- ==============================================================================
    -- [PERSISTENCE HISTORY]
    -- ==============================================================================
    function Engine:LoadHistory()
        if isfile and isfile(CONFIG.VisitedFile) then
            local ok, data = pcall(function()
                return HttpService:JSONDecode(readfile(CONFIG.VisitedFile))
            end)
            if ok and type(data) == "table" then
                local now = os.time()
                local cleaned = {}
                for jId, t in pairs(data) do
                    if type(t) == "number" and (now - t < 600) then
                        cleaned[jId] = t
                    end
                end
                self.VisitedServers = cleaned
                return
            end
        end
        self.VisitedServers = {}
    end

    function Engine:RecordServer(jobId)
        if not jobId then return end
        self.VisitedServers[tostring(jobId)] = os.time()
        if writefile then
            pcall(function()
                writefile(CONFIG.VisitedFile, HttpService:JSONEncode(self.VisitedServers))
            end)
        end
    end

    function Engine:IsVisited(jobId)
        if not jobId then return true end
        local t = self.VisitedServers[tostring(jobId)]
        if not t then return false end
        if (os.time() - t > 600) then
            self.VisitedServers[tostring(jobId)] = nil
            return false
        end
        return true
    end

    Engine:LoadHistory()

    -- ==============================================================================
    -- [CHACHA20 DECRYPTION KERNEL]
    -- ==============================================================================
    local bxor, band, lshift, rshift, lrotate = bit32.bxor, bit32.band, bit32.lshift, bit32.rshift, bit32.lrotate
    local CONST_MOD = 4294967296
    local STATE_CONST = { 1634760805, 857760878, 2036477234, 1797285236 }
    local SBOX_CACHE = {}

    local function HexToBytes(hex)
        local out = {}
        for i = 1, #hex, 2 do out[#out + 1] = tonumber(hex:sub(i, i + 1), 16) end
        return out
    end

    local MasterKeyBytes = HexToBytes(CONFIG.MasterKeyHex)

    local function U32LE(b, offset)
        return b[offset] + b[offset + 1] * 256 + b[offset + 2] * 65536 + b[offset + 3] * 16777216
    end

    local function QuarterRound(s, a, b, c, d)
        s[a] = (s[a] + s[b]) % CONST_MOD
        s[d] = lrotate(bxor(s[d], s[a]), 16)
        s[c] = (s[c] + s[d]) % CONST_MOD
        s[b] = lrotate(bxor(s[b], s[c]), 12)
        s[a] = (s[a] + s[b]) % CONST_MOD
        s[d] = lrotate(bxor(s[d], s[a]), 8)
        s[c] = (s[c] + s[d]) % CONST_MOD
        s[b] = lrotate(bxor(s[b], s[c]), 7)
    end

    local function Permute(s)
        for _ = 1, 10 do
            QuarterRound(s, 1, 5, 9, 13)
            QuarterRound(s, 2, 6, 10, 14)
            QuarterRound(s, 3, 7, 11, 15)
            QuarterRound(s, 4, 8, 12, 16)
            QuarterRound(s, 1, 6, 11, 16)
            QuarterRound(s, 2, 7, 12, 13)
            QuarterRound(s, 3, 8, 9, 14)
            QuarterRound(s, 4, 5, 10, 15)
        end
    end

    local function InitState(key, counter, nonce)
        local state = { STATE_CONST[1], STATE_CONST[2], STATE_CONST[3], STATE_CONST[4] }
        for i = 0, 7 do state[5 + i] = U32LE(key, 1 + 4 * i) end
        state[13] = counter % CONST_MOD
        for i = 0, 2 do state[14 + i] = U32LE(nonce, 1 + 4 * i) end
        return state
    end

    local function GenerateBlock(key, counter, nonce)
        local initial = InitState(key, counter, nonce)
        local state = {}
        for i = 1, 16 do state[i] = initial[i] end
        Permute(state)
        local stream = {}
        for i = 1, 16 do
            local sum = (state[i] + initial[i]) % CONST_MOD
            local idx = (i - 1) * 4
            stream[idx + 1] = band(sum, 255)
            stream[idx + 2] = band(rshift(sum, 8), 255)
            stream[idx + 3] = band(rshift(sum, 16), 255)
            stream[idx + 4] = band(rshift(sum, 24), 255)
        end
        return stream
    end

    local function Keystream(key, nonce, counter, len)
        local out, total = {}, 0
        while total < len do
            local block = GenerateBlock(key, counter, nonce)
            for i = 1, 64 do
                if total >= len then break end
                total = total + 1
                out[total] = block[i]
            end
            counter = counter + 1
        end
        return out
    end

    local function ComputeTag(key, nonce, data)
        local state = InitState(key, 4294967295, nonce)
        Permute(state)
        local dataLen = #data
        local padded = dataLen + (16 - dataLen % 16) % 16
        for i = 0, padded - 1, 16 do
            for j = 0, 3 do
                local off = i + 4 * j
                local val = (data[off + 1] or 0) + (data[off + 2] or 0) * 256 + (data[off + 3] or 0) * 65536 + (data[off + 4] or 0) * 16777216
                state[j + 1] = bxor(state[j + 1], val)
            end
            Permute(state)
        end
        state[1] = bxor(state[1], dataLen)
        Permute(state)
        local tagWord = state[1]
        return {
            band(tagWord, 255),
            band(rshift(tagWord, 8), 255),
            band(rshift(tagWord, 16), 255),
            band(rshift(tagWord, 24), 255)
        }
    end

    local function BuildAlphabet(key)
        local cacheKey = table.concat(key, ",")
        if SBOX_CACHE[cacheKey] then return SBOX_CACHE[cacheKey] end
        local stream = Keystream(key, { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, 11259375, 128)
        local chars = {}
        for i = 1, 64 do
            chars[i] = ("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"):sub(i, i)
        end
        for i = 64, 2, -1 do
            local n = i - 1
            local target = (stream[2 * n + 1] * 256 + stream[2 * n + 2]) % i + 1
            chars[i], chars[target] = chars[target], chars[i]
        end
        local res = table.concat(chars)
        SBOX_CACHE[cacheKey] = res
        return res
    end

    local function Base64CustomDecode(str, alphabet)
        local map = {}
        for i = 1, 64 do map[alphabet:sub(i, i)] = i - 1 end
        local indices = {}
        for i = 1, #str do
            local idx = map[str:sub(i, i)]
            if not idx then return nil end
            indices[#indices + 1] = idx
        end
        local bytes = {}
        for i = 1, #indices, 4 do
            local c1, c2, c3, c4 = indices[i], indices[i + 1], indices[i + 2], indices[i + 3]
            if not c2 then return nil end
            bytes[#bytes + 1] = band(lshift(c1, 2) + rshift(c2, 4), 255)
            if c3 then bytes[#bytes + 1] = band(lshift(band(c2, 15), 4) + rshift(c3, 2), 255) end
            if c4 then bytes[#bytes + 1] = band(lshift(band(c3, 3), 6) + c4, 255) end
        end
        return bytes
    end

    local function DecryptJobId(encryptedString)
        if type(encryptedString) ~= "string" or encryptedString:sub(1, #CONFIG.CipherPrefix) ~= CONFIG.CipherPrefix then
            return nil, "Prefix mismatch"
        end
        local cipherBody = encryptedString:sub(#CONFIG.CipherPrefix + 1)
        local alphabet = BuildAlphabet(MasterKeyBytes)
        local raw = Base64CustomDecode(cipherBody, alphabet)
        if not raw or #raw < 12 then return nil, "Malformed payload" end

        local nonce = {}
        for i = 1, 8 do nonce[i] = raw[i] end
        for i = 9, 12 do nonce[i] = 0 end

        local expectedTag = {}
        for i = 1, 4 do expectedTag[i] = raw[8 + i] end

        local ciphertext = {}
        for i = 13, #raw do ciphertext[#ciphertext + 1] = raw[i] end

        local calculatedTag = ComputeTag(MasterKeyBytes, nonce, ciphertext)
        for i = 1, 4 do
            if calculatedTag[i] ~= expectedTag[i] then return nil, "Tag validation failure" end
        end

        local stream = Keystream(MasterKeyBytes, nonce, 1, #ciphertext)
        local plainBytes = {}
        for i = 1, #ciphertext do
            plainBytes[i] = string.char(bxor(ciphertext[i], stream[i]))
        end
        return table.concat(plainBytes)
    end

    -- ==============================================================================
    -- [API LIVE BOSS DISPATCHER]
    -- ==============================================================================
    local function FetchBossServers(endpoints)
        if not request_ and not game.HttpGet then return nil end
        local candidateList = (type(endpoints) == "table") and endpoints or { endpoints }

        for _, ep in ipairs(candidateList) do
            local url = string.format("%s/%s", CONFIG.BaseUrl, ep)
            local raw = nil

            if request_ then
                pcall(function()
                    local res = request_({
                        Url = url,
                        Method = "GET",
                        Headers = {
                            ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)",
                            ["Accept"] = "application/json"
                        }
                    })
                    if res and (res.StatusCode == 200 or res.status == 200) then
                        raw = res.Body or res.body
                    end
                end)
            end

            if not raw or raw == "" then
                pcall(function()
                    raw = game:HttpGet(url)
                end)
            end

            if raw and raw ~= "" then
                local ok, payload = pcall(HttpService.JSONDecode, HttpService, raw)
                if ok and type(payload) == "table" then
                    local validServers = {}
                    local dataList = payload.data or payload.servers or payload.Servers or (type(payload) == "table" and payload)

                    if type(dataList) == "table" then
                        for _, entry in ipairs(dataList) do
                            if type(entry) == "table" and (entry.JobId or entry.job_id) then
                                local jId = entry.JobId or entry.job_id
                                local decrypted = DecryptJobId(jId) or jId
                                if decrypted then
                                    table.insert(validServers, {
                                        JobId   = tostring(decrypted),
                                        Players = tonumber(entry.Players or entry.players or entry.count) or 0,
                                        PlaceId = entry.PlaceId or entry.placeId or game.PlaceId,
                                        Sea     = entry.Sea or entry.sea or 3
                                    })
                                end
                            end
                        end
                    end

                    if #validServers > 0 then
                        return validServers
                    end
                end
            end
        end
        return nil
    end

    local function SelectLowestServerBottomUp(servers)
        if not servers or #servers == 0 then return nil end
        local candidates = {}

        for _, s in ipairs(servers) do
            local isDiffJob = s.JobId ~= tostring(game.JobId)
            local notVisited = not Engine:IsVisited(s.JobId)
            local validPlayers = s.Players <= CONFIG.MaxHopPlayers

            if isDiffJob and notVisited and validPlayers then
                table.insert(candidates, s)
            end
        end

        if #candidates == 0 then return nil end

        local minPlayers = math.huge
        for _, s in ipairs(candidates) do
            if s.Players < minPlayers then
                minPlayers = s.Players
            end
        end

        for i = #candidates, 1, -1 do
            if candidates[i].Players == minPlayers then
                return candidates[i]
            end
        end

        return candidates[#candidates]
    end

    -- ==============================================================================
    -- [TELEPORT ENGINE]
    -- ==============================================================================
    local tpInitConn = TeleportService.TeleportInitFailed:Connect(function(player)
        if player == LocalPlayer then
            Engine.IsHopping = false
            if Engine.StatusLabel then
                Engine.StatusLabel.Text = "Trạng thái: ⚠️ Lỗi kết nối server! Đang chuyển Job khác..."
            end
        end
    end)
    table.insert(Engine.Connections, tpInitConn)

    local onTpConn = LocalPlayer.OnTeleport:Connect(function(state)
        local stateName = ""
        pcall(function() stateName = state.Name end)
        if stateName == "Failed" then
            Engine.IsHopping = false
        end
    end)
    table.insert(Engine.Connections, onTpConn)

    -- [AXIOM RESPAWN RECOVERY] INSTANT TWEEN RESUME ON CHARACTER SPAWN
    local charAddedConn = LocalPlayer.CharacterAdded:Connect(function()
        if Engine.CurrentTween then
            pcall(function() Engine.CurrentTween:Cancel() end)
            Engine.CurrentTween = nil
        end
        Engine.IsTweening = false
        Engine.CurrentCombatTarget = nil
        Engine.CurrentTweenToken = (Engine.CurrentTweenToken or 0) + 1
    end)
    table.insert(Engine.Connections, charAddedConn)

    function Engine:TeleportToBossJob(JOB_ID, targetPlaceId)
        if not JOB_ID or JOB_ID == "" or JOB_ID == game.JobId then return false end
        self:RecordServer(JOB_ID)

        local destinationPlace = targetPlaceId or game.PlaceId
        local sb = ReplicatedStorage:FindFirstChild("__ServerBrowser")
        local success = false

        if sb then
            success = pcall(function()
                sb:InvokeServer("teleport", JOB_ID)
            end)
        end

        if not success then
            pcall(function()
                TeleportService:TeleportToPlaceInstance(destinationPlace, JOB_ID, LocalPlayer)
            end)
        end

        return true
    end

    function Engine:HopToTargetBoss(bossName)
        if self.IsHopping then return end
        self.IsHopping = true

        task.spawn(function()
            local isDough = (bossName == "Dough King")
            local targetDest = isDough and POS_LOAF or POS_CASTLE
            local zoneLabel = isDough and "Cake Loaf" or "Castle on the Sea"
            local bossPatterns = isDough and { "Dough King" } or { "rip_indra", "rip_indra True Form" }

            -- [AXIOM MANDATORY PRE-HOP GATE]: Phải tween tới đích và xác nhận đã đến trước 1 lần rồi mới chạy Hop API
            local arrived = EnsureZoneArrivalBeforeHop(bossName, targetDest, zoneLabel, bossPatterns)
            if not arrived or not Engine.IsRunning or not Engine.Enabled then
                self.IsHopping = false
                return
            end

            if Engine.StatusLabel then
                Engine.StatusLabel.Text = string.format("Trạng thái: 🌐 Đã xác nhận vị trí %s! Đang tìm server %s...", zoneLabel, bossName)
            end

            local endpoints = TARGET_ENDPOINTS[bossName] or { bossName }
            local servers = FetchBossServers(endpoints)
            local targetServer = SelectLowestServerBottomUp(servers)

            if targetServer and targetServer.JobId then
                if Engine.StatusLabel then
                    Engine.StatusLabel.Text = string.format("Trạng thái: 🚀 Đang hop tới Job: %s (%d players)...", targetServer.JobId:sub(1, 8), targetServer.Players)
                end
                local ok = Engine:TeleportToBossJob(targetServer.JobId, targetServer.PlaceId)
                if not ok then
                    Engine.IsHopping = false
                end
            else
                if Engine.StatusLabel then
                    Engine.StatusLabel.Text = string.format("Trạng thái: ⚠️ Không tìm thấy server %s phù hợp, thử lại sau %ds...", bossName, CONFIG.HopTimeout)
                end
                task.wait(CONFIG.HopTimeout)
                Engine.IsHopping = false
            end
        end)
    end

    -- =========================================================================
    -- [AXIOM WATCHDOG] 0.5S BOSS HEALTH MONITOR & TWEEN AUTO-CANCEL
    -- =========================================================================
    local watchdogThread = task.spawn(function()
        while task.wait(0.5) do
            if Engine and Engine.IsRunning then
                local mob = Engine.CurrentCombatTarget or Engine.TargetBoss
                if mob then
                    local hum = mob:FindFirstChildOfClass("Humanoid")
                    local isDead = (not mob.Parent) or (not hum) or (hum.Health <= 0)
                    if isDead then
                        if Engine.CurrentTween then
                            pcall(function() Engine.CurrentTween:Cancel() end)
                            Engine.CurrentTween = nil
                        end
                        Engine.CurrentCombatTarget = nil
                        Engine.TargetBoss = nil
                    end
                end
            end
        end
    end)
    table.insert(Engine.Threads, watchdogThread)

    -- ==============================================================================
    -- [SEA CHECK & AUTO SEA 3]
    -- ==============================================================================
    local function GetCurrentSeaNum()
        local pid = game.PlaceId
        if pid == CONFIG.Sea1PlaceId then return 1
        elseif pid == CONFIG.Sea2PlaceId or pid == 79091703265657 then return 2
        elseif pid == CONFIG.Sea3PlaceId or pid == 100117331123089 then return 3 end

        local map = workspace:FindFirstChild("Map")
        if map then
            if map:FindFirstChild("Turtle") or map:FindFirstChild("Castle") or map:FindFirstChild("Haunted") or map:FindFirstChild("PortTown") then return 3
            elseif map:FindFirstChild("Dressrosa") or map:FindFirstChild("GreenZone") or map:FindFirstChild("Factory") or map:FindFirstChild("Ship") then return 2 end
        end
        return 3
    end

    local function TeleportToSea(targetSea)
        local currentSea = GetCurrentSeaNum()
        if currentSea == targetSea then return end
        local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_")
        local targetPlaceId = (targetSea == 3) and CONFIG.Sea3PlaceId or ((targetSea == 2) and CONFIG.Sea2PlaceId or CONFIG.Sea1PlaceId)

        if commF then
            if targetSea == 3 then pcall(function() commF:InvokeServer("TravelZou") end)
            elseif targetSea == 2 then pcall(function() commF:InvokeServer("TravelDressrosa") end)
            elseif targetSea == 1 then pcall(function() commF:InvokeServer("TravelMain") end) end
        end
        task.wait(2.0)
        pcall(function() TeleportService:Teleport(targetPlaceId, LocalPlayer) end)
    end

    -- // =========================================================================
    -- // [SMART PORTAL ENGINE & ISLAND NAVIGATOR] HARD-LOCKED 170 STUDS/S
    -- // =========================================================================
    local LOCKED_TWEEN_SPEED = 170

    local PORTAL_NETWORK_MM = {
        [1] = {
            {
                Name = "Skypiea Cloud Gate",
                Gate = Vector3.new(-6024.18, 5471.35, 2218.09),
                RemoteExit = Vector3.new(-4166.61, 1093.70, -347.16),
                ExitArrival = Vector3.new(-4166.61, 1093.70, -347.16)
            },
            {
                Name = "Underwater Whirlpool",
                Gate = Vector3.new(4041.83, -3.07, -1810.55),
                RemoteExit = Vector3.new(61167.36, -2.93, 1950.91),
                ExitArrival = Vector3.new(61167.36, 18.50, 1950.91)
            }
        },
        [2] = {
            {
                Name = "Graveyard -> Cursed Ship",
                Gate = Vector3.new(-6501.28, 83.46, -124.42),
                RemoteExit = Vector3.new(922.89, 125.36, 32843.34),
                ExitArrival = Vector3.new(922.89, 125.36, 32843.34)
            },
            {
                Name = "Cursed Ship -> Graveyard",
                Gate = Vector3.new(922.89, 125.36, 32843.34),
                RemoteExit = Vector3.new(-6501.28, 83.46, -124.42),
                ExitArrival = Vector3.new(-6501.28, 83.46, -124.42)
            }
        },
        [3] = {
            {
                Name = "Castle -> Mansion Portal",
                Gate = Vector3.new(-5059.82, 326.79, -3192.29),
                RemoteExit = Vector3.new(-12463.60, 386.62, -7566.08),
                ExitArrival = Vector3.new(-12463.60, 386.62, -7566.08)
            },
            {
                Name = "Mansion -> Castle Portal",
                Gate = Vector3.new(-12463.60, 386.62, -7566.08),
                RemoteExit = Vector3.new(-5059.82, 326.79, -3192.29),
                ExitArrival = Vector3.new(-5059.82, 326.79, -3192.29)
            },
            {
                Name = "Castle -> Tiki Outpost",
                Gate = Vector3.new(-5095.44, 316.79, -3175.76),
                RemoteExit = Vector3.new(-16800.35, 60.26, 290.22),
                ExitArrival = Vector3.new(-16800.35, 60.26, 290.22)
            },
            {
                Name = "Tiki -> Castle Portal",
                Gate = Vector3.new(-16800.35, 60.26, 290.22),
                RemoteExit = Vector3.new(-5095.44, 316.79, -3175.76),
                ExitArrival = Vector3.new(-5095.44, 316.79, -3175.76)
            },
            {
                Name = "Hydra Waterfall -> Castle",
                Gate = Vector3.new(5650.95, 1025.57, -350.38),
                RemoteExit = Vector3.new(-5027.03, 326.79, -3206.70),
                ExitArrival = Vector3.new(-5027.03, 326.79, -3206.70)
            }
        }
    }

    local function CalculateOptimalRoute(targetPos)
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return nil, nil end

        local currentPos = root.Position
        local targetV3 = (typeof(targetPos) == "CFrame" and targetPos.Position) or targetPos
        local directDist = (targetV3 - currentPos).Magnitude
        local sea = CURRENT_SEA or 3
        local portals = PORTAL_NETWORK_MM[sea] or PORTAL_NETWORK_MM[3] or {}

        local bestPortal = nil
        local bestTotalDist = directDist

        if #portals > 0 then
            for _, portal in ipairs(portals) do
                local distToGate = (portal.Gate - currentPos).Magnitude
                local distFromExit = (targetV3 - portal.ExitArrival).Magnitude
                local totalWithPortal = distToGate + distFromExit

                if totalWithPortal < (bestTotalDist - 600) then
                    bestTotalDist = totalWithPortal
                    bestPortal = portal
                end
            end
        end

        return bestPortal, directDist
    end

    local Navigator = {
        Running        = true,
        UsePortalTP    = true,
        TweenSpeed     = LOCKED_TWEEN_SPEED,
        ActiveTween    = nil,
        IsTweening     = false,
        CurrentToken   = 0,
        SelectedIsland = nil,
        Connections    = {},
        Instances      = {}
    }
    getgenv().AxiomIslandNavigator = Navigator

    function Navigator:Unload()
        self.Running = false
        for _, conn in pairs(self.Connections) do
            if typeof(conn) == "RBXScriptConnection" then pcall(function() conn:Disconnect() end) end
        end
        self.Connections = {}
        if self.Instances.ScreenGui then pcall(function() self.Instances.ScreenGui:Destroy() end) end
        self.Instances = {}
        getgenv().AxiomIslandNavigator = nil
    end

    -- ==============================================================================
    -- [RADAR SCANNER]
    -- ==============================================================================
    local function ScanBossEntity(patterns)
        local containers = { workspace:FindFirstChild("Enemies"), workspace, ReplicatedStorage }
        for _, container in ipairs(containers) do
            if container then
                for _, child in ipairs(container:GetChildren()) do
                    local low = child.Name:lower()
                    for _, pat in ipairs(patterns) do
                        if low == pat:lower() or low:find(pat:lower()) then
                            local hum = child:FindFirstChildOfClass("Humanoid")
                            local root = child:FindFirstChild("HumanoidRootPart") or child:FindFirstChild("Head") or child.PrimaryPart
                            if (not hum or hum.Health > 0) then
                                return true, child, root, hum
                            end
                        end
                    end
                end
            end
        end
        return false, nil, nil, nil
    end

    -- ==============================================================================
    -- [FLIGHT & LOAF MIRROR SEQUENCE ENGINE]
    -- ==============================================================================
    local noclipConnection = RunService.Stepped:Connect(function()
        if Engine.IsRunning and Engine.Enabled then
            local char = LocalPlayer.Character
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end
    end)
    table.insert(Engine.Connections, noclipConnection)

    local function DirectTweenSegment(targetPos, token, abortBossPatterns)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not Engine.IsRunning or (token and Engine.CurrentTweenToken ~= token) then return false end

        if Engine.CurrentTween then
            pcall(function() Engine.CurrentTween:Cancel() end)
            Engine.CurrentTween = nil
        end

        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero

        local stabilizer = hrp:FindFirstChild("__AxiomStabilizer") or Instance.new("BodyVelocity")
        stabilizer.Name = "__AxiomStabilizer"
        stabilizer.MaxForce = Vector3.new(1e9, 1e9, 1e9)
        stabilizer.Velocity = Vector3.zero
        stabilizer.Parent = hrp

        Engine.IsTweening = true
        local speed = 170 -- Hard-locked velocity
        local dist = (hrp.Position - targetPos).Magnitude
        local duration = math.max(dist / speed, 0.05)

        local tw = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), { CFrame = CFrame.new(targetPos) })
        Engine.CurrentTween = tw

        local completed = false
        local conn
        conn = tw.Completed:Connect(function()
            completed = true
            if conn then conn:Disconnect() end
        end)
        tw:Play()

        while not completed and Engine.IsRunning and Engine.Enabled and (not token or Engine.CurrentTweenToken == token) do
            task.wait(0.05)
            local myHum = char:FindFirstChildOfClass("Humanoid")
            if not myHum or myHum.Health <= 0 then
                if tw then pcall(function() tw:Cancel() end) end
                if conn then conn:Disconnect() end
                Engine.IsTweening = false
                return false
            end
            -- Nếu đang pre-tween tới điểm chờ mà Boss xuất hiện giữa đường -> ngắt tween để vào đánh ngay
            if abortBossPatterns then
                local bActive = ScanBossEntity(abortBossPatterns)
                if bActive then
                    if tw then pcall(function() tw:Cancel() end) end
                    if conn then conn:Disconnect() end
                    Engine.IsTweening = false
                    return false
                end
            end
            if Engine.CurrentCombatTarget then
                local hum = Engine.CurrentCombatTarget:FindFirstChildOfClass("Humanoid")
                if not Engine.CurrentCombatTarget.Parent or not hum or hum.Health <= 0 then
                    Engine.CurrentCombatTarget = nil
                    if tw then pcall(function() tw:Cancel() end) end
                    if conn then conn:Disconnect() end
                    Engine.IsTweening = false
                    return false
                end
            end
        end

        if conn then conn:Disconnect() end
        Engine.IsTweening = false
        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        return completed
    end

    local function EscapeSubmergeIsland(token)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        if (hrp.Position - POS_SUBMERGE_CENTER).Magnitude <= 2000 then
            if Engine.StatusLabel then
                Engine.StatusLabel.Text = "Trạng thái: 🌊 Đang ở Submerged Island! Thoát về Sea Castle..."
            end
            local ok = DirectTweenSegment(POS_SUBMERGE_TELEPORT, token)
            if ok and (not token or Engine.CurrentTweenToken == token) then
                pcall(function()
                    local args = {
                        "InitiateTeleport",
                        "Sea Castle"
                    }
                    game:GetService("ReplicatedStorage"):WaitForChild("Modules"):WaitForChild("Net"):WaitForChild("RF/SubmarineTransportation"):InvokeServer(unpack(args))
                end)
                task.wait(1.5)
                local waitTicks = 0
                repeat
                    task.wait(0.2)
                    waitTicks = waitTicks + 1
                    local curHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                until not curHrp or (curHrp.Position - POS_SUBMERGE_CENTER).Magnitude > 2000 or waitTicks > 20
            end
            return true
        end
        return false
    end

    TweenToPosition = function(targetPos, _, abortBossPatterns)
        if not Engine.IsRunning or not Engine.Enabled then return false end
        Engine.CurrentTweenToken = (Engine.CurrentTweenToken or 0) + 1
        local token = Engine.CurrentTweenToken

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        -- [AXIOM SUBMERGE ESCAPE HOOK]
        EscapeSubmergeIsland(token)
        if Engine.CurrentTweenToken ~= token then return false end

        local targetV3 = (typeof(targetPos) == "CFrame" and targetPos.Position) or targetPos

        -- Smart Portal Routing Resolver
        -- [AXIOM GATE] Valkyrie Helm Check: Chưa có mũ thì cấm dùng Portal (Bay thường thuần túy)
        local hasValkyrieForPortal = (Inventory and Inventory:HasItem("valkyrie")) == true
        local bestPortal = hasValkyrieForPortal and CalculateOptimalRoute and CalculateOptimalRoute(targetV3)
        if bestPortal and (Navigator and Navigator.UsePortalTP ~= false) then
            if Engine.StatusLabel then
                Engine.StatusLabel.Text = string.format("Trạng thái: 🌀 Smart Portal: Bay tới %s...", bestPortal.Name)
            end
            local gatePos = bestPortal.Gate + Vector3.new(0, 3, 0)
            local gateOk = DirectTweenSegment(gatePos, token, abortBossPatterns)
            if not gateOk or Engine.CurrentTweenToken ~= token then return false end

            -- [AXIOM HITBOX ALIGNMENT]: Snap CFrame directly inside portal trigger frame
            local hrpCurrent = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrpCurrent then
                hrpCurrent.CFrame = CFrame.new(bestPortal.Gate + Vector3.new(0, 3, 0))
                task.wait(0.1)
            end

            if Engine.StatusLabel then
                Engine.StatusLabel.Text = "Trạng thái: 🌀 Đang qua cổng Portal..."
            end

            -- [AXIOM VERIFIED INVOCATION]: Multi-cycle retry loop until spatial shift confirmed
            local commF = GetCommF()
            if commF then
                for _ = 1, 4 do
                    pcall(function()
                        commF:InvokeServer("requestEntrance", bestPortal.RemoteExit)
                    end)
                    task.wait(0.2)
                    local ch = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if ch and (ch.Position - bestPortal.Gate).Magnitude > 200 then
                        break
                    end
                end
            end

            local waitTicks = 0
            repeat
                task.wait(0.1)
                waitTicks = waitTicks + 1
                local curHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            until not curHrp or (curHrp.Position - bestPortal.Gate).Magnitude > 200 or waitTicks > 25 or Engine.CurrentTweenToken ~= token

            if Engine.CurrentTweenToken ~= token then return false end
        end

        return DirectTweenSegment(targetV3, token, abortBossPatterns)
    end

    -- ==============================================================================
    -- [AXIOM PRE-HOP ZONE ARRIVAL VERIFIER]
    -- Bắt buộc Tween đến Castle on the Sea / Cake Loaf ít nhất 1 lần & xác nhận khoảng cách
    -- trước khi cho phép kích hoạt RealKid Hop hoặc Hop API.
    -- ==============================================================================
    EnsureZoneArrivalBeforeHop = function(bossName, targetPos, zoneLabel, bossPatterns)
        local isDough = (bossName == "Dough King")

        -- Nếu đã xác nhận đến nơi ít nhất 1 lần trong phiên server này -> kiểm tra lại hoặc cho qua
        if (isDough and Engine.HasArrivedAtLoaf) or (not isDough and Engine.HasArrivedAtCastle) then
            return true
        end

        while Engine.IsRunning and Engine.Enabled do
            -- Nếu Boss xuất hiện trong lúc đang bay tới điểm kiểm tra -> dừng quy trình hop để đánh Boss ngay
            if bossPatterns and ScanBossEntity(bossPatterns) then
                return false
            end

            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")

            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - targetPos).Magnitude
                if dist <= CONFIG.ArrivalRadius then
                    if isDough then
                        Engine.HasArrivedAtLoaf = true
                    else
                        Engine.HasArrivedAtCastle = true
                    end
                    if Engine.StatusLabel then
                        Engine.StatusLabel.Text = string.format("Trạng thái: ✅ Đã xác nhận đến %s (Cách: %.0f)! Sẵn sàng Hop...", zoneLabel, dist)
                    end
                    return true
                end

                if Engine.StatusLabel then
                    Engine.StatusLabel.Text = string.format("Trạng thái: ✈️ Đang tween đến %s trước khi Hop (Cách: %.0f)...", zoneLabel, dist)
                end

                TweenToPosition(targetPos, CONFIG.TweenSpeed, bossPatterns)

                -- Kiểm tra lại ngay sau khi kết thúc nhịp Tween
                local postChar = LocalPlayer.Character
                local postHrp = postChar and postChar:FindFirstChild("HumanoidRootPart")
                if postHrp and (postHrp.Position - targetPos).Magnitude <= CONFIG.ArrivalRadius then
                    if isDough then
                        Engine.HasArrivedAtLoaf = true
                    else
                        Engine.HasArrivedAtCastle = true
                    end
                    if Engine.StatusLabel then
                        Engine.StatusLabel.Text = string.format("Trạng thái: ✅ Đã xác nhận đến %s! Chuẩn bị quét & Hop...", zoneLabel)
                    end
                    return true
                end
            end

            task.wait(0.2)
        end

        return false
    end

    local function FlyOverTarget(targetPart)
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not targetPart or not targetPart.Parent then return end

        local targetCombatPos = targetPart.Position + Vector3.new(0, CONFIG.HoverDistanceY, 0)
        local dist = (hrp.Position - targetCombatPos).Magnitude

        if dist > 22 then
            TweenToPosition(targetCombatPos, CONFIG.TweenSpeed)
        else
            hrp.CFrame = CFrame.lookAt(targetCombatPos, targetPart.Position)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end
    end

    local function ExecuteLoafMirrorSequence()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end

        if Engine.StatusLabel then
            Engine.StatusLabel.Text = "Trạng thái: 🪞 Đang tween đến điểm gương Loaf..."
        end

        TweenToPosition(CF_MIRROR_TARGET.Position, CONFIG.TweenSpeed)

        hrp.AssemblyLinearVelocity = Vector3.zero
        hrp.AssemblyAngularVelocity = Vector3.zero
        hrp.CFrame = CF_MIRROR_TARGET
        hrp.Anchored = false

        if Engine.StatusLabel then
            Engine.StatusLabel.Text = "Trạng thái: 🪞 Đã đến gương! Thả Anchor, chờ 1s rồi áp sát Dough King..."
        end

        task.wait(1.0)
        Engine.MirrorTeleported = true
        return true
    end

    -- ==============================================================================
    -- [24/7 DYNAMIC MULTI-PROTOCOL FAST ATTACK KERNEL] (100% CDK REVISION)
    -- ==============================================================================
    local ObfuscatedRemote = nil
    local RemoteId = nil

    local function HookDynamicFastAttackRemote()
        local searchContainers = {
            ReplicatedStorage:FindFirstChild("Util"),
            ReplicatedStorage:FindFirstChild("Common"),
            ReplicatedStorage:FindFirstChild("Remotes"),
            ReplicatedStorage:FindFirstChild("Assets"),
            ReplicatedStorage:FindFirstChild("FX"),
        }

        for _, container in ipairs(searchContainers) do
            if container then
                for _, child in ipairs(container:GetChildren()) do
                    if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                        ObfuscatedRemote = child
                        RemoteId = child:GetAttribute("Id")
                        return
                    end
                end
                container.ChildAdded:Connect(function(child)
                    if child:IsA("RemoteEvent") and child:GetAttribute("Id") then
                        ObfuscatedRemote = child
                        RemoteId = child:GetAttribute("Id")
                    end
                end)
            end
        end
    end
    pcall(HookDynamicFastAttackRemote)

    local function EnsureBuso()
        local char = LocalPlayer.Character
        if char and not char:FindFirstChild("HasBuso") then
            local commF = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("CommF_") or ReplicatedStorage:FindFirstChild("CommF_")
            if commF then
                pcall(function() commF:InvokeServer("Buso") end)
            end
        end
    end

    local function ForceEquipWeapon()
        EnsureBuso()
        local char = LocalPlayer.Character
        if not char then return nil end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local equipped = char:FindFirstChildOfClass("Tool")
        if equipped and (equipped.ToolTip == "Melee" or equipped.ToolTip == "Sword") then
            return equipped
        end

        local bp = LocalPlayer:FindFirstChild("Backpack")
        if bp and hum then
            for _, item in ipairs(bp:GetChildren()) do
                if item:IsA("Tool") and (item.ToolTip == "Melee" or item.ToolTip == "Sword") then
                    hum:EquipTool(item)
                    return item
                end
            end
        end
        return equipped
    end

    local CachedNet = nil
    local function GetNetModule()
        if CachedNet then return CachedNet end
        local netMod = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
        if netMod and netMod:IsA("ModuleScript") then
            local ok, res = pcall(require, netMod)
            if ok and type(res) == "table" then
                CachedNet = res
                return CachedNet
            end
        end
        return nil
    end

    local function ExecuteFastAttack247()
        if not Engine.IsRunning or not Engine.Enabled then return end

        local char = LocalPlayer.Character
        if not char then return end
        local root = char:FindFirstChild("HumanoidRootPart")
        if not root then return end

        local activeTool = char:FindFirstChildOfClass("Tool")
        if not activeTool or (activeTool.ToolTip ~= "Melee" and activeTool.ToolTip ~= "Sword") then
            activeTool = ForceEquipWeapon()
        end
        EnsureBuso()

        local hitList = {}
        local primaryTarget = nil
        local hitPartsArray = {}

        -- Ưu tiên số 1: Mục tiêu boss đang khóa
        if Engine.CurrentCombatTarget and Engine.CurrentCombatTarget.Parent then
            local cHum = Engine.CurrentCombatTarget:FindFirstChildOfClass("Humanoid")
            local cRoot = Engine.CurrentCombatTarget:FindFirstChild("HumanoidRootPart") or Engine.CurrentCombatTarget:FindFirstChild("Head") or Engine.CurrentCombatTarget.PrimaryPart
            if cHum and cHum.Health > 0 and cRoot then
                local dist = (root.Position - cRoot.Position).Magnitude
                if dist <= 120 then
                    primaryTarget = Engine.CurrentCombatTarget:FindFirstChild("Head") or cRoot
                    table.insert(hitList, Engine.CurrentCombatTarget)
                    table.insert(hitPartsArray, { [1] = Engine.CurrentCombatTarget, [2] = cRoot })
                    table.insert(hitPartsArray, Engine.CurrentCombatTarget)
                end
            end
        end

        -- Quét diện rộng toàn bộ quái và boss xung quanh
        local function CollectTargets(container)
            if not container then return end
            for _, mob in ipairs(container:GetChildren()) do
                if mob ~= char and mob:IsA("Model") and not string.find(mob.Name:lower(), "reaper") and mob ~= Engine.CurrentCombatTarget then
                    local hum = mob:FindFirstChildOfClass("Humanoid")
                    local mRoot = mob:FindFirstChild("HumanoidRootPart") or mob:FindFirstChild("Head") or mob.PrimaryPart
                    if hum and hum.Health > 0 and mRoot then
                        local dist = (root.Position - mRoot.Position).Magnitude
                        if dist <= 75 then
                            table.insert(hitList, mob)
                            table.insert(hitPartsArray, { [1] = mob, [2] = mRoot })
                            table.insert(hitPartsArray, mob)
                            if not primaryTarget then
                                primaryTarget = mob:FindFirstChild("Head") or mRoot
                            end
                        end
                    end
                end
            end
        end

        CollectTargets(workspace:FindFirstChild("Enemies"))
        CollectTargets(workspace:FindFirstChild("Characters"))

        if #hitList == 0 or not primaryTarget then return end

        local netModInstance = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
        local netObj = GetNetModule()

        -- Protocol 1: Module Net Wrapper API
        if netObj and typeof(netObj.RemoteEvent) == "function" then
            pcall(function()
                local regAttack = netObj:RemoteEvent("RegisterAttack", true)
                local regHit = netObj:RemoteEvent("RegisterHit", true)
                if regAttack then regAttack:FireServer(0) end
                if regHit then
                    regHit:FireServer(primaryTarget, hitPartsArray, {}, "078da5141")
                end
            end)
        end

        -- Protocol 2 & 3: Direct Remote Event + Obfuscated Seed Hash
        if netModInstance then
            local regAttackDirect = netModInstance:FindFirstChild("RE/RegisterAttack")
            local regHitDirect = netModInstance:FindFirstChild("RE/RegisterHit")
            if regAttackDirect and regAttackDirect:IsA("RemoteEvent") then
                regAttackDirect:FireServer()
            end
            if regHitDirect and regHitDirect:IsA("RemoteEvent") then
                local callHash = tostring(LocalPlayer.UserId):sub(2, 4) .. tostring(os.clock()):sub(3, 7)
                regHitDirect:FireServer(primaryTarget, hitPartsArray, {}, callHash)
            end

            if ObfuscatedRemote and RemoteId then
                pcall(function()
                    local obfuscatedKey = string.gsub("RE/RegisterHit", ".", function(c)
                        return string.char(bit32.bxor(string.byte(c), math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1))
                    end)
                    local seedVal = 0
                    if netModInstance:FindFirstChild("seed") then
                        seedVal = netModInstance.seed:InvokeServer() * 2
                    end
                    local payloadHash = bit32.bxor(RemoteId + 909090, seedVal)
                    ObfuscatedRemote:FireServer(obfuscatedKey, payloadHash, primaryTarget, hitPartsArray)
                end)
            end
        end

        -- Protocol 4: Tool Native Activation
        if activeTool and typeof(activeTool.Activate) == "function" then
            pcall(function() activeTool:Activate() end)
        end
    end

    local combatHeartbeat = RunService.Heartbeat:Connect(function()
        if Engine.IsRunning and Engine.Enabled then
            pcall(ExecuteFastAttack247)
        end
    end)
    table.insert(Engine.Connections, combatHeartbeat)

    -- ==============================================================================
    -- [AXIOM REALKID HOP KERNEL] DYNAMIC CONFIG DISPATCHER & TRIPLE SENSOR GATE
    -- ==============================================================================
    local function VerifyBossAbsent(patterns)
        for _ = 1, 3 do
            local found, _, _, hum = ScanBossEntity(patterns)
            if found and (not hum or hum.Health > 0) then
                return false
            end
            task.wait(0.25)
        end
        return true
    end

    local function LaunchRealKidHop(destination)
        if getgenv().RealKidHopExecuted or (Engine and Engine.RealKidHopExecuted) then
            return
        end

        local isDough = (destination == "Dough King")
        local targetDest = isDough and POS_LOAF or POS_CASTLE
        local zoneLabel = isDough and "Cake Loaf" or "Castle on the Sea"
        local bossPatterns = isDough and { "Dough King" } or { "rip_indra", "rip_indra True Form" }

        -- [AXIOM MANDATORY PRE-HOP GATE]: Đảm bảo đã tween tới khu vực Boss và xác nhận đến nơi trước khi chạy RealKid Hop
        local arrived = EnsureZoneArrivalBeforeHop(destination, targetDest, zoneLabel, bossPatterns)
        if not arrived or not Engine.IsRunning or not Engine.Enabled then
            return
        end

        -- Quét xác nhận lại lần cuối tại chỗ sau khi đã đến nơi
        if not VerifyBossAbsent(bossPatterns) then
            return
        end

        getgenv().RealKidHopExecuted = true
        if Engine then Engine.RealKidHopExecuted = true end
        if App then
            App.HubLaunched = true
            App.ActiveHopHub = "RealKid Hop"
            App.ActiveHub = "RealKid Hop"
            App.ActiveConfig = destination
        end

        local userId = tostring(LocalPlayer.UserId)
        local fileName = "RealKidHop_" .. userId .. ".json"
        local existingVisited = {
            ["837a8b61-0303-469d-b997-0440a7987f1b"] = true,
            ["b71d64b7-00be-4c8d-b08c-b6a059adeec4"] = true
        }

        pcall(function()
            for _, path in ipairs({ fileName, "workspace/" .. fileName }) do
                if isfile and isfile(path) then
                    local raw = readfile(path)
                    local decoded = raw and HttpService:JSONDecode(raw)
                    if decoded and type(decoded.VisitedJobs) == "table" then
                        for k, v in pairs(decoded.VisitedJobs) do
                            existingVisited[k] = v
                        end
                        break
                    end
                end
            end
        end)

        local configPayload = {
            ["RaceV4Enabled"]       = false,
            ["WeaponCategory"]      = "Melee",
            ["SearchEnabled"]       = true,
            ["AttackEnabled"]       = true,
            ["FruitWebhookEnabled"] = false,
            ["DebugEnabled"]        = false,
            ["GhostFruitEnabled"]   = false,
            ["Destination"]         = destination,
            ["RaidEnabled"]         = false,
            ["GunHeight"]           = 35,
            ["InitialSide"]         = "Marines",
            ["MovementSpeed"]       = 200,
            ["AttackHeight"]        = 30,
            ["BerryEnabled"]        = false,
            ["SearchPause"]         = 5,
            ["StoreEnabled"]        = true,
            ["BossEnabled"]         = true,
            ["AuraEnabled"]         = true,
            ["KenEnabled"]          = false,
            ["WebhookAddress"]      = "",
            ["RaceV3Enabled"]       = false,
            ["WebhookEnabled"]      = false,
            ["PortalEnabled"]       = true,
            ["VisitedJobs"]         = existingVisited,
            ["RandomEnabled"]       = false,
            ["FruitEnabled"]        = false
        }

        local encoded = HttpService:JSONEncode(configPayload)
        pcall(function()
            if writefile then
                writefile(fileName, encoded)
                pcall(writefile, "workspace/" .. fileName, encoded)
            end
        end)

        if Engine and Engine.StatusLabel then
            Engine.StatusLabel.Text = string.format("Trạng thái: 🚀 Đã đến %s! Kích hoạt RealKid Hop [%s]...", zoneLabel, destination)
        end

        task.spawn(function()
            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/RealKidHop.lua"))()
            end)
            if not ok then
                warn("[AXIOM] RealKid Hop Loader execution failed: " .. tostring(err))
            end
        end)
    end

    -- ==============================================================================
    -- [MAIN CONTROLLER THREAD - GETMM] (ĐÃ XÓA CHANGE ACC, XONG MM SẼ SANG PULL LEVER)
    -- ==============================================================================
    local mainThread = task.spawn(function()
        while not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") do
            task.wait(0.1)
        end

        while Engine.IsRunning do
            if not Engine.Enabled then
                Engine.CurrentCombatTarget = nil
                task.wait(0.3)
                continue
            end

            if GetCurrentSeaNum() ~= 3 then
                if Engine.StatusLabel then
                    Engine.StatusLabel.Text = "Trạng thái: 🚀 Đang chuyển về Sea 3..."
                end
                TeleportToSea(3)
                task.wait(2.5)
                continue
            end

            -- [AXIOM SUBMERGE ISLAND MONITOR]
            local charRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if charRoot and (charRoot.Position - POS_SUBMERGE_CENTER).Magnitude <= 2000 then
                EscapeSubmergeIsland()
                task.wait(1.0)
                continue
            end

            -- Quét túi đồ đa tầng
            EnsureBuso()
            local hasFractal = Inventory:HasItem("mirror fractal")
            local hasValkyrie = Inventory:HasItem("valkyrie")

            if Engine.FractalLabel then
                Engine.FractalLabel.Text = "🪞 Mirror Fractal: " .. (hasFractal and "🟢 ĐÃ CÓ" or "🔴 CHƯA CÓ")
                Engine.FractalLabel.TextColor3 = hasFractal and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(255, 100, 100)
            end
            if Engine.ValkyrieLabel then
                Engine.ValkyrieLabel.Text = "🛡️ Valkyrie Helm: " .. (hasValkyrie and "🟢 ĐÃ CÓ" or "🔴 CHƯA CÓ")
                Engine.ValkyrieLabel.TextColor3 = hasValkyrie and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(255, 100, 100)
            end

            local dActive, dModel, dRoot, dHum = ScanBossEntity({ "Dough King" })
            local iActive, iModel, iRoot, iHum = ScanBossEntity({ "rip_indra", "rip_indra True Form" })

            if Engine.DoughStatusLabel then
                Engine.DoughStatusLabel.Text = "🍩 Dough King: " .. (dActive and "🟢 ONLINE" or "🔴 OFFLINE")
                Engine.DoughStatusLabel.TextColor3 = dActive and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(220, 100, 100)
            end
            if Engine.IndraStatusLabel then
                Engine.IndraStatusLabel.Text = "⚔️ rip_indra: " .. (iActive and "🟢 ONLINE" or "🔴 OFFLINE")
                Engine.IndraStatusLabel.TextColor3 = iActive and Color3.fromRGB(80, 255, 140) or Color3.fromRGB(220, 100, 100)
            end

            -- // =========================================================================
            -- // [AXIOM PIPELINE] ƯU TIÊN SỐ 1: VALKYRIE HELM (RIP INDRA)
            -- // =========================================================================
            if not hasValkyrie then
                Engine.MirrorTeleported = false
                if iActive and iModel and iRoot and iHum and iHum.Health > 0 then
                    Engine.CurrentCombatTarget = iModel
                    if Engine.StatusLabel then
                        Engine.StatusLabel.Text = string.format("Trạng thái: ⚔️ Khóa mục tiêu rip_indra [HP: %.0f/%.0f]!", iHum.Health, iHum.MaxHealth)
                    end
                    FlyOverTarget(iRoot)
                else
                    Engine.CurrentCombatTarget = nil
                    local indraPatterns = { "rip_indra", "rip_indra True Form" }

                    -- Bắt buộc Tween đến Castle on the Sea trước 1 lần và xác nhận đã tới
                    local arrivedCastle = EnsureZoneArrivalBeforeHop("Rip Indra", POS_CASTLE, "Castle on the Sea", indraPatterns)
                    if arrivedCastle then
                        -- Sau khi đã đến Castle on the Sea, quét xác nhận Boss thực sự không có rồi mới Hop
                        if VerifyBossAbsent(indraPatterns) then
                            if not getgenv().RealKidHopExecuted then
                                LaunchRealKidHop("Rip Indra")
                            elseif not Engine.IsHopping then
                                Engine:HopToTargetBoss("Rip Indra")
                            end
                        end
                    end
                end

            -- // =========================================================================
            -- // [AXIOM PIPELINE] ƯU TIÊN SỐ 2: MIRROR FRACTAL (DOUGH KING)
            -- // =========================================================================
            elseif not hasFractal then
                if dActive and dModel and dRoot and dHum and dHum.Health > 0 then
                    local char = LocalPlayer.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")

                    if hrp then
                        local distToLoaf = (hrp.Position - POS_LOAF).Magnitude

                        -- Xử lý quy trình gương Loaf nếu chưa tele qua phòng
                        if distToLoaf > 500 and not Engine.MirrorTeleported then
                            if Engine.StatusLabel then
                                Engine.StatusLabel.Text = string.format("Trạng thái: 🍩 Phát hiện Dough King! Bay tới Loaf (Cách: %.0f)...", distToLoaf)
                            end
                            TweenToPosition(POS_LOAF, CONFIG.TweenSpeed)
                        elseif not Engine.MirrorTeleported then
                            ExecuteLoafMirrorSequence()
                        else
                            Engine.CurrentCombatTarget = dModel
                            if Engine.StatusLabel then
                                Engine.StatusLabel.Text = string.format("Trạng thái: 🍩 Khóa mục tiêu Dough King [HP: %.0f/%.0f]!", dHum.Health, dHum.MaxHealth)
                            end
                            FlyOverTarget(dRoot)
                        end
                    end
                else
                    Engine.CurrentCombatTarget = nil
                    Engine.MirrorTeleported = false
                    local doughPatterns = { "Dough King" }

                    -- Bắt buộc Tween đến Cake Loaf trước 1 lần và xác nhận đã tới
                    local arrivedLoaf = EnsureZoneArrivalBeforeHop("Dough King", POS_LOAF, "Cake Loaf", doughPatterns)
                    if arrivedLoaf then
                        -- Sau khi đã đến Cake Loaf, quét xác nhận Boss thực sự không có rồi mới Hop
                        if VerifyBossAbsent(doughPatterns) then
                            if not getgenv().RealKidHopExecuted then
                                LaunchRealKidHop("Dough King")
                            elseif not Engine.IsHopping then
                                Engine:HopToTargetBoss("Dough King")
                            end
                        end
                    end
                end

            -- // =========================================================================
            -- // [AXIOM PIPELINE] 3. ĐÃ ĐỦ CẢ 2 VẬT PHẨM -> DỪNG GETMM, CHUYỂN SANG GẠT CẦN
            -- // =========================================================================
            else
                Engine.CurrentCombatTarget = nil
                Engine.Enabled = false
                if Engine.CurrentTween then
                    pcall(function() Engine.CurrentTween:Cancel() end)
                    Engine.CurrentTween = nil
                end
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp:FindFirstChild("__AxiomStabilizer") then
                    pcall(function() hrp.__AxiomStabilizer:Destroy() end)
                end
                if Engine.StatusLabel then
                    Engine.StatusLabel.Text = "Trạng thái: 👑 ĐÃ CÓ ĐỦ MIRROR FRACTAL & VALKYRIE HELM! Chuyển sang đi gạt cần (Pull Lever)..."
                end
            end

            task.wait(0.15)
        end
    end)
    table.insert(Engine.Threads, mainThread)

    function Engine:Unload()
        self.IsRunning = false
        self.Enabled = false
        self.IsHopping = false
        self.CurrentCombatTarget = nil
        self.MirrorTeleported = false
        self.HasArrivedAtCastle = false
        self.HasArrivedAtLoaf = false

        if self.CurrentTween then
            pcall(function() self.CurrentTween:Cancel() end)
        end

        local char = LocalPlayer.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("__AxiomStabilizer") then
                hrp.__AxiomStabilizer:Destroy()
            end
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end

        for _, c in ipairs(self.Connections) do
            if c and typeof(c) == "RBXScriptConnection" then
                pcall(function() c:Disconnect() end)
            end
        end

        for _, t in ipairs(self.Threads) do
            if t and coroutine.status(t) ~= "dead" then
                pcall(task.cancel, t)
            end
        end

        for _, inst in ipairs(self.Instances) do
            pcall(function() inst:Destroy() end)
        end

        getgenv()._AxiomBossFarm = nil
    end
end

local function ProcessRealKidSea3()
    if not IsSea3() then
        TravelToSea3("Cần qua Sea 3 để kiểm tra Temple Door & Kéo cần")
        return
    end

    -- 1. ĐÃ MỞ CỬA ĐỀN / KÉO CẦN XONG -> ĐỔI ACC NGAY LẬP TỨC
    if CheckLeverPulled() then
        App.IsPullingLever = true
        if MM_Engine then MM_Engine.Enabled = false end
        warn("[AXIOM V4] >>> CHECK TEMPLE DOOR = TRUE: ĐÃ KÉO CẦN XONG! ĐỔI ACC NGAY LẬP TỨC! <<<")
        App.CurrentActivity = "🔒 [Hoàn tất V4] Đã mở Temple Door! Đang chuyển tài khoản tiếp theo..."
        if App.UI and App.UI.lblStatus then
            App.UI.lblStatus.Text = "Trạng thái: 🔒 Đã mở Temple Door! Đang chuyển tài khoản..."
        end
        ExecuteChangeAccount("Kéo cần thành công (Instant Switch)")
        return
    end

    -- 2. KIỂM TRA CÓ ĐỦ MIRROR FRACTAL & VALKYRIE HELM TRƯỚC KHI ĐI GẠT CẦN
    local hasValkyrie = (MM_Inventory and MM_Inventory:HasItem("valkyrie")) == true
    local hasFractal = (MM_Inventory and MM_Inventory:HasItem("mirror fractal")) == true

    if not (hasValkyrie and hasFractal) then
        -- Chưa đủ Mirror Fractal & Valkyrie Helm -> Mở khóa Hop để GetMM chạy 100% cơ chế săn Boss
        App.IsPullingLever = false
        if MM_Engine and not MM_Engine.Enabled then
            MM_Engine.Enabled = true
            local missingItems = (not hasValkyrie and not hasFractal) and "Valkyrie Helm & Mirror Fractal"
                or (not hasValkyrie and "Valkyrie Helm" or "Mirror Fractal")
            App.CurrentActivity = string.format("🛡️🪞 [Get MM] Thiếu %s -> Chạy Auto Farm Valkyrie & Mirror trước khi gạt cần...", missingItems)
        end
        return
    end

    -- Đã có đủ Mirror Fractal & Valkyrie Helm -> Tắt GetMM Engine và dọn Stabilizer nếu còn
    if MM_Engine and MM_Engine.Enabled then
        MM_Engine.Enabled = false
        MM_Engine.CurrentCombatTarget = nil
        if MM_Engine.CurrentTween then
            pcall(function() MM_Engine.CurrentTween:Cancel() end)
            MM_Engine.CurrentTween = nil
        end
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("__AxiomStabilizer") then
            pcall(function() hrp.__AxiomStabilizer:Destroy() end)
        end
    end

    -- Nếu trong server này vừa bật RealKidHop để săn Boss thì Hop sang server sạch trước khi bật RealKid Main gạt cần
    if getgenv().RealKidHopExecuted or App.ActiveHub == "RealKid Hop" or App.ActiveHopHub == "RealKid Hop" then
        App.IsPullingLever = false
        App.CurrentActivity = "🔄 [Get MM -> Pull Lever] Đã đủ Mirror & Valkyrie! Hop sang server sạch để chạy RealKid Main gạt cần..."
        if TriggerLowServerHop then
            TriggerLowServerHop(true)
        end
        task.wait(3)
        return
    end

    -- Khóa cứng trạng thái pull lever: Tuyệt đối không hop với bất kì giá nào cả
    App.IsPullingLever = true

    -- 3. ĐỦ ĐIỀU KIỆN KÉO CẦN (ĐÃ CÓ MIRROR & VALK): CHẠY DUY NHẤT REALKID MAIN VỚI AutoPullLever = true
    App.CurrentActivity = "🕹️ [Sea 3] Đã đủ Mirror & Valkyrie! Khởi chạy RealKid Main với AutoPullLever = true..."
    SyncRealKidConfig({
        ["AutoPullLever"] = true,
        ["AutoFindMirageIsland"] = false,
        ["AutoLookAtMoon"] = false,
        ["AutoCollectGear"] = false
    })

    if not (App.ActiveMainHub == "RealKid Main" or getgenv().RealKidLoaded or getgenv().realkid or getgenv().RealKidHub) then
        App.HubLaunched = true
        App.ActiveMainHub = "RealKid Main"
        App.ActiveHub = "RealKid Main"
        App.ActiveConfig = "PullLever"

        task.spawn(function()
            local safeDebug = debug or getgenv().debug or (getrenv and getrenv().debug) or {}
            if type(safeDebug) ~= "table" then safeDebug = {} end
            if not safeDebug.getinfo then safeDebug.getinfo = function() return {} end end
            if not safeDebug.traceback then safeDebug.traceback = function(...) return tostring(...) end end
            getgenv().debug = safeDebug
            pcall(function()
                if getfenv then
                    getfenv(0).debug = safeDebug
                    getfenv(1).debug = safeDebug
                end
            end)

            local ok, err = pcall(function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua"))()
            end)
            if not ok then
                warn("[AXIOM HUB] RealKid Main Load Error: " .. tostring(err))
            else
                warn("[AXIOM HUB] RealKid Main loaded successfully.")
                App.CurrentActivity = "🕹️ [RealKid Main] Đang tự động kéo cần (AutoPullLever = true)..."
            end
        end)
    end
end

-- // MASTER KAITUN STATE MACHINE
-- // =============================================================================
-- // [AXIOM ZERO-DELAY ACCOUNT SWITCH ENGINE]
-- // Quét liên tục mỗi 0.1s: Ngay khi phát hiện ĐÃ KÉO CẦN (CheckTempleDoor == true) -> ĐỔI ACC TỨC THÌ
-- // =============================================================================
task.spawn(function()
    while App.Running do
        task.wait(0.1)
        pcall(function()
            if not App.IsChangingAccount then
                local leverDone = CheckLeverPulled and CheckLeverPulled()
                if leverDone then
                    warn("[AXIOM FAST-SWITCH] ⚡ >>> PHÁT HIỆN ĐÃ MỞ CỬA ĐỀN / KÉO CẦN! ĐỔI ACC NGAY LẬP TỨC! <<<")
                    App.CurrentActivity = "⚡ [Hoàn tất V4] Đã mở Temple Door! Đổi tài khoản ngay..."
                    if App.UI and App.UI.lblStatus then
                        App.UI.lblStatus.Text = "Trạng thái: ⚡ Đã mở Temple Door! Đang chuyển tài khoản..."
                    end
                    if typeof(getgenv().Config) == "table" and getgenv().Config.AutoChangeAccount == false then
                        return
                    end
                    ExecuteChangeAccount("Instant Switch: Lever Pulled")
                end
            end
        end)
    end
end)

-- // ==============================================================================
-- // AXIOM UNIFIED CO-OP V3 ENGINE (SKYPIEA & GHOUL) - REBUILT FROM SCRATCH
-- // Features:
-- // 1. Auto-discover non-V3 accounts of the same race (plus V3 helpers if needed)
-- // 2. Deterministic election: 1 UpRace (killer) + N HelpRace (sacrifice)
-- // 3. Auto Server Sync: Join common low-player Sea 2 server via __ServerBrowser
-- // 4. Auto Rendezvous at COOP_SACRIFICE_POS (-389.69, 40.99, 31.59)
-- // 5. Reference Combat: Wenlocktoad "1"->"2"->"3", EnablePvp, Buso,
-- //    EquipWeaponByTip("Melee") Z/X/C + EquipWeaponByTip("Sword") Z/X
-- //    with CFrame.lookAt(targetRoot.Position + Vector3.new(0, 4, 4), targetRoot.Position)
-- // ==============================================================================
local VirtualInputManager = cloneref(game:GetService("VirtualInputManager"))

local CoopTweenState = {
    CurrentTween = nil
}

local function StopCoopTween()
    if CoopTweenState.CurrentTween then
        pcall(function() CoopTweenState.CurrentTween:Cancel() end)
        CoopTweenState.CurrentTween = nil
    end
    if State and State.ActiveTween then
        pcall(function() State.ActiveTween:Cancel() end)
        State.ActiveTween = nil
    end
end

local function TweenToCoopCFrame(targetCFrame)
    if not (App and App.Running) then return end
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    root.Anchored = false
    if GetStabilizer then
        GetStabilizer(root).Velocity = Vector3.zero
    end

    local dist = (root.Position - targetCFrame.Position).Magnitude
    if dist <= 15 then
        StopCoopTween()
        root.CFrame = targetCFrame
        return
    end

    StopCoopTween()
    local speed = 300
    local info = TweenInfo.new(math.max(dist / speed, 0.05), Enum.EasingStyle.Linear)
    CoopTweenState.CurrentTween = TweenService:Create(root, info, {CFrame = targetCFrame})
    CoopTweenState.CurrentTween:Play()
end

local function TweenToPosition(targetPos)
    local targetCF = (typeof(targetPos) == "CFrame") and targetPos or CFrame.new(targetPos)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    root.Anchored = false
    local dist = (root.Position - targetCF.Position).Magnitude
    if dist <= 15 then
        StopCoopTween()
        root.CFrame = targetCF
        return
    end

    if typeof(DirectLinearFlight) == "function" and dist > 60 then
        DirectLinearFlight(targetCF)
    else
        TweenToCoopCFrame(targetCF)
    end
end

local function EquipWeaponByTip(toolTip)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not char or not hum or hum.Health <= 0 then return false end

    local currentTool = char:FindFirstChildOfClass("Tool")
    if currentTool and currentTool.ToolTip == toolTip then
        return true
    end

    local bp = LocalPlayer:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            if tool:IsA("Tool") and tool.ToolTip == toolTip then
                hum:EquipTool(tool)
                return true
            end
        end
    end
    return false
end

local function CastSkillKey(keyCode, holdTime)
    if not (App and App.Running) then return end
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(holdTime or 0.1)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    end)
end

local function EnsurePvP()
    pcall(function()
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        local mainGui = pGui and pGui:FindFirstChild("Main")
        local pvpDisabled = mainGui and mainGui:FindFirstChild("PvpDisabled")
        if pvpDisabled and pvpDisabled.Visible then
            CommF:InvokeServer("EnablePvp")
        end
    end)
end

local function EnsureCoopBuso()
    pcall(function()
        local char = LocalPlayer.Character
        if char and not char:FindFirstChild("HasBuso") then
            CommF:InvokeServer("Buso")
        end
    end)
end

local function SpamMeleeAndSwordSkills(targetRoot)
    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot or not targetRoot then return end

    EnsureCoopBuso()

    -- Combo Melee: Z, X, C
    if EquipWeaponByTip("Melee") then
        for _, key in ipairs({Enum.KeyCode.Z, Enum.KeyCode.X, Enum.KeyCode.C}) do
            if not (App and App.Running) or not targetRoot.Parent then return end
            local tHum = targetRoot.Parent:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Health <= 0 then return end
            TweenToCoopCFrame(CFrame.lookAt(targetRoot.Position + Vector3.new(0, 4, 4), targetRoot.Position))
            CastSkillKey(key, 0.12)
            task.wait(0.08)
        end
    end

    -- Combo Sword: Z, X
    if EquipWeaponByTip("Sword") then
        for _, key in ipairs({Enum.KeyCode.Z, Enum.KeyCode.X}) do
            if not (App and App.Running) or not targetRoot.Parent then return end
            local tHum = targetRoot.Parent:FindFirstChildOfClass("Humanoid")
            if not tHum or tHum.Health <= 0 then return end
            TweenToCoopCFrame(CFrame.lookAt(targetRoot.Position + Vector3.new(0, 4, 4), targetRoot.Position))
            CastSkillKey(key, 0.12)
            task.wait(0.08)
        end
    end
end

local function SafeJoinJobId(targetJobId)
    local cleanJob = string.gsub(tostring(targetJobId or ""), "%s+", "")
    if cleanJob == "" or cleanJob == tostring(game.JobId) then return end
    warn("[AXIOM COOP] Joining Peer JobId: " .. cleanJob)
    pcall(function()
        local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
        if browser then
            browser:InvokeServer("teleport", cleanJob)
        end
    end)
    task.wait(0.6)
    pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, cleanJob, LocalPlayer)
    end)
end

local function Notify(msg)
    warn("[AXIOM NOTIFY] " .. tostring(msg))
    pcall(function()
        local starterGui = cloneref(game:GetService("StarterGui"))
        starterGui:SetCore("SendNotification", {
            Title = "Axiom Kaitun",
            Text = tostring(msg),
            Duration = 3
        })
    end)
end

local function IsInCursedShip(): boolean
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return false end
    if CURSED_SHIP_INTERIOR_POS then
        return (root.Position - CURSED_SHIP_INTERIOR_POS).Magnitude <= 3000
    end
    return false
end

-- // DETERMINISTIC CO-OP ELECTION & SESSION LEDGER
EvaluateCoopRoles = function()
    local myName = tostring(LocalPlayer.Name)
    local myGroup = NormalizeCoopRaceGroup(App and App.TargetRace or TARGET_RACE or "")
    local curGroup = NormalizeCoopRaceGroup(GetCurrentRace and GetCurrentRace() or "")

    if not IsCoopSupportedRace(myGroup) then
        App.CoopRole = "none"
        App.CoopEnable = false
        return
    end

    local hasV2 = (App and App.HasV2Confirmed == true) or (CheckRaceV2 and CheckRaceV2() == true) or false
    local hasV3 = (App and App.HasV3Confirmed == true) or (CheckCyborgV3 and CheckCyborgV3() == true) or false
    local now = os.time()

    local sessions = ReadJsonSafe(COOP_SESSION_FILE, {})

    -- Prune stale entries older than COOP_HEARTBEAT_TTL
    for name, info in pairs(sessions) do
        if type(info) == "table" then
            local hb = tonumber(info.Heartbeat or info.UpdatedAt or 0)
            if (now - hb) > COOP_HEARTBEAT_TTL then
                sessions[name] = nil
            end
        else
            sessions[name] = nil
        end
    end

    -- Update our raw telemetry first if we are on the right race and have V2
    local eligible = (curGroup == myGroup) and hasV2
    if not eligible then
        App.CoopRole = "none"
        App.CoopEnable = false
        sessions[myName] = {
            Name = myName,
            Role = "none",
            CoopEnable = false,
            TargetRace = myGroup,
            Race = curGroup,
            HasV2 = hasV2,
            HasV3 = hasV3,
            Sea = IsSea2() and "Sea 2" or (GetCurrentSea and GetCurrentSea() or "Unknown"),
            JobId = tostring(game.JobId),
            PlayerCount = #Players:GetPlayers(),
            Heartbeat = now,
            UpdatedAt = now
        }
        WriteJsonSafe(COOP_SESSION_FILE, sessions)
        return
    end

    -- Provisional entry for election
    sessions[myName] = {
        Name = myName,
        Role = App.CoopRole or "none",
        CoopEnable = true,
        TargetRace = myGroup,
        Race = curGroup,
        HasV2 = hasV2,
        HasV3 = hasV3,
        Sea = IsSea2() and "Sea 2" or (GetCurrentSea and GetCurrentSea() or "Unknown"),
        JobId = tostring(game.JobId),
        PlayerCount = #Players:GetPlayers(),
        Heartbeat = now,
        UpdatedAt = now
    }

    -- Collect all non-V3 candidates of the same race group
    local nonV3Names = {}
    local v3HelperNames = {}

    for name, info in pairs(sessions) do
        if type(info) == "table" then
            local hb = tonumber(info.Heartbeat or info.UpdatedAt or 0)
            if (now - hb) <= COOP_HEARTBEAT_TTL then
                local pGroup = NormalizeCoopRaceGroup(info.TargetRace or info.Race or "")
                if pGroup == myGroup and info.HasV2 == true then
                    if info.HasV3 ~= true then
                        table.insert(nonV3Names, tostring(name))
                    else
                        table.insert(v3HelperNames, tostring(name))
                    end
                end
            end
        end
    end

    table.sort(nonV3Names)
    table.sort(v3HelperNames)

    -- Election Rule:
    -- 1. Among all non-V3 accounts of the same race, the first in sorted order is "uprace".
    -- 2. All other non-V3 accounts of the same race become "helprace" (sacrifice).
    -- 3. Once the current "uprace" finishes V3,HasV3 becomes true, and the next non-V3 automatically becomes "uprace"!
    -- 4. If there is only 1 non-V3 account and a V3 account is available, the V3 account becomes "helprace" to assist.
    local electedUpRace = nonV3Names[1]
    local myRole = "none"
    local myCoopEnable = false

    if not hasV3 then
        myCoopEnable = true
        if electedUpRace == myName then
            myRole = "uprace"
        else
            myRole = "helprace"
        end
    else
        -- We already have V3: only stay/return as helprace if there's an active uprace needing a partner
        if electedUpRace ~= nil and #nonV3Names < 2 then
            myRole = "helprace"
            myCoopEnable = true
        else
            myRole = "none"
            myCoopEnable = false
        end
    end

    -- Determine target server JobId (Anchor on the HelpRace in Sea 2, or UpRace in Sea 2)
    local targetPeer = nil
    if myRole == "uprace" then
        -- Find a helprace peer (prefer one already in Sea 2)
        for _, name in ipairs(nonV3Names) do
            if name ~= myName and sessions[name] then
                targetPeer = sessions[name]
                if tostring(targetPeer.Sea):find("Sea 2") then break end
            end
        end
        if not targetPeer then
            for _, name in ipairs(v3HelperNames) do
                if name ~= myName and sessions[name] and sessions[name].CoopEnable == true then
                    targetPeer = sessions[name]
                    if tostring(targetPeer.Sea):find("Sea 2") then break end
                end
            end
        end
    elseif myRole == "helprace" then
        if electedUpRace and electedUpRace ~= myName and sessions[electedUpRace] then
            targetPeer = sessions[electedUpRace]
        end
    end

    App.CoopRole = myRole
    App.CoopEnable = myCoopEnable
    App.CurrentHelperPeer = targetPeer
    App.AssignedHelperName = targetPeer and targetPeer.Name or nil

    sessions[myName].Role = myRole
    sessions[myName].CoopEnable = myCoopEnable
    WriteJsonSafe(COOP_SESSION_FILE, sessions)
end

-- Background heartbeat every 2.5s
task.spawn(function()
    while App.Running do
        pcall(function()
            if LocalPlayer and LocalPlayer:FindFirstChild("Data") then
                local myGroup = NormalizeCoopRaceGroup(App and App.TargetRace or TARGET_RACE or "")
                local curGroup = NormalizeCoopRaceGroup(GetCurrentRace and GetCurrentRace() or "")
                if IsCoopSupportedRace(myGroup) or IsCoopSupportedRace(curGroup) then
                    EvaluateCoopRoles()
                end
            end
        end)
        task.wait(2.5)
    end
end)

-- Find matching combat target in current server for UpRace
local function FindCoopVictimInServer(myGroup, preferredPeerName)
    -- 1. Priority: Assigned peer from session ledger
    if preferredPeerName then
        local p = Players:FindFirstChild(preferredPeerName)
        if p and p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                return p, root, hum
            end
        end
    end

    -- 2. Scan players near COOP_SACRIFICE_POS or matching race
    local bestPlayer, bestRoot, bestHum = nil, nil, nil
    local bestDist = math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local root = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hum.Health > 0 and root then
                local pRace = ""
                pcall(function() pRace = NormalizeCoopRaceGroup(plr.Data.Race.Value) end)
                local distFromHelp = (root.Position - COOP_SACRIFICE_POS).Magnitude

                if myGroup == "skypiea" then
                    -- Skypiea V3 requires killing another Skypiea player
                    if pRace == "skypiea" and distFromHelp < bestDist then
                        bestDist = distFromHelp
                        bestPlayer, bestRoot, bestHum = plr, root, hum
                    end
                elseif myGroup == "ghoul" then
                    -- Ghoul V3 requires killing players (prefer players at sacrifice pos or same race)
                    if (distFromHelp <= 300 or pRace == "ghoul") and distFromHelp < bestDist then
                        bestDist = distFromHelp
                        bestPlayer, bestRoot, bestHum = plr, root, hum
                    end
                end
            end
        end
    end

    return bestPlayer, bestRoot, bestHum
end

-- Main Co-op V3 Step (Executed in Sea 2 when V2 is done and V3 is needed/helping)
ExecuteCoopV3Tick = function()
    EvaluateCoopRoles()

    local myGroup = NormalizeCoopRaceGroup(App.TargetRace or TARGET_RACE or GetCurrentRace())
    if not IsCoopSupportedRace(myGroup) then return false end

    -- Stop RealKid or any external hub if it was running on this server
    if App.HubLaunched and App.ActiveHub and App.ActiveHub ~= "Axiom_Coop_V3" then
        App.CurrentActivity = "🔄 [Coop V3] Ngắt Hub cũ -> Hop Low Server để vào chế độ Coop sạch..."
        TriggerLowServerHop(true)
        task.wait(3)
        return true
    end

    -- Disable FastAttack aura so skill combos register cleanly for V3 quest
    FastAttackRuntime.Active = false
    _G.FastAttack = false
    getgenv().FastAttack = false

    -- If inside Cursed Ship interior, exit first before flying to sacrifice point
    if IsInCursedShip() and GHOST_SHIP_INTERIOR_EXIT_CF then
        App.CurrentActivity = "🚢 [Coop V3] Đang thoát khỏi Cursed Ship để bay tới điểm tập kết..."
        TweenToCoopCFrame(GHOST_SHIP_INTERIOR_EXIT_CF)
        task.wait(0.5)
        return true
    end

    EnsurePirates()
    EnsurePvP()

    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not (char and root and hum and hum.Health > 0) then return true end

    local peer = App.CurrentHelperPeer
    local curJob = tostring(game.JobId)

    -- =========================================================================
    -- ROLE A: HELPRACE (HIẾN MẠNG TẠI -389.69, 40.99, 31.59)
    -- =========================================================================
    if App.CoopRole == "helprace" then
        -- Settle on a < 8 player server once
        if not App.HelpraceServerSettled then
            if #Players:GetPlayers() >= 8 then
                App.CurrentActivity = "🌐 [Coop HelpRace] Server >= 8 người -> Hop tìm server vắng..."
                TriggerLowServerHop(true)
                task.wait(3)
                return true
            end
            App.HelpraceServerSettled = true
        end

        pcall(function() hum:UnequipTools() end)
        root.Anchored = false

        local dist = (root.Position - COOP_SACRIFICE_POS).Magnitude
        if dist > 6 then
            App.CurrentActivity = string.format("🏃 [Coop HelpRace] Đang bay tới điểm hiến mạng (-389.69, 40.99, 31.59) [%dm]...", math.floor(dist))
            TweenToCoopCFrame(CFrame.new(COOP_SACRIFICE_POS))
        else
            StopCoopTween()
            if GetStabilizer then GetStabilizer(root).Velocity = Vector3.zero end
            App.CurrentActivity = string.format("🤝 [Coop HelpRace] Đang đứng hiến mạng tại (-389.69, 40.99, 31.59) cho %s...", tostring(peer and peer.Name or "UpRace"))
        end
        return true
    end

    -- =========================================================================
    -- ROLE B: UPRACE (NHẬN QUEST WENLOCKTOAD -> JOIN HELPRACE -> SPAM SKILL)
    -- =========================================================================
    if App.CoopRole == "uprace" then
        -- 1. Check if our target HelpRace peer is in another Sea 2 server -> Join them!
        local peerInServer = (peer and Players:FindFirstChild(peer.Name))
        if not peerInServer and peer and peer.JobId and peer.JobId ~= "" and peer.JobId ~= curJob and tostring(peer.Sea):find("Sea 2") then
            local nowClock = os.clock()
            App._lastCoopJoinAttempt = App._lastCoopJoinAttempt or 0
            App.CurrentActivity = string.format("🚀 [Coop UpRace] Đang sang server của HelpRace %s (%s)...", tostring(peer.Name), tostring(peer.JobId))
            if (nowClock - App._lastCoopJoinAttempt) >= 5 then
                App._lastCoopJoinAttempt = nowClock
                task.spawn(function() SafeJoinJobId(peer.JobId) end)
            end
            return true
        end

        -- 2. Query NPC Arowe (Wenlocktoad) exactly like reference script
        local progress = nil
        pcall(function()
            progress = CommF:InvokeServer("Wenlocktoad", "1")
        end)

        if progress == -2 then
            App.HasV3Confirmed = true
            StopCoopTween()
            PurgeMyCoopSession()
            Notify("Đã hoàn tất Race V3!")
            return false
        elseif progress == 0 then
            App.CurrentActivity = "📜 [Coop UpRace] Nhận nhiệm vụ V3 tại Wenlocktoad (1 -> 2)..."
            pcall(function() CommF:InvokeServer("Wenlocktoad", "2") end)
            task.wait(0.3)
            return true
        elseif progress == 2 then
            App.CurrentActivity = "🎉 [Coop UpRace] Đã đủ điều kiện trả nhiệm vụ V3! Đang trả Wenlocktoad (3)..."
            pcall(function() CommF:InvokeServer("Wenlocktoad", "3") end)
            StopCoopTween()
            task.wait(0.5)
            if CheckCyborgV3() then
                App.HasV3Confirmed = true
                PurgeMyCoopSession()
                Notify("Đã nâng cấp thành công Race V3!")
                return false
            end
            return true
        end

        -- 3. progress == 1 (Hoặc đang trong tiến trình kill mạng):
        EnsurePvP()

        local victimPlr, victimRoot, victimHum = FindCoopVictimInServer(myGroup, peer and peer.Name or nil)
        if victimPlr and victimRoot and victimHum and victimHum.Health > 0 then
            App.CurrentActivity = string.format("⚔️ [Coop UpRace] Đang xả skill Melee (Z,X,C) & Sword (Z,X) vào %s (HP: %.0f)...", victimPlr.Name, victimHum.Health)
            SpamMeleeAndSwordSkills(victimRoot)
            -- Thử trả quest ngay sau chuỗi combo phòng trường hợp vừa đủ kill (1 kill cho Sky, 5 kills cho Ghoul)
            pcall(function()
                local pCheck = CommF:InvokeServer("Wenlocktoad", "1")
                if pCheck == 2 then
                    CommF:InvokeServer("Wenlocktoad", "3")
                end
            end)
        else
            -- Chưa thấy mục tiêu sống tại điểm hẹn -> Bay về điểm tập kết (-389.69, 40.99, 31.59) chờ
            local dist = (root.Position - COOP_SACRIFICE_POS).Magnitude
            if dist > 10 then
                App.CurrentActivity = string.format("🏃 [Coop UpRace] Đang bay tới điểm tập kết (-389.69, 40.99, 31.59) [%dm]...", math.floor(dist))
                TweenToCoopCFrame(CFrame.new(COOP_SACRIFICE_POS))
            else
                StopCoopTween()
                App.CurrentActivity = "⏳ [Coop UpRace] Đang đợi HelpRace tại điểm tập kết (-389.69, 40.99, 31.59)..."
            end
        end

        if CheckCyborgV3() then
            App.HasV3Confirmed = true
            StopCoopTween()
            PurgeMyCoopSession()
            return false
        end

        return true
    end

    return false
end

masterKaitunThread = task.spawn(function()
    while App.Running do
        local ok, err = pcall(function()
            local activeRaceCheck = App.TargetRace or TARGET_RACE
            if not activeRaceCheck or activeRaceCheck == "" then
                App.CurrentActivity = "ko có race được set, vui lòng chỉnh race trong script"
                task.wait(1)
                return
            end

            local targetName = tostring(App.TargetRace or TARGET_RACE or ""):match("^%s*(.-)%s*$")
            local cleanTarget = CleanRaceStr(targetName)

            if App.IsHopping then return end
            if SyncDualTargetRace then SyncDualTargetRace() end

            EnsureMarines()

            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not (char and hrp and hum and hum.Health > 0) then
                task.wait(0.2)
                return
            end

            if not App.InitialV2Checked then
                App.CurrentActivity = "Sẵn sàng điều phối tác vụ"
                task.wait(0.3)
                return
            end

            local frags = GetFragments()
            local beli = GetBeli()
            local isTarget = IsTargetRace()
            local initialFrag = App.InitialFragChecked and App.InitialFragValue or frags
            local leverDone = CheckLeverPulled()
            local hasV3 = isTarget and CheckCyborgV3()
            local isCoopRace = IsCoopSupportedRace(cleanTarget)

            -- 1. HOÀN TẤT TOÀN BỘ (Đúng tộc + V3 + Kéo cần) -> Đổi acc
            if leverDone or (isTarget and hasV3 and leverDone) then
                App.ActiveHub = nil
                App.HubLaunched = false
                local targetFolder = (typeof(getgenv().Config) == "table" and typeof(getgenv().Config.ChangeAccountConfig) == "table" and getgenv().Config.ChangeAccountConfig.FolderName) or "thue 1"
                App.CurrentActivity = string.format("🔒 ĐÃ HOÀN TẤT: Tộc %s + V3 + Pull Lever! Đang đổi Account [%s]...", targetName, tostring(targetFolder))

                if typeof(getgenv().Config) == "table" and getgenv().Config.AutoChangeAccount == false then
                    App.CurrentActivity = string.format("🎉 ĐÃ HOÀN TẤT: Tộc %s + V3 + Pull Lever (AutoChangeAccount = false)", targetName)
                    return
                end

                ExecuteChangeAccount(targetName or LocalPlayer.Name)
                return
            end

            -- 2. ĐÃ CÓ TỘC MỤC TIÊU & ĐÃ XONG V3 -> LÀM TIẾP V4 / KÉO CẦN
            if isTarget and hasV3 then
                if isCoopRace then
                    EvaluateCoopRoles()
                    if App.CoopRole == "helprace" and App.CoopEnable == true then
                        if not IsSea2() then
                            TravelToSea2("Acc V3 quay về Sea 2 làm HelpRace hỗ trợ đồng đội lên V3")
                            return
                        end
                        ExecuteCoopV3Tick()
                        return
                    end
                end

                if PurgeMyCoopSession then PurgeMyCoopSession() end

                if not IsSea3() then
                    TravelToSea3(string.format("Đã hoàn tất V3 tộc %s -> Sang Sea 3 làm tiếp Race V4 (Kéo cần)", targetName))
                    return
                end

                if frags < 13000 then
                    ProcessFragmentFarmCakeQueen()
                else
                    if not leverDone then
                        ProcessRealKidSea3()
                    else
                        ExecuteChangeAccount(targetName or LocalPlayer.Name)
                    end
                end
                return
            end

            -- 3. CHƯA CÓ V3 CỦA TỘC MỤC TIÊU
            -- Nhánh 3A: 4 Tộc thường (Human, Mink, Fishman, Skypiea)
            if cleanTarget == "human" or cleanTarget == "mink" or cleanTarget == "rabbit" or cleanTarget == "fishman" or cleanTarget == "shark" or cleanTarget == "skypiea" or cleanTarget == "sky" or cleanTarget == "angel" or cleanTarget:find("human") or cleanTarget:find("mink") then
                if not isTarget then
                    if not IsSea3() then
                        TravelToSea3(string.format("Chưa có tộc %s -> Sang Sea 3 farm 13k Frag để roll tộc", targetName))
                        return
                    end
                    if frags < 13000 then
                        ProcessFragmentFarmCakeQueen()
                    else
                        RerollRace()
                    end
                    return
                else
                    -- Chưa đủ tài nguyên (Beli < 2.5m HOẶC Frag < 13k) -> BẮT BUỘC sang Sea 3 cày Cake Prince
                    if not CanTeleportToSea2ForUprace() then
                        if not IsSea3() then
                            TravelToSea3(string.format("Đã có tộc %s nhưng chưa đủ tài nguyên uprace (Frag: %d/13k, Beli: %d/2.5m) -> Sang Sea 3 cày Cake Prince", targetName, frags, beli))
                            return
                        end
                        ProcessFragmentFarmCakeQueen()
                        return
                    else
                        if not IsSea2() then
                            TravelToSea2(string.format("Đã có tộc %s & đủ tài nguyên (Frag >= 13k, Beli >= 2.5m) -> Về Sea 2 làm V2-V3", targetName))
                            return
                        end

                        if isCoopRace and CheckRaceV2() and not CheckCyborgV3() then
                            ExecuteCoopV3Tick()
                            return
                        end

                        ProcessRealKidSea2()
                        pcall(function() ExecuteRaceV3TurnIn() end)
                        return
                    end
                end

            -- Nhánh 3B: Tộc Ghoul
            elseif cleanTarget == "ghoul" then
                if not isTarget then
                    if frags < 13000 then
                        if not IsSea3() then
                            TravelToSea3("Chưa có tộc Ghoul và thiếu Frag -> Sang Sea 3 cày Cake Prince")
                            return
                        end
                        ProcessFragmentFarmCakeQueen()
                        return
                    else
                        if not IsSea2() then
                            TravelToSea2("Đủ tài nguyên lấy Ghoul -> Về Sea 2 lấy tộc Ghoul")
                            return
                        end
                        if not App.HubLaunched or (App.ActiveHub ~= "RealKid Hub" and App.ActiveHub ~= "RealKid" and App.ActiveHub ~= "RealKid Main" and App.ActiveMainHub ~= "RealKid Main") then
                            LaunchGhoulRealKid()
                        end
                    end
                else
                    if App.HubLaunched and (App.ActiveHub == "NightHub_Ghoul" or App.ActiveHub == "RealKid_Ghoul" or App.ActiveConfig == "GhoulV1") then
                        App.CurrentActivity = "🎉 [Ghoul] Đã nhận được tộc Ghoul! Hop Low Server..."
                        TriggerLowServerHop(true)
                        return
                    end

                    -- [AXIOM FIX CHO GHOUL]: Chưa đủ 2.5m Beli hoặc chưa đủ 13k Frag -> LẬP TỨC qua Sea 3 cày Cake Queen!
                    if not CanTeleportToSea2ForUprace() then
                        if not IsSea3() then
                            TravelToSea3(string.format("Đã có Ghoul nhưng thiếu tài nguyên (Frag: %d/13k, Beli: %d/2.5m) -> Sang Sea 3 cày Cake Queen/Prince", frags, beli))
                            return
                        end
                        ProcessFragmentFarmCakeQueen()
                        return
                    else
                        if not IsSea2() then
                            TravelToSea2("Đã là tộc Ghoul & đủ tài nguyên (Frag >= 13k, Beli >= 2.5m) -> Sang Sea 2 nâng cấp V2 và V3")
                            return
                        end

                        if CheckRaceV2() and not CheckCyborgV3() then
                            ExecuteCoopV3Tick()
                            return
                        end

                        ProcessRealKidSea2()
                        pcall(function() ExecuteRaceV3TurnIn() end)
                        return
                    end
                end

            -- Nhánh 3C: Tộc Cyborg
            else
                if not isTarget then
                    if frags < 13000 then
                        if not IsSea3() then
                            TravelToSea3("Chưa có Cyborg và thiếu Frag -> Sang Sea 3 cày Cake Prince")
                            return
                        end
                        ProcessFragmentFarmCakeQueen()
                    else
                        if not IsSea2() then
                            TravelToSea2("Đủ tài nguyên mua Cyborg -> Sang Sea 2 lấy tộc")
                            return
                        end
                        if not App.HubLaunched or (App.ActiveHub ~= "RealKid Hub" and App.ActiveHub ~= "RealKid" and App.ActiveHub ~= "RealKid Main" and App.ActiveMainHub ~= "RealKid Main") then
                            LaunchCyborgRealKid()
                        end
                    end
                else
                    -- [AXIOM FIX CHO CYBORG]: Chưa đủ 2.5m Beli hoặc chưa đủ 13k Frag -> Bắt buộc về Sea 3 farm!
                    if not CanTeleportToSea2ForUprace() then
                        if not IsSea3() then
                            TravelToSea3(string.format("Đã là Cyborg nhưng thiếu tài nguyên (Frag: %d/13k, Beli: %d/2.5m) -> Sang Sea 3 cày Cake Queen/Prince", frags, beli))
                            return
                        end
                        ProcessFragmentFarmCakeQueen()
                        return
                    else
                        if not IsSea2() then
                            TravelToSea2("Đã là tộc Cyborg & đủ tài nguyên (Frag >= 13k, Beli >= 2.5m) -> Sang Sea 2 nâng cấp V2 và V3")
                            return
                        end
                        ProcessRealKidSea2()
                        pcall(function() ExecuteRaceV3TurnIn() end)
                    end
                end
            end
        end)

        if not ok and err then
            warn("[AXIOM STATE MACHINE ERROR] " .. tostring(err))
            App.CurrentActivity = "⚠️ Lỗi: " .. tostring(err)
        end

        task.wait(0.25)
    end
end)

table.insert(App.Threads, masterKaitunThread)

-- // =============================================================================
-- // [AXIOM PASSIVE CHEST TOUCH DETECTOR & 30-CHEST LOW HOP RADAR]
-- // RealKid tự nhặt chest -> Bộ lắng nghe thụ động đếm số chest chạm -> Đủ 30 chest tự Hop Low
-- // =============================================================================
App.ChestCount = 0
local countedChests = {}

local function RegisterChestTouch(chestInst)
    if not chestInst then return end
    local rootChest = chestInst:FindFirstAncestorOfClass("Model") or chestInst
    if not countedChests[rootChest] then
        countedChests[rootChest] = true
        App.ChestCount = (App.ChestCount or 0) + 1
        warn(string.format("[AXIOM CHEST TRACKER] 📦 RealKid nhặt Chest #%d/30 (%s)", App.ChestCount, tostring(rootChest.Name)))
        if App.UI and App.UI.lblChest then
            App.UI.lblChest.Text = string.format("📦 Chest đã chạm: %d/30", App.ChestCount)
        end
        local _targetRaceForChest = string.lower(tostring(App.TargetRace or TARGET_RACE or "")):gsub("%s+", "")
    if _targetRaceForChest == "cyborg" and App.ChestCount >= 30 then
        App.CurrentActivity = "📦 [Chest Limit] Đã chạm đủ 30 chest (Cyborg) -> Kích hoạt Hop Low Server..."
        warn("[AXIOM CHEST TRACKER] 30 chests reached for Cyborg! Triggering Low Server Hop...")
        if TriggerLowServerHop then
            TriggerLowServerHop(true)
        end
    end
    end
end

local function HookCharForChests(char)
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Touched:Connect(function(hit)
                if hit and (hit.Name:lower():find("chest") or (hit.Parent and hit.Parent.Name:lower():find("chest")) or CollectionService:HasTag(hit, "_ChestTagged") or (hit.Parent and CollectionService:HasTag(hit.Parent, "_ChestTagged"))) then
                    RegisterChestTouch(hit)
                end
            end)
        end
    end
end

pcall(function() HookCharForChests(LocalPlayer.Character) end)
LocalPlayer.CharacterAdded:Connect(function(newChar)
    task.wait(0.5)
    pcall(function() HookCharForChests(newChar) end)
end)

-- Proximity fallback quét bán kính 12 studs quanh nhân vật
task.spawn(function()
    while App.Running do
        task.wait(0.3)
        pcall(function()
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local myPos = hrp.Position
                for _, chest in ipairs(CollectionService:GetTagged("_ChestTagged")) do
                    if chest:IsA("BasePart") or chest:IsA("Model") then
                        local cPos = chest:IsA("Model") and chest:GetPivot().Position or chest.Position
                        if (myPos - cPos).Magnitude <= 12 then
                            RegisterChestTouch(chest)
                        end
                    end
                end
            end
        end)
    end
end)

-- // AXIOM CYBER TELEMETRY RADAR UI (CDK STYLE)
local function PurgeExistingUI()

    for _, path in ipairs({typeof(gethui) == "function" and gethui(), CoreGui, LocalPlayer:FindFirstChild("PlayerGui")}) do
        pcall(function()

            if path and path:FindFirstChild("AxiomKaitunDashboardUI") then
                path.AxiomKaitunDashboardUI:Destroy()
            end
        end)
    end
end

PurgeExistingUI()

local screenGui = Instance.new("ScreenGui")

screenGui.Name = "AxiomKaitunDashboardUI"

screenGui.ResetOnSpawn = false

screenGui.DisplayOrder = 999999999

screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

screenGui.IgnoreGuiInset = true

local function MountUI(gui)
    local target = (typeof(gethui) == "function" and gethui()) or CoreGui or LocalPlayer:FindFirstChild("PlayerGui")

    if target then pcall(function() gui.Parent = target end) end
end

MountUI(screenGui)

table.insert(App.Instances, screenGui)

local mainCard = Instance.new("Frame", screenGui)

mainCard.Name = "MainCard"

mainCard.AnchorPoint = Vector2.new(0.5, 0)

mainCard.Position = UDim2.new(0.5, 0, 0.04, 0)

mainCard.Size = UDim2.new(0, 440, 0, 485)

mainCard.BackgroundColor3 = Color3.fromRGB(13, 17, 24)

mainCard.BackgroundTransparency = 0.04

mainCard.BorderSizePixel = 0

Instance.new("UICorner", mainCard).CornerRadius = UDim.new(0, 10)

local stroke = Instance.new("UIStroke", mainCard)

stroke.Color = Color3.fromRGB(0, 200, 255)

stroke.Thickness = 1.6

local title = Instance.new("TextLabel", mainCard)

title.Size = UDim2.new(0, 270, 0, 26)

title.Position = UDim2.new(0, 12, 0, 6)

title.BackgroundTransparency = 1

local initFolderTag = (typeof(getgenv().Config) == "table" and typeof(getgenv().Config.ChangeAccountConfig) == "table" and getgenv().Config.ChangeAccountConfig.FolderName) or "thue 1"

title.Text = "AXIOM // KAITUN [" .. string.upper(tostring(initFolderTag)) .. "]"

title.TextColor3 = Color3.fromRGB(0, 220, 255)

title.Font = Enum.Font.SourceSansBold

title.TextSize = 13

title.TextXAlignment = Enum.TextXAlignment.Left

local timerBadge = Instance.new("TextLabel", mainCard)

timerBadge.Size = UDim2.new(0, 110, 0, 20)

timerBadge.Position = UDim2.new(1, -122, 0, 8)

timerBadge.BackgroundColor3 = Color3.fromRGB(25, 35, 55)

timerBadge.Text = "⏰ 00:00 / 20:00"

timerBadge.TextColor3 = Color3.fromRGB(0, 220, 255)

timerBadge.Font = Enum.Font.SourceSansBold

timerBadge.TextSize = 11

Instance.new("UICorner", timerBadge).CornerRadius = UDim.new(0, 4)

local radarBox = Instance.new("Frame", mainCard)

radarBox.Size = UDim2.new(1, -24, 0, 330)

radarBox.Position = UDim2.new(0, 12, 0, 34)

radarBox.BackgroundColor3 = Color3.fromRGB(20, 26, 38)

Instance.new("UICorner", radarBox).CornerRadius = UDim.new(0, 8)

local function CreateLabel(text, yPos, color, isBold)
    local lbl = Instance.new("TextLabel", radarBox)

    lbl.Size = UDim2.new(1, -16, 0, 17)

    lbl.Position = UDim2.new(0, 8, 0, yPos)

    lbl.BackgroundTransparency = 1

    lbl.Text = text

    lbl.TextColor3 = color or Color3.fromRGB(255, 255, 255)

    lbl.Font = isBold and Enum.Font.SourceSansBold or Enum.Font.SourceSans

    lbl.TextSize = 12

    lbl.TextXAlignment = Enum.TextXAlignment.Left

    return lbl
end

local lblSea     = CreateLabel("📍 Sea: Đang nạp...", 10, Color3.fromRGB(255, 200, 80), true)
local lblRace    = CreateLabel("🧬 Race: Đang nạp...", 34, Color3.fromRGB(0, 255, 180), true)
local lblFrag    = CreateLabel("🟣 Frag: Đang nạp...", 58, Color3.fromRGB(180, 120, 255), true)
local lblBeli    = CreateLabel("💰 Beli: Đang nạp...", 82, Color3.fromRGB(0, 255, 170), true)
local lblLever   = CreateLabel("🕹️ Temple Lever: Đang kiểm tra...", 106, Color3.fromRGB(255, 150, 50), true)
local lblFolder     = CreateLabel("📂 Target Folder: " .. tostring((typeof(getgenv().Config) == "table" and typeof(getgenv().Config.ChangeAccountConfig) == "table" and getgenv().Config.ChangeAccountConfig.FolderName) or "thue 1"), 130, Color3.fromRGB(255, 220, 100), true)
local lblActiveMain = CreateLabel("⚙️ Active Main: [NONE]", 152, Color3.fromRGB(255, 255, 100), true)
local lblActiveHop  = CreateLabel("🌐 Active Hop:  [NONE]", 174, Color3.fromRGB(255, 255, 100), true)
local lblMelee      = CreateLabel("🥋 Melee hiện tại: Đang nạp...", 196, Color3.fromRGB(255, 120, 200), true)
local lblMirage     = CreateLabel("🏝️ Mirage: Đang quét...", 218, Color3.fromRGB(0, 255, 255), true)
local lblChest      = CreateLabel("📦 Chest đã chạm: 0/30", 240, Color3.fromRGB(255, 215, 0), true)
local lblStatus = Instance.new("TextLabel", radarBox)

lblStatus.Size = UDim2.new(1, -16, 0, 95)

lblStatus.Position = UDim2.new(0, 8, 0, 226)

lblStatus.BackgroundTransparency = 1

lblStatus.Text = "Trạng thái: ⏳ Hệ thống Kaitun đã kích hoạt..."

lblStatus.TextColor3 = Color3.fromRGB(0, 200, 255)

lblStatus.Font = Enum.Font.SourceSansBold

lblStatus.TextSize = 12

lblStatus.TextWrapped = true

lblStatus.TextXAlignment = Enum.TextXAlignment.Left

lblStatus.TextYAlignment = Enum.TextYAlignment.Top

App.UI = {
    ScreenGui = screenGui,
    MainCard = mainCard,
    lblSea = lblSea,
    lblRace = lblRace,
    lblFrag = lblFrag,
    lblBeli = lblBeli,
    lblLever = lblLever,
    lblFolder = lblFolder,
    lblActive = lblActiveMain,
    lblActiveMain = lblActiveMain,
    lblActiveHop = lblActiveHop,
    lblMelee = lblMelee,
    lblMirage = lblMirage,
    lblChest = lblChest,
    lblStatus = lblStatus
}

local btnWenlock3 = Instance.new("TextButton", mainCard)

btnWenlock3.Size = UDim2.new(1, -24, 0, 30)

btnWenlock3.Position = UDim2.new(0, 12, 0, 370)

btnWenlock3.BackgroundColor3 = Color3.fromRGB(0, 160, 100)

btnWenlock3.Text = "⚡ NẠP NHIỆM VỤ V3 (WENLOCKTOAD 3)"

btnWenlock3.TextColor3 = Color3.fromRGB(255, 255, 255)

btnWenlock3.Font = Enum.Font.SourceSansBold

btnWenlock3.TextSize = 12

Instance.new("UICorner", btnWenlock3).CornerRadius = UDim.new(0, 6)

btnWenlock3.MouseButton1Click:Connect(function()

    pcall(function()

        local commF = ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("CommF_")

        commF:InvokeServer("Wenlocktoad", "3")

        commF:InvokeServer("Wenlocktoad", 3)

        Notify("Đã kích hoạt Remote Wenlocktoad 3 nạp V3!")
    end)
end)

local btnHopLowServer = Instance.new("TextButton", mainCard)

btnHopLowServer.Size = UDim2.new(1, -24, 0, 30)

btnHopLowServer.Position = UDim2.new(0, 12, 0, 404)

btnHopLowServer.BackgroundColor3 = Color3.fromRGB(30, 100, 180)

btnHopLowServer.Text = "🌐 HOP LOW SERVER (≤ 8 PLAYERS)"

btnHopLowServer.TextColor3 = Color3.fromRGB(255, 255, 255)

btnHopLowServer.Font = Enum.Font.SourceSansBold

btnHopLowServer.TextSize = 12

Instance.new("UICorner", btnHopLowServer).CornerRadius = UDim.new(0, 6)

btnHopLowServer.MouseButton1Click:Connect(function()

    App.CurrentActivity = "🌐 [User] Kích hoạt Hop Low Server..."

    TriggerLowServerHop(true)
end)

local btnUnload = Instance.new("TextButton", mainCard)

btnUnload.Size = UDim2.new(1, -24, 0, 28)

btnUnload.Position = UDim2.new(0, 12, 0, 438)

btnUnload.BackgroundColor3 = Color3.fromRGB(170, 40, 40)

btnUnload.Text = "DỪNG & UNLOAD SCRIPT AXIOM"

btnUnload.TextColor3 = Color3.fromRGB(255, 255, 255)

btnUnload.Font = Enum.Font.SourceSansBold

btnUnload.TextSize = 12

Instance.new("UICorner", btnUnload).CornerRadius = UDim.new(0, 6)

local function EnableDrag(frame, handle)

    handle = handle or frame

    local UIS = cloneref(game:GetService("UserInputService"))
    local dragging, mousePos, framePos

    handle.InputBegan:Connect(function(input)

        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true

            mousePos = input.Position

            framePos = frame.Position

            input.Changed:Connect(function()

                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    local dragConn = UIS.InputChanged:Connect(function(input)

        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - mousePos

            frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
        end
    end)

    table.insert(App.Connections, dragConn)
end

pcall(function()

    EnableDrag(mainCard, title)
end)

local serverJoinTime = os.clock()

serverJoinEpoch = os.time()

timerThread = task.spawn(function()

    while App.Running do
        local elapsed = os.clock() - serverJoinTime
        local m, s = math.floor(elapsed / 60), math.floor(elapsed % 60)

        timerBadge.Text = string.format("⏰ %02d:%02d / 20:00", m, s)

        if elapsed >= 1200  then
            App.CurrentActivity = "⏰ Đã kết nối 20 phút! Tự động Hop Low Server..."

            TriggerLowServerHop(true)

            break
        end

        task.wait(1)
    end
end)

table.insert(App.Threads, timerThread)

telemetryThread = task.spawn(function()

    while App.Running do
        pcall(function()

            local v2Status = false

            pcall(function() v2Status = CheckRaceV2() end)

            local v3Status = false

            pcall(function() v3Status = CheckCyborgV3() end)

            local curSea = "Sea ?"

            pcall(function() curSea = GetCurrentSea() end)

            local curRace = "Unknown"

            pcall(function() curRace = GetCurrentRace() end)

            local curFrags = 0

            pcall(function() curFrags = GetFragments() end)

            local curBeli = 0

            pcall(function() curBeli = GetBeli() end)

            local leverState = false

            pcall(function() leverState = CheckLeverPulled() end)

            local curMelee = "None"

            pcall(function()

                local char = LocalPlayer.Character

                if char then
                    for _, t in ipairs(char:GetChildren()) do
                        if t:IsA("Tool") and t.ToolTip == "Melee" then
                            curMelee = t.Name

                            break
                        end
                    end
                end

                if curMelee == "None" then
                    local bp = LocalPlayer:FindFirstChild("Backpack")

                    if bp then
                        for _, t in ipairs(bp:GetChildren()) do
                            if t:IsA("Tool") and t.ToolTip == "Melee" then
                                curMelee = t.Name

                                break
                            end
                        end
                    end
                end
            end)

            local targetKey = CleanRaceStr(App.TargetRace or TARGET_RACE)
            local curKey = CleanRaceStr(curRace)
            local isFish = (targetKey == "fishman" or targetKey == "shark" or curKey == "fishman" or curKey == "shark")
            local activeCheckRace = App.TargetRace or TARGET_RACE

            lblSea.Text = "📍 " .. tostring(curSea)

            if not activeCheckRace or activeCheckRace == "" then
                lblRace.Text = "🧬 Race: " .. tostring(curRace) .. " (Mục tiêu: ❌ CHƯA SET)"
                lblRace.TextColor3 = Color3.fromRGB(255, 75, 75)
            else
                lblRace.Text = string.format("🧬 Race: %s %s %s (Mục tiêu: %s)", tostring(curRace), v2Status and "[V2 ✅]" or "[Chưa V2 ❌]", v3Status and "[V3 ✅]" or "[Chưa V3 ❌]", tostring(activeCheckRace))
                lblRace.TextColor3 = Color3.fromRGB(0, 255, 180)
            end

            lblFrag.Text = string.format("🟣 Frag: %s (Lần đầu: %s)", tostring(curFrags), tostring(App.InitialFragValue))
            lblBeli.Text = "💰 Beli: " .. tostring(curBeli)
            lblLever.Text = leverState and "🕹️ Temple Lever: Status: ✅" or "🕹️ Temple Lever: Status: ❌"
            lblLever.TextColor3 = leverState and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(255, 120, 80)

            local currentFolderName = (typeof(getgenv().Config) == "table" and typeof(getgenv().Config.ChangeAccountConfig) == "table" and getgenv().Config.ChangeAccountConfig.FolderName) or "thue 1"
            if lblFolder then
                lblFolder.Text = "📂 Target Folder: " .. string.upper(tostring(currentFolderName))
                lblFolder.TextColor3 = (currentFolderName == "thue 2") and Color3.fromRGB(80, 220, 255) or Color3.fromRGB(255, 200, 80)
            end

            local mainHubText = tostring(App.ActiveMainHub or (App.ActiveHub and not App.ActiveHub:find("Hop") and App.ActiveHub) or "NONE (Sẵn sàng)")
            if mainHubText == "RealKid Hub" or mainHubText == "RealKid" then
                mainHubText = "RealKid Main"
            end
            lblActiveMain.Text = "⚙️ Active Main: " .. mainHubText
            if App.ActiveMainHub and App.ActiveMainHub ~= "NONE (Sẵn sàng)" and App.ActiveMainHub ~= "NONE" then
                lblActiveMain.TextColor3 = Color3.fromRGB(0, 255, 180)
            else
                lblActiveMain.TextColor3 = Color3.fromRGB(255, 255, 100)
            end

            local hopHubText = tostring(App.ActiveHopHub or (App.ActiveHub and App.ActiveHub:find("Hop") and App.ActiveHub) or "NONE (Sẵn sàng)")
            lblActiveHop.Text = "🌐 Active Hop:  " .. hopHubText
            if App.ActiveHopHub and App.ActiveHopHub ~= "NONE (Sẵn sàng)" and App.ActiveHopHub ~= "NONE" then
                lblActiveHop.TextColor3 = Color3.fromRGB(0, 255, 180)
            else
                lblActiveHop.TextColor3 = Color3.fromRGB(255, 255, 100)
            end

            local currentY = 196

            if isFish then
                lblMelee.Visible = true
                lblMelee.Text = "🥋 Melee hiện tại: " .. tostring(curMelee)
                lblMelee.Position = UDim2.new(0, 8, 0, currentY)
                currentY = currentY + 22
            else
                lblMelee.Visible = false
            end

            lblMirage.Position = UDim2.new(0, 8, 0, currentY)
            currentY = currentY + 22

            lblStatus.Position = UDim2.new(0, 8, 0, currentY)
            local remainingHeight = math.max(50, 330 - currentY - 6)
            lblStatus.Size = UDim2.new(1, -16, 0, remainingHeight)

            if not activeCheckRace or activeCheckRace == "" then
                lblStatus.Text = "Trạng thái: ⚠️ ko có race được set, vui lòng chỉnh race trong script"
                lblStatus.TextColor3 = Color3.fromRGB(255, 60, 60)
            else
                lblStatus.Text = "Trạng thái: " .. tostring(App.CurrentActivity or "")
                lblStatus.TextColor3 = Color3.fromRGB(0, 200, 255)
            end

            -- // AXIOM RADAR: SEA 3 MIRAGE ISLAND TELEMETRY & DISTANCE TRACKER
            pcall(function()

                local isSea3Now = (game.PlaceId == 7449423635 or game.PlaceId == 100117331123089)

                if isSea3Now then
                    local map = workspace:FindFirstChild("Map")
                    local locations = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
                    local mirage = (map and map:FindFirstChild("MysticIsland"))

                        or (locations and locations:FindFirstChild("MysticIsland"))

                        or workspace:FindFirstChild("MysticIsland")

                    local myChar = LocalPlayer.Character
                    local hrp = myChar and myChar:FindFirstChild("HumanoidRootPart")

                    if mirage then
                        _G.AxiomMirageSeen = true

                        local miragePos = nil

                        if mirage:IsA("Model") then
                            miragePos = mirage:GetPivot().Position
                        elseif mirage:IsA("BasePart") then
                            miragePos = mirage.Position
                        else
                            local anyPart = mirage:FindFirstChildWhichIsA("BasePart", true)

                            if anyPart then miragePos = anyPart.Position end
                        end

                        if miragePos and hrp then
                            local dist = math.floor((hrp.Position - miragePos).Magnitude)

                            lblMirage.Text = "🏝️ Mirage: Có mặt (" .. tostring(dist) .. " studs)"

                            lblMirage.TextColor3 = Color3.fromRGB(0, 255, 127)
                        else
                            lblMirage.Text = "🏝️ Mirage: Có mặt (Đang định vị...)"

                            lblMirage.TextColor3 = Color3.fromRGB(0, 255, 127)
                        end
                    else
                        if _G.AxiomMirageSeen then
                            lblMirage.Text = "🏝️ Mirage: Đã biến mất"

                            lblMirage.TextColor3 = Color3.fromRGB(255, 85, 85)
                        else
                            lblMirage.Text = "🏝️ Mirage: Chưa xuất hiện"

                            lblMirage.TextColor3 = Color3.fromRGB(180, 180, 180)
                        end
                    end
                else
                    lblMirage.Text = "🏝️ Mirage: Chỉ quét tại Sea 3"

                    lblMirage.TextColor3 = Color3.fromRGB(150, 150, 150)
                end
            end)
        end)

        task.wait(0.5)
    end
end)

table.insert(App.Threads, telemetryThread)

-- // UNLOAD PROTOCOL
function App:Unload()

    self.Running = false

    self.IsHopping = false

    if TerminateAll then
        pcall(TerminateAll)
    end

    pcall(function()

        local container = workspace:FindFirstChild("AxiomCyborgPresence")
        local myNode = container and container:FindFirstChild(LocalPlayer.Name)

        if myNode then myNode:Destroy() end

        local hContainer = workspace:FindFirstChild("AxiomHumanV3Presence")
        local hNode = hContainer and hContainer:FindFirstChild(LocalPlayer.Name)

        if hNode then hNode:Destroy() end

        if isfile and readfile and writefile and HttpService then
            local hSessionFile = "Axiom_Sea2_HumanV3_Sessions.json"

            if isfile(hSessionFile) then
                local ok, data = pcall(function() return HttpService:JSONDecode(readfile(hSessionFile)) end)

                if ok and type(data) == "table" and data[LocalPlayer.Name] then
                    data[LocalPlayer.Name] = nil

                    writefile(hSessionFile, HttpService:JSONEncode(data))
                end
            end
        end

        local cFolder = workspace:FindFirstChild("AxiomCoopPresence")
        local coopNode = cFolder and cFolder:FindFirstChild(LocalPlayer.Name)

        if coopNode then coopNode:Destroy() end

        if isfile and readfile and writefile and HttpService then
            local sessionFile = "Axiom_Coop_Sessions.json"

            if isfile(sessionFile) then
                local ok, data = pcall(function() return HttpService:JSONDecode(readfile(sessionFile)) end)

                if ok and type(data) == "table" and data[LocalPlayer.Name] then
                    data[LocalPlayer.Name] = nil

                    writefile(sessionFile, HttpService:JSONEncode(data))
                end
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

    pcall(function()

        local cGui = cloneref(game:GetService("CoreGui"))
        local lp = Players.LocalPlayer

        for _, path in ipairs({typeof(gethui) == "function" and gethui(), cGui, lp and lp:FindFirstChild("PlayerGui")}) do
            if path and path:FindFirstChild("AxiomKaitunDashboardUI") then
                path.AxiomKaitunDashboardUI:Destroy()
            end
        end
    end)

    getgenv().AxiomKaitunSuite = nil
end

btnUnload.MouseButton1Click:Connect(function()

    App:Unload()
end)

local function IsInCursedShip(pos)
    local p = pos
    if not p then
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then p = root.Position end
    end
    if not p then return false end
    return (p.Z > 30000) or (p.Y > 500 and p.Z > 28000)
end

game:BindToClose(function()
    pcall(UnregisterCyborgSession)
end)
