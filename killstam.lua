-- ==========================================================
-- SCRIPT ULTIMATE AFK MASTER UI + SMART AUTO-SELL (CUSTOM THRESHOLD)
-- RUN IN Volt Executor (Client-side)
-- ==========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

local localPlayer = Players.LocalPlayer
local playerName = localPlayer.Name

-- ดึงรูปอวาตาร์ของผู้เล่น
local playerThumbnail = ""
local okThumb, thumbImg = pcall(Players.GetUserThumbnailAsync, Players, localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
if okThumb then playerThumbnail = thumbImg end

-- โหลดโมดูลข้อมูลที่จำเป็นจากเกม
local UpgradesConfig = require(ReplicatedStorage.Framework.Features.Upgrades.Upgrades)
local TreeStructure = require(ReplicatedStorage.Framework.Features.Upgrades.TreeStructure)
local DiceConfig = require(ReplicatedStorage.Framework.Features.Rolling.Dice)
local RebirthsConfig = require(ReplicatedStorage.Framework.Features.Rebirth.Rebirths)
local framework = ReplicatedStorage:FindFirstChild("Framework")
local DataController = framework and require(framework.Features.Data.DataController) or nil

-- โหลดโมดูลระบบขาย (Sell System) เพื่อดึงข้อมูลมาทำ Smart Sell
local SellUtil = framework and require(framework.Features.Selling.SellUtil) or nil
local EntryRegistry = framework and require(framework.Features.Inventory.EntryRegistry) or nil

-- ค้นหา RemoteEvents ของเกม
local network = ReplicatedStorage:WaitForChild("Network", 5)
local function findRemote(service, folderName, remoteName)
    if not service then return nil end
    local folder = service:WaitForChild(folderName, 5)
    return (folder and folder:WaitForChild(remoteName, 5))
        or service:FindFirstChild(remoteName, true)
        or (network and network:FindFirstChild(remoteName, true))
end

local plotService = network and network:WaitForChild("PlotService", 5)
local collectBalanceEvent = findRemote(plotService, "RE", "CollectBalance")
local levelUpSlotEvent = findRemote(plotService, "RE", "LevelUpSlot")
local equipBestEvent = findRemote(plotService, "RE", "EquipBest")
local buyUpgradeEvent = findRemote(network, "RE", "BuyUpgrade")

-- ค้นหา RemoteEvents ของระบบลูกเต๋า
local diceShopService = network and network:WaitForChild("DiceShopService", 5)
local buyDiceEvent = findRemote(diceShopService, "RE", "BuyDice")
local equipDiceEvent = findRemote(diceShopService, "RE", "EquipDice")

-- ค้นหา RemoteEvent ของระบบ Rebirth
local rebirthServiceComm = network and network:WaitForChild("RebirthService", 5)
local rebirthEvent = findRemote(rebirthServiceComm, "RE", "Rebirth")

-- ค้นหา RemoteEvent ของระบบขาย (SellService - SellInventory)
local sellServiceComm = network and network:WaitForChild("SellService", 5)
local sellInventoryEvent = findRemote(sellServiceComm, "RF", "SellInventory")

-- ค้นหา Event แจ้งเตือนสำหรับระบบ Block Notifications
local notificationService = network and network:WaitForChild("NotificationService", 5)
local textNotificationRE = findRemote(notificationService, "RE", "TextNotification")

-- ลบ UI เก่าทิ้งก่อน (ถ้ามี)
local oldGui = CoreGui:FindFirstChild("EpicAFK_Piriya")
if oldGui then
    oldGui:Destroy()
end

-- สร้าง ScreenGui หลัก
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "EpicAFK_Piriya"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    screenGui.Parent = CoreGui
end)
if not screenGui.Parent then
    screenGui.Parent = localPlayer:WaitForChild("PlayerGui")
end

-- 1. ปุ่มเปิดหน้าต่างแบบย่อ (Floating Open Button)
local openButton = Instance.new("ImageButton")
openButton.Size = UDim2.new(0, 44, 0, 44)
openButton.Position = UDim2.new(0, 20, 0.4, 0)
openButton.BackgroundColor3 = Color3.fromRGB(60, 52, 137)
openButton.Image = playerThumbnail
openButton.Visible = false
openButton.Active = true
openButton.Parent = screenGui

Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 10)
local openStroke = Instance.new("UIStroke", openButton)
openStroke.Color = Color3.fromRGB(250, 199, 117)
openStroke.Thickness = 2

-- กรอบไล่สีหมุนรอบนอก (Frame ภายนอก)
local outerFrame = Instance.new("Frame")
outerFrame.Size = UDim2.new(0, 330, 0, 560) -- ขยายความสูงเพิ่มรองรับช่องกรอกข้อความ
outerFrame.Position = UDim2.new(0.5, -165, 0.1, 0)
outerFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
outerFrame.BorderSizePixel = 0
outerFrame.Active = true
outerFrame.Parent = screenGui

local outerCorner = Instance.new("UICorner")
outerCorner.CornerRadius = UDim.new(0, 20)
outerCorner.Parent = outerFrame

local outerGradient = Instance.new("UIGradient")
outerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(250, 199, 117)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(212, 83, 126)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(127, 119, 221)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(93, 202, 165)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(250, 199, 117))
})
outerGradient.Parent = outerFrame

-- เมนูด้านใน (Main Panel)
local mainPanel = Instance.new("ScrollingFrame")
mainPanel.Size = UDim2.new(1, -6, 1, -6)
mainPanel.Position = UDim2.new(0, 3, 0, 3)
mainPanel.BackgroundColor3 = Color3.fromRGB(17, 14, 28)
mainPanel.BorderSizePixel = 0
mainPanel.CanvasSize = UDim2.new(0, 0, 0, 1240)
mainPanel.ScrollBarThickness = 4
mainPanel.Parent = outerFrame

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 17)
panelCorner.Parent = mainPanel

-- ส่วนหัว (Header)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 156)
header.BackgroundColor3 = Color3.fromRGB(60, 52, 137)
header.BorderSizePixel = 0
header.ClipsDescendants = true
header.Parent = mainPanel

local headerGradient = Instance.new("UIGradient", header)
headerGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 52, 137)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(17, 14, 28))
})

for index = 1, 12 do
    local ray = Instance.new("Frame")
    ray.AnchorPoint = Vector2.new(0.5, 0.5)
    ray.Position = UDim2.new(0.5, 0, 0.5, 0)
    ray.Size = UDim2.new(0, 2, 0, 168)
    ray.Rotation = (index - 1) * 30
    ray.BackgroundColor3 = Color3.fromRGB(206, 203, 246)
    ray.BackgroundTransparency = 0.88
    ray.BorderSizePixel = 0
    ray.ZIndex = 1
    ray.Parent = header
end

local TweenService = game:GetService("TweenService")
local sparklePositions = {
    UDim2.new(0, 34, 0, 24),
    UDim2.new(0, 72, 0, 102),
    UDim2.new(1, -48, 0, 28),
    UDim2.new(1, -80, 0, 106),
    UDim2.new(0, 112, 0, 12)
}
for index, position in ipairs(sparklePositions) do
    local sparkle = Instance.new("TextLabel")
    sparkle.Size = UDim2.new(0, 20, 0, 20)
    sparkle.Position = position
    sparkle.BackgroundTransparency = 1
    sparkle.Font = Enum.Font.GothamBold
    sparkle.Text = index == 5 and "*" or "+"
    sparkle.TextColor3 = Color3.fromRGB(250, 199, 117)
    sparkle.TextSize = index % 2 == 0 and 13 or 17
    sparkle.TextTransparency = 0.2
    sparkle.ZIndex = 2
    sparkle.Parent = header
    TweenService:Create(
        sparkle,
        TweenInfo.new(1.4 + index * 0.12, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { TextTransparency = 0.8 }
    ):Play()
end

-- ระบบลากหน้าต่างด้วย Header
local dragging, dragInput, dragStart, startPos
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = outerFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        outerFrame.Position = UDim2.new(
            startPos.X.Scale, 
            startPos.X.Offset + delta.X, 
            startPos.Y.Scale, 
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ปุ่มปิด (X Button)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 28)
closeBtn.Position = UDim2.new(1, -35, 0, 10)
closeBtn.BackgroundColor3 = Color3.fromRGB(212, 83, 126)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = header
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)

closeBtn.MouseButton1Click:Connect(function()
    outerFrame.Visible = false
    openButton.Visible = true
end)

openButton.MouseButton1Click:Connect(function()
    outerFrame.Visible = true
    openButton.Visible = false
end)

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.new(0, 96, 0, 96)
avatar.Position = UDim2.new(0.5, -48, 0, 30)
avatar.BackgroundTransparency = 1
avatar.Image = playerThumbnail
avatar.ZIndex = 3
avatar.Parent = header
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

local crown = Instance.new("TextLabel")
crown.Size = UDim2.new(0, 34, 0, 30)
crown.Position = UDim2.new(0.5, -17, 0, 2)
crown.BackgroundTransparency = 1
crown.Font = Enum.Font.GothamBold
crown.Text = "♛"
crown.TextColor3 = Color3.fromRGB(250, 199, 117)
crown.TextSize = 27
crown.Rotation = -12
crown.ZIndex = 4
crown.Parent = header

local ring = Instance.new("UIStroke", avatar)
ring.Thickness = 3
ring.Color = Color3.new(1, 1, 1)
local ringGrad = Instance.new("UIGradient", ring)
ringGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 120)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(210, 80, 130)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 120)),
})

RunService.RenderStepped:Connect(function(dt)
    ringGrad.Rotation = (ringGrad.Rotation + 120 * dt) % 360
    outerGradient.Rotation = (outerGradient.Rotation + 60 * dt) % 360
end)

local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(1, 0, 0, 64)
titleContainer.Position = UDim2.new(0, 0, 0, 158)
titleContainer.BackgroundTransparency = 1
titleContainer.Parent = mainPanel

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, 0, 0, 36)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Enum.Font.GothamBold
nameLabel.Text = playerName
nameLabel.TextColor3 = Color3.fromRGB(250, 199, 117)
nameLabel.TextSize = 26
nameLabel.Parent = titleContainer
local nameGradient = Instance.new("UIGradient", nameLabel)
nameGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 243, 196)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(250, 199, 117)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(186, 117, 23))
})

local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(1, 0, 0, 20)
subLabel.Position = UDim2.new(0, 0, 0, 37)
subLabel.BackgroundTransparency = 1
subLabel.Font = Enum.Font.GothamMedium
subLabel.Text = "AFK MASTER  |  CUSTOM SMART SELL"
subLabel.TextColor3 = Color3.fromRGB(206, 203, 246)
subLabel.TextSize = 12
subLabel.Parent = titleContainer

local statsContainer = Instance.new("Frame")
statsContainer.Size = UDim2.new(1, -24, 0, 72)
statsContainer.Position = UDim2.new(0, 12, 0, 226)
statsContainer.BackgroundTransparency = 1
statsContainer.Parent = mainPanel

local statsLayout = Instance.new("UIListLayout")
statsLayout.FillDirection = Enum.FillDirection.Horizontal
statsLayout.SortOrder = Enum.SortOrder.LayoutOrder
statsLayout.Padding = UDim.new(0, 6)
statsLayout.Parent = statsContainer

local function createProfileStat(order, title, value)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(1 / 3, -4, 1, 0)
    card.BackgroundColor3 = Color3.fromRGB(28, 24, 48)
    card.BorderSizePixel = 0
    card.LayoutOrder = order
    card.Parent = statsContainer
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)
    Instance.new("UIStroke", card).Color = Color3.fromRGB(60, 52, 137)

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -8, 0, 18)
    titleLabel.Position = UDim2.new(0, 4, 0, 7)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.Gotham
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(175, 169, 236)
    titleLabel.TextSize = 9
    titleLabel.Parent = card

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, -8, 0, 24)
    valueLabel.Position = UDim2.new(0, 4, 0, 31)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Text = value
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    valueLabel.TextSize = 13
    valueLabel.TextTruncate = Enum.TextTruncate.AtEnd
    valueLabel.Parent = card
    return valueLabel
end

local activeStatValue = createProfileStat(1, "ACTIVE", "0/8")
local profileStatValue = createProfileStat(2, "CONFIGS", "0")
local thresholdStatValue = createProfileStat(3, "SELL MIN", "1.5qd")

local automationProgress = Instance.new("Frame")
automationProgress.Size = UDim2.new(1, -24, 0, 42)
automationProgress.Position = UDim2.new(0, 12, 0, 306)
automationProgress.BackgroundTransparency = 1
automationProgress.Parent = mainPanel

local progressTitle = Instance.new("TextLabel")
progressTitle.Size = UDim2.new(0.65, 0, 0, 16)
progressTitle.BackgroundTransparency = 1
progressTitle.Font = Enum.Font.GothamBold
progressTitle.Text = "ACTIVE AUTOMATIONS"
progressTitle.TextColor3 = Color3.fromRGB(175, 169, 236)
progressTitle.TextSize = 10
progressTitle.TextXAlignment = Enum.TextXAlignment.Left
progressTitle.Parent = automationProgress

local progressCount = Instance.new("TextLabel")
progressCount.Size = UDim2.new(0.35, 0, 0, 16)
progressCount.Position = UDim2.new(0.65, 0, 0, 0)
progressCount.BackgroundTransparency = 1
progressCount.Font = Enum.Font.Gotham
progressCount.Text = "0 / 8"
progressCount.TextColor3 = Color3.fromRGB(230, 230, 230)
progressCount.TextSize = 10
progressCount.TextXAlignment = Enum.TextXAlignment.Right
progressCount.Parent = automationProgress

local progressTrack = Instance.new("Frame")
progressTrack.Size = UDim2.new(1, 0, 0, 9)
progressTrack.Position = UDim2.new(0, 0, 0, 22)
progressTrack.BackgroundColor3 = Color3.fromRGB(28, 24, 48)
progressTrack.BorderSizePixel = 0
progressTrack.ClipsDescendants = true
progressTrack.Parent = automationProgress
Instance.new("UICorner", progressTrack).CornerRadius = UDim.new(0, 5)

local progressFill = Instance.new("Frame")
progressFill.Size = UDim2.new(0, 0, 1, 0)
progressFill.BackgroundColor3 = Color3.fromRGB(212, 83, 126)
progressFill.BorderSizePixel = 0
progressFill.Parent = progressTrack
Instance.new("UICorner", progressFill).CornerRadius = UDim.new(0, 5)
local progressGradient = Instance.new("UIGradient", progressFill)
progressGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(212, 83, 126)),
    ColorSequenceKeypoint.new(0.55, Color3.fromRGB(127, 119, 221)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(93, 202, 165))
})

-- ช่องกรอกค่าขีดจำกัดเงินขั้นต่ำสำหรับการขาย (Custom Threshold Input)
local thresholdContainer = Instance.new("Frame")
thresholdContainer.Size = UDim2.new(1, -24, 0, 50)
thresholdContainer.Position = UDim2.new(0, 12, 0, 360)
thresholdContainer.BackgroundColor3 = Color3.fromRGB(28, 24, 48)
thresholdContainer.BorderSizePixel = 0
thresholdContainer.Parent = mainPanel
Instance.new("UICorner", thresholdContainer).CornerRadius = UDim.new(0, 10)

local thresholdLabel = Instance.new("TextLabel")
thresholdLabel.Size = UDim2.new(0.6, 0, 1, 0)
thresholdLabel.Position = UDim2.new(0, 12, 0, 0)
thresholdLabel.BackgroundTransparency = 1
thresholdLabel.Font = Enum.Font.GothamBold
thresholdLabel.Text = "Min Sell Income (เช่น 1.5qd)"
thresholdLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
thresholdLabel.TextSize = 11
thresholdLabel.TextXAlignment = Enum.TextXAlignment.Left
thresholdLabel.Parent = thresholdContainer

local thresholdBox = Instance.new("TextBox")
thresholdBox.Size = UDim2.new(0, 90, 0, 30)
thresholdBox.Position = UDim2.new(1, -102, 0.5, -15)
thresholdBox.BackgroundColor3 = Color3.fromRGB(45, 38, 72)
thresholdBox.TextColor3 = Color3.fromRGB(250, 199, 117)
thresholdBox.Font = Enum.Font.GothamBold
thresholdBox.TextSize = 13
thresholdBox.Text = "1.5qd" -- ค่าเริ่มต้น
thresholdBox.ClearTextOnFocus = false
thresholdBox.Parent = thresholdContainer
Instance.new("UICorner", thresholdBox).CornerRadius = UDim.new(0, 6)

local togglesContainer = Instance.new("Frame")
togglesContainer.Size = UDim2.new(1, -24, 0, 440)
togglesContainer.Position = UDim2.new(0, 12, 0, 424)
togglesContainer.BackgroundTransparency = 1
togglesContainer.Parent = mainPanel

local uiList = Instance.new("UIListLayout")
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 8)
uiList.Parent = togglesContainer

local states = {
    collect = true,
    upgradeTree = true,
    levelUnit = true,
    equipBest = true,
    dice = true,
    autoRebirth = true,
    smartSell = true,
    blockNotif = true
}

local toggleControls = {}
local function refreshToggleVisuals()
    for stateKey, controls in pairs(toggleControls) do
        local isActive = states[stateKey]
        controls.button.BackgroundColor3 = isActive and Color3.fromRGB(127, 119, 221) or Color3.fromRGB(60, 58, 75)
        controls.knob.Position = isActive and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    end
end

local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "EpicAFK_Piriya_config.json"

local function saveSettings()
    if type(writefile) ~= "function" then return end

    local savedStates = {}
    for key, value in pairs(states) do
        savedStates[key] = value
    end

    local ok, encoded = pcall(function()
        return HttpService:JSONEncode({
            states = savedStates,
            threshold = thresholdBox.Text
        })
    end)
    if ok then
        pcall(writefile, CONFIG_FILE, encoded)
    end
end

local function loadSettings()
    if type(isfile) ~= "function" or type(readfile) ~= "function" then return end

    local fileOk, fileExists = pcall(isfile, CONFIG_FILE)
    if not fileOk or not fileExists then return end

    local readOk, contents = pcall(readfile, CONFIG_FILE)
    if not readOk then return end

    local decodeOk, config = pcall(function()
        return HttpService:JSONDecode(contents)
    end)
    if not decodeOk or type(config) ~= "table" then return end

    if type(config.states) == "table" then
        for key in pairs(states) do
            if type(config.states[key]) == "boolean" then
                states[key] = config.states[key]
            end
        end
    end

    if type(config.threshold) == "string" then
        thresholdBox.Text = config.threshold
    end
end

local CONFIG_STORE_FILE = "EpicAFK_Piriya_configs.json"
local function captureSettings()
    local savedStates = {}
    for key, value in pairs(states) do
        savedStates[key] = value
    end
    return { states = savedStates, threshold = thresholdBox.Text }
end

local function applySettings(config)
    if type(config) ~= "table" then return false end
    if type(config.states) == "table" then
        for key in pairs(states) do
            if type(config.states[key]) == "boolean" then
                states[key] = config.states[key]
            end
        end
    end
    if type(config.threshold) == "string" then
        thresholdBox.Text = config.threshold
    end
    refreshToggleVisuals()
    return true
end

local function loadConfigStore()
    local store = { profiles = {}, loadOnStart = nil }
    if type(isfile) ~= "function" or type(readfile) ~= "function" then return store end

    local existsOk, exists = pcall(isfile, CONFIG_STORE_FILE)
    if not existsOk or not exists then return store end
    local readOk, contents = pcall(readfile, CONFIG_STORE_FILE)
    if not readOk then return store end
    local decodeOk, decoded = pcall(function()
        return HttpService:JSONDecode(contents)
    end)
    if not decodeOk or type(decoded) ~= "table" then return store end

    if type(decoded.profiles) == "table" then
        store.profiles = decoded.profiles
    end
    if type(decoded.loadOnStart) == "string" and type(store.profiles[decoded.loadOnStart]) == "table" then
        store.loadOnStart = decoded.loadOnStart
    end
    return store
end

local configStore
local function saveConfigStore()
    if type(writefile) ~= "function" then return false end
    local encodeOk, encoded = pcall(function()
        return HttpService:JSONEncode(configStore)
    end)
    if not encodeOk then return false end
    return pcall(writefile, CONFIG_STORE_FILE, encoded)
end

loadSettings()
configStore = loadConfigStore()
local selectedConfig = configStore.loadOnStart
if selectedConfig then
    applySettings(configStore.profiles[selectedConfig])
end
saveSettings()
thresholdBox.FocusLost:Connect(saveSettings)

local function updateProfileStats()
    local enabledCount = 0
    local totalCount = 0
    local profileCount = 0
    for _, enabled in pairs(states) do
        totalCount = totalCount + 1
        if enabled then
            enabledCount = enabledCount + 1
        end
    end
    for _ in pairs(configStore.profiles) do
        profileCount = profileCount + 1
    end

    activeStatValue.Text = tostring(enabledCount) .. "/" .. tostring(totalCount)
    profileStatValue.Text = tostring(profileCount)
    thresholdStatValue.Text = thresholdBox.Text
    progressCount.Text = tostring(enabledCount) .. " / " .. tostring(totalCount)
    progressFill.Size = UDim2.new(totalCount > 0 and enabledCount / totalCount or 0, 0, 1, 0)
end

updateProfileStats()
thresholdBox.FocusLost:Connect(updateProfileStats)

local featureIcons = {
    collect = "¢",
    upgradeTree = "↗",
    levelUnit = "↑",
    equipBest = "★",
    dice = "◇",
    autoRebirth = "↻",
    smartSell = "⇄",
    blockNotif = "◉"
}

local function createFeatureToggle(order, title, desc, stateKey)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 48)
    row.BackgroundColor3 = Color3.fromRGB(28, 24, 48)
    row.BorderSizePixel = 0
    row.LayoutOrder = order
    row.Parent = togglesContainer

    Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)
    local rowStroke = Instance.new("UIStroke", row)
    rowStroke.Color = Color3.fromRGB(60, 52, 137)
    rowStroke.Thickness = 0.5
    rowStroke.Transparency = 0.3

    local iconFrame = Instance.new("Frame")
    iconFrame.Size = UDim2.new(0, 30, 0, 30)
    iconFrame.Position = UDim2.new(0, 8, 0.5, -15)
    iconFrame.BackgroundColor3 = Color3.fromRGB(38, 33, 92)
    iconFrame.BorderSizePixel = 0
    iconFrame.Parent = row
    Instance.new("UICorner", iconFrame).CornerRadius = UDim.new(0, 8)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.Text = featureIcons[stateKey] or "*"
    iconLabel.TextColor3 = Color3.fromRGB(175, 169, 236)
    iconLabel.TextSize = 16
    iconLabel.Parent = iconFrame

    local textHolder = Instance.new("Frame")
    textHolder.Size = UDim2.new(1, -112, 1, 0)
    textHolder.Position = UDim2.new(0, 48, 0, 0)
    textHolder.BackgroundTransparency = 1
    textHolder.Parent = row

    local tLabel = Instance.new("TextLabel")
    tLabel.Size = UDim2.new(1, 0, 0, 20)
    tLabel.Position = UDim2.new(0, 0, 0, 4)
    tLabel.BackgroundTransparency = 1
    tLabel.Font = Enum.Font.GothamBold
    tLabel.Text = title
    tLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    tLabel.TextSize = 13
    tLabel.TextTruncate = Enum.TextTruncate.AtEnd
    tLabel.TextXAlignment = Enum.TextXAlignment.Left
    tLabel.Parent = textHolder

    local dLabel = Instance.new("TextLabel")
    dLabel.Size = UDim2.new(1, 0, 0, 16)
    dLabel.Position = UDim2.new(0, 0, 0, 25)
    dLabel.BackgroundTransparency = 1
    dLabel.Font = Enum.Font.Gotham
    dLabel.Text = desc
    dLabel.TextColor3 = Color3.fromRGB(136, 135, 128)
    dLabel.TextSize = 10
    dLabel.TextTruncate = Enum.TextTruncate.AtEnd
    dLabel.TextXAlignment = Enum.TextXAlignment.Left
    dLabel.Parent = textHolder

    local swBtn = Instance.new("TextButton")
    swBtn.Size = UDim2.new(0, 44, 0, 24)
    swBtn.Position = UDim2.new(1, -54, 0.5, -12)
    swBtn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(127, 119, 221) or Color3.fromRGB(60, 58, 75)
    swBtn.Text = ""
    swBtn.AutoButtonColor = false
    swBtn.Parent = row

    Instance.new("UICorner", swBtn).CornerRadius = UDim.new(1, 0)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = states[stateKey] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.Parent = swBtn

    Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)
    toggleControls[stateKey] = { button = swBtn, knob = knob }

    swBtn.MouseButton1Click:Connect(function()
        states[stateKey] = not states[stateKey]
        saveSettings()
        updateProfileStats()
        local isActive = states[stateKey]

        swBtn.BackgroundColor3 = isActive and Color3.fromRGB(127, 119, 221) or Color3.fromRGB(60, 58, 75)
        knob:TweenPosition(
            isActive and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9),
            Enum.EasingDirection.Out,
            Enum.EasingStyle.Quad,
            0.15,
            true
        )

        if stateKey == "blockNotif" and textNotificationRE then
            pcall(function()
                for _, conn in ipairs(getconnections(textNotificationRE.OnClientEvent)) do
                    if isActive then conn:Disable() else conn:Enable() end
                end
            end)
        end
    end)
end

createFeatureToggle(1, "Auto-Collect Money", "กวาดเก็บเงินจากสล็อตออโต้", "collect")
createFeatureToggle(2, "Auto-Upgrade Tree", "ซื้ออัพเกรดผังความสามารถอัตโนมัติ", "upgradeTree")
createFeatureToggle(3, "Auto-Level Units", "อัพเลเวลยูนิตในฐานตามเงินที่มี", "levelUnit")
createFeatureToggle(4, "Auto-Equip Best Units", "สวมใส่ยูนิตที่ดีที่สุดลงสล็อต", "equipBest")
createFeatureToggle(5, "Auto-BuyEquip Dice", "ซื้อและสวมใส่ลูกเต๋าที่ดีที่สุด", "dice")
createFeatureToggle(6, "Auto-Rebirth", "ทำการจุติ (Rebirth) อัตโนมัติเมื่อเงินถึง", "autoRebirth")
createFeatureToggle(7, "Smart Auto-Sell", "ขายยูนิตที่รายได้ต่ำกว่าค่าที่พิมพ์ออโต้", "smartSell")
createFeatureToggle(8, "Block Notifications", "ซ่อนหน้าต่างแจ้งเตือนกวนใจ", "blockNotif")

local configsPanel = Instance.new("Frame")
configsPanel.Name = "ConfigsPanel"
configsPanel.Size = UDim2.new(1, -24, 0, 330)
configsPanel.Position = UDim2.new(0, 12, 0, 880)
configsPanel.BackgroundTransparency = 1
configsPanel.Parent = mainPanel

local configHeader = Instance.new("TextButton")
configHeader.Size = UDim2.new(1, 0, 0, 30)
configHeader.BackgroundColor3 = Color3.fromRGB(60, 52, 137)
configHeader.BorderSizePixel = 0
configHeader.Font = Enum.Font.GothamBold
configHeader.Text = "Configs  v"
configHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
configHeader.TextSize = 13
configHeader.TextXAlignment = Enum.TextXAlignment.Left
configHeader.AutoButtonColor = false
configHeader.Parent = configsPanel
Instance.new("UICorner", configHeader).CornerRadius = UDim.new(0, 6)

local configBody = Instance.new("Frame")
configBody.Size = UDim2.new(1, 0, 0, 292)
configBody.Position = UDim2.new(0, 0, 0, 36)
configBody.BackgroundColor3 = Color3.fromRGB(28, 24, 48)
configBody.BorderSizePixel = 0
configBody.Parent = configsPanel
Instance.new("UICorner", configBody).CornerRadius = UDim.new(0, 6)

local configNameLabel = Instance.new("TextLabel")
configNameLabel.Size = UDim2.new(1, -12, 0, 18)
configNameLabel.Position = UDim2.new(0, 6, 0, 4)
configNameLabel.BackgroundTransparency = 1
configNameLabel.Font = Enum.Font.Gotham
configNameLabel.Text = "Config name"
configNameLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
configNameLabel.TextSize = 11
configNameLabel.TextXAlignment = Enum.TextXAlignment.Left
configNameLabel.Parent = configBody

local configNameBox = Instance.new("TextBox")
configNameBox.Size = UDim2.new(1, -12, 0, 25)
configNameBox.Position = UDim2.new(0, 6, 0, 23)
configNameBox.BackgroundColor3 = Color3.fromRGB(45, 38, 72)
configNameBox.BorderSizePixel = 0
configNameBox.Font = Enum.Font.Gotham
configNameBox.PlaceholderText = "name..."
configNameBox.Text = ""
configNameBox.TextColor3 = Color3.fromRGB(255, 255, 255)
configNameBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
configNameBox.TextSize = 12
configNameBox.ClearTextOnFocus = false
configNameBox.Parent = configBody
Instance.new("UICorner", configNameBox).CornerRadius = UDim.new(0, 4)

local function makeConfigButton(text, position, size, color)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = color or Color3.fromRGB(45, 38, 72)
    button.BorderSizePixel = 0
    button.Font = Enum.Font.Gotham
    button.Text = text
    button.TextColor3 = Color3.fromRGB(235, 235, 235)
    button.TextSize = 11
    button.AutoButtonColor = true
    button.Parent = configBody
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    return button
end

local saveNewConfigButton = makeConfigButton(
    "Save as new config",
    UDim2.new(0, 6, 0, 53),
    UDim2.new(1, -12, 0, 26),
    Color3.fromRGB(60, 52, 137)
)

local savedConfigsLabel = Instance.new("TextLabel")
savedConfigsLabel.Size = UDim2.new(1, -12, 0, 18)
savedConfigsLabel.Position = UDim2.new(0, 6, 0, 82)
savedConfigsLabel.BackgroundTransparency = 1
savedConfigsLabel.Font = Enum.Font.GothamBold
savedConfigsLabel.Text = "Saved configs"
savedConfigsLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
savedConfigsLabel.TextSize = 11
savedConfigsLabel.TextXAlignment = Enum.TextXAlignment.Left
savedConfigsLabel.Parent = configBody

local configList = Instance.new("ScrollingFrame")
configList.Size = UDim2.new(1, -12, 0, 48)
configList.Position = UDim2.new(0, 6, 0, 102)
configList.BackgroundColor3 = Color3.fromRGB(20, 18, 32)
configList.BorderSizePixel = 0
configList.ScrollBarThickness = 3
configList.CanvasSize = UDim2.new(0, 0, 0, 0)
configList.Parent = configBody

local configListLayout = Instance.new("UIListLayout")
configListLayout.SortOrder = Enum.SortOrder.LayoutOrder
configListLayout.Padding = UDim.new(0, 2)
configListLayout.Parent = configList

local loadConfigButton = makeConfigButton("Load", UDim2.new(0, 6, 0, 156), UDim2.new(0.5, -9, 0, 26))
local updateConfigButton = makeConfigButton("Update", UDim2.new(0.5, 3, 0, 156), UDim2.new(0.5, -9, 0, 26))
local loadOnStartButton = makeConfigButton("Load on start", UDim2.new(0, 6, 0, 186), UDim2.new(0.5, -9, 0, 26))
local deleteConfigButton = makeConfigButton("Delete", UDim2.new(0.5, 3, 0, 186), UDim2.new(0.5, -9, 0, 26), Color3.fromRGB(150, 55, 75))

local loadStatusLabel = Instance.new("TextLabel")
loadStatusLabel.Size = UDim2.new(1, -12, 0, 18)
loadStatusLabel.Position = UDim2.new(0, 6, 0, 216)
loadStatusLabel.BackgroundTransparency = 1
loadStatusLabel.Font = Enum.Font.Gotham
loadStatusLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
loadStatusLabel.TextSize = 10
loadStatusLabel.TextXAlignment = Enum.TextXAlignment.Left
loadStatusLabel.Parent = configBody

local disableLoadButton = makeConfigButton("Don't load on start", UDim2.new(0, 6, 0, 238), UDim2.new(0.5, -9, 0, 26))
local refreshConfigsButton = makeConfigButton("Refresh", UDim2.new(0.5, 3, 0, 238), UDim2.new(0.5, -9, 0, 26))

local configMessageLabel = Instance.new("TextLabel")
configMessageLabel.Size = UDim2.new(1, -12, 0, 18)
configMessageLabel.Position = UDim2.new(0, 6, 0, 268)
configMessageLabel.BackgroundTransparency = 1
configMessageLabel.Font = Enum.Font.Gotham
configMessageLabel.TextColor3 = Color3.fromRGB(250, 199, 117)
configMessageLabel.TextSize = 10
configMessageLabel.TextXAlignment = Enum.TextXAlignment.Left
configMessageLabel.TextTruncate = Enum.TextTruncate.AtEnd
configMessageLabel.Parent = configBody

local function refreshLoadStatus()
    loadStatusLabel.Text = "Loads on start: " .. (configStore.loadOnStart or "---")
end

local function refreshConfigList()
    for _, child in ipairs(configList:GetChildren()) do
        if child ~= configListLayout then
            child:Destroy()
        end
    end

    local names = {}
    for name in pairs(configStore.profiles) do
        table.insert(names, name)
    end
    table.sort(names)
    updateProfileStats()
    configList.CanvasSize = UDim2.new(0, 0, 0, math.max(#names, 1) * 24)

    if #names == 0 then
        local emptyLabel = Instance.new("TextLabel")
        emptyLabel.Size = UDim2.new(1, -4, 0, 22)
        emptyLabel.BackgroundTransparency = 1
        emptyLabel.Font = Enum.Font.Gotham
        emptyLabel.Text = "---"
        emptyLabel.TextColor3 = Color3.fromRGB(160, 160, 160)
        emptyLabel.TextSize = 11
        emptyLabel.TextXAlignment = Enum.TextXAlignment.Left
        emptyLabel.Parent = configList
        return
    end

    for index, name in ipairs(names) do
        local profileName = name
        local itemButton = Instance.new("TextButton")
        itemButton.Size = UDim2.new(1, -4, 0, 22)
        itemButton.LayoutOrder = index
        itemButton.BackgroundColor3 = profileName == selectedConfig and Color3.fromRGB(60, 52, 137) or Color3.fromRGB(35, 31, 52)
        itemButton.BorderSizePixel = 0
        itemButton.Font = Enum.Font.Gotham
        itemButton.Text = "  " .. profileName
        itemButton.TextColor3 = Color3.fromRGB(240, 240, 240)
        itemButton.TextSize = 11
        itemButton.TextXAlignment = Enum.TextXAlignment.Left
        itemButton.Parent = configList
        itemButton.MouseButton1Click:Connect(function()
            selectedConfig = profileName
            configNameBox.Text = profileName
            configMessageLabel.Text = "Selected: " .. profileName
            refreshConfigList()
        end)
    end
end

configHeader.MouseButton1Click:Connect(function()
    configBody.Visible = not configBody.Visible
    configHeader.Text = configBody.Visible and "Configs  v" or "Configs  >"
end)

saveNewConfigButton.MouseButton1Click:Connect(function()
    local name = string.gsub(configNameBox.Text, "^%s*(.-)%s*$", "%1")
    if name == "" then
        configMessageLabel.Text = "Enter a config name"
        return
    end
    if configStore.profiles[name] then
        configMessageLabel.Text = "Config already exists; use Update"
        return
    end
    configStore.profiles[name] = captureSettings()
    selectedConfig = name
    if saveConfigStore() then
        configMessageLabel.Text = "Saved: " .. name
    else
        configMessageLabel.Text = "Save failed: executor file APIs unavailable"
    end
    refreshConfigList()
    refreshLoadStatus()
end)

loadConfigButton.MouseButton1Click:Connect(function()
    local profile = selectedConfig and configStore.profiles[selectedConfig]
    if not profile then
        configMessageLabel.Text = "Select a saved config"
        return
    end
    applySettings(profile)
    saveSettings()
    updateProfileStats()
    configMessageLabel.Text = "Loaded: " .. selectedConfig
end)

updateConfigButton.MouseButton1Click:Connect(function()
    if not selectedConfig or not configStore.profiles[selectedConfig] then
        configMessageLabel.Text = "Select a saved config"
        return
    end
    configStore.profiles[selectedConfig] = captureSettings()
    if saveConfigStore() then
        configMessageLabel.Text = "Updated: " .. selectedConfig
    else
        configMessageLabel.Text = "Update failed: executor file APIs unavailable"
    end
    refreshConfigList()
end)

loadOnStartButton.MouseButton1Click:Connect(function()
    if not selectedConfig or not configStore.profiles[selectedConfig] then
        configMessageLabel.Text = "Select a saved config"
        return
    end
    configStore.loadOnStart = selectedConfig
    if saveConfigStore() then
        configMessageLabel.Text = "Will load: " .. selectedConfig
    else
        configMessageLabel.Text = "Save failed: executor file APIs unavailable"
    end
    refreshLoadStatus()
end)

disableLoadButton.MouseButton1Click:Connect(function()
    configStore.loadOnStart = nil
    if saveConfigStore() then
        configMessageLabel.Text = "Startup profile disabled; latest settings still restore"
    else
        configMessageLabel.Text = "Save failed: executor file APIs unavailable"
    end
    refreshLoadStatus()
end)

deleteConfigButton.MouseButton1Click:Connect(function()
    if not selectedConfig or not configStore.profiles[selectedConfig] then
        configMessageLabel.Text = "Select a saved config"
        return
    end
    local deletedName = selectedConfig
    configStore.profiles[deletedName] = nil
    if configStore.loadOnStart == deletedName then
        configStore.loadOnStart = nil
    end
    selectedConfig = nil
    configNameBox.Text = ""
    if saveConfigStore() then
        configMessageLabel.Text = "Deleted: " .. deletedName
    else
        configMessageLabel.Text = "Delete failed: executor file APIs unavailable"
    end
    refreshConfigList()
    refreshLoadStatus()
end)

refreshConfigsButton.MouseButton1Click:Connect(function()
    configStore = loadConfigStore()
    if selectedConfig and not configStore.profiles[selectedConfig] then
        selectedConfig = nil
        configNameBox.Text = ""
    end
    refreshConfigList()
    refreshLoadStatus()
    configMessageLabel.Text = "Configs refreshed"
end)

refreshConfigList()
refreshLoadStatus()

-- ฟังก์ชันแปลงข้อความตัวย่อ (เช่น 1.5qd, 500m) ให้เป็นตัวเลขเต็มสำหรับคำนวณ
local function parseIncomeThreshold(inputStr)
    if type(inputStr) == "number" then return inputStr end
    if type(inputStr) ~= "string" then return 0 end
    
    inputStr = string.lower(string.gsub(inputStr, "%s+", ""))
    local numberPart = tonumber(string.match(inputStr, "[%d%.]+")) or 0
    local unit = string.match(inputStr, "[a-z]+")
    
    local multipliers = {
        k = 1e3,
        m = 1e6,
        b = 1e9,
        t = 1e12,
        qd = 1e15,
        qi = 1e18
    }
    
    if unit and multipliers[unit] then
        numberPart = numberPart * multipliers[unit]
    end
    
    return numberPart
end

pcall(function()
    if textNotificationRE then
        for _, conn in ipairs(getconnections(textNotificationRE.OnClientEvent)) do
            conn:Disable()
        end
    end
end)

-- Anti-AFK Worker
task.spawn(function()
    local connection
    connection = localPlayer.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end)

-- Master Loop
task.spawn(function()
    while true do
        task.wait(1.5)
        
        if states.collect and collectBalanceEvent then
            pcall(function()
                for i = 1, 50 do
                    collectBalanceEvent:FireServer(i)
                end
            end)
        end
        
        if states.upgradeTree and buyUpgradeEvent and DataController then
            pcall(function()
                local currentMoney = DataController.Money() or 0
                local function checkAndBuy(nodeName)
                    for _, childName in ipairs(TreeStructure.GetChildren(nodeName) or {}) do
                        local isOwned = DataController.Upgrades[childName] and DataController.Upgrades[childName]()
                        if not isOwned then
                            local upgradeData = UpgradesConfig[childName]
                            if upgradeData and currentMoney >= upgradeData.price then
                                buyUpgradeEvent:FireServer(childName)
                                task.wait(0.2)
                            end
                            checkAndBuy(childName)
                        else
                            checkAndBuy(childName)
                        end
                    end
                end
                checkAndBuy("Start")
            end)
        end
        
        if states.levelUnit and levelUpSlotEvent and DataController then
            pcall(function()
                for slotIdx = 1, 50 do
                    if not states.levelUnit then break end
                    local slotData = DataController.Slots and DataController.Slots[tostring(slotIdx)] and DataController.Slots[tostring(slotIdx)]()
                    if slotData and slotData.unitId then
                        levelUpSlotEvent:FireServer(slotIdx)
                        task.wait(0.1)
                    end
                end
            end)
        end
        
        if states.equipBest and equipBestEvent then
            pcall(function()
                equipBestEvent:FireServer()
            end)
        end
        
        if states.dice and DataController and buyDiceEvent and equipDiceEvent then
            pcall(function()
                local currentMoney = DataController.Money() or 0
                local allDice = DiceConfig.GetAll()
                local sortedDice = {}
                for diceName, diceData in pairs(allDice) do
                    if diceData.price then
                        table.insert(sortedDice, {name = diceName, data = diceData})
                    end
                end
                table.sort(sortedDice, function(a, b)
                    return a.data.luck > b.data.luck
                end)
                
                local targetToBuy = nil
                local bestOwnedDice = nil
                
                for _, entry in ipairs(sortedDice) do
                    local diceName = entry.name
                    local diceData = entry.data
                    local isOwned = DataController.OwnedDice[diceName] and DataController.OwnedDice[diceName]()
                    
                    if isOwned then
                        if not bestOwnedDice then
                            bestOwnedDice = diceName
                        end
                    else
                        if currentMoney >= diceData.price and not targetToBuy then
                            targetToBuy = diceName
                        end
                    end
                end
                
                if targetToBuy then
                    buyDiceEvent:FireServer(targetToBuy)
                    task.wait(0.3)
                end
                
                if bestOwnedDice and DataController.Dice() ~= bestOwnedDice then
                    equipDiceEvent:FireServer(bestOwnedDice)
                end
            end)
        end

        if states.autoRebirth and rebirthEvent and DataController then
            pcall(function()
                local currentRebirth = DataController.Rebirth() or 0
                local nextRebirthData = RebirthsConfig.GetNext(currentRebirth)
                if nextRebirthData then
                    local currentMoney = DataController.Money() or 0
                    if currentMoney >= nextRebirthData.cost then
                        rebirthEvent:FireServer()
                    end
                end
            end)
        end

        -- ระบบขายยูนิตอัตโนมัติอัจฉริยะตามค่าที่ผู้เล่นพิมพ์กำหนด (Custom Smart Auto-Sell)
        if states.smartSell and DataController and SellUtil and EntryRegistry and sellInventoryEvent then
            pcall(function()
                local inventory = DataController.Inventory()
                local slots = DataController.Slots()
                local plottedUnits = SellUtil.GetPlottedUnits(slots)
                local itemsToSellKeys = {}
                
                -- แปลงค่าที่พิมพ์ในช่อง (เช่น 1.5qd) เป็นตัวเลขเปรียบเทียบ
                local thresholdLimit = parseIncomeThreshold(thresholdBox.Text)

                for key, item in pairs(inventory) do
                    if item and item.amount and item.amount > 0 then
                        -- ห้ามขายตัวที่ล็อกไว้ หรือ ตัวที่ติดตั้งอยู่บนบอร์ดสล็อต
                        if not item.attributes.locked and not plottedUnits[key] then
                            local entryConfig = EntryRegistry.getEntryConfig(item.name)
                            if entryConfig and entryConfig.kind == "Unit" then
                                local income = entryConfig.income(item.attributes)
                                
                                -- ถ้ารายได้ต่ำกว่าค่าที่ผู้เล่นกำหนดในช่อง จะถูกจัดเข้าคิวขายทันที
                                if thresholdLimit > 0 and income < thresholdLimit then
                                    table.insert(itemsToSellKeys, key)
                                end
                            end
                        end
                    end
                end

                if #itemsToSellKeys > 0 then
                    sellInventoryEvent:InvokeServer(itemsToSellKeys)
                end
            end)
        end
    end
end)

print("Epic AFK Master UI with Custom Smart Auto-Sell Loaded Smoothly.")