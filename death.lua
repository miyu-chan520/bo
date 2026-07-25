-- === iLoVe DeAtH // ULTIMATE DESTROYER v9.0 (UNIVERSAL OMNI EDITION) ===

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Players = Services.Players
local RunService = Services.RunService
local InputService = Services.UserInputService
local Workspace = Services.Workspace
local TeleportService = Services.TeleportService
local HttpService = Services.HttpService
local TextChatService = Services.TextChatService
local ReplicatedStorage = Services.ReplicatedStorage
local VirtualUser = Services.VirtualUser
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local ProtectGui = gethui or function() 
    return game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui") 
end

-- ==========================================
-- 0. UNIVERSAL CLICK ENGINE (HỖ TRỢ PC & MOBILE)
-- ==========================================
local function UniversalClick()
    pcall(function()
        if type(mouse1click) == "function" then
            mouse1click()
        else
            VirtualUser:ClickButton1(Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2))
            local t = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if t then t:Activate() end
        end
    end)
end

-- ==========================================
-- 1. HYBRID BYPASS & ANTI-KICK
-- ==========================================
local function SafeDestroy(obj) pcall(function() obj:Destroy() end) end

local function DeepCleanup()
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v.Name == "ClientAlert" or v.Name == "LocalScript3" then SafeDestroy(v) end
    end
    for _, v in ipairs(LocalPlayer.PlayerGui:GetDescendants()) do
        if v.Name == "ClientAlert" or v.Name == "LocalScript3" then SafeDestroy(v) end
    end
end

if type(hookmetamethod) == "function" then
    local OldNamecall
    OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
        local Method = getnamecallmethod()
        if Method == "Kick" or Method == "kick" then return end
        if Method == "FireServer" then
            local rn = tostring(Self.Name):lower()
            if rn:find("kick") or rn:find("alert") or rn:find("ban") then return end
        end
        return OldNamecall(Self, ...)
    end)
end

if type(hookfunction) == "function" then
    pcall(function() hookfunction(LocalPlayer.Kick, function() end) end)
end

task.spawn(function()
    while task.wait(1.5) do
        DeepCleanup()
        local alert = ReplicatedStorage:FindFirstChild("ClientAlert", true) or Services.StarterGui:FindFirstChild("ClientAlert", true)
        if alert then SafeDestroy(alert) end
    end
end)
DeepCleanup()

-- ==========================================
-- 2. NUCLEAR BOBO INVISIBLE ENGINE
-- ==========================================
local invisChar, invisHum, invisRoot
local invisible = false
local invisParts = {}
local invisConn

local function SetupInvisible()
    if invisConn then pcall(function() invisConn:Disconnect() end) end
    invisParts = {}
    invisChar = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    invisHum = invisChar:WaitForChild("Humanoid")
    invisRoot = invisChar:WaitForChild("HumanoidRootPart")

    invisHum.Died:Once(function()
        invisible = false
        for _, part in pairs(invisParts) do
            pcall(function() if part:IsA("BasePart") then part.Transparency = 0 end end)
        end
    end)

    for _, obj in pairs(invisChar:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" and obj.Name ~= "CollisionPart" then
            table.insert(invisParts, obj)
            if invisible then obj.Transparency = 0.7 end
        end
    end

    invisConn = invisChar.DescendantAdded:Connect(function(obj)
        task.wait()
        if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" and obj.Name ~= "CollisionPart" then
            table.insert(invisParts, obj)
            if invisible then obj.Transparency = 0.7 end
        end
    end)
end

local function ToggleNuclearInvisible(state)
    invisible = state
    for _, part in pairs(invisParts) do
        pcall(function() if part:IsA("BasePart") then part.Transparency = invisible and 0.7 or 0 end end)
    end
end

RunService.Heartbeat:Connect(function()
    if invisible and invisChar and invisRoot and invisHum and invisHum.Health > 0 then
        local cf = invisRoot.CFrame
        local camOffset = invisHum.CameraOffset
        local hidden = cf * CFrame.new(0, -200000, 0)
        
        invisRoot.CFrame = hidden
        invisHum.CameraOffset = hidden:ToObjectSpace(CFrame.new(cf.Position)).Position
        RunService.RenderStepped:Wait()
        invisRoot.CFrame = cf
        invisHum.CameraOffset = camOffset
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    invisible = false
    task.wait(1)
    SetupInvisible()
end)
SetupInvisible()

-- ==========================================
-- 3. GUI SYSTEM & CONFIGURATION
-- ==========================================
local MenuOpen = true
_G.SpamText = "iLoVe DeAtH v9.0 is DOMINATING THIS SERVER!"

local Features = {
    KillAura = false, AimLock = false, TriggerBot = false, AutoClicker = false, GunMod = false, Magnet = false, Hitbox = false,
    SpeedHack = false, Noclip = false, InfJump = false, Spinbot = false, Fly = false,
    TpToClosest = false, ClickTP = false, BringEnemies = false, AnchorSpawn = false,
    ESP = false, Tracers = false, Fullbright = false, NoFog = false, Chams = false,
    AntiAim = false, SpamChat = false, FpsBooster = false, ServerHop = false, AutoRespawn = false, VoidImmune = false, Invisible = false
}

local MagnetLimit = 6
local BaseHeadSizeV = Vector3.new(1.2, 1.2, 1.2)
local HitboxSize = 15

if ProtectGui():FindFirstChild("iLoVeDeAtH_v9") then ProtectGui().iLoVeDeAtH_v9:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "iLoVeDeAtH_v9"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ProtectGui()

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 480, 0, 450)
MainFrame.Position = UDim2.new(0.5, -240, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 15)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.Color = Color3.fromRGB(220, 0, 0)
MainStroke.Thickness = 2

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(10, 5, 10)
Sidebar.BorderSizePixel = 0
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local TitleText = Instance.new("TextLabel", Sidebar)
TitleText.Size = UDim2.new(1, 0, 0, 45)
TitleText.Text = "DEATH v9.0"
TitleText.TextColor3 = Color3.fromRGB(255, 0, 0)
TitleText.TextSize = 20
TitleText.Font = Enum.Font.GothamBlack
TitleText.BackgroundTransparency = 1

local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.Size = UDim2.new(1, -145, 1, -20)
ContentFrame.Position = UDim2.new(0, 138, 0, 10)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(220, 0, 0)

local ListLayout = Instance.new("UIListLayout", ContentFrame)
ListLayout.Padding = UDim.new(0, 8)
ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

local function ClearContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child:IsA("TextButton") or child:IsA("TextBox") then child:Destroy() end
    end
end

local function SendNotification(msg)
    pcall(function() Services.StarterGui:SetCore("SendNotification", { Title = "DEATH v9.0"; Text = msg; Duration = 2; }) end)
end

local RenderTab
local function CreateToggle(text, key)
    local Btn = Instance.new("TextButton", ContentFrame)
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BorderSizePixel = 0
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 12
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

    local function UpdateVisuals()
        if Features[key] then
            Btn.Text = ">> " .. text .. " <<"
            Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            Btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
        else
            Btn.Text = "[ OFF ]  " .. text
            Btn.TextColor3 = Color3.fromRGB(160, 160, 160)
            Btn.BackgroundColor3 = Color3.fromRGB(25, 20, 25)
        end
    end
    UpdateVisuals()
    Btn.MouseButton1Click:Connect(function()
        Features[key] = not Features[key]
        UpdateVisuals()
        if key == "Invisible" then ToggleNuclearInvisible(Features[key]) end
    end)
end

local function CreateActionBtn(text, callback, isRage)
    local Btn = Instance.new("TextButton", ContentFrame)
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BorderSizePixel = 0
    Btn.Font = Enum.Font.GothamBlack
    Btn.TextSize = 13
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.BackgroundColor3 = isRage and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(50, 50, 50)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
    if isRage then
        local stroke = Instance.new("UIStroke", Btn)
        stroke.Color = Color3.fromRGB(255, 255, 255)
        stroke.Thickness = 1
    end
    Btn.MouseButton1Click:Connect(callback)
end

local function CreateTextBox(placeholder)
    local Box = Instance.new("TextBox", ContentFrame)
    Box.Size = UDim2.new(1, -10, 0, 35)
    Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 12
    Box.PlaceholderText = placeholder
    Box.Text = _G.SpamText
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
    Box.FocusLost:Connect(function() _G.SpamText = Box.Text end)
end

RenderTab = function(tabName)
    ClearContent()
    if tabName == "Combat" then
        CreateActionBtn("🔥 RAGE MODE (ENABLE ALL) 🔥", function()
            local rageList = {"Hitbox", "ESP", "Tracers", "TriggerBot", "Magnet", "SpeedHack", "InfJump", "Fullbright", "NoFog", "VoidImmune", "Invisible"}
            for _, v in ipairs(rageList) do Features[v] = true end
            ToggleNuclearInvisible(true)
            SendNotification("OMNI RAGE ACTIVATED!")
            RenderTab("Combat")
        end, true)
        CreateToggle("AIMLOCK (180° INSTANT AIM)", "AimLock")
        CreateToggle("SAFE MAGNET (Silent Aim)", "Magnet")
        CreateToggle("HEAD HITBOX (15x Size)", "Hitbox")
        CreateToggle("TRIGGERBOT (UNIVERSAL CLICK)", "TriggerBot")
        CreateToggle("AUTO CLICKER (Hold to Spam)", "AutoClicker")
        CreateToggle("KILL AURA (Auto Attack Nearby)", "KillAura")
        CreateToggle("GUN MOD (Old Games Only)", "GunMod")
    elseif tabName == "Movement" then
        CreateToggle("UNIVERSAL SPEEDHACK (CFrame Bypass)", "SpeedHack")
        CreateToggle("SPINBOT (Tilt 45°, Safe Cam)", "Spinbot")
        CreateToggle("INFINITE JUMP", "InfJump")
        CreateToggle("NOCLIP", "Noclip")
        CreateToggle("UNIVERSAL FLY (BodyVelocity)", "Fly")
    elseif tabName == "Teleport" then
        CreateToggle("TP TO CLOSEST (Press X)", "TpToClosest")
        CreateToggle("CLICK TP (Ctrl + Click)", "ClickTP")
        CreateToggle("BRING ENEMIES", "BringEnemies")
    elseif tabName == "Visuals" then
        CreateToggle("ESP BOX & NAME (Universal Drawing)", "ESP")
        CreateToggle("TRACERS (Lines)", "Tracers")
        CreateToggle("CHAMS (Wallhack)", "Chams")
        CreateToggle("FULLBRIGHT", "Fullbright")
        CreateToggle("NO FOG", "NoFog")
    elseif tabName == "Exploits" then
        CreateToggle("GOD INVISIBLE (NuclearBobo)", "Invisible")
        CreateToggle("VOID IMMUNITY (Bounce to 150m)", "VoidImmune")
        CreateActionBtn("FPS BOOSTER (Max Performance)", function()
            settings().Rendering.QualityLevel = 1
            game.Lighting.GlobalShadows = false
            for _, v in pairs(Workspace:GetDescendants()) do
                if v:IsA("BasePart") and not v:IsA("Terrain") then
                    v.Material = Enum.Material.SmoothPlastic
                    v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v:Destroy()
                end
            end
            game.Lighting:ClearAllChildren()
            SendNotification("FPS MAXIMIZED!")
        end, false)
        CreateToggle("CHAT SPAMMER (Super Fast)", "SpamChat")
        CreateTextBox("Type your spam text here...")
        CreateToggle("AUTO RESPAWN", "AutoRespawn")
        CreateActionBtn("SERVER HOP", function() Features.ServerHop = true end, false)
    end
    task.wait(0.05)
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
end

local function CreateTabButton(name, layoutOrder)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.Position = UDim2.new(0, 5, 0, 50 + (layoutOrder * 42))
    TabBtn.BackgroundColor3 = Color3.fromRGB(25, 20, 25)
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Text = name
    TabBtn.TextSize = 14
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.BorderSizePixel = 0
    Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 4)
    TabBtn.MouseButton1Click:Connect(function() RenderTab(name) end)
end

CreateTabButton("Combat", 0)
CreateTabButton("Movement", 1)
CreateTabButton("Teleport", 2)
CreateTabButton("Visuals", 3)
CreateTabButton("Exploits", 4)
RenderTab("Combat")

-- ==========================================
-- 4. CORE ESP DRAWING (BO HUB 100%)
-- ==========================================
local ESPData = {}
local AllEntities = {}

task.spawn(function()
    while task.wait(1) do
        local t = {}
        for _, o in pairs(Workspace:GetDescendants()) do
            if o:IsA("Model") and o ~= LocalPlayer.Character then
                local h = o:FindFirstChildOfClass("Humanoid")
                local r = o:FindFirstChild("HumanoidRootPart")
                if h and r and h.Health > 0 and h.MaxHealth > 0 and not r.Anchored then 
                    table.insert(t, o) 
                end
            end
        end
        AllEntities = t
    end
end)

local function IsEnemy(c)
    if c == LocalPlayer.Character then return false end
    local p = Players:GetPlayerFromCharacter(c)
    if not p then return true end
    local ok, e = pcall(function()
        if p.Neutral and LocalPlayer.Neutral then return true end
        if p.TeamColor and LocalPlayer.TeamColor and p.TeamColor ~= LocalPlayer.TeamColor then return true end
        if p.Team and LocalPlayer.Team and p.Team ~= LocalPlayer.Team then return true end
        return false
    end)
    return ok and e or true
end

local function InitESP(c)
    if ESPData[c] or not (typeof(Drawing) == "table" or type(Drawing) == "userdata") then return end
    local p = Players:GetPlayerFromCharacter(c)
    ESPData[c] = {
        Box = Drawing.new("Square"), Tracer = Drawing.new("Line"), 
        Name = Drawing.new("Text"), Distance = Drawing.new("Text"),
        HealthBg = Drawing.new("Line"), HealthVal = Drawing.new("Line"),
        DisplayName = p and p.Name or c.Name
    }
    local d = ESPData[c]
    d.Box.Thickness = 1 d.Box.Filled = false d.Box.Color = Color3.fromRGB(255, 0, 0)
    d.Tracer.Thickness = 1 d.Tracer.Color = Color3.fromRGB(255, 0, 0)
    d.Name.Size = 14 d.Name.Center = true d.Name.Outline = true d.Name.Color = Color3.new(1,1,1)
    d.Distance.Size = 12 d.Distance.Center = true d.Distance.Outline = true d.Distance.Color = Color3.new(1,1,1)
    d.HealthBg.Thickness = 3 d.HealthBg.Color = Color3.new(0,0,0) d.HealthVal.Thickness = 1
end

local function ClearESP(c)
    if ESPData[c] then 
        for _, v in pairs(ESPData[c]) do 
            if type(v) ~= "string" and type(v) ~= "boolean" then pcall(function() v:Remove() end) end 
        end 
        ESPData[c] = nil 
    end
end

-- ==========================================
-- 5. UTILS LOGIC (WALLCHECK & CLOSEST)
-- ==========================================
local function GetClosest180()
    local closest = nil
    local minDist = math.huge
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and IsEnemy(p.Character) then
                local pos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                if pos.Z > 0 then
                    local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                    if dist < minDist then minDist = dist closest = p.Character end
                end
            end
        end
    end
    return closest
end

local function IsVisible(targetPart)
    local origin = Camera.CFrame.Position
    local direction = (targetPart.Position - origin).Unit * (targetPart.Position - origin).Magnitude
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.IgnoreWater = true
    local result = Workspace:Raycast(origin, direction, rayParams)
    return result == nil or result.Instance:IsDescendantOf(targetPart.Parent)
end

-- ==========================================
-- 6. INPUT & HOTKEYS
-- ==========================================
InputService.JumpRequest:Connect(function()
    if Features.InfJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
    end
end)

InputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    if input.KeyCode == Enum.KeyCode.X then
        if Features.TpToClosest then
            local closest = nil
            local minDist = math.huge
            local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    if IsEnemy(p.Character) then
                        local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
                        if onScreen then
                            local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                            if dist < minDist then minDist = dist closest = p.Character end
                        end
                    end
                end
            end
            local char = LocalPlayer.Character
            if closest and char and char:FindFirstChild("HumanoidRootPart") then
                char.HumanoidRootPart.CFrame = closest.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
            end
        end
    end
    if Features.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton1 and InputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local Mouse = LocalPlayer:GetMouse()
        if Mouse.Target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, 3, 0))
        end
    end
    if input.KeyCode == Enum.KeyCode.Insert then
        MenuOpen = not MenuOpen
        MainFrame.Visible = MenuOpen
    end
end)

-- ==========================================
-- 7. RENDER LOOP (ESP, AIM, MAGNET)
-- ==========================================
local MagnetAnchorPos = nil 
local MagnetTarget = nil
local origC0 = nil

RunService.Stepped:Connect(function()
    if Features.Hitbox then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and IsEnemy(player.Character) then
                local headE = player.Character:FindFirstChild("Head")
                if headE then headE.CanCollide = false end
            end
        end
    end
    if Features.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetChildren()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local center = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
    local top = Vector2.new(Camera.ViewportSize.X/2, 0)
    local Char = LocalPlayer.Character
    local isInteracting = InputService:IsMouseButtonPressed(0) or InputService:IsMouseButtonPressed(1)

    -- ESP DRAWING
    for _, c in ipairs(AllEntities) do if not ESPData[c] and c.Parent then InitESP(c) end end
    for c, _ in pairs(ESPData) do 
        local h = c:FindFirstChildOfClass("Humanoid")
        if not c.Parent or not h or h.Health <= 0 then ClearESP(c) end 
    end

    local tc, sd = nil, 500
    for c, o in pairs(ESPData) do
        local h = c:FindFirstChildOfClass("Humanoid")
        if h and h.Health > 0 and IsEnemy(c) then
            local r = c:FindFirstChild("HumanoidRootPart")
            local hd = c:FindFirstChild("Head")
            if r and hd then 
                local hp, onScreen = Camera:WorldToViewportPoint(hd.Position)
                local rp, _ = Camera:WorldToViewportPoint(r.Position)
                local dist = (Camera.CFrame.Position - r.Position).Magnitude
                
                if onScreen then 
                    local m = (Vector2.new(hp.X, hp.Y) - center).Magnitude
                    if m < sd then sd = m tc = c end 
                end

                if onScreen and Features.ESP then
                    local bh = math.abs(hp.Y - rp.Y) * 1.5
                    local bw = bh * 0.6
                    local tl = Vector2.new(hp.X - bw/2, hp.Y - bh * 0.2)
                    local br = Vector2.new(hp.X + bw/2, rp.Y + bh * 0.2)
                    
                    o.Box.Visible = true; o.Box.Size = Vector2.new(bw, br.Y - tl.Y); o.Box.Position = tl
                    o.Tracer.Visible = Features.Tracers; o.Tracer.From = top; o.Tracer.To = Vector2.new(hp.X, hp.Y)
                    o.Name.Visible = true; o.Name.Position = Vector2.new(hp.X, tl.Y - 20); o.Name.Text = o.DisplayName
                    o.Distance.Visible = true; o.Distance.Position = Vector2.new(hp.X, br.Y + 5); o.Distance.Text = math.floor(dist).."m"
                    
                    local hpct = math.clamp(h.Health / h.MaxHealth, 0, 1)
                    local bah = (br.Y - tl.Y)
                    o.HealthBg.Visible = true; o.HealthBg.From = Vector2.new(tl.X - 5, tl.Y); o.HealthBg.To = Vector2.new(tl.X - 5, br.Y)
                    o.HealthVal.Visible = true; o.HealthVal.From = Vector2.new(tl.X - 5, br.Y); o.HealthVal.To = Vector2.new(tl.X - 5, br.Y - (bah * hpct))
                    o.HealthVal.Color = Color3.fromHSV(hpct * 0.3, 1, 1)
                else
                    o.Box.Visible = false o.Tracer.Visible = false o.Name.Visible = false o.Distance.Visible = false o.HealthBg.Visible = false o.HealthVal.Visible = false
                end
            end
        else
            o.Box.Visible = false o.Tracer.Visible = false o.Name.Visible = false o.Distance.Visible = false o.HealthBg.Visible = false o.HealthVal.Visible = false
        end
    end

    -- AIMLOCK & MAGNET
    local Target = GetClosest180()
    if Target then
        local tHead = Target:FindFirstChild("Head")
        local tRoot = Target:FindFirstChild("HumanoidRootPart")
        if tHead and tRoot then
            if Features.AimLock and isInteracting then
                Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, tHead.Position)
                MagnetAnchorPos = nil
                MagnetTarget = nil
            elseif Features.Magnet and isInteracting then
                if not MagnetAnchorPos or MagnetTarget ~= Target then
                    MagnetTarget = Target
                    MagnetAnchorPos = tRoot.Position + Vector3.new(0, 1.5, 0)
                end
                local camPos = Camera.CFrame.Position
                local lookVec = Camera.CFrame.LookVector
                local projectionDistance = (MagnetAnchorPos - camPos):Dot(lookVec)
                local pointOnRay = camPos + (lookVec * projectionDistance)
                local diff = pointOnRay - MagnetAnchorPos

                if diff.Magnitude > MagnetLimit then diff = diff.Unit * MagnetLimit end
                tHead.CFrame = CFrame.new(MagnetAnchorPos + diff)
                tHead.Velocity = Vector3.zero
            else
                MagnetAnchorPos = nil
                MagnetTarget = nil
            end
        end
    else
        MagnetAnchorPos = nil
        MagnetTarget = nil
    end

    -- SPINBOT (SAFE CAM - TILT 45°)
    local rootJoint = Char and (Char:FindFirstChild("LowerTorso") and Char.LowerTorso:FindFirstChild("Root") or Char:FindFirstChild("HumanoidRootPart") and Char.HumanoidRootPart:FindFirstChild("RootJoint"))
    if Features.Spinbot and rootJoint then
        if not origC0 then origC0 = rootJoint.C0 end
        local spinAngle = (tick() * 1500) % 360 
        rootJoint.C0 = origC0 * CFrame.Angles(math.rad(45), math.rad(spinAngle), 0)
    else
        if origC0 and rootJoint then rootJoint.C0 = origC0; origC0 = nil end
    end
end)

-- ==========================================
-- 8. PHYSICS & UNIVERSAL LOOP (HEARTBEAT)
-- ==========================================
local lastSpam = 0
local lastTriggerClick = 0
local lastAutoClick = 0

RunService.Heartbeat:Connect(function()
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local isShooting = InputService:IsMouseButtonPressed(0) or InputService:IsMouseButtonPressed(1)

    -- HEAD HITBOX (BO HUB CORE) & CHAMS
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local humE = player.Character:FindFirstChildOfClass("Humanoid")
            local headE = player.Character:FindFirstChild("Head")
            
            if humE and headE and humE.Health > 0 and IsEnemy(player.Character) then
                if Features.Hitbox then
                    headE.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                    headE.Transparency = 0.6
                    headE.Massless = true
                    headE.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
                else
                    if headE.Size.X > 5 then 
                        headE.Size = BaseHeadSizeV 
                        headE.Transparency = 0 
                        headE.CustomPhysicalProperties = nil 
                    end
                end

                if Features.Chams then
                    if not player.Character:FindFirstChild("DeathChams") then
                        local Highlight = Instance.new("Highlight")
                        Highlight.Name = "DeathChams" Highlight.FillColor = Color3.fromRGB(255, 0, 0) Highlight.OutlineColor = Color3.fromRGB(255, 255, 255) Highlight.FillTransparency = 0.5 Highlight.Parent = player.Character
                    end
                else
                    if player.Character:FindFirstChild("DeathChams") then player.Character.DeathChams:Destroy() end
                end
            end
        end
    end

    -- UNIVERSAL AUTO CLICKER
    if Features.AutoClicker and isShooting then 
        if tick() - lastAutoClick > 0.05 then
            UniversalClick()
            lastAutoClick = tick()
        end
    end

    -- UNIVERSAL TRIGGER BOT (CÓ WALLCHECK)
    if Features.TriggerBot and not isShooting then
        local rayParams = RaycastParams.new()
        rayParams.FilterType = Enum.RaycastFilterType.Blacklist
        rayParams.FilterDescendantsInstances = {Char, Camera}
        
        local result = Workspace:Raycast(Camera.CFrame.Position, Camera.CFrame.LookVector * 1500, rayParams)
        
        if result and result.Instance then
            local hitModel = result.Instance:FindFirstAncestorOfClass("Model")
            if hitModel and hitModel:FindFirstChild("Humanoid") and hitModel:FindFirstChild("Humanoid").Health > 0 and IsEnemy(hitModel) then
                if tick() - lastTriggerClick > 0.05 then 
                    UniversalClick()
                    lastTriggerClick = tick()
                end
            end
        end
    end

    -- UNIVERSAL KILL AURA
    if Features.KillAura and Root then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                if (Root.Position - p.Character.HumanoidRootPart.Position).Magnitude <= 20 and IsEnemy(p.Character) then
                    UniversalClick()
                end
            end
        end
    end

    if Features.GunMod then
        local Tool = Char and Char:FindFirstChildOfClass("Tool")
        if Tool then
            for _, v in pairs(Tool:GetDescendants()) do
                if v:IsA("NumberValue") or v:IsA("IntValue") then
                    local name = v.Name:lower()
                    if name:find("recoil") or name:find("spread") or name:find("accuracy") then v.Value = 0 end
                end
            end
        end
    end

    if Features.BringEnemies and Root then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and IsEnemy(p.Character) then
                p.Character.HumanoidRootPart.CFrame = Root.CFrame * CFrame.new(0, 0, -3)
            end
        end
    end

    -- UNIVERSAL SPEEDHACK (CFrame Bypass Anti-Cheat)
    if Features.SpeedHack and Hum and Root then 
        local moveDir = Hum.MoveDirection
        if moveDir.Magnitude > 0 then
            Root.CFrame = Root.CFrame + (moveDir * 1.2) -- Tương đương Speed = 80
        end
    end
    
    -- UNIVERSAL FLY (BodyVelocity)
    if Features.Fly and Root then
        local Dir = Vector3.new()
        local camCF = Camera.CFrame
        if InputService:IsKeyDown(Enum.KeyCode.W) then Dir = Dir + camCF.LookVector end
        if InputService:IsKeyDown(Enum.KeyCode.S) then Dir = Dir - camCF.LookVector end
        if InputService:IsKeyDown(Enum.KeyCode.A) then Dir = Dir - camCF.RightVector end
        if InputService:IsKeyDown(Enum.KeyCode.D) then Dir = Dir + camCF.RightVector end
        
        if not Root:FindFirstChild("OmniFly") then
            local bv = Instance.new("BodyVelocity", Root)
            bv.Name = "OmniFly"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.zero
        end
        Root.OmniFly.Velocity = Dir * 80
    else
        if Root and Root:FindFirstChild("OmniFly") then Root.OmniFly:Destroy() end
    end

    if Features.Fullbright then
        game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
        game:GetService("Lighting").Brightness = 2
    end
    if Features.NoFog then game:GetService("Lighting").FogEnd = 999999 end

    -- VOID IMMUNITY (NẢY LÊN 150M)
    if Features.VoidImmune and Root and Root.Position.Y < -50 then
        Root.Velocity = Vector3.zero
        Root.CFrame = CFrame.new(Root.Position.X, 150, Root.Position.Z)
    end

    -- SAFE SPAM CHAT (ANTI-RATE LIMIT BYPASS)
    if Features.SpamChat and tick() - lastSpam > 2.5 then -- 2.5s là tốc độ nhanh nhất không bị khóa mõm
        -- Tạo một chuỗi mã ngẫu nhiên chống bộ lọc trùng lặp của Roblox
        local randomCode = " | ID:" .. tostring(math.random(1000, 9999))
        local bypassMsg = _G.SpamText .. randomCode
        
        -- Gửi tin nhắn
        pcall(function() ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(bypassMsg, "All") end)
        pcall(function() TextChatService.TextChannels.RBXGeneral:SendAsync(bypassMsg) end)
        
        lastSpam = tick()
    end
    
    if Features.AutoRespawn and Hum and Hum.Health <= 0 then pcall(function() LocalPlayer:LoadCharacter() end) end
end)

print("iLoVe DeAtH v9.0 (UNIVERSAL OMNI) Loaded Successfully!")
