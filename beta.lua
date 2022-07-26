--[[

                      REDLINE

                      .=%%=.                      
                    .+%%@@%%+.                    
                  .+%*-%**%-*%+.                  
                .+%*: =@::@= :*%+.                
              .+%*:  .%+  +%.  :*%+.              
            .+%*:    +@.  .@+    :*%+.            
          .+%*:     .@+    +@.     :*%+.          
        .+%*:       +%.    .%+       :*%+.        
      .+%*:        :@=      =@:        :*%+.      
    .=#*.          *%.      .%*          .*#=.    
    *@%=--:.      :@-        -@:      .:--=%@*    
    .=%@*+****++=-##.        .##-=++****+*@%=.    
       =#*:  :-=+*@%**+=--=+**%@*+=-:  :*#=       
        .+%*:     +@::-=++=-::@+     :*%+.        
          .+%*:   .@=        =@.   :*%+.          
            .+%*:  +@.      .@+  :*%+.            
              .+%*:.%+      +%.:*%+.              
                .+%**@:    :@**%+.                
                  .+%@*    *@%+.                  
                    .=%*::*%=.                    
                      .+##+.                      
]]--


-- redline might be rewritten soon since all of this code is absolute shit




if (_G.RLLOADED) then
    
    if (_G.RLNOTIF) then
        _G.RLNOTIF('Oops','Redline is already loaded. Destroy the current instance by pressing [END]', 5, 'warn', true)
        return
    else
    
        if (printconsole) then 
            printconsole('Already loaded Redline', 255, 64, 64)
            printconsole('Destroy the current script by pressing [End]', 192, 192, 255)
            return
        else
            warn('Already loaded Redline\nDestroy the current script by pressing [End]')
            return
        end
    end
end

if (Drawing == nil) then
    warn('Unfortunately, your executor is missing the Drawing library and is not supported by Redline.')
    warn('Consider upgrading to an exploit like Fluxus or KRNL')
    return
end

-- { Make redline folder } --
if (not isfile('REDLINE')) then
    makefolder('REDLINE')
end

-- { Version } --
local REDLINEVER = 'v0.6.4'


local IndentLevel1 = 8
local IndentLevel2 = 14
local IndentLevel3 = 22
local RightIndent = 14

-- { Wait for load } --
if not game:IsLoaded() then game.Loaded:Wait() end

-- { Microops } --

-- Services
local servContext   = game:GetService('ContextActionService')
local servGui       = game:GetService('GuiService')
local servHttp      = game:GetService('HttpService')
local servNetwork   = game:GetService('NetworkClient')
local servPlayers   = game:GetService('Players')
local servRun       = game:GetService('RunService')
local servTeleport  = game:GetService('TeleportService')
local servTween     = game:GetService('TweenService')
local servInput     = game:GetService('UserInputService')
local servVim       = game:GetService('VirtualInputManager')

-- Colors
local colRgb,colHsv,colNew = Color3.fromRGB, Color3.fromHSV, Color3.new
-- UDim2
local dimOffset, dimScale, dimNew = UDim2.fromOffset, UDim2.fromScale, UDim2.new
-- Instances
local instNew = Instance.new
local drawNew = Drawing.new
-- Vectors
local vec3, vec2 = Vector3.new, Vector2.new
-- CFrames
local cfrNew = CFrame.new
-- Task
local wait, delay, spawn = task.wait, task.delay, task.spawn
-- Math
local mathRand = math.random
local mathFloor = math.floor
local mathClamp = math.clamp
-- Table
local tabInsert,tabRemove,tabClear,tabFind = table.insert, table.remove, table.clear, table.find
-- Os
local date = os.date
local tick = tick
-- Other stuff
local workspace = workspace
local ipairs = ipairs
local game = game
local isrbxactive = isrbxactive


if (isrbxactive == nil) then
    
    local active = true
    servInput.WindowFocused:Connect(function() 
        active = true 
    end)
    servInput.WindowFocusReleased:Connect(function() 
        active = false
    end)
    getgenv().isrbxactive = function() 
        return active
    end
    isrbxactive = isrbxactive
end



-- { Load in some shit } --
local function DecodeThemeJson(json) 
    
    -- Strip away comments
    json = json:gsub('//[^\n]+','')
    -- Convert JSON to lua
    local stuff = servHttp:JSONDecode(json)
    -- Get the theme data
    local theme = stuff['theme']
    
    -- Set up locals
    local RLTHEME
    local RLTHEMEFONT
    do
        RLTHEME = {}
        RLTHEMEFONT = theme['Font']
        
        -- Make a switch statement
        local switch = {}
        switch['Generic_Outline']       = 'go' -- Thank god im switching away from indices
        switch['Generic_Shadow']        = 'gs'
        switch['Generic_Window']        = 'gw'
        switch['Generic_Enabled']       = 'ge'
        switch['Background_Menu']       = 'bm'
        switch['Background_Module']     = 'bo'
        switch['Background_Setting']    = 'bs'
        switch['Background_Dropdown']   = 'bd'
        switch['Hovering_Menu']         = 'hm'
        switch['Hovering_Module']       = 'ho'
        switch['Hovering_Setting']      = 'hs'
        switch['Hovering_Dropdown']     = 'hd'
        switch['Slider_Foreground']     = 'sf'
        switch['Slider_Background']     = 'sb'
        switch['Text_Main']             = 'tm'
        switch['Text_Outline']          = 'to'
        
        -- Go through all theme data and do stuff
        for Index, ThemeSetting in pairs(theme) do
            -- If this setting isnt a table (like the font) then continue
            if (type(ThemeSetting) ~= 'table') then continue end            
            -- If this setting doesn't have a valid id then continue
            if (not switch[Index]) then continue end
            -- Get theme options
            local Color1 = ThemeSetting['Color']
            local Color2 = ThemeSetting['Color2']
            local IsGradient = ThemeSetting['Gradient']
            local Transpar = ThemeSetting['Transparency']
            
            -- Add to RLTHEME
            local _ = {
                colRgb(Color1[1],Color1[2],Color1[3]);
                Transpar;
                IsGradient;
                Color2 and colRgb(Color2[1],Color2[2],Color2[3]);
                
                
            }
            RLTHEME[switch[Index]] = _
        end
    end
    
    
    -- Return
    return RLTHEME, RLTHEMEFONT
end

if (isfile('REDLINE/theme.jsonc')) then
    _G.RLLOADERROR = 0
    
    local ThemeData, Font
    pcall(function()
        local FileData = readfile('REDLINE/theme.jsonc')
        ThemeData, Font = DecodeThemeJson(FileData)
    end)
    
    if (ThemeData and Font) then
        _G.RLTHEMEDATA = ThemeData
        _G.RLTHEMEFONT = Font
    else
        _G.RLLOADERROR = 2 -- Couldn't load theme properly (JSON decoder failed)
    end
end

-- ! WARNING ! --
-- SHITTY THEME CODE BELOW
-- SKIP DOWN LIKE 2000 LINES TO GET TO THE GOOD STUFF


-- { Theme } --
local RLTHEMEDATA, RLTHEMEFONT do 
    RLTHEMEFONT = _G.RLTHEMEFONT or 'SourceSans'
    if (RLTHEMEFONT:match('https://')) then
        -- syn v3 forwards compatibility
        -- doubt this works but maybe it does
        
        local req = nil or
            (type(syn) == 'table' and syn.request) or 
            (type(http) == 'table' and http.request) or 
            (type(fluxus) == 'table' and fluxus.request) or
            http_request or request
        
        if (req) then
            local _ = req{
                Method = 'GET',
                Url = RLTHEMEFONT
            }
            if (_.Success) then
                writefile('rl-temp.ttf', _.Body)
                local works = pcall(function()
                    RLTHEMEFONT = (getsynasset or getcustomasset or fakeasset or getfakeasset)('temp.ttf')
                end)
                if (not works) then
                    RLTHEMEFONT = 'SourceSans'  
                end
                delfile('rl-temp.ttf')
            end
        else
            RLTHEMEFONT = 'SourceSans' 
        end
    end
    
    RLTHEMEDATA = _G.RLTHEMEDATA or {} do
        RLTHEMEDATA['go'] = RLTHEMEDATA['go'] or {}
        RLTHEMEDATA['gs'] = RLTHEMEDATA['gs'] or {}
        RLTHEMEDATA['gw'] = RLTHEMEDATA['gw'] or {}
        RLTHEMEDATA['ge'] = RLTHEMEDATA['ge'] or {}
        RLTHEMEDATA['bm'] = RLTHEMEDATA['bm'] or {}
        RLTHEMEDATA['bo'] = RLTHEMEDATA['bo'] or {}
        RLTHEMEDATA['bs'] = RLTHEMEDATA['bs'] or {}
        RLTHEMEDATA['bd'] = RLTHEMEDATA['bd'] or {}
        RLTHEMEDATA['hm'] = RLTHEMEDATA['hm'] or {}
        RLTHEMEDATA['ho'] = RLTHEMEDATA['ho'] or {}
        RLTHEMEDATA['hs'] = RLTHEMEDATA['hs'] or {}
        RLTHEMEDATA['hd'] = RLTHEMEDATA['hd'] or {}
        RLTHEMEDATA['sf'] = RLTHEMEDATA['sf'] or {}
        RLTHEMEDATA['sb'] = RLTHEMEDATA['sb'] or {}
        RLTHEMEDATA['tm'] = RLTHEMEDATA['tm'] or {}
        RLTHEMEDATA['to'] = RLTHEMEDATA['to'] or {}
    end
    -- so many fucking tables my god
    do 
        -- generic
        RLTHEMEDATA['go'][1]   = RLTHEMEDATA['go'][1]  or colRgb(075, 075, 080); -- outline color
        RLTHEMEDATA['gs'][1]   = RLTHEMEDATA['gs'][1]  or colRgb(005, 005, 010); -- shadow
        RLTHEMEDATA['gw'][1]   = RLTHEMEDATA['gw'][1]  or colRgb(023, 022, 027); -- window background
        RLTHEMEDATA['ge'][1]   = RLTHEMEDATA['ge'][1]  or colRgb(225, 035, 061); -- enabled
        -- backgrounds
        RLTHEMEDATA['bm'][1]   = RLTHEMEDATA['bm'][1]  or colRgb(035, 035, 040); -- header background
        RLTHEMEDATA['bo'][1]   = RLTHEMEDATA['bo'][1]  or colRgb(030, 030, 035); -- object background
        RLTHEMEDATA['bs'][1]   = RLTHEMEDATA['bs'][1]  or colRgb(025, 025, 030); -- setting background
        RLTHEMEDATA['bd'][1]   = RLTHEMEDATA['bd'][1]  or colRgb(020, 020, 025); -- dropdown background
        -- backgrounds selected
        RLTHEMEDATA['hm'][1]   = RLTHEMEDATA['hm'][1]  or colRgb(038, 038, 043); -- header hovering
        RLTHEMEDATA['ho'][1]   = RLTHEMEDATA['ho'][1] or colRgb(033, 033, 038); -- object hovering
        RLTHEMEDATA['hs'][1]   = RLTHEMEDATA['hs'][1] or colRgb(028, 028, 033); -- setting hovering
        RLTHEMEDATA['hd'][1]   = RLTHEMEDATA['hd'][1] or colRgb(023, 023, 028); -- dropdown hovering
        -- slider 
        RLTHEMEDATA['sf'][1]   = RLTHEMEDATA['sf'][1] or colRgb(225, 075, 080); -- slider foreground
        RLTHEMEDATA['sb'][1]   = RLTHEMEDATA['sb'][1] or colRgb(033, 033, 038); -- slider background
        -- text   
        RLTHEMEDATA['tm'][1]   = RLTHEMEDATA['tm'][1] or colRgb(255, 255, 255); -- main text
        RLTHEMEDATA['to'][1]   = RLTHEMEDATA['to'][1] or colRgb(020, 020, 025); -- outline
    end
    do 
        RLTHEMEDATA['go'][2]   = RLTHEMEDATA['go'][2]  or 0;
        RLTHEMEDATA['gs'][2]   = RLTHEMEDATA['gs'][2]  or 0;
        RLTHEMEDATA['gw'][2]   = RLTHEMEDATA['gw'][2]  or 0.2;
        RLTHEMEDATA['ge'][2]   = RLTHEMEDATA['ge'][2]  or 0.7;
        RLTHEMEDATA['bm'][2]   = RLTHEMEDATA['bm'][2]  or 0;
        RLTHEMEDATA['bo'][2]   = RLTHEMEDATA['bo'][2]  or 0;
        RLTHEMEDATA['bs'][2]   = RLTHEMEDATA['bs'][2]  or 0;
        RLTHEMEDATA['bd'][2]   = RLTHEMEDATA['bd'][2]  or 0;
        RLTHEMEDATA['hm'][2]   = RLTHEMEDATA['hm'][2]  or 0;
        RLTHEMEDATA['ho'][2]   = RLTHEMEDATA['ho'][2]  or 0;
        RLTHEMEDATA['hs'][2]   = RLTHEMEDATA['hs'][2]  or 0;
        RLTHEMEDATA['hd'][2]   = RLTHEMEDATA['hd'][2]  or 0;
        RLTHEMEDATA['sf'][2]   = RLTHEMEDATA['sf'][2]  or 0;
        RLTHEMEDATA['sb'][2]   = RLTHEMEDATA['sb'][2]  or 0;
        RLTHEMEDATA['tm'][2]   = RLTHEMEDATA['tm'][2]  or 0;
        RLTHEMEDATA['to'][2]   = RLTHEMEDATA['to'][2]  or 0;
    end
    
    do 
        RLTHEMEDATA['go'][3]  = RLTHEMEDATA['go'][3] or false;
    end
end

-- { UI functions / variables } --
local gradient,twn,ctwn,getnext,stroke,round,uierror
do
    do
        local g1
        if (RLTHEMEDATA['go'][3]) then 
            g1 = ColorSequence.new{
                ColorSequenceKeypoint.new(0, RLTHEMEDATA['go'][1]);
                ColorSequenceKeypoint.new(1, RLTHEMEDATA['go'][4]);
            }
        end
        gradient = function(parent)
            local _ = instNew('UIGradient')
            _.Rotation = 45
            --_.Transparency = parent.Transparency
            _.Color = g1
            _.Parent = parent
        
            return _
        end
    end
    stroke = function(parent,mode, trans) 
        local _ = instNew('UIStroke')
        _.ApplyStrokeMode = mode or 'Contextual'
        _.Thickness = 1
        
        _.Transparency = trans or RLTHEMEDATA['go'][2]
        
        if (RLTHEMEDATA['go'][3]) then
            gradient(_) 
            _.Color = colNew(1,1,1)
        else
            _.Color = RLTHEMEDATA['go'][1]
        end
        
        _.Parent = parent
        return _
    end
    
    local info1, info2 = TweenInfo.new(0.1,10,1), TweenInfo.new(0.3,10,1)
    function twn(twn_target, twn_settings, twn_long) 
        local tween = servTween:Create(
            twn_target,
            twn_long and info2 or info1,
            twn_settings
        )
        tween:Play()
        return tween
    end
    function ctwn(twn_target, twn_settings, twn_dur, twn_style, twn_dir) 
        local tween = servTween:Create(
            twn_target,
            TweenInfo.new(twn_dur,twn_style or 10,twn_dir or 1),
            twn_settings
        )
        tween:Play()
        return tween
    end
    function getnext() 
        local a = ''
        for i = 1, 5 do a = a .. utf8.char(mathRand(50,2000)) end 
        return a 
    end
    function round(num, place) 
        return mathFloor(((num+(place*.5)) / place)) * place
    end
    function uierror(func, prop, type) 
        error(('%s failed; %s is not of type %s'):format(func,prop,type), 3)
    end
end



local W_WindowOpen = false or false
local RGBCOLOR
-- { UI } --
local ui = {} do 
    
    local ui_Hotkeys = {}
    local ui_Connections = {}
    local ui_Menus = {}
    local ui_Widgets = {}
    local ui_Modules = {}
    
    local rgbinsts = {}
    
    local monitor_resolution = servGui:GetScreenResolution()
    local monitor_inset = servGui:GetGuiInset()
    
    -- connections
    ui_Connections['i'] = servInput.InputBegan:Connect(function(io, gpe) 
        if (gpe == false and io.UserInputType.Value == 8) then
            local kcv = io.KeyCode.Value
            for i = 1, #ui_Hotkeys do 
                local hk = ui_Hotkeys[i]
                if (hk[1] == kcv) then
                    hk[2]()
                end
            end
        end
    end)
    do
        local rgbtime = 0
        
        ui_Connections['r'] = servRun.RenderStepped:Connect(function(dt) 
            if (not isrbxactive()) then return end
            
            rgbtime = (rgbtime > 1 and 0 or rgbtime)+(dt*0.1)
            RGBCOLOR = colHsv(rgbtime,0.8,1)
            for i = 1, #rgbinsts do 
                local v = rgbinsts[i]
                v[1][v[2]] = RGBCOLOR
            end
        end)
    end
    
    -- Gui creation
    local w_Screen
     local w_TooltipHeader
      local w_Tooltip
    local w_Backframe
     local w_CreditFrame
     local w_FriendsFrame
     local w_ModFrame
      local w_Help
      local w_Modal
     local w_ProfileFrame
     local w_SettingsFrame
    local w_ModList
     local w_ModListLayout
     local w_ModListTitle
    local w_MouseCursor
    
    
    local ModlistPadding = {
        dimOffset(-100, 0).X;
        dimOffset(8, 0).X;
        Enum.TextXAlignment.Left;
        'PaddingLeft';
    } 
    
    do 
        w_Screen = instNew('ScreenGui')
        w_Screen.IgnoreGuiInset = true
        w_Screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
        w_Screen.Name = getnext()
        pcall(function() 
            syn.protect_gui(w_Screen)
        end)
        w_Screen.DisplayOrder = 939393
        w_Screen.Parent = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or game.CoreGui
        
        w_Backframe = instNew('Frame')
        w_Backframe.BackgroundColor3 = RLTHEMEDATA['gw'][1]
        w_Backframe.BackgroundTransparency = RLTHEMEDATA['gw'][2]
        w_Backframe.BorderSizePixel = 0
        w_Backframe.ClipsDescendants = true
        w_Backframe.Position = dimNew(0, 0, 0, 0)
        w_Backframe.Size = dimScale(1,1)
        w_Backframe.Visible = false
        w_Backframe.Parent = w_Screen
        
        w_ModFrame = instNew('Frame')
        w_ModFrame.BackgroundTransparency = 1
        w_ModFrame.BorderSizePixel = 0
        w_ModFrame.ClipsDescendants = false
        w_ModFrame.Size = dimScale(1,1)
        w_ModFrame.Visible = true
        w_ModFrame.Parent = w_Backframe
        
        w_FriendsFrame = instNew('Frame')
        w_FriendsFrame.BackgroundTransparency = 1
        w_FriendsFrame.BorderSizePixel = 0
        w_FriendsFrame.ClipsDescendants = false
        w_FriendsFrame.Size = dimScale(1,1)
        w_FriendsFrame.Visible = false
        w_FriendsFrame.Parent = w_Backframe
        
        w_ProfileFrame = instNew('Frame')
        w_ProfileFrame.BackgroundTransparency = 1
        w_ProfileFrame.BorderSizePixel = 0
        w_ProfileFrame.ClipsDescendants = false
        w_ProfileFrame.Size = dimScale(1,1)
        w_ProfileFrame.Visible = false
        w_ProfileFrame.Parent = w_Backframe
        
        w_SettingsFrame = instNew('Frame')
        w_SettingsFrame.BackgroundTransparency = 1
        w_SettingsFrame.BorderSizePixel = 0
        w_SettingsFrame.ClipsDescendants = false
        w_SettingsFrame.Size = dimScale(1,1)
        w_SettingsFrame.Visible = false
        w_SettingsFrame.Parent = w_Backframe
        
        w_CreditFrame = instNew('Frame')
        w_CreditFrame.BackgroundTransparency = 1
        w_CreditFrame.BorderSizePixel = 0
        w_CreditFrame.ClipsDescendants = false
        w_CreditFrame.Size = dimScale(1,1)
        w_CreditFrame.Visible = false
        w_CreditFrame.Parent = w_Backframe
        
        do 
            
        end
        
        w_Modal = instNew('TextButton')
        w_Modal.Active = false
        w_Modal.BackgroundTransparency = 1
        w_Modal.Modal = true
        w_Modal.Size = dimOffset(1,1)
        w_Modal.Text = ''
        w_Modal.Parent = w_ModFrame
        
        w_Help = instNew('TextLabel')
        w_Help.AnchorPoint = vec2(1,1)
        w_Help.BackgroundTransparency = 1
        w_Help.Font = RLTHEMEFONT
        w_Help.Position = dimScale(1,1)
        w_Help.RichText = true
        w_Help.Size = dimOffset(300,300)
        w_Help.Text = ''
        w_Help.TextColor3 = RLTHEMEDATA['tm'][1]
        w_Help.TextSize = 20
        w_Help.TextStrokeColor3 = RLTHEMEDATA['to'][1]
        w_Help.TextStrokeTransparency = 0
        w_Help.TextXAlignment = 'Left'
        w_Help.TextYAlignment = 'Top'
        w_Help.Visible = false
        w_Help.ZIndex = 1
        w_Help.Parent = w_ModFrame
        
        w_ModList = instNew('Frame')
        w_ModList.AnchorPoint = vec2(0, 1)
        w_ModList.BackgroundColor3 = RLTHEMEDATA['gw'][1]
        w_ModList.BackgroundTransparency = 1
        w_ModList.BorderColor3 = RLTHEMEDATA['gs'][1]
        w_ModList.BorderMode = 'Inset'
        w_ModList.BorderSizePixel = 1
        w_ModList.Position = dimScale(0,1)
        w_ModList.Size = dimNew(0,200,0.3,0)
        w_ModList.Visible = false
        w_ModList.Parent = w_Screen
        
        w_ModListLayout = instNew('UIListLayout')
        w_ModListLayout.FillDirection = 'Vertical'
        w_ModListLayout.HorizontalAlignment = 'Left'
        w_ModListLayout.VerticalAlignment = 'Bottom'
        w_ModListLayout.Parent = w_ModList
        
        w_ModListTitle = instNew('TextLabel')
        w_ModListTitle.BackgroundTransparency = 1
        w_ModListTitle.Font = RLTHEMEFONT
        w_ModListTitle.LayoutOrder = 939
        w_ModListTitle.Size = dimNew(1, 0, 0, 30)
        w_ModListTitle.Text = ' '..'Redline '..REDLINEVER..' '
        w_ModListTitle.TextColor3 = RLTHEMEDATA['tm'][1]
        w_ModListTitle.TextSize = 24
        w_ModListTitle.TextStrokeColor3 = RLTHEMEDATA['to'][1]
        w_ModListTitle.TextStrokeTransparency = RLTHEMEDATA['to'][2]
        w_ModListTitle.TextTransparency = RLTHEMEDATA['tm'][1]
        w_ModListTitle.TextXAlignment = 'Left'
        w_ModListTitle.ZIndex = 5
        w_ModListTitle.Parent = w_ModList
        
        w_TooltipHeader = instNew('TextLabel')
        w_TooltipHeader.BackgroundColor3 = RLTHEMEDATA['bm'][1]
        w_TooltipHeader.BackgroundTransparency = RLTHEMEDATA['bm'][2]
        w_TooltipHeader.BorderSizePixel = 0
        w_TooltipHeader.Font = RLTHEMEFONT
        w_TooltipHeader.RichText = true
        w_TooltipHeader.Size = dimOffset(175,20)
        w_TooltipHeader.Text = 'Hi'
        w_TooltipHeader.TextColor3 = RLTHEMEDATA['tm'][1]
        w_TooltipHeader.TextSize = 19
        w_TooltipHeader.TextStrokeColor3 = RLTHEMEDATA['to'][1]
        w_TooltipHeader.TextStrokeTransparency = 0
        w_TooltipHeader.TextXAlignment = 'Center'
        w_TooltipHeader.Visible = false 
        w_TooltipHeader.ZIndex = 1500
        w_TooltipHeader.Parent = w_Screen
        
        stroke(w_TooltipHeader, 'Border')
        
        w_Tooltip = instNew('TextLabel')
        w_Tooltip.BackgroundColor3 = RLTHEMEDATA['gw'][1]
        w_Tooltip.BackgroundTransparency = RLTHEMEDATA['gw'][2]
        w_Tooltip.BorderSizePixel = 0
        w_Tooltip.Font = RLTHEMEFONT
        w_Tooltip.Position = dimOffset(0, 21)
        w_Tooltip.RichText = true
        w_Tooltip.Size = dimOffset(175,25)
        w_Tooltip.Text = ''
        w_Tooltip.TextColor3 = RLTHEMEDATA['tm'][1]
        w_Tooltip.TextSize = 17
        w_Tooltip.TextStrokeColor3 = RLTHEMEDATA['to'][1]
        w_Tooltip.TextStrokeTransparency = 0
        w_Tooltip.TextWrapped = true
        w_Tooltip.TextXAlignment = 'Left'
        w_Tooltip.TextYAlignment = 'Top'
        w_Tooltip.Visible = true 
        w_Tooltip.ZIndex = 1500
        w_Tooltip.Parent = w_TooltipHeader
        
        stroke(w_Tooltip, 'Border')
        
        local __ = instNew('UIPadding')
        __.PaddingLeft = dimOffset(5, 0).X
        --__.PaddingTop = dimOffset(0, 5).Y
        __.Parent = w_Tooltip
        
        w_Tooltip:GetPropertyChangedSignal('Text'):Connect(function() 
            w_Tooltip.Size = dimOffset(175,25)
            local n = dimOffset(0,5)
            for i = 1, 25 do 
                w_Tooltip.Size += n
                if (w_Tooltip.TextFits) then break end
            end
            w_Tooltip.Size += n
        end)
        
        w_MouseCursor = instNew('ImageLabel')
        w_MouseCursor.BackgroundTransparency = 1
        w_MouseCursor.Image = 'rbxassetid://8845749987'
        w_MouseCursor.ImageColor3 = RLTHEMEDATA['ge'][1]
        w_MouseCursor.ImageTransparency = 1
        w_MouseCursor.Position = dimOffset(150, 150)
        w_MouseCursor.Size = dimOffset(24, 24)
        w_MouseCursor.Visible = true
        w_MouseCursor.ZIndex = 1500
        w_MouseCursor.Parent = w_Screen
    end
    
    function ui:manageml(x1,x2,align,paddir) 
        ModlistPadding[1] = x1 and dimOffset(x1, 0).X or ModlistPadding[1]
        ModlistPadding[2] = x2 and dimOffset(x2, 0).X or ModlistPadding[2]
        ModlistPadding[4] = paddir or ModlistPadding[4]
        
        if (align and align ~= ModlistPadding[3]) then
            -- :troll
            local c = w_ModList:GetChildren()
            local _ = ModlistPadding[2]
            local __ = ModlistPadding[4]
            local ___ = __ == 'PaddingLeft' and 'PaddingRight' or __
            local ____ = dimOffset(0,0).X
            for i = 1, #c do
                local v = c[i]
                if (v.ClassName == 'TextLabel' and v ~= w_ModListTitle) then
                    v.TextXAlignment = align
                    local p = v.P
                    p[__] = _
                    p[___] = ____
                end
            end
            w_ModListTitle.TextXAlignment = align
            ModlistPadding[3] = align
        end
        
        
        return {
            w_ModList;
            w_ModListLayout;
            w_ModListTitle;
        }
    end
    
    
    
    ui_Connections['t'] = servRun.RenderStepped:Connect(function() 
        local pos = servInput:GetMouseLocation()
        local x,y = pos.X, pos.Y
        w_TooltipHeader.Position = dimOffset(x+15, y+15)
        w_MouseCursor.Position = dimOffset(x-4, y)
    end)
    
    
    local ModListEnable,ModListDisable,ModListInit,ModListModify do 
        local mods_instance = {}
        
        
        ModListEnable = function(name) 
            local b = mods_instance[name]
            
            b.TextXAlignment = ModlistPadding[3]
            b.Parent = w_ModList
            twn(b.P, {[ModlistPadding[4]] = ModlistPadding[2]},true)
            twn(b, {Size = dimNew(1, 0, 0, 24), TextTransparency = 0, TextStrokeTransparency = 0},true)
        end
        
        ModListDisable = function(name)
            local b = mods_instance[name]
            
            twn(b.P, {[ModlistPadding[4]] = ModlistPadding[1]},true)
            twn(b, {Size = dimNew(0, 0, 0, 0), TextTransparency = 1, TextStrokeTransparency = 1},true)
        end
        
        ModListModify = function(name, new) 
            mods_instance[name].Text = new
        end
        
        ModListInit = function(name) 
            local _ = instNew('TextLabel')
            _.Size = dimNew(0, 0, 0, 0)
            _.BackgroundTransparency = 1
            _.Font = RLTHEMEFONT
            _.TextXAlignment = ModlistPadding[3]
            _.TextColor3 = RLTHEMEDATA['tm'][1]
            _.TextSize = 22
            _.Text = name
            --_.Name = name
            _.RichText = true
            _.TextTransparency = 1
            _.TextStrokeTransparency = 1
            _.TextStrokeColor3 = RLTHEMEDATA['to'][1]
            _.ZIndex = 5
            
            mods_instance[name] = _
            
            tabInsert(rgbinsts, {_,'TextColor3'})
            
            
            local __ = instNew('UIPadding')
            __.Name = 'P'
            __[ModlistPadding[4]] = ModlistPadding[1]
            __.Parent = _
        end
    end
    
    -- Base class for stuff
    local base_class = {} do 
        local s1,s2 = dimNew(1,0,1,0), dimNew(0,0,1,0)
        
        
        
        -- objtype_action_actiontype
        
        -- Menu funcs
        do
            base_class.menu_toggle = function(self) 
                local t = not self.MToggled
                
                self.MToggled = t
                self.Menu.Visible = t
                twn(self.Icon, {Rotation = t and 0 or 180}, true)
            end
            base_class.menu_enable = function(self) 
                self.MToggled = true
                self.Menu.Visible = true
                twn(self.Icon, {Rotation = 0}, true)
            end
            base_class.menu_disable = function(self) 
                self.MToggled = false
                self.Menu.Visible = false
                twn(self.Icon, {Rotation = 180}, true)
            end
            base_class.menu_getstate = function(self) 
                return self.MToggled
            end
        end
        -- Module funcs
        do
            base_class.module_toggle_menu = function(self) 
                local t = not self.MToggled
                
                self.MToggled = t
                self.Menu.Visible = t
                
                twn(self.Icon, {Rotation = t and 360 or 0}, true)
                self.Icon.Text = t and '-' or '+'
            end
            base_class.module_toggle_self = function(self) 
                local t = not self.OToggled
                self.OToggled = t
                
                
                pcall(self.Flags.Toggled, t)
                pcall(self.Flags[t and 'Enabled' or 'Disabled'])
                
                twn(self.Effect, {Size = t and s1 or s2}, true)
                
                if (t) then
                    ModListEnable(self.Name)
                else
                    ModListDisable(self.Name)
                end
                return self 
            end
            base_class.module_toggle_enable = function(self) 
                self.OToggled = true
                
                pcall(self.Flags.Toggled, true)
                pcall(self.Flags.Enabled)
                
                twn(self.Effect, {Size = s1}, true)
                
                ModListEnable(self.Name)
                return self 
            end
            base_class.module_toggle_disable = function(self) 
                self.OToggled = false
                
                pcall(self.Flags.Toggled, false)
                pcall(self.Flags.Disabled)
                
                twn(self.Effect, {Size = s2}, true)
                
                ModListDisable(self.Name)
                return self
            end
            base_class.module_toggle_reset = function(self)
                if (self.OToggled) then
                    local f = self.Flags
                    pcall(f.Toggled, false)
                    pcall(f.Disabled)
                    
                    pcall(f.Toggled, true)
                    pcall(f.Enabled)
                end
            end
            base_class.module_getstate_self = function(self) return self.OToggled end
            base_class.module_getstate_menu = function(self) return self.MToggled end
            
            base_class.module_setvis = function(self, t, t2) 
                self.Root.Visible = t 
                self.Highlight.Visible = t2
            end 
            
            base_class.module_click_self = function(self) 
                pcall(self.Flags.Clicked)
                
                self.Effect.BackgroundTransparency = 0.8
                twn(self.Effect, {BackgroundTransparency = 1}, true)
            end
            base_class.module_gettext = function(self) 
                return self.Text
            end
            
        end
        -- Setting funcs
        do
            base_class.s_toggle_self = function(self) 
                local t = not self.Toggled
                
                pcall(self.Flags.Toggled, t)
                pcall(self.Flags.Enabled)
                pcall(self.Flags.Disabled)
                
                self.Toggled = t
                twn(self.Icon, {BackgroundTransparency = t and 0 or 1})
                return self
            end 
            base_class.s_toggle_enable = function(self) 
                self.Toggled = true
                
                pcall(self.Flags.Toggled, true)
                pcall(self.Flags.Enabled)
                
                twn(self.Icon, {BackgroundTransparency = 0})
                return self
            end 
            base_class.s_toggle_disable = function(self) 
                self.Toggled = false
                
                pcall(self.Flags.Toggled, false)
                pcall(self.Flags.Disabled)
                
                twn(self.Icon, {BackgroundTransparency = 1})
                return self
            end 
            base_class.s_toggle_reset = function(self) 
                if (self.Toggled) then
                    local f = self.Flags
                    pcall(f.Toggled, false)
                    pcall(f.Disabled)
                    
                    pcall(f.Toggled, true)
                    pcall(f.Enabled)
                end
            end
            base_class.s_toggle_getstate = function(self) 
                return self.Toggled
            end
            
            base_class.s_modhotkey_sethotkey = function(self) 
                local label = self.Label
                label.Text = 'Press any key...'
                
                wait(0.01);
                local c;
                c = servInput.InputBegan:Connect(function(io,gpe)
                    
                    local kcv = io.KeyCode.Value
                    if (kcv ~= 0) then
                        
                        self.Hotkey = kcv
                        label.Text = 'Hotkey: '..io.KeyCode.Name
                        
                        -- As scuffed as this is, it works
                        -- To prevent the module being bound from immediately toggling, a short delay is made
                        delay(0.01, function()
                            local n = self.Parent.Name
                            for i = 1, #ui_Hotkeys do 
                                if ui_Hotkeys[i][3] == n then
                                    tabRemove(ui_Hotkeys, i)
                                    break
                                end
                            end
                            tabInsert(ui_Hotkeys, {kcv, function() 
                                self.Parent:Toggle()
                            end, n})
                        end)
                    else
                        self.Hotkey = nil    
                        label.Text = 'Hotkey: N/A'
                        
                        local n = self.Parent.Name
                        for i = 1, #ui_Hotkeys do 
                            if ui_Hotkeys[i][3] == n then
                                tabRemove(ui_Hotkeys, i)
                                break
                            end
                        end
                    end
                    c:Disconnect()
                end)
                
            end
        
            base_class.s_modhotkey_gethotkey = function(self) 
                return self.Hotkey
            end
            
            base_class.s_hotkey_sethotkey = function(self) 
                local label = self.Label
                label.Text = 'Press any key...'
                
                wait(0.01);
                local c;
                c = servInput.InputBegan:Connect(function(io,gpe)
                    local kc = io.KeyCode
                    local kcv = kc.Value
                    if (kcv ~= 0) then
                        
                        self.Hotkey = kc
                        label.Text = self.Name..': '..kc.Name
                        
                        pcall(self.Flags.HotkeySet, kc, kcv)
                    else
                        self.Hotkey = nil    
                        label.Text = self.Name..': N/A'
                        
                        pcall(self.Flags.HotkeySet, nil, 0)
                    end
                    c:Disconnect()
                end)
            end
            
            base_class.s_hotkey_sethotkeyexplicit = function(self, kc) 
                self.Hotkey = kc
                self.Label.Text = self.Name..': '..kc.Name
                
                pcall(self.Flags.HotkeySet, kc, kc.Value)
                
                return self
            end
            
            base_class.s_hotkey_gethotkey = function(self)
                return self.Hotkey
            end
            
            
            base_class.s_dropdown_getselection = function(self) 
                return self.Selection
            end
            base_class.s_dropdown_toggle = function(self) 
                local t = not self.MToggled
                
                self.MToggled = t
                self.Menu.Visible = t
                
                pcall(self.Flags[ t and 'Opened' or 'Closed'])
                
                twn(self.Icon, {Rotation = t and 0 or 180}, true)
            end
            
            base_class.s_ddoption_select_self = function(self) 
                local parent = self.Parent
                
                local objs = parent.Objects
                for i = 1, #objs do objs[i]:Deselect() end
                
                self.Selected = true
                parent.Selection = self.Name
                pcall(parent.Flags['Changed'], self.Name, self)
                
                if (parent.Primary) then
                    local n = parent.Parent.Name 
                    ModListModify(n, n .. ' <font color="#DFDFDF">['..self.Name..']</font>')
                end
                
                twn(self.Effect, {Size = s1}, true)
                
                return self
            end
            base_class.s_ddoption_deselect_self = function(self) 
                if (self.Selected) then 
                    self.Selected = false
                    twn(self.Effect, {Size = s2}, true)
                end
                
                return self
            end
            base_class.s_ddoption_selected_getstate = function(self) 
                return self.Selected
            end
            
            base_class.s_slider_getval = function(self) return self.CurrentVal end
            base_class.s_slider_setvalnum = function(self, nval) 
                local min = self.Min
                local cval = self.CurrentVal
                local pval = self.PreviousVal

                
                cval = round(mathClamp(nval, min, self.Max), self.Step)
                
                if (pval ~= cval) then
                    pval = cval
                    local form = self.StepFormat
                    
                    self.SliderFill.Position = dimOffset(mathFloor((cval - min) * self.Ratio), 0)
                    self.SliderAmnt.Text = form:format(cval)
                    
                    if (self.Primary) then
                        local n = self.Parent.Name 
                        ModListModify(n, n .. (' <font color="#DFDFDF">('..form..')</font>'):format(cval))
                    end
                    
                    pcall(self.Flags.Changed, cval)
                end
                
                self.CurrentVal = cval
            end
            base_class.s_slider_setvalpos = function(self, xval) 
                local min = self.Min
                local cval = self.CurrentVal
                local pval = self.PreviousVal
                
                local pos_normalized = mathClamp(xval - self.SliderBg.AbsolutePosition.X, 0, self.SliderSize)
                
                cval = round((pos_normalized * self.RatioInverse)+min, self.Step)
                
                if (pval ~= cval) then
                    pval = cval
                    local form = self.StepFormat
                    
                    self.SliderFill.Position = dimOffset(mathFloor((cval - min)*self.Ratio), 0)
                    self.SliderAmnt.Text = form:format(cval)
                    
                    self.CurrentVal = cval
                    
                    if (self.Primary) then
                        local n = self.Parent.Name 
                        ModListModify(n, n .. (' <font color="#DFDFDF">('..form..')</font>'):format(cval))
                    end
                    
                    pcall(self.Flags.Changed, cval)
                end
            end
        end
        -- Button funcs
        base_class.button_click = function(self) 
            pcall(self.Flags['Clicked'])
        end
        -- Slider funcs
        base_class.slider_setval = function(self, value) 
            value = tonumber(value)
            if not value then uierror('slider_setval','value','number') end
            
            local m1,m2,m3 = self.min, self.max, self.step
            value = mathClamp(round(value, m3),m1,m2)
            
            self.setval_internal(value)
        end
        base_class.slider_getval = function(self) 
            return self.value1
        end
        -- Input funcs
        base_class.input_gettxt = function(self) 
            return self.Text
        end
        
        -- Generic funcs
        base_class.generic_tooltip = function(self, tooltip) 
            if (tooltip) then
                self.Tooltip = tostring(tooltip)    
            else
                self.Tooltip = nil
            end
            return self 
        end
        base_class.generic_connect = function(self, flagname, func) 
            if (type(func) ~= 'function' and type(func) ~= 'nil') then
                uierror('generic_connect','func','function or type nil')
            end
            if (type(flagname) ~= 'string') then
                uierror('generic_connect','flagname','string')
            end
            
            self.Flags[flagname] = func
            return self 
        end
        
        -- Creation functions
        base_class.menu_create_module = function(self, text, Type, nohotkey) 
            Type = Type or 'Toggle'
            local M_IndexOffset = self.ZIndex+1
            
            if (Type == 'Toggle') then 
                ModListInit(text)
                
                
                
                
                local m_ModuleRoot
                 local m_ModuleBackground
                  local m_ModuleEnableEffect
                   local m_ModuleEnableEffect2
                  local m_Highlight
                  local m_ModuleText
                   local m_TextPadding
                  local m_ModuleIcon
                 local m_Menu
                  local m_MenuListLayout
                
                do
                    m_ModuleRoot = instNew('ImageButton')
                    m_ModuleRoot.Size = dimNew(1, 0, 0, 25)
                    m_ModuleRoot.AutomaticSize = 'Y'
                    m_ModuleRoot.ClipsDescendants = false
                    m_ModuleRoot.BackgroundTransparency = 1
                    m_ModuleRoot.BorderSizePixel = 0
                    m_ModuleRoot.ZIndex = M_IndexOffset-1
                    m_ModuleRoot.Parent = self.Menu
                    
                     m_ModuleBackground = instNew('Frame')
                     m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['bo'][1]
                     m_ModuleBackground.BackgroundTransparency = RLTHEMEDATA['bo'][2]
                     m_ModuleBackground.BorderSizePixel = 0
                     m_ModuleBackground.Size = dimNew(1,0,0,25)
                     m_ModuleBackground.ZIndex = M_IndexOffset
                     m_ModuleBackground.Parent = m_ModuleRoot
                     
                      m_Highlight = instNew('Frame')
                      m_Highlight.Active = false
                      m_Highlight.BackgroundColor3 = RLTHEMEDATA['ge'][1]
                      m_Highlight.BackgroundTransparency = 0.9
                      m_Highlight.BorderSizePixel = 0
                      m_Highlight.Size = dimScale(1,1)
                      m_Highlight.Visible = false
                      m_Highlight.ZIndex = M_IndexOffset
                      m_Highlight.Parent = m_ModuleBackground
                      
                      m_ModuleEnableEffect = instNew('Frame')
                      m_ModuleEnableEffect.BackgroundColor3 = RLTHEMEDATA['tm'][1]
                      m_ModuleEnableEffect.BackgroundTransparency = 0.92
                      m_ModuleEnableEffect.BorderSizePixel = 0
                      m_ModuleEnableEffect.ClipsDescendants = true
                      m_ModuleEnableEffect.Size = dimNew(0,0,1,0)
                      m_ModuleEnableEffect.ZIndex = M_IndexOffset
                      m_ModuleEnableEffect.Parent = m_ModuleBackground
                      
                       m_ModuleEnableEffect2 = instNew('Frame')
                       m_ModuleEnableEffect2.BackgroundColor3 = RLTHEMEDATA['ge'][1]
                       m_ModuleEnableEffect2.BorderSizePixel = 0
                       m_ModuleEnableEffect2.Size = dimNew(0,2,1,0)
                       m_ModuleEnableEffect2.ZIndex = M_IndexOffset
                       m_ModuleEnableEffect2.Parent = m_ModuleEnableEffect
                      
                      m_ModuleText = instNew('TextLabel')
                      m_ModuleText.BackgroundTransparency = 1
                      m_ModuleText.Font = RLTHEMEFONT
                      m_ModuleText.Position = dimOffset(0, 0)
                      m_ModuleText.RichText = true
                      m_ModuleText.Size = dimScale(1, 1)
                      m_ModuleText.Text = text
                      m_ModuleText.TextColor3 = RLTHEMEDATA['tm'][1]
                      m_ModuleText.TextSize = 20
                      m_ModuleText.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                      m_ModuleText.TextStrokeTransparency = 0
                      m_ModuleText.TextXAlignment = 'Left'
                      m_ModuleText.ZIndex = M_IndexOffset
                      m_ModuleText.Parent = m_ModuleBackground
                      
                       m_TextPadding = instNew('UIPadding')
                       m_TextPadding.PaddingLeft = dimOffset(IndentLevel1, 0).X -- LEFT PADDING 1
                       m_TextPadding.Parent = m_ModuleText
                      
                      m_ModuleIcon = instNew('TextLabel')
                      m_ModuleIcon.AnchorPoint = vec2(1,0)
                      m_ModuleIcon.BackgroundTransparency = 1
                      m_ModuleIcon.Font = RLTHEMEFONT
                      m_ModuleIcon.Position = dimScale(1,0)
                      m_ModuleIcon.Rotation = 0
                      m_ModuleIcon.Size = dimOffset(25, 25)
                      m_ModuleIcon.Text = '+'
                      m_ModuleIcon.TextColor3 = RLTHEMEDATA['tm'][1]
                      m_ModuleIcon.TextSize = 18
                      m_ModuleIcon.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                      m_ModuleIcon.TextStrokeTransparency = 0
                      m_ModuleIcon.TextXAlignment = 'Center'
                      m_ModuleIcon.ZIndex = M_IndexOffset
                      m_ModuleIcon.Parent = m_ModuleBackground
                    
                    m_Menu = instNew('Frame')
                    m_Menu.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                    m_Menu.BackgroundTransparency = 1
                    m_Menu.BorderSizePixel = 0
                    m_Menu.Position = dimOffset(0,25)
                    m_Menu.Size = dimNew(1,0,0,0)
                    m_Menu.Visible = false
                    m_Menu.ZIndex = M_IndexOffset-1
                    m_Menu.Parent = m_ModuleRoot
                    
                     m_MenuListLayout = instNew('UIListLayout')
                     m_MenuListLayout.FillDirection = 'Vertical'
                     m_MenuListLayout.SortOrder = 2
                     m_MenuListLayout.HorizontalAlignment = 'Left'
                     m_MenuListLayout.VerticalAlignment = 'Top'
                     m_MenuListLayout.Parent = m_Menu
                     
                end
                    
                local M_Object = {} do 
                    M_Object.Tooltip = nil
                    
                    M_Object.MToggled = false
                    M_Object.OToggled = false
                    
                    M_Object.Flags = {} do 
                        M_Object.Flags['Enabled'] = true
                        M_Object.Flags['Disabled'] = true
                        M_Object.Flags['Toggled'] = true
                    end
                    
                    M_Object.Name = text
                    M_Object.Menu = m_Menu
                    M_Object.Icon = m_ModuleIcon
                    M_Object.Effect = m_ModuleEnableEffect
                    M_Object.ZIndex = M_IndexOffset
                    
                    M_Object.Highlight = m_Highlight
                    
                    M_Object.Parent = self
                    M_Object.Root = m_ModuleRoot
                    
                    M_Object.addToggle = base_class.module_create_toggle
                    M_Object.AddLabel = base_class.module_create_label
                    M_Object.addDropdown = base_class.module_create_dropdown
                    M_Object.addModHotkey = base_class.module_create_modhotkey
                    M_Object.AddHotkey = base_class.module_create_hotkey
                    M_Object.addSlider = base_class.module_create_slider
                    M_Object.AddInput = base_class.module_create_input
                    M_Object.AddButton = base_class.module_create_button
                    
                    M_Object.setvis = base_class.module_setvis
                    
                    M_Object.Toggle = base_class.module_toggle_self
                    M_Object.Disable = base_class.module_toggle_disable
                    M_Object.Enable = base_class.module_toggle_enable
                    M_Object.Reset = base_class.module_toggle_reset
                    
                    M_Object.ToggleMenu = base_class.module_toggle_menu
                    M_Object.getState = base_class.module_getstate_self
                    M_Object.isEnabled = base_class.module_getstate_self
                    M_Object.GetMenuState = base_class.module_getstate_menu
                    
                    M_Object.Connect = base_class.generic_connect
                    M_Object.setTooltip = base_class.generic_tooltip
                end
                
                do
                    m_ModuleBackground.InputBegan:Connect(function(io) 
                        local uitv = io.UserInputType.Value
                        if (uitv == 0) then
                            M_Object:Toggle()
                            return
                        end
                        
                        if (uitv == 1) then
                            M_Object:ToggleMenu()
                            return
                        end
                    end)
                    
                    m_ModuleBackground.MouseEnter:Connect(function() 
                        m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['ho'][1]
                        
                        
                        local tt = M_Object.Tooltip
                        if (tt) then
                            w_Tooltip.Text = tt
                            w_TooltipHeader.Text = M_Object.Name
                            w_TooltipHeader.Visible = true
                        end
                    end)
                    
                    m_ModuleBackground.MouseLeave:Connect(function() 
                        m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['bo'][1]
                        
                        if (w_Tooltip.Text == M_Object.Tooltip) then
                            w_TooltipHeader.Visible = false
                        end
                    end)
                end
                
                if (not nohotkey) then M_Object:addModHotkey() end
                
                tabInsert(ui_Modules, M_Object)
                return M_Object
            elseif (Type == 'Textbox') then
                local m_ModuleRoot
                 local m_ModuleBackground
                 local m_ModuleEnableEffect
                  local m_ModuleText
                   local m_ModulePadding
                  local m_ModuleIcon

                do
                    m_ModuleRoot = instNew('Frame')
                    m_ModuleRoot.AutomaticSize = 'Y'
                    m_ModuleRoot.BackgroundTransparency = 1
                    m_ModuleRoot.BorderSizePixel = 0
                    m_ModuleRoot.Size = dimNew(1, 0, 0, 25)
                    m_ModuleRoot.ZIndex = M_IndexOffset-1
                    m_ModuleRoot.Parent = self.Menu
                    
                     m_ModuleBackground = instNew('Frame')
                     m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['bo'][1]
                     m_ModuleBackground.BackgroundTransparency = RLTHEMEDATA['bo'][2]
                     m_ModuleBackground.BorderSizePixel = 0
                     m_ModuleBackground.Size = dimNew(1,0,0,25)
                     m_ModuleBackground.ZIndex = M_IndexOffset
                     m_ModuleBackground.Parent = m_ModuleRoot
                     
                      m_ModuleEnableEffect = instNew('Frame')
                      m_ModuleEnableEffect.BackgroundColor3 = RLTHEMEDATA['tm'][1]
                      m_ModuleEnableEffect.BackgroundTransparency = 1
                      m_ModuleEnableEffect.BorderSizePixel = 0
                      m_ModuleEnableEffect.ClipsDescendants = true
                      m_ModuleEnableEffect.Size = dimNew(1,0,1,0)
                      m_ModuleEnableEffect.ZIndex = M_IndexOffset
                      m_ModuleEnableEffect.Parent = m_ModuleBackground
                     
                     m_ModuleText = instNew('TextBox')
                     m_ModuleText.BackgroundTransparency = 1
                     m_ModuleText.ClearTextOnFocus = not nohotkey
                     m_ModuleText.Font = RLTHEMEFONT
                     m_ModuleText.Size = dimScale(1, 1)
                     m_ModuleText.Text = text
                     m_ModuleText.TextColor3 = RLTHEMEDATA['tm'][1]
                     m_ModuleText.TextSize = 20
                     m_ModuleText.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                     m_ModuleText.TextStrokeTransparency = 0
                     m_ModuleText.TextWrapped = true
                     m_ModuleText.TextXAlignment = 'Left'
                     m_ModuleText.ZIndex = M_IndexOffset
                     m_ModuleText.Parent = m_ModuleBackground
                      
                      m_ModulePadding = instNew('UIPadding')
                      m_ModulePadding.PaddingLeft = dimOffset(IndentLevel1, 0).X
                      m_ModulePadding.Parent = m_ModuleText
                     
                     m_ModuleIcon = instNew('TextLabel')
                     m_ModuleIcon.Size = dimOffset(25, 25)
                     m_ModuleIcon.Position = dimScale(1,0)
                     m_ModuleIcon.AnchorPoint = vec2(1,0)
                     m_ModuleIcon.BackgroundTransparency = 1
                     m_ModuleIcon.Font = RLTHEMEFONT
                     m_ModuleIcon.TextXAlignment = 'Center'
                     m_ModuleIcon.TextColor3 = RLTHEMEDATA['tm'][1]
                     m_ModuleIcon.TextSize = 18
                     m_ModuleIcon.Text = '🅃'
                     m_ModuleIcon.TextStrokeTransparency = 0
                     m_ModuleIcon.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                     m_ModuleIcon.Rotation = 0
                     m_ModuleIcon.ZIndex = M_IndexOffset
                     m_ModuleIcon.Parent = m_ModuleBackground
                end
                    
                local M_Object = {} do 
                    M_Object.Tooltip = nil
                    
                    
                    M_Object.Flags = {} do 
                        M_Object.Flags['Focused'] = true
                        M_Object.Flags['Unfocused'] = true
                        M_Object.Flags['TextChanged'] = true
                    end
                    
                    M_Object.Effect = m_ModuleEnableEffect
                    
                    M_Object.Name = text
                    M_Object.ZIndex = M_IndexOffset
                                        
                    M_Object.Connect = base_class.generic_connect
                    M_Object.setTooltip = base_class.generic_tooltip
                end
                
                do
                    m_ModuleBackground.MouseEnter:Connect(function() 
                        m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['ho'][1]
                        
                        
                        local tt = M_Object.Tooltip
                        if (tt) then
                            w_Tooltip.Text = tt
                            w_TooltipHeader.Text = M_Object.Name
                            w_TooltipHeader.Visible = true
                        end
                    end)
                    
                    m_ModuleBackground.MouseLeave:Connect(function() 
                        m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['bo'][1]
                        
                        if (w_Tooltip.Text == M_Object.Tooltip) then
                            w_TooltipHeader.Visible = false
                        end
                    end)
                    
                    m_ModuleText.FocusLost:Connect(function(enter) 
                        pcall(M_Object.Flags.Unfocused, m_ModuleText.Text, enter)
                        if (not nohotkey) then 
                            m_ModuleText.Text = M_Object.Name
                        end
                    end)
                    m_ModuleText.Focused:Connect(function() 
                        pcall(M_Object.Flags.Focused)
                    end)
                    m_ModuleText:GetPropertyChangedSignal('Text'):Connect(function() 
                        pcall(M_Object.Flags.TextChanged, m_ModuleText.Text)
                    end)
                end
                
                tabInsert(ui_Modules, M_Object)
                return M_Object
            elseif (Type == 'Button') then
                local m_ModuleRoot
                 local m_ModuleBackground
                  local m_Highlight
                  local m_ModuleEnableEffect
                  local m_ModuleText
                   local m_ModulePadding
                  local m_ModuleIcon

                do
                    m_ModuleRoot = instNew('Frame')
                    m_ModuleRoot.Size = dimNew(1, 0, 0, 25)
                    m_ModuleRoot.AutomaticSize = 'Y'
                    m_ModuleRoot.BackgroundTransparency = 1
                    m_ModuleRoot.BorderSizePixel = 0
                    m_ModuleRoot.ZIndex = M_IndexOffset-1
                    m_ModuleRoot.Parent = self.Menu
                    
                     m_ModuleBackground = instNew('Frame')
                     m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['bo'][1]
                     m_ModuleBackground.BackgroundTransparency = RLTHEMEDATA['bo'][2]
                     m_ModuleBackground.BorderSizePixel = 0
                     m_ModuleBackground.Size = dimNew(1,0,0,25)
                     m_ModuleBackground.ZIndex = M_IndexOffset
                     m_ModuleBackground.Parent = m_ModuleRoot
                     
                     
                      m_ModuleEnableEffect = instNew('Frame')
                      m_ModuleEnableEffect.BackgroundColor3 = RLTHEMEDATA['tm'][1]
                      m_ModuleEnableEffect.BackgroundTransparency = 1
                      m_ModuleEnableEffect.ClipsDescendants = true
                      m_ModuleEnableEffect.Size = dimNew(1,0,1,0)
                      m_ModuleEnableEffect.BorderSizePixel = 0
                      m_ModuleEnableEffect.ZIndex = M_IndexOffset
                      m_ModuleEnableEffect.Parent = m_ModuleBackground
                      
                      m_Highlight = instNew('Frame')
                      m_Highlight.Size = dimScale(1,1)
                      m_Highlight.BackgroundColor3 = RLTHEMEDATA['ge'][1]
                      m_Highlight.BackgroundTransparency = 0.9
                      m_Highlight.Visible = false
                      m_Highlight.ZIndex = M_IndexOffset
                      m_Highlight.BorderSizePixel = 0
                      m_Highlight.Parent = m_ModuleBackground
                     
                     m_ModuleText = instNew('TextLabel')
                     m_ModuleText.BackgroundTransparency = 1
                     m_ModuleText.Font = RLTHEMEFONT
                     m_ModuleText.Position = dimOffset(0, 0)
                     m_ModuleText.RichText = true
                     m_ModuleText.Size = dimNew(1, 0, 1, 0)
                     m_ModuleText.Text = text
                     m_ModuleText.TextColor3 = RLTHEMEDATA['tm'][1]
                     m_ModuleText.TextSize = 20
                     m_ModuleText.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                     m_ModuleText.TextStrokeTransparency = 0
                     m_ModuleText.TextXAlignment = 'Left'
                     m_ModuleText.ZIndex = M_IndexOffset
                     m_ModuleText.Parent = m_ModuleBackground
                     
                     m_ModulePadding = instNew('UIPadding')
                     m_ModulePadding.PaddingLeft = dimOffset(IndentLevel1, 0).X
                     m_ModulePadding.Parent = m_ModuleText
                     
                     m_ModuleIcon = instNew('ImageLabel')
                     m_ModuleIcon.AnchorPoint = vec2(1,0.5)
                     m_ModuleIcon.BackgroundTransparency = 1
                     m_ModuleIcon.Position = dimNew(1,-6, 0.5, 0)
                     m_ModuleIcon.Rotation = 0
                     m_ModuleIcon.Size = dimOffset(12, 12)
                     m_ModuleIcon.Image = 'rbxassetid://8997446977'
                     m_ModuleIcon.ImageColor3 = RLTHEMEDATA['tm'][1]
                     m_ModuleIcon.ZIndex = M_IndexOffset
                     m_ModuleIcon.Parent = m_ModuleBackground
                end
                    
                local M_Object = {} do 
                    M_Object.Tooltip = nil
                    
                    
                    M_Object.Flags = {} do 
                        M_Object.Flags['Clicked'] = true
                    end
                    
                    M_Object.setvis = base_class.module_setvis
                    M_Object.Root = m_ModuleRoot
                    
                    M_Object.Highlight = m_Highlight
                    
                    
                    M_Object.Effect = m_ModuleEnableEffect
                    
                    M_Object.Name = text
                    M_Object.ZIndex = M_IndexOffset
                    
                    M_Object.Click = base_class.module_click_self
                    
                    M_Object.Connect = base_class.generic_connect
                    M_Object.setTooltip = base_class.generic_tooltip
                end
                
                do
                    m_ModuleBackground.InputBegan:Connect(function(io) 
                        local uitv = io.UserInputType.Value
                        if (uitv == 0) then
                            M_Object:Click()
                            return
                        end
                    end)
                    
                    m_ModuleBackground.MouseEnter:Connect(function() 
                        m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['ho'][1]
                        
                        
                        local tt = M_Object.Tooltip
                        if (tt) then
                            w_Tooltip.Text = tt
                            w_TooltipHeader.Text = M_Object.Name
                            w_TooltipHeader.Visible = true
                        end
                    end)
                    
                    m_ModuleBackground.MouseLeave:Connect(function() 
                        m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['bo'][1]
                        
                        if (w_Tooltip.Text == M_Object.Tooltip) then
                            w_TooltipHeader.Visible = false
                        end
                    end)
                end
                
                tabInsert(ui_Modules, M_Object)
                return M_Object
            end
        end
        base_class.module_create_label = function(self, text) 
            text = tostring(text)
                        
            local T_IndexOffset = self.ZIndex+1
            local t_Text
             local t_Padding
            do
                t_Text = instNew('TextLabel')
                t_Text.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                t_Text.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                t_Text.BorderSizePixel = 0
                t_Text.Font = RLTHEMEFONT
                t_Text.Parent = self.Menu
                t_Text.RichText = true
                t_Text.Size = dimNew(1, 0, 0, 25)
                t_Text.Text = text
                t_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                t_Text.TextSize = 18
                t_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                t_Text.TextStrokeTransparency = 0
                t_Text.TextWrapped = true
                t_Text.TextXAlignment = 'Left'
                t_Text.TextYAlignment = 'Center'
                t_Text.ZIndex = T_IndexOffset
                
                t_Padding = instNew('UIPadding')
                t_Padding.PaddingLeft = dimOffset(IndentLevel2, 0).X -- LEFT PADDING 2
                t_Padding.Parent = t_Text
            end
            
            for i = 1, 25 do 
                if (t_Text.TextFits) then
                    break
                end
                t_Text.Size += dimOffset(0,25)
            end
                
            local T_Object = {} do 
                T_Object.Tooltip = nil
                T_Object.Toggled = false
                
                T_Object.Name = text
                T_Object.setTooltip = base_class.generic_tooltip
            end
            
            do
                t_Text.MouseEnter:Connect(function()                     
                    local tt = T_Object.Tooltip
                    if (tt) then
                        w_Tooltip.Text = tt
                        w_TooltipHeader.Text = T_Object.Name
                        w_TooltipHeader.Visible = true
                    end
                end)
                
                t_Text.MouseLeave:Connect(function() 
                    
                    if (w_Tooltip.Text == T_Object.Tooltip) then
                        w_TooltipHeader.Visible = false
                    end
                end)
            end
            
            return T_Object            
        end
        base_class.module_create_toggle = function(self, text) 
            text = tostring(text)
            
            local T_IndexOffset = self.ZIndex+1
            
            
            local t_Toggle
             local t_Box1
              local t_Box2
             local t_Text
              local t_TextPadding
            
            do
                t_Toggle = instNew('Frame')
                t_Toggle.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                t_Toggle.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                t_Toggle.BorderSizePixel = 0
                t_Toggle.Size = dimNew(1, 0, 0, 25)
                t_Toggle.ZIndex = T_IndexOffset
                t_Toggle.Parent = self.Menu
                 
                 t_Text = instNew('TextLabel')
                 t_Text.Size = dimScale(1, 1)
                 t_Text.BackgroundTransparency = 1
                 t_Text.Font = RLTHEMEFONT
                 t_Text.TextXAlignment = 'Left'
                 t_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                 t_Text.TextSize = 18
                 t_Text.Text = text
                 t_Text.TextStrokeTransparency = 0
                 t_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 t_Text.ZIndex = T_IndexOffset
                 t_Text.Parent = t_Toggle
                 
                  t_TextPadding = instNew('UIPadding')
                  t_TextPadding.PaddingLeft = dimOffset(IndentLevel2, 0).X -- LEFT PADDING 2
                  t_TextPadding.Parent = t_Text
                 
                 t_Box1 = instNew('Frame')
                 t_Box1.AnchorPoint = vec2(1,0)
                 t_Box1.BackgroundColor3 = RLTHEMEDATA['sf'][1]
                 t_Box1.BackgroundTransparency = 1
                 t_Box1.BorderSizePixel = 0
                 t_Box1.Position = dimNew(1,-RightIndent,0.5,-5) -- RIGHT PADDING
                 t_Box1.Size = dimOffset(10, 10)
                 t_Box1.ZIndex = T_IndexOffset
                 t_Box1.Parent = t_Toggle
                 
                 stroke(t_Box1)
                 
                 t_Box2 = instNew('Frame')
                 t_Box2.Size = dimOffset(8, 8)
                 t_Box2.Position = dimOffset(1,1)
                 t_Box2.BackgroundTransparency = 1
                 t_Box2.BackgroundColor3 = RLTHEMEDATA['ge'][1]
                 t_Box2.BorderSizePixel = 0
                 t_Box2.Visible = true
                 t_Box2.ZIndex = T_IndexOffset
                 t_Box2.Parent = t_Box1
            end
                
            local T_Object = {} do 
                T_Object.Tooltip = nil
                T_Object.Toggled = false
                
                T_Object.Flags = {}
                T_Object.Flags['Enabled'] = true
                T_Object.Flags['Disabled'] = true
                T_Object.Flags['Toggled'] = true
                
                T_Object.Icon = t_Box2
                T_Object.Name = text
                
                T_Object.Toggle = base_class.s_toggle_self
                T_Object.Disable = base_class.s_toggle_disable
                T_Object.Enable = base_class.s_toggle_enable
                T_Object.Reset = base_class.s_toggle_reset
                T_Object.getState = base_class.s_toggle_getstate
                T_Object.getValue = base_class.s_toggle_getstate
                T_Object.isEnabled = base_class.s_toggle_getstate
                
                T_Object.Connect = base_class.generic_connect
                T_Object.setTooltip = base_class.generic_tooltip
            end
            
            do
                t_Toggle.InputBegan:Connect(function(io) 
                    local uitv = io.UserInputType.Value
                    if (uitv == 0) then
                        T_Object:Toggle()
                        return
                    end
                end)
                
                t_Toggle.MouseEnter:Connect(function() 
                    t_Toggle.BackgroundColor3 = RLTHEMEDATA['hs'][1]
                    
                    local tt = T_Object.Tooltip
                    if (tt) then
                        w_Tooltip.Text = tt
                        w_TooltipHeader.Text = T_Object.Name
                        w_TooltipHeader.Visible = true
                    end
                end)
                
                t_Toggle.MouseLeave:Connect(function() 
                    t_Toggle.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                    
                    if (w_Tooltip.Text == T_Object.Tooltip) then
                        w_TooltipHeader.Visible = false
                    end
                end)
            end
            
            return T_Object            
        end
        base_class.module_create_dropdown = function(self, text, primary) 
            text = tostring(text)
            primary = primary or false
            
            local D_IndexOffset = self.ZIndex+1
            
            local d_Root
             local d_Header
              local d_HeaderText
               local d_TextPadding
              local d_HeaderIcon
              
              
              local d_Menu
               local d_MenuListLayout
            
            do
                d_Root = instNew('Frame')
                d_Root.Size = dimNew(1, 0, 0, 25)
                d_Root.AutomaticSize = 'Y'
                d_Root.BackgroundTransparency = 1
                d_Root.BorderSizePixel = 0
                d_Root.ZIndex = D_IndexOffset-1
                d_Root.Parent = self.Menu
            
                 d_Header = instNew('Frame')
                 d_Header.Active = true
                 d_Header.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                 d_Header.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                 d_Header.BorderSizePixel = 0
                 d_Header.Size = dimNew(1, 0, 0, 25)
                 d_Header.ZIndex = D_IndexOffset+1
                 d_Header.Parent = d_Root
                 
                  d_HeaderText = instNew('TextLabel')
                  d_HeaderText.Size = dimScale(1, 1)
                  d_HeaderText.BackgroundTransparency = 1
                  d_HeaderText.Font = RLTHEMEFONT
                  d_HeaderText.TextXAlignment = 'Left'
                  d_HeaderText.TextColor3 = RLTHEMEDATA['tm'][1]
                  d_HeaderText.TextSize = 18
                  d_HeaderText.Text = text
                  d_HeaderText.TextStrokeTransparency = 0
                  d_HeaderText.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                  d_HeaderText.ZIndex = D_IndexOffset+1
                  d_HeaderText.Parent = d_Header
                  
                   d_TextPadding = instNew('UIPadding')
                   d_TextPadding.PaddingLeft = dimOffset(IndentLevel2, 0).X -- LEFT PADDING 2
                   d_TextPadding.Parent = d_HeaderText
                  
                  d_HeaderIcon = instNew('ImageLabel')
                  d_HeaderIcon.Size = dimOffset(25, 25)
                  d_HeaderIcon.Position = dimNew(1,-RightIndent +10, 0, 0) -- RIGHT PADDING
                  d_HeaderIcon.AnchorPoint = vec2(1,0)
                  d_HeaderIcon.BackgroundTransparency = 1
                  d_HeaderIcon.ImageColor3 = RLTHEMEDATA['tm'][1]
                  d_HeaderIcon.Image = 'rbxassetid://7184113125'
                  d_HeaderIcon.Rotation = 180
                  d_HeaderIcon.ZIndex = D_IndexOffset+1
                  d_HeaderIcon.Parent = d_Header
                 
                 d_Menu = instNew('Frame')
                 d_Menu.Size = dimNew(1,0,0,0)
                 d_Menu.AutomaticSize = 'Y'
                 d_Menu.Position = dimOffset(0, 25)
                 d_Menu.BackgroundColor3 = RLTHEMEDATA['bd'][1]
                 d_Menu.BackgroundTransparency = 1
                 d_Menu.BorderSizePixel = 0
                 d_Menu.ZIndex = D_IndexOffset
                 d_Menu.Visible = false
                 d_Menu.Parent = d_Header
                 
                  d_MenuListLayout = instNew('UIListLayout')
                  d_MenuListLayout.FillDirection = 'Vertical'
                  d_MenuListLayout.HorizontalAlignment = 'Left'
                  d_MenuListLayout.VerticalAlignment = 'Top'
                  d_MenuListLayout.Parent = d_Menu
            end
            
            local D_Object = {} do 
                D_Object.Tooltip = nil
                D_Object.MToggled = false
                
                D_Object.Primary = primary
                
                D_Object.Menu = d_Menu
                D_Object.Name = text
                D_Object.Parent = self
                D_Object.Icon = d_HeaderIcon
                D_Object.ZIndex = D_IndexOffset
                
                D_Object.Selection = nil
                
                D_Object.Objects = {}
                
                
                D_Object.Flags = {}
                D_Object.Flags['Changed'] = true
                D_Object.Flags['Opened'] = true
                D_Object.Flags['Closed'] = true
                
                D_Object.Toggle = base_class.s_dropdown_toggle
                D_Object.GetSelection = base_class.s_dropdown_getselection
                D_Object.getValue = base_class.s_dropdown_getselection

                
                D_Object.Connect = base_class.generic_connect
                D_Object.setTooltip = base_class.generic_tooltip
                D_Object.addOption = base_class.dropdown_create_option
            end
            
            do
                d_Header.InputBegan:Connect(function(io) 
                    local uitv = io.UserInputType.Value
                    if (uitv == 0 or uitv == 1) then
                        D_Object:Toggle()
                        return
                    end
                end)
                
                d_Header.MouseEnter:Connect(function() 
                    d_Header.BackgroundColor3 = RLTHEMEDATA['hs'][1]
                    
                    local tt = D_Object.Tooltip
                    if (tt) then
                        w_Tooltip.Text = tt
                        w_TooltipHeader.Text = D_Object.Name
                        w_TooltipHeader.Visible = true
                    end
                end)
                
                d_Header.MouseLeave:Connect(function() 
                    d_Header.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                    
                    if (w_Tooltip.Text == D_Object.Tooltip) then
                        w_TooltipHeader.Visible = false
                    end
                end)
            end
            
            return D_Object
        end
        base_class.module_create_modhotkey = function(self) 
            local H_IndexOffset = self.ZIndex+1
            
            local h_Hotkey
             local h_Text
              local h_TextPadding
            
            do
                h_Hotkey = instNew('Frame')
                h_Hotkey.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                h_Hotkey.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                h_Hotkey.BorderSizePixel = 0
                h_Hotkey.Size = dimNew(1, 0, 0, 25)
                h_Hotkey.ZIndex = H_IndexOffset
                h_Hotkey.Parent = self.Menu
                 
                 h_Text = instNew('TextLabel')
                 h_Text.Size = dimScale(1, 1)
                 h_Text.BackgroundTransparency = 1
                 h_Text.Font = RLTHEMEFONT
                 h_Text.TextXAlignment = 'Left'
                 h_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                 h_Text.TextSize = 18
                 h_Text.Text = 'Hotkey: N/A'
                 h_Text.TextStrokeTransparency = 0
                 h_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 h_Text.ZIndex = H_IndexOffset
                 h_Text.Parent = h_Hotkey
                 
                  h_TextPadding = instNew('UIPadding')
                  h_TextPadding.PaddingLeft = dimOffset(IndentLevel2, 0).X -- LEFT PADDING 2
                  h_TextPadding.Parent = h_Text
                    
            end
                
            local H_Object = {} do 
                H_Object.Label = h_Text
                H_Object.Hotkey = nil
                
                H_Object.Parent = self
                H_Object.Tooltip = nil
                
                H_Object.Flags = {}
                H_Object.Flags['HotkeySet'] = true
                
                H_Object.setHotkey = base_class.s_modhotkey_sethotkey
                H_Object.GetHotkey = base_class.s_modhotkey_gethotkey
                H_Object.getValue = base_class.s_modhotkey_gethotkey
                
                H_Object.Connect = base_class.generic_connect
                H_Object.setTooltip = base_class.generic_tooltip
            end
            
            do
                h_Hotkey.InputBegan:Connect(function(io) 
                    local uitv = io.UserInputType.Value
                    if (uitv == 0) then
                        H_Object:setHotkey()
                        return
                    end
                end)
                
                h_Hotkey.MouseEnter:Connect(function() 
                    h_Hotkey.BackgroundColor3 = RLTHEMEDATA['hs'][1]
                end)
                
                h_Hotkey.MouseLeave:Connect(function() 
                    h_Hotkey.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                end)
            end
            
            return H_Object   
        end
        base_class.module_create_hotkey = function(self, text) 
            local H_IndexOffset = self.ZIndex+1
            
            local h_Hotkey
             local h_Text
              local h_TextPadding
            
            do
                h_Hotkey = instNew('Frame')
                h_Hotkey.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                h_Hotkey.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                h_Hotkey.BorderSizePixel = 0
                h_Hotkey.Size = dimNew(1, 0, 0, 25)
                h_Hotkey.ZIndex = H_IndexOffset
                h_Hotkey.Parent = self.Menu
                 
                 h_Text = instNew('TextLabel')
                 h_Text.Size = dimScale(1, 1)
                 h_Text.BackgroundTransparency = 1
                 h_Text.Font = RLTHEMEFONT
                 h_Text.TextXAlignment = 'Left'
                 h_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                 h_Text.TextSize = 18
                 h_Text.Text = tostring(text)..': N/A'
                 h_Text.TextStrokeTransparency = 0
                 h_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 h_Text.ZIndex = H_IndexOffset
                 h_Text.Parent = h_Hotkey
                 
                 h_TextPadding = instNew('UIPadding')
                 h_TextPadding.PaddingLeft = dimOffset(IndentLevel2, 0).X -- LEFT PADDING 2
                 h_TextPadding.Parent = h_Text
            end
                
            local H_Object = {} do 
                H_Object.Label = h_Text
                H_Object.Hotkey = nil
                
                H_Object.Parent = self
                H_Object.Tooltip = nil
                
                H_Object.Name = tostring(text)
                H_Object.Flags = {}
                H_Object.Flags['HotkeySet'] = true
                
                H_Object.bind = base_class.s_hotkey_sethotkey
                H_Object.setHotkey = base_class.s_hotkey_sethotkeyexplicit
                H_Object.GetHotkey = base_class.s_hotkey_gethotkey
                H_Object.getValue = base_class.s_hotkey_gethotkey
                
                H_Object.Connect = base_class.generic_connect
                H_Object.setTooltip = base_class.generic_tooltip
            end
            
            do
                h_Hotkey.InputBegan:Connect(function(io) 
                    local uitv = io.UserInputType.Value
                    if (uitv == 0) then
                        H_Object:bind()
                        return
                    end
                end)
                
                h_Hotkey.MouseEnter:Connect(function() 
                    h_Hotkey.BackgroundColor3 = RLTHEMEDATA['hs'][1]
                    
                    local tt = H_Object.Tooltip
                    if (tt) then
                        w_Tooltip.Text = tt
                        w_TooltipHeader.Text = H_Object.Name
                        w_TooltipHeader.Visible = true
                    end
                end)
                
                h_Hotkey.MouseLeave:Connect(function() 
                    h_Hotkey.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                    
                    if (w_Tooltip.Text == H_Object.Tooltip) then
                        w_TooltipHeader.Visible = false
                    end
                end)
            end
            
            return H_Object   
        end
        base_class.module_create_slider = function(self, text, args, primary) 
            text = tostring(text)
            
            args['min'] = args['min'] or 0
            args['max'] = args['max'] or 100
            args['cur'] = args['cur'] or args['min']
            args['step'] = args['step'] or 1
            
            
            local S_IndexOffset = self.ZIndex+1
            
            local s_Slider
             local s_InputBox
             local s_Text
              local s_TextPad
             local s_Amount
             local s_SliderBarBg
              local s_SliderBar
              
            do
                s_Slider = instNew('Frame')
                s_Slider.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                s_Slider.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                s_Slider.BorderSizePixel = 0
                s_Slider.Size = dimNew(1, 0, 0, 25)
                s_Slider.ZIndex = S_IndexOffset
                s_Slider.Parent = self.Menu
                 
                 s_InputBox = instNew('TextBox')
                 s_InputBox.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                 s_InputBox.BackgroundTransparency = 0.1--RLTHEMEDATA['bs'][2]
                 s_InputBox.BorderSizePixel = 0
                 s_InputBox.Font = RLTHEMEFONT
                 s_InputBox.Size = dimNew(1, 0, 1, 0)
                 s_InputBox.PlaceholderText = 'Enter new value'
                 s_InputBox.TextColor3 = RLTHEMEDATA['tm'][1]
                 s_InputBox.TextSize = 18
                 s_InputBox.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 s_InputBox.TextStrokeTransparency = 0
                 s_InputBox.TextXAlignment = 'Center'
                 s_InputBox.Visible = false
                 s_InputBox.ZIndex = S_IndexOffset + 3
                 s_InputBox.Parent = s_Slider
                 
                 s_Text = instNew('TextLabel')
                 s_Text.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                 s_Text.BackgroundTransparency = 0.2
                 s_Text.BorderSizePixel = 0
                 s_Text.Font = RLTHEMEFONT
                 s_Text.Size = dimScale(1, 1)
                 s_Text.Text = text
                 s_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                 s_Text.TextSize = 18
                 s_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 s_Text.TextStrokeTransparency = 0
                 s_Text.TextXAlignment = 'Left'
                 s_Text.Visible = true
                 s_Text.ZIndex = S_IndexOffset + 1
                 s_Text.Parent = s_Slider
                  
                  s_TextPad = instNew('UIPadding')
                  s_TextPad.PaddingLeft = dimOffset(IndentLevel2, 0).X -- LEFT PADDING 2
                  s_TextPad.Parent = s_Text 
                 
                 s_Amount = instNew('TextLabel')
                 s_Amount.Size = dimNew(0, 30, 1, 0)
                 s_Amount.Position = dimNew(1,-RightIndent, 0, 0) -- RIGHT PADDING
                 s_Amount.AnchorPoint = vec2(1,0)
                 s_Amount.BackgroundTransparency = 1
                 s_Amount.BorderSizePixel = 0
                 s_Amount.Font = RLTHEMEFONT
                 s_Amount.TextXAlignment = 'Right'
                 s_Amount.TextColor3 = RLTHEMEDATA['tm'][1]
                 s_Amount.TextSize = 18
                 s_Amount.Visible = true
                 s_Amount.TextStrokeTransparency = 0
                 s_Amount.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 s_Amount.ZIndex = S_IndexOffset + 1 
                 s_Amount.Parent = s_Slider
                 
                 s_SliderBarBg = instNew('Frame')
                 s_SliderBarBg.BackgroundColor3 = RLTHEMEDATA['sb'][1]
                 s_SliderBarBg.BackgroundTransparency = RLTHEMEDATA['sb'][2]
                 s_SliderBarBg.BorderSizePixel = 0
                 s_SliderBarBg.ClipsDescendants = true
                 s_SliderBarBg.Position = dimNew(0, 8, 0.5, -3)
                 s_SliderBarBg.Size = dimNew(1, -16, 0, 6)
                 s_SliderBarBg.ZIndex = S_IndexOffset
                 s_SliderBarBg.Parent = s_Slider
                 
                  s_SliderBar = instNew('Frame')
                  s_SliderBar.Size = dimScale(1, 1)
                  s_SliderBar.Position = dimNew(0,0)
                  s_SliderBar.AnchorPoint = vec2(1, 0)
                  s_SliderBar.BackgroundColor3 = RLTHEMEDATA['sf'][1]
                  s_SliderBar.BackgroundTransparency = RLTHEMEDATA['sf'][2]
                  s_SliderBar.BorderSizePixel = 0
                  s_SliderBar.ZIndex = S_IndexOffset
                  s_SliderBar.Parent = s_SliderBarBg
                  
                stroke(s_SliderBarBg, nil, 0.7)
                 
            end
            
            local StepFormat
            
            if (args['step'] < 1) then
                StepFormat = (
                    '%.'..
                    (
                        (('%.0e'):format(args['step'])):match('e%-0(%d)')
                    )..
                    'f'
                )
                
                if (StepFormat == '%.f') then
                    error('FATAL ERROR WHEN MAKING SLIDER\nCOULDN\'T MAKE STEPFORMAT PROPERLY\nTELL ME IF YOU SEE THIS')
                    return
                end
            else
                StepFormat = '%d'
            end
            
            s_Amount.Text = StepFormat:format(args['cur'])
            
            
            local DragConn
                
            local S_Object = {} do 
                S_Object.Tooltip = nil
                S_Object.Name = text
                
                S_Object.SliderFill = s_SliderBar
                S_Object.SliderBg = s_SliderBarBg
                S_Object.SliderAmnt = s_Amount
                
                
                S_Object.SliderSize = s_SliderBarBg.AbsoluteSize.X
                
                S_Object.CurrentVal = args['cur']
                S_Object.PreviousVal = nil
                S_Object.Min = args['min']
                S_Object.Max = args['max']
                S_Object.Step = args['step']
                S_Object.Ratio = S_Object.SliderSize / (S_Object.Max - S_Object.Min)
                S_Object.RatioInverse = 1 / S_Object.Ratio
                S_Object.StepFormat = StepFormat
                
                
                S_Object.Parent = self
                S_Object.Primary = primary or false
                
                
                
                S_Object.Flags = {}
                S_Object.Flags['Changed'] = true
                
                S_Object.getValue = base_class.s_slider_getval
                S_Object.SetValue = base_class.s_slider_setvalnum
                S_Object.SetValuePos = base_class.s_slider_setvalpos
                
                S_Object.Connect = base_class.generic_connect
                S_Object.setTooltip = base_class.generic_tooltip
            end
            
            S_Object:SetValue(args['cur'])
            
            do
                s_Slider.MouseEnter:Connect(function() 
                    s_Slider.BackgroundColor3 = RLTHEMEDATA['hs'][1]
                    
                    s_Amount.TextXAlignment = 'Center'
                    twn(s_Text, {BackgroundTransparency = 1, TextTransparency = 1, TextStrokeTransparency = 1},true)
                    twn(s_Amount, {Position = dimNew(0.5,IndentLevel2,0,0)}, true) -- LEFT PADDING 2
                    
                    local tt = S_Object.Tooltip
                    if (tt) then
                        w_Tooltip.Text = tt
                        w_TooltipHeader.Text = S_Object.Name
                        w_TooltipHeader.Visible = true
                    end
                end)
                
                s_Slider.MouseLeave:Connect(function() 
                    s_Slider.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                    -- deez nuts
                    s_Amount.TextXAlignment = 'Right'
                    twn(s_Text, {BackgroundTransparency = 0.2, TextTransparency = 0, TextStrokeTransparency = 0},true)
                    twn(s_Amount, {Position = dimNew(1,-RightIndent,0,0)}, true) -- RIGHT PADDING
                    
                    if (w_Tooltip.Text == S_Object.Tooltip) then
                        w_TooltipHeader.Visible = false
                    end
                end)
                
                s_Slider.InputBegan:Connect(function(io) 
                    local v = io.UserInputType.Value
                    if (v == 0) then
                        S_Object:SetValuePos(io.Position.X)
                        
                        DragConn = servInput.InputChanged:Connect(function(io) 
                            if (io.UserInputType.Value == 4) then
                                S_Object:SetValuePos(io.Position.X)
                            end
                        end)
                    elseif (v == 1) then
                        s_InputBox.Visible = true
                        s_InputBox:CaptureFocus()
                        s_InputBox.Text = ''
                    end
                end)
                
                s_Slider.InputEnded:Connect(function(io) 
                    if (io.UserInputType.Value == 0) then
                        DragConn:Disconnect()
                    end
                end)
                
                s_InputBox.FocusLost:Connect(function(enter) 
                    if not enter then return end
                    
                    local t = s_InputBox.Text
                    local a = tonumber(t)
                    if (a == nil) then
                        if (t == '') then
                            s_InputBox.Visible = false
                        else
                            s_InputBox.Text = 'Not a number'
                        end
                    else
                        S_Object:SetValue(a)
                        s_InputBox.Visible = false
                    end
                end)
            end
            return S_Object            
        end
        base_class.module_create_input = function(self, text) 
            text = tostring(text)
            local I_IndexOffset = self.ZIndex + 1 
            
            local i_Input
             local i_TextPad
             local i_Icon

            do

                
                i_Input = instNew('TextBox')
                i_Input.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                i_Input.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                i_Input.BorderSizePixel = 0 
                i_Input.ClearTextOnFocus = true
                i_Input.Font = RLTHEMEFONT
                i_Input.Size = dimNew(1, 0, 0, 25)
                i_Input.Text = text
                i_Input.TextColor3 = RLTHEMEDATA['tm'][1]
                i_Input.TextSize = 18
                i_Input.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                i_Input.TextStrokeTransparency = 0
                i_Input.TextWrapped = true
                i_Input.TextXAlignment = 'Left'
                i_Input.ZIndex = I_IndexOffset
                i_Input.Parent = self.Menu
                 
                 i_TextPad = instNew('UIPadding')
                 i_TextPad.PaddingLeft = dimOffset(IndentLevel2, 0).X -- LEFT PADDING 2
                 i_TextPad.Parent = i_Input
                
                i_Icon = instNew('ImageLabel')
                i_Icon.AnchorPoint = vec2(1,0.5)
                i_Icon.Position = dimNew(1,-4, 0.5, 0)                
                i_Icon.BackgroundTransparency = 1
                i_Icon.Image = 'rbxassetid://8997447289'
                i_Icon.Rotation = 0
                i_Icon.Size = dimOffset(12, 12)
                i_Icon.ZIndex = I_IndexOffset
                i_Icon.Parent = i_Input
            end
                
            local I_Object = {} do 
                I_Object.Tooltip = nil
                
                
                I_Object.Flags = {} do 
                    I_Object.Flags['Focused'] = true
                    I_Object.Flags['Unfocused'] = true
                    I_Object.Flags['TextChanged'] = true
                end
                
                I_Object.Name = text
                I_Object.ZIndex = I_IndexOffset
                
                I_Object.Connect = base_class.generic_connect
                I_Object.setTooltip = base_class.generic_tooltip
            end
            
            do
                i_Input.MouseEnter:Connect(function() 
                    i_Input.BackgroundColor3 = RLTHEMEDATA['hs'][1]
                    
                    
                    local tt = I_Object.Tooltip
                    if (tt) then
                        w_Tooltip.Text = tt
                        w_TooltipHeader.Text = I_Object.Name
                        w_TooltipHeader.Visible = true
                    end
                end)
                
                i_Input.MouseLeave:Connect(function() 
                    i_Input.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                    
                    if (w_Tooltip.Text == I_Object.Tooltip) then
                        w_TooltipHeader.Visible = false
                    end
                end)
                
                i_Input.FocusLost:Connect(function(enter) 
                    pcall(I_Object.Flags.Unfocused, i_Input.Text, enter)
                    i_Input.Text = I_Object.Name
                end)
                i_Input.Focused:Connect(function() 
                    pcall(I_Object.Flags.Focused)
                end)
                i_Input:GetPropertyChangedSignal('Text'):Connect(function() 
                    pcall(I_Object.Flags.TextChanged, i_Input.Text)
                end)
            end
            
            return I_Object
        end
        base_class.module_create_button = function(self, text) 
            text = tostring(text)
            
            local B_IndexOffset = self.ZIndex + 1
            
            local b_Background
             local b_EnableEffect
             local b_Text
              local b_TextPadding
             local b_Icon
            
            do
                b_Background = instNew('Frame')
                b_Background.BackgroundColor3 = RLTHEMEDATA['bs'][1] 
                b_Background.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                b_Background.BorderSizePixel = 0
                b_Background.Size = dimNew(1,0,0,25)
                b_Background.ZIndex = B_IndexOffset
                b_Background.Parent = self.Menu
                
                 b_EnableEffect = instNew('Frame')
                 b_EnableEffect.BackgroundColor3 = RLTHEMEDATA['tm'][1]
                 b_EnableEffect.BackgroundTransparency = 1
                 b_EnableEffect.BorderSizePixel = 0
                 b_EnableEffect.ClipsDescendants = true
                 b_EnableEffect.Size = dimNew(1,0,1,0)
                 b_EnableEffect.ZIndex = B_IndexOffset
                 b_EnableEffect.Parent = b_Background
                
                 b_Text = instNew('TextLabel')
                 b_Text.BackgroundTransparency = 1
                 b_Text.Font = RLTHEMEFONT
                 b_Text.Position = dimOffset(10, 0)
                 b_Text.Size = dimNew(1, -10, 1, 0)
                 b_Text.Text = text
                 b_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                 b_Text.TextSize = 18
                 b_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 b_Text.TextStrokeTransparency = 0
                 b_Text.TextXAlignment = 'Left'
                 b_Text.ZIndex = B_IndexOffset
                 b_Text.Parent = b_Background
                 
                  b_TextPadding = instNew('UIPadding')
                  b_TextPadding.PaddingLeft = dimOffset(IndentLevel2, 0).X -- LEFT PADDING 2
                  b_TextPadding.Parent = b_Text
                    
                 
                 b_Icon = instNew('ImageLabel')
                 b_Icon.AnchorPoint = vec2(1,0.5)
                 b_Icon.BackgroundTransparency = 1
                 b_Icon.Position = dimNew(1,-4, 0.5, 0)
                 b_Icon.Rotation = 0
                 b_Icon.Size = dimOffset(12, 12)
                 b_Icon.Image = 'rbxassetid://8997446977'
                 b_Icon.ImageColor3 = RLTHEMEDATA['tm'][1]
                 b_Icon.ZIndex = B_IndexOffset
                 b_Icon.Parent = b_Background
            end
                
            local B_Object = {} do 
                B_Object.Tooltip = nil
                
                
                B_Object.Flags = {} do 
                    B_Object.Flags['Clicked'] = true
                end
                
                B_Object.Effect = b_EnableEffect
                
                B_Object.Name = text
                B_Object.ZIndex = B_IndexOffset
                
                B_Object.Click = base_class.module_click_self
                
                B_Object.Connect = base_class.generic_connect
                B_Object.setTooltip = base_class.generic_tooltip
            end
            
            do
                b_Background.InputBegan:Connect(function(io) 
                    local uitv = io.UserInputType.Value
                    if (uitv == 0) then
                        B_Object:Click()
                        return
                    end
                end)
                
                b_Background.MouseEnter:Connect(function() 
                    b_Background.BackgroundColor3 = RLTHEMEDATA['hs'][1]
                    
                    
                    local tt = B_Object.Tooltip
                    if (tt) then
                        w_Tooltip.Text = tt
                        w_TooltipHeader.Text = B_Object.Name
                        w_TooltipHeader.Visible = true
                    end
                end)
                
                b_Background.MouseLeave:Connect(function() 
                    b_Background.BackgroundColor3 = RLTHEMEDATA['bs'][1] 
                    
                    if (w_Tooltip.Text == B_Object.Tooltip) then
                        w_TooltipHeader.Visible = false
                    end
                end)
            end
            
            return B_Object
        end
        base_class.dropdown_create_option = function(self, text) 
            text = tostring(text)

            local O_IndexOffset = self.ZIndex + 1
            
            local o_Option
             local o_Text
              local o_TextPadding
             local o_EnableEffect
             local o_EnableEffect2
            
            do
                o_Option = instNew('Frame')
                o_Option.BackgroundColor3 = RLTHEMEDATA['bd'][1]
                o_Option.BackgroundTransparency = RLTHEMEDATA['bd'][2]
                o_Option.BorderSizePixel = 0
                o_Option.Size = dimNew(1, 0, 0, 25)
                o_Option.ZIndex = O_IndexOffset
                o_Option.Parent = self.Menu
                 
                 o_Text = instNew('TextLabel')
                 o_Text.BackgroundTransparency = 1
                 o_Text.Font = RLTHEMEFONT
                 o_Text.Size = dimScale(1,1)
                 o_Text.Text = text
                 o_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                 o_Text.TextSize = 18
                 o_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 o_Text.TextStrokeTransparency = 0
                 o_Text.TextXAlignment = 'Left'
                 o_Text.ZIndex = O_IndexOffset
                 o_Text.Parent = o_Option
                 
                 o_TextPadding = instNew('UIPadding')
                 o_TextPadding.PaddingLeft = dimOffset(IndentLevel3, 0).X -- LEFT PADDING 3
                 o_TextPadding.Parent = o_Text
                 
                 o_EnableEffect = instNew('Frame')
                 o_EnableEffect.BackgroundColor3 = RLTHEMEDATA['tm'][1]
                 o_EnableEffect.BackgroundTransparency = 0.96
                 o_EnableEffect.BorderSizePixel = 0
                 o_EnableEffect.ClipsDescendants = true
                 o_EnableEffect.Size = dimNew(0,0,1,0)
                 o_EnableEffect.ZIndex = O_IndexOffset
                 o_EnableEffect.Parent = o_Option
                 
                  o_EnableEffect2 = instNew('Frame')
                  o_EnableEffect2.BackgroundColor3 = RLTHEMEDATA['ge'][1]
                  o_EnableEffect2.Size = dimNew(0,2,1,0)
                  o_EnableEffect2.BorderSizePixel = 0
                  o_EnableEffect2.ZIndex = O_IndexOffset
                  o_EnableEffect2.Parent = o_EnableEffect
            end
                
            local O_Object = {} do 
                O_Object.Tooltip = nil
                O_Object.Selected = false
                
                O_Object.Name = text
                O_Object.Parent = self
                
                O_Object.Effect = o_EnableEffect
                
                O_Object.Select = base_class.s_ddoption_select_self
                O_Object.Deselect = base_class.s_ddoption_deselect_self
                
                O_Object.getState = base_class.s_ddoption_selected_getstate
                O_Object.IsSelected = base_class.s_ddoption_selected_getstate
                
                O_Object.setTooltip = base_class.generic_tooltip
            end
            
            do
                o_Option.InputBegan:Connect(function(io) 
                    local uitv = io.UserInputType.Value
                    if (uitv == 0 or uitv == 1) then
                        O_Object:Select()
                        return
                    end
                end)
                
                o_Option.MouseEnter:Connect(function() 
                    o_Option.BackgroundColor3 = RLTHEMEDATA['hd'][1]
                    
                    local tt = O_Object.Tooltip
                    if (tt) then
                        w_Tooltip.Text = tt
                        w_TooltipHeader.Text = O_Object.Name
                        w_TooltipHeader.Visible = true
                    end
                end)
                
                o_Option.MouseLeave:Connect(function() 
                    o_Option.BackgroundColor3 = RLTHEMEDATA['bd'][1]
                    
                    if (w_Tooltip.Text == O_Object.Tooltip) then
                        w_TooltipHeader.Visible = false
                    end
                end)
            end
            
            tabInsert(self.Objects, O_Object)
            return O_Object
        end
        
        base_class.widget_create_label = function(self, text) 
            local WidgetLabel = instNew('TextLabel')
            WidgetLabel.BackgroundTransparency = 1
            WidgetLabel.Font = RLTHEMEFONT
            WidgetLabel.RichText = true
            WidgetLabel.TextColor3 = RLTHEMEDATA['tm'][1]
            WidgetLabel.TextSize = 20
            WidgetLabel.TextStrokeColor3 = RLTHEMEDATA['to'][1]
            WidgetLabel.TextStrokeTransparency = 0
            WidgetLabel.ZIndex = self.Index
            WidgetLabel.Parent = self.Frame
            
            local bl = {}
            bl['BackgroundTransparency'] = true
            bl['Font'] = true
            bl['TextColor3'] = true
            bl['TextStrokeColor3'] = true
            bl['TextStrokeTransparency'] = true
            bl['ZIndex'] = true
            bl['Parent'] = true
            
            
            local mt = setmetatable({}, {
                __index = function(a,b) 
                    return WidgetLabel[b] 
                end;
                
                __newindex = function(part, prop, val) 
                    if (bl[prop] == nil) then
                        WidgetLabel[prop] = val
                    elseif (prop == 'SELF') then
                        return WidgetLabel
                    end
                end;
                
                __metatable = 'the j :skull:'
            })
            
            return mt
        end
        
        
    end
    
    -- UI functions
    function ui:newMenu(text) 
        local M_Id = #ui_Menus+1
        local M_IndexOffset = 50+(M_Id * 15)
        
        local m_Header
         local m_HeaderEnableEffect
         local m_HeaderText
         local m_HeaderIcon
         
         local m_Menu
          local m_MenuListLayout
        
        m_Header = instNew('ImageButton')
        m_Header.Active = true
        m_Header.AutoButtonColor = false
        m_Header.BackgroundColor3 = RLTHEMEDATA['bm'][1]
        m_Header.BackgroundTransparency = RLTHEMEDATA['bm'][2]
        m_Header.BorderSizePixel = 0
        m_Header.ClipsDescendants = false
        m_Header.Size = dimOffset(monitor_resolution.X < 1600 and 200 or 250, 30)
        
        local FinalPosition do 
            local MenusPerRow = mathFloor(((monitor_resolution.X-400) / 300))
            FinalPosition = dimOffset(200+(((M_Id-1)%MenusPerRow)*(300)), 200+150*(mathFloor((M_Id-1)/MenusPerRow)))
        end
        
        
        m_Header.Position = FinalPosition
            
        
        
        --dimOffset((0.1*((M_Id-1)%6) * monitor_resolution.X)+(100*((M_Id-1)%6)+100), 0)
        m_Header.ZIndex = M_IndexOffset+2
        m_Header.Parent = w_ModFrame
        
        
        
         m_HeaderEnableEffect = instNew('Frame')
         m_HeaderEnableEffect.BackgroundColor3 = RLTHEMEDATA['ge'][1]
         m_HeaderEnableEffect.Size = dimNew(0,0,1,0)
         m_HeaderEnableEffect.BorderSizePixel = 0
         m_HeaderEnableEffect.ZIndex = M_IndexOffset+2
         m_HeaderEnableEffect.Parent = m_Header
        
         m_HeaderText = instNew('TextLabel')
         m_HeaderText.Size = dimNew(1, 0, 1, 0)
         m_HeaderText.Position = dimOffset(0, 0)
         m_HeaderText.BackgroundTransparency = 1
         m_HeaderText.Font = RLTHEMEFONT
         m_HeaderText.TextXAlignment = 'Center'
         m_HeaderText.TextColor3 = RLTHEMEDATA['tm'][1]
         m_HeaderText.TextSize = 22
         m_HeaderText.Text = text
         m_HeaderText.TextStrokeTransparency = 0
         m_HeaderText.TextStrokeColor3 = RLTHEMEDATA['to'][1]
         m_HeaderText.ZIndex = M_IndexOffset+2
         m_HeaderText.Parent = m_Header
         
         m_HeaderIcon = instNew('ImageLabel')
         m_HeaderIcon.Size = dimOffset(30, 30)
         m_HeaderIcon.Position = dimScale(1,0)
         m_HeaderIcon.AnchorPoint = vec2(1,0)
         m_HeaderIcon.BackgroundTransparency = 1
         m_HeaderIcon.ImageColor3 = RLTHEMEDATA['tm'][1]
         m_HeaderIcon.Image = 'rbxassetid://7184113125'
         m_HeaderIcon.Rotation = 180
         m_HeaderIcon.ZIndex = M_IndexOffset+2
         m_HeaderIcon.Parent = m_Header

        m_Menu = instNew('Frame')
        m_Menu.AutomaticSize = 'Y'
        m_Menu.BackgroundColor3 = RLTHEMEDATA['bo'][1]
        m_Menu.BackgroundTransparency = 1--RLTHEMEDATA['bo'][2]
        m_Menu.BorderSizePixel = 0
        m_Menu.Position = dimOffset(0, 30)
        m_Menu.Size = dimNew(1,0,0,0)
        m_Menu.Visible = false
        m_Menu.ZIndex = M_IndexOffset
        m_Menu.Parent = m_Header
        
         m_MenuListLayout = instNew('UIListLayout')
         m_MenuListLayout.FillDirection = 'Vertical'
         m_MenuListLayout.HorizontalAlignment = 'Left'
         m_MenuListLayout.VerticalAlignment = 'Top'
         m_MenuListLayout.Parent = m_Menu
        
         
        stroke(m_Header)
        stroke(m_Menu)
        
        
        
        
        local M_Object = {} do 
            M_Object.MToggled = false
            M_Object.Menu = m_Menu
            M_Object.Icon = m_HeaderIcon
            M_Object.ZIndex = M_IndexOffset
            M_Object.Enabled = m_HeaderEnableEffect
            
            M_Object.addMod = base_class.menu_create_module
            
            
            M_Object.Enable = base_class.menu_enable
            M_Object.Disable = base_class.menu_disable
            M_Object.Toggle = base_class.menu_toggle
            M_Object.getState = base_class.menu_getstate
        end
        
        do
            local prevclicktime = 0
            local id = 'menu-'..M_Id
            
            m_Header.InputBegan:Connect(function(io) 
                -- Header got input; check type
                local uitv = io.UserInputType.Value
                
                -- If left clicking then do stuff
                if (uitv == 0) then
                    -- Check double click debounce
                    local currclicktime = tick()
                    if (currclicktime - prevclicktime < 0.2) then
                        M_Object:Toggle()
                    end
                    prevclicktime = currclicktime
                    
                    -- Start dragging logic
                    
                    local root_pos = m_Header.AbsolutePosition -- Get the original header position
                    local start_pos = io.Position -- Get start input position; this will be used for a "delta" position
                    start_pos = vec2(start_pos.X, start_pos.Y) -- Convert it to a vec2 so it can be used easier
                    
                    local destination = vec2(root_pos.X, root_pos.Y) + monitor_inset -- Get the wanted destination; this will be used for custom tweening
                    -- (normal roblox tweening works fine, but i believe custom is more performant)
                    servRun:BindToRenderStep(M_Id, 2000, function(dt) -- "Tween" code
                        m_Header.Position = m_Header.Position:lerp(dimOffset(destination.X, destination.Y), 1 - 1e-9^(dt)) -- Lerp the position
                        
                        -- value = lerp(target, value, exp2(-rate*deltaTime))
                    end)
                    -- Connect to mouse movement
                    ui_Connections[id] = servInput.InputChanged:Connect(function(io) 
                        -- Check if the input is a mouse movement
                        if (io.UserInputType.Value == 4) then
                            -- If so then get the mouse position
                            local curr_pos = io.Position
                            -- Convert it to a vec2
                            curr_pos = vec2(curr_pos.X, curr_pos.Y)
                            -- Get the new destination (original position + input delta + inset)
                            destination = root_pos + (curr_pos - start_pos) + monitor_inset
                            
                            --twn(m_Header, {Position = dimOffset(destination.X, destination.Y)})
                        end
                    end)
                    
                -- If its not mouse1, check if its a right click
                elseif (uitv == 1) then
                    -- Toggle if it is
                    M_Object:Toggle()
                end
            end)
            m_Header.InputEnded:Connect(function(io) 
                if (io.UserInputType.Value == 0) then
                    local a = ui_Connections[id]
                    if (a) then a:Disconnect() end
                    servRun:UnbindFromRenderStep(M_Id)
                end
            end)
            
            m_Header.MouseEnter:Connect(function() 
                m_Header.BackgroundColor3 = RLTHEMEDATA['hm'][1]
            end)
            
            m_Header.MouseLeave:Connect(function() 
                m_Header.BackgroundColor3 = RLTHEMEDATA['bm'][1]
            end)
        end
        
        
        
        tabInsert(ui_Menus, M_Object)
        return M_Object
    end
    function ui:CreateWidget(Name, Position, Size, InRedlineWindow) 
        local W_Id = #ui_Widgets+1
        local W_IndexOffset = 25+(W_Id * 15)
        
        
        local w_Header
        local w_Main
        
        w_Header = instNew('TextLabel')
        w_Header.BackgroundColor3 = RLTHEMEDATA['bm'][1]
        w_Header.BackgroundTransparency = RLTHEMEDATA['bm'][2]
        w_Header.BorderSizePixel = 0
        w_Header.Font = RLTHEMEFONT
        w_Header.Position = Position
        w_Header.RichText = true
        w_Header.Size = dimOffset(Size.X, 21)
        w_Header.Text = Name
        w_Header.TextColor3 = RLTHEMEDATA['tm'][1]
        w_Header.TextSize = 19
        w_Header.TextStrokeColor3 = RLTHEMEDATA['to'][1]
        w_Header.TextStrokeTransparency = 0
        w_Header.TextXAlignment = 'Center'
        w_Header.Visible = true 
        w_Header.ZIndex = W_IndexOffset
        w_Header.Parent = InRedlineWindow and w_ModFrame or w_Main
        
        stroke(w_Header, 'Border')
        
        w_Main = instNew('Frame')
        w_Main.BackgroundColor3 = RLTHEMEDATA['gw'][1]
        w_Main.BackgroundTransparency = RLTHEMEDATA['gw'][2]
        w_Main.BorderSizePixel = 0
        w_Main.Position = dimOffset(0, 21)
        w_Main.Size = dimNew(1, 0, 1, Size.Y-21)
        w_Main.Visible = true 
        w_Main.ZIndex = W_IndexOffset
        w_Main.Parent = w_Header
        
        stroke(w_Main, 'Border')
        
        local WidgetObject = {} do 
            WidgetObject.Frame = w_Main
            WidgetObject.Name = Name
            WidgetObject.Index = W_IndexOffset
            WidgetObject.Header = w_Header
            
            WidgetObject.CreateLabel = widget_create_label
            WidgetObject.Colors = {}
            WidgetObject.Colors.Text = RLTHEMEDATA['tm'][1]
            WidgetObject.Colors.TextStroke = RLTHEMEDATA['to'][1]
        end
        do 
            local id = 'wid-'..W_Id
            
            w_Header.InputBegan:Connect(function(io) 
                -- Header got input; check type
                local uitv = io.UserInputType.Value
                
                -- If left clicking then do stuff
                if (uitv == 0) then
                    -- Start dragging logic
                    
                    local root_pos = w_Header.AbsolutePosition -- Get the original header position
                    local start_pos = io.Position -- Get start input position; this will be used for a "delta" position
                    start_pos = vec2(start_pos.X, start_pos.Y) -- Convert it to a vec2 so it can be used easier
                    
                    local destination = vec2(root_pos.X, root_pos.Y) + monitor_inset -- Get the wanted destination; this will be used for custom tweening
                    -- (normal roblox tweening works fine, but i believe custom is more performant)
                    servRun:BindToRenderStep(W_Id, 2000, function() -- "Tween" code
                        w_Header.Position = w_Header.Position:lerp(dimOffset(destination.X, destination.Y), 0.3) -- Lerp the position
                    end)
                    -- Connect to mouse movement
                    ui_Connections[id] = servInput.InputChanged:Connect(function(io) 
                        -- Check if the input is a mouse movement
                        if (io.UserInputType.Value == 4) then
                            -- If so then get the mouse position
                            local curr_pos = io.Position
                            -- Convert it to a vec2
                            curr_pos = vec2(curr_pos.X, curr_pos.Y)
                            -- Get the new destination (original position + input delta + inset)
                            destination = root_pos + (curr_pos - start_pos) + monitor_inset
                        end
                    end)
                end
            end)
            w_Header.InputEnded:Connect(function(io) 
                if (io.UserInputType.Value == 0) then
                    local a = ui_Connections[id]
                    if (a) then a:Disconnect() end
                    servRun:UnbindFromRenderStep(W_Id)
                end
            end)
        
        end
        return WidgetObject
    end
    
    function ui:Destroy() 
        pcall(ui.Flags.Destroying)
        
        
        -- Destroy
        local _ = w_Screen.Parent
        w_Screen:Destroy()
        
        -- Unbinds
        servContext:UnbindAction('RL-ToggleMenu')
        servContext:UnbindAction('RL-Destroy')
        
        -- Disconnections
        
        for i,v in pairs(ui_Connections) do 
            v:Disconnect() 
        end
        
        -- Variable clearing
        gradient,getnext,stroke,round,uierror = nil,nil,nil,nil,nil
        ui_Menus = nil
        
        _G.RLLOADED = false
        _G.RLTHEME = nil
        _G.RLTHEMEDATA = nil
        _G.RLTHEMEFONT = nil
        _G.RLLOADERROR = nil
        
        writefile('REDLINE/Queued.txt','')
        
        local sound = instNew('Sound')
        sound.SoundId = 'rbxassetid://9009668475'
        sound.Volume = 1
        sound.TimePosition = 0.02
        sound.Parent = _
        sound:Play()
        sound.Ended:Connect(function() 
            sound:Destroy()
        end)
        
    end
    function ui:GetModules() 
        return ui_Modules
    end
    function ui:GetScreen() 
        return w_Screen 
    end
    function ui:GetModframe() 
        return w_ModFrame
    end
    
    do
        local notifs = {}
        local notifsounds = {
            high = 'rbxassetid://9009664674',
            low = 'rbxassetid://9009665420',
            none = '',
            warn = 'rbxassetid://9009666085'
        }
        
        local m_Notif
        local m_Description
        local m_Header
        local m_Icon
        local m_Text
        
        local m_Sound
        do 
            
            m_Notif = instNew('Frame')
            m_Notif.AnchorPoint = vec2(1,1)
            m_Notif.BackgroundColor3 = RLTHEMEDATA['bo'][1]
            m_Notif.BackgroundTransparency = RLTHEMEDATA['bo'][2]
            m_Notif.BorderSizePixel = 0
            m_Notif.Position = dimNew(1, 275, 1, -((#notifs*125)+((#notifs+1)*25)))
            m_Notif.Size = dimOffset(200, 125)
            m_Notif.ZIndex = 162
            --m_Notif.Parent = w_Screen
            
            stroke(m_Notif)
            
            m_Sound = instNew('Sound')
            --m_Sound.Playing = true
            --m_Sound.SoundId =notifsounds[tone or 3]
            m_Sound.Volume = 1
            m_Sound.TimePosition = 0.1
            --m_Sound.Parent = m_Notif 
            
            m_Progress = instNew('Frame')
            m_Progress.BackgroundColor3 = RLTHEMEDATA['ge'][1]
            m_Progress.BorderSizePixel = 0
            m_Progress.Position = dimOffset(0, 30)
            m_Progress.Size = dimNew(1,0,0,1)
            m_Progress.ZIndex = 163
            --m_Progress.Parent = m_Notif
            
            m_Header = instNew('Frame')
            m_Header.BackgroundColor3 = RLTHEMEDATA['bm'][1]
            m_Header.BackgroundTransparency = RLTHEMEDATA['bm'][2]
            m_Header.BorderSizePixel = 0
            m_Header.Size = dimNew(1,0,0,30)
            m_Header.ZIndex = 162
            --m_Header.Parent = m_Notif
            
            stroke(m_Header)
            
            m_Text = instNew('TextLabel')
            m_Text.BackgroundTransparency = 1
            m_Text.Font = RLTHEMEFONT
            m_Text.Position = dimOffset(32, 0)
            m_Text.RichText = true
            m_Text.Size = dimNew(1, -32, 1, 0)
            m_Text.Text = ''
            m_Text.TextColor3 = RLTHEMEDATA['tm'][1]
            m_Text.TextSize = 22
            m_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
            m_Text.TextStrokeTransparency = 0
            m_Text.TextXAlignment = 'Left'
            m_Text.ZIndex = 162
            --m_Text.Parent = m_Header
            
            m_Description = instNew('TextLabel')
            m_Description.BackgroundTransparency = 1
            m_Description.Font = RLTHEMEFONT
            m_Description.Position = dimOffset(4, 32)
            m_Description.RichText = true
            m_Description.Size = dimNew(1, -4, 1, -32)
            m_Description.Text = tostring(text)
            m_Description.TextColor3 = RLTHEMEDATA['tm'][1]
            m_Description.TextSize = 20
            m_Description.TextStrokeColor3 = RLTHEMEDATA['to'][1]
            m_Description.TextStrokeTransparency = 0
            m_Description.TextWrapped = true
            m_Description.TextXAlignment = 'Left'
            m_Description.TextYAlignment = 'Top'
            m_Description.ZIndex = 162
            --m_Description.Parent = m_Notif
            
            m_Icon = instNew('ImageLabel')
            m_Icon.Size = dimOffset(26, 26)
            m_Icon.Position = dimOffset(2,2)
            m_Icon.BackgroundTransparency = 1
            m_Icon.ImageColor3 = RLTHEMEDATA['ge'][1]
            
            --m_Icon.Image = not warning and 'rbxassetid://8854459207' or 'rbxassetid://8854458547'
            m_Icon.Rotation = 0
            m_Icon.ZIndex = 162
            --m_Icon.Parent = m_Header
        end
        
        
        
        
        function ui:Notify(title, text, duration, tone, warning) 
            duration = mathClamp(duration or 2, 0.1, 30)
            
            local m_Notif = m_Notif:Clone()
            local m_Description = m_Description:Clone()
            local m_Header = m_Header:Clone()
            local m_Progress = m_Progress:Clone()
            local m_Icon = m_Icon:Clone()
            local m_Text = m_Text:Clone()
            local m_Sound = m_Sound:Clone()
            
            do
                m_Description.Parent = m_Notif
                m_Sound.Parent = m_Notif
                m_Progress.Parent = m_Notif
                m_Header.Parent = m_Notif
                m_Icon.Parent = m_Header
                m_Text.Parent = m_Header
            end do
                m_Text.Text = title
                m_Description.Text = text
            end
            
            m_Sound.SoundId = notifsounds[tone or 'none']
            m_Sound.Playing = true
            
            m_Icon.Image = warning and 'rbxassetid://8854458547' or 'rbxassetid://8854459207'
            
            
            m_Notif.Position = dimNew(1, 275, 1, -((#notifs*125)+((#notifs+1)*25)))
            m_Notif.Parent = w_Screen
            
            for i = 1, 25 do
                if (m_Text.TextFits) then break end
                m_Notif.Size += dimOffset(25, 0)
            end
            
            
            
            tabInsert(notifs, m_Notif)
            twn(m_Notif, {Position = m_Notif.Position - dimOffset(300,0)}, true)
            local j = ctwn(m_Progress, {Size = dimOffset(0, 1)}, duration)
            j.Completed:Connect(function()
                do
                    for i = 1, #notifs do 
                        if (notifs[i] == m_Notif) then 
                            tabRemove(notifs, i) 
                        end 
                    end
                    for i = 1, #notifs do 
                        twn(notifs[i], {Position = dimNew(1, -25, 1, -(((i-1)*125)+(i*25)))}, true)
                    end
                    twn(m_Notif, {Position = dimNew(1, -25, 1, 200)}, true).Completed:Wait()
                    m_Notif:Destroy()
                end
            end)
        end
    end
    
    ui.Flags = {}
    ui.Flags.Destroying = true
    ui.Connect = base_class.generic_connect
    
    
    -- Gui binds
    local OldIconEnabled = servInput.MouseIconEnabled
    servContext:BindActionAtPriority('RL-ToggleMenu',function(_,uis) 
        
        if (uis.Value == 0) then
            W_WindowOpen = not W_WindowOpen
            
            if (W_WindowOpen) then
                servInput.MouseIconEnabled = false
                w_MouseCursor.ImageTransparency = 0
                
                w_Backframe.Visible = true
                twn(w_Backframe, {Size = dimScale(1, 1)}, true)
            else
                servInput.MouseIconEnabled = OldIconEnabled
                w_MouseCursor.ImageTransparency = 1
                
                
                local j = twn(w_Backframe, {Size = dimScale(1, 0)}, true)
                j.Completed:Wait()
                if j.PlaybackState == 4 then
                    w_Backframe.Visible = false
                end 
            end
        end
    end,false,999999,Enum.KeyCode.RightShift)
    
    servContext:BindActionAtPriority('RL-Destroy',function(_,uis) 
        if (uis.Value == 0) then
            ui:Destroy()
        end
    end,false,999999,Enum.KeyCode.End)
    -- Auto collection
    delay(5, function() 
        if (ui_Menus ~= nil and #ui_Menus == 0) then
            ui:Destroy()
            warn'[REDLINE] Failure to clean library resources!\nAutomatically cleared for you; make sure to\ncall ui:Destroy() when finished'
        end
    end)
end
-- // END REDLINE LIBRARY



-- kys
local isexecclosure = is_synapse_function or 
    is_exec_closure or 
    is_exec_func or 
    is_exec_function or 
    is_executor_closure or 
    is_executor_func or 
    is_executor_function or
    is_our_closure or 
    is_our_func or
    is_our_function or 
    is_synapse_closure or 
    is_synapse_func or 
    is_synapse_function or 
    iselectronfunction or 
    isexecclosure or 
    isexecfunc or 
    isexecfunction or 
    isexecutorclosure or
    isexecutorfunc or 
    isexecutorfunction or
    isfluxusfunction or 
    iskrnlclosure or
    iskrnlfunction or
    isourclosure or 
    isourfunc or
    isourfunction or
    isoxygenfunction
    
-- Disable non exec cons

local disabled_signals = {}
local function dnec(signal, id)
    disabled_signals[id] = disabled_signals[id] or {}
        
    if (#disabled_signals[id] ~= 0) then warn'returning' return end
    
    local average = getconnections(signal)
    for i = 1, #average do 
        local connection = average[i]
        local confunc = connection.Function
                
        if (type(confunc) == 'function' and islclosure(confunc) and not isexecclosure(confunc)) then
            tabInsert(disabled_signals[id], connection)
            connection:Disable()
        end
    end
    
end
-- Reenable non exec cons
local function enec(id)
    local signals = disabled_signals[id]
    
    if (signals == nil or #signals == 0) then return end
    
    for i = 1, #signals do 
        local connection = signals[i]
        local confunc = connection.Function
        
        if (type(confunc) == 'function' and islclosure(confunc) and not isexecclosure(confunc)) then
            connection:Enable()
        end
    end
    
    tabClear(disabled_signals[id])
end

local scriptCons = {}

-- Locals


local clientPlayer = servPlayers.LocalPlayer
local clientMouse = clientPlayer:GetMouse()
local clientChar = clientPlayer.Character
local clientRoot, clientHumanoid do 
    scriptCons.charRespawn = clientPlayer.CharacterAdded:Connect(function(newChar) 
        clientChar = newChar
        clientRoot = newChar:WaitForChild('HumanoidRootPart', 10)
        clientHumanoid = newChar:WaitForChild('Humanoid', 10)
        
    end)
    
    if (clientChar) then 
        clientRoot = clientChar:FindFirstChild('HumanoidRootPart')
        clientHumanoid = clientChar:FindFirstChild('Humanoid')
    end
end
local clientCamera do 
    clientCamera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
    scriptCons.cameraUpdate = workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function() 
        clientCamera = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
        
    end)
end

local playerNames = {} -- an array of every player's name
local playerExisting = {} -- playerNames, but as a switch dictionary where keys are the names
local playerManagers = {} -- managers of each player
local playerCons = {}  -- connections related to the managers


-- PlayerRemoving and PlayerAdded
do 
    local function removePlayer(player) 
        local thisName = player.Name
        local thisManager = playerManagers[thisName]
        local thisPlayerCons = playerCons[thisName]
                
        if (thisManager.onLeave) then 
            thisManager.onLeave()
        end
        
        for _, con in pairs(thisPlayerCons) do
            con:Disconnect()
        end
        
        thisManager.onDeath = nil
        thisManager.onLeave = nil
        thisManager.onRemoval = nil
        thisManager.onRespawn = nil
        
        
        playerExisting[thisName] = nil
        playerCons[thisName] = nil 
        playerManagers[thisName] = nil 
        
        table.remove(playerNames, table.find(playerNames, thisName))
        
        --printconsole(('disconnected %s; left'):format(thisName), 255, 255, 0)
    end
    
    
    local function readyPlayer(player) 
        -- init some variables
        local thisName = player.Name
        local thisManager = {}
        local thisPlayerCons = {}
        
        playerExisting[thisName] = true 
        table.insert(playerNames, thisName)
        
        -- setup connections
        thisPlayerCons['chr-add'] = player.CharacterAdded:Connect(function(newChar) 
            local RootPart = newChar:WaitForChild('HumanoidRootPart', 3)
            local Humanoid = newChar:WaitForChild('Humanoid', 3)
            
            if (thisManager.onRespawn) then
                thisManager.onRespawn(newChar, RootPart, Humanoid)
            end
            thisManager.Character = newChar
            thisManager.RootPart = RootPart
            thisManager.Humanoid = Humanoid
            
            
            thisPlayerCons['chr-die'] = Humanoid.Died:Connect(function() 
                if (thisManager.onDeath) then
                    thisManager.onDeath()
                end
            end)
            
            --printconsole(('updated %s character'):format(thisName), 128, 128, 255)
        end)
        thisPlayerCons['chr-rem'] = player.CharacterRemoving:Connect(function() 
            if (thisManager.onRemoval) then
                thisManager.onRemoval()
            end
            thisManager.Character = nil
            thisManager.RootPart = nil
            thisManager.Humanoid = nil 
            
            --printconsole(('removed %s character'):format(thisName), 128, 128, 255)
        end)
        thisPlayerCons['team'] = player:GetPropertyChangedSignal('Team'):Connect(function() 
            thisManager.Team = player.Team
            
            --printconsole(('updated %s team'):format(thisName), 128, 128, 255)
        end)
        
        if (player.Character) then
            local Character = player.Character
            local Humanoid = Character:FindFirstChild('Humanoid')
            local RootPart = Character:FindFirstChild('HumanoidRootPart')
            thisManager.Character = Character
            thisManager.RootPart = RootPart
            thisManager.Humanoid = Humanoid 
            
            --printconsole(('init %s character'):format(thisName), 128, 128, 255)
        end
        thisManager.Team = player.Team
        thisManager.Player = player
        
        
        -- finalize shit
        playerManagers[thisName] = thisManager
        playerCons[thisName] = thisPlayerCons
        
        --printconsole(('readied %s'):format(thisName), 0, 255, 0)
    end
    
    for _, player in ipairs(servPlayers:GetPlayers()) do
        if (player ~= clientPlayer) then
            readyPlayer(player)
        end
    end
    scriptCons.pm_playerAdd = servPlayers.PlayerAdded:Connect(readyPlayer)
    scriptCons.pm_playerRemove = servPlayers.PlayerRemoving:Connect(removePlayer)
    
end





local fakechar do 
    fakechar = instNew('Model')
    fakechar.Name = getnext()


    local Head = instNew('Part')
    Head.Anchored = false
    Head.CanCollide = false
    Head.Name = 'Head'
    Head.Size = vec3(2, 1, 1)
    Head.Transparency = 0
    Head.Parent = fakechar

    local Torso = instNew('Part')
    Torso.Anchored = false
    Torso.CanCollide = false
    Torso.Name = 'Torso'
    Torso.Size = vec3(2, 2, 1)
    Torso.Parent = fakechar

    local Left_Arm = instNew('Part')
    Left_Arm.Anchored = false
    Left_Arm.CanCollide = false
    Left_Arm.Name = 'Left Arm'
    Left_Arm.Size = vec3(1, 2, 1)
    Left_Arm.Parent = fakechar

    local Right_Arm = instNew('Part')
    Right_Arm.Anchored = false
    Right_Arm.CanCollide = false
    Right_Arm.Name = 'Right Arm'
    Right_Arm.Size = vec3(1, 2, 1)
    Right_Arm.Parent = fakechar

    local Left_Leg = instNew('Part')
    Left_Leg.Anchored = false
    Left_Leg.CanCollide = false
    Left_Leg.Name = 'Left Leg'
    Left_Leg.Size = vec3(1, 2, 1)
    Left_Leg.Parent = fakechar

    local Right_Leg = instNew('Part')
    Right_Leg.Anchored = false
    Right_Leg.CanCollide = false
    Right_Leg.Name = 'Right Leg'
    Right_Leg.Size = vec3(1, 2, 1)
    Right_Leg.Parent = fakechar

    local HumanoidRootPart = instNew('Part')
    HumanoidRootPart.Anchored = true
    HumanoidRootPart.CanCollide = false
    HumanoidRootPart.Name = 'HumanoidRootPart'
    HumanoidRootPart.Size = vec3(2, 2, 1)
    HumanoidRootPart.Transparency = 1
    HumanoidRootPart.Parent = fakechar

    local Right_Shoulder = instNew('Motor6D')
    Right_Shoulder.C0 = cfrNew(1, 0.5, 0)
    Right_Shoulder.C1 = cfrNew(-0.5, 0.5, 0)
    Right_Shoulder.Name = 'Right Shoulder'
    Right_Shoulder.Part0 = Torso
    Right_Shoulder.Part1 = Right_Arm
    Right_Shoulder.Parent = Torso

    local Left_Shoulder = instNew('Motor6D')
    Left_Shoulder.C0 = cfrNew(-1, 0.5, 0)
    Left_Shoulder.C1 = cfrNew(0.5, 0.5, 0)
    Left_Shoulder.Name = 'Left Shoulder'
    Left_Shoulder.Part0 = Torso
    Left_Shoulder.Part1 = Left_Arm
    Left_Shoulder.Parent = Torso

    local Right_Hip = instNew('Motor6D')
    Right_Hip.C0 = cfrNew(1, -1, 0)
    Right_Hip.C1 = cfrNew(0.5, 1, 0)
    Right_Hip.Name = 'Right Hip'
    Right_Hip.Part0 = Torso
    Right_Hip.Part1 = Right_Leg
    Right_Hip.Parent = Torso

    local Left_Hip = instNew('Motor6D')
    Left_Hip.C0 = cfrNew(-1, -1, 0)
    Left_Hip.C1 = cfrNew(-0.5, 1, 0)
    Left_Hip.Name = 'Left Hip'
    Left_Hip.Part0 = Torso
    Left_Hip.Part1 = Left_Leg
    Left_Hip.Parent = Torso

    local Neck = instNew('Motor6D')
    Neck.C0 = cfrNew(0, 1, 0)
    Neck.C1 = cfrNew(0, -0.5, 0)
    Neck.Name = 'Neck'
    Neck.Part0 = Torso
    Neck.Part1 = Head
    Neck.Parent = Torso

    local RootJoint = instNew('Motor6D')
    RootJoint.C0 = cfrNew(0, 0, 0)
    RootJoint.C1 = cfrNew(0, 0, 0)
    RootJoint.Name = 'RootJoint'
    RootJoint.Part0 = HumanoidRootPart
    RootJoint.Part1 = Torso
    RootJoint.Parent = HumanoidRootPart
    
    do 
        local _ = fakechar:GetChildren()
        for i = 1, #_ do
            local c = _[i]
            if (not c:IsA('BasePart')) then continue end
            c.Material = 1584
            c.Color = colNew(0.52, 0.52, 0.55)
            
            local _ = instNew('BoxHandleAdornment')
            _.Adornee = c
            _.AlwaysOnTop = true
            _.ZIndex = 10
            _.Color3 = RLTHEMEDATA['ge'][1]
            _.Size = c.Size
            _.Transparency = 0.5
            _.Parent = c
        end
    end
end



ui:Connect('Destroying', function() 
    for i,v in pairs(scriptCons) do v:Disconnect() end
    for i,v in ipairs(ui:GetModules()) do 
        if (v.Toggle and v:isEnabled()) then
            v:Toggle()
        end
    end

    for i = 1, #playerNames do 
        local playerName = playerNames[i]
        
        do 
            for i,v in pairs(playerCons[playerName]) do
                v:Disconnect()
            end
            playerManagers[PlayerName] = nil
        end 
        playerNames[i] = nil
    end
    playerNames = nil
    playerManagers = nil
    
    servInput.MouseIconEnabled = true
    
    fakechar:Destroy()
end)

do
    local betatxt
    do 
        local col = RLTHEMEDATA['ge'][1]
        betatxt = (' <font color="rgb(%d,%d,%d)">[BETA]</font>'):format(col.R*255, col.G*255, col.B*255)
    end

    local AimbotTarget
    local AimbotStatus = ''

    local m_combat = ui:newMenu('Combat') do 
        -- Aimbot
        local c_aimbot = m_combat:addMod('Aimbot')
        do 
            local s_SafetyKey = c_aimbot:AddHotkey('Aimbot key'):setTooltip('Only aims if this key is held. If no key is set, Mouse2 is checked for instead')
            
            local s_AliveCheck = c_aimbot:addToggle('Alive check'):setTooltip('Skips over targets that are dead')
            local s_DistanceCheck = c_aimbot:addToggle('Distance check'):setTooltip('Skips over targets that are too far away from your character')
            local s_FovCheck = c_aimbot:addToggle('FOV check'):setTooltip('Skips over the target if they are not within the set FOV')
            local s_TeamCheck = c_aimbot:addToggle('Team check'):setTooltip('Skips over the target if they are on your team')
            local s_VisibilityCheck = c_aimbot:addToggle('Visibility check'):setTooltip('Skips over the target if they are not visible')
            
            local s_DeltaTime = c_aimbot:addToggle('Deltatime safe'):setTooltip('Makes mouse movement more consistent across different frame rates, but ends up decreasing aim precision')
            local s_LockOn = c_aimbot:addToggle('Lock on'):setTooltip('Locks onto a target until aiming is disabled or the target loses focus')
            local s_Prediction = c_aimbot:addToggle('Prediction'):setTooltip('Aims at the position ahead of the target. A little scuffed, but can work good enough.')
            
            
            
            local s_DistanceSlider = c_aimbot:addSlider('Distance',{min=100,max=10000,cur=2000}):setTooltip('Targets only get considered if their distance is less than this number. Requires <b>Distance check</b> to be enabled')
            local s_FovSlider = c_aimbot:addSlider('FOV',{min=50,max=500,cur=150,step=1}):setTooltip('The size of the FOV. Requires <b>FOV check</b> to be enabled')
            local s_PredictionSlider = c_aimbot:addSlider('Prediction',{min=0.1,max=1,cur=0,step=0.1}):setTooltip('How far prediction looks ahead. Requires <b>Prediction</b> to be enabled')
            local s_SmoothnessSlider = c_aimbot:addSlider('Smoothness',{min=0,max=1,cur=0.5,step=0.01}):setTooltip('How smooth the aimbot is; 0 is no smoothing, 1 is maximum smoothing')
            local s_VerticalOffset = c_aimbot:addSlider('Y Offset (Studs)',{min=-2,max=2,step=-0.1,cur=0}):setTooltip('Optional Y offset. <b>Works in studs</b>')
            --local s_VerticalPxOffset = c_aimbot:addSlider('Y Offset (Px)',{min=-200,max=200,step=1,cur=0}):setTooltip('Optional Y offset. <b>Works in pixels</b>')
            --local s_HorizontalOffset = c_aimbot:addSlider('X Offset (Px)',{min=-200,max=200,step=1,cur=0}):setTooltip('Optional X offset. <b>Works in pixels</b>')
            
            local s_AimbotMethod = c_aimbot:addDropdown('Aimbot method',true):setTooltip('The way aimbot makes you look at someone')
            s_AimbotMethod:addOption('Mouse'):setTooltip('Uses input functions to move your mouse. Works well for nearly every game'):Select()
            s_AimbotMethod:addOption('Camera'):setTooltip('Usually has better results than Mouse but may fuck shit up in some games')
            
            local s_CursorMove = c_aimbot:addToggle('Move crosshair'):setTooltip('Moves the crosshair over the target, even when not aiming. <b>Requires the Crosshair module to be enabled.</b>')
            
            local AliveCheck = s_AliveCheck:getValue()
            local DistanceCheck = s_DistanceCheck:getValue()
            local FovCheck = s_FovCheck:getValue()
            local TeamCheck = s_TeamCheck:getValue()
            local VisibilityCheck = s_VisibilityCheck:getValue()
            
            local LockOn = s_LockOn:getValue()
            local SafetyKey = s_SafetyKey:getValue()
            local Prediction = s_Prediction:getValue()
            local Deltatime = s_DeltaTime:getValue()
            
            local Fov = 9999--s_FovSlider:getValue()
            local Distance = s_DistanceSlider:getValue()
            local Smoothness = s_SmoothnessSlider:getValue()
            local PredictionValue = s_PredictionSlider:getValue()
            local VerticalOffset = s_VerticalOffset:getValue()
            local CursorMove = s_CursorMove:getValue()
            --local VerticalPxOffset = s_VerticalPxOffset:getValue()
            --local HorizontalOffset = s_HorizontalOffset:getValue()
            
            local AimbotMethod = s_AimbotMethod:GetSelection()
            
            local FovCircle
            local FovCircleOutline
            
            
            do
                s_AliveCheck:Connect('Toggled', function(t) 
                    AliveCheck = t
                end)
                s_DistanceCheck:Connect('Toggled', function(t) 
                    DistanceCheck = t
                end)
                s_FovCheck:Connect('Toggled', function(t) 
                    FovCheck = t
                    
                    Fov = FovCheck and s_FovSlider:getValue() or 9999
                    c_aimbot:Reset() -- no clue why the hell this is needed but oh well
                end)
                s_TeamCheck:Connect('Toggled', function(t) 
                    TeamCheck = t
                end)
                s_VisibilityCheck:Connect('Toggled', function(t) 
                    VisibilityCheck = t
                end)
                s_LockOn:Connect('Toggled', function(t) 
                    LockOn = t
                end)
                s_SafetyKey:Connect('HotkeySet', function(k) 
                    SafetyKey = k
                end)
                s_Prediction:Connect('Toggled', function(t) 
                    Prediction = t
                end)
                s_DeltaTime:Connect('Toggled', function(t) 
                    Deltatime = t
                end)
                s_CursorMove:Connect('Toggled', function(t) 
                    CursorMove = t
                end)
                
                
                do
                    local tempCircle = false
                    local last = tick()
                    s_FovSlider:Connect('Changed', function(v)
                        Fov = v;
                        last = tick()
                        if (FovCircle) then 
                            FovCircle.Radius = Fov 
                            FovCircleOutline.Radius = Fov
                        else
                            tempCircle = true
                            FovCircle = drawNew('Circle')
                            FovCircle.NumSides = 40
                            FovCircle.Thickness = 2
                            FovCircle.Visible = true
                            FovCircle.Radius = Fov
                            FovCircle.ZIndex = 2
                                            
                            FovCircleOutline = drawNew('Circle')
                            FovCircleOutline.NumSides = 40
                            FovCircleOutline.Thickness = 4
                            FovCircleOutline.Visible = true
                            FovCircleOutline.Radius = Fov
                            FovCircleOutline.ZIndex = 1
                            servRun:BindToRenderStep('RL-fovanim',2000,function() 
                                local mp = servInput:GetMouseLocation()
                                FovCircle.Position = mp
                                FovCircleOutline.Position = mp
                                FovCircle.Color = RGBCOLOR
                            end)
                            
                            spawn(function()
                                
                                while tick() - last < 0.2 do
                                    wait() 
                                end
                                servRun:UnbindFromRenderStep('RL-fovanim')
                                if (tempCircle) then
                                    tempCircle = false
                                    FovCircle:Remove()
                                    FovCircleOutline:Remove()
                                    FovCircle = nil
                                    FovCircleOutline = nil 
                                end
                            end)
                        end
                    end)
                end
                
                
                s_DistanceSlider:Connect('Changed', function(v)Distance = v;end)
                s_SmoothnessSlider:Connect('Changed', function(v)Smoothness = v;end)
                s_PredictionSlider:Connect('Changed', function(v)PredictionValue = v;end)
                s_VerticalOffset:Connect('Changed', function(v)VerticalOffset = v;end)
                --s_VerticalPxOffset:Connect('Changed', function(v)VerticalPxOffset = v;end)
                --s_HorizontalOffset:Connect('Changed', function(v)HorizontalOffset = v;end)
                
                s_AimbotMethod:Connect('Changed', function(v)
                    AimbotMethod = v
                    c_aimbot:Reset()
                end)
            end
                    
            local AimbotConnection
            local PreviousTarget
            local CurrentTarget
            
            
            c_aimbot:Connect('Enabled', function()
                local GetClosestPlayerToCursor
                
                FovCircle = drawNew('Circle')
                FovCircle.NumSides = 40
                FovCircle.Thickness = 2
                FovCircle.Visible = FovCheck
                FovCircle.Radius = Fov
                FovCircle.ZIndex = 2
                
                FovCircleOutline = drawNew('Circle')
                FovCircleOutline.NumSides = 40
                FovCircleOutline.Thickness = 4
                FovCircleOutline.Visible = FovCheck
                FovCircleOutline.Radius = Fov
                FovCircleOutline.ZIndex = 1 
                
                
                local NextTarget
                do 
                    
                    local function dist(cpos, rootpos) 
                        if (DistanceCheck) then
                            return ((cpos - rootpos).Magnitude < Distance)
                        else
                            return true
                        end
                    end
                    
                    local function alive(hum) 
                        if (AliveCheck and hum) then
                            return (hum.Health > 0)
                        else
                            return true 
                        end
                    end
                    
                    local function team(team) 
                        if (TeamCheck) then
                            return (team ~= clientPlayer.Team)
                        else
                            return true
                        end
                    end
                    
                    local function vis(root) 
                        if (VisibilityCheck) then
                            local clear = clientCamera:GetPartsObscuringTarget({root.Position}, {clientChar})
                            return (#clear == 0)
                        else
                            return true 
                        end
                    end
                    
                    local function lock(targ) 
                        if (LockOn) then
                            if (PreviousTarget) then
                                return (targ == PreviousTarget)
                            else
                                return true
                            end
                        else
                            return true 
                        end
                    end
                    
                    local function predic(part) 
                        if (Prediction) then
                            return part and (part.Position + (part.Velocity * PredictionValue) + vec3(0, VerticalOffset, 0))
                        else
                            return part and (part.Position + vec3(0, VerticalOffset, 0))
                        end
                    end
                    
                    if (AimbotMethod == 'Mouse') then 
                        NextTarget = function(mp) 
                            local FinalTarget, FinalVec2, FinalMag = nil, nil, Fov
                            local MousePosition = mp or vec2(clientMouse.X, clientMouse.Y)
                            
                            local CameraPos = clientCamera.CFrame.Position
                            
                            AimbotTarget = nil 
                            for i = 1, #playerNames do 
                                local plrObject = playerManagers[playerNames[i]]
                                local Root, Humanoid = plrObject.RootPart, plrObject.Humanoid
                                
                                local CurVec3 = predic(Root)
                                -- the funny if statement 🗿
                                if (CurVec3 and lock(Root) and team(plrObject.Team) and alive(Humanoid) and dist(CameraPos, CurVec3) and vis(Root)) then
                                    local CurVec2, CurVis = clientCamera:WorldToViewportPoint(CurVec3)
                                    
                                    
                                    if (CurVis) then
                                        CurVec2 = vec2(CurVec2.X, CurVec2.Y)
                                        local CurMag = (MousePosition - CurVec2).Magnitude
                                        if (CurMag < FinalMag) then
                                            FinalTarget, FinalVec2, FinalMag = Root, CurVec2, CurMag
                                        end
                                    end
                                end
                            end
                            
                            AimbotTarget = FinalVec2
                            return FinalTarget, FinalVec2, FinalMag
                        end 
                    elseif (AimbotMethod == 'Camera') then
                        NextTarget = function(mp) 
                            local FinalTarget, FinalVec3, FinalVec2
                            local FinalMag = Fov
                            local MousePosition = mp or vec2(clientMouse.X, clientMouse.Y)
                            
                            local CameraPos = clientCamera.CFrame.Position
                            
                            AimbotTarget = nil 
                            for i = 1, #playerNames do 
                                local plrObject = playerManagers[playerNames[i]]
                                local Root, Humanoid = plrObject.RootPart, plrObject.Humanoid
                                
                                local CurVec3 = predic(Root)
                                -- the funny if statement 🗿
                                if (CurVec3 and lock(Root) and team(plrObject.Team) and alive(Humanoid) and dist(CameraPos, CurVec3) and vis(Root)) then
                                    local CurVec2, CurVis = clientCamera:WorldToViewportPoint(CurVec3)
                                    
                                    
                                    if (CurVis) then
                                        CurVec2 = vec2(CurVec2.X, CurVec2.Y)
                                        local CurMag = (MousePosition - CurVec2).Magnitude
                                        if (CurMag < FinalMag) then
                                            FinalMag = CurMag
                                            FinalTarget = Root
                                            FinalVec2 = CurVec2
                                            FinalVec3 = CurVec3
                                        end
                                    end
                                end
                            end
                            
                            AimbotTarget = FinalVec2
                            return FinalTarget, FinalVec3
                        end 
                    end
                end
                
                if (AimbotMethod == 'Camera') then
                    AimbotConnection = servRun.RenderStepped:Connect(function() 
                        
                        
                        local mp = servInput:GetMouseLocation()--+vec2(HorizontalOffset, VerticalPxOffset)
                        FovCircle.Position = mp
                        FovCircleOutline.Position = mp
                        FovCircle.Color = RGBCOLOR
                        
                        FovCircle.Visible = FovCheck
                        FovCircleOutline.Visible = FovCheck
                        
                        local target, position, dist = NextTarget(mp)
                        if (SafetyKey) then
                            if (not servInput:IsKeyDown(SafetyKey)) then
                                AimbotStatus = 'aimbot off'
                                PreviousTarget = nil
                                if (not CursorMove) then AimbotTarget = nil end
                                return
                            end
                        else
                            if (not servInput:IsMouseButtonPressed(1)) then
                                AimbotStatus = 'aimbot off'
                                PreviousTarget = nil
                                if (not CursorMove) then AimbotTarget = nil end
                                return 
                            end
                        end
                        
                        
                        if (W_WindowOpen) then return end 
                        AimbotStatus = target and 'aiming' or 'no target'
                        PreviousTarget = target
                        
                        if (position) then
                            local _ = clientCamera.CFrame
                            clientCamera.CFrame = cfrNew(_.Position, position):lerp(_, Smoothness)
                        end
                    end)
                elseif (AimbotMethod == 'Mouse') then
                    AimbotConnection = servRun.RenderStepped:Connect(function(dt) 
                        local mp = servInput:GetMouseLocation()--+vec2(HorizontalOffset, VerticalPxOffset)
                        FovCircle.Position = mp
                        FovCircleOutline.Position = mp
                        FovCircle.Color = RGBCOLOR
                        
                        FovCircle.Visible = FovCheck
                        FovCircleOutline.Visible = FovCheck
                        
                        local target, position, dist = NextTarget(mp)
                        if (SafetyKey) then
                            if (not servInput:IsKeyDown(SafetyKey)) then
                                AimbotStatus = 'aimbot off'
                                PreviousTarget = nil
                                if (not CursorMove) then AimbotTarget = nil end
                                return
                            end
                        else
                            if (not servInput:IsMouseButtonPressed(1)) then
                                AimbotStatus = 'aimbot off'
                                PreviousTarget = nil
                                if (not CursorMove) then AimbotTarget = nil end
                                return 
                            end
                        end
                        
                        --local target, position, dist = NextTarget(mp)
                        if (W_WindowOpen) then return end 
                        PreviousTarget = target
                        AimbotStatus = target and 'aiming' or 'no target'
                        
                        
                        if (position) then
                            local delta = position - mp
                            delta *= Deltatime and ((1 - Smoothness) * dt * 75) or (1 - Smoothness)
                            mousemoverel(delta.X, delta.Y)
                        end
                    end)
                end
            end)
            
            c_aimbot:Connect('Disabled', function() 
                AimbotTarget = nil
                AimbotStatus = ''
                
                if (AimbotConnection) then 
                    AimbotConnection:Disconnect() 
                    AimbotConnection = nil 
                end
                
                if (FovCircle) then 
                    FovCircle:Remove()
                    FovCircle = nil
                end
                
                if (FovCircleOutline) then 
                    FovCircleOutline:Remove()
                    FovCircleOutline = nil
                end
            end)
        end
        
        -- Hitboxes
        local c_hitbox = m_combat:addMod('Hitboxes')
        do 
            local s_HitboxSize = c_hitbox:addSlider('Size',{min=2,max=50,step=0.1,value=5}):setTooltip('How large (in studs) the hitboxes are')
            local s_Transparency = c_hitbox:addSlider('Transparency',{min=0,max=1,step=0.01,value=0.5}):setTooltip('How transparent the hitboxes are')
            
            local s_RGB = c_hitbox:addToggle('RGB'):setTooltip('Makes hitboxes RGB instead of gray')
            local s_TeamCheck = c_hitbox:addToggle('Team check'):setTooltip('Disables hbe for teammates')
            local s_XZOnly = c_hitbox:addToggle('XZ only'):setTooltip('Disables expansion on the Y axis, used for certain games that may break with this disabled')        
            
            local HitboxSize = s_HitboxSize:getValue()
            local Transparency = s_Transparency:getValue()
            
            local RGB = s_RGB:getValue()
            local TeamCheck = s_TeamCheck:getValue()
            local XZOnly = s_XZOnly:getValue()
            
            s_HitboxSize:Connect('Changed',function(v)HitboxSize=v;end)
            s_Transparency:Connect('Changed',function(v)Transparency=v;end)
            s_RGB:Connect('Toggled',function(v)RGB=v;end)
            s_TeamCheck:Connect('Toggled',function(v)TeamCheck=v;c_hitbox:Reset();end)
            s_XZOnly:Connect('Toggled',function(v)XZOnly=v;end)
            
            
            local HitboxConnection
            local old_color
            local old_size 

            c_hitbox:Connect('Enabled',function() 
                old_color = clientRoot.Color 
                old_size = clientRoot.Size
                
                if (TeamCheck) then
                    
                    HitboxConnection = servRun.RenderStepped:Connect(function() 
                        local size = vec3(HitboxSize, XZOnly and 2 or HitboxSize, HitboxSize)
                        local lteam = clientPlayer.Team
                        
                        for i = 1, #playerNames do 
                            local pobj = playerManagers[playerNames[i]]
                            if (pobj.Player.Team == lteam) then continue end
                            local humrp = pobj.RootPart
                            
                            if (humrp) then
                                humrp.Size = size
                                humrp.Color = RGB and RGBCOLOR or old_color
                                humrp.Transparency = Transparency
                            end
                        end
                    end)
                else 
                    HitboxConnection = servRun.RenderStepped:Connect(function() 
                        local size = vec3(HitboxSize, XZOnly and 2 or HitboxSize, HitboxSize)
                        for i = 1, #playerNames do 
                            local pobj = playerManagers[playerNames[i]]
                            local humrp = pobj.RootPart
                            
                            if (humrp) then
                                humrp.Size = size
                                humrp.Color = RGB and RGBCOLOR or old_color
                                humrp.Transparency = Transparency
                            end
                        end
                    end)
                end
            end)
            c_hitbox:Connect('Disabled',function() 
                if (HitboxConnection) then 
                    HitboxConnection:Disconnect() HitboxConnection = nil
                end
                for i = 1, #playerNames do 
                    local pobj = playerManagers[playerNames[i]]
                    local rp = pobj.RootPart
                    if (rp) then
                        rp.Transparency = 1
                        rp.Color = old_color
                        rp.Size = old_size 
                    end
                end
            end)
        end
        
        
        -- Trig bot
        
        --[[
        do 
            local s_MouseButton = c_trigbot:addDropdown('Mouse button'):setTooltip('The mouse button that gets clicked')
            local s_ShootMode   = c_trigbot:addDropdown('Shoot mode'):setTooltip('The way it\'ll shoot. Different modes work better for different guns')
            local s_ScanMode    = c_trigbot:addDropdown('Scan mode'):setTooltip('The way triggerbot finds the target')
            
            local s_SafetyKey   = c_trigbot:AddHotkey('Safety key'):setTooltip('Will only shoot if this key is held')
            local s_CheckRate   = c_trigbot:addSlider('Check rate',{min=0,max=0.1,step=0.01,cur=0}):setTooltip('How often targets are checked for')
            local s_ClickSpeed  = c_trigbot:addSlider('Spam speed',{min=0,max=0.5,step=0.01,cur=0}):setTooltip('The delay between clicks. Only for Spam')
            local s_Teamcheck   = c_trigbot:addToggle('Team check'):setTooltip('Disables Triggerbot for your teammates')
            local s_Delay       = c_trigbot:addSlider('Delay',{min=0,max=0.1,step=0.01,cur=0}):setTooltip('Optional delay after a target\'s detected')
            
            s_MouseButton:addOption('Mouse1'):setTooltip('Uses Mouse1 (left click)'):Select()
            s_MouseButton:addOption('Mouse2'):setTooltip('Uses Mouse2 (right click')
            
            s_ShootMode:addOption('Spam'):setTooltip('Spam clicks button while there\'s a target. Use for semi-auto weapons'):Select()
            s_ShootMode:addOption('Hold'):setTooltip('Holds button down while there\'s a target. Use for automatic weapons')
            s_ShootMode:addOption('Single'):setTooltip('Clicks button once when there\'s a target. Use for semi-auto / snipers'):Select()
            
            s_ScanMode:addOption('Raycast'):setTooltip('Raycasts and checks if the target is valid. Can work for both players and NPCs; heavily game dependant')
            s_ScanMode:addOption('Proximity'):setTooltip('Checks if any player characters are close to your mouse.')
            
            local l_MouseButton = s_MouseButton:getValue()
            local l_ShootMode   = s_ShootMode:getValue()
            
            
            
            
            
            
            local wl
            c_trigbot:Connect('Enabled',function() 
                ui:Notify('Triggerbot','Triggerbot is currently disabled while it is being remade. Please wait for it to be updated.',3,1)
                do return end 
                
                wl = {} do
                    wl['HumanoidRootPart'] = true
                    wl['Left Leg'] = true
                    wl['Right Leg'] = true
                    wl['Left Arm'] = true
                    wl['Right Arm'] = true
                    wl['Torso'] = true
                    wl['Head'] = true        
                    wl['UpperTorso'] = true
                    wl['LowerTorso'] = true
                    wl['LeftUpperArm'] = true
                    wl['LeftLowerArm'] = true
                    wl['LeftHand'] = true
                    wl['RightUpperArm'] = true
                    wl['RightLowerArm'] = true
                    wl['RightHand'] = true
                    wl['LeftUpperLeg'] = true
                    wl['LeftLowerLeg'] = true
                    wl['LeftFoot'] = true
                    wl['RightUpperLeg'] = true
                    wl['RightLowerLeg'] = true
                    wl['RightFoot'] = true
                end
                
                local TrySpam
                local TryHold
                local CheckTeam
            end)
            
            c_trigbot:Connect('Disabled',function() 
                wl = nil
            end)
            
            c_trigbot:setTooltip('Automatically clicks when you mouse over a player')
        end
        ]]
        
        c_aimbot:setTooltip('Locks your aim onto other players. Works in a variety of games, and has a ton of settings')
        c_hitbox:setTooltip('Expand other players\' hitboxes. Depending on the game, this lets you hit them easier. <b>Note that this mod is detectable - always test on an alt and never use your main!</b>')
    end
    local m_player = ui:newMenu('Player') do 
        local p_animspeed   = m_player:addMod('Animspeed')
        local p_antiafk     = m_player:addMod('Anti-AFK')
        local p_anticrash   = m_player:addMod('Anti-crash')
        local p_antifling   = m_player:addMod('Anti-fling')
        local p_antiwarp    = m_player:addMod('Anti-warp')
        local p_antiplayer  = m_player:addMod('Anti-player')
        local p_autoclick   = m_player:addMod('Auto clicker')
        local p_brespawn    = m_player:addMod('Better reset', 'Toggle')
        local p_flag        = m_player:addMod('Fakelag')
        local p_flashback   = m_player:addMod('Flashback')
        local p_safemin     = m_player:addMod('Safe minimize')
        local p_waypoints   = m_player:addMod('Waypoints')
        
        -- Anim speed
        do 
            local s_mode = p_animspeed:addDropdown('Mode',true):setTooltip('The way animation speed gets modified')
            local s_max = p_animspeed:addToggle('Max speed'):setTooltip('Sets speed to the highest it possibly can')
            local s_perframe = p_animspeed:addToggle('Per frame'):setTooltip('Updates animation speeds per frame')
            local s_percent = p_animspeed:addSlider('Speed (Percent)',{min=0,max=500,cur=100}):setTooltip('Multiplies every animation\'s speed by this percent value')
            local s_speed = p_animspeed:addSlider('Speed (Absolute)',{min=0,max=100,cur=1,step=0.01}):setTooltip('Sets every animation\'s speed to this value')
            s_mode:addOption('Absolute'):setTooltip('Sets the animation speeds to this value'):Select()
            s_mode:addOption('Percent'):setTooltip('Multiplies the animation speeds by this percent')
            
            
            local max = s_max:isEnabled()
            local speed = s_speed:getValue()
            local percent = s_percent:getValue()
            local mode = s_mode:GetSelection()
            
            s_max:Connect('Toggled',function(t)max=t;end)
            s_speed:Connect('Changed',function(t)speed=t;end)
            s_percent:Connect('Changed',function(t)percent=t;end)
            s_mode:Connect('Changed',function(t)mode=t;p_animspeed:Reset()end)
            
            
            local animcon
            p_animspeed:Connect('Enabled',function(t) 
                local noob
                if (max) then
                    noob = function(track) 
                        track:AdjustSpeed(99999)
                    end
                else
                    if (mode == 'Absolute') then
                        noob = function(track) 
                            track:AdjustSpeed(speed)
                        end
                    else
                        noob = function(track) 
                            track:AdjustSpeed(track.Speed * (percent/100))
                        end
                    end
                end
                
                if (s_perframe:isEnabled()) then
                    servRun:BindToRenderStep('RL-AnimSpeed',2356,function()
                        local tracks = clientHumanoid:GetPlayingAnimationTracks()
                        
                        for i = 1, #tracks do 
                            noob(tracks[i])
                        end
                    end)
                else
                    animcon = clientHumanoid.AnimationPlayed:Connect(noob)
                
                    local tracks = clientHumanoid:GetPlayingAnimationTracks()
                    
                    for i = 1, #tracks do 
                        noob(tracks[i])
                    end
                end
                
                resetcon = clientPlayer.CharacterAdded:Connect(function() 
                    wait()
                    p_animspeed:Reset()
                end)
            end)
            
            p_animspeed:Connect('Disabled',function() 
                if (animcon) then animcon:Disconnect() animcon = nil end
                if (resetcon) then resetcon:Disconnect() resetcon = nil end
                servRun:UnbindFromRenderStep('RL-AnimSpeed')
            end)
            
        end
        -- Anti afk
        do 
            local p_afk_mode   = p_antiafk:addDropdown('Mode', true)
            do 
                local _ = p_afk_mode:addOption('Standard')
                :Select()
                :setTooltip('Disables connections related to player idling. Impossible to detect, has no side-effects');
                
                p_afk_mode:addOption('Move on idle'):setTooltip('Automatically moves your character when the client idles')
                p_afk_mode:addOption('Walk around'):setTooltip('Randomly moves your character around. Useful for games with more afk checks than the default roblox ones')
            end
            
            
            local c
            local p = 'Standard'
            p_antiafk:Connect('Enabled', function() 
                if (p == 'Standard') then
                    dnec(clientPlayer.Idled, 'plr_idled')
                    return 
                end
                if (p == 'Move on idle') then
                    c = clientPlayer.Idled:Connect(function() 
                        clientHumanoid:MoveTo(clientRoot.Position + vec3(0, 0, 2))
                    end)
                    return 
                end
            
                if (p == 'Walk around') then
                    spawn(function() 
                        local base = clientRoot.Position
                        while (p_antiafk:isEnabled()) do 
                            wait(mathRand()*8)
                            clientHumanoid:MoveTo(base + vec3(
                                (mathRand()-.5)*15,
                                0,
                                (mathRand()-.5)*15)
                            )
                        end
                    end)
                    return
                end
            end)
            p_antiafk:Connect('Disabled', function()
                enec('plr_idled')
                
                if (c) then
                    c:Disconnect()
                    c = nil
                end
            end)
            p_afk_mode:Connect('Changed', function(v) 
                p = v
                p_antiafk:Reset()
            end)
        end
        -- Anticrash
        do 
            local scriptCtx = game:GetService('ScriptContext')
            
            local s_antiDelay = p_anticrash:addSlider('Delay',{min=0.1,max=5,cur=2,step=0.1},true):setTooltip('Anti-crash sensitivity. <b>Setting this too low may mess with your game. Leave it at the default if you don\'t know what this does.</b>')
            
            s_antiDelay:Connect('Changed',function(v) 
                if (p_anticrash:isEnabled()) then
                    scriptCtx:SetTimeout(v)
                end
            end)
            
            p_anticrash:Connect('Toggled',function(t) 
                if t then
                    scriptCtx:SetTimeout(s_antiDelay:getValue())
                else
                    scriptCtx:SetTimeout(99)
                end
            end)
        end
        -- Antifling
        do 
            local s_FreezeMethod = p_antifling:addDropdown('Method', true):setTooltip('The method Antifling uses')
            do 
                s_FreezeMethod:addOption('Anchor'):Select():setTooltip('Anchors your character when someone gets close to you, works the best but limits movement')
                s_FreezeMethod:addOption('Anchor + Safemin'):setTooltip('Combines Anchor and Safemin; anchors when either the screen is out of focus or someones closed to you')
                s_FreezeMethod:addOption('Noclip'):setTooltip('Activates noclip when someones near you. You\'ll still be slightly pushed around')
                s_FreezeMethod:addOption('Teleport'):setTooltip('Teleports you away from them. Funny to use but you may be flung')
            end
            local distance = 25
            local pcon
            
            p_antifling:addSlider('Distance',{min=1,max=50,cur=25,step=0.1}):setTooltip('How close a player has to be to you to trigger the antifling'):Connect('Changed',function(v)distance=v;end)
            
            
            p_antifling:Connect('Enabled', function() 
                local m = s_FreezeMethod:GetSelection()
                dnec(clientRoot.Changed, 'rp_changed')
                dnec(clientRoot:GetPropertyChangedSignal('CanCollide'), 'rp_cancollide')
                dnec(clientRoot:GetPropertyChangedSignal('Anchored'), 'rp_anchored')
                
                if (m == 'Anchor') then
                    pcon = servRun.Heartbeat:Connect(function() 
                        local self_pos = clientRoot.Position
                        clientRoot.Anchored = false
                        for i = 1, #playerNames do 
                            local rootPart = playerManagers[playerNames[i]].RootPart
                            
                            if (rootPart and ((rootPart.Position - self_pos).Magnitude) < distance) then
                                clientRoot.Anchored = true
                                break
                            end
                        end		
                    end)
                elseif (m == 'Anchor + Safemin') then
                    
                    pcon = servRun.Heartbeat:Connect(function()
                        if (isrbxactive() == false) then
                            clientRoot.Anchored = true
                            return
                        end
                        
                        local self_pos = clientRoot.Position
                        clientRoot.Anchored = false
                        for i = 1, #playerNames do 
                            local rootPart = playerManagers[playerNames[i]].RootPart
                            
                            if (rootPart and ((rootPart.Position - self_pos).Magnitude) < distance) then
                                clientRoot.Anchored = true
                                break
                            end
                        end		
                    end)              
                elseif (m == 'Noclip') then
                    pcon = servRun.Heartbeat:Connect(function() 
                        local self_pos = clientRoot.Position
                        for i = 1, #playerNames do 
                            local rootPart = playerManagers[playerNames[i]].RootPart
                            
                            if (rootPart and ((rootPart.Position - self_pos).Magnitude) < distance) then
                                local c = clientChar:GetChildren()
                                for i = 1, #c do 
                                    local v = c[i]
                                    if (v:IsA('BasePart')) then
                                        v.CanCollide = false    
                                    end
                                end
                                break
                            end
                        end		
                    end)
                elseif (m == 'Teleport') then
                    pcon = servRun.Heartbeat:Connect(function() 
                        local self_pos = clientRoot.Position
                        for i = 1, #playerNames do 
                            local rootPart = playerManagers[playerNames[i]].RootPart
                            
                            if (rootPart and ((rootPart.Position - self_pos).Magnitude) < distance) then
                                clientRoot.CFrame += vec3(mathRand(-100,100)*.1,mathRand(0,20)*.1,mathRand(-100,100)*.1)
                                break
                            end
                        end		
                    end)
                end
            end)
            p_antifling:Connect('Disabled', function() 
                if (pcon) then pcon:Disconnect() pcon = nil end		
                if (clientRoot.Anchored) then clientRoot.Anchored = false end
                
                enec('rp_changed')
                enec('rp_cancollide')
                enec('rp_anchored')
            end)
        
        
            s_FreezeMethod:Connect('Changed', function()
                p_antifling:Reset()
            end)
        end
        -- Antiwarp
        do 
            local s_Lerp = p_antiwarp:addSlider('Lerp',{min=0,max=1,cur=1,step=0.01}):setTooltip('How much you will be teleported back when antiwarp gets triggered')
            local s_Dist = p_antiwarp:addSlider('Distance',{min=1,max=150,cur=20,step=0.1}):setTooltip('How far you\'d have to be teleported before it gets set off')
            local Lerp = s_Lerp:getValue()
            local Dist = s_Dist:getValue()
            
            s_Lerp:Connect('Changed',function(v)Lerp=v;end)
            s_Dist:Connect('Changed',function(v)Dist=v;end)
            
            local AntiwarpStep
            
            local CurrentCFrame = clientRoot and clientRoot.CFrame or cfrNew(0,0,0)
            local PreviousCFrame = clientRoot and clientRoot.CFrame or cfrNew(0,0,0)
            
            p_antiwarp:Connect('Enabled',function() 
                dnec(clientRoot.Changed, 'rp_changed')
                dnec(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                
                
                PreviousCFrame = clientRoot.CFrame
                AntiwarpStep = servRun.Heartbeat:Connect(function() 
                    CurrentCFrame = clientRoot.CFrame 
                    
                    if ((CurrentCFrame.Position - PreviousCFrame.Position).Magnitude > Dist) then
                        local _ = CurrentCFrame:lerp(PreviousCFrame, Lerp)
                        PreviousCFrame = _
                        clientRoot.CFrame = _
                    else
                        PreviousCFrame = CurrentCFrame
                    end
                end)
            end)
            p_antiwarp:Connect('Disabled',function() 
                if (AntiwarpStep) then AntiwarpStep:Disconnect() AntiwarpStep = nil end
                
                enec('rp_changed')
                enec('rp_cframe')
            end)
        end
        -- Antiplayer
        do 
            local settingDist = p_antiplayer:addSlider('Distance',{min=50,max=3000,cur=500,step=1}):setTooltip('How close a player has to be to trip the antiplayer')
            local settingKick = p_antiplayer:addToggle('Kick when triggered'):setTooltip('Kicks you from the game if someone gets too close')
            
            local valueDist = settingDist:getValue()
            local valueKick = settingKick:getValue()
            
            settingDist:Connect('Changed', function(v)
                valueDist = v  
            end)
            settingKick:Connect('Toggled', function(v)
                valueKick = v  
            end)
            
            
            local playerAddCn
            local playerRemCn
            local runCn
            
            local drawingObjects = {}
            p_antiplayer:Connect('Enabled', function()
                local function initPlayer(player)
                    local playerName = player.Name
                    
                    local obj = {} do 
                        local nametag = Drawing.new('Text')
                        nametag.Text = playerName
                        nametag.Size = 20
                        nametag.Center = true
                        nametag.Outline = true
                        nametag.Color = Color3.fromRGB(212, 212, 212)
                        nametag.OutlineColor = Color3.fromRGB(2, 2, 2)
                        
                        local distance = Drawing.new('Text')
                        distance.Text = ('%s studs away')
                        distance.Size = 18
                        distance.Center = true
                        distance.Outline = true
                        distance.Color = Color3.fromRGB(168, 168, 168)
                        distance.OutlineColor = Color3.fromRGB(2, 2, 2)
                        
                        obj.Nametag = nametag
                        obj.Distance = distance
                    end
                    
                    drawingObjects[playerName] = obj 
                end
                local function cleanupPlayer(player)
                    local playerName = player.Name
                    
                    local obj = drawingObjects[playerName]
                    obj.Nametag:Remove()
                    obj.Distance:Remove()
                    drawingObjects[playerName] = nil
                end
                
                playerAddCn = servPlayers.PlayerAdded:Connect(initPlayer)
                playerRemCn = servPlayers.PlayerRemoving:Connect(cleanupPlayer)
                
                for _, playerName in ipairs(playerNames) do 
                    local manager = playerManagers[playerName]
                    local player = manager.Player
                    
                    initPlayer(player)
                end
                
                local offs1, offs2 = vec3(0, 4, 0), vec3(0, -2, 0)
                
                runCn = servRun.Heartbeat:Connect(function() 
                    local clientPos = clientRoot.Position
                    
                    for _, playerName in ipairs(playerNames) do 
                        local manager = playerManagers[playerName]
                        local root = manager.RootPart
                        
                        if (root) then
                            local drawObj = drawingObjects[playerName]
                            local nameTag = drawObj.Nametag
                            local distanceTag = drawObj.Distance
                            
                            local playerPos = root.Position
                            
                            local distance = (playerPos - clientPos).Magnitude
                            if (distance <= valueDist) then
                                if (valueKick) then
                                    runCn:Disconnect()
                                    clientPlayer:Kick(('%s was %d studs away!'):format(playerName, distance))
                                    return 
                                end
                                
                                local namePos, nameVis = clientCamera:WorldToViewportPoint(playerPos + offs1)
                                local distPos, distVis = clientCamera:WorldToViewportPoint(playerPos + offs2)
                                
                                nameTag.Visible = true
                                distanceTag.Visible = true
                                
                                distanceTag.Text = ('%d studs away'):format(distance)
                                                                
                                if (nameVis and distVis) then
                                    nameTag.Visible = true
                                    distanceTag.Visible = true
                                    
                                    nameTag.Position = vec2(namePos.X, namePos.Y - 10)
                                    distanceTag.Position = vec2(distPos.X, distPos.Y + 10)
                                else
                                    nameTag.Visible = false
                                    distanceTag.Visible = false
                                end
                            else
                                nameTag.Visible = false
                                distanceTag.Visible = false
                            end
                        end
                    end
                end)
            end)
                
                
            p_antiplayer:Connect('Disabled', function() 
                runCn:Disconnect()
                playerAddCn:Disconnect()
                playerRemCn:Disconnect()
                
                for player, objs in pairs(drawingObjects) do 
                    objs.Nametag:Remove()
                    objs.Distance:Remove()
                end
                table.clear(drawingObjects)
            end)
        end
        -- Autoclick
        do 
            local s_ButtonType = p_autoclick:addDropdown('Mouse key',true):setTooltip('The key to click')
            local s_Shake = p_autoclick:addToggle('Mouse shake'):setTooltip('Shakes your mouse around to fake jitterclicking')
            local s_ShakeAmount = p_autoclick:addSlider('Shake amount',{min=1,max=15,step=1,cur=5}):setTooltip('How much your mouse gets shooken <i>(shook? shaken? who knows)</i>')
            local s_ClickRate = p_autoclick:addSlider('Delay',{min=0,max=0.7,cur=0,step=0.01}):setTooltip('Delay (in seconds) between mouse clicks. A delay of 0 is 1 click per frame')
            local s_ClickAmount = p_autoclick:addSlider('Click amount',{min=1,max=15,step=1,cur=1}):setTooltip('How many clicks are done')
            local s_clickVisual = p_autoclick:addToggle('Click indicator'):setTooltip('Displays a little indicator on your mouse when it clicks')
            
            s_ButtonType:addOption('Mouse1'):setTooltip('Clicks Mouse1 (left click)'):Select()
            s_ButtonType:addOption('Mouse2'):setTooltip('Clicks Mouse2 (right click)')
            
            
            local ButtonType   = s_ButtonType:GetSelection()
            local ClickAmount  = s_ClickAmount:getValue()
            local ClickRate    = s_ClickRate:getValue()
            local Shake        = s_Shake:getValue()
            local ShakeAmount  = s_ShakeAmount:getValue()
            
            s_ButtonType:Connect('Changed', function(v)
                ButtonType = v
                p_autoclick:Reset()
            end)
            s_ClickRate:Connect('Changed', function(v)
                ClickRate = v
                if (v == 0) then
                    p_autoclick:Reset()
                end
            end)
            s_Shake:Connect('Toggled', function(t) 
                Shake = t;
                if (ClickRate == 0) then 
                    p_autoclick:Reset()
                end
            end)
            s_ClickAmount:Connect('Changed', function(v) 
                ClickAmount = v
            end)
            s_clickVisual:Connect('Toggled', function(t) 
                p_autoclick:Reset()
            end)
            
            
            local ClickConnection
            local ConnectionIdentifier
            local visualCircle
            
            p_autoclick:Connect('Enabled',function() 
                ConnectionIdentifier = mathRand(1, 9999)
                local _ = ConnectionIdentifier
                
                
                -- Handle shaking
                spawn(function() 
                    if (Shake) then
                        while (Shake and p_autoclick:isEnabled()) do 
                            if (not W_WindowOpen) then
                                mousemoverel(mathRand(-ShakeAmount, ShakeAmount),mathRand(-ShakeAmount, ShakeAmount))
                            else
                                wait(0.5)
                            end
                            wait(0.02)
                            if (ConnectionIdentifier ~= _) then break end
                        end
                    end
                end)
                
                -- Handle clicking
                do
                    -- If clickrate is 0, then setup renderstepped connection
                    if (ClickRate == 0) then
                        -- Get func
                        local clickFunc = ButtonType == 'Mouse1' and mouse1click or mouse2click
                        
                        -- Try to click every frame
                        if (s_clickVisual:isEnabled()) then
                            
                            -- click visual
                            
                            visualCircle = drawNew('Circle')
                            visualCircle.NumSides = 20
                            visualCircle.Radius = 13
                            visualCircle.Color = RLTHEMEDATA['ge'][1]
                            visualCircle.Filled = true
                            visualCircle.Transparency = 0.8
                            visualCircle.Visible = true 
                            
                            ClickConnection = servRun.RenderStepped:Connect(function(dt)
                                visualCircle.Transparency -= dt*5
                                visualCircle.Position = servInput:GetMouseLocation()
                                -- If window is closed then
                                if (not W_WindowOpen) then
                                    -- click the mouse button
                                    
                                    for i = 1, ClickAmount do 
                                        clickFunc()
                                    end
                                    visualCircle.Transparency = 0.8
                                end
                                -- otherwise do nothing
                            end)
                        else
                            ClickConnection = servRun.RenderStepped:Connect(function() 
                                -- If window is closed then
                                if (not W_WindowOpen) then
                                    -- click the mouse button
                                    
                                    for i = 1, ClickAmount do 
                                        clickFunc()
                                    end
                                end
                                -- otherwise do nothing
                            end)
                        end
                    else
                        -- If the clickrate isn't 0 then spawn a loop
                        spawn(function() 
                            -- Get func
                            local clickFunc = ButtonType == 'Mouse1' and mouse1click or mouse2click
                            
                            if (s_clickVisual:isEnabled()) then
                                
                                visualCircle = drawNew('Circle')
                                visualCircle.NumSides = 20
                                visualCircle.Radius = 13
                                visualCircle.Color = RLTHEMEDATA['ge'][1]
                                visualCircle.Filled = true
                                visualCircle.Transparency = 0.8
                                visualCircle.Visible = true 
                                
                                
                                ClickConnection = servRun.RenderStepped:Connect(function(dt)
                                    visualCircle.Transparency -= dt*5
                                    visualCircle.Position = servInput:GetMouseLocation()
                                end)
                                
                                
                                -- While autoclicking...
                                while (p_autoclick:isEnabled()) do 
                                    -- try to click
                                    if (not W_WindowOpen) then
                                        for i = 1, ClickAmount do 
                                            clickFunc()
                                        end
                                        visualCircle.Transparency = 0.8
                                    end
                                    -- wait for click duration
                                    wait(ClickRate)
                                    -- check if the identifier changed (i.e. check if there are 2 loops, break if there are)
                                    if (ConnectionIdentifier ~= _) then break end
                                end
                            else
                                -- While autoclicking...
                                while (p_autoclick:isEnabled()) do 
                                    -- try to click
                                    if (not W_WindowOpen) then
                                        for i = 1, ClickAmount do 
                                            clickFunc()
                                        end
                                    end
                                    -- wait for click duration
                                    wait(ClickRate)
                                    -- check if the identifier changed (i.e. check if there are 2 loops, break if there are)
                                    if (ConnectionIdentifier ~= _) then break end
                                end
                            end
                        end)
                    end
                end
            end)
            
            p_autoclick:Connect('Disabled',function() 
                if (ClickConnection) then 
                    ClickConnection:Disconnect() 
                    ClickConnection = nil 
                end
                if (visualCircle) then
                    visualCircle:Remove()
                    visualCircle = nil
                end
            end)
        end 
        -- Better reset
        do 
            local resp_con
            local qdie_con
            p_brespawn:Connect('Enabled', function() 
                local function bind(h) 
                    qdie_con = h.Died:Connect(function() 
                        h:Destroy()
                    end)
                end
                
                bind(clientHumanoid)
                resp_con = clientPlayer.CharacterAdded:Connect(function(c) 
                    local h = c:WaitForChild('Humanoid',0.5)
                    if (h) then
                        bind(h) 
                    end
                end)
                
                if (clientHumanoid.Health == 0) then
                    clientHumanoid:Destroy()
                end
            end)
            p_brespawn:Connect('Disabled',function() 
                resp_con:Disconnect()
                qdie_con:Disconnect()
            end)
        end
        -- Fake lag
        do 
            local s_Method = p_flag:addDropdown('Method',true)
            s_Method:addOption('Fake'):setTooltip('Doesn\'t affect your network usage. Visualizer is more accurate than Fake, but still may have desync issues'):Select()
            s_Method:addOption('Real'):setTooltip('Limits your actual network usage. May lag more than just your movement. Visualizer is less accurate than Fake, but lag looks more realistic')
            
            local s_LagAmnt = p_flag:addSlider('Amount',{min=1,max=10,step=0.1,cur=3}):setTooltip('Lag amount. The larger the number, the more lag you have')
            local LagAmnt = s_LagAmnt:getValue()
            local Method = s_Method:GetSelection()
            
            s_LagAmnt:Connect('Changed',function(v)LagAmnt=v;end)
            s_Method:Connect('Changed',function(v)Method=v;p_flag:Reset()end)
            
            local seat
            p_flag:Connect('Enabled',function() 
                local fakerp = fakechar.HumanoidRootPart
                
                if (Method == 'Fake') then
                    local s = Method 
                    
                    local thej = clientRoot.CFrame
                    
                    seat = instNew('Seat')
                    seat.Transparency = 1
                    seat.CanTouch = false
                    seat.CanCollide = false
                    seat.Anchored = true
                    seat.CFrame = thej
                    
                    local weld = instNew('Weld')
                    weld.Part0 = seat
                    weld.Part1 = nil
                    weld.Parent = seat
                    
                    seat.Parent = workspace
                    
                    spawn(function() 
                        while true do 
                            if (not p_flag:isEnabled() or Method ~= s) then break end
                            wait((mathRand(20,40)*.1) / LagAmnt)
                            if (not p_flag:isEnabled() or Method ~= s) then break end
                            
                            do
                                seat.Anchored = false
                                local thej = clientRoot.CFrame
                                fakechar.Parent = workspace
                                fakerp.CFrame = thej
                                
                                seat.CFrame = thej
                                weld.Part1 = clientRoot
                            end
                            
                            wait(mathRand(1,LagAmnt)*.1)
                            fakechar.Parent = nil
                            weld.Part1 = nil
                            seat.Anchored = true
                        end 
                    end)
                else
                    spawn(function() 
                        local s = Method
                        while true do 
                            if (not p_flag:isEnabled() or Method ~= s) then break end
                            wait(5 / LagAmnt)
                            if (not p_flag:isEnabled() or Method ~= s) then break end
                            
                            
                            fakechar.Parent = workspace
                            fakerp.CFrame = clientRoot.CFrame
                            
                            servNetwork:SetOutgoingKBPSLimit(1)
                            
                            wait(mathRand(1,LagAmnt)*.1)
                            fakechar.Parent = nil
                            servNetwork:SetOutgoingKBPSLimit(9e9)
                        end 
                    end)
                end 
            end)
            
            p_flag:Connect('Disabled',function() 
                if (seat) then seat:Destroy() seat = nil end 
                
                fakechar.Parent = nil
                servNetwork:SetOutgoingKBPSLimit(9e9)
            end)
        end
        -- Flashback
        do 
            local flash_delay = p_flashback:addSlider('Delay', {min=0,max=5,cur=0,step=0.1},true)
            flash_delay:setTooltip('How long to wait before teleporting you back')
            
            local fb_con
            local resp_con
            
            p_flashback:Connect('Enabled', function() 
                
                local pos = clientRoot and clientRoot.CFrame
                
                local function bind(h) 
                    h.Died:Connect(function() 
                        pos = clientRoot.CFrame
                        clientPlayer.CharacterAdded:Wait()
                        delay(flash_delay:getValue(), function() clientRoot.CFrame = pos end)
                    end)
                end
                
                resp_con = clientPlayer.CharacterAdded:Connect(function() 
                    wait(0.03)
                    bind(clientHumanoid)
                end)
                
                bind(clientHumanoid)
            end)
            p_flashback:Connect('Disabled', function() 
                fb_con:Disconnect()
                resp_con:Disconnect()
            end)
        end
        -- Safe min
        do 
            local s_DetectMode = p_safemin:addDropdown('Detection mode',true):setTooltip('The method used to detect tabbing out. Leave on default unless detection stops working')
            s_DetectMode:addOption('Default'):setTooltip('Uses UserInputService to detect window minimizing. Some scripts may mess with this event!'):Select()
            s_DetectMode:addOption('Backup'):setTooltip('Uses isrbxactive to detect window minimizing. May not be compatible with every exploit')
            
            s_DetectMode:Connect('Changed',function()p_safemin:Reset();end)
            
            local freezecon
            local wincon1
            local wincon2
            
            p_safemin:Connect('Enabled', function() 
                local mode = s_DetectMode:GetSelection()
                
                if (mode == 'Default') then 
                    local focused = true 
                    wincon1 = servInput.WindowFocused:Connect(function() 
                        focused = true
                    end)
                    wincon2 = servInput.WindowFocusReleased:Connect(function() 
                        focused = false
                    end)
                    
                    con = servRun.Heartbeat:Connect(function() 
                        clientRoot.Anchored = false
                        if (not focused) then 
                            clientRoot.Anchored = true
                        end
                    end)
                elseif (mode == 'Backup') then 
                    con = servRun.Heartbeat:Connect(function() 
                        clientRoot.Anchored = false
                        if (not isrbxactive()) then 
                            clientRoot.Anchored = true
                        end
                    end)
                end
            end)
            p_safemin:Connect('Disabled',function() 
                if (wincon1) then
                    wincon1:Disconnect()
                    wincon1 = nil
                end
                if (wincon2) then
                    wincon2:Disconnect() 
                    wincon2 = nil
                end
                if (freezecon) then
                    freezecon:Disconnect()
                    freezecon = nil
                end
            end)
        end
        -- Waypoints
        do
            local waypoints
            local makewp = p_waypoints:AddInput('Make waypoint')
            local gotowp = p_waypoints:AddInput('Goto waypoint')
            local delewp = p_waypoints:AddInput('Delete waypoint')
            local deleall = p_waypoints:AddButton('Delete all waypoints')
            
            local folder
            
            local cg = game.CoreGui
            
            local function makewaypoint(text) 
                local new = {}
                new[1] = text
                new[2] = clientRoot.CFrame
                
                local a = instNew('BillboardGui')
                local b = instNew('BoxHandleAdornment')
                local c = instNew('Part')
                local d = instNew('TextLabel')
                
                
                c.Anchored = true
                c.CanCollide = false
                c.CanTouch = false
                c.Color = colNew(0,0,0)
                c.Name = getnext()
                c.Size = vec3(1, 1, 1)
                c.Position = new[2].Position
                c.Transparency = 1
                
                a.Adornee = c
                a.AlwaysOnTop = true
                a.LightInfluence = 0.8
                a.Size = dimNew(1.5, 30, 0.75, 15)
                
                b.Adornee = c
                b.AlwaysOnTop = false
                b.ZIndex = 10
                b.Color3 = colNew(0,0,0)
                b.Size = vec3(1, 200, 1)
                b.SizeRelativeOffset = vec3(0, 200, 0)
                b.Transparency = 0.5
                
                d.BackgroundColor3 = RLTHEMEDATA['bm'][1]
                d.BackgroundTransparency = 0.6
                d.BorderColor3 = RLTHEMEDATA['bm'][1]
                d.BorderSizePixel = 1
                d.Font = RLTHEMEFONT
                d.Size = dimScale(1,1)
                d.Text = text
                d.TextColor3 = RLTHEMEDATA['tm'][1]
                d.TextScaled = true
                d.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                d.TextStrokeTransparency = 0
                
                
                
                c.Parent = folder
                a.Parent = folder
                b.Parent = folder
                d.Parent = a
                
                
                
                new[3] = a
                new[4] = b
                new[5] = c
                new[6] = d
                
                tabInsert(waypoints, new)
            end
            
            
            makewp:Connect('Unfocused',function(text) 
                if (not p_waypoints:isEnabled()) then p_waypoints:Enable() end
                
                for i = 1, #waypoints do
                    local wp = waypoints[i]
                    if (wp[1] == text) then
                        for i = 3, 5 do wp[i]:Destroy() end
                        tabRemove(waypoints, i)
                        break
                    end
                end 
                
                makewaypoint(text)
            end)
            
            delewp:Connect('Unfocused',function(text) 
                for i = 1, #waypoints do
                    local wp = waypoints[i]
                    if (wp[1] == text) then
                        for i = 3, 5 do wp[i]:Destroy() end
                        tabRemove(waypoints, i)
                        break
                    end
                end 
            end)
            
            gotowp:Connect('Unfocused',function(text) 
                for i = 1, #waypoints do
                    local wp = waypoints[i]
                    if (wp[1] == text) then
                        dnec(clientRoot.Changed, 'rp_changed')
                        dnec(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                        
                        clientRoot.CFrame = wp[2]
                        
                        enec('rp_changed')
                        enec('rp_cframe')
                    end
                end 
            end)
            
            deleall:Connect('Clicked',function() 
                for i = 1, #waypoints do
                    local wp = waypoints[i]
                    for i = 3, 5 do wp[i]:Destroy() end
                    waypoints[i] = nil
                end
                tabClear(waypoints)
            end)
            
            p_waypoints:Connect('Enabled',function() 
                waypoints = {}
                
                folder = instNew('Folder')
                folder.Name = getnext()
                folder.Parent = game.CoreGui
            end)
            
            p_waypoints:Connect('Disabled',function() 
                folder:Destroy()
                
                
                for i = 1, #waypoints do
                    local wp = waypoints[i]
                    for i = 3, 5 do wp[i]:Destroy() end
                    waypoints[i] = nil
                end
                waypoints = nil
                
            end)
            
            deleall:setTooltip('Deletes all waypoints. Preferable over untoggling and retoggling')
            makewp:setTooltip('Makes a waypoint at your position with the name you type in')
            delewp:setTooltip('Deletes all waypoints matching the name you type in')
        end
        
        
        --p_fancy:setTooltip('Converts your chat letters into a fancier version. Has a toggleable mode and a non-toggleable mode')
        --p_ftools:setTooltip('Lets you equip and unequip multiple tools at once')
        --p_gtweaks:setTooltip('Lets you configure various misc 'forceable' settings like 3rd person, chat, inventories, and more')
        --p_pathfind:setTooltip('Pathfinder. Kinda like Baritone')
        --p_radar:setTooltip('Radar that displays where other players are')
        p_animspeed:setTooltip('Increases the speed of your character animations. May mess with game logic')
        p_antiafk:setTooltip('Prevents you from being kicked for idling. Make sure to report any problems to me! <i>May not work in games with custom AFK mechanics</i>')
        p_anticrash:setTooltip('Prevents game scripts from while true do end\'ing you. Lets you bypass some clientside anticheats. <i>Doesn\'t work for certain uncommon methods</i>')
        p_antifling:setTooltip('Sorta scuffed anti-fling. Only works on players, not other things like NPCs or in game objects / parts.')
        p_antiwarp:setTooltip('Prevents your character from being teleported (as in character movement, not a server change)')
        p_antiplayer:setTooltip('Shows text above players that are within a certain distance. Also has the option to kick you if someone is close enough.')
        p_autoclick:setTooltip('Automatically clicks for you. Can get up to around 2160 CPS (144 fps * 15 clicks p/ frame)')
        p_flag:setTooltip('Makes your character look laggy. <b>Don\'t combine with blink!</b>')
        p_flashback:setTooltip('Teleports you back to your death point after you die. Also known as DiedTP')
        p_brespawn:setTooltip('Deletes your humanoid whenever you die. Forces a respawn, acting as a better version of resetting. Can also fix certain permadeaths caused by reanimations')
        p_safemin:setTooltip('Freezes your character whenever you tab out of your screen. <i>Don\'t combine this with antifling, instead use the antifling \'safemin + anchor\' mode</i>')
        p_waypoints:setTooltip('Lets you save positions and teleport back to them later')
    end
    local m_movement = ui:newMenu('Movement') do 
        local m_airjump   = m_movement:addMod('Air jump')
        local m_blink     = m_movement:addMod('Blink')
        local m_clicktp   = m_movement:addMod('Click TP')
        local m_dash      = m_movement:addMod('Dash')
        local m_flight    = m_movement:addMod('Flight')
        local m_float     = m_movement:addMod('Float')
        local m_highjump  = m_movement:addMod('High jump')
        local m_noclip    = m_movement:addMod('Noclip')
        local m_nofall    = m_movement:addMod('Nofall')
        local m_notrip    = m_movement:addMod('Notrip')
        local m_parkour   = m_movement:addMod('Parkour')
        local m_speed     = m_movement:addMod('Speed')
        local m_velocity  = m_movement:addMod('Velocity')
        -- Airjump
        do 
            local mode = m_airjump:addDropdown('Mode',true)
            mode:addOption('Jump'):setTooltip('Forces a jump. If the game has something to prevent you from jumping, this won\'t work'):Select()
            mode:addOption('Velocity'):setTooltip('Changes your velocity. Can bypass jump prevention')
            local velmount = m_airjump:addSlider('Velocity amount', {min=-100,max=300,cur=70})
            
            local vel = 70
            local ajcon
            
            velmount:Connect('Changed',function(v)vel=v;end)
            
            m_airjump:Connect('Enabled', function() 
                if (mode:GetSelection() == 'Jump') then
                    ajcon = servInput.InputBegan:Connect(function(io, gpe) 
                        if (gpe == false and io.KeyCode.Value == 32) then
                            clientHumanoid:ChangeState(3)
                        end
                    end)
                else
                    ajcon = servInput.InputBegan:Connect(function(io, gpe) 
                        if (gpe == false and io.KeyCode.Value == 32) then
                            clientRoot.Velocity = vec3(0, vel, 0)
                        end
                    end)
                end
            end)
        
            m_airjump:Connect('Disabled', function() 
                ajcon:Disconnect()
            end)
            
            mode:Connect('Changed',function() 
                m_airjump:Reset()
            end)
            
            mode:setTooltip('Mode for Airjump to use')
            velmount:setTooltip('What your velocity gets set to when you jump (Velocity mode)')
        end
        -- Blink
        do 
            -- Not my method, don't know the original creator
            
            local weld
            local seat
            
            m_blink:Connect('Enabled',function() 
                local thej = clientRoot.CFrame
                
                seat = instNew('Seat')
                seat.Transparency = 1
                seat.CanTouch = false
                seat.CanCollide = false
                seat.CFrame = thej
                
                weld = instNew('Weld')
                weld.Part0 = seat
                weld.Part1 = clientRoot
                weld.Parent = seat
                
                seat.Parent = workspace
                
                fakechar.HumanoidRootPart.CFrame = thej
                fakechar.Parent = workspace
            end)
            
            m_blink:Connect('Disabled',function() 
                if (weld) then weld:Destroy() weld = nil end
                if (seat) then seat:Destroy() seat = nil end
                
                fakechar.Parent = nil
            end)
        end
        -- Click tp
        do 
            local s_TPKey = m_clicktp:AddHotkey('Teleport key'):setTooltip('The key you have to be holding in order to teleport')
            local s_Tween = m_clicktp:addToggle('Tween'):setTooltip('Tweens you to your mouse instead of teleporting')
            local s_TweenSpeed = m_clicktp:addSlider('Tween speed', {min=0,max=50,cur=20,step=0.1}):setTooltip('Speed of the tween')
            
            local Tween = s_Tween:getValue()
            local TweenSpeed = (s_TweenSpeed:getValue()*9)+50
            local TPKey = s_TPKey:getValue()
            s_TPKey:Connect('HotkeySet',function(k)
                TPKey=k;
                m_clicktp:setTooltip(('Teleports you to your mouse when you press %s Mouse1'):format(k and k.Name..' + ' or ''))
            end)
            s_Tween:Connect('Toggled',function(t)Tween=t;end)
            s_TweenSpeed:Connect('Changed',function(v)TweenSpeed=(v*9)+50;end)
            
            
            s_TPKey:setHotkey(Enum.KeyCode.LeftControl)
            local MouseConnection
            m_clicktp:Connect('Enabled',function() 
                local offset = vec3(0, 3, 0)
                
                local function tp() 
                    local lv = clientRoot.CFrame.LookVector
                    local p = clientMouse.Hit.Position + offset
                    
                    local c = cfrNew(p, p+lv)
                    if (Tween) then
                        local dist = (clientRoot.Position - c.Position).Magnitude
                        ctwn(clientRoot, {CFrame = c}, dist / TweenSpeed, 0, 1)
                    else
                        clientRoot.CFrame = c
                    end
                end
                
                MouseConnection = clientMouse.Button1Down:Connect(function() 
                    
                    if (TPKey) then
                        if (servInput:IsKeyDown(TPKey)) then
                            tp()
                        end
                    else
                        tp()
                    end
                end)
            end)
            m_clicktp:Connect('Disabled',function() 
                MouseConnection:Disconnect()
                MouseConnection = nil
            end) 
        end
        -- Dash
        do 
            local s_DashSpeed = m_dash:addSlider('Speed', {min=100,max=300,cur=150,step=0.1},true):setTooltip('How much you get boosted')
            local s_DashSensitivity = m_dash:addSlider('Tap sensitivity', {min=0.1,max=0.3,cur=0.22,step=0.01}):setTooltip('The amount of time between button presses that\'s considered a dash')
            local s_Boost = m_dash:addToggle('Boost'):setTooltip('Boosts you up a bit when you dash, lets you go farther without needing to jump')
            local s_IncludeY = m_dash:addToggle('Include Y'):setTooltip('Includes the up axis when dashing, allows you to boost upwards when you look up')
            local s_Debounce = m_dash:addToggle('Debounce'):setTooltip('Adds a delay between dashes, stopping you from going too fast')
            
            local DashSpeed = s_DashSpeed:getValue()
            local DashSensitivity = s_DashSensitivity:getValue()
            local IncludeY = s_IncludeY:getValue()
            local Boost = s_Boost:getValue()
            local Debounce = s_Debounce:getValue()
            
            s_DashSpeed:Connect('Changed',function(v)DashSpeed=v;end)
            s_DashSensitivity:Connect('Changed',function(v)DashSensitivity=v;end)
            s_IncludeY:Connect('Toggled',function(t)IncludeY=t;end)
            s_Boost:Connect('Toggled',function(t)Boost=t;end)
            s_Debounce:Connect('Toggled',function(t)Debounce=t;end)
            
            
            
            do
                local input_con
                local delays = {}
                delays['W'] = 0
                delays['A'] = 0
                delays['S'] = 0
                delays['D'] = 0
                
                local keys = {}
                keys[Enum.KeyCode.W] = true
                keys[Enum.KeyCode.A] = true
                keys[Enum.KeyCode.S] = true
                keys[Enum.KeyCode.D] = true
                
                m_dash:Connect('Enabled',function() 
                    
                    local dbtime = tick()
                    local dash = function(k)
                        local old = dbtime
                        local new = tick()
                        
                        if (Debounce and ((new - old) < 0.3)) then return end
                        dbtime = new
                        
                        
                        local lv = clientCamera.CFrame.LookVector.Unit
                        local rv = clientCamera.CFrame.RightVector.Unit
                        
                        local v = ((k == 'W' and lv) or (k == 'S' and -lv) or (k == 'A' and -rv) or (k == 'D' and rv))
                        v = (IncludeY and v or vec3(v.X, 0, v.Z).Unit)
                        v = (Boost and vec3(v.X, v.Y+0.15, v.Z) or v)
                        
                        clientRoot.Velocity += (v*DashSpeed)
                    end
                    
                    
                    input_con = servInput.InputBegan:Connect(function(io, gpe) 
                        if (gpe) then return end
                        io = io.KeyCode
                        
                        if (keys[io]) then
                            local n = io.Name
                            local curtime = tick()
                            local oldtime = delays[n]
                            if (curtime - oldtime < DashSensitivity) then
                                dash(n)
                            end
                            
                            delays[n] = tick()
                        end
                    end)
                end)
                
                m_dash:Connect('Disabled',function()
                    input_con:Disconnect()
                    delays['W'] = 0
                    delays['A'] = 0
                    delays['S'] = 0
                    delays['D'] = 0
                end)
            end
        end
        -- Flight
        do 
            local ascend_h = m_flight:AddHotkey('Ascend key')
            local descend_h = m_flight:AddHotkey('Descend key')
            local mode = m_flight:addDropdown('Method', true)
            local turndir = m_flight:addDropdown('Turn direction')
            local speedslider = m_flight:addSlider('Speed',{min=0,max=250,step=0.01,cur=30})
            local camera = m_flight:addToggle('Camera-based')
            
            
            mode:addOption('Standard'):setTooltip('Standard CFlight. Undetectable (within reason), unlike other scripts such as Inf Yield'):Select()
            mode:addOption('Smooth'):setTooltip('Just like Standard, but smooth')
            mode:addOption('Vehicle'):setTooltip('BodyPosition CFlight, may let you fly with vehicles in some games like Jailbreak. Has more protection than other scripts, but is still more detectable than Standard')
            
            
            turndir:addOption('XYZ'):setTooltip('Follows the camera\'s direction exactly. <b>This is the normal option you\'d see used for other scripts</b>'):Select()
            turndir:addOption('XZ'):setTooltip('Follows the camera\'s direction on all axes but Y')
            turndir:addOption('Up'):setTooltip('Faces straight up, useful for carrying players')
            turndir:addOption('Down'):setTooltip('I really hope you can figure this one out')
            
            local fi1 -- flight instNew 1 
            local fi2 -- flight instNew 2  
            local fcon -- flight connection
            
            
            local clvcon -- connection to update camera look vector
            local clv -- camera look vector
            local normclv -- normal unmodified one
            
            local ask = Enum.KeyCode.E-- keycode for ascension
            local dsk = Enum.KeyCode.Q-- keycode for descension
            
            local speed = 30 -- speed 
            
            local cambased = true 
            camera:Enable()
            
            ascend_h:Connect('HotkeySet',function(j)ask=j or 0;end)
            descend_h:Connect('HotkeySet',function(k)dsk=k or 0;end)
            camera:Connect('Toggled',function(t)
                cambased=t;
                m_flight:Reset()
            end)
            turndir:Connect('Changed',function() 
                m_flight:Reset()
            end)
            mode:Connect('Changed',function() 
                m_flight:Reset()
            end)
            speedslider:Connect('Changed',function(v)speed=v;end)
            
            
            m_flight:Connect('Enabled', function()
                clv = clientCamera.CFrame.LookVector 
                normclv = clv
                
                dnec(clientRoot.Changed, 'rp_changed')
                dnec(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                dnec(clientRoot:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
                
                local curmod = mode:GetSelection()
                local curturn = turndir:GetSelection()
                
                local upp, downp, nonep = vec3(0, 1, 0), vec3(0, -1, 0), vec3(0,0,0)
                
                
                if (curturn == 'XYZ') then 
                    clvcon = clientCamera:GetPropertyChangedSignal('CFrame'):Connect(function() 
                        normclv = clientCamera.CFrame.LookVector
                        clv = normclv
                    end)
                elseif (curturn == 'XZ') then
                    clvcon = clientCamera:GetPropertyChangedSignal('CFrame'):Connect(function() 
                        normclv = clientCamera.CFrame.LookVector
                        clv = vec3(normclv.X, 0, normclv.Z)
                    end)
                elseif (curturn == 'Up') then
                    if (cambased) then
                        clvcon = clientCamera:GetPropertyChangedSignal('CFrame'):Connect(function() 
                            normclv = clientCamera.CFrame.LookVector
                        end)
                    end
                    
                    clv = upp
                elseif (curturn == 'Down') then
                    if (cambased) then
                        clvcon = clientCamera:GetPropertyChangedSignal('CFrame'):Connect(function() 
                            normclv = clientCamera.CFrame.LookVector
                        end)
                    end
                    
                    clv = downp
                end
                
                if (curmod == 'Standard') then
                    local base = clientRoot.CFrame
                    
                    
                    if (cambased) then
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = servInput:IsKeyDown(ask)
                            local IsDownPressed = servInput:IsKeyDown(dsk)
                            local IsForwardPressed = servInput:IsKeyDown(119)
                            local IsBackwardPressed = servInput:IsKeyDown(115)
                            
                            -- Keep character frozen
                            clientHumanoid:ChangeState(1)
                            clientRoot.Velocity = nonep
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                clientHumanoid.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) + -- If down is pressed
                                
                                (IsForwardPressed and vec3(0, normclv.Y, 0) or nonep) + -- If forward is pressed
                                (IsBackwardPressed and vec3(0, -normclv.Y, 0) or nonep) -- If backward is pressed
                            ) * Delta)
                            
                            base += Vector
                            
                            local Position = base.Position
                            clientRoot.CFrame = cfrNew(Position, Position + clv)
                        end)
                    else
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = servInput:IsKeyDown(ask)
                            local IsDownPressed = servInput:IsKeyDown(dsk)
                            
                            -- Keep character frozen
                            clientHumanoid:ChangeState(1)
                            clientRoot.Velocity = nonep
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = (
                                clientHumanoid.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) -- If down is presed
                            ) * Delta
                            
                            base += Vector
                            
                            local Position = base.Position
                            clientRoot.CFrame = cfrNew(Position, Position + clv)
                        end)
                    end
                elseif (curmod == 'Smooth') then
                    local base = clientRoot.CFrame
                    
                    fi1 = instNew('Part')
                    fi1.CFrame = base
                    fi1.Transparency = 1
                    fi1.CanCollide = false
                    fi1.CanTouch = false
                    fi1.Anchored = false
                    fi1.Size = vec3(1, 1, 1)
                    fi1.Parent = workspace
                    
                    local pos = instNew('BodyPosition')
                    pos.Position = base.Position
                    pos.D = 1900
                    pos.P = 125000
                    pos.MaxForce = vec3(9e9, 9e9, 9e9)
                    pos.Parent = fi1
                    local gyro = instNew('BodyGyro')
                    gyro.D = 1900
                    gyro.P = 125000
                    gyro.MaxTorque = vec3(9e9, 9e9, 9e9)
                    gyro.Parent = fi1
                    
                    if (cambased) then
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = servInput:IsKeyDown(ask)
                            local IsDownPressed = servInput:IsKeyDown(dsk)
                            local IsForwardPressed = servInput:IsKeyDown(119)
                            local IsBackwardPressed = servInput:IsKeyDown(115)
                            
                            -- Keep character frozen
                            clientHumanoid:ChangeState(1)
                            clientRoot.Velocity = nonep
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                clientHumanoid.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) + -- If down is pressed
                                
                                (IsForwardPressed and vec3(0, normclv.Y, 0) or nonep) + -- If forward is pressed
                                (IsBackwardPressed and vec3(0, -normclv.Y, 0) or nonep) -- If backward is pressed
                            ) * Delta)
                            
                            base += Vector
                            
                            local Position = base.Position
                            pos.Position = Position
                            gyro.CFrame = cfrNew(Position, Position + clv)
                            clientRoot.CFrame = fi1.CFrame   
                        end)
                    else
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = servInput:IsKeyDown(ask)
                            local IsDownPressed = servInput:IsKeyDown(dsk)
                            
                            -- Keep character frozen
                            clientHumanoid:ChangeState(1)
                            clientRoot.Velocity = nonep
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = (
                                clientHumanoid.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) -- If down is presed
                            ) * Delta
                            
                            base += Vector
                            
                            local Position = base.Position
                            pos.Position = Position
                            gyro.CFrame = cfrNew(Position, Position + clv)
                            clientRoot.CFrame = fi1.CFrame                   
                        end)
                    end
                elseif (curmod == 'Vehicle') then
                    local base = clientRoot.CFrame
                    
                    dnec(clientRoot.ChildAdded, 'rp_child')
                    dnec(clientRoot.DescendantAdded, 'rp_desc')
                    dnec(clientChar.DescendantAdded, 'chr_desc')
                    
                    fi1 = instNew('BodyPosition')
                    fi1.Position = base.Position
                    fi1.D = 1900
                    fi1.P = 125000
                    fi1.MaxForce = vec3(9e9, 9e9, 9e9)
                    fi1.Parent = clientRoot
                    
                    fi2 = instNew('BodyGyro')
                    fi2.D = 1900
                    fi2.P = 125000
                    fi2.MaxTorque = vec3(9e9, 9e9, 9e9)
                    fi2.Parent = clientRoot
                    
                    
                    if (cambased) then
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = servInput:IsKeyDown(ask)
                            local IsDownPressed = servInput:IsKeyDown(dsk)
                            local IsForwardPressed = servInput:IsKeyDown(119)
                            local IsBackwardPressed = servInput:IsKeyDown(115)
                            
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                clientHumanoid.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) + -- If down is pressed
                                
                                (IsForwardPressed and vec3(0, normclv.Y, 0) or nonep) + -- If forward is pressed
                                (IsBackwardPressed and vec3(0, -normclv.Y, 0) or nonep) -- If backward is pressed
                            ) * Delta)
                            
                            base += Vector
                            
                            local Position = base.Position
                            fi1.Position = Position
                            fi2.CFrame = cfrNew(Position, Position + clv)
                            
                            clientCamera.CameraSubject = clientHumanoid
                        end)
                    else
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = servInput:IsKeyDown(ask)
                            local IsDownPressed = servInput:IsKeyDown(dsk)
                            
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                clientHumanoid.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) -- If down is pressed
                            ) * Delta)
                            
                            base += Vector
                            
                            local Position = base.Position
                            fi1.Position = Position
                            fi2.CFrame = cfrNew(Position, Position + clv)      
                            
                            clientCamera.CameraSubject = clientHumanoid
                        end)
                    end
                end
            end)
            
            m_flight:Connect('Disabled',function() 
                if (fcon) then fcon:Disconnect() fcon = nil end 
                if (clvcon) then clvcon:Disconnect() clvcon = nil end
                if (fi1) then fi1:Destroy() fi1 = nil end
                if (fi2) then 
                    if (fi2.ClassName ~= 'BodyGyro') then
                        clientHumanoid:ChangeState(8)
                    end
                    
                    fi2:Destroy() 
                    fi2 = nil 
                else
                    clientHumanoid:ChangeState(8)
                end
                
                
                enec('rp_changed')
                enec('rp_cframe')
                enec('rp_velocity')
                enec('rp_child')
                enec('rp_desc')
                enec('chr_desc')
                    
            end)
            
            
            ascend_h:setTooltip('When pressed you vertically ascend (move up)'):setHotkey(Enum.KeyCode.E)
            descend_h:setTooltip('When pressed you vertically descend (move down)'):setHotkey(Enum.KeyCode.Q)
            mode:setTooltip('The method Flight uses')
            speedslider:setTooltip('The speed of your flight')
            camera:setTooltip('When enabled, the direction of your camera affects your Y movement. <b>This is the normal option you\'d see used for other scripts</b>')
            turndir:setTooltip('The direction your character faces')
        end
        -- Float
        do 
            local mode = m_float:addDropdown('Mode'):setTooltip('What method Float will use')
            mode:addOption('Undetectable'):setTooltip('Directly changes your velocity. Isn\'t perfect, but it\'s undetectable'):Select()
            mode:addOption('Velocity'):setTooltip('Uses a bodymover. Has better results, but is easier to detect')
            
            local vel = m_float:addSlider('Velocity',{min=-10,cur=0,max=10,step=0.1}):setTooltip('The amount of velocity you\'ll have when floating')
            local amnt = 0
            
            vel:Connect('Changed',a)
            
            mode:Connect('Changed',function() 
                m_float:Reset()
            end)
            
            local fcon
            local finst
            
            local a = function(v) amnt = v; end
            local b = function(v) finst.Velocity = vec3(0, v, 0) end
            
            
            
            m_float:Connect('Enabled',function() 
                local mode = mode:GetSelection()
                if (mode == 'Undetectable') then
                    fcon = servRun.Heartbeat:Connect(function() 
                        local vel = clientRoot.Velocity
                        
                        clientRoot.Velocity = vec3(vel.X, amnt+1.15, vel.Z)
                    end)
                elseif (mode == 'Velocity') then
                    dnec(clientRoot.ChildAdded, 'rp_child')
                    dnec(clientRoot.DescendantAdded, 'rp_desc')
                    dnec(clientChar.DescendantAdded, 'chr_desc')
                    
                    finst = instNew('BodyVelocity')
                    finst.MaxForce = vec3(0, 9e9, 0)
                    finst.Velocity = vec3(0, vel:getValue(), 0)
                    finst.Parent = clientRoot
                    
                    vel:Connect('Changed',b)
                end
            end)
            m_float:Connect('Disabled',function() 
                if (finst) then finst:Destroy(); finst = nil end
                if (fcon) then fcon:Disconnect() fcon = nil end
                
                vel:Connect('Changed',a)
                
                enec('rp_child')
                enec('rp_desc')
                enec('chr_desc')
            end)
            
        end
        -- High jump
        do 
            local s_Mode = m_highjump:addDropdown('Method',true):setTooltip('The method Highjump uses')
            s_Mode:addOption('Velocity'):setTooltip('Increases your vertical velocity when you jump'):Select()
            s_Mode:addOption('JumpPower'):setTooltip('Changes your characters JumpPower property. Is easily detectable, so don\'t use this unless you know what you\'re doing') 
            
            local s_Amount = m_highjump:addSlider('Amount',{min=50,max=300,cur=75,step=0.1},true):setTooltip('How much your jumps get boosted')
            
            local Amount = s_Amount:getValue()
            
            s_Mode:Connect('Changed',function()m_highjump:Reset()end)
            s_Amount:Connect('Changed',function(v)Amount=v;end)
            
            local JumpCon
            local OldJumpPow
            local OldUseJP
            
            m_highjump:Connect('Enabled', function() 
                if (s_Mode:GetSelection() == 'Velocity') then
                    JumpCon = clientHumanoid.StateChanged:Connect(function(old, new) 
                        if (new.Value == 3) then
                            clientRoot.Velocity += vec3(0, Amount, 0)
                        end
                    end)
                else
                    OldJumpPow = clientHumanoid.JumpPower
                    OldUseJP = clientHumanoid.UseJumpPower
                    
                    dnec(clientHumanoid:GetPropertyChangedSignal('JumpPower'), 'hum_jp')
                    dnec(clientHumanoid:GetPropertyChangedSignal('UseJumpPower'), 'hum_ujp')
                    
                    JumpCon = servRun.Heartbeat:Connect(function() 
                        clientHumanoid.UseJumpPower = true
                        clientHumanoid.JumpPower = Amount
                    end)
                end
            end)
            m_highjump:Connect('Disabled',function() 
                if (JumpCon) then JumpCon:Disconnect() JumpCon = nil end
                
                if (OldJumpPow) then
                    clientHumanoid.JumpPower = OldJumpPow
                    clientHumanoid.UseJumpPower = OldUseJP
                    OldJumpPow = nil
                    OldUseJP = nil
                end
                
                enec('hum_jp')
                enec('hum_ujp')
            end)
        end
        -- Noclip
        do 
            local s_Mode = m_noclip:addDropdown('Method', true):setTooltip('The method Noclip uses')
            s_Mode:addOption('Standard'):setTooltip('The average CanCollide noclip'):Select()
            s_Mode:addOption('Legacy'):setTooltip('Emulates the older HumanoidState noclip (Just standard, but with a float effect)')
            s_Mode:addOption('Teleport'):setTooltip('Teleports you through walls')
            s_Mode:addOption('Bypass'):setTooltip('May bypass certain serverside anticheats that rely on the direction you\'re facing')
            
            local s_LookAhead = m_noclip:addSlider('Lookahead',{min=2,cur=4,max=15,step=0.1}):setTooltip('The amount of distance between a wall Teleport will consider noclipping')
            
            local LookAhead = s_LookAhead:getValue()
            s_LookAhead:Connect('Changed',function(v) LookAhead = v end)
            
            
            local Con_Respawn
            local Con_Step
            
            local p = RaycastParams.new()
            p.FilterDescendantsInstances = {clientChar}
            p.FilterType = Enum.RaycastFilterType.Blacklist
            
            s_Mode:Connect('Changed',function()m_noclip:Reset()end)
            
            local loopid
            
            m_noclip:Connect('Enabled', function() 
                loopid = mathRand(1,999999)
                local mode = s_Mode:GetSelection()
                
                if (mode == 'Standard') then
                    local NoclipObjects = {}
                    
                    local c = clientChar:GetChildren()
                    for i = 1, #c do
                        local obj = c[i]
                        if ((obj == nil) or (obj:IsA('BasePart') == false)) then continue end 
                        tabInsert(NoclipObjects, obj)
                    end
                    
                    
                    Con_Respawn = clientPlayer.CharacterAdded:Connect(function(chr) 
                        wait(0.15)
                        
                        tabClear(NoclipObjects)
                        local c = clientChar:GetChildren()
                        for i = 1, #c do
                            local obj = c[i]
                            if ((obj == nil) or (obj:IsA('BasePart') == false)) then continue end 
                            tabInsert(NoclipObjects, obj)
                        end
                    end)
                    
                    Con_Step = servRun.Stepped:Connect(function() 
                        for i = 1, #NoclipObjects do 
                            NoclipObjects[i].CanCollide = false 
                        end
                    end)
                    
                elseif (mode == 'Legacy') then
                    local NoclipObjects = {}
                    
                    local c = clientChar:GetChildren()
                    for i = 1, #c do
                        local obj = c[i]
                        if ((obj == nil) or (obj:IsA('BasePart') == false)) then continue end 
                        tabInsert(NoclipObjects, obj)
                    end
                    
                    
                    Con_Respawn = clientPlayer.CharacterAdded:Connect(function(chr) 
                        wait(0.15)
                        
                        tabClear(NoclipObjects)
                        local c = clientChar:GetChildren()
                        for i = 1, #c do
                            local obj = c[i]
                            if ((obj == nil) or (obj:IsA('BasePart') == false)) then continue end 
                            tabInsert(NoclipObjects, obj)
                        end
                    end)
                    
                    Con_Step = servRun.Stepped:Connect(function() 
                        local vel = clientRoot.Velocity
                        clientRoot.Velocity = vec3(vel.X, 0.3, vel.Z)
                        for i = 1, #NoclipObjects do 
                            NoclipObjects[i].CanCollide = false 
                        end
                    end)
                
                elseif (mode == 'Teleport') then
                    local p = RaycastParams.new()
                    p.FilterDescendantsInstances = {clientChar}
                    p.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    Con_Respawn = clientPlayer.CharacterAdded:Connect(function(c) 
                        p.FilterDescendantsInstances = {c}
                    end)
                    
                    dnec(clientRoot.Changed, 'rp_changed')
                    dnec(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                    
                    Con_Respawn = clientPlayer.CharacterAdded:Connect(function() 
                        m_noclip:Reset()
                    end)
                    
                    Con_Step = servRun.Heartbeat:Connect(function() 
                        local c = clientRoot.CFrame
                        local lv = c.LookVector
                        c = c.Position
                        local m = clientHumanoid.MoveDirection.Unit
                        
                        local j = workspace:Raycast(c, m*LookAhead, p)
                        if (j) then
                            local t = j.Position + (m * (j.Distance/2))
                            
                            clientRoot.CFrame = cfrNew(t, t + lv)
                        end
                    end)
                elseif (mode == 'Bypass') then
                    local p = RaycastParams.new()
                    p.FilterDescendantsInstances = {clientChar}
                    p.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    Con_Respawn = clientPlayer.CharacterAdded:Connect(function(c) 
                        p.FilterDescendantsInstances = {c}
                    end)
                    
                    dnec(clientRoot.Changed, 'rp_changed')
                    dnec(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                    
                    
                    
                    Con_Respawn = clientPlayer.CharacterAdded:Connect(function() 
                        m_noclip:Reset()
                    end)
                    
                    local lid = loopid
                    spawn(function()
                        while m_noclip:isEnabled() and lid == loopid do
                            local c = clientRoot.CFrame
                            local lv = c.LookVector
                            c = c.Position
                            local m = clientHumanoid.MoveDirection.Unit
                            
                            local j = workspace:Raycast(c, m*LookAhead, p)
                            if (j) then
                                clientRoot.CFrame = cfrNew(c, c - lv)
                                clientRoot.Anchored = true
                                wait(0.1) 
                                clientRoot.Anchored = false
                                local t = j.Position + (m * (j.Distance/2))
                                clientRoot.CFrame = cfrNew(t, t + lv)
                            end
                            wait()
                        end
                    end)
                end
            end)
            m_noclip:Connect('Disabled', function() 
                if (Con_Respawn) then 
                    Con_Respawn:Disconnect() 
                    Con_Respawn = nil 
                end
                
                if (Con_Step) then 
                    Con_Step:Disconnect() 
                    Con_Step = nil 
                end
                
                loopid = 0
                
                enec('rp_changed')
                enec('rp_cframe')
            end)
            
        end
        -- Nofall
        do 
            local s_Mode = m_nofall:addDropdown('Mode', true):setTooltip('The method Nofall uses')
            s_Mode:addOption('Drop'):setTooltip('Instantly teleports you down once you start falling. Works in games like Natural Disaster Survival'):Select()
            s_Mode:addOption('Decelerate'):setTooltip('Slows you down before you hit the ground. Doesn\'t work very well, but atleast its here')
            s_Mode:addOption('Boost'):setTooltip('Boosts you up a bit before you hit the ground')
            
            local s_BoostSens = m_nofall:addSlider('Sensitivity (Boost)',{min=30,max=300,cur=100,step=0.1}):setTooltip('How fast you need to be falling before Boost can boost you')
            local s_DropSens = m_nofall:addSlider('Sensitivity (Drop)',{min=5,max=50,cur=10,step=0.1}):setTooltip('How high up you have to be above the ground before Drop will teleport you')
            local s_DecelSens = m_nofall:addSlider('Sensitivity (Decelerate)',{min=1,max=20,cur=10,step=0.1}):setTooltip('How close you have to be to the ground before Decelerate will start slowing your fall')
            
            local BoostSens = -(s_BoostSens:getValue())
            local DropSens = s_DropSens:getValue()
            local DecelSens = s_DecelSens:getValue()
            
            s_BoostSens:Connect('Changed',function(v)BoostSens=-v;end)
            s_DecelSens:Connect('Changed',function(v)DecelSens=v;end)
            s_DropSens:Connect('Changed',function(v)DropSens=v;end)
            
            
            
            local plrcon
            local rcon
            
            s_Mode:Connect('Changed',function() 
                m_nofall:Reset()
            end)
            
            m_nofall:Connect('Enabled',function() 
                
                local CurrentMode = s_Mode:GetSelection()
                if (CurrentMode == 'Drop') then
                    dnec(clientRoot.Changed, 'rp_changed')
                    dnec(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                    local down = vec3(0, -1000000, 0)
                    local p = RaycastParams.new()
                    p.FilterDescendantsInstances = {clientChar}
                    p.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    plrcon = clientPlayer.CharacterAdded:Connect(function(c) 
                        p.FilterDescendantsInstances = {c}
                    end)
                    
                    
                    rcon = servRun.Heartbeat:Connect(function() 
                        local j = workspace:Raycast(clientRoot.Position, down, p)
                        if (j and j.Distance > DropSens) then
                            local hv = clientRoot.Velocity
                            
                            if (hv.Y < 0) then
                                local p = j.Position
                                clientRoot.CFrame = cfrNew(p, p + clientRoot.CFrame.LookVector)
                                clientRoot.Velocity = vec3(hv.X, 20, hv.Z)
                            end
                        end
                    end)
                elseif (CurrentMode == 'Decelerate') then
                    dnec(clientRoot:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
                    dnec(clientRoot.Changed, 'rp_changed')
                    
                    local down = vec3(0, -1000000, 0)
                    local p = RaycastParams.new()
                    p.FilterDescendantsInstances = {clientChar}
                    p.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    plrcon = clientPlayer.CharacterAdded:Connect(function(c) 
                        p.FilterDescendantsInstances = {c}
                    end)
                    
                    
                    rcon = servRun.Heartbeat:Connect(function(dt) 
                        local j = workspace:Raycast(clientRoot.Position, down, p)
                        if (j and j.Distance < DecelSens) then
                            local hv = clientRoot.Velocity
                            local y = hv.Y
                            if (y < -5) then
                                clientRoot.Velocity = vec3(hv.X, y * 0.7, hv.Z)
                            end
                        end
                    end)
                elseif (CurrentMode == 'Boost') then 
                    local holding = false
                    local down = vec3(0, -1000000, 0)
                    local p = RaycastParams.new()
                    p.FilterDescendantsInstances = {clientChar}
                    p.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    plrcon = clientPlayer.CharacterAdded:Connect(function(c) 
                        p.FilterDescendantsInstances = {c}
                    end)
                    
                    rcon = servRun.Heartbeat:Connect(function()
                        if (holding) then return end
                        local j = workspace:Raycast(clientRoot.Position, down, p)
                        
                        if (j and j.Distance < 8) then
                            local hv = clientRoot.Velocity
                            
                            if (hv.Y < BoostSens) then
                                clientRoot.Velocity = vec3(hv.X, 30, hv.Z)
                                
                                holding = true
                                delay(0.5, function()
                                    holding = false
                                end)
                            end
                        end
                    end)
                end
            end)
            
            m_nofall:Connect('Disabled',function() 
                if (rcon) then rcon:Disconnect() rcon = nil end
                if (plrcon) then plrcon:Disconnect() plrcon = nil end
                
                enec('rp_velocity')
                enec('rp_changed')
                enec('rp_cframe')
            end)
        end
        -- Notrip
        do 
            local Con_Respawn
            
            m_notrip:Connect('Enabled',function()
                
                
                local function hook(h) 
                    h:SetStateEnabled(0, false)
                    h:SetStateEnabled(1, false)
                    h:SetStateEnabled(16, false)
                end
                if (clientHumanoid) then
                    hook(clientHumanoid)
                end
                
                Con_Respawn = clientPlayer.CharacterAdded:Connect(function(c) 
                    local hum = c:WaitForChild('Humanoid',5)
                    hook(hum)
                end)
            end)
            m_notrip:Connect('Disabled',function() 
                Con_Respawn:Disconnect()
                
                if (clientHumanoid) then
                    clientHumanoid:SetStateEnabled(0, true)
                    clientHumanoid:SetStateEnabled(1, true)
                    clientHumanoid:SetStateEnabled(16, true) 
                end
            end)
        end
        -- Parkour
        do 
            local delayslid = m_parkour:addSlider('Delay before jumping',{min=0,max=0.2,cur=0,step=0.01}):setTooltip('How long to wait before jumping')
            local delay = 0
            local humcon
            
            delayslid:Connect('Changed',function(v)delay=v;end)
            
            m_parkour:Connect('Toggled',function(t) 
                if (t) then
                    local a = Enum.Material.Air
                    humcon = clientHumanoid:GetPropertyChangedSignal('FloorMaterial'):Connect(function() 
                        if (clientHumanoid.FloorMaterial == a) then
                            if (delay == 0) then
                                if (clientHumanoid.Jump) then return end
                                clientHumanoid:ChangeState(3)
                            else
                                wait(delay)
                                if (clientHumanoid.Jump) then return end
                                clientHumanoid:ChangeState(3)
                            end
                        end
                    end)
                else
                    if (humcon) then humcon:Disconnect() humcon = nil end
                end
            end)
            
        end
        -- Speed
        do 
            local mode = m_speed:addDropdown('Mode',true)
            mode:addOption('Standard'):setTooltip('Standard CFrame speed. <b>Mostly</b> undetectable, unlike other scripts such as Inf Yield. Also known as TPWalk'):Select()
            mode:addOption('Velocity'):setTooltip('Changes your velocity, doesn\'t use any bodymovers. Because of friction, Velocity typically won\'t increase your speed unless it\'s set high or you jump.')
            mode:addOption('Bhop'):setTooltip('The exact same as Velocity, but it spam jumps. Useful for looking legit in games with bhop mechanics, like Arsenal')
            mode:addOption('Part'):setTooltip('Pushes you physically with a clientside part. Can also affect vehicles in certain games, such as Jailbreak')
            mode:addOption('WalkSpeed'):setTooltip('<font color="rgb(255,64,64)"><b>Insanely easy to detect. Use Standard instead.</b></font>')
            
            local speedslider = m_speed:addSlider('Speed',{min=0,max=100,cur=30,step=0.01})
            local speed = 30
            speedslider:Connect('Changed',function(v)speed=v;end)
            local part
            local scon
                    
            m_speed:Connect('Enabled',function() 
                local mode = mode:GetSelection()
                
                dnec(clientHumanoid.Changed, 'hum_changed')
                dnec(clientHumanoid:GetPropertyChangedSignal('Jump'), 'hum_jump')
                dnec(clientRoot.Changed, 'rp_changed')
                dnec(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                dnec(clientRoot:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
                
                if (scon) then scon:Disconnect() scon = nil end
                
                if (mode == 'Standard') then
                    scon = servRun.Heartbeat:Connect(function(dt) 
                        clientRoot.CFrame += clientHumanoid.MoveDirection * (5 * dt * speed)
                    end)
                elseif (mode == 'Velocity') then
                    scon = servRun.Heartbeat:Connect(function(dt) 
                        clientRoot.Velocity += clientHumanoid.MoveDirection * (5 * dt * speed)
                    end)
                elseif (mode == 'Bhop') then
                    scon = servRun.RenderStepped:Connect(function(dt) 
                        local md = clientHumanoid.MoveDirection
                        
                        clientRoot.Velocity += md * (5 * dt * speed)
                        clientHumanoid.Jump = not (md.Magnitude < 0.01 and true or false)
                    end)
                elseif (mode == 'Part') then
                    part = instNew('Part')
                    part.Transparency = 0.8
                    part.Size = vec3(4,4,1)
                    part.CanTouch = false
                    part.CanCollide = true
                    part.Anchored = false
                    part.Name = getnext()
                    part.Parent = workspace
                    scon = ev:Connect(function(dt) 
                        local md = clientHumanoid.MoveDirection
                        local p = clientRoot.Position
                        
                        part.CFrame = cfrNew(p-(md), p)
                        part.Velocity = md * (dt * speed * 1200)
                        
                        clientHumanoid:ChangeState(8)
                    end)
                elseif (mode == 'WalkSpeed') then
                    dnec(clientHumanoid:GetPropertyChangedSignal('WalkSpeed'), 'hum_walk')
                    
                    scon = servRun.Heartbeat:Connect(function() 
                        clientHumanoid.WalkSpeed = speed
                    end)
                end
            end)
            
            m_speed:Connect('Disabled',function() 
                if (scon) then scon:Disconnect() scon = nil end
                if (part) then part:Destroy() end
                
                enec('hum_changed')
                enec('hum_jump')
                
                enec('hum_walk')
                
                enec('rp_changed')
                enec('rp_cframe')
                enec('rp_velocity')
                
                
            end)
            
            mode:Connect('Changed',function() 
                m_speed:Reset()
            end)
            
            mode:setTooltip('Method used for the speedhack')
            speedslider:setTooltip('Amount of speed')
        end
        -- Velocity
        do 
            local xslider = m_velocity:addSlider('X',{min=0,max=100,cur=20,step=0.01}):setTooltip('The minimum / max X velocity you can have')
            local yslider = m_velocity:addSlider('Y',{min=0,max=100,cur=20,step=0.01}):setTooltip('The minimum / max Y velocity you can have')
            local zslider = m_velocity:addSlider('Z',{min=0,max=100,cur=20,step=0.01}):setTooltip('The minimum / max Z velocity you can have')
            
            local x,y,z = 20,20,20
            
            xslider:Connect('Changed',function(v)x=v;end)
            yslider:Connect('Changed',function(v)y=v;end)
            zslider:Connect('Changed',function(v)z=v;end)
            
            local velc
            m_velocity:Connect('Enabled',function() 
                velc = servRun.Stepped:Connect(function() 
                    local v = clientRoot.Velocity
                    clientRoot.Velocity = vec3(
                        mathClamp(v.X,-x,x),
                        mathClamp(v.Y,-y,y),
                        mathClamp(v.Z,-z,z)
                    )
                end)
            end)
            
            m_velocity:Connect('Disabled',function() 
                if (velc) then velc:Disconnect() velc = nil end
            end)
        end
        
        m_airjump:setTooltip('Lets you jump in mid-air, infinitely. May bypass any jump restrictions the game has in place')
        m_blink:setTooltip('Freezes your character for other people. <b>Do not combine with fakelag.</b>')
        m_clicktp:setTooltip('Classic click teleport')
        m_dash:setTooltip('Boosts your velocity when you double tap W, A, S, or D. Will be improved upon later.')
        m_flight:setTooltip('Makes your character fly')
        m_float:setTooltip('Lets you slowly fall, slowly rise, or simply just float.')
        m_highjump:setTooltip('Increases how high you can jump')
        m_noclip:setTooltip('Disables your character\'s collision, or bypasses the collision entirely')
        m_nofall:setTooltip('May bypass some games fall damage mechanics by changing how you fall.')
        m_notrip:setTooltip('Prevents you from tripping / ragdolling, like when you get by a fast part')
        m_parkour:setTooltip('Jumps when you reach the end of a part')
        m_speed:setTooltip('Speedhacks with various bypasses and settings')
        m_velocity:setTooltip('Limits your velocity')
    end
    local m_render = ui:newMenu('Render') do 
        local CrosshairPosition
        
        
        local r_crosshair   = m_render:addMod('Crosshair')
        local r_esp         = m_render:addMod('ESP'..betatxt)
        local r_freecam     = m_render:addMod('Freecam')
        local r_fullbright  = m_render:addMod('Fullbright')
        local r_keystrokes  = m_render:addMod('Keystrokes'..betatxt)
        --local r_radar       = m_render:addMod('Radar'..betatxt)
        local r_ugpu        = m_render:addMod('Unfocused GPU')
        local r_zoom        = m_render:addMod('Zoom')
        
        -- Crosshair
        do 
            local s_Size = r_crosshair:addSlider('Size',{min=5,max=15,cur=7,step=1}):setTooltip('The size of the crosshair circle')
            local s_Speed = r_crosshair:addSlider('Speed',{min=0,max=10,cur=4,step=0.1}):setTooltip('The speed of the rotation effect')
            local s_AccuracyMult = r_crosshair:addSlider('Spread multiplier',{min=0.01,max=1.5,step=0.01,cur=0.05}):setTooltip('How sensitive the spread effect is')
            local s_Accuracy = r_crosshair:addToggle('Spread'):setTooltip('Emulates bullet spread by changing the crosshair arm distance based off of your velocity')
            
            local s_Style = r_crosshair:addDropdown('Style'):setTooltip('The crosshair design used')
            local s_RotStyle = r_crosshair:addDropdown('Animation'):setTooltip('The animation used')
            
            local s_Status = r_crosshair:addToggle('Aimbot status'):setTooltip('Shows a status underneath the crosshair indicating what it\'s doing. For the aimbot module')
            
            s_Style:addOption('2 arms'):setTooltip('Has 2 arms with a ring'):Select()
            s_Style:addOption('4 arms'):setTooltip('Has 4 arms with a ring')
            s_Style:addOption('2 arms (no ring)'):setTooltip('Has just 2 arms without any ring')
            s_Style:addOption('4 arms (no ring)'):setTooltip('Has just 4 arms without any ring')
        
            s_RotStyle:addOption('Swing'):setTooltip('Swings back and forth'):Select()
            s_RotStyle:addOption('Spin'):setTooltip('Constantly spins at a linear speed')
            s_RotStyle:addOption('3d'):setTooltip('Does a cool 3d spin thing')
            s_RotStyle:addOption('None'):setTooltip('No animation')
            
            
            local Accuracy = s_Accuracy:isEnabled()
            local AccuracyMult = s_AccuracyMult:getValue()
            local Size = s_Size:getValue()
            local Speed = s_Speed:getValue()
            local Status = s_Status:isEnabled()
            
            s_Accuracy:Connect('Toggled',function(v)Accuracy=v;end)
            s_AccuracyMult:Connect('Changed',function(v)AccuracyMult=v;end)
            s_RotStyle:Connect('Changed',function()r_crosshair:Reset()end)
            s_Size:Connect('Changed',function(v)Size=v;end)
            s_Speed:Connect('Changed',function(v)Speed=v;end)
            s_Style:Connect('Changed',function()r_crosshair:Reset()end)
            
            local objs = {}
            local stop = false
            local animcon
            local moncon
            
            local vpcen = clientCamera.ViewportSize / 2 
            
            r_crosshair:Connect('Enabled', function() 
                stop = false
                local m = s_Style:GetSelection()
                local r = s_RotStyle:GetSelection()
                
                local sin, cos = math.sin, math.cos
                
                local InnerLine1 = drawNew('Line')
                local InnerLine2 = drawNew('Line')
                local InnerLine3 = drawNew('Line')
                local InnerLine4 = drawNew('Line')
                local InnerRing = drawNew('Circle')
                local OuterLine1 = drawNew('Line')
                local OuterLine2 = drawNew('Line')
                local OuterLine3 = drawNew('Line')
                local OuterLine4 = drawNew('Line')
                local OuterRing = drawNew('Circle')
                local StatusText = drawNew('Text')
                
                do
                    InnerLine1.Visible = true
                    InnerLine2.Visible = true
                    InnerLine3.Visible = true
                    InnerLine4.Visible = true
                    InnerRing.Visible = true
                    OuterLine1.Visible = true
                    OuterLine2.Visible = true
                    OuterLine3.Visible = true
                    OuterLine4.Visible = true
                    OuterRing.Visible = true
                    StatusText.Visible = Status
                    
                    OuterRing.Color = colNew(0,0,0)
                    OuterRing.NumSides = 20
                    OuterRing.Position = vpcen-vec2(Size/2,Size/2)
                    OuterRing.Radius = 6
                    OuterRing.Thickness = 4
                    OuterRing.ZIndex = 50
                    
                    InnerRing.NumSides = 20
                    InnerRing.Position = OuterRing.Position
                    InnerRing.Radius = 6
                    InnerRing.Thickness = 2
                    InnerRing.ZIndex = 50
                    
                    InnerLine1.Thickness = 2
                    InnerLine1.ZIndex = 53
                    OuterLine1.Color = colNew(0,0,0)
                    OuterLine1.Thickness = 4
                    OuterLine1.ZIndex = 52
                    
                    InnerLine2.Thickness = 2
                    InnerLine2.ZIndex = 53
                    OuterLine2.Color = colNew(0,0,0)
                    OuterLine2.Thickness = 4
                    OuterLine2.ZIndex = 52
                    
                    InnerLine3.Thickness = 2
                    InnerLine3.ZIndex = 53
                    OuterLine3.Color = colNew(0,0,0)
                    OuterLine3.Thickness = 4
                    OuterLine3.ZIndex = 52
                    
                    InnerLine4.Thickness = 2
                    InnerLine4.ZIndex = 53
                    OuterLine4.Color = colNew(0,0,0)
                    OuterLine4.Thickness = 4
                    OuterLine4.ZIndex = 52
                    
                    StatusText.Center = true
                    StatusText.Font = 1
                    StatusText.Outline = true
                    StatusText.OutlineColor = colNew(0,0,0)
                    StatusText.Size = 16
                    StatusText.ZIndex = 54
                end
                
                -- most optimized lua script
                objs[#objs+1] = InnerLine1
                objs[#objs+1] = InnerLine2
                objs[#objs+1] = InnerLine3
                objs[#objs+1] = InnerLine4
                objs[#objs+1] = InnerRing 
                objs[#objs+1] = OuterLine1
                objs[#objs+1] = OuterLine2
                objs[#objs+1] = OuterLine3
                objs[#objs+1] = OuterLine4
                objs[#objs+1] = OuterRing 
                objs[#objs+1] = StatusText
                
                
                -- vscode syntax highlighting fucks up for some reason
                -- so i have to use [[]] instead of ' or "
                if (m == [[2 arms]]) then
                    InnerLine3.Visible = false
                    InnerLine4.Visible = false
                    OuterLine3.Visible = false
                    OuterLine4.Visible = false
                elseif (m == [[2 arms (no ring)]]) then
                    InnerLine3.Visible = false
                    InnerLine4.Visible = false
                    OuterLine3.Visible = false
                    OuterLine4.Visible = false
                    
                    InnerRing.Visible = false
                    OuterRing.Visible = false
                    
                elseif (m == [[4 arms (no ring)]]) then
                    InnerRing.Visible = false
                    OuterRing.Visible = false
                end
                
                
                local t = 0 
                local v = 3 
                local size
                
                if (r == 'Swing') then
                    animcon = servRun.RenderStepped:Connect(function(dt) 
                        if stop then return end
                        t += dt
                        
                        local c = RGBCOLOR--colHsv((t*0.02)%1,1,1)
                        v = v + ((3 + (Accuracy and clientRoot and mathClamp(clientRoot.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
                        local _ = sin(t)
                        local t2 = _*Speed
                        local _1 = vec2(sin(t2), cos(t2))
                        local _2 = vec2(sin(t2+66), cos(t2+66))
                        local _3 = vec2(sin(t2+33), cos(t2+33))
                        local _4 = vec2(sin(t2+99), cos(t2+99))
                    
                        size = Size+(_)
                    
                        local p = InnerRing.Position:lerp(AimbotTarget or vpcen, 0.2)
                        CrosshairPosition = p
                        InnerRing.Position = p
                        OuterRing.Position = p
                        
                        InnerRing.Radius = size
                        OuterRing.Radius = size
                    
                        local size0 = size*v
                        local size1 = size*(v-1) 
                        
                        local __1 = p + _1*size1
                        local __2 = p + _1*size0
                        InnerLine1.From = __1
                        InnerLine1.To = __2
                        OuterLine1.From = __1
                        OuterLine1.To = __2
                    
                        __1 = p + _2*size1
                        __2 = p + _2*size0
                        InnerLine2.From = __1
                        InnerLine2.To = __2
                        OuterLine2.From = __1
                        OuterLine2.To = __2
                        
                        __1 = p + _3*size1
                        __2 = p + _3*size0
                        InnerLine3.From = __1
                        InnerLine3.To = __2
                        OuterLine3.From = __1
                        OuterLine3.To = __2
                        
                        __1 = p + _4*size1
                        __2 = p + _4*size0
                        InnerLine4.From = __1
                        InnerLine4.To = __2
                        OuterLine4.From = __1
                        OuterLine4.To = __2
                        
                        StatusText.Text = AimbotStatus
                        StatusText.Position = p + vec2(0, StatusText.TextBounds.Y)
                        
                        StatusText.Color = c 
                        InnerRing.Color = c
                        InnerLine1.Color = c
                        InnerLine2.Color = c
                        InnerLine3.Color = c
                        InnerLine4.Color = c
                    end)
                elseif (r == 'Spin') then
                    
                    animcon = servRun.RenderStepped:Connect(function(dt) 
                        if stop then return end
                        t += dt
                        
                        local c = RGBCOLOR--colHsv((t*0.02)%1,1,1)
                        
                        v = v + ((3 + (Accuracy and clientRoot and mathClamp(clientRoot.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
                        local t2 = (t*Speed)%360
                        local _1 = vec2(sin(t2), cos(t2))
                        local _2 = vec2(sin(t2+66), cos(t2+66))
                        local _3 = vec2(sin(t2+33), cos(t2+33))
                        local _4 = vec2(sin(t2+99), cos(t2+99))
                    
                        size = Size+(sin(t))
                    
                        local p = InnerRing.Position:lerp(AimbotTarget or vpcen, 0.2)
                        CrosshairPosition = p
                        InnerRing.Position = p
                        OuterRing.Position = p
                        
                        InnerRing.Radius = size
                        OuterRing.Radius = size
                    
                        local size0 = size*v
                        local size1 = size*(v-1) 
                        
                        local __1 = p + _1*size1
                        local __2 = p + _1*size0
                        InnerLine1.From = __1
                        InnerLine1.To = __2
                        OuterLine1.From = __1
                        OuterLine1.To = __2
                    
                        __1 = p + _2*size1
                        __2 = p + _2*size0
                        InnerLine2.From = __1
                        InnerLine2.To = __2
                        OuterLine2.From = __1
                        OuterLine2.To = __2
                        
                        __1 = p + _3*size1
                        __2 = p + _3*size0
                        InnerLine3.From = __1
                        InnerLine3.To = __2
                        OuterLine3.From = __1
                        OuterLine3.To = __2
                        
                        __1 = p + _4*size1
                        __2 = p + _4*size0
                        InnerLine4.From = __1
                        InnerLine4.To = __2
                        OuterLine4.From = __1
                        OuterLine4.To = __2
                        
                        StatusText.Text = AimbotStatus
                        StatusText.Position = p + vec2(0, StatusText.TextBounds.Y)
                        
                        StatusText.Color = c 
                        InnerRing.Color = c
                        InnerLine1.Color = c
                        InnerLine2.Color = c
                        InnerLine3.Color = c
                        InnerLine4.Color = c
                    end)
                elseif (r == '3d') then
                    animcon = servRun.RenderStepped:Connect(function(dt) 
                        if stop then return end
                        t += dt
                        
                        -- ignore the shitty ass variable names
                        -- (problem? :troll)
                        
                        
                        local c = RGBCOLOR
                        v = v + ((3 + (Accuracy and clientRoot and mathClamp(clientRoot.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
                        local _ = sin(t)
                        local __ = ((cos(t+1)-1))*Speed
                        local t2 = (_*Speed)
                        local _1 = vec2(sin(t2      - __), cos(t2      + __))
                        local _2 = vec2(sin(t2 + 66 - __), cos(t2 + 66 + __))
                        local _3 = vec2(sin(t2 + 33 - __), cos(t2 + 33 + __))
                        local _4 = vec2(sin(t2 + 99 - __), cos(t2 + 99 + __))
                    
                        size = Size+(_)
                    
                        local p = InnerRing.Position:lerp(AimbotTarget or vpcen, 0.2)
                        CrosshairPosition = p
                        InnerRing.Position = p
                        OuterRing.Position = p
                        
                        InnerRing.Radius = size
                        OuterRing.Radius = size
                    
                        local size0 = size*v
                        local size1 = size*(v-1) 
                        
                        local __1 = p + _1*size1
                        local __2 = p + _1*size0
                        InnerLine1.From = __1
                        InnerLine1.To = __2
                        OuterLine1.From = __1
                        OuterLine1.To = __2
                    
                        __1 = p + _2*size1
                        __2 = p + _2*size0
                        InnerLine2.From = __1
                        InnerLine2.To = __2
                        OuterLine2.From = __1
                        OuterLine2.To = __2
                        
                        __1 = p + _3*size1
                        __2 = p + _3*size0
                        InnerLine3.From = __1
                        InnerLine3.To = __2
                        OuterLine3.From = __1
                        OuterLine3.To = __2
                        
                        __1 = p + _4*size1
                        __2 = p + _4*size0
                        InnerLine4.From = __1
                        InnerLine4.To = __2
                        OuterLine4.From = __1
                        OuterLine4.To = __2
                        
                        StatusText.Text = AimbotStatus
                        StatusText.Position = p + vec2(0, StatusText.TextBounds.Y)
                        
                        StatusText.Color = c 
                        InnerRing.Color = c
                        InnerLine1.Color = c
                        InnerLine2.Color = c
                        InnerLine3.Color = c
                        InnerLine4.Color = c
                    end)
                elseif (r == 'None') then
                    local _1 = vec2(1, 0)
                    local _2 = vec2(0, -1)
                    local _3 = vec2(0, 1)
                    local _4 = vec2(-1, 0)
                    animcon = servRun.RenderStepped:Connect(function(dt) 
                        if stop then return end
                        t += dt
                        
                        local c = RGBCOLOR--colHsv((t*0.02)%1,1,1)
                        v = v + ((3 + (Accuracy and clientRoot and mathClamp(clientRoot.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
                    
                        size = Size+(sin(t))
                    
                        local p = InnerRing.Position:lerp(AimbotTarget or vpcen, 0.2)
                        CrosshairPosition = p
                        InnerRing.Position = p
                        OuterRing.Position = p
                        
                        InnerRing.Radius = size
                        OuterRing.Radius = size
                    
                        local size0 = size*v
                        local size1 = size*(v-1) 
                        
                        local __1 = p + _1*size1
                        local __2 = p + _1*size0
                        InnerLine1.From = __1
                        InnerLine1.To = __2
                        OuterLine1.From = __1
                        OuterLine1.To = __2
                    
                        __1 = p + _2*size1
                        __2 = p + _2*size0
                        InnerLine2.From = __1
                        InnerLine2.To = __2
                        OuterLine2.From = __1
                        OuterLine2.To = __2
                        
                        __1 = p + _3*size1
                        __2 = p + _3*size0
                        InnerLine3.From = __1
                        InnerLine3.To = __2
                        OuterLine3.From = __1
                        OuterLine3.To = __2
                        
                        __1 = p + _4*size1
                        __2 = p + _4*size0
                        InnerLine4.From = __1
                        InnerLine4.To = __2
                        OuterLine4.From = __1
                        OuterLine4.To = __2
                        
                        StatusText.Text = AimbotStatus
                        StatusText.Position = p + vec2(0, StatusText.TextBounds.Y)
                        
                        StatusText.Color = c 
                        InnerRing.Color = c
                        InnerLine1.Color = c
                        InnerLine2.Color = c
                        InnerLine3.Color = c
                        InnerLine4.Color = c
                    end)
                end
                
                moncon = clientCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function() 
                    vpcen = clientCamera.ViewportSize / 2
                end)
            end)
            
            r_crosshair:Connect('Disabled', function() 
                stop = true
                if (animcon) then animcon:Disconnect() animcon = nil end 
                if (moncon) then moncon:Disconnect() moncon = nil end 
                
                for i,v in ipairs(objs) do v:Remove() end
                objs = {}
                
                CrosshairPosition = nil
                AimbotStatus = ''
            end)
            
            --[[
            local msgs = {
                'wassup',
                'hows it goin',
                'happy '..(os.date('%A'):lower()),
                'yooo wassup',
                'status enabled'
            }]]
            s_Status:Connect('Toggled',function(v)
                Status=v;
                local obj = objs[#objs]
                
                if (obj) then
                    obj.Visible = Status
                    --[[
                    local msg = msgs[mathRand(1, #msgs)]
                    AimbotStatus = msg
                    delay(1, function() 
                        if (AimbotStatus == msg) then
                            AimbotStatus = ''
                        end
                    end)]]
                end
                
            end)
        end
        -- Freecam
        do 
            -- Hotkeys
            local ascend_h = r_freecam:AddHotkey('Ascend key')
            local descend_h = r_freecam:AddHotkey('Descend key')
            -- Dropdowns
            local mode = r_freecam:addDropdown('Method', true)
            local freezemode = r_freecam:addDropdown('Freeze mode')
            -- sliders 
            local speedslider = r_freecam:addSlider('Speed',{min=0,max=300,step=0.1,cur=30})
            -- buttons
            local gotocam = r_freecam:AddButton('Goto freecam')
            local resetcam = r_freecam:AddButton('Reset freecam position')
            -- toggles
            local camera = r_freecam:addToggle('Camera-based')
            local resetonenable = r_freecam:addToggle('Reset pos on enable')
            
            
            mode:addOption('Standard'):setTooltip('Standard freecam'):Select()
            mode:addOption('Smooth'):setTooltip('Just like Standard, but smooth')  
            mode:addOption('Bypass'):setTooltip('<b>Currently unfinished.</b> May bypass some anticheats / game mechanics that break freecam, but it\'s extremely janky')      
            freezemode:addOption('Anchor'):setTooltip('Anchors your character'):Select()
            freezemode:addOption('Walkspeed'):setTooltip('Sets your walkspeed to 0')
            freezemode:addOption('Stuck'):setTooltip('Constantly overwrites your position')
            
            local campart -- camera part
            local fcon -- flight connection
            local clvcon -- clv connection
            
            local ask = Enum.KeyCode.E-- keycode for ascension
            local dsk = Enum.KeyCode.Q-- keycode for descension
            
            local fcampos = clientRoot and clientRoot.Position or vec3(0,0,0)        
            local speed = 30 -- speed 
            
            local cambased = true 
            camera:Enable()
            resetonenable:Enable()
            
            ascend_h:Connect('HotkeySet',function(j)ask=j or 0;end)
            descend_h:Connect('HotkeySet',function(k)dsk=k or 0;end)
            camera:Connect('Toggled',function(t)
                cambased=t;
                r_freecam:Reset()
            end)
            mode:Connect('Changed',function() 
                r_freecam:Reset()
            end)
            freezemode:Connect('Changed',function() 
                r_freecam:Reset()
            end)
            speedslider:Connect('Changed',function(v)speed=v;end)
            
            local stuckcon, stuckcf, oldwalk
            
            r_freecam:Connect('Enabled', function()
                
                local curmod = mode:GetSelection()        
                local upp, downp, nonep = vec3(0, 1, 0), vec3(0, -1, 0), vec3(0,0,0)
                
                if (resetonenable:isEnabled()) then
                    fcampos = clientRoot.Position
                end
                
                local normclv = clientCamera.CFrame.LookVector
                clvcon = clientCamera:GetPropertyChangedSignal('CFrame'):Connect(function() 
                    normclv = clientCamera.CFrame.LookVector
                end)
                
                if (curmod == 'Standard') then
                    campart = instNew('Part')
                    campart.Position = fcampos
                    campart.Transparency = 1
                    campart.CanCollide = false
                    campart.CanTouch = false
                    campart.Anchored = true
                    campart.Size = vec3(1, 1, 1)
                    campart.Parent = workspace  
                    
                    clientCamera.CameraSubject = campart
                    
                    if (cambased) then
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = servInput:IsKeyDown(ask)
                            local IsDownPressed = servInput:IsKeyDown(dsk)
                            local IsForwardPressed = servInput:IsKeyDown(119)
                            local IsBackwardPressed = servInput:IsKeyDown(115)
                                                        
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                clientHumanoid.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) + -- If down is pressed
                                
                                (IsForwardPressed and vec3(0, normclv.Y, 0) or nonep) + -- If forward is pressed
                                (IsBackwardPressed and vec3(0, -normclv.Y, 0) or nonep) -- If backward is pressed
                            ) * Delta)
                            
                            fcampos += Vector
                            
                            campart.Position = fcampos
                            clientCamera.CameraSubject = campart
                        end)
                    else
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = servInput:IsKeyDown(ask)
                            local IsDownPressed = servInput:IsKeyDown(dsk)
                                                        
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                clientHumanoid.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) -- If down is pressed
                            ) * Delta)
                            
                            fcampos += Vector
                            
                            campart.Position = fcampos
                            clientCamera.CameraSubject = campart
                        end)
                    end
                elseif (curmod == 'Smooth') then
                    campart = instNew('Part')
                    campart.Position = fcampos
                    campart.Transparency = 1
                    campart.CanCollide = false
                    campart.CanTouch = false
                    campart.Anchored = true
                    campart.Size = vec3(1, 1, 1)
                    campart.Parent = workspace  
                    
                    clientCamera.CameraSubject = campart
                    
                    
                    local pos = instNew('BodyPosition')
                    pos.Position = fcampos
                    pos.D = 1900
                    pos.P = 125000
                    pos.MaxForce = vec3(9e9, 9e9, 9e9)
                    pos.Parent = campart
                    
                    campart.Anchored = false
                    
                    if (cambased) then
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = servInput:IsKeyDown(ask)
                            local IsDownPressed = servInput:IsKeyDown(dsk)
                            local IsForwardPressed = servInput:IsKeyDown(119)
                            local IsBackwardPressed = servInput:IsKeyDown(115)
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                clientHumanoid.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) + -- If down is pressed
                                
                                (IsForwardPressed and vec3(0, normclv.Y, 0) or nonep) + -- If forward is pressed
                                (IsBackwardPressed and vec3(0, -normclv.Y, 0) or nonep) -- If backward is pressed
                            ) * Delta)
                            
                            fcampos += Vector
                            
                            pos.Position = fcampos
                        end)
                    else
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = servInput:IsKeyDown(ask)
                            local IsDownPressed = servInput:IsKeyDown(dsk)
                            
                            -- Keep character frozen
                            clientHumanoid:ChangeState(1)
                            clientRoot.Velocity = nonep
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = (
                                clientHumanoid.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) -- If down is presed
                            ) * Delta
                            
                            fcampos += Vector
                            
                            pos.Position = fcampos
                            clientCamera.CameraSubject = campart
                        end)
                    end
                    
                elseif (curmod == 'Bypass') then
                    
                    clientCamera.CameraSubject = clientHumanoid
                    
                    if (cambased) then
                        local thej = cfrNew(clientRoot.Position, clientRoot.Position + vec3(0, 0, 1))
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            clientRoot.CFrame = thej
                            
                            local up = servInput:IsKeyDown(ask)
                            local down = servInput:IsKeyDown(dsk)
                            local f,b = servInput:IsKeyDown(119), servInput:IsKeyDown(115)
                            
                            local movevec = (clientHumanoid.MoveDirection * dt * 3 * speed)
                            local upvec = (((up and upp or nonep) + (down and downp or nonep))*(dt*3*speed))
                            local cupvec = ((f and vec3(0, normclv.Y, 0) or nonep) - (b and vec3(0, normclv.Y, 0) or nonep)*(dt*3*speed))
                            
                            fcampos += movevec
                            fcampos -= upvec
                            fcampos -= cupvec
                            
                            local normalized = cfrNew(fcampos):ToObjectSpace(thej)
                            
                            clientHumanoid.CameraOffset = (normalized).Position
                        end)
                    else
                        local thej = cfrNew(clientRoot.Position, clientRoot.Position + vec3(0, 0, 1))
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            clientRoot.CFrame = thej
                            
                            local up = servInput:IsKeyDown(ask)
                            local down = servInput:IsKeyDown(dsk)
                            
                            local movevec = (clientHumanoid.MoveDirection * dt * 3 * speed)
                            local upvec = (((up and upp or nonep) + (down and downp or nonep))*(dt*3*speed))
                            
                            fcampos += movevec
                            fcampos -= upvec
                            
                            local normalized = cfrNew(fcampos):ToObjectSpace(thej)
                            
                            clientHumanoid.CameraOffset = (normalized).Position
                        end)
                    end
                end
                
                local fmode = freezemode:GetSelection()
                
                
                if (fmode == 'Anchor') then
                    clientRoot.Anchored = true
                    
                elseif (fmode == 'Walkspeed') then
                    oldwalk = clientHumanoid.WalkSpeed
                    clientHumanoid.WalkSpeed = 0
                    
                elseif (fmode == 'Stuck') then
                    
                    stuckcf = clientRoot.CFrame
                    dnec(clientRoot.Changed, 'rp_changed')
                    dnec(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                    stuckcon = servRun.Heartbeat:Connect(function() 
                        clientRoot.CFrame = stuckcf
                    end)
                end
            end)
            
            r_freecam:Connect('Disabled',function() 
                
                if (fcon) then 
                    fcon:Disconnect() 
                    fcon = nil 
                end 
                if (clvcon) then 
                    clvcon:Disconnect() 
                    clvcon = nil 
                end
                if (campart) then 
                    campart:Destroy() 
                    campart = nil 
                end
                
                clientCamera.CameraSubject = clientHumanoid
                clientHumanoid.CameraOffset = vec3(0, 0, 0)
                
                if (clientRoot.Anchored == true) then
                    clientRoot.Anchored = false
                
                elseif (clientHumanoid.WalkSpeed == 0) then
                    clientRoot.WalkSpeed = (oldwalk == 0 and 16 or oldwalk) -- Prevent getting infinitely stuck
                end
                if (stuckcon) then
                    stuckcon:Disconnect()
                    stuckcon = nil
                    enec('rp_changed')
                    enec('rp_cframe')
                end
            end)
            
            gotocam:Connect('Clicked',function() 
                local pos = campart.Position
                local new = cfrNew(pos, pos+clientRoot.CFrame.LookVector)
                stuckcf = new
                clientRoot.CFrame = new
            end)
            
            resetcam:Connect('Clicked',function() 
                fcampos = clientRoot.Position
            end)
            
            ascend_h:setTooltip('When pressed the freecam vertically ascends'):setHotkey(Enum.KeyCode.E)
            camera:setTooltip('When enabled, the direction of your camera affects your Y movement. <b>This is the normal option you\'d see used for other scripts</b>')
            descend_h:setTooltip('When pressed the freecam vertically descends'):setHotkey(Enum.KeyCode.Q)
            mode:setTooltip('The method Freecam uses')
            speedslider:setTooltip('The speed of your freecam flight')
            freezemode:setTooltip('The method used to make your character not move')
            gotocam:setTooltip('Brings you to the camera')
            resetcam:setTooltip('Resets the camera\'s position')
            resetonenable:setTooltip('Resets the camera\'s position when Freecam gets enabled')
        end
        -- Esp
        do
            
            -- Settings     
            local s_TeamCheck = r_esp:addToggle('Team check'):setTooltip('Won\'t display ESP for teammates')
            local s_TeamColor = r_esp:addToggle('Team color'):setTooltip('Replaces the RGB color with their team color. If a player doesn\'t have a team, then their color will remain RGB')
            local s_ShowDistance = r_esp:addToggle('Display distance'):setTooltip('Shows player distance in the nametag')
            local s_ShowHealth = r_esp:addToggle('Display health'):setTooltip('Shows player health in the nametag')    
            
            -- Esp types
            local s_Boxes = r_esp:addToggle('Boxes'):setTooltip('Displays boxes around the targets')
            local s_Nametags = r_esp:addToggle('Nametags'):setTooltip('Shows the usernames of targets')
            local s_Tracers = r_esp:addToggle('Tracers'):setTooltip('Enables tracers for the targets')
            --local s_VisibilityCheck = r_esp:addToggle('Visibility check'):setTooltip('Only shows ESP for a player if they\'re visible and not blocked by anything')
            
            -- Sliders
            local s_UpdateDelay = r_esp:addSlider('Update delay',{min=0,max=0.2,cur=0,step=0.01}):setTooltip('Delay in seconds between ESP updates. <0.05 recommended. <b>Only used for Drawing related ESPS</b>')
            local s_TracerVis = r_esp:addSlider('Tracer visibility',{min=0,max=1,cur=1,step=0.1}):setTooltip('The visibility of the tracers - 0 is fully invisible and 1 is fully opaque')
            local s_TextSize = r_esp:addSlider('Text size',{min=1,max=30,cur=20,step=1}):setTooltip('The size of the text')
            
            -- Dropdowns
            local s_BoxType = r_esp:addDropdown('Box type',true):setTooltip('The type of box to use')
            local s_HealthType = r_esp:addDropdown('Health display type'):setTooltip('How the health value is calculated')
            local s_TracerPosition = r_esp:addDropdown('Tracer position'):setTooltip('Where the tracer is drawn')
            
            s_BoxType:addOption('Simple 2d'):setTooltip('Simple 2d box ESP. 2 WTVPs'):Select()
            s_BoxType:addOption('Simple 3d'):setTooltip('Classic Unnamed ESP look. 4 WTVPs')
            s_BoxType:addOption('Westeria 2d'):setTooltip('Westeria box style. 2 WTVPs')
            s_BoxType:addOption('Westeria 3d'):setTooltip('Westeria 3d style. 14 WTVPs; this may lag a bit!')
            --s_BoxType:addOption('Apathy'):setTooltip('Apathy (epic 😎) style - has healthbars and a team color overlay')
            
            s_HealthType:addOption('Percentage'):setTooltip('The percentage of the current health out of the max health'):Select()
            s_HealthType:addOption('Value'):setTooltip('Just the current health')
            
            s_TracerPosition:addOption('Crosshair'):setTooltip('Tracers are drawn at the crosshairs\'s position. If Crosshair is disabled, it resorts to your mouse.'):Select()
            s_TracerPosition:addOption('Character'):setTooltip('Tracers are drawn towards yourself')
            s_TracerPosition:addOption('Down'):setTooltip('Tracers are drawn towards the bottom of your screen')
            s_TracerPosition:addOption('Mouse'):setTooltip('Tracers are drawn at the mouse position')
            
            s_Tracers:Enable()
            s_Nametags:Enable()
            s_Boxes:Enable()
            
            -- l_ = localization
            -- s_ = setting
            
            local l_TeamCheck   = s_TeamCheck:getValue()
            local l_TeamColor   = s_TeamColor:getValue()
            local l_ShowDistance = s_ShowDistance:getValue()
            local l_ShowHealth = s_ShowHealth:getValue()
            
            local l_Boxes = s_Boxes:getValue()
            local l_Nametags = s_Nametags:getValue()
            local l_Tracers = s_Tracers:getValue()
            
            local l_UpdateDelay = s_UpdateDelay:getValue()
            local l_TracerVis = s_TracerVis:getValue()
            local l_TextSize = s_TextSize:getValue()
            
            
            local l_BoxType = s_BoxType:getValue()
            local l_HealthType = s_HealthType:getValue()
            local l_TracerPosition = s_TracerPosition:getValue()
            
            
            
            local PreviousMode
            local EspFolder

            local espObjects = {}
            local PlrCons = {}
            local EspCons = {}
            
            
            do
                s_TeamCheck:Connect('Toggled',function(t)l_TeamCheck=t;end)
                s_TeamColor:Connect('Toggled',function(t)l_TeamColor=t;end)
                s_ShowDistance:Connect('Toggled',function(t)l_ShowDistance=t;end)
                s_ShowHealth:Connect('Toggled',function(t)l_ShowHealth=t;end)
                
                s_Boxes:Connect('Toggled',function(t)l_Boxes=t;end)
                s_Nametags:Connect('Toggled',function(t)l_Nametags=t;end)
                s_Tracers:Connect('Toggled',function(t)l_Tracers=t;end)
                
                s_UpdateDelay:Connect('Changed',function(v)l_UpdateDelay=v;end)
                
                s_BoxType:Connect('Changed',function(v)
                    l_BoxType=v;
                    r_esp:Reset()
                end)
                s_HealthType:Connect('Changed',function(v)l_HealthType=v;end)
                s_TracerPosition:Connect('Changed',function(v)
                    l_TracerPosition=v;
                    r_esp:Reset()
                end)
                
                s_TracerVis:Connect('Changed',function(v)
                    l_TracerVis = v
                    for _, name in ipairs(playerNames) do 
                        local esp = espObjects[name]
                        if (esp) then
                            esp['Tracer1'].Transparency = v
                            esp['Tracer2'].Transparency = v
                        end
                    end
                end)
                s_TextSize:Connect('Changed',function(v)
                    l_TextSize = v
                    for i,name in ipairs(playerNames) do 
                        local esp = espObjects[name]
                        if (esp) then
                            local t1 = esp['Nametag']
                            local t2 = esp['Distance']
                            if (t1) then t1.Size = v end
                            if (t2) then t2.Size = v end
                        end
                    end
                end)
            end
            
            
                   
            
            
            local jskull1
            r_esp:Connect('Enabled',function()
                jskull1 = mathRand(1,99999) -- j💀
                print(pcall(function()
                PreviousMode = EspType
                
                local function create_esp()
                    
                    local espObject = {}
                    espObject['upd'] = tick()
                    
                    local BLACK = colNew(0,0,0)
                    
                    do
                        local Name = drawNew('Text') 
                        Name.Center = true
                        Name.Color = colNew(1,1,1)
                        Name.Font = 1
                        Name.Outline = true
                        Name.OutlineColor = colNew(0,0,0)
                        Name.Size = l_TextSize
                        Name.Text = ''
                        Name.Visible = true
                        Name.ZIndex = 3
                        
                        espObject['Nametag'] = Name
                    end do
                        local Tracer1 = drawNew('Line')
                        local Tracer2 = drawNew('Line')
                        
                        
                        Tracer1.Thickness = 1
                        Tracer1.Visible = true
                        Tracer1.Transparency = l_TracerVis or 1
                        Tracer1.ZIndex = 3
                        
                        Tracer2.Color = colNew(0,0,0)
                        Tracer2.Thickness = 3
                        Tracer2.Visible = true
                        Tracer2.Transparency = l_TracerVis or 1
                        Tracer2.ZIndex = 2
                        
                        espObject['Tracer1'] = Tracer1
                        espObject['Tracer2'] = Tracer2
                    end do 
                        espObject['Boxes'] = {}
                        if (l_BoxType == 'Simple 2d') then
                            local Square1 = drawNew('Square')
                            Square1.Thickness = 1
                            Square1.Visible = true
                            Square1.ZIndex = 3
                            local Square2 = drawNew('Square')
                            Square2.Thickness = 3
                            Square2.Visible = true
                            Square2.ZIndex = 2
                            Square2.Color = BLACK
                            
                            espObject['Boxes']['1_1'] = Square1
                            espObject['Boxes']['1_2'] = Square2
                            
                        elseif (l_BoxType == 'Simple 3d') then
                            local Quad1 = drawNew('Quad')
                            Quad1.Thickness = 1
                            Quad1.Visible = true
                            Quad1.ZIndex = 3
                            local Quad2 = drawNew('Quad')
                            Quad2.Thickness = 3
                            Quad2.Visible = true
                            Quad2.ZIndex = 2
                            Quad2.Color = BLACK
                            
                            espObject['Boxes']['1_1'] = Quad1
                            espObject['Boxes']['1_2'] = Quad2
                            
                        elseif (l_BoxType == 'Westeria 2d') then
                            do
                                local Corner1_1 = drawNew('Line')
                                Corner1_1.Thickness = 1
                                Corner1_1.Visible = true
                                Corner1_1.ZIndex = 3
                                local Corner1_2 = drawNew('Line')
                                Corner1_2.Thickness = 1
                                Corner1_2.Visible = true
                                Corner1_2.ZIndex = 3
                                
                                local Corner1_1_o = drawNew('Line')
                                Corner1_1_o.Thickness = 3
                                Corner1_1_o.Visible = true
                                Corner1_1_o.ZIndex = 2
                                Corner1_1_o.Color = BLACK
                                local Corner1_2_o = drawNew('Line')
                                Corner1_2_o.Thickness = 3
                                Corner1_2_o.Visible = true
                                Corner1_2_o.ZIndex = 2
                                Corner1_2_o.Color = BLACK
                                
                                espObject['Boxes']['1_1'] = Corner1_1
                                espObject['Boxes']['1_2'] = Corner1_2
                                espObject['Boxes']['1_1_o'] = Corner1_1_o
                                espObject['Boxes']['1_2_o'] = Corner1_2_o
                            end
                            do
                                local Corner2_1 = drawNew('Line')
                                Corner2_1.Thickness = 1
                                Corner2_1.Visible = true
                                Corner2_1.ZIndex = 3
                                local Corner2_2 = drawNew('Line')
                                Corner2_2.Thickness = 1
                                Corner2_2.Visible = true
                                Corner2_2.ZIndex = 3
                                
                                local Corner2_1_o = drawNew('Line')
                                Corner2_1_o.Thickness = 3
                                Corner2_1_o.Visible = true
                                Corner2_1_o.ZIndex = 2
                                Corner2_1_o.Color = BLACK
                                local Corner2_2_o = drawNew('Line')
                                Corner2_2_o.Thickness = 3
                                Corner2_2_o.Visible = true
                                Corner2_2_o.ZIndex = 2
                                Corner2_2_o.Color = BLACK
                                
                                espObject['Boxes']['2_1'] = Corner2_1
                                espObject['Boxes']['2_2'] = Corner2_2
                                espObject['Boxes']['2_1_o'] = Corner2_1_o
                                espObject['Boxes']['2_2_o'] = Corner2_2_o
                                
                            end
                            do
                                local Corner3_1 = drawNew('Line')
                                Corner3_1.Thickness = 1
                                Corner3_1.Visible = true
                                Corner3_1.ZIndex = 3
                                local Corner3_2 = drawNew('Line')
                                Corner3_2.Thickness = 1
                                Corner3_2.Visible = true
                                Corner3_2.ZIndex = 3
                                
                                local Corner3_1_o = drawNew('Line')
                                Corner3_1_o.Thickness = 3
                                Corner3_1_o.Visible = true
                                Corner3_1_o.ZIndex = 2
                                Corner3_1_o.Color = BLACK
                                local Corner3_2_o = drawNew('Line')
                                Corner3_2_o.Thickness = 3
                                Corner3_2_o.Visible = true
                                Corner3_2_o.ZIndex = 2
                                Corner3_2_o.Color = BLACK
                                
                                espObject['Boxes']['3_1'] = Corner3_1
                                espObject['Boxes']['3_2'] = Corner3_2
                                espObject['Boxes']['3_1_o'] = Corner3_1_o
                                espObject['Boxes']['3_2_o'] = Corner3_2_o
                            end
                            do
                                local Corner4_1 = drawNew('Line')
                                Corner4_1.Thickness = 1
                                Corner4_1.Visible = true
                                Corner4_1.ZIndex = 3
                                local Corner4_2 = drawNew('Line')
                                Corner4_2.Thickness = 1
                                Corner4_2.Visible = true
                                Corner4_2.ZIndex = 3
                                
                                local Corner4_1_o = drawNew('Line')
                                Corner4_1_o.Thickness = 3
                                Corner4_1_o.Visible = true
                                Corner4_1_o.ZIndex = 2
                                Corner4_1_o.Color = BLACK
                                local Corner4_2_o = drawNew('Line')
                                Corner4_2_o.Thickness = 3
                                Corner4_2_o.Visible = true
                                Corner4_2_o.ZIndex = 2
                                Corner4_2_o.Color = BLACK
                                
                                espObject['Boxes']['4_1'] = Corner4_1
                                espObject['Boxes']['4_2'] = Corner4_2
                                espObject['Boxes']['4_1_o'] = Corner4_1_o
                                espObject['Boxes']['4_2_o'] = Corner4_2_o
                            end
                        elseif (l_BoxType == 'Westeria 3d') then
                            do
                                local Corner1_1 = drawNew('Line')
                                Corner1_1.Thickness = 1
                                Corner1_1.Visible = true
                                Corner1_1.ZIndex = 3
                                local Corner1_2 = drawNew('Line')
                                Corner1_2.Thickness = 1
                                Corner1_2.Visible = true
                                Corner1_2.ZIndex = 3
                                
                                local Corner1_1_o = drawNew('Line')
                                Corner1_1_o.Thickness = 3
                                Corner1_1_o.Visible = true
                                Corner1_1_o.ZIndex = 2
                                Corner1_1_o.Color = BLACK
                                local Corner1_2_o = drawNew('Line')
                                Corner1_2_o.Thickness = 3
                                Corner1_2_o.Visible = true
                                Corner1_2_o.ZIndex = 2
                                Corner1_2_o.Color = BLACK
                                
                                espObject['Boxes']['1_1'] = Corner1_1
                                espObject['Boxes']['1_2'] = Corner1_2
                                espObject['Boxes']['1_1_o'] = Corner1_1_o
                                espObject['Boxes']['1_2_o'] = Corner1_2_o
                            end
                            do
                                local Corner2_1 = drawNew('Line')
                                Corner2_1.Thickness = 1
                                Corner2_1.Visible = true
                                Corner2_1.ZIndex = 3
                                local Corner2_2 = drawNew('Line')
                                Corner2_2.Thickness = 1
                                Corner2_2.Visible = true
                                Corner2_2.ZIndex = 3
                                
                                local Corner2_1_o = drawNew('Line')
                                Corner2_1_o.Thickness = 3
                                Corner2_1_o.Visible = true
                                Corner2_1_o.ZIndex = 2
                                Corner2_1_o.Color = BLACK
                                local Corner2_2_o = drawNew('Line')
                                Corner2_2_o.Thickness = 3
                                Corner2_2_o.Visible = true
                                Corner2_2_o.ZIndex = 2
                                Corner2_2_o.Color = BLACK
                                
                                espObject['Boxes']['2_1'] = Corner2_1
                                espObject['Boxes']['2_2'] = Corner2_2
                                espObject['Boxes']['2_1_o'] = Corner2_1_o
                                espObject['Boxes']['2_2_o'] = Corner2_2_o
                                
                            end
                            do
                                local Corner3_1 = drawNew('Line')
                                Corner3_1.Thickness = 1
                                Corner3_1.Visible = true
                                Corner3_1.ZIndex = 3
                                local Corner3_2 = drawNew('Line')
                                Corner3_2.Thickness = 1
                                Corner3_2.Visible = true
                                Corner3_2.ZIndex = 3
                                
                                local Corner3_1_o = drawNew('Line')
                                Corner3_1_o.Thickness = 3
                                Corner3_1_o.Visible = true
                                Corner3_1_o.ZIndex = 2
                                Corner3_1_o.Color = BLACK
                                local Corner3_2_o = drawNew('Line')
                                Corner3_2_o.Thickness = 3
                                Corner3_2_o.Visible = true
                                Corner3_2_o.ZIndex = 2
                                Corner3_2_o.Color = BLACK
                                
                                espObject['Boxes']['3_1'] = Corner3_1
                                espObject['Boxes']['3_2'] = Corner3_2
                                espObject['Boxes']['3_1_o'] = Corner3_1_o
                                espObject['Boxes']['3_2_o'] = Corner3_2_o
                            end
                            do
                                local Corner4_1 = drawNew('Line')
                                Corner4_1.Thickness = 1
                                Corner4_1.Visible = true
                                Corner4_1.ZIndex = 3
                                local Corner4_2 = drawNew('Line')
                                Corner4_2.Thickness = 1
                                Corner4_2.Visible = true
                                Corner4_2.ZIndex = 3
                                
                                local Corner4_1_o = drawNew('Line')
                                Corner4_1_o.Thickness = 3
                                Corner4_1_o.Visible = true
                                Corner4_1_o.ZIndex = 2
                                Corner4_1_o.Color = BLACK
                                local Corner4_2_o = drawNew('Line')
                                Corner4_2_o.Thickness = 3
                                Corner4_2_o.Visible = true
                                Corner4_2_o.ZIndex = 2
                                Corner4_2_o.Color = BLACK
                                
                                espObject['Boxes']['4_1'] = Corner4_1
                                espObject['Boxes']['4_2'] = Corner4_2
                                espObject['Boxes']['4_1_o'] = Corner4_1_o
                                espObject['Boxes']['4_2_o'] = Corner4_2_o
                            end
                        elseif (l_BoxType == 'Apathy') then
                            local Square1 = drawNew('Square')
                            Square1.Thickness = 1
                            Square1.Visible = true
                            Square1.ZIndex = 3
                            local Square2 = drawNew('Square')
                            Square2.Thickness = 3
                            Square2.Visible = true
                            Square2.ZIndex = 2
                            Square2.Color = BLACK
                            
                            espObject['Boxes']['1_1'] = Square1
                            espObject['Boxes']['1_2'] = Square2
                            
                            local Name = drawNew('Text') 
                            Name.Center = true
                            Name.Color = colNew(1,1,1)
                            Name.Font = 1
                            Name.Outline = true
                            Name.OutlineColor = colNew(0,0,0)
                            Name.Size = l_TextSize
                            Name.Text = ''
                            Name.Visible = true
                            Name.ZIndex = 3
                            
                            espObject['Distance'] = Name
                        end
                    end
                    return espObject
                end
                local function hookPlayer(pName)
                    local PlayerName = pName
                    local PlayerObject = playerManagers[pName]
                    if (not PlayerObject) then 
                        local retryCount = 0
                        repeat
                            if (retryCount > 5) then
                                warn'[REDLINE:ESP] Maximum retry count (5) exceeded, returning'
                                return
                            end
                            warn'[REDLINE:ESP] This player hasn\'t finished joining the server! Couldn\'t hook, retrying in 2s' 
                            retryCount += 1
                            wait(2)
                        until playerManagers[pName].RootPart
                        
                    end 
                    
                    local PlayerInstance = PlayerObject.Player
                    
                    
                    local espObject = create_esp()
                    
                    PlrCons[PlayerName] = {}
                    PlrCons[PlayerName][1] = PlayerInstance:GetPropertyChangedSignal('TeamColor'):Connect(function() 
                        local tx = espObjects[PlayerName]
                        tx = tx and tx['Nametag'] or nil
                        
                        local col = PlayerInstance.TeamColor
                        col = col and PlayerInstance.TeamColor.Color or nil
                        
                        
                        
                        if (tx) then
                            tx.Color = col or colNew(1,1,1)
                        end
                    end)
                    PlrCons[PlayerName][2] = PlayerInstance.CharacterAdded:Connect(function(c)
                        espObject['Nametag'].Visible = true
                        espObject['Tracer1'].Visible = true
                        espObject['Tracer2'].Visible = true
                        
                        if (espObject['Boxes']) then 
                            for i,v in pairs(espObject['Boxes']) do v.Visible = true end
                        end
                        if (espObject['Distance']) then 
                            espObject['Distance'].Visible = false
                        end
                    end)
                    PlrCons[PlayerName][3] = PlayerInstance.CharacterRemoving:Connect(function()
                        --printconsole(('[%s] Character removed, hiding objects'):format(PlayerName), 0, 0, 255)
                        espObject['Nametag'].Text = 'CHARACTER REMOVED ('..PlayerName..')'
                        espObject['Tracer1'].Visible = false
                        espObject['Tracer2'].Visible = false
                        
                        if (espObject['Boxes']) then 
                            for i,v in pairs(espObject['Boxes']) do v.Visible = false end
                        end
                        if (espObject['Distance']) then 
                            espObject['Distance'].Visible = false
                        end
                        ----printconsole(('[%s] Successfully hid objects'):format(PlayerName), 0, 255, 0)
                    end)
                    
                    espObjects[PlayerName] = espObject
                end
                
                -- Hook stuff
                do
                    for i,v in ipairs(playerNames) do hookPlayer(v) end
                
                    EspCons['PlrA'] = servPlayers.PlayerAdded:Connect(function(p) 
                        local PlayerName = p.Name
                        wait(2.5)
                        hookPlayer(PlayerName)
                    end)
                    EspCons['PlrR'] = servPlayers.PlayerRemoving:Connect(function(p) 
                        local PlayerName = p.Name
                        ----printconsole(('[%s] Player left'):format(PlayerName), 0, 0, 255)
                        local a, b = pcall(function()
                            local thisPlrCons = PlrCons[PlayerName] 
                            if (thisPlrCons) then 
                                for i,v in ipairs(thisPlrCons) do 
                                    v:Disconnect()
                                end
                            end 
                            local thisPlrObjs = espObjects[PlayerName]
                            if (thisPlrObjs) then
                                thisPlrObjs.Nametag:Remove()
                                thisPlrObjs.Tracer1:Remove()
                                thisPlrObjs.Tracer2:Remove()
                                for i,v in pairs(thisPlrObjs['Boxes']) do 
                                    v:Remove()
                                end
                                if (thisPlrObjs['Distance']) then
                                    thisPlrObjs['Distance']:Remove() 
                                end
                            else
                                warn'No objects, oopsies'
                            end
                        end)
                        ----printconsole(('[%s] Deleted objects? %s; %s'):format(PlayerName, tostring(a), tostring(b)), 0, 255, 0)
                    end)
                end
                
                local update_esp do
                    -- 🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑🤑
                    local textoffs = cfrNew(0, 3, 0)
                    local vecNil = vec3(0, 0, 0)
                    
                    local boxoffs_1_0 = cfrNew(-2.5,  2.8,  0.0) -- corner
                    local boxoffs_1_1 = cfrNew(-1.5,  2.8,  0.0)
                    local boxoffs_1_2 = cfrNew(-2.5,  1.8,  0.0)

                    local boxoffs_2_0 = cfrNew( 2.5,  2.8,  0.0) -- corner
                    local boxoffs_2_1 = cfrNew( 1.5,  2.8,  0.0)
                    local boxoffs_2_2 = cfrNew( 2.5,  1.8,  0.0)
                    
                    local boxoffs_3_0 = cfrNew( 2.5, -2.8,  0.0) -- corner
                    local boxoffs_3_1 = cfrNew( 1.5, -2.8,  0.0)
                    local boxoffs_3_2 = cfrNew( 2.5, -1.8,  0.0)
                    
                    local boxoffs_4_0 = cfrNew(-2.5, -2.8,  0.0) -- corner
                    local boxoffs_4_1 = cfrNew(-1.5, -2.8,  0.0)
                    local boxoffs_4_2 = cfrNew(-2.5, -1.8,  0.0)
                    
                    
                    local TracerPos do 
                        if (l_TracerPosition == 'Crosshair') then
                            EspCons['TracerAimbot'] = servRun.RenderStepped:Connect(function() 
                                TracerPos = CrosshairPosition or servInput:GetMouseLocation()
                            end)
                        elseif (l_TracerPosition == 'Character') then
                            EspCons['TracerAimbot'] = servRun.RenderStepped:Connect(function() 
                                local j = clientCamera:WorldToViewportPoint(clientRoot.Position)
                                TracerPos = vec2(j.X, j.Y)
                            end)
                        elseif (l_TracerPosition == 'Down') then
                            TracerPos = clientCamera.ViewportSize
                            TracerPos = vec2(TracerPos.X/2, TracerPos.Y*0.8)
                            EspCons['TracerDown'] = clientCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function() 
                                local _ = clientCamera.ViewportSize
                                TracerPos = vec2(_.X/2, _.Y*0.8)
                            end)
                        elseif (l_TracerPosition == 'Mouse') then
                            EspCons['TracerMouse'] = servRun.RenderStepped:Connect(function() 
                                TracerPos = servInput:GetMouseLocation()
                            end)
                        end
                    end
                    
                    if (l_BoxType == 'Simple 2d') then
                        local viewportY = clientCamera.ViewportSize.Y
                        EspCons['Screen'] = clientCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function() 
                            viewportY = clientCamera.ViewportSize.Y
                        end)
                        
                        update_esp = function() 
                            local namesLen = #playerNames
                            if (isrbxactive() == false or namesLen == 0) then return end
                            
                            -- Get some funny shit
                            local selfPos = clientRoot and clientRoot.Position or vecNil
                            local curTime = tick()
                            local localTeam = clientPlayer.Team
                            
                            -- Loop over esp stuff
                            for i = 1, namesLen do
                                -- Localize some important vars
                                local plrName = playerNames[i]
                                local plrObject = playerManagers[plrName]
                                local espObject = espObjects[plrName]
                                
                                local plrRoot = plrObject.RootPart --😎😎😎
                                local plrHum = plrObject.Humanoid
                                
                                
                                -- Safety checks
                                if (espObject and espObject.upd < curTime and plrRoot and plrHum) then
                                    local plrInstance = plrObject.Player
                                    
                                    if (l_TeamCheck and plrInstance.Team == localTeam) then 
                                        local textLabel = espObject['Nametag']
                                        
                                        if (textLabel.Visible) then
                                            textLabel.Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local boxes = espObject['Boxes']
                                            boxes['1_1'].Visible = false
                                            boxes['1_2'].Visible = false 
                                        end
                                        continue 
                                    end 
                                    
                                    local targRootPos = plrRoot.Position
                                    local Root_Pos2d, Depth do 
                                        local shit, vis = clientCamera:WorldToViewportPoint(targRootPos)
                                        
                                        if (not vis) then
                                            espObject['upd'] = curTime+0.2
                                            espObject['Nametag'].Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local boxes = espObject['Boxes']
                                            boxes['1_1'].Visible = false
                                            boxes['1_2'].Visible = false
                                            continue
                                        end
                                        
                                        Root_Pos2d = vec2(shit.X, shit.Y)
                                        Depth = shit.Z
                                    end
                                    
                                    local Text_Pos2d do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((plrRoot.CFrame*textoffs).Position)
                                        
                                        if (not vis) then
                                            espObject['upd'] = curTime + 0.2
                                            espObject['Nametag'].Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local boxes = espObject['Boxes']
                                            boxes['1_1'].Visible = false
                                            boxes['1_2'].Visible = false
                                            continue
                                        end
                                        Text_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    local Text, Tracer1, Tracer2 = espObject['Nametag'], espObject['Tracer1'], espObject['Tracer2']
                                    local boxes = espObject['Boxes']
                                    
                                    local Box1_1 = boxes['1_1']
                                    local Box1_2 = boxes['1_2']
                                    
                                    local validColor = l_TeamColor and plrInstance.TeamColor.Color or RGBCOLOR
                                    
                                    -- Nametag
                                    do
                                        local HealthText = ''
                                        local DistText = ''
                                        if (l_ShowDistance) then
                                            DistText = (' / d: %.1f'):format((selfPos - targRootPos).Magnitude)
                                        end
                                        if (l_ShowHealth) then
                                            HealthText = ' / hp: '..(l_HealthType == 'Percentage' and (mathFloor((plrHum.Health / plrHum.MaxHealth)*100)..'%') or mathFloor(hum.Health))
                                        end
                                        
                                        Text.Text = plrName .. DistText .. HealthText
                                        Text.Position = Text_Pos2d - vec2(0, Text.TextBounds.Y)
                                    end
                                    
                                    -- Tracers
                                    do
                                        local TracerP1 = Root_Pos2d
                                        local TracerP2 = TracerPos or vec2(0, 0)
                                        
                                        Tracer1.From = TracerP1 
                                        Tracer1.To = TracerP2
                                        Tracer2.From = TracerP1 
                                        Tracer2.To = TracerP2
                                        
                                        Tracer1.Color = validColor
                                    end
                                    
                                    -- Boxes
                                    do 
                                        Depth = (1 / Depth) * viewportY * (1 / (clientCamera.FieldOfView / 70))
                                        
                                        Root_Pos2d = Root_Pos2d - vec2(Depth*1.5, Depth*1.8)
                                        local Box_Size = vec2(Depth*3,Depth*4)
                                        
                                        Box1_1.Size = Box_Size
                                        Box1_1.Position = Root_Pos2d
                                        
                                        Box1_2.Size = Box_Size
                                        Box1_2.Position = Root_Pos2d 
                                    end
                                    
                                    Box1_1.Color = validColor
                                    Box1_1.Visible = l_Boxes
                                    Box1_2.Visible = l_Boxes
                                    Text.Visible = l_Nametags
                                    Tracer1.Visible = l_Tracers
                                    Tracer2.Visible = l_Tracers
                                end
                            end
                        end
                    elseif (l_BoxType == 'Westeria 2d') then
                        local ScreenY = clientCamera.ViewportSize.Y
                        EspCons['Screen'] = clientCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function() 
                            ScreenY = clientCamera.ViewportSize.Y
                        end)
                        
                        
                        update_esp = function() 
                            local len = #playerNames
                            if (isrbxactive() == false or len == 0) then return end
                            local SelfPos = clientRoot and clientRoot.Position or vec3(0, 0, 0)
                            local CurTime = tick()
                            
                            local localteam = clientPlayer.Team
                            
                            for i = 1, len do
                                local Name = playerNames[i]
                                local PlayerObject = playerManagers[Name]
                                local espObject = espObjects[Name]
                                local rp = PlayerObject.RootPart
                                local hum = PlayerObject.Humanoid
                                
                                if (espObject and rp and hum) then
                                    local PlayerInstance = PlayerObject.Player
                                    
                                    if (espObject['upd'] > CurTime) then continue end
                                    if (l_TeamCheck and PlayerInstance.Team == localteam) then
                                        local tx = espObject['Nametag']
                                        if (tx.Visible == true) then
                                            tx.Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local Boxes = espObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            Boxes['2_1'].Visible = false
                                            Boxes['2_2'].Visible = false
                                            Boxes['3_1'].Visible = false
                                            Boxes['3_2'].Visible = false
                                            Boxes['4_1'].Visible = false
                                            Boxes['4_2'].Visible = false
                                            Boxes['1_1_o'].Visible = false
                                            Boxes['1_2_o'].Visible = false
                                            Boxes['2_1_o'].Visible = false
                                            Boxes['2_2_o'].Visible = false
                                            Boxes['3_1_o'].Visible = false
                                            Boxes['3_2_o'].Visible = false
                                            Boxes['4_1_o'].Visible = false
                                            Boxes['4_2_o'].Visible = false
                                        end
                                        continue
                                    end 
                                    local TargRootPos = rp.CFrame
                                    
                                    -- Some position shit
                                    local Text_Pos2d do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*textoffs).Position)
                                        
                                        if (not vis) then
                                            espObject['upd'] = CurTime+0.2
                                            espObject['Nametag'].Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local Boxes = espObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            Boxes['2_1'].Visible = false
                                            Boxes['2_2'].Visible = false
                                            Boxes['3_1'].Visible = false
                                            Boxes['3_2'].Visible = false
                                            Boxes['4_1'].Visible = false
                                            Boxes['4_2'].Visible = false
                                            Boxes['1_1_o'].Visible = false
                                            Boxes['1_2_o'].Visible = false
                                            Boxes['2_1_o'].Visible = false
                                            Boxes['2_2_o'].Visible = false
                                            Boxes['3_1_o'].Visible = false
                                            Boxes['3_2_o'].Visible = false
                                            Boxes['4_1_o'].Visible = false
                                            Boxes['4_2_o'].Visible = false
                                            continue
                                        end
                                        Text_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    TargRootPos = TargRootPos.Position
                                    local Root_Pos2d, Depth do 
                                        local shit, vis = clientCamera:WorldToViewportPoint(TargRootPos)
                                        if (not vis) then
                                            espObject['upd'] = CurTime+0.2
                                            espObject['Nametag'].Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local Boxes = espObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            Boxes['2_1'].Visible = false
                                            Boxes['2_2'].Visible = false
                                            Boxes['3_1'].Visible = false
                                            Boxes['3_2'].Visible = false
                                            Boxes['4_1'].Visible = false
                                            Boxes['4_2'].Visible = false
                                            Boxes['1_1_o'].Visible = false
                                            Boxes['1_2_o'].Visible = false
                                            Boxes['2_1_o'].Visible = false
                                            Boxes['2_2_o'].Visible = false
                                            Boxes['3_1_o'].Visible = false
                                            Boxes['3_2_o'].Visible = false
                                            Boxes['4_1_o'].Visible = false
                                            Boxes['4_2_o'].Visible = false
                                            continue
                                        end
                                        
                                        
                                        Root_Pos2d = vec2(shit.X, shit.Y)
                                        Depth = shit.Z
                                    end
                                    
                                    
                                    local Text, Tracer1, Tracer2 = espObject['Nametag'], espObject['Tracer1'], espObject['Tracer2']
                                    local Boxes = espObject['Boxes']
                                    
                                    -- most optimized lua code
                                    local Box1_1 = Boxes['1_1']
                                    local Box1_2 = Boxes['1_2']
                                    local Box2_1 = Boxes['2_1']
                                    local Box2_2 = Boxes['2_2']
                                    local Box3_1 = Boxes['3_1']
                                    local Box3_2 = Boxes['3_2']
                                    local Box4_1 = Boxes['4_1']
                                    local Box4_2 = Boxes['4_2']
                                    
                                    local Box1_1_o = Boxes['1_1_o']
                                    local Box1_2_o = Boxes['1_2_o']
                                    local Box2_1_o = Boxes['2_1_o']
                                    local Box2_2_o = Boxes['2_2_o']
                                    local Box3_1_o = Boxes['3_1_o']
                                    local Box3_2_o = Boxes['3_2_o']
                                    local Box4_1_o = Boxes['4_1_o']
                                    local Box4_2_o = Boxes['4_2_o']
                                    
                                    
                                    -- Text shit
                                    do
                                        local HealthText = ''
                                        local DistText = ''
                                        if (l_ShowDistance) then
                                            DistText = (' / d: %.1f'):format((SelfPos - TargRootPos).Magnitude)
                                        end
                                        if (l_ShowHealth) then
                                            HealthText = ' / hp: '..(l_HealthType == 'Percentage' and (mathFloor((hum.Health / hum.MaxHealth)*100)..'%') or mathFloor(hum.Health))
                                        end
                                        
                                        Text.Text = Name .. DistText .. HealthText
                                        Text.Position = Text_Pos2d - vec2(0, Text.TextBounds.Y)
                                    end
                                    -- Tracer shit
                                    local ValidColor
                                    do
                                        local TracerP1 = Root_Pos2d
                                        local TracerP2 = TracerPos or vec2(0, 0)
                                        Tracer1.From = TracerP1 
                                        Tracer1.To = TracerP2
                                        Tracer2.From = TracerP1 
                                        Tracer2.To = TracerP2
                                        do
                                            local _ = (l_TeamColor and PlayerInstance.TeamColor)
                                            _ = _ and _.Color or RGBCOLOR
                                            ValidColor = _
                                        end
                                        Tracer1.Color = ValidColor
                                    end
                                    
                                    -- Box shit :troll:
                                    do 
                                        -- Modify depth
                                        Depth = (1 / Depth) * ScreenY * (1 / (clientCamera.FieldOfView / 70))
                                        -- Make size
                                        local BoxSize = vec2(Depth*3,Depth*4)
                                        -- Make corners
                                        local TopLeft = Root_Pos2d - vec2(Depth*1.5, Depth*1.8)
                                        local TopRight = Root_Pos2d + vec2(Depth*1.5, -Depth*1.8)
                                        local BottomLeft = Root_Pos2d - vec2(Depth*1.5, -Depth*1.8)
                                        local BottomRight = Root_Pos2d + vec2(Depth*1.5, Depth*1.8)

                                        local p1 = TopLeft:lerp(TopRight, 0.2)
                                        local p2 = TopLeft:lerp(BottomLeft, 0.2)
                                        local p3 = TopRight:lerp(TopLeft, 0.2)
                                        local p4 = TopRight:lerp(BottomRight, 0.2)
                                        local p5 = BottomLeft:lerp(TopLeft, 0.2)
                                        local p6 = BottomLeft:lerp(BottomRight, 0.2)
                                        local p7 = BottomRight:lerp(TopRight, 0.2)
                                        local p8 = BottomRight:lerp(BottomLeft, 0.2)
                                        
                                        Box1_1.From = TopLeft
                                        Box1_1.To = p1
                                        Box1_2.From = TopLeft
                                        Box1_2.To = p2
                                        
                                        Box2_1.From = TopRight
                                        Box2_1.To = p3
                                        Box2_2.From = TopRight
                                        Box2_2.To = p4
                                        
                                        Box3_1.From = BottomLeft
                                        Box3_1.To = p5
                                        Box3_2.From = BottomLeft
                                        Box3_2.To = p6
                                        
                                        Box4_1.From = BottomRight
                                        Box4_1.To = p7
                                        Box4_2.From = BottomRight
                                        Box4_2.To = p8
                                        
                                        
                                        Box1_1_o.From = TopLeft
                                        Box1_1_o.To = p1
                                        Box1_2_o.From = TopLeft
                                        Box1_2_o.To = p2
                                        Box2_1_o.From = TopRight
                                        Box2_1_o.To = p3
                                        Box2_2_o.From = TopRight
                                        Box2_2_o.To = p4
                                        Box3_1_o.From = BottomLeft
                                        Box3_1_o.To = p5
                                        Box3_2_o.From = BottomLeft
                                        Box3_2_o.To = p6
                                        Box4_1_o.From = BottomRight
                                        Box4_1_o.To = p7
                                        Box4_2_o.From = BottomRight
                                        Box4_2_o.To = p8
                                    end
                                    
                                    Text.Visible = l_Nametags
                                    Tracer1.Visible = l_Tracers
                                    Tracer2.Visible = l_Tracers
                                    
                                    
                                    Box1_1.Color = ValidColor
                                    Box1_2.Color = ValidColor
                                    Box2_1.Color = ValidColor
                                    Box2_2.Color = ValidColor
                                    Box3_1.Color = ValidColor
                                    Box3_2.Color = ValidColor
                                    Box4_1.Color = ValidColor
                                    Box4_2.Color = ValidColor
                                    
                                    Box1_1.Visible = l_Boxes
                                    Box1_2.Visible = l_Boxes
                                    Box2_1.Visible = l_Boxes
                                    Box2_2.Visible = l_Boxes
                                    Box3_1.Visible = l_Boxes
                                    Box3_2.Visible = l_Boxes
                                    Box4_1.Visible = l_Boxes
                                    Box4_2.Visible = l_Boxes
                                    
                                    Box1_1_o.Visible = l_Boxes
                                    Box1_2_o.Visible = l_Boxes
                                    Box2_1_o.Visible = l_Boxes
                                    Box2_2_o.Visible = l_Boxes
                                    Box3_1_o.Visible = l_Boxes
                                    Box3_2_o.Visible = l_Boxes
                                    Box4_1_o.Visible = l_Boxes
                                    Box4_2_o.Visible = l_Boxes
                                end
                            end
                        end
                    elseif (l_BoxType == 'Westeria 3d') then
                        update_esp = function() 
                            local len = #playerNames
                            if (isrbxactive() == false or len == 0) then return end
                            local SelfPos = clientRoot and clientRoot.Position or vec3(0, 0, 0)
                            local CurTime = tick()
                            
                            local localteam = clientPlayer.Team
                            
                            for i = 1, len do
                                local Name = playerNames[i]
                                local PlayerObject = playerManagers[Name]
                                local espObject = espObjects[Name]
                                local rp = PlayerObject.RootPart
                                local hum = PlayerObject.Humanoid
                                
                                if (espObject and rp and hum) then
                                    local PlayerInstance = PlayerObject.Player
                                    
                                    if (espObject['upd'] > CurTime) then continue end
                                    if (l_TeamCheck and PlayerInstance.Team == localteam) then
                                        local tx = espObject['Nametag']
                                        if (tx.Visible) then
                                            tx.Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local Boxes = espObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            Boxes['2_1'].Visible = false
                                            Boxes['2_2'].Visible = false
                                            Boxes['3_1'].Visible = false
                                            Boxes['3_2'].Visible = false
                                            Boxes['4_1'].Visible = false
                                            Boxes['4_2'].Visible = false
                                            Boxes['1_1_o'].Visible = false
                                            Boxes['1_2_o'].Visible = false
                                            Boxes['2_1_o'].Visible = false
                                            Boxes['2_2_o'].Visible = false
                                            Boxes['3_1_o'].Visible = false
                                            Boxes['3_2_o'].Visible = false
                                            Boxes['4_1_o'].Visible = false
                                            Boxes['4_2_o'].Visible = false
                                        end
                                        continue
                                    end
                                    local TargRootPos = rp.CFrame
                                    
                                    -- Some position shit
                                    local Text_Pos2d do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*textoffs).Position)
                                        
                                        if (not vis) then
                                            espObject['upd'] = CurTime+0.2
                                            espObject['Nametag'].Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local Boxes = espObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            Boxes['2_1'].Visible = false
                                            Boxes['2_2'].Visible = false
                                            Boxes['3_1'].Visible = false
                                            Boxes['3_2'].Visible = false
                                            Boxes['4_1'].Visible = false
                                            Boxes['4_2'].Visible = false
                                            Boxes['1_1_o'].Visible = false
                                            Boxes['1_2_o'].Visible = false
                                            Boxes['2_1_o'].Visible = false
                                            Boxes['2_2_o'].Visible = false
                                            Boxes['3_1_o'].Visible = false
                                            Boxes['3_2_o'].Visible = false
                                            Boxes['4_1_o'].Visible = false
                                            Boxes['4_2_o'].Visible = false
                                            continue
                                        end
                                        Text_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    local Box_Pos1_0 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_1_0).Position)
                                        -- i am not doing anymore fuckingchecks
                                        Box_Pos1_0 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos1_1 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_1_1).Position)
                                        Box_Pos1_1 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos1_2 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_1_2).Position)
                                        Box_Pos1_2 = vec2(shit.X, shit.Y)
                                    end
                                    
                                    local Box_Pos2_0 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_2_0).Position)
                                        Box_Pos2_0 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos2_1 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_2_1).Position)
                                        Box_Pos2_1 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos2_2 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_2_2).Position)
                                        Box_Pos2_2 = vec2(shit.X, shit.Y)
                                    end
                                    
                                    local Box_Pos3_0 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_3_0).Position)
                                        Box_Pos3_0 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos3_1 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_3_1).Position)
                                        Box_Pos3_1 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos3_2 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_3_2).Position)
                                        Box_Pos3_2 = vec2(shit.X, shit.Y)
                                    end
                                    
                                    local Box_Pos4_0 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_4_0).Position)
                                        Box_Pos4_0 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos4_1 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_4_1).Position)
                                        Box_Pos4_1 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos4_2 do
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_4_2).Position)
                                        Box_Pos4_2 = vec2(shit.X, shit.Y)
                                    end
                                    
                                    
                                    
                                    
                                    
                                    TargRootPos = TargRootPos.Position
                                    local Root_Pos2d do 
                                        local shit, vis = clientCamera:WorldToViewportPoint(TargRootPos)
                                        if (not vis) then
                                            espObject['upd'] = CurTime+0.2
                                            espObject['Nametag'].Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local Boxes = espObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            Boxes['2_1'].Visible = false
                                            Boxes['2_2'].Visible = false
                                            Boxes['3_1'].Visible = false
                                            Boxes['3_2'].Visible = false
                                            Boxes['4_1'].Visible = false
                                            Boxes['4_2'].Visible = false
                                            Boxes['1_1_o'].Visible = false
                                            Boxes['1_2_o'].Visible = false
                                            Boxes['2_1_o'].Visible = false
                                            Boxes['2_2_o'].Visible = false
                                            Boxes['3_1_o'].Visible = false
                                            Boxes['3_2_o'].Visible = false
                                            Boxes['4_1_o'].Visible = false
                                            Boxes['4_2_o'].Visible = false
                                            continue
                                        end
                                        
                                        Root_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    
                                    local Text, Tracer1, Tracer2 = espObject['Nametag'], espObject['Tracer1'], espObject['Tracer2']
                                    local Boxes = espObject['Boxes']
                                    
                                    -- most optimized lua code
                                    local Box1_1 = Boxes['1_1']
                                    local Box1_2 = Boxes['1_2']
                                    local Box2_1 = Boxes['2_1']
                                    local Box2_2 = Boxes['2_2']
                                    local Box3_1 = Boxes['3_1']
                                    local Box3_2 = Boxes['3_2']
                                    local Box4_1 = Boxes['4_1']
                                    local Box4_2 = Boxes['4_2']
                                    
                                    local Box1_1_o = Boxes['1_1_o']
                                    local Box1_2_o = Boxes['1_2_o']
                                    local Box2_1_o = Boxes['2_1_o']
                                    local Box2_2_o = Boxes['2_2_o']
                                    local Box3_1_o = Boxes['3_1_o']
                                    local Box3_2_o = Boxes['3_2_o']
                                    local Box4_1_o = Boxes['4_1_o']
                                    local Box4_2_o = Boxes['4_2_o']
                                    
                                    
                                    -- Text shit
                                    do
                                        local HealthText = ''
                                        local DistText = ''
                                        if (l_ShowDistance) then
                                            DistText = (' / d: %.1f'):format((SelfPos - TargRootPos).Magnitude)
                                        end
                                        if (l_ShowHealth) then
                                            HealthText = ' / hp: '..(l_HealthType == 'Percentage' and (mathFloor((hum.Health / hum.MaxHealth)*100)..'%') or mathFloor(hum.Health))
                                        end
                                        
                                        Text.Text = Name .. DistText .. HealthText
                                        Text.Position = Text_Pos2d - vec2(0, Text.TextBounds.Y)
                                    end
                                    -- Tracer shit
                                    local ValidColor
                                    do
                                        local TracerP1 = Root_Pos2d
                                        local TracerP2 = TracerPos or vec2(0, 0)
                                        Tracer1.From = TracerP1 
                                        Tracer1.To = TracerP2
                                        Tracer2.From = TracerP1 
                                        Tracer2.To = TracerP2
                                        do
                                            local _ = (l_TeamColor and PlayerInstance.TeamColor)
                                            _ = _ and _.Color or RGBCOLOR
                                            ValidColor = _
                                        end
                                        Tracer1.Color = ValidColor
                                    end
                                    
                                    -- Box shit :troll:
                                    do 
                                        Box1_1.From = Box_Pos1_0
                                        Box1_1.To = Box_Pos1_1
                                        Box1_2.From = Box_Pos1_0
                                        Box1_2.To = Box_Pos1_2
                                        
                                        Box2_1.From = Box_Pos2_0
                                        Box2_1.To = Box_Pos2_1
                                        Box2_2.From = Box_Pos2_0
                                        Box2_2.To = Box_Pos2_2
                                        
                                        Box3_1.From = Box_Pos3_0
                                        Box3_1.To = Box_Pos3_1
                                        Box3_2.From = Box_Pos3_0
                                        Box3_2.To = Box_Pos3_2
                                        
                                        Box4_1.From = Box_Pos4_0
                                        Box4_1.To = Box_Pos4_1
                                        Box4_2.From = Box_Pos4_0
                                        Box4_2.To = Box_Pos4_2
                                        
                                        Box1_1_o.From = Box_Pos1_0
                                        Box1_1_o.To = Box_Pos1_1
                                        Box1_2_o.From = Box_Pos1_0
                                        Box1_2_o.To = Box_Pos1_2
                                        
                                        Box2_1_o.From = Box_Pos2_0
                                        Box2_1_o.To = Box_Pos2_1
                                        Box2_2_o.From = Box_Pos2_0
                                        Box2_2_o.To = Box_Pos2_2
                                        
                                        Box3_1_o.From = Box_Pos3_0
                                        Box3_1_o.To = Box_Pos3_1
                                        Box3_2_o.From = Box_Pos3_0
                                        Box3_2_o.To = Box_Pos3_2
                                        
                                        Box4_1_o.From = Box_Pos4_0
                                        Box4_1_o.To = Box_Pos4_1
                                        Box4_2_o.From = Box_Pos4_0
                                        Box4_2_o.To = Box_Pos4_2
                                    end
                                    
                                    Text.Visible = l_Nametags
                                    Tracer1.Visible = l_Tracers
                                    Tracer2.Visible = l_Tracers
                                    
                                    
                                    Box1_1.Color = ValidColor
                                    Box1_2.Color = ValidColor
                                    Box2_1.Color = ValidColor
                                    Box2_2.Color = ValidColor
                                    Box3_1.Color = ValidColor
                                    Box3_2.Color = ValidColor
                                    Box4_1.Color = ValidColor
                                    Box4_2.Color = ValidColor
                                    
                                    Box1_1.Visible = l_Boxes
                                    Box1_2.Visible = l_Boxes
                                    Box2_1.Visible = l_Boxes
                                    Box2_2.Visible = l_Boxes
                                    Box3_1.Visible = l_Boxes
                                    Box3_2.Visible = l_Boxes
                                    Box4_1.Visible = l_Boxes
                                    Box4_2.Visible = l_Boxes
                                    
                                    Box1_1_o.Visible = l_Boxes
                                    Box1_2_o.Visible = l_Boxes
                                    Box2_1_o.Visible = l_Boxes
                                    Box2_2_o.Visible = l_Boxes
                                    Box3_1_o.Visible = l_Boxes
                                    Box3_2_o.Visible = l_Boxes
                                    Box4_1_o.Visible = l_Boxes
                                    Box4_2_o.Visible = l_Boxes
                                end
                            end
                        end
                    elseif (l_BoxType == 'Simple 3d') then
                        update_esp = function() 
                            local len = #playerNames
                            if (isrbxactive() == false or len == 0) then return end
                            local SelfPos = clientRoot and clientRoot.Position or vec3(0, 0, 0)
                            local CurTime = tick()
                            
                            local localteam = clientPlayer.Team
                            
                            for i = 1, len do
                                local Name = playerNames[i]
                                local PlayerObject = playerManagers[Name]
                                local espObject = espObjects[Name]
                                local rp = PlayerObject.RootPart
                                local hum = PlayerObject.Humanoid
                                
                                if (espObject and rp and hum) then
                                    local PlayerInstance = PlayerObject.Player
                                    
                                    if (espObject['upd'] > CurTime) then continue end
                                    if (l_TeamCheck and PlayerInstance.Team == localteam) then
                                        local tx = espObject['Nametag']
                                        if (tx.Visible == true) then
                                            tx.Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local Boxes = espObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                        end
                                        continue
                                    end
                                    local TargRootPos = rp.CFrame
                                    
                                    -- Some position shit
                                    local Text_Pos2d do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*textoffs).Position)
                                        
                                        if (not vis) then
                                            espObject['upd'] = CurTime+0.2
                                            espObject['Nametag'].Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local Boxes = espObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            continue
                                        end
                                        Text_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    local Box_Pos1 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_1_0).Position)
                                        Box_Pos1 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos2 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_2_0).Position)
                                        Box_Pos2 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos3 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_3_0).Position)
                                        Box_Pos3 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos4 do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*boxoffs_4_0).Position)
                                        Box_Pos4 = vec2(shit.X, shit.Y)
                                    end
                                    
                                    
                                    TargRootPos = TargRootPos.Position
                                    local Root_Pos2d do 
                                        local shit, vis = clientCamera:WorldToViewportPoint(TargRootPos)
                                        if (not vis) then
                                            espObject['upd'] = CurTime+0.2
                                            espObject['Nametag'].Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            
                                            local Boxes = espObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            continue
                                        end
                                        
                                        Root_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    
                                    local Text, Tracer1, Tracer2 = espObject['Nametag'], espObject['Tracer1'], espObject['Tracer2']
                                    local Boxes = espObject['Boxes']
                                    local Box1_1 = Boxes['1_1']
                                    local Box1_2 = Boxes['1_2']
                                    
                                    -- Text shit
                                    do
                                        local HealthText = ''
                                        local DistText = ''
                                        if (l_ShowDistance) then
                                            DistText = (' / d: %.1f'):format((SelfPos - TargRootPos).Magnitude)
                                        end
                                        if (l_ShowHealth) then
                                            HealthText = ' / hp: '..(l_HealthType == 'Percentage' and (mathFloor((hum.Health / hum.MaxHealth)*100)..'%') or mathFloor(hum.Health))
                                        end
                                        
                                        Text.Text = Name .. DistText .. HealthText
                                        Text.Position = Text_Pos2d - vec2(0, Text.TextBounds.Y)
                                    end
                                    -- Tracer shit
                                    local ValidColor
                                    do
                                        local TracerP1 = Root_Pos2d
                                        local TracerP2 = TracerPos or vec2(0, 0)
                                        Tracer1.From = TracerP1 
                                        Tracer1.To = TracerP2
                                        Tracer2.From = TracerP1 
                                        Tracer2.To = TracerP2
                                        do
                                            local _ = (l_TeamColor and PlayerInstance.TeamColor)
                                            _ = _ and _.Color or RGBCOLOR
                                            
                                            ValidColor = _
                                        end
                                        Tracer1.Color = ValidColor
                                    end
                                    
                                    -- Box shit :troll:
                                    do 
                                        Box1_1.PointA = Box_Pos1
                                        Box1_1.PointB = Box_Pos2
                                        Box1_1.PointC = Box_Pos3
                                        Box1_1.PointD = Box_Pos4
                                        
                                        Box1_2.PointA = Box_Pos1
                                        Box1_2.PointB = Box_Pos2
                                        Box1_2.PointC = Box_Pos3
                                        Box1_2.PointD = Box_Pos4
                                    end
                                    
                                    Text.Visible = l_Nametags
                                    Tracer1.Visible = l_Tracers
                                    Tracer2.Visible = l_Tracers
                                    
                                    Box1_1.Color = ValidColor
                                    
                                    Box1_1.Visible = l_Boxes
                                    Box1_2.Visible = l_Boxes
                                end
                            end
                        end
                    else 
                        
                        update_esp = function() 
                            local len = #playerNames
                            if (isrbxactive() == false or len == 0) then return end
                            local SelfPos = clientRoot and clientRoot.Position or vec3(0, 0, 0)
                            local CurTime = tick()
                            
                            for i = 1, len do
                                local Name = playerNames[i]
                                local PlayerObject = playerManagers[Name]
                                local espObject = espObjects[Name]
                                local rp = PlayerObject.RootPart
                                local hum = PlayerObject.Humanoid
                                
                                
                                
                                if (espObject and rp and hum) then
                                    if (espObject['upd'] > CurTime) then continue end
                                    
                                    local TargRootPos = rp.CFrame
                                    
                                    local Text_Pos2d do 
                                        local shit, vis = clientCamera:WorldToViewportPoint((TargRootPos*textoffs).Position)
                                        
                                        if (not vis) then
                                            espObject['upd'] = CurTime+0.2
                                            espObject['Nametag'].Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            continue
                                        end
                                        Text_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    TargRootPos = TargRootPos.Position
                                    
                                    local Root_Pos2d do 
                                        local shit, vis = clientCamera:WorldToViewportPoint(TargRootPos)
                                        if (not vis) then
                                            espObject['upd'] = CurTime+0.2
                                            espObject['Nametag'].Visible = false
                                            espObject['Tracer1'].Visible = false
                                            espObject['Tracer2'].Visible = false
                                            continue
                                        end
                                        
                                        Root_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    
                                    
                                    local Text, Tracer1, Tracer2 = espObject['Nametag'], espObject['Tracer1'], espObject['Tracer2']
                                    
                                    local Dist = (SelfPos - TargRootPos).Magnitude
                                    local HealthText = l_HealthType == 'Percentage' and (mathFloor((hum.Health / hum.MaxHealth)*100)..'%') or mdloor(hum.Health)
                                    
                                    
                                    Text.Text = (('%s / dist:%.1f / hp:%s'):format(Name, Dist, HealthText))
                                    Text.Position = Text_Pos2d - vec2(0, Text.TextBounds.Y)
                                    
                                    
                                    local TracerP1 = Root_Pos2d
                                    local TracerP2 = TracerPos or vec2(0, 0)
                                    
                                    Tracer1.From = TracerP1 
                                    Tracer1.To = TracerP2
                                    Tracer2.From = TracerP1 
                                    Tracer2.To = TracerP2
                                    
                                    do
                                        local _ = (l_TeamColor and PlayerObject.TeamColor)
                                        _ = _ and _.Color or RGBCOLOR
                                        
                                        Tracer1.Color = _
                                    end
                                    Text.Visible = l_Nametags
                                    Tracer1.Visible = l_Tracers
                                    Tracer2.Visible = l_Tracers
                                end
                            end
                        end
                    end
                end
                
                
                if (l_UpdateDelay == 0) then
                    EspCons['Update'] = servRun.RenderStepped:Connect(update_esp)
                else
                    local jskull2 = jskull1
                    spawn(function()
                        while jskull2 == jskull1 and r_esp:isEnabled() do 
                            update_esp()
                            wait(l_UpdateDelay)
                        end
                    end)
                end
            end))
            end)
            r_esp:Connect('Disabled',function() 
                print(pcall(function()
                for _, con in pairs(EspCons) do con:Disconnect() end
                tabClear(EspCons)
                
                --if (EspFolder) then EspFolder:Destroy() EspFolder = nil end
                
                for i,v in ipairs(playerNames) do 
                    local _ = PlrCons[v] 
                    if (_) then 
                        for i,v in ipairs(_) do 
                            v:Disconnect()
                        end
                    end 
                    local _ = espObjects[v]
                    if (_) then
                        _['Nametag']:Remove()
                        _['Tracer1']:Remove()
                        _['Tracer2']:Remove()
                        
                        if (_['Boxes']) then
                            for i,v in pairs(_['Boxes']) do v:Remove() end    
                        end
                    end
                end
                tabClear(PlrCons)
                tabClear(espObjects)
            end))
            end)
        
        end
        -- Fullbright
        do 
            local s_looped = r_fullbright:addToggle('Looped'):setTooltip('Loops the fullbright every frame. Needed for games like the Rake or Lumber Tycoon')
            local s_mode = r_fullbright:addDropdown('Mode',true):setTooltip('Different modes for fullbright. Some may work better in other games')
            
            s_mode:addOption('Standard'):setTooltip('Your average fullbright. Doesn\'t look too harsh'):Select()
            s_mode:addOption('Bright'):setTooltip('Insanely bright')
            s_mode:addOption('Nofog'):setTooltip('Only affects fog')
            s_mode:addOption('Soft'):setTooltip('Instead of turning everything white, it turns everything gray. Meant for games with bloom effects')
            
            s_looped:Connect('Toggled',function()r_fullbright:Reset()end)
            s_mode:Connect('Changed',function()r_fullbright:Reset()end)
            
            local oldambient
            local oldoutambient
            local oldbrightness
            local oldshadows
            local oldfogend
            local oldfogstart
            
            local steppedcon
            
            r_fullbright:Connect('Enabled',function() 
                local loop = s_looped:isEnabled()
                local mode = s_mode:GetSelection()
                
                local lighting = game:GetService('Lighting')
                dnec(lighting.Changed, 'li_changed')
                
                oldambient     = lighting.Ambient        
                oldoutambient  = lighting.OutdoorAmbient 
                oldbrightness  = lighting.Brightness     
                oldshadows     = lighting.GlobalShadows  
                oldfogend      = lighting.FogEnd
                oldfogstart    = lighting.FogStart
                
                if (mode == 'Standard') then
                    local c1 = colNew(0.9, 0.9, 0.9)
                    local function fb() 
                        lighting.Ambient = c1
                        lighting.OutdoorAmbient = c1
                        lighting.Brightness = 7
                        lighting.FogEnd = 9e9
                        lighting.FogStart = 9e9
                    end
                    
                    if (loop) then
                        servRun:BindToRenderStep('RL-Fullbright',9999,fb)
                        steppedcon = servRun.Stepped:Connect(fb)
                    else
                        fb()   
                    end
                elseif (mode == 'Bright') then
                    local c1 = colNew(1, 1, 1)
                    local function fb() 
                        lighting.Ambient = c1
                        lighting.OutdoorAmbient = c1
                        lighting.Brightness = 10
                        lighting.FogEnd = 9e9
                        lighting.FogStart = 9e9
                        lighting.GlobalShadows = false
                    end
                    
                    if (loop) then
                        servRun:BindToRenderStep('RL-Fullbright',9999,fb) 
                        steppedcon = servRun.Stepped:Connect(fb)
                    else
                        fb()   
                    end
                elseif (mode == 'Nofog') then
                    local function fb() 
                        lighting.FogEnd = 9e9
                        lighting.FogStart = 9e9
                    end
                    
                    if (loop) then
                        servRun:BindToRenderStep('RL-Fullbright',9999,fb) 
                        steppedcon = servRun.Stepped:Connect(fb)
                    else
                        fb()   
                    end
                elseif (mode == 'Soft') then
                    local c1 = colNew(0.6, 0.6, 0.6)
                    local function fb() 
                        lighting.Ambient = c1
                        lighting.OutdoorAmbient = c1
                        lighting.Brightness = 4
                        lighting.FogEnd = 9e9
                        lighting.FogStart = 9e9
                    end
                    
                    if (loop) then
                        servRun:BindToRenderStep('RL-Fullbright',9999,fb) 
                        steppedcon = servRun.Stepped:Connect(fb)
                    else
                        fb()   
                    end
                end
            end)
            
            r_fullbright:Connect('Disabled',function() 
                servRun:UnbindFromRenderStep('RL-Fullbright')
                if (steppedcon) then steppedcon:Disconnect() steppedcon=nil;end
                
                local lighting = game:GetService('Lighting')
                lighting.Ambient         = oldambient
                lighting.OutdoorAmbient  = oldoutambient
                lighting.Brightness      = oldbrightness
                lighting.GlobalShadows   = oldshadows
                lighting.FogEnd          = oldfogend
                lighting.FogStart        = oldfogstart
                
                enec('li_changed')
            end)
            
        end
        -- Keystrokes 
        do 
            local kmframe
            
            local InputConnection
            local KSDrag
            
            r_keystrokes:Connect('Enabled',function() 
                kmframe = instNew('Frame')
                kmframe.BackgroundTransparency = 0.9
                kmframe.Size = dimOffset(170, 120)
                kmframe.Position = dimNew(1,-170-20,0,20)
                kmframe.ZIndex = 200
                kmframe.Parent = ui:GetScreen()
                
                local w = instNew('TextLabel')
                w.AnchorPoint = vec2(0.5, 0)
                w.BackgroundColor3 = RLTHEMEDATA['gw'][1]
                w.BackgroundTransparency = RLTHEMEDATA['gw'][2]
                w.Font = RLTHEMEFONT
                w.Position = dimScale(0.5, 0)
                w.Size = dimOffset(50, 50)
                w.Text = 'W'
                w.TextColor3 = RLTHEMEDATA['tm'][1]
                w.TextSize = 19
                w.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                w.TextStrokeTransparency = 0
                w.TextXAlignment = 'Center'
                w.TextYAlignment = 'Center'
                w.ZIndex = 300
                w.Parent = kmframe
                stroke(w, 'Border')
                
                local a = w:Clone()
                a.Text = 'A'
                a.AnchorPoint = vec2(0, 1)
                a.Position = dimScale(0, 1)
                a.Parent = kmframe
                
                local s = w:Clone()
                s.Text = 'S'
                s.AnchorPoint = vec2(0.5, 1)
                s.Position = dimScale(0.5, 1)
                s.Parent = kmframe
                
                local d = w:Clone()
                d.Text = 'D'
                d.AnchorPoint = vec2(1, 1)
                d.Position = dimScale(1, 1)
                d.Parent = kmframe
                
                --[[local mb1 = w:Clone()
                mb1.Text = 'Mouse1'
                mb1.AnchorPoint = vec2(0, 1)
                mb1.Position = dimScale(0, 2)
                mb1.Parent = kmframe]]

                
                local keys = {}
                keys[Enum.KeyCode.W] = w
                keys[Enum.KeyCode.A] = a
                keys[Enum.KeyCode.S] = s
                keys[Enum.KeyCode.D] = d
                
                
                local monitor_inset = servGui:GetGuiInset()
                
                kmframe.InputBegan:Connect(function(io) 
                    local uitv = io.UserInputType.Value
                    
                    if (uitv == 0) then
                        local monitor_res = clientCamera.ViewportSize
                        
                        local root_pos = kmframe.AbsolutePosition -- Get the original header position
                        local start_pos = io.Position
                        start_pos = vec2(start_pos.X, start_pos.Y)
                        
                        KSDrag = servInput.InputChanged:Connect(function(io) 
                            if (io.UserInputType.Value == 4) then
                                local curr_pos = io.Position
                                curr_pos = vec2(curr_pos.X, curr_pos.Y)
                                local _ = (root_pos + (curr_pos - start_pos) + monitor_inset) / monitor_res
                                kmframe.Position = dimScale(_.X,_.Y)
                            end
                        end)
                    end
                end)
                kmframe.InputEnded:Connect(function(io) 
                    if (io.UserInputType.Value == 0) then
                        if (KSDrag) then KSDrag:Disconnect() KSDrag = nil end
                    end
                end)
                
                local ColEnabled = RLTHEMEDATA['ge'][1]
                local ColNorm = RLTHEMEDATA['gw'][1]
                
                InputConnection = servInput.InputBegan:Connect(function(kc) 
                    kc = kc.KeyCode
                    local key = keys[kc]
                    if (key) then
                        twn(key, {BackgroundColor3 = ColEnabled})
                    end
                end)
                
                InputConnection = servInput.InputEnded:Connect(function(kc) 
                    kc = kc.KeyCode
                    local key = keys[kc]
                    if (key) then
                        twn(key, {BackgroundColor3 = ColNorm})
                    end
                end)
            end)
            r_keystrokes:Connect('Disabled',function() 
                kmframe:Destroy()
                
                if (KSDrag) then KSDrag:Disconnect() KSDrag = nil end 
            end)
        end
        -- Unfocused GPU
        do 
            local FocusedConnection
            local UnfocusedConnection 
            
            r_ugpu:Connect('Enabled',function() 
                
                if (isrbxactive and isrbxactive() == false) then
                    servRun:Set3dRenderingEnabled(false)
                end
                
                
                FocusedConnection = servInput.WindowFocused:Connect(function() 
                    servRun:Set3dRenderingEnabled(true)
                end)
                UnfocusedConnection = servInput.WindowFocusReleased:Connect(function() 
                    servRun:Set3dRenderingEnabled(false)
                end)
                
            end)
            r_ugpu:Connect('Disabled',function() 
                if (FocusedConnection) then
                    FocusedConnection:Disconnect()
                    FocusedConnection = nil
                    UnfocusedConnection:Disconnect()
                    UnfocusedConnection = nil
                end
            end)
        end
        -- Zoom
        do 
            local s_Amount = r_zoom:addSlider('Zoom amount',{min=0,max=140,cur=30,step=0.1},true):setTooltip('The amount to zoom in by')
            local s_Looped = r_zoom:addToggle('Looped'):setTooltip('Loop changes FOV. Useful for some games that change it every frame')
            local s_Key = r_zoom:AddHotkey('Toggle key'):setTooltip('Toggles zoom without requiring a module disable / enable')
            
            local Key = s_Key:getValue()
            s_Key:Connect('HotkeySet',function(k) 
                Key = k 
                r_zoom:Reset()
            end)
            
            
            local Toggled
            local KeyCon
            
            local oldfov = clientCamera and clientCamera.FieldOfView or 70
            r_zoom:Connect('Enabled',function() 
                dnec(clientCamera:GetPropertyChangedSignal('FieldOfView'),'cam_fov')
                
                local v = 70 - (s_Amount:getValue()*.5)
                
                if (Key) then
                    
                    s_Amount:Connect('Changed',function(j) 
                        v = 70 - (j*.5)
                        if (Toggled) then 
                            clientCamera.FieldOfView = v
                        end
                    end)
                    
                    
                    Toggled = false
                    KeyCon = servInput.InputBegan:Connect(function(io, gpe) 
                        if (gpe == false and io.KeyCode == Key) then
                            Toggled = not Toggled
                            if (Toggled) then
                                if (s_Looped:isEnabled()) then
                                    servRun:BindToRenderStep('RL-FOV',2000,function() 
                                        clientCamera.FieldOfView = v
                                    end)
                                else
                                    twn(clientCamera, {FieldOfView = v}, true)
                                end
                            else
                                twn(clientCamera, {FieldOfView = oldfov}, true)
                                
                                
                                servRun:UnbindFromRenderStep('RL-FOV')
                            end
                        end
                    end)
                else
                    s_Amount:Connect('Changed',function(j) 
                        v = 70 - (j*.5)
                        clientCamera.FieldOfView = v
                    end)
                    
                    if (s_Looped:isEnabled()) then
                        servRun:BindToRenderStep('RL-FOV',2000,function() 
                            clientCamera.FieldOfView = v
                        end)
                    else
                        clientCamera.FieldOfView = v
                    end
                end
            end)
                
                
            r_zoom:Connect('Disabled',function()
                s_Amount:Connect('Changed',nil)
                servRun:UnbindFromRenderStep('RL-FOV')
                
                clientCamera.FieldOfView = oldfov
                enec('cam_fov')
                
                if (KeyCon) then KeyCon:Disconnect() KeyCon = nil end
            end)

        end
        
        r_crosshair:setTooltip('Enables a crosshair overlay made in Drawing. Also has extra features for Aimbot')
        r_esp:setTooltip('Activates ESP for other players. Currently is in beta, may glitch out, but should be way more stable than before.')
        r_freecam:setTooltip('Frees up your camera, letting you fly it anywhere. Useful for spying on others. <i>Doesn\'t work on games with custom camera systems</i>')
        r_fullbright:setTooltip('Makes the world insanely bright. Useful for games with fog effects, like Lumber Tycoon 2 or Rake. <i>May not work with every game</i>')
        r_keystrokes:setTooltip('Enables an overlay with your movement keys. Currently unfinished')
        r_ugpu:setTooltip('Disables 3d rendering when the window loses focus, saving GPU processing time')
        r_zoom:setTooltip('Zooms in your camera. <i>May not work with every game</i>')
    end
    local m_ui = ui:newMenu('UI') do 
        local u_jeff = m_ui:addMod('Jeff')
        local u_modlist = m_ui:addMod('Mod list')
        local u_plr = m_ui:addMod('Player notifications')
        local u_theme = m_ui:addMod('Theme',nil,true)
        
        -- jeff 
        do 
            local _
            u_jeff:Connect('Toggled', function(t) 
                if (t) then
                    _ = instNew('ImageLabel')
                    _.Size = dimOffset(250, 250)
                    _.BackgroundTransparency = 1
                    _.Position = dimNew(1, -250, 1, 0)
                    _.Image = 'rbxassetid://8723094657'
                    _.ResampleMode = 'Pixelated'
                    _.Parent = ui:GetScreen()
                    
                    ctwn(_, {Position = dimNew(1, -250, 1, -130)}, 25)
                else
                    _:Destroy()
                end
                
            end)
        end
        -- plr
        do 
            local rfriends = u_plr:addToggle('Roblox friends only'):setTooltip('Only send notifications if they are your roblox friend')
            local sound = u_plr:addToggle('Play sound'):setTooltip('Play the notif sound'):Enable()
            
            local h = true
            sound:Connect('Toggled',function(t)h=t;end)
            
            local join
            local leave 
            
            u_plr:Connect('Enabled',function() 
                join = servPlayers.PlayerAdded:Connect(function(p) 
                    local display, name = p.DisplayName, p.Name
                    
                    local title,msg,duration,sound do
                        title = clientPlayer:IsFriendsWith(p.UserId) and 'Friend joined' or 'Player joined'
                        msg = (display and display ~= name and 
                            ('%s (%s) has joined the server'):format(display, name)) or 
                            ('%s has joined the server'):format(name)
                    
                        duration = 2.5
                        sound = h and 'high' or 'none'
                    end
                    
                    ui:Notify(
                        title,
                        msg,
                        duration,
                        sound
                    )
                    
                    
                end)
                leave = servPlayers.PlayerRemoving:Connect(function(p) 
                    local display, name = p.DisplayName, p.Name
                    
                    local title,msg,duration,sound do
                        title = clientPlayer:IsFriendsWith(p.UserId) and 'Friend left' or 'Player left'
                        msg = (display and display ~= name and 
                            ('%s (%s) has left the server'):format(display, name)) or 
                            ('%s has left the server'):format(name)
                    
                        duration = 2.5
                        sound = h and 'low' or 'none'
                    end
                    
                    ui:Notify(
                        title,
                        msg,
                        duration,
                        sound
                    )
                end)
            end)
            u_plr:Connect('Disabled',function() 
                join:Disconnect()
                leave:Disconnect()
            end)
        end
        -- modlist
        do 
            local corner = u_modlist:addDropdown('Corner'):setTooltip('The corner the modlist is in')
            corner:addOption('Top left'):setTooltip('Sets the modlist to be at the top left')
            corner:addOption('Top right'):setTooltip('Sets the modlist to be at the top right')
            corner:addOption('Bottom left'):setTooltip('Sets the modlist to be at the bottom left; default option'):Select()
            corner:addOption('Bottom right'):setTooltip('Sets the modlist to be at the bottom right')
            
            
            local _ = ui:manageml()
            local uiframe = _[1]
            local uilist = _[2]
            local uititle = _[3]
            
            corner:Connect('Changed',function() 
                u_modlist:Reset()
            end)
            
            u_modlist:Connect('Enabled',function() 
                local s = corner:GetSelection()
                
                
                if (s == 'Top left') then
                    uiframe.Position = dimScale(0, 0)
                    uiframe.AnchorPoint = vec2(0, 0)
                    
                    uilist.HorizontalAlignment = 'Left'
                    uilist.VerticalAlignment = 'Top'
                    
                    ui:manageml(-100, 10, 'Left', 'PaddingLeft')
                    
                elseif (s == 'Top right') then
                    uiframe.Position = dimScale(1, 0)
                    uiframe.AnchorPoint = vec2(1, 0)
                    
                    uilist.HorizontalAlignment = 'Right'
                    uilist.VerticalAlignment = 'Top'
                    
                    ui:manageml(-100, 10, 'Right', 'PaddingRight')
                elseif (s == 'Bottom left') then
                    uiframe.Position = dimScale(0, 1)
                    uiframe.AnchorPoint = vec2(0, 1)
                    
                    uilist.HorizontalAlignment = 'Left'
                    uilist.VerticalAlignment = 'Bottom'
                    
                    ui:manageml(-100, 10, 'Left', 'PaddingLeft')
                elseif (s == 'Bottom right') then
                    uiframe.Position = dimScale(1, 1)
                    uiframe.AnchorPoint = vec2(1, 1)
                    
                    uilist.HorizontalAlignment = 'Right'
                    uilist.VerticalAlignment = 'Bottom'
                    
                    ui:manageml(-100, 10, 'Right', 'PaddingRight')
                end
                
                
                uiframe.Visible = true
            end)
            
            u_modlist:Connect('Disabled',function() 
                uiframe.Visible = false
            end)
            
            
            -- https://cdn.discordapp.com/attachments/910740525785706521/940869118071046194/you_should-5-1-4_001.mp4
        end
        u_modlist:Enable()
        -- theme
        do 
            
            local s_theme = u_theme:addDropdown('Theme'):setTooltip('The preset theme to use. If you want to make your own then edit the config')
            local s_save = u_theme:AddButton('Save'):setTooltip('Saves the selected theme to the theme config. Requires a restart to load the theme')
            local s_apply = u_theme:AddButton('Apply'):setTooltip('Saves the selected theme to the theme config. Automatically restarts')
            
            local themedata 
            
            s_theme:Connect('Changed', function(o) 
                spawn(function()
                    themedata = nil
                                
                    local worked = pcall(function()
                        themedata = game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/themes/'..o..'.jsonc')
                    end)
                    
                    if (not worked) then
                        ui:Notify('Oops','Got an error while loading this theme. It may have been removed or modified.', 5, 'warn', true)
                    end
                end)
            end)
            
            s_save:Connect('Clicked',function()
                writefile('REDLINE/theme.jsonc', themedata)
            end)
            s_apply:Connect('Clicked',function()
                writefile('REDLINE/theme.jsonc', themedata)
                ui:Destroy()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/loader.lua'))()
            end)
            
            spawn(function()
                local themes = game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/themes/themelist.txt')
                themes = themes:split(']')
                for i = 1, #themes do
                    local a = themes[i]
                    local b = a:match('([^|]+)|')
                    local c = a:match('|(.+)')
                    
                    local _ = s_theme:addOption(b):setTooltip(c)
                    if ( i == 1 ) then _:Select() end
                end
            end)
        end
        
        
        u_jeff:setTooltip('🗿🗿🗿')
        u_modlist:setTooltip('Displays what modules you currently have enabled in a list')
        u_plr:setTooltip('Get notifications whenever a player joins / leaves the server')
        u_theme:setTooltip('Lets you choose a UI theme. <b>This "mod" is only temporary and will be replaced by a separate window for UI theming soon!</b>')
    end
    local m_server = ui:newMenu('Server') do 
        local s_autohop = m_server:addMod('AutoHop'..betatxt)
        local s_autorec = m_server:addMod('AutoReconnect'..betatxt)
        local s_hop = m_server:addMod('Server hop'..betatxt, 'Button')
        local s_priv = m_server:addMod('Private server'..betatxt,'Button')
        local s_rejoin = m_server:addMod('Rejoin', 'Button')
        
        -- Autohop
        do 
            local MsgChangedCon
            s_autorec:Connect('Enabled',function() 
                local kicktime = 0
                
                MsgChangedCon = servGui.ErrorMessageChanged:Connect(function() 
                    -- Debounce cause messagechanged gets fired multiple times for some reason
                    local curtime = tick()
                    if (curtime - kicktime < 10) then
                        return
                    end
                    kicktime = tick()
                    
                    -- Notify
                    wait(1)
                    servGui:ClearError()
                    ui:Notify('Auto Hop','Auto hopping in a few seconds, hang tight', 5, 'high')
                    wait(1)
                    do 
                        s_hop:Click()
                        
                    end
                end)
            end)
            s_autorec:Connect('Disabled',function() 
                if (MsgChangedCon) then 
                    MsgChangedCon:Disconnect()
                    MsgChangedCon = nil
                end
            end)
        end
        
        -- Auto recon
        do 
            local MsgChangedCon
            s_autorec:Connect('Enabled',function() 
                local kicktime = 0
                
                MsgChangedCon = servGui.ErrorMessageChanged:Connect(function() 
                    -- Debounce cause messagechanged gets fired multiple times for some reason
                    local curtime = tick()
                    if (curtime - kicktime < 10) then
                        return
                    end
                    kicktime = tick()
                    
                    -- Notify
                    wait(1)
                    servGui:ClearError()
                    ui:Notify('Auto Reconnect','Auto reconnecting in a few seconds, hang tight', 5, 'high')
                    wait(1)
                    
                    -- Player kicked, rejoin
                    if (#servPlayers:GetPlayers() <= 1) then
                        servTeleport:Teleport(game.PlaceId, clientPlayer)
                    else
                        servTeleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, clientPlayer)
                    end
                end)
            end)
            s_autorec:Connect('Disabled',function() 
                if (MsgChangedCon) then 
                    MsgChangedCon:Disconnect()
                    MsgChangedCon = nil
                end
            end)
        end
        
        -- Server hop
        do 
            s_hop:Connect('Clicked',function() 
                spawn(function()
                    
                    local CurPlaceId = game.PlaceId
                    local CurJobId = game.JobId
                    
                    local APIURL = ('https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100'):format(CurPlaceId)
                    
                    
                    do
                        do
                            local Data = servHttp:JSONDecode(game:HttpGet(APIURL))
                            local Servers = Data.data
                            local TargetServers = {}
                            
                            if (#Servers == 0) then
                                ui:Notify('Server hop','Roblox returned that there are no existing servers. This game is likely not compatible with Server hop',5, 'low')
                                return 
                            end
                            
                            local j = 0
                            for i = 1, 200 do 
                                if (j > 25) then break end
                                
                                local Server = Servers[mathRand(1,#Servers)]
                                if (Server.playing == Server.maxPlayers or Server.id == CurJobId) then continue end
                                tabInsert(TargetServers, Server.id)
                                j += 1
                            end
                            
                            if (#TargetServers == 0) then
                                -- search more here (adding that later)
                                ui:Notify('Server hop','Couldn\'t find a valid server; you may already be in the smallest one. Try again later',5, 'low')
                                
                            else
                                local serv = TargetServers[mathRand(1,#TargetServers)]
                                servTeleport:TeleportToPlaceInstance(CurPlaceId, serv, clientPlayer)
                                ui:Notify('Server hop','Teleporting to a new server, wait a sec',5, 'high')
                            end
                        end
                    end
                end)
            end)
        end
        
        -- Private server
        do 
            s_priv:Connect('Clicked',function() 
                spawn(function()
                    print(pcall(function()
                    
                    local sc = ui:GetScreen()
                    local p_Backframe
                    local p_Header
                    local p_Window
                    local p_Progress1
                    local p_Progress2
                    local p_Status
                    
                    do 
                        p_Backframe = instNew('Frame')
                        p_Backframe.BackgroundTransparency = 1
                        p_Backframe.Size = dimScale(0,0)
                        p_Backframe.Position = dimScale(0.5, 0.5)
                        p_Backframe.AnchorPoint = vec2(0.5, 0.5)
                        p_Backframe.ZIndex = 300
                        p_Backframe.Parent = sc
                                        
                        p_Header = instNew('TextLabel')
                        p_Header.BackgroundColor3 = RLTHEMEDATA['bm'][1]
                        p_Header.BackgroundTransparency = RLTHEMEDATA['bm'][2]
                        p_Header.BorderSizePixel = 0
                        p_Header.Font = RLTHEMEFONT
                        p_Header.RichText = true
                        p_Header.Size = dimNew(1, 0, 0,20)
                        p_Header.Text = 'Private server'
                        p_Header.TextColor3 = RLTHEMEDATA['tm'][1]
                        p_Header.TextSize = 19
                        p_Header.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                        p_Header.TextStrokeTransparency = 0
                        p_Header.TextXAlignment = 'Center'
                        p_Header.ZIndex = 301
                        p_Header.Parent = p_Backframe
                        
                        stroke(p_Header, 'Border')
                        
                        p_Window = instNew('Frame')
                        p_Window.BackgroundColor3 = RLTHEMEDATA['gw'][1]
                        p_Window.BackgroundTransparency = RLTHEMEDATA['gw'][2]
                        p_Window.BorderSizePixel = 0
                        p_Window.Position = dimOffset(0, 20)
                        p_Window.Size = dimNew(1, 0, 1, -20)
                        p_Window.ZIndex = 300
                        p_Window.Parent = p_Backframe
                        
                        p_Progress1 = instNew('Frame')
                        p_Progress1.AnchorPoint = vec2(0.5, 0)
                        p_Progress1.BackgroundTransparency = 1
                        p_Progress1.Position = dimNew(0.5, 0, 0.1, 0)
                        p_Progress1.Size = dimNew(1, -10, 0, 20)
                        p_Progress1.ZIndex = 301
                        p_Progress1.Parent = p_Window
                        
                        p_Progress2 = instNew('Frame')
                        p_Progress2.BackgroundColor3 = RLTHEMEDATA['ge'][1]
                        p_Progress2.BackgroundTransparency = 0.5
                        p_Progress2.BorderSizePixel = 0
                        p_Progress2.Size = dimScale(0,1)
                        p_Progress2.ZIndex = 302
                        p_Progress2.Parent = p_Progress1
                        
                        stroke(p_Progress1)
                        
                        p_Status = instNew('TextLabel')
                        p_Status.AnchorPoint = vec2(0.5, 1)
                        p_Status.BackgroundTransparency = 1
                        p_Status.Font = RLTHEMEFONT
                        p_Status.Position = dimNew(0.5, 0, 1, 0)
                        p_Status.RichText = true
                        p_Status.Size = dimNew(1, 0, 0, 40)
                        p_Status.Text = '...'
                        p_Status.TextColor3 = RLTHEMEDATA['tm'][1]
                        p_Status.TextSize = 17
                        p_Status.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                        p_Status.TextStrokeTransparency = 0
                        p_Status.TextWrapped = true
                        p_Status.TextXAlignment = 'Center'
                        p_Status.TextYAlignment = 'Center'
                        p_Status.Visible = true 
                        p_Status.ZIndex = 300
                        p_Status.Parent = p_Window
                        
                        stroke(p_Window, 'Border')
                        
                        twn(p_Backframe, {Size = dimScale(0.2, 0.1)}, true)
                    end
                    
                    
                    local CurPlaceId = game.PlaceId
                    local CurJobId = game.JobId
                    
                    local APIURL = ('https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100&cursor='):format(CurPlaceId)
                    
                    local PrevCursor = ''
                    local CurrentServerCount = 0
                    local EstimatedServerCount = 1
                    local Loop = true
                    
                    local function SafetyCheck(jsondata) 
                        do
                            local Worked = true
                            
                            if (jsondata) then
                                -- If we got a response check to see if decoding works
                                Worked = pcall(function() jsondata = servHttp:JSONDecode(jsondata) end)
                                
                                if (Worked) then
                                    -- Everything worked
                                    return jsondata, 0
                                else
                                    -- Couldn't decode it, might be a server error / roblox api is down / something else
                                    return nil, 1
                                end
                            else
                                -- Didn't get any response, this shouldn't ever appear and is just a failsafe
                                return nil, 2
                            end
                        end
                    end
                    
                    do
                        -- First step: estimate the server count (used for the progress bar)
                        do
                            p_Status.Text = 'Estimating server count [1/2]'
                            
                            -- First get the universe id of the current game, it's needed for another api call
                            local UniverseData, UniverseStatus = game:HttpGet('https://api.roblox.com/universes/get-universe-containing-place?placeid='..CurPlaceId)
                            UniverseData, UniverseStatus = SafetyCheck(UniverseData)
                            -- Check if the universeid call worked
                            if (UniverseData and UniverseData['Code'] == nil) then
                                local UniverseId = UniverseData['UniverseId']
                                -- Got a valid UniverseId, now get the server and player count
                                p_Status.Text = 'Estimating server count [2/2]'
                                
                                
                                local GameStats, GameStatus = game:HttpGet('https://games.roblox.com/v1/games?universeIds='..UniverseId)
                                GameStats, GameStatus = SafetyCheck(GameStats)
                                
                                if (GameStats and GameStats['errors'] == nil) then
                                    local CurrentPlaying = GameStats['data'][1]['playing']
                                    local MaxServers = GameStats['data'][1]['maxPlayers']
                                    
                                    EstimatedServerCount = mathFloor(((CurrentPlaying / MaxServers)*1.01)+1)
                                    --print(EstimatedServerCount)
                                else
                                    Loop = false
                                
                                    p_Status.Text = (
                                        UniverseStatus == 1 and '[GameStats] Failed to JSONDecode API response' or 
                                        UniverseStatus == 2 and '[GameStats] Never received API response' or 
                                        '[GameStats] Server responded with error code '..GameStats['errors'][1]['code']
                                    )
                                    ui:Notify('Oops','Something went wrong when making an API call. Try again later', 5, 'low')
                                end
                            else
                                Loop = false
                                
                                p_Status.Text = (
                                    UniverseStatus == 1 and '[UniverseId] Failed to JSONDecode API response' or 
                                    UniverseStatus == 2 and '[UniverseId] Never received API response' or 
                                    '[UniverseId] Server responded with error code '..UniverseData['Code']
                                )
                                ui:Notify('Oops','Something went wrong when making an API call. Try again later', 5, 'low')
                            end
                            
                        end
                        
                        -- Second step: get the actual servers
                        do
                            local a = 0
                            while Loop do
                                wait(0.1 + (mathRand(10, 30)*0.01))
                                -- Get list of servers via api
                                local CurrentData
                                local OldData
                                do
                                    --p_Status.Text = ('Fetching more servers... (%s / ~%s)'):format(CurrentServerCount, EstimatedServerCount)
                                    -- Get server list
                                    
                                    CurrentData, CurrentStatus = game:HttpGet(APIURL..PrevCursor)
                                    -- Complete safety checks
                                    OldData = CurrentData
                                    CurrentData, CurrentStatus = SafetyCheck(CurrentData)
                                    
                                    if (CurrentData) then
                                        -- Should probably check for ['errors'] here, but it doesn't matter
                                        CurrentServerCount += #CurrentData.data
                                    else
                                        p_Status.Text = (CurrentStatus == 1 and '[Servers] Failed to JSONDecode API response' or '[Servers] Never received API response')
                                        break
                                    end
                                end
                                -- Wait to update the status
                                --wait()
                                
                                -- Do page cursor checks
                                do
                                    -- Store the new page cursor                                
                                    PrevCursor = CurrentData.nextPageCursor
                                    -- Check to see if there actually is a new cursor
                                    if (PrevCursor) then
                                        -- There are more servers, so increase progress bar and continue the loop
                                        p_Progress2.Size = dimScale((CurrentServerCount/EstimatedServerCount), 1)
                                        p_Status.Text = ('Fetching more servers... (%s / ~%s)'):format(CurrentServerCount, EstimatedServerCount)
                                        continue
                                    else
                                        p_Progress2.Size = dimScale(1, 1)
                                        -- There are no more servers (on the last page), so handle stuff                                 
                                        -- Get the servers for this page and make a table that will hold a few matching servers
                                        wait(0.3)
                                        writefile('thegggj.json',OldData)
                                        local Servers = CurrentData.data
                                        for i,v in ipairs(Servers) do print(v.playing,v.maxPlayers) end
                                        local TargetServers = {}
                                        
                                        -- Save the 40 smallest servers
                                        for i = 0, 39 do 
                                            tabInsert(TargetServers, Servers[#Servers-i])
                                        end
                                        
                                        -- Store a success variable (used to identify if it couldn't teleport to / find a server)
                                        local Worked = false
                                        for i = 1, 100 do 
                                            -- Increase progress bar to show progress
                                            --p_Progress2.Size = dimScale(0.8 + (i/100), 1)
                                            -- Update text
                                            p_Status.Text = ('Checking for a valid server (%s out of 100 tries)'):format(i)
                                            -- Yield to display text and progress
                                            wait()
                                            
                                            -- Get a random server (this is why there are 25 attempts)
                                            local Server = TargetServers[mathRand(1, #TargetServers)]
                                            if (Server.id == CurJobId or Server.playing == Server.maxPlayers) then
                                                -- If the chosen server is the current one or if its full then continue
                                                continue
                                            else
                                                -- Otherwise teleport to this server
                                                p_Status.Text = 'Got a matching server! Teleporting...'
                                                Worked = true
                                                wait(0.5)
                                                servTeleport:TeleportToPlaceInstance(CurPlaceId, Server.id, clientPlayer)
                                                Loop = false
                                                break
                                            end
                                        end
                                        -- Check if it failed to teleport and notify the player
                                        if (Worked == false) then
                                            p_Status.Text = 'Couldn\'t find any valid servers'
                                            ui:Notify('Oops','Couldn\'t find a valid server; you may already be in the smallest one. Try again in a sec',5, 'low')
                                            break
                                        end
                                    end
                                end
                            end
                        end
                    end
                    -- Out of loop, wait to hide the window
                    wait(3)
                    
                    p_Header.Text = ''
                    p_Status.Text = ''
                    twn(p_Progress2, {Size = dimScale(0, 1)}, true)
                    wait(0.1)
                    twn(p_Backframe, {Size = dimScale(0, 0)}, true).Completed:Wait()
                    p_Backframe:Destroy()
                    
                    -- Done
                end))
                end)
            end)
        end
        
        -- Rejoin
        do
            s_rejoin:Connect('Clicked',function() 
                if #servPlayers:GetPlayers() <= 1 then
                    clientPlayer:Kick('\nRejoining, one second...')
                    wait(0.3)
                    servTeleport:Teleport(game.PlaceId, clientPlayer)
                else
                    servTeleport:TeleportToPlaceInstance(game.PlaceId, game.JobId, clientPlayer)
                end
            end)
        end
        
        s_autohop:setTooltip('Automatically server hops whenever you get disconnected. Useful for server ban evading')
        s_autorec:setTooltip('Automatically rejoins whenever you get disconnected')
        s_hop:setTooltip('Teleports you to a random server')
        s_priv:setTooltip('Teleports you to one of the smallest servers possible. May take a bit of time to search, but atleast it has a snazzy progress bar')
        s_rejoin:setTooltip('Rejoins you into the current server. <b>Don\'t rejoin too many times, or you\'ll get error 268</b>')
    end
    do
        --[[
        local w_Search = ui:CreateWidget('Search', dimNew(1,-325,1,-225), vec2(300, 50), true) do 
            
        end]]
    end
end
_G.RLLOADED = true

if (game.PlaceId == 292439477 or game.PlaceId == 3233893879) then
    ui:Notify('Warning','Redline is not designed for games with custom character systems.',5,'warn',true)
    wait(3)
    ui:Notify('Warning','It may not function properly, or even function at all.',5,'warn',true)
    wait(3) 
end

do
    wait(1)
    local sound = instNew('Sound')
    sound.SoundId = 'rbxassetid://9009663963'--'rbxassetid://8781250986'
    sound.Volume = 1
    sound.TimePosition = 0.15
    sound.Parent = ui:GetScreen()
    sound.Playing = true
    do 
        local center = workspace.CurrentCamera.ViewportSize/2
        
        local col = RLTHEMEDATA['ge'][1]
        local dn = function() 
            local _ = drawNew('Line')
            _.Visible = true
            _.Color = col
            _.Thickness = 4
            return _
        end
        local lines = {}
        
        
        local SizeAnimation 
        local PositionAnim
        
        SizeAnimation = servRun.RenderStepped:Connect(function(dt) 
            dt *= 9
            for i,v in ipairs(lines) do 
                local obj = v[1]
                obj.To = obj.To:lerp(v[2], dt)
            end
        end)
        do
            local up = center + vec2(0, -200)
            local down = center + vec2(0, 200)
        
            do
                local _ = dn()
                _.From = up
                _.To = up
                tabInsert(lines, {_, center + vec2(-200, 0), 0})
            end
            do
                local _ = dn()
                _.From = up
                _.To = up
                tabInsert(lines, {_, center + vec2(-66, 45), 0})
            end
            do
                local _ = dn()
                _.From = up
                _.To = up
                tabInsert(lines, {_, center + vec2(66, 45), 0})
            end
            do
                local _ = dn()
                _.From = up
                _.To = up
                tabInsert(lines, {_, center + vec2(200, 0), 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(-200, 0)
                _.To = _.From
                tabInsert(lines, {_, center + vec2(0, 66), 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(200, 0)
                _.To = _.From
                tabInsert(lines, {_, center + vec2(0, 66), 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(-200, 0)
                _.To = _.From
                tabInsert(lines, {_, down, 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(-66, 44)
                _.To = _.From
                tabInsert(lines, {_, down, 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(66, 44)
                _.To = _.From
                tabInsert(lines, {_, down, 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(200, 0)
                _.To = _.From
                tabInsert(lines, {_, down, 0})
            end
        end
        wait(1)
        SizeAnimation:Disconnect()
        wait(1)
        
        local y = 0
        PositionAnim = servRun.RenderStepped:Connect(function(dt) 
            local _1 = dt * 15
            local _2 = _1 * 15
        
            y += _2
            for i,v in ipairs(lines) do
                local obj = v[1]
                obj.From += vec2(0, y)*_1
                obj.To += vec2(0, y)*_1
        
                obj.Transparency -= dt*2
            end
        end)
        wait(0.5)
        PositionAnim:Disconnect()
        for i,v in ipairs(lines) do 
            v[1]:Remove()
        end
        
        lines = nil
    end
    sound:Destroy()
        
    do
        local bf = ui:GetModframe()
        
        local prism = instNew('ImageLabel')
        prism.AnchorPoint = vec2(0, 0)
        prism.BackgroundTransparency = 1
        prism.Image = 'rbxassetid://8951023311'
        prism.ImageColor3 = RLTHEMEDATA['ge'][1]
        prism.Position = dimScale(0.5, 0.5)
        prism.Size = dimOffset(0,0)
        
        local redline = instNew('ImageLabel')
        redline.BackgroundTransparency = 1
        redline.Image = 'rbxassetid://8950999035'
        redline.ImageColor3 = RLTHEMEDATA['tm'][1]
        redline.AnchorPoint = vec2(0, 0)
        redline.Position = dimScale(0.5, 0.5)
        redline.Size = dimScale(0.8, 0.8)

        redline.Parent = bf
        prism.Parent = bf
    

        redline.AnchorPoint = vec2(0,0)
        prism.AnchorPoint = vec2(0,0)
        
        redline.Size = dimOffset(150, 150)
        prism.Size = dimOffset(75, 75) 
        
        prism.Position = dimOffset(25, -105)
        redline.Position = dimOffset(90, -155)
        
        twn(prism, {Position = dimOffset(25, 35)},true)
        twn(redline, {Position = dimOffset(90, -5)},true)
    end
    
end

_G.RLTHEME = nil
if (_G.RLLOADERROR ~= 0) then
    local err = _G.RLLOADERROR
    if (err == 1) then
        ui:Notify('Redline got an error when loading','Couldn\'t load theme properly. Check console for more info', 5, 'warn', true)
        print('(Error code 1)')
        print(
            'The JSON decoder recognized the config as invalid JSON.'..
            '\nMake sure that the config is formatted properly.'..
            '\nIf you cannot fix it then delete the file (workspace/REDLINE/theme.jsonc) and reload Redline.'
        )
        
    elseif (err == 2) then
        ui:Notify('Redline got an error when loading','Couldn\'t load theme properly. Check console for more info', 5, 'warn', true)
        print('(Error code 2)')
        print(
            'An unknown error occured while loading the theme config.'..
            '\nMake sure that the theme config\'s values are formatted properly.'..
            '\nIf you cannot fix it then delete the file (workspace/REDLINE/theme.jsonc) and reload Redline.'
        )
    end
else
    _G.RLLOADERROR = nil
    
    ui:Notify(('Redline %s loaded'):format(REDLINEVER), ('Press RightShift to begin'), 5, 'high')
end


local pg do 
    pg = nil or 
        (type(syn) == 'table' and syn.queue_on_teleport) or 
        (type(fluxus) == 'table' and fluxus.queue_on_teleport) or 
        (queue_on_teleport)
end 

if (isfile('REDLINE/Queued.txt')) then
    _G.RLQUEUED = readfile('REDLINE/Queued.txt'):match('true') ~= nil
else
    _G.RLQUEUED = true
    writefile('REDLINE/Queued.txt', 'true')
end

if (pg and _G.RLQUEUED == false) then
    pg[[if(readfile('REDLINE/Queued.txt') == 'true')then loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/loader.lua'))()end]]
    writefile('REDLINE/Queued.txt', 'true')
    _G.RLQUEUED = true
end
_G.RLNOTIF = function(...) 
    return ui:Notify(...)
end

-- 0.6.4
--[[
! Sorry about the lack of updates
- Added Antiplayer mod
- Changed a few tooltips
- Changed the name and description of the respawn mod
- Fixed aimbot smoothness when the method is set to Mouse being inverted
- Removed glide module since it was useless
- Trying to execute redline when its already loaded now sends a notification instead of printing
]]--
