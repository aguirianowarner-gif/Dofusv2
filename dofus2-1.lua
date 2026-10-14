--============================================================
-- DOOFUS JERRY V2.3.0 — FINAL
-- Skybox ON · Rainbow OFF
--============================================================

local CONFIG = {
    NAME = "DOOFUS JERRY V1", GUI_NAME = "DOOFUS_JERRY_V2", VERSION = "2.3.0", DEBUG = true,
    Colors = {
        BG=Color3.fromRGB(11,15,10), PANEL=Color3.fromRGB(20,26,18),
        PANEL_2=Color3.fromRGB(30,40,32), PANEL_3=Color3.fromRGB(42,55,44),
        BORDER=Color3.fromRGB(46,58,44), ACCENT=Color3.fromRGB(124,255,58),
        ACCENT_2=Color3.fromRGB(255,179,71), TEXT=Color3.fromRGB(234,242,229),
        SUBTEXT=Color3.fromRGB(139,154,133), OK=Color3.fromRGB(124,255,58),
        WARN=Color3.fromRGB(255,179,71), ERR=Color3.fromRGB(255,90,90),
    },
}
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local TweenService=game:GetService("TweenService")
local RunService=game:GetService("RunService")
local Lighting=game:GetService("Lighting")
local Stats=game:GetService("Stats")
local VirtualUser=game:GetService("VirtualUser")
local SoundService=game:GetService("SoundService")
local TeleportService=game:GetService("TeleportService")
local HttpService=game:GetService("HttpService")
local HitMarker={conn=nil,frame=nil}

local LogBuffer,StatusLabel={},nil
local function pushLog(tag,msg,isErr)
    local l=string.format("[DJ][%s]%s %s",tag,isErr and "[ERR]" or "",tostring(msg))
    if isErr then warn(l) elseif CONFIG.DEBUG then print(l) end
    table.insert(LogBuffer,l); if #LogBuffer>150 then table.remove(LogBuffer,1) end
    if StatusLabel then StatusLabel.Text=l
        StatusLabel.TextColor3=isErr and CONFIG.Colors.ERR or CONFIG.Colors.SUBTEXT end
end
local function log(t,m) pushLog(t,m,false) end
local function logErr(t,m) pushLog(t,m,true) end

local ENV=shared
pcall(function() if type(getgenv)=="function" then ENV=getgenv() end end)
if type(ENV.DOOFUS_JERRY_V1_CLEANUP)=="function" then
    pcall(ENV.DOOFUS_JERRY_V1_CLEANUP); ENV.DOOFUS_JERRY_V1_CLEANUP=nil
    log("INIT","Ejecución previa limpiada") end
local Connections={}
local function track(c) table.insert(Connections,c); return c end
local function disconnectAll()
    for _,c in ipairs(Connections) do pcall(function() c:Disconnect() end) end
    Connections={}
end

local lp=Players.LocalPlayer
if not lp then local t=0
    repeat task.wait(0.1); t=t+0.1 until Players.LocalPlayer or t>10
    lp=Players.LocalPlayer end
if not lp then logErr("INIT","LocalPlayer no disponible"); return end
local pg=lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui",10)
if not pg then logErr("INIT","PlayerGui no disponible"); return end
log("INIT","LocalPlayer: "..lp.Name)
local oldGui=pg:FindFirstChild(CONFIG.GUI_NAME)
if oldGui then oldGui:Destroy() end

local function new(c,p,ch)
    local i=Instance.new(c); for k,v in pairs(p or {}) do i[k]=v end
    for _,x in ipairs(ch or {}) do x.Parent=i end; return i end
local function corner(r) return new("UICorner",{CornerRadius=UDim.new(0,r or 8)}) end
local function stroke(c,t) return new("UIStroke",{Color=c or CONFIG.Colors.BORDER,Thickness=t or 1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function pad(px) return new("UIPadding",{PaddingTop=UDim.new(0,px),PaddingBottom=UDim.new(0,px),PaddingLeft=UDim.new(0,px),PaddingRight=UDim.new(0,px)}) end
local function getViewport()
    local cam=workspace.CurrentCamera
    if cam and cam.ViewportSize.X>0 then return cam.ViewportSize end
    return Vector2.new(400,700) end

local vp=getViewport()
local W=math.clamp(vp.X*0.94,290,440)
local H=math.clamp(vp.Y*0.85,360,660)

local ScreenGui=new("ScreenGui",{Name=CONFIG.GUI_NAME,ResetOnSpawn=false,IgnoreGuiInset=true,
    ZIndexBehavior=Enum.ZIndexBehavior.Sibling,DisplayOrder=999,Parent=pg})

local WM=new("Frame",{Name="DJ_Watermark",BackgroundColor3=CONFIG.Colors.PANEL,
    BorderSizePixel=0,Size=UDim2.new(0,0,0,22),AutomaticSize=Enum.AutomaticSize.X,
    Position=UDim2.new(0,8,0,8),Parent=ScreenGui},{corner(6),stroke(CONFIG.Colors.ACCENT,1),pad(6)})
local WMLabel=new("TextLabel",{BackgroundTransparency=1,
    Text=string.format("%s · v%s · %s",CONFIG.NAME,CONFIG.VERSION,lp.Name),
    TextColor3=CONFIG.Colors.ACCENT,Font=Enum.Font.Code,TextSize=11,
    Size=UDim2.new(0,0,1,0),AutomaticSize=Enum.AutomaticSize.X,Parent=WM})

local Main=new("Frame",{Name="Main",BackgroundColor3=CONFIG.Colors.BG,BorderSizePixel=0,
    Size=UDim2.fromOffset(W,H),Position=UDim2.new(0.5,0,0.5,0),
    AnchorPoint=Vector2.new(0.5,0.5),ClipsDescendants=true,Parent=ScreenGui},
    {corner(14),stroke(CONFIG.Colors.BORDER,1)})
local TitleBar=new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL,BorderSizePixel=0,
    Size=UDim2.new(1,0,0,48),Parent=Main},{corner(14)})
new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL,BorderSizePixel=0,
    Size=UDim2.new(1,0,0,14),Position=UDim2.new(0,0,1,-14),Parent=TitleBar})
local JIcon=new("TextLabel",{BackgroundColor3=CONFIG.Colors.ACCENT,BorderSizePixel=0,
    Text="J",TextColor3=CONFIG.Colors.BG,Font=Enum.Font.GothamBlack,TextSize=20,
    Size=UDim2.fromOffset(30,30),Position=UDim2.new(0,10,0.5,0),
    AnchorPoint=Vector2.new(0,0.5),Parent=TitleBar},{corner(8)})
TweenService:Create(JIcon,TweenInfo.new(1.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{BackgroundColor3=CONFIG.Colors.ACCENT_2}):Play()
new("TextLabel",{BackgroundTransparency=1,Text=CONFIG.NAME,TextColor3=CONFIG.Colors.TEXT,
    Font=Enum.Font.GothamBlack,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left,
    Size=UDim2.new(1,-200,1,0),Position=UDim2.new(0,48,0,0),Parent=TitleBar})
local function smallBtn(t,x,c)
    return new("TextButton",{BackgroundColor3=c or CONFIG.Colors.PANEL_2,BorderSizePixel=0,
        Text=t,TextColor3=CONFIG.Colors.TEXT,Font=Enum.Font.GothamBold,TextSize=15,
        Size=UDim2.fromOffset(34,34),Position=UDim2.new(1,x,0.5,0),
        AnchorPoint=Vector2.new(1,0.5),AutoButtonColor=true,Parent=TitleBar},{corner(8)}) end
local BtnPanic=smallBtn("!",-138,CONFIG.Colors.ERR)
local BtnMin=smallBtn("—",-12,CONFIG.Colors.PANEL_2)
local BtnClose=smallBtn("×",-54,CONFIG.Colors.ERR)

local TabBar=new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL,BorderSizePixel=0,
    Size=UDim2.new(1,0,0,50),Position=UDim2.new(0,0,0,48),Parent=Main},{pad(6)})
local TabList=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(1,0,1,0),Parent=TabBar},
    {new("UIListLayout",{FillDirection=Enum.FillDirection.Horizontal,
        HorizontalAlignment=Enum.HorizontalAlignment.Center,
        VerticalAlignment=Enum.VerticalAlignment.Center,
        Padding=UDim.new(0,3),SortOrder=Enum.SortOrder.LayoutOrder})})
local Content=new("Frame",{BackgroundColor3=CONFIG.Colors.BG,BorderSizePixel=0,
    Size=UDim2.new(1,0,1,-(48+50+26)),Position=UDim2.new(0,0,0,98),Parent=Main},{pad(10)})
local StatusBar=new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL,BorderSizePixel=0,
    Size=UDim2.new(1,0,0,26),Position=UDim2.new(0,0,1,-26),Parent=Main},{pad(6)})
StatusLabel=new("TextLabel",{BackgroundTransparency=1,Text="[DJ][INIT] Listo",
    TextColor3=CONFIG.Colors.SUBTEXT,Font=Enum.Font.Code,TextSize=12,
    TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
    Size=UDim2.new(1,0,1,0),Parent=StatusBar})

local Pages,TabBtns={},{}
local function buildPage(name)
    local p=new("ScrollingFrame",{Name="Page_"..name,BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),CanvasSize=UDim2.new(0,0,0,0),
        ScrollBarThickness=4,ScrollBarImageColor3=CONFIG.Colors.ACCENT,
        AutomaticCanvasSize=Enum.AutomaticSize.Y,Visible=false,Parent=Content},
        {new("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder}),pad(4)})
    Pages[name]=p end
local function selectTab(name)
    if not Pages[name] then logErr("TAB","Desconocida: "..name); return end
    for n,p in pairs(Pages) do p.Visible=(n==name) end
    for n,b in pairs(TabBtns) do
        local a=(n==name)
        TweenService:Create(b,TweenInfo.new(0.15),{
            BackgroundColor3=a and CONFIG.Colors.ACCENT or CONFIG.Colors.PANEL_2,
            TextColor3=a and CONFIG.Colors.BG or CONFIG.Colors.TEXT}):Play()
    end end
local function buildTab(name)
    local b=new("TextButton",{BackgroundColor3=CONFIG.Colors.PANEL_2,BorderSizePixel=0,
        Text=name,TextColor3=CONFIG.Colors.TEXT,Font=Enum.Font.GothamBold,TextSize=11,
        Size=UDim2.new(1/5,-4,1,0),AutoButtonColor=false,Parent=TabList},{corner(8)})
    track(b.Activated:Connect(function() selectTab(name) end))
    TabBtns[name]=b end
for _,n in ipairs({"JERRY","DOOFUS","CAOS","COMBATE","EXTRAS"}) do
    buildTab(n); buildPage(n) end

local ToastHolder=new("Frame",{BackgroundTransparency=1,Size=UDim2.new(0,260,0,400),
    Position=UDim2.new(1,-12,1,-12),AnchorPoint=Vector2.new(1,1),Parent=ScreenGui},
    {new("UIListLayout",{FillDirection=Enum.FillDirection.Vertical,
        VerticalAlignment=Enum.VerticalAlignment.Bottom,
        HorizontalAlignment=Enum.HorizontalAlignment.Right,
        Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder})})
local NotifHistory={}
local function toast(text,kind)
    local color=CONFIG.Colors.ACCENT
    if kind=="err" then color=CONFIG.Colors.ERR elseif kind=="warn" then color=CONFIG.Colors.ACCENT_2 end
    table.insert(NotifHistory,{t=os.time(),text=text,kind=kind})
    if #NotifHistory>30 then table.remove(NotifHistory,1) end
    local t=new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        BackgroundTransparency=1,Parent=ToastHolder},{corner(10),pad(10)})
    new("UIStroke",{Color=color,Thickness=1,Transparency=1,Parent=t})
    new("Frame",{BackgroundColor3=color,BorderSizePixel=0,Size=UDim2.new(0,3,1,0),Parent=t})
    new("TextLabel",{BackgroundTransparency=1,Text=text,TextColor3=CONFIG.Colors.TEXT,
        Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true,
        TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-10,0,0),
        Position=UDim2.new(0,8,0,0),AutomaticSize=Enum.AutomaticSize.Y,Parent=t})
    task.spawn(function()
        TweenService:Create(t,TweenInfo.new(0.2),{BackgroundTransparency=0}):Play()
        task.wait(3)
        if t.Parent then
            TweenService:Create(t,TweenInfo.new(0.25),{BackgroundTransparency=1}):Play()
            task.wait(0.3); t:Destroy() end end)
end

local Order=0
local function nextOrder() Order=Order+1; return Order end
local function sectionTitle(parent,text)
    new("TextLabel",{BackgroundTransparency=1,Text=text,TextColor3=CONFIG.Colors.ACCENT,
        Font=Enum.Font.GothamBold,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(1,0,0,18),LayoutOrder=nextOrder(),Parent=parent}) end
local function makeInfoRow(parent,label)
    local h=new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,34),LayoutOrder=nextOrder(),Parent=parent},
        {corner(8),stroke(CONFIG.Colors.BORDER,1),pad(8)})
    new("TextLabel",{BackgroundTransparency=1,Text=label,TextColor3=CONFIG.Colors.SUBTEXT,
        Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(0.5,0,1,0),Parent=h})
    local v=new("TextLabel",{BackgroundTransparency=1,Text="—",TextColor3=CONFIG.Colors.TEXT,
        Font=Enum.Font.Code,TextSize=13,TextXAlignment=Enum.TextXAlignment.Right,
        Size=UDim2.new(0.5,0,1,0),Position=UDim2.new(0.5,0,0,0),Parent=h})
    return h,v end
local function makeDesc(parent,text,color)
    new("TextLabel",{BackgroundColor3=CONFIG.Colors.PANEL,BorderSizePixel=0,Text=text,
        TextColor3=color or CONFIG.Colors.ACCENT_2,Font=Enum.Font.Gotham,TextSize=11,
        TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        LayoutOrder=nextOrder(),Parent=parent},
        {corner(8),stroke(color or CONFIG.Colors.ACCENT_2,1),pad(8)}) end
local function makeButton(parent,opts)
    local h=new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        LayoutOrder=nextOrder(),Parent=parent},{corner(10),stroke(CONFIG.Colors.BORDER,1),pad(10)})
    new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,Parent=h})
    new("TextLabel",{BackgroundTransparency=1,Text=opts.label,TextColor3=CONFIG.Colors.TEXT,
        Font=Enum.Font.GothamBold,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(1,0,0,18),LayoutOrder=1,Parent=h})
    if opts.desc and opts.desc~="" then
        new("TextLabel",{BackgroundTransparency=1,Text=opts.desc,TextColor3=CONFIG.Colors.SUBTEXT,
            Font=Enum.Font.Gotham,TextSize=12,TextWrapped=true,
            TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,0,0,0),
            AutomaticSize=Enum.AutomaticSize.Y,LayoutOrder=2,Parent=h}) end
    local b=new("TextButton",{BackgroundColor3=CONFIG.Colors.PANEL_2,BorderSizePixel=0,
        Text=opts.actionText or "EJECUTAR",TextColor3=CONFIG.Colors.TEXT,
        Font=Enum.Font.GothamBold,TextSize=14,Size=UDim2.new(1,0,0,46),
        LayoutOrder=3,AutoButtonColor=false,Parent=h},{corner(8)})
    track(b.Activated:Connect(function()
        log("CTRL","Pulsado: "..opts.label)
        local ok,err=pcall(opts.onClick)
        if not ok then logErr("CTRL",opts.label.." → "..tostring(err)); toast("Error: "..opts.label,"err") end
    end))
    return b end
local function makeToggle(parent,opts)
    local h=new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,46),LayoutOrder=nextOrder(),Parent=parent},
        {corner(10),stroke(CONFIG.Colors.BORDER,1),pad(10)})
    new("TextLabel",{BackgroundTransparency=1,Text=opts.label,TextColor3=CONFIG.Colors.TEXT,
        Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(0.7,0,1,0),Parent=h})
    local tb=new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL_3,BorderSizePixel=0,
        Size=UDim2.fromOffset(52,28),Position=UDim2.new(1,-52,0.5,0),
        AnchorPoint=Vector2.new(0,0.5),Parent=h},{corner(14)})
    local k=new("Frame",{BackgroundColor3=CONFIG.Colors.TEXT,BorderSizePixel=0,
        Size=UDim2.fromOffset(22,22),Position=UDim2.new(0,3,0.5,0),
        AnchorPoint=Vector2.new(0,0.5),Parent=tb},{corner(11)})
    local state=opts.initial==true
    local function apply(v)
        state=v
        TweenService:Create(tb,TweenInfo.new(0.15),{
            BackgroundColor3=v and CONFIG.Colors.ACCENT or CONFIG.Colors.PANEL_3}):Play()
        TweenService:Create(k,TweenInfo.new(0.15),{
            Position=UDim2.new(v and 1 or 0,v and -25 or 3,0.5,0)}):Play() end
    apply(state)
    local b=new("TextButton",{BackgroundTransparency=1,Text="",Size=UDim2.new(1,0,1,0),Parent=h})
    track(b.Activated:Connect(function()
        local ns=not state; apply(ns)
        if opts.onChange then
            local ok,err=pcall(opts.onChange,ns)
            if not ok then logErr("CTRL",tostring(err)) end end
    end))
    return {set=apply,get=function() return state end} end
local function makeSlider(parent,opts)
    local min,max=opts.min or 0,opts.max or 100
    local value=opts.initial or min
    local h=new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,66),LayoutOrder=nextOrder(),Parent=parent},
        {corner(10),stroke(CONFIG.Colors.BORDER,1),pad(10)})
    new("TextLabel",{BackgroundTransparency=1,Text=opts.label,TextColor3=CONFIG.Colors.TEXT,
        Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(0.7,0,0,18),Parent=h})
    local vl=new("TextLabel",{BackgroundTransparency=1,Text=tostring(value),
        TextColor3=CONFIG.Colors.ACCENT,Font=Enum.Font.Code,TextSize=13,
        TextXAlignment=Enum.TextXAlignment.Right,Size=UDim2.new(0.3,0,0,18),
        Position=UDim2.new(0.7,0,0,0),Parent=h})
    local bar=new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL_3,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,8),Position=UDim2.new(0,0,0,34),Parent=h},{corner(4)})
    local fill=new("Frame",{BackgroundColor3=CONFIG.Colors.ACCENT,BorderSizePixel=0,
        Size=UDim2.new(0,0,1,0),Parent=bar},{corner(4)})
    local knob=new("Frame",{BackgroundColor3=CONFIG.Colors.TEXT,BorderSizePixel=0,
        Size=UDim2.fromOffset(20,20),Position=UDim2.new(0,0,0.5,0),
        AnchorPoint=Vector2.new(0.5,0.5),Parent=bar},{corner(10),stroke(CONFIG.Colors.ACCENT,2)})
    local hit=new("TextButton",{BackgroundTransparency=1,Text="",
        Size=UDim2.new(1,0,0,30),Position=UDim2.new(0,0,0,26),Parent=h})
    local function sfx(absX)
        local rel=math.clamp((absX-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        value=math.floor(min+(max-min)*rel+0.5)
        fill.Size=UDim2.new(rel,0,1,0); knob.Position=UDim2.new(rel,0,0.5,0)
        vl.Text=tostring(value)
        if opts.onChange then
            local ok,err=pcall(opts.onChange,value)
            if not ok then logErr("CTRL",tostring(err)) end end end
    local drag=false
    track(hit.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=true; sfx(i.Position.X) end end))
    track(UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseMovement) then
            sfx(i.Position.X) end end))
    track(UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch or i.UserInputType==Enum.UserInputType.MouseButton1 then
            drag=false end end))
    return {get=function() return value end,set=sfx} end
local function makeTextInput(parent,opts)
    local h=new("Frame",{BackgroundColor3=CONFIG.Colors.PANEL,BorderSizePixel=0,
        Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,
        LayoutOrder=nextOrder(),Parent=parent},{corner(10),stroke(CONFIG.Colors.BORDER,1),pad(10)})
    new("UIListLayout",{Padding=UDim.new(0,6),SortOrder=Enum.SortOrder.LayoutOrder,Parent=h})
    new("TextLabel",{BackgroundTransparency=1,Text=opts.label,TextColor3=CONFIG.Colors.TEXT,
        Font=Enum.Font.GothamBold,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left,
        Size=UDim2.new(1,0,0,18),LayoutOrder=1,Parent=h})
    local txt=new("TextBox",{BackgroundColor3=CONFIG.Colors.PANEL_2,BorderSizePixel=0,
        Text=opts.initial or "",PlaceholderText=opts.placeholder or "Escribe aquí...",
        TextColor3=CONFIG.Colors.TEXT,PlaceholderColor3=CONFIG.Colors.SUBTEXT,
        Font=Enum.Font.Code,TextSize=13,ClearTextOnFocus=false,
        Size=UDim2.new(1,0,0,40),LayoutOrder=2,
        TextXAlignment=Enum.TextXAlignment.Left,Parent=h},{corner(6),pad(6)})
    local b=new("TextButton",{BackgroundColor3=CONFIG.Colors.ACCENT,BorderSizePixel=0,
        Text=opts.actionText or "APLICAR",TextColor3=CONFIG.Colors.BG,
        Font=Enum.Font.GothamBold,TextSize=13,Size=UDim2.new(1,0,0,40),
        LayoutOrder=3,AutoButtonColor=false,Parent=h},{corner(6)})
    track(b.Activated:Connect(function()
        local ok,err=pcall(opts.onSubmit,txt.Text)
        if not ok then logErr("CTRL",tostring(err)) end end))
    return txt end

--============================================================
-- JERRY
--============================================================
local Jerry=Pages["JERRY"]
sectionTitle(Jerry,"ESTADO DEL JUGADOR")
local _,LblName=makeInfoRow(Jerry,"Jugador")
local _,LblHp=makeInfoRow(Jerry,"Vida")
local _,LblVel=makeInfoRow(Jerry,"Velocidad")
local _,LblPos=makeInfoRow(Jerry,"Posición")
local _,LblFps=makeInfoRow(Jerry,"FPS")
local _,LblPing=makeInfoRow(Jerry,"Ping")
local _,LblPlayers=makeInfoRow(Jerry,"Jugadores")
local _,LblSession=makeInfoRow(Jerry,"Sesión")
local _,LblMem=makeInfoRow(Jerry,"Memoria")
local _,LblUptime=makeInfoRow(Jerry,"Uptime")
LblName.Text=lp.Name
local SessionStart=os.time()
local ServerStart=tick()
local WMExtra={active=false,kills=0}

sectionTitle(Jerry,"ANTI-AFK Y RESPAWN")
local AntiAFK={active=false,conn=nil}
makeToggle(Jerry,{label="Anti-AFK",initial=true,onChange=function(v)
    AntiAFK.active=v
    if v then
        if not AntiAFK.conn then
            AntiAFK.conn=lp.Idled:Connect(function()
                if not AntiAFK.active then return end
                pcall(function() VirtualUser:CaptureController()
                    VirtualUser:ClickButton2(Vector2.new()) end) end) end
        toast("Anti-AFK ON")
    else toast("Anti-AFK OFF") end end})
local AutoRespawn={active=false,conn=nil}
makeToggle(Jerry,{label="Auto-Respawn",initial=false,onChange=function(v)
    AutoRespawn.active=v
    if v then
        if not AutoRespawn.conn then
            AutoRespawn.conn=lp.CharacterAdded:Connect(function()
                if not AutoRespawn.active then return end
                task.wait(0.5); if lp.Character then lp.Character:BreakJoints() end end) end
        toast("Auto-Respawn ON","warn")
    else toast("Auto-Respawn OFF") end end})

sectionTitle(Jerry,"CÁMARA Y CHAT")
makeToggle(Jerry,{label="Third Person forzado",initial=false,onChange=function(v)
    pcall(function() lp.CameraMode=v and Enum.CameraMode.Classic or Enum.CameraMode.LockFirstPerson end)
    toast(v and "Third Person ON" or "Third Person OFF") end})
makeToggle(Jerry,{label="Force First Person",initial=false,onChange=function(v)
    pcall(function() lp.CameraMode=v and Enum.CameraMode.LockFirstPerson or Enum.CameraMode.Classic end)
    toast(v and "1st Person ON" or "1st Person OFF") end})
local ChatLog={active=false}
makeToggle(Jerry,{label="Chat Logger",initial=false,onChange=function(v)
    ChatLog.active=v
    if v then
        for _,plr in ipairs(Players:GetPlayers()) do
            track(plr.Chatted:Connect(function(m)
                if ChatLog.active then log("CHAT",plr.Name..": "..m) end end)) end
        track(Players.PlayerAdded:Connect(function(plr)
            track(plr.Chatted:Connect(function(m)
                if ChatLog.active then log("CHAT",plr.Name..": "..m) end end)) end))
        toast("Chat Logger ON")
    else toast("Chat Logger OFF") end end})

sectionTitle(Jerry,"WATERMARK Y CONTADORES")
makeToggle(Jerry,{label="Watermark extendida",initial=false,onChange=function(v)
    WMExtra.active=v
    if not v then WMLabel.Text=string.format("%s · v%s · %s",CONFIG.NAME,CONFIG.VERSION,lp.Name) end
    toast(v and "Watermark ON" or "Watermark OFF") end})
makeButton(Jerry,{label="Resetear contador",onClick=function() WMExtra.kills=0; toast("Contador a 0") end})
makeButton(Jerry,{label="Ver contador",onClick=function() toast("Muertes: "..WMExtra.kills) end})

sectionTitle(Jerry,"CUSTOM NAMETAG")
local CNametag={active=false,bg=nil}
local function cnameBuild(text)
    if CNametag.bg and CNametag.bg.Parent then CNametag.bg:Destroy() end
    local char=lp.Character; if not char then return end
    local head=char:FindFirstChild("Head"); if not head then return end
    local bg=new("BillboardGui",{Name="DJ_MyTag",Adornee=head,
        Size=UDim2.new(0,200,0,30),StudsOffsetWorldSpace=Vector3.new(0,2.5,0),
        AlwaysOnTop=true,LightInfluence=0,Parent=char})
    new("TextLabel",{BackgroundTransparency=1,Text=text,TextColor3=CONFIG.Colors.ACCENT,
        Font=Enum.Font.GothamBold,TextSize=14,
        TextStrokeTransparency=0,TextStrokeColor3=CONFIG.Colors.BG,
        Size=UDim2.new(1,0,1,0),Parent=bg})
    CNametag.bg=bg end
makeTextInput(Jerry,{label="Tu nametag personalizado",initial="DOOFUS JERRY",
    onSubmit=function(text) cnameBuild(text); toast("Nametag: "..text) end})
makeToggle(Jerry,{label="Mostrar mi nametag",initial=false,onChange=function(v)
    CNametag.active=v
    if v then cnameBuild("DOOFUS JERRY")
    elseif CNametag.bg and CNametag.bg.Parent then CNametag.bg:Destroy(); CNametag.bg=nil end
    toast(v and "Nametag ON" or "Nametag OFF") end})

sectionTitle(Jerry,"SERVER INFO Y HOP")
makeButton(Jerry,{label="Ver info del servidor",onClick=function()
    log("SRV","Nombre: "..game.Name)
    log("SRV","PlaceId: "..game.PlaceId)
    log("SRV","JobId: "..game.JobId)
    log("SRV","Jugadores: "..#Players:GetPlayers().."/"..Players.MaxPlayers)
    log("SRV","Uptime: "..math.floor(tick()-ServerStart).."s")
    toast("Server info en consola","warn") end})
makeButton(Jerry,{label="Rejoin mismo servidor",onClick=function()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId,game.JobId,lp) end)
    toast("Rejoin solicitado","warn") end})

sectionTitle(Jerry,"AUTO-MESSAGE")
makeDesc(Jerry,"Cuidado: puede violar las reglas del juego.",CONFIG.Colors.ERR)
local AutoMsg={active=false,text="hola",interval=5,conn=nil}
makeTextInput(Jerry,{label="Mensaje a enviar",initial="hola",
    onSubmit=function(t) AutoMsg.text=t; toast("Mensaje: "..t) end})
makeSlider(Jerry,{label="Intervalo (seg)",min=2,max=60,initial=5,
    onChange=function(v) AutoMsg.interval=v end})
makeToggle(Jerry,{label="Auto-message ON/OFF",initial=false,onChange=function(v)
    AutoMsg.active=v
    if v then
        toast("Auto-msg ON","warn")
        task.spawn(function()
            while AutoMsg.active do
                task.wait(AutoMsg.interval)
                if AutoMsg.active then
                    pcall(function()
                        local cse=game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                        if cse then
                            local say=cse:FindFirstChild("SayMessageRequest")
                            if say then say:FireServer(AutoMsg.text,"All") end end end) end end end)
    else toast("Auto-msg OFF") end end})

sectionTitle(Jerry,"HISTORIAL Y DIAGNÓSTICO")
makeButton(Jerry,{label="Ver notificaciones",onClick=function()
    log("NOTIF","Últimas "..#NotifHistory..":")
    for _,n in ipairs(NotifHistory) do
        log("NOTIF",os.date("%H:%M:%S",n.t).." ["..(n.kind or "info").."] "..n.text) end
    toast("Historial en consola","warn") end})
makeButton(Jerry,{label="Copiar JobId",onClick=function()
    local jid=game.JobId or ""
    if type(setclipboard)=="function" then pcall(setclipboard,jid); toast("JobId copiado")
    else log("INFO","JobId: "..jid); toast("En consola","warn") end end})
makeButton(Jerry,{label="Diagnóstico",onClick=function()
    log("DEP","getgenv: "..tostring(type(getgenv)))
    log("DEP","getconnections: "..tostring(type(getconnections)))
    log("DEP","mouse1click: "..tostring(type(mouse1click)))
    log("DEP","setclipboard: "..tostring(type(setclipboard)))
    log("DEP","Drawing: "..tostring(type(Drawing)))
    for _,l in ipairs(LogBuffer) do print("  "..l) end
    toast("Diagnóstico en consola","warn") end})
makeButton(Jerry,{label="Limpiar buffer",onClick=function() LogBuffer={}; toast("Buffer limpiado") end})

--============================================================
-- DOOFUS
--============================================================
local Doofus=Pages["DOOFUS"]
sectionTitle(Doofus,"ILUMINACIÓN")
local FBBackup={Brightness=Lighting.Brightness,Ambient=Lighting.Ambient,
    OutdoorAmbient=Lighting.OutdoorAmbient,ClockTime=Lighting.ClockTime,
    FogEnd=Lighting.FogEnd,GlobalShadows=Lighting.GlobalShadows}
makeToggle(Doofus,{label="Fullbright",initial=false,onChange=function(v)
    if v then
        Lighting.Brightness=3; Lighting.Ambient=Color3.fromRGB(180,180,180)
        Lighting.OutdoorAmbient=Color3.fromRGB(180,180,180); Lighting.ClockTime=14
    else
        Lighting.Brightness=FBBackup.Brightness; Lighting.Ambient=FBBackup.Ambient
        Lighting.OutdoorAmbient=FBBackup.OutdoorAmbient; Lighting.ClockTime=FBBackup.ClockTime end
    toast(v and "Fullbright ON" or "Fullbright OFF") end})
makeSlider(Doofus,{label="Hora local",min=0,max=24,initial=14,onChange=function(v) Lighting.ClockTime=v end})
makeToggle(Doofus,{label="Anti-Fog",initial=false,onChange=function(v)
    if v then Lighting.FogEnd=math.huge; Lighting.FogStart=math.huge
    else Lighting.FogEnd=FBBackup.FogEnd end
    toast(v and "Anti-Fog ON" or "Anti-Fog OFF") end})
makeToggle(Doofus,{label="Quitar sombras",initial=false,onChange=function(v)
    Lighting.GlobalShadows=not v; toast(v and "Sombras OFF" or "Sombras ON") end})
makeButton(Doofus,{label="Restaurar iluminación original",onClick=function()
    Lighting.Brightness=FBBackup.Brightness; Lighting.Ambient=FBBackup.Ambient
    Lighting.OutdoorAmbient=FBBackup.OutdoorAmbient; Lighting.ClockTime=FBBackup.ClockTime
    Lighting.FogEnd=FBBackup.FogEnd; Lighting.GlobalShadows=FBBackup.GlobalShadows
    toast("Iluminación restaurada") end})

sectionTitle(Doofus,"COLOR AMBIENTAL")
makeSlider(Doofus,{label="Ambient R (0-255)",min=0,max=255,initial=180,
    onChange=function(v) Lighting.Ambient=Color3.fromRGB(v,Lighting.Ambient.G*255,Lighting.Ambient.B*255) end})
makeSlider(Doofus,{label="Ambient G (0-255)",min=0,max=255,initial=180,
    onChange=function(v) Lighting.Ambient=Color3.fromRGB(Lighting.Ambient.R*255,v,Lighting.Ambient.B*255) end})
makeSlider(Doofus,{label="Ambient B (0-255)",min=0,max=255,initial=180,
    onChange=function(v) Lighting.Ambient=Color3.fromRGB(Lighting.Ambient.R*255,Lighting.Ambient.G*255,v) end})

sectionTitle(Doofus,"SKYBOX")
local skyBackup={node=Lighting:FindFirstChildOfClass("Sky")}
if skyBackup.node then skyBackup.clone=skyBackup.node:Clone() end
local function setSky(mode)
    local ex=Lighting:FindFirstChildOfClass("Sky"); if ex then ex:Destroy() end
    if mode=="reset" then
        if skyBackup.clone then skyBackup.clone:Clone().Parent=Lighting end
        toast("Skybox restaurado"); return end
    local sky=new("Sky",{Parent=Lighting})
    if mode=="day" then
        sky.SkyboxBk="rbxassetid://159454299"; sky.SkyboxDn="rbxassetid://159454296"
        sky.SkyboxFt="rbxassetid://159454293"; sky.SkyboxLf="rbxassetid://159454286"
        sky.SkyboxRt="rbxassetid://159454300"; sky.SkyboxUp="rbxassetid://159454288"
    elseif mode=="night" then
        sky.SkyboxBk="rbxassetid://12064107"; sky.SkyboxDn="rbxassetid://12064152"
        sky.SkyboxFt="rbxassetid://12064121"; sky.SkyboxLf="rbxassetid://12063984"
        sky.SkyboxRt="rbxassetid://12064115"; sky.SkyboxUp="rbxassetid://12064108"
    elseif mode=="space" then
        sky.SkyboxBk="rbxassetid://159454299"; sky.SkyboxDn="rbxassetid://159454296"
        sky.SkyboxFt="rbxassetid://159454293"; sky.SkyboxLf="rbxassetid://159454286"
        sky.SkyboxRt="rbxassetid://159454300"; sky.SkyboxUp="rbxassetid://159454288"
        Lighting.ClockTime=0 end
    toast("Skybox: "..mode) end
makeButton(Doofus,{label="Skybox: Día",onClick=function() setSky("day") end})
makeButton(Doofus,{label="Skybox: Noche",onClick=function() setSky("night") end})
makeButton(Doofus,{label="Skybox: Espacio",onClick=function() setSky("space") end})
makeButton(Doofus,{label="Skybox: Restaurar",onClick=function() setSky("reset") end})

sectionTitle(Doofus,"SCREEN EFFECTS")
local Blur={active=false,eff=nil}
makeToggle(Doofus,{label="Blur (fondo borroso)",initial=false,onChange=function(v)
    if v then Blur.eff=new("BlurEffect",{Size=16,Parent=Lighting})
    elseif Blur.eff then Blur.eff:Destroy(); Blur.eff=nil end
    toast(v and "Blur ON" or "Blur OFF") end})
local DOF={active=false,eff=nil}
makeToggle(Doofus,{label="Depth of Field",initial=false,onChange=function(v)
    if v then DOF.eff=new("DepthOfFieldEffect",{FocusDistance=20,InFocusRadius=15,FarIntensity=0.3,Parent=Lighting})
    elseif DOF.eff then DOF.eff:Destroy(); DOF.eff=nil end
    toast(v and "DOF ON" or "DOF OFF") end})

sectionTitle(Doofus,"CAMERA FX")
local CamFx={cc=nil}
local function camFxClear()
    if CamFx.cc then CamFx.cc:Destroy(); CamFx.cc=nil end end
local function camFxApply(mode)
    camFxClear()
    if mode=="off" then toast("FX OFF"); return end
    CamFx.cc=new("ColorCorrectionEffect",{Name="DJ_CC",Parent=Lighting})
    if mode=="night" then CamFx.cc.TintColor=Color3.fromRGB(80,255,120); CamFx.cc.Brightness=0.15; CamFx.cc.Contrast=0.2
    elseif mode=="thermal" then CamFx.cc.TintColor=Color3.fromRGB(255,180,80); CamFx.cc.Brightness=0.05; CamFx.cc.Contrast=0.4; CamFx.cc.Saturation=-0.3
    elseif mode=="cold" then CamFx.cc.TintColor=Color3.fromRGB(120,200,255); CamFx.cc.Brightness=0.05
    elseif mode=="sepia" then CamFx.cc.TintColor=Color3.fromRGB(255,220,160); CamFx.cc.Saturation=-0.5; CamFx.cc.Brightness=0.05 end
    toast("FX: "..mode,"warn") end
makeButton(Doofus,{label="Night Vision",onClick=function() camFxApply("night") end})
makeButton(Doofus,{label="Thermal Vision",onClick=function() camFxApply("thermal") end})
makeButton(Doofus,{label="Cold Tint",onClick=function() camFxApply("cold") end})
makeButton(Doofus,{label="Sepia",onClick=function() camFxApply("sepia") end})
makeButton(Doofus,{label="Desactivar FX",onClick=function() camFxApply("off") end})

sectionTitle(Doofus,"EFECTOS DE MUNDO")
local DecalsBackup={}
makeToggle(Doofus,{label="Remove Decals",initial=false,onChange=function(v)
    if v then
        DecalsBackup={}
        for _,d in ipairs(workspace:GetDescendants()) do
            if d:IsA("Decal") or d:IsA("Texture") then
                DecalsBackup[d]=d.Transparency; d.Transparency=1 end end
        toast("Decals OFF")
    else
        for d,t in pairs(DecalsBackup) do if d and d.Parent then d.Transparency=t end end
        DecalsBackup={}; toast("Decals ON") end end})
makeToggle(Doofus,{label="Remove Terrain Details",initial=false,onChange=function(v)
    pcall(function() workspace.Terrain.Decoration=not v end)
    toast(v and "Terrain OFF" or "Terrain ON") end})
makeToggle(Doofus,{label="Remove Particles",initial=false,onChange=function(v)
    if v then
        local c=0
        for _,p in ipairs(workspace:GetDescendants()) do
            if p:IsA("ParticleEmitter") and p.Enabled then p.Enabled=false; c=c+1 end end
        toast("Partículas OFF ("..c..")","warn")
    else
        for _,p in ipairs(workspace:GetDescendants()) do
            if p:IsA("ParticleEmitter") then p.Enabled=true end end
        toast("Partículas ON") end end})
makeToggle(Doofus,{label="Remove Lights",initial=false,onChange=function(v)
    for _,p in ipairs(workspace:GetDescendants()) do
        if p:IsA("PointLight") or p:IsA("SpotLight") or p:IsA("SurfaceLight") then
            p.Enabled=not v end end
    toast(v and "Luces OFF" or "Luces ON") end})
local MuteAll={active=false,backup={},conn=nil}
makeToggle(Doofus,{label="Mute Sounds",initial=false,onChange=function(v)
    MuteAll.active=v
    if v then
        MuteAll.backup={}
        for _,s in ipairs(SoundService:GetDescendants()) do
            if s:IsA("Sound") then MuteAll.backup[s]=s.Volume; s.Volume=0 end end
        MuteAll.conn=SoundService.ChildAdded:Connect(function(c)
            if MuteAll.active and c:IsA("Sound") then MuteAll.backup[c]=c.Volume; c.Volume=0 end end)
        toast("Audio silenciado")
    else
        for s,vol in pairs(MuteAll.backup) do
            if s and s.Parent then pcall(function() s.Volume=vol end) end end
        MuteAll.backup={}
        if MuteAll.conn then MuteAll.conn:Disconnect(); MuteAll.conn=nil end
        toast("Audio restaurado") end end})

sectionTitle(Doofus,"PERSONAJE")
makeSlider(Doofus,{label="WalkSpeed",min=8,max=200,initial=16,onChange=function(v)
    local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed=v end end})
makeSlider(Doofus,{label="JumpPower",min=50,max=300,initial=50,onChange=function(v)
    local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.UseJumpPower=true; hum.JumpPower=v end end})
makeSlider(Doofus,{label="Hip Height (x10)",min=0,max=50,initial=20,onChange=function(v)
    local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.HipHeight=v/10 end end})
local InfJump={active=false,conn=nil}
makeToggle(Doofus,{label="Infinite Jump",initial=false,onChange=function(v)
    InfJump.active=v
    if v then
        if not InfJump.conn then
            InfJump.conn=UIS.JumpRequest:Connect(function()
                if InfJump.active then
                    local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                    if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end end) end
        toast("Infinite Jump ON")
    else toast("Infinite Jump OFF") end end})
local Noclip={active=false,conn=nil}
makeToggle(Doofus,{label="Noclip",initial=false,onChange=function(v)
    Noclip.active=v
    if v then
        if not Noclip.conn then
            Noclip.conn=RunService.Stepped:Connect(function()
                if not Noclip.active then return end
                local char=lp.Character; if not char then return end
                for _,p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end end end) end
        toast("Noclip ON","warn")
    else
        if Noclip.conn then Noclip.conn:Disconnect(); Noclip.conn=nil end
        toast("Noclip OFF") end end})
local AutoJump={active=false}
makeToggle(Doofus,{label="Auto-Jump",initial=false,onChange=function(v)
    AutoJump.active=v; toast(v and "Auto-Jump ON" or "Auto-Jump OFF") end})
local Sprint={active=false,mode="hold",speed=32}
makeSlider(Doofus,{label="Velocidad sprint",min=20,max=120,initial=32,onChange=function(v) Sprint.speed=v end})
makeToggle(Doofus,{label="Sprint toggle",initial=false,onChange=function(v)
    Sprint.active=v; toast(v and "Sprint toggle ON" or "OFF") end})
local Bhop={active=false,conn=nil}
makeToggle(Doofus,{label="Bunny Hop (bhop auto)",initial=false,onChange=function(v)
    Bhop.active=v
    if v then
        if not Bhop.conn then
            Bhop.conn=UIS.JumpRequest:Connect(function()
                if Bhop.active then
                    local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                    if hum and hum.FloorMaterial~=Enum.Material.Air then
                        hum:ChangeState(Enum.HumanoidStateType.Jumping) end end end) end
        toast("Bhop ON")
    else toast("Bhop OFF") end end})
local CrouchSpam={active=false,conn=nil}
makeToggle(Doofus,{label="Crouch spam",initial=false,onChange=function(v)
    CrouchSpam.active=v
    if v then
        if not CrouchSpam.conn then
            CrouchSpam.conn=RunService.Heartbeat:Connect(function()
                if not CrouchSpam.active then return end
                pcall(function()
                    game:GetService("VirtualInputManager"):SendKeyEvent(true,Enum.KeyCode.LeftControl,false,game)
                    task.wait(0.05)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false,Enum.KeyCode.LeftControl,false,game) end) end) end
        toast("Crouch spam ON")
    else
        if CrouchSpam.conn then CrouchSpam.conn:Disconnect(); CrouchSpam.conn=nil end
        toast("Crouch spam OFF") end end})
local LookAt={active=false,conn=nil}
makeToggle(Doofus,{label="Look at player más cercano",initial=false,onChange=function(v)
    LookAt.active=v
    if v then
        if not LookAt.conn then
            LookAt.conn=RunService.RenderStepped:Connect(function()
                if not LookAt.active then return end
                local myHrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                local cam=workspace.CurrentCamera; if not myHrp or not cam then return end
                local best,bestD=nil,math.huge
                for _,plr in ipairs(Players:GetPlayers()) do
                    if plr~=lp then
                        local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local d=(myHrp.Position-hrp.Position).Magnitude
                            if d<bestD then bestD=d; best=hrp end end end end
                if best then cam.CFrame=CFrame.new(cam.CFrame.Position,best.Position) end end) end
        toast("Look at ON")
    else
        if LookAt.conn then LookAt.conn:Disconnect(); LookAt.conn=nil end
        toast("Look at OFF") end end})
local CamLock={active=false,target=nil,conn=nil}
makeButton(Doofus,{label="Lock cámara a jugador más cercano",onClick=function()
    local myHrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then toast("Sin personaje","err"); return end
    local best,bestD=nil,math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp then
            local hrp=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local d=(myHrp.Position-hrp.Position).Magnitude
                if d<bestD then bestD=d; best=plr end end end end
    if best then
        CamLock.target=best; CamLock.active=true
        if not CamLock.conn then
            CamLock.conn=RunService.RenderStepped:Connect(function()
                if not CamLock.active or not CamLock.target then return end
                local hrp=CamLock.target.Character and CamLock.target.Character:FindFirstChild("HumanoidRootPart")
                local cam=workspace.CurrentCamera
                if hrp and cam then cam.CFrame=CFrame.new(cam.CFrame.Position,hrp.Position) end end) end
        toast("Camera lock: "..best.Name,"warn") end end})
makeButton(Doofus,{label="Soltar camera lock",onClick=function()
    CamLock.active=false; CamLock.target=nil
    if CamLock.conn then CamLock.conn:Disconnect(); CamLock.conn=nil end
    toast("Camera lock OFF") end})
local Ghost={active=false,backup={}}
local function ghostApply()
    local char=lp.Character; if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") or p:IsA("Decal") then
            if not Ghost.backup[p] then Ghost.backup[p]=p.Transparency end
            p.Transparency=1 end end end
local function ghostRestore()
    for obj,t in pairs(Ghost.backup) do
        if obj and obj.Parent then pcall(function() obj.Transparency=t end) end end
    Ghost.backup={} end
makeToggle(Doofus,{label="Ghost Local",initial=false,onChange=function(v)
    Ghost.active=v
    if v then ghostApply(); toast("Ghost Local ON","warn")
    else ghostRestore(); toast("Ghost Local OFF") end end})
local BigHead={active=false,backup={}}
local function bigHeadApply(char)
    if not char then return end
    local head=char:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        if not BigHead.backup[head] then BigHead.backup[head]=head.Size end
        head.Size=BigHead.backup[head]*2.5
        local mesh=head:FindFirstChildOfClass("SpecialMesh")
        if mesh then
            if not BigHead.backup[mesh] then BigHead.backup[mesh]=Vector3.new(mesh.Scale.X,mesh.Scale.Y,mesh.Scale.Z) end
            mesh.Scale=BigHead.backup[mesh]*2.5 end end end
local function bigHeadRestore()
    for obj,orig in pairs(BigHead.backup) do
        if obj and obj.Parent then
            pcall(function()
                if obj:IsA("BasePart") then obj.Size=orig
                elseif obj:IsA("SpecialMesh") then obj.Scale=orig end end) end end
    BigHead.backup={} end
makeToggle(Doofus,{label="Big Head",initial=false,onChange=function(v)
    BigHead.active=v
    if v then bigHeadApply(lp.Character); toast("Big Head ON","warn")
    else bigHeadRestore(); toast("Big Head OFF") end end})
local NoAcc={active=false,backup={}}
makeToggle(Doofus,{label="Remove Accessories",initial=false,onChange=function(v)
    NoAcc.active=v
    if v then
        NoAcc.backup={}
        for _,plr in ipairs(Players:GetPlayers()) do
            local char=plr.Character
            if char then
                for _,acc in ipairs(char:GetChildren()) do
                    if acc:IsA("Accessory") then NoAcc.backup[acc]=acc.Parent; acc.Parent=nil end end end end
        toast("Accesorios OFF")
    else
        for acc,parent in pairs(NoAcc.backup) do if acc and parent then acc.Parent=parent end end
        NoAcc.backup={}; toast("Accesorios ON") end end})
local NeonBody={active=false,backup={}}
local function neonApply()
    local char=lp.Character; if not char then return end
    for _,p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            if not NeonBody.backup[p] then NeonBody.backup[p]={mat=p.Material,col=p.Color} end
            p.Material=Enum.Material.Neon; p.Color=CONFIG.Colors.ACCENT end end end
local function neonRestore()
    for p,d in pairs(NeonBody.backup) do
        if p and p.Parent then pcall(function() p.Material=d.mat; p.Color=d.col end) end end
    NeonBody.backup={} end
makeToggle(Doofus,{label="Neon Body",initial=false,onChange=function(v)
    NeonBody.active=v
    if v then neonApply(); toast("Neon Body ON","warn")
    else neonRestore(); toast("Neon Body OFF") end end})
local CharScale={backup=nil}
makeToggle(Doofus,{label="Character Scale (grande)",initial=false,onChange=function(v)
    local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if not hum then toast("Sin personaje","err"); return end
    if v then
        pcall(function()
            CharScale.backup={H=hum.BodyHeightScale,W=hum.BodyWidthScale,D=hum.BodyDepthScale,Hd=hum.HeadScale}
            hum.BodyHeightScale=1.5; hum.BodyWidthScale=1.3; hum.BodyDepthScale=1.3; hum.HeadScale=1.2 end)
        toast("Escala grande ON")
    else
        if CharScale.backup then
            pcall(function()
                hum.BodyHeightScale=CharScale.backup.H; hum.BodyWidthScale=CharScale.backup.W
                hum.BodyDepthScale=CharScale.backup.D; hum.HeadScale=CharScale.backup.Hd end) end
        toast("Escala normal") end end})
local CharColor={backup={}}
makeToggle(Doofus,{label="Character Color (verde)",initial=false,onChange=function(v)
    local char=lp.Character; if not char then return end
    if v then
        CharColor.backup={}
        for _,p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then CharColor.backup[p]=p.Color; p.Color=CONFIG.Colors.ACCENT end end
        toast("Color verde ON")
    else
        for p,c in pairs(CharColor.backup) do if p and p.Parent then pcall(function() p.Color=c end) end end
        CharColor.backup={}; toast("Color restaurado") end end})
local AntiFling={active=false}
makeToggle(Doofus,{label="Anti-Fling",initial=false,onChange=function(v)
    AntiFling.active=v; toast(v and "Anti-Fling ON" or "Anti-Fling OFF") end})
local AntiVoid={active=false,lastSafe=nil,timer=0}
makeToggle(Doofus,{label="Anti-Void",desc="Te devuelve si caes al vacío.",initial=false,onChange=function(v)
    AntiVoid.active=v; AntiVoid.lastSafe=nil; toast(v and "Anti-Void ON" or "Anti-Void OFF") end})
local AntiRagdoll={active=false,conn=nil}
makeToggle(Doofus,{label="Anti-Ragdoll",initial=false,onChange=function(v)
    AntiRagdoll.active=v
    if v then
        if not AntiRagdoll.conn then
            AntiRagdoll.conn=RunService.Heartbeat:Connect(function()
                if not AntiRagdoll.active then return end
                local char=lp.Character; if not char then return end
                local hum=char:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll,false)
                    hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown,false) end end) end
        toast("Anti-Ragdoll ON")
    else
        if AntiRagdoll.conn then AntiRagdoll.conn:Disconnect(); AntiRagdoll.conn=nil end
        toast("Anti-Ragdoll OFF") end end})
local DoubleJump={active=false,conn=nil,jumped=false}
makeToggle(Doofus,{label="Double Jump",initial=false,onChange=function(v)
    DoubleJump.active=v
    if v then
        if not DoubleJump.conn then
            DoubleJump.conn=UIS.JumpRequest:Connect(function()
                if not DoubleJump.active then return end
                local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if not hum then return end
                if hum.FloorMaterial==Enum.Material.Air and not DoubleJump.jumped then
                    DoubleJump.jumped=true
                    hum:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
        toast("Double Jump ON")
    else toast("Double Jump OFF") end end})
local Dash={active=false,cooldown=1,last=0,conn=nil}
makeToggle(Doofus,{label="Dash",initial=false,onChange=function(v)
    Dash.active=v
    if v then
        if not Dash.conn then
            Dash.conn=UIS.JumpRequest:Connect(function()
                if not Dash.active then return end
                local now=os.clock()
                if now-Dash.last<Dash.cooldown then return end
                Dash.last=now
                local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local cam=workspace.CurrentCamera
                    hrp.AssemblyLinearVelocity=cam.CFrame.LookVector*150+Vector3.new(0,30,0) end end) end
        toast("Dash ON")
    else toast("Dash OFF") end end})
local ZoomUnlim={backup=nil}
makeToggle(Doofus,{label="Zoom ilimitado",initial=false,onChange=function(v)
    if v then ZoomUnlim.backup=lp.CameraMaxZoomDistance; lp.CameraMaxZoomDistance=5000
    else lp.CameraMaxZoomDistance=ZoomUnlim.backup or 128 end
    toast(v and "Zoom ON" or "Zoom OFF") end})
local Fly={active=false,speed=60,conn=nil,bodyVel=nil,gyro=nil}
local function flyStart()
    if Fly.active then return end
    local char=lp.Character; if not char then toast("Sin personaje","err"); return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    Fly.active=true
    Fly.bodyVel=new("BodyVelocity",{MaxForce=Vector3.new(math.huge,math.huge,math.huge),
        Velocity=Vector3.zero,Parent=hrp})
    Fly.gyro=new("BodyGyro",{MaxTorque=Vector3.new(math.huge,math.huge,math.huge),
        P=10000,D=500,CFrame=hrp.CFrame,Parent=hrp})
    Fly.conn=RunService.RenderStepped:Connect(function()
        if not Fly.active then return end
        local c=lp.Character; local h=c and c:FindFirstChild("HumanoidRootPart")
        if not h then return end
        local cam=workspace.CurrentCamera
        local move=Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W) then move=move+cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then move=move-cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then move=move-cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then move=move+cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move=move-Vector3.new(0,1,0) end
        if move.Magnitude>0 then move=move.Unit end
        if Fly.bodyVel then Fly.bodyVel.Velocity=move*Fly.speed end
        if Fly.gyro then Fly.gyro.CFrame=cam.CFrame end end)
    toast("Fly ON","warn") end
local function flyStop()
    if not Fly.active then return end
    Fly.active=false
    if Fly.conn then Fly.conn:Disconnect(); Fly.conn=nil end
    if Fly.bodyVel then Fly.bodyVel:Destroy(); Fly.bodyVel=nil end
    if Fly.gyro then Fly.gyro:Destroy(); Fly.gyro=nil end
    toast("Fly OFF") end
makeToggle(Doofus,{label="Fly",initial=false,onChange=function(v)
    if v then flyStart() else flyStop() end end})
makeSlider(Doofus,{label="Velocidad vuelo",min=10,max=400,initial=60,onChange=function(v) Fly.speed=v end})
local AutoPickup={active=false,radius=12}
makeToggle(Doofus,{label="Auto-Pickup armas",initial=false,onChange=function(v)
    AutoPickup.active=v; toast(v and "Auto-Pickup ON" or "Auto-Pickup OFF") end})
makeSlider(Doofus,{label="Radio pickup",min=5,max=50,initial=12,onChange=function(v) AutoPickup.radius=v end})
local AutoTool={active=false,conn=nil}
makeToggle(Doofus,{label="Auto-equip",initial=false,onChange=function(v)
    AutoTool.active=v
    if v then
        if not AutoTool.conn then
            AutoTool.conn=RunService.Heartbeat:Connect(function()
                if not AutoTool.active then return end
                local char=lp.Character; if not char then return end
                local hum=char:FindFirstChildOfClass("Humanoid")
                local bp=lp:FindFirstChildOfClass("Backpack")
                if hum and bp then
                    local cur=char:FindFirstChildOfClass("Tool")
                    if not cur then
                        local tools=bp:GetChildren()
                        if #tools>0 then
                            local tool=tools[#tools]
                            if tool and tool:IsA("Tool") then pcall(function() hum:EquipTool(tool) end) end end end end end) end
        toast("Auto-equip ON")
    else
        if AutoTool.conn then AutoTool.conn:Disconnect(); AutoTool.conn=nil end
        toast("Auto-equip OFF") end end})
local FpsCap={active=false,cap=30,conn=nil,last=0}
makeToggle(Doofus,{label="FPS Cap (batería)",initial=false,onChange=function(v)
    FpsCap.active=v
    if v then
        if not FpsCap.conn then
            FpsCap.conn=RunService.RenderStepped:Connect(function()
                if not FpsCap.active then return end
                local interval=1/FpsCap.cap
                local now=os.clock()
                if now-FpsCap.last<interval then task.wait(interval-(now-FpsCap.last)) end
                FpsCap.last=os.clock() end) end
        toast("FPS Cap ON")
    else
        if FpsCap.conn then FpsCap.conn:Disconnect(); FpsCap.conn=nil end
        toast("FPS Cap OFF") end end})
makeSlider(Doofus,{label="FPS objetivo",min=15,max=120,initial=30,onChange=function(v) FpsCap.cap=v end})
sectionTitle(Doofus,"CÁMARA Y FÍSICA")
makeSlider(Doofus,{label="FOV",min=40,max=120,initial=70,onChange=function(v)
    local cam=workspace.CurrentCamera
    if cam then cam.FieldOfView=v end end})
local gravityBackup=workspace.Gravity
makeSlider(Doofus,{label="Gravedad",min=0,max=196,initial=math.floor(gravityBackup),onChange=function(v)
    workspace.Gravity=v end})
makeButton(Doofus,{label="Restaurar gravedad",onClick=function()
    workspace.Gravity=gravityBackup; toast("Gravedad restaurada") end})
makeButton(Doofus,{label="Resetear personaje",onClick=function()
    local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
    if hum then hum.Health=0; toast("Reseteando…")
    else logErr("CTRL","Humanoid no encontrado") end end})

--============================================================
-- CAOS
--============================================================
local Caos=Pages["CAOS"]

sectionTitle(Caos,"CROSSHAIR")
local Crosshair={active=false,size=16,thickness=2,gap=6,color=CONFIG.Colors.ACCENT,parts={}}
local function chBuild()
    for _,p in ipairs(Crosshair.parts) do if p and p.Parent then p:Destroy() end end
    Crosshair.parts={}
    local function mk(w,h,x,y)
        local f=new("Frame",{BackgroundColor3=Crosshair.color,BorderSizePixel=0,
            Size=UDim2.fromOffset(w,h),Position=UDim2.new(0.5,x,0.5,y),
            AnchorPoint=Vector2.new(0.5,0.5),ZIndex=5,Parent=ScreenGui})
        table.insert(Crosshair.parts,f) end
    mk(Crosshair.thickness,Crosshair.size,0,-(Crosshair.gap+Crosshair.size/2))
    mk(Crosshair.thickness,Crosshair.size,0,(Crosshair.gap+Crosshair.size/2))
    mk(Crosshair.size,Crosshair.thickness,-(Crosshair.gap+Crosshair.size/2),0)
    mk(Crosshair.size,Crosshair.thickness,(Crosshair.gap+Crosshair.size/2),0) end
local function chClear()
    for _,p in ipairs(Crosshair.parts) do if p and p.Parent then p:Destroy() end end
    Crosshair.parts={} end
makeToggle(Caos,{label="Crosshair personalizada",initial=false,onChange=function(v)
    Crosshair.active=v
    if v then chBuild(); toast("Crosshair ON") else chClear(); toast("Crosshair OFF") end end})
makeSlider(Caos,{label="Tamaño líneas",min=4,max=40,initial=16,onChange=function(v)
    Crosshair.size=v; if Crosshair.active then chBuild() end end})
makeSlider(Caos,{label="Grosor",min=1,max=6,initial=2,onChange=function(v)
    Crosshair.thickness=v; if Crosshair.active then chBuild() end end})
makeSlider(Caos,{label="Separación centro",min=0,max=30,initial=6,onChange=function(v)
    Crosshair.gap=v; if Crosshair.active then chBuild() end end})

sectionTitle(Caos,"HITBOX EXPANDER (4 MODOS)")
makeDesc(Caos,"Modo 1: HRP. Modo 2: Todas las partes. Modo 3: Cabeza+torso. Modo 4: Solo cabeza.")
local Hitbox={active=false,mode=1,size=15,originals={},loopConn=nil}
local function hbGetHRP(plr) local c=plr.Character; return c and c:FindFirstChild("HumanoidRootPart") end
local function hbApplyMode1(plr)
    local hrp=hbGetHRP(plr); if not hrp then return end
    if not Hitbox.originals[hrp] then Hitbox.originals[hrp]=hrp.Size end
    hrp.Size=Vector3.new(Hitbox.size,Hitbox.size,Hitbox.size) end
local function hbApplyMode2(plr)
    local c=plr.Character; if not c then return end
    for _,p in ipairs(c:GetDescendants()) do
        if p:IsA("BasePart") then
            if not Hitbox.originals[p] then Hitbox.originals[p]=p.Size end
            local base=Hitbox.originals[p]
            if base.Magnitude>1 then p.Size=base*(Hitbox.size/5) end end end end
local function hbApplyMode3(plr)
    local c=plr.Character; if not c then return end
    for _,name in ipairs({"Head","UpperTorso","LowerTorso","Torso"}) do
        local p=c:FindFirstChild(name)
        if p and p:IsA("BasePart") then
            if not Hitbox.originals[p] then Hitbox.originals[p]=p.Size end
            p.Size=Vector3.new(Hitbox.size,Hitbox.size,Hitbox.size) end end end
local function hbApplyMode4(plr)
    local c=plr.Character; if not c then return end
    local head=c:FindFirstChild("Head")
    if head and head:IsA("BasePart") then
        if not Hitbox.originals[head] then Hitbox.originals[head]=head.Size end
        head.Size=Vector3.new(Hitbox.size,Hitbox.size,Hitbox.size) end end
local function hbApply(plr)
    if Hitbox.mode==1 then hbApplyMode1(plr)
    elseif Hitbox.mode==2 then hbApplyMode2(plr)
    elseif Hitbox.mode==3 then hbApplyMode3(plr)
    elseif Hitbox.mode==4 then hbApplyMode4(plr) end end
local function hbRestoreAll()
    for p,orig in pairs(Hitbox.originals) do
        if p and p.Parent then pcall(function() p.Size=orig end) end end
    Hitbox.originals={} end
local function hbStart()
    if Hitbox.active then return end
    Hitbox.active=true
    for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp then hbApply(plr) end end
    Hitbox.loopConn=RunService.Heartbeat:Connect(function()
        if not Hitbox.active then return end
        for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp then hbApply(plr) end end end)
    toast("Hitbox modo "..Hitbox.mode.." ON","warn") end
local function hbStop()
    if not Hitbox.active then return end
    Hitbox.active=false
    if Hitbox.loopConn then Hitbox.loopConn:Disconnect(); Hitbox.loopConn=nil end
    hbRestoreAll(); toast("Hitbox OFF") end
makeButton(Caos,{label="Modo 1: HRP",onClick=function()
    if Hitbox.active then hbStop() end
    Hitbox.mode=1; toast("Hitbox modo 1") end})
makeButton(Caos,{label="Modo 2: Todas las partes",onClick=function()
    if Hitbox.active then hbStop() end
    Hitbox.mode=2; toast("Hitbox modo 2") end})
makeButton(Caos,{label="Modo 3: Cabeza + torso",onClick=function()
    if Hitbox.active then hbStop() end
    Hitbox.mode=3; toast("Hitbox modo 3") end})
makeButton(Caos,{label="Modo 4: Solo cabeza",onClick=function()
    if Hitbox.active then hbStop() end
    Hitbox.mode=4; toast("Hitbox modo 4") end})
makeToggle(Caos,{label="Hitbox ON/OFF",initial=false,onChange=function(v)
    if v then hbStart() else hbStop() end end})
makeSlider(Caos,{label="Tamaño (studs)",min=5,max=40,initial=15,onChange=function(v)
    Hitbox.size=v
    if Hitbox.active then
        for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp then hbApply(plr) end end end end})

sectionTitle(Caos,"AIMBOT (5 TIPOS)")
makeDesc(Caos,"T1: Suave. T2: Snap. T3: Silent. T4: Predictive. T5: Instant Hit.")
local Aim={active=false,type=1,smoothness=0.35,maxDistance=500,fov=260,
    headAim=false,predictFactor=0.15,bound=false,priority="closest"}
local function aimFindTarget()
    local cam=workspace.CurrentCamera; if not cam then return nil end
    local center=Vector2.new(cam.ViewportSize.X/2,cam.ViewportSize.Y/2)
    local best,bestScore=nil,math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp then
            local char=plr.Character
            local hrp=char and char:FindFirstChild("HumanoidRootPart")
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health>0 then
                local dist3=(cam.CFrame.Position-hrp.Position).Magnitude
                if dist3<=Aim.maxDistance then
                    local sp,onScreen=cam:WorldToViewportPoint(hrp.Position)
                    if onScreen then
                        local score
                        if Aim.priority=="weakest" then score=hum.Health
                        elseif Aim.priority=="strongest" then score=-hum.Health
                        else score=(Vector2.new(sp.X,sp.Y)-center).Magnitude end
                        if score<bestScore then bestScore=score; best=char end end end end end end
    return best end
local function aimGetAimPos(char)
    local target=(Aim.headAim and char:FindFirstChild("Head")) or char:FindFirstChild("HumanoidRootPart")
    if not target then return nil end
    local pos=target.Position
    if Aim.type==4 or Aim.type==5 then
        local hrp=char:FindFirstChild("HumanoidRootPart")
        if hrp then pos=pos+(hrp.AssemblyLinearVelocity or Vector3.zero)*Aim.predictFactor end end
    return pos end
local function aimTick()
    if not Aim.active then return end
    local char=aimFindTarget(); if not char then return end
    local pos=aimGetAimPos(char); if not pos then return end
    if Aim.type==3 then
        local tool=lp.Character and lp.Character:FindFirstChildOfClass("Tool")
        if tool then
            local myHrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if myHrp then
                local oldCF=myHrp.CFrame
                myHrp.CFrame=CFrame.new(myHrp.Position,Vector3.new(pos.X,myHrp.Position.Y,pos.Z))
                pcall(function() tool:Activate() end)
                task.wait()
                myHrp.CFrame=oldCF end end
        return end
    if Aim.type==5 then
        local cam=workspace.CurrentCamera
        cam.CFrame=CFrame.new(cam.CFrame.Position,pos)
        local tool=lp.Character and lp.Character:FindFirstChildOfClass("Tool")
        if tool then pcall(function() tool:Activate() end) end
        return end
    local cam=workspace.CurrentCamera
    local desired=CFrame.new(cam.CFrame.Position,pos)
    if Aim.type==2 then cam.CFrame=desired
    else cam.CFrame=cam.CFrame:Lerp(desired,Aim.smoothness) end end
local function aimStart()
    if Aim.active then return end
    Aim.active=true
    if not Aim.bound then
        pcall(function()
            RunService:BindToRenderStep("DJ_Aimbot",Enum.RenderPriority.Camera.Value+1,aimTick) end)
        Aim.bound=true end
    toast("Aimbot tipo "..Aim.type.." ON","warn") end
local function aimStop()
    if not Aim.active then return end
    Aim.active=false
    if Aim.bound then
        pcall(function() RunService:UnbindFromRenderStep("DJ_Aimbot") end)
        Aim.bound=false end
    toast("Aimbot OFF") end
makeButton(Caos,{label="Tipo 1: Suave",onClick=function()
    if Aim.active then aimStop() end; Aim.type=1; toast("Aimbot T1") end})
makeButton(Caos,{label="Tipo 2: Snap",onClick=function()
    if Aim.active then aimStop() end; Aim.type=2; toast("Aimbot T2") end})
makeButton(Caos,{label="Tipo 3: Silent",onClick=function()
    if Aim.active then aimStop() end; Aim.type=3; toast("Aimbot T3","warn") end})
makeButton(Caos,{label="Tipo 4: Predictive",onClick=function()
    if Aim.active then aimStop() end; Aim.type=4; toast("Aimbot T4") end})
makeButton(Caos,{label="Tipo 5: Instant Hit",onClick=function()
    if Aim.active then aimStop() end; Aim.type=5; toast("Aimbot T5") end})
makeToggle(Caos,{label="Aimbot ON/OFF",initial=false,onChange=function(v)
    if v then aimStart() else aimStop() end end})
makeToggle(Caos,{label="Apuntar a la cabeza",initial=false,onChange=function(v)
    Aim.headAim=v; toast(v and "Cabeza ON" or "Torso ON") end})
makeButton(Caos,{label="Prioridad: Más cercano",onClick=function() Aim.priority="closest"; toast("closest") end})
makeButton(Caos,{label="Prioridad: Más débil",onClick=function() Aim.priority="weakest"; toast("weakest") end})
makeButton(Caos,{label="Prioridad: Más fuerte",onClick=function() Aim.priority="strongest"; toast("strongest") end})
makeSlider(Caos,{label="Suavizado",min=5,max=100,initial=35,onChange=function(v) Aim.smoothness=v/100 end})
makeSlider(Caos,{label="FOV detección",min=40,max=500,initial=260,onChange=function(v) Aim.fov=v end})
makeSlider(Caos,{label="Distancia máx",min=30,max=1000,initial=500,onChange=function(v) Aim.maxDistance=v end})
makeSlider(Caos,{label="Factor predicción",min=0,max=50,initial=15,onChange=function(v) Aim.predictFactor=v/100 end})

sectionTitle(Caos,"ESP")
local EspMaxDist={value=500}
local EspMode={value="full"}
makeButton(Caos,{label="ESP: Full",onClick=function() EspMode.value="full"; toast("ESP full") end})
makeButton(Caos,{label="ESP: Solo Nombre",onClick=function() EspMode.value="name"; toast("ESP name") end})
makeButton(Caos,{label="ESP: Solo Caja",onClick=function() EspMode.value="box"; toast("ESP box") end})
makeButton(Caos,{label="ESP: Solo Vida",onClick=function() EspMode.value="health"; toast("ESP health") end})
local ESP={active=false,boxes={},folder=nil}
local function ensureESPFolder()
    if ESP.folder and ESP.folder.Parent then return ESP.folder end
    ESP.folder=new("Folder",{Name="DJ_ESP_Folder",Parent=ScreenGui})
    return ESP.folder end
local function clearESPFor(plr)
    local d=ESP.boxes[plr]; if not d then return end
    if d.billboard and d.billboard.Parent then d.billboard:Destroy() end
    ESP.boxes[plr]=nil end
local function clearAllESP()
    local list={}; for plr in pairs(ESP.boxes) do table.insert(list,plr) end
    for _,plr in ipairs(list) do clearESPFor(plr) end end
local function createESPFor(plr)
    if plr==lp or ESP.boxes[plr] then return end
    local char=plr.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local mode=EspMode.value
    local bb=new("BillboardGui",{Name="DJ_ESP_"..plr.Name,Adornee=hrp,
        Size=UDim2.new(0,46,0,76),StudsOffsetWorldSpace=Vector3.new(0,2.4,0),
        AlwaysOnTop=true,MaxDistance=EspMaxDist.value,LightInfluence=0,
        Parent=ensureESPFolder()})
    local box=new("Frame",{Name="Box",BackgroundTransparency=1,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),Visible=(mode=="full" or mode=="box"),Parent=bb})
    new("UIStroke",{Color=CONFIG.Colors.ACCENT,Thickness=1.5,Parent=box})
    local nameLbl=new("TextLabel",{BackgroundTransparency=1,Text=plr.Name,
        TextColor3=CONFIG.Colors.TEXT,Font=Enum.Font.GothamBold,TextSize=11,
        TextStrokeTransparency=0,TextStrokeColor3=CONFIG.Colors.BG,
        Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,0,-14),
        Visible=(mode=="full" or mode=="name"),Parent=bb})
    local distLbl=new("TextLabel",{BackgroundTransparency=1,Text="0m",
        TextColor3=CONFIG.Colors.ACCENT_2,Font=Enum.Font.Code,TextSize=10,
        TextStrokeTransparency=0,TextStrokeColor3=CONFIG.Colors.BG,
        Size=UDim2.new(1,0,0,12),Position=UDim2.new(0,0,0,-28),
        Visible=(mode=="full" or mode=="name"),Parent=bb})
    local hpBg=new("Frame",{BackgroundColor3=Color3.fromRGB(20,26,18),BorderSizePixel=0,
        Size=UDim2.new(1,0,0,5),Position=UDim2.new(0,0,1,4),
        Visible=(mode=="full" or mode=="health"),Parent=bb},{corner(2)})
    local hpFill=new("Frame",{BackgroundColor3=CONFIG.Colors.ACCENT,BorderSizePixel=0,
        Size=UDim2.new(1,0,1,0),Parent=hpBg},{corner(2)})
    ESP.boxes[plr]={billboard=bb,box=box,hpFill=hpFill,distLbl=distLbl,nameLbl=nameLbl,hum=hum,mode=mode} end
local function espUpdate()
    if not ESP.active then return end
    for plr in pairs(ESP.boxes) do if not plr.Parent or plr==lp then clearESPFor(plr) end end
    local myHrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp then
            local d=ESP.boxes[plr]
            if not d then createESPFor(plr)
            else
                if d.mode~=EspMode.value then
                    d.box.Visible=(EspMode.value=="full" or EspMode.value=="box")
                    d.nameLbl.Visible=(EspMode.value=="full" or EspMode.value=="name")
                    d.distLbl.Visible=(EspMode.value=="full" or EspMode.value=="name")
                    d.mode=EspMode.value end
                local char=plr.Character
                local hrp=char and char:FindFirstChild("HumanoidRootPart")
                local hum=char and char:FindFirstChildOfClass("Humanoid")
                if hrp and d.billboard.Adornee~=hrp then d.billboard.Adornee=hrp end
                if hum then
                    d.hum=hum
                    local pct=math.clamp(hum.Health/math.max(hum.MaxHealth,1),0,1)
                    d.hpFill.Size=UDim2.new(pct,0,1,0)
                    if pct>0.5 then d.hpFill.BackgroundColor3=CONFIG.Colors.ACCENT
                    elseif pct>0.25 then d.hpFill.BackgroundColor3=CONFIG.Colors.ACCENT_2
                    else d.hpFill.BackgroundColor3=CONFIG.Colors.ERR end
                    d.billboard.Enabled=hum.Health>0
                    if myHrp and hrp then
                        d.distLbl.Text=string.format("%.0fm",(myHrp.Position-hrp.Position).Magnitude) end end end end end end
local function espStart()
    if ESP.active then return end
    ESP.active=true; ensureESPFolder()
    for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp then createESPFor(plr) end end
    toast("ESP ON") end
local function espStop()
    if not ESP.active then return end
    ESP.active=false; clearAllESP()
    if ESP.folder and ESP.folder.Parent then ESP.folder:Destroy() end
    ESP.folder=nil; toast("ESP OFF") end
makeToggle(Caos,{label="ESP Box + Vida + Distancia",initial=false,onChange=function(v)
    if v then espStart() else espStop() end end})
makeSlider(Caos,{label="Distancia máx ESP",min=30,max=2000,initial=500,onChange=function(v)
    EspMaxDist.value=v
    for _,d in pairs(ESP.boxes) do if d.billboard then d.billboard.MaxDistance=v end end end})

sectionTitle(Caos,"SKELETON ESP")
local Skeleton={active=false,lines={}}
local skelPairs={
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},
}
local function skelEnsure(plr)
    if Skeleton.lines[plr] then return Skeleton.lines[plr] end
    local list={}
    for i=1,#skelPairs do
        local line=new("Frame",{Name="SkelLine_"..i,
            BackgroundColor3=CONFIG.Colors.ERR,BorderSizePixel=0,
            AnchorPoint=Vector2.new(0,0.5),Size=UDim2.fromOffset(0,1),
            ZIndex=3,Visible=false,Parent=ScreenGui})
        table.insert(list,line) end
    Skeleton.lines[plr]=list
    return list end
local function skelClear()
    for plr,list in pairs(Skeleton.lines) do
        for _,line in ipairs(list) do if line and line.Parent then line:Destroy() end end end
    Skeleton.lines={} end
local function skelUpdate()
    if not Skeleton.active then return end
    local cam=workspace.CurrentCamera; if not cam then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp then
            local c=plr.Character
            local hum=c and c:FindFirstChildOfClass("Humanoid")
            if c and hum and hum.Health>0 then
                local list=skelEnsure(plr)
                for i,pair in ipairs(skelPairs) do
                    local a=c:FindFirstChild(pair[1])
                    local b=c:FindFirstChild(pair[2])
                    local line=list[i]
                    if a and b and line then
                        local ap,aOn=cam:WorldToViewportPoint(a.Position)
                        local bp,bOn=cam:WorldToViewportPoint(b.Position)
                        if aOn and bOn then
                            local aV=Vector2.new(ap.X,ap.Y)
                            local bV=Vector2.new(bp.X,bp.Y)
                            local delta=bV-aV
                            line.Position=UDim2.fromOffset(aV.X,aV.Y)
                            line.Size=UDim2.fromOffset(delta.Magnitude,1)
                            line.Rotation=math.deg(math.atan2(delta.Y,delta.X))
                            line.Visible=true
                        else line.Visible=false end
                    elseif line then line.Visible=false end end end end end end
makeToggle(Caos,{label="Skeleton ESP",initial=false,onChange=function(v)
    Skeleton.active=v
    if v then toast("Skeleton ON","warn")
    else skelClear(); toast("Skeleton OFF") end end})

sectionTitle(Caos,"WALL CHECKER")
local WallCheck={active=false,conn=nil}
makeToggle(Caos,{label="Wall Checker",initial=false,onChange=function(v)
    WallCheck.active=v
    if v then
        if not WallCheck.conn then
            WallCheck.conn=RunService.Heartbeat:Connect(function()
                if not WallCheck.active then return end
                local myHrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                if not myHrp then return end
                for plr,d in pairs(ESP.boxes) do
                    local c=plr.Character
                    local hrp=c and c:FindFirstChild("HumanoidRootPart")
                    if hrp and d.box then
                        local params=RaycastParams.new()
                        params.FilterType=Enum.RaycastFilterType.Exclude
                        params.FilterDescendantsInstances={lp.Character,c}
                        local res=workspace:Raycast(myHrp.Position,hrp.Position-myHrp.Position,params)
                        local s2=d.box:FindFirstChildOfClass("UIStroke")
                        if s2 then s2.Color=res and CONFIG.Colors.ERR or CONFIG.Colors.ACCENT end end end end) end
        toast("Wall Checker ON")
    else
        if WallCheck.conn then WallCheck.conn:Disconnect(); WallCheck.conn=nil end
        toast("Wall Checker OFF") end end})

sectionTitle(Caos,"HIDE NAMETAGS")
local HideTags={active=false,backup={}}
makeToggle(Caos,{label="Ocultar nametags ajenos",initial=false,onChange=function(v)
    HideTags.active=v
    if v then
        HideTags.backup={}
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=lp and plr.Character then
                local head=plr.Character:FindFirstChild("Head")
                local hd=head and head:FindFirstChildOfClass("BillboardGui")
                if hd then HideTags.backup[hd]=hd.Enabled; hd.Enabled=false end end end
        toast("Nametags OFF")
    else
        for obj,en in pairs(HideTags.backup) do if obj and obj.Parent then obj.Enabled=en end end
        HideTags.backup={}; toast("Nametags ON") end end})

sectionTitle(Caos,"HIGHLIGHT Y CHAMS")
local Highlight={active=false,instances={},conn=nil}
local function hlClear()
    for plr,hl in pairs(Highlight.instances) do
        if hl and hl.Parent then hl:Destroy() end
        Highlight.instances[plr]=nil end end
local function hlApply(plr)
    if plr==lp then return end
    local char=plr.Character; if not char then return end
    local hl=Highlight.instances[plr]
    if hl and hl.Parent~=char then hl:Destroy(); hl=nil end
    if not hl then
        hl=new("Highlight",{Name="DJ_HL_"..plr.Name,
            FillColor=CONFIG.Colors.ACCENT,OutlineColor=CONFIG.Colors.ACCENT,
            FillTransparency=0.6,OutlineTransparency=0,
            DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,Parent=char})
        Highlight.instances[plr]=hl end end
local function hlStart()
    if Highlight.active then return end
    Highlight.active=true
    for _,plr in ipairs(Players:GetPlayers()) do hlApply(plr) end
    if not Highlight.conn then
        Highlight.conn=RunService.Heartbeat:Connect(function()
            if not Highlight.active then return end
            for _,plr in ipairs(Players:GetPlayers()) do hlApply(plr) end end) end
    toast("Highlight ON") end
local function hlStop()
    if not Highlight.active then return end
    Highlight.active=false
    if Highlight.conn then Highlight.conn:Disconnect(); Highlight.conn=nil end
    hlClear(); toast("Highlight OFF") end
makeToggle(Caos,{label="Highlight (silueta verde)",initial=false,onChange=function(v)
    if v then hlStart() else hlStop() end end})
local Chams={active=false,backup={},conn=nil}
local function chamsApply(char)
    if not char then return end
    for _,part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            if not Chams.backup[part] then Chams.backup[part]={mat=part.Material,col=part.Color} end
            part.Material=Enum.Material.Neon; part.Color=CONFIG.Colors.ACCENT end end end
local function chamsRestore()
    for part,data in pairs(Chams.backup) do
        if part and part.Parent then pcall(function() part.Material=data.mat; part.Color=data.col end) end end
    Chams.backup={} end
local function chamsStart()
    if Chams.active then return end
    Chams.active=true
    for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp then chamsApply(plr.Character) end end
    if not Chams.conn then
        Chams.conn=RunService.Heartbeat:Connect(function()
            if not Chams.active then return end
            for _,plr in ipairs(Players:GetPlayers()) do if plr~=lp then chamsApply(plr.Character) end end end) end
    toast("Chams ON","warn") end
local function chamsStop()
    if not Chams.active then return end
    Chams.active=false; chamsRestore()
    if Chams.conn then Chams.conn:Disconnect(); Chams.conn=nil end
    toast("Chams OFF") end
makeToggle(Caos,{label="Chams (neón a otros)",initial=false,onChange=function(v)
    if v then chamsStart() else chamsStop() end end})

sectionTitle(Caos,"TRACERS")
local Tracers={active=false,lines={}}
local function tracerGetLine(plr)
    local line=Tracers.lines[plr]
    if not line or not line.Parent then
        line=new("Frame",{Name="DJ_Tracer_"..plr.Name,
            BackgroundColor3=CONFIG.Colors.ACCENT,BorderSizePixel=0,
            AnchorPoint=Vector2.new(0,0.5),Size=UDim2.fromOffset(0,1),
            ZIndex=1,Visible=false,Parent=ScreenGui})
        Tracers.lines[plr]=line end
    return line end
local function tracerUpdate()
    if not Tracers.active then return end
    local cam=workspace.CurrentCamera; if not cam then return end
    local size=cam.ViewportSize
    local origin=Vector2.new(size.X/2,size.Y)
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp then
            local char=plr.Character
            local head=char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
            local hum=char and char:FindFirstChildOfClass("Humanoid")
            local line=tracerGetLine(plr)
            if head and hum and hum.Health>0 then
                local sp,onScreen=cam:WorldToViewportPoint(head.Position)
                if onScreen then
                    local delta=Vector2.new(sp.X,sp.Y)-origin
                    line.Position=UDim2.fromOffset(origin.X,origin.Y)
                    line.Size=UDim2.fromOffset(delta.Magnitude,1)
                    line.Rotation=math.deg(math.atan2(delta.Y,delta.X))
                    line.Visible=true
                else line.Visible=false end
            else if line then line.Visible=false end end end end
    for plr,line in pairs(Tracers.lines) do
        if not plr.Parent then line:Destroy(); Tracers.lines[plr]=nil end end end
local function tracersStart()
    if Tracers.active then return end
    Tracers.active=true; toast("Tracers ON") end
local function tracersStop()
    if not Tracers.active then return end
    Tracers.active=false
    for _,line in pairs(Tracers.lines) do pcall(function() line:Destroy() end) end
    Tracers.lines={}; toast("Tracers OFF") end
makeToggle(Caos,{label="Tracers",initial=false,onChange=function(v)
    if v then tracersStart() else tracersStop() end end})

sectionTitle(Caos,"KILL AURA")
local KillAura={active=false,radius=15,cooldown=0.18,last=0,conn=nil}
local function killAuraTick()
    if not KillAura.active then return end
    local now=os.clock(); if now-KillAura.last<KillAura.cooldown then return end
    local char=lp.Character
    local myHrp=char and char:FindFirstChild("HumanoidRootPart"); if not myHrp then return end
    local nearest,nearestDist=nil,KillAura.radius
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp then
            local c=plr.Character
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            local hum=c and c:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health>0 then
                local d=(myHrp.Position-hrp.Position).Magnitude
                if d<nearestDist then nearestDist=d; nearest=hrp end end end end
    if not nearest then return end
    KillAura.last=now
    local cam=workspace.CurrentCamera
    if cam then cam.CFrame=CFrame.new(cam.CFrame.Position,nearest.Position) end
    local tool=char:FindFirstChildOfClass("Tool")
    if tool then pcall(function() tool:Activate() end) end
    if type(mouse1click)=="function" then pcall(mouse1click)
    elseif type(mouse1press)=="function" and type(mouse1release)=="function" then
        pcall(mouse1press); task.delay(0.05,function() pcall(mouse1release) end) end end
local function killAuraStart()
    if KillAura.active then return end
    KillAura.active=true
    if not KillAura.conn then KillAura.conn=RunService.Heartbeat:Connect(killAuraTick) end
    toast("Kill Aura ON","warn") end
local function killAuraStop()
    if not KillAura.active then return end
    KillAura.active=false
    if KillAura.conn then KillAura.conn:Disconnect(); KillAura.conn=nil end
    toast("Kill Aura OFF") end
makeToggle(Caos,{label="Kill Aura",initial=false,onChange=function(v)
    if v then killAuraStart() else killAuraStop() end end})
makeSlider(Caos,{label="Radio",min=5,max=60,initial=15,onChange=function(v) KillAura.radius=v end})
makeSlider(Caos,{label="Cooldown (ms)",min=50,max=1000,initial=180,onChange=function(v) KillAura.cooldown=v/1000 end})

sectionTitle(Caos,"AUTO-CLICKER Y AUTO-PARRY")
local AutoClick={active=false,delay=0.1}
makeToggle(Caos,{label="Auto-Clicker",initial=false,onChange=function(v)
    AutoClick.active=v
    if v then
        toast("Auto-Clicker ON","warn")
        task.spawn(function()
            while AutoClick.active do
                if type(mouse1click)=="function" then pcall(mouse1click)
                elseif type(mouse1press)=="function" and type(mouse1release)=="function" then
                    pcall(mouse1press); task.wait(0.03); pcall(mouse1release) end
                task.wait(AutoClick.delay) end end)
    else toast("Auto-Clicker OFF") end end})
makeSlider(Caos,{label="Intervalo auto-click (ms)",min=30,max=1000,initial=100,onChange=function(v) AutoClick.delay=v/1000 end})
local AutoParry={active=false,key=Enum.KeyCode.F,cooldown=0.4,last=0,conn=nil}
local function autoParryTick()
    if not AutoParry.active then return end
    local now=os.clock(); if now-AutoParry.last<AutoParry.cooldown then return end
    local myHrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp then
            local c=plr.Character
            local hrp=c and c:FindFirstChild("HumanoidRootPart")
            local hum=c and c:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health>0 then
                if (myHrp.Position-hrp.Position).Magnitude<8 then
                    AutoParry.last=now
                    pcall(function()
                        game:GetService("VirtualInputManager"):SendKeyEvent(true,AutoParry.key,false,game)
                        task.wait(0.08)
                        game:GetService("VirtualInputManager"):SendKeyEvent(false,AutoParry.key,false,game) end)
                    return end end end end end
makeToggle(Caos,{label="Auto-Parry",initial=false,onChange=function(v)
    AutoParry.active=v
    if v then
        if not AutoParry.conn then AutoParry.conn=RunService.Heartbeat:Connect(autoParryTick) end
        toast("Auto-Parry ON","warn")
    else
        if AutoParry.conn then AutoParry.conn:Disconnect(); AutoParry.conn=nil end
        toast("Auto-Parry OFF") end end})

sectionTitle(Caos,"ITEM ESP Y KILL EFFECT")
local ItemESP={active=false,boxes={},folder=nil}
local function ensureItemFolder()
    if ItemESP.folder and ItemESP.folder.Parent then return ItemESP.folder end
    ItemESP.folder=new("Folder",{Name="DJ_ItemESP",Parent=ScreenGui})
    return ItemESP.folder end
local function itemEspScan()
    if not ItemESP.active then return end
    local folder=ensureItemFolder()
    local found={}
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Tool") and obj.Parent~=lp.Character then
            found[obj]=true
            if not ItemESP.boxes[obj] then
                local bb=new("BillboardGui",{Name="DJ_ItemESP_"..obj.Name,Adornee=obj,
                    Size=UDim2.new(0,140,0,30),AlwaysOnTop=true,MaxDistance=500,
                    LightInfluence=0,Parent=folder})
                new("TextLabel",{BackgroundTransparency=1,Text="📦 "..obj.Name,
                    TextColor3=CONFIG.Colors.ACCENT_2,Font=Enum.Font.GothamBold,
                    TextSize=11,TextStrokeTransparency=0,TextStrokeColor3=CONFIG.Colors.BG,
                    Size=UDim2.new(1,0,1,0),Parent=bb})
                ItemESP.boxes[obj]=bb end end end
    for obj,bb in pairs(ItemESP.boxes) do
        if not found[obj] or not obj.Parent then
            if bb and bb.Parent then bb:Destroy() end
            ItemESP.boxes[obj]=nil end end end
makeToggle(Caos,{label="Item ESP",initial=false,onChange=function(v)
    ItemESP.active=v
    if v then ensureItemFolder(); itemEspScan(); toast("Item ESP ON")
    else
        for _,bb in pairs(ItemESP.boxes) do if bb then bb:Destroy() end end
        ItemESP.boxes={}
        if ItemESP.folder and ItemESP.folder.Parent then ItemESP.folder:Destroy() end
        ItemESP.folder=nil; toast("Item ESP OFF") end end})
local KillEffect={active=false,seen={}}
local function spawnKillEffect(pos)
    local part=new("Part",{Size=Vector3.new(1,1,1),Position=pos,Anchored=true,
        CanCollide=false,Transparency=0.4,Material=Enum.Material.Neon,
        Color=CONFIG.Colors.ERR,Shape=Enum.PartType.Ball,Parent=workspace})
    local att=new("Attachment",{Parent=part})
    local emit=new("ParticleEmitter",{Texture="rbxasset://textures/particles/explosion01_implosion_main.dds",
        Rate=0,Lifetime=NumberRange.new(0.6,1.0),Speed=NumberRange.new(8,14),
        SpreadAngle=Vector2.new(180,180),Color=ColorSequence.new(CONFIG.Colors.ERR),
        Size=NumberSequence.new(0.4,0),LightEmission=1,Parent=att})
    emit:Emit(30)
    task.delay(1.2,function() if part and part.Parent then part:Destroy() end end) end
makeToggle(Caos,{label="Kill Effect",initial=false,onChange=function(v)
    KillEffect.active=v; toast(v and "Kill Effect ON" or "Kill Effect OFF") end})

--============================================================
-- COMBATE
--============================================================
local Combate=Pages["COMBATE"]
sectionTitle(Combate,"AUTO BLOCK Y GODMODE")
local AutoBlock={active=false,key=Enum.KeyCode.F,conn=nil}
makeToggle(Combate,{label="Auto Block (mantener F)",initial=false,onChange=function(v)
    AutoBlock.active=v
    if v then
        if not AutoBlock.conn then
            AutoBlock.conn=RunService.Heartbeat:Connect(function()
                if not AutoBlock.active then return end
                pcall(function()
                    game:GetService("VirtualInputManager"):SendKeyEvent(true,AutoBlock.key,false,game) end) end) end
        toast("Auto Block ON","warn")
    else
        if AutoBlock.conn then AutoBlock.conn:Disconnect(); AutoBlock.conn=nil end
        pcall(function() game:GetService("VirtualInputManager"):SendKeyEvent(false,AutoBlock.key,false,game) end)
        toast("Auto Block OFF") end end})
local Godmode={active=false,conn=nil}
makeToggle(Combate,{label="Godmode Local",initial=false,onChange=function(v)
    Godmode.active=v
    if v then
        if not Godmode.conn then
            Godmode.conn=RunService.Heartbeat:Connect(function()
                if not Godmode.active then return end
                local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health=hum.MaxHealth end end) end
        toast("Godmode ON","warn")
    else
        if Godmode.conn then Godmode.conn:Disconnect(); Godmode.conn=nil end
        toast("Godmode OFF") end end})
sectionTitle(Combate,"AUTO COMBO Y M1 SPAM")
local M1Spam={active=false,delay=0.08}
makeToggle(Combate,{label="M1 Spam",initial=false,onChange=function(v)
    M1Spam.active=v
    if v then
        toast("M1 Spam ON","warn")
        task.spawn(function()
            while M1Spam.active do
                local tool=lp.Character and lp.Character:FindFirstChildOfClass("Tool")
                if tool then pcall(function() tool:Activate() end) end
                if type(mouse1click)=="function" then pcall(mouse1click)
                elseif type(mouse1press)=="function" and type(mouse1release)=="function" then
                    pcall(mouse1press); task.wait(0.03); pcall(mouse1release) end
                task.wait(M1Spam.delay) end end)
    else toast("M1 Spam OFF") end end})
makeSlider(Combate,{label="Intervalo M1 (ms)",min=30,max=500,initial=80,onChange=function(v) M1Spam.delay=v/1000 end})
sectionTitle(Combate,"TELEKINESIS")
local Telekinesis={active=false,target=nil,conn=nil}
local function tkGetNearestPart()
    local myHrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not myHrp then return nil end
    local nearest,nd=nil,math.huge
    for _,obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored and obj:IsDescendantOf(workspace) then
            if not obj:IsDescendantOf(lp.Character) then
                local d=(myHrp.Position-obj.Position).Magnitude
                if d<30 and d<nd then nd=d; nearest=obj end end end end
    return nearest end
makeButton(Combate,{label="Agarrar objeto más cercano",onClick=function()
    local p=tkGetNearestPart()
    if p then Telekinesis.target=p
        if not Telekinesis.conn then
            Telekinesis.conn=RunService.RenderStepped:Connect(function()
                if not Telekinesis.target or not Telekinesis.target.Parent then return end
                local cam=workspace.CurrentCamera
                pcall(function()
                    Telekinesis.target.CFrame=CFrame.new(cam.CFrame.Position+cam.CFrame.LookVector*8) end) end) end
        toast("Agarré: "..p.Name,"warn") end end})
makeButton(Combate,{label="Soltar objeto",onClick=function()
    Telekinesis.target=nil
    if Telekinesis.conn then Telekinesis.conn:Disconnect(); Telekinesis.conn=nil end
    toast("Objeto soltado") end})

--============================================================
-- EXTRAS
--============================================================
local Extras=Pages["EXTRAS"]
sectionTitle(Extras,"JOYSTICK PARA FLY")
makeDesc(Extras,"Activa Fly en DOOFUS y usa este joystick para moverte.")
local Joystick={active=false,frame=nil,knob=nil,dragging=false,dir=Vector3.zero,conn=nil}
local function joyStart()
    if Joystick.active then return end
    Joystick.active=true
    local f=new("Frame",{Name="DJ_Joystick",BackgroundColor3=CONFIG.Colors.PANEL,
        BackgroundTransparency=0.4,BorderSizePixel=0,
        AnchorPoint=Vector2.new(0.5,1),Position=UDim2.new(0.25,0,1,-40),
        Size=UDim2.fromOffset(130,130),ZIndex=20,Parent=ScreenGui},
        {corner(65),stroke(CONFIG.Colors.ACCENT,2)})
    local k=new("Frame",{Name="Knob",BackgroundColor3=CONFIG.Colors.ACCENT,
        BorderSizePixel=0,AnchorPoint=Vector2.new(0.5,0.5),
        Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(50,50),
        ZIndex=21,Parent=f},{corner(25)})
    Joystick.frame=f; Joystick.knob=k
    track(f.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            Joystick.dragging=true end end))
    track(f.InputChanged:Connect(function(input)
        if Joystick.dragging and (input.UserInputType==Enum.UserInputType.Touch
        or input.UserInputType==Enum.UserInputType.MouseMovement) then
            local rel=Vector2.new(input.Position.X,input.Position.Y)-f.AbsolutePosition-f.AbsoluteSize/2
            local mag=math.min(rel.Magnitude/(f.AbsoluteSize.X/2),1)
            local dir=rel.Unit
            if rel.Magnitude>0 then
                Joystick.dir=Vector3.new(dir.X,0,dir.Y)*mag
                Joystick.knob.Position=UDim2.new(0.5,dir.X*45,0.5,dir.Y*45) end end end))
    track(UIS.InputEnded:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.Touch or input.UserInputType==Enum.UserInputType.MouseButton1 then
            Joystick.dragging=false; Joystick.dir=Vector3.zero
            Joystick.knob.Position=UDim2.fromScale(0.5,0.5) end end))
    if not Joystick.conn then
        Joystick.conn=RunService.RenderStepped:Connect(function()
            if not Joystick.active then return end
            if Fly and Fly.active and Fly.bodyVel then
                local cam=workspace.CurrentCamera; if not cam then return end
                local move=cam.CFrame.RightVector*Joystick.dir.X+cam.CFrame.LookVector*Joystick.dir.Z
                Fly.bodyVel.Velocity=move*Fly.speed end end) end
    toast("Joystick ON") end
local function joyStop()
    if not Joystick.active then return end
    Joystick.active=false
    if Joystick.frame then Joystick.frame:Destroy(); Joystick.frame=nil end
    if Joystick.conn then Joystick.conn:Disconnect(); Joystick.conn=nil end
    toast("Joystick OFF") end
makeToggle(Extras,{label="Joystick virtual (para Fly)",initial=false,onChange=function(v)
    if v then joyStart() else joyStop() end end})
sectionTitle(Extras,"LISTA DE JUGADORES")
local PlayerList={active=false,frame=nil,rows={},conn=nil}
local function plClear()
    if PlayerList.frame then PlayerList.frame:Destroy(); PlayerList.frame=nil end
    PlayerList.rows={} end
local function plRefresh()
    if not PlayerList.active or not PlayerList.frame then return end
    for _,row in pairs(PlayerList.rows) do if row and row.Parent then row:Destroy() end end
    PlayerList.rows={}
    local y=0
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=lp then
            local row=new("Frame",{Name="Row_"..plr.Name,BackgroundColor3=CONFIG.Colors.PANEL_2,
                BorderSizePixel=0,Size=UDim2.new(1,0,0,26),
                Position=UDim2.new(0,0,0,y),Parent=PlayerList.frame},{corner(6)})
            y=y+30
            new("TextLabel",{BackgroundTransparency=1,Text=plr.Name,TextColor3=CONFIG.Colors.TEXT,
                Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
                Size=UDim2.new(0.6,0,1,0),Position=UDim2.new(0,6,0,0),Parent=row})
            local btnS=new("TextButton",{BackgroundColor3=CONFIG.Colors.ACCENT,BorderSizePixel=0,
                Text="ESP",TextColor3=CONFIG.Colors.BG,Font=Enum.Font.GothamBold,
                TextSize=11,Size=UDim2.fromOffset(36,20),
                Position=UDim2.new(1,-80,0.5,0),AnchorPoint=Vector2.new(0,0.5),
                Parent=row},{corner(4)})
            track(btnS.Activated:Connect(function()
                local char=plr.Character
                local hrp=char and char:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local hl=hrp:FindFirstChild("DJ_TempHL")
                    if hl then hl:Destroy()
                    else new("Highlight",{Name="DJ_TempHL",FillColor=Color3.fromRGB(255,255,0),
                        OutlineColor=Color3.fromRGB(255,255,0),FillTransparency=0.5,
                        DepthMode=Enum.HighlightDepthMode.AlwaysOnTop,Parent=hrp}) end end end))
            local btnT=new("TextButton",{BackgroundColor3=CONFIG.Colors.ACCENT_2,BorderSizePixel=0,
                Text="TP",TextColor3=CONFIG.Colors.BG,Font=Enum.Font.GothamBold,
                TextSize=11,Size=UDim2.fromOffset(36,20),
                Position=UDim2.new(1,-40,0.5,0),AnchorPoint=Vector2.new(0,0.5),
                Parent=row},{corner(4)})
            track(btnT.Activated:Connect(function()
                local myHrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
                local char=plr.Character
                local hrp=char and char:FindFirstChild("HumanoidRootPart")
                if myHrp and hrp then myHrp.CFrame=hrp.CFrame+Vector3.new(0,0,4)
                    toast("TP a "..plr.Name,"warn") end end))
            PlayerList.rows[plr]=row end end end
makeToggle(Extras,{label="Lista de jugadores clickeable",initial=false,onChange=function(v)
    PlayerList.active=v
    if v then
        local f=new("Frame",{Name="DJ_PlayerList",BackgroundColor3=CONFIG.Colors.BG,
            BackgroundTransparency=0.15,BorderSizePixel=0,
            Size=UDim2.new(0,220,0,300),Position=UDim2.new(1,-230,0.5,-150),
            ZIndex=15,Parent=ScreenGui},{corner(10),stroke(CONFIG.Colors.ACCENT,1),pad(6)})
        new("TextLabel",{BackgroundTransparency=1,Text="Jugadores",TextColor3=CONFIG.Colors.ACCENT,
            Font=Enum.Font.GothamBold,TextSize=13,Size=UDim2.new(1,0,0,20),Parent=f})
        local holder=new("ScrollingFrame",{BackgroundTransparency=1,BorderSizePixel=0,
            Size=UDim2.new(1,0,1,-24),Position=UDim2.new(0,0,0,22),
            CanvasSize=UDim2.new(0,0,0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,
            ScrollBarThickness=3,Parent=f})
        PlayerList.frame=holder
        plRefresh()
        if not PlayerList.conn then
            PlayerList.conn=Players.PlayerAdded:Connect(plRefresh)
            track(Players.PlayerRemoving:Connect(plRefresh)) end
        toast("Lista ON")
    else
        plClear()
        if PlayerList.conn then PlayerList.conn:Disconnect(); PlayerList.conn=nil end
        toast("Lista OFF") end end})
sectionTitle(Extras,"ATAJOS RÁPIDOS")
makeButton(Extras,{label="Modo PvP",onClick=function()
    if not KillAura.active then killAuraStart() end
    if not ESP.active then espStart() end
    if not Highlight.active then hlStart() end
    toast("Modo PvP ON","warn") end})
makeButton(Extras,{label="Modo Stealth",onClick=function()
    pcall(function() killAuraStop() end)
    pcall(function() espStop() end)
    pcall(function() hlStop() end)
    pcall(function() chamsStop() end)
    pcall(function() tracersStop() end)
    pcall(function() aimStop() end)
    pcall(function() hbStop() end)
    toast("Modo Stealth ON") end})
makeButton(Extras,{label="Screenshot",onClick=function()
    if type(saveinstance)=="function" then pcall(saveinstance); toast("saveinstance","warn")
    elseif type(screenshot)=="function" then pcall(screenshot); toast("screenshot","warn")
    else toast("No disponible","err") end end})

--============================================================
-- DRAG / MIN / CLOSE
--============================================================
local function makeDraggable(frame,handle)
    local dragging,dragStart,startPos
    track(handle.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1
        or input.UserInputType==Enum.UserInputType.Touch then
            dragging=true; dragStart=input.Position; startPos=frame.Position
            track(input.Changed:Connect(function()
                if input.UserInputState==Enum.UserInputState.End then dragging=false end end)) end end))
    track(handle.InputChanged:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseMovement
        or input.UserInputType==Enum.UserInputType.Touch then
            if dragging then
                local delta=input.Position-dragStart
                frame.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+delta.X,
                    startPos.Y.Scale,startPos.Y.Offset+delta.Y) end end end)) end
makeDraggable(Main,TitleBar)
local miniBtn
local function createMini()
    miniBtn=new("TextButton",{BackgroundColor3=CONFIG.Colors.ACCENT,BorderSizePixel=0,
        Text="J",TextColor3=CONFIG.Colors.BG,Font=Enum.Font.GothamBlack,TextSize=20,
        Size=UDim2.fromOffset(52,52),Position=UDim2.new(0,16,0,80),
        Visible=false,Parent=ScreenGui},{corner(26),stroke(CONFIG.Colors.ACCENT_2,2)})
    track(miniBtn.Activated:Connect(function()
        Main.Visible=true; miniBtn.Visible=false end))
    makeDraggable(miniBtn,miniBtn) end
createMini()
track(BtnMin.Activated:Connect(function() Main.Visible=false; miniBtn.Visible=true end))
track(BtnClose.Activated:Connect(function()
    if type(ENV.DOOFUS_JERRY_V1_CLEANUP)=="function" then
        ENV.DOOFUS_JERRY_V1_CLEANUP(); ENV.DOOFUS_JERRY_V1_CLEANUP=nil end end))
track(BtnPanic.Activated:Connect(function()
    if type(ENV.DOOFUS_JERRY_V1_CLEANUP)=="function" then
        ENV.DOOFUS_JERRY_V1_CLEANUP(); ENV.DOOFUS_JERRY_V1_CLEANUP=nil end end))

--============================================================
-- LOOPS
--============================================================
local frameCount=0
local lastUpdate=os.clock()
local lastEsp=0
local function readPing()
    local ok,v=pcall(function() return Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
    if ok and typeof(v)=="number" then return math.floor(v+0.5) end
    return nil end
track(RunService.Heartbeat:Connect(function()
    local now2=os.clock()
    if ESP.active and now2-lastEsp>=0.2 then lastEsp=now2; espUpdate() end
    if ItemESP.active then itemEspScan() end
    if AutoJump.active then
        local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum and hum.FloorMaterial~=Enum.Material.Air then
            hum:ChangeState(Enum.HumanoidStateType.Jumping) end end
    if Sprint.active then
        local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed=Sprint.speed end end
    if AutoPickup.active then
        local char=lp.Character
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if hrp and char then
            for _,obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("Tool") and obj.Parent~=char then
                    local handle=obj:FindFirstChild("Handle")
                    if handle and (hrp.Position-handle.Position).Magnitude<AutoPickup.radius then
                        pcall(function()
                            local hum=char:FindFirstChildOfClass("Humanoid")
                            if hum then hum:EquipTool(obj) end end) end end end end end
    if KillEffect.active then
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr~=lp then
                local c=plr.Character
                local hum=c and c:FindFirstChildOfClass("Humanoid")
                local hrp=c and c:FindFirstChild("HumanoidRootPart")
                if hum and hrp and hum.Health<=0 and not KillEffect.seen[plr] then
                    KillEffect.seen[plr]=true
                    spawnKillEffect(hrp.Position)
                elseif hum and hum.Health>0 then KillEffect.seen[plr]=nil end end end end
    if AntiFling.active then
        local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            local v=hrp.AssemblyLinearVelocity
            if v and v.Magnitude>200 then
                hrp.AssemblyLinearVelocity=Vector3.zero
                hrp.AssemblyAngularVelocity=Vector3.zero end end end
    if AntiVoid.active then
        local hrp=lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            if hrp.Position.Y<50 then
                if AntiVoid.lastSafe then hrp.CFrame=CFrame.new(AntiVoid.lastSafe) end
            else
                AntiVoid.timer=AntiVoid.timer+1
                if AntiVoid.timer>=20 then AntiVoid.lastSafe=hrp.Position; AntiVoid.timer=0 end end end end
end))
track(RunService.RenderStepped:Connect(function()
    frameCount=frameCount+1
    local now=os.clock()
    if Tracers.active then tracerUpdate() end
    if Skeleton.active then skelUpdate() end
    if now-lastUpdate>=0.5 then
        local fps=math.floor(frameCount/(now-lastUpdate)+0.5)
        LblFps.Text=tostring(fps)
        frameCount=0; lastUpdate=now
        local ping=readPing()
        LblPing.Text=ping and (ping.." ms") or "n/d"
        LblPlayers.Text=tostring(#Players:GetPlayers())
        local elapsed=os.time()-SessionStart
        LblSession.Text=string.format("%02d:%02d:%02d",
            math.floor(elapsed/3600),math.floor((elapsed%3600)/60),elapsed%60)
        pcall(function()
            local mem=Stats:GetTotalMemoryUsageMb()
            if mem then LblMem.Text=string.format("%.0f MB",mem) end end)
        local up=tick()-ServerStart
        LblUptime.Text=string.format("%02d:%02d:%02d",
            math.floor(up/3600),math.floor((up%3600)/60),math.floor(up%60))
        if WMExtra.active and WMLabel then
            WMLabel.Text=string.format("%s v%s · %s · %d fps · %s · %d kills",
                CONFIG.NAME,CONFIG.VERSION,lp.Name,fps,
                ping and (ping.."ms") or "n/d",WMExtra.kills) end
        local char=lp.Character
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        local hrp=char and char:FindFirstChild("HumanoidRootPart")
        if hum then
            LblHp.Text=string.format("%d / %d",math.floor(hum.Health),math.floor(hum.MaxHealth))
            LblHp.TextColor3=hum.Health>0 and CONFIG.Colors.OK or CONFIG.Colors.ERR
        else LblHp.Text="sin Humanoid"; LblHp.TextColor3=CONFIG.Colors.SUBTEXT end
        if hrp then
            local p=hrp.Position
            LblPos.Text=string.format("%.0f, %.0f, %.0f",p.X,p.Y,p.Z)
            local v3=hrp.AssemblyLinearVelocity or Vector3.zero
            LblVel.Text=string.format("%.0f st/s",Vector3.new(v3.X,0,v3.Z).Magnitude)
        else LblPos.Text="sin personaje"; LblVel.Text="—" end end
end))

--============================================================
-- CLEANUP
--============================================================
ENV.DOOFUS_JERRY_V1_CLEANUP=function()
    pcall(hbStop); pcall(espStop); pcall(aimStop); pcall(killAuraStop)
    pcall(flyStop); pcall(chClear)
    pcall(chamsRestore); pcall(bigHeadRestore); pcall(ghostRestore)
    pcall(neonRestore); pcall(camFxClear); pcall(skelClear); pcall(hlClear)
    pcall(tracersStop)
    if Chams.conn then Chams.conn:Disconnect(); Chams.conn=nil end
    if HitMarker.conn then HitMarker.conn:Disconnect(); HitMarker.conn=nil end
    if HitMarker.frame then HitMarker.frame:Destroy(); HitMarker.frame=nil end
    if WallCheck.conn then WallCheck.conn:Disconnect(); WallCheck.conn=nil end
    if FpsCap.conn then FpsCap.conn:Disconnect(); FpsCap.conn=nil end
    if MuteAll.conn then MuteAll.conn:Disconnect(); MuteAll.conn=nil end
    if Highlight.conn then Highlight.conn:Disconnect(); Highlight.conn=nil end
    if AutoParry.conn then AutoParry.conn:Disconnect(); AutoParry.conn=nil end
    if AutoBlock.conn then AutoBlock.conn:Disconnect(); AutoBlock.conn=nil end
    if Godmode.conn then Godmode.conn:Disconnect(); Godmode.conn=nil end
    if InfJump.conn then InfJump.conn:Disconnect(); InfJump.conn=nil end
    if Noclip.conn then Noclip.conn:Disconnect(); Noclip.conn=nil end
    if AntiAFK.conn then AntiAFK.conn:Disconnect(); AntiAFK.conn=nil end
    if ChatLog.conn then ChatLog.conn:Disconnect(); ChatLog.conn=nil end
    if AutoRespawn.conn then AutoRespawn.conn:Disconnect(); AutoRespawn.conn=nil end
    if DoubleJump.conn then DoubleJump.conn:Disconnect(); DoubleJump.conn=nil end
    if Dash.conn then Dash.conn:Disconnect(); Dash.conn=nil end
    if Joystick.conn then Joystick.conn:Disconnect(); Joystick.conn=nil end
    if PlayerList.conn then PlayerList.conn:Disconnect(); PlayerList.conn=nil end
    if Bhop.conn then Bhop.conn:Disconnect(); Bhop.conn=nil end
    if CrouchSpam.conn then CrouchSpam.conn:Disconnect(); CrouchSpam.conn=nil end
    if LookAt.conn then LookAt.conn:Disconnect(); LookAt.conn=nil end
    if CamLock.conn then CamLock.conn:Disconnect(); CamLock.conn=nil end
    if AntiRagdoll.conn then AntiRagdoll.conn:Disconnect(); AntiRagdoll.conn=nil end
    if AutoTool.conn then AutoTool.conn:Disconnect(); AutoTool.conn=nil end
    if Telekinesis.conn then Telekinesis.conn:Disconnect(); Telekinesis.conn=nil end
    if Blur.eff then Blur.eff:Destroy(); Blur.eff=nil end
    if DOF.eff then DOF.eff:Destroy(); DOF.eff=nil end
    if CNametag.bg then CNametag.bg:Destroy(); CNametag.bg=nil end
    if ItemESP.folder and ItemESP.folder.Parent then ItemESP.folder:Destroy() end
    if Joystick.frame then Joystick.frame:Destroy() end
    if PlayerList.frame then PlayerList.frame:Destroy() end
    if ZoomUnlim.backup then pcall(function() lp.CameraMaxZoomDistance=ZoomUnlim.backup end) end
    if CharScale.backup then
        local hum=lp.Character and lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            pcall(function()
                hum.BodyHeightScale=CharScale.backup.H
                hum.BodyWidthScale=CharScale.backup.W
                hum.BodyDepthScale=CharScale.backup.D
                hum.HeadScale=CharScale.backup.Hd end) end end
    for p,c in pairs(CharColor.backup) do
        if p and p.Parent then pcall(function() p.Color=c end) end end
    CharColor.backup={}
    for s,vol in pairs(MuteAll.backup) do
        if s and s.Parent then pcall(function() s.Volume=vol end) end end
    MuteAll.backup={}
    for acc,parent in pairs(NoAcc.backup) do
        if acc and parent then pcall(function() acc.Parent=parent end) end end
    NoAcc.backup={}
    for d,t in pairs(DecalsBackup) do
        if d and d.Parent then pcall(function() d.Transparency=t end) end end
    workspace.Gravity=gravityBackup
    disconnectAll()
    if ScreenGui and ScreenGui.Parent then ScreenGui:Destroy() end
    log("INIT","Cleanup ejecutado")
end

selectTab("JERRY")
log("INIT",CONFIG.NAME.." v"..CONFIG.VERSION.." cargado")
toast("Doofus Jerry V2.3.0 cargado","warn")