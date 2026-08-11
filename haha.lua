-- === Haha Hub :) // ULTIMATE SCRIPT ===

local Services = setmetatable({}, {__index = function(_, k) return game:GetService(k) end})
local Players = Services.Players
local RunService = Services.RunService
local InputService = Services.UserInputService
local Workspace = Services.Workspace
local ReplicatedStorage = Services.ReplicatedStorage
local GuiService = Services.GuiService
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local TextChatService = game:GetService("TextChatService")
local ProximityPromptService = game:GetService("ProximityPromptService")

local MenuOpen = true

print("----------------------------------------")
print("[Haha Hub :)] INITIATING SYSTEM...")

-- ==========================================
-- 0. DRAWING API MEMORY LEAK FIX
-- ==========================================
local HAS_DRAWING = type(Drawing) == "table" or type(Drawing) == "function"

if _G.DeAtH_ESPData then
    for _, obj in pairs(_G.DeAtH_ESPData) do
        for _, v in pairs(obj) do
            if type(v) ~= "string" and type(v) ~= "boolean" then
                pcall(function() v.Visible = false; v:Remove() end)
            end
        end
    end
end
_G.DeAtH_ESPData = {}
local ESPData = _G.DeAtH_ESPData

if _G.DeAtH_FOVCircle then 
    pcall(function() _G.DeAtH_FOVCircle.Visible = false; _G.DeAtH_FOVCircle:Remove() end) 
end

local FOVCircle
if HAS_DRAWING then
    FOVCircle = Drawing.new("Circle")
    _G.DeAtH_FOVCircle = FOVCircle
    FOVCircle.Thickness = 1.5
    FOVCircle.Filled = false
    FOVCircle.Color = Color3.fromRGB(0, 255, 200) -- Theme Xanh Ngọc
    FOVCircle.NumSides = 64
    FOVCircle.Visible = false
end

-- ==========================================
-- 1. EVENT-DRIVEN CLEANUP
-- ==========================================
local function SafeDestroy(obj) pcall(function() obj:Destroy() end) end

LocalPlayer.PlayerGui.DescendantAdded:Connect(function(obj)
    if obj.Name == "ClientAlert" or obj.Name == "LocalScript3" then
        SafeDestroy(obj)
    end
end)

local BadRemotes = {
    ["Kick"] = true, ["kick"] = true, ["Ban"] = true, ["ban"] = true, 
    ["Alert"] = true, ["alert"] = true, ["Log"] = true, ["log"] = true, 
    ["Report"] = true, ["report"] = true, ["Crash"] = true, ["crash"] = true, ["ClientAlert"] = true
}

if type(hookmetamethod) == "function" then
    pcall(function()
        local OldNamecall
        OldNamecall = hookmetamethod(game, "__namecall", function(Self, ...)
            local Method = getnamecallmethod()
            if Method == "Kick" or Method == "kick" then return end
            if (Method == "FireServer" or Method == "InvokeServer") and typeof(Self) == "Instance" then
                if BadRemotes[Self.Name] then return end 
            end
            return OldNamecall(Self, ...)
        end)
    end)
end

if type(hookfunction) == "function" then
    pcall(function() hookfunction(Instance.new("Player").Kick, function() return end) end)
end

-- ==========================================
-- 2. GUI CONFIG & BUILDER
-- ==========================================
_G.SpamText = "Haha Hub :) is DOMINATING THIS SERVER!"
_G.SavedSkyPos = nil
_G.SkyBasePart = nil
_G.SkyCampHeight = 40
_G.WalkSpeedValue = 100
_G.FOVSize = 100
_G.OrigC0 = nil
_G.BindingTarget = nil
_G.AimPart = "Head"
_G.MagnetPart = "Head"

local Features = {
    KillAura = false, AimLock = false, WallCheck = true, GunMod = false, FastReload = false, Magnet = false, Hitbox = false,
    SpeedHackWS = false, SpeedHackCF = false, Noclip = false, InfJump = false, Spinbot = false, Fly = false,
    ClickTP = false, BringEnemies = false, SkyCamp = false, 
    ESP = false, ESPBox = true, ESPName = true, ESPDistance = true, ESPHealth = true, ESPTracer = false,
    Fullbright = false, NoFog = false, Chams = false, ShowFOV = false, HidePlayer = false,
    SpamChat = false, AutoRespawn = false, VoidImmune = false, Invisible = false, InstantGet = false, GodMode = false
}

local Keybinds = { SkyCamp = Enum.KeyCode.Z, TpToClosest = Enum.KeyCode.X }
local VisualCallbacks = {}
local ActionCallbacks = {}
local MagnetLimit = 6
local BaseHeadSizeV = Vector3.new(1.2, 1.2, 1.2)
local HitboxSize = 15

local ProtectGui = gethui and gethui() or game:GetService("CoreGui") or LocalPlayer:WaitForChild("PlayerGui")
for _, gui in ipairs(ProtectGui:GetChildren()) do
    if string.find(gui.Name, "HahaHub") then gui:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HahaHub_v1"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = ProtectGui

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 480)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -240)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)
local MainStroke = Instance.new("UIStroke", MainFrame)
MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
MainStroke.Color = Color3.fromRGB(0, 255, 200)
MainStroke.Thickness = 2.5

local Sidebar = Instance.new("Frame", MainFrame)
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 16, 20)
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

local TitleText = Instance.new("TextLabel", Sidebar)
TitleText.Size = UDim2.new(1, 0, 0, 45)
TitleText.Text = "Haha Hub :)"
TitleText.TextColor3 = Color3.fromRGB(0, 255, 200)
TitleText.TextSize = 20
TitleText.Font = Enum.Font.GothamBlack
TitleText.BackgroundTransparency = 1

local InsertHint = Instance.new("TextLabel", Sidebar)
InsertHint.Size = UDim2.new(1, 0, 0, 30)
InsertHint.Position = UDim2.new(0, 0, 1, -35)
InsertHint.BackgroundTransparency = 1
InsertHint.Text = "[INSERT] Hide Menu\nClick [-] to Bind Key"
InsertHint.TextColor3 = Color3.fromRGB(150, 150, 150)
InsertHint.Font = Enum.Font.Gotham
InsertHint.TextSize = 10

local ContentFrame = Instance.new("ScrollingFrame", MainFrame)
ContentFrame.Size = UDim2.new(1, -155, 1, -20)
ContentFrame.Position = UDim2.new(0, 148, 0, 10)
ContentFrame.BackgroundTransparency = 1
ContentFrame.BorderSizePixel = 0
ContentFrame.ScrollBarThickness = 4
ContentFrame.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 200)

local ListLayout = Instance.new("UIListLayout", ContentFrame)
ListLayout.Padding = UDim.new(0, 8)

local function ClearContent()
    for _, child in pairs(ContentFrame:GetChildren()) do
        if child:IsA("GuiObject") and not child:IsA("UIListLayout") then child:Destroy() end
    end
end

local function SendNotification(msg)
    pcall(function() Services.StarterGui:SetCore("SendNotification", { Title = "Haha Hub :)"; Text = msg; Duration = 2; }) end)
end

-- ==========================================
-- 3. MOUSE TRACKING & TARGETING
-- ==========================================
local isShooting = false
InputService.InputBegan:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
        isShooting = true
    end
end)
InputService.InputEnded:Connect(function(input, processed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
        isShooting = false
    end
end)

local function GetScreenCenter()
    local inset = GuiService:GetGuiInset()
    return Vector2.new(Camera.ViewportSize.X / 2, (Camera.ViewportSize.Y / 2) + inset.Y)
end

local function WorldToScreenDrawing(pos3D)
    local pos, onScreen = Camera:WorldToViewportPoint(pos3D)
    local inset = GuiService:GetGuiInset()
    return Vector2.new(pos.X, pos.Y + inset.Y), onScreen, pos.Z
end

local function UniversalClick()
    task.spawn(function()
        pcall(function()
            if not MenuOpen then
                local vim = game:GetService("VirtualInputManager")
                if vim then
                    vim:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, true, game, 1)
                    task.wait(0.01)
                    vim:SendMouseButtonEvent(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2, 0, false, game, 1)
                end
                if type(mouse1click) == "function" then mouse1click() end
            end
            local t = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if t then t:Activate() task.wait(0.01) t:Deactivate() end
        end)
    end)
end

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

local function CheckVisibility(part)
    if not part then return false end
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    local dir = part.Position - Camera.CFrame.Position
    local result = Workspace:Raycast(Camera.CFrame.Position, dir, rayParams)
    
    if result then
        return result.Instance:IsDescendantOf(part.Parent)
    end
    return true
end

local function GetClosestScreen()
    local closest = nil
    local minDist = _G.FOVSize or 100
    local center = GetScreenCenter()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and IsEnemy(p.Character) then
                local targetPart = p.Character:FindFirstChild(_G.AimPart or "Head") or p.Character.HumanoidRootPart
                
                local isVisible = true
                if Features.WallCheck then
                    isVisible = CheckVisibility(targetPart)
                end
                
                if isVisible then
                    local pos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                    if onScreen and pos.Z > 0 then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < minDist then 
                            minDist = dist
                            closest = p.Character 
                        end
                    end
                end
            end
        end
    end
    return closest
end

local function GetClosest3D()
    local closest = nil
    local minDist = math.huge
    local char = LocalPlayer.Character
    local myRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end

    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and IsEnemy(p.Character) then
                local dist = (p.Character.HumanoidRootPart.Position - myRoot.Position).Magnitude
                if dist < minDist then
                    minDist = dist
                    closest = p.Character
                end
            end
        end
    end
    return closest
end

local function ToggleSkyCamp(state)
    local char = LocalPlayer.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if state then
        if root then
            if not _G.SavedSkyPos then _G.SavedSkyPos = root.CFrame end
            local skyPos = _G.SavedSkyPos.Position + Vector3.new(0, _G.SkyCampHeight, 0)
            if not _G.SkyBasePart or not _G.SkyBasePart.Parent then
                _G.SkyBasePart = Instance.new("Part")
                _G.SkyBasePart.Name = "DeathSkyBase" 
                _G.SkyBasePart.Size = Vector3.new(20000, 1, 20000)
                _G.SkyBasePart.Anchored = true
                pcall(function() _G.SkyBasePart.CanQuery = false end)
                _G.SkyBasePart.Transparency = 0.7
                _G.SkyBasePart.Material = Enum.Material.SmoothPlastic
                _G.SkyBasePart.Color = Color3.fromRGB(0, 255, 200)
            end
            _G.SkyBasePart.Parent = char
            _G.SkyBasePart.Position = skyPos
            root.Velocity = Vector3.zero
            root.CFrame = CFrame.new(skyPos + Vector3.new(0, 4, 0))
            SendNotification("☁️ SKY CAMP ENABLED (".._G.SkyCampHeight.."m)")
        end
    else
        if root and _G.SavedSkyPos then
            root.Velocity = Vector3.zero
            root.CFrame = _G.SavedSkyPos
            _G.SavedSkyPos = nil
        end
        if _G.SkyBasePart then _G.SkyBasePart:Destroy(); _G.SkyBasePart = nil end
        SendNotification("☁️ SKY CAMP DISABLED")
    end
end

-- ==========================================
-- 4. SMART UI BUILDER 
-- ==========================================
local function CreateToggleWithBind(text, key, callback)
    local Container = Instance.new("Frame", ContentFrame)
    Container.Size = UDim2.new(1, -10, 0, 35)
    Container.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, -65, 1, 0)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local BindBtn = Instance.new("TextButton", Container)
    BindBtn.Size = UDim2.new(0, 60, 1, 0)
    BindBtn.Position = UDim2.new(1, -60, 0, 0)
    BindBtn.Font = Enum.Font.Gotham
    BindBtn.TextSize = 10
    BindBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    BindBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)

    local function UpdateVisuals()
        if Features[key] then
            Btn.Text = ">> " .. text .. " <<"
            Btn.TextColor3 = Color3.fromRGB(20, 20, 25)
            Btn.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
        else
            Btn.Text = "[ OFF ]  " .. text
            Btn.TextColor3 = Color3.fromRGB(180, 180, 180)
            Btn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
        end
        local currentKey = Keybinds[key]
        BindBtn.Text = currentKey and "["..currentKey.Name.."]" or "[ - ]"
    end

    VisualCallbacks[key] = UpdateVisuals
    UpdateVisuals()

    Btn.MouseButton1Click:Connect(function()
        Features[key] = not Features[key]
        UpdateVisuals()
        if callback then callback(Features[key]) end
        if key == "Invisible" and _G.ToggleGhostMode then _G.ToggleGhostMode(Features[key]) end
        if key == "SkyCamp" then ToggleSkyCamp(Features[key]) end
    end)

    BindBtn.MouseButton1Click:Connect(function()
        BindBtn.Text = "[ ... ]"
        _G.BindingTarget = key
    end)
end

local function CreateActionBtnWithBind(text, actionName, callback, isRage)
    local Container = Instance.new("Frame", ContentFrame)
    Container.Size = UDim2.new(1, -10, 0, 35)
    Container.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, -65, 1, 0)
    Btn.Font = Enum.Font.GothamBlack
    Btn.TextSize = 12
    Btn.Text = text
    Btn.TextColor3 = isRage and Color3.fromRGB(20, 20, 25) or Color3.fromRGB(255, 255, 255)
    Btn.BackgroundColor3 = isRage and Color3.fromRGB(0, 255, 200) or Color3.fromRGB(50, 50, 60)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local BindBtn = Instance.new("TextButton", Container)
    BindBtn.Size = UDim2.new(0, 60, 1, 0)
    BindBtn.Position = UDim2.new(1, -60, 0, 0)
    BindBtn.Font = Enum.Font.Gotham
    BindBtn.TextSize = 10
    BindBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    BindBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 6)

    local function UpdateBindVisual()
        local currentKey = Keybinds[actionName]
        BindBtn.Text = currentKey and "["..currentKey.Name.."]" or "[ - ]"
    end
    VisualCallbacks[actionName] = UpdateBindVisual
    UpdateBindVisual()
    ActionCallbacks[actionName] = callback

    Btn.MouseButton1Click:Connect(callback)
    BindBtn.MouseButton1Click:Connect(function()
        BindBtn.Text = "[ ... ]"
        _G.BindingTarget = actionName
    end)
end

local function CreateCycleButton(text, options, defaultIndex, callback)
    local Container = Instance.new("Frame", ContentFrame)
    Container.Size = UDim2.new(1, -10, 0, 35)
    Container.BackgroundTransparency = 1

    local Btn = Instance.new("TextButton", Container)
    Btn.Size = UDim2.new(1, -10, 1, 0)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 11
    Btn.BackgroundColor3 = Color3.fromRGB(40, 42, 50)
    Btn.TextColor3 = Color3.fromRGB(0, 255, 200)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local currentIndex = defaultIndex
    Btn.Text = "[ " .. options[currentIndex] .. " ]  " .. text

    Btn.MouseButton1Click:Connect(function()
        currentIndex = currentIndex + 1
        if currentIndex > #options then currentIndex = 1 end
        Btn.Text = "[ " .. options[currentIndex] .. " ]  " .. text
        if callback then callback(options[currentIndex]) end
    end)
    if callback then callback(options[currentIndex]) end
end

local function CreateTextBox(placeholder)
    local Box = Instance.new("TextBox", ContentFrame)
    Box.Size = UDim2.new(1, -10, 0, 35)
    Box.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 12
    Box.PlaceholderText = placeholder
    Box.Text = _G.SpamText
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 6)
    Box.FocusLost:Connect(function() _G.SpamText = Box.Text end)
end

local function CreateSlider(text, min, max, step, default, callback)
    local F = Instance.new("Frame", ContentFrame)
    F.Size = UDim2.new(1, -10, 0, 45)
    F.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    Instance.new("UICorner", F).CornerRadius = UDim.new(0, 6)

    local L = Instance.new("TextLabel", F)
    L.Size = UDim2.new(1, -10, 0, 20)
    L.Position = UDim2.new(0, 10, 0, 5)
    L.BackgroundTransparency = 1
    if text == "SPEED VALUE" then L.Text = text .. ": " .. default elseif text == "FOV SIZE" then L.Text = text .. ": " .. default else L.Text = text .. ": " .. default .. "m" end
    L.TextColor3 = Color3.fromRGB(200, 200, 200)
    L.Font = Enum.Font.GothamBold
    L.TextSize = 12
    L.TextXAlignment = Enum.TextXAlignment.Left

    local Track = Instance.new("TextButton", F)
    Track.Size = UDim2.new(1, -20, 0, 8)
    Track.Position = UDim2.new(0, 10, 0, 28)
    Track.BackgroundColor3 = Color3.fromRGB(50, 52, 60)
    Track.Text = ""
    Instance.new("UICorner", Track).CornerRadius = UDim.new(1, 0)

    local Fill = Instance.new("Frame", Track)
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 255, 200)
    Instance.new("UICorner", Fill).CornerRadius = UDim.new(1, 0)

    local dragging = false
    local function Update(input)
        local pos = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + ((max - min) * pos))
        value = math.floor(value / step + 0.5) * step
        Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
        if text == "SPEED VALUE" then L.Text = text .. ": " .. value elseif text == "FOV SIZE" then L.Text = text .. ": " .. value else L.Text = text .. ": " .. value .. "m" end
        callback(value)
    end

    Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; Update(input) end
    end)
    InputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end)
    InputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
    end)
end

-- ==========================================
-- 5. TAB RENDERING
-- ==========================================
local RenderTab
RenderTab = function(tabName)
    ClearContent()
    if tabName == "Combat" then
        CreateActionBtnWithBind("🔥 BRUTAL MODE 🔥", "RageMode", function()
            local rageList = {"ESP", "ESPBox", "ESPName", "ESPHealth", "ESPDistance", "ESPTracer", "Chams", "Magnet", "AimLock", "ShowFOV"}
            for _, v in ipairs(rageList) do 
                if Features[v] ~= nil then Features[v] = true end
                if VisualCallbacks[v] then VisualCallbacks[v]() end
            end
            _G.AimPart = "Head"
            _G.MagnetPart = "Head"
            SendNotification("BRUTAL MODE ACTIVATED!")
        end, true)
        
        CreateToggleWithBind("WALL CHECK (Visible Only)", "WallCheck")
        CreateToggleWithBind("AIMLOCK", "AimLock")
        CreateCycleButton("AIMLOCK TARGET", {"HEAD", "BODY"}, 1, function(val)
            _G.AimPart = (val == "HEAD") and "Head" or "HumanoidRootPart"
        end)
        
        CreateToggleWithBind("MAGNET", "Magnet")
        CreateCycleButton("MAGNET TARGET", {"HEAD", "BODY"}, 1, function(val)
            _G.MagnetPart = (val == "HEAD") and "Head" or "HumanoidRootPart"
        end)
        
        CreateToggleWithBind("KILL AURA", "KillAura")
        CreateToggleWithBind("HEAD HITBOX", "Hitbox")
        CreateToggleWithBind("GUN MOD", "GunMod")
        CreateToggleWithBind("FAST RELOAD", "FastReload")
    elseif tabName == "Movement" then
        CreateToggleWithBind("SPEEDHACK (WalkSpeed)", "SpeedHackWS", function(state)
            if not state and LocalPlayer.Character then
                local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = 16 end
            end
        end)
        CreateToggleWithBind("SPEEDHACK (CFrame/Bypass)", "SpeedHackCF")
        CreateSlider("SPEED VALUE", 16, 300, 5, _G.WalkSpeedValue, function(val) _G.WalkSpeedValue = val end)
        CreateToggleWithBind("OMNI MATRIX SPINBOT", "Spinbot")
        CreateToggleWithBind("INFINITE JUMP", "InfJump")
        CreateToggleWithBind("NOCLIP", "Noclip")
        CreateToggleWithBind("UNIVERSAL FLY", "Fly")
    elseif tabName == "Teleport" then
        CreateToggleWithBind("☁️ SKY CAMP / OVERWATCH ☁️", "SkyCamp")
        CreateSlider("SKY CAMP HEIGHT", 10, 500, 10, _G.SkyCampHeight, function(val)
            _G.SkyCampHeight = val
            if Features.SkyCamp and _G.SavedSkyPos and _G.SkyBasePart then
                local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local skyPos = _G.SavedSkyPos.Position + Vector3.new(0, val, 0)
                    _G.SkyBasePart.Position = skyPos
                    root.Velocity = Vector3.zero
                    root.CFrame = CFrame.new(skyPos + Vector3.new(0, 4, 0))
                end
            end
        end)
        
        CreateActionBtnWithBind("TP TO CLOSEST", "TpToClosest", function()
            local Target = GetClosest3D()
            local char = LocalPlayer.Character
            if Target and char and char:FindFirstChild("HumanoidRootPart") then
                if Features.SkyCamp then
                    Features.SkyCamp = false
                    _G.SavedSkyPos = nil
                    ToggleSkyCamp(false)
                    if VisualCallbacks["SkyCamp"] then VisualCallbacks["SkyCamp"]() end
                end
                char.HumanoidRootPart.CFrame = Target.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
                SendNotification("Teleported to Target!")
            else
                SendNotification("No Target Found!")
            end
        end, false)
        
        CreateToggleWithBind("CLICK TP (Ctrl + Click)", "ClickTP")
        CreateToggleWithBind("BRING ENEMIES", "BringEnemies")
    elseif tabName == "Visuals" then
        CreateToggleWithBind("SHOW AIM FOV", "ShowFOV")
        CreateSlider("FOV SIZE", 10, 500, 10, _G.FOVSize, function(val) _G.FOVSize = val end)
        CreateToggleWithBind("HIDE BODY", "HidePlayer")
        CreateToggleWithBind("ESP MASTER SWITCH", "ESP")
        CreateToggleWithBind("ESP BOX", "ESPBox")
        CreateToggleWithBind("ESP NAME", "ESPName")
        CreateToggleWithBind("ESP DISTANCE", "ESPDistance")
        CreateToggleWithBind("ESP HEALTH BAR", "ESPHealth")
        CreateToggleWithBind("ESP TRACERS", "ESPTracer")
        CreateToggleWithBind("CHAMS", "Chams")
        CreateToggleWithBind("FULLBRIGHT", "Fullbright")
        CreateToggleWithBind("NO FOG", "NoFog")
    elseif tabName == "Exploits" then
        CreateToggleWithBind("GOD MODE", "GodMode")
        CreateToggleWithBind("VOID IMMUNE", "VoidImmune", function(state)
            if not state and Workspace:FindFirstChild("DeathAntiVoidNet") then Workspace.DeathAntiVoidNet:Destroy() end
        end)
        CreateToggleWithBind("INSTANT GET", "InstantGet")
        CreateToggleWithBind("GHOST MODE", "Invisible")
        CreateActionBtnWithBind("FPS BOOSTER", "FpsBooster", function()
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
        CreateToggleWithBind("CHAT SPAMMER", "SpamChat")
        CreateTextBox("Type your spam text here...")
        CreateToggleWithBind("AUTO RESPAWN", "AutoRespawn")
    end
    task.wait(0.05)
    ContentFrame.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y + 20)
end

local function CreateTabButton(name, layoutOrder)
    local TabBtn = Instance.new("TextButton", Sidebar)
    TabBtn.Size = UDim2.new(1, -10, 0, 35)
    TabBtn.Position = UDim2.new(0, 5, 0, 50 + (layoutOrder * 42))
    TabBtn.BackgroundColor3 = Color3.fromRGB(30, 32, 40)
    TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    TabBtn.Text = name
    TabBtn.Font = Enum.Font.GothamBold
    TabBtn.MouseButton1Click:Connect(function() RenderTab(name) end)
end

CreateTabButton("Combat", 0)
CreateTabButton("Movement", 1)
CreateTabButton("Teleport", 2)
CreateTabButton("Visuals", 3)
CreateTabButton("Exploits", 4)
RenderTab("Combat")

-- ==========================================
-- 6. KEYBIND LISTENER
-- ==========================================
InputService.InputBegan:Connect(function(input, processed)
    if _G.BindingTarget and input.UserInputType == Enum.UserInputType.Keyboard then
        local key = input.KeyCode
        if key == Enum.KeyCode.Escape or key == Enum.KeyCode.Backspace then
            Keybinds[_G.BindingTarget] = nil
        else
            for k, v in pairs(Keybinds) do
                if v == key then Keybinds[k] = nil end
            end
            Keybinds[_G.BindingTarget] = key
        end
        
        for _, cb in pairs(VisualCallbacks) do cb() end 
        _G.BindingTarget = nil
        return
    end

    if processed then return end

    if input.UserInputType == Enum.UserInputType.Keyboard then
        if input.KeyCode == Enum.KeyCode.Insert then
            MenuOpen = not MenuOpen
            MainFrame.Visible = MenuOpen
        end

        for actionKey, keycode in pairs(Keybinds) do
            if input.KeyCode == keycode then
                if Features[actionKey] ~= nil then 
                    Features[actionKey] = not Features[actionKey]
                    if VisualCallbacks[actionKey] then VisualCallbacks[actionKey]() end
                    if actionKey == "Invisible" and _G.ToggleGhostMode then _G.ToggleGhostMode(Features[actionKey]) end
                    if actionKey == "SkyCamp" then ToggleSkyCamp(Features[actionKey]) end
                elseif ActionCallbacks[actionKey] then 
                    ActionCallbacks[actionKey]()
                end
            end
        end
    end

    if Features.ClickTP and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2) and InputService:IsKeyDown(Enum.KeyCode.LeftControl) then
        local Mouse = LocalPlayer:GetMouse()
        if Mouse.Target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(Mouse.Hit.p + Vector3.new(0, 3, 0))
        end
    end
end)

-- ==========================================
-- 7. EVENT LOOPS (NOCLIP, GHOST)
-- ==========================================
ProximityPromptService.PromptShown:Connect(function(prompt)
    if Features.InstantGet then prompt.HoldDuration = 0 end
end)

RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if Features.Noclip and char then
        for _, part in pairs(char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "DeathSkyBase" then 
                part.CanCollide = false 
            end
        end
    end
end)

local isGhosting = false
local EXCLUDE_NAMES = { ["HumanoidRootPart"] = true, ["CollisionPart"] = true }

_G.ToggleGhostMode = function(state)
    Features.Invisible = state
    local char = LocalPlayer.Character
    if char then
        for _, part in pairs(char:GetDescendants()) do
            if part:IsA("BasePart") and not EXCLUDE_NAMES[part.Name] then
                part.Transparency = state and 0.7 or 0
            end
        end
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    Features.SkyCamp = false
    _G.SavedSkyPos = nil
    _G.OrigC0 = nil
    
    isGhosting = false
    if _G.SkyBasePart then _G.SkyBasePart:Destroy(); _G.SkyBasePart = nil end

    if Features.Invisible then
        task.wait(0.5)
        _G.ToggleGhostMode(true)
    end

    local hum = char:WaitForChild("Humanoid", 5)
    if hum then
        hum.Died:Connect(function()
            if Features.AutoRespawn then
                task.wait(0.5) 
                game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("!respawn", "All")
            end
        end)
    end
end)

InputService.JumpRequest:Connect(function()
    if Features.InfJump and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState("Jumping") end
    end
end)

RunService.Heartbeat:Connect(function()
    if not Features.Invisible or isGhosting then return end
    
    local char = LocalPlayer.Character
    local rootPart = char and char:FindFirstChild("HumanoidRootPart")
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    
    if char and rootPart and humanoid and humanoid.Health > 0 then
        isGhosting = true
        local cf = rootPart.CFrame
        local camOffset = humanoid.CameraOffset
        local hidden = cf * CFrame.new(0, -200000, 0)
        
        rootPart.CFrame = hidden
        humanoid.CameraOffset = hidden:ToObjectSpace(CFrame.new(cf.Position)).Position
        
        RunService.RenderStepped:Wait()
        
        rootPart.CFrame = cf
        humanoid.CameraOffset = camOffset
        isGhosting = false
    end
end)

-- ==========================================
-- 8. DRAWING API ESP (ĐỘC LẬP & PCALL AN TOÀN)
-- ==========================================
local function InitESP(c)
    if not HAS_DRAWING then return end
    if ESPData[c] then return end
    local p = Players:GetPlayerFromCharacter(c)
    ESPData[c] = {
        Box = Drawing.new("Square"),
        Tracer = Drawing.new("Line"),
        Name = Drawing.new("Text"),
        Distance = Drawing.new("Text"),
        HealthBg = Drawing.new("Line"),
        HealthVal = Drawing.new("Line"),
        DisplayName = p and p.Name or c.Name
    }
    local d = ESPData[c]
    d.Box.Thickness = 1; d.Box.Filled = false; d.Tracer.Thickness = 1
    d.Name.Size = 14; d.Name.Center = true; d.Name.Outline = true
    d.Distance.Size = 12; d.Distance.Center = true; d.Distance.Outline = true
    d.HealthBg.Thickness = 3; d.HealthBg.Color = Color3.new(0, 0, 0); d.HealthVal.Thickness = 1
end

local function ClearESP(c)
    if ESPData[c] then
        for _, v in pairs(ESPData[c]) do
            if type(v) ~= "string" and type(v) ~= "boolean" then 
                pcall(function() v.Visible = false; v:Remove() end) 
            end
        end
        ESPData[c] = nil
    end
end

task.spawn(function()
    while task.wait(1) do
        if HAS_DRAWING then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    if not ESPData[p.Character] then InitESP(p.Character) end
                end
            end
        end
    end
end)

RunService.RenderStepped:Connect(function()
    local center = GetScreenCenter()
    local topScreen = Vector2.new(center.X, 0)
    local Char = LocalPlayer.Character
    
    if HAS_DRAWING and FOVCircle then
        if Features.ShowFOV then
            FOVCircle.Position = center
            FOVCircle.Radius = _G.FOVSize
            FOVCircle.Visible = true
        else
            FOVCircle.Visible = false
        end
        
        pcall(function()
            for c, o in pairs(ESPData) do
                local h = c:FindFirstChildOfClass("Humanoid")
                local rt = c:FindFirstChild("HumanoidRootPart")
                
                if not c.Parent or not h or h.Health <= 0 then
                    ClearESP(c)
                    continue
                end

                if Features.ESP and rt and IsEnemy(c) then
                    local p = Players:GetPlayerFromCharacter(c)
                    if p and p ~= LocalPlayer then
                        local top3D = rt.Position + Vector3.new(0, 2.5, 0)
                        local bot3D = rt.Position - Vector3.new(0, 3.5, 0)
                        
                        local topPos, onScreen, z = WorldToScreenDrawing(top3D)
                        local botPos = WorldToScreenDrawing(bot3D)
                        local dist = (Camera.CFrame.Position - rt.Position).Magnitude

                        if onScreen and z > 0 and dist < 1500 then
                            local height = math.clamp(math.abs(topPos.Y - botPos.Y), 5, 2000)
                            local width = height * 0.55
                            local tl = Vector2.new(topPos.X - width/2, topPos.Y)
                            local br = Vector2.new(topPos.X + width/2, botPos.Y)

                            if Features.ESPBox then o.Box.Visible = true; o.Box.Size = Vector2.new(width, height); o.Box.Position = tl; o.Box.Color = Color3.fromRGB(0, 255, 200) else o.Box.Visible = false end
                            if Features.ESPName then o.Name.Visible = true; o.Name.Text = o.DisplayName; o.Name.Position = Vector2.new(topPos.X, topPos.Y - 18); o.Name.Color = Color3.new(1, 1, 1) else o.Name.Visible = false end
                            if Features.ESPDistance then o.Distance.Visible = true; o.Distance.Text = math.floor(dist) .. "m"; o.Distance.Position = Vector2.new(topPos.X, botPos.Y + 4); o.Distance.Color = Color3.new(1, 1, 1) else o.Distance.Visible = false end

                            if Features.ESPHealth then
                                local hpct = math.clamp(h.Health / h.MaxHealth, 0, 1)
                                o.HealthBg.Visible = true; o.HealthBg.From = Vector2.new(tl.X - 5, tl.Y); o.HealthBg.To = Vector2.new(tl.X - 5, br.Y)
                                o.HealthVal.Visible = true; o.HealthVal.From = Vector2.new(tl.X - 5, br.Y); o.HealthVal.To = Vector2.new(tl.X - 5, br.Y - (height * hpct)); o.HealthVal.Color = Color3.fromHSV(hpct * 0.3, 1, 1)
                            else
                                o.HealthBg.Visible = false; o.HealthVal.Visible = false
                            end

                            if Features.ESPTracer then o.Tracer.Visible = true; o.Tracer.From = topScreen; o.Tracer.To = Vector2.new(topPos.X, topPos.Y); o.Tracer.Color = Color3.fromRGB(0, 255, 200) else o.Tracer.Visible = false end
                        else
                            o.Box.Visible = false; o.Name.Visible = false; o.Distance.Visible = false; o.HealthBg.Visible = false; o.HealthVal.Visible = false; o.Tracer.Visible = false
                        end
                    end
                else
                    o.Box.Visible = false; o.Name.Visible = false; o.Distance.Visible = false; o.HealthBg.Visible = false; o.HealthVal.Visible = false; o.Tracer.Visible = false
                end
            end
        end)
    end
    
    if Char then
        local shouldHide = Features.HidePlayer and Features.Spinbot
        for _, part in pairs(Char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "DeathSkyBase" then
                part.LocalTransparencyModifier = shouldHide and 1 or 0
            elseif part:IsA("Decal") or part:IsA("Texture") then
                part.LocalTransparencyModifier = shouldHide and 1 or 0
            end
        end
    end
end)

-- ==========================================
-- 9. CAMERA AIMLOCK 
-- ==========================================
RunService.RenderStepped:Connect(function()
    local Target = GetClosestScreen()
    
    if Target and Features.AimLock and isShooting then
        local aimTargetPart = Target:FindFirstChild(_G.AimPart or "Head")
        if aimTargetPart then
            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, aimTargetPart.Position)
        end
    end
end)

-- ==========================================
-- 10. HEARTBEAT: PHYSICS, AIM 3D ALIGN & MAGNET ANTI-WALL
-- ==========================================
RunService.Heartbeat:Connect(function()
    local Char = LocalPlayer.Character
    local Root = Char and Char:FindFirstChild("HumanoidRootPart")
    local Hum = Char and Char:FindFirstChildOfClass("Humanoid")
    local rootJoint = Char and (Char:FindFirstChild("LowerTorso") and Char.LowerTorso:FindFirstChild("Root") or Root and Root:FindFirstChild("RootJoint"))
    local Target = GetClosestScreen()

    local pauseSpin = Features.AimLock and isShooting and Target ~= nil

    -- [AIM 3D: CƠ THỂ HƯỚNG THEO CAMERA]
    if pauseSpin and Root and Hum then
        local aimTargetPart = Target:FindFirstChild(_G.AimPart or "Head")
        if aimTargetPart then
            Hum.AutoRotate = false 
            Root.CFrame = CFrame.lookAt(Root.Position, aimTargetPart.Position)
        end
    elseif Hum then
        Hum.AutoRotate = true
    end

    -- [MAGNET BÙ ĐẠN - ANTI-WALL CLIP]
    if Features.Magnet and isShooting and Target then
        local magTargetPart = Target:FindFirstChild(_G.MagnetPart or "HumanoidRootPart")
        local targetRoot = Target:FindFirstChild("HumanoidRootPart")
        
        if magTargetPart and targetRoot then
            local camPos = Camera.CFrame.Position
            local lookVec = Camera.CFrame.LookVector
            
            local projectionDistance = (magTargetPart.Position - camPos):Dot(lookVec)
            if projectionDistance < 10 then projectionDistance = 10 end
            
            -- CHỐNG KẸT TƯỜNG (RAYCAST)
            local rayParams = RaycastParams.new()
            rayParams.FilterType = Enum.RaycastFilterType.Blacklist
            rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Target, Camera}
            
            local wallCheckRay = Workspace:Raycast(camPos, lookVec * projectionDistance, rayParams)
            if wallCheckRay then
                -- Nếu đụng tường, lôi địch ra đứng ngay trước mặt tường 2 studs
                projectionDistance = (wallCheckRay.Position - camPos).Magnitude - 2
                if projectionDistance < 5 then projectionDistance = 5 end
            end
            
            local pointOnRay = camPos + (lookVec * projectionDistance)
            
            local dropOffset = Vector3.new(0, 0, 0)
            if _G.MagnetPart == "Head" then
                dropOffset = Vector3.new(0, -1.35, 0)
            end
            
            local targetPos = pointOnRay + dropOffset
            local diff = targetPos - magTargetPart.Position
            
            if diff.Magnitude > MagnetLimit then 
                diff = diff.Unit * MagnetLimit 
            end
            
            targetRoot.Velocity = Vector3.zero
            targetRoot.CFrame = targetRoot.CFrame + diff
            
            for _, part in pairs(Target:GetChildren()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end
    end

    -- [OMNI MATRIX SPINBOT]
    if Features.Spinbot and rootJoint and Root then
        if not _G.OrigC0 then _G.OrigC0 = rootJoint.C0 end
        
        if pauseSpin then
            rootJoint.C0 = _G.OrigC0
        else
            local t = tick() * 25 
            local radius = 2 
            local offsetX = math.cos(t) * radius
            local offsetZ = math.sin(t) * radius
            local offsetY = 1.2 + math.sin(t * 0.5) * 1.5 
            
            local spinX = (tick() * 1200) % (math.pi * 2) 
            local spinY = (tick() * 4000) % (math.pi * 2) 
            local spinZ = (tick() * 1500) % (math.pi * 2) 
            
            rootJoint.C0 = _G.OrigC0 * CFrame.new(offsetX, offsetY, offsetZ) * CFrame.Angles(spinX, spinY, spinZ)
        end
        
        for _, part in pairs(Char:GetChildren()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "DeathSkyBase" then
                part.CanCollide = false
            end
        end
    else
        if _G.OrigC0 and rootJoint then 
            rootJoint.C0 = _G.OrigC0
            _G.OrigC0 = nil 
            if not Features.Noclip and Char then
                for _, part in pairs(Char:GetChildren()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "DeathSkyBase" then
                        part.CanCollide = true
                    end
                end
            end
        end
    end

    -- [SPEEDHACK & FLY]
    if Features.GodMode and Hum then
        pcall(function()
            if Hum.MaxHealth < math.huge then Hum.MaxHealth = math.huge end
            if Hum.Health < math.huge then Hum.Health = math.huge end
        end)
    end

    if Features.SpeedHackWS and Hum then Hum.WalkSpeed = _G.WalkSpeedValue end
    
    if Features.SpeedHackCF and Hum and Root then 
        local moveDir = Hum.MoveDirection
        if moveDir.Magnitude > 0 then
            local cfMultiplier = _G.WalkSpeedValue / 80
            Root.CFrame = Root.CFrame + (moveDir * cfMultiplier)
        end
    end

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
    
    if Features.BringEnemies and Root then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and IsEnemy(p.Character) then
                local eRoot = p.Character.HumanoidRootPart
                eRoot.CFrame = Root.CFrame * CFrame.new(0, 0, -3)
                eRoot.Velocity = Vector3.zero 
                for _, part in pairs(p.Character:GetChildren()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end
    end
    
    if Features.VoidImmune and Root then
        local voidHeight = Workspace.FallenPartsDestroyHeight + 25
        if not Workspace:FindFirstChild("DeathAntiVoidNet") then
            local Net = Instance.new("Part")
            Net.Name = "DeathAntiVoidNet"
            Net.Size = Vector3.new(20000, 2, 20000)
            Net.Position = Vector3.new(0, voidHeight, 0)
            Net.Anchored = true; Net.CanCollide = false
            Net.Transparency = 0.6; Net.Color = Color3.fromRGB(0, 255, 200); Net.Material = Enum.Material.ForceField
            Net.Parent = Workspace
        end
        if Root.Position.Y < voidHeight then
            Root.Velocity = Vector3.zero
            Root.CFrame = CFrame.new(Root.Position.X, Root.Position.Y + 150, Root.Position.Z)
        end
    end
end)

-- ==========================================
-- 11. LOW FREQUENCY LOOPS (SAVE 60% CPU)
-- ==========================================
local lastSpam = 0
task.spawn(function()
    while task.wait(1) do
        local Char = LocalPlayer.Character
        -- TÍNH NĂNG FAST RELOAD BYPASS ANTI-CHEAT
        if Char and (Features.GunMod or Features.FastReload) then
            local Tool = Char:FindFirstChildOfClass("Tool")
            if Tool then
                for _, v in pairs(Tool:GetDescendants()) do
                    if v:IsA("NumberValue") or v:IsA("IntValue") then
                        local name = v.Name:lower()
                        if Features.GunMod and (name:find("recoil") or name:find("spread") or name:find("accuracy")) then 
                            if v:IsA("NumberValue") or v:IsA("IntValue") then v.Value = 0 end
                        end
                        if Features.FastReload and (name:find("reload") or name:find("loadtime") or name:find("firerate") or name:find("cooldown")) then
                            if v:IsA("NumberValue") then
                                if v.Value > 0.085 then v.Value = 0.085 end -- Giữ ở mức an toàn chống kick
                            elseif v:IsA("IntValue") then
                                v.Value = 0
                            end
                        end
                    end
                end
            end
        end
        
        if Features.Fullbright then
            game:GetService("Lighting").Ambient = Color3.fromRGB(255, 255, 255)
            game:GetService("Lighting").Brightness = 2
        end
        if Features.NoFog then game:GetService("Lighting").FogEnd = 999999 end
        
        if Features.SpamChat and tick() - lastSpam > 2.5 then
            local randomCode = " | ID:" .. tostring(math.random(1000, 9999))
            local bypassMsg = _G.SpamText .. randomCode
            pcall(function() ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest:FireServer(bypassMsg, "All") end)
            pcall(function() TextChatService.TextChannels.RBXGeneral:SendAsync(bypassMsg) end)
            lastSpam = tick()
        end
        
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character then
                local humE = player.Character:FindFirstChildOfClass("Humanoid")
                local headE = player.Character:FindFirstChild("Head")
                if humE and headE and humE.Health > 0 and IsEnemy(player.Character) then
                    if Features.Hitbox then
                        headE.Size = Vector3.new(HitboxSize, HitboxSize, HitboxSize)
                        headE.Transparency = 0.6; headE.Massless = true; headE.CanCollide = false
                        headE.CustomPhysicalProperties = PhysicalProperties.new(0,0,0,0,0)
                    else
                        if headE.Size.X > 5 then 
                            headE.Size = BaseHeadSizeV; headE.Transparency = 0; headE.CustomPhysicalProperties = nil 
                        end
                    end
                    
                    if Features.Chams then
                        if not player.Character:FindFirstChild("DeathChams") then
                            local Highlight = Instance.new("Highlight")
                            Highlight.Name = "DeathChams"
                            Highlight.FillColor = Color3.fromRGB(0, 255, 200) 
                            Highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
                            Highlight.FillTransparency = 0.5 
                            Highlight.OutlineTransparency = 0
                            Highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                            Highlight.Parent = player.Character
                        end
                    else
                        local cham = player.Character:FindFirstChild("DeathChams")
                        if cham then cham:Destroy() end
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- 12. THROTTLED KILL AURA
-- ==========================================
task.spawn(function()
    while task.wait(0.1) do
        if Features.KillAura then
            local Char = LocalPlayer.Character
            local Root = Char and Char:FindFirstChild("HumanoidRootPart")
            if Root then
                local weapons = {}
                for _, item in ipairs(Char:GetChildren()) do
                    if item:IsA("Tool") and item:FindFirstChild("Handle") then table.insert(weapons, item.Handle) end
                end
                if LocalPlayer:FindFirstChild("Backpack") then
                    for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
                        if item:IsA("Tool") and item:FindFirstChild("Handle") then table.insert(weapons, item.Handle) end
                    end
                end
                
                if #weapons > 0 then
                    for _, targetPlayer in ipairs(Players:GetPlayers()) do
                        if targetPlayer ~= LocalPlayer and targetPlayer.Character then
                            local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                            local hum = targetPlayer.Character:FindFirstChildOfClass("Humanoid")
                            if hrp and hum and hum.Health > 0 and IsEnemy(targetPlayer.Character) and (Root.Position - hrp.Position).Magnitude <= 45 then
                                if type(firetouchinterest) == "function" then
                                    for _, handle in ipairs(weapons) do
                                        firetouchinterest(hrp, handle, 0)
                                        firetouchinterest(hrp, handle, 1)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

print("[Haha Hub :)] Loaded Successfully!")
