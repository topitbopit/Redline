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


---@diagnostic disable:undefined-global
---@diagnostic disable:undefined-field

if (_G.RLLOADED) then
    if (printconsole) then 
        printconsole('Already loaded Redline', 255, 64, 64)
        printconsole('Destroy the current script by pressing [End]', 192, 192, 255)
        return
    else
        warn('Already loaded Redline\nDestroy the current script by pressing [End]')
        return
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
local REDLINEVER = 'v0.6.1'


local IndentLevel1 = 8
local IndentLevel2 = 14
local IndentLevel3 = 22
local RightIndent = 14

-- { Wait for load } --
if not game:IsLoaded() then game.Loaded:Wait() end

-- { Microops } --

-- Services
local serv_ctx     = game:GetService('ContextActionService')
local serv_gui     = game:GetService('GuiService')
local serv_http    = game:GetService('HttpService')
local serv_net     = game:GetService('NetworkClient')
local serv_players = game:GetService('Players')
local serv_run     = game:GetService('RunService')
local serv_tps     = game:GetService('TeleportService')
local serv_twn     = game:GetService('TweenService')
local serv_uinput  = game:GetService('UserInputService')
local serv_vim     = game:GetService('VirtualInputManager')

-- Colors
local c_rgb,c_hsv,c_new = Color3.fromRGB, Color3.fromHSV, Color3.new
-- UDim2
local dim_off, dim_sca, dim_new = UDim2.fromOffset, UDim2.fromScale, UDim2.new
-- Instances
local inst_new = Instance.new
local draw_new = Drawing.new
-- Vectors
local vec3, vec2 = Vector3.new, Vector2.new
-- CFrames
local cfnew = CFrame.new
-- Task
local wait, delay, spawn = task.wait, task.delay, task.spawn
-- Math
local mrandom = math.random
local mfloor = math.floor
local mclamp = math.clamp
-- Table
local tinsert,tremove,tclear,tfind = table.insert, table.remove, table.clear, table.find
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
    serv_uinput.WindowFocused:Connect(function() 
        active = true 
    end)
    serv_uinput.WindowFocusReleased:Connect(function() 
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
    local stuff = serv_http:JSONDecode(json)
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
                c_rgb(Color1[1],Color1[2],Color1[3]);
                Transpar;
                IsGradient;
                Color2 and c_rgb(Color2[1],Color2[2],Color2[3]);
                
                
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
        RLTHEMEDATA['go'][1]   = RLTHEMEDATA['go'][1]  or c_rgb(075, 075, 080); -- outline color
        RLTHEMEDATA['gs'][1]   = RLTHEMEDATA['gs'][1]  or c_rgb(005, 005, 010); -- shadow
        RLTHEMEDATA['gw'][1]   = RLTHEMEDATA['gw'][1]  or c_rgb(023, 022, 027); -- window background
        RLTHEMEDATA['ge'][1]   = RLTHEMEDATA['ge'][1]  or c_rgb(225, 035, 061); -- enabled
        -- backgrounds
        RLTHEMEDATA['bm'][1]   = RLTHEMEDATA['bm'][1]  or c_rgb(035, 035, 040); -- header background
        RLTHEMEDATA['bo'][1]   = RLTHEMEDATA['bo'][1]  or c_rgb(030, 030, 035); -- object background
        RLTHEMEDATA['bs'][1]   = RLTHEMEDATA['bs'][1]  or c_rgb(025, 025, 030); -- setting background
        RLTHEMEDATA['bd'][1]   = RLTHEMEDATA['bd'][1]  or c_rgb(020, 020, 025); -- dropdown background
        -- backgrounds selected
        RLTHEMEDATA['hm'][1]   = RLTHEMEDATA['hm'][1]  or c_rgb(038, 038, 043); -- header hovering
        RLTHEMEDATA['ho'][1]   = RLTHEMEDATA['ho'][1] or c_rgb(033, 033, 038); -- object hovering
        RLTHEMEDATA['hs'][1]   = RLTHEMEDATA['hs'][1] or c_rgb(028, 028, 033); -- setting hovering
        RLTHEMEDATA['hd'][1]   = RLTHEMEDATA['hd'][1] or c_rgb(023, 023, 028); -- dropdown hovering
        -- slider 
        RLTHEMEDATA['sf'][1]   = RLTHEMEDATA['sf'][1] or c_rgb(225, 075, 080); -- slider foreground
        RLTHEMEDATA['sb'][1]   = RLTHEMEDATA['sb'][1] or c_rgb(033, 033, 038); -- slider background
        -- text   
        RLTHEMEDATA['tm'][1]   = RLTHEMEDATA['tm'][1] or c_rgb(255, 255, 255); -- main text
        RLTHEMEDATA['to'][1]   = RLTHEMEDATA['to'][1] or c_rgb(020, 020, 025); -- outline
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
            local _ = inst_new('UIGradient')
            _.Rotation = 45
            --_.Transparency = parent.Transparency
            _.Color = g1
            _.Parent = parent
        
            return _
        end
    end
    stroke = function(parent,mode, trans) 
        local _ = inst_new('UIStroke')
        _.ApplyStrokeMode = mode or 'Contextual'
        _.Thickness = 1
        
        _.Transparency = trans or RLTHEMEDATA['go'][2]
        
        if (RLTHEMEDATA['go'][3]) then
            gradient(_) 
            _.Color = c_new(1,1,1)
        else
            _.Color = RLTHEMEDATA['go'][1]
        end
        
        _.Parent = parent
        return _
    end
    
    local info1, info2 = TweenInfo.new(0.1,10,1), TweenInfo.new(0.3,10,1)
    function twn(twn_target, twn_settings, twn_long) 
        local tween = serv_twn:Create(
            twn_target,
            twn_long and info2 or info1,
            twn_settings
        )
        tween:Play()
        return tween
    end
    function ctwn(twn_target, twn_settings, twn_dur, twn_style, twn_dir) 
        local tween = serv_twn:Create(
            twn_target,
            TweenInfo.new(twn_dur,twn_style or 10,twn_dir or 1),
            twn_settings
        )
        tween:Play()
        return tween
    end
    function getnext() 
        local a = ''
        for i = 1, 5 do a = a .. utf8.char(mrandom(50,2000)) end 
        return a 
    end
    function round(num, place) 
        return mfloor(((num+(place*.5)) / place)) * place
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
    
    local monitor_resolution = serv_gui:GetScreenResolution()
    local monitor_inset = serv_gui:GetGuiInset()
    
    -- connections
    ui_Connections['i'] = serv_uinput.InputBegan:Connect(function(io, gpe) 
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
        
        ui_Connections['r'] = serv_run.RenderStepped:Connect(function(dt) 
            if (not isrbxactive()) then return end
            
            rgbtime = (rgbtime > 1 and 0 or rgbtime)+(dt*0.1)
            RGBCOLOR = c_hsv(rgbtime,0.8,1)
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
     local w_Help
     local w_Modal
    local w_ModList
     local w_ModListLayout
     local w_ModListTitle
    local w_MouseCursor
    
    
    local ModlistPadding = {
        dim_off(-100, 0).X;
        dim_off(8, 0).X;
        Enum.TextXAlignment.Left;
        'PaddingLeft';
    } 
    
    do 
        w_Screen = inst_new('ScreenGui')
        w_Screen.IgnoreGuiInset = true
        w_Screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
        w_Screen.Name = getnext()
        pcall(function() 
            syn.protect_gui(w_Screen)
        end)
        w_Screen.DisplayOrder = 939393
        w_Screen.Parent = (gethui and gethui()) or (get_hidden_gui and get_hidden_gui()) or game.CoreGui
        
        
        w_Backframe = inst_new('Frame')
        w_Backframe.BackgroundColor3 = RLTHEMEDATA['gw'][1]
        w_Backframe.BackgroundTransparency = RLTHEMEDATA['gw'][2]
        w_Backframe.BorderSizePixel = 0
        w_Backframe.ClipsDescendants = true
        w_Backframe.Position = dim_new(0, 0, -1, 0)
        w_Backframe.Size = dim_sca(1,1)
        w_Backframe.Visible = false
        w_Backframe.Parent = w_Screen
        
        w_Modal = inst_new('TextButton')
        w_Modal.Active = false
        w_Modal.BackgroundTransparency = 1
        w_Modal.Modal = true
        w_Modal.Size = dim_off(1,1)
        w_Modal.Text = ''
        w_Modal.Parent = w_Backframe
        
        w_Help = inst_new('TextLabel')
        w_Help.AnchorPoint = vec2(1,1)
        w_Help.BackgroundTransparency = 1
        w_Help.Font = RLTHEMEFONT
        w_Help.Position = dim_sca(1,1)
        w_Help.RichText = true
        w_Help.Size = dim_off(300,300)
        w_Help.Text = ''
        w_Help.TextColor3 = RLTHEMEDATA['tm'][1]
        w_Help.TextSize = 20
        w_Help.TextStrokeColor3 = RLTHEMEDATA['to'][1]
        w_Help.TextStrokeTransparency = 0
        w_Help.TextXAlignment = 'Left'
        w_Help.TextYAlignment = 'Top'
        w_Help.Visible = false
        w_Help.ZIndex = 1
        w_Help.Parent = w_Backframe
        
        w_ModList = inst_new('Frame')
        w_ModList.AnchorPoint = vec2(0, 1)
        w_ModList.BackgroundColor3 = RLTHEMEDATA['gw'][1]
        w_ModList.BackgroundTransparency = 1
        w_ModList.BorderColor3 = RLTHEMEDATA['gs'][1]
        w_ModList.BorderMode = 'Inset'
        w_ModList.BorderSizePixel = 1
        w_ModList.Position = dim_sca(0,1)
        w_ModList.Size = dim_new(0,200,0.3,0)
        w_ModList.Visible = false
        w_ModList.Parent = w_Screen
        
        w_ModListLayout = inst_new('UIListLayout')
        w_ModListLayout.FillDirection = 'Vertical'
        w_ModListLayout.HorizontalAlignment = 'Left'
        w_ModListLayout.VerticalAlignment = 'Bottom'
        w_ModListLayout.Parent = w_ModList
        
        w_ModListTitle = inst_new('TextLabel')
        w_ModListTitle.BackgroundTransparency = 1
        w_ModListTitle.Font = RLTHEMEFONT
        w_ModListTitle.LayoutOrder = 939
        w_ModListTitle.Size = dim_new(1, 0, 0, 30)
        w_ModListTitle.Text = ' '..'Redline '..REDLINEVER..' '
        w_ModListTitle.TextColor3 = RLTHEMEDATA['tm'][1]
        w_ModListTitle.TextSize = 24
        w_ModListTitle.TextStrokeColor3 = RLTHEMEDATA['to'][1]
        w_ModListTitle.TextStrokeTransparency = RLTHEMEDATA['to'][2]
        w_ModListTitle.TextTransparency = RLTHEMEDATA['tm'][1]
        w_ModListTitle.TextXAlignment = 'Left'
        w_ModListTitle.ZIndex = 5
        w_ModListTitle.Parent = w_ModList
        
        w_TooltipHeader = inst_new('TextLabel')
        w_TooltipHeader.BackgroundColor3 = RLTHEMEDATA['bm'][1]
        w_TooltipHeader.BackgroundTransparency = RLTHEMEDATA['bm'][2]
        w_TooltipHeader.BorderSizePixel = 0
        w_TooltipHeader.Font = RLTHEMEFONT
        w_TooltipHeader.RichText = true
        w_TooltipHeader.Size = dim_off(175,20)
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
        
        w_Tooltip = inst_new('TextLabel')
        w_Tooltip.BackgroundColor3 = RLTHEMEDATA['gw'][1]
        w_Tooltip.BackgroundTransparency = RLTHEMEDATA['gw'][2]
        w_Tooltip.BorderSizePixel = 0
        w_Tooltip.Font = RLTHEMEFONT
        w_Tooltip.Position = dim_off(0, 21)
        w_Tooltip.RichText = true
        w_Tooltip.Size = dim_off(175,25)
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
        
        local __ = inst_new('UIPadding')
        __.PaddingLeft = dim_off(5, 0).X
        --__.PaddingTop = dim_off(0, 5).Y
        __.Parent = w_Tooltip
        
        w_Tooltip:GetPropertyChangedSignal('Text'):Connect(function() 
            w_Tooltip.Size = dim_off(175,25)
            local n = dim_off(0,5)
            for i = 1, 25 do 
                w_Tooltip.Size += n
                if (w_Tooltip.TextFits) then break end
            end
            w_Tooltip.Size += n
        end)
        
        w_MouseCursor = inst_new('ImageLabel')
        w_MouseCursor.BackgroundTransparency = 1
        w_MouseCursor.Image = 'rbxassetid://8845749987'
        w_MouseCursor.ImageColor3 = RLTHEMEDATA['ge'][1]
        w_MouseCursor.ImageTransparency = 1
        w_MouseCursor.Position = dim_off(150, 150)
        w_MouseCursor.Size = dim_off(24, 24)
        w_MouseCursor.Visible = true
        w_MouseCursor.ZIndex = 1500
        w_MouseCursor.Parent = w_Screen
    end
    
    function ui:manageml(x1,x2,align,paddir) 
        ModlistPadding[1] = x1 and dim_off(x1, 0).X or ModlistPadding[1]
        ModlistPadding[2] = x2 and dim_off(x2, 0).X or ModlistPadding[2]
        ModlistPadding[4] = paddir or ModlistPadding[4]
        
        if (align and align ~= ModlistPadding[3]) then
            local c = w_ModList:GetChildren()
            local _ = ModlistPadding[2]
            local __ = ModlistPadding[4]
            local ___ = __ == 'PaddingLeft' and 'PaddingRight' or __
            local ____ = dim_off(0,0).X
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
    
    
    
    ui_Connections['t'] = serv_run.RenderStepped:Connect(function() 
        local pos = serv_uinput:GetMouseLocation()
        local x,y = pos.X, pos.Y
        w_TooltipHeader.Position = dim_off(x+15, y+15)
        w_MouseCursor.Position = dim_off(x-4, y)
    end)
    
    
    local ModListEnable,ModListDisable,ModListInit,ModListModify do 
        local mods_instance = {}
        
        
        ModListEnable = function(name) 
            local b = mods_instance[name]
            
            b.TextXAlignment = ModlistPadding[3]
            b.Parent = w_ModList
            twn(b.P, {[ModlistPadding[4]] = ModlistPadding[2]},true)
            twn(b, {Size = dim_new(1, 0, 0, 24), TextTransparency = 0, TextStrokeTransparency = 0},true)
        end
        
        ModListDisable = function(name)
            local b = mods_instance[name]
            
            twn(b.P, {[ModlistPadding[4]] = ModlistPadding[1]},true)
            twn(b, {Size = dim_new(0, 0, 0, 0), TextTransparency = 1, TextStrokeTransparency = 1},true)
        end
        
        ModListModify = function(name, new) 
            mods_instance[name].Text = new
        end
        
        ModListInit = function(name) 
            local _ = inst_new('TextLabel')
            _.Size = dim_new(0, 0, 0, 0)
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
            
            tinsert(rgbinsts, {_,'TextColor3'})
            
            
            local __ = inst_new('UIPadding')
            __.Name = 'P'
            __[ModlistPadding[4]] = ModlistPadding[1]
            __.Parent = _
        end
    end
    
    -- Base class for stuff
    local base_class = {} do 
        local s1,s2 = dim_new(1,0,1,0), dim_new(0,0,1,0)
        
        
        
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
                c = serv_uinput.InputBegan:Connect(function(io,gpe)
                    
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
                                    tremove(ui_Hotkeys, i)
                                    break
                                end
                            end
                            tinsert(ui_Hotkeys, {kcv, function() 
                                self.Parent:Toggle()
                            end, n})
                        end)
                    else
                        self.Hotkey = nil    
                        label.Text = 'Hotkey: N/A'
                        
                        local n = self.Parent.Name
                        for i = 1, #ui_Hotkeys do 
                            if ui_Hotkeys[i][3] == n then
                                tremove(ui_Hotkeys, i)
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
                c = serv_uinput.InputBegan:Connect(function(io,gpe)
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

                
                cval = round(mclamp(nval, min, self.Max), self.Step)
                
                if (pval ~= cval) then
                    pval = cval
                    local form = self.StepFormat
                    
                    self.SliderFill.Position = dim_off(mfloor((cval - min) * self.Ratio), 0)
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
                
                local pos_normalized = mclamp(xval - self.SliderBg.AbsolutePosition.X, 0, self.SliderSize)
                
                cval = round((pos_normalized * self.RatioInverse)+min, self.Step)
                
                if (pval ~= cval) then
                    pval = cval
                    local form = self.StepFormat
                    
                    self.SliderFill.Position = dim_off(mfloor((cval - min)*self.Ratio), 0)
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
            value = mclamp(round(value, m3),m1,m2)
            
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
                    m_ModuleRoot = inst_new('ImageButton')
                    m_ModuleRoot.Size = dim_new(1, 0, 0, 25)
                    m_ModuleRoot.AutomaticSize = 'Y'
                    m_ModuleRoot.ClipsDescendants = false
                    m_ModuleRoot.BackgroundTransparency = 1
                    m_ModuleRoot.BorderSizePixel = 0
                    m_ModuleRoot.ZIndex = M_IndexOffset-1
                    m_ModuleRoot.Parent = self.Menu
                    
                     m_ModuleBackground = inst_new('Frame')
                     m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['bo'][1]
                     m_ModuleBackground.BackgroundTransparency = RLTHEMEDATA['bo'][2]
                     m_ModuleBackground.BorderSizePixel = 0
                     m_ModuleBackground.Size = dim_new(1,0,0,25)
                     m_ModuleBackground.ZIndex = M_IndexOffset
                     m_ModuleBackground.Parent = m_ModuleRoot
                     
                      m_Highlight = inst_new('Frame')
                      m_Highlight.Active = false
                      m_Highlight.BackgroundColor3 = RLTHEMEDATA['ge'][1]
                      m_Highlight.BackgroundTransparency = 0.9
                      m_Highlight.BorderSizePixel = 0
                      m_Highlight.Size = dim_sca(1,1)
                      m_Highlight.Visible = false
                      m_Highlight.ZIndex = M_IndexOffset
                      m_Highlight.Parent = m_ModuleBackground
                      
                      m_ModuleEnableEffect = inst_new('Frame')
                      m_ModuleEnableEffect.BackgroundColor3 = RLTHEMEDATA['tm'][1]
                      m_ModuleEnableEffect.BackgroundTransparency = 0.92
                      m_ModuleEnableEffect.BorderSizePixel = 0
                      m_ModuleEnableEffect.ClipsDescendants = true
                      m_ModuleEnableEffect.Size = dim_new(0,0,1,0)
                      m_ModuleEnableEffect.ZIndex = M_IndexOffset
                      m_ModuleEnableEffect.Parent = m_ModuleBackground
                      
                       m_ModuleEnableEffect2 = inst_new('Frame')
                       m_ModuleEnableEffect2.BackgroundColor3 = RLTHEMEDATA['ge'][1]
                       m_ModuleEnableEffect2.BorderSizePixel = 0
                       m_ModuleEnableEffect2.Size = dim_new(0,2,1,0)
                       m_ModuleEnableEffect2.ZIndex = M_IndexOffset
                       m_ModuleEnableEffect2.Parent = m_ModuleEnableEffect
                      
                      m_ModuleText = inst_new('TextLabel')
                      m_ModuleText.BackgroundTransparency = 1
                      m_ModuleText.Font = RLTHEMEFONT
                      m_ModuleText.Position = dim_off(0, 0)
                      m_ModuleText.RichText = true
                      m_ModuleText.Size = dim_sca(1, 1)
                      m_ModuleText.Text = text
                      m_ModuleText.TextColor3 = RLTHEMEDATA['tm'][1]
                      m_ModuleText.TextSize = 20
                      m_ModuleText.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                      m_ModuleText.TextStrokeTransparency = 0
                      m_ModuleText.TextXAlignment = 'Left'
                      m_ModuleText.ZIndex = M_IndexOffset
                      m_ModuleText.Parent = m_ModuleBackground
                      
                       m_TextPadding = inst_new('UIPadding')
                       m_TextPadding.PaddingLeft = dim_off(IndentLevel1, 0).X -- LEFT PADDING 1
                       m_TextPadding.Parent = m_ModuleText
                      
                      m_ModuleIcon = inst_new('TextLabel')
                      m_ModuleIcon.AnchorPoint = vec2(1,0)
                      m_ModuleIcon.BackgroundTransparency = 1
                      m_ModuleIcon.Font = RLTHEMEFONT
                      m_ModuleIcon.Position = dim_sca(1,0)
                      m_ModuleIcon.Rotation = 0
                      m_ModuleIcon.Size = dim_off(25, 25)
                      m_ModuleIcon.Text = '+'
                      m_ModuleIcon.TextColor3 = RLTHEMEDATA['tm'][1]
                      m_ModuleIcon.TextSize = 18
                      m_ModuleIcon.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                      m_ModuleIcon.TextStrokeTransparency = 0
                      m_ModuleIcon.TextXAlignment = 'Center'
                      m_ModuleIcon.ZIndex = M_IndexOffset
                      m_ModuleIcon.Parent = m_ModuleBackground
                    
                    m_Menu = inst_new('Frame')
                    m_Menu.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                    m_Menu.BackgroundTransparency = 1
                    m_Menu.BorderSizePixel = 0
                    m_Menu.Position = dim_off(0,25)
                    m_Menu.Size = dim_new(1,0,0,0)
                    m_Menu.Visible = false
                    m_Menu.ZIndex = M_IndexOffset-1
                    m_Menu.Parent = m_ModuleRoot
                    
                     m_MenuListLayout = inst_new('UIListLayout')
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
                    
                    M_Object.AddToggle = base_class.module_create_toggle
                    M_Object.AddLabel = base_class.module_create_label
                    M_Object.AddDropdown = base_class.module_create_dropdown
                    M_Object.AddModHotkey = base_class.module_create_modhotkey
                    M_Object.AddHotkey = base_class.module_create_hotkey
                    M_Object.AddSlider = base_class.module_create_slider
                    M_Object.AddInput = base_class.module_create_input
                    M_Object.AddButton = base_class.module_create_button
                    
                    M_Object.setvis = base_class.module_setvis
                    
                    M_Object.Toggle = base_class.module_toggle_self
                    M_Object.Disable = base_class.module_toggle_disable
                    M_Object.Enable = base_class.module_toggle_enable
                    M_Object.Reset = base_class.module_toggle_reset
                    
                    M_Object.ToggleMenu = base_class.module_toggle_menu
                    M_Object.GetState = base_class.module_getstate_self
                    M_Object.IsEnabled = base_class.module_getstate_self
                    M_Object.GetMenuState = base_class.module_getstate_menu
                    
                    M_Object.Connect = base_class.generic_connect
                    M_Object.SetTooltip = base_class.generic_tooltip
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
                
                if (not nohotkey) then M_Object:AddModHotkey() end
                
                tinsert(ui_Modules, M_Object)
                return M_Object
            elseif (Type == 'Textbox') then
                local m_ModuleRoot
                 local m_ModuleBackground
                 local m_ModuleEnableEffect
                  local m_ModuleText
                   local m_ModulePadding
                  local m_ModuleIcon

                do
                    m_ModuleRoot = inst_new('Frame')
                    m_ModuleRoot.AutomaticSize = 'Y'
                    m_ModuleRoot.BackgroundTransparency = 1
                    m_ModuleRoot.BorderSizePixel = 0
                    m_ModuleRoot.Size = dim_new(1, 0, 0, 25)
                    m_ModuleRoot.ZIndex = M_IndexOffset-1
                    m_ModuleRoot.Parent = self.Menu
                    
                     m_ModuleBackground = inst_new('Frame')
                     m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['bo'][1]
                     m_ModuleBackground.BackgroundTransparency = RLTHEMEDATA['bo'][2]
                     m_ModuleBackground.BorderSizePixel = 0
                     m_ModuleBackground.Size = dim_new(1,0,0,25)
                     m_ModuleBackground.ZIndex = M_IndexOffset
                     m_ModuleBackground.Parent = m_ModuleRoot
                     
                      m_ModuleEnableEffect = inst_new('Frame')
                      m_ModuleEnableEffect.BackgroundColor3 = RLTHEMEDATA['tm'][1]
                      m_ModuleEnableEffect.BackgroundTransparency = 1
                      m_ModuleEnableEffect.BorderSizePixel = 0
                      m_ModuleEnableEffect.ClipsDescendants = true
                      m_ModuleEnableEffect.Size = dim_new(1,0,1,0)
                      m_ModuleEnableEffect.ZIndex = M_IndexOffset
                      m_ModuleEnableEffect.Parent = m_ModuleBackground
                     
                     m_ModuleText = inst_new('TextBox')
                     m_ModuleText.BackgroundTransparency = 1
                     m_ModuleText.ClearTextOnFocus = not nohotkey
                     m_ModuleText.Font = RLTHEMEFONT
                     m_ModuleText.Size = dim_sca(1, 1)
                     m_ModuleText.Text = text
                     m_ModuleText.TextColor3 = RLTHEMEDATA['tm'][1]
                     m_ModuleText.TextSize = 20
                     m_ModuleText.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                     m_ModuleText.TextStrokeTransparency = 0
                     m_ModuleText.TextWrapped = true
                     m_ModuleText.TextXAlignment = 'Left'
                     m_ModuleText.ZIndex = M_IndexOffset
                     m_ModuleText.Parent = m_ModuleBackground
                      
                      m_ModulePadding = inst_new('UIPadding')
                      m_ModulePadding.PaddingLeft = dim_off(IndentLevel1, 0).X
                      m_ModulePadding.Parent = m_ModuleText
                     
                     m_ModuleIcon = inst_new('TextLabel')
                     m_ModuleIcon.Size = dim_off(25, 25)
                     m_ModuleIcon.Position = dim_sca(1,0)
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
                    M_Object.SetTooltip = base_class.generic_tooltip
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
                
                tinsert(ui_Modules, M_Object)
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
                    m_ModuleRoot = inst_new('Frame')
                    m_ModuleRoot.Size = dim_new(1, 0, 0, 25)
                    m_ModuleRoot.AutomaticSize = 'Y'
                    m_ModuleRoot.BackgroundTransparency = 1
                    m_ModuleRoot.BorderSizePixel = 0
                    m_ModuleRoot.ZIndex = M_IndexOffset-1
                    m_ModuleRoot.Parent = self.Menu
                    
                     m_ModuleBackground = inst_new('Frame')
                     m_ModuleBackground.BackgroundColor3 = RLTHEMEDATA['bo'][1]
                     m_ModuleBackground.BackgroundTransparency = RLTHEMEDATA['bo'][2]
                     m_ModuleBackground.BorderSizePixel = 0
                     m_ModuleBackground.Size = dim_new(1,0,0,25)
                     m_ModuleBackground.ZIndex = M_IndexOffset
                     m_ModuleBackground.Parent = m_ModuleRoot
                     
                     
                      m_ModuleEnableEffect = inst_new('Frame')
                      m_ModuleEnableEffect.BackgroundColor3 = RLTHEMEDATA['tm'][1]
                      m_ModuleEnableEffect.BackgroundTransparency = 1
                      m_ModuleEnableEffect.ClipsDescendants = true
                      m_ModuleEnableEffect.Size = dim_new(1,0,1,0)
                      m_ModuleEnableEffect.BorderSizePixel = 0
                      m_ModuleEnableEffect.ZIndex = M_IndexOffset
                      m_ModuleEnableEffect.Parent = m_ModuleBackground
                      
                      m_Highlight = inst_new('Frame')
                      m_Highlight.Size = dim_sca(1,1)
                      m_Highlight.BackgroundColor3 = RLTHEMEDATA['ge'][1]
                      m_Highlight.BackgroundTransparency = 0.9
                      m_Highlight.Visible = false
                      m_Highlight.ZIndex = M_IndexOffset
                      m_Highlight.BorderSizePixel = 0
                      m_Highlight.Parent = m_ModuleBackground
                     
                     m_ModuleText = inst_new('TextLabel')
                     m_ModuleText.BackgroundTransparency = 1
                     m_ModuleText.Font = RLTHEMEFONT
                     m_ModuleText.Position = dim_off(0, 0)
                     m_ModuleText.RichText = true
                     m_ModuleText.Size = dim_new(1, 0, 1, 0)
                     m_ModuleText.Text = text
                     m_ModuleText.TextColor3 = RLTHEMEDATA['tm'][1]
                     m_ModuleText.TextSize = 20
                     m_ModuleText.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                     m_ModuleText.TextStrokeTransparency = 0
                     m_ModuleText.TextXAlignment = 'Left'
                     m_ModuleText.ZIndex = M_IndexOffset
                     m_ModuleText.Parent = m_ModuleBackground
                     
                     m_ModulePadding = inst_new('UIPadding')
                     m_ModulePadding.PaddingLeft = dim_off(IndentLevel1, 0).X
                     m_ModulePadding.Parent = m_ModuleText
                     
                     m_ModuleIcon = inst_new('ImageLabel')
                     m_ModuleIcon.AnchorPoint = vec2(1,0.5)
                     m_ModuleIcon.BackgroundTransparency = 1
                     m_ModuleIcon.Position = dim_new(1,-6, 0.5, 0)
                     m_ModuleIcon.Rotation = 0
                     m_ModuleIcon.Size = dim_off(12, 12)
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
                    M_Object.SetTooltip = base_class.generic_tooltip
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
                
                tinsert(ui_Modules, M_Object)
                return M_Object
            end
        end
        base_class.module_create_label = function(self, text) 
            text = tostring(text)
                        
            local T_IndexOffset = self.ZIndex+1
            local t_Text
             local t_Padding
            do
                t_Text = inst_new('TextLabel')
                t_Text.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                t_Text.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                t_Text.BorderSizePixel = 0
                t_Text.Font = RLTHEMEFONT
                t_Text.Parent = self.Menu
                t_Text.RichText = true
                t_Text.Size = dim_new(1, 0, 0, 25)
                t_Text.Text = text
                t_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                t_Text.TextSize = 18
                t_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                t_Text.TextStrokeTransparency = 0
                t_Text.TextWrapped = true
                t_Text.TextXAlignment = 'Left'
                t_Text.TextYAlignment = 'Center'
                t_Text.ZIndex = T_IndexOffset
                
                t_Padding = inst_new('UIPadding')
                t_Padding.PaddingLeft = dim_off(IndentLevel2, 0).X -- LEFT PADDING 2
                t_Padding.Parent = t_Text
            end
            
            for i = 1, 25 do 
                if (t_Text.TextFits) then
                    break
                end
                t_Text.Size += dim_off(0,25)
            end
                
            local T_Object = {} do 
                T_Object.Tooltip = nil
                T_Object.Toggled = false
                
                T_Object.Name = text
                T_Object.SetTooltip = base_class.generic_tooltip
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
                t_Toggle = inst_new('Frame')
                t_Toggle.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                t_Toggle.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                t_Toggle.BorderSizePixel = 0
                t_Toggle.Size = dim_new(1, 0, 0, 25)
                t_Toggle.ZIndex = T_IndexOffset
                t_Toggle.Parent = self.Menu
                 
                 t_Text = inst_new('TextLabel')
                 t_Text.Size = dim_sca(1, 1)
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
                 
                  t_TextPadding = inst_new('UIPadding')
                  t_TextPadding.PaddingLeft = dim_off(IndentLevel2, 0).X -- LEFT PADDING 2
                  t_TextPadding.Parent = t_Text
                 
                 t_Box1 = inst_new('Frame')
                 t_Box1.AnchorPoint = vec2(1,0)
                 t_Box1.BackgroundColor3 = RLTHEMEDATA['sf'][1]
                 t_Box1.BackgroundTransparency = 1
                 t_Box1.BorderSizePixel = 0
                 t_Box1.Position = dim_new(1,-RightIndent,0.5,-5) -- RIGHT PADDING
                 t_Box1.Size = dim_off(10, 10)
                 t_Box1.ZIndex = T_IndexOffset
                 t_Box1.Parent = t_Toggle
                 
                 stroke(t_Box1)
                 
                 t_Box2 = inst_new('Frame')
                 t_Box2.Size = dim_off(8, 8)
                 t_Box2.Position = dim_off(1,1)
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
                T_Object.GetState = base_class.s_toggle_getstate
                T_Object.GetValue = base_class.s_toggle_getstate
                T_Object.IsEnabled = base_class.s_toggle_getstate
                
                T_Object.Connect = base_class.generic_connect
                T_Object.SetTooltip = base_class.generic_tooltip
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
                d_Root = inst_new('Frame')
                d_Root.Size = dim_new(1, 0, 0, 25)
                d_Root.AutomaticSize = 'Y'
                d_Root.BackgroundTransparency = 1
                d_Root.BorderSizePixel = 0
                d_Root.ZIndex = D_IndexOffset-1
                d_Root.Parent = self.Menu
            
                 d_Header = inst_new('Frame')
                 d_Header.Active = true
                 d_Header.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                 d_Header.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                 d_Header.BorderSizePixel = 0
                 d_Header.Size = dim_new(1, 0, 0, 25)
                 d_Header.ZIndex = D_IndexOffset+1
                 d_Header.Parent = d_Root
                 
                  d_HeaderText = inst_new('TextLabel')
                  d_HeaderText.Size = dim_sca(1, 1)
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
                  
                   d_TextPadding = inst_new('UIPadding')
                   d_TextPadding.PaddingLeft = dim_off(IndentLevel2, 0).X -- LEFT PADDING 2
                   d_TextPadding.Parent = d_HeaderText
                  
                  d_HeaderIcon = inst_new('ImageLabel')
                  d_HeaderIcon.Size = dim_off(25, 25)
                  d_HeaderIcon.Position = dim_new(1,-RightIndent +10, 0, 0) -- RIGHT PADDING
                  d_HeaderIcon.AnchorPoint = vec2(1,0)
                  d_HeaderIcon.BackgroundTransparency = 1
                  d_HeaderIcon.ImageColor3 = RLTHEMEDATA['tm'][1]
                  d_HeaderIcon.Image = 'rbxassetid://7184113125'
                  d_HeaderIcon.Rotation = 180
                  d_HeaderIcon.ZIndex = D_IndexOffset+1
                  d_HeaderIcon.Parent = d_Header
                 
                 d_Menu = inst_new('Frame')
                 d_Menu.Size = dim_new(1,0,0,0)
                 d_Menu.AutomaticSize = 'Y'
                 d_Menu.Position = dim_off(0, 25)
                 d_Menu.BackgroundColor3 = RLTHEMEDATA['bd'][1]
                 d_Menu.BackgroundTransparency = 1
                 d_Menu.BorderSizePixel = 0
                 d_Menu.ZIndex = D_IndexOffset
                 d_Menu.Visible = false
                 d_Menu.Parent = d_Header
                 
                  d_MenuListLayout = inst_new('UIListLayout')
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
                D_Object.GetValue = base_class.s_dropdown_getselection

                
                D_Object.Connect = base_class.generic_connect
                D_Object.SetTooltip = base_class.generic_tooltip
                D_Object.AddOption = base_class.dropdown_create_option
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
                h_Hotkey = inst_new('Frame')
                h_Hotkey.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                h_Hotkey.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                h_Hotkey.BorderSizePixel = 0
                h_Hotkey.Size = dim_new(1, 0, 0, 25)
                h_Hotkey.ZIndex = H_IndexOffset
                h_Hotkey.Parent = self.Menu
                 
                 h_Text = inst_new('TextLabel')
                 h_Text.Size = dim_sca(1, 1)
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
                 
                  h_TextPadding = inst_new('UIPadding')
                  h_TextPadding.PaddingLeft = dim_off(IndentLevel2, 0).X -- LEFT PADDING 2
                  h_TextPadding.Parent = h_Text
                    
            end
                
            local H_Object = {} do 
                H_Object.Label = h_Text
                H_Object.Hotkey = nil
                
                H_Object.Parent = self
                H_Object.Tooltip = nil
                
                H_Object.Flags = {}
                H_Object.Flags['HotkeySet'] = true
                
                H_Object.SetHotkey = base_class.s_modhotkey_sethotkey
                H_Object.GetHotkey = base_class.s_modhotkey_gethotkey
                H_Object.GetValue = base_class.s_modhotkey_gethotkey
                
                H_Object.Connect = base_class.generic_connect
                H_Object.SetTooltip = base_class.generic_tooltip
            end
            
            do
                h_Hotkey.InputBegan:Connect(function(io) 
                    local uitv = io.UserInputType.Value
                    if (uitv == 0) then
                        H_Object:SetHotkey()
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
                h_Hotkey = inst_new('Frame')
                h_Hotkey.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                h_Hotkey.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                h_Hotkey.BorderSizePixel = 0
                h_Hotkey.Size = dim_new(1, 0, 0, 25)
                h_Hotkey.ZIndex = H_IndexOffset
                h_Hotkey.Parent = self.Menu
                 
                 h_Text = inst_new('TextLabel')
                 h_Text.Size = dim_sca(1, 1)
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
                 
                 h_TextPadding = inst_new('UIPadding')
                 h_TextPadding.PaddingLeft = dim_off(IndentLevel2, 0).X -- LEFT PADDING 2
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
                H_Object.SetHotkey = base_class.s_hotkey_sethotkeyexplicit
                H_Object.GetHotkey = base_class.s_hotkey_gethotkey
                H_Object.GetValue = base_class.s_hotkey_gethotkey
                
                H_Object.Connect = base_class.generic_connect
                H_Object.SetTooltip = base_class.generic_tooltip
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
                s_Slider = inst_new('Frame')
                s_Slider.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                s_Slider.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                s_Slider.BorderSizePixel = 0
                s_Slider.Size = dim_new(1, 0, 0, 25)
                s_Slider.ZIndex = S_IndexOffset
                s_Slider.Parent = self.Menu
                 
                 s_InputBox = inst_new('TextBox')
                 s_InputBox.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                 s_InputBox.BackgroundTransparency = 0.1--RLTHEMEDATA['bs'][2]
                 s_InputBox.BorderSizePixel = 0
                 s_InputBox.Font = RLTHEMEFONT
                 s_InputBox.Size = dim_new(1, 0, 1, 0)
                 s_InputBox.PlaceholderText = 'Enter new value'
                 s_InputBox.TextColor3 = RLTHEMEDATA['tm'][1]
                 s_InputBox.TextSize = 18
                 s_InputBox.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 s_InputBox.TextStrokeTransparency = 0
                 s_InputBox.TextXAlignment = 'Center'
                 s_InputBox.Visible = false
                 s_InputBox.ZIndex = S_IndexOffset + 3
                 s_InputBox.Parent = s_Slider
                 
                 s_Text = inst_new('TextLabel')
                 s_Text.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                 s_Text.BackgroundTransparency = 0.2
                 s_Text.BorderSizePixel = 0
                 s_Text.Font = RLTHEMEFONT
                 s_Text.Size = dim_sca(1, 1)
                 s_Text.Text = text
                 s_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                 s_Text.TextSize = 18
                 s_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 s_Text.TextStrokeTransparency = 0
                 s_Text.TextXAlignment = 'Left'
                 s_Text.Visible = true
                 s_Text.ZIndex = S_IndexOffset + 1
                 s_Text.Parent = s_Slider
                  
                  s_TextPad = inst_new('UIPadding')
                  s_TextPad.PaddingLeft = dim_off(IndentLevel2, 0).X -- LEFT PADDING 2
                  s_TextPad.Parent = s_Text 
                 
                 s_Amount = inst_new('TextLabel')
                 s_Amount.Size = dim_new(0, 30, 1, 0)
                 s_Amount.Position = dim_new(1,-RightIndent, 0, 0) -- RIGHT PADDING
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
                 
                 s_SliderBarBg = inst_new('Frame')
                 s_SliderBarBg.BackgroundColor3 = RLTHEMEDATA['sb'][1]
                 s_SliderBarBg.BackgroundTransparency = RLTHEMEDATA['sb'][2]
                 s_SliderBarBg.BorderSizePixel = 0
                 s_SliderBarBg.ClipsDescendants = true
                 s_SliderBarBg.Position = dim_new(0, 8, 0.5, -3)
                 s_SliderBarBg.Size = dim_new(1, -16, 0, 6)
                 s_SliderBarBg.ZIndex = S_IndexOffset
                 s_SliderBarBg.Parent = s_Slider
                 
                  s_SliderBar = inst_new('Frame')
                  s_SliderBar.Size = dim_sca(1, 1)
                  s_SliderBar.Position = dim_new(0,0)
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
                
                S_Object.GetValue = base_class.s_slider_getval
                S_Object.SetValue = base_class.s_slider_setvalnum
                S_Object.SetValuePos = base_class.s_slider_setvalpos
                
                S_Object.Connect = base_class.generic_connect
                S_Object.SetTooltip = base_class.generic_tooltip
            end
            
            S_Object:SetValue(args['cur'])
            
            do
                s_Slider.MouseEnter:Connect(function() 
                    s_Slider.BackgroundColor3 = RLTHEMEDATA['hs'][1]
                    
                    s_Amount.TextXAlignment = 'Center'
                    twn(s_Text, {BackgroundTransparency = 1, TextTransparency = 1, TextStrokeTransparency = 1},true)
                    twn(s_Amount, {Position = dim_new(0.5,IndentLevel2,0,0)}, true) -- LEFT PADDING 2
                    
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
                    twn(s_Amount, {Position = dim_new(1,-RightIndent,0,0)}, true) -- RIGHT PADDING
                    
                    if (w_Tooltip.Text == S_Object.Tooltip) then
                        w_TooltipHeader.Visible = false
                    end
                end)
                
                s_Slider.InputBegan:Connect(function(io) 
                    local v = io.UserInputType.Value
                    if (v == 0) then
                        S_Object:SetValuePos(io.Position.X)
                        
                        DragConn = serv_uinput.InputChanged:Connect(function(io) 
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

                
                i_Input = inst_new('TextBox')
                i_Input.BackgroundColor3 = RLTHEMEDATA['bs'][1]
                i_Input.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                i_Input.BorderSizePixel = 0 
                i_Input.ClearTextOnFocus = true
                i_Input.Font = RLTHEMEFONT
                i_Input.Size = dim_new(1, 0, 0, 25)
                i_Input.Text = text
                i_Input.TextColor3 = RLTHEMEDATA['tm'][1]
                i_Input.TextSize = 18
                i_Input.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                i_Input.TextStrokeTransparency = 0
                i_Input.TextWrapped = true
                i_Input.TextXAlignment = 'Left'
                i_Input.ZIndex = I_IndexOffset
                i_Input.Parent = self.Menu
                 
                 i_TextPad = inst_new('UIPadding')
                 i_TextPad.PaddingLeft = dim_off(IndentLevel2, 0).X -- LEFT PADDING 2
                 i_TextPad.Parent = i_Input
                
                i_Icon = inst_new('ImageLabel')
                i_Icon.AnchorPoint = vec2(1,0.5)
                i_Icon.Position = dim_new(1,-4, 0.5, 0)                
                i_Icon.BackgroundTransparency = 1
                i_Icon.Image = 'rbxassetid://8997447289'
                i_Icon.Rotation = 0
                i_Icon.Size = dim_off(12, 12)
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
                I_Object.SetTooltip = base_class.generic_tooltip
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
                b_Background = inst_new('Frame')
                b_Background.BackgroundColor3 = RLTHEMEDATA['bs'][1] 
                b_Background.BackgroundTransparency = RLTHEMEDATA['bs'][2]
                b_Background.BorderSizePixel = 0
                b_Background.Size = dim_new(1,0,0,25)
                b_Background.ZIndex = B_IndexOffset
                b_Background.Parent = self.Menu
                
                 b_EnableEffect = inst_new('Frame')
                 b_EnableEffect.BackgroundColor3 = RLTHEMEDATA['tm'][1]
                 b_EnableEffect.BackgroundTransparency = 1
                 b_EnableEffect.BorderSizePixel = 0
                 b_EnableEffect.ClipsDescendants = true
                 b_EnableEffect.Size = dim_new(1,0,1,0)
                 b_EnableEffect.ZIndex = B_IndexOffset
                 b_EnableEffect.Parent = b_Background
                
                 b_Text = inst_new('TextLabel')
                 b_Text.BackgroundTransparency = 1
                 b_Text.Font = RLTHEMEFONT
                 b_Text.Position = dim_off(10, 0)
                 b_Text.Size = dim_new(1, -10, 1, 0)
                 b_Text.Text = text
                 b_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                 b_Text.TextSize = 18
                 b_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 b_Text.TextStrokeTransparency = 0
                 b_Text.TextXAlignment = 'Left'
                 b_Text.ZIndex = B_IndexOffset
                 b_Text.Parent = b_Background
                 
                  b_TextPadding = inst_new('UIPadding')
                  b_TextPadding.PaddingLeft = dim_off(IndentLevel2, 0).X -- LEFT PADDING 2
                  b_TextPadding.Parent = b_Text
                    
                 
                 b_Icon = inst_new('ImageLabel')
                 b_Icon.AnchorPoint = vec2(1,0.5)
                 b_Icon.BackgroundTransparency = 1
                 b_Icon.Position = dim_new(1,-4, 0.5, 0)
                 b_Icon.Rotation = 0
                 b_Icon.Size = dim_off(12, 12)
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
                B_Object.SetTooltip = base_class.generic_tooltip
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
                o_Option = inst_new('Frame')
                o_Option.BackgroundColor3 = RLTHEMEDATA['bd'][1]
                o_Option.BackgroundTransparency = RLTHEMEDATA['bd'][2]
                o_Option.BorderSizePixel = 0
                o_Option.Size = dim_new(1, 0, 0, 25)
                o_Option.ZIndex = O_IndexOffset
                o_Option.Parent = self.Menu
                 
                 o_Text = inst_new('TextLabel')
                 o_Text.BackgroundTransparency = 1
                 o_Text.Font = RLTHEMEFONT
                 o_Text.Size = dim_sca(1,1)
                 o_Text.Text = text
                 o_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                 o_Text.TextSize = 18
                 o_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 o_Text.TextStrokeTransparency = 0
                 o_Text.TextXAlignment = 'Left'
                 o_Text.ZIndex = O_IndexOffset
                 o_Text.Parent = o_Option
                 
                 o_TextPadding = inst_new('UIPadding')
                 o_TextPadding.PaddingLeft = dim_off(IndentLevel3, 0).X -- LEFT PADDING 3
                 o_TextPadding.Parent = o_Text
                 
                 o_EnableEffect = inst_new('Frame')
                 o_EnableEffect.BackgroundColor3 = RLTHEMEDATA['tm'][1]
                 o_EnableEffect.BackgroundTransparency = 0.96
                 o_EnableEffect.BorderSizePixel = 0
                 o_EnableEffect.ClipsDescendants = true
                 o_EnableEffect.Size = dim_new(0,0,1,0)
                 o_EnableEffect.ZIndex = O_IndexOffset
                 o_EnableEffect.Parent = o_Option
                 
                  o_EnableEffect2 = inst_new('Frame')
                  o_EnableEffect2.BackgroundColor3 = RLTHEMEDATA['ge'][1]
                  o_EnableEffect2.Size = dim_new(0,2,1,0)
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
                
                O_Object.GetState = base_class.s_ddoption_selected_getstate
                O_Object.IsSelected = base_class.s_ddoption_selected_getstate
                
                O_Object.SetTooltip = base_class.generic_tooltip
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
            
            tinsert(self.Objects, O_Object)
            return O_Object
        end
        
        base_class.widget_create_label = function(self, text) 
            local WidgetLabel = inst_new('TextLabel')
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
    function ui:CreateMenu(text) 
        local M_Id = #ui_Menus+1
        local M_IndexOffset = 50+(M_Id * 15)
        
        local m_Header
         local m_HeaderEnableEffect
         local m_HeaderText
         local m_HeaderIcon
         
         local m_Menu
          local m_MenuListLayout
        
        m_Header = inst_new('ImageButton')
        m_Header.Active = true
        m_Header.AutoButtonColor = false
        m_Header.BackgroundColor3 = RLTHEMEDATA['bm'][1]
        m_Header.BackgroundTransparency = RLTHEMEDATA['bm'][2]
        m_Header.BorderSizePixel = 0
        m_Header.ClipsDescendants = false
        m_Header.Size = dim_off(monitor_resolution.X < 1600 and 200 or 250, 30)
        
        local FinalPosition do 
            local MenusPerRow = mfloor(((monitor_resolution.X-400) / 300))
            FinalPosition = dim_off(200+(((M_Id-1)%MenusPerRow)*(300)), 200+150*(mfloor((M_Id-1)/MenusPerRow)))
        end
        
        
        m_Header.Position = FinalPosition
            
        
        
        --dim_off((0.1*((M_Id-1)%6) * monitor_resolution.X)+(100*((M_Id-1)%6)+100), 0)
        m_Header.ZIndex = M_IndexOffset+2
        m_Header.Parent = w_Backframe
        
        
        
         m_HeaderEnableEffect = inst_new('Frame')
         m_HeaderEnableEffect.BackgroundColor3 = RLTHEMEDATA['ge'][1]
         m_HeaderEnableEffect.Size = dim_new(0,0,1,0)
         m_HeaderEnableEffect.BorderSizePixel = 0
         m_HeaderEnableEffect.ZIndex = M_IndexOffset+2
         m_HeaderEnableEffect.Parent = m_Header
        
         m_HeaderText = inst_new('TextLabel')
         m_HeaderText.Size = dim_new(1, 0, 1, 0)
         m_HeaderText.Position = dim_off(0, 0)
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
         
         m_HeaderIcon = inst_new('ImageLabel')
         m_HeaderIcon.Size = dim_off(30, 30)
         m_HeaderIcon.Position = dim_sca(1,0)
         m_HeaderIcon.AnchorPoint = vec2(1,0)
         m_HeaderIcon.BackgroundTransparency = 1
         m_HeaderIcon.ImageColor3 = RLTHEMEDATA['tm'][1]
         m_HeaderIcon.Image = 'rbxassetid://7184113125'
         m_HeaderIcon.Rotation = 180
         m_HeaderIcon.ZIndex = M_IndexOffset+2
         m_HeaderIcon.Parent = m_Header

        m_Menu = inst_new('Frame')
        m_Menu.AutomaticSize = 'Y'
        m_Menu.BackgroundColor3 = RLTHEMEDATA['bo'][1]
        m_Menu.BackgroundTransparency = 1--RLTHEMEDATA['bo'][2]
        m_Menu.BorderSizePixel = 0
        m_Menu.Position = dim_off(0, 30)
        m_Menu.Size = dim_new(1,0,0,0)
        m_Menu.Visible = false
        m_Menu.ZIndex = M_IndexOffset
        m_Menu.Parent = m_Header
        
         m_MenuListLayout = inst_new('UIListLayout')
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
            
            M_Object.AddMod = base_class.menu_create_module
            
            
            M_Object.Enable = base_class.menu_enable
            M_Object.Disable = base_class.menu_disable
            M_Object.Toggle = base_class.menu_toggle
            M_Object.GetState = base_class.menu_getstate
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
                    serv_run:BindToRenderStep(M_Id, 2000, function(dt) -- "Tween" code
                        m_Header.Position = m_Header.Position:lerp(dim_off(destination.X, destination.Y), 1 - 1e-9^(dt)) -- Lerp the position
                        
                        -- value = lerp(target, value, exp2(-rate*deltaTime))
                    end)
                    -- Connect to mouse movement
                    ui_Connections[id] = serv_uinput.InputChanged:Connect(function(io) 
                        -- Check if the input is a mouse movement
                        if (io.UserInputType.Value == 4) then
                            -- If so then get the mouse position
                            local curr_pos = io.Position
                            -- Convert it to a vec2
                            curr_pos = vec2(curr_pos.X, curr_pos.Y)
                            -- Get the new destination (original position + input delta + inset)
                            destination = root_pos + (curr_pos - start_pos) + monitor_inset
                            
                            --twn(m_Header, {Position = dim_off(destination.X, destination.Y)})
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
                    serv_run:UnbindFromRenderStep(M_Id)
                end
            end)
            
            m_Header.MouseEnter:Connect(function() 
                m_Header.BackgroundColor3 = RLTHEMEDATA['hm'][1]
            end)
            
            m_Header.MouseLeave:Connect(function() 
                m_Header.BackgroundColor3 = RLTHEMEDATA['bm'][1]
            end)
        end
        
        
        
        tinsert(ui_Menus, M_Object)
        return M_Object
    end
    function ui:CreateWidget(Name, Position, Size, InRedlineWindow) 
        local W_Id = #ui_Widgets+1
        local W_IndexOffset = 25+(W_Id * 15)
        
        
        local w_Header
        local w_Main
        
        w_Header = inst_new('TextLabel')
        w_Header.BackgroundColor3 = RLTHEMEDATA['bm'][1]
        w_Header.BackgroundTransparency = RLTHEMEDATA['bm'][2]
        w_Header.BorderSizePixel = 0
        w_Header.Font = RLTHEMEFONT
        w_Header.Position = Position
        w_Header.RichText = true
        w_Header.Size = dim_off(Size.X, 21)
        w_Header.Text = Name
        w_Header.TextColor3 = RLTHEMEDATA['tm'][1]
        w_Header.TextSize = 19
        w_Header.TextStrokeColor3 = RLTHEMEDATA['to'][1]
        w_Header.TextStrokeTransparency = 0
        w_Header.TextXAlignment = 'Center'
        w_Header.Visible = true 
        w_Header.ZIndex = W_IndexOffset
        w_Header.Parent = InRedlineWindow and w_Backframe or w_Main
        
        stroke(w_Header, 'Border')
        
        w_Main = inst_new('Frame')
        w_Main.BackgroundColor3 = RLTHEMEDATA['gw'][1]
        w_Main.BackgroundTransparency = RLTHEMEDATA['gw'][2]
        w_Main.BorderSizePixel = 0
        w_Main.Position = dim_off(0, 21)
        w_Main.Size = dim_new(1, 0, 1, Size.Y-21)
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
                    serv_run:BindToRenderStep(W_Id, 2000, function() -- "Tween" code
                        w_Header.Position = w_Header.Position:lerp(dim_off(destination.X, destination.Y), 0.3) -- Lerp the position
                    end)
                    -- Connect to mouse movement
                    ui_Connections[id] = serv_uinput.InputChanged:Connect(function(io) 
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
                    serv_run:UnbindFromRenderStep(W_Id)
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
        serv_ctx:UnbindAction('RL-ToggleMenu')
        serv_ctx:UnbindAction('RL-Destroy')
        
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
        
        local sound = inst_new('Sound')
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
    function ui:GetBackframe() 
        return w_Backframe
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
            
            m_Notif = inst_new('Frame')
            m_Notif.AnchorPoint = vec2(1,1)
            m_Notif.BackgroundColor3 = RLTHEMEDATA['bo'][1]
            m_Notif.BackgroundTransparency = RLTHEMEDATA['bo'][2]
            m_Notif.BorderSizePixel = 0
            m_Notif.Position = dim_new(1, 275, 1, -((#notifs*125)+((#notifs+1)*25)))
            m_Notif.Size = dim_off(200, 125)
            m_Notif.ZIndex = 162
            --m_Notif.Parent = w_Screen
            
            stroke(m_Notif)
            
            m_Sound = inst_new('Sound')
            --m_Sound.Playing = true
            --m_Sound.SoundId =notifsounds[tone or 3]
            m_Sound.Volume = 1
            m_Sound.TimePosition = 0.1
            --m_Sound.Parent = m_Notif 
            
            m_Progress = inst_new('Frame')
            m_Progress.BackgroundColor3 = RLTHEMEDATA['ge'][1]
            m_Progress.BorderSizePixel = 0
            m_Progress.Position = dim_off(0, 30)
            m_Progress.Size = dim_new(1,0,0,1)
            m_Progress.ZIndex = 163
            --m_Progress.Parent = m_Notif
            
            m_Header = inst_new('Frame')
            m_Header.BackgroundColor3 = RLTHEMEDATA['bm'][1]
            m_Header.BackgroundTransparency = RLTHEMEDATA['bm'][2]
            m_Header.BorderSizePixel = 0
            m_Header.Size = dim_new(1,0,0,30)
            m_Header.ZIndex = 162
            --m_Header.Parent = m_Notif
            
            stroke(m_Header)
            
            m_Text = inst_new('TextLabel')
            m_Text.BackgroundTransparency = 1
            m_Text.Font = RLTHEMEFONT
            m_Text.Position = dim_off(32, 0)
            m_Text.RichText = true
            m_Text.Size = dim_new(1, -32, 1, 0)
            m_Text.Text = ''
            m_Text.TextColor3 = RLTHEMEDATA['tm'][1]
            m_Text.TextSize = 22
            m_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
            m_Text.TextStrokeTransparency = 0
            m_Text.TextXAlignment = 'Left'
            m_Text.ZIndex = 162
            --m_Text.Parent = m_Header
            
            m_Description = inst_new('TextLabel')
            m_Description.BackgroundTransparency = 1
            m_Description.Font = RLTHEMEFONT
            m_Description.Position = dim_off(4, 32)
            m_Description.RichText = true
            m_Description.Size = dim_new(1, -4, 1, -32)
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
            
            m_Icon = inst_new('ImageLabel')
            m_Icon.Size = dim_off(26, 26)
            m_Icon.Position = dim_off(2,2)
            m_Icon.BackgroundTransparency = 1
            m_Icon.ImageColor3 = RLTHEMEDATA['ge'][1]
            
            --m_Icon.Image = not warning and 'rbxassetid://8854459207' or 'rbxassetid://8854458547'
            m_Icon.Rotation = 0
            m_Icon.ZIndex = 162
            --m_Icon.Parent = m_Header
        end
        
        
        
        
        function ui:Notify(title, text, duration, tone, warning) 
            duration = mclamp(duration or 2, 0.1, 30)
            
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
            
            
            m_Notif.Position = dim_new(1, 275, 1, -((#notifs*125)+((#notifs+1)*25)))
            m_Notif.Parent = w_Screen
            
            for i = 1, 25 do
                if (m_Text.TextFits) then break end
                m_Notif.Size += dim_off(25, 0)
            end
            
            
            
            tinsert(notifs, m_Notif)
            twn(m_Notif, {Position = m_Notif.Position - dim_off(300,0)}, true)
            local j = ctwn(m_Progress, {Size = dim_off(0, 1)}, duration)
            j.Completed:Connect(function()
                do
                    for i = 1, #notifs do 
                        if (notifs[i] == m_Notif) then 
                            tremove(notifs, i) 
                        end 
                    end
                    for i = 1, #notifs do 
                        twn(notifs[i], {Position = dim_new(1, -25, 1, -(((i-1)*125)+(i*25)))}, true)
                    end
                    twn(m_Notif, {Position = dim_new(1, -25, 1, 200)}, true).Completed:Wait()
                    m_Notif:Destroy()
                end
            end)
        end
    end
    
    ui.Flags = {}
    ui.Flags.Destroying = true
    ui.Connect = base_class.generic_connect
    
    
    -- Gui binds
    local OldIconEnabled = serv_uinput.MouseIconEnabled
    serv_ctx:BindActionAtPriority('RL-ToggleMenu',function(_,uis) 
        
        if (uis.Value == 0) then
            W_WindowOpen = not W_WindowOpen
            
            if (W_WindowOpen) then
                serv_uinput.MouseIconEnabled = false
                w_MouseCursor.ImageTransparency = 0
                
                w_Backframe.Visible = true
                twn(w_Backframe, {Position = dim_new(0, 0, 0, 0)}, true)
            else
                serv_uinput.MouseIconEnabled = OldIconEnabled
                w_MouseCursor.ImageTransparency = 1
                
                
                local j = twn(w_Backframe, {Position = dim_new(0, 0, -1, 0)}, true)
                j.Completed:Wait()
                if j.PlaybackState == 4 then
                    w_Backframe.Visible = false
                end 
            end
        end
    end,false,999999,Enum.KeyCode.RightShift)
    
    serv_ctx:BindActionAtPriority('RL-Destroy',function(_,uis) 
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



-- Executor closure func
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
            tinsert(disabled_signals[id], connection)
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
    
    tclear(disabled_signals[id])
end

local cons = {}

-- Locals
local l_plr = serv_players.LocalPlayer
local l_mouse = l_plr:GetMouse()
local l_chr = l_plr.Character
local l_hum = l_chr and l_chr:FindFirstChild('Humanoid')
local l_humrp = l_chr and l_chr:FindFirstChild('HumanoidRootPart')
local l_cam = workspace.CurrentCamera or workspace:FindFirstChildOfClass('Camera')
-- Character respawn handler
cons['chr'] = l_plr.CharacterAdded:Connect(function(c) 
    l_chr = c
    l_hum = c:WaitForChild('Humanoid',2)
    l_humrp = c:WaitForChild('HumanoidRootPart',2)
end)


local p_RLFriends    = {} -- Redline friends
local p_RefKeys      = {} -- Player references (hashmap)
local p_Names        = {} -- Player names (array)

local function addplr(p)
    local PlayerName = p.Name
    if (p == l_plr or p_RLFriends[PlayerName]) then 
        return 
    end
    
    
    local ptable = {} do
        ptable['plr'] = p
        ptable['chr'] = nil
        ptable['hum'] = nil
        ptable['rp'] = nil
        
        ptable['cons'] = {}
        ptable['cons'][1] = p.CharacterAdded:Connect(function(c) 
            
            ptable['chr'] = c
            ptable['rp'] = c:WaitForChild('HumanoidRootPart', 0.5)
            ptable['hum'] = c:WaitForChild('Humanoid', 0.1)
            
        end)
        
        local chr = p.Character
        if (chr) then
            ptable['chr'] = chr
            ptable['hum'] = chr:FindFirstChild('Humanoid')
            ptable['rp'] = chr:FindFirstChild('HumanoidRootPart')
        end
    end
    
    p_RefKeys[PlayerName] = ptable
    tinsert(p_Names, PlayerName)
end 

local function remplr(p) 
    local PlayerName = p.Name
    
    do 
        local ref = p_RefKeys[PlayerName]
        if (ref == nil) then return end 
        local cons = ref.cons
        for i = 1, #cons do 
            
            cons[i]:Disconnect()
        end
        p_RefKeys[PlayerName].cons = nil -- just in case
        
        p_RefKeys[PlayerName] = nil
        
    end 
    do
        
        local idx = tfind(p_Names, PlayerName)
        tremove(p_Names, idx)
        
    end
end

cons['p1'] = serv_players.PlayerAdded:Connect(addplr)
cons['p2'] = serv_players.PlayerRemoving:Connect(remplr)
cons['cam'] = workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function() 
    local cc = workspace.CurrentCamera
    if not cc then
        cc = workspace:FindFirstChildOfClass('Camera')
    end
    l_cam = cc
end)
for i,p in ipairs(serv_players:GetPlayers()) do 
    addplr(p)
end


local fakechar do 
    fakechar = inst_new('Model')
    fakechar.Name = getnext()


    local Head = inst_new('Part')
    Head.Anchored = false
    Head.CanCollide = false
    Head.Name = 'Head'
    Head.Size = vec3(2, 1, 1)
    Head.Transparency = 0
    Head.Parent = fakechar

    local Torso = inst_new('Part')
    Torso.Anchored = false
    Torso.CanCollide = false
    Torso.Name = 'Torso'
    Torso.Size = vec3(2, 2, 1)
    Torso.Parent = fakechar

    local Left_Arm = inst_new('Part')
    Left_Arm.Anchored = false
    Left_Arm.CanCollide = false
    Left_Arm.Name = 'Left Arm'
    Left_Arm.Size = vec3(1, 2, 1)
    Left_Arm.Parent = fakechar

    local Right_Arm = inst_new('Part')
    Right_Arm.Anchored = false
    Right_Arm.CanCollide = false
    Right_Arm.Name = 'Right Arm'
    Right_Arm.Size = vec3(1, 2, 1)
    Right_Arm.Parent = fakechar

    local Left_Leg = inst_new('Part')
    Left_Leg.Anchored = false
    Left_Leg.CanCollide = false
    Left_Leg.Name = 'Left Leg'
    Left_Leg.Size = vec3(1, 2, 1)
    Left_Leg.Parent = fakechar

    local Right_Leg = inst_new('Part')
    Right_Leg.Anchored = false
    Right_Leg.CanCollide = false
    Right_Leg.Name = 'Right Leg'
    Right_Leg.Size = vec3(1, 2, 1)
    Right_Leg.Parent = fakechar

    local HumanoidRootPart = inst_new('Part')
    HumanoidRootPart.Anchored = true
    HumanoidRootPart.CanCollide = false
    HumanoidRootPart.Name = 'HumanoidRootPart'
    HumanoidRootPart.Size = vec3(2, 2, 1)
    HumanoidRootPart.Transparency = 1
    HumanoidRootPart.Parent = fakechar

    local Right_Shoulder = inst_new('Motor6D')
    Right_Shoulder.C0 = cfnew(1, 0.5, 0)
    Right_Shoulder.C1 = cfnew(-0.5, 0.5, 0)
    Right_Shoulder.Name = 'Right Shoulder'
    Right_Shoulder.Part0 = Torso
    Right_Shoulder.Part1 = Right_Arm
    Right_Shoulder.Parent = Torso

    local Left_Shoulder = inst_new('Motor6D')
    Left_Shoulder.C0 = cfnew(-1, 0.5, 0)
    Left_Shoulder.C1 = cfnew(0.5, 0.5, 0)
    Left_Shoulder.Name = 'Left Shoulder'
    Left_Shoulder.Part0 = Torso
    Left_Shoulder.Part1 = Left_Arm
    Left_Shoulder.Parent = Torso

    local Right_Hip = inst_new('Motor6D')
    Right_Hip.C0 = cfnew(1, -1, 0)
    Right_Hip.C1 = cfnew(0.5, 1, 0)
    Right_Hip.Name = 'Right Hip'
    Right_Hip.Part0 = Torso
    Right_Hip.Part1 = Right_Leg
    Right_Hip.Parent = Torso

    local Left_Hip = inst_new('Motor6D')
    Left_Hip.C0 = cfnew(-1, -1, 0)
    Left_Hip.C1 = cfnew(-0.5, 1, 0)
    Left_Hip.Name = 'Left Hip'
    Left_Hip.Part0 = Torso
    Left_Hip.Part1 = Left_Leg
    Left_Hip.Parent = Torso

    local Neck = inst_new('Motor6D')
    Neck.C0 = cfnew(0, 1, 0)
    Neck.C1 = cfnew(0, -0.5, 0)
    Neck.Name = 'Neck'
    Neck.Part0 = Torso
    Neck.Part1 = Head
    Neck.Parent = Torso

    local RootJoint = inst_new('Motor6D')
    RootJoint.C0 = cfnew(0, 0, 0)
    RootJoint.C1 = cfnew(0, 0, 0)
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
            c.Color = c_new(0.52, 0.52, 0.55)
            
            local _ = inst_new('BoxHandleAdornment')
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
    for i,v in pairs(cons) do v:Disconnect() end
    for i,v in ipairs(ui:GetModules()) do 
        if (v.Toggle and v:IsEnabled()) then
            v:Toggle()
        end
    end

    for i = 1, #p_Names do 
        local PlayerName = p_Names[i]
        
        do 
            local ref = p_RefKeys[PlayerName]
            local cons = ref.cons
            for i = 1, #cons do 
                cons[i]:Disconnect()
            end
            p_RefKeys[PlayerName].cons = nil -- just in case
            p_RefKeys[PlayerName] = nil
        end 
        p_Names[i] = nil
    end
    p_Names = nil
    p_RefKeys = nil
    
    serv_uinput.MouseIconEnabled = true
    
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

    local m_combat = ui:CreateMenu('Combat') do 
        -- Aimbot
        local c_aimbot = m_combat:AddMod('Aimbot')
        do 
            -- warning to any da hood skids:
            -- please fuck off
            -- (and also have fun remaking my code)
            
            local s_SafetyKey = c_aimbot:AddHotkey('Aimbot key'):SetTooltip('Only aimbots if this key is held. If no key is set, aimbot checks for mouse2 instead')
            
            local s_AliveCheck = c_aimbot:AddToggle('Alive check'):SetTooltip('Checks if the target is alive')
            local s_DistanceCheck = c_aimbot:AddToggle('Distance check'):SetTooltip('Checks if the target is within a set distance')
            local s_FovCheck = c_aimbot:AddToggle('FOV check'):SetTooltip('Checks if the target is in a set FOV')
            local s_TeamCheck = c_aimbot:AddToggle('Team check'):SetTooltip('Disables aimbot for your teammates')
            local s_VisibilityCheck = c_aimbot:AddToggle('Visibility check'):SetTooltip('Checks if the target is visible')
            
            local s_DeltaTime = c_aimbot:AddToggle('Deltatime safe'):SetTooltip('Accounts for deltatime. Makes mouse movement stable across different frame rates, but makes it smoother')
            local s_LockOn = c_aimbot:AddToggle('Lock on'):SetTooltip('Locks onto a target and doesn\'t change until you release Aimbot or they lose focus')
            local s_Prediction = c_aimbot:AddToggle('Prediction'):SetTooltip('Predicts where the opponent will move')
            
            
            local s_DistanceSlider = c_aimbot:AddSlider('Distance',{min=100,max=10000,cur=2000}):SetTooltip('Targets only get considered if their distance is less than this number. Requires <b>Distance check</b> to be enabled')
            local s_FovSlider = c_aimbot:AddSlider('FOV',{min=50,max=500,cur=150,step=1}):SetTooltip('Size of the FOV. Needs <b>FOV check</b> to be enabled')
            local s_PredictionSlider = c_aimbot:AddSlider('Prediction',{min=0.1,max=1,cur=0,step=0.1}):SetTooltip('How much prediction affects the aimbot')
            local s_SmoothnessSlider = c_aimbot:AddSlider('Smoothness',{min=0,max=1,cur=0.5,step=0.01}):SetTooltip('How smooth the aimbot is')
            local s_VerticalOffset = c_aimbot:AddSlider('Y Offset (Studs)',{min=-2,max=2,step=-0.1,cur=0}):SetTooltip('Optional Y offset. <b>Works in studs</b>')
            --local s_VerticalPxOffset = c_aimbot:AddSlider('Y Offset (Px)',{min=-200,max=200,step=1,cur=0}):SetTooltip('Optional Y offset. <b>Works in pixels</b>')
            --local s_HorizontalOffset = c_aimbot:AddSlider('X Offset (Px)',{min=-200,max=200,step=1,cur=0}):SetTooltip('Optional X offset. <b>Works in pixels</b>')
            
            local s_AimbotMethod = c_aimbot:AddDropdown('Aimbot method',true):SetTooltip('The method Aimbot uses')
            s_AimbotMethod:AddOption('Mouse'):SetTooltip('Fakes moving your mouse with input functions'):Select()
            s_AimbotMethod:AddOption('Camera'):SetTooltip('Usually better results than Mouse. How good it works depends on the game')
            
            
            local AliveCheck = s_AliveCheck:GetValue()
            local DistanceCheck = s_DistanceCheck:GetValue()
            local FovCheck = s_FovCheck:GetValue()
            local TeamCheck = s_TeamCheck:GetValue()
            local VisibilityCheck = s_VisibilityCheck:GetValue()
            
            local LockOn = s_LockOn:GetValue()
            local SafetyKey = s_SafetyKey:GetValue()
            local Prediction = s_Prediction:GetValue()
            local Deltatime = s_DeltaTime:GetValue()
            
            local Fov = 9999--s_FovSlider:GetValue()
            local Distance = s_DistanceSlider:GetValue()
            local Smoothness = s_SmoothnessSlider:GetValue()
            local PredictionValue = s_PredictionSlider:GetValue()
            local VerticalOffset = s_VerticalOffset:GetValue()
            --local VerticalPxOffset = s_VerticalPxOffset:GetValue()
            --local HorizontalOffset = s_HorizontalOffset:GetValue()
            
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
                    
                    Fov = FovCheck and s_FovSlider:GetValue() or 9999
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
                
                
                
                s_FovSlider:Connect('Changed', function(v)
                    Fov = v;
                    if (FovCircle) then 
                        FovCircle.Radius = Fov 
                        FovCircleOutline.Radius = Fov
                    end
                end)
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
                
                FovCircle = draw_new('Circle')
                FovCircle.NumSides = 40
                FovCircle.Thickness = 2
                FovCircle.Visible = FovCheck
                FovCircle.Radius = Fov
                FovCircle.ZIndex = 2
                
                FovCircleOutline = draw_new('Circle')
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
                    
                    local function team(plr) 
                        if (TeamCheck) then
                            return (plr.Team ~= l_plr.Team)
                        else
                            return true
                        end
                    end
                    
                    local function vis(root) 
                        if (VisibilityCheck) then
                            local clear = l_cam:GetPartsObscuringTarget({root.Position}, {l_chr})
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
                            local MousePosition = mp or vec2(l_mouse.X, l_mouse.Y)
                            
                            local CameraPos = l_cam.CFrame.Position
                            
                            AimbotTarget = nil 
                            for i = 1, #p_Names do 
                                local PlrObj = p_RefKeys[p_Names[i]]
                                local Root, Humanoid = PlrObj.rp, PlrObj.hum
                                
                                local CurVec3 = predic(Root)
                                -- the funny if statement 🗿
                                if (CurVec3 and lock(Root) and team(PlrObj.plr) and alive(Humanoid) and dist(CameraPos, CurVec3) and vis(Root)) then
                                    local CurVec2, CurVis = l_cam:WorldToViewportPoint(CurVec3)
                                    
                                    
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
                            local MousePosition = mp or vec2(l_mouse.X, l_mouse.Y)
                            
                            local CameraPos = l_cam.CFrame.Position
                            
                            AimbotTarget = nil 
                            for i = 1, #p_Names do 
                                local PlrObj = p_RefKeys[p_Names[i]]
                                local Root, Humanoid = PlrObj.rp, PlrObj.hum
                                
                                local CurVec3 = predic(Root)
                                -- the funny if statement 🗿
                                if (CurVec3 and lock(Root) and team(PlrObj.plr) and alive(Humanoid) and dist(CameraPos, CurVec3) and vis(Root)) then
                                    local CurVec2, CurVis = l_cam:WorldToViewportPoint(CurVec3)
                                    
                                    
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
                    AimbotConnection = serv_run.RenderStepped:Connect(function() 
                        if (W_WindowOpen) then return end 
                        
                        local mp = serv_uinput:GetMouseLocation()--+vec2(HorizontalOffset, VerticalPxOffset)
                        FovCircle.Position = mp
                        FovCircleOutline.Position = mp
                        FovCircle.Color = RGBCOLOR
                        
                        FovCircle.Visible = FovCheck
                        FovCircleOutline.Visible = FovCheck
                        if (SafetyKey) then
                            if (not serv_uinput:IsKeyDown(SafetyKey)) then
                                AimbotStatus = 'aimbot off'
                                PreviousTarget = nil
                                AimbotTarget = nil
                                return
                            end
                        else
                            if (not serv_uinput:IsMouseButtonPressed(1)) then
                                AimbotStatus = 'aimbot off'
                                PreviousTarget = nil
                                AimbotTarget = nil
                                return 
                            end
                        end
                        
                        
                        local target, position, dist = NextTarget(mp)
                        AimbotStatus = target and 'aiming' or 'no target'
                        PreviousTarget = target
                        
                        if (position) then
                            local _ = l_cam.CFrame
                            l_cam.CFrame = cfnew(_.Position, position):lerp(_, Smoothness)
                        end
                    end)
                elseif (AimbotMethod == 'Mouse') then
                    AimbotConnection = serv_run.RenderStepped:Connect(function(dt) 
                        local mp = serv_uinput:GetMouseLocation()--+vec2(HorizontalOffset, VerticalPxOffset)
                        FovCircle.Position = mp
                        FovCircleOutline.Position = mp
                        FovCircle.Color = RGBCOLOR
                        
                        FovCircle.Visible = FovCheck
                        FovCircleOutline.Visible = FovCheck
                        
                        if (SafetyKey) then
                            if (not serv_uinput:IsKeyDown(SafetyKey)) then
                                AimbotStatus = 'aimbot off'
                                PreviousTarget = nil
                                AimbotTarget = nil
                                return
                            end
                        else
                            if (not serv_uinput:IsMouseButtonPressed(1)) then
                                AimbotStatus = 'aimbot off'
                                PreviousTarget = nil
                                AimbotTarget = nil
                                return 
                            end
                        end
                        
                        local target, position, dist = NextTarget(mp)
                        AimbotStatus = target and 'aiming' or 'no target'
                        PreviousTarget = target
                        
                        if (position) then
                            local delta = position - mp
                            delta *= Deltatime and (Smoothness * dt * 75) or Smoothness
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
        local c_hitbox = m_combat:AddMod('Hitboxes')
        do 
            local s_HitboxSize = c_hitbox:AddSlider('Size',{min=2,max=50,step=0.1,value=5}):SetTooltip('How large (in studs) the hitboxes are')
            local s_Transparency = c_hitbox:AddSlider('Transparency',{min=0,max=1,step=0.01,value=0.5}):SetTooltip('How transparent the hitboxes are')
            
            local s_RGB = c_hitbox:AddToggle('RGB'):SetTooltip('Makes hitboxes RGB instead of gray')
            local s_TeamCheck = c_hitbox:AddToggle('Team check'):SetTooltip('Disables hbe for teammates')
            local s_XZOnly = c_hitbox:AddToggle('XZ only'):SetTooltip('Disables expansion on the Y axis, used for certain games that may break with this disabled')        
            
            local HitboxSize = s_HitboxSize:GetValue()
            local Transparency = s_Transparency:GetValue()
            
            local RGB = s_RGB:GetValue()
            local TeamCheck = s_TeamCheck:GetValue()
            local XZOnly = s_XZOnly:GetValue()
            
            s_HitboxSize:Connect('Changed',function(v)HitboxSize=v;end)
            s_Transparency:Connect('Changed',function(v)Transparency=v;end)
            s_RGB:Connect('Toggled',function(v)RGB=v;end)
            s_TeamCheck:Connect('Toggled',function(v)TeamCheck=v;c_hitbox:Reset();end)
            s_XZOnly:Connect('Toggled',function(v)XZOnly=v;end)
            
            
            local HitboxConnection
            local old_color
            local old_size 

            c_hitbox:Connect('Enabled',function() 
                old_color = l_humrp.Color 
                old_size = l_humrp.Size
                
                if (TeamCheck) then
                    
                    HitboxConnection = serv_run.RenderStepped:Connect(function() 
                        local size = vec3(HitboxSize, XZOnly and 2 or HitboxSize, HitboxSize)
                        local lteam = l_plr.Team
                        
                        for i = 1, #p_Names do 
                            local pobj = p_RefKeys[p_Names[i]]
                            if (pobj.plr.Team == lteam) then continue end
                            local humrp = pobj.rp
                            
                            if (humrp) then
                                humrp.Size = size
                                humrp.Color = RGB and RGBCOLOR or old_color
                                humrp.Transparency = Transparency
                            end
                        end
                    end)
                else 
                    HitboxConnection = serv_run.RenderStepped:Connect(function() 
                        local size = vec3(HitboxSize, XZOnly and 2 or HitboxSize, HitboxSize)
                        for i = 1, #p_Names do 
                            local pobj = p_RefKeys[p_Names[i]]
                            local humrp = pobj.rp
                            
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
                for i = 1, #p_Names do 
                    local pobj = p_RefKeys[p_Names[i]]
                    local rp = pobj.rp
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
            local s_MouseButton = c_trigbot:AddDropdown('Mouse button'):SetTooltip('The mouse button that gets clicked')
            local s_ShootMode   = c_trigbot:AddDropdown('Shoot mode'):SetTooltip('The way triggerbot shoots when it finds someone')
            local s_ScanMode    = c_trigbot:AddDropdown('Scan mode'):SetTooltip('The way triggerbot finds a target. Leave this on default if you don\'t know what this does')
            
            local s_SafetyKey   = c_trigbot:AddHotkey('Safety key'):SetTooltip('Will only shoot if this key is held')
            local s_CheckRate   = c_trigbot:AddSlider('Check rate',{min=0,max=0.1,step=0.01,cur=0.03}):SetTooltip('How often targets are checked for')
            local s_ClickSpeed  = c_trigbot:AddSlider('Click speed',{min=0,max=0.5,step=0.01,cur=0}):SetTooltip('The delay between clicks when Spam mode is enabled')
            local s_Teamcheck   = c_trigbot:AddToggle('Team check'):SetTooltip('Disables Triggerbot for your teammates')
            
            s_MouseButton:AddOption('Mouse1'):SetTooltip('Clicks MouseButton1 (left click)'):Select()
            s_MouseButton:AddOption('Mouse2'):SetTooltip('Clicks MouseButton2 (right click')
            
            s_ShootMode:AddOption('Spam'):SetTooltip('Spams button down while there\'s a target'):Select()
            s_ShootMode:AddOption('Hold'):SetTooltip('Holds button down while there\'s a target')
            
            s_ScanMode:AddOption('Raycast'):SetTooltip('Raycasts directly and checks if the target is valid. Works for players and NPCs')
            s_ScanMode:AddOption('Proximity'):SetTooltip('Checks if any players are close to your mouse')
            
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
            
            c_trigbot:SetTooltip('Automatically clicks when you mouse over a player')
        end
        ]]
        
        c_aimbot:SetTooltip('Locks your aim onto other players. Works in a variety of games, and has a ton of settings')
        c_hitbox:SetTooltip('Expand other players\' hitboxes. Depending on the game, this lets you hit them easier. <b>Note that this mod is detectable - always test on an alt and never use your main!</b>')
    end
    local m_player = ui:CreateMenu('Player') do 
        local p_animspeed   = m_player:AddMod('Animspeed')
        local p_antiafk     = m_player:AddMod('Anti-AFK')
        local p_anticrash   = m_player:AddMod('Anti-crash')
        local p_antifling   = m_player:AddMod('Anti-fling')
        local p_antiwarp    = m_player:AddMod('Anti-warp')
        local p_autoclick   = m_player:AddMod('Auto clicker')
        local p_flag        = m_player:AddMod('Fakelag')
        local p_flashback   = m_player:AddMod('Flashback')
        local p_respawn     = m_player:AddMod('Respawn', 'Toggle')
        local p_safemin     = m_player:AddMod('Safe minimize')
        local p_waypoints   = m_player:AddMod('Waypoints')
        
        -- Anim speed
        do 
            local s_mode = p_animspeed:AddDropdown('Mode',true):SetTooltip('The way animation speed gets modified')
            local s_max = p_animspeed:AddToggle('Max speed'):SetTooltip('Sets speed to the highest it possibly can')
            local s_perframe = p_animspeed:AddToggle('Per frame'):SetTooltip('Updates animation speeds per frame')
            local s_percent = p_animspeed:AddSlider('Speed (Percent)',{min=0,max=500,cur=100}):SetTooltip('Multiplies every animation\'s speed by this percent value')
            local s_speed = p_animspeed:AddSlider('Speed (Absolute)',{min=0,max=100,cur=1,step=0.01}):SetTooltip('Sets every animation\'s speed to this value')
            s_mode:AddOption('Absolute'):SetTooltip('Sets the animation speeds to this value'):Select()
            s_mode:AddOption('Percent'):SetTooltip('Multiplies the animation speeds by this percent')
            
            
            local max = s_max:IsEnabled()
            local speed = s_speed:GetValue()
            local percent = s_percent:GetValue()
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
                
                if (s_perframe:IsEnabled()) then
                    serv_run:BindToRenderStep('RL-AnimSpeed',2356,function()
                        local tracks = l_hum:GetPlayingAnimationTracks()
                        
                        for i = 1, #tracks do 
                            noob(tracks[i])
                        end
                    end)
                else
                    animcon = l_hum.AnimationPlayed:Connect(noob)
                
                    local tracks = l_hum:GetPlayingAnimationTracks()
                    
                    for i = 1, #tracks do 
                        noob(tracks[i])
                    end
                end
                
                resetcon = l_plr.CharacterAdded:Connect(function() 
                    wait()
                    p_animspeed:Reset()
                end)
            end)
            
            p_animspeed:Connect('Disabled',function() 
                if (animcon) then animcon:Disconnect() animcon = nil end
                if (resetcon) then resetcon:Disconnect() resetcon = nil end
                serv_run:UnbindFromRenderStep('RL-AnimSpeed')
            end)
            
        end
        -- Anti afk
        do 
            local p_afk_mode   = p_antiafk:AddDropdown('Mode', true)
            do 
                local _ = p_afk_mode:AddOption('Standard')
                :Select()
                :SetTooltip('Disables connections related to player idling. Impossible to detect, has no side-effects');
                
                p_afk_mode:AddOption('Move on idle'):SetTooltip('Automatically moves your character when the client idles')
                p_afk_mode:AddOption('Walk around'):SetTooltip('Randomly moves your character around. Useful for games with more afk checks than the default roblox ones')
            end
            
            
            local c
            local p = 'Standard'
            p_antiafk:Connect('Enabled', function() 
                if (p == 'Standard') then
                    dnec(l_plr.Idled, 'plr_idled')
                    return 
                end
                if (p == 'Move on idle') then
                    c = l_plr.Idled:Connect(function() 
                        l_hum:MoveTo(l_humrp.Position + vec3(0, 0, 2))
                    end)
                    return 
                end
            
                if (p == 'Walk around') then
                    spawn(function() 
                        local base = l_humrp.Position
                        while (p_antiafk:IsEnabled()) do 
                            wait(mrandom()*8)
                            l_hum:MoveTo(base + vec3(
                                (mrandom()-.5)*15,
                                0,
                                (mrandom()-.5)*15)
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
            local sc = game:GetService('ScriptContext')
            
            local amnt = p_anticrash:AddSlider('Delay',{min=0.1,max=5,cur=2,step=0.1},true):SetTooltip('Anti-crash sensitivity. <b>Setting this too low may mess with your game. Leave it at the default if you don\'t know what this does.</b>')
            
            amnt:Connect('Changed',function(v) 
                if (p_anticrash:IsEnabled()) then
                    sc:SetTimeout(v)
                end
            end)
            
            p_anticrash:Connect('Toggled',function(t) 
                if t then
                    sc:SetTimeout(amnt:GetValue())
                else
                    sc:SetTimeout(99)
                end
            end)
        end
        -- Antifling
        do 
            local s_FreezeMethod = p_antifling:AddDropdown('Method', true):SetTooltip('The method Antifling uses')
            do 
                s_FreezeMethod:AddOption('Anchor'):Select():SetTooltip('Anchors your character when someone gets close to you, works the best but limits movement')
                s_FreezeMethod:AddOption('Anchor + Safemin'):SetTooltip('Combines Anchor and Safemin; anchors when either the screen is out of focus or someones closed to you')
                s_FreezeMethod:AddOption('Noclip'):SetTooltip('Activates noclip when someones near you. You\'ll still be slightly pushed around')
                s_FreezeMethod:AddOption('Teleport'):SetTooltip('Teleports you away from them. Funny to use but you may be flung')
            end
            local distance = 25
            local pcon
            
            p_antifling:AddSlider('Distance',{min=1,max=50,cur=25,step=0.1}):SetTooltip('How close a player has to be to you to trigger the antifling'):Connect('Changed',function(v)distance=v;end)
            
            
            p_antifling:Connect('Enabled', function() 
                local m = s_FreezeMethod:GetSelection()
                dnec(l_humrp.Changed, 'rp_changed')
                dnec(l_humrp:GetPropertyChangedSignal('CanCollide'), 'rp_cancollide')
                dnec(l_humrp:GetPropertyChangedSignal('Anchored'), 'rp_anchored')
                
                if (m == 'Anchor') then
                    pcon = serv_run.Heartbeat:Connect(function() 
                        local self_pos = l_humrp.Position
                        l_humrp.Anchored = false
                        for i = 1, #p_Names do 
                            local rp = p_RefKeys[p_Names[i]].rp
                            
                            if (rp and ((rp.Position - self_pos).Magnitude) < distance) then
                                l_humrp.Anchored = true
                                break
                            end
                        end		
                    end)
                elseif (m == 'Anchor + Safemin') then
                    
                    pcon = serv_run.Heartbeat:Connect(function()
                        if (isrbxactive() == false) then
                            l_humrp.Anchored = true
                            return
                        end
                        
                        local self_pos = l_humrp.Position
                        l_humrp.Anchored = false
                        for i = 1, #p_Names do 
                            local rp = p_RefKeys[p_Names[i]].rp
                            
                            if (rp and ((rp.Position - self_pos).Magnitude) < distance) then
                                l_humrp.Anchored = true
                                break
                            end
                        end		
                    end)              
                elseif (m == 'Noclip') then
                    pcon = serv_run.Heartbeat:Connect(function() 
                        local self_pos = l_humrp.Position
                        for i = 1, #p_Names do 
                            local rp = p_RefKeys[p_Names[i]].rp
                            
                            if (rp and ((rp.Position - self_pos).Magnitude) < distance) then
                                local c = l_chr:GetChildren()
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
                    pcon = serv_run.Heartbeat:Connect(function() 
                        local self_pos = l_humrp.Position
                        for i = 1, #p_Names do 
                            local rp = p_RefKeys[p_Names[i]].rp
                            
                            if (rp and ((rp.Position - self_pos).Magnitude) < distance) then
                                l_humrp.CFrame += vec3(mrandom(-100,100)*.1,mrandom(0,20)*.1,mrandom(-100,100)*.1)
                                break
                            end
                        end		
                    end)
                end
            end)
            p_antifling:Connect('Disabled', function() 
                if (pcon) then pcon:Disconnect() pcon = nil end		
                if (l_humrp.Anchored) then l_humrp.Anchored = false end
                
                enec('rp_changed')
                enec('rp_cancollide')
                enec('rp_anchored')
            end)
        
        
            s_FreezeMethod:Connect('Changed', function()
                p_antifling:Reset()
            end)
            
            if (game.PlaceId == 4483381587) then
                wait(0.2)
                p_antifling:Enable() 
            end
        end
        -- Antiwarp
        do 
            local s_Lerp = p_antiwarp:AddSlider('Lerp',{min=0,max=1,cur=1,step=0.01}):SetTooltip('How much you will be teleported back when antiwarp gets triggered')
            local s_Dist = p_antiwarp:AddSlider('Distance',{min=1,max=150,cur=20,step=0.1}):SetTooltip('How far you\'d have to be teleported before it gets set off')
            local Lerp = s_Lerp:GetValue()
            local Dist = s_Dist:GetValue()
            
            s_Lerp:Connect('Changed',function(v)Lerp=v;end)
            s_Dist:Connect('Changed',function(v)Dist=v;end)
            
            local AntiwarpStep
            
            local CurrentCFrame = l_humrp and l_humrp.CFrame or cfnew(0,0,0)
            local PreviousCFrame = l_humrp and l_humrp.CFrame or cfnew(0,0,0)
            
            p_antiwarp:Connect('Enabled',function() 
                dnec(l_humrp.Changed, 'rp_changed')
                dnec(l_humrp:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                
                
                PreviousCFrame = l_humrp.CFrame
                AntiwarpStep = serv_run.Heartbeat:Connect(function() 
                    CurrentCFrame = l_humrp.CFrame 
                    
                    if ((CurrentCFrame.Position - PreviousCFrame.Position).Magnitude > Dist) then
                        local _ = CurrentCFrame:lerp(PreviousCFrame, Lerp)
                        PreviousCFrame = _
                        l_humrp.CFrame = _
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
        -- Autoclick
        do 
            local s_ButtonType = p_autoclick:AddDropdown('Mouse key',true):SetTooltip('The key to click')
            local s_Shake = p_autoclick:AddToggle('Mouse shake'):SetTooltip('Shakes your mouse around to fake jitterclicking')
            local s_ShakeAmount = p_autoclick:AddSlider('Shake amount',{min=1,max=15,step=1,cur=5}):SetTooltip('How much your mouse gets shooken <i>(shook? shaken? who knows)</i>')
            local s_ClickRate = p_autoclick:AddSlider('Delay',{min=0,max=0.7,cur=0,step=0.01}):SetTooltip('Delay (in seconds) between mouse clicks. A delay of 0 is 1 click per frame')
            local s_ClickAmount = p_autoclick:AddSlider('Click amount',{min=1,max=15,step=1,cur=1}):SetTooltip('How many clicks are done')
            
            
            s_ButtonType:AddOption('Mouse1'):SetTooltip('Clicks Mouse1 / left click'):Select()
            s_ButtonType:AddOption('Mouse2'):SetTooltip('Clicks Mouse2 / right click')
            
            
            local ButtonType   = s_ButtonType:GetSelection()
            local ClickAmount  = s_ClickAmount:GetValue()
            local ClickRate    = s_ClickRate:GetValue()
            local Shake        = s_Shake:GetValue()
            local ShakeAmount  = s_ShakeAmount:GetValue()
            
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
            
            
            local ClickConnection
            local ConnectionIdentifier
            
            p_autoclick:Connect('Enabled',function() 
                ConnectionIdentifier = mrandom(1, 9999)
                local _ = ConnectionIdentifier
                
                
                -- Handle shaking
                spawn(function() 
                    if (Shake) then
                        while (Shake and p_autoclick:IsEnabled()) do 
                            if (not W_WindowOpen) then
                                mousemoverel(mrandom(-ShakeAmount, ShakeAmount),mrandom(-ShakeAmount, ShakeAmount))
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
                        local ClickFunc = ButtonType == 'Mouse1' and mouse1click or mouse2click
                        
                        -- Try to click every frame
                        ClickConnection = serv_run.RenderStepped:Connect(function() 
                            -- If window is closed then
                            if (not W_WindowOpen) then
                                -- click the mouse button
                                
                                for i = 1, ClickAmount do 
                                    ClickFunc()
                                end
                            end
                            -- otherwise do nothing
                        end)               
                    else
                        -- If the clickrate isn't 0 then spawn a loop
                        spawn(function() 
                            -- Get func
                            local ClickFunc = ButtonType == 'Mouse1' and mouse1click or mouse2click
                            
                            -- While autoclicking...
                            while (p_autoclick:IsEnabled()) do 
                                -- try to click
                                if (not W_WindowOpen) then
                                    for i = 1, ClickAmount do 
                                        ClickFunc()
                                    end
                                end
                                -- wait for click duration
                                wait(ClickRate)
                                -- check if the identifier changed (i.e. check if there are 2 loops, break if there are)
                                if (ConnectionIdentifier ~= _) then break end
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
            end)
        end 
        -- Fake lag
        do 
            local s_Method = p_flag:AddDropdown('Method',true)
            s_Method:AddOption('Fake'):SetTooltip('Doesn\'t affect your network usage. Visualizer is more accurate than Fake, but still may have desync issues'):Select()
            s_Method:AddOption('Real'):SetTooltip('Limits your actual network usage. May lag more than just your movement. Visualizer is less accurate than Fake, but lag looks more realistic')
            
            local s_LagAmnt = p_flag:AddSlider('Amount',{min=1,max=10,step=0.1,cur=3}):SetTooltip('Lag amount. The larger the number, the more lag you have')
            local LagAmnt = s_LagAmnt:GetValue()
            local Method = s_Method:GetSelection()
            
            s_LagAmnt:Connect('Changed',function(v)LagAmnt=v;end)
            s_Method:Connect('Changed',function(v)Method=v;p_flag:Reset()end)
            
            local seat
            p_flag:Connect('Enabled',function() 
                local fakerp = fakechar.HumanoidRootPart
                
                if (Method == 'Fake') then
                    local s = Method 
                    
                    local thej = l_humrp.CFrame
                    
                    seat = inst_new('Seat')
                    seat.Transparency = 1
                    seat.CanTouch = false
                    seat.CanCollide = false
                    seat.Anchored = true
                    seat.CFrame = thej
                    
                    local weld = inst_new('Weld')
                    weld.Part0 = seat
                    weld.Part1 = nil
                    weld.Parent = seat
                    
                    seat.Parent = workspace
                    
                    spawn(function() 
                        while true do 
                            if (not p_flag:IsEnabled() or Method ~= s) then break end
                            wait((mrandom(20,40)*.1) / LagAmnt)
                            if (not p_flag:IsEnabled() or Method ~= s) then break end
                            
                            do
                                seat.Anchored = false
                                local thej = l_humrp.CFrame
                                fakechar.Parent = workspace
                                fakerp.CFrame = thej
                                
                                seat.CFrame = thej
                                weld.Part1 = l_humrp
                            end
                            
                            wait(mrandom(1,LagAmnt)*.1)
                            fakechar.Parent = nil
                            weld.Part1 = nil
                            seat.Anchored = true
                        end 
                    end)
                else
                    spawn(function() 
                        local s = Method
                        while true do 
                            if (not p_flag:IsEnabled() or Method ~= s) then break end
                            wait(5 / LagAmnt)
                            if (not p_flag:IsEnabled() or Method ~= s) then break end
                            
                            
                            fakechar.Parent = workspace
                            fakerp.CFrame = l_humrp.CFrame
                            
                            serv_net:SetOutgoingKBPSLimit(1)
                            
                            wait(mrandom(1,LagAmnt)*.1)
                            fakechar.Parent = nil
                            serv_net:SetOutgoingKBPSLimit(9e9)
                        end 
                    end)
                end 
            end)
            
            p_flag:Connect('Disabled',function() 
                if (seat) then seat:Destroy() seat = nil end 
                
                fakechar.Parent = nil
                serv_net:SetOutgoingKBPSLimit(9e9)
            end)
        end
        -- Flashback
        do 
            local flash_delay = p_flashback:AddSlider('Delay', {min=0,max=5,cur=0,step=0.1},true)
            flash_delay:SetTooltip('How long to wait before teleporting you back')
            
            local fb_con
            local resp_con
            
            p_flashback:Connect('Enabled', function() 
                
                local pos = l_humrp and l_humrp.CFrame
                
                local function bind(h) 
                    h.Died:Connect(function() 
                        pos = l_humrp.CFrame
                        l_plr.CharacterAdded:Wait()
                        delay(flash_delay:GetValue(), function() l_humrp.CFrame = pos end)
                    end)
                end
                
                resp_con = l_plr.CharacterAdded:Connect(function() 
                    wait(0.03)
                    bind(l_hum)
                end)
                
                bind(l_hum)
            end)
            p_flashback:Connect('Disabled', function() 
                fb_con:Disconnect()
                resp_con:Disconnect()
            end)
        end
        -- Respawn
        do 
            local resp_con
            local qdie_con
            p_respawn:Connect('Enabled', function() 
                local function bind(h) 
                    qdie_con = h.Died:Connect(function() 
                        h:Destroy()
                    end)
                end
                
                bind(l_hum)
                resp_con = l_plr.CharacterAdded:Connect(function(c) 
                    local h = c:WaitForChild('Humanoid',0.5)
                    if (h) then
                        bind(h) 
                    end
                end)
                
                if (l_hum.Health == 0) then
                    l_hum:Destroy()
                end
            end)
            p_respawn:Connect('Disabled',function() 
                resp_con:Disconnect()
                qdie_con:Disconnect()
            end)
        end
        -- Safe min
        do 
            local s_DetectMode = p_safemin:AddDropdown('Detection mode',true):SetTooltip('The method used to detect tabbing out. Leave on default unless detection stops working')
            s_DetectMode:AddOption('Default'):SetTooltip('Uses UserInputService to detect window minimizing. Some scripts may mess with this event!'):Select()
            s_DetectMode:AddOption('Backup'):SetTooltip('Uses isrbxactive to detect window minimizing. May not be compatible with every exploit')
            
            s_DetectMode:Connect('Changed',function()p_safemin:Reset();end)
            
            local freezecon
            local wincon1
            local wincon2
            
            p_safemin:Connect('Enabled', function() 
                local mode = s_DetectMode:GetSelection()
                
                if (mode == 'Default') then 
                    local focused = true 
                    wincon1 = serv_uinput.WindowFocused:Connect(function() 
                        focused = true
                    end)
                    wincon2 = serv_uinput.WindowFocusReleased:Connect(function() 
                        focused = false
                    end)
                    
                    con = serv_run.Heartbeat:Connect(function() 
                        l_humrp.Anchored = false
                        if (not focused) then 
                            l_humrp.Anchored = true
                        end
                    end)
                elseif (mode == 'Backup') then 
                    con = serv_run.Heartbeat:Connect(function() 
                        l_humrp.Anchored = false
                        if (not isrbxactive()) then 
                            l_humrp.Anchored = true
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
                new[2] = l_humrp.CFrame
                
                local a = inst_new('BillboardGui')
                local b = inst_new('BoxHandleAdornment')
                local c = inst_new('Part')
                local d = inst_new('TextLabel')
                
                
                c.Anchored = true
                c.CanCollide = false
                c.CanTouch = false
                c.Color = c_new(0,0,0)
                c.Name = getnext()
                c.Size = vec3(1, 1, 1)
                c.Position = new[2].Position
                c.Transparency = 1
                
                a.Adornee = c
                a.AlwaysOnTop = true
                a.LightInfluence = 0.8
                a.Size = dim_new(1.5, 30, 0.75, 15)
                
                b.Adornee = c
                b.AlwaysOnTop = false
                b.ZIndex = 10
                b.Color3 = c_new(0,0,0)
                b.Size = vec3(1, 200, 1)
                b.SizeRelativeOffset = vec3(0, 200, 0)
                b.Transparency = 0.5
                
                d.BackgroundColor3 = RLTHEMEDATA['bm'][1]
                d.BackgroundTransparency = 0.6
                d.BorderColor3 = RLTHEMEDATA['bm'][1]
                d.BorderSizePixel = 1
                d.Font = RLTHEMEFONT
                d.Size = dim_sca(1,1)
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
                
                tinsert(waypoints, new)
            end
            
            
            makewp:Connect('Unfocused',function(text) 
                if (not p_waypoints:IsEnabled()) then p_waypoints:Enable() end
                
                for i = 1, #waypoints do
                    local wp = waypoints[i]
                    if (wp[1] == text) then
                        for i = 3, 5 do wp[i]:Destroy() end
                        tremove(waypoints, i)
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
                        tremove(waypoints, i)
                        break
                    end
                end 
            end)
            
            gotowp:Connect('Unfocused',function(text) 
                for i = 1, #waypoints do
                    local wp = waypoints[i]
                    if (wp[1] == text) then
                        dnec(l_humrp.Changed, 'rp_changed')
                        dnec(l_humrp:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                        
                        l_humrp.CFrame = wp[2]
                        
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
                tclear(waypoints)
            end)
            
            p_waypoints:Connect('Enabled',function() 
                waypoints = {}
                
                folder = inst_new('Folder')
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
            
            deleall:SetTooltip('Deletes all waypoints. Preferable over untoggling and retoggling')
            makewp:SetTooltip('Makes a waypoint at your position with the name you type in')
            delewp:SetTooltip('Deletes all waypoints matching the name you type in')
        end
        
        --p_fancy:SetTooltip('Converts your chat letters into a fancier version. Has a toggleable mode and a non-toggleable mode')
        --p_ftools:SetTooltip('Lets you equip and unequip multiple tools at once')
        --p_gtweaks:SetTooltip('Lets you configure various misc 'forceable' settings like 3rd person, chat, inventories, and more')
        --p_pathfind:SetTooltip('Pathfinder. Kinda like Baritone')
        --p_radar:SetTooltip('Radar that displays where other players are')
        p_animspeed:SetTooltip('Increases the speed of your character animations. May mess with game logic')
        p_antiafk:SetTooltip('Prevents you from being kicked for idling. Make sure to report any problems to me! <i>May not work in games with custom AFK mechanics</i>')
        p_anticrash:SetTooltip('Prevents game scripts from while true do end\'ing you. Lets you bypass some clientside anticheats. <i>Doesn\'t work for certain uncommon methods</i>')
        p_antifling:SetTooltip('Prevents skids from flinging you. Only works on players, not other things like NPCs or in game objects / parts. <i>Doesn\'t work well for some reanimations yet</i>')
        p_antiwarp:SetTooltip('Prevents your character from being teleported (as in character movement, not a server change)')
        p_autoclick:SetTooltip('Automatically clicks for you. Can get up to around 2160 CPS (144 fps * 15 clicks p/ frame)')
        p_flag:SetTooltip('Makes your character look laggy. <b>Don\'t combine with blink!</b>')
        p_flashback:SetTooltip('Teleports you back to your death point after you die. Also known as DiedTP')
        p_respawn:SetTooltip('Deletes your humanoid whenever you die. Forces a respawn, acting as a better version of resetting. Can also fix certain permadeaths caused by reanimations')
        p_safemin:SetTooltip('Freezes your character whenever you tab out of your screen. <i>Don\'t combine this with antifling, instead use the antifling \'safemin + anchor\' mode</i>')
        p_waypoints:SetTooltip('Lets you save positions and teleport back to them later')
    end
    local m_movement = ui:CreateMenu('Movement') do 
        local m_airjump   = m_movement:AddMod('Air jump')
        local m_blink     = m_movement:AddMod('Blink')
        local m_clicktp   = m_movement:AddMod('Click TP')
        local m_dash      = m_movement:AddMod('Dash')
        local m_flight    = m_movement:AddMod('Flight')
        local m_float     = m_movement:AddMod('Float')
        local m_glide     = m_movement:AddMod('Glide')
        local m_highjump  = m_movement:AddMod('High jump')
        local m_noclip    = m_movement:AddMod('Noclip')
        local m_nofall    = m_movement:AddMod('Nofall')
        local m_notrip    = m_movement:AddMod('Notrip')
        local m_parkour   = m_movement:AddMod('Parkour')
        local m_speed     = m_movement:AddMod('Speed')
        local m_velocity  = m_movement:AddMod('Velocity')
        -- Airjump
        do 
            local mode = m_airjump:AddDropdown('Mode',true)
            mode:AddOption('Jump'):SetTooltip('Simply just jumps. If the game has something to prevent jumps, this will not work'):Select()
            mode:AddOption('Velocity'):SetTooltip('Changes your velocity. Bypasses jump prevention, but this is not as realistic as actually jumping')
            local velmount = m_airjump:AddSlider('Velocity amount', {min=-100,max=300,cur=70})
            
            local vel = 70
            local ajcon
            
            velmount:Connect('Changed',function(v)vel=v;end)
            
            m_airjump:Connect('Enabled', function() 
                if (mode:GetSelection() == 'Jump') then
                    ajcon = serv_uinput.InputBegan:Connect(function(io, gpe) 
                        if (gpe == false and io.KeyCode.Value == 32) then
                            l_hum:ChangeState(3)
                        end
                    end)
                else
                    ajcon = serv_uinput.InputBegan:Connect(function(io, gpe) 
                        if (gpe == false and io.KeyCode.Value == 32) then
                            l_humrp.Velocity = vec3(0, vel, 0)
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
            
            mode:SetTooltip('Mode for Airjump to use')
            velmount:SetTooltip('What your velocity gets set to when you jump (Velocity mode)')
        end
        -- Blink
        do 
            --local methoddd = m_blink:AddDropdown('Method',true)
            --methoddd:AddOption('Fake'):SetTooltip('Doesn\'t affect your network usage. Simply exploits a roblox glitch to freeze your character'):Select()
            --methoddd:AddOption('Network'):SetTooltip('Limits your actual network usage. Lags more than just your movement')
            
            
            
            -- Not my method, don't know the original creator
            
            local weld
            local seat
            
            m_blink:Connect('Enabled',function() 
                local thej = l_humrp.CFrame
                
                seat = inst_new('Seat')
                seat.Transparency = 1
                seat.CanTouch = false
                seat.CanCollide = false
                seat.CFrame = thej
                
                weld = inst_new('Weld')
                weld.Part0 = seat
                weld.Part1 = l_humrp
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
            local s_TPKey = m_clicktp:AddHotkey('Teleport key'):SetTooltip('The key you have to be holding in order to teleport')
            local s_Tween = m_clicktp:AddToggle('Tween'):SetTooltip('Tweens you to your mouse instead of teleporting')
            local s_TweenSpeed = m_clicktp:AddSlider('Tween speed', {min=0,max=50,cur=20,step=0.1}):SetTooltip('Speed of the tween')
            
            local Tween = s_Tween:GetValue()
            local TweenSpeed = (s_TweenSpeed:GetValue()*8)+50
            local TPKey = s_TPKey:GetValue()
            s_TPKey:Connect('HotkeySet',function(k)
                TPKey=k;
                m_clicktp:SetTooltip(('Teleports you to your mouse when you press %s Mouse1'):format(k and k.Name..' + ' or ''))
            end)
            s_Tween:Connect('Toggled',function(t)Tween=t;end)
            s_TweenSpeed:Connect('Changed',function(v)TweenSpeed=(v*8)+50;end)
            
            
            s_TPKey:SetHotkey(Enum.KeyCode.LeftControl)
            local MouseConnection
            m_clicktp:Connect('Enabled',function() 
                local offset = vec3(0, 3, 0)
                
                local function tp() 
                    local lv = l_humrp.CFrame.LookVector
                    local p = l_mouse.Hit.Position + offset
                    
                    local c = cfnew(p, p+lv)
                    if (Tween) then
                        local dist = (l_humrp.Position - c.Position).Magnitude
                        ctwn(l_humrp, {CFrame = c}, dist / TweenSpeed, 0, 1)
                    else
                        l_humrp.CFrame = c
                    end
                end
                
                MouseConnection = l_mouse.Button1Down:Connect(function() 
                    
                    if (TPKey) then
                        if (serv_uinput:IsKeyDown(TPKey)) then
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
            local s_DashSpeed = m_dash:AddSlider('Speed', {min=100,max=300,cur=150,step=0.1},true):SetTooltip('How much you get boosted')
            local s_DashSensitivity = m_dash:AddSlider('Tap sensitivity', {min=0.1,max=0.3,cur=0.22,step=0.01}):SetTooltip('The amount of time between button presses that\'s considered a dash')
            local s_Boost = m_dash:AddToggle('Boost'):SetTooltip('Boosts you up a bit when you dash, lets you go farther without needing to jump')
            local s_IncludeY = m_dash:AddToggle('Include Y'):SetTooltip('Includes the up axis when dashing, allows you to boost upwards when you look up')
            local s_Debounce = m_dash:AddToggle('Debounce'):SetTooltip('Adds a delay between dashes, stopping you from going too fast')
            
            local DashSpeed = s_DashSpeed:GetValue()
            local DashSensitivity = s_DashSensitivity:GetValue()
            local IncludeY = s_IncludeY:GetValue()
            local Boost = s_Boost:GetValue()
            local Debounce = s_Debounce:GetValue()
            
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
                        
                        
                        local lv = l_cam.CFrame.LookVector.Unit
                        local rv = l_cam.CFrame.RightVector.Unit
                        
                        local v = ((k == 'W' and lv) or (k == 'S' and -lv) or (k == 'A' and -rv) or (k == 'D' and rv))
                        v = (IncludeY and v or vec3(v.X, 0, v.Z).Unit)
                        v = (Boost and vec3(v.X, v.Y+0.15, v.Z) or v)
                        
                        l_humrp.Velocity += (v*DashSpeed)
                    end
                    
                    
                    input_con = serv_uinput.InputBegan:Connect(function(io, gpe) 
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
            local mode = m_flight:AddDropdown('Method', true)
            local turndir = m_flight:AddDropdown('Turn direction')
            local speedslider = m_flight:AddSlider('Speed',{min=0,max=250,step=0.01,cur=30})
            local camera = m_flight:AddToggle('Camera-based')
            
            
            mode:AddOption('Standard'):SetTooltip('Standard CFlight. Undetectable (within reason), unlike other scripts such as Inf Yield'):Select()
            mode:AddOption('Smooth'):SetTooltip('Just like Standard, but smooth')
            mode:AddOption('Vehicle'):SetTooltip('BodyPosition CFlight, may let you fly with vehicles in some games like Jailbreak. Has more protection than other scripts, but is still more detectable than Standard')
            
            
            turndir:AddOption('XYZ'):SetTooltip('Follows the camera\'s direction exactly. <b>This is the normal option you\'d see used for other scripts</b>'):Select()
            turndir:AddOption('XZ'):SetTooltip('Follows the camera\'s direction on all axes but Y')
            turndir:AddOption('Up'):SetTooltip('Faces straight up, useful for carrying players')
            turndir:AddOption('Down'):SetTooltip('I really hope you can figure this one out')
            
            local fi1 -- flight inst_new 1 
            local fi2 -- flight inst_new 2  
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
                clv = l_cam.CFrame.LookVector 
                normclv = clv
                
                dnec(l_humrp.Changed, 'rp_changed')
                dnec(l_humrp:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                dnec(l_humrp:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
                
                local curmod = mode:GetSelection()
                local curturn = turndir:GetSelection()
                
                local upp, downp, nonep = vec3(0, 1, 0), vec3(0, -1, 0), vec3(0,0,0)
                
                
                if (curturn == 'XYZ') then 
                    clvcon = l_cam:GetPropertyChangedSignal('CFrame'):Connect(function() 
                        normclv = l_cam.CFrame.LookVector
                        clv = normclv
                    end)
                elseif (curturn == 'XZ') then
                    clvcon = l_cam:GetPropertyChangedSignal('CFrame'):Connect(function() 
                        normclv = l_cam.CFrame.LookVector
                        clv = vec3(normclv.X, 0, normclv.Z)
                    end)
                elseif (curturn == 'Up') then
                    if (cambased) then
                        clvcon = l_cam:GetPropertyChangedSignal('CFrame'):Connect(function() 
                            normclv = l_cam.CFrame.LookVector
                        end)
                    end
                    
                    clv = upp
                elseif (curturn == 'Down') then
                    if (cambased) then
                        clvcon = l_cam:GetPropertyChangedSignal('CFrame'):Connect(function() 
                            normclv = l_cam.CFrame.LookVector
                        end)
                    end
                    
                    clv = downp
                end
                
                if (curmod == 'Standard') then
                    local base = l_humrp.CFrame
                    
                    
                    if (cambased) then
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = serv_uinput:IsKeyDown(ask)
                            local IsDownPressed = serv_uinput:IsKeyDown(dsk)
                            local IsForwardPressed = serv_uinput:IsKeyDown(119)
                            local IsBackwardPressed = serv_uinput:IsKeyDown(115)
                            
                            -- Keep character frozen
                            l_hum:ChangeState(1)
                            l_humrp.Velocity = nonep
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                l_hum.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) + -- If down is pressed
                                
                                (IsForwardPressed and vec3(0, normclv.Y, 0) or nonep) + -- If forward is pressed
                                (IsBackwardPressed and vec3(0, -normclv.Y, 0) or nonep) -- If backward is pressed
                            ) * Delta)
                            
                            base += Vector
                            
                            local Position = base.Position
                            l_humrp.CFrame = cfnew(Position, Position + clv)
                        end)
                    else
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = serv_uinput:IsKeyDown(ask)
                            local IsDownPressed = serv_uinput:IsKeyDown(dsk)
                            
                            -- Keep character frozen
                            l_hum:ChangeState(1)
                            l_humrp.Velocity = nonep
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = (
                                l_hum.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) -- If down is presed
                            ) * Delta
                            
                            base += Vector
                            
                            local Position = base.Position
                            l_humrp.CFrame = cfnew(Position, Position + clv)
                        end)
                    end
                elseif (curmod == 'Smooth') then
                    local base = l_humrp.CFrame
                    
                    fi1 = inst_new('Part')
                    fi1.CFrame = base
                    fi1.Transparency = 1
                    fi1.CanCollide = false
                    fi1.CanTouch = false
                    fi1.Anchored = false
                    fi1.Size = vec3(1, 1, 1)
                    fi1.Parent = workspace
                    
                    local pos = inst_new('BodyPosition')
                    pos.Position = base.Position
                    pos.D = 1900
                    pos.P = 125000
                    pos.MaxForce = vec3(9e9, 9e9, 9e9)
                    pos.Parent = fi1
                    local gyro = inst_new('BodyGyro')
                    gyro.D = 1900
                    gyro.P = 125000
                    gyro.MaxTorque = vec3(9e9, 9e9, 9e9)
                    gyro.Parent = fi1
                    
                    if (cambased) then
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = serv_uinput:IsKeyDown(ask)
                            local IsDownPressed = serv_uinput:IsKeyDown(dsk)
                            local IsForwardPressed = serv_uinput:IsKeyDown(119)
                            local IsBackwardPressed = serv_uinput:IsKeyDown(115)
                            
                            -- Keep character frozen
                            l_hum:ChangeState(1)
                            l_humrp.Velocity = nonep
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                l_hum.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) + -- If down is pressed
                                
                                (IsForwardPressed and vec3(0, normclv.Y, 0) or nonep) + -- If forward is pressed
                                (IsBackwardPressed and vec3(0, -normclv.Y, 0) or nonep) -- If backward is pressed
                            ) * Delta)
                            
                            base += Vector
                            
                            local Position = base.Position
                            pos.Position = Position
                            gyro.CFrame = cfnew(Position, Position + clv)
                            l_humrp.CFrame = fi1.CFrame   
                        end)
                    else
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = serv_uinput:IsKeyDown(ask)
                            local IsDownPressed = serv_uinput:IsKeyDown(dsk)
                            
                            -- Keep character frozen
                            l_hum:ChangeState(1)
                            l_humrp.Velocity = nonep
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = (
                                l_hum.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) -- If down is presed
                            ) * Delta
                            
                            base += Vector
                            
                            local Position = base.Position
                            pos.Position = Position
                            gyro.CFrame = cfnew(Position, Position + clv)
                            l_humrp.CFrame = fi1.CFrame                   
                        end)
                    end
                elseif (curmod == 'Vehicle') then
                    local base = l_humrp.CFrame
                    
                    dnec(l_humrp.ChildAdded, 'rp_child')
                    dnec(l_humrp.DescendantAdded, 'rp_desc')
                    dnec(l_chr.DescendantAdded, 'chr_desc')
                    
                    fi1 = inst_new('BodyPosition')
                    fi1.Position = base.Position
                    fi1.D = 1900
                    fi1.P = 125000
                    fi1.MaxForce = vec3(9e9, 9e9, 9e9)
                    fi1.Parent = l_humrp
                    
                    fi2 = inst_new('BodyGyro')
                    fi2.D = 1900
                    fi2.P = 125000
                    fi2.MaxTorque = vec3(9e9, 9e9, 9e9)
                    fi2.Parent = l_humrp
                    
                    
                    if (cambased) then
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = serv_uinput:IsKeyDown(ask)
                            local IsDownPressed = serv_uinput:IsKeyDown(dsk)
                            local IsForwardPressed = serv_uinput:IsKeyDown(119)
                            local IsBackwardPressed = serv_uinput:IsKeyDown(115)
                            
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                l_hum.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) + -- If down is pressed
                                
                                (IsForwardPressed and vec3(0, normclv.Y, 0) or nonep) + -- If forward is pressed
                                (IsBackwardPressed and vec3(0, -normclv.Y, 0) or nonep) -- If backward is pressed
                            ) * Delta)
                            
                            base += Vector
                            
                            local Position = base.Position
                            fi1.Position = Position
                            fi2.CFrame = cfnew(Position, Position + clv)
                            
                            l_cam.CameraSubject = l_hum
                        end)
                    else
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = serv_uinput:IsKeyDown(ask)
                            local IsDownPressed = serv_uinput:IsKeyDown(dsk)
                            
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                l_hum.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) -- If down is pressed
                            ) * Delta)
                            
                            base += Vector
                            
                            local Position = base.Position
                            fi1.Position = Position
                            fi2.CFrame = cfnew(Position, Position + clv)      
                            
                            l_cam.CameraSubject = l_hum
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
                        l_hum:ChangeState(8)
                    end
                    
                    fi2:Destroy() 
                    fi2 = nil 
                else
                    l_hum:ChangeState(8)
                end
                
                
                enec('rp_changed')
                enec('rp_cframe')
                enec('rp_velocity')
                enec('rp_child')
                enec('rp_desc')
                enec('chr_desc')
                    
            end)
            
            
            ascend_h:SetTooltip('When pressed you vertically ascend (move up)'):SetHotkey(Enum.KeyCode.E)
            descend_h:SetTooltip('When pressed you vertically descend (move down)'):SetHotkey(Enum.KeyCode.Q)
            mode:SetTooltip('The method Flight uses')
            speedslider:SetTooltip('The speed of your flight')
            camera:SetTooltip('When enabled, the direction of your camera affects your Y movement. <b>This is the normal option you\'d see used for other scripts</b>')
            turndir:SetTooltip('The direction your character faces')
        end
        -- Float
        do 
            local mode = m_float:AddDropdown('Mode'):SetTooltip('What method Float will use')
            mode:AddOption('Undetectable'):SetTooltip('Directly changes your velocity. Isn\'t perfect, but it\'s undetectable'):Select()
            mode:AddOption('Velocity'):SetTooltip('Uses a bodymover. Has better results, but is easier to detect')
            
            local vel = m_float:AddSlider('Velocity',{min=-10,cur=0,max=10,step=0.1}):SetTooltip('The amount of velocity you\'ll have when floating')
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
                    fcon = serv_run.Heartbeat:Connect(function() 
                        local vel = l_humrp.Velocity
                        
                        l_humrp.Velocity = vec3(vel.X, amnt+1.15, vel.Z)
                    end)
                elseif (mode == 'Velocity') then
                    dnec(l_humrp.ChildAdded, 'rp_child')
                    dnec(l_humrp.DescendantAdded, 'rp_desc')
                    dnec(l_chr.DescendantAdded, 'chr_desc')
                    
                    finst = inst_new('BodyVelocity')
                    finst.MaxForce = vec3(0, 9e9, 0)
                    finst.Velocity = vec3(0, vel:GetValue(), 0)
                    finst.Parent = l_humrp
                    
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
        -- Glide
        do 
            local s_Amount = m_glide:AddSlider('Glide amount',{min=-25,max=-1,step=0.1,cur=-5},true):SetTooltip('How much your downwards velocity gets limited to')
            local Amount = s_Amount:GetValue()
            
            s_Amount:Connect('Changed',function(v)Amount=v;end)
            
            
            local GlideCon
            m_glide:Connect('Enabled',function() 
                dnec(l_humrp.Changed, 'rp_changed')
                dnec(l_humrp:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
                
                GlideCon = serv_run.Heartbeat:Connect(function() 
                    local vel = l_humrp.Velocity
                    l_humrp.Velocity = vec3(vel.X, mclamp(vel.Y, Amount, 9e9), vel.Z)
                end)
            end)
            m_glide:Connect('Disabled',function() 
                if (GlideCon) then GlideCon:Disconnect() GlideCon = nil end
                
                enec('rp_changed')
                enec('rp_velocity')
            end)
        end
        -- High jump
        do 
            local s_Mode = m_highjump:AddDropdown('Method',true):SetTooltip('The method Highjump uses')
            s_Mode:AddOption('Velocity'):SetTooltip('Increases your vertical velocity when you jump'):Select()
            s_Mode:AddOption('JumpPower'):SetTooltip('Changes your characters JumpPower property. Is easily detectable, so don\'t use this unless you know what you\'re doing') 
            
            local s_Amount = m_highjump:AddSlider('Amount',{min=50,max=300,cur=75,step=0.1},true):SetTooltip('How much your jumps get boosted')
            
            local Amount = s_Amount:GetValue()
            
            s_Mode:Connect('Changed',function()m_highjump:Reset()end)
            s_Amount:Connect('Changed',function(v)Amount=v;end)
            
            local JumpCon
            local OldJumpPow
            local OldUseJP
            
            m_highjump:Connect('Enabled', function() 
                if (s_Mode:GetSelection() == 'Velocity') then
                    JumpCon = l_hum.StateChanged:Connect(function(old, new) 
                        if (new.Value == 3) then
                            l_humrp.Velocity += vec3(0, Amount, 0)
                        end
                    end)
                else
                    OldJumpPow = l_hum.JumpPower
                    OldUseJP = l_hum.UseJumpPower
                    
                    dnec(l_hum:GetPropertyChangedSignal('JumpPower'), 'hum_jp')
                    dnec(l_hum:GetPropertyChangedSignal('UseJumpPower'), 'hum_ujp')
                    
                    JumpCon = serv_run.Heartbeat:Connect(function() 
                        l_hum.UseJumpPower = true
                        l_hum.JumpPower = Amount
                    end)
                end
            end)
            m_highjump:Connect('Disabled',function() 
                if (JumpCon) then JumpCon:Disconnect() JumpCon = nil end
                
                if (OldJumpPow) then
                    l_hum.JumpPower = OldJumpPow
                    l_hum.UseJumpPower = OldUseJP
                    OldJumpPow = nil
                    OldUseJP = nil
                end
                
                enec('hum_jp')
                enec('hum_ujp')
            end)
        end
        -- Noclip
        do 
            local s_Mode = m_noclip:AddDropdown('Method', true):SetTooltip('The method Noclip uses')
            s_Mode:AddOption('Standard'):SetTooltip('The average CanCollide noclip'):Select()
            s_Mode:AddOption('Legacy'):SetTooltip('Emulates the older HumanoidState noclip (Just standard, but with a float effect)')
            s_Mode:AddOption('Teleport'):SetTooltip('Teleports you through walls')
            s_Mode:AddOption('Bypass'):SetTooltip('May bypass certain serverside anticheats that rely on the direction you\'re facing')
            
            local s_LookAhead = m_noclip:AddSlider('Lookahead',{min=2,cur=4,max=15,step=0.1}):SetTooltip('The amount of distance between a wall Teleport will consider noclipping')
            
            local LookAhead = s_LookAhead:GetValue()
            s_LookAhead:Connect('Changed',function(v) LookAhead = v end)
            
            
            local Con_Respawn
            local Con_Step
            
            local p = RaycastParams.new()
            p.FilterDescendantsInstances = {l_chr}
            p.FilterType = Enum.RaycastFilterType.Blacklist
            
            s_Mode:Connect('Changed',function()m_noclip:Reset()end)
            
            local loopid
            
            m_noclip:Connect('Enabled', function() 
                loopid = mrandom(1,999999)
                local mode = s_Mode:GetSelection()
                
                if (mode == 'Standard') then
                    local NoclipObjects = {}
                    
                    local c = l_chr:GetChildren()
                    for i = 1, #c do
                        local obj = c[i]
                        if ((obj == nil) or (obj:IsA('BasePart') == false)) then continue end 
                        tinsert(NoclipObjects, obj)
                    end
                    
                    
                    Con_Respawn = l_plr.CharacterAdded:Connect(function(chr) 
                        wait(0.15)
                        
                        tclear(NoclipObjects)
                        local c = l_chr:GetChildren()
                        for i = 1, #c do
                            local obj = c[i]
                            if ((obj == nil) or (obj:IsA('BasePart') == false)) then continue end 
                            tinsert(NoclipObjects, obj)
                        end
                    end)
                    
                    Con_Step = serv_run.Stepped:Connect(function() 
                        for i = 1, #NoclipObjects do 
                            NoclipObjects[i].CanCollide = false 
                        end
                    end)
                    
                elseif (mode == 'Legacy') then
                    local NoclipObjects = {}
                    
                    local c = l_chr:GetChildren()
                    for i = 1, #c do
                        local obj = c[i]
                        if ((obj == nil) or (obj:IsA('BasePart') == false)) then continue end 
                        tinsert(NoclipObjects, obj)
                    end
                    
                    
                    Con_Respawn = l_plr.CharacterAdded:Connect(function(chr) 
                        wait(0.15)
                        
                        tclear(NoclipObjects)
                        local c = l_chr:GetChildren()
                        for i = 1, #c do
                            local obj = c[i]
                            if ((obj == nil) or (obj:IsA('BasePart') == false)) then continue end 
                            tinsert(NoclipObjects, obj)
                        end
                    end)
                    
                    Con_Step = serv_run.Stepped:Connect(function() 
                        local vel = l_humrp.Velocity
                        l_humrp.Velocity = vec3(vel.X, 0.3, vel.Z)
                        for i = 1, #NoclipObjects do 
                            NoclipObjects[i].CanCollide = false 
                        end
                    end)
                
                elseif (mode == 'Teleport') then
                    local p = RaycastParams.new()
                    p.FilterDescendantsInstances = {l_chr}
                    p.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    Con_Respawn = l_plr.CharacterAdded:Connect(function(c) 
                        p.FilterDescendantsInstances = {c}
                    end)
                    
                    dnec(l_humrp.Changed, 'rp_changed')
                    dnec(l_humrp:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                    
                    Con_Respawn = l_plr.CharacterAdded:Connect(function() 
                        m_noclip:Reset()
                    end)
                    
                    Con_Step = serv_run.Heartbeat:Connect(function() 
                        local c = l_humrp.CFrame
                        local lv = c.LookVector
                        c = c.Position
                        local m = l_hum.MoveDirection.Unit
                        
                        local j = workspace:Raycast(c, m*LookAhead, p)
                        if (j) then
                            local t = j.Position + (m * (j.Distance/2))
                            
                            l_humrp.CFrame = cfnew(t, t + lv)
                        end
                    end)
                elseif (mode == 'Bypass') then
                    local p = RaycastParams.new()
                    p.FilterDescendantsInstances = {l_chr}
                    p.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    Con_Respawn = l_plr.CharacterAdded:Connect(function(c) 
                        p.FilterDescendantsInstances = {c}
                    end)
                    
                    dnec(l_humrp.Changed, 'rp_changed')
                    dnec(l_humrp:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                    
                    
                    
                    Con_Respawn = l_plr.CharacterAdded:Connect(function() 
                        m_noclip:Reset()
                    end)
                    
                    local lid = loopid
                    spawn(function()
                        while m_noclip:IsEnabled() and lid == loopid do
                            local c = l_humrp.CFrame
                            local lv = c.LookVector
                            c = c.Position
                            local m = l_hum.MoveDirection.Unit
                            
                            local j = workspace:Raycast(c, m*LookAhead, p)
                            if (j) then
                                l_humrp.CFrame = cfnew(c, c - lv)
                                l_humrp.Anchored = true
                                wait(0.1) 
                                l_humrp.Anchored = false
                                local t = j.Position + (m * (j.Distance/2))
                                l_humrp.CFrame = cfnew(t, t + lv)
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
            local s_Mode = m_nofall:AddDropdown('Mode', true):SetTooltip('The method Nofall uses')
            s_Mode:AddOption('Drop'):SetTooltip('Instantly teleports you down once you start falling. Works in games like Natural Disaster Survival'):Select()
            s_Mode:AddOption('Decelerate'):SetTooltip('Slows you down before you hit the ground. Doesn\'t work very well, but atleast its here')
            s_Mode:AddOption('Boost'):SetTooltip('Boosts you up a bit before you hit the ground')
            
            local s_BoostSens = m_nofall:AddSlider('Sensitivity (Boost)',{min=30,max=300,cur=100,step=0.1}):SetTooltip('How fast you need to be falling before Boost can boost you')
            local s_DropSens = m_nofall:AddSlider('Sensitivity (Drop)',{min=5,max=50,cur=10,step=0.1}):SetTooltip('How high up you have to be above the ground before Drop will teleport you')
            local s_DecelSens = m_nofall:AddSlider('Sensitivity (Decelerate)',{min=1,max=20,cur=10,step=0.1}):SetTooltip('How close you have to be to the ground before Decelerate will start slowing your fall')
            
            local BoostSens = -(s_BoostSens:GetValue())
            local DropSens = s_DropSens:GetValue()
            local DecelSens = s_DecelSens:GetValue()
            
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
                    dnec(l_humrp.Changed, 'rp_changed')
                    dnec(l_humrp:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                    local down = vec3(0, -1000000, 0)
                    local p = RaycastParams.new()
                    p.FilterDescendantsInstances = {l_chr}
                    p.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    plrcon = l_plr.CharacterAdded:Connect(function(c) 
                        p.FilterDescendantsInstances = {c}
                    end)
                    
                    
                    rcon = serv_run.Heartbeat:Connect(function() 
                        local j = workspace:Raycast(l_humrp.Position, down, p)
                        if (j and j.Distance > DropSens) then
                            local hv = l_humrp.Velocity
                            
                            if (hv.Y < 0) then
                                local p = j.Position
                                l_humrp.CFrame = cfnew(p, p + l_humrp.CFrame.LookVector)
                                l_humrp.Velocity = vec3(hv.X, 20, hv.Z)
                            end
                        end
                    end)
                elseif (CurrentMode == 'Decelerate') then
                    dnec(l_humrp:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
                    dnec(l_humrp.Changed, 'rp_changed')
                    
                    local down = vec3(0, -1000000, 0)
                    local p = RaycastParams.new()
                    p.FilterDescendantsInstances = {l_chr}
                    p.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    plrcon = l_plr.CharacterAdded:Connect(function(c) 
                        p.FilterDescendantsInstances = {c}
                    end)
                    
                    
                    rcon = serv_run.Heartbeat:Connect(function(dt) 
                        local j = workspace:Raycast(l_humrp.Position, down, p)
                        if (j and j.Distance < DecelSens) then
                            local hv = l_humrp.Velocity
                            local y = hv.Y
                            if (y < -5) then
                                l_humrp.Velocity = vec3(hv.X, y * 0.7, hv.Z)
                            end
                        end
                    end)
                elseif (CurrentMode == 'Boost') then 
                    local holding = false
                    local down = vec3(0, -1000000, 0)
                    local p = RaycastParams.new()
                    p.FilterDescendantsInstances = {l_chr}
                    p.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    plrcon = l_plr.CharacterAdded:Connect(function(c) 
                        p.FilterDescendantsInstances = {c}
                    end)
                    
                    rcon = serv_run.Heartbeat:Connect(function()
                        if (holding) then return end
                        local j = workspace:Raycast(l_humrp.Position, down, p)
                        
                        if (j and j.Distance < 8) then
                            local hv = l_humrp.Velocity
                            
                            if (hv.Y < BoostSens) then
                                l_humrp.Velocity = vec3(hv.X, 30, hv.Z)
                                
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
                if (l_hum) then
                    hook(l_hum)
                end
                
                Con_Respawn = l_plr.CharacterAdded:Connect(function(c) 
                    local hum = c:WaitForChild('Humanoid',5)
                    hook(hum)
                end)
            end)
            m_notrip:Connect('Disabled',function() 
                Con_Respawn:Disconnect()
                
                if (l_hum) then
                    l_hum:SetStateEnabled(0, true)
                    l_hum:SetStateEnabled(1, true)
                    l_hum:SetStateEnabled(16, true) 
                end
            end)
        end
        -- Parkour
        do 
            local delayslid = m_parkour:AddSlider('Delay before jumping',{min=0,max=0.2,cur=0,step=0.01}):SetTooltip('How long to wait before jumping')
            local delay = 0
            local humcon
            
            delayslid:Connect('Changed',function(v)delay=v;end)
            
            m_parkour:Connect('Toggled',function(t) 
                if (t) then
                    local a = Enum.Material.Air
                    humcon = l_hum:GetPropertyChangedSignal('FloorMaterial'):Connect(function() 
                        if (l_hum.FloorMaterial == a) then
                            if (delay == 0) then
                                if (l_hum.Jump) then return end
                                l_hum:ChangeState(3)
                            else
                                wait(delay)
                                if (l_hum.Jump) then return end
                                l_hum:ChangeState(3)
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
            local mode = m_speed:AddDropdown('Mode',true)
            mode:AddOption('Standard'):SetTooltip('Standard CFrame speed. <b>Mostly</b> undetectable, unlike other scripts such as Inf Yield. Also known as TPWalk'):Select()
            mode:AddOption('Velocity'):SetTooltip('Changes your velocity, doesn\'t use any bodymovers. Because of friction, Velocity typically won\'t increase your speed unless it\'s set high or you jump.')
            mode:AddOption('Bhop'):SetTooltip('The exact same as Velocity, but it spam jumps. Useful for looking legit in games with bhop mechanics, like Arsenal')
            mode:AddOption('Part'):SetTooltip('Pushes you physically with a clientside part. Can also affect vehicles in certain games, such as Jailbreak')
            mode:AddOption('WalkSpeed'):SetTooltip('<font color="rgb(255,64,64)"><b>Insanely easy to detect. Use Standard instead.</b></font>')
            
            local speedslider = m_speed:AddSlider('Speed',{min=0,max=100,cur=30,step=0.01})
            local speed = 30
            speedslider:Connect('Changed',function(v)speed=v;end)
            local part
            local scon
                    
            m_speed:Connect('Enabled',function() 
                local mode = mode:GetSelection()
                
                dnec(l_hum.Changed, 'hum_changed')
                dnec(l_hum:GetPropertyChangedSignal('Jump'), 'hum_jump')
                dnec(l_humrp.Changed, 'rp_changed')
                dnec(l_humrp:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                dnec(l_humrp:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
                
                if (scon) then scon:Disconnect() scon = nil end
                
                if (mode == 'Standard') then
                    scon = serv_run.Heartbeat:Connect(function(dt) 
                        l_humrp.CFrame += l_hum.MoveDirection * (5 * dt * speed)
                    end)
                elseif (mode == 'Velocity') then
                    scon = serv_run.Heartbeat:Connect(function(dt) 
                        l_humrp.Velocity += l_hum.MoveDirection * (5 * dt * speed)
                    end)
                elseif (mode == 'Bhop') then
                    scon = serv_run.RenderStepped:Connect(function(dt) 
                        local md = l_hum.MoveDirection
                        
                        l_humrp.Velocity += md * (5 * dt * speed)
                        l_hum.Jump = not (md.Magnitude < 0.01 and true or false)
                    end)
                elseif (mode == 'Part') then
                    part = inst_new('Part')
                    part.Transparency = 0.8
                    part.Size = vec3(4,4,1)
                    part.CanTouch = false
                    part.CanCollide = true
                    part.Anchored = false
                    part.Name = getnext()
                    part.Parent = workspace
                    scon = ev:Connect(function(dt) 
                        local md = l_hum.MoveDirection
                        local p = l_humrp.Position
                        
                        part.CFrame = cfnew(p-(md), p)
                        part.Velocity = md * (dt * speed * 1200)
                        
                        l_hum:ChangeState(8)
                    end)
                elseif (mode == 'WalkSpeed') then
                    dnec(l_hum:GetPropertyChangedSignal('WalkSpeed'), 'hum_walk')
                    
                    scon = serv_run.Heartbeat:Connect(function() 
                        l_hum.WalkSpeed = speed
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
            
            mode:SetTooltip('Method used for the speedhack')
            speedslider:SetTooltip('Amount of speed')
        end
        -- Velocity
        do 
            local xslider = m_velocity:AddSlider('X',{min=0,max=100,cur=20,step=0.01}):SetTooltip('The minimum / max X velocity you can have')
            local yslider = m_velocity:AddSlider('Y',{min=0,max=100,cur=20,step=0.01}):SetTooltip('The minimum / max Y velocity you can have')
            local zslider = m_velocity:AddSlider('Z',{min=0,max=100,cur=20,step=0.01}):SetTooltip('The minimum / max Z velocity you can have')
            
            local x,y,z = 20,20,20
            
            xslider:Connect('Changed',function(v)x=v;end)
            yslider:Connect('Changed',function(v)y=v;end)
            zslider:Connect('Changed',function(v)z=v;end)
            
            local velc
            m_velocity:Connect('Enabled',function() 
                velc = serv_run.Stepped:Connect(function() 
                    local v = l_humrp.Velocity
                    l_humrp.Velocity = vec3(
                        mclamp(v.X,-x,x),
                        mclamp(v.Y,-y,y),
                        mclamp(v.Z,-z,z)
                    )
                end)
            end)
            
            m_velocity:Connect('Disabled',function() 
                if (velc) then velc:Disconnect() velc = nil end
            end)
        end
        
        m_airjump:SetTooltip('Lets you jump in mid-air, infinitely. May bypass any jump restrictions the game has in place')
        m_blink:SetTooltip('Freezes your character for other people. <b>Do not combine with fakelag.</b>')
        m_clicktp:SetTooltip('You can\'t see this lololololololo')
        m_dash:SetTooltip('Allows you to dash by double tapping W, A, S, or D')
        m_flight:SetTooltip('Makes your character fly')
        m_float:SetTooltip('Makes your character stop falling entirely. <i>Yes, this is basically the same as Glide, i dont care</i>')
        m_glide:SetTooltip('Slows down your fall, letting you jump farther')
        m_highjump:SetTooltip('Increases how high you can jump')
        m_noclip:SetTooltip('Disables your character\'s collision, or bypasses the collision entirely')
        m_nofall:SetTooltip('May bypass some games fall damage mechanics by changing how you fall.')
        m_notrip:SetTooltip('Prevents you from tripping / ragdolling, like when you get by a fast part')
        m_parkour:SetTooltip('Jumps when you reach the end of a part')
        m_speed:SetTooltip('Speedhacks with various bypasses and settings')
        m_velocity:SetTooltip('Limits your velocity')
    end
    local m_render = ui:CreateMenu('Render') do 
        local CrosshairPosition
        
        local r_crosshair   = m_render:AddMod('Crosshair')
        local r_esp         = m_render:AddMod('ESP'..betatxt)
        local r_freecam     = m_render:AddMod('Freecam')
        local r_fullbright  = m_render:AddMod('Fullbright')
        local r_keystrokes  = m_render:AddMod('Keystrokes'..betatxt)
        local r_ugpu        = m_render:AddMod('Unfocused GPU')
        local r_zoom        = m_render:AddMod('Zoom')
        
        -- Crosshair
        do 
            local s_Size = r_crosshair:AddSlider('Size',{min=5,max=15,cur=7,step=1}):SetTooltip('The size of the crosshair circle')
            local s_Speed = r_crosshair:AddSlider('Speed',{min=0,max=10,cur=4,step=0.1}):SetTooltip('The speed of the rotation effect')
            local s_AccuracyMult = r_crosshair:AddSlider('Spread multiplier',{min=0.01,max=1.5,step=0.01,cur=0.05}):SetTooltip('How sensitive the spread effect is')
            local s_Accuracy = r_crosshair:AddToggle('Spread'):SetTooltip('Emulates bullet spread by changing the crosshair arm distance based off of your velocity')
            
            local s_Style = r_crosshair:AddDropdown('Style'):SetTooltip('The crosshair design used')
            local s_RotStyle = r_crosshair:AddDropdown('Animation'):SetTooltip('The animation used')
            
            local s_Status = r_crosshair:AddToggle('Aimbot status'):SetTooltip('Shows a status underneath the crosshair indicating what it\'s doing. For the aimbot module')
            
            s_Style:AddOption('2 arms'):SetTooltip('Has 2 arms with a ring'):Select()
            s_Style:AddOption('4 arms'):SetTooltip('Has 4 arms with a ring')
            s_Style:AddOption('2 arms (no ring)'):SetTooltip('Has just 2 arms without any ring')
            s_Style:AddOption('4 arms (no ring)'):SetTooltip('Has just 4 arms without any ring')
        
            s_RotStyle:AddOption('Swing'):SetTooltip('Swings back and forth'):Select()
            s_RotStyle:AddOption('Spin'):SetTooltip('Constantly spins at a linear speed')
            s_RotStyle:AddOption('3d'):SetTooltip('Does a cool 3d spin thing')
            s_RotStyle:AddOption('None'):SetTooltip('No animation')
            
            
            local Accuracy = s_Accuracy:IsEnabled()
            local AccuracyMult = s_AccuracyMult:GetValue()
            local Size = s_Size:GetValue()
            local Speed = s_Speed:GetValue()
            local Status = s_Status:IsEnabled()
            
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
            
            local vpcen = l_cam.ViewportSize / 2 
            
            r_crosshair:Connect('Enabled', function() 
                stop = false
                local m = s_Style:GetSelection()
                local r = s_RotStyle:GetSelection()
                
                local sin, cos = math.sin, math.cos
                
                local InnerLine1 = draw_new('Line')
                local InnerLine2 = draw_new('Line')
                local InnerLine3 = draw_new('Line')
                local InnerLine4 = draw_new('Line')
                local InnerRing = draw_new('Circle')
                local OuterLine1 = draw_new('Line')
                local OuterLine2 = draw_new('Line')
                local OuterLine3 = draw_new('Line')
                local OuterLine4 = draw_new('Line')
                local OuterRing = draw_new('Circle')
                local StatusText = draw_new('Text')
                
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
                    
                    OuterRing.Color = c_new(0,0,0)
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
                    OuterLine1.Color = c_new(0,0,0)
                    OuterLine1.Thickness = 4
                    OuterLine1.ZIndex = 52
                    
                    InnerLine2.Thickness = 2
                    InnerLine2.ZIndex = 53
                    OuterLine2.Color = c_new(0,0,0)
                    OuterLine2.Thickness = 4
                    OuterLine2.ZIndex = 52
                    
                    InnerLine3.Thickness = 2
                    InnerLine3.ZIndex = 53
                    OuterLine3.Color = c_new(0,0,0)
                    OuterLine3.Thickness = 4
                    OuterLine3.ZIndex = 52
                    
                    InnerLine4.Thickness = 2
                    InnerLine4.ZIndex = 53
                    OuterLine4.Color = c_new(0,0,0)
                    OuterLine4.Thickness = 4
                    OuterLine4.ZIndex = 52
                    
                    StatusText.Center = true
                    StatusText.Font = 1
                    StatusText.Outline = true
                    StatusText.OutlineColor = c_new(0,0,0)
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
                    animcon = serv_run.RenderStepped:Connect(function(dt) 
                        if stop then return end
                        t += dt
                        
                        local c = RGBCOLOR--c_hsv((t*0.02)%1,1,1)
                        v = v + ((3 + (Accuracy and l_humrp and mclamp(l_humrp.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
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
                    
                    animcon = serv_run.RenderStepped:Connect(function(dt) 
                        if stop then return end
                        t += dt
                        
                        local c = RGBCOLOR--c_hsv((t*0.02)%1,1,1)
                        
                        v = v + ((3 + (Accuracy and l_humrp and mclamp(l_humrp.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
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
                    animcon = serv_run.RenderStepped:Connect(function(dt) 
                        if stop then return end
                        t += dt
                        
                        -- ignore the shitty ass variable names
                        -- (problem? :troll)
                        
                        
                        local c = RGBCOLOR
                        v = v + ((3 + (Accuracy and l_humrp and mclamp(l_humrp.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
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
                    animcon = serv_run.RenderStepped:Connect(function(dt) 
                        if stop then return end
                        t += dt
                        
                        local c = RGBCOLOR--c_hsv((t*0.02)%1,1,1)
                        v = v + ((3 + (Accuracy and l_humrp and mclamp(l_humrp.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
                    
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
                
                moncon = l_cam:GetPropertyChangedSignal('ViewportSize'):Connect(function() 
                    vpcen = l_cam.ViewportSize / 2
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
                    local msg = msgs[mrandom(1, #msgs)]
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
            local mode = r_freecam:AddDropdown('Method', true)
            local freezemode = r_freecam:AddDropdown('Freeze mode')
            -- sliders 
            local speedslider = r_freecam:AddSlider('Speed',{min=0,max=300,step=0.1,cur=30})
            -- buttons
            local gotocam = r_freecam:AddButton('Goto freecam')
            local resetcam = r_freecam:AddButton('Reset freecam position')
            -- toggles
            local camera = r_freecam:AddToggle('Camera-based')
            local resetonenable = r_freecam:AddToggle('Reset pos on enable')
            
            
            mode:AddOption('Standard'):SetTooltip('Standard freecam'):Select()
            mode:AddOption('Smooth'):SetTooltip('Just like Standard, but smooth')  
            mode:AddOption('Bypass'):SetTooltip('<b>Currently unfinished.</b> May bypass some anticheats / game mechanics that break freecam, but it\'s extremely janky')      
            freezemode:AddOption('Anchor'):SetTooltip('Anchors your character'):Select()
            freezemode:AddOption('Walkspeed'):SetTooltip('Sets your walkspeed to 0')
            freezemode:AddOption('Stuck'):SetTooltip('Constantly overwrites your position')
            
            local campart -- camera part
            local fcon -- flight connection
            local clvcon -- clv connection
            
            local ask = Enum.KeyCode.E-- keycode for ascension
            local dsk = Enum.KeyCode.Q-- keycode for descension
            
            local fcampos = l_humrp and l_humrp.Position or vec3(0,0,0)        
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
                
                if (resetonenable:IsEnabled()) then
                    fcampos = l_humrp.Position
                end
                
                local normclv = l_cam.CFrame.LookVector
                clvcon = l_cam:GetPropertyChangedSignal('CFrame'):Connect(function() 
                    normclv = l_cam.CFrame.LookVector
                end)
                
                if (curmod == 'Standard') then
                    campart = inst_new('Part')
                    campart.Position = fcampos
                    campart.Transparency = 1
                    campart.CanCollide = false
                    campart.CanTouch = false
                    campart.Anchored = true
                    campart.Size = vec3(1, 1, 1)
                    campart.Parent = workspace  
                    
                    l_cam.CameraSubject = campart
                    
                    if (cambased) then
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = serv_uinput:IsKeyDown(ask)
                            local IsDownPressed = serv_uinput:IsKeyDown(dsk)
                            local IsForwardPressed = serv_uinput:IsKeyDown(119)
                            local IsBackwardPressed = serv_uinput:IsKeyDown(115)
                                                        
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                l_hum.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) + -- If down is pressed
                                
                                (IsForwardPressed and vec3(0, normclv.Y, 0) or nonep) + -- If forward is pressed
                                (IsBackwardPressed and vec3(0, -normclv.Y, 0) or nonep) -- If backward is pressed
                            ) * Delta)
                            
                            fcampos += Vector
                            
                            campart.Position = fcampos
                            l_cam.CameraSubject = campart
                        end)
                    else
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = serv_uinput:IsKeyDown(ask)
                            local IsDownPressed = serv_uinput:IsKeyDown(dsk)
                                                        
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                l_hum.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) -- If down is pressed
                            ) * Delta)
                            
                            fcampos += Vector
                            
                            campart.Position = fcampos
                            l_cam.CameraSubject = campart
                        end)
                    end
                elseif (curmod == 'Smooth') then
                    campart = inst_new('Part')
                    campart.Position = fcampos
                    campart.Transparency = 1
                    campart.CanCollide = false
                    campart.CanTouch = false
                    campart.Anchored = true
                    campart.Size = vec3(1, 1, 1)
                    campart.Parent = workspace  
                    
                    l_cam.CameraSubject = campart
                    
                    
                    local pos = inst_new('BodyPosition')
                    pos.Position = fcampos
                    pos.D = 1900
                    pos.P = 125000
                    pos.MaxForce = vec3(9e9, 9e9, 9e9)
                    pos.Parent = campart
                    
                    campart.Anchored = false
                    
                    if (cambased) then
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = serv_uinput:IsKeyDown(ask)
                            local IsDownPressed = serv_uinput:IsKeyDown(dsk)
                            local IsForwardPressed = serv_uinput:IsKeyDown(119)
                            local IsBackwardPressed = serv_uinput:IsKeyDown(115)
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = ((
                                l_hum.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) + -- If down is pressed
                                
                                (IsForwardPressed and vec3(0, normclv.Y, 0) or nonep) + -- If forward is pressed
                                (IsBackwardPressed and vec3(0, -normclv.Y, 0) or nonep) -- If backward is pressed
                            ) * Delta)
                            
                            fcampos += Vector
                            
                            pos.Position = fcampos
                        end)
                    else
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            -- Get what keys are pressed
                            local IsUpPressed = serv_uinput:IsKeyDown(ask)
                            local IsDownPressed = serv_uinput:IsKeyDown(dsk)
                            
                            -- Keep character frozen
                            l_hum:ChangeState(1)
                            l_humrp.Velocity = nonep
                            
                            -- Calc delta stuff
                            local Delta = dt * speed * 3
                            -- Get the final vector
                            local Vector = (
                                l_hum.MoveDirection + -- Direction character is moving
                                
                                (IsUpPressed and upp or nonep) + -- If up is pressed
                                (IsDownPressed and downp or nonep) -- If down is presed
                            ) * Delta
                            
                            fcampos += Vector
                            
                            pos.Position = fcampos
                            l_cam.CameraSubject = campart
                        end)
                    end
                    
                elseif (curmod == 'Bypass') then
                    
                    l_cam.CameraSubject = l_hum
                    
                    if (cambased) then
                        local thej = cfnew(l_humrp.Position, l_humrp.Position + vec3(0, 0, 1))
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            l_humrp.CFrame = thej
                            
                            local up = serv_uinput:IsKeyDown(ask)
                            local down = serv_uinput:IsKeyDown(dsk)
                            local f,b = serv_uinput:IsKeyDown(119), serv_uinput:IsKeyDown(115)
                            
                            local movevec = (l_hum.MoveDirection * dt * 3 * speed)
                            local upvec = (((up and upp or nonep) + (down and downp or nonep))*(dt*3*speed))
                            local cupvec = ((f and vec3(0, normclv.Y, 0) or nonep) - (b and vec3(0, normclv.Y, 0) or nonep)*(dt*3*speed))
                            
                            fcampos += movevec
                            fcampos -= upvec
                            fcampos -= cupvec
                            
                            local normalized = cfnew(fcampos):ToObjectSpace(thej)
                            
                            l_hum.CameraOffset = (normalized).Position
                        end)
                    else
                        local thej = cfnew(l_humrp.Position, l_humrp.Position + vec3(0, 0, 1))
                        fcon = serv_run.Heartbeat:Connect(function(dt) 
                            l_humrp.CFrame = thej
                            
                            local up = serv_uinput:IsKeyDown(ask)
                            local down = serv_uinput:IsKeyDown(dsk)
                            
                            local movevec = (l_hum.MoveDirection * dt * 3 * speed)
                            local upvec = (((up and upp or nonep) + (down and downp or nonep))*(dt*3*speed))
                            
                            fcampos += movevec
                            fcampos -= upvec
                            
                            local normalized = cfnew(fcampos):ToObjectSpace(thej)
                            
                            l_hum.CameraOffset = (normalized).Position
                        end)
                    end
                end
                
                local fmode = freezemode:GetSelection()
                
                
                if (fmode == 'Anchor') then
                    l_humrp.Anchored = true
                    
                elseif (fmode == 'Walkspeed') then
                    oldwalk = l_hum.WalkSpeed
                    l_hum.WalkSpeed = 0
                    
                elseif (fmode == 'Stuck') then
                    
                    stuckcf = l_humrp.CFrame
                    dnec(l_humrp.Changed, 'rp_changed')
                    dnec(l_humrp:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                    stuckcon = serv_run.Heartbeat:Connect(function() 
                        l_humrp.CFrame = stuckcf
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
                
                l_cam.CameraSubject = l_hum
                l_hum.CameraOffset = vec3(0, 0, 0)
                
                if (l_humrp.Anchored == true) then
                    l_humrp.Anchored = false
                
                elseif (l_hum.WalkSpeed == 0) then
                    l_humrp.WalkSpeed = (oldwalk == 0 and 16 or oldwalk) -- Prevent getting infinitely stuck
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
                local new = cfnew(pos, pos+l_humrp.CFrame.LookVector)
                stuckcf = new
                l_humrp.CFrame = new
            end)
            
            resetcam:Connect('Clicked',function() 
                fcampos = l_humrp.Position
            end)
            
            ascend_h:SetTooltip('When pressed the freecam vertically ascends'):SetHotkey(Enum.KeyCode.E)
            camera:SetTooltip('When enabled, the direction of your camera affects your Y movement. <b>This is the normal option you\'d see used for other scripts</b>')
            descend_h:SetTooltip('When pressed the freecam vertically descends'):SetHotkey(Enum.KeyCode.Q)
            mode:SetTooltip('The method Freecam uses')
            speedslider:SetTooltip('The speed of your freecam flight')
            freezemode:SetTooltip('The method used to make your character not move')
            gotocam:SetTooltip('Brings you to the camera')
            resetcam:SetTooltip('Resets the camera\'s position')
            resetonenable:SetTooltip('Resets the camera\'s position when Freecam gets enabled')
        end
        -- Esp
        do
            
            -- Settings     
            local s_TeamCheck = r_esp:AddToggle('Team check'):SetTooltip('Won\'t display ESP for teammates')
            local s_TeamColor = r_esp:AddToggle('Team color'):SetTooltip('Replaces the RGB color with their team color. If a player doesn\'t have a team, then their color will remain RGB')
            
            -- Esp types
            local s_Boxes = r_esp:AddToggle('Boxes'):SetTooltip('Displays boxes around the targets')
            local s_Nametags = r_esp:AddToggle('Nametags'):SetTooltip('Shows the usernames of targets')
            local s_Tracers = r_esp:AddToggle('Tracers'):SetTooltip('Enables tracers for the targets')
            --local s_VisibilityCheck = r_esp:AddToggle('Visibility check'):SetTooltip('Only shows ESP for a player if they\'re visible and not blocked by anything')
            
            -- Sliders
            local s_UpdateDelay = r_esp:AddSlider('Update delay',{min=0,max=0.2,cur=0,step=0.01}):SetTooltip('Delay in seconds between ESP updates. <0.05 recommended. <b>Only used for Drawing related ESPS</b>')
            local s_TracerVis = r_esp:AddSlider('Tracer visibility',{min=0,max=1,cur=1,step=0.1}):SetTooltip('The visibility of the tracers - 0 is fully invisible and 1 is fully opaque')
            local s_TextSize = r_esp:AddSlider('Text size',{min=1,max=30,cur=20,step=1}):SetTooltip('The size of the text')
            
            -- Dropdowns
            local s_BoxType = r_esp:AddDropdown('Box type',true):SetTooltip('The type of box to use')
            local s_HealthType = r_esp:AddDropdown('Health display type'):SetTooltip('How the health value is calculated')
            local s_TracerPosition = r_esp:AddDropdown('Tracer position'):SetTooltip('Where the tracer is drawn')
            
            s_BoxType:AddOption('Simple 2d'):SetTooltip('Simple 2d box ESP. Very fast (2 WTVPs p/ object)'):Select()
            s_BoxType:AddOption('Simple 3d'):SetTooltip('Classic Unnamed ESP look. Slightly fast (4 WTVPs p/ object)')
            s_BoxType:AddOption('Westeria 2d'):SetTooltip('Westeria (a c++ aimbot exploit) box style. Very fast (2 WTVPs p/ object)')
            s_BoxType:AddOption('Westeria 3d'):SetTooltip('Westeria (a c++ aimbot exploit) 3d style. Very slow (14 WTVPs p/ object); <b>this will lag your computer.</b>')
            
            s_HealthType:AddOption('Percentage'):SetTooltip('The percentage of the current health and maxhealth'):Select()
            s_HealthType:AddOption('Value'):SetTooltip('Just the current health')
            
            s_TracerPosition:AddOption('Crosshair'):SetTooltip('Tracers are drawn at the crosshairs\'s position. If Crosshair is disabled, it resorts to your mouse.'):Select()
            s_TracerPosition:AddOption('Character'):SetTooltip('Tracers are drawn towards yourself')
            s_TracerPosition:AddOption('Down'):SetTooltip('Tracers are drawn towards the bottom of your screen')
            s_TracerPosition:AddOption('Mouse'):SetTooltip('Tracers are drawn at the mouse position')
            
            s_Tracers:Enable()
            s_Nametags:Enable()
            s_Boxes:Enable()
            
            -- l_ = localization
            -- s_ = setting
            
            local l_TeamCheck   = s_TeamCheck:GetValue()
            local l_TeamColor   = s_TeamColor:GetValue()
            
            local l_Boxes = s_Boxes:GetValue()
            local l_Nametags = s_Nametags:GetValue()
            local l_Tracers = s_Tracers:GetValue()
            
            local l_UpdateDelay = s_UpdateDelay:GetValue()
            local l_TracerVis = s_TracerVis:GetValue()
            local l_TextSize = s_TextSize:GetValue()
            
            
            local l_BoxType = s_BoxType:GetValue()
            local l_HealthType = s_HealthType:GetValue()
            local l_TracerPosition = s_TracerPosition:GetValue()
            
            
            
            local PreviousMode
            local EspFolder

            local EspObjects = {}
            local PlrCons = {}
            local EspCons = {}
            
            
            do
                s_TeamCheck:Connect('Toggled',function(t)l_TeamCheck=t;end)
                s_TeamColor:Connect('Toggled',function(t)l_TeamColor=t;end)
                
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
                    for _, name in ipairs(p_Names) do 
                        local esp = EspObjects[name]
                        if (esp) then
                            esp['Tracer1'].Transparency = v
                            esp['Tracer2'].Transparency = v
                        end
                    end
                end)
                s_TextSize:Connect('Changed',function(v)
                    l_TextSize = v
                    for i,name in ipairs(p_Names) do 
                        local esp = EspObjects[name]
                        if (esp) then
                            esp['Text'].Size = v   
                        end
                    end
                end)
            end
            
            
                   
            
            
            local jskull1
            r_esp:Connect('Enabled',function()
                jskull1 = mrandom(1,99999) -- j💀
                print(pcall(function()
                PreviousMode = EspType
                
                local function create_esp()
                    
                    local EspObject = {}
                    EspObject['upd'] = tick()
                    
                    local BLACK = c_new(0,0,0)
                    
                    do
                        local Name = draw_new('Text') 
                        Name.Center = true
                        Name.Color = c_new(1,1,1)
                        Name.Font = 1
                        Name.Outline = true
                        Name.OutlineColor = c_new(0,0,0)
                        Name.Size = l_TextSize
                        Name.Text = ''
                        Name.Visible = true
                        Name.ZIndex = 3
                        
                        EspObject['Text'] = Name
                    end do
                        local Tracer1 = draw_new('Line')
                        local Tracer2 = draw_new('Line')
                        
                        
                        Tracer1.Thickness = 1
                        Tracer1.Visible = true
                        Tracer1.Transparency = l_TracerVis or 1
                        Tracer1.ZIndex = 3
                        
                        Tracer2.Color = c_new(0,0,0)
                        Tracer2.Thickness = 3
                        Tracer2.Visible = true
                        Tracer2.Transparency = l_TracerVis or 1
                        Tracer2.ZIndex = 2
                        
                        EspObject['Tracer1'] = Tracer1
                        EspObject['Tracer2'] = Tracer2
                    end do 
                        EspObject['Boxes'] = {}
                        if (l_BoxType == 'Simple 2d') then
                            local Square1 = draw_new('Square')
                            Square1.Thickness = 1
                            Square1.Visible = true
                            Square1.ZIndex = 3
                            local Square2 = draw_new('Square')
                            Square2.Thickness = 3
                            Square2.Visible = true
                            Square2.ZIndex = 2
                            Square2.Color = BLACK
                            
                            EspObject['Boxes']['1_1'] = Square1
                            EspObject['Boxes']['1_2'] = Square2
                            
                        elseif (l_BoxType == 'Simple 3d') then
                            local Quad1 = draw_new('Quad')
                            Quad1.Thickness = 1
                            Quad1.Visible = true
                            Quad1.ZIndex = 3
                            local Quad2 = draw_new('Quad')
                            Quad2.Thickness = 3
                            Quad2.Visible = true
                            Quad2.ZIndex = 2
                            Quad2.Color = BLACK
                            
                            EspObject['Boxes']['1_1'] = Quad1
                            EspObject['Boxes']['1_2'] = Quad2
                            
                        elseif (l_BoxType == 'Westeria 2d') then
                            do
                                local Corner1_1 = draw_new('Line')
                                Corner1_1.Thickness = 1
                                Corner1_1.Visible = true
                                Corner1_1.ZIndex = 3
                                local Corner1_2 = draw_new('Line')
                                Corner1_2.Thickness = 1
                                Corner1_2.Visible = true
                                Corner1_2.ZIndex = 3
                                
                                local Corner1_1_o = draw_new('Line')
                                Corner1_1_o.Thickness = 3
                                Corner1_1_o.Visible = true
                                Corner1_1_o.ZIndex = 2
                                Corner1_1_o.Color = BLACK
                                local Corner1_2_o = draw_new('Line')
                                Corner1_2_o.Thickness = 3
                                Corner1_2_o.Visible = true
                                Corner1_2_o.ZIndex = 2
                                Corner1_2_o.Color = BLACK
                                
                                EspObject['Boxes']['1_1'] = Corner1_1
                                EspObject['Boxes']['1_2'] = Corner1_2
                                EspObject['Boxes']['1_1_o'] = Corner1_1_o
                                EspObject['Boxes']['1_2_o'] = Corner1_2_o
                            end
                            do
                                local Corner2_1 = draw_new('Line')
                                Corner2_1.Thickness = 1
                                Corner2_1.Visible = true
                                Corner2_1.ZIndex = 3
                                local Corner2_2 = draw_new('Line')
                                Corner2_2.Thickness = 1
                                Corner2_2.Visible = true
                                Corner2_2.ZIndex = 3
                                
                                local Corner2_1_o = draw_new('Line')
                                Corner2_1_o.Thickness = 3
                                Corner2_1_o.Visible = true
                                Corner2_1_o.ZIndex = 2
                                Corner2_1_o.Color = BLACK
                                local Corner2_2_o = draw_new('Line')
                                Corner2_2_o.Thickness = 3
                                Corner2_2_o.Visible = true
                                Corner2_2_o.ZIndex = 2
                                Corner2_2_o.Color = BLACK
                                
                                EspObject['Boxes']['2_1'] = Corner2_1
                                EspObject['Boxes']['2_2'] = Corner2_2
                                EspObject['Boxes']['2_1_o'] = Corner2_1_o
                                EspObject['Boxes']['2_2_o'] = Corner2_2_o
                                
                            end
                            do
                                local Corner3_1 = draw_new('Line')
                                Corner3_1.Thickness = 1
                                Corner3_1.Visible = true
                                Corner3_1.ZIndex = 3
                                local Corner3_2 = draw_new('Line')
                                Corner3_2.Thickness = 1
                                Corner3_2.Visible = true
                                Corner3_2.ZIndex = 3
                                
                                local Corner3_1_o = draw_new('Line')
                                Corner3_1_o.Thickness = 3
                                Corner3_1_o.Visible = true
                                Corner3_1_o.ZIndex = 2
                                Corner3_1_o.Color = BLACK
                                local Corner3_2_o = draw_new('Line')
                                Corner3_2_o.Thickness = 3
                                Corner3_2_o.Visible = true
                                Corner3_2_o.ZIndex = 2
                                Corner3_2_o.Color = BLACK
                                
                                EspObject['Boxes']['3_1'] = Corner3_1
                                EspObject['Boxes']['3_2'] = Corner3_2
                                EspObject['Boxes']['3_1_o'] = Corner3_1_o
                                EspObject['Boxes']['3_2_o'] = Corner3_2_o
                            end
                            do
                                local Corner4_1 = draw_new('Line')
                                Corner4_1.Thickness = 1
                                Corner4_1.Visible = true
                                Corner4_1.ZIndex = 3
                                local Corner4_2 = draw_new('Line')
                                Corner4_2.Thickness = 1
                                Corner4_2.Visible = true
                                Corner4_2.ZIndex = 3
                                
                                local Corner4_1_o = draw_new('Line')
                                Corner4_1_o.Thickness = 3
                                Corner4_1_o.Visible = true
                                Corner4_1_o.ZIndex = 2
                                Corner4_1_o.Color = BLACK
                                local Corner4_2_o = draw_new('Line')
                                Corner4_2_o.Thickness = 3
                                Corner4_2_o.Visible = true
                                Corner4_2_o.ZIndex = 2
                                Corner4_2_o.Color = BLACK
                                
                                EspObject['Boxes']['4_1'] = Corner4_1
                                EspObject['Boxes']['4_2'] = Corner4_2
                                EspObject['Boxes']['4_1_o'] = Corner4_1_o
                                EspObject['Boxes']['4_2_o'] = Corner4_2_o
                            end
                        elseif (l_BoxType == 'Westeria 3d') then
                            do
                                local Corner1_1 = draw_new('Line')
                                Corner1_1.Thickness = 1
                                Corner1_1.Visible = true
                                Corner1_1.ZIndex = 3
                                local Corner1_2 = draw_new('Line')
                                Corner1_2.Thickness = 1
                                Corner1_2.Visible = true
                                Corner1_2.ZIndex = 3
                                
                                local Corner1_1_o = draw_new('Line')
                                Corner1_1_o.Thickness = 3
                                Corner1_1_o.Visible = true
                                Corner1_1_o.ZIndex = 2
                                Corner1_1_o.Color = BLACK
                                local Corner1_2_o = draw_new('Line')
                                Corner1_2_o.Thickness = 3
                                Corner1_2_o.Visible = true
                                Corner1_2_o.ZIndex = 2
                                Corner1_2_o.Color = BLACK
                                
                                EspObject['Boxes']['1_1'] = Corner1_1
                                EspObject['Boxes']['1_2'] = Corner1_2
                                EspObject['Boxes']['1_1_o'] = Corner1_1_o
                                EspObject['Boxes']['1_2_o'] = Corner1_2_o
                            end
                            do
                                local Corner2_1 = draw_new('Line')
                                Corner2_1.Thickness = 1
                                Corner2_1.Visible = true
                                Corner2_1.ZIndex = 3
                                local Corner2_2 = draw_new('Line')
                                Corner2_2.Thickness = 1
                                Corner2_2.Visible = true
                                Corner2_2.ZIndex = 3
                                
                                local Corner2_1_o = draw_new('Line')
                                Corner2_1_o.Thickness = 3
                                Corner2_1_o.Visible = true
                                Corner2_1_o.ZIndex = 2
                                Corner2_1_o.Color = BLACK
                                local Corner2_2_o = draw_new('Line')
                                Corner2_2_o.Thickness = 3
                                Corner2_2_o.Visible = true
                                Corner2_2_o.ZIndex = 2
                                Corner2_2_o.Color = BLACK
                                
                                EspObject['Boxes']['2_1'] = Corner2_1
                                EspObject['Boxes']['2_2'] = Corner2_2
                                EspObject['Boxes']['2_1_o'] = Corner2_1_o
                                EspObject['Boxes']['2_2_o'] = Corner2_2_o
                                
                            end
                            do
                                local Corner3_1 = draw_new('Line')
                                Corner3_1.Thickness = 1
                                Corner3_1.Visible = true
                                Corner3_1.ZIndex = 3
                                local Corner3_2 = draw_new('Line')
                                Corner3_2.Thickness = 1
                                Corner3_2.Visible = true
                                Corner3_2.ZIndex = 3
                                
                                local Corner3_1_o = draw_new('Line')
                                Corner3_1_o.Thickness = 3
                                Corner3_1_o.Visible = true
                                Corner3_1_o.ZIndex = 2
                                Corner3_1_o.Color = BLACK
                                local Corner3_2_o = draw_new('Line')
                                Corner3_2_o.Thickness = 3
                                Corner3_2_o.Visible = true
                                Corner3_2_o.ZIndex = 2
                                Corner3_2_o.Color = BLACK
                                
                                EspObject['Boxes']['3_1'] = Corner3_1
                                EspObject['Boxes']['3_2'] = Corner3_2
                                EspObject['Boxes']['3_1_o'] = Corner3_1_o
                                EspObject['Boxes']['3_2_o'] = Corner3_2_o
                            end
                            do
                                local Corner4_1 = draw_new('Line')
                                Corner4_1.Thickness = 1
                                Corner4_1.Visible = true
                                Corner4_1.ZIndex = 3
                                local Corner4_2 = draw_new('Line')
                                Corner4_2.Thickness = 1
                                Corner4_2.Visible = true
                                Corner4_2.ZIndex = 3
                                
                                local Corner4_1_o = draw_new('Line')
                                Corner4_1_o.Thickness = 3
                                Corner4_1_o.Visible = true
                                Corner4_1_o.ZIndex = 2
                                Corner4_1_o.Color = BLACK
                                local Corner4_2_o = draw_new('Line')
                                Corner4_2_o.Thickness = 3
                                Corner4_2_o.Visible = true
                                Corner4_2_o.ZIndex = 2
                                Corner4_2_o.Color = BLACK
                                
                                EspObject['Boxes']['4_1'] = Corner4_1
                                EspObject['Boxes']['4_2'] = Corner4_2
                                EspObject['Boxes']['4_1_o'] = Corner4_1_o
                                EspObject['Boxes']['4_2_o'] = Corner4_2_o
                            end
                        end
                    end
                    return EspObject
                end
                local function hook_player(pName)
                    local PlayerName = pName
                    local PlayerObject = p_RefKeys[pName]
                    if (not PlayerObject) then warn'[REDLINE:ESP] This player hasn\'t finished joining the server! Couldn\'t hook, returning' return end 
                    
                    local PlayerInstance = PlayerObject.plr
                    
                    
                    local EspObject = create_esp()
                    
                    PlrCons[PlayerName] = {}
                    PlrCons[PlayerName][1] = PlayerInstance:GetPropertyChangedSignal('TeamColor'):Connect(function() 
                        local tx = EspObjects[PlayerName]
                        tx = tx and tx['Text'] or nil
                        
                        local col = PlayerInstance.TeamColor
                        col = col and PlayerInstance.TeamColor.Color or nil
                        
                        
                        
                        if (tx) then
                            tx.Color = col or c_new(1,1,1)
                        end
                    end)
                    PlrCons[PlayerName][2] = PlayerInstance.CharacterAdded:Connect(function(c)
                        EspObject['Text'].Visible = true
                        EspObject['Tracer1'].Visible = true
                        EspObject['Tracer2'].Visible = true
                        
                        if (EspObject['Boxes']) then 
                            for i,v in pairs(EspObject['Boxes']) do v.Visible = true end
                        end
                    end)
                    PlrCons[PlayerName][3] = PlayerInstance.CharacterRemoving:Connect(function()
                        EspObject['Text'].Visible = false
                        EspObject['Tracer1'].Visible = false
                        EspObject['Tracer2'].Visible = false
                        
                        if (EspObject['Boxes']) then 
                            for i,v in pairs(EspObject['Boxes']) do v.Visible = false end
                        end
                    end)
                    
                    EspObjects[PlayerName] = EspObject
                end
                
                -- Hook stuff
                do
                    for i,v in ipairs(p_Names) do hook_player(v) end
                
                    EspCons['PlrA'] = serv_players.PlayerAdded:Connect(function(p) 
                        local PlayerName = p.Name
                        wait(2.5)
                        hook_player(PlayerName)
                    end)
                    EspCons['PlrR'] = serv_players.PlayerRemoving:Connect(function(p) 
                        local PlayerName = p.Name
                        
                        local _ = PlrCons[PlayerName] 
                        if (_) then 
                            for i,v in ipairs(_) do 
                                v:Disconnect()
                            end
                        end 
                        local _ = EspObjects[v]
                        if (_) then
                            _['Text']:Remove()
                            _['Tracer1']:Remove()
                            _['Tracer2']:Remove()
                            for i,v in pairs(_['Boxes']) do 
                                v:Remove()
                            end
                        end
                    end)
                end
                
                local update_esp do
                    local textoffs = cfnew(0, 3, 0)
                    local boxoffs_1_0 = cfnew(-2.5,  2.8,  0.0) -- corner
                    local boxoffs_1_1 = cfnew(-1.5,  2.8,  0.0)
                    local boxoffs_1_2 = cfnew(-2.5,  1.8,  0.0)

                    local boxoffs_2_0 = cfnew( 2.5,  2.8,  0.0) -- corner
                    local boxoffs_2_1 = cfnew( 1.5,  2.8,  0.0)
                    local boxoffs_2_2 = cfnew( 2.5,  1.8,  0.0)
                    
                    local boxoffs_3_0 = cfnew( 2.5, -2.8,  0.0) -- corner
                    local boxoffs_3_1 = cfnew( 1.5, -2.8,  0.0)
                    local boxoffs_3_2 = cfnew( 2.5, -1.8,  0.0)
                    
                    local boxoffs_4_0 = cfnew(-2.5, -2.8,  0.0) -- corner
                    local boxoffs_4_1 = cfnew(-1.5, -2.8,  0.0)
                    local boxoffs_4_2 = cfnew(-2.5, -1.8,  0.0)
                    
                    
                    local TracerPos do 
                        if (l_TracerPosition == 'Crosshair') then
                            EspCons['TracerAimbot'] = serv_run.RenderStepped:Connect(function() 
                                TracerPos = CrosshairPosition or serv_uinput:GetMouseLocation()
                            end)
                        elseif (l_TracerPosition == 'Character') then
                            EspCons['TracerAimbot'] = serv_run.RenderStepped:Connect(function() 
                                local j = l_cam:WorldToViewportPoint(l_humrp.Position)
                                TracerPos = vec2(j.X, j.Y)
                            end)
                        elseif (l_TracerPosition == 'Down') then
                            TracerPos = l_cam.ViewportSize
                            TracerPos = vec2(TracerPos.X/2, TracerPos.Y*0.8)
                            EspCons['TracerDown'] = l_cam:GetPropertyChangedSignal('ViewportSize'):Connect(function() 
                                local _ = l_cam.ViewportSize
                                TracerPos = vec2(_.X/2, _.Y*0.8)
                            end)
                        elseif (l_TracerPosition == 'Mouse') then
                            EspCons['TracerMouse'] = serv_run.RenderStepped:Connect(function() 
                                TracerPos = serv_uinput:GetMouseLocation()
                            end)
                        end
                    end
                    
                    if (l_BoxType == 'Simple 2d') then
                        local ScreenY = l_cam.ViewportSize.Y
                        EspCons['Screen'] = l_cam:GetPropertyChangedSignal('ViewportSize'):Connect(function() 
                            ScreenY = l_cam.ViewportSize.Y
                        end)
                        
                        update_esp = function() 
                            local len = #p_Names
                            if (isrbxactive() == false or len == 0) then return end
                            local SelfPos = l_humrp and l_humrp.Position or vec3(0, 0, 0)
                            local CurTime = tick()
                            
                            for i = 1, len do
                                local Name = p_Names[i]
                                local PlayerObject = p_RefKeys[Name]
                                local EspObject = EspObjects[Name]
                                local rp = PlayerObject.rp
                                local hum = PlayerObject.hum
                                
                                local localteam = l_plr.Team
                                
                                if (EspObject and rp and hum) then
                                    local PlayerInstance = PlayerObject.plr
                                    if (EspObject['upd'] > CurTime) then continue end
                                    if (l_TeamCheck and PlayerInstance.Team == localteam) then 
                                        local tx = EspObject['Text']
                                        if (tx.Visible) then
                                            tx.Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false 
                                        end
                                        continue 
                                    end 
                                    local TargRootPos = rp.CFrame
                                    
                                    -- Some position shit
                                    local Text_Pos2d do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*textoffs).Position)
                                        
                                        if (not vis) then
                                            EspObject['upd'] = CurTime+0.2
                                            EspObject['Text'].Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            continue
                                        end
                                        Text_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    TargRootPos = TargRootPos.Position
                                    local Root_Pos2d, Depth do 
                                        local shit, vis = l_cam:WorldToViewportPoint(TargRootPos)
                                        if (not vis) then
                                            EspObject['upd'] = CurTime+0.2
                                            EspObject['Text'].Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            continue
                                        end
                                        
                                        Root_Pos2d = vec2(shit.X, shit.Y)
                                        Depth = shit.Z
                                    end
                                    
                                    local Text, Tracer1, Tracer2 = EspObject['Text'], EspObject['Tracer1'], EspObject['Tracer2']
                                    local Boxes = EspObject['Boxes']
                                    
                                    local Box1_1 = Boxes['1_1']
                                    local Box1_2 = Boxes['1_2']
                                    
                                    -- Text shit
                                    do
                                        local Dist = (SelfPos - TargRootPos).Magnitude
                                        local HealthText = l_HealthType == 'Percentage' and (mfloor((hum.Health / hum.MaxHealth)*100)..'%') or mfloor(hum.Health)
                                        
                                        Text.Text = (('%s / dist:%.1f / hp:%s'):format(Name, Dist, HealthText))
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
                                            local _ = (l_TeamColor and PlayerInstance.TeamColor) or false
                                            _ = _ and _.Color or RGBCOLOR
                                            ValidColor = _
                                        end
                                        Tracer1.Color = ValidColor
                                    end
                                    
                                    -- Box shit :troll:
                                    do 
                                        -- Use depth to figure out approx where thee corners should be
                                        Depth = (1 / Depth) * ScreenY * (1 / (l_cam.FieldOfView / 70))
                                        Root_Pos2d = Root_Pos2d - vec2(Depth*1.5, Depth*1.8)
                                        local Box_Size = vec2(Depth*3,Depth*4)
                                        
                                        Box1_1.Size = Box_Size
                                        Box1_1.Position = Root_Pos2d
                                        
                                        Box1_2.Size = Box_Size
                                        Box1_2.Position = Root_Pos2d 
                                    end
                                    
                                    Box1_1.Color = ValidColor
                                    Box1_1.Visible = l_Boxes
                                    Box1_2.Visible = l_Boxes
                                    Text.Visible = l_Nametags
                                    Tracer1.Visible = l_Tracers
                                    Tracer2.Visible = l_Tracers
                                end
                            end
                        end
                    elseif (l_BoxType == 'Westeria 2d') then
                        local ScreenY = l_cam.ViewportSize.Y
                        EspCons['Screen'] = l_cam:GetPropertyChangedSignal('ViewportSize'):Connect(function() 
                            ScreenY = l_cam.ViewportSize.Y
                        end)
                        
                        
                        update_esp = function() 
                            local len = #p_Names
                            if (isrbxactive() == false or len == 0) then return end
                            local SelfPos = l_humrp and l_humrp.Position or vec3(0, 0, 0)
                            local CurTime = tick()
                            
                            local localteam = l_plr.Team
                            
                            for i = 1, len do
                                local Name = p_Names[i]
                                local PlayerObject = p_RefKeys[Name]
                                local EspObject = EspObjects[Name]
                                local rp = PlayerObject.rp
                                local hum = PlayerObject.hum
                                
                                if (EspObject and rp and hum) then
                                    local PlayerInstance = PlayerObject.plr
                                    
                                    if (EspObject['upd'] > CurTime) then continue end
                                    if (l_TeamCheck and PlayerInstance.Team == localteam) then
                                        local tx = EspObject['Text']
                                        if (tx.Visible == true) then
                                            tx.Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
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
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*textoffs).Position)
                                        
                                        if (not vis) then
                                            EspObject['upd'] = CurTime+0.2
                                            EspObject['Text'].Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
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
                                        local shit, vis = l_cam:WorldToViewportPoint(TargRootPos)
                                        if (not vis) then
                                            EspObject['upd'] = CurTime+0.2
                                            EspObject['Text'].Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
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
                                    
                                    
                                    local Text, Tracer1, Tracer2 = EspObject['Text'], EspObject['Tracer1'], EspObject['Tracer2']
                                    local Boxes = EspObject['Boxes']
                                    
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
                                        local Dist = (SelfPos - TargRootPos).Magnitude
                                        local HealthText = l_HealthType == 'Percentage' and (mfloor((hum.Health / hum.MaxHealth)*100)..'%') or mfloor(hum.Health)
                                        
                                        Text.Text = (('%s / dist:%.1f / hp:%s'):format(Name, Dist, HealthText))
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
                                        Depth = (1 / Depth) * ScreenY * (1 / (l_cam.FieldOfView / 70))
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
                            local len = #p_Names
                            if (isrbxactive() == false or len == 0) then return end
                            local SelfPos = l_humrp and l_humrp.Position or vec3(0, 0, 0)
                            local CurTime = tick()
                            
                            local localteam = l_plr.Team
                            
                            for i = 1, len do
                                local Name = p_Names[i]
                                local PlayerObject = p_RefKeys[Name]
                                local EspObject = EspObjects[Name]
                                local rp = PlayerObject.rp
                                local hum = PlayerObject.hum
                                
                                if (EspObject and rp and hum) then
                                    local PlayerInstance = PlayerObject.plr
                                    
                                    if (EspObject['upd'] > CurTime) then continue end
                                    if (l_TeamCheck and PlayerInstance.Team == localteam) then
                                        local tx = EspObject['Text']
                                        if (tx.Visible) then
                                            tx.Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
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
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*textoffs).Position)
                                        
                                        if (not vis) then
                                            EspObject['upd'] = CurTime+0.2
                                            EspObject['Text'].Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
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
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_1_0).Position)
                                        -- i am not doing anymore fuckingchecks
                                        Box_Pos1_0 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos1_1 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_1_1).Position)
                                        Box_Pos1_1 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos1_2 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_1_2).Position)
                                        Box_Pos1_2 = vec2(shit.X, shit.Y)
                                    end
                                    
                                    local Box_Pos2_0 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_2_0).Position)
                                        Box_Pos2_0 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos2_1 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_2_1).Position)
                                        Box_Pos2_1 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos2_2 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_2_2).Position)
                                        Box_Pos2_2 = vec2(shit.X, shit.Y)
                                    end
                                    
                                    local Box_Pos3_0 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_3_0).Position)
                                        Box_Pos3_0 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos3_1 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_3_1).Position)
                                        Box_Pos3_1 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos3_2 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_3_2).Position)
                                        Box_Pos3_2 = vec2(shit.X, shit.Y)
                                    end
                                    
                                    local Box_Pos4_0 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_4_0).Position)
                                        Box_Pos4_0 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos4_1 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_4_1).Position)
                                        Box_Pos4_1 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos4_2 do
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_4_2).Position)
                                        Box_Pos4_2 = vec2(shit.X, shit.Y)
                                    end
                                    
                                    
                                    
                                    
                                    
                                    TargRootPos = TargRootPos.Position
                                    local Root_Pos2d do 
                                        local shit, vis = l_cam:WorldToViewportPoint(TargRootPos)
                                        if (not vis) then
                                            EspObject['upd'] = CurTime+0.2
                                            EspObject['Text'].Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
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
                                    
                                    
                                    local Text, Tracer1, Tracer2 = EspObject['Text'], EspObject['Tracer1'], EspObject['Tracer2']
                                    local Boxes = EspObject['Boxes']
                                    
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
                                        local Dist = (SelfPos - TargRootPos).Magnitude
                                        local HealthText = l_HealthType == 'Percentage' and (mfloor((hum.Health / hum.MaxHealth)*100)..'%') or mfloor(hum.Health)
                                        
                                        Text.Text = (('%s / dist:%.1f / hp:%s'):format(Name, Dist, HealthText))
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
                            local len = #p_Names
                            if (isrbxactive() == false or len == 0) then return end
                            local SelfPos = l_humrp and l_humrp.Position or vec3(0, 0, 0)
                            local CurTime = tick()
                            
                            local localteam = l_plr.Team
                            
                            for i = 1, len do
                                local Name = p_Names[i]
                                local PlayerObject = p_RefKeys[Name]
                                local EspObject = EspObjects[Name]
                                local rp = PlayerObject.rp
                                local hum = PlayerObject.hum
                                
                                if (EspObject and rp and hum) then
                                    local PlayerInstance = PlayerObject.plr
                                    
                                    if (EspObject['upd'] > CurTime) then continue end
                                    if (l_TeamCheck and PlayerInstance.Team == localteam) then
                                        local tx = EspObject['Text']
                                        if (tx.Visible == true) then
                                            tx.Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                        end
                                        continue
                                    end
                                    local TargRootPos = rp.CFrame
                                    
                                    -- Some position shit
                                    local Text_Pos2d do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*textoffs).Position)
                                        
                                        if (not vis) then
                                            EspObject['upd'] = CurTime+0.2
                                            EspObject['Text'].Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            continue
                                        end
                                        Text_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    local Box_Pos1 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_1_0).Position)
                                        Box_Pos1 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos2 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_2_0).Position)
                                        Box_Pos2 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos3 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_3_0).Position)
                                        Box_Pos3 = vec2(shit.X, shit.Y)
                                    end
                                    local Box_Pos4 do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*boxoffs_4_0).Position)
                                        Box_Pos4 = vec2(shit.X, shit.Y)
                                    end
                                    
                                    
                                    TargRootPos = TargRootPos.Position
                                    local Root_Pos2d do 
                                        local shit, vis = l_cam:WorldToViewportPoint(TargRootPos)
                                        if (not vis) then
                                            EspObject['upd'] = CurTime+0.2
                                            EspObject['Text'].Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            
                                            local Boxes = EspObject['Boxes']
                                            Boxes['1_1'].Visible = false
                                            Boxes['1_2'].Visible = false
                                            continue
                                        end
                                        
                                        Root_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    
                                    local Text, Tracer1, Tracer2 = EspObject['Text'], EspObject['Tracer1'], EspObject['Tracer2']
                                    local Boxes = EspObject['Boxes']
                                    local Box1_1 = Boxes['1_1']
                                    local Box1_2 = Boxes['1_2']
                                    
                                    -- Text shit
                                    do
                                        local Dist = (SelfPos - TargRootPos).Magnitude
                                        local HealthText = l_HealthType == 'Percentage' and (mfloor((hum.Health / hum.MaxHealth)*100)..'%') or mfloor(hum.Health)
                                        
                                        Text.Text = (('%s / dist:%.1f / hp:%s'):format(Name, Dist, HealthText))
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
                            local len = #p_Names
                            if (isrbxactive() == false or len == 0) then return end
                            local SelfPos = l_humrp and l_humrp.Position or vec3(0, 0, 0)
                            local CurTime = tick()
                            
                            for i = 1, len do
                                local Name = p_Names[i]
                                local PlayerObject = p_RefKeys[Name]
                                local EspObject = EspObjects[Name]
                                local rp = PlayerObject.rp
                                local hum = PlayerObject.hum
                                
                                
                                
                                if (EspObject and rp and hum) then
                                    if (EspObject['upd'] > CurTime) then continue end
                                    
                                    local TargRootPos = rp.CFrame
                                    
                                    local Text_Pos2d do 
                                        local shit, vis = l_cam:WorldToViewportPoint((TargRootPos*textoffs).Position)
                                        
                                        if (not vis) then
                                            EspObject['upd'] = CurTime+0.2
                                            EspObject['Text'].Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            continue
                                        end
                                        Text_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    TargRootPos = TargRootPos.Position
                                    
                                    local Root_Pos2d do 
                                        local shit, vis = l_cam:WorldToViewportPoint(TargRootPos)
                                        if (not vis) then
                                            EspObject['upd'] = CurTime+0.2
                                            EspObject['Text'].Visible = false
                                            EspObject['Tracer1'].Visible = false
                                            EspObject['Tracer2'].Visible = false
                                            continue
                                        end
                                        
                                        Root_Pos2d = vec2(shit.X, shit.Y)
                                    end
                                    
                                    
                                    
                                    local Text, Tracer1, Tracer2 = EspObject['Text'], EspObject['Tracer1'], EspObject['Tracer2']
                                    
                                    local Dist = (SelfPos - TargRootPos).Magnitude
                                    local HealthText = l_HealthType == 'Percentage' and (mfloor((hum.Health / hum.MaxHealth)*100)..'%') or mdloor(hum.Health)
                                    
                                    
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
                    EspCons['Update'] = serv_run.RenderStepped:Connect(update_esp)
                else
                    local jskull2 = jskull1
                    spawn(function()
                        while jskull2 == jskull1 and r_esp:IsEnabled() do 
                            update_esp()
                            wait(l_UpdateDelay)
                        end
                    end)
                end
            end))
            end)
            r_esp:Connect('Disabled',function() 
                for _, con in pairs(EspCons) do con:Disconnect() end
                tclear(EspCons)
                
                --if (EspFolder) then EspFolder:Destroy() EspFolder = nil end
                
                for i,v in ipairs(p_Names) do 
                    local _ = PlrCons[v] 
                    if (_) then 
                        for i,v in ipairs(_) do 
                            v:Disconnect()
                        end
                    end 
                    local _ = EspObjects[v]
                    if (_) then
                        _['Text']:Remove()
                        _['Tracer1']:Remove()
                        _['Tracer2']:Remove()
                        
                        if (_['Boxes']) then
                            for i,v in pairs(_['Boxes']) do v:Remove() end    
                        end
                    end
                end
                tclear(PlrCons)
                tclear(EspObjects)
            end)
        end
        -- Fullbright
        do 
            local s_looped = r_fullbright:AddToggle('Looped'):SetTooltip('Loops the fullbright every frame. Needed for games like the Rake or Lumber Tycoon')
            local s_mode = r_fullbright:AddDropdown('Mode',true):SetTooltip('Different modes for fullbright. Some may work better in other games')
            
            s_mode:AddOption('Standard'):SetTooltip('Your average fullbright. Doesn\'t look too harsh'):Select()
            s_mode:AddOption('Bright'):SetTooltip('Insanely bright')
            s_mode:AddOption('Nofog'):SetTooltip('Only affects fog')
            s_mode:AddOption('Soft'):SetTooltip('Instead of turning everything white, it turns everything gray. Meant for games with bloom effects')
            
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
                local loop = s_looped:IsEnabled()
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
                    local c1 = c_new(0.9, 0.9, 0.9)
                    local function fb() 
                        lighting.Ambient = c1
                        lighting.OutdoorAmbient = c1
                        lighting.Brightness = 7
                        lighting.FogEnd = 9e9
                        lighting.FogStart = 9e9
                    end
                    
                    if (loop) then
                        serv_run:BindToRenderStep('RL-Fullbright',9999,fb)
                        steppedcon = serv_run.Stepped:Connect(fb)
                    else
                        fb()   
                    end
                elseif (mode == 'Bright') then
                    local c1 = c_new(1, 1, 1)
                    local function fb() 
                        lighting.Ambient = c1
                        lighting.OutdoorAmbient = c1
                        lighting.Brightness = 10
                        lighting.FogEnd = 9e9
                        lighting.FogStart = 9e9
                        lighting.GlobalShadows = false
                    end
                    
                    if (loop) then
                        serv_run:BindToRenderStep('RL-Fullbright',9999,fb) 
                        steppedcon = serv_run.Stepped:Connect(fb)
                    else
                        fb()   
                    end
                elseif (mode == 'Nofog') then
                    local function fb() 
                        lighting.FogEnd = 9e9
                        lighting.FogStart = 9e9
                    end
                    
                    if (loop) then
                        serv_run:BindToRenderStep('RL-Fullbright',9999,fb) 
                        steppedcon = serv_run.Stepped:Connect(fb)
                    else
                        fb()   
                    end
                elseif (mode == 'Soft') then
                    local c1 = c_new(0.6, 0.6, 0.6)
                    local function fb() 
                        lighting.Ambient = c1
                        lighting.OutdoorAmbient = c1
                        lighting.Brightness = 4
                        lighting.FogEnd = 9e9
                        lighting.FogStart = 9e9
                    end
                    
                    if (loop) then
                        serv_run:BindToRenderStep('RL-Fullbright',9999,fb) 
                        steppedcon = serv_run.Stepped:Connect(fb)
                    else
                        fb()   
                    end
                end
            end)
            
            r_fullbright:Connect('Disabled',function() 
                serv_run:UnbindFromRenderStep('RL-Fullbright')
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
                kmframe = inst_new('Frame')
                kmframe.BackgroundTransparency = 1
                kmframe.Size = dim_off(170, 115)
                kmframe.Position = dim_new(1,-170-20,0,20)
                kmframe.ZIndex = 200
                kmframe.Parent = ui:GetScreen()
                
                local w = inst_new('TextLabel')
                w.AnchorPoint = vec2(0.5, 0)
                w.BackgroundColor3 = RLTHEMEDATA['gw'][1]
                w.BackgroundTransparency = RLTHEMEDATA['gw'][2]
                w.Font = RLTHEMEFONT
                w.Position = dim_sca(0.5, 0)
                w.Size = dim_off(50, 50)
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
                a.Position = dim_sca(0, 1)
                a.Parent = kmframe
                
                local s = w:Clone()
                s.Text = 'S'
                s.AnchorPoint = vec2(0.5, 1)
                s.Position = dim_sca(0.5, 1)
                s.Parent = kmframe
                
                local d = w:Clone()
                d.Text = 'D'
                d.AnchorPoint = vec2(1, 1)
                d.Position = dim_sca(1, 1)
                d.Parent = kmframe
                

                
                local keys = {}
                keys[Enum.KeyCode.W] = w
                keys[Enum.KeyCode.A] = a
                keys[Enum.KeyCode.S] = s
                keys[Enum.KeyCode.D] = d
                
                
                local monitor_inset = serv_gui:GetGuiInset()
                
                kmframe.InputBegan:Connect(function(io) 
                    local uitv = io.UserInputType.Value
                    
                    if (uitv == 0) then
                        local monitor_res = l_cam.ViewportSize
                        
                        local root_pos = kmframe.AbsolutePosition -- Get the original header position
                        local start_pos = io.Position
                        start_pos = vec2(start_pos.X, start_pos.Y)
                        
                        KSDrag = serv_uinput.InputChanged:Connect(function(io) 
                            if (io.UserInputType.Value == 4) then
                                local curr_pos = io.Position
                                curr_pos = vec2(curr_pos.X, curr_pos.Y)
                                local _ = (root_pos + (curr_pos - start_pos) + monitor_inset) / monitor_res
                                kmframe.Position = dim_sca(_.X,_.Y)
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
                
                InputConnection = serv_uinput.InputBegan:Connect(function(kc) 
                    kc = kc.KeyCode
                    local key = keys[kc]
                    if (key) then
                        twn(key, {BackgroundColor3 = ColEnabled})
                    end
                end)
                
                InputConnection = serv_uinput.InputEnded:Connect(function(kc) 
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
                    serv_run:Set3dRenderingEnabled(false)
                end
                
                
                FocusedConnection = serv_uinput.WindowFocused:Connect(function() 
                    serv_run:Set3dRenderingEnabled(true)
                end)
                UnfocusedConnection = serv_uinput.WindowFocusReleased:Connect(function() 
                    serv_run:Set3dRenderingEnabled(false)
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
            local s_Amount = r_zoom:AddSlider('Zoom amount',{min=0,max=140,cur=30,step=0.1},true):SetTooltip('The amount to zoom in by')
            local s_Looped = r_zoom:AddToggle('Looped'):SetTooltip('Loop changes FOV. Useful for some games that change it every frame')
            local s_Key = r_zoom:AddHotkey('Toggle key'):SetTooltip('Toggles zoom without requiring a module disable / enable')
            
            local Key = s_Key:GetValue()
            s_Key:Connect('HotkeySet',function(k) 
                Key = k 
                r_zoom:Reset()
            end)
            
            
            local Toggled
            local KeyCon
            
            local oldfov = l_cam and l_cam.FieldOfView or 70
            r_zoom:Connect('Enabled',function() 
                dnec(l_cam:GetPropertyChangedSignal('FieldOfView'),'cam_fov')
                
                local v = 70 - (s_Amount:GetValue()*.5)
                
                if (Key) then
                    
                    s_Amount:Connect('Changed',function(j) 
                        v = 70 - (j*.5)
                        if (Toggled) then 
                            l_cam.FieldOfView = v
                        end
                    end)
                    
                    
                    Toggled = false
                    KeyCon = serv_uinput.InputBegan:Connect(function(io, gpe) 
                        if (gpe == false and io.KeyCode == Key) then
                            Toggled = not Toggled
                            if (Toggled) then
                                if (s_Looped:IsEnabled()) then
                                    serv_run:BindToRenderStep('RL-FOV',2000,function() 
                                        l_cam.FieldOfView = v
                                    end)
                                else
                                    twn(l_cam, {FieldOfView = v}, true)
                                end
                            else
                                twn(l_cam, {FieldOfView = oldfov}, true)
                                
                                
                                serv_run:UnbindFromRenderStep('RL-FOV')
                            end
                        end
                    end)
                else
                    s_Amount:Connect('Changed',function(j) 
                        v = 70 - (j*.5)
                        l_cam.FieldOfView = v
                    end)
                    
                    if (s_Looped:IsEnabled()) then
                        serv_run:BindToRenderStep('RL-FOV',2000,function() 
                            l_cam.FieldOfView = v
                        end)
                    else
                        l_cam.FieldOfView = v
                    end
                end
            end)
                
                
            r_zoom:Connect('Disabled',function()
                s_Amount:Connect('Changed',nil)
                serv_run:UnbindFromRenderStep('RL-FOV')
                
                l_cam.FieldOfView = oldfov
                enec('cam_fov')
                
                if (KeyCon) then KeyCon:Disconnect() KeyCon = nil end
            end)

        end
        
        r_crosshair:SetTooltip('Enables a crosshair overlay made in Drawing. Also has extra features for Aimbot')
        r_esp:SetTooltip('Activates ESP for other players. Currently is in beta, may glitch out, but should be way more stable than before.')
        r_freecam:SetTooltip('Frees up your camera, letting you fly it anywhere. Useful for spying on others. <i>Doesn\'t work on games with custom camera systems</i>')
        r_fullbright:SetTooltip('Makes the world insanely bright. Useful for games with fog effects, like Lumber Tycoon 2 or Rake. <i>May not work with every game</i>')
        r_keystrokes:SetTooltip('Enables an overlay with your movement keys. Currently unfinished')
        r_ugpu:SetTooltip('Disables 3d rendering when the window loses focus, saving GPU processing time')
        r_zoom:SetTooltip('Zooms in your camera. <i>May not work with every game</i>')
    end
    local m_ui = ui:CreateMenu('UI') do 
        local u_jeff = m_ui:AddMod('Jeff')
        local u_modlist = m_ui:AddMod('Mod list')
        local u_plr = m_ui:AddMod('Player notifications')
        local u_theme = m_ui:AddMod('Theme',nil,true)
        
        -- jeff 
        do 
            local _
            u_jeff:Connect('Toggled', function(t) 
                if (t) then
                    _ = inst_new('ImageLabel')
                    _.Size = dim_off(250, 250)
                    _.BackgroundTransparency = 1
                    _.Position = dim_new(1, -250, 1, 0)
                    _.Image = 'rbxassetid://8723094657'
                    _.ResampleMode = 'Pixelated'
                    _.Parent = ui:GetScreen()
                    
                    ctwn(_, {Position = dim_new(1, -250, 1, -130)}, 25)
                else
                    _:Destroy()
                end
                
            end)
        end
        -- plr
        do 
            local rfriends = u_plr:AddToggle('Roblox friends only'):SetTooltip('Only send notifications if they are your roblox friend')
            local sound = u_plr:AddToggle('Play sound'):SetTooltip('Play the notif sound'):Enable()
            
            local h = true
            sound:Connect('Toggled',function(t)h=t;end)
            
            local join
            local leave 
            
            u_plr:Connect('Enabled',function() 
                join = serv_players.PlayerAdded:Connect(function(p) 
                    local display, name = p.DisplayName, p.Name
                    
                    local title,msg,duration,sound do
                        title = l_plr:IsFriendsWith(p.UserId) and 'Friend joined' or 'Player joined'
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
                leave = serv_players.PlayerRemoving:Connect(function(p) 
                    local display, name = p.DisplayName, p.Name
                    
                    local title,msg,duration,sound do
                        title = l_plr:IsFriendsWith(p.UserId) and 'Friend left' or 'Player left'
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
            local corner = u_modlist:AddDropdown('Corner'):SetTooltip('The corner the modlist is in')
            corner:AddOption('Top left'):SetTooltip('Sets the modlist to be at the top left')
            corner:AddOption('Top right'):SetTooltip('Sets the modlist to be at the top right')
            corner:AddOption('Bottom left'):SetTooltip('Sets the modlist to be at the bottom left; default option'):Select()
            corner:AddOption('Bottom right'):SetTooltip('Sets the modlist to be at the bottom right')
            
            
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
                    uiframe.Position = dim_sca(0, 0)
                    uiframe.AnchorPoint = vec2(0, 0)
                    
                    uilist.HorizontalAlignment = 'Left'
                    uilist.VerticalAlignment = 'Top'
                    
                    ui:manageml(-100, 10, 'Left', 'PaddingLeft')
                    
                elseif (s == 'Top right') then
                    uiframe.Position = dim_sca(1, 0)
                    uiframe.AnchorPoint = vec2(1, 0)
                    
                    uilist.HorizontalAlignment = 'Right'
                    uilist.VerticalAlignment = 'Top'
                    
                    ui:manageml(-100, 10, 'Right', 'PaddingRight')
                elseif (s == 'Bottom left') then
                    uiframe.Position = dim_sca(0, 1)
                    uiframe.AnchorPoint = vec2(0, 1)
                    
                    uilist.HorizontalAlignment = 'Left'
                    uilist.VerticalAlignment = 'Bottom'
                    
                    ui:manageml(-100, 10, 'Left', 'PaddingLeft')
                elseif (s == 'Bottom right') then
                    uiframe.Position = dim_sca(1, 1)
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
            
            local s_theme = u_theme:AddDropdown('Theme'):SetTooltip('The preset theme to use. If you want to make your own then edit the config')
            local s_save = u_theme:AddButton('Save'):SetTooltip('Saves the selected theme to the theme config. Requires a restart to load the theme')
            local s_apply = u_theme:AddButton('Apply'):SetTooltip('Saves the selected theme to the theme config. Automatically restarts')
            
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
                    
                    local _ = s_theme:AddOption(b):SetTooltip(c)
                    if ( i == 1 ) then _:Select() end
                end
            end)
        end
        
        
        u_jeff:SetTooltip('🗿🗿🗿')
        u_modlist:SetTooltip('Displays what modules you currently have enabled in a list')
        u_plr:SetTooltip('Get notifications whenever a player joins / leaves the server')
        u_theme:SetTooltip('Lets you choose a UI theme. <b>This "mod" is only temporary and will be replaced by a separate window for UI theming soon!</b>')
    end
    local m_server = ui:CreateMenu('Server') do 
        local s_autohop = m_server:AddMod('AutoHop'..betatxt)
        local s_autorec = m_server:AddMod('AutoReconnect'..betatxt)
        local s_hop = m_server:AddMod('Server hop'..betatxt, 'Button')
        local s_priv = m_server:AddMod('Private server'..betatxt,'Button')
        local s_rejoin = m_server:AddMod('Rejoin', 'Button')
        
        -- Autohop
        do 
            local MsgChangedCon
            s_autorec:Connect('Enabled',function() 
                local kicktime = 0
                
                MsgChangedCon = serv_gui.ErrorMessageChanged:Connect(function() 
                    -- Debounce cause messagechanged gets fired multiple times for some reason
                    local curtime = tick()
                    if (curtime - kicktime < 10) then
                        return
                    end
                    kicktime = tick()
                    
                    -- Notify
                    wait(1)
                    serv_gui:ClearError()
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
                
                MsgChangedCon = serv_gui.ErrorMessageChanged:Connect(function() 
                    -- Debounce cause messagechanged gets fired multiple times for some reason
                    local curtime = tick()
                    if (curtime - kicktime < 10) then
                        return
                    end
                    kicktime = tick()
                    
                    -- Notify
                    wait(1)
                    serv_gui:ClearError()
                    ui:Notify('Auto Reconnect','Auto reconnecting in a few seconds, hang tight', 5, 'high')
                    wait(1)
                    
                    -- Player kicked, rejoin
                    if (#serv_players:GetPlayers() <= 1) then
                        serv_tps:Teleport(game.PlaceId, l_plr)
                    else
                        serv_tps:TeleportToPlaceInstance(game.PlaceId, game.JobId, l_plr)
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
                            local Data = serv_http:JSONDecode(game:HttpGet(APIURL))
                            local Servers = Data.data
                            local TargetServers = {}
                            
                            if (#Servers == 0) then
                                ui:Notify('Server hop','Roblox returned that there are no existing servers. This game is likely not compatible with Server hop',5, 'low')
                                return 
                            end
                            
                            local j = 0
                            for i = 1, 200 do 
                                if (j > 25) then break end
                                
                                local Server = Servers[mrandom(1,#Servers)]
                                if (Server.playing == Server.maxPlayers or Server.id == CurJobId) then continue end
                                tinsert(TargetServers, Server.id)
                                j += 1
                            end
                            
                            if (#TargetServers == 0) then
                                -- search more here (adding that later)
                                ui:Notify('Server hop','Couldn\'t find a valid server; you may already be in the smallest one. Try again later',5, 'low')
                                
                            else
                                local serv = TargetServers[mrandom(1,#TargetServers)]
                                serv_tps:TeleportToPlaceInstance(CurPlaceId, serv, l_plr)
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
                        p_Backframe = inst_new('Frame')
                        p_Backframe.BackgroundTransparency = 1
                        p_Backframe.Size = dim_sca(0,0)
                        p_Backframe.Position = dim_sca(0.5, 0.5)
                        p_Backframe.AnchorPoint = vec2(0.5, 0.5)
                        p_Backframe.ZIndex = 300
                        p_Backframe.Parent = sc
                                        
                        p_Header = inst_new('TextLabel')
                        p_Header.BackgroundColor3 = RLTHEMEDATA['bm'][1]
                        p_Header.BackgroundTransparency = RLTHEMEDATA['bm'][2]
                        p_Header.BorderSizePixel = 0
                        p_Header.Font = RLTHEMEFONT
                        p_Header.RichText = true
                        p_Header.Size = dim_new(1, 0, 0,20)
                        p_Header.Text = 'Private server'
                        p_Header.TextColor3 = RLTHEMEDATA['tm'][1]
                        p_Header.TextSize = 19
                        p_Header.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                        p_Header.TextStrokeTransparency = 0
                        p_Header.TextXAlignment = 'Center'
                        p_Header.ZIndex = 301
                        p_Header.Parent = p_Backframe
                        
                        stroke(p_Header, 'Border')
                        
                        p_Window = inst_new('Frame')
                        p_Window.BackgroundColor3 = RLTHEMEDATA['gw'][1]
                        p_Window.BackgroundTransparency = RLTHEMEDATA['gw'][2]
                        p_Window.BorderSizePixel = 0
                        p_Window.Position = dim_off(0, 20)
                        p_Window.Size = dim_new(1, 0, 1, -20)
                        p_Window.ZIndex = 300
                        p_Window.Parent = p_Backframe
                        
                        p_Progress1 = inst_new('Frame')
                        p_Progress1.AnchorPoint = vec2(0.5, 0)
                        p_Progress1.BackgroundTransparency = 1
                        p_Progress1.Position = dim_new(0.5, 0, 0.1, 0)
                        p_Progress1.Size = dim_new(1, -10, 0, 20)
                        p_Progress1.ZIndex = 301
                        p_Progress1.Parent = p_Window
                        
                        p_Progress2 = inst_new('Frame')
                        p_Progress2.BackgroundColor3 = RLTHEMEDATA['ge'][1]
                        p_Progress2.BackgroundTransparency = 0.5
                        p_Progress2.BorderSizePixel = 0
                        p_Progress2.Size = dim_sca(0,1)
                        p_Progress2.ZIndex = 302
                        p_Progress2.Parent = p_Progress1
                        
                        stroke(p_Progress1)
                        
                        p_Status = inst_new('TextLabel')
                        p_Status.AnchorPoint = vec2(0.5, 1)
                        p_Status.BackgroundTransparency = 1
                        p_Status.Font = RLTHEMEFONT
                        p_Status.Position = dim_new(0.5, 0, 1, 0)
                        p_Status.RichText = true
                        p_Status.Size = dim_new(1, 0, 0, 40)
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
                        
                        twn(p_Backframe, {Size = dim_sca(0.2, 0.1)}, true)
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
                                Worked = pcall(function() jsondata = serv_http:JSONDecode(jsondata) end)
                                
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
                                    
                                    EstimatedServerCount = mfloor(((CurrentPlaying / MaxServers)*1.01)+1)
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
                                wait(0.1 + (mrandom(10, 30)*0.01))
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
                                        p_Progress2.Size = dim_sca((CurrentServerCount/EstimatedServerCount), 1)
                                        p_Status.Text = ('Fetching more servers... (%s / ~%s)'):format(CurrentServerCount, EstimatedServerCount)
                                        continue
                                    else
                                        p_Progress2.Size = dim_sca(1, 1)
                                        -- There are no more servers (on the last page), so handle stuff                                 
                                        -- Get the servers for this page and make a table that will hold a few matching servers
                                        wait(0.3)
                                        writefile('thegggj.json',OldData)
                                        local Servers = CurrentData.data
                                        for i,v in ipairs(Servers) do print(v.playing,v.maxPlayers) end
                                        local TargetServers = {}
                                        
                                        -- Save the 40 smallest servers
                                        for i = 0, 39 do 
                                            tinsert(TargetServers, Servers[#Servers-i])
                                        end
                                        
                                        -- Store a success variable (used to identify if it couldn't teleport to / find a server)
                                        local Worked = false
                                        for i = 1, 100 do 
                                            -- Increase progress bar to show progress
                                            --p_Progress2.Size = dim_sca(0.8 + (i/100), 1)
                                            -- Update text
                                            p_Status.Text = ('Checking for a valid server (%s out of 100 tries)'):format(i)
                                            -- Yield to display text and progress
                                            wait()
                                            
                                            -- Get a random server (this is why there are 25 attempts)
                                            local Server = TargetServers[mrandom(1, #TargetServers)]
                                            if (Server.id == CurJobId or Server.playing == Server.maxPlayers) then
                                                -- If the chosen server is the current one or if its full then continue
                                                continue
                                            else
                                                -- Otherwise teleport to this server
                                                p_Status.Text = 'Got a matching server! Teleporting...'
                                                Worked = true
                                                wait(0.5)
                                                serv_tps:TeleportToPlaceInstance(CurPlaceId, Server.id, l_plr)
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
                    twn(p_Progress2, {Size = dim_sca(0, 1)}, true)
                    wait(0.1)
                    twn(p_Backframe, {Size = dim_sca(0, 0)}, true).Completed:Wait()
                    p_Backframe:Destroy()
                    
                    -- Done
                end))
                end)
            end)
        end
        
        -- Rejoin
        do
            s_rejoin:Connect('Clicked',function() 
                if #serv_players:GetPlayers() <= 1 then
                    l_plr:Kick('\nRejoining, one second...')
                    wait(0.3)
                    serv_tps:Teleport(game.PlaceId, l_plr)
                else
                    serv_tps:TeleportToPlaceInstance(game.PlaceId, game.JobId, l_plr)
                end
            end)
        end
        
        s_autohop:SetTooltip('Automatically server hops whenever you get disconnected. Useful for server ban evading')
        s_autorec:SetTooltip('Automatically rejoins whenever you get disconnected')
        s_hop:SetTooltip('Teleports you to a random server')
        s_priv:SetTooltip('Teleports you to one of the smallest servers possible. May take a bit of time to search, but atleast it has a snazzy progress bar')
        s_rejoin:SetTooltip('Rejoins you into the current server. <b>Don\'t rejoin too many times, or you\'ll get error 268</b>')
    end
    --[[
    local w_Search = ui:CreateWidget('Search', dim_new(1,-325,1,-225), vec2(300, 50), true) do 
        
    end
    ]]
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
    local sound = inst_new('Sound')
    sound.SoundId = 'rbxassetid://9009663963'--'rbxassetid://8781250986'
    sound.Volume = 1
    sound.TimePosition = 0.15
    sound.Parent = ui:GetScreen()
    sound.Playing = true
    do 
        local center = workspace.CurrentCamera.ViewportSize/2
        
        local col = RLTHEMEDATA['ge'][1]
        local dn = function() 
            local _ = draw_new('Line')
            _.Visible = true
            _.Color = col
            _.Thickness = 4
            return _
        end
        local lines = {}
        
        
        local SizeAnimation 
        local PositionAnim
        
        SizeAnimation = serv_run.RenderStepped:Connect(function(dt) 
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
                tinsert(lines, {_, center + vec2(-200, 0), 0})
            end
            do
                local _ = dn()
                _.From = up
                _.To = up
                tinsert(lines, {_, center + vec2(-66, 45), 0})
            end
            do
                local _ = dn()
                _.From = up
                _.To = up
                tinsert(lines, {_, center + vec2(66, 45), 0})
            end
            do
                local _ = dn()
                _.From = up
                _.To = up
                tinsert(lines, {_, center + vec2(200, 0), 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(-200, 0)
                _.To = _.From
                tinsert(lines, {_, center + vec2(0, 66), 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(200, 0)
                _.To = _.From
                tinsert(lines, {_, center + vec2(0, 66), 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(-200, 0)
                _.To = _.From
                tinsert(lines, {_, down, 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(-66, 44)
                _.To = _.From
                tinsert(lines, {_, down, 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(66, 44)
                _.To = _.From
                tinsert(lines, {_, down, 0})
            end
            do
                local _ = dn()
                _.From = center + vec2(200, 0)
                _.To = _.From
                tinsert(lines, {_, down, 0})
            end
        end
        wait(1)
        SizeAnimation:Disconnect()
        wait(1)
        
        local y = 0
        PositionAnim = serv_run.RenderStepped:Connect(function(dt) 
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
        local bf = ui:GetBackframe()
        
        local prism = inst_new('ImageLabel')
        prism.AnchorPoint = vec2(0, 0)
        prism.BackgroundTransparency = 1
        prism.Image = 'rbxassetid://8951023311'
        prism.ImageColor3 = RLTHEMEDATA['ge'][1]
        prism.Position = dim_sca(0.5, 0.5)
        prism.Size = dim_off(0,0)
        
        local redline = inst_new('ImageLabel')
        redline.BackgroundTransparency = 1
        redline.Image = 'rbxassetid://8950999035'
        redline.ImageColor3 = RLTHEMEDATA['tm'][1]
        redline.AnchorPoint = vec2(0, 0)
        redline.Position = dim_sca(0.5, 0.5)
        redline.Size = dim_sca(0.8, 0.8)

        redline.Parent = bf
        prism.Parent = bf
    

        redline.AnchorPoint = vec2(0,0)
        prism.AnchorPoint = vec2(0,0)
        
        redline.Size = dim_off(150, 150)
        prism.Size = dim_off(75, 75) 
        
        prism.Position = dim_off(25, -105)
        redline.Position = dim_off(90, -155)
        
        twn(prism, {Position = dim_off(25, 35)},true)
        twn(redline, {Position = dim_off(90, -5)},true)
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
