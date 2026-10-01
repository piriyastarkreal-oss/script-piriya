-- โค้ดเมนู UI Piriya Menu (เรดาร์ระยะปกติ + เพิ่มฟังก์ชันปรับความเร็ววิ่ง)
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

if CoreGui:FindFirstChild("PiriyaMenuHub") then
    CoreGui.PiriyaMenuHub:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "PiriyaMenuHub"
ScreenGui.Parent = CoreGui
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Name = "ToggleBtn"
ToggleBtn.Parent = ScreenGui
ToggleBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
ToggleBtn.Size = UDim2.new(0, 130, 0, 42)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Text = "⛏ Piriya Hub"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 8)

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 32)
MainFrame.Position = UDim2.new(0.05, 0, 0.18, 0)
MainFrame.Size = UDim2.new(0, 420, 0, 520)
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke")
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(60, 60, 70)
MainStroke.Parent = MainFrame

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundTransparency = 1
TitleLabel.Position = UDim2.new(0, 15, 0, 10)
TitleLabel.Size = UDim2.new(1, -30, 0, 30)
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.Text = "PIRIYA CONTROL PANEL (STANDARD)"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 14
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left

local LeftCol = Instance.new("ScrollingFrame")
LeftCol.Parent = MainFrame
LeftCol.BackgroundTransparency = 1
LeftCol.Position = UDim2.new(0, 12, 0, 45)
LeftCol.Size = UDim2.new(0, 190, 0, 430)
LeftCol.CanvasSize = UDim2.new(0, 0, 0, 480)
LeftCol.ScrollBarThickness = 4
LeftCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
local LeftLayout = Instance.new("UIListLayout")
LeftLayout.Parent = LeftCol
LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
LeftLayout.Padding = UDim.new(0, 8)

local RightCol = Instance.new("ScrollingFrame")
RightCol.Parent = MainFrame
RightCol.BackgroundTransparency = 1
RightCol.Position = UDim2.new(0, 215, 0, 45)
RightCol.Size = UDim2.new(0, 192, 0, 430)
RightCol.CanvasSize = UDim2.new(0, 0, 0, 600)
RightCol.ScrollBarThickness = 4
RightCol.AutomaticCanvasSize = Enum.AutomaticSize.Y
local RightLayout = Instance.new("UIListLayout")
RightLayout.Parent = RightCol
RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
RightLayout.Padding = UDim.new(0, 8)

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Parent = MainFrame
StatusLabel.BackgroundTransparency = 1
StatusLabel.Position = UDim2.new(0, 15, 1, -28)
StatusLabel.Size = UDim2.new(1, -30, 0, 25)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.Text = "Status: Standard Radar Ready"
StatusLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
StatusLabel.TextSize = 11
StatusLabel.TextXAlignment = Enum.TextXAlignment.Left

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

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
local savedPosition = nil
local currentPositionBeforeTp = nil

local function createButton(parent, name, text, color, order)
    local btn = Instance.new("TextButton")
    btn.Name = name
    btn.Parent = parent
    btn.BackgroundColor3 = color
    btn.Size = UDim2.new(1, -5, 0, 32)
    btn.Font = Enum.Font.GothamBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 12
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local AutoDigBtn = createButton(LeftCol, "AutoDigBtn", "Auto Dig: OFF", Color3.fromRGB(60, 60, 65), 1)
local AutoInteractBtn = createButton(LeftCol, "AutoInteractBtn", "⚡ Auto Press E: OFF", Color3.fromRGB(60, 60, 65), 2)
local WalkSpeedBtn = createButton(LeftCol, "WalkSpeedBtn", "🏃 WalkSpeed: OFF", Color3.fromRGB(60, 60, 65), 3)

local SpeedBox = Instance.new("TextBox")
SpeedBox.Parent = LeftCol
SpeedBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
SpeedBox.Size = UDim2.new(1, -5, 0, 30)
SpeedBox.Font = Enum.Font.GothamSemibold
SpeedBox.PlaceholderText = "WalkSpeed Value"
SpeedBox.Text = "30"
SpeedBox.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBox.TextSize = 12
SpeedBox.LayoutOrder = 4
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 6)

SpeedBox.FocusLost:Connect(function()
    local num = tonumber(SpeedBox.Text)
    if num and num > 0 then
        getgenv().CustomWalkSpeed = num
    else
        SpeedBox.Text = tostring(getgenv().CustomWalkSpeed)
    end
end)

local DelayBox = Instance.new("TextBox")
DelayBox.Parent = LeftCol
DelayBox.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
DelayBox.Size = UDim2.new(1, -5, 0, 30)
DelayBox.Font = Enum.Font.GothamSemibold
DelayBox.PlaceholderText = "Dig Delay"
DelayBox.Text = "0.05"
DelayBox.TextColor3 = Color3.fromRGB(255, 255, 255)
DelayBox.TextSize = 12
DelayBox.LayoutOrder = 5
Instance.new("UICorner", DelayBox).CornerRadius = UDim.new(0, 6)

DelayBox.FocusLost:Connect(function()
    local num = tonumber(DelayBox.Text)
    if num and num > 0 then getgenv().DigDelayValue = num else DelayBox.Text = tostring(getgenv().DigDelayValue) end
end)

AutoDigBtn.MouseButton1Click:Connect(function()
    getgenv().AutoDigActive = not getgenv().AutoDigActive
    if getgenv().AutoDigActive then
        AutoDigBtn.Text = "Auto Dig: ON"
        AutoDigBtn.BackgroundColor3 = Color3.fromRGB(40, 130, 60)
    else
        AutoDigBtn.Text = "Auto Dig: OFF"
        AutoDigBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

AutoInteractBtn.MouseButton1Click:Connect(function()
    getgenv().AutoInteractActive = not getgenv().AutoInteractActive
    if getgenv().AutoInteractActive then
        AutoInteractBtn.Text = "⚡ Auto Press E: ON"
        AutoInteractBtn.BackgroundColor3 = Color3.fromRGB(180, 110, 20)
    else
        AutoInteractBtn.Text = "⚡ Auto Press E: OFF"
        AutoInteractBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

WalkSpeedBtn.MouseButton1Click:Connect(function()
    getgenv().WalkSpeedActive = not getgenv().WalkSpeedActive
    if getgenv().WalkSpeedActive then
        WalkSpeedBtn.Text = "🏃 WalkSpeed: ON"
        WalkSpeedBtn.BackgroundColor3 = Color3.fromRGB(40, 120, 160)
    else
        WalkSpeedBtn.Text = "🏃 WalkSpeed: OFF"
        WalkSpeedBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 65)
    end
end)

createButton(LeftCol, "SellAllBtn", "💰 Sell All Items", Color3.fromRGB(160, 90, 30), 6).MouseButton1Click:Connect(function()
    pcall(function() ReplicatedStorage:FindFirstChild("RequestSell", true):FireServer("All") end)
end)
createButton(LeftCol, "UpgradeBagBtn", "🎒 Max Carry", Color3.fromRGB(40, 100, 160), 7).MouseButton1Click:Connect(function()
    pcall(function() ReplicatedStorage:FindFirstChild("BuyUpgrade", true):FireServer("carry", "max") end)
end)
createButton(LeftCol, "UpgradeWarmthBtn", "🔥 Max Warmth", Color3.fromRGB(160, 50, 50), 8).MouseButton1Click:Connect(function()
    pcall(function() ReplicatedStorage:FindFirstChild("BuyUpgrade", true):FireServer("warmth", "max") end)
end)
createButton(LeftCol, "SetTpBtn", "📍 Set TP Pos", Color3.fromRGB(70, 70, 140), 9).MouseButton1Click:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            savedPosition = char.HumanoidRootPart.CFrame
            StatusLabel.Text = "Status: TP Position Saved!"
        end
    end)
end)
createButton(LeftCol, "TpToggleBtn", "🚀 Teleport Toggle", Color3.fromRGB(90, 50, 140), 10).MouseButton1Click:Connect(function()
    pcall(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp or not savedPosition then return end
        if not currentPositionBeforeTp then
            currentPositionBeforeTp = hrp.CFrame
            hrp.CFrame = savedPosition
        else
            hrp.CFrame = currentPositionBeforeTp
            currentPositionBeforeTp = nil
        end
    end)
end)

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
    ById = {
        CommonRadar = { displayName = "Common Radar", radius = 100 },
        UncommonRadar = { displayName = "Uncommon Radar", radius = 150 },
        RareRadar = { displayName = "Rare Radar", radius = 200 },
        EpicRadar = { displayName = "Epic Radar", radius = 250 },
        LegendaryRadar = { displayName = "Legendary Radar", radius = 300 },
        MythicRadar = { displayName = "Mythic Radar", radius = 350 },
        ExoticRadar = { displayName = "Exotic Radar", radius = 400 },
        ZenithRadar = { displayName = "Zenith Radar", radius = 500 },
        MeteorRadar = { displayName = "Meteor Radar", radius = 600 },
    },
}

local WHITE = Color3.new(1, 1, 1)
local BLACK = Color3.new(0, 0, 0)
local SCOPE_GREEN = Color3.fromRGB(90, 230, 130)

local function hex(c)
    return string.format("#%02X%02X%02X", math.floor((c.R*255)+0.5), math.floor((c.G*255)+0.5), math.floor((c.B*255)+0.5))
end
local function studs(v) return string.format("%d studs", math.floor(v + 0.5)) end

local radarHudPanel = Instance.new("Frame")
radarHudPanel.Name = "RadarHudPanel"
radarHudPanel.Position = UDim2.new(0, 14, 0.45, 0)
radarHudPanel.Size = UDim2.fromOffset(350, 118)
radarHudPanel.BackgroundColor3 = Color3.fromRGB(16, 20, 28)
radarHudPanel.BackgroundTransparency = 0.12
radarHudPanel.Visible = false
radarHudPanel.Parent = ScreenGui
Instance.new("UICorner", radarHudPanel).CornerRadius = UDim.new(0, 14)
local radarPanelStroke = Instance.new("UIStroke")
radarPanelStroke.Thickness = 2
radarPanelStroke.Color = BLACK
radarPanelStroke.Parent = radarHudPanel

local scopeFrame = Instance.new("Frame")
scopeFrame.Name = "Scope"
scopeFrame.Position = UDim2.fromOffset(10, 10)
scopeFrame.Size = UDim2.fromOffset(98, 98)
scopeFrame.BackgroundColor3 = Color3.fromRGB(8, 36, 22)
scopeFrame.ClipsDescendants = true
scopeFrame.Parent = radarHudPanel
Instance.new("UICorner", scopeFrame).CornerRadius = UDim.new(1, 0)
local scopeStroke = Instance.new("UIStroke")
scopeStroke.Thickness = 2
scopeStroke.Color = SCOPE_GREEN
scopeStroke.Parent = scopeFrame

for _, sVal in ipairs({0.66, 0.33}) do
    local ring = Instance.new("Frame")
    ring.AnchorPoint = Vector2.new(0.5, 0.5)
    ring.Position = UDim2.fromScale(0.5, 0.5)
    ring.Size = UDim2.fromScale(sVal, sVal)
    ring.BackgroundTransparency = 1
    ring.Parent = scopeFrame
    Instance.new("UICorner", ring).CornerRadius = UDim.new(1, 0)
    local rs = Instance.new("UIStroke")
    rs.Thickness = 1
    rs.Color = SCOPE_GREEN
    rs.Transparency = 0.65
    rs.Parent = ring
end

local scopeMask = Instance.new("Frame")
scopeMask.BackgroundTransparency = 1
scopeMask.Size = UDim2.fromScale(1, 1)
scopeMask.ZIndex = 4
scopeMask.Parent = scopeFrame

local scopeDot = Instance.new("Frame")
scopeDot.AnchorPoint = Vector2.new(0.5, 0.5)
scopeDot.Position = UDim2.fromScale(0.5, 0.5)
scopeDot.Size = UDim2.fromOffset(8, 8)
scopeDot.BackgroundColor3 = WHITE
scopeDot.ZIndex = 6
scopeDot.Parent = scopeFrame
Instance.new("UICorner", scopeDot).CornerRadius = UDim.new(1, 0)

local function createRadarLabel(name, yOffset, height, fontSize, bold)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(118, yOffset)
    label.Size = UDim2.new(1, -128, 0, height)
    label.Font = bold and Enum.Font.FredokaOne or Enum.Font.GothamBold
    label.TextSize = fontSize
    label.TextColor3 = WHITE
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextStrokeTransparency = 0.5
    label.RichText = true
    label.Parent = radarHudPanel
    return label
end

local radarTitle = createRadarLabel("Title", 8, 28, 22, true)
local radarLine1 = createRadarLabel("Line1", 38, 22, 15, false)
local radarLine2 = createRadarLabel("Line2", 60, 20, 13, false)
radarLine2.TextColor3 = Color3.fromRGB(200, 205, 215)

local radarState = nil

local function worldBlip(adornee, color, textLabel)
    local gui = Instance.new("BillboardGui")
    gui.Name = "RadarDot"
    gui.AlwaysOnTop = true
    gui.Size = UDim2.fromOffset(150, 44)
    gui.StudsOffsetWorldSpace = Vector3.new(0, 2.2, 0)
    gui.Adornee = adornee
    gui.MaxDistance = 1500
    gui.Parent = adornee

    local dot = Instance.new("Frame")
    dot.AnchorPoint = Vector2.new(0.5, 0)
    dot.Position = UDim2.fromScale(0.5, 0)
    dot.Size = UDim2.fromOffset(12, 12)
    dot.BackgroundColor3 = color
    dot.Parent = gui
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1.5
    stroke.Color = BLACK
    stroke.Parent = dot

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.new(0, 0, 0, 14)
    label.Size = UDim2.new(1, 0, 0, 20)
    label.Font = Enum.Font.FredokaOne
    label.TextSize = 12
    label.TextColor3 = WHITE
    label.TextStrokeTransparency = 0
    label.RichText = true
    label.Text = textLabel
    label.Parent = gui
    return { bb = gui, dot = dot, label = label }
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

    if millionOnly then
        scopeStroke.Color = Color3.fromRGB(255, 215, 0)
        radarTitle.Text = "<font color=\"#FFD700\">💰 1M+ VALUE</font>"
    elseif giantOnly then
        scopeStroke.Color = Color3.fromRGB(50, 220, 255)
        radarTitle.Text = "<font color=\"#32DCFF\">🏔️ GIANT OBJECT</font>"
    elseif highestOnly then
        scopeStroke.Color = Color3.fromRGB(255, 75, 220)
        radarTitle.Text = "<font color=\"#FF4BDC\">👑 HIGHEST VALUE</font>"
    else
        scopeStroke.Color = isAll and Color3.fromRGB(255, 220, 50) or (RadarData.RARITY_COLOR[targetRarity] or SCOPE_GREEN)
        radarTitle.Text = isAll and "<font color=\"#FFDC32\">🌟 ALL RADARS</font>" or string.format("<font color=\"%s\">%s</font>", hex(scopeStroke.Color), def.displayName)
    end
    radarHudPanel.Visible = true
end

local MillionScanBtn = createButton(RightCol, "MillionScanBtn", "💰 1M+ Value: OFF", Color3.fromRGB(180, 140, 20), 0)
local GiantScanBtn = createButton(RightCol, "GiantScanBtn", "🏔️ Giant Object: OFF", Color3.fromRGB(30, 110, 140), 1)
local HighestOnlyBtn = createButton(RightCol, "HighestOnlyBtn", "👑 Highest Value: OFF", Color3.fromRGB(140, 40, 110), 2)
local AllRadarsBtn = createButton(RightCol, "AllRadarsBtn", "🌟 All Radars: OFF", Color3.fromRGB(120, 90, 20), 3)

local radarList = {
    {id = "CommonRadar", name = "⚪ Common", order = 4},
    {id = "UncommonRadar", name = "🟢 Uncommon", order = 5},
    {id = "RareRadar", name = "🔵 Rare", order = 6},
    {id = "EpicRadar", name = "🟣 Epic", order = 7},
    {id = "LegendaryRadar", name = "🟠 Legendary", order = 8},
    {id = "MythicRadar", name = "🔴 Mythic", order = 9},
    {id = "ExoticRadar", name = "🟡 Exotic", order = 10},
    {id = "ZenithRadar", name = "✨ Zenith", order = 11},
    {id = "MeteorRadar", name = "☄️ Meteor", order = 12},
}
local radarButtons = {}

local function resetAllBtns()
    MillionScanBtn.Text = "💰 1M+ Value: OFF"
    MillionScanBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 20)
    GiantScanBtn.Text = "🏔️ Giant Object: OFF"
    GiantScanBtn.BackgroundColor3 = Color3.fromRGB(30, 110, 140)
    HighestOnlyBtn.Text = "👑 Highest Value: OFF"
    HighestOnlyBtn.BackgroundColor3 = Color3.fromRGB(140, 40, 110)
    AllRadarsBtn.Text = "🌟 All Radars: OFF"
    AllRadarsBtn.BackgroundColor3 = Color3.fromRGB(120, 90, 20)
    for id, btn in pairs(radarButtons) do
        local info = nil
        for _, v in ipairs(radarList) do if v.id == id then info = v end end
        btn.Text = (info and info.name or id) .. ": OFF"
        btn.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
    end
end

MillionScanBtn.MouseButton1Click:Connect(function()
    if getgenv().MillionScanActive then
        getgenv().MillionScanActive = false
        getgenv().ActiveRadarId = nil
        resetAllBtns()
        stopRadar()
    else
        getgenv().MillionScanActive = true
        getgenv().GiantScanActive = false
        getgenv().HighestOnlyActive = false
        getgenv().AllRadarsActive = false
        getgenv().ActiveRadarId = "Million"
        resetAllBtns()
        MillionScanBtn.Text = "💰 1M+ Value: ON"
        MillionScanBtn.BackgroundColor3 = Color3.fromRGB(220, 170, 20)
        startRadar("MeteorRadar", false, false, false, true)
    end
end)

GiantScanBtn.MouseButton1Click:Connect(function()
    if getgenv().GiantScanActive then
        getgenv().GiantScanActive = false
        getgenv().ActiveRadarId = nil
        resetAllBtns()
        stopRadar()
    else
        getgenv().GiantScanActive = true
        getgenv().MillionScanActive = false
        getgenv().HighestOnlyActive = false
        getgenv().AllRadarsActive = false
        getgenv().ActiveRadarId = "Giant"
        resetAllBtns()
        GiantScanBtn.Text = "🏔️ Giant Object: ON"
        GiantScanBtn.BackgroundColor3 = Color3.fromRGB(30, 160, 200)
        startRadar("MeteorRadar", false, false, true, false)
    end
end)

HighestOnlyBtn.MouseButton1Click:Connect(function()
    if getgenv().HighestOnlyActive then
        getgenv().HighestOnlyActive = false
        getgenv().ActiveRadarId = nil
        resetAllBtns()
        stopRadar()
    else
        getgenv().HighestOnlyActive = true
        getgenv().MillionScanActive = false
        getgenv().GiantScanActive = false
        getgenv().AllRadarsActive = false
        getgenv().ActiveRadarId = "Highest"
        resetAllBtns()
        HighestOnlyBtn.Text = "👑 Highest Value: ON"
        HighestOnlyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 160)
        startRadar("MeteorRadar", false, true, false, false)
    end
end)

AllRadarsBtn.MouseButton1Click:Connect(function()
    if getgenv().AllRadarsActive then
        getgenv().AllRadarsActive = false
        getgenv().HighestOnlyActive = false
        getgenv().GiantScanActive = false
        resetAllBtns()
        stopRadar()
    else
        getgenv().AllRadarsActive = true
        getgenv().MillionScanActive = false
        getgenv().HighestOnlyActive = false
        getgenv().GiantScanActive = false
        resetAllBtns()
        AllRadarsBtn.Text = "🌟 All Radars: ON"
        AllRadarsBtn.BackgroundColor3 = Color3.fromRGB(180, 130, 20)
        startRadar("MeteorRadar", true, false, false, false)
    end
end)

for _, info in ipairs(radarList) do
    local btn = createButton(RightCol, info.id, info.name .. ": OFF", Color3.fromRGB(50, 50, 55), info.order)
    radarButtons[info.id] = btn
    btn.MouseButton1Click:Connect(function()
        if getgenv().ActiveRadarId == info.id then
            getgenv().ActiveRadarId = nil
            getgenv().AllRadarsActive = false
            getgenv().HighestOnlyActive = false
            getgenv().GiantScanActive = false
            getgenv().MillionScanActive = false
            resetAllBtns()
            stopRadar()
        else
            getgenv().AllRadarsActive = false
            getgenv().HighestOnlyActive = false
            getgenv().GiantScanActive = false
            getgenv().MillionScanActive = false
            resetAllBtns()
            getgenv().ActiveRadarId = info.id
            btn.Text = info.name .. ": ON"
            btn.BackgroundColor3 = Color3.fromRGB(35, 110, 50)
            startRadar(info.id, false, false, false, false)
        end
    end)
end

-- ระบบทำงานความเร็ววิ่ง (WalkSpeed)
RunService.RenderStepped:Connect(function()
    if getgenv().WalkSpeedActive then
        local char = LocalPlayer.Character
        if char then
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = getgenv().CustomWalkSpeed
            end
        end
    end

    if not getgenv().ActiveRadarId or not radarState then return end

    local now = os.clock()
    scopeFrame.Rotation = (now * 150) % 360

    if radarState.nextScan <= now then
        radarState.nextScan = now + 0.4
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then
            local targets = scanAllObjects(root, radarState.radius, radarState.filter, radarState.highestOnly, radarState.giantOnly, radarState.millionOnly)
            radarState.targets = targets

            if #targets > 0 then
                local best = targets[1]
                if radarState.millionOnly then
                    radarLine1.Text = string.format("💰 1M+: <font color=\"%s\">[%s] %s</font>", hex(best.color), best.rarity, best.name)
                    radarLine2.Text = string.format("Distance: %s", studs(best.dist))
                elseif radarState.giantOnly then
                    radarLine1.Text = string.format("🏔️ Giant: <font color=\"%s\">[%s] %s</font>", hex(best.color), best.rarity, best.name)
                    radarLine2.Text = string.format("Size: %d studs → %s", math.floor(best.size), studs(best.dist))
                elseif radarState.highestOnly then
                    radarLine1.Text = string.format("👑 Best: <font color=\"%s\">[%s] %s</font>", hex(best.color), best.rarity, best.name)
                    radarLine2.Text = string.format("Distance: %s", studs(best.dist))
                else
                    radarLine1.Text = string.format("⚡ Found: <font color=\"%s\">%s</font>", hex(best.color), best.name)
                    radarLine2.Text = string.format("Distance: %s", studs(best.dist))
                end
            else
                radarLine1.Text = "Scanning Area..."
                radarLine2.Text = "No items in range"
            end

            local activeKeys = {}
            for _, t in ipairs(targets) do
                activeKeys[t.key] = true
                local txt = string.format("<font color=\"%s\">%s</font> (%s)", hex(t.color), t.rarity, studs(t.dist))
                local blip = radarState.blips[t.key]

                if not blip or not blip.bb.Parent then
                    blip = worldBlip(t.adornee, t.color, txt)
                    radarState.blips[t.key] = blip
                end
                if blip.label then blip.label.Text = txt end
                blip.dot.BackgroundColor3 = t.color

                local sBlip = radarState.scopeBlips[t.key]
                if not sBlip then
                    sBlip = Instance.new("Frame")
                    sBlip.AnchorPoint = Vector2.new(0.5, 0.5)
                    sBlip.Size = UDim2.fromOffset(6, 6)
                    sBlip.BorderSizePixel = 0
                    sBlip.Position = UDim2.fromScale(0.5, 0.5)
                    Instance.new("UICorner", sBlip).CornerRadius = UDim.new(1, 0)
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
    while true do
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

task.spawn(function()
    local DigRequest = ReplicatedStorage:WaitForChild("DigRemotes"):WaitForChild("DigRequest", 10)
    while true do
        task.wait(getgenv().DigDelayValue)
        if getgenv().AutoDigActive and DigRequest then
            pcall(function() DigRequest:FireServer(Mouse.Hit.Position, true) end)
        end
    end
end)

print("[Piriya Hub] Standard Radars & WalkSpeed Loaded Successfully!")
