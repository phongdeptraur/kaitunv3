-- // ==============================================================================
-- // KAITUN 6 V4 FULL GEAR ENGINE (COMPACT EDITION)
-- // Sequential: cyborg -> ghoul -> fishman -> skypiea -> mink -> human
-- // ==============================================================================

-- [1] CONFIG: ĐIỀN TÊN 3 ACC SUPPORT (KÈM RACE KHÓA) & DANH SÁCH ACC CLONE
local SUPPORT_ACCOUNTS = {
    ["XxScarlettCodexX2020"] = "cyborg",
    ["pxqmvtrka"]            = "ghoul",
    ["FayeMaraz38"]          = "fishman",
}

local CLONE_ACCOUNTS = {
    "ChaosPrismNinja27",
    "CarterSlime200867",
    "ChillPrimal201611",
}

-- Thứ tự 6 tộc và tên file log tương ứng trong folder 6V4Progress
local RACE_ORDER = { "cyborg", "ghoul", "fishman", "skypiea", "mink", "human" }
local STAGE_LOG_NAMES = {
    [1] = "1race-cyborg.txt",
    [2] = "2race-cyborgghoul.txt",
    [3] = "3race-cyborgghoulfish.txt",
    [4] = "4race-cyborgghoulfishskypiea.txt",
    [5] = "5race-cyborgghoulfishskypieamink.txt",
    [6] = "6race-cyborgghoulfishskypieaminkhuman.txt",
}

local V3_PULL_URLS = {
    ["human"]   = "https://raw.githubusercontent.com/phongdeptraur/kaitunv3/refs/heads/main/autohumanv3pull",
    ["cyborg"]  = "https://raw.githubusercontent.com/phongdeptraur/kaitunv3/refs/heads/main/kaituncyv3pull",
    ["fishman"] = "https://raw.githubusercontent.com/phongdeptraur/kaitunv3/refs/heads/main/kaitunfishV3pull",
    ["ghoul"]   = "https://raw.githubusercontent.com/phongdeptraur/kaitunv3/refs/heads/main/kaitunghoulv3pull",
    ["mink"]    = "https://raw.githubusercontent.com/phongdeptraur/kaitunv3/refs/heads/main/kaitunminkV3pull",
    ["skypiea"] = "https://raw.githubusercontent.com/phongdeptraur/kaitunv3/refs/heads/main/kaitunskypieav3pull",
}

local RACE_DOORS = {
    ["mink"]    = CFrame.new(29020.66015625, 14889.426757812, -379.2682800293),
    ["fishman"] = CFrame.new(28224.056640625, 14889.426757812, -210.58720397949),
    ["cyborg"]  = CFrame.new(28492.4140625, 14894.426757812, -422.11001586914),
    ["skypiea"] = CFrame.new(28967.408203125, 14918.075195312, 234.31198120117),
    ["ghoul"]   = CFrame.new(28672.720703125, 14889.127929688, 454.59616088867),
    ["human"]   = CFrame.new(29237.294921875, 14889.426757812, -206.94955444336),
}

local TEMPLE_POS       = Vector3.new(28294, 14896, 103)
local GREAT_TREE_TOP   = CFrame.new(3028.83, 2281.17, -7324.77)
local GREAT_TREE_IDLE  = CFrame.new(2262.59, 21.69, -6462.95)
local TWEEN_SPEED      = 190
local FOLDER           = "6V4Progress"
local STATE_FILE       = FOLDER .. "/state.json"
local MOON_FILE        = FOLDER .. "/moon_servers.json"
local BLACKLIST_FILE   = FOLDER .. "/blacklist.json"
local TRAIN_TTL_FILE   = FOLDER .. "/train_ttl.json"
local DOOR_SYNC_FILE   = FOLDER .. "/door_sync.json"

-- // ==============================================================================
-- // SERVICES & INITIALIZATION
-- // ==============================================================================
repeat task.wait() until game:IsLoaded()
local Players             = game:GetService("Players")
local ReplicatedStorage   = game:GetService("ReplicatedStorage")
local TeleportService     = game:GetService("TeleportService")
local TweenService        = game:GetService("TweenService")
local RunService          = game:GetService("RunService")
local HttpService         = game:GetService("HttpService")
local Lighting            = game:GetService("Lighting")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser         = game:GetService("VirtualUser")
local LocalPlayer         = Players.LocalPlayer or Players.PlayerAdded:Wait()
local myName              = tostring(LocalPlayer.Name)
local joinTimestamp       = os.time()

if getgenv().Kaitun6V4 then pcall(function() getgenv().Kaitun6V4.Running = false end) end
if isfolder and makefolder and not isfolder(FOLDER) then pcall(makefolder, FOLDER) end

local App = {
    Running = true,
    Role = SUPPORT_ACCOUNTS[myName] and "Support" or "Clone",
    Status = "Init...",
    TrialStatus = "Checking...",
    RawTrialCode = "?",
    IsTrained = false,
    HubRunning = false, -- true khi V3Pull hoặc RealKid Main đang chạy (CẤM TWEEN)
    ActiveTween = nil,
    LastNotif = "",
    TrialStartingAt = 0,
    AllTrialsCompletedAt = 0,
    InTrial = false,
    IsHopping = false,
}
getgenv().Kaitun6V4 = App
MousePos = Vector3.zero

-- Auto chọn phe Marines
task.spawn(function()
    for _ = 1, 15 do
        if LocalPlayer.Team and LocalPlayer.Team.Name ~= "" and LocalPlayer.Team.Name ~= "Neutral" then break end
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("SetTeam", "Marines") end)
        task.wait(0.5)
    end
end)

-- // ==============================================================================
-- // FILE & IPC HELPERS (FOLDER 6V4Progress)
-- // ==============================================================================
local function ReadJSON(path)
    if isfile and readfile and isfile(path) then
        local ok, data = pcall(function() return HttpService:JSONDecode(readfile(path)) end)
        if ok and type(data) == "table" then return data end
    end
    return {}
end

local function WriteJSON(path, tbl)
    if writefile then pcall(function() writefile(path, HttpService:JSONEncode(tbl)) end) end
end

local function CleanRace(r)
    local s = tostring(r or ""):lower():match("^%s*(.-)%s*$")
    if s == "rabbit" then return "mink" end
    if s == "shark" then return "fishman" end
    if s == "angel" or s == "sky" then return "skypiea" end
    return s
end

local function GetMyRace()
    local d = LocalPlayer:FindFirstChild("Data")
    return d and d:FindFirstChild("Race") and tostring(d.Race.Value) or "Unknown"
end

local function GetV4Tier()
    local t = 0
    pcall(function()
        local r = LocalPlayer.Data.Race
        t = tonumber((r:FindFirstChild("C") and r.C.Value) or (r:FindFirstChild("Tier") and r.Tier.Value) or 0) or 0
    end)
    return t
end

local function IsSea3()
    return game.PlaceId == 7449423635 or game.PlaceId == 100117331123089
end

local function TravelSea3()
    if not IsSea3() then
        App.Status = "Traveling to Sea 3..."
        pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("TravelZou") end)
        return false
    end
    return true
end

-- // ==============================================================================
-- // CHECK V3, LEVER, TRAIN & FULL GEAR
-- // ==============================================================================
local function HasV3()
    local skills = { "energy core", "water body", "heavenly blood", "agility", "last resort", "heightened senses" }
    for _, container in ipairs({ LocalPlayer.Character, LocalPlayer:FindFirstChild("Backpack") }) do
        if container then
            for _, item in ipairs(container:GetChildren()) do
                for _, sk in ipairs(skills) do
                    if item.Name:lower():find(sk, 1, true) then return true end
                end
            end
        end
    end
    local ok, res = pcall(function() return ReplicatedStorage.Remotes.CommF_:InvokeServer("Wenlocktoad", "1") end)
    return ok and tonumber(res) == -2
end

local function HasPulledLever()
    local ok, res = pcall(function() return ReplicatedStorage.Remotes.CommF_:InvokeServer("CheckTempleDoor") end)
    return ok and (res == true or res == 1 or tostring(res) == "true")
end

local function CheckTrain()
    local ok, res = pcall(function()
        return ReplicatedStorage.Remotes.CommF_:InvokeServer("UpgradeRace", "Check")
    end)
    if not ok then
        App.RawTrialCode = "Err"
        App.TrialStatus = "Check Err: " .. tostring(res)
        App.IsTrained = false
        return false
    end
    if res == 0 or res == "0" or res == nil or res == "nil" then
        App.RawTrialCode = 0
        App.IsTrained = true
        App.TrialStatus = "Ready for trial [" .. tostring(res or "nil") .. "]"
    else
        App.RawTrialCode = res
        App.IsTrained = false
        App.TrialStatus = "Need Training [" .. tostring(res) .. "]"
    end
    return App.IsTrained
end

local function IsCurrentRaceFullGear(targetRace)
    if targetRace and CleanRace(GetMyRace()) ~= CleanRace(targetRace) then return false end
    CheckTrain()
    local tier = GetV4Tier()
    local raw = App.RawTrialCode
    if tier >= 6 or tostring(raw) == "5" then return true end
    if tier >= 5 and not App.IsTrained then return true end
    local ok, clk = pcall(function() return ReplicatedStorage.Remotes.CommF_:InvokeServer("TempleClock", "Check") end)
    if ok and type(clk) == "table" and not clk.HadPoint and clk.RaceDetails then
        local a = tonumber(clk.RaceDetails.A) or 0
        local b = tonumber(clk.RaceDetails.B) or 0
        if tier >= 5 and (a + b >= 4) then return true end
    end
    return false
end

-- // ==============================================================================
-- // CHECK FULL MOON & NEAR FULL MOON (< 5 PHÚT TRƯỚC KHI TỐI)
-- // ==============================================================================
local function CheckMoonStatus()
    local sky = Lighting:FindFirstChildOfClass("Sky") or Lighting:FindFirstChild("Sky")
    local tex = sky and tostring(sky.MoonTextureId) or ""
    local isFMTexture = (tex:find("9709149431") ~= nil) or (Lighting:GetAttribute("FullMoon") == true)
    if not isFMTexture then return "None", false, false end

    local clk = Lighting.ClockTime
    local isNight = (clk >= 18 or clk < 5.5)
    if isNight then
        return "FullMoon", true, true -- (statusName, isValidMoon, isOfficialNightFM)
    end
    -- Trời sáng: tính thời gian còn lại tới 18h tối (1 giờ game = 50s thực tế; 5 phút = 300s = 6 giờ game)
    local secToNight = (18 - clk) * 50
    if secToNight > 0 and secToNight <= 300 then
        return "NearFullMoon", true, false
    end
    -- > 5 phút nữa mới tối mà đang hiện moon => moon đã qua
    return "PastMoon", false, false
end

-- // ==============================================================================
-- // CONTINUOUS PLAYERGUI NOTIFICATION MONITOR
-- // ==============================================================================
local seenElements = {}
task.spawn(function()
    while App.Running do
        task.wait(0.1)
        local pGui = LocalPlayer:FindFirstChild("PlayerGui")
        if pGui then
            local notifFolder = pGui:FindFirstChild("Notifications") or pGui
            for _, d in ipairs(notifFolder:GetDescendants()) do
                if (d:IsA("TextLabel") or d:IsA("TextButton")) and d.Text and d.Text ~= "" then
                    if seenElements[d] ~= d.Text then
                        seenElements[d] = d.Text
                        local cleanText = d.Text:gsub("<[^>]->", "")
                        App.LastNotif = cleanText
                        print(string.format("[%s] [NOTIF]: %s", os.date("%X"), cleanText))
                        local lower = cleanText:lower()
                        if lower:find("trials starting in") then
                            App.TrialStartingAt = os.clock()
                        elseif lower:find("all trials have been completed") then
                            App.AllTrialsCompletedAt = os.clock()
                        end
                    end
                end
            end
        end
    end
end)

-- // ==============================================================================
-- // AUTO BUY GEAR OMEGA/ALPHA BẤT KỲ MỖI 5S
-- // ==============================================================================
task.spawn(function()
    while App.Running do
        task.wait(5)
        pcall(function()
            if App.HubRunning or App.Role == "Support" then return end
            local commF = ReplicatedStorage.Remotes.CommF_
            local check = commF:InvokeServer("TempleClock", "Check")
            if check and check.HadPoint then
                local raceDetails = check.RaceDetails or { A = 0, B = 0 }
                local tot = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Temple of Time")
                if tot and tot:FindFirstChild("Prompt") and tot.Prompt:FindFirstChild("ProximityPrompt") then
                    if not App.HubRunning then _tp(tot.Prompt.CFrame) end
                    fireproximityprompt(tot.Prompt.ProximityPrompt)
                end
                task.wait(0.2)
                if tot and tot:FindFirstChild("InnerClock") then
                    for _, v12 in next, tot.InnerClock:GetChildren() do
                        if v12:FindFirstChild("Highlight") and v12.Highlight.Enabled then
                            if v12.Name == "Gear4" then
                                if (raceDetails.A or 0) <= 2 then
                                    commF:InvokeServer("TempleClock", "SpendPoint", v12.Name, "Alpha")
                                elseif (raceDetails.B or 0) == 2 then
                                    commF:InvokeServer("TempleClock", "SpendPoint", v12.Name, "Omega")
                                end
                            else
                                commF:InvokeServer("TempleClock", "SpendPoint", v12.Name, math.random(0, 1) == 1 and "Alpha" or "Omega")
                            end
                        end
                    end
                end
                CheckTrain()
            else
                local pGui = LocalPlayer:FindFirstChild("PlayerGui")
                local tGui = pGui and pGui:FindFirstChild("TempleGui")
                if tGui and tGui:FindFirstChild("Skip") and tGui.Skip:FindFirstChild("TextButton") and getconnections then
                    for _, v13 in next, getconnections(tGui.Skip.TextButton.Activated) do
                        v13.Function()
                    end
                end
            end
        end)
    end
end)

-- // ==============================================================================
-- // SERVER HOP LOW ENGINE + 10-MINUTE BLACKLIST
-- // ==============================================================================
local function GetCleanBlacklist()
    local bl = ReadJSON(BLACKLIST_FILE)
    local now = os.time()
    local changed = false
    for jid, ts in pairs(bl) do
        if now - (tonumber(ts) or 0) >= 600 then
            bl[jid] = nil
            changed = true
        end
    end
    if changed then WriteJSON(BLACKLIST_FILE, bl) end
    return bl
end

local function BlacklistCurrentServer()
    local bl = GetCleanBlacklist()
    bl[tostring(game.JobId)] = os.time()
    WriteJSON(BLACKLIST_FILE, bl)
end

local function TeleportToJob(JOB_ID)
    if not JOB_ID or JOB_ID == "" or tostring(JOB_ID) == tostring(game.JobId) then return end
    local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")
    if browser then
        pcall(function() browser:InvokeServer("teleport", tostring(JOB_ID)) end)
    end
    task.wait(0.2)
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, tostring(JOB_ID), LocalPlayer) end)
end

local function HopLowServer(blacklistCurrent)
    if App.IsHopping then return end
    App.IsHopping = true
    if blacklistCurrent ~= false then BlacklistCurrentServer() end
    App.Status = "Hopping Low Server (Blacklist 10m)..."

    task.spawn(function()
        local bl = GetCleanBlacklist()
        local list = {}
        local browser = ReplicatedStorage:FindFirstChild("__ServerBrowser")

        if browser then
            local completed, totalPages = 0, 100
            local byJob = {}
            for page = 1, totalPages do
                task.spawn(function()
                    local ok, res = pcall(function() return browser:InvokeServer(page) end)
                    if ok and type(res) == "table" then
                        for jobId, data in pairs(res) do
                            local id = tostring(jobId)
                            local count = (type(data) == "table" and tonumber(data.Count)) or tonumber(data) or 12
                            if id ~= tostring(game.JobId) and not bl[id] and count < 11 then
                                byJob[id] = { id = id, playing = count }
                            end
                        end
                    end
                    completed = completed + 1
                end)
            end
            local start = os.clock()
            repeat task.wait(0.05) until completed >= totalPages or (os.clock() - start) >= 3.5
            for _, item in pairs(byJob) do table.insert(list, item) end
        end

        if #list == 0 then
            local ok, res = pcall(function()
                return game:HttpGet(string.format("https://games.roblox.com/v1/games/%d/servers/Public?sortOrder=Asc&limit=100", game.PlaceId))
            end)
            if ok and res then
                local okJ, data = pcall(function() return HttpService:JSONDecode(res) end)
                if okJ and data and data.data then
                    for _, s in ipairs(data.data) do
                        local id = tostring(s.id)
                        local count = tonumber(s.playing) or 12
                        if id ~= tostring(game.JobId) and not bl[id] and count < (tonumber(s.maxPlayers) or 12) then
                            table.insert(list, { id = id, playing = count })
                        end
                    end
                end
            end
        end

        table.sort(list, function(a, b) return a.playing < b.playing end)
        for _, s in ipairs(list) do
            bl[s.id] = os.time()
            WriteJSON(BLACKLIST_FILE, bl)
            TeleportToJob(s.id)
            task.wait(4)
        end
        App.IsHopping = false
    end)
end

-- // ==============================================================================
-- // TWEEN ENGINE (LOCKED 190 STUD/S) & COMBAT HELPERS (_tp, notween, Useskills, G.Kill)
-- // ==============================================================================
local function SetStabilizer(enable)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local bv = hrp:FindFirstChild("KaitunBV")
    if enable then
        if not bv then
            bv = Instance.new("BodyVelocity")
            bv.Name = "KaitunBV"
            bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            bv.Velocity = Vector3.zero
            bv.Parent = hrp
        end
    else
        if bv then bv:Destroy() end
        hrp.Anchored = false
    end
end

RunService.Stepped:Connect(function()
    if App.HubRunning then return end
    local char = LocalPlayer.Character
    if char and App.ActiveTween then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end
end)

function notween(cf)
    if App.HubRunning then return end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        if App.ActiveTween then pcall(function() App.ActiveTween:Cancel() end) App.ActiveTween = nil end
        hrp.CFrame = typeof(cf) == "CFrame" and cf or CFrame.new(cf)
    end
end

function _tp(targetCF)
    -- TUYỆT ĐỐI CẤM TWEEN KHI V3PULL HOẶC REALKID MAIN ĐANG CHẠY
    if App.HubRunning then
        HopLowServer(false)
        return
    end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cf = typeof(targetCF) == "CFrame" and targetCF or CFrame.new(targetCF)
    local dist = (hrp.Position - cf.Position).Magnitude
    SetStabilizer(true)
    if dist <= 4 then
        if App.ActiveTween then pcall(function() App.ActiveTween:Cancel() end) App.ActiveTween = nil end
        hrp.CFrame = cf
        return
    end
    if App.ActiveTween then pcall(function() App.ActiveTween:Cancel() end) end
    local tw = TweenService:Create(hrp, TweenInfo.new(dist / TWEEN_SPEED, Enum.EasingStyle.Linear), { CFrame = cf })
    App.ActiveTween = tw
    tw:Play()
end

local function EquipToolByTooltip(tip)
    local char = LocalPlayer.Character
    local bp = LocalPlayer:FindFirstChild("Backpack")
    if not char then return nil end
    local cur = char:FindFirstChildOfClass("Tool")
    if cur and cur.ToolTip == tip then return cur end
    if bp then
        for _, t in ipairs(bp:GetChildren()) do
            if t:IsA("Tool") and t.ToolTip == tip then
                local hum = char:FindFirstChildOfClass("Humanoid")
                if hum then hum:EquipTool(t) end
                return t
            end
        end
    end
    return nil
end

function Useskills(weaponType, key)
    pcall(function()
        EquipToolByTooltip(weaponType)
        local char = LocalPlayer.Character
        if char and not char:FindFirstChild("HasBuso") then
            ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso")
        end
        if MousePos and MousePos ~= Vector3.zero and char and char:FindFirstChild("HumanoidRootPart") then
            char.HumanoidRootPart.CFrame = CFrame.new(char.HumanoidRootPart.Position, MousePos)
        end
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode[key], false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode[key], false, game)
    end)
end

-- Fast Attack Engine (Hỗ trợ cả Mob Trial & Player sau Trial)
local ObfRemote, ObfId = nil, nil
pcall(function()
    for _, name in ipairs({ "Util", "Common", "Remotes", "Assets", "FX" }) do
        local folder = ReplicatedStorage:FindFirstChild(name)
        if folder then
            for _, c in ipairs(folder:GetChildren()) do
                if c:IsA("RemoteEvent") and c:GetAttribute("Id") then
                    ObfRemote, ObfId = c, c:GetAttribute("Id")
                end
            end
        end
    end
end)

local function FastAttackTarget(includePlayers)
    pcall(function()
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then return end
        if not char:FindFirstChild("HasBuso") then
            pcall(function() ReplicatedStorage.Remotes.CommF_:InvokeServer("Buso") end)
        end
        EquipToolByTooltip("Melee")

        local hitParts, head = {}, nil
        local folders = { workspace:FindFirstChild("Enemies") }
        if includePlayers then table.insert(folders, workspace:FindFirstChild("Characters")) end

        for _, f in ipairs(folders) do
            if f then
                for _, m in ipairs(f:GetChildren()) do
                    local mr = m:FindFirstChild("HumanoidRootPart")
                    local mh = m:FindFirstChildOfClass("Humanoid")
                    if m ~= char and mr and mh and mh.Health > 0 and (root.Position - mr.Position).Magnitude <= 65 then
                        for _, p in ipairs(m:GetChildren()) do
                            if p:IsA("BasePart") then table.insert(hitParts, { m, p }) end
                        end
                        if not head and m:FindFirstChild("Head") then head = m.Head end
                    end
                end
            end
        end
        if #hitParts == 0 or not head then return end

        local net = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Net")
        if net then
            if net:FindFirstChild("RE/RegisterAttack") then net["RE/RegisterAttack"]:FireServer() end
            local hash = tostring(LocalPlayer.UserId):sub(2, 4) .. tostring(coroutine.running()):sub(11, 15)
            if net:FindFirstChild("RE/RegisterHit") then net["RE/RegisterHit"]:FireServer(head, hitParts, {}, hash) end
            if ObfRemote and ObfId then
                local key = string.gsub("RE/RegisterHit", ".", function(c)
                    return string.char(bit32.bxor(string.byte(c), math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1))
                end)
                local seed = 0
                pcall(function() seed = net.seed:InvokeServer() * 2 end)
                ObfRemote:FireServer(key, bit32.bxor(ObfId + 909090, seed), head, hitParts)
            end
        end
        VirtualUser:CaptureController()
        VirtualUser:Button1Down(Vector2.new(800, 600))
    end)
end

function GetConnectionEnemies(names)
    local enemies = workspace:FindFirstChild("Enemies")
    if not enemies then return nil end
    for _, e in ipairs(enemies:GetChildren()) do
        for _, n in ipairs(names) do
            if e.Name == n or e.Name:find(n, 1, true) then
                local h = e:FindFirstChildOfClass("Humanoid")
                if h and h.Health > 0 and e:FindFirstChild("HumanoidRootPart") then
                    return e
                end
            end
        end
    end
    return nil
end

G = G or {}
function G.Kill(e, active)
    if not active or not e or not e:FindFirstChild("HumanoidRootPart") then return end
    _tp(e.HumanoidRootPart.CFrame * CFrame.new(0, 25, 0))
    FastAttackTarget(false)
end

-- // ==============================================================================
-- // AUTO COMPLETE TRIAL LOGIC (THEO SCRIPT MẪU CỦA USER)
-- // ==============================================================================
local function GetSeaBeastTrial()
    if not (workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("FishmanTrial")) then
        return nil
    end
    local FishmanTrial = workspace:FindFirstChild("_WorldOrigin")
        and workspace._WorldOrigin:FindFirstChild("Locations")
        and workspace._WorldOrigin.Locations:FindFirstChild("Trial of Water")
    if FishmanTrial and workspace:FindFirstChild("SeaBeasts") then
        for _, e in next, workspace.SeaBeasts:GetChildren() do
            if e:FindFirstChild("HumanoidRootPart") and (e.HumanoidRootPart.Position - FishmanTrial.Position).Magnitude <= 1500 then
                if e:FindFirstChild("Health") and e.Health.Value > 0 then
                    return e
                end
            end
        end
    end
    return nil
end

local function IsInsideTrial()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    local locs = workspace:FindFirstChild("_WorldOrigin") and workspace._WorldOrigin:FindFirstChild("Locations")
    if locs then
        for _, loc in ipairs(locs:GetChildren()) do
            if loc.Name:lower():find("trial") and (hrp.Position - loc.Position).Magnitude <= 1500 then
                return true
            end
        end
    end
    local map = workspace:FindFirstChild("Map")
    if map then
        for _, tName in ipairs({ "MinkTrial", "SkyTrial", "CyborgTrial", "FishmanTrial" }) do
            local m = map:FindFirstChild(tName)
            if m then
                local p = m:FindFirstChildWhichIsA("BasePart", true)
                if p and (hrp.Position - p.Position).Magnitude <= 1500 then return true end
            end
        end
    end
    if GetConnectionEnemies({ "Ancient Vampire", "Ancient Zombie" }) then
        return true
    end
    return false
end

local function RunTrialStepForMyRace()
    local race = tostring(LocalPlayer.Data.Race.Value)
    if race == "Mink" then
        if workspace.Map:FindFirstChild("MinkTrial") and workspace.Map.MinkTrial:FindFirstChild("Ceiling") then
            notween(workspace.Map.MinkTrial.Ceiling.CFrame * CFrame.new(0, -20, 0))
        end
    elseif race == "Fishman" then
        local sb = GetSeaBeastTrial()
        if sb then
            _tp(CFrame.new(sb.HumanoidRootPart.Position.X, workspace.Map["WaterBase-Plane"].Position.Y + 300, sb.HumanoidRootPart.Position.Z))
            MousePos = sb.HumanoidRootPart.Position
            Useskills("Melee", "Z")
            Useskills("Melee", "X")
            Useskills("Melee", "C")
            task.wait(0.1)
            Useskills("Sword", "Z")
            Useskills("Sword", "X")
            task.wait(0.1)
            Useskills("Blox Fruit", "Z")
            Useskills("Blox Fruit", "X")
            Useskills("Blox Fruit", "C")
            task.wait(0.1)
            Useskills("Gun", "Z")
            Useskills("Gun", "X")
        end
    elseif race == "Cyborg" then
        if workspace.Map:FindFirstChild("CyborgTrial") and workspace.Map.CyborgTrial:FindFirstChild("Floor") then
            _tp(workspace.Map.CyborgTrial.Floor.CFrame * CFrame.new(0, 500, 0))
        end
    elseif race == "Skypiea" then
        if workspace.Map:FindFirstChild("SkyTrial") and workspace.Map.SkyTrial:FindFirstChild("Model") then
            notween(workspace.Map.SkyTrial.Model.FinishPart.CFrame)
        end
    elseif race == "Human" or race == "Ghoul" then
        local e = GetConnectionEnemies({ "Ancient Vampire", "Ancient Zombie" })
        if e then
            G.Kill(e, true)
        end
    end
end

-- // ==============================================================================
-- // TEMPLE OF TIME NAVIGATION & IDLE ENGINE
-- // ==============================================================================
local function IsInTempleOfTime()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    return hrp and (hrp.Position - TEMPLE_POS).Magnitude <= 4000 or false
end

local function EnterTempleOfTime()
    if App.HubRunning then HopLowServer(false) return false end
    if IsInTempleOfTime() then return true end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    App.Status = "Tweening to Great Tree Top -> Enter Temple..."
    if (hrp.Position - GREAT_TREE_TOP.Position).Magnitude > 15 then
        _tp(GREAT_TREE_TOP)
        return false
    end
    pcall(function()
        ReplicatedStorage.Remotes.CommF_:InvokeServer("requestEntrance", TEMPLE_POS)
    end)
    task.wait(0.8)
    return IsInTempleOfTime()
end

local function IdleAtGreatTree(reason)
    if App.HubRunning then
        HopLowServer(false)
        return
    end
    App.Status = "Idle Great Tree: " .. tostring(reason or "")
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp and (hrp.Position - GREAT_TREE_IDLE.Position).Magnitude > 10 then
        _tp(GREAT_TREE_IDLE)
    end
end

-- // ==============================================================================
-- // EXTERNAL HUB LAUNCHERS (V3 PULL & REALKID MAIN) + 60S TRAIN ANTI-COLLISION
-- // ==============================================================================
local function LaunchV3PullHub(targetRace)
    if App.HubRunning then return end
    local url = V3_PULL_URLS[CleanRace(targetRace)]
    if not url then return end
    if App.ActiveTween then pcall(function() App.ActiveTween:Cancel() end) App.ActiveTween = nil end
    SetStabilizer(false)
    App.HubRunning = true
    App.Status = "Running V3Pull Hub [" .. targetRace .. "]..."
    task.spawn(function()
        pcall(function() loadstring(game:HttpGet(url))() end)
    end)
end

local function CheckTrainCollision60s()
    local sessions = ReadJSON(TRAIN_TTL_FILE)
    local now = os.time()
    for acc, info in pairs(sessions) do
        if type(info) ~= "table" or (now - (tonumber(info.UpdatedAt) or 0) > 60) then
            sessions[acc] = nil
        end
    end
    local myJob = tostring(game.JobId)
    for acc, info in pairs(sessions) do
        if acc ~= myName and info.JobId == myJob then
            local otherJoin = tonumber(info.JoinTime) or 0
            if joinTimestamp > otherJoin or (joinTimestamp == otherJoin and myName > acc) then
                WriteJSON(TRAIN_TTL_FILE, sessions)
                return true -- Bị trùng server train -> phải hop low!
            end
        end
    end
    sessions[myName] = { JobId = myJob, JoinTime = joinTimestamp, UpdatedAt = now }
    WriteJSON(TRAIN_TTL_FILE, sessions)
    return false
end

local function ClearMyTrainSession()
    local sessions = ReadJSON(TRAIN_TTL_FILE)
    if sessions[myName] then
        sessions[myName] = nil
        WriteJSON(TRAIN_TTL_FILE, sessions)
    end
end

local function LaunchRealKidTrainV4()
    if App.HubRunning then return end
    if App.ActiveTween then pcall(function() App.ActiveTween:Cancel() end) App.ActiveTween = nil end
    SetStabilizer(false)
    App.HubRunning = true
    App.Status = "Running RealKid Main [AutoTrainV4]..."
    pcall(function()
        if makefolder then
            for _, f in ipairs({ "RealKidHub", "RealKidHub/save", "RealKidHub/save2", "workspace/RealKidHub", "workspace/RealKidHub/save", "workspace/RealKidHub/save2" }) do
                pcall(makefolder, f)
            end
        end
        local paths = {
            "RealKidHub/save/" .. myName .. ".json",
            "workspace/RealKidHub/save/" .. myName .. ".json",
            "RealKidHub/save2/" .. myName .. ".json",
            "workspace/RealKidHub/save2/" .. myName .. ".json",
        }
        local cfg = {
            ["Initialize"] = true,
            ["selected_team"] = "Marines",
            ["AutoTrainV4"] = true,
            ["AutoPullLever"] = false,
            ["AutoUpgradeRaceV3"] = false,
            ["AutoCompleteTrialRace"] = false,
            ["TweenSpeedV4"] = 190,
            ["AntiAFK"] = true,
            ["BusuAura"] = true,
            ["Bringmob"] = true,
        }
        for _, p in ipairs(paths) do
            if isfile and isfile(p) then
                local ok, dec = pcall(function() return HttpService:JSONDecode(readfile(p)) end)
                if ok and type(dec) == "table" then
                    for k, v in pairs(cfg) do dec[k] = v end
                    cfg = dec
                    break
                end
            end
        end
        local enc = HttpService:JSONEncode(cfg)
        for _, p in ipairs(paths) do pcall(writefile, p, enc) end
    end)
    task.spawn(function()
        pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua"))()
        end)
    end)
end

-- // ==============================================================================
-- // SEQUENTIAL 6-RACE PROGRESS TRACKER (6V4Progress)
-- // ==============================================================================
local function GetCurrentStageAndRace()
    local st = ReadJSON(STATE_FILE)
    st.Completed = st.Completed or {}

    for idx, rName in ipairs(RACE_ORDER) do
        local f1 = FOLDER .. "/" .. STAGE_LOG_NAMES[idx]
        local f2 = FOLDER .. "/" .. idx .. "racedone.txt"
        st.Completed[rName] = st.Completed[rName] or {}

        local allClonesDone = true
        for _, cName in ipairs(CLONE_ACCOUNTS) do
            if not st.Completed[rName][cName] then
                allClonesDone = false
                break
            end
        end

        if allClonesDone and #CLONE_ACCOUNTS > 0 then
            if writefile then
                if not (isfile and isfile(f1)) then pcall(writefile, f1, "Done: " .. rName .. " at " .. os.date("%c")) end
                if not (isfile and isfile(f2)) then pcall(writefile, f2, "Done: " .. rName .. " at " .. os.date("%c")) end
            end
        else
            WriteJSON(STATE_FILE, st)
            return idx, rName, st
        end
    end
    WriteJSON(STATE_FILE, st)
    return 7, "DONE", st
end

local function MarkCloneRaceDone(raceName)
    local st = ReadJSON(STATE_FILE)
    st.Completed = st.Completed or {}
    st.Completed[raceName] = st.Completed[raceName] or {}
    if not st.Completed[raceName][myName] then
        st.Completed[raceName][myName] = true
        WriteJSON(STATE_FILE, st)
    end
    GetCurrentStageAndRace()
end

-- Xác định 2 acc Support chính (khác race với targetRace của Clone) và 1 acc Support dư ra
local function GetActiveSupportsForRace(targetRace)
    local tRace = CleanRace(targetRace)
    local list, usedRaces = {}, {}
    local names = {}
    for accName in pairs(SUPPORT_ACCOUNTS) do table.insert(names, accName) end
    table.sort(names)
    for _, accName in ipairs(names) do
        local sRace = CleanRace(SUPPORT_ACCOUNTS[accName])
        if sRace ~= tRace and not usedRaces[sRace] and #list < 2 then
            usedRaces[sRace] = true
            table.insert(list, accName)
        end
    end
    return list[1], list[2]
end

-- // ==============================================================================
-- // MOON SERVER COORDINATION (PRIMARY + BACKUP MOON SERVERS)
-- // ==============================================================================
local function UpdateMoonPool(targetRace)
    local pool = ReadJSON(MOON_FILE)
    pool.Servers = pool.Servers or {}
    local now = os.time()
    for jid, info in pairs(pool.Servers) do
        if type(info) ~= "table" or (now - (tonumber(info.UpdatedAt) or 0) > 45) or not info.Valid then
            pool.Servers[jid] = nil
        end
    end

    local mState, isValid, isOfficial = CheckMoonStatus()
    local myJob = tostring(game.JobId)
    if isValid and IsSea3() then
        pool.Servers[myJob] = {
            JobId = myJob,
            FoundBy = myName,
            State = mState,
            Official = isOfficial,
            Players = #Players:GetPlayers(),
            UpdatedAt = now,
            Valid = true,
        }
    else
        pool.Servers[myJob] = nil
    end

    -- Chọn PrimaryServer (ưu tiên server đã có Support chính hoặc Official Full Moon)
    if pool.PrimaryJobId and not pool.Servers[pool.PrimaryJobId] then
        pool.PrimaryJobId = nil
    end
    if not pool.PrimaryJobId then
        for jid, info in pairs(pool.Servers) do
            if info.Valid and (tonumber(info.Players) or 0) < 12 then
                pool.PrimaryJobId = jid
                break
            end
        end
    end
    WriteJSON(MOON_FILE, pool)
    return pool, mState, isValid, isOfficial
end

-- // ==============================================================================
-- // UP GEAR & TRIAL COORDINATOR (DOOR TWEEN -> SYNC V3 -> FALL -> TRIAL -> PVP/RESET)
-- // ==============================================================================
local function IsPlayerAtRaceDoor(plrName, raceStr)
    local p = Players:FindFirstChild(plrName)
    local hrp = p and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
    local doorCF = RACE_DOORS[CleanRace(raceStr)]
    if hrp and doorCF then
        return (hrp.Position - doorCF.Position).Magnitude <= 18
    end
    return false
end

local function ActivateRaceV3()
    pcall(function()
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.T, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.T, false, game)
    end)
    pcall(function() ReplicatedStorage.Remotes.CommE:FireServer("ActivateAbility") end)
end

local function ResetCharacter()
    SetStabilizer(false)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health = 0 end
    pcall(function() if char then char:BreakJoints() end end)
end

local function RunUpGearCycle(targetRace, sup1, sup2)
    local myRace = CleanRace(GetMyRace())
    local myDoor = RACE_DOORS[myRace]
    if not myDoor then return end

    -- 1. Xử lý ngay khi có thông báo "All trials have been completed!" (Support Reset / Clone Kill Player)
    if App.AllTrialsCompletedAt > 0 and (os.clock() - App.AllTrialsCompletedAt < 120) then
        App.TrialStartingAt = 0
        if App.Role == "Support" then
            App.Status = "All Trials Completed! Support Resetting..."
            ResetCharacter()
            App.AllTrialsCompletedAt = 0
            task.wait(4)
            return
        else
            if not CheckTrain() then
                -- Đã mua gear và chuyển sang Need Train -> Kết thúc pha PvP
                App.AllTrialsCompletedAt = 0
                return
            end
            App.Status = "All Trials Completed! Killing surviving players..."
            local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local foundTarget = false
            if myHrp then
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= LocalPlayer and plr.Character then
                        local th = plr.Character:FindFirstChildOfClass("Humanoid")
                        local tr = plr.Character:FindFirstChild("HumanoidRootPart")
                        if th and tr and th.Health > 0 and (tr.Position - TEMPLE_POS).Magnitude <= 4000 and (tr.Position - myHrp.Position).Magnitude <= 1500 then
                            foundTarget = true
                            _tp(tr.CFrame * CFrame.new(0, 4, 2))
                            MousePos = tr.Position
                            FastAttackTarget(true)
                            Useskills("Melee", "Z")
                            Useskills("Melee", "X")
                            Useskills("Sword", "Z")
                            break
                        end
                    end
                end
            end
            if not foundTarget then
                -- Không còn player nào sống xung quanh -> Tween lên đồng hồ mua Gear
                local tot = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Temple of Time")
                if tot and tot:FindFirstChild("Prompt") then
                    _tp(tot.Prompt.CFrame)
                    if tot.Prompt:FindFirstChild("ProximityPrompt") then
                        pcall(function() fireproximityprompt(tot.Prompt.ProximityPrompt) end)
                    end
                end
            end
            return
        end
    end

    -- 2. Nếu đang ở trong Trial -> Làm Trial theo tộc
    if IsInsideTrial() then
        App.TrialStartingAt = 0
        App.Status = "Completing Trial [" .. myRace .. "]..."
        RunTrialStepForMyRace()
        return
    end

    -- 2. Nếu vừa có thông báo "Trials starting in..." -> Tween tới cửa rồi nhả anchor rơi tự do liên tục
    if App.TrialStartingAt > 0 and (os.clock() - App.TrialStartingAt < 18) then
        App.Status = "Trials starting! Tween door & free-fall..."
        _tp(myDoor)
        task.wait(0.35)
        if App.ActiveTween then pcall(function() App.ActiveTween:Cancel() end) App.ActiveTween = nil end
        SetStabilizer(false)
        task.wait(0.55)
        return
    end

    -- 3. Kiểm tra sự hiện diện của 2 Support chính và ít nhất 1 Clone Ready trong server
    local pSup1 = sup1 and Players:FindFirstChild(sup1)
    local pSup2 = sup2 and Players:FindFirstChild(sup2)
    local syncData = ReadJSON(DOOR_SYNC_FILE)
    syncData.ReadyClones = syncData.ReadyClones or {}
    local now = os.time()
    for cName, info in pairs(syncData.ReadyClones) do
        if type(info) ~= "table" or (now - (tonumber(info.UpdatedAt) or 0) > 15) or not Players:FindFirstChild(cName) then
            syncData.ReadyClones[cName] = nil
        end
    end
    if App.Role == "Clone" and App.IsTrained and myRace == CleanRace(targetRace) then
        syncData.ReadyClones[myName] = { JobId = tostring(game.JobId), UpdatedAt = now }
        WriteJSON(DOOR_SYNC_FILE, syncData)
    end

    local readyClonesInServer = {}
    for _, cName in ipairs(CLONE_ACCOUNTS) do
        local info = syncData.ReadyClones[cName]
        if info and info.JobId == tostring(game.JobId) and Players:FindFirstChild(cName) then
            table.insert(readyClonesInServer, cName)
        end
    end

    if not (pSup1 and pSup2 and #readyClonesInServer >= 1) then
        IdleAtGreatTree("Waiting for 2 Supports + >=1 Clone in server...")
        return
    end

    local activeClone = readyClonesInServer[1]
    if App.Role == "Clone" and myName ~= activeClone then
        IdleAtGreatTree("Waiting turn (Active Clone: " .. activeClone .. ")...")
        return
    end

    -- 4. Bắt buộc vào Temple of Time trước khi tween tới cửa tộc
    if not EnterTempleOfTime() then return end

    -- 5. Tween tới cửa tộc của mình
    App.Status = "Tweening to Race Door [" .. myRace .. "]..."
    _tp(myDoor)

    -- 6. Xác nhận cả 3 acc (2 Support + 1 Clone) đều đã đứng tại cửa tương ứng
    local s1AtDoor = IsPlayerAtRaceDoor(sup1, SUPPORT_ACCOUNTS[sup1])
    local s2AtDoor = IsPlayerAtRaceDoor(sup2, SUPPORT_ACCOUNTS[sup2])
    local clAtDoor = IsPlayerAtRaceDoor(activeClone, targetRace)

    if s1AtDoor and s2AtDoor and clAtDoor then
        App.Status = "All 3 races at doors! Activating V3..."
        App.TrialStartingAt = 0
        ActivateRaceV3()
        local t0 = os.clock()
        while (os.clock() - t0) < 5 do
            if App.TrialStartingAt > 0 or IsInsideTrial() then break end
            task.wait(0.2)
        end
        -- Nếu sau 5s bật V3 không có notification "Trials starting in" -> Reset những acc đã bật V3
        if App.TrialStartingAt == 0 and not IsInsideTrial() then
            App.Status = "No 'Trials starting in' after 5s! Resetting..."
            ResetCharacter()
            task.wait(5)
        end
    end
end

-- // ==============================================================================
-- // MAIN ORCHESTRATION LOOP
-- // ==============================================================================
task.spawn(function()
    repeat task.wait(0.2) until LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer:FindFirstChild("Data")
    task.wait(1)

    while App.Running do
        pcall(function()
            local stageIdx, stageRace = GetCurrentStageAndRace()
            if stageIdx > 6 then
                App.Status = "ALL 6 RACES V4 FULL GEAR COMPLETED!"
                IdleAtGreatTree("All 6 V4 Done")
                return
            end

            local myTargetRace = (App.Role == "Support") and CleanRace(SUPPORT_ACCOUNTS[myName]) or CleanRace(stageRace)
            local myCurrentRace = CleanRace(GetMyRace())
            local v3Ready = (myCurrentRace == myTargetRace) and HasV3() and HasPulledLever()

            -- BƯỚC 1: KIỂM TRA V3 + PULL LEVER RACE TARGET
            if not v3Ready then
                LaunchV3PullHub(myTargetRace)
                return
            elseif App.HubRunning and App.Status:find("V3Pull") then
                -- Vừa hoàn thành V3Pull -> Hop Low hoặc qua Sea 3 để refresh sạch Hub
                App.HubRunning = false
                if TravelSea3() then HopLowServer(false) end
                return
            end

            -- BƯỚC 2: ĐẢM BẢO ĐANG Ở SEA 3
            if not TravelSea3() then return end

            -- BƯỚC 3: KIỂM TRA FULL GEAR (ĐỐI VỚI CLONE)
            if App.Role == "Clone" and IsCurrentRaceFullGear(stageRace) then
                MarkCloneRaceDone(stageRace)
                ClearMyTrainSession()
                if App.HubRunning then
                    App.HubRunning = false
                    HopLowServer(false)
                    return
                end
                -- Clone đã xong tộc hiện tại: nếu chưa hết 6 tộc thì phụ đi tìm Full Moon hoặc đợi ở Great Tree
                local _, mValid = CheckMoonStatus()
                UpdateMoonPool(stageRace)
                if mValid then
                    IdleAtGreatTree("Done " .. stageRace .. " (Holding Moon Server)")
                else
                    HopLowServer(true)
                end
                return
            end

            -- BƯỚC 4: KIỂM TRA TRAIN GEAR (REAL KID MAIN + ANTI-COLLISION TTL 60S)
            local trained = CheckTrain()
            if not trained then
                local _, mValid = CheckMoonStatus()
                if mValid or CheckTrainCollision60s() then
                    App.HubRunning = false
                    HopLowServer(false)
                    return
                end
                LaunchRealKidTrainV4()
                return
            else
                ClearMyTrainSession()
                if App.HubRunning then
                    -- Đã train xong trong khi RealKid Main đang chạy -> Buộc Hop Low để refresh trước khi tween!
                    App.HubRunning = false
                    HopLowServer(false)
                    return
                end
            end

            -- BƯỚC 5: ĐIỀU PHỐI FULL MOON / NEAR FULL MOON & UP GEAR
            local sup1, sup2 = GetActiveSupportsForRace(stageRace)
            local isActiveSupport = (App.Role == "Support") and (myName == sup1 or myName == sup2)
            local isSurplusSupport = (App.Role == "Support") and not isActiveSupport

            local pool, mState, isValidMoon, isOfficialFM = UpdateMoonPool(stageRace)
            local primaryJob = pool.PrimaryJobId
            local myJob = tostring(game.JobId)

            if isSurplusSupport then
                -- Acc Support dư ra: Tìm server Full Moon / Near Full Moon KHÁC với PrimaryJobId
                if isValidMoon and myJob ~= primaryJob then
                    IdleAtGreatTree("Surplus Support Holding Backup " .. mState)
                else
                    HopLowServer(true)
                end
                return
            end

            if isActiveSupport then
                if primaryJob and primaryJob ~= myJob then
                    App.Status = "Joining Primary Moon Server..."
                    TeleportToJob(primaryJob)
                    return
                end
                if not isValidMoon then
                    HopLowServer(true)
                    return
                end
                if isOfficialFM then
                    RunUpGearCycle(stageRace, sup1, sup2)
                else
                    IdleAtGreatTree("Waiting Near Full Moon -> Night...")
                end
                return
            end

            -- Acc Clone (Ready for Trial)
            if primaryJob then
                if primaryJob ~= myJob then
                    local pInfo = pool.Servers and pool.Servers[primaryJob]
                    if pInfo and (tonumber(pInfo.Players) or 0) >= 12 then
                        -- Server của Support đã full -> Clone đi tìm server Full Moon khác làm dự phòng
                        if isValidMoon then
                            IdleAtGreatTree("Backup Moon Server (Primary Full)")
                        else
                            HopLowServer(true)
                        end
                    else
                        App.Status = "Joining Primary Moon Server..."
                        TeleportToJob(primaryJob)
                    end
                    return
                end
                if isOfficialFM then
                    RunUpGearCycle(stageRace, sup1, sup2)
                else
                    IdleAtGreatTree("Waiting Near Full Moon -> Night...")
                end
            else
                -- Chưa có server Full Moon -> Clone đã Ready cũng phụ đi tìm hoặc đợi ở Great Tree
                if isValidMoon then
                    IdleAtGreatTree("Found " .. mState .. "! Waiting Supports...")
                else
                    HopLowServer(true)
                end
            end
        end)
        task.wait(0.8)
    end
end)

-- // ==============================================================================
-- // MINIMALIST UI
-- // ==============================================================================
pcall(function()
    local cg = (gethui and gethui()) or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
    if cg:FindFirstChild("Kaitun6V4UI") then cg.Kaitun6V4UI:Destroy() end

    local sg = Instance.new("ScreenGui", cg)
    sg.Name = "Kaitun6V4UI"
    sg.ResetOnSpawn = false

    local fr = Instance.new("Frame", sg)
    fr.Size = UDim2.new(0, 310, 0, 125)
    fr.Position = UDim2.new(0, 15, 0, 15)
    fr.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    fr.Active = true
    fr.Draggable = true
    Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 6)

    local lbl = Instance.new("TextLabel", fr)
    lbl.Size = UDim2.new(1, -16, 1, -12)
    lbl.Position = UDim2.new(0, 8, 0, 6)
    lbl.BackgroundTransparency = 1
    lbl.TextColor3 = Color3.fromRGB(235, 235, 245)
    lbl.Font = Enum.Font.Code
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextYAlignment = Enum.TextYAlignment.Top
    lbl.TextWrapped = true

    task.spawn(function()
        while App.Running and sg.Parent do
            pcall(function()
                local idx, sRace = GetCurrentStageAndRace()
                local mState = CheckMoonStatus()
                lbl.Text = string.format(
                    "[KAITUN 6 V4] %s (%s)\nStage: %d/6 [%s] | MyRace: %s (T%d)\nTrain: %s | Moon: %s\nStatus: %s\nNotif: %s",
                    myName, App.Role, math.min(idx, 6), tostring(sRace):upper(),
                    tostring(GetMyRace()), GetV4Tier(), tostring(App.TrialStatus),
                    mState, tostring(App.Status), tostring(App.LastNotif):sub(1, 38)
                )
            end)
            task.wait(0.5)
        end
    end)
end)
