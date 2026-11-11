-- 6V4 AUTO UPGEAR ORCHESTRATOR (chay bang autoexec tren TAT CA acc: support + clone)
local CFG = {
    Supports = { {"SupportName1", "ghoul"}, {"SupportName2", "fishman"}, {"SupportName3", "skypiea"} }, -- {ten acc, race khoa}
    Clones   = { "CloneName1", "CloneName2" },                                                           -- acc up gear (race = race dang lam)
}
local ORDER = {"cyborg", "ghoul", "fishman", "skypiea", "mink", "human"}

repeat task.wait() until game:IsLoaded()
local function S(n) return game:GetService(n) end
local P, RS, TS, HS, VIM, VU, LT, TW, WS = S"Players", S"ReplicatedStorage", S"TeleportService", S"HttpService", S"VirtualInputManager", S"VirtualUser", S"Lighting", S"TweenService", workspace
local me = P.LocalPlayer
local N = me.Name
local D = "6V4Progress"
pcall(makefolder, D)
local CF = RS:WaitForChild("Remotes"):WaitForChild("CommF_")
local SEA3 = {[7449423635] = true, [100117331123089] = true}
local TEMPLE, TREE, TREETOP = Vector3.new(28294, 14896, 103), Vector3.new(2262.59, 21.69, -6462.95), Vector3.new(3028.83, 2281.17, -7324.77)
local DOORS = {
    mink = Vector3.new(29020.66, 14889.43, -379.27), fishman = Vector3.new(28224.06, 14889.43, -210.59),
    cyborg = Vector3.new(28492.41, 14894.43, -422.11), skypiea = Vector3.new(28967.41, 14918.08, 234.31),
    ghoul = Vector3.new(28672.72, 14889.13, 454.60), human = Vector3.new(29237.29, 14889.43, -206.95),
}
local V3U = "https://raw.githubusercontent.com/phongdeptraur/kaitunv3/refs/heads/main/"
local V3F = {human = "autohumanv3pull", cyborg = "kaituncyv3pull", fishman = "kaitunfishV3pull", ghoul = "kaitunghoulv3pull", mink = "kaitunminkV3pull", skypiea = "kaitunskypieav3pull"}

local ABIL = {human = "Last Resort", mink = "Agility", fishman = "Water Body", skypiea = "Heavenly Blood", ghoul = "Heightened Senses", cyborg = "Energy Core"} -- ability V3 theo toc (sua neu sai ten)
local SUP, CLN, ALL = {}, {}, {}
for _, s in ipairs(CFG.Supports) do SUP[s[1]] = s[2]; ALL[#ALL + 1] = s[1] end
for _, c in ipairs(CFG.Clones) do CLN[c] = true; ALL[#ALL + 1] = c end
if not (SUP[N] or CLN[N]) then return end

local function rj(p) local ok, r = pcall(function() return HS:JSONDecode(readfile(p)) end) return (ok and type(r) == "table") and r or {} end
local function wj(p, t) pcall(writefile, p, HS:JSONEncode(t)) end
local function Root() local c = me.Character return c and c:FindFirstChild("HumanoidRootPart") end
local function Race() local d = me:FindFirstChild("Data") local r = d and d:FindFirstChild("Race") return r and tostring(r.Value):lower() or "" end
local function Pos(o) return o:IsA("BasePart") and o.Position or o:GetPivot().Position end
local cache = {}
local function C(k, ttl, f) local c = cache[k] if c and os.clock() - c[1] < ttl then return c[2] end local v = f() cache[k] = {os.clock(), v} return v end

local ST = {sup = SUP[N] ~= nil, race = "", j = game.JobId, rdy = false, dn = false, m = 0, np = 1, door = false, ph = "init", t = os.time(), jt = os.time()}
local hopping, Ev = false, {start = 0, done = 0}

-- ===== TRIAL / TRAIN / MOON STATE =====
local function Trained(f)
    return C("tr", f and 0 or 4, function()
        local ok, r = pcall(function() return CF:InvokeServer("UpgradeRace", "Check") end)
        return ok and (r == 0 or r == nil or r == "0" or r == "nil")
    end)
end
local function Ready(rc) -- da dung race + da V3 pull
    if not SEA3[game.PlaceId] or Race() ~= rc then return false end
    local ab, c = ABIL[rc], me.Character
    if not (me.Backpack:FindFirstChild(ab) or (c and c:FindFirstChild(ab))) then return false end -- V3: co ability trong backpack
    return C("rd", 5, function() local ok, r = pcall(function() return CF:InvokeServer("CheckTempleDoor") end) return ok and r == true end)
end
local function Tier()
    local ok, v = pcall(function() local R = me.Data.Race return tonumber((R:FindFirstChild("C") or R:FindFirstChild("Tier")).Value) end)
    return ok and v or -1
end
local ck0, t0, rate
local function Moon() -- 0 none | 1 near full moon (<5p toi) | 2 full moon + troi toi
    local sk = LT:FindFirstChildOfClass("Sky")
    local c = LT.ClockTime
    local now = os.clock()
    if not ck0 then ck0, t0 = c, now elseif now - t0 >= 6 then rate = ((c - ck0) % 24) / (now - t0); ck0, t0 = c, now end
    if not (sk and tostring(sk.MoonTextureId):find("9709149431")) then return 0 end
    if c >= 18 or c < 5 then return 2 end
    if rate and rate > 0 and ((18 - c) % 24) / rate / 60 < 5 then return 1 end
    return 0
end

-- ===== NOTIFICATION WATCHER =====
local seen = {}
task.spawn(function()
    while task.wait(0.25) do pcall(function()
        local g = me:FindFirstChild("PlayerGui") if not g then return end
        for _, d in ipairs((g:FindFirstChild("Notifications") or g):GetDescendants()) do
            if d:IsA("TextLabel") then
                local t = (d.Text:lower():gsub("<[^>]->", ""))
                local vis = d.Visible and d.TextTransparency < 0.9
                local key = t .. tostring(vis)
                if seen[d] ~= key then
                    seen[d] = key
                    if vis then
                        if t:find("trials starting in") then Ev.start = os.clock() elseif t:find("all trials have been completed") then Ev.done = os.clock() end
                    end
                end
            end
        end
    end) end
end)

-- ===== HOP LOW (blacklist 10p dung chung) =====
local function Hop()
    if hopping then return end
    hopping = true
    local bl = rj(D .. "/bl.json")
    bl[game.JobId] = os.time() + 600
    wj(D .. "/bl.json", bl)
    task.spawn(function()
        while true do
            bl = rj(D .. "/bl.json")
            local br, by, done = RS:FindFirstChild("__ServerBrowser"), {}, 0
            for p = 1, 100 do task.delay(p * 0.02, function()
                local ok, r = pcall(function() return br:InvokeServer(p) end)
                if ok and type(r) == "table" then
                    for id, d in pairs(r) do
                        if type(d) == "table" and id ~= game.JobId and (bl[id] or 0) < os.time() then by[id] = tonumber(d.Count) or 99 end
                    end
                end
                done += 1
            end) end
            local dl = os.clock() + 8
            repeat task.wait(0.1) until done >= 100 or os.clock() > dl
            local pool = {}
            for id, c in pairs(by) do pool[#pool + 1] = {id, c} end
            table.sort(pool, function(a, b) return a[2] < b[2] end)
            for _ = 1, math.min(#pool, 6) do
                local i = math.random(1, math.min(#pool, 3))
                local id = table.remove(pool, i)[1]
                pcall(function() br:InvokeServer("teleport", id) end)
                task.wait(8)
            end
            task.wait(2)
        end
    end)
end
local function Join(id)
    pcall(function() RS.__ServerBrowser:InvokeServer("teleport", id) end)
    task.wait(8)
    pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, id, me) end)
    task.wait(10)
end

-- ===== TWEEN (190 stud/s, cam khi hub dang chay -> hop refresh) =====
local function Tween(pos)
    if getgenv().V4Hub then Hop() return false end
    local r = Root() if not r then return false end
    r.Anchored = true
    local tw = TW:Create(r, TweenInfo.new((r.Position - pos).Magnitude / 190, Enum.EasingStyle.Linear), {CFrame = CFrame.new(pos)})
    tw:Play(); tw.Completed:Wait()
    return true
end
local function Idle() ST.ph = "idle" local r = Root() if r and (r.Position - TREE).Magnitude > 150 then Tween(TREE) end end
local function InTemple() local r = Root() return r and (r.Position - TEMPLE).Magnitude < 4000 end
local function Enter()
    if InTemple() then return true end
    if not Tween(TREETOP) then return false end
    pcall(function() CF:InvokeServer("requestEntrance", TEMPLE) end)
    task.wait(2)
    local r = Root() if r then r.Anchored = false end
    return InTemple()
end

-- ===== HUBS =====
local function Hub(name, f) if getgenv().V4Hub then return end getgenv().V4Hub = name task.spawn(f) end
local function Train()
    for _, pre in ipairs({"", "workspace/"}) do
        pcall(makefolder, pre .. "RealKidHub")
        for _, sub in ipairs({"save", "save2"}) do
            pcall(makefolder, pre .. "RealKidHub/" .. sub)
            local p = pre .. "RealKidHub/" .. sub .. "/" .. N .. ".json"
            local c = rj(p)
            c.AutoTrainV4, c.AutoCompleteTrialRace, c.AutoPullLever, c.AutoUpgradeRaceV3 = true, false, false, false
            wj(p, c)
        end
    end
    loadstring(game:HttpGet("https://raw.githubusercontent.com/realkidhub/realkid/refs/heads/main/main.lua"))()
end

-- ===== AUTO BUY GEAR (clone, moi 5s) =====
task.spawn(function()
    while task.wait(5) do
        if CLN[N] and InTemple() then pcall(function()
            local c = CF:InvokeServer("TempleClock", "Check")
            if c and c.HadPoint then
                local rd, T = c.RaceDetails, WS.Map["Temple of Time"]
                fireproximityprompt(T.Prompt.ProximityPrompt)
                task.wait()
                for _, v in ipairs(T.InnerClock:GetChildren()) do
                    if v:FindFirstChild("Highlight") and v.Highlight.Enabled then
                        local t = math.random(0, 1) == 1 and "Alpha" or "Omega"
                        if v.Name == "Gear4" then t = (rd.A <= 2 and "Alpha") or (rd.B == 2 and "Omega") or nil end
                        if t then CF:InvokeServer("TempleClock", "SpendPoint", v.Name, t) end
                    end
                end
            end
        end) end
    end
end)

-- ===== COMBAT HELPERS =====
local function Equip(tp)
    local c = me.Character
    if not c then return end
    for _, t in ipairs(me.Backpack:GetChildren()) do if t:IsA("Tool") and t.ToolTip == tp then c.Humanoid:EquipTool(t) return end end
end
local Net = RS:WaitForChild("Modules"):WaitForChild("Net")
local function Hit(hrp) -- fast attack: RegisterAttack + RegisterHit len muc tieu quanh hrp (mob + player)
    pcall(function()
        local list = {}
        local function add(m)
            local p = m:FindFirstChild("Head") or m:FindFirstChild("HumanoidRootPart")
            local h = m:FindFirstChildOfClass("Humanoid")
            if p and h and h.Health > 0 and (p.Position - hrp.Position).Magnitude < 60 then list[#list + 1] = {m, p} end
        end
        for _, m in ipairs(WS.Enemies:GetChildren()) do add(m) end
        for _, p in ipairs(P:GetPlayers()) do if p ~= me and p.Character then add(p.Character) end end
        if #list == 0 then return end
        Net["RE/RegisterAttack"]:FireServer(0)
        Net["RE/RegisterHit"]:FireServer(list[1][2], list)
    end)
end
local function Atk(hrp)
    local r = Root()
    if r and hrp then r.Anchored = false r.CFrame = hrp.CFrame * CFrame.new(0, 4, 2) r.AssemblyLinearVelocity = Vector3.zero Equip("Melee") Hit(hrp) end
end
local function Key(k) VIM:SendKeyEvent(true, Enum.KeyCode[k], false, game) task.wait(0.05) VIM:SendKeyEvent(false, Enum.KeyCode[k], false, game) end
local function Alive()
    for _, p in ipairs(P:GetPlayers()) do
        local c = p ~= me and p.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 and c:FindFirstChild("HumanoidRootPart") then return c.HumanoidRootPart end
    end
end
local TR = {
    mink = function() local r = Root() r.Anchored = false r.CFrame = WS.Map.MinkTrial.Ceiling.CFrame * CFrame.new(0, -20, 0) end,
    skypiea = function() local r = Root() r.Anchored = false r.CFrame = WS.Map.SkyTrial.Model.FinishPart.CFrame end,
    cyborg = function() Tween((WS.Map.CyborgTrial.Floor.CFrame * CFrame.new(0, 500, 0)).Position) end,
    fishman = function()
        local L = WS._WorldOrigin.Locations:FindFirstChild("Trial of Water")
        if not (WS.Map:FindFirstChild("FishmanTrial") and L) then return end
        for _, b in ipairs(WS.SeaBeasts:GetChildren()) do
            local h = b:FindFirstChild("HumanoidRootPart")
            if h and b:FindFirstChild("Health") and b.Health.Value > 0 and (h.Position - Pos(L)).Magnitude <= 1500 then
                local r, cam = Root(), WS.CurrentCamera
                r.Anchored = false
                r.CFrame = CFrame.new(h.Position.X, WS.Map["WaterBase-Plane"].Position.Y + 300, h.Position.Z)
                cam.CFrame = CFrame.lookAt(cam.CFrame.Position, h.Position)
                for _, s in ipairs({{"Melee", "ZXC"}, {"Sword", "ZX"}, {"Blox Fruit", "ZXC"}, {"Gun", "ZX"}}) do
                    Equip(s[1])
                    for k in s[2]:gmatch(".") do Key(k) end
                end
                return
            end
        end
    end,
}
local function KillMob()
    for _, m in ipairs(WS.Enemies:GetChildren()) do
        local h = m:FindFirstChild("Humanoid")
        if (m.Name == "Ancient Vampire" or m.Name == "Ancient Zombie") and h and h.Health > 0 and m:FindFirstChild("HumanoidRootPart") then Atk(m.HumanoidRootPart) return end
    end
end
TR.ghoul, TR.human = KillMob, KillMob
local function InTrial()
    local r = Root()
    if not r then return false end
    for _, l in ipairs(WS._WorldOrigin.Locations:GetChildren()) do
        if l.Name:find("^Trial of") and (r.Position - Pos(l)).Magnitude < 3000 then return true end
    end
    return false
end
local function Reset() local c = me.Character if c and c:FindFirstChild("Humanoid") then c.Humanoid.Health = 0 end end

-- ===== GROUP LOGIC =====
local function Others(ttl)
    local o = {}
    for _, n in ipairs(ALL) do
        if n ~= N then local s = rj(D .. "/st_" .. n .. ".json") if s.t and os.time() - s.t < ttl then o[n] = s end end
    end
    o[N] = ST
    return o
end
local function El(s, tr) return s.rdy and ((s.sup and s.race ~= tr) or (not s.sup and not s.dn)) end
local function Group(O) -- 2 support khac race (!= target) + >=1 clone cung server
    local sup, cl, rs, names = {}, {}, {}, {}
    for n in pairs(O) do names[#names + 1] = n end
    table.sort(names)
    for _, n in ipairs(names) do
        local s = O[n]
        if s.j == game.JobId and s.rdy then
            if s.sup then
                if s.race ~= ST.tr and not rs[s.race] and #sup < 2 then rs[s.race] = 1 sup[#sup + 1] = n end
            elseif not s.dn then cl[#cl + 1] = n end
        end
    end
    if #sup == 2 and #cl > 0 then
        local all = {}
        for _, v in ipairs(sup) do all[#all + 1] = v end
        for _, v in ipairs(cl) do all[#all + 1] = v end
        table.sort(all)
        return all
    end
end
local function PickG(O, tr) -- server full/near moon co nhieu thanh vien hop le nhat
    local sc, np = {}, {}
    for _, s in pairs(O) do
        if s.rdy and s.m > 0 then sc[s.j] = (sc[s.j] or 0) + (El(s, tr) and 1 or 0) np[s.j] = math.max(np[s.j] or 0, s.np) end
    end
    local bj, bs
    for j, v in pairs(sc) do if not bj or v > bs or (v == bs and j < bj) then bj, bs = j, v end end
    return bj, np[bj]
end

-- ===== UPGEAR FSM =====
local lastGo, tt = nil, 0
local function Gear(O)
    local ph, race = ST.ph, Race()
    if ph == "gear" then
        local all = Group(O)
        if not all or ST.m ~= 2 or not table.find(all, N) then ST.ph = "idle" return end
        if not Enter() then return end
        local d, r = DOORS[race], Root()
        if (r.Position - d).Magnitude > 30 then Tween(d) return end
        local ok = true
        for _, n in ipairs(all) do if not (O[n].door or n == N) then ok = false end end
        local g = rj(D .. "/go.json")
        if ok and all[1] == N and not (g.j == game.JobId and os.time() - g.t < 20) then
            g = {j = game.JobId, t = os.time() + 3, id = math.random(1, 1e9)}
            wj(D .. "/go.json", g)
        end
        if g.j == game.JobId and g.id ~= lastGo and os.time() <= g.t + 6 then
            lastGo = g.id
            while os.time() < g.t do task.wait(0.1) end
            local t0 = os.clock()
            pcall(function() RS.Remotes.CommE:FireServer("ActivateAbility") end)
            repeat task.wait(0.1) until Ev.start >= t0 or os.clock() - t0 > 5
            if Ev.start >= t0 then ST.ph, tt = "trial", os.clock() else Reset() end
        end
    elseif ph == "trial" then
        if Ev.done > Ev.start then ST.ph = "after" return end
        if os.clock() - tt > 300 then ST.ph = "idle" return end
        if InTrial() then
            pcall(TR[race] or function() end)
            task.wait(0.2)
        else
            local d, r = DOORS[race], Root()
            if r and (r.Position - d).Magnitude > 20 then Tween(d) end
            task.wait(0.3)
            r = Root() if r then r.Anchored = false end
            task.wait(1.5)
        end
    elseif ph == "after" then
        if CLN[N] then
            local t = os.clock()
            local r = Root() if r then r.Anchored = false end
            repeat
                local h = Alive()
                if not h then break end
                Atk(h)
                task.wait(0.05)
            until not Trained(true) or os.clock() - t > 150
        else
            Reset()
        end
        ST.ph = "idle"
    end
end

-- ===== TIEN DO =====
local function Target()
    for i, r in ipairs(ORDER) do if not isfile(D .. "/" .. i .. "race-" .. r .. ".txt") then return i, r end end
end
local function CheckDone(i, r)
    for _, c in ipairs(CFG.Clones) do if not isfile(D .. "/c_" .. r .. "_" .. c .. ".txt") then return end end
    writefile(D .. "/" .. i .. "race-" .. r .. ".txt", os.date() .. " | " .. table.concat(CFG.Clones, ","))
end

-- ===== UI + HEARTBEAT =====
local gui, lb = Instance.new("ScreenGui"), Instance.new("TextLabel")
gui.ResetOnSpawn = false
lb.Size, lb.BackgroundColor3, lb.BackgroundTransparency = UDim2.new(0, 340, 0, 64), Color3.new(0, 0, 0), 0.4
lb.TextColor3, lb.TextSize, lb.Font, lb.TextXAlignment, lb.TextYAlignment = Color3.new(1, 1, 1), 12, Enum.Font.Code, Enum.TextXAlignment.Left, Enum.TextYAlignment.Top
lb.Parent = gui
gui.Parent = (gethui and gethui()) or S"CoreGui"
me.Idled:Connect(function() VU:CaptureController() VU:ClickButton2(Vector2.new()) end)
pcall(function() getgenv().Team = "Marines" CF:InvokeServer("SetTeam", "Marines") end)

task.spawn(function()
    while task.wait(1) do pcall(function()
        ST.j, ST.race, ST.m, ST.np, ST.t = game.JobId, Race(), Moon(), #P:GetPlayers(), os.time()
        local r, d = Root(), DOORS[ST.race]
        ST.door = (r and d and (r.Position - d).Magnitude < 30) or false
        wj(D .. "/st_" .. N .. ".json", ST)
        lb.Text = string.format("%s [%s] target=%s\nph=%s hub=%s rdy=%s dn=%s\nmoon=%d players=%d hop=%s", N, SUP[N] and "SUP " .. SUP[N] or "CLONE", tostring(ST.tr), ST.ph, tostring(getgenv().V4Hub), tostring(ST.rdy), tostring(ST.dn), ST.m, ST.np, tostring(hopping))
    end) end
end)

-- ===== MAIN LOOP =====
local function tick()
    if hopping then return end
    local ti, tr = Target()
    if not ti then ST.ph, ST.rdy = "ALL 6 DONE", false getgenv().V4Stop = true return end
    ST.tr = tr
    CheckDone(ti, tr)
    local mk = D .. "/c_" .. tr .. "_" .. N .. ".txt"
    if CLN[N] and not isfile(mk) and Race() == tr then
        local t = Tier()
        if t >= 6 or (t == 5 and not Trained()) then writefile(mk, os.date()) end
    end
    ST.dn = CLN[N] and isfile(mk) or false
    local O = Others(15)
    if ST.ph == "gear" or ST.ph == "trial" or ST.ph == "after" then return Gear(O) end
    if ST.dn then ST.rdy = false return Idle() end

    local rc = SUP[N] or tr
    local need = (not Ready(rc)) and "v3" or (not Trained()) and "train" or nil
    if need then
        ST.ph, ST.rdy = need, false
        if need == "train" then -- anti collision TTL 60s
            for n, s in pairs(Others(60)) do
                if n ~= N and s.j == game.JobId and s.ph == "train" and (s.jt < ST.jt or (s.jt == ST.jt and n < N)) then return Hop() end
            end
        end
        local h = getgenv().V4Hub
        if h and h ~= need then return Hop() end -- hub cu dang chay -> hop refresh
        Hub(need, need == "v3" and function() loadstring(game:HttpGet(V3U .. V3F[rc]))() end or Train)
        return
    end
    ST.rdy = true
    if getgenv().V4Hub then return Hop() end -- xong V3/train -> hop refresh de tat hub
    if os.time() - ST.jt < 6 then return end

    local gj, gn = PickG(O, tr)
    if El(ST, tr) and gj and gj ~= game.JobId and (gn or 0) < 10 then ST.ph = "join" return Join(gj) end
    if ST.m == 0 then ST.ph = "hunt" return Hop() end
    local all = Group(O)
    if all and ST.m == 2 and table.find(all, N) then ST.ph = "gear" return end
    Idle()
end
while task.wait(0.5) and not getgenv().V4Stop do pcall(tick) end
