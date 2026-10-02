-- ════════════════════════════════════════════════════════════════
--   K I L L S T A M   H U B   —   UI โฉมใหม่ (ฟาร์ม • ร้านค้า • วาร์ป • เรดาร์ • ผู้เล่น)
--   RightShift = ซ่อน/แสดงเมนู  •  ลากแถบหัวเมนูเพื่อย้ายตำแหน่ง
-- ════════════════════════════════════════════════════════════════
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- กันสคริปต์ซ้อนกันเวลารันใหม่ (ลูปของรอบก่อนจะหยุดเอง)
getgenv().KillstamSession = (getgenv().KillstamSession or 0) + 1
local SESSION = getgenv().KillstamSession
local function alive()
    return getgenv().KillstamSession == SESSION
end

for _, oldName in ipairs({ "KillstamHub", "PiriyaMenuHub" }) do
    local old = CoreGui:FindFirstChild(oldName)
    if old then
        old:Destroy()
    end
end

-- ═════════════════════════ รายงานการใช้งาน (Discord Webhook) ═════════════════════════
-- ใส่ลิงก์ webhook ของห้อง Discord ที่อยากให้แจ้งเตือน (เว้นว่าง = ไม่ส่ง)
local WEBHOOK_URL = "https://discord.com/api/webhooks/1552637151089393684/7024Z_6lDfzdyua8KgVLNEmNSieMQ6gxx6ymchOF9Exh8UFZDAHLiVcXBciAYp5jWtFm"

-- ส่งแค่ครั้งแรกที่รันในเซิร์ฟนั้น รันสคริปต์ซ้ำจะไม่ส่งซ้ำ (กันสแปม)
if WEBHOOK_URL ~= "" then
    task.spawn(function()
        local httpRequest = request or http_request or (syn and syn.request)
        if not httpRequest then
            return
        end
        local executor = identifyexecutor and identifyexecutor() or "ไม่ทราบ"
        local gameName = "ไม่ทราบ"
        pcall(function()
            gameName = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        local embed = {
            title = "มีคนรัน KILLSTAM",
            color = 0xFF2E63,
            fields = {
                {
                    name = "ผู้เล่น",
                    value = string.format(
                        "[%s (@%s)](https://www.roblox.com/users/%d/profile)",
                        LocalPlayer.DisplayName,
                        LocalPlayer.Name,
                        LocalPlayer.UserId
                    ),
                    inline = true,
                },
                { name = "UserId", value = tostring(LocalPlayer.UserId), inline = true },
                { name = "ตัวรัน", value = tostring(executor), inline = true },
                {
                    name = "เกม",
                    value = string.format("[%s](https://www.roblox.com/games/%d)", gameName, game.PlaceId),
                    inline = false,
                },
            },
            footer = { text = "KILLSTAM HUB v2.0" },
            timestamp = DateTime.now():ToIsoDate(),
        }
        pcall(httpRequest, {
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = game:GetService("HttpService"):JSONEncode({ embeds = { embed } }),
        })
    end)
end

-- ═════════════════════════ ธีมสี ═════════════════════════
local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)
local SCOPE_GREEN = Color3.fromRGB(90, 230, 130)

local Theme = {
    Bg = Color3.fromRGB(11, 9, 18),
    Panel = Color3.fromRGB(17, 14, 28),
    Card = Color3.fromRGB(24, 20, 39),
    CardHover = Color3.fromRGB(33, 27, 53),
    Stroke = Color3.fromRGB(62, 50, 98),
    Off = Color3.fromRGB(44, 38, 66),
    KnobOff = Color3.fromRGB(165, 158, 195),
    Text = Color3.fromRGB(246, 244, 255),
    SubText = Color3.fromRGB(150, 142, 184),
    Muted = Color3.fromRGB(96, 89, 128),
    Crimson = Color3.fromRGB(255, 46, 99),
    Ember = Color3.fromRGB(255, 128, 64),
    Gold = Color3.fromRGB(255, 196, 77),
    Violet = Color3.fromRGB(160, 92, 255),
    Pink = Color3.fromRGB(255, 75, 220),
    Cyan = Color3.fromRGB(0, 214, 255),
    Mint = Color3.fromRGB(64, 230, 160),
}
local TITLE_COLORS = { Theme.Crimson, Theme.Ember, Theme.Gold, WHITE, Theme.Violet, Theme.Crimson }

-- ═════════════════════════ ตัวช่วยสร้าง UI ═════════════════════════
local function create(className, props)
    local inst = Instance.new(className)
    local parent
    for key, value in pairs(props or {}) do
        if key == "Parent" then
            parent = value
        else
            inst[key] = value
        end
    end
    if parent then
        inst.Parent = parent
    end
    return inst
end

local function corner(parent, radius)
    return create("UICorner", { CornerRadius = UDim.new(0, radius or 10), Parent = parent })
end

local function round(parent)
    return create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
    return create("UIStroke", {
        Color = color,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = parent,
    })
end

local function colorSeq(colors)
    local keys = {}
    for i, c in ipairs(colors) do
        keys[i] = ColorSequenceKeypoint.new((i - 1) / (#colors - 1), c)
    end
    return ColorSequence.new(keys)
end

local function fadeSeq(points)
    local keys = {}
    for i, p in ipairs(points) do
        keys[i] = NumberSequenceKeypoint.new(p[1], p[2])
    end
    return NumberSequence.new(keys)
end

local function gradient(parent, colors, rotation, transparency)
    return create("UIGradient", {
        Color = colorSeq(colors),
        Rotation = rotation or 0,
        Transparency = transparency,
        Parent = parent,
    })
end

local function tween(obj, duration, props, style, direction)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

local function text(parent, props)
    local merged = {
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = parent,
    }
    for key, value in pairs(props) do
        merged[key] = value
    end
    return create("TextLabel", merged)
end

-- gradient ที่หมุนวน / ไล่แสงวิ้งๆ (อัปเดตใน RenderStepped)
local spinners = {}
local function spin(grad, speed)
    table.insert(spinners, { grad, speed })
    return grad
end

local shimmers = {}
local function shimmer(grad, speed)
    table.insert(shimmers, { grad, speed })
    return grad
end

local function isPress(input)
    return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function chipSequence(accent)
    return colorSeq({ accent:Lerp(WHITE, 0.3), accent, accent:Lerp(BLACK, 0.45) })
end

-- ไอคอนแบบชิปไล่สี (แทนอิโมจิ)
local function iconChip(parent, glyph, accent, size)
    local chip = create("Frame", {
        Name = "Icon",
        Size = UDim2.fromOffset(size, size),
        BackgroundColor3 = WHITE,
        Parent = parent,
    })
    corner(chip, math.floor(size * 0.3))
    local grad = create("UIGradient", { Color = chipSequence(accent), Rotation = 135, Parent = chip })
    local chipStroke = stroke(chip, accent:Lerp(WHITE, 0.35), 1, 0.5)
    local length = utf8.len(glyph) or #glyph
    local textScale = length <= 1 and 0.5 or (length == 2 and 0.36 or 0.28)
    local label = text(chip, {
        Size = UDim2.fromScale(1, 1),
        Font = Enum.Font.GothamBlack,
        Text = glyph,
        TextColor3 = WHITE,
        TextSize = math.floor(size * textScale),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextStrokeTransparency = 0.65,
    })
    return chip, label, grad, chipStroke
end

-- เอฟเฟกต์คลื่นตอนกดปุ่ม
local function attachRipple(button, getColor)
    button.ClipsDescendants = true
    button.InputBegan:Connect(function(input)
        if not isPress(input) then
            return
        end
        local absPos, absSize = button.AbsolutePosition, button.AbsoluteSize
        if absSize.X <= 0 or absSize.Y <= 0 then
            return
        end
        local circle = create("Frame", {
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(
                (input.Position.X - absPos.X) / absSize.X,
                (input.Position.Y - absPos.Y) / absSize.Y
            ),
            Size = UDim2.fromScale(0, 0),
            SizeConstraint = Enum.SizeConstraint.RelativeXX,
            BackgroundColor3 = getColor and getColor() or WHITE,
            BackgroundTransparency = 0.7,
            ZIndex = 0,
            Parent = button,
        })
        round(circle)
        tween(circle, 0.6, { Size = UDim2.fromScale(2.4, 2.4), BackgroundTransparency = 1 }, Enum.EasingStyle.Quad)
        task.delay(0.65, function()
            circle:Destroy()
        end)
    end)
end

-- ลากย้ายได้ทั้งเมาส์และจอสัมผัส (คืนฟังก์ชันเช็คว่าเพิ่งลากหรือเปล่า)
local function makeDraggable(handle, target)
    local dragging, moved = false, false
    local dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if not isPress(input) then
            return
        end
        dragging, moved = true, false
        dragStart, startPos = input.Position, target.Position
        local conn
        conn = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                conn:Disconnect()
            end
        end)
    end)
    UserInputService.InputChanged:Connect(function(input)
        if not dragging then
            return
        end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
            return
        end
        local delta = input.Position - dragStart
        if delta.Magnitude > 4 then
            moved = true
        end
        if moved then
            target.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    return function()
        return moved
    end
end

-- ═════════════════════════ ค่าเริ่มต้นระบบ ═════════════════════════
getgenv().AutoDigActive = false
getgenv().AutoInteractActive = false
getgenv().DigDelayValue = 0.05
getgenv().WalkSpeedActive = false
getgenv().CustomWalkSpeed = 30
getgenv().ActiveRadarId = nil
getgenv().AllRadarsActive = false
getgenv().HighestOnlyActive = false
getgenv().GiantScanActive = false
getgenv().MillionScanActive = false
getgenv().PlayerESPActive = false
getgenv().SpectateActive = false
local savedPosition = nil
local currentPositionBeforeTp = nil

local ScreenGui = create("ScreenGui", {
    Name = "KillstamHub",
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    ResetOnSpawn = false,
    DisplayOrder = 50,
    Parent = CoreGui,
})

-- ═════════════════════════ การแจ้งเตือน (Toast) ═════════════════════════
local ToastHolder = create("Frame", {
    Name = "Toasts",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 12),
    Size = UDim2.fromOffset(300, 280),
    BackgroundTransparency = 1,
    ZIndex = 20,
    Parent = ScreenGui,
})
create("UIListLayout", {
    SortOrder = Enum.SortOrder.LayoutOrder,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    Padding = UDim.new(0, 8),
    Parent = ToastHolder,
})

local toastCount = 0
local function notify(title, message, accent, icon, duration)
    accent = accent or Theme.Crimson
    duration = duration or 2.4
    toastCount = toastCount + 1

    local slots = {}
    for _, child in ipairs(ToastHolder:GetChildren()) do
        if child:IsA("Frame") then
            table.insert(slots, child)
        end
    end
    table.sort(slots, function(a, b)
        return a.LayoutOrder < b.LayoutOrder
    end)
    for i = 1, #slots - 3 do
        slots[i]:Destroy()
    end

    local slot = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(300, 58),
        LayoutOrder = toastCount,
        Parent = ToastHolder,
    })
    local card = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = WHITE,
        Parent = slot,
    })
    corner(card, 12)
    gradient(card, { accent:Lerp(Theme.Panel, 0.78), Theme.Panel }, 0)
    stroke(card, accent, 1.2, 0.25)
    local cardScale = create("UIScale", { Scale = 0.6, Parent = card })
    local chip = iconChip(card, icon or "!", accent, 34)
    chip.Position = UDim2.fromOffset(12, 12)
    text(card, {
        Position = UDim2.fromOffset(56, 10),
        Size = UDim2.new(1, -66, 0, 18),
        Text = title,
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    text(card, {
        Position = UDim2.fromOffset(56, 29),
        Size = UDim2.new(1, -66, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = message,
        TextColor3 = Theme.SubText,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local timer = create("Frame", {
        Position = UDim2.new(0, 12, 1, -4),
        Size = UDim2.new(1, -24, 0, 2),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Parent = card,
    })
    round(timer)

    tween(cardScale, 0.45, { Scale = 1 }, Enum.EasingStyle.Back)
    tween(timer, duration, { Size = UDim2.new(0, 0, 0, 2) }, Enum.EasingStyle.Linear)
    task.delay(duration, function()
        if not slot.Parent then
            return
        end
        tween(cardScale, 0.25, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
        task.wait(0.25)
        slot:Destroy()
    end)
end

-- ═════════════════════════ หน้าต่างหลัก ═════════════════════════
local WINDOW_W, WINDOW_H = 560, 500
local COLLAPSED_H = 78
local BODY_H = WINDOW_H - 120

local MainFrame = create("Frame", {
    Name = "MainFrame",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0.5, -WINDOW_H / 2),
    Size = UDim2.fromOffset(WINDOW_W, WINDOW_H),
    BackgroundColor3 = WHITE,
    Active = true,
    ClipsDescendants = true,
    Visible = false,
    Parent = ScreenGui,
})
corner(MainFrame, 16)
gradient(MainFrame, { Color3.fromRGB(26, 10, 26), Theme.Bg, Color3.fromRGB(10, 10, 28) }, 125)
local MainStroke = stroke(MainFrame, WHITE, 2, 0)
spin(gradient(MainStroke, { Theme.Gold, Theme.Crimson, Theme.Violet, Theme.Cyan, Theme.Gold }), 70)
local WindowScale = create("UIScale", { Parent = MainFrame })

-- ลูกแก้วเรืองแสงลอยอยู่ด้านหลัง
local function orb(color, diameter, position, drift)
    local outer = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = position,
        Size = UDim2.fromOffset(diameter, diameter),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.93,
        ZIndex = 0,
        Parent = MainFrame,
    })
    round(outer)
    local inner = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(0.55, 0.55),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.88,
        ZIndex = 0,
        Parent = outer,
    })
    round(inner)
    TweenService:Create(outer, TweenInfo.new(7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        Position = position + drift,
    }):Play()
end
orb(Theme.Crimson, 240, UDim2.fromScale(0.8, 0.32), UDim2.fromOffset(-24, 14))
orb(Theme.Violet, 230, UDim2.fromScale(0.3, 0.72), UDim2.fromOffset(26, -16))
orb(Theme.Cyan, 150, UDim2.fromScale(0.58, 0.82), UDim2.fromOffset(-14, -18))

-- ─────────── แบนเนอร์หัวเมนู ───────────
local Banner = create("Frame", {
    Name = "Banner",
    Position = UDim2.fromOffset(8, 8),
    Size = UDim2.new(1, -16, 0, 62),
    BackgroundColor3 = WHITE,
    BackgroundTransparency = 0.05,
    Active = true,
    ClipsDescendants = true,
    Parent = MainFrame,
})
corner(Banner, 12)
gradient(Banner, { Color3.fromRGB(80, 14, 44), Color3.fromRGB(40, 14, 64), Color3.fromRGB(14, 20, 52) }, 0)
local BannerStroke = stroke(Banner, WHITE, 1, 0.5)
spin(gradient(BannerStroke, { Theme.Crimson, Theme.Violet, Theme.Gold, Theme.Crimson }), 40)

local LogoRing = create("Frame", {
    Position = UDim2.fromOffset(8, 7),
    Size = UDim2.fromOffset(48, 48),
    BackgroundTransparency = 1,
    Parent = Banner,
})
corner(LogoRing, 14)
local LogoRingStroke = stroke(LogoRing, WHITE, 2, 0.2)
spin(gradient(LogoRingStroke, { Theme.Gold, Theme.Crimson, Theme.Violet, Theme.Gold }), 140)

local Logo = create("Frame", {
    Position = UDim2.fromOffset(12, 11),
    Size = UDim2.fromOffset(40, 40),
    BackgroundColor3 = WHITE,
    Parent = Banner,
})
corner(Logo, 11)
spin(gradient(Logo, { Theme.Crimson, Color3.fromRGB(110, 16, 60), Theme.Violet }), 50)
text(Logo, {
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBlack,
    Text = "K",
    TextColor3 = WHITE,
    TextSize = 24,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextStrokeTransparency = 0.5,
})

-- ชื่อ KILLSTAM + เงาแดง/ฟ้าแบบ glitch
local TITLE_POS = UDim2.fromOffset(66, 5)
local GHOST_A_POS = TITLE_POS + UDim2.fromOffset(-2, 0)
local GHOST_B_POS = TITLE_POS + UDim2.fromOffset(2, 1)
local function titleLayer(color, transparency, position)
    return text(Banner, {
        Position = position,
        Size = UDim2.fromOffset(230, 32),
        Font = Enum.Font.GothamBlack,
        Text = "KILLSTAM",
        TextColor3 = color,
        TextTransparency = transparency,
        TextSize = 28,
    })
end
local TitleGhostA = titleLayer(Theme.Crimson, 0.35, GHOST_A_POS)
local TitleGhostB = titleLayer(Theme.Cyan, 0.5, GHOST_B_POS)
local TitleMain = titleLayer(WHITE, 0, TITLE_POS)
shimmer(gradient(TitleMain, TITLE_COLORS), 0.35)
create("UIStroke", {
    Color = Color3.fromRGB(120, 10, 40),
    Thickness = 1.2,
    Transparency = 0.2,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
    Parent = TitleMain,
})

local EditionPill = text(Banner, {
    Position = UDim2.fromOffset(67, 39),
    Size = UDim2.fromOffset(64, 16),
    BackgroundTransparency = 0,
    BackgroundColor3 = WHITE,
    Font = Enum.Font.GothamBlack,
    Text = "ULTIMATE",
    TextColor3 = Color3.fromRGB(40, 20, 0),
    TextSize = 9,
    TextXAlignment = Enum.TextXAlignment.Center,
})
round(EditionPill)
shimmer(gradient(EditionPill, { Theme.Gold, Color3.fromRGB(255, 240, 190), Theme.Ember, Theme.Gold }), 0.5)
text(Banner, {
    Position = UDim2.fromOffset(138, 38),
    Size = UDim2.fromOffset(160, 18),
    Text = "MINING SUITE  •  v2.0",
    TextColor3 = Theme.SubText,
    TextSize = 10,
})

-- โปรไฟล์ผู้เล่น
local HeaderAvatar = create("Frame", {
    AnchorPoint = Vector2.new(1, 0.5),
    Position = UDim2.new(1, -80, 0.5, 0),
    Size = UDim2.fromOffset(38, 38),
    BackgroundColor3 = Color3.fromRGB(38, 31, 67),
    Parent = Banner,
})
round(HeaderAvatar)
local HeaderAvatarStroke = stroke(HeaderAvatar, WHITE, 2, 0)
gradient(HeaderAvatarStroke, { Color3.fromRGB(255, 243, 196), Theme.Gold, Color3.fromRGB(186, 117, 23) }, 45)
local AvatarImage = create("ImageLabel", {
    Name = "PlayerThumbnail",
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ImageTransparency = 1,
    ScaleType = Enum.ScaleType.Crop,
    ZIndex = 2,
    Parent = HeaderAvatar,
})
round(AvatarImage)
local AvatarInitial = text(HeaderAvatar, {
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBlack,
    Text = string.sub(LocalPlayer.Name, 1, 1):upper(),
    TextColor3 = Color3.fromRGB(255, 243, 196),
    TextSize = 18,
    TextXAlignment = Enum.TextXAlignment.Center,
})
local OnlineDot = create("Frame", {
    AnchorPoint = Vector2.new(1, 1),
    Position = UDim2.new(1, 1, 1, 1),
    Size = UDim2.fromOffset(11, 11),
    BackgroundColor3 = Theme.Mint,
    ZIndex = 3,
    Parent = HeaderAvatar,
})
round(OnlineDot)
stroke(OnlineDot, Color3.fromRGB(30, 16, 50), 2, 0)

text(Banner, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -126, 0, 12),
    Size = UDim2.fromOffset(150, 18),
    Text = LocalPlayer.DisplayName,
    TextSize = 13,
    TextXAlignment = Enum.TextXAlignment.Right,
    TextTruncate = Enum.TextTruncate.AtEnd,
})
text(Banner, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -126, 0, 31),
    Size = UDim2.fromOffset(150, 14),
    Font = Enum.Font.GothamMedium,
    Text = "@" .. LocalPlayer.Name,
    TextColor3 = Theme.SubText,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Right,
    TextTruncate = Enum.TextTruncate.AtEnd,
})

local function headerButton(glyph, xOffset, hoverColor, textSize)
    local btn = create("TextButton", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, xOffset, 0.5, 0),
        Size = UDim2.fromOffset(26, 26),
        AutoButtonColor = false,
        BackgroundColor3 = WHITE,
        BackgroundTransparency = 0.92,
        Font = Enum.Font.GothamBold,
        Text = glyph,
        TextColor3 = Theme.Text,
        TextSize = textSize,
        Parent = Banner,
    })
    corner(btn, 8)
    btn.MouseEnter:Connect(function()
        tween(btn, 0.15, { BackgroundColor3 = hoverColor, BackgroundTransparency = 0.1 })
    end)
    btn.MouseLeave:Connect(function()
        tween(btn, 0.15, { BackgroundColor3 = WHITE, BackgroundTransparency = 0.92 })
    end)
    return btn
end
local CloseBtn = headerButton("×", -10, Theme.Crimson, 18)
local MinBtn = headerButton("—", -42, Theme.Violet, 12)

-- ─────────── แถบข้าง / พื้นที่เนื้อหา / แถบสถานะ ───────────
local Sidebar = create("Frame", {
    Name = "Sidebar",
    Position = UDim2.fromOffset(8, 78),
    Size = UDim2.fromOffset(142, BODY_H),
    BackgroundColor3 = Theme.Panel,
    BackgroundTransparency = 0.2,
    Parent = MainFrame,
})
corner(Sidebar, 12)
stroke(Sidebar, Theme.Stroke, 1, 0.5)

local Content = create("Frame", {
    Name = "Content",
    Position = UDim2.fromOffset(158, 78),
    Size = UDim2.fromOffset(394, BODY_H),
    BackgroundTransparency = 1,
    ClipsDescendants = true,
    Parent = MainFrame,
})

local Footer = create("Frame", {
    Name = "Footer",
    Position = UDim2.fromOffset(8, WINDOW_H - 34),
    Size = UDim2.new(1, -16, 0, 26),
    BackgroundColor3 = Theme.Panel,
    BackgroundTransparency = 0.2,
    Parent = MainFrame,
})
corner(Footer, 8)
stroke(Footer, Theme.Stroke, 1, 0.5)
local StatusDot = create("Frame", {
    AnchorPoint = Vector2.new(0, 0.5),
    Position = UDim2.new(0, 11, 0.5, 0),
    Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = Theme.Mint,
    Parent = Footer,
})
round(StatusDot)
local StatusLabel = text(Footer, {
    Position = UDim2.fromOffset(26, 0),
    Size = UDim2.new(1, -236, 1, 0),
    Font = Enum.Font.GothamMedium,
    Text = "สถานะ: พร้อมใช้งาน",
    TextSize = 11,
    TextTruncate = Enum.TextTruncate.AtEnd,
})
local FooterRight = text(Footer, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -11, 0, 0),
    Size = UDim2.new(0, 200, 1, 0),
    Text = "FPS --   •   RShift ซ่อนเมนู",
    TextColor3 = Theme.Muted,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Right,
})

local function setStatus(message, color)
    StatusLabel.Text = "สถานะ: " .. message
    StatusDot.BackgroundColor3 = color or Theme.Mint
end

-- ─────────── แผง LIVE (ไฟบอกระบบที่เปิดอยู่) ───────────
local LIVE_ITEMS = {
    { key = "dig", name = "ขุดอัตโนมัติ", color = Theme.Crimson },
    { key = "interact", name = "กด E", color = Theme.Ember },
    { key = "speed", name = "ความเร็ว", color = Theme.Cyan },
    { key = "radar", name = "เรดาร์", color = Theme.Violet },
    { key = "esp", name = "ESP ผู้เล่น", color = Theme.Pink },
    { key = "spec", name = "สเปคจอ", color = Theme.Gold },
}
local LIVE_H = 26 + #LIVE_ITEMS * 15

local LivePanel = create("Frame", {
    Position = UDim2.new(0, 8, 1, -(LIVE_H + 8)),
    Size = UDim2.new(1, -16, 0, LIVE_H),
    BackgroundColor3 = Theme.Card,
    BackgroundTransparency = 0.25,
    Parent = Sidebar,
})
corner(LivePanel, 10)
stroke(LivePanel, Theme.Stroke, 1, 0.5)
text(LivePanel, {
    Position = UDim2.fromOffset(10, 6),
    Size = UDim2.new(1, -20, 0, 14),
    Font = Enum.Font.GothamBlack,
    Text = "● LIVE",
    TextColor3 = Theme.Crimson,
    TextSize = 10,
})
local LiveCount = text(LivePanel, {
    Position = UDim2.fromOffset(10, 6),
    Size = UDim2.new(1, -20, 0, 14),
    Font = Enum.Font.GothamBlack,
    Text = "0/" .. #LIVE_ITEMS,
    TextColor3 = Theme.SubText,
    TextSize = 10,
    TextXAlignment = Enum.TextXAlignment.Right,
})

local liveRows = {}
for i, item in ipairs(LIVE_ITEMS) do
    local y = 24 + (i - 1) * 15
    local dot = create("Frame", {
        Position = UDim2.fromOffset(11, y + 4),
        Size = UDim2.fromOffset(6, 6),
        BackgroundColor3 = Theme.Off,
        Parent = LivePanel,
    })
    round(dot)
    liveRows[item.key] = {
        dot = dot,
        glow = stroke(dot, item.color, 2, 1),
        name = text(LivePanel, {
            Position = UDim2.fromOffset(24, y),
            Size = UDim2.new(1, -60, 0, 14),
            Font = Enum.Font.GothamMedium,
            Text = item.name,
            TextColor3 = Theme.SubText,
            TextSize = 10,
        }),
        state = text(LivePanel, {
            Position = UDim2.fromOffset(10, y),
            Size = UDim2.new(1, -20, 0, 14),
            Font = Enum.Font.GothamBlack,
            Text = "OFF",
            TextColor3 = Theme.Muted,
            TextSize = 9,
            TextXAlignment = Enum.TextXAlignment.Right,
        }),
        color = item.color,
        on = false,
    }
end

local function refreshLive()
    local states = {
        dig = getgenv().AutoDigActive,
        interact = getgenv().AutoInteractActive,
        speed = getgenv().WalkSpeedActive,
        radar = getgenv().ActiveRadarId ~= nil,
        esp = getgenv().PlayerESPActive,
        spec = getgenv().SpectateActive,
    }
    local count = 0
    for key, row in pairs(liveRows) do
        local on = states[key] == true
        if on then
            count = count + 1
        end
        row.on = on
        tween(row.dot, 0.25, { BackgroundColor3 = on and row.color or Theme.Off })
        tween(row.name, 0.25, { TextColor3 = on and Theme.Text or Theme.SubText })
        row.state.Text = on and "ON" or "OFF"
        row.state.TextColor3 = on and row.color or Theme.Muted
    end
    LiveCount.Text = count .. "/" .. #LIVE_ITEMS
end

-- ═════════════════════════ คอมโพเนนต์ ═════════════════════════
local pages = {}
local function createPage(id, accent)
    local page = create("ScrollingFrame", {
        Name = id .. "Page",
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromScale(1, 1),
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = accent,
        ScrollBarImageTransparency = 0.2,
        Visible = false,
        Parent = Content,
    })
    create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = page })
    create("UIPadding", {
        PaddingTop = UDim.new(0, 2),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 1),
        Parent = page,
    })
    pages[id] = page
    return page
end

local function createPageHeader(page, title, desc, accent)
    local holder = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 48),
        LayoutOrder = 0,
        Parent = page,
    })
    local titleLabel = text(holder, {
        Position = UDim2.fromOffset(2, 0),
        Size = UDim2.new(1, -4, 0, 28),
        Font = Enum.Font.GothamBlack,
        Text = title,
        TextColor3 = WHITE,
        TextSize = 22,
    })
    gradient(titleLabel, { WHITE, accent:Lerp(WHITE, 0.2), accent })
    text(holder, {
        Position = UDim2.fromOffset(2, 29),
        Size = UDim2.new(1, -4, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = desc,
        TextColor3 = Theme.SubText,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local function createSection(page, title, accent, order)
    local holder = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 22),
        LayoutOrder = order,
        Parent = page,
    })
    local bar = create("Frame", {
        Position = UDim2.fromOffset(2, 5),
        Size = UDim2.fromOffset(3, 12),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
        Parent = holder,
    })
    round(bar)
    gradient(bar, { accent:Lerp(WHITE, 0.3), accent }, 90)
    local titleLabel = text(holder, {
        Position = UDim2.fromOffset(12, 2),
        Size = UDim2.new(1, -12, 0, 18),
        Text = title,
        TextColor3 = accent:Lerp(WHITE, 0.35),
        TextSize = 11,
    })
    local line = create("Frame", {
        Position = UDim2.new(0, 2, 1, -1),
        Size = UDim2.new(1, -2, 0, 1),
        BackgroundColor3 = accent,
        BorderSizePixel = 0,
        Parent = holder,
    })
    gradient(line, { accent, accent }, 0, fadeSeq({ { 0, 0.4 }, { 1, 1 } }))
    return titleLabel
end

local function createToggle(page, opts)
    local accent = opts.accent
    local row = create("TextButton", {
        Name = opts.name or "Toggle",
        AutoButtonColor = false,
        Text = "",
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0.08,
        Size = UDim2.new(1, -10, 0, 58),
        LayoutOrder = opts.order,
        Parent = page,
    })
    corner(row, 12)
    local rowStroke = stroke(row, Theme.Stroke, 1, 0.35)
    attachRipple(row, function()
        return accent
    end)

    local bar = create("Frame", {
        Position = UDim2.fromOffset(0, 14),
        Size = UDim2.fromOffset(3, 30),
        BackgroundColor3 = accent,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Parent = row,
    })
    round(bar)
    local chip = iconChip(row, opts.icon, accent, 38)
    chip.Position = UDim2.fromOffset(12, 10)
    text(row, {
        Position = UDim2.fromOffset(60, 11),
        Size = UDim2.new(1, -128, 0, 18),
        Text = opts.title,
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    text(row, {
        Position = UDim2.fromOffset(60, 30),
        Size = UDim2.new(1, -128, 0, 16),
        Font = Enum.Font.Gotham,
        Text = opts.desc,
        TextColor3 = Theme.SubText,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local track = create("Frame", {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -14, 0.5, 0),
        Size = UDim2.fromOffset(46, 24),
        BackgroundColor3 = Theme.Off,
        Parent = row,
    })
    round(track)
    local trackStroke = stroke(track, Theme.Stroke, 1, 0.2)
    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0, 3, 0.5, 0),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = Theme.KnobOff,
        Parent = track,
    })
    round(knob)

    local toggle = { state = false }
    local hovered = false
    local function render()
        local on = toggle.state
        local bg = on and Theme.Card:Lerp(accent, 0.16) or (hovered and Theme.CardHover or Theme.Card)
        tween(row, 0.2, { BackgroundColor3 = bg })
        tween(rowStroke, 0.25, { Color = on and accent or Theme.Stroke, Transparency = on and 0.15 or 0.35 })
        tween(bar, 0.25, { BackgroundTransparency = on and 0 or 1 })
        tween(track, 0.25, { BackgroundColor3 = on and accent or Theme.Off })
        tween(trackStroke, 0.25, { Color = on and accent:Lerp(WHITE, 0.35) or Theme.Stroke })
        tween(knob, 0.35, {
            Position = on and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = on and WHITE or Theme.KnobOff,
        }, Enum.EasingStyle.Back)
    end

    function toggle:Set(on, silent)
        self.state = on
        render()
        if not silent and opts.onToggle then
            opts.onToggle(on)
        end
    end

    row.MouseEnter:Connect(function()
        hovered = true
        render()
    end)
    row.MouseLeave:Connect(function()
        hovered = false
        render()
    end)
    row.MouseButton1Click:Connect(function()
        if opts.onClick then
            opts.onClick()
        else
            toggle:Set(not toggle.state)
        end
    end)
    render()
    return toggle
end

local function createSlider(page, opts)
    local accent = opts.accent
    local fmt = "%." .. (opts.decimals or 0) .. "f"
    local card = create("Frame", {
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0.08,
        Size = UDim2.new(1, -10, 0, 66),
        LayoutOrder = opts.order,
        Parent = page,
    })
    corner(card, 12)
    stroke(card, Theme.Stroke, 1, 0.35)
    text(card, {
        Position = UDim2.fromOffset(14, 9),
        Size = UDim2.new(1, -110, 0, 18),
        Text = opts.title,
        TextSize = 13,
    })
    text(card, {
        Position = UDim2.fromOffset(14, 27),
        Size = UDim2.new(1, -110, 0, 14),
        Font = Enum.Font.Gotham,
        Text = opts.desc,
        TextColor3 = Theme.SubText,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    local box = create("TextBox", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 10),
        Size = UDim2.fromOffset(70, 26),
        BackgroundColor3 = Theme.Bg,
        BackgroundTransparency = 0.2,
        Font = Enum.Font.GothamBold,
        Text = "",
        TextColor3 = accent:Lerp(WHITE, 0.3),
        TextSize = 13,
        ClearTextOnFocus = false,
        Parent = card,
    })
    corner(box, 8)
    local boxStroke = stroke(box, accent, 1, 0.55)

    local track = create("Frame", {
        Position = UDim2.new(0, 14, 0, 48),
        Size = UDim2.new(1, -28, 0, 6),
        BackgroundColor3 = Theme.Off,
        Parent = card,
    })
    round(track)
    local fill = create("Frame", {
        Size = UDim2.fromScale(0, 1),
        BackgroundColor3 = WHITE,
        BorderSizePixel = 0,
        Parent = track,
    })
    round(fill)
    gradient(fill, { accent:Lerp(BLACK, 0.25), accent, accent:Lerp(WHITE, 0.35) })
    local knob = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0, 0.5),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = WHITE,
        Parent = track,
    })
    round(knob)
    stroke(knob, accent, 3, 0.15)
    local hit = create("TextButton", {
        Text = "",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 6, 0, 38),
        Size = UDim2.new(1, -12, 0, 26),
        Parent = card,
    })

    local value = opts.default
    local function render(instant)
        local alpha = math.clamp((value - opts.min) / (opts.max - opts.min), 0, 1)
        if instant then
            fill.Size = UDim2.fromScale(alpha, 1)
            knob.Position = UDim2.fromScale(alpha, 0.5)
        else
            tween(fill, 0.25, { Size = UDim2.fromScale(alpha, 1) })
            tween(knob, 0.25, { Position = UDim2.fromScale(alpha, 0.5) })
        end
        box.Text = string.format(fmt, value)
    end
    local function setValue(v, instant)
        value = v
        render(instant)
        if opts.onChange then
            opts.onChange(value)
        end
    end
    local function setFromX(x)
        local alpha = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
        local raw = opts.min + (opts.max - opts.min) * alpha
        local stepped = tonumber(string.format(fmt, math.floor(raw / opts.step + 0.5) * opts.step))
        setValue(math.clamp(stepped, opts.min, opts.max), true)
    end

    local dragging = false
    hit.InputBegan:Connect(function(input)
        if isPress(input) then
            dragging = true
            tween(knob, 0.15, { Size = UDim2.fromOffset(20, 20) })
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            setFromX(input.Position.X)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if dragging and isPress(input) then
            dragging = false
            tween(knob, 0.15, { Size = UDim2.fromOffset(16, 16) })
        end
    end)
    box.Focused:Connect(function()
        tween(boxStroke, 0.2, { Transparency = 0 })
    end)
    box.FocusLost:Connect(function()
        tween(boxStroke, 0.2, { Transparency = 0.55 })
        local num = tonumber(box.Text)
        if num and num > 0 then
            setValue(num)
        else
            render()
        end
    end)
    render(true)
end

local function createGrid(page, columns, cellHeight, order)
    local grid = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = order,
        Parent = page,
    })
    create("UIGridLayout", {
        CellSize = UDim2.new(1 / columns, -((columns - 1) * 8) / columns, 0, cellHeight),
        CellPadding = UDim2.fromOffset(8, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = grid,
    })
    return grid
end

local function runAction(title, callback)
    local ok, err = pcall(callback)
    if not ok then
        warn("[KILLSTAM] " .. tostring(err))
        notify(title, "เกิดข้อผิดพลาด ลองใหม่อีกครั้ง", Theme.Crimson, "!")
    end
end

local function createActionCard(grid, opts)
    local accent = opts.accent
    local card = create("TextButton", {
        Name = opts.name or "Action",
        AutoButtonColor = false,
        Text = "",
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0.08,
        LayoutOrder = opts.order,
        Parent = grid,
    })
    corner(card, 12)
    local cardStroke = stroke(card, Theme.Stroke, 1, 0.35)
    attachRipple(card, function()
        return accent
    end)
    local glow = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -4),
        Size = UDim2.new(1, -28, 0, 2),
        BackgroundColor3 = accent,
        BackgroundTransparency = 0.6,
        BorderSizePixel = 0,
        Parent = card,
    })
    round(glow)
    local chip = iconChip(card, opts.icon, accent, 40)
    chip.Position = UDim2.fromOffset(12, 12)
    local arrow = text(card, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 12),
        Size = UDim2.fromOffset(20, 20),
        Text = "→",
        TextColor3 = Theme.Muted,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    text(card, {
        Position = UDim2.fromOffset(12, 58),
        Size = UDim2.new(1, -24, 0, 18),
        Text = opts.title,
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    text(card, {
        Position = UDim2.fromOffset(12, 76),
        Size = UDim2.new(1, -24, 0, 16),
        Font = Enum.Font.Gotham,
        Text = opts.desc,
        TextColor3 = Theme.SubText,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })

    card.MouseEnter:Connect(function()
        tween(card, 0.2, { BackgroundColor3 = Theme.CardHover })
        tween(cardStroke, 0.2, { Color = accent, Transparency = 0.25 })
        tween(chip, 0.3, { Rotation = -10 }, Enum.EasingStyle.Back)
        tween(arrow, 0.25, { Position = UDim2.new(1, -7, 0, 12), TextColor3 = accent })
        tween(glow, 0.25, { BackgroundTransparency = 0.05 })
    end)
    card.MouseLeave:Connect(function()
        tween(card, 0.2, { BackgroundColor3 = Theme.Card })
        tween(cardStroke, 0.2, { Color = Theme.Stroke, Transparency = 0.35 })
        tween(chip, 0.3, { Rotation = 0 }, Enum.EasingStyle.Back)
        tween(arrow, 0.25, { Position = UDim2.new(1, -12, 0, 12), TextColor3 = Theme.Muted })
        tween(glow, 0.25, { BackgroundTransparency = 0.6 })
    end)
    card.MouseButton1Click:Connect(function()
        tween(chip, 0.1, { Rotation = 14 }).Completed:Connect(function()
            tween(chip, 0.6, { Rotation = 0 }, Enum.EasingStyle.Elastic)
        end)
        runAction(opts.title, opts.callback)
    end)
    return card
end

local function createActionRow(page, opts)
    local accent = opts.accent
    local row = create("TextButton", {
        AutoButtonColor = false,
        Text = "",
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0.08,
        Size = UDim2.new(1, -10, 0, 52),
        LayoutOrder = opts.order,
        Parent = page,
    })
    corner(row, 12)
    local rowStroke = stroke(row, accent, 1, 0.6)
    attachRipple(row, function()
        return accent
    end)
    local chip = iconChip(row, opts.icon, accent, 32)
    chip.Position = UDim2.fromOffset(12, 10)
    text(row, {
        Position = UDim2.fromOffset(54, 9),
        Size = UDim2.new(1, -96, 0, 18),
        Text = opts.title,
        TextSize = 13,
    })
    text(row, {
        Position = UDim2.fromOffset(54, 27),
        Size = UDim2.new(1, -96, 0, 14),
        Font = Enum.Font.Gotham,
        Text = opts.desc,
        TextColor3 = Theme.SubText,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local arrow = text(row, {
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -16, 0.5, 0),
        Size = UDim2.fromOffset(20, 20),
        Text = "→",
        TextColor3 = accent,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Right,
    })
    row.MouseEnter:Connect(function()
        tween(row, 0.2, { BackgroundColor3 = Theme.Card:Lerp(accent, 0.14) })
        tween(rowStroke, 0.2, { Transparency = 0.15 })
        tween(arrow, 0.25, { Position = UDim2.new(1, -10, 0.5, 0) })
    end)
    row.MouseLeave:Connect(function()
        tween(row, 0.2, { BackgroundColor3 = Theme.Card })
        tween(rowStroke, 0.2, { Transparency = 0.6 })
        tween(arrow, 0.25, { Position = UDim2.new(1, -16, 0.5, 0) })
    end)
    row.MouseButton1Click:Connect(function()
        runAction(opts.title, opts.callback)
    end)
    return row
end

local function fireRemote(remoteName, ...)
    local args = table.pack(...)
    return pcall(function()
        ReplicatedStorage:FindFirstChild(remoteName, true):FireServer(table.unpack(args, 1, args.n))
    end)
end

-- ═════════════════════════ หน้า: ฟาร์ม ═════════════════════════
local FarmPage = createPage("Farm", Theme.Crimson)
createPageHeader(FarmPage, "ฟาร์ม", "ขุด กด E และเร่งความเร็วแบบอัตโนมัติ", Theme.Crimson)
createSection(FarmPage, "ระบบอัตโนมัติ", Theme.Crimson, 1)

createToggle(FarmPage, {
    name = "AutoDigBtn",
    icon = "▼",
    title = "ขุดอัตโนมัติ",
    desc = "ขุดตรงจุดที่เมาส์ชี้ไว้ต่อเนื่อง",
    accent = Theme.Crimson,
    order = 2,
    onToggle = function(on)
        getgenv().AutoDigActive = on
        refreshLive()
        notify("ขุดอัตโนมัติ", on and "เปิดใช้งานแล้ว — ลุยเลย!" or "ปิดใช้งานแล้ว", Theme.Crimson, "▼")
        setStatus(on and "กำลังขุดอัตโนมัติ" or "หยุดขุดอัตโนมัติ", on and Theme.Crimson or Theme.Muted)
    end,
})
createSlider(FarmPage, {
    title = "ช่วงเวลาขุด",
    desc = "วินาทีต่อครั้ง • ยิ่งน้อยยิ่งไว",
    min = 0.01,
    max = 0.5,
    step = 0.01,
    decimals = 2,
    default = getgenv().DigDelayValue,
    accent = Theme.Crimson,
    order = 3,
    onChange = function(v)
        getgenv().DigDelayValue = v
    end,
})
createToggle(FarmPage, {
    name = "AutoInteractBtn",
    icon = "E",
    title = "กด E อัตโนมัติ",
    desc = "กดปุ่มโต้ตอบที่อยู่ในระยะให้ทันที",
    accent = Theme.Ember,
    order = 4,
    onToggle = function(on)
        getgenv().AutoInteractActive = on
        refreshLive()
        notify("กด E อัตโนมัติ", on and "เปิดใช้งานแล้ว" or "ปิดใช้งานแล้ว", Theme.Ember, "E")
        setStatus(on and "กำลังกด E อัตโนมัติ" or "หยุดกด E อัตโนมัติ", on and Theme.Ember or Theme.Muted)
    end,
})

createSection(FarmPage, "การเคลื่อนที่", Theme.Cyan, 5)
createToggle(FarmPage, {
    name = "WalkSpeedBtn",
    icon = "»",
    title = "ความเร็วเดิน",
    desc = "ล็อกความเร็วเดินตามค่าที่ตั้งไว้",
    accent = Theme.Cyan,
    order = 6,
    onToggle = function(on)
        getgenv().WalkSpeedActive = on
        refreshLive()
        notify("ความเร็วเดิน", on and ("ล็อกที่ " .. tostring(getgenv().CustomWalkSpeed)) or "ปิดใช้งานแล้ว", Theme.Cyan, "»")
        setStatus(on and "เร่งความเร็วเดินอยู่" or "ปิดการเร่งความเร็ว", on and Theme.Cyan or Theme.Muted)
    end,
})
createSlider(FarmPage, {
    title = "ค่าความเร็ว",
    desc = "ค่าปกติของเกมคือ 16",
    min = 16,
    max = 200,
    step = 1,
    decimals = 0,
    default = getgenv().CustomWalkSpeed,
    accent = Theme.Cyan,
    order = 7,
    onChange = function(v)
        getgenv().CustomWalkSpeed = v
    end,
})

-- ═════════════════════════ หน้า: ร้านค้า ═════════════════════════
local ShopPage = createPage("Shop", Theme.Gold)
createPageHeader(ShopPage, "ร้านค้า & อัปเกรด", "ขาย อัปเกรด และเปิดร้านได้ในคลิกเดียว", Theme.Gold)
createSection(ShopPage, "ปุ่มลัด", Theme.Gold, 1)
local ShopGrid = createGrid(ShopPage, 2, 104, 2)

local function remoteFeedback(title, ok, icon, accent, okMessage)
    notify(title, ok and okMessage or "ไม่พบระบบนี้ในเกม", ok and accent or Theme.Crimson, icon)
    setStatus(ok and (title .. " • ส่งคำสั่งแล้ว") or (title .. " • ไม่สำเร็จ"), ok and accent or Theme.Crimson)
end

createActionCard(ShopGrid, {
    name = "SellAllBtn",
    icon = "$",
    title = "ขายทั้งหมด",
    desc = "ขายไอเทมทุกชิ้นในกระเป๋า",
    accent = Theme.Gold,
    order = 1,
    callback = function()
        remoteFeedback("ขายทั้งหมด", fireRemote("RequestSell", "All"), "$", Theme.Gold, "ส่งคำสั่งขายแล้ว")
    end,
})
createActionCard(ShopGrid, {
    name = "UpgradeBagBtn",
    icon = "+",
    title = "กระเป๋าสูงสุด",
    desc = "อัปเกรดช่องเก็บของจนเต็ม",
    accent = Theme.Cyan,
    order = 2,
    callback = function()
        remoteFeedback("กระเป๋าสูงสุด", fireRemote("BuyUpgrade", "carry", "max"), "+", Theme.Cyan, "ส่งคำสั่งอัปเกรดแล้ว")
    end,
})
createActionCard(ShopGrid, {
    name = "UpgradeWarmthBtn",
    icon = "▲",
    title = "ความอบอุ่นสูงสุด",
    desc = "อัปเกรดความอบอุ่นจนเต็ม",
    accent = Theme.Ember,
    order = 3,
    callback = function()
        remoteFeedback("ความอบอุ่นสูงสุด", fireRemote("BuyUpgrade", "warmth", "max"), "▲", Theme.Ember, "ส่งคำสั่งอัปเกรดแล้ว")
    end,
})
createActionCard(ShopGrid, {
    name = "OpenPickaxeShopBtn",
    icon = "◆",
    title = "ร้านขายพลั่ว",
    desc = "เปิดหน้าต่างร้านได้ทุกที่",
    accent = Theme.Mint,
    order = 4,
    callback = function()
        local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
        local pickaxeShopGui = playerGui and playerGui:FindFirstChild("PickaxeShopGui")
        if not (pickaxeShopGui and pickaxeShopGui:IsA("ScreenGui")) then
            notify("ร้านขายพลั่ว", "ไม่พบ PickaxeShopGui ใน PlayerGui", Theme.Crimson, "◆")
            setStatus("ไม่พบ PickaxeShopGui ใน PlayerGui", Theme.Crimson)
            return
        end
        -- เปิดการใช้งาน ScreenGui หลัก
        pickaxeShopGui.Enabled = true
        -- กวาดเปิดทุก Frame ย่อยข้างในทั้งหมด
        for _, frame in ipairs(pickaxeShopGui:GetDescendants()) do
            if frame:IsA("Frame") or frame:IsA("ScrollingFrame") then
                frame.Visible = true
            end
        end
        notify("ร้านขายพลั่ว", "เปิดหน้าต่างร้านสำเร็จแล้ว!", Theme.Mint, "◆")
        setStatus("เปิดหน้าต่าง PickaxeShopGui สำเร็จแล้ว", Theme.Mint)
    end,
})

-- ═════════════════════════ หน้า: วาร์ป ═════════════════════════
local WarpPage = createPage("Warp", Theme.Cyan)
createPageHeader(WarpPage, "วาร์ป", "บันทึกจุด แล้วสลับไป-กลับได้ในคลิกเดียว", Theme.Cyan)
createSection(WarpPage, "จุดวาร์ปของคุณ", Theme.Cyan, 1)

local WarpInfo = create("Frame", {
    BackgroundColor3 = WHITE,
    BackgroundTransparency = 0.08,
    Size = UDim2.new(1, -10, 0, 68),
    LayoutOrder = 2,
    Parent = WarpPage,
})
corner(WarpInfo, 12)
gradient(WarpInfo, { Theme.Card:Lerp(Theme.Cyan, 0.12), Theme.Card }, 0)
stroke(WarpInfo, Theme.Cyan, 1, 0.55)
local warpChip = iconChip(WarpInfo, "◎", Theme.Cyan, 42)
warpChip.Position = UDim2.fromOffset(12, 13)
text(WarpInfo, {
    Position = UDim2.fromOffset(64, 14),
    Size = UDim2.new(1, -180, 0, 18),
    Text = "จุดที่บันทึกไว้",
    TextSize = 13,
})
local WarpCoords = text(WarpInfo, {
    Position = UDim2.fromOffset(64, 34),
    Size = UDim2.new(1, -76, 0, 16),
    Font = Enum.Font.GothamMedium,
    Text = "",
    TextColor3 = Theme.SubText,
    TextSize = 11,
    TextTruncate = Enum.TextTruncate.AtEnd,
})
local WarpPill = text(WarpInfo, {
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -12, 0, 12),
    Size = UDim2.fromOffset(0, 20),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundTransparency = 0.8,
    BackgroundColor3 = Theme.Off,
    Font = Enum.Font.GothamBlack,
    Text = "",
    TextSize = 9,
})
round(WarpPill)
create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = WarpPill })

local function refreshWarp()
    if savedPosition then
        local p = savedPosition.Position
        WarpCoords.Text = string.format(
            "X %d   •   Y %d   •   Z %d",
            math.floor(p.X + 0.5),
            math.floor(p.Y + 0.5),
            math.floor(p.Z + 0.5)
        )
    else
        WarpCoords.Text = "ยังไม่ได้ตั้งจุด — กด \"ตั้งจุดวาร์ป\" ก่อนนะ"
    end
    local pillText, pillColor
    if not savedPosition then
        pillText, pillColor = "ยังไม่ตั้ง", Theme.Muted
    elseif currentPositionBeforeTp then
        pillText, pillColor = "อยู่ที่จุดวาร์ป", Theme.Violet
    else
        pillText, pillColor = "พร้อมวาร์ป", Theme.Mint
    end
    WarpPill.Text = pillText
    WarpPill.TextColor3 = pillColor:Lerp(WHITE, 0.3)
    WarpPill.BackgroundColor3 = pillColor
end
refreshWarp()

createSection(WarpPage, "คำสั่ง", Theme.Violet, 3)
local WarpGrid = createGrid(WarpPage, 2, 104, 4)
createActionCard(WarpGrid, {
    name = "SetTpBtn",
    icon = "+",
    title = "ตั้งจุดวาร์ป",
    desc = "บันทึกตำแหน่งที่ยืนอยู่ตอนนี้",
    accent = Theme.Cyan,
    order = 1,
    callback = function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedPosition = char.HumanoidRootPart.CFrame
            refreshWarp()
            notify("ตั้งจุดวาร์ป", "บันทึกจุดวาร์ปแล้ว", Theme.Cyan, "+")
            setStatus("บันทึกจุดวาร์ปแล้ว", Theme.Cyan)
        end
    end,
})
createActionCard(WarpGrid, {
    name = "TpToggleBtn",
    icon = "TP",
    title = "วาร์ปไป-กลับ",
    desc = "สลับระหว่างจุดวาร์ปกับที่เดิม",
    accent = Theme.Violet,
    order = 2,
    callback = function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            return
        end
        if not savedPosition then
            notify("วาร์ปไป-กลับ", "ต้องตั้งจุดวาร์ปก่อน", Theme.Crimson, "TP")
            return
        end
        if not currentPositionBeforeTp then
            currentPositionBeforeTp = hrp.CFrame
            hrp.CFrame = savedPosition
            notify("วาร์ปไป-กลับ", "วาร์ปไปจุดที่บันทึกแล้ว", Theme.Violet, "TP")
            setStatus("อยู่ที่จุดวาร์ป", Theme.Violet)
        else
            hrp.CFrame = currentPositionBeforeTp
            currentPositionBeforeTp = nil
            notify("วาร์ปไป-กลับ", "กลับตำแหน่งเดิมแล้ว", Theme.Violet, "TP")
            setStatus("กลับตำแหน่งเดิมแล้ว", Theme.Violet)
        end
        refreshWarp()
    end,
})
createActionCard(WarpGrid, {
    name = "MeteorWarpBtn",
    icon = "M",
    title = "วาปอุกกาบาต",
    desc = "ไปยังตำแหน่งที่อุกกาบาตตก",
    accent = Theme.Ember,
    order = 3,
    callback = function()
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local meteorRemotes = ReplicatedStorage:FindFirstChild("MeteorRemotes")
        local impactPos = meteorRemotes and meteorRemotes:FindFirstChild("ImpactPos")
        if not rootPart then
            notify("วาปอุกกาบาต", "ไม่พบตัวละครหรือ HumanoidRootPart", Theme.Crimson, "M")
            setStatus("ไม่พบตัวละคร", Theme.Crimson)
            return
        end
        if not impactPos or not impactPos:IsA("Vector3Value") then
            notify("วาปอุกกาบาต", "ยังไม่มีพิกัดอุกกาบาต", Theme.Crimson, "M")
            setStatus("ยังไม่มีพิกัดอุกกาบาต", Theme.Crimson)
            return
        end

        local targetPos = impactPos.Value + Vector3.new(0, 10, 0)
        rootPart.CFrame = CFrame.new(targetPos)
        notify("วาปอุกกาบาต", "ย้ายไปยังจุดตกแล้ว", Theme.Ember, "M")
        setStatus("วาปไปยังตำแหน่งอุกกาบาตแล้ว", Theme.Ember)
    end,
})

-- ═════════════════════════ ระบบเรดาร์ ═════════════════════════
local RadarData = {
    RARITY_ORDER = {
        Common = 1,
        Uncommon = 2,
        Rare = 3,
        Epic = 4,
        Legendary = 5,
        Mythic = 6,
        Exotic = 7,
        Zenith = 8,
        Meteor = 9,
    },
    RARITY_COLOR = {
        Common = Color3.fromRGB(180, 180, 180),
        Uncommon = Color3.fromRGB(90, 220, 120),
        Rare = Color3.fromRGB(95, 150, 255),
        Epic = Color3.fromRGB(175, 90, 255),
        Legendary = Color3.fromRGB(255, 160, 70),
        Mythic = Color3.fromRGB(255, 75, 110),
        Exotic = Color3.fromRGB(255, 200, 70),
        Zenith = Color3.fromRGB(255, 255, 120),
        Meteor = Color3.fromRGB(255, 120, 50),
    },
    RARITY_NAME = {
        Common = "ทั่วไป",
        Uncommon = "ไม่ธรรมดา",
        Rare = "หายาก",
        Epic = "เอปิก",
        Legendary = "ระดับตำนาน",
        Mythic = "มิธิก",
        Exotic = "เอ็กโซติก",
        Zenith = "จุดสูงสุด",
        Meteor = "อุกกาบาต",
    },
    ById = {
        CommonRadar = { displayName = "เรดาร์ทั่วไป", radius = 100 },
        UncommonRadar = { displayName = "เรดาร์ไม่ธรรมดา", radius = 150 },
        RareRadar = { displayName = "เรดาร์แร่หายาก", radius = 200 },
        EpicRadar = { displayName = "เรดาร์แร่เอปิก", radius = 250 },
        LegendaryRadar = { displayName = "เรดาร์ระดับตำนาน", radius = 300 },
        MythicRadar = { displayName = "เรดาร์แร่มิธิก", radius = 350 },
        ExoticRadar = { displayName = "เรดาร์แร่เอ็กโซติก", radius = 400 },
        ZenithRadar = { displayName = "เรดาร์จุดสูงสุด", radius = 500 },
        MeteorRadar = { displayName = "เรดาร์อุกกาบาต", radius = 600 },
    },
}

local radarList = {
    { id = "CommonRadar" },
    { id = "UncommonRadar" },
    { id = "RareRadar" },
    { id = "EpicRadar" },
    { id = "LegendaryRadar" },
    { id = "MythicRadar" },
    { id = "ExoticRadar" },
    { id = "ZenithRadar" },
    { id = "MeteorRadar" },
}

local RADAR_MODES = {
    Million = {
        name = "มูลค่า 1 ล้านขึ้นไป",
        desc = "ล็อกเป้าแร่มูลค่า 1M+ หรือเอ็กโซติกขึ้นไป",
        color = Theme.Gold,
        icon = "1M",
        args = { false, false, false, true },
    },
    Giant = {
        name = "วัตถุขนาดใหญ่",
        desc = "ล็อกเป้าแร่ก้อนใหญ่ที่สุดในระยะ",
        color = Theme.Cyan,
        icon = "XL",
        args = { false, false, true, false },
    },
    Highest = {
        name = "มูลค่าสูงสุด",
        desc = "ชี้เป้าแร่ที่หายากที่สุดใกล้ตัว",
        color = Theme.Pink,
        icon = "★",
        args = { false, true, false, false },
    },
    All = {
        name = "เรดาร์ทั้งหมด",
        desc = "แสดงแร่ทุกระดับในระยะ 600 สตั๊ด",
        color = Theme.Mint,
        icon = "ALL",
        args = { true, false, false, false },
    },
}

local function hex(c)
    return string.format("#%02X%02X%02X", math.floor((c.R*255)+0.5), math.floor((c.G*255)+0.5), math.floor((c.B*255)+0.5))
end
local function studs(v) return string.format("%d สตั๊ด", math.floor(v + 0.5)) end
local MUTED_HEX = hex(Theme.SubText)

local function radarModeInfo(id)
    local mode = RADAR_MODES[id]
    if mode then
        return mode
    end
    local rarity = (id:gsub("Radar", ""))
    local def = RadarData.ById[id]
    return {
        name = def and def.displayName or id,
        color = RadarData.RARITY_COLOR[rarity] or SCOPE_GREEN,
        icon = "T" .. tostring(RadarData.RARITY_ORDER[rarity] or "?"),
    }
end

-- ─────────── HUD เรดาร์ ───────────
local radarHudPanel = create("Frame", {
    Name = "RadarHudPanel",
    Position = UDim2.new(0, 14, 0.45, 0),
    Size = UDim2.fromOffset(372, 128),
    BackgroundColor3 = WHITE,
    BackgroundTransparency = 0.06,
    Active = true,
    Visible = false,
    Parent = ScreenGui,
})
corner(radarHudPanel, 16)
gradient(radarHudPanel, { Color3.fromRGB(24, 14, 36), Color3.fromRGB(12, 10, 20) }, 90)
local radarPanelStroke = stroke(radarHudPanel, SCOPE_GREEN, 2, 0)
spin(gradient(radarPanelStroke, { WHITE, WHITE }, 0, fadeSeq({ { 0, 0 }, { 0.5, 0.85 }, { 1, 0 } })), 120)
local radarHudScale = create("UIScale", { Parent = radarHudPanel })
makeDraggable(radarHudPanel, radarHudPanel)

local scopeFrame = create("Frame", {
    Name = "Scope",
    Position = UDim2.fromOffset(11, 11),
    Size = UDim2.fromOffset(106, 106),
    BackgroundColor3 = Color3.fromRGB(6, 24, 16),
    ClipsDescendants = true,
    Parent = radarHudPanel,
})
round(scopeFrame)
local scopeStroke = stroke(scopeFrame, SCOPE_GREEN, 2, 0)

local scopeRings = {}
for _, sVal in ipairs({ 0.66, 0.33 }) do
    local ring = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromScale(sVal, sVal),
        BackgroundTransparency = 1,
        Parent = scopeFrame,
    })
    round(ring)
    table.insert(scopeRings, stroke(ring, SCOPE_GREEN, 1, 0.65))
end

local scopeCross = {}
for _, vertical in ipairs({ true, false }) do
    table.insert(scopeCross, create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = vertical and UDim2.new(0, 1, 1, -8) or UDim2.new(1, -8, 0, 1),
        BackgroundColor3 = SCOPE_GREEN,
        BackgroundTransparency = 0.8,
        BorderSizePixel = 0,
        Parent = scopeFrame,
    }))
end

-- เส้นกวาดเรดาร์ (หมุนเฉพาะเส้น จุดแร่ไม่หมุนตาม)
local sweepHolder = create("Frame", {
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    Parent = scopeFrame,
})
local sweepLines = {}
for i = 0, 7 do
    local arm = create("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Rotation = -i * 4,
        Parent = sweepHolder,
    })
    table.insert(sweepLines, create("Frame", {
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.new(0.5, -3, 0, 2),
        BackgroundColor3 = SCOPE_GREEN,
        BackgroundTransparency = i == 0 and 0 or math.min(0.45 + i * 0.07, 0.95),
        BorderSizePixel = 0,
        Parent = arm,
    }))
end

local scopeMask = create("Frame", {
    BackgroundTransparency = 1,
    Size = UDim2.fromScale(1, 1),
    ZIndex = 4,
    Parent = scopeFrame,
})

local scopeDot = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.fromOffset(8, 8),
    BackgroundColor3 = WHITE,
    ZIndex = 6,
    Parent = scopeFrame,
})
round(scopeDot)

local function createRadarLabel(name, yOffset, height, fontSize, font, color)
    return text(radarHudPanel, {
        Name = name,
        Position = UDim2.fromOffset(130, yOffset),
        Size = UDim2.new(1, -142, 0, height),
        Font = font,
        TextSize = fontSize,
        TextColor3 = color or WHITE,
        RichText = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
end

local radarTag = createRadarLabel("Tag", 10, 12, 9, Enum.Font.GothamBlack, Theme.SubText)
radarTag.Text = "KILLSTAM  •  RADAR"
local radarTitle = createRadarLabel("Title", 22, 26, 17, Enum.Font.GothamBlack)
local radarLine1 = createRadarLabel("Line1", 50, 20, 13, Enum.Font.GothamBold)
local radarLine2 = createRadarLabel("Line2", 71, 18, 11, Enum.Font.GothamMedium, Color3.fromRGB(200, 205, 215))
local radarRange = text(radarHudPanel, {
    Name = "Range",
    Position = UDim2.fromOffset(130, 96),
    Size = UDim2.fromOffset(0, 20),
    AutomaticSize = Enum.AutomaticSize.X,
    BackgroundColor3 = SCOPE_GREEN,
    BackgroundTransparency = 0.82,
    TextSize = 10,
    Text = "",
})
round(radarRange)
create("UIPadding", { PaddingLeft = UDim.new(0, 9), PaddingRight = UDim.new(0, 9), Parent = radarRange })

local function applyHudColor(color)
    scopeStroke.Color = color
    radarPanelStroke.Color = color
    scopeFrame.BackgroundColor3 = color:Lerp(BLACK, 0.86)
    for _, ring in ipairs(scopeRings) do
        ring.Color = color
    end
    for _, line in ipairs(scopeCross) do
        line.BackgroundColor3 = color
    end
    for _, line in ipairs(sweepLines) do
        line.BackgroundColor3 = color
    end
    radarRange.BackgroundColor3 = color
    radarRange.TextColor3 = color:Lerp(WHITE, 0.55)
end

local radarState = nil

local function worldBlip(adornee, color, textLabel)
    local gui = create("BillboardGui", {
        Name = "RadarDot",
        AlwaysOnTop = true,
        Size = UDim2.fromOffset(170, 48),
        StudsOffsetWorldSpace = Vector3.new(0, 2.2, 0),
        Adornee = adornee,
        MaxDistance = 1500,
        Parent = adornee,
    })

    local ring = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.fromScale(0.5, 0),
        Size = UDim2.fromOffset(18, 18),
        BackgroundTransparency = 1,
        Parent = gui,
    })
    round(ring)
    local ringStroke = stroke(ring, color, 1.5, 0.25)

    local dot = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(10, 10),
        BackgroundColor3 = color,
        Parent = ring,
    })
    round(dot)
    stroke(dot, BLACK, 1.5, 0)

    local label = text(gui, {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0, 22),
        Size = UDim2.fromOffset(0, 22),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = Color3.fromRGB(10, 8, 18),
        BackgroundTransparency = 0.25,
        TextColor3 = WHITE,
        TextSize = 12,
        TextStrokeTransparency = 0.5,
        TextXAlignment = Enum.TextXAlignment.Center,
        RichText = true,
        Text = textLabel,
    })
    corner(label, 8)
    create("UIPadding", { PaddingLeft = UDim.new(0, 7), PaddingRight = UDim.new(0, 7), Parent = label })
    local labelStroke = stroke(label, color, 1, 0.4)
    return { bb = gui, dot = dot, ring = ringStroke, label = label, labelStroke = labelStroke }
end

local function scanAllObjects(origin, maxRange, filterRarity, highestOnly, giantOnly, millionOnly)
    local results = {}
    local char = LocalPlayer.Character

    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:GetAttribute("Rarity") ~= nil then
            local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
            if primary and (not char or not obj:IsDescendantOf(char)) then
                local dist = (primary.Position - origin.Position).Magnitude
                if dist <= maxRange then
                    local rarity = tostring(obj:GetAttribute("Rarity"))
                    local col = RadarData.RARITY_COLOR[rarity] or primary.Color or Color3.fromRGB(200, 200, 200)
                    local score = RadarData.RARITY_ORDER[rarity] or 1

                    local _, size = obj:GetBoundingBox()
                    local maxDim = math.max(size.X, size.Y, size.Z)

                    local isMillion = false
                    local valAttr = obj:GetAttribute("Value") or obj:GetAttribute("Price") or obj:GetAttribute("Money")
                    if type(valAttr) == "number" and valAttr >= 1000000 then
                        isMillion = true
                    elseif score >= 7 then
                        isMillion = true
                    end

                    if not millionOnly or isMillion then
                        if not giantOnly or maxDim >= 15 then
                            if not filterRarity or rarity:lower() == filterRarity:lower() then
                                table.insert(results, {
                                    key = obj,
                                    adornee = primary,
                                    pos = primary.Position,
                                    dist = dist,
                                    name = obj.Name,
                                    rarity = rarity,
                                    color = col,
                                    score = score,
                                    size = maxDim,
                                })
                            end
                        end
                    end
                end
            end
        end
    end

    table.sort(results, function(a, b)
        if millionOnly or highestOnly then
            if a.score ~= b.score then return a.score > b.score end
        elseif giantOnly then
            if a.size ~= b.size then return a.size > b.size end
        end
        return a.dist < b.dist
    end)

    if (highestOnly or giantOnly or millionOnly) and #results > 0 then
        return { results[1] }
    end

    return results
end

local function stopRadar()
    if radarState then
        for _, b in pairs(radarState.blips) do if b.bb then b.bb:Destroy() end end
        for _, s in pairs(radarState.scopeBlips) do if s then s:Destroy() end end
        radarState = nil
    end
    radarHudPanel.Visible = false
end

local function startRadar(radarId, isAll, highestOnly, giantOnly, millionOnly)
    stopRadar()
    local def = RadarData.ById[radarId] or { displayName = radarId, radius = 600 }
    local targetRarity = not isAll and not highestOnly and not giantOnly and not millionOnly and radarId:gsub("Radar", "") or nil

    radarState = {
        nextScan = 0,
        radius = def.radius,
        blips = {},
        scopeBlips = {},
        targets = {},
        filter = targetRarity,
        isAll = isAll,
        highestOnly = highestOnly,
        giantOnly = giantOnly,
        millionOnly = millionOnly,
    }

    local modeColor, modeTitle
    if millionOnly then
        modeColor, modeTitle = RADAR_MODES.Million.color, RADAR_MODES.Million.name
    elseif giantOnly then
        modeColor, modeTitle = RADAR_MODES.Giant.color, RADAR_MODES.Giant.name
    elseif highestOnly then
        modeColor, modeTitle = RADAR_MODES.Highest.color, RADAR_MODES.Highest.name
    elseif isAll then
        modeColor, modeTitle = RADAR_MODES.All.color, RADAR_MODES.All.name
    else
        modeColor, modeTitle = RadarData.RARITY_COLOR[targetRarity] or SCOPE_GREEN, def.displayName
    end
    applyHudColor(modeColor)
    radarTitle.Text = string.format("<font color=\"%s\">%s</font>", hex(modeColor), modeTitle)
    radarLine1.Text = "กำลังสแกนพื้นที่..."
    radarLine2.Text = ""
    radarRange.Text = string.format("ระยะ %s", studs(def.radius))

    radarHudScale.Scale = 0.85
    radarHudPanel.Visible = true
    tween(radarHudScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
end

local radarControls = {}
local function refreshRadarButtons()
    local active = getgenv().ActiveRadarId
    for id, setActive in pairs(radarControls) do
        setActive(active == id)
    end
    refreshLive()
end

local function setRadarMode(modeId)
    getgenv().MillionScanActive = modeId == "Million"
    getgenv().GiantScanActive = modeId == "Giant"
    getgenv().HighestOnlyActive = modeId == "Highest"
    getgenv().AllRadarsActive = modeId == "All"
    getgenv().ActiveRadarId = modeId

    local mode = modeId and RADAR_MODES[modeId]
    if mode then
        startRadar("MeteorRadar", table.unpack(mode.args))
    elseif modeId then
        startRadar(modeId, false, false, false, false)
    else
        stopRadar()
    end
    refreshRadarButtons()

    if modeId then
        local info = radarModeInfo(modeId)
        notify("เรดาร์: " .. info.name, "เริ่มสแกนแล้ว ดูจุดบนจอได้เลย", info.color, info.icon)
        setStatus("เรดาร์ " .. info.name .. " กำลังสแกน", info.color)
    else
        notify("เรดาร์", "ปิดการสแกนแล้ว", Theme.Muted, "■")
        setStatus("ปิดเรดาร์แล้ว", Theme.Muted)
    end
end

local function toggleRadarMode(modeId)
    if getgenv().ActiveRadarId == modeId then
        setRadarMode(nil)
    else
        setRadarMode(modeId)
    end
end

-- ═════════════════════════ หน้า: เรดาร์ ═════════════════════════
local RadarPage = createPage("Radar", Theme.Violet)
createPageHeader(RadarPage, "เรดาร์", "สแกนหาแร่รอบตัว พร้อมจุดบอกตำแหน่งบนจอ", Theme.Violet)
createSection(RadarPage, "สแกนอัจฉริยะ", Theme.Gold, 1)

for i, modeId in ipairs({ "Million", "Giant", "Highest", "All" }) do
    local mode = RADAR_MODES[modeId]
    local row = createToggle(RadarPage, {
        name = modeId .. "ScanBtn",
        icon = mode.icon,
        title = mode.name,
        desc = mode.desc,
        accent = mode.color,
        order = 1 + i,
        onClick = function()
            toggleRadarMode(modeId)
        end,
    })
    radarControls[modeId] = function(on)
        row:Set(on, true)
    end
end

createSection(RadarPage, "เรดาร์ตามระดับความหายาก", Theme.Violet, 6)
local RarityGrid = createGrid(RadarPage, 3, 70, 7)

local function createRarityTile(info, order)
    local rarity = (info.id:gsub("Radar", ""))
    local color = RadarData.RARITY_COLOR[rarity] or SCOPE_GREEN
    local def = RadarData.ById[info.id]
    local tile = create("TextButton", {
        Name = info.id,
        AutoButtonColor = false,
        Text = "",
        BackgroundColor3 = Theme.Card,
        BackgroundTransparency = 0.08,
        LayoutOrder = order,
        Parent = RarityGrid,
    })
    corner(tile, 12)
    local tileStroke = stroke(tile, Theme.Stroke, 1, 0.35)
    attachRipple(tile, function()
        return color
    end)
    text(tile, {
        Position = UDim2.fromOffset(10, 8),
        Size = UDim2.fromOffset(40, 12),
        Font = Enum.Font.GothamBlack,
        Text = "T" .. tostring(RadarData.RARITY_ORDER[rarity] or "?"),
        TextColor3 = color,
        TextSize = 10,
    })
    local gem = create("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -11, 0, 10),
        Size = UDim2.fromOffset(9, 9),
        Rotation = 45,
        BackgroundColor3 = color,
        Parent = tile,
    })
    corner(gem, 2)
    local gemGlow = stroke(gem, color:Lerp(WHITE, 0.4), 2, 1)
    text(tile, {
        Position = UDim2.fromOffset(10, 24),
        Size = UDim2.new(1, -20, 0, 18),
        Text = RadarData.RARITY_NAME[rarity] or rarity,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    text(tile, {
        Position = UDim2.fromOffset(10, 42),
        Size = UDim2.new(1, -20, 0, 14),
        Font = Enum.Font.GothamMedium,
        Text = def and studs(def.radius) or "",
        TextColor3 = Theme.SubText,
        TextSize = 10,
    })
    local underline = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0.5, 0, 1, -4),
        Size = UDim2.new(1, -20, 0, 2),
        BackgroundColor3 = color,
        BackgroundTransparency = 0.75,
        BorderSizePixel = 0,
        Parent = tile,
    })
    round(underline)

    local active, hovered = false, false
    local function render()
        local bg = active and Theme.Card:Lerp(color, 0.2) or (hovered and Theme.CardHover or Theme.Card)
        tween(tile, 0.2, { BackgroundColor3 = bg })
        tween(tileStroke, 0.25, { Color = active and color or Theme.Stroke, Transparency = active and 0 or 0.35 })
        tween(underline, 0.25, { BackgroundTransparency = active and 0 or (hovered and 0.4 or 0.75) })
        tween(gemGlow, 0.25, { Transparency = active and 0.2 or 1 })
    end
    tile.MouseEnter:Connect(function()
        hovered = true
        render()
    end)
    tile.MouseLeave:Connect(function()
        hovered = false
        render()
    end)
    tile.MouseButton1Click:Connect(function()
        toggleRadarMode(info.id)
    end)
    radarControls[info.id] = function(on)
        active = on
        render()
    end
end

for i, info in ipairs(radarList) do
    createRarityTile(info, i)
end

createActionRow(RadarPage, {
    icon = "■",
    title = "หยุดเรดาร์ทั้งหมด",
    desc = "ปิดการสแกนและล้างจุดบนจอ",
    accent = Theme.Crimson,
    order = 8,
    callback = function()
        setRadarMode(nil)
    end,
})

-- ═════════════════════════ ระบบผู้เล่น (ESP • สเปคจอ • วาร์ปหา) ═════════════════════════
-- ห่อไว้ใน do...end เพื่อไม่ให้ตัวแปร local ระดับบนสุดเกินขีดจำกัด 200 ตัวของ Luau
local updatePlayerTools, stopPlayerTools
do
    local selectedPlayer = nil
    local playerRows = {}
    local thumbCache = {}
    local ESP_COLOR = Theme.Pink
    local TARGET_COLOR = Theme.Gold
    local hasDrawing = pcall(function()
        Drawing.new("Line"):Remove()
    end)

    local function getRoot(player)
        local char = player and player.Character
        return char and char:FindFirstChild("HumanoidRootPart")
    end

    local function getHumanoid(player)
        local char = player and player.Character
        return char and char:FindFirstChildOfClass("Humanoid")
    end

    local function distanceTo(player)
        local myRoot, theirRoot = getRoot(LocalPlayer), getRoot(player)
        if myRoot and theirRoot then
            return (myRoot.Position - theirRoot.Position).Magnitude
        end
        return nil
    end

    -- รูปโปรไฟล์ผู้เล่นแบบวงกลม (โหลดเบื้องหลัง + แคชไว้ใช้ซ้ำ)
    local function avatarBubble(parent, size)
        local frame = create("Frame", {
            Size = UDim2.fromOffset(size, size),
            BackgroundColor3 = Color3.fromRGB(38, 31, 67),
            Parent = parent,
        })
        round(frame)
        local initial = text(frame, {
            Size = UDim2.fromScale(1, 1),
            Font = Enum.Font.GothamBlack,
            Text = "?",
            TextColor3 = Color3.fromRGB(255, 243, 196),
            TextSize = math.floor(size * 0.45),
            TextXAlignment = Enum.TextXAlignment.Center,
        })
        local image = create("ImageLabel", {
            BackgroundTransparency = 1,
            Size = UDim2.fromScale(1, 1),
            ImageTransparency = 1,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 2,
            Parent = frame,
        })
        round(image)
        return { frame = frame, image = image, initial = initial, userId = nil }
    end

    local function showAvatar(avatar, player)
        avatar.userId = player and player.UserId
        avatar.image.ImageTransparency = 1
        avatar.initial.Visible = true
        avatar.initial.Text = player and string.sub(player.Name, 1, 1):upper() or "?"
        if not player then
            return
        end
        local userId = player.UserId
        local function apply(image)
            if avatar.userId == userId and avatar.image.Parent then
                avatar.image.Image = image
                avatar.image.ImageTransparency = 0
                avatar.initial.Visible = false
            end
        end
        if thumbCache[userId] then
            apply(thumbCache[userId])
            return
        end
        task.spawn(function()
            local ok, image = pcall(function()
                return Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
            end)
            if ok and image then
                thumbCache[userId] = image
                apply(image)
            end
        end)
    end

    -- ESP วาดด้วย Drawing API (กรอบ • เส้นชี้ • ชื่อ + ระยะ) — เป้าหมายที่เลือกจะเป็นสีทอง
    local espObjects = {}

    local function removeESP(player)
        local esp = espObjects[player]
        if not esp then
            return
        end
        for _, drawing in pairs(esp) do
            pcall(function()
                drawing:Remove()
            end)
        end
        espObjects[player] = nil
    end

    local function clearESP()
        for player in pairs(espObjects) do
            removeESP(player)
        end
    end

    local function newDrawing(kind, props)
        local drawing = Drawing.new(kind)
        for key, value in pairs(props) do
            drawing[key] = value
        end
        return drawing
    end

    local function getESP(player)
        local esp = espObjects[player]
        if not esp then
            esp = {
                tracer = newDrawing("Line", { Thickness = 1.5, Visible = false }),
                box = newDrawing("Square", { Thickness = 1, Filled = false, Visible = false }),
                name = newDrawing("Text", { Size = 14, Center = true, Outline = true, Visible = false }),
            }
            espObjects[player] = esp
        end
        return esp
    end

    local function updateESP(cam)
        local myRoot = getRoot(LocalPlayer)
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer then
                local esp = getESP(player)
                local root = getRoot(player)
                local head = player.Character and player.Character:FindFirstChild("Head")
                local screenPos, onScreen
                if root and head then
                    screenPos, onScreen = cam:WorldToViewportPoint(root.Position)
                end
                if onScreen then
                    local isTarget = player == selectedPlayer
                    local headPos = cam:WorldToViewportPoint(head.Position + Vector3.new(0, 0.5, 0))
                    local legPos = cam:WorldToViewportPoint(root.Position - Vector3.new(0, 3, 0))
                    local height = math.abs(headPos.Y - legPos.Y)
                    local width = height / 2
                    local dist = myRoot and math.floor((myRoot.Position - root.Position).Magnitude) or 0

                    esp.tracer.From = Vector2.new(cam.ViewportSize.X / 2, cam.ViewportSize.Y)
                    esp.tracer.To = Vector2.new(screenPos.X, screenPos.Y)
                    esp.tracer.Color = isTarget and TARGET_COLOR or ESP_COLOR
                    esp.box.Size = Vector2.new(width, height)
                    esp.box.Position = Vector2.new(screenPos.X - width / 2, headPos.Y)
                    esp.box.Color = isTarget and TARGET_COLOR or WHITE
                    esp.name.Text = string.format("%s [%dm]", player.Name, dist)
                    esp.name.Position = Vector2.new(screenPos.X, headPos.Y - 18)
                    esp.name.Color = isTarget and TARGET_COLOR or WHITE
                end
                esp.tracer.Visible = onScreen == true
                esp.box.Visible = onScreen == true
                esp.name.Visible = onScreen == true
            end
        end
    end

    -- คืนกล้องกลับมาที่ตัวเอง (ไม่ยุ่งกับกล้องตอนนั่งยานพาหนะ)
    local function restoreCamera()
        local cam = workspace.CurrentCamera
        local myHumanoid = getHumanoid(LocalPlayer)
        if not cam or not myHumanoid then
            return
        end
        local subject = cam.CameraSubject
        if subject == nil or (subject:IsA("Humanoid") and subject ~= myHumanoid) then
            cam.CameraSubject = myHumanoid
        end
    end

    -- ═════════════════════════ หน้า: ผู้เล่น ═════════════════════════
    local PlayerPage = createPage("Players", Theme.Pink)
    createPageHeader(PlayerPage, "ผู้เล่น", "มองผู้เล่นทะลุกำแพง สเปคจอ และวาร์ปไปหา", Theme.Pink)
    createSection(PlayerPage, "มองผู้เล่น (ESP)", Theme.Pink, 1)

    local espToggle
    espToggle = createToggle(PlayerPage, {
        name = "PlayerESPBtn",
        icon = "ESP",
        title = "ESP ผู้เล่น",
        desc = "กรอบ • เส้นชี้ • ชื่อ และระยะห่างของทุกคน",
        accent = Theme.Pink,
        order = 2,
        onToggle = function(on)
            if on and not hasDrawing then
                espToggle:Set(false, true)
                notify("ESP ผู้เล่น", "ตัวรันนี้ไม่รองรับ Drawing API", Theme.Crimson, "ESP")
                setStatus("ESP ใช้ไม่ได้ (ไม่มี Drawing API)", Theme.Crimson)
                return
            end
            getgenv().PlayerESPActive = on
            if not on then
                clearESP()
            end
            refreshLive()
            notify("ESP ผู้เล่น", on and "เปิดแล้ว — เป้าหมายจะเป็นสีทอง" or "ปิดใช้งานแล้ว", Theme.Pink, "ESP")
            setStatus(on and "กำลังแสดง ESP ผู้เล่น" or "ปิด ESP ผู้เล่น", on and Theme.Pink or Theme.Muted)
        end,
    })

    createSection(PlayerPage, "เป้าหมาย", TARGET_COLOR, 3)
    local TargetCard = create("Frame", {
        BackgroundColor3 = WHITE,
        BackgroundTransparency = 0.08,
        Size = UDim2.new(1, -10, 0, 68),
        LayoutOrder = 4,
        Parent = PlayerPage,
    })
    corner(TargetCard, 12)
    gradient(TargetCard, { Theme.Card:Lerp(TARGET_COLOR, 0.12), Theme.Card }, 0)
    stroke(TargetCard, TARGET_COLOR, 1, 0.55)
    local targetAvatar = avatarBubble(TargetCard, 42)
    targetAvatar.frame.Position = UDim2.fromOffset(12, 13)
    stroke(targetAvatar.frame, TARGET_COLOR, 1.5, 0)
    local TargetName = text(TargetCard, {
        Position = UDim2.fromOffset(64, 14),
        Size = UDim2.new(1, -180, 0, 18),
        Text = "",
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local TargetInfo = text(TargetCard, {
        Position = UDim2.fromOffset(64, 34),
        Size = UDim2.new(1, -76, 0, 16),
        Font = Enum.Font.GothamMedium,
        Text = "",
        TextColor3 = Theme.SubText,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    local TargetPill = text(TargetCard, {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -12, 0, 12),
        Size = UDim2.fromOffset(0, 20),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 0.8,
        BackgroundColor3 = Theme.Off,
        Font = Enum.Font.GothamBlack,
        Text = "",
        TextSize = 9,
    })
    round(TargetPill)
    create("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = TargetPill })

    local function refreshTarget()
        local player = selectedPlayer
        if player then
            local dist = distanceTo(player)
            TargetName.Text = player.DisplayName
            TargetInfo.Text = "@" .. player.Name .. "   •   " .. (dist and studs(dist) or "ไม่พบตัวละคร")
        else
            TargetName.Text = "ยังไม่ได้เลือกเป้าหมาย"
            TargetInfo.Text = "แตะชื่อผู้เล่นในรายชื่อด้านล่างเพื่อเลือก"
        end
        local pillText, pillColor
        if not player then
            pillText, pillColor = "ยังไม่เลือก", Theme.Muted
        elseif getgenv().SpectateActive then
            pillText, pillColor = "กำลังสเปค", TARGET_COLOR
        else
            pillText, pillColor = "พร้อม", Theme.Mint
        end
        TargetPill.Text = pillText
        TargetPill.TextColor3 = pillColor:Lerp(WHITE, 0.3)
        TargetPill.BackgroundColor3 = pillColor
    end

    local spectateToggle
    local function setSpectate(on, message)
        if on and not selectedPlayer then
            spectateToggle:Set(false, true)
            notify("สเปคจอ", "เลือกผู้เล่นจากรายชื่อก่อนนะ", Theme.Crimson, "▶")
            return
        end
        getgenv().SpectateActive = on
        spectateToggle:Set(on, true)
        if not on then
            restoreCamera()
        end
        refreshLive()
        refreshTarget()
        if on then
            notify("สเปคจอ", "กำลังดูจอของ " .. selectedPlayer.DisplayName, TARGET_COLOR, "▶")
            setStatus("กำลังสเปคจอ " .. selectedPlayer.DisplayName, TARGET_COLOR)
        else
            notify("สเปคจอ", message or "กล้องกลับมาที่ตัวเองแล้ว", Theme.Muted, "▶")
            setStatus("ปิดการสเปคจอแล้ว", Theme.Muted)
        end
    end

    spectateToggle = createToggle(PlayerPage, {
        name = "SpectateBtn",
        icon = "▶",
        title = "สเปคจอ (Spectate)",
        desc = "ย้ายกล้องไปดูมุมมองของเป้าหมาย",
        accent = TARGET_COLOR,
        order = 5,
        onClick = function()
            setSpectate(not getgenv().SpectateActive)
        end,
    })

    createActionRow(PlayerPage, {
        icon = "TP",
        title = "วาร์ปไปหาเป้าหมาย",
        desc = "ย้ายไปยืนเหนือผู้เล่นที่เลือกไว้",
        accent = Theme.Cyan,
        order = 6,
        callback = function()
            if not selectedPlayer then
                notify("วาร์ปหาผู้เล่น", "เลือกผู้เล่นจากรายชื่อก่อนนะ", Theme.Crimson, "TP")
                return
            end
            local myRoot, targetRoot = getRoot(LocalPlayer), getRoot(selectedPlayer)
            if not myRoot or not targetRoot then
                notify("วาร์ปหาผู้เล่น", "ไม่พบตัวละครของคุณหรือเป้าหมาย", Theme.Crimson, "TP")
                setStatus("วาร์ปไม่สำเร็จ • ไม่พบตัวละคร", Theme.Crimson)
                return
            end
            myRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
            notify("วาร์ปหาผู้เล่น", "วาร์ปไปหา " .. selectedPlayer.DisplayName .. " แล้ว", Theme.Cyan, "TP")
            setStatus("วาร์ปไปหา " .. selectedPlayer.DisplayName .. " แล้ว", Theme.Cyan)
        end,
    })

    -- ─────────── รายชื่อผู้เล่นในเซิร์ฟเวอร์ (อัปเดตอัตโนมัติ) ───────────
    local PlayerListTitle = createSection(PlayerPage, "ผู้เล่นในเซิร์ฟเวอร์", Theme.Violet, 7)
    local PlayerList = create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        LayoutOrder = 8,
        Parent = PlayerPage,
    })
    create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = PlayerList })
    local PlayerListEmpty = text(PlayerList, {
        Size = UDim2.new(1, 0, 0, 40),
        Font = Enum.Font.GothamMedium,
        Text = "ยังไม่มีผู้เล่นคนอื่นในเซิร์ฟเวอร์",
        TextColor3 = Theme.Muted,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    local function renderPlayerRow(row)
        local selected = row.player == selectedPlayer
        local bg = selected and Theme.Card:Lerp(TARGET_COLOR, 0.16) or (row.hovered and Theme.CardHover or Theme.Card)
        tween(row.button, 0.2, { BackgroundColor3 = bg })
        tween(row.stroke, 0.25, { Color = selected and TARGET_COLOR or Theme.Stroke, Transparency = selected and 0.15 or 0.35 })
        row.dist.TextColor3 = selected and TARGET_COLOR or Theme.SubText
    end

    local function sortPlayerRows()
        local rows = {}
        for _, row in pairs(playerRows) do
            table.insert(rows, row)
        end
        table.sort(rows, function(a, b)
            return a.player.DisplayName:lower() < b.player.DisplayName:lower()
        end)
        for i, row in ipairs(rows) do
            row.button.LayoutOrder = i
        end
        PlayerListEmpty.Visible = #rows == 0
        PlayerListTitle.Text = string.format("ผู้เล่นในเซิร์ฟเวอร์  •  %d คน", #rows)
    end

    local function selectPlayer(player, silent)
        selectedPlayer = player
        showAvatar(targetAvatar, player)
        for _, row in pairs(playerRows) do
            renderPlayerRow(row)
        end
        if not player and getgenv().SpectateActive then
            setSpectate(false)
        end
        refreshTarget()
        if silent then
            return
        end
        if player then
            notify("เลือกเป้าหมาย", player.DisplayName .. "  (@" .. player.Name .. ")", TARGET_COLOR, "◉")
            setStatus((getgenv().SpectateActive and "กำลังสเปคจอ " or "เป้าหมาย: ") .. player.DisplayName, TARGET_COLOR)
        else
            notify("เป้าหมาย", "ยกเลิกการเลือกแล้ว", Theme.Muted, "◉")
            setStatus("ยกเลิกเป้าหมายแล้ว", Theme.Muted)
        end
    end

    local function addPlayerRow(player)
        if player == LocalPlayer or playerRows[player] then
            return
        end
        local button = create("TextButton", {
            Name = player.Name,
            AutoButtonColor = false,
            Text = "",
            BackgroundColor3 = Theme.Card,
            BackgroundTransparency = 0.08,
            Size = UDim2.new(1, 0, 0, 46),
            Parent = PlayerList,
        })
        corner(button, 10)
        local rowStroke = stroke(button, Theme.Stroke, 1, 0.35)
        attachRipple(button, function()
            return TARGET_COLOR
        end)
        local avatar = avatarBubble(button, 32)
        avatar.frame.Position = UDim2.fromOffset(10, 7)
        showAvatar(avatar, player)
        text(button, {
            Position = UDim2.fromOffset(52, 7),
            Size = UDim2.new(1, -150, 0, 18),
            Text = player.DisplayName,
            TextSize = 12,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        text(button, {
            Position = UDim2.fromOffset(52, 24),
            Size = UDim2.new(1, -150, 0, 14),
            Font = Enum.Font.GothamMedium,
            Text = "@" .. player.Name,
            TextColor3 = Theme.SubText,
            TextSize = 10,
            TextTruncate = Enum.TextTruncate.AtEnd,
        })
        local distLabel = text(button, {
            AnchorPoint = Vector2.new(1, 0.5),
            Position = UDim2.new(1, -12, 0.5, 0),
            Size = UDim2.fromOffset(86, 16),
            Text = "--",
            TextColor3 = Theme.SubText,
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Right,
        })

        local row = { player = player, button = button, stroke = rowStroke, dist = distLabel, hovered = false }
        button.MouseEnter:Connect(function()
            row.hovered = true
            renderPlayerRow(row)
        end)
        button.MouseLeave:Connect(function()
            row.hovered = false
            renderPlayerRow(row)
        end)
        button.MouseButton1Click:Connect(function()
            -- แตะคนเดิมซ้ำ = ยกเลิกการเลือก
            selectPlayer(selectedPlayer ~= player and player or nil)
        end)
        playerRows[player] = row
        renderPlayerRow(row)
        sortPlayerRows()
    end

    local function removePlayerRow(player)
        removeESP(player)
        local row = playerRows[player]
        if row then
            row.button:Destroy()
            playerRows[player] = nil
        end
        if player == selectedPlayer then
            if getgenv().SpectateActive then
                setSpectate(false, player.DisplayName .. " ออกจากเซิร์ฟแล้ว")
            else
                notify("เป้าหมาย", player.DisplayName .. " ออกจากเซิร์ฟแล้ว", Theme.Muted, "◉")
            end
            selectPlayer(nil, true)
        end
        sortPlayerRows()
    end

    for _, player in ipairs(Players:GetPlayers()) do
        addPlayerRow(player)
    end
    sortPlayerRows()
    refreshTarget()
    Players.PlayerAdded:Connect(function(player)
        if alive() then
            addPlayerRow(player)
        end
    end)
    Players.PlayerRemoving:Connect(function(player)
        if alive() then
            removePlayerRow(player)
        end
    end)

    -- อัปเดตระยะห่างในรายชื่อและการ์ดเป้าหมาย
    task.spawn(function()
        while alive() and ScreenGui.Parent do
            task.wait(0.5)
            for player, row in pairs(playerRows) do
                local dist = distanceTo(player)
                row.dist.Text = dist and studs(dist) or "--"
            end
            refreshTarget()
        end
    end)

    -- เรียกทุกเฟรมจากลูปหลัก: ล็อกกล้องสเปค (ตามต่อได้แม้เป้าหมายเกิดใหม่) + วาด ESP
    function updatePlayerTools(camera)
        if getgenv().SpectateActive then
            local targetHumanoid = getHumanoid(selectedPlayer)
            if targetHumanoid and camera.CameraSubject ~= targetHumanoid then
                camera.CameraSubject = targetHumanoid
            end
        end
        if getgenv().PlayerESPActive then
            pcall(updateESP, camera)
        end
    end

    -- เก็บกวาดตอนรันสคริปต์ใหม่/ปิดเมนู: ลบ ESP และคืนกล้อง
    function stopPlayerTools()
        clearESP()
        restoreCamera()
    end
end

-- ═════════════════════════ แท็บด้านข้าง ═════════════════════════
local TABS = {
    { id = "Farm", name = "ฟาร์ม", sub = "ขุด • เคลื่อนที่", icon = "▼", accent = Theme.Crimson },
    { id = "Shop", name = "ร้านค้า", sub = "ขาย • อัปเกรด", icon = "$", accent = Theme.Gold },
    { id = "Warp", name = "วาร์ป", sub = "จุดวาร์ป", icon = "TP", accent = Theme.Cyan },
    { id = "Radar", name = "เรดาร์", sub = "สแกนแร่", icon = "◎", accent = Theme.Violet },
    { id = "Players", name = "ผู้เล่น", sub = "ESP • สเปคจอ", icon = "◉", accent = Theme.Pink },
}
local TAB_H, TAB_GAP = 44, 5

local TabIndicator = create("Frame", {
    Position = UDim2.fromOffset(2, 18),
    Size = UDim2.fromOffset(3, 24),
    BackgroundColor3 = Theme.Crimson,
    BorderSizePixel = 0,
    Parent = Sidebar,
})
round(TabIndicator)

local tabWidgets = {}
local currentTab = nil

local function selectTab(id)
    if currentTab == id then
        return
    end
    currentTab = id
    for _, widget in ipairs(tabWidgets) do
        widget.render(widget.id == id)
        if widget.id == id then
            tween(TabIndicator, 0.45, {
                Position = UDim2.fromOffset(2, widget.y + 10),
                BackgroundColor3 = widget.accent,
            }, Enum.EasingStyle.Back)
        end
    end
    for pageId, page in pairs(pages) do
        if pageId == id then
            page.Visible = true
            page.Position = UDim2.fromOffset(24, 0)
            tween(page, 0.35, { Position = UDim2.fromOffset(0, 0) })
        else
            page.Visible = false
        end
    end
end

for i, info in ipairs(TABS) do
    local y = 8 + (i - 1) * (TAB_H + TAB_GAP)
    local btn = create("TextButton", {
        Name = info.id .. "Tab",
        AutoButtonColor = false,
        Text = "",
        Position = UDim2.fromOffset(8, y),
        Size = UDim2.new(1, -16, 0, TAB_H),
        BackgroundColor3 = WHITE,
        BackgroundTransparency = 1,
        Parent = Sidebar,
    })
    corner(btn, 10)
    gradient(btn, { info.accent, info.accent }, 0, fadeSeq({ { 0, 0.55 }, { 1, 0.95 } }))
    local chip, _, chipGrad, chipStroke = iconChip(btn, info.icon, info.accent, 30)
    chip.Position = UDim2.fromOffset(7, 7)
    local nameLabel = text(btn, {
        Position = UDim2.fromOffset(45, 6),
        Size = UDim2.new(1, -50, 0, 18),
        Text = info.name,
        TextSize = 13,
    })
    local subLabel = text(btn, {
        Position = UDim2.fromOffset(45, 23),
        Size = UDim2.new(1, -50, 0, 14),
        Font = Enum.Font.GothamMedium,
        Text = info.sub,
        TextColor3 = Theme.Muted,
        TextSize = 9,
    })

    local widget = { id = info.id, y = y, accent = info.accent, active = false, hovered = false }
    function widget.render(active)
        if active ~= nil then
            widget.active = active
        end
        local on = widget.active
        tween(btn, 0.25, { BackgroundTransparency = on and 0 or (widget.hovered and 0.65 or 1) })
        chipGrad.Color = chipSequence(on and info.accent or Theme.Off)
        chipStroke.Transparency = on and 0.4 or 0.85
        tween(nameLabel, 0.25, { TextColor3 = on and WHITE or Theme.SubText })
        tween(subLabel, 0.25, { TextColor3 = on and info.accent:Lerp(WHITE, 0.4) or Theme.Muted })
    end
    btn.MouseEnter:Connect(function()
        widget.hovered = true
        widget.render()
    end)
    btn.MouseLeave:Connect(function()
        widget.hovered = false
        widget.render()
    end)
    btn.MouseButton1Click:Connect(function()
        selectTab(info.id)
    end)
    table.insert(tabWidgets, widget)
    widget.render(false)
end

-- ═════════════════════════ ปุ่มลอยเปิด/ปิดเมนู ═════════════════════════
local ToggleHolder = create("Frame", {
    Name = "ToggleHolder",
    Position = UDim2.new(0.05, 0, 0.1, 0),
    Size = UDim2.fromOffset(178, 48),
    BackgroundTransparency = 1,
    Parent = ScreenGui,
})
local ToggleGlow = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = UDim2.new(1, 10, 1, 10),
    BackgroundColor3 = WHITE,
    BackgroundTransparency = 0.7,
    Parent = ToggleHolder,
})
corner(ToggleGlow, 19)
gradient(ToggleGlow, { Theme.Crimson, Theme.Violet })

local ToggleBtn = create("TextButton", {
    Name = "ToggleBtn",
    AutoButtonColor = false,
    Text = "",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = WHITE,
    Parent = ToggleHolder,
})
corner(ToggleBtn, 14)
gradient(ToggleBtn, { Color3.fromRGB(74, 14, 42), Color3.fromRGB(34, 16, 62) })
local ToggleStroke = stroke(ToggleBtn, WHITE, 2, 0)
spin(gradient(ToggleStroke, { Theme.Gold, Theme.Crimson, Theme.Violet, Theme.Cyan, Theme.Gold }), 90)
attachRipple(ToggleBtn, function()
    return Theme.Crimson
end)

local ToggleAvatar = create("ImageLabel", {
    Name = "PlayerThumbnail",
    Position = UDim2.fromOffset(8, 8),
    Size = UDim2.fromOffset(32, 32),
    BackgroundColor3 = Color3.fromRGB(38, 31, 67),
    ImageTransparency = 1,
    Parent = ToggleBtn,
})
round(ToggleAvatar)
stroke(ToggleAvatar, Theme.Gold, 1.5, 0)
local ToggleInitial = text(ToggleAvatar, {
    Size = UDim2.fromScale(1, 1),
    Font = Enum.Font.GothamBlack,
    Text = string.sub(LocalPlayer.Name, 1, 1):upper(),
    TextColor3 = Color3.fromRGB(255, 243, 196),
    TextSize = 15,
    TextXAlignment = Enum.TextXAlignment.Center,
})
local ToggleTitle = text(ToggleBtn, {
    Position = UDim2.fromOffset(48, 7),
    Size = UDim2.new(1, -56, 0, 20),
    Font = Enum.Font.GothamBlack,
    Text = "KILLSTAM",
    TextColor3 = WHITE,
    TextSize = 16,
})
shimmer(gradient(ToggleTitle, TITLE_COLORS), 0.35)
local ToggleSub = text(ToggleBtn, {
    Position = UDim2.fromOffset(48, 26),
    Size = UDim2.new(1, -56, 0, 14),
    Font = Enum.Font.GothamMedium,
    Text = "เมนู: เปิดอยู่",
    TextColor3 = Theme.SubText,
    TextSize = 10,
})

-- ═════════════════════════ เปิด/ปิด/ย่อ หน้าต่าง ═════════════════════════
local windowOpen, collapsed = true, false

local function computeScale()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    return math.clamp(math.min((viewport.X - 24) / WINDOW_W, (viewport.Y - 80) / WINDOW_H), 0.5, 1)
end

local baseScale = computeScale()
local function placeWindow()
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, -math.floor(WINDOW_H * baseScale / 2))
end
WindowScale.Scale = baseScale
placeWindow()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
        baseScale = computeScale()
        placeWindow()
        if windowOpen then
            WindowScale.Scale = baseScale
        end
    end)
end

local function setWindow(open)
    windowOpen = open
    ToggleSub.Text = open and "เมนู: เปิดอยู่" or "เมนู: ซ่อนอยู่"
    if open then
        MainFrame.Visible = true
        WindowScale.Scale = baseScale * 0.82
        tween(WindowScale, 0.45, { Scale = baseScale }, Enum.EasingStyle.Back)
    else
        tween(WindowScale, 0.2, { Scale = baseScale * 0.82 }, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.delay(0.2, function()
            if not windowOpen then
                MainFrame.Visible = false
            end
        end)
    end
end

local function setCollapsed(state)
    collapsed = state
    MinBtn.Text = state and "+" or "—"
    tween(MainFrame, 0.4, { Size = UDim2.fromOffset(WINDOW_W, state and COLLAPSED_H or WINDOW_H) })
end

makeDraggable(Banner, MainFrame)
local toggleWasDragged = makeDraggable(ToggleBtn, ToggleHolder)

ToggleBtn.MouseButton1Click:Connect(function()
    if toggleWasDragged() then
        return
    end
    setWindow(not windowOpen)
end)
MinBtn.MouseButton1Click:Connect(function()
    setCollapsed(not collapsed)
end)
CloseBtn.MouseButton1Click:Connect(function()
    setWindow(false)
    notify("ซ่อนเมนูแล้ว", "กดปุ่ม KILLSTAM หรือ RightShift เพื่อเปิด", Theme.Violet, "K")
end)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed or not alive() then
        return
    end
    if input.KeyCode == Enum.KeyCode.RightShift then
        setWindow(not windowOpen)
    end
end)

-- ═════════════════════════ รูปโปรไฟล์ ═════════════════════════
task.spawn(function()
    local success, thumbnail = pcall(function()
        local image, isReady = Players:GetUserThumbnailAsync(
            LocalPlayer.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size100x100
        )
        if not isReady then
            task.wait(0.5)
            image = Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
        end
        return image
    end)

    if success then
        AvatarImage.Image = thumbnail
        AvatarImage.ImageTransparency = 0
        AvatarInitial.Visible = false
        ToggleAvatar.Image = thumbnail
        ToggleAvatar.ImageTransparency = 0
        ToggleInitial.Visible = false
    else
        warn("[KILLSTAM] Failed to load Roblox avatar thumbnail: " .. tostring(thumbnail))
    end
end)

-- ═════════════════════════ ลูปหลัก (แอนิเมชัน + ความเร็ว + เรดาร์) ═════════════════════════
local fpsFrames, fpsTimer = 0, 0
local renderConnection
renderConnection = RunService.RenderStepped:Connect(function(dt)
    if not alive() or not ScreenGui.Parent then
        renderConnection:Disconnect()
        stopRadar()
        stopPlayerTools()
        return
    end

    local now = os.clock()
    for _, item in ipairs(spinners) do
        item[1].Rotation = (now * item[2]) % 360
    end
    for _, item in ipairs(shimmers) do
        item[1].Offset = Vector2.new(((now * item[2]) % 2) - 1, 0)
    end
    local pulse = (math.sin(now * 3.2) + 1) / 2
    ToggleGlow.BackgroundTransparency = 0.55 + pulse * 0.35
    LogoRingStroke.Transparency = 0.1 + pulse * 0.5
    StatusDot.BackgroundTransparency = pulse * 0.6
    for _, row in pairs(liveRows) do
        row.glow.Transparency = row.on and (0.2 + pulse * 0.7) or 1
    end

    fpsFrames = fpsFrames + 1
    fpsTimer = fpsTimer + dt
    if fpsTimer >= 0.5 then
        FooterRight.Text = string.format("FPS %d   •   RShift ซ่อนเมนู", math.floor(fpsFrames / fpsTimer + 0.5))
        fpsFrames, fpsTimer = 0, 0
    end

    -- ระบบทำงานความเร็ววิ่ง (WalkSpeed)
    if getgenv().WalkSpeedActive then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = getgenv().CustomWalkSpeed
            end
        end
    end

    -- สเปคจอ + ESP ผู้เล่น
    if workspace.CurrentCamera then
        updatePlayerTools(workspace.CurrentCamera)
    end

    if not getgenv().ActiveRadarId or not radarState then return end

    sweepHolder.Rotation = (now * 150) % 360

    if radarState.nextScan <= now then
        radarState.nextScan = now + 0.4
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local targets = scanAllObjects(root, radarState.radius, radarState.filter, radarState.highestOnly, radarState.giantOnly, radarState.millionOnly)
            radarState.targets = targets

            if #targets > 0 then
                local best = targets[1]
                local rarityName = RadarData.RARITY_NAME[best.rarity] or best.rarity
                local bestText = string.format("<font color=\"%s\">[%s] %s</font>", hex(best.color), rarityName, best.name)
                if radarState.millionOnly then
                    radarLine1.Text = string.format("<font color=\"%s\">1M+</font>  %s", MUTED_HEX, bestText)
                    radarLine2.Text = string.format("ระยะห่าง: %s", studs(best.dist))
                elseif radarState.giantOnly then
                    radarLine1.Text = string.format("<font color=\"%s\">ใหญ่สุด</font>  %s", MUTED_HEX, bestText)
                    radarLine2.Text = string.format("ขนาด %d สตั๊ด  •  ห่าง %s", math.floor(best.size), studs(best.dist))
                elseif radarState.highestOnly then
                    radarLine1.Text = string.format("<font color=\"%s\">สูงสุด</font>  %s", MUTED_HEX, bestText)
                    radarLine2.Text = string.format("ระยะห่าง: %s", studs(best.dist))
                else
                    radarLine1.Text = string.format("<font color=\"%s\">ใกล้สุด</font>  <font color=\"%s\">%s</font>", MUTED_HEX, hex(best.color), best.name)
                    radarLine2.Text = string.format("ระยะห่าง: %s", studs(best.dist))
                end
            else
                radarLine1.Text = "กำลังสแกนพื้นที่..."
                radarLine2.Text = "ไม่พบแร่ในระยะ"
            end
            radarRange.Text = string.format("ระยะ %s  •  พบ %d", studs(radarState.radius), #targets)

            local activeKeys = {}
            for _, t in ipairs(targets) do
                activeKeys[t.key] = true
                local rarityName = RadarData.RARITY_NAME[t.rarity] or t.rarity
                local txt = string.format("<font color=\"%s\">%s</font>  %s", hex(t.color), rarityName, studs(t.dist))
                local blip = radarState.blips[t.key]

                if not blip or not blip.bb.Parent then
                    blip = worldBlip(t.adornee, t.color, txt)
                    radarState.blips[t.key] = blip
                end
                if blip.label then blip.label.Text = txt end
                blip.dot.BackgroundColor3 = t.color
                blip.ring.Color = t.color
                blip.labelStroke.Color = t.color

                local sBlip = radarState.scopeBlips[t.key]
                if not sBlip then
                    sBlip = create("Frame", {
                        AnchorPoint = Vector2.new(0.5, 0.5),
                        Size = UDim2.fromOffset(6, 6),
                        BorderSizePixel = 0,
                        Position = UDim2.fromScale(0.5, 0.5),
                    })
                    round(sBlip)
                    sBlip.Parent = scopeMask
                    radarState.scopeBlips[t.key] = sBlip
                end
                sBlip.BackgroundColor3 = t.color
            end

            for k, b in pairs(radarState.blips) do
                if not activeKeys[k] then b.bb:Destroy() radarState.blips[k] = nil end
            end
            for k, s in pairs(radarState.scopeBlips) do
                if not activeKeys[k] then s:Destroy() radarState.scopeBlips[k] = nil end
            end
        end
    end

    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    local cam = workspace.CurrentCamera
    if root and cam then
        local fwd = cam.CFrame.LookVector
        local flatFwd = Vector3.new(fwd.X, 0, fwd.Z).Unit
        local right = flatFwd:Cross(Vector3.new(0, 1, 0))
        local radius = radarState.radius

        for _, t in ipairs(radarState.targets) do
            local sBlip = radarState.scopeBlips[t.key]
            if sBlip then
                local delta = t.pos - root.Position
                local x = delta:Dot(right) / radius
                local y = delta:Dot(flatFwd) / radius
                local dist = math.sqrt((x * x) + (y * y))
                if dist > 0.94 then
                    x = x / dist * 0.94
                    y = y / dist * 0.94
                end
                sBlip.Position = UDim2.fromScale(0.5 + (x * 0.5), 0.5 - (y * 0.5))
            end
        end
    end
end)

-- ระบบ Auto Press E / ProximityPrompt
task.spawn(function()
    while alive() do
        task.wait(0.2)
        if getgenv().AutoInteractActive then
            pcall(function()
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ProximityPrompt") then
                        local parent = obj.Parent
                        local pos = nil
                        if parent:IsA("BasePart") then
                            pos = parent.Position
                        elseif parent:IsA("Model") and parent.PrimaryPart then
                            pos = parent.PrimaryPart.Position
                        end

                        if pos and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                            local rootPos = LocalPlayer.Character.HumanoidRootPart.Position
                            if (pos - rootPos).Magnitude <= (obj.MaxActivationDistance or 25) then
                                fireproximityprompt(obj)
                            end
                        end
                    end
                end
            end)
        end
    end
end)

-- ระบบขุดอัตโนมัติ
task.spawn(function()
    local DigRequest = ReplicatedStorage:WaitForChild("DigRemotes"):WaitForChild("DigRequest", 10)
    while alive() do
        task.wait(getgenv().DigDelayValue)
        if getgenv().AutoDigActive and DigRequest then
            pcall(function() DigRequest:FireServer(Mouse.Hit.Position, true) end)
        end
    end
end)

-- ═════════════════════════ เอฟเฟกต์อลังการ ═════════════════════════
-- ประกายไฟลอยขึ้นจากแบนเนอร์
task.spawn(function()
    local sparkColors = { Theme.Crimson, Theme.Gold, Theme.Violet, Theme.Ember }
    while alive() and ScreenGui.Parent do
        task.wait(0.12)
        if MainFrame.Visible then
            local size = math.random(2, 4)
            local spark = create("Frame", {
                BorderSizePixel = 0,
                BackgroundColor3 = sparkColors[math.random(#sparkColors)],
                BackgroundTransparency = 0.15,
                Size = UDim2.fromOffset(size, size),
                Position = UDim2.fromOffset(math.random(60, 520), 60),
                ZIndex = 0,
                Parent = Banner,
            })
            round(spark)
            local life = math.random(12, 22) / 10
            tween(spark, life, {
                Position = spark.Position + UDim2.fromOffset(math.random(-14, 14), -math.random(25, 55)),
                BackgroundTransparency = 1,
            }, Enum.EasingStyle.Sine)
            task.delay(life, function()
                spark:Destroy()
            end)
        end
    end
end)

-- ชื่อ KILLSTAM กระตุกแบบ glitch เป็นระยะ
task.spawn(function()
    while alive() and ScreenGui.Parent do
        task.wait(math.random(25, 50) / 10)
        for _ = 1, 4 do
            TitleGhostA.Position = GHOST_A_POS + UDim2.fromOffset(math.random(-4, 4), math.random(-2, 2))
            TitleGhostB.Position = GHOST_B_POS + UDim2.fromOffset(math.random(-4, 4), math.random(-2, 2))
            task.wait(0.05)
        end
        TitleGhostA.Position = GHOST_A_POS
        TitleGhostB.Position = GHOST_B_POS
    end
end)

-- ═════════════════════════ อินโทรตอนเปิด ═════════════════════════
refreshLive()
selectTab("Farm")

task.spawn(function()
    local titleLayers = { TitleMain, TitleGhostA, TitleGhostB }
    for _, label in ipairs(titleLayers) do
        label.MaxVisibleGraphemes = 0
    end
    MainFrame.Visible = true
    WindowScale.Scale = baseScale * 0.5
    tween(WindowScale, 0.7, { Scale = baseScale }, Enum.EasingStyle.Back)
    task.wait(0.3)
    for i = 1, 8 do
        for _, label in ipairs(titleLayers) do
            label.MaxVisibleGraphemes = i
        end
        task.wait(0.05)
    end
    for _, label in ipairs(titleLayers) do
        label.MaxVisibleGraphemes = -1
    end
    notify("KILLSTAM พร้อมลุย!", "ยินดีต้อนรับ " .. LocalPlayer.DisplayName, Theme.Crimson, "K", 3.5)
end)

print("[KILLSTAM] โหลดเมนูเรียบร้อยแล้ว")
