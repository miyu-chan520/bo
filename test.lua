-- ==========================================
-- BO HUB v7.0 | NUCLEAR ORIGINAL (-200k Y)
-- Invisible: ĐẨY XUỐNG DƯỚI MAP NHƯ GỐC
-- ==========================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

if CoreGui:FindFirstChild("BOHUB") then CoreGui.BOHUB:Destroy() end
if LocalPlayer.PlayerGui:FindFirstChild("BOGuide") then LocalPlayer.PlayerGui.BOGuide:Destroy() end

local isMobile = UserInputService.TouchEnabled

-- ==========================================
-- 🌈 RAINBOW
-- ==========================================
local function createSmoothRainbow(stroke, speed)
    speed = speed or 0.02
    local colors = {
        Color3.new(1,0,0),Color3.new(1,.5,0),Color3.new(1,1,0),
        Color3.new(0,1,0),Color3.new(0,.5,1),Color3.new(.5,0,1),Color3.new(1,0,1)
    }
    local i=2;j=3;p=0
    task.spawn(function()
        while stroke and stroke.Parent do
            local a=colors[i];local b=colors[j]
            stroke.Color=Color3.new(a.R+(b.R-a.R)*p,a.G+(b.G-a.G)*p,a.B+(b.B-a.B)*p)
            p+=speed;if p>=1 then p=0;i=j;j=i%#colors+1 end
            task.wait(0.016)
        end
    end)
end
local function GetRainbowColor(o)
    local t=(os.clock()+(o or 0))%6/6;local r,g,b
    if t<1/6 then r=1;g=t*6;b=0
    elseif t<2/6 then r=1-(t-1/6)*6;g=1;b=0
    elseif t<3/6 then r=0;g=1;b=(t-2/6)*6
    elseif t<4/6 then r=0;g=1-(t-3/6)*6;b=1
    elseif t<5/6 then r=(t-4/6)*6;g=0;b=1
    else r=1;g=0;b=1-(t-5/6)*6 end
    return Color3.new(r,g,b)
end

-- ==========================================
-- 1. CONFIG
-- ==========================================
local Config = {
    Aim = { Enabled=false, VisibleCheck=true, FOV=100, Mode=2 },
    Magnet = { Enabled=false, Limit=5 },
    ESP = { Box=false,Tracer=false,Name=false,Distance=false,HealthBar=false,ShowFOV=true,Color=Color3.new(1,1,1),Rainbow=false },
    Hitbox = { Enabled=false, Size=15, Mode=1 },
    -- 👻 NUCLEAR ORIGINAL: ĐẨY XUỐNG DƯỚI MAP -200.000
    Invisible = { Enabled=false, TeleportHeight = -200000 },
    RivalFast = false
}

local ESPData={};local AllEntities={}
local LockedTarget,LockedAimPart,ProAimStartTime,ProAimDuration=nil,nil,nil,nil
local MagnetAnchorPos=nil;local MagnetTarget=nil
local character,humanoid,rootPart

local FOVCircle=Drawing.new("Circle");FOVCircle.Thickness=1;FOVCircle.Filled=false
local StatsText=Drawing.new("Text");StatsText.Size=isMobile and 16 or 18;StatsText.Center=true;StatsText.Outline=true;StatsText.Visible=true;StatsText.Color=Color3.new(1,.6,0)

-- ==========================================
-- 👻 INVISIBLE NUCLEARBOBO GỐC (ĐẨY XUỐNG Y)
-- KHÔNG SỬA GÌ, KHÔNG BẢO VỆ, CHỈ NHÁY XUỐNG
-- ==========================================
local function setupCharacter()
    character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    humanoid = character:WaitForChild("Humanoid",10)
    rootPart = character:WaitForChild("HumanoidRootPart",10)
end
setupCharacter()
LocalPlayer.CharacterAdded:Connect(function() Config.Invisible.Enabled=false; task.wait(1); setupCharacter() end)

-- VÒNG LẬP CHÍNH GIỐNG NUCLEARBOBO GỐC
RunService.Heartbeat:Connect(function()
    if Config.Invisible.Enabled and character and rootPart and humanoid then
        local cf = rootPart.CFrame
        -- ✅ ĐẨY THẲNG XUỐNG -200.000 studs (NHƯ GỐC)
        local hidden = cf * CFrame.new(0, Config.Invisible.TeleportHeight, 0)
        
        rootPart.CFrame = hidden
        RunService.RenderStepped:Wait()
        rootPart.CFrame = cf
    end
end)

-- ==========================================
-- 2. SCANNER + LOGIC
-- ==========================================
task.spawn(function()
    while task.wait(1) do
        local t={}
        for _,o in pairs(workspace:GetDescendants()) do
            if o:IsA("Model") and o~=LocalPlayer.Character then
                local h=o:FindFirstChildOfClass("Humanoid");local r=o:FindFirstChild("HumanoidRootPart")
                if h and r and h.Health>0 and h.MaxHealth>0 and not r.Anchored then table.insert(t,o) end
            end
        end
        AllEntities=t
    end
end)
local function IsEnemy(c)
    if c==LocalPlayer.Character then return false end
    local p=Players:GetPlayerFromCharacter(c);if not p then return true end
    local ok,e=pcall(function()
        if p.Neutral and LocalPlayer.Neutral then return true end
        if p.TeamColor and LocalPlayer.TeamColor and p.TeamColor~=LocalPlayer.TeamColor then return true end
        if p.Team and LocalPlayer.Team and p.Team~=LocalPlayer.Team then return true end
        for _,a in pairs({"Team","team","TeamId","GroupId"})do local x,y=LocalPlayer:GetAttribute(a),p:GetAttribute(a);if x~=nil and y~=nil and x~=y then return true end end
        return false
    end);return ok and e or true
end
local function IsVisible(part)
    if not Config.Aim.VisibleCheck then return true end
    local o=Camera.CFrame.Position;local d=(part.Position-o).Unit*(part.Position-o).Magnitude
    local r=RaycastParams.new();r.FilterType=Enum.RaycastFilterType.Blacklist;r.FilterDescendantsInstances={LocalPlayer.Character,Camera}
    local res=workspace:Raycast(o,d,r);return res==nil or res.Instance:IsDescendantOf(part.Parent)
end
local function InitESP(c)
    if ESPData[c] then return end
    local p=Players:GetPlayerFromCharacter(c)
    ESPData[c]={Box=Drawing.new("Square"),Tracer=Drawing.new("Line"),Name=Drawing.new("Text"),Distance=Drawing.new("Text"),HealthBg=Drawing.new("Line"),HealthVal=Drawing.new("Line"),IsPlayer=p~=nil,DisplayName=p and p.Name or("[BOT] "..c.Name)}
    local d=ESPData[c];d.Box.Thickness=1;d.Box.Filled=false;d.Tracer.Thickness=1
    d.Name.Size=14;d.Name.Center=true;d.Name.Outline=true;d.Distance.Size=12;d.Distance.Center=true;d.Distance.Outline=true
    d.HealthBg.Thickness=3;d.HealthBg.Color=Color3.new(0,0,0);d.HealthVal.Thickness=1
end
local function ClearESP(c)
    if ESPData[c] then for _,v in pairs(ESPData[c])do if type(v)~="string"and type(v)~="boolean"then pcall(function()v:Remove()end)end end;ESPData[c]=nil end
end

-- ==========================================
-- 3. MAIN LOOP
-- ==========================================
RunService.RenderStepped:Connect(function()
    local center=Vector2.new(Camera.ViewportSize.X/2,Camera.ViewportSize.Y/2)
    local top=Vector2.new(Camera.ViewportSize.X/2,0)
    local ec=Config.ESP.Rainbow and GetRainbowColor(0)or Config.ESP.Color
    FOVCircle.Position=center;FOVCircle.Radius=Config.Aim.FOV;FOVCircle.Color=ec;FOVCircle.Visible=Config.ESP.ShowFOV
    StatsText.Position=Vector2.new(center.X,20)
    local cp,cb=0,0
    for _,c in ipairs(AllEntities)do if not ESPData[c]and c.Parent then InitESP(c)end end
    for c,_ in pairs(ESPData)do local h=c:FindFirstChildOfClass("Humanoid");if not c.Parent or not h or h.Health<=0 then ClearESP(c)end end
    local tc,sd=nil,Config.Aim.FOV
    for c,o in pairs(ESPData)do
        local h=c:FindFirstChildOfClass("Humanoid")
        if h and h.Health>0 and IsEnemy(c)then
            if o.IsPlayer then cp+=1 else cb+=1 end
            local r=c:FindFirstChild("HumanoidRootPart")
            if r then local pp,on=Camera:WorldToViewportPoint(r.Position)
                if on then local m=(Vector2.new(pp.X,pp.Y)-center).Magnitude;if m<sd then sd=m;tc=c end end
            end
        end
    end
    StatsText.Text=(Config.RivalFast and"🔥 RIVAL FAST | "or"").."Players: "..cp.." | Bots: "..cb..(Config.Invisible.Enabled and" | 👻 INVISIBLE"or"")
    if tc then
        local th,tb=tc:FindFirstChild("Head"),tc:FindFirstChild("HumanoidRootPart")
        if th and tb then
            if LockedTarget~=tc then LockedTarget=tc;LockedAimPart=nil;ProAimStartTime=nil end
            local tp,ap=nil,th
            local shoot=UserInputService:IsMouseButtonPressed(0)or UserInputService:IsMouseButtonPressed(1)or UserInputService:IsMouseButtonPressed(Enum.UserInputType.Touch)
            if Config.Aim.Mode==1 then tp=tb.Position;ap=tb
            elseif Config.Aim.Mode==2 then tp=th.Position
            elseif Config.Aim.Mode==3 then if not LockedAimPart then LockedAimPart=(math.random(1,100)<=70)and"Head"or"HumanoidRootPart"end;local p=tc:FindFirstChild(LockedAimPart)or th;tp=p.Position;ap=p
            elseif Config.Aim.Mode==4 then
                if shoot then if not ProAimStartTime then ProAimStartTime=os.clock();ProAimDuration=math.random(30,70)/100 end;local a=math.sin(math.clamp((os.clock()-ProAimStartTime)/ProAimDuration,0,1)*(math.pi/2));tp=tb.Position:Lerp(th.Position,a)else ProAimStartTime=nil;tp=tb.Position end;ap=tb
            end
            local ar=Config.Aim.Enabled and shoot and IsVisible(ap)
            if ar then Camera.CFrame=CFrame.lookAt(Camera.CFrame.Position,tp);MagnetAnchorPos=nil;MagnetTarget=nil
            elseif Config.Magnet.Enabled and shoot then
                local rp=tc:FindFirstChild("HumanoidRootPart")
                if rp then
                    if not MagnetAnchorPos or MagnetTarget~=tc then MagnetTarget=tc;MagnetAnchorPos=rp.Position+(ap.Name=="Head"and Vector3.new(0,1.5,0)or Vector3.zero)end
                    local cp2=Camera.CFrame.Position;local lv=Camera.CFrame.LookVector;local pd=(MagnetAnchorPos-cp2):Dot(lv);local por=cp2+(lv*pd);local df=por-MagnetAnchorPos;if df.Magnitude>Config.Magnet.Limit then df=df.Unit*Config.Magnet.Limit end
                    ap.CFrame=CFrame.new(MagnetAnchorPos+df);ap.Velocity=Vector3.zero
                end
            else MagnetAnchorPos=nil;MagnetTarget=nil end
        end
    else LockedTarget=nil end
    for c,o in pairs(ESPData)do
        local h,hd,rt=c:FindFirstChildOfClass("Humanoid"),c:FindFirstChild("Head"),c:FindFirstChild("HumanoidRootPart")
        if h and h.Health>0 and IsEnemy(c)and hd and rt then
            if Config.Hitbox.Enabled then
                local pt=c:FindFirstChild(Config.Hitbox.Mode==1 and"HumanoidRootPart"or"Head")
                if pt then pt.Size=Vector3.new(Config.Hitbox.Size,Config.Hitbox.Size,Config.Hitbox.Size);pt.Transparency=0.6;pt.CanCollide=false;pt.Massless=true;pt.CustomPhysicalProperties=PhysicalProperties.new(0,0,0,0,0)end
            end
            local hp,on=Camera:WorldToViewportPoint(hd.Position);local rp=Camera:WorldToViewportPoint(rt.Position);local dist=(Camera.CFrame.Position-rt.Position).Magnitude
            if on then
                local bh=math.abs(hp.Y-rp.Y)*1.5;local bw=bh*0.6;local tl=Vector2.new(hp.X-bw/2,hp.Y-bh*0.2);local br=Vector2.new(hp.X+bw/2,rp.Y+bh*0.2)
                o.Box.Visible=Config.ESP.Box;o.Box.Color=ec;o.Box.Size=Vector2.new(bw,br.Y-tl.Y);o.Box.Position=tl
                o.Tracer.Visible=Config.ESP.Tracer;o.Tracer.Color=ec;o.Tracer.From=top;o.Tracer.To=Vector2.new(hp.X,hp.Y)
                o.Name.Visible=Config.ESP.Name;o.Name.Color=ec;o.Name.Position=Vector2.new(hp.X,tl.Y-20);o.Name.Text=o.DisplayName
                o.Distance.Visible=Config.ESP.Distance;o.Distance.Color=ec;o.Distance.Position=Vector2.new(hp.X,br.Y+5);o.Distance.Text=math.floor(dist).."m"
                if Config.ESP.HealthBar then
                    local hpct=math.clamp(h.Health/h.MaxHealth,0,1);local bah=(br.Y-tl.Y)
                    o.HealthBg.Visible=true;o.HealthBg.From=Vector2.new(tl.X-5,tl.Y);o.HealthBg.To=Vector2.new(tl.X-5,br.Y)
                    o.HealthVal.Visible=true;o.HealthVal.From=Vector2.new(tl.X-5,br.Y);o.HealthVal.To=Vector2.new(tl.X-5,br.Y-(bah*hpct))
                    o.HealthVal.Color=Config.ESP.Rainbow and GetRainbowColor(1)or Color3.fromHSV(hpct*0.3,1,1)
                else o.HealthBg.Visible=false;o.HealthVal.Visible=false end
            else o.Box.Visible=false;o.Tracer.Visible=false;o.Name.Visible=false;o.Distance.Visible=false;o.HealthBg.Visible=false;o.HealthVal.Visible=false end
        else o.Box.Visible=false;o.Tracer.Visible=false;o.Name.Visible=false;o.Distance.Visible=false;o.HealthBg.Visible=false;o.HealthVal.Visible=false end
    end
end)

-- ==========================================
-- 🎨 UI + RAINBOW VIỀN
-- ==========================================
local UI=Instance.new("ScreenGui",CoreGui);UI.Name="BOHUB";UI.ResetOnSpawn=false
local MW,MH=isMobile and 310 or 460,isMobile and 520 or 540
local MainFrame=Instance.new("Frame",UI)
MainFrame.Size=UDim2.new(0,MW,0,MH);MainFrame.Position=UDim2.new(0.5,-MW/2,0.5,-MH/2)
MainFrame.BackgroundColor3=Color3.fromRGB(12,12,16);MainFrame.Visible=false
Instance.new("UICorner",MainFrame).CornerRadius=UDim.new(0,12)
local MS=Instance.new("UIStroke",MainFrame);MS.Thickness=2.5
createSmoothRainbow(MS,0.025)

local Title=Instance.new("TextLabel",MainFrame)
Title.Size=UDim2.new(1,0,0,48);Title.BackgroundColor3=Color3.fromRGB(18,18,22)
Title.Text="🔥 BO HUB v7.0 | NUCLEAR CORE";Title.TextColor3=Color3.new(1,.6,0)
Title.Font=Enum.Font.GothamBold;Title.TextSize=17
Instance.new("UICorner",Title).CornerRadius=UDim.new(0,12)

local TabCont=Instance.new("Frame",MainFrame)
TabCont.Size=UDim2.new(1,-16,0,34);TabCont.Position=UDim2.new(0,8,0,56);TabCont.BackgroundTransparency=1
local TLL=Instance.new("UIListLayout",TabCont);TLL.FillDirection="Horizontal";TLL.Padding=UDim.new(0,5)
local ContCont=Instance.new("Frame",MainFrame)
ContCont.Size=UDim2.new(1,-16,1,-108);ContCont.Position=UDim2.new(0,8,0,98);ContCont.BackgroundTransparency=1

local Tabs={}
local function MakeTab(n,f)
    local B=Instance.new("TextButton",TabCont)
    B.Size=UDim2.new(0,math.floor((MW-32)/3),0,34)
    B.BackgroundColor3=f and Color3.new(1,.5,0)or Color3.fromRGB(30,30,35)
    B.Text=n;B.TextColor3=Color3.new(1,1,1);B.Font=Enum.Font.GothamSemibold;B.TextSize=13
    Instance.new("UICorner",B).CornerRadius=UDim.new(0,6)
    local S=Instance.new("ScrollingFrame",ContCont)
    S.Size=UDim2.new(1,0,1,0);S.BackgroundTransparency=1;S.Visible=f
    S.ScrollBarThickness=4;S.CanvasSize=UDim2.new(0,0,3,0)
    Instance.new("UIListLayout",S).Padding=UDim.new(0,8)
    table.insert(Tabs,{B=B,S=S})
    B.MouseButton1Click:Connect(function()for _,t in pairs(Tabs)do t.B.BackgroundColor3=Color3.fromRGB(30,30,35);t.S.Visible=false end;B.BackgroundColor3=Color3.new(1,.5,0);S.Visible=true end)
    return S
end
local Tab1=MakeTab("Combat",true)
local Tab2=MakeTab("Visuals",false)
local Tab3=MakeTab("Extra",false)

local function AddToggle(P,N,D,CB)
    local F=Instance.new("Frame",P);F.Size=UDim2.new(1,0,0,36);F.BackgroundColor3=Color3.fromRGB(25,25,30);Instance.new("UICorner",F).CornerRadius=UDim.new(0,6)
    local L=Instance.new("TextLabel",F);L.Size=UDim2.new(1,-55,1,0);L.Position=UDim2.new(0,12,0,0);L.BackgroundTransparency=1;L.Text=N;L.TextColor3=Color3.new(230,230,230);L.Font=Enum.Font.Gotham;L.TextSize=14;L.TextXAlignment="Left"
    local B=Instance.new("TextButton",F);B.Size=UDim2.new(0,40,0,20);B.Position=UDim2.new(1,-50,.5,-10);B.BackgroundColor3=D and Color3.new(0,.8,.4)or Color3.fromRGB(55,55,60);B.Text="";Instance.new("UICorner",B).CornerRadius=UDim.new(1,0)
    local C=Instance.new("Frame",B);C.Size=UDim2.new(0,16,0,16);C.BackgroundColor3=Color3.new(1,1,1);C.Position=D and UDim2.new(1,-18,.5,-8)or UDim2.new(0,2,.5,-8);Instance.new("UICorner",C).CornerRadius=UDim.new(1,0)
    local st=D
    B.MouseButton1Click:Connect(function()st=not st;B.BackgroundColor3=st and Color3.new(0,.8,.4)or Color3.fromRGB(55,55,60);C.Position=st and UDim2.new(1,-18,.5,-8)or UDim2.new(0,2,.5,-8);CB(st)end)
    return function(v)st=v;B.BackgroundColor3=v and Color3.new(0,.8,.4)or Color3.fromRGB(55,55,60);C.Position=v and UDim2.new(1,-18,.5,-8)or UDim2.new(0,2,.5,-8)end
end
local function AddSlider(P,N,mi,ma,de,CB)
    local F=Instance.new("Frame",P);F.Size=UDim2.new(1,0,0,45);F.BackgroundColor3=Color3.fromRGB(25,25,30);Instance.new("UICorner",F).CornerRadius=UDim.new(0,6)
    local L=Instance.new("TextLabel",F);L.Size=UDim2.new(1,-10,0,20);L.Position=UDim2.new(0,10,0,5);L.BackgroundTransparency=1;L.Text=N..": "..de;L.TextColor3=Color3.new(220,220,220);L.Font=Enum.Font.Gotham;L.TextSize=13;L.TextXAlignment="Left"
    local B=Instance.new("TextButton",F);B.Size=UDim2.new(1,-20,0,6);B.Position=UDim2.new(0,10,0,30);B.BackgroundColor3=Color3.fromRGB(40,40,45);B.Text="";Instance.new("UICorner",B).CornerRadius=UDim.new(1,0)
    local FI=Instance.new("Frame",B);FI.Size=UDim2.new((de-mi)/(ma-mi),0,1,0);FI.BackgroundColor3=Color3.new(0,.6,1);Instance.new("UICorner",FI).CornerRadius=UDim.new(1,0)
    B.MouseButton1Down:Connect(function()
        local mv=RunService.RenderStepped:Connect(function()
            local pc=math.clamp((UserInputService:GetMouseLocation().X-B.AbsolutePosition.X)/B.AbsoluteSize.X,0,1)
            local v=math.floor(mi+(ma-mi)*pc);FI.Size=UDim2.new(pc,0,1,0);L.Text=N..": "..v;CB(v)
        end)
        local ei;ei=UserInputService.InputEnded:Connect(function(i)if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then mv:Disconnect();ei:Disconnect()end end)
    end)
end
local function AddDropdown(P,N,ops,CB)
    local F=Instance.new("Frame",P);F.Size=UDim2.new(1,0,0,36);F.BackgroundColor3=Color3.fromRGB(25,25,30);Instance.new("UICorner",F).CornerRadius=UDim.new(0,6)
    local L=Instance.new("TextLabel",F);L.Size=UDim2.new(.55,0,1,0);L.Position=UDim2.new(0,12,0,0);L.BackgroundTransparency=1;L.Text=N;L.TextColor3=Color3.new(220,220,220);L.Font=Enum.Font.Gotham;L.TextSize=14;L.TextXAlignment="Left"
    local B=Instance.new("TextButton",F);B.Size=UDim2.new(.35,-10,0,26);B.Position=UDim2.new(.6,5,.5,-13);B.BackgroundColor3=Color3.fromRGB(40,40,45);B.Text=ops[1];B.TextColor3=Color3.new(1,1,1);B.Font=Enum.Font.Gotham;B.TextSize=12;Instance.new("UICorner",B).CornerRadius=UDim.new(0,4)
    local idx=1;B.MouseButton1Click:Connect(function()idx=idx>=#ops and 1 or idx+1;B.Text=ops[idx];CB(idx)end)
    return function(v)idx=v;B.Text=ops[idx]end
end
local function AddButton(P,N,Color,CB)
    local B=Instance.new("TextButton",P);B.Size=UDim2.new(1,0,0,42);B.BackgroundColor3=Color;B.Text=N;B.TextColor3=Color3.new(1,1,1);B.Font=Enum.Font.GothamBold;B.TextSize=14;Instance.new("UICorner",B).CornerRadius=UDim.new(0,8)
    B.MouseButton1Click:Connect(CB);return B
end
local function AddSpace(P,H)local S=Instance.new("Frame",P);S.Size=UDim2.new(1,0,0,H or 5);S.BackgroundTransparency=1 end

-- ================= TAB 1: COMBAT =================
AddToggle(Tab1,"Enable Aimbot",false,function(v)Config.Aim.Enabled=v end)
local SetAimMode=AddDropdown(Tab1,"Aim Part",{"Body","Head","Random 70/30","Pro Pre-Aim"},function(v)Config.Aim.Mode=v end)
SetAimMode(2)
AddToggle(Tab1,"Wall Check (Visible Only)",true,function(v)Config.Aim.VisibleCheck=v end)
AddSlider(Tab1,"FOV Radius",50,500,100,function(v)Config.Aim.FOV=v end)
AddSpace(Tab1,5)
AddToggle(Tab1,"Enable Magnet (On Shoot)",false,function(v)Config.Magnet.Enabled=v end)
AddSlider(Tab1,"Magnet Safe Range",1,20,5,function(v)Config.Magnet.Limit=v end)
AddSpace(Tab1,5)
AddToggle(Tab1,"Enable Hitbox Expander",false,function(v)Config.Hitbox.Enabled=v end)
AddDropdown(Tab1,"Hitbox Part",{"Body","Head"},function(v)Config.Hitbox.Mode=v end)
AddSlider(Tab1,"Hitbox Size",1,50,15,function(v)Config.Hitbox.Size=v end)

-- ================= TAB 2: VISUALS =================
AddToggle(Tab2,"Show FOV Circle",true,function(v)Config.ESP.ShowFOV=v end)
AddToggle(Tab2,"ESP Boxes",false,function(v)Config.ESP.Box=v end)
AddToggle(Tab2,"ESP Health Bar",false,function(v)Config.ESP.HealthBar=v end)
AddToggle(Tab2,"ESP Tracers",false,function(v)Config.ESP.Tracer=v end)
AddToggle(Tab2,"ESP Names",false,function(v)Config.ESP.Name=v end)
AddToggle(Tab2,"ESP Distance",false,function(v)Config.ESP.Distance=v end)
AddSpace(Tab2,5)
local SetESPColor=AddDropdown(Tab2,"ESP Color",{"White","Red","Green","Blue","Yellow","Purple","RAINBOW 🌈"},function(idx)
    local cols={Color3.new(1,1,1),Color3.new(1,.2,.2),Color3.new(.2,1,.2),Color3.new(.2,.6,1),Color3.new(1,1,.2),Color3.new(.8,.2,1)}
    if idx<=6 then Config.ESP.Color=cols[idx];Config.ESP.Rainbow=false else Config.ESP.Rainbow=true end
end)

-- ================= TAB 3: EXTRA =================
AddToggle(Tab3,"👻 Invisible (Nuclear -200k)",false,function(v)Config.Invisible.Enabled=v end)
AddSpace(Tab3,10)

-- ✅ RIVAL FAST FUNCTION: 1 CLICK BẬT TẤT CẢ
AddButton(Tab3,"⚡ RIVAL FAST FUNCTION",Color3.new(1,.2,.2),function()
    Config.RivalFast = not Config.RivalFast
    if Config.RivalFast then
        -- Bật toàn bộ ESP
        Config.ESP.Box=true;Config.ESP.Tracer=true;Config.ESP.Name=true
        Config.ESP.Distance=true;Config.ESP.HealthBar=true;Config.ESP.ShowFOV=true
        -- Aim Pro + Magnet
        Config.Aim.Enabled=true;Config.Aim.Mode=4;SetAimMode(4)
        Config.Aim.VisibleCheck=true;Config.Aim.FOV=180
        Config.Magnet.Enabled=true;Config.Magnet.Limit=8
        print("[BO HUB] ⚡ RIVAL FAST: ALL ON")
    else
        Config.ESP.Box=false;Config.ESP.Tracer=false;Config.ESP.Name=false
        Config.ESP.Distance=false;Config.ESP.HealthBar=false
        Config.Aim.Enabled=false;Config.Magnet.Enabled=false
        print("[BO HUB] RIVAL FAST: OFF")
    end
end)

AddSpace(Tab3,10)
AddButton(Tab3,"🔄 UNLOAD SCRIPT",Color3.fromRGB(80,20,20),function()
    for _,v in pairs(getconnections(RunService.Heartbeat))do if v and v.Disconnect then pcall(function()v:Disconnect()end)end end
    for _,v in pairs(getconnections(RunService.RenderStepped))do if v and v.Disconnect then pcall(function()v:Disconnect()end)end end
    pcall(function()FOVCircle:Remove()end);pcall(function()StatsText:Remove()end)
    for c,_ in pairs(ESPData)do ClearESP(c)end
    UI:Destroy();CoreGui.BOHUB:Destroy()
end)

-- ================= MOBILE NÚT BO / PC PHÍM K =================
if isMobile then
    local OB=Instance.new("TextButton",UI);OB.Size=UDim2.new(0,55,0,55);OB.Position=UDim2.new(0,15,.45,0)
    OB.BackgroundColor3=Color3.fromRGB(18,18,22);OB.Text="BO";OB.TextColor3=Color3.new(1,1,1);OB.Font=Enum.Font.GothamBlack;OB.TextSize=18
    Instance.new("UICorner",OB).CornerRadius=UDim.new(1,0)
    local OBS=Instance.new("UIStroke",OB);OBS.Color=Color3.new(1,.5,0);OBS.Thickness=2;createSmoothRainbow(OBS)
    local dr,ds,sp;OB.InputBegan:Connect(function(i)if i.UserInputType=="Touch"then dr=true;ds=i.Position;sp=OB.Position end end)
    UserInputService.InputChanged:Connect(function(i)if dr and i.UserInputType=="Touch"then local d=i-ds;OB.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)end end)
    UserInputService.InputEnded:Connect(function(i)if i.UserInputType=="Touch"then dr=false end end)
    OB.MouseButton1Click:Connect(function()MainFrame.Visible=not MainFrame.Visible end)
else
    UserInputService.InputBegan:Connect(function(i,gp)if gp then return end
        if i.KeyCode==Enum.KeyCode.K then MainFrame.Visible=not MainFrame.Visible
        elseif i.KeyCode==Enum.KeyCode.X then Config.Invisible.Enabled=not Config.Invisible.Enabled
        elseif i.KeyCode==Enum.KeyCode.M then UI.Enabled=not UI.Enabled;StatsText.Visible=UI.Enabled end
    end)
    
    -- ✅ PC: HIỆN LUÔN BẢNG HƯỚNG DẪN KHI EXECUTE
    local Guide=Instance.new("ScreenGui");Guide.Name="BOGuide";Guide.Parent=LocalPlayer.PlayerGui;Guide.ResetOnSpawn=false
    local GF=Instance.new("Frame",Guide);GF.Size=UDim2.new(0,320,0,110);GF.Position=UDim2.new(0.5,-160,0.85,-55)
    GF.BackgroundColor3=Color3.fromRGB(12,12,16);GF.ClipsDescendants=true
    Instance.new("UICorner",GF).CornerRadius=UDim.new(0,10)
    local GS=Instance.new("UIStroke",GF);GS.Thickness=2;createSmoothRainbow(GS,0.03)
    local GT=Instance.new("TextLabel",GF);GT.Size=UDim2.new(1,0,0,30);GT.Position=UDim2.new(0,0,0,0);GT.BackgroundColor3=Color3.new(1,.5,0);GT.Text="✅ BO HUB LOADED";GT.TextColor3=Color3.new(0,0,0);GT.Font=Enum.Font.GothamBold;GT.TextSize=14
    local GL=Instance.new("TextLabel",GF);GL.Size=UDim2.new(1,-20,0,70);GL.Position=UDim2.new(0,10,0,35);GL.BackgroundTransparency=1
    GL.Text="⌨️  [K] = Mở / Đóng Menu\n⌨️  [X] = Bật / Tắt Invisible\n⌨️  [M] = Ẩn / Hiện Toàn Bộ UI"
    GL.TextColor3=Color3.new(230,230,230);GL.Font=Enum.Font.Gotham;GL.TextSize=13;GL.TextXAlignment="Left"
    task.delay(8,function()pcall(function()Guide:Destroy()end)end) -- Tự mất sau 8s
end

-- KÉO MENU
local md,mss,msp
Title.InputBegan:Connect(function(i)if i.UserInputType=="MouseButton1"or i.UserInputType=="Touch"then md=true;mss=i.Position;msp=MainFrame.Position end end)
UserInputService.InputChanged:Connect(function(i)if md and(i.UserInputType=="MouseMovement"or i.UserInputType=="Touch")then local d=i-mss;MainFrame.Position=UDim2.new(msp.X.Scale,msp.X.Offset+d.X,msp.Y.Scale,msp.Y.Offset+d.Y)end end)
UserInputService.InputEnded:Connect(function(i)if i.UserInputType=="MouseButton1"or i.UserInputType=="Touch"then md=false end end)

print("╔══════════════════════════════════╗")
print("║       🔥 BO HUB v7.0 LOADED       ║")
print("║   NUCLEAR INVISIBLE -200.000 Y    ║")
print("║   Rainbow UI • Rival Fast         ║")
print("╠══════════════════════════════════╣")
print("║  [K] Menu   [X] Invisible   [M] UI║")
print("╚══════════════════════════════════╝")
