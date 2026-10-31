--[[
    ════════════════════════════════════════════
        SLAX HUB  |  San Diego Roleplay
        الثيم: SlaxRed (الأحمر الغامق)
        مبني على تقرير فحص SLAX للريموتات
        الميزات: أيم بوت + FOV · رقصة مايباخ 👑
    ════════════════════════════════════════════
]]

-- 1) تحميل WindUI
local WindUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()

-- 2) ثيم الأحمر الغامق
WindUI:AddTheme({
    Name        = "SlaxRed",
    Accent      = Color3.fromHex("#c1122f"),
    Background  = Color3.fromHex("#0d0507"),
    Outline     = Color3.fromHex("#6e1420"),
    Text        = Color3.fromHex("#f7e9ea"),
    Placeholder = Color3.fromHex("#94666d"),
    Button      = Color3.fromHex("#57101b"),
    Icon        = Color3.fromHex("#e05252"),
})

-- 3) مرجع ريموتات اللعبة (نسخة Knit من تقرير الفحص)
local RS      = game:GetService("ReplicatedStorage")
local Remotes = RS:WaitForChild("__remotes")

local function getRemote(serviceName, remoteName)
    local svc = Remotes:FindFirstChild(serviceName)
    return svc and svc:FindFirstChild(remoteName)
end

-- إرسال RemoteEvent بأمان
local function fire(serviceName, remoteName, ...)
    local r = getRemote(serviceName, remoteName)
    if r then
        pcall(function(...)
            r:FireServer(...)
        end, ...)
    end
end

-- استدعاء RemoteFunction بأمان — يرجع (نجاح, النتيجة)
local function invoke(serviceName, remoteName, ...)
    local r = getRemote(serviceName, remoteName)
    if not r then return false, nil end
    local ok, result = pcall(function(...)
        return r:InvokeServer(...)
    end, ...)
    return ok, result
end

local function notify(title, content)
    WindUI:Notify({ Title = title, Content = content, Icon = "flame", Duration = 3 })
end

-- 4) إنشاء النافذة
local Window = WindUI:CreateWindow({
    Title  = "SLAX HUB",
    Icon   = "siren",
    Author = "San Diego Roleplay",
    Folder = "SlaxHub",
    Theme  = "SlaxRed",
    Size   = UDim2.fromOffset(580, 460),
    ToggleKey = Enum.KeyCode.RightControl,
    HideSearchBar = false,

    OpenButton = {
        Title           = "فتح SLAX HUB",
        CornerRadius    = UDim.new(1, 0),
        StrokeThickness = 2,
        Enabled         = true,
        Draggable       = true,
        Color = ColorSequence.new(
            Color3.fromHex("#8b0f1f"),
            Color3.fromHex("#e02438")
        ),
    },
})

Window:Tag({
    Title  = "San Diego RP",
    Icon   = "siren",
    Color  = Color3.fromHex("#7d1128"),
    Border = true,
})

notify("SLAX HUB", "تم تحميل سكربت San Diego Roleplay")

-- 5) التبويبات
local TeamTab = Window:Tab({ Title = "الفِرق والسجن", Icon = "siren" })
local CarTab  = Window:Tab({ Title = "السيارات",      Icon = "car" })
local PlrTab  = Window:Tab({ Title = "الشخصية",       Icon = "user" })
local VisTab  = Window:Tab({ Title = "المرئيات",      Icon = "eye" })
local AimTab  = Window:Tab({ Title = "الأيم بوت",     Icon = "crosshair" })
local ExpTab  = Window:Tab({ Title = "تجريبي",        Icon = "flask-conical" })
local SetTab  = Window:Tab({ Title = "الإعدادات",     Icon = "settings" })

-- ═══════════ تبويب: الفِرق والسجن ═══════════
local selectedTeam = "Civilian"

TeamTab:Section({ Title = "تبديل الفريق" }):Dropdown({
    Title  = "اختر الفريق",
    Desc   = "عدّل الأسماء لتطابق فرق اللعبة إذا لزم",
    Values = {
        "San Diego Police Department",
        "San Diego County Sheriff",
        "California Highway Patrol",
        "Fire & Rescue",
        "Civilian",
        "Criminal",
    },
    Value = "Civilian",
    Callback = function(opt) selectedTeam = opt end,
})

TeamTab:Button({
    Title   = "الانضمام للفريق",
    Icon    = "users",
    Color   = Color3.fromHex("#b3122e"),
    Justify = "Center",
    Callback = function()
        local ok = invoke("TeamService", "JoinTeam", selectedTeam)
        notify("TeamService", ok and ("طلب انضمام: " .. selectedTeam) or "السيرفر رفض الطلب")
    end,
})

local JailSec = TeamTab:Section({ Title = "السجن والخزائن" })

JailSec:Button({
    Title   = "دفع الكفالة والخروج (Bail)",
    Icon    = "gavel",
    Color   = Color3.fromHex("#b3122e"),
    Justify = "Center",
    Callback = function()
        local ok = invoke("JailService", "Bail")
        notify("JailService", ok and "تم إرسال طلب الكفالة" or "فشل — قد تحتاج كاش كافياً")
    end,
})

JailSec:Button({
    Title   = "فتح الخزنة من أي مكان",
    Icon    = "backpack",
    Justify = "Center",
    Callback = function()
        local ok = invoke("LoadoutService", "OpenLocker")
        notify("LoadoutService", ok and "تم فتح الخزنة" or "فشل الطلب")
    end,
})

-- ═══════════ تبويب: السيارات ═══════════
local SirenSec = CarTab:Section({ Title = "الشرطة والإنذار" })

SirenSec:Dropdown({
    Title  = "وضع الصافرة",
    Values = { "إيقاف", "1", "2", "3" },
    Value  = "إيقاف",
    Callback = function(opt)
        fire("VehicleService", "SetSirenMode", tonumber(opt) or 0)
    end,
})

SirenSec:Dropdown({
    Title  = "نغمة الصافرة (Tone)",
    Values = { "1", "2", "3" },
    Value  = "1",
    Callback = function(opt)
        fire("VehicleService", "SetSirenTone", tonumber(opt) or 1)
    end,
})

SirenSec:Dropdown({
    Title  = "إضاءة الطوارئ (Lightbar)",
    Values = { "إيقاف", "1", "2", "3" },
    Value  = "إيقاف",
    Callback = function(opt)
        fire("VehicleService", "SetLightbarStage", tonumber(opt) or 0)
    end,
})

local CarSec = CarTab:Section({ Title = "تحكم السيارة" })

CarSec:Button({
    Title = "قفل / فتح السيارة",
    Icon  = "lock",
    Callback = function()
        invoke("VehicleService", "ToggleLocked")
        notify("VehicleService", "تم تبديل قفل السيارة")
    end,
})

CarSec:Button({
    Title = "تبديل الأبواب",
    Icon  = "door-open",
    Callback = function()
        fire("VehicleService", "ToggleDoors")
    end,
})

CarSec:Button({
    Title = "إلغاء التعليق (Unstuck)",
    Icon  = "wrench",
    Callback = function()
        fire("VehicleService", "UnstuckVehicle")
        notify("VehicleService", "طلب إلغاء تعليق السيارة")
    end,
})

CarSec:Button({
    Title = "مغادرة المقعد",
    Icon  = "log-out",
    Callback = function()
        fire("VehicleService", "ExitVehicleSeat")
    end,
})

CarSec:Button({
    Title   = "ورشة تعديل محمولة",
    Icon    = "paintbrush",
    Justify = "Center",
    Color   = Color3.fromHex("#b3122e"),
    Callback = function()
        local ok = invoke("VehicleCustomisationService", "OpenPortableSession")
        notify("VehicleCustomisation", ok and "تم فتح ورشة التعديل" or "فشل — جرّب قرب مركز التعديل")
    end,
})

-- ═══════════ تبويب: الشخصية ═══════════
local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local RunSvc  = game:GetService("RunService")
local LP      = Players.LocalPlayer

local function getHumanoid()
    local char = LP.Character
    return char and char:FindFirstChildOfClass("Humanoid")
end

local MoveSec = PlrTab:Section({ Title = "الحركة" })

MoveSec:Slider({
    Title = "سرعة المشي",
    Step  = 1,
    Value = { Min = 16, Max = 250, Default = 16 },
    Callback = function(v)
        local hum = getHumanoid()
        if hum then hum.WalkSpeed = v end
    end,
})

MoveSec:Slider({
    Title = "قوة القفز",
    Step  = 1,
    Value = { Min = 50, Max = 350, Default = 50 },
    Callback = function(v)
        local hum = getHumanoid()
        if hum then hum.JumpPower = v end
    end,
})

MoveSec:Toggle({
    Title = "قفز لا نهائي",
    Callback = function(state) _G.SlaxJump = state end,
})

UIS.JumpRequest:Connect(function()
    if _G.SlaxJump then
        local hum = getHumanoid()
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)

local flying = false
MoveSec:Toggle({
    Title = "الطيران (تجريبي)",
    Desc  = "W A S D للحركة — Space للصعود — Shift للنزول",
    Callback = function(state) flying = state end,
})

RunSvc.Heartbeat:Connect(function()
    if not flying then return end
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cam = workspace.CurrentCamera
    local dir = Vector3.zero
    if UIS:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
    if UIS:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
    if UIS:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.yAxis end
    if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.yAxis end
    hrp.AssemblyLinearVelocity = dir.Magnitude > 0 and dir.Unit * 70 or Vector3.zero
end)

local AvaSec = PlrTab:Section({ Title = "الأفاتار والبيانات" })

AvaSec:Slider({
    Title = "حجم الشخصية (LoadoutService)",
    Step  = 0.1,
    Value = { Min = 0.5, Max = 3, Default = 1 },
    Callback = function(v)
        invoke("LoadoutService", "SetScale", v)
    end,
})

AvaSec:Button({
    Title = "استعادة الأفاتار",
    Icon  = "rotate-ccw",
    Callback = function()
        invoke("LoadoutService", "RestoreAvatar")
        notify("LoadoutService", "تمت استعادة الأفاتار")
    end,
})

AvaSec:Button({
    Title = "عرض رصيد الكاش",
    Icon  = "banknote",
    Callback = function()
        local ok, data = invoke("PlayerDataService", "GetPlayerData")
        if ok and data then
            print(data)
            local cash = (typeof(data) == "table") and (data.Cash or data.Money or data.Bank or "?") or tostring(data)
            notify("PlayerDataService", "الرصيد: " .. tostring(cash))
        else
            notify("PlayerDataService", "فشل جلب البيانات")
        end
    end,
})

-- ═══════════ تبويب: المرئيات ═══════════
local espOn     = false
local espColor  = Color3.fromHex("#c1122f")
local espLights = {}

local function applyEsp()
    for _, hl in pairs(espLights) do pcall(function() hl:Destroy() end) end
    table.clear(espLights)
    if not espOn then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hl = Instance.new("Highlight")
            hl.FillColor    = espColor
            hl.OutlineColor = espColor
            hl.FillTransparency    = 0.6
            hl.OutlineTransparency = 0
            hl.Adornee = plr.Character
            hl.Parent  = plr.Character
            table.insert(espLights, hl)
        end
    end
end

Players.PlayerAdded:Connect(function(plr)
    plr.CharacterAdded:Connect(function() task.wait(1) applyEsp() end)
end)
for _, plr in ipairs(Players:GetPlayers()) do
    plr.CharacterAdded:Connect(function() task.wait(1) applyEsp() end)
end

local VisSec = VisTab:Section({ Title = "الرؤية والإضاءة" })

VisSec:Toggle({
    Title = "رؤية اللاعبين (ESP)",
    Callback = function(state) espOn = state applyEsp() end,
})

VisSec:Dropdown({
    Title  = "لون ESP",
    Values = { "أحمر غامق", "قرمزي", "ناري", "أبيض" },
    Value  = "أحمر غامق",
    Callback = function(opt)
        local map = {
            ["أحمر غامق"] = "#c1122f",
            ["قرمزي"]    = "#ff4d5e",
            ["ناري"]     = "#ff7a1a",
            ["أبيض"]     = "#f5e6e8",
        }
        espColor = Color3.fromHex(map[opt] or "#c1122f")
        applyEsp()
    end,
})

-- أسماء + مسافات + خطوط التتبع (Tracers) عبر Drawing
local espExtrasOn = true
local espTexts  = {}
local espTraces = {}

local function espDrawingsFor(plr)
    if not espTexts[plr] then
        local okT, t = pcall(function()
            local d = Drawing.new("Text")
            d.Center  = true
            d.Outline = true
            d.Size    = 13
            d.Color   = espColor
            d.Visible = false
            return d
        end)
        if okT then espTexts[plr] = t end

        local okL, l = pcall(function()
            local d = Drawing.new("Line")
            d.Thickness    = 1.2
            d.Transparency = 0.85
            d.Color        = espColor
            d.Visible      = false
            return d
        end)
        if okL then espTraces[plr] = l end
    end
end

Players.PlayerRemoving:Connect(function(plr)
    if espTexts[plr]  then pcall(function() espTexts[plr]:Remove()  end) espTexts[plr]  = nil end
    if espTraces[plr] then pcall(function() espTraces[plr]:Remove() end) espTraces[plr] = nil end
end)

RunSvc.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == LP then continue end
        espDrawingsFor(plr)
        local t, l = espTexts[plr], espTraces[plr]
        if not t and not l then continue end

        local char = plr.Character
        local hrp  = char and char:FindFirstChild("HumanoidRootPart")
        local show = espOn and espExtrasOn and hrp ~= nil
        local pos2, onScreen = nil, false

        if show then
            local p, s = cam:WorldToViewportPoint(hrp.Position)
            pos2, onScreen = Vector2.new(p.X, p.Y), s
        end

        if t then
            if show and onScreen then
                local dist = math.floor((cam.CFrame.Position - hrp.Position).Magnitude)
                t.Text     = plr.DisplayName .. "  [" .. dist .. "m]"
                t.Color    = espColor
                t.Position = Vector2.new(pos2.X, pos2.Y - 44)
                t.Visible  = true
            else
                t.Visible = false
            end
        end

        if l then
            if show and onScreen then
                l.From    = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y - 4)
                l.To      = Vector2.new(pos2.X, pos2.Y + 26)
                l.Color   = espColor
                l.Visible = true
            else
                l.Visible = false
            end
        end
    end
end)

VisSec:Toggle({
    Title = "أسماء + مسافات + خطوط اللاعبين (ESP أماكن)",
    Desc  = "اسم كل لاعب وبُعده فوق رأسه + خط تتبع من أسفل الشاشة",
    Value = true,
    Callback = function(state) espExtrasOn = state end,
})

VisSec:Toggle({
    Title = "إضاءة كاملة (FullBright)",
    Callback = function(state)
        local lighting = game:GetService("Lighting")
        lighting.GlobalShadows  = not state
        lighting.Brightness     = state and 2 or 1
        lighting.OutdoorAmbient = state
            and Color3.fromRGB(128, 128, 128)
            or  Color3.fromRGB(70, 70, 70)
    end,
})

-- ═══════════ رقصة مايباخ (داخل تبويب السيارات) ═══════════
local danceActive = false
local danceStyle  = "مايباخ"
local danceSpeed  = 1
local danceVelocity, danceGyro

local function findMyVehicle()
    local char = LP.Character
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    local seat = hum and hum.SeatPart
    if not seat then return nil, nil end
    local model = seat:FindFirstAncestorOfClass("Model")
    if not model then return nil, nil end
    return model, model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
end

local function stopMaybach()
    danceActive = false
    if danceVelocity then danceVelocity:Destroy() danceVelocity = nil end
    if danceGyro then danceGyro:Destroy() danceGyro = nil end
end

local function startMaybach()
    stopMaybach()

    local model, base = findMyVehicle()
    if not base then
        notify("رقصة مايباخ", "لازم تكون جالس في سيارة أولاً")
        return
    end

    danceActive = true

    danceVelocity = Instance.new("BodyVelocity")
    danceVelocity.MaxForce = Vector3.new(0, 60000, 0)
    danceVelocity.Velocity = Vector3.zero
    danceVelocity.P        = 9000
    danceVelocity.Parent   = base

    danceGyro = Instance.new("BodyAngularVelocity")
    danceGyro.MaxTorque       = Vector3.new(50000, 50000, 50000)
    danceGyro.AngularVelocity = Vector3.zero
    danceGyro.P               = 9000
    danceGyro.Parent          = base

    -- رخصة مايباخ: إضاءة + نبضة عبر ريموتات اللعبة الحقيقية
    fire("VehicleService", "SetLightbarStage", 3)
    fire("VehicleService", "VehicleNudgeImpulse", Vector3.new(0, 12, 0))

    task.spawn(function()
        while danceActive and base.Parent do
            local t = os.clock() * 3 * danceSpeed

            if danceStyle == "مايباخ" then
                danceVelocity.Velocity = Vector3.new(math.sin(t) * 6, math.abs(math.sin(t)) * 22, math.cos(t) * 6)
                danceGyro.AngularVelocity = Vector3.new(math.sin(t) * 4, 2.5, math.cos(t) * 4)
            elseif danceStyle == "نبض" then
                danceVelocity.Velocity = Vector3.new(0, math.abs(math.sin(t)) * 32, 0)
                danceGyro.AngularVelocity = Vector3.zero
            elseif danceStyle == "دوران" then
                danceVelocity.Velocity = Vector3.new(0, 16, 0)
                danceGyro.AngularVelocity = Vector3.new(0, 14, 0)
            elseif danceStyle == "قفزة" then
                danceVelocity.Velocity = Vector3.new(0, math.sin(t) * 48, 0)
                danceGyro.AngularVelocity = Vector3.new(math.sin(t * 2) * 6, 0, 0)
            end

            task.wait(0.03)
        end
        stopMaybach()
    end)

    notify("رقصة مايباخ 👑", "رخصة مايباخ — السيارة بدأت ترقص!")
end

-- ═══ نطة السيارة العالية ═══
local HopSec = CarTab:Section({ Title = "نطة السيارة 🚀" })

local hopPower = 45

HopSec:Slider({
    Title = "قوة النطة",
    Desc  = "كل ما زادت القيمة طارت السيارة أعلى",
    Step  = 1,
    Value = { Min = 10, Max = 150, Default = 45 },
    Callback = function(v) hopPower = v end,
})

HopSec:Button({
    Title   = "نطة عالية 🚀",
    Icon    = "rocket",
    Color   = Color3.fromHex("#b3122e"),
    Justify = "Center",
    Callback = function()
        local model, base = findMyVehicle()
        if not base then
            notify("النطة", "اركب سيارة أولاً")
            return
        end
        -- إشعار للعبة عبر ريموتها الحقيقي
        fire("VehicleService", "VehicleNudgeImpulse", Vector3.new(0, hopPower, 0))
        -- دفع محلي مباشر ومضمون للصعود
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(0, 120000, 0)
        bv.Velocity = Vector3.new(0, hopPower * 2, 0)
        bv.P        = 9000
        bv.Parent   = base
        task.delay(0.22, function() bv:Destroy() end)
        notify("النطة 🚀", "انطلقت السيارة بقوة " .. hopPower)
    end,
})

local DanceSec = CarTab:Section({ Title = "رقصة مايباخ 👑" })

DanceSec:Section({
    Title = "رخصة مايباخ — MAYBACH EDITION",
    TextSize = 15,
    TextTransparency = 0.25,
})

DanceSec:Dropdown({
    Title  = "ستايل الرقصة",
    Values = { "مايباخ", "نبض", "دوران", "قفزة" },
    Value  = "مايباخ",
    Callback = function(opt) danceStyle = opt end,
})

DanceSec:Slider({
    Title = "سرعة الرقصة",
    Step  = 0.1,
    Value = { Min = 0.5, Max = 3, Default = 1 },
    Callback = function(v) danceSpeed = v end,
})

DanceSec:Toggle({
    Title = "تشغيل رقصة مايباخ 👑",
    Desc  = "اركب سيارة أولاً — رخصة مايباخ ترفع السيارة وتجعلها ترقص",
    Callback = function(state)
        if state then
            startMaybach()
        else
            stopMaybach()
            notify("رقصة مايباخ", "توقفت الرقصة")
        end
    end,
})

-- ═══════════ تبويب: الأيم بوت + FOV ═══════════
local aimEnabled, aimTeamCheck = false, true
local aimFOV, aimSmooth, aimPart = 120, 8, "Head"
local fovVisible = true

-- إنشاء دائرة FOV بأمان (pcall يعمل في كل المشغّلات حتى لو Drawing نوعه userdata)
local fovCircle
pcall(function()
    fovCircle = Drawing.new("Circle")
    fovCircle.Color        = Color3.fromHex("#ff2d3f")
    fovCircle.Thickness    = 1.6
    fovCircle.Filled       = false
    fovCircle.Transparency = 1
    fovCircle.NumSides     = 64
    fovCircle.Visible      = false
end)

-- مركز التصويب = مكان الماوس (نفس مكان الدائرة — زي السايلنت آيم)
local function aimCenter()
    local cam = workspace.CurrentCamera
    local ok, pos = pcall(function()
        return UIS:GetMouseLocation()
    end)
    if ok and pos then
        return Vector2.new(pos.X, pos.Y)
    end
    return Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y / 2)
end

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude

local function aimVisible(part)
    local cam = workspace.CurrentCamera
    local hit = workspace:Raycast(cam.CFrame.Position, part.Position - cam.CFrame.Position, rayParams)
    return hit == nil or hit.Instance:IsDescendantOf(part.Parent)
end

local function getAimTarget(center)
    local cam = workspace.CurrentCamera
    local best, bestDist = nil, math.huge

    for _, plr in ipairs(Players:GetPlayers()) do
        -- فحص فريق صحيح: لو الفريقين مختلفين أو أحدهم بلا فريق = يعتبر عدو
        local myTeam   = LP.Team
        local hisTeam  = plr.Team
        local isFriend = aimTeamCheck and myTeam ~= nil and hisTeam == myTeam

        if plr ~= LP and plr.Character and not isFriend then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local part = plr.Character:FindFirstChild(aimPart)
                    or plr.Character:FindFirstChild("HumanoidRootPart")
                if part and aimVisible(part) then
                    local pos, onScreen = cam:WorldToViewportPoint(part.Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist <= aimFOV and dist < bestDist then
                            bestDist = dist
                            best = part
                        end
                    end
                end
            end
        end
    end

    return best
end

RunSvc.RenderStepped:Connect(function()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local center = aimCenter()

    -- الدائرة تلزق مكان الماوس وتتحدث كل إطار
    if fovCircle then
        fovCircle.Position = center
        fovCircle.Radius   = aimFOV
        fovCircle.Visible  = aimEnabled and fovVisible
    end

    if not aimEnabled then return end
    rayParams.FilterDescendantsInstances = { LP.Character }

    local target = getAimTarget(center)
    if target then
        local pos = target.Position
        if aimPart == "Head" then
            pos += Vector3.new(0, 0.15, 0)
        end
        local goal  = CFrame.lookAt(cam.CFrame.Position, pos)
        local alpha = math.clamp(1 / (aimSmooth ^ 0.9), 0.06, 0.9)
        cam.CFrame  = cam.CFrame:Lerp(goal, alpha)
    end
end)

local AimSec = AimTab:Section({ Title = "التصويب التلقائي (Aimbot)" })

AimSec:Toggle({
    Title = "تفعيل الأيم بوت",
    Desc  = "يصوّب على أقرب هدف لدائرة FOV (مع فحص الجدران)",
    Callback = function(state)
        aimEnabled = state
        notify("Aimbot", state and "الأيم بوت شغّال" or "الأيم بوت متوقف")
    end,
})

AimSec:Keybind({
    Title   = "زر الأيم بوت السريع",
    Default = "Q",
    Callback = function()
        aimEnabled = not aimEnabled
        notify("Aimbot", aimEnabled and "شغّال" or "متوقف")
    end,
})

AimSec:Toggle({
    Title = "إظهار دائرة FOV",
    Value = true,
    Callback = function(state) fovVisible = state end,
})

AimSec:Slider({
    Title = "نطاق التصويب (FOV)",
    Desc  = "نصف قطر الدائرة بالبكسل حول الماوس",
    Step  = 5,
    Value = { Min = 20, Max = 500, Default = 120 },
    Callback = function(v) aimFOV = v end,
})

AimSec:Slider({
    Title = "سلاسة التصويب",
    Desc  = "1 = فوري · 20 = ناعم جداً",
    Step  = 1,
    Value = { Min = 1, Max = 20, Default = 8 },
    Callback = function(v) aimSmooth = v end,
})

AimSec:Dropdown({
    Title  = "الجزء المستهدف",
    Values = { "الرأس (Head)", "الجسم (Root)" },
    Value  = "الرأس (Head)",
    Callback = function(opt)
        aimPart = (opt == "الرأس (Head)") and "Head" or "HumanoidRootPart"
    end,
})

AimSec:Toggle({
    Title = "تجاهل أعضاء فريقي",
    Value = true,
    Callback = function(state)
        aimTeamCheck = state
        notify("Aimbot", state and "لن يصوّب على فريقك" or "يصوّب على الجميع — مهم في مابات الـRP")
    end,
})

local CamSec = AimTab:Section({ Title = "مجال الرؤية (Camera FOV)" })

CamSec:Slider({
    Title = "Camera FOV",
    Desc  = "ملاحظة: اللعبة قد تعيد ضبطه تلقائياً",
    Step  = 1,
    Value = { Min = 70, Max = 120, Default = 70 },
    Callback = function(v)
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = v end
    end,
})

CamSec:Button({
    Title = "إعادة ضبط مجال الرؤية",
    Icon  = "rotate-ccw",
    Callback = function()
        local cam = workspace.CurrentCamera
        if cam then cam.FieldOfView = 70 end
        notify("FOV", "تمت إعادة ضبط الكاميرا إلى 70")
    end,
})

CamSec:Section({
    Title = "إذا لم يصوّب على أحد: أوقف (تجاهل فريقي) لأن مابات الـRP غالباً تخلي الجميع بنفس الفريق. وإذا لم تظهر الدائرة فمشغّلك لا يدعم Drawing والأيم بوت يعمل بدونها.",
    TextTransparency = 0.4,
})

-- ═══════════ تبويب: تجريبي ═══════════
local ExpSec = ExpTab:Section({
    Title = "FeatureFlagService — ريموتات ADMIN (تجريبي)",
    TextSize = 13,
})

ExpSec:Section({
    Title = "هذه الريموتات مكتشفة من الفحص وقد ترفضها صلاحيات السيرفر — جرّبها على مسؤوليتك.",
    TextTransparency = 0.4,
})

ExpSec:Button({
    Title = "جلب كل الأعلام (GetAllFlagsADMIN)",
    Icon  = "crown",
    Callback = function()
        local ok, flags = invoke("FeatureFlagService", "GetAllFlagsADMIN")
        if ok then
            print(flags)
            notify("ADMIN", "نجح — افتح الكونسول F9 لرؤية الأعلام")
        else
            notify("ADMIN", "السيرفر رفض — تحتاج صلاحيات")
        end
    end,
})

local flagName, flagVal = "", true
ExpSec:Input({
    Title       = "اسم الفلاغ",
    Placeholder = "FlagName",
    Callback    = function(text) flagName = text end,
})

ExpSec:Dropdown({
    Title  = "القيمة",
    Values = { "true", "false" },
    Value  = "true",
    Callback = function(opt) flagVal = (opt == "true") end,
})

ExpSec:Button({
    Title = "تعيين الفلاغ (SetFlagADMIN)",
    Icon  = "flask-conical",
    Color = Color3.fromHex("#b3122e"),
    Callback = function()
        if flagName == "" then
            notify("ADMIN", "اكتب اسم الفلاغ أولاً")
            return
        end
        local ok = invoke("FeatureFlagService", "SetFlagADMIN", flagName, flagVal)
        notify("ADMIN", ok and "تم إرسال الطلب" or "مرفوض من السيرفر")
    end,
})

-- ═══════════ تبويب: الإعدادات ═══════════
local SetSec = SetTab:Section({ Title = "إعدادات الواجهة" })

SetSec:Slider({
    Title = "حجم الواجهة (UIScale)",
    Step  = 0.05,
    Value = { Min = 0.7, Max = 1.3, Default = 1 },
    Callback = function(v) Window:SetUIScale(v) end,
})

SetSec:Input({
    Title       = "عنوان النافذة",
    Default     = "SLAX HUB",
    Placeholder = "اكتب اسماً جديداً...",
    Callback    = function(text) Window:SetTitle(text) end,
})

SetSec:Button({
    Title   = "إغلاق الواجهة نهائياً",
    Icon    = "trash-2",
    Color   = Color3.fromHex("#ff2d3f"),
    Justify = "Center",
    Callback = function() Window:Destroy() end,
})
