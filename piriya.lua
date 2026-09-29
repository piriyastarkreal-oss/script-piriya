-- ==========================================================
-- SCRIPT: ULTIMATE AFK MASTER UI (WITH AUTO-REBIRTH)
-- RUN IN: Volt Executor (Client-side)
-- ==========================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

local localPlayer = Players.LocalPlayer
local playerName = "PIRIYA"

-- ดึงรูปอวาตาร์ของผู้เล่น
local playerThumbnail = ""
local okThumb, thumbImg = pcall(Players.GetUserThumbnailAsync, Players, localPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
if okThumb then playerThumbnail = thumbImg end

-- โหลดโมดูลข้อมูลที่จำเป็นจากเกม
local UpgradesConfig = require(ReplicatedStorage.Framework.Features.Upgrades.Upgrades)
local TreeStructure = require(ReplicatedStorage.Framework.Features.Upgrades.TreeStructure)
local DiceConfig = require(ReplicatedStorage.Framework.Features.Rolling.Dice)
local RebirthsConfig = require(ReplicatedStorage.Framework.Features.Rebirth.Rebirths)
local DataController = ReplicatedStorage:FindFirstChild("Framework") and require(ReplicatedStorage.Framework.Features.Data.DataController) or nil

-- ค้นหา RemoteEvents ของเกม
local network = ReplicatedStorage:WaitForChild("Network", 5)
local plotService = network and network:WaitForChild("PlotService", 5)
local collectBalanceEvent = plotService and (plotService:WaitForChild("RE", 5) and plotService.RE:WaitForChild("CollectBalance", 5) or plotService:FindFirstChild("CollectBalance", true))
local levelUpSlotEvent = plotService and (plotService:WaitForChild("RE", 5) and plotService.RE:WaitForChild("LevelUpSlot", 5) or plotService:FindFirstChild("LevelUpSlot", true))
local equipBestEvent = plotService and (plotService:WaitForChild("RE", 5) and plotService.RE:WaitForChild("EquipBest", 5) or plotService:FindFirstChild("EquipBest", true))
local buyUpgradeEvent = network:WaitForChild("RE", 5) and network.RE:WaitForChild("BuyUpgrade", 5) or network:FindFirstChild("BuyUpgrade", true)

-- ค้นหา RemoteEvents ของระบบลูกเต๋า
local diceShopService = network:WaitForChild("DiceShopService", 5)
local buyDiceEvent = diceShopService and (diceShopService:WaitForChild("RE", 5) and diceShopService.RE:WaitForChild("BuyDice", 5) or diceShopService:FindFirstChild("BuyDice", true))
local equipDiceEvent = diceShopService and (diceShopService:WaitForChild("RE", 5) and diceShopService.RE:WaitForChild("EquipDice", 5) or diceShopService:FindFirstChild("EquipDice", true))

-- ค้นหา RemoteEvent ของระบบ Rebirth
local rebirthServiceComm = network:WaitForChild("RebirthService", 5)
local rebirthEvent = rebirthServiceComm and rebirthServiceComm:WaitForChild("RE", 5) and rebirthServiceComm.RE:WaitForChild("Rebirth", 5) or network:FindFirstChild("Rebirth", true)

-- ค้นหา Event แจ้งเตือนสำหรับระบบ Block Notifications
local notificationService = network:WaitForChild("NotificationService", 5)
local textNotificationRE = notificationService and (notificationService:WaitForChild("RE", 5) and notificationService.RE:WaitForChild("TextNotification", 5) or notificationService:FindFirstChild("TextNotification", true))

-- ลบ UI เก่าทิ้งก่อน (ถ้ามี)
if CoreGui:FindFirstChild("EpicAFK_Piriya") then
	CoreGui["EpicAFK_Piriya"]:Destroy()
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
openButton.Draggable = true
openButton.Parent = screenGui

Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 10)
local openStroke = Instance.new("UIStroke", openButton)
openStroke.Color = Color3.fromRGB(250, 199, 117)
openStroke.Thickness = 2

-- กรอบไล่สีหมุนรอบนอก (Frame ภายนอก) - เพิ่มความสูงเป็น 530 เพื่อรองรับปุ่มใหม่
local outerFrame = Instance.new("Frame")
outerFrame.Size = UDim2.new(0, 330, 0, 530)
outerFrame.Position = UDim2.new(0.5, -165, 0.1, 0)
outerFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
outerFrame.BorderSizePixel = 0
outerFrame.Active = true
outerFrame.Draggable = true
outerFrame.Parent = screenGui

local outerCorner = Instance.new("UICorner")
outerCorner.CornerRadius = UDim.new(0, 20)
outerCorner.Parent = outerFrame

-- เอฟเฟกต์ไล่สีหมุนรอบกรอบ
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
mainPanel.CanvasSize = UDim2.new(0, 0, 0, 620)
mainPanel.ScrollBarThickness = 4
mainPanel.Parent = outerFrame

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 17)
panelCorner.Parent = mainPanel

-- ส่วนหัว (Header)
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 140)
header.BackgroundColor3 = Color3.fromRGB(60, 52, 137)
header.BorderSizePixel = 0
header.Parent = mainPanel

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
avatar.Size = UDim2.new(0, 84, 0, 84)
avatar.Position = UDim2.new(0.5, -42, 0, 20)
avatar.BackgroundTransparency = 1
avatar.Image = playerThumbnail
avatar.Parent = header
Instance.new("UICorner", avatar).CornerRadius = UDim.new(1, 0)

-- ขอบไล่สีหมุนรอบรูปอวาตาร์
local ring = Instance.new("UIStroke", avatar)
ring.Thickness = 3
ring.Color = Color3.new(1, 1, 1)
local ringGrad = Instance.new("UIGradient", ring)
ringGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 220, 120)),
	ColorSequenceKeypoint.new(0.5, Color3.fromRGB(210, 80, 130)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 220, 120)),
})

-- หมุนขอบอวาตาร์และกรอบนอกตลอดเวลา
RunService.RenderStepped:Connect(function(dt)
	ringGrad.Rotation = (ringGrad.Rotation + 120 * dt) % 360
	outerGradient.Rotation = (outerGradient.Rotation + 60 * dt) % 360
end)

-- ชื่อและยศด้านล่างหัว
local titleContainer = Instance.new("Frame")
titleContainer.Size = UDim2.new(1, 0, 0, 70)
titleContainer.Position = UDim2.new(0, 0, 0, 145)
titleContainer.BackgroundTransparency = 1
titleContainer.Parent = mainPanel

local nameLabel = Instance.new("TextLabel")
nameLabel.Size = UDim2.new(1, 0, 0, 35)
nameLabel.BackgroundTransparency = 1
nameLabel.Font = Enum.Font.GothamBold
nameLabel.Text = playerName
nameLabel.TextColor3 = Color3.fromRGB(250, 199, 117)
nameLabel.TextSize = 22
nameLabel.Parent = titleContainer

local subLabel = Instance.new("TextLabel")
subLabel.Size = UDim2.new(1, 0, 0, 20)
subLabel.Position = UDim2.new(0, 0, 0, 35)
subLabel.BackgroundTransparency = 1
subLabel.Font = Enum.Font.GothamMedium
subLabel.Text = "👑 AFK Master & Developer Mode"
subLabel.TextColor3 = Color3.fromRGB(206, 203, 246)
subLabel.TextSize = 12
subLabel.Parent = titleContainer

-- พื้นที่ใส่สวิตช์ฟังก์ชันต่างๆ (ขยายความสูงให้รองรับ 7 รายการ)
local togglesContainer = Instance.new("Frame")
togglesContainer.Size = UDim2.new(1, -24, 0, 340)
togglesContainer.Position = UDim2.new(0, 12, 0, 225)
togglesContainer.BackgroundTransparency = 1
togglesContainer.Parent = mainPanel

local uiList = Instance.new("UIListLayout")
uiList.SortOrder = Enum.SortOrder.LayoutOrder
uiList.Padding = UDim.new(0, 8)
uiList.Parent = togglesContainer

-- สถานะการทำงานของฟีเจอร์ต่างๆ (เพิ่ม autoRebirth เป็น true เริ่มต้น)
local states = {
	collect = true,
	upgradeTree = true,
	levelUnit = true,
	equipBest = true,
	dice = true,
	autoRebirth = true,
	blockNotif = true
}

-- ฟังก์ชันสร้างแถวสวิตช์ (Toggle Row) สไตล์พรีเมียม
local function createFeatureToggle(order, title, desc, stateKey)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1, 0, 0, 42)
	row.BackgroundColor3 = Color3.fromRGB(28, 24, 48)
	row.BorderSizePixel = 0
	row.LayoutOrder = order
	row.Parent = togglesContainer

	Instance.new("UICorner", row).CornerRadius = UDim.new(0, 10)

	local textHolder = Instance.new("Frame")
	textHolder.Size = UDim2.new(1, -60, 1, 0)
	textHolder.Position = UDim2.new(0, 12, 0, 0)
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
	tLabel.TextXAlignment = Enum.TextXAlignment.Left
	tLabel.Parent = textHolder

	local dLabel = Instance.new("TextLabel")
	dLabel.Size = UDim2.new(1, 0, 0, 16)
	dLabel.Position = UDim2.new(0, 0, 0, 22)
	dLabel.BackgroundTransparency = 1
	dLabel.Font = Enum.Font.Gotham
	dLabel.Text = desc
	dLabel.TextColor3 = Color3.fromRGB(136, 135, 128)
	dLabel.TextSize = 10
	dLabel.TextXAlignment = Enum.TextXAlignment.Left
	dLabel.Parent = textHolder

	-- ปุ่ม Switch เปิด/ปิด
	local swBtn = Instance.new("TextButton")
	swBtn.Size = UDim2.new(0, 42, 0, 22)
	swBtn.Position = UDim2.new(1, -50, 0.5, -11)
	swBtn.BackgroundColor3 = states[stateKey] and Color3.fromRGB(127, 119, 221) or Color3.fromRGB(60, 58, 75)
	swBtn.Text = ""
	swBtn.AutoButtonColor = false
	swBtn.Parent = row

	Instance.new("UICorner", swBtn).CornerRadius = UDim.new(1, 0)

	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0, 16, 0, 16)
	knob.Position = states[stateKey] and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.Parent = swBtn

	Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

	-- กดสลับสถานะ
	swBtn.MouseButton1Click:Connect(function()
		states[stateKey] = not states[stateKey]
		local isActive = states[stateKey]

		swBtn.BackgroundColor3 = isActive and Color3.fromRGB(127, 119, 221) or Color3.fromRGB(60, 58, 75)
		knob:TweenPosition(
			isActive and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
			Enum.EasingDirection.Out,
			Enum.EasingStyle.Quad,
			0.15,
			true
		)

		-- พิเศษสำหรับระบบบล็อกแจ้งเตือน
		if stateKey == "blockNotif" and textNotificationRE then
			pcall(function()
				for _, conn in ipairs(getconnections(textNotificationRE.OnClientEvent)) do
					if isActive then conn:Disable() else conn:Enable() end
				end
			end)
		end
	end)
end

-- สร้างปุ่มสวิตช์ทั้งหมด รวมถึง Auto-Rebirth
createFeatureToggle(1, "Auto-Collect Money", "กวาดเก็บเงินจากสล็อตออโต้", "collect")
createFeatureToggle(2, "Auto-Upgrade Tree", "ซื้ออัพเกรดผังความสามารถอัตโนมัติ", "upgradeTree")
createFeatureToggle(3, "Auto-Level Units", "อัพเลเวลยูนิตในฐานตามเงินที่มี", "levelUnit")
createFeatureToggle(4, "Auto-Equip Best Units", "สวมใส่ยูนิตที่ดีที่สุดลงสล็อต", "equipBest")
createFeatureToggle(5, "Auto-Buy/Equip Dice", "ซื้อและสวมใส่ลูกเต๋าที่ดีที่สุด", "dice")
createFeatureToggle(6, "Auto-Rebirth", "ทำการจุติ (Rebirth) อัตโนมัติเมื่อเงินถึง", "autoRebirth")
createFeatureToggle(7, "Block Notifications", "ซ่อนหน้าต่างแจ้งเตือนกวนใจ", "blockNotif")

-- เริ่มต้นปิดการแจ้งเตือนตามค่าเริ่มต้น
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

-- Master Loop (ระบบ AFK ทำงานเบื้องหลังข้ามคืน)
task.spawn(function()
	while true do
		task.wait(1.5)
		
		-- 1. เก็บเงินออโต้
		if states.collect and collectBalanceEvent then
			pcall(function()
				for i = 1, 50 do
					collectBalanceEvent:FireServer(i)
				end
			end)
		end
		
		-- 2. ออโต้ซื้ออัพเกรดผัง
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
		
		-- 3. ออโต้อัพเกรดเลเวลยูนิต (วนทีละช่อง)
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
		
		-- 4. ออโต้สวมใส่ยูนิตที่ดีที่สุด
		if states.equipBest and equipBestEvent then
			pcall(function()
				equipBestEvent:FireServer()
			end)
		end
		
		-- 5. ออโต้ซื้อและสวมใส่ลูกเต๋าที่ดีที่สุด
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

		-- 6. ออโต้ Rebirth (เช็คเงินเทียบกับค่าใช้จ่าย Rebirth ถัดไปจาก Config)[cite: 9, 10]
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
	end
end)

print("Epic AFK Master UI with Auto-Rebirth Loaded Successfully for " .. playerName)