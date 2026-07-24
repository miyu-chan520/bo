-- ==========================================
-- BO HUB - PROFESSIONAL EDITION (NO ASSETS)
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if CoreGui:FindFirstChild("BOHUB") then CoreGui.BOHUB:Destroy() end

local isMobile = UserInputService.TouchEnabled

-- ==========================================
-- 1. CONFIGURATION
-- ==========================================
local Config = {
    Aim = { 
        Enabled = false, 
        VisibleCheck = true, 
        FOV = 100, 
        Mode = 2, -- 1: Body, 2: Head, 3: Random, 4: Pro (Pre-Aim)
    }, 
    Magnet = { Enabled = false, Limit = 5 },
    ESP = { 
        Box = false, 
        Tracer = false, 
        Name = false, 
        Distance = false, 
        HealthBar = false,
        ShowFOV = true,
        Color = Color3.fromRGB(255, 255, 255)
    },
    Hitbox = { Enabled = false, Size = 15, Mode = 1 }
}

local ESPData = {}
local AllEntities = {} 
local LockedTarget, LockedAimPart, ProAimStartTime, ProAimDuration = nil, nil, nil, nil

-- Drawings (Rendered directly, no image dependencies)
local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 1; FOVCircle.Filled = false

local StatsText = Drawing.new("Text")
StatsText.Size = isMobile and 16 or 20
StatsText.Center = true
StatsText.Outline = true
StatsText.Color = Color3.fromRGB(0, 255, 150)
StatsText.Visible = true

-- ==========================================
-- 2. SMART ENTITY SCANNER
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        local newEntities = {}
        for _, obj in pairs(workspace:GetDescendants()) do
            if obj:IsA("Model") and obj ~= LocalPlayer.Character then
                local hum = obj:FindFirstChildOfClass("Humanoid")
                local root = obj:FindFirstChild("HumanoidRootPart")
                if hum and root and hum.Health > 0 and hum.MaxHealth > 0 and not root.Anchored then
                    table.insert(newEntities, obj)
                end
            end
        end
        AllEntities = newEntities
    end
end)

-- ==========================================
-- 3. ADVANCED LOGIC (TEAM CHECK & VISIBILITY)
-- ==========================================
local function IsEnemy(char)
    if char == LocalPlayer.Character then return false end
    local p = Players:GetPlayerFromCharacter(char)
    if not p then return true end 

    local success, isEnemy = pcall(function()
        if p.Neutral and LocalPlayer.Neutral then return true end
        if p.TeamColor and LocalPlayer.TeamColor and p.TeamColor ~= LocalPlayer.TeamColor then return true end
        if p.Team and LocalPlayer.Team and p.Team ~= LocalPlayer.Team then return true end
        
        for _, attr in pairs({"Team", "team", "TeamId", "GroupId"}) do
            local a1, a2 = LocalPlayer:GetAttribute(attr), p:GetAttribute(attr)
            if a1 ~= nil and a2 ~= nil and a1 ~= a2 then return true end
        end
        return false 
    end)
    return success and isEnemy or true
end

local function IsVisible(part)
    if not Config.Aim.VisibleCheck then return true end
    local origin = Camera.CFrame.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local ray = RaycastParams.new(); ray.FilterType = Enum.RaycastFilterType.Blacklist
    ray.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local res = workspace:Raycast(origin, direction, ray)
    return res == nil or res.Instance:IsDescendantOf(part.Parent)
end

local function InitESP(char)
    if ESPData[char] then return end
    local p = Players:GetPlayerFromCharacter(char)
    ESPData[char] = {
        Box = Drawing.new("Square"), Tracer = Drawing.new("Line"), 
        Name = Drawing.new("Text"), Distance = Drawing.new("Text"),
        HealthBg = Drawing.new("Line"), HealthVal = Drawing.new("Line"),
        IsPlayer = (p ~= nil),
        DisplayName = p and p.Name or ("[BOT] " .. char.Name)
    }
    local d = ESPData[char]
    d.Box.Thickness = 1; d.Box.Filled = false
    d.Tracer.Thickness = 1
    d.Name.Size = 14; d.Name.Center = true; d.Name.Outline = true
    d.Distance.Size = 12; d.Distance.Center = true; d.Distance.Outline = true
    d.HealthBg.Thickness = 3; d.HealthBg.Color = Color3.fromRGB(0, 0, 0)
    d.HealthVal.Thickness = 1; d.HealthVal.Color = Color3.fromRGB(0, 255, 0)
end

local function ClearESP(char)
    if ESPData[char] then
        for _, v in pairs(ESPData[char]) do if type(v) ~= "string" and type(v) ~= "boolean" then pcall(function() v:Remove() end) end end
        ESPData[char] = nil
    end
end

-- ==========================================
-- 4. MAIN RENDER LOOP
-- ==========================================
RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local topCenter = Vector2.new(Camera.ViewportSize.X/2, 0)
    
    FOVCircle.Position = center; FOVCircle.Radius = Config.Aim.FOV
    FOVCircle.Color = Config.ESP.Color; FOVCircle.Visible = Config.ESP.ShowFOV
    StatsText.Position = Vector2.new(center.X, 20)

    local countPlayers, countBots = 0, 0

    for _, char in ipairs(AllEntities) do if not ESPData[char] and char.Parent then InitESP(char) end end
    for char, _ in pairs(ESPData) do
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not char.Parent or not hum or hum.Health <= 0 then ClearESP(char) end
    end

    local targetChar, shortestDist = nil, Config.Aim.FOV

    for char, obj in pairs(ESPData) do
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and IsEnemy(char) then
            if obj.IsPlayer then countPlayers = countPlayers + 1 else countBots = countBots + 1 end
            
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                local partP, onScreen = Camera:WorldToViewportPoint(root.Position)
                if onScreen then
                    local mag = (Vector2.new(partP.X, partP.Y) - center).Magnitude
                    if mag < shortestDist then shortestDist = mag; targetChar = char end
                end
            end
        end
    end

    StatsText.Text = "Players: " .. countPlayers .. " | Bots: " .. countBots

    -- AIMBOT LOGIC
    if targetChar then
        local tHead, tBody = targetChar:FindFirstChild("Head"), targetChar:FindFirstChild("HumanoidRootPart")
        if tHead and tBody then
            if LockedTarget ~= targetChar then LockedTarget = targetChar; LockedAimPart = nil; ProAimStartTime = nil end

            local targetPos; local aimPartForCheck = tHead
            local isInteracting = UserInputService:IsMouseButtonPressed(0) or UserInputService:IsMouseButtonPressed(1) or UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch)

            if Config.Aim.Mode == 1 then targetPos = tBody.Position; aimPartForCheck = tBody
            elseif Config.Aim.Mode == 2 then targetPos = tHead.Position
            elseif Config.Aim.Mode == 3 then
                if not LockedAimPart then LockedAimPart = (math.random(1,100)<=70) and "Head" or "HumanoidRootPart" end
                local p = targetChar:FindFirstChild(LockedAimPart) or tHead; targetPos = p.Position; aimPartForCheck = p
            elseif Config.Aim.Mode == 4 then
                if isInteracting then
                    if not ProAimStartTime then ProAimStartTime = os.clock(); ProAimDuration = math.random(30, 70)/100 end
                    local alpha = math.sin(math.clamp((os.clock() - ProAimStartTime)/ProAimDuration, 0, 1) * (math.pi/2))
                    targetPos = tBody.Position:Lerp(tHead.Position, alpha)
                else
                    ProAimStartTime = nil; targetPos = tBody.Position
                end
                aimPartForCheck = tBody 
            end

            if Config.Aim.Enabled and IsVisible(aimPartForCheck) then
                -- Direct Camera Lock (Fixes shake by not touching the RootPart)
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos)
            end
            
            -- Safe Magnet
            if Config.Magnet.Enabled and isInteracting then
    local rootPart = targetChar:FindFirstChild("HumanoidRootPart")
    
    if rootPart then
        -- 1. Lấy vị trí GỐC (Dùng RootPart làm mỏ neo, cộng thêm chiều cao của Đầu nếu cần)
        local isHead = (aimPartForCheck.Name == "Head")
        local originalPos = rootPart.Position + (isHead and Vector3.new(0, 1.5, 0) or Vector3.zero)

        -- 2. Tìm điểm gần nhất trên tia ngắm của Camera
        local camPos = Camera.CFrame.Position
        local lookVec = Camera.CFrame.LookVector
        
        -- Dùng Dot Product để tìm điểm chiếu vuông góc từ originalPos lên tia ngắm
        local projectionDistance = (originalPos - camPos):Dot(lookVec)
        local pointOnRay = camPos + (lookVec * projectionDistance)

        -- 3. Tính toán khoảng cách chênh lệch từ vị trí gốc đến điểm trên tia ngắm
        local diff = pointOnRay - originalPos

        -- 4. Giới hạn khoảng cách CỰC ĐẠI dựa trên Limit
        if diff.Magnitude > Config.Magnet.Limit then 
            diff = diff.Unit * Config.Magnet.Limit 
        end

        -- 5. Dịch chuyển part dựa trên VỊ TRÍ GỐC + ĐỘ LỆCH ĐÃ GIỚI HẠN
        aimPartForCheck.CFrame = CFrame.new(originalPos + diff)
        aimPartForCheck.Velocity = Vector3.zero
    end
end

    -- ESP & HITBOX RENDER
    for char, obj in pairs(ESPData) do
        local hum, head, root = char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("Head"), char:FindFirstChild("HumanoidRootPart")
        if hum and hum.Health > 0 and IsEnemy(char) and head and root then
            
            if Config.Hitbox.Enabled then
                local pTarget = char:FindFirstChild((Config.Hitbox.Mode == 1) and "HumanoidRootPart" or "Head")
                if pTarget then
                    pTarget.Size = Vector3.new(Config.Hitbox.Size, Config.Hitbox.Size, Config.Hitbox.Size)
                    pTarget.Transparency = 0.6; pTarget.CanCollide = false; pTarget.Massless = true
                    pTarget.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
                end
            end

            local headP, onScreen = Camera:WorldToViewportPoint(head.Position)
            local rootP = Camera:WorldToViewportPoint(root.Position)
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            
            if onScreen then
                local boxHeight = math.abs(headP.Y - rootP.Y) * 1.5
                local boxWidth = boxHeight * 0.6
                local tl = Vector2.new(headP.X - boxWidth/2, headP.Y - boxHeight * 0.2)
                local br = Vector2.new(headP.X + boxWidth/2, rootP.Y + boxHeight * 0.2)

                obj.Box.Visible = Config.ESP.Box; obj.Box.Color = Config.ESP.Color; obj.Box.Size = Vector2.new(boxWidth, br.Y - tl.Y); obj.Box.Position = tl
                obj.Tracer.Visible = Config.ESP.Tracer; obj.Tracer.Color = Config.ESP.Color; obj.Tracer.From = topCenter; obj.Tracer.To = Vector2.new(headP.X, headP.Y)
                obj.Name.Visible = Config.ESP.Name; obj.Name.Color = Config.ESP.Color; obj.Name.Position = Vector2.new(headP.X, tl.Y - 20); obj.Name.Text = obj.DisplayName
                obj.Distance.Visible = Config.ESP.Distance; obj.Distance.Color = Config.ESP.Color; obj.Distance.Position = Vector2.new(headP.X, br.Y + 5); obj.Distance.Text = math.floor(dist).."m"
                
                if Config.ESP.HealthBar then
                    local healthPct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                    local barHeight = (br.Y - tl.Y)
                    obj.HealthBg.Visible = true; obj.HealthBg.From = Vector2.new(tl.X - 5, tl.Y); obj.HealthBg.To = Vector2.new(tl.X - 5, br.Y)
                    obj.HealthVal.Visible = true; obj.HealthVal.From = Vector2.new(tl.X - 5, br.Y); obj.HealthVal.To = Vector2.new(tl.X - 5, br.Y - (barHeight * healthPct))
                    obj.HealthVal.Color = Color3.fromHSV(healthPct * 0.3, 1, 1) -- Red to Green gradient
                else
                    obj.HealthBg.Visible = false; obj.HealthVal.Visible = false
                end
            else
                obj.Box.Visible = false; obj.Tracer.Visible = false; obj.Name.Visible = false; obj.Distance.Visible = false; obj.HealthBg.Visible = false; obj.HealthVal.Visible = false
            end
        else
            obj.Box.Visible = false; obj.Tracer.Visible = false; obj.Name.Visible = false; obj.Distance.Visible = false; obj.HealthBg.Visible = false; obj.HealthVal.Visible = false
        end
    end
end)

-- ==========================================
-- 5. PROFESSIONAL RESPONSIVE UI (CLEAN VERSION)
-- ==========================================
local UI = Instance.new("ScreenGui", CoreGui); UI.Name = "BOHUB"

local MenuWidth, MenuHeight = isMobile and 300 or 450, isMobile and 350 or 450
local MainFrame = Instance.new("Frame", UI)
MainFrame.Size = UDim2.new(0, MenuWidth, 0, MenuHeight); MainFrame.Position = UDim2.new(0.5, -MenuWidth/2, 0.5, -MenuHeight/2)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20); MainFrame.Visible = false
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", MainFrame).Color = Color3.fromRGB(50, 50, 60)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40); Title.Text = "BO HUB"; Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 18; Title.BackgroundTransparency = 1

local TabContainer = Instance.new("Frame", MainFrame)
TabContainer.Size = UDim2.new(1, -20, 0, 30); TabContainer.Position = UDim2.new(0, 10, 0, 40); TabContainer.BackgroundTransparency = 1
local TabList = Instance.new("UIListLayout", TabContainer); TabList.FillDirection = Enum.FillDirection.Horizontal; TabList.Padding = UDim.new(0, 5)

local ContentContainer = Instance.new("Frame", MainFrame)
ContentContainer.Size = UDim2.new(1, -20, 1, -85); ContentContainer.Position = UDim2.new(0, 10, 0, 75); ContentContainer.BackgroundTransparency = 1

local function MakeTab(name, isFirst)
    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(0.32, 0, 1, 0); btn.Text = name; btn.Font = Enum.Font.GothamSemibold; btn.TextSize = 14
    btn.BackgroundColor3 = isFirst and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(30, 30, 35)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    
    local scroll = Instance.new("ScrollingFrame", ContentContainer)
    scroll.Size = UDim2.new(1, 0, 1, 0); scroll.BackgroundTransparency = 1; scroll.Visible = isFirst
    scroll.ScrollBarThickness = 4; scroll.CanvasSize = UDim2.new(0, 0, 2, 0)
    local list = Instance.new("UIListLayout", scroll); list.Padding = UDim.new(0, 8); list.SortOrder = Enum.SortOrder.LayoutOrder
    return btn, scroll
end

local Tab1Btn, Tab1 = MakeTab("Combat", true)
local Tab2Btn, Tab2 = MakeTab("Visuals", false)

local function SwitchTab(activeBtn, activeTab)
    for _, child in pairs(TabContainer:GetChildren()) do if child:IsA("TextButton") then child.BackgroundColor3 = Color3.fromRGB(30, 30, 35) end end
    for _, child in pairs(ContentContainer:GetChildren()) do if child:IsA("ScrollingFrame") then child.Visible = false end end
    activeBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255); activeTab.Visible = true
end
Tab1Btn.MouseButton1Click:Connect(function() SwitchTab(Tab1Btn, Tab1) end)
Tab2Btn.MouseButton1Click:Connect(function() SwitchTab(Tab2Btn, Tab2) end)

-- UI Elements Creators
local function AddToggle(parent, name, callback)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 35); f.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, -50, 1, 0); l.Position = UDim2.new(0, 10, 0, 0); l.Text = name; l.TextColor3 = Color3.fromRGB(220, 220, 220); l.Font = Enum.Font.Gotham; l.TextSize = 14; l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(0, 40, 0, 20); btn.Position = UDim2.new(1, -50, 0.5, -10); btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50); btn.Text = ""; Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local circle = Instance.new("Frame", btn); circle.Size = UDim2.new(0, 16, 0, 16); circle.Position = UDim2.new(0, 2, 0.5, -8); circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255); Instance.new("UICorner", circle).CornerRadius = UDim.new(1, 0)
    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state; callback(state)
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(50, 50, 50)
        circle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    end)
end

local function AddSlider(parent, name, min, max, default, callback)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 45); f.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(1, -10, 0, 20); l.Position = UDim2.new(0, 10, 0, 5); l.Text = name .. ": " .. default; l.TextColor3 = Color3.fromRGB(220, 220, 220); l.Font = Enum.Font.Gotham; l.TextSize = 13; l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(1, -20, 0, 6); btn.Position = UDim2.new(0, 10, 0, 30); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); btn.Text = ""; Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
    local fill = Instance.new("Frame", btn); fill.Size = UDim2.new((default-min)/(max-min), 0, 1, 0); fill.BackgroundColor3 = Color3.fromRGB(0, 150, 255); Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)
    btn.MouseButton1Down:Connect(function()
        local move = RunService.RenderStepped:Connect(function()
            local pct = math.clamp((UserInputService:GetMouseLocation().X - btn.AbsolutePosition.X) / btn.AbsoluteSize.X, 0, 1)
            local val = math.floor(min + (max - min) * pct)
            fill.Size = UDim2.new(pct, 0, 1, 0); l.Text = name .. ": " .. val; callback(val)
        end)
        local endIn; endIn = UserInputService.InputEnded:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then move:Disconnect(); endIn:Disconnect() end end)
    end)
end

local function AddDropdown(parent, name, options, callback)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1, 0, 0, 35); f.BackgroundColor3 = Color3.fromRGB(25, 25, 30); Instance.new("UICorner", f).CornerRadius = UDim.new(0, 6)
    local l = Instance.new("TextLabel", f); l.Size = UDim2.new(0.5, 0, 1, 0); l.Position = UDim2.new(0, 10, 0, 0); l.Text = name; l.TextColor3 = Color3.fromRGB(220, 220, 220); l.Font = Enum.Font.Gotham; l.TextSize = 14; l.BackgroundTransparency = 1; l.TextXAlignment = Enum.TextXAlignment.Left
    local btn = Instance.new("TextButton", f); btn.Size = UDim2.new(0.4, 0, 0, 25); btn.Position = UDim2.new(0.55, 0, 0.5, -12.5); btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45); btn.Text = options[1]; btn.TextColor3 = Color3.fromRGB(255, 255, 255); btn.Font = Enum.Font.Gotham; btn.TextSize = 12; Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 4)
    local idx = 1
    btn.MouseButton1Click:Connect(function() idx = idx >= #options and 1 or idx + 1; btn.Text = options[idx]; callback(idx) end)
end

-- POPULATE TABS
AddToggle(Tab1, "Enable Aimbot", function(v) Config.Aim.Enabled = v end)
AddDropdown(Tab1, "Aim Part", {"Body", "Head", "Random 70/30", "Pro Pre-Aim"}, function(v) Config.Aim.Mode = v end)
AddToggle(Tab1, "Wall Check (Visible Only)", function(v) Config.Aim.VisibleCheck = v end)
AddSlider(Tab1, "FOV Radius", 50, 500, 100, function(v) Config.Aim.FOV = v end)

AddToggle(Tab1, "Enable Magnet (On Shoot)", function(v) Config.Magnet.Enabled = v end)
AddSlider(Tab1, "Magnet Safe Range", 1, 20, 5, function(v) Config.Magnet.Limit = v end)

AddToggle(Tab1, "Enable Hitbox Expander", function(v) Config.Hitbox.Enabled = v end)
AddDropdown(Tab1, "Hitbox Part", {"Body", "Head"}, function(v) Config.Hitbox.Mode = v end)
AddSlider(Tab1, "Hitbox Size", 1, 50, 15, function(v) Config.Hitbox.Size = v end)

AddToggle(Tab2, "Show FOV Circle", function(v) Config.ESP.ShowFOV = v end)
AddToggle(Tab2, "ESP Boxes", function(v) Config.ESP.Box = v end)
AddToggle(Tab2, "ESP Health Bar", function(v) Config.ESP.HealthBar = v end)
AddToggle(Tab2, "ESP Tracers", function(v) Config.ESP.Tracer = v end)
AddToggle(Tab2, "ESP Names", function(v) Config.ESP.Name = v end)
AddToggle(Tab2, "ESP Distance", function(v) Config.ESP.Distance = v end)

local colorColors = {Color3.fromRGB(255,255,255), Color3.fromRGB(255,50,50), Color3.fromRGB(50,255,50), Color3.fromRGB(50,150,255), Color3.fromRGB(255,255,50), Color3.fromRGB(200,50,255)}
local colorNames = {"White", "Red", "Green", "Blue", "Yellow", "Purple"}
AddDropdown(Tab2, "ESP Color", colorNames, function(idx) Config.ESP.Color = colorColors[idx] end)

-- Mobile Toggle Button / PC Keybind
if isMobile then
    local OpenBtn = Instance.new("TextButton", UI)
    OpenBtn.Size = UDim2.new(0, 50, 0, 50); OpenBtn.Position = UDim2.new(0, 15, 0.4, 0)
    OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    OpenBtn.Text = "BO"; OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255); OpenBtn.Font = Enum.Font.GothamBlack; OpenBtn.TextSize = 18
    Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(1, 0)
    Instance.new("UIStroke", OpenBtn).Color = Color3.fromRGB(0, 150, 255); Instance.new("UIStroke", OpenBtn).Thickness = 2
    
    local dragging, dragStart, startPos
    OpenBtn.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = input.Position; startPos = OpenBtn.Position end end)
    UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.Touch then local delta = input.Position - dragStart; OpenBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
    UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = not MainFrame.Visible end)
else
    UserInputService.InputBegan:Connect(function(input, gp) if not gp and input.KeyCode == Enum.KeyCode.K then MainFrame.Visible = not MainFrame.Visible end end)
end

local dragToggle, dragStart, startPos
Title.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = true; dragStart = input.Position; startPos = MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(input) if dragToggle and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then local delta = input.Position - dragStart; MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragToggle = false end end)
