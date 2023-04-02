--[[

            REDLINE
             :**:             
           :+*%%*+:           
         :+=.+--+.=+:         
       :+=. :#  #: .=+:       
     :+=.   *-  -*   .=+:     
   :+=     :#    #:     =+:   
  -@*:::.  *:    :*  .:::*@-  
   :*#=:-=+%--::--%+=-:=#*:   
     :+=.  #-:--:-#  .=+:     
       :+=.-+    +-.=+:       
         :++%:  :%++:         
           :*#..#*:           
             :++:                
]]--



-- WARNING: this is pretty much entirely shitcode
-- im currently working on a rewrite with 10x more features
-- join discord for updates https://discord.gg/TyKZFQtDvw

if ( _G.RLLOADED and _G.RLNOTIF ) then
    _G.RLNOTIF('Oops', 'Redline is already loaded. Destroy the current instance by pressing [END]', 5, 'warn', true)
    return
end


if ( not isfolder('REDLINE') ) then
    makefolder('REDLINE')
end


local REDLINEVER = 'v0.7.2'

if not game:IsLoaded() then game.Loaded:Wait() end

--- Services
local servContext   = game:GetService('ContextActionService')
local servGui       = game:GetService('GuiService')
local servHttp      = game:GetService('HttpService')
local servNetwork   = game:GetService('NetworkClient')
local servPlayers   = game:GetService('Players')
local servRun       = game:GetService('RunService')
local servTeleport  = game:GetService('TeleportService')
local servTween     = game:GetService('TweenService')
local servInput     = game:GetService('UserInputService')

-- Colors
local colRgb, colNew = Color3.fromRGB, Color3.new
-- UDim2
local dimOffset, dimScale, dimNew = UDim2.fromOffset, UDim2.fromScale, UDim2.new
-- Instances
local instNew = Instance.new
local drawNew = Drawing.new
-- Vectors
local vec3, vec2 = Vector3.new, Vector2.new
-- Other stuff
local isrbxactive = isrbxactive or iswindowactive
local isexecclosure = is_synapse_function  or isexecutorclosure or isourclosure


if ( isrbxactive == nil ) then
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

local blankfn = function() end -- used for flags


-- { Load in theme } --
local function DecodeThemeJson(json) 
    json = json:gsub('//[^\n]+','')

    local stuff = servHttp:JSONDecode(json)
    local theme = stuff['theme']
    
    local RLTHEME
    local RLTHEMEFONT
    do
        RLTHEME = {}
        RLTHEMEFONT = theme['Font']
        
        -- this is an extremely shitty idea (but atleast it works for now 👍👍)
        local switch = {}
        switch['Generic_Outline']       = 'go'
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
        

        for Index, ThemeSetting in pairs(theme) do
            if ( typeof(ThemeSetting) ~= 'table' ) then 
                continue 
            end            
            if ( not switch[Index] ) then 
                continue 
            end

            local Color1 = ThemeSetting['Color']
            local Color2 = ThemeSetting['Color2']
            local IsGradient = ThemeSetting['Gradient']
            local Trans = ThemeSetting['Transparency']
            
            RLTHEME[switch[Index]] = {
                colRgb(Color1[1], Color1[2], Color1[3]);
                Trans;
                IsGradient;
                Color2 and colRgb(Color2[1], Color2[2], Color2[3]);
            }
        end
    end
    
    return RLTHEME, RLTHEMEFONT
end

if (isfile('REDLINE/theme.json')) then
    _G.RLLOADERROR = 0
    
    local ThemeData, Font
    pcall(function()
        local FileData = readfile('REDLINE/theme.json')
        ThemeData, Font = DecodeThemeJson(FileData)
    end)
    
    if ( ThemeData and Font ) then
        _G.RLTHEMEDATA = ThemeData
        _G.RLTHEMEFONT = Font
    else
        _G.RLLOADERROR = 2 -- couldnt load theme properly
    end
end

--- theme
local RLTHEMEDATA, RLTHEMEFONT do 
    RLTHEMEFONT = _G.RLTHEMEFONT or 'SourceSans'
    RLTHEMEDATA = _G.RLTHEMEDATA or {} 
    
    local keys = {
        ['go'] = { colRgb(075, 075, 080), 0.0, false}; -- generic outline (3rd argument should be true for gradients)
        ['gs'] = { colRgb(005, 005, 010), 0.0}; -- generic shadow
        ['gw'] = { colRgb(023, 022, 027), 0.2}; -- generic window
        ['ge'] = { colRgb(225, 035, 061), 0.7}; -- generic enabled
        ['bm'] = { colRgb(035, 035, 040), 0.0}; -- header background
        ['bo'] = { colRgb(030, 030, 035), 0.0}; -- object background
        ['bs'] = { colRgb(025, 025, 030), 0.0}; -- setting background
        ['bd'] = { colRgb(020, 020, 025), 0.0}; -- dropdown background
        ['hm'] = { colRgb(038, 038, 043), 0.0}; -- header hovering
        ['ho'] = { colRgb(033, 033, 038), 0.0}; -- object hovering
        ['hs'] = { colRgb(028, 028, 033), 0.0}; -- setting hovering
        ['hd'] = { colRgb(023, 023, 028), 0.0}; -- dropdown hovering
        ['sf'] = { colRgb(225, 075, 080), 0.0}; -- slider foreground
        ['sb'] = { colRgb(033, 033, 038), 0.0}; -- slider background
        ['tm'] = { colRgb(255, 255, 255), 0.0}; -- main text
        ['to'] = { colRgb(020, 020, 025), 0.0}; -- outline
    }
    
    for i, v in pairs(keys) do 
        RLTHEMEDATA[i] = RLTHEMEDATA[i] or v
    end
end

--- random utility shit 
local gradient,twn,ctwn,randstr,stroke,round,uierror
do
    do
        local gradColor
        if ( RLTHEMEDATA['go'][3] ) then 
            gradColor = ColorSequence.new{
                ColorSequenceKeypoint.new(0, RLTHEMEDATA['go'][1]);
                ColorSequenceKeypoint.new(1, RLTHEMEDATA['go'][4]);
            }
        end
        function gradient(parent)
            local newGradient = instNew('UIGradient')
            newGradient.Rotation = 45
            newGradient.Color = gradColor
            newGradient.Parent = parent
        
            return newGradient
        end
    end
    
    function stroke(parent, mode, trans) 
        local str = instNew('UIStroke')
        str.ApplyStrokeMode = mode or 'Contextual'
        str.Thickness = 1
        
        str.Transparency = trans or RLTHEMEDATA['go'][2]
        
        if ( RLTHEMEDATA['go'][3] ) then -- if gradients are being used, add a gradient
            gradient(str) 
            str.Color = colNew(1, 1, 1)
        else
            str.Color = RLTHEMEDATA['go'][1] -- leave the color as the default outline
        end
        
        str.Parent = parent
        return str
    end
    
    local info1, info2 = TweenInfo.new(0.1, 10, 1), TweenInfo.new(0.3, 10, 1)
    
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
    
    function randstr() 
        local a = ''
        for i = 1, 5 do a = a .. utf8.char(math.random(50,2000)) end 
        return a 
    end
    
    function round(num, place) 
        return math.floor(((num+(place*.5)) / place)) * place
    end
    
    function uierror(func, prop, type) 
        error(('%s failed; %s is not of type %s'):format(func,prop,type), 3)
    end
end



local W_WindowOpen = false
local RGBCOLOR


--- ui 
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
        if ( gpe == false and io.UserInputType.Value == 8 ) then
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
        
        ui_Connections['r'] = servRun.Heartbeat:Connect(function(deltaTime) 
            if ( not isrbxactive() ) then 
                return 
            end
            
            rgbtime += deltaTime / 10 
            if ( rgbtime > 1 ) then
                rgbtime -= 1  
            end
            
            RGBCOLOR = Color3.fromHSV(rgbtime, 0.8, 1)
            
            for i = 1, #rgbinsts do 
                local v = rgbinsts[i]
                v[1][ v[2] ] = RGBCOLOR
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
    
    
    local ModlistPadding = { -- i still have no clue why i thought this was a good idea 
        dimOffset(-100, 0).X;
        dimOffset(8, 0).X;
        Enum.TextXAlignment.Left;
        'PaddingLeft';
    } 
    
    do 
        w_Screen = instNew('ScreenGui')
        w_Screen.DisplayOrder = 939393
        w_Screen.IgnoreGuiInset = true
        w_Screen.Name = randstr()
        w_Screen.ZIndexBehavior = Enum.ZIndexBehavior.Global
        
        if ( typeof(syn) == 'table' and typeof(syn.protect_gui) == 'function' and gethui == nil ) then
            syn.protect_gui(w_Screen)  
        end
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
        
        local tooltipPadding = instNew('UIPadding')
        tooltipPadding.PaddingLeft = dimOffset(5, 0).X
        tooltipPadding.Parent = w_Tooltip
        
        w_Tooltip:GetPropertyChangedSignal('Text'):Connect(function() 
            w_Tooltip.Size = dimOffset(175, 25)
            local n = dimOffset(0, 5)
            
            for i = 1, 25 do 
                w_Tooltip.Size += n
                
                if ( w_Tooltip.TextFits ) then 
                    break 
                end
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
            local paddingDir = ModlistPadding[4]
            local direction = paddingDir == 'PaddingLeft' and 'PaddingRight' or paddingDir
            local value = dimOffset(0,0).X
            for i = 1, #c do
                local v = c[i]
                if (v.ClassName == 'TextLabel' and v ~= w_ModListTitle) then
                    v.TextXAlignment = align
                    local p = v.P
                    --p[__] = _
                    p[direction] = value
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
    
    
    
    ui_Connections['t'] = servRun.Heartbeat:Connect(function() 
        local pos = servInput:GetMouseLocation()
        local x,y = pos.X, pos.Y
        w_TooltipHeader.Position = dimOffset(x+15, y+15)
        w_MouseCursor.Position = dimOffset(x-4, y)
    end)
    
    
    local ModListEnable, ModListDisable, ModListInit, ModListModify do 
        local mods_instance = {}
        
        
        function ModListEnable(name) 
            local b = mods_instance[name]
            
            b.TextXAlignment = ModlistPadding[3]
            b.Parent = w_ModList
            twn(b.P, {[ModlistPadding[4]] = ModlistPadding[2]},true)
            twn(b, {Size = dimNew(1, 0, 0, 24), TextTransparency = 0, TextStrokeTransparency = 0},true)
        end
        
        function ModListDisable(name)
            local b = mods_instance[name]
            
            twn(b.P, {[ModlistPadding[4]] = ModlistPadding[1]},true)
            twn(b, {Size = dimNew(0, 0, 0, 0), TextTransparency = 1, TextStrokeTransparency = 1},true)
        end
        
        function ModListModify(name, new) 
            mods_instance[name].Text = new
        end
        
        function ModListInit(name) 
            local label = instNew('TextLabel')
            label.Size = dimNew(0, 0, 0, 0)
            label.BackgroundTransparency = 1
            label.Font = RLTHEMEFONT
            label.TextXAlignment = ModlistPadding[3]
            label.TextColor3 = RLTHEMEDATA['tm'][1]
            label.TextSize = 22
            label.Text = name
            label.RichText = true
            label.TextTransparency = 1
            label.TextStrokeTransparency = 1
            label.TextStrokeColor3 = RLTHEMEDATA['to'][1]
            label.ZIndex = 5
            
            mods_instance[name] = label
            
            table.insert(rgbinsts, {label, 'TextColor3'})
            
            
            local padding = instNew('UIPadding')
            padding.Name = 'P'
            padding[ModlistPadding[4]] = ModlistPadding[1]
            padding.Parent = label
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
                
                
                task.spawn(self.Flags.Toggled, t)
                task.spawn(self.Flags[t and 'Enabled' or 'Disabled'])
                
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
                
                task.spawn(self.Flags.Toggled, true)
                task.spawn(self.Flags.Enabled)
                
                twn(self.Effect, {Size = s1}, true)
                
                ModListEnable(self.Name)
                return self 
            end
            base_class.module_toggle_disable = function(self) 
                self.OToggled = false
                
                task.spawn(self.Flags.Toggled, false)
                task.spawn(self.Flags.Disabled)
                
                twn(self.Effect, {Size = s2}, true)
                
                ModListDisable(self.Name)
                return self
            end
            base_class.module_toggle_reset = function(self)
                if (self.OToggled) then
                    local f = self.Flags
                    task.spawn(f.Toggled, false)
                    task.spawn(f.Disabled)
                    
                    task.spawn(f.Toggled, true)
                    task.spawn(f.Enabled)
                end
            end
            base_class.module_getstate_self = function(self) return self.OToggled end
            base_class.module_getstate_menu = function(self) return self.MToggled end
            
            base_class.module_setvis = function(self, t, t2) 
                self.Root.Visible = t 
                self.Highlight.Visible = t2
            end 
            
            base_class.module_click_self = function(self) 
                task.spawn(self.Flags.Clicked)
                
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
                
                task.spawn(self.Flags.Toggled, t)
                task.spawn(self.Flags.Enabled)
                task.spawn(self.Flags.Disabled)
                
                self.Toggled = t
                twn(self.Icon, {BackgroundTransparency = t and 0 or 1})
                return self
            end 
            base_class.s_toggle_enable = function(self) 
                self.Toggled = true
                
                task.spawn(self.Flags.Toggled, true)
                task.spawn(self.Flags.Enabled)
                
                twn(self.Icon, {BackgroundTransparency = 0})
                return self
            end 
            base_class.s_toggle_disable = function(self) 
                self.Toggled = false
                
                task.spawn(self.Flags.Toggled, false)
                task.spawn(self.Flags.Disabled)
                
                twn(self.Icon, {BackgroundTransparency = 1})
                return self
            end 
            base_class.s_toggle_reset = function(self) 
                if (self.Toggled) then
                    local f = self.Flags
                    task.spawn(f.Toggled, false)
                    task.spawn(f.Disabled)
                    
                    task.spawn(f.Toggled, true)
                    task.spawn(f.Enabled)
                end
            end
            base_class.s_toggle_getstate = function(self) 
                return self.Toggled
            end
            
            base_class.s_modhotkey_sethotkey = function(self) 
                local label = self.Label
                label.Text = 'Press any key...'
                
                task.wait(0.01)
                local cn
                cn = servInput.InputBegan:Connect(function(input, gpe)
                    
                    local code = input.KeyCode 
                    local codeName = code.Name
                    if ( codeName ~= 'Unknown' ) then
                        
                        self.Hotkey = code.Value
                        label.Text = 'Hotkey: ' .. codeName
                        
                        -- As scuffed as this is, it works
                        -- To prevent the module being bound from immediately toggling, a short delay is made
                        task.delay(0.01, function()
                            local name = self.Parent.Name
                            
                            for i = 1, #ui_Hotkeys do 
                                if (ui_Hotkeys[i][3] == name) then
                                    table.remove(ui_Hotkeys, i)
                                    break
                                end
                            end
                            
                            table.insert(ui_Hotkeys, {code.Value, function() 
                                self.Parent:Toggle()
                            end, name})
                        end)
                    else
                        self.Hotkey = nil    
                        label.Text = 'Hotkey: N/A'
                        
                        local name = self.Parent.Name
                        for i = 1, #ui_Hotkeys do 
                            if ui_Hotkeys[i][3] == name then
                                table.remove(ui_Hotkeys, i)
                                break
                            end
                        end
                    end
                    
                    cn:Disconnect()
                end)
            end
        
            base_class.s_modhotkey_gethotkey = function(self) 
                return self.Hotkey
            end
            
            base_class.s_hotkey_sethotkey = function(self) 
                local label = self.Label
                label.Text = 'Press any key...'
                
                task.wait(0.01);
                local c;
                c = servInput.InputBegan:Connect(function(io,gpe)
                    local kc = io.KeyCode
                    local kcv = kc.Value
                    if (kcv ~= 0) then
                        
                        self.Hotkey = kc
                        label.Text = self.Name..': '..kc.Name
                        
                        task.spawn(self.Flags.HotkeySet, kc, kcv)
                    else
                        self.Hotkey = nil    
                        label.Text = self.Name..': N/A'
                        
                        task.spawn(self.Flags.HotkeySet, nil, 0)
                    end
                    c:Disconnect()
                end)
            end
            
            base_class.s_hotkey_sethotkeyexplicit = function(self, kc) 
                self.Hotkey = kc
                self.Label.Text = self.Name..': '..kc.Name
                
                task.spawn(self.Flags.HotkeySet, kc, kc.Value)
                
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
                
                task.spawn(self.Flags[ t and 'Opened' or 'Closed'])
                
                twn(self.Icon, {Rotation = t and 0 or 180}, true)
            end
            
            base_class.s_ddoption_select_self = function(self) 
                local parent = self.Parent
                
                local objs = parent.Objects
                for i = 1, #objs do objs[i]:Deselect() end
                
                self.Selected = true
                parent.Selection = self.Name
                task.spawn(parent.Flags['Changed'], self.Name, self)
                
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

                
                cval = round(math.clamp(nval, min, self.Max), self.Step)
                
                if (pval ~= cval) then
                    pval = cval
                    local form = self.StepFormat
                    
                    self.SliderFill.Position = dimOffset(math.floor((cval - min) * self.Ratio), 0)
                    self.SliderAmnt.Text = form:format(cval)
                    
                    if (self.Primary) then
                        local n = self.Parent.Name 
                        ModListModify(n, n .. (' <font color="#DFDFDF">('..form..')</font>'):format(cval))
                    end
                    
                    task.spawn(self.Flags.Changed, cval)
                end
                
                self.CurrentVal = cval
            end
            base_class.s_slider_setvalpos = function(self, xval) 
                local min = self.Min
                local cval = self.CurrentVal
                local pval = self.PreviousVal
                
                local pos_normalized = math.clamp(xval - self.SliderBg.AbsolutePosition.X, 0, self.SliderSize)
                
                cval = round((pos_normalized * self.RatioInverse)+min, self.Step)
                
                if (pval ~= cval) then
                    pval = cval
                    local form = self.StepFormat
                    
                    self.SliderFill.Position = dimOffset(math.floor((cval - min)*self.Ratio), 0)
                    self.SliderAmnt.Text = form:format(cval)
                    
                    self.CurrentVal = cval
                    
                    if (self.Primary) then
                        local n = self.Parent.Name 
                        ModListModify(n, n .. (' <font color="#DFDFDF">('..form..')</font>'):format(cval))
                    end
                    
                    task.spawn(self.Flags.Changed, cval)
                end
            end
        end
        -- Button funcs
        base_class.button_click = function(self) 
            task.spawn(self.Flags.Clicked)
        end
        -- Slider funcs
        base_class.slider_setval = function(self, value) 
            value = tonumber(value)
            if not value then uierror('slider_setval','value','number') end
            
            local m1,m2,m3 = self.min, self.max, self.step
            value = math.clamp(round(value, m3),m1,m2)
            
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
                       m_TextPadding.PaddingLeft = dimOffset(8, 0).X -- LEFT PADDING 1
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
                        M_Object.Flags['Enabled'] = blankfn
                        M_Object.Flags['Disabled'] = blankfn
                        M_Object.Flags['Toggled'] = blankfn
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
                
                table.insert(ui_Modules, M_Object)
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
                      m_ModulePadding.PaddingLeft = dimOffset(8, 0).X
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
                        M_Object.Flags['Focused'] = blankfn
                        M_Object.Flags['Unfocused'] = blankfn
                        M_Object.Flags['TextChanged'] = blankfn
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
                        task.spawn(M_Object.Flags.Unfocused, m_ModuleText.Text, enter)
                        if (not nohotkey) then 
                            m_ModuleText.Text = M_Object.Name
                        end
                    end)
                    m_ModuleText.Focused:Connect(function() 
                        task.spawn(M_Object.Flags.Focused)
                    end)
                    m_ModuleText:GetPropertyChangedSignal('Text'):Connect(function() 
                        task.spawn(M_Object.Flags.TextChanged, m_ModuleText.Text)
                    end)
                end
                
                table.insert(ui_Modules, M_Object)
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
                     m_ModulePadding.PaddingLeft = dimOffset(8, 0).X
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
                        M_Object.Flags['Clicked'] = blankfn
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
                
                table.insert(ui_Modules, M_Object)
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
                t_Padding.PaddingLeft = dimOffset(14, 0).X -- LEFT PADDING 2
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
                  t_TextPadding.PaddingLeft = dimOffset(14, 0).X -- LEFT PADDING 2
                  t_TextPadding.Parent = t_Text
                 
                 t_Box1 = instNew('Frame')
                 t_Box1.AnchorPoint = vec2(1,0)
                 t_Box1.BackgroundColor3 = RLTHEMEDATA['sf'][1]
                 t_Box1.BackgroundTransparency = 1
                 t_Box1.BorderSizePixel = 0
                 t_Box1.Position = dimNew(1,-14,0.5,-5) -- RIGHT PADDING
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
                T_Object.Flags['Enabled'] = blankfn
                T_Object.Flags['Disabled'] = blankfn
                T_Object.Flags['Toggled'] = blankfn
                
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
                   d_TextPadding.PaddingLeft = dimOffset(14, 0).X -- LEFT PADDING 2
                   d_TextPadding.Parent = d_HeaderText
                  
                  d_HeaderIcon = instNew('ImageLabel')
                  d_HeaderIcon.Size = dimOffset(25, 25)
                  d_HeaderIcon.Position = dimNew(1,-14 +10, 0, 0) -- RIGHT PADDING
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
                D_Object.Flags['Changed'] = blankfn
                D_Object.Flags['Opened'] = blankfn
                D_Object.Flags['Closed'] = blankfn
                
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
                  h_TextPadding.PaddingLeft = dimOffset(14, 0).X -- LEFT PADDING 2
                  h_TextPadding.Parent = h_Text
                    
            end
                
            local H_Object = {} do 
                H_Object.Label = h_Text
                H_Object.Hotkey = nil
                
                H_Object.Parent = self
                H_Object.Tooltip = nil
                
                H_Object.Flags = {}
                H_Object.Flags['HotkeySet'] = blankfn
                
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
                 h_TextPadding.PaddingLeft = dimOffset(14, 0).X -- LEFT PADDING 2
                 h_TextPadding.Parent = h_Text
            end
                
            local H_Object = {} do 
                H_Object.Label = h_Text
                H_Object.Hotkey = nil
                
                H_Object.Parent = self
                H_Object.Tooltip = nil
                
                H_Object.Name = tostring(text)
                H_Object.Flags = {}
                H_Object.Flags['HotkeySet'] = blankfn
                
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
                  s_TextPad.PaddingLeft = dimOffset(14, 0).X -- LEFT PADDING 2
                  s_TextPad.Parent = s_Text 
                 
                 s_Amount = instNew('TextLabel')
                 s_Amount.Size = dimNew(0, 30, 1, 0)
                 s_Amount.Position = dimNew(1,-14, 0, 0) -- RIGHT PADDING
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
                        (('%.0e'):format(args['step'])):match('e%-0(%d)') -- this is insanely awful but idc 🤑🤑🤑🤑
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
                S_Object.Flags['Changed'] = blankfn
                
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
                    twn(s_Amount, {Position = dimNew(0.5,14,0,0)}, true) -- LEFT PADDING 2
                    
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
                    twn(s_Amount, {Position = dimNew(1,-14,0,0)}, true) -- RIGHT PADDING
                    
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
                 i_TextPad.PaddingLeft = dimOffset(14, 0).X -- LEFT PADDING 2
                 i_TextPad.Parent = i_Input
                
                i_Icon = instNew('ImageLabel')
                i_Icon.AnchorPoint = vec2(1, 0.5)
                i_Icon.Position = dimNew(1, -12, 0.5, 0)                
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
                    I_Object.Flags['Focused'] = blankfn
                    I_Object.Flags['Unfocused'] = blankfn
                    I_Object.Flags['TextChanged'] = blankfn
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
                    task.spawn(I_Object.Flags.Unfocused, i_Input.Text, enter)
                    i_Input.Text = I_Object.Name
                end)
                i_Input.Focused:Connect(function() 
                    task.spawn(I_Object.Flags.Focused)
                end)
                i_Input:GetPropertyChangedSignal('Text'):Connect(function() 
                    task.spawn(I_Object.Flags.TextChanged, i_Input.Text)
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
                 b_Text.Position = dimOffset(0, 0)
                 b_Text.Size = dimNew(1, 0, 1, 0)
                 b_Text.Text = text
                 b_Text.TextColor3 = RLTHEMEDATA['tm'][1]
                 b_Text.TextSize = 18
                 b_Text.TextStrokeColor3 = RLTHEMEDATA['to'][1]
                 b_Text.TextStrokeTransparency = 0
                 b_Text.TextXAlignment = 'Left'
                 b_Text.ZIndex = B_IndexOffset
                 b_Text.Parent = b_Background
                 
                  b_TextPadding = instNew('UIPadding')
                  b_TextPadding.PaddingLeft = dimOffset(14, 0).X -- LEFT PADDING 2
                  b_TextPadding.Parent = b_Text
                
                  
                 b_Icon = instNew('ImageLabel')
                 b_Icon.AnchorPoint = vec2(1,0.5)
                 b_Icon.BackgroundTransparency = 1
                 b_Icon.Position = dimNew(1,-14, 0.5, 0)
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
                    B_Object.Flags['Clicked'] = blankfn
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
                 o_TextPadding.PaddingLeft = dimOffset(22, 0).X -- LEFT PADDING 3
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
            
            table.insert(self.Objects, O_Object)
            return O_Object
        end
        
        base_class.widget_create_label = function(self, text) 
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
            local MenusPerRow = math.floor(((monitor_resolution.X-400) / 300))
            FinalPosition = dimOffset(200+(((M_Id-1)%MenusPerRow)*(300)), 200+150*(math.floor((M_Id-1)/MenusPerRow)))
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
        
        
        
        table.insert(ui_Menus, M_Object)
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
        task.spawn(ui.Flags.Destroying)
        
        
        -- Destroy
        local coreGui = w_Screen.Parent
        w_Screen:Destroy()
        
        -- Unbinds
        servContext:UnbindAction('RL-ToggleMenu')
        servContext:UnbindAction('RL-Destroy')
        
        -- Disconnections
        
        for i,v in pairs(ui_Connections) do 
            v:Disconnect() 
        end
        
        -- Cleanup clearing
        gradient = nil
        randstr = nil
        stroke = nil
        round = nil
        uierror = nil
        ui_Menus = nil
        
        _G.RLLOADED = false
        _G.RLTHEME = nil
        _G.RLTHEMEDATA = nil
        _G.RLTHEMEFONT = nil
        _G.RLLOADERROR = nil
        _G.RLQUEUED = nil
        writefile('REDLINE/Queued.txt', 'false')
        
        local sound = instNew('Sound')
        sound.SoundId = 'rbxassetid://9009668475'
        sound.Volume = 1
        sound.TimePosition = 0.02
        sound.Parent = coreGui
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
            duration = math.clamp(duration or 2, 0.1, 30)
            
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
            
            
            
            table.insert(notifs, m_Notif)
            twn(m_Notif, {Position = m_Notif.Position - dimOffset(300,0)}, true)
            local j = ctwn(m_Progress, {Size = dimOffset(0, 1)}, duration)
            j.Completed:Connect(function()
                do
                    for i = 1, #notifs do 
                        if (notifs[i] == m_Notif) then 
                            table.remove(notifs, i) 
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
    end, false, 999999, Enum.KeyCode.RightShift)
    
    servContext:BindActionAtPriority('RL-Destroy',function(_,uis) 
        if (uis.Value == 0) then
            ui:Destroy()
        end
    end, false, 999999, Enum.KeyCode.End)
    -- Auto collection
    task.delay(5, function() 
        if (ui_Menus ~= nil and #ui_Menus == 0) then
            ui:Destroy()
            warn'[REDLINE] Failure to clean library resources!\nAutomatically cleared for you; make sure to\ncall ui:Destroy() when finished'
        end
    end)
end
-- // END REDLINE LIBRARY

local disabledSignals = {}
local function disablecons(signal, id)
    disabledSignals[id] = disabledSignals[id] or {}
        
    if ( #disabledSignals[id] ~= 0 ) then 
        -- signals are already disabled
        return 
    end
    
    local connections = getconnections(signal)
    for _, cn in ipairs(connections) do 
        local confunc = cn.Function
                
        if ( typeof(confunc) == 'function' and islclosure(confunc) and not isexecclosure(confunc) ) then
            table.insert(disabledSignals[id], cn)
            cn:Disable()
        end
    end
end

local function enablecons(id)
    local signals = disabledSignals[id]
    
    if ( signals == nil or #signals == 0 ) then 
        return 
    end
    
    for _, cn in ipairs(signals) do 
        local confunc = cn.Function
        
        if (typeof(confunc) == 'function' and islclosure(confunc) and not isexecclosure(confunc) ) then
            cn:Enable()
        end
    end
    
    table.clear(disabledSignals[id])
end

local scriptCons = {}

-- Local stuff
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
local clientTeam do 
    scriptCons.teamUpdate = clientPlayer:GetPropertyChangedSignal('Team'):Connect(function() 
        clientTeam = clientPlayer.Team
    end)
    clientTeam = clientPlayer.Team
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
            local RootPart = newChar:WaitForChild('HumanoidRootPart', 5)
            local Humanoid = newChar:WaitForChild('Humanoid', 5)
            
            if (thisManager.onRespawn) then
                thisManager.onRespawn(newChar, RootPart, Humanoid)
            end
            thisManager.Character = newChar
            thisManager.RootPart = RootPart
            thisManager.Humanoid = Humanoid
            
            if (Humanoid) then 
                thisPlayerCons['chr-die'] = Humanoid.Died:Connect(function() 
                    if (thisManager.onDeath) then
                        thisManager.onDeath()
                    end
                end)
            end
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
            
            if (Humanoid) then 
                thisPlayerCons['chr-die'] = Humanoid.Died:Connect(function() 
                    if (thisManager.onDeath) then
                        thisManager.onDeath()
                    end
                end)
            end
            
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

local function getFakeChar() 
    local fakechar = instNew('Model')
    fakechar.Name = randstr()


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
    Right_Shoulder.C0 = CFrame.new(1, 0.5, 0)
    Right_Shoulder.C1 = CFrame.new(-0.5, 0.5, 0)
    Right_Shoulder.Name = 'Right Shoulder'
    Right_Shoulder.Part0 = Torso
    Right_Shoulder.Part1 = Right_Arm
    Right_Shoulder.Parent = Torso

    local Left_Shoulder = instNew('Motor6D')
    Left_Shoulder.C0 = CFrame.new(-1, 0.5, 0)
    Left_Shoulder.C1 = CFrame.new(0.5, 0.5, 0)
    Left_Shoulder.Name = 'Left Shoulder'
    Left_Shoulder.Part0 = Torso
    Left_Shoulder.Part1 = Left_Arm
    Left_Shoulder.Parent = Torso

    local Right_Hip = instNew('Motor6D')
    Right_Hip.C0 = CFrame.new(1, -1, 0)
    Right_Hip.C1 = CFrame.new(0.5, 1, 0)
    Right_Hip.Name = 'Right Hip'
    Right_Hip.Part0 = Torso
    Right_Hip.Part1 = Right_Leg
    Right_Hip.Parent = Torso

    local Left_Hip = instNew('Motor6D')
    Left_Hip.C0 = CFrame.new(-1, -1, 0)
    Left_Hip.C1 = CFrame.new(-0.5, 1, 0)
    Left_Hip.Name = 'Left Hip'
    Left_Hip.Part0 = Torso
    Left_Hip.Part1 = Left_Leg
    Left_Hip.Parent = Torso

    local Neck = instNew('Motor6D')
    Neck.C0 = CFrame.new(0, 1, 0)
    Neck.C1 = CFrame.new(0, -0.5, 0)
    Neck.Name = 'Neck'
    Neck.Part0 = Torso
    Neck.Part1 = Head
    Neck.Parent = Torso

    local RootJoint = instNew('Motor6D')
    RootJoint.C0 = CFrame.new(0, 0, 0)
    RootJoint.C1 = CFrame.new(0, 0, 0)
    RootJoint.Name = 'RootJoint'
    RootJoint.Part0 = HumanoidRootPart
    RootJoint.Part1 = Torso
    RootJoint.Parent = HumanoidRootPart
    
    do 
        for i, v in ipairs(fakechar:GetChildren()) do 
            if ( not v:IsA('BasePart') ) then 
                continue 
            end
            
            v.Material = 'ForceField'
            v.Color = colNew(0.52, 0.52, 0.55)
            
            local glow = instNew('BoxHandleAdornment')
            glow.Adornee = v
            glow.AlwaysOnTop = true
            glow.ZIndex = 10
            glow.Color3 = RLTHEMEDATA['ge'][1]
            glow.Size = v.Size
            glow.Transparency = 0.5
            glow.Parent = v
        end
    end
    
    return fakechar
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
            playerManagers[playerName] = nil
        end 
        playerNames[i] = nil
    end
    playerNames = nil
    playerManagers = nil
    
    servInput.MouseIconEnabled = true
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
            local s_PredictionSlider = c_aimbot:addSlider('Prediction',{min=0,max=1,cur=0,step=0.05}):setTooltip('How far prediction looks ahead. Requires <b>Prediction</b> to be enabled')
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
                            
                            task.spawn(function()
                                
                                while tick() - last < 0.2 do
                                    task.wait() 
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
                            return (team ~= clientTeam)
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
                            return part and (part.Position + (part.AssemblyLinearVelocity * PredictionValue) + vec3(0, VerticalOffset, 0))
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
                            clientCamera.CFrame = CFrame.new(_.Position, position):lerp(_, Smoothness)
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
                
                if ( AimbotConnection ) then 
                    AimbotConnection:Disconnect() 
                    AimbotConnection = nil 
                end
                
                if ( FovCircle ) then 
                    FovCircle:Remove()
                    FovCircle = nil
                end
                
                if ( FovCircleOutline ) then 
                    FovCircleOutline:Remove()
                    FovCircleOutline = nil
                end
            end)
        end
        
        -- Hitboxes
        local c_hitbox = m_combat:addMod('Hitboxes')
        do 
            local s_HitboxSize = c_hitbox:addSlider('Size', {min = 2, max = 50, step = 0.1, value = 5}):setTooltip('How large (in studs) the hitboxes are')
            local s_Transparency = c_hitbox:addSlider('Transparency', {min = 0,max = 1,step = 0.01,value = 0.5}):setTooltip('How transparent the hitboxes are')
            
            local s_HitboxPart = c_hitbox:addDropdown('Hitbox part', true)
            s_HitboxPart:addOption('RootPart'):setTooltip('Expands the RootPart (effectively the same thing as torso)'):Select()
            s_HitboxPart:addOption('Head'):setTooltip('Expands the Head, good for getting headshots')
            
            local s_RGB = c_hitbox:addToggle('RGB'):setTooltip('Makes hitboxes RGB instead of gray')
            local s_TeamCheck = c_hitbox:addToggle('Team check'):setTooltip('Disables hbe for teammates')
            local s_XZOnly = c_hitbox:addToggle('XZ only'):setTooltip('Disables expansion on the Y axis, used for certain games that may break with this disabled')        
            
            local HitboxSize = s_HitboxSize:getValue()
            local Transparency = s_Transparency:getValue()
            
            local RGB = s_RGB:getValue()
            local TeamCheck = s_TeamCheck:getValue()
            local XZOnly = s_XZOnly:getValue()
            
            local HitboxPart = s_HitboxPart:getValue()
            
            s_HitboxSize:Connect('Changed', function(t)
                HitboxSize = t
            end)
            
            s_Transparency:Connect('Changed', function(t)
                Transparency = t
            end)
            
            s_RGB:Connect('Toggled', function(t)
                RGB = t
            end)
            
            s_TeamCheck:Connect('Toggled', function(t)
                TeamCheck = t
                c_hitbox:Reset()
            end)
            
            s_XZOnly:Connect('Toggled', function(t)
                XZOnly = t
            end)
            s_HitboxPart:Connect('Changed', function(s)
                HitboxPart = s 
                c_hitbox:Reset()
            end)
            
            local HitboxConnection
            local root_OldColor
            local root_OldSize 
            
            local head_OldSize = vec3(1.2, 1.1, 1.1)
            
            

            c_hitbox:Connect('Enabled',function() 
                root_OldColor = clientRoot.Color 
                root_OldSize = clientRoot.Size
                
                if ( HitboxPart == 'Head' and clientRoot ) then
                    local head = clientChar:FindFirstChild('Head')
                    if ( head ) then
                        head_OldSize = head.Size 
                    end
                end
                
                HitboxConnection = servRun.Heartbeat:Connect(function(dt) 
                    local size = vec3(HitboxSize, XZOnly and 2 or HitboxSize, HitboxSize)
                    
                    for i, name in ipairs(playerNames) do 
                        local manager = playerManagers[name]
                        if ( TeamCheck and manager.Player.Team == clientTeam ) then 
                            continue 
                        end
                        
                        local humrp = manager.RootPart
                        if ( HitboxPart == 'Head' ) then
                            local head = humrp and manager.Character:FindFirstChild('Head')
                            if ( not head ) then
                                continue
                            end
                            
                            head.Size = size
                            head.Transparency = Transparency
                            
                        elseif ( humrp ) then
                            humrp.Size = size
                            humrp.Color = RGB and RGBCOLOR or root_OldColor
                            humrp.Transparency = Transparency
                        end
                    end
                end)
            end)
            c_hitbox:Connect('Disabled',function() 
                if ( HitboxConnection ) then 
                    HitboxConnection:Disconnect() 
                    HitboxConnection = nil
                end
                
                for i, name in ipairs(playerNames) do 
                    local manager = playerManagers[name]
                    
                    local rootPart = manager.RootPart
                    
                    if ( rootPart ) then
                        rootPart.Transparency = 1
                        rootPart.Color = root_OldColor
                        rootPart.Size = root_OldSize
                        
                        local head = manager.Character:FindFirstChild('Head')
                    
                        if ( head ) then
                            head.Transparency = 0
                            head.Size = head_OldSize 
                        end
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
        local p_antiplayer  = m_player:addMod('Anti-player')
        local p_antiwarp    = m_player:addMod('Anti-warp')
        local p_autoclick   = m_player:addMod('Auto clicker')
        local p_flag        = m_player:addMod('Fakelag')
        local p_flashback   = m_player:addMod('Flashback')
        local p_notrip      = m_player:addMod('Notrip')
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
                    task.wait()
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
                    disablecons(clientPlayer.Idled, 'plr_idled')
                    return 
                end
                if (p == 'Move on idle') then
                    c = clientPlayer.Idled:Connect(function() 
                        clientHumanoid:MoveTo(clientRoot.Position + vec3(0, 0, 2))
                    end)
                    return 
                end
            
                if (p == 'Walk around') then
                    task.spawn(function() 
                        local base = clientRoot.Position
                        while (p_antiafk:isEnabled()) do 
                            task.wait(math.random()*8)
                            clientHumanoid:MoveTo(base + vec3(
                                (math.random()-.5)*15,
                                0,
                                (math.random()-.5)*15)
                            )
                        end
                    end)
                    return
                end
            end)
            p_antiafk:Connect('Disabled', function()
                enablecons('plr_idled')
                
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
                disablecons(clientRoot.Changed, 'rp_changed')
                disablecons(clientRoot:GetPropertyChangedSignal('CanCollide'), 'rp_cancollide')
                disablecons(clientRoot:GetPropertyChangedSignal('Anchored'), 'rp_anchored')
                
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
                                clientRoot.CFrame += vec3(math.random(-100,100)*.1,math.random(0,20)*.1,math.random(-100,100)*.1)
                                break
                            end
                        end		
                    end)
                end
            end)
            p_antifling:Connect('Disabled', function() 
                if (pcon) then pcon:Disconnect() pcon = nil end		
                if (clientRoot.Anchored) then clientRoot.Anchored = false end
                
                enablecons('rp_changed')
                enablecons('rp_cancollide')
                enablecons('rp_anchored')
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
            
            local CurrentCFrame = clientRoot and clientRoot.CFrame or CFrame.new(0,0,0)
            local PreviousCFrame = clientRoot and clientRoot.CFrame or CFrame.new(0,0,0)
            
            p_antiwarp:Connect('Enabled',function() 
                disablecons(clientRoot.Changed, 'rp_changed')
                disablecons(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                
                
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
                
                enablecons('rp_changed')
                enablecons('rp_cframe')
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
                task.wait()
                p_autoclick:Reset()
            end)
            
            
            local ClickConnection
            local ConnectionIdentifier
            local visualCircle
            
            p_autoclick:Connect('Enabled',function() 
                ConnectionIdentifier = math.random(1, 9999)
                local _ = ConnectionIdentifier
                
                
                -- Handle shaking
                task.spawn(function() 
                    if (Shake) then
                        while (Shake and p_autoclick:isEnabled()) do 
                            if (not W_WindowOpen) then
                                mousemoverel(math.random(-ShakeAmount, ShakeAmount),math.random(-ShakeAmount, ShakeAmount))
                            else
                                task.wait(0.5)
                            end
                            task.wait(0.02)
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
                            
                            ClickConnection = servRun.Heartbeat:Connect(function(dt)
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
                        task.spawn(function() 
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
                                    task.wait(ClickRate)
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
                                    task.wait(ClickRate)
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
        -- Fake lag
        do 
            local s_Method = p_flag:addDropdown('Method', true)
            s_Method:addOption('Fake'):setTooltip('Doesn\'t affect your network usage. Visualizer is more accurate than Fake, but still may have desync issues'):Select()
            s_Method:addOption('Real'):setTooltip('Limits your actual network usage. May lag more than just your movement. Visualizer is less accurate than Fake, but lag looks more realistic')
            
            local s_LagAmnt = p_flag:addSlider('Amount', { min = 1, max = 10, step = 0.1, cur = 3 }):setTooltip('Lag amount. The larger the number, the more lag you have')
            local LagAmnt = s_LagAmnt:getValue()
            local Method = s_Method:GetSelection()
            
            s_LagAmnt:Connect('Changed', function(v)
                LagAmnt = v 
            end)
            s_Method:Connect('Changed', function(v)
                Method = v 
                p_flag:Reset()
            end)
            
            local fakechar 
            local seat
            p_flag:Connect('Enabled',function() 
                fakechar = getFakeChar()
                local fakerp = fakechar.HumanoidRootPart
                
                if (Method == 'Fake') then
                    local s = Method 
                    
                    local position = clientRoot.CFrame
                    
                    seat = instNew('Seat')
                    seat.Transparency = 1
                    seat.CanTouch = false
                    seat.CanCollide = false
                    seat.Anchored = true
                    seat.CFrame = position
                    
                    local weld = instNew('Weld')
                    weld.Part0 = seat
                    weld.Part1 = nil
                    weld.Parent = seat
                    
                    seat.Parent = workspace
                    
                    task.spawn(function() 
                        while true do 
                            if ( not p_flag:isEnabled() or Method ~= s ) then break end
                            task.wait((math.random(20, 40) * 0.1) / LagAmnt)
                            if ( not p_flag:isEnabled() or Method ~= s ) then break end
                            
                            do
                                seat.Anchored = false
                                local position = clientRoot.CFrame
                                fakechar.Parent = workspace
                                fakerp.CFrame = position
                                
                                seat.CFrame = position
                                weld.Part1 = clientRoot
                            end
                            
                            task.wait(math.random(1,LagAmnt) * 0.1)
                            fakechar.Parent = nil
                            weld.Part1 = nil
                            seat.Anchored = true
                        end 
                    end)
                else
                    task.spawn(function() 
                        local s = Method
                        while true do 
                            if ( not p_flag:isEnabled() or Method ~= s ) then break end
                            task.wait(5 / LagAmnt)
                            if ( not p_flag:isEnabled() or Method ~= s ) then break end
                            
                            
                            fakechar.Parent = workspace
                            fakerp.CFrame = clientRoot.CFrame
                            
                            servNetwork:SetOutgoingKBPSLimit(1)
                            
                            task.wait(math.random(1, LagAmnt) * 0.1)
                            fakechar.Parent = nil
                            servNetwork:SetOutgoingKBPSLimit(9e9)
                        end 
                    end)
                end 
            end)
            
            p_flag:Connect('Disabled',function() 
                if (seat) then 
                    seat:Destroy() 
                    seat = nil 
                end 
                
                fakechar:Destroy()
                servNetwork:SetOutgoingKBPSLimit(9e9)
            end)
        end
        -- Flashback
        do 
            local s_flashDelay = p_flashback:addSlider('Delay', { min = 0,max = 5,cur = 0,step = 0.1}, true)
            s_flashDelay:setTooltip('How long to wait before teleporting you back')
            
            local v_flashDelay = s_flashDelay:getValue()
            
            s_flashDelay:Connect('Changed', function(value) 
                v_flashDelay = value
            end)
            
            local respawnCn
            
            p_flashback:Connect('Enabled', function() 
                local respawnPos = clientRoot and clientRoot.CFrame
                
                local function teleportFunc() -- microoptimizations 🤑
                    clientRoot.CFrame = respawnPos 
                end
                
                local function bind(humanoid) 
                    humanoid.Died:Connect(function() 
                        if ( not clientRoot ) then -- ????
                            return
                        end
                        respawnPos = clientRoot.CFrame
                        clientPlayer.CharacterAdded:Wait()
                        
                        task.delay(v_flashDelay, teleportFunc)
                    end)
                end
                
                respawnCn = clientPlayer.CharacterAdded:Connect(function() 
                    task.wait(0.03)
                    bind(clientHumanoid)
                end)
                
                bind(clientHumanoid)
            end)
            
            p_flashback:Connect('Disabled', function() 
                respawnCn:Disconnect()
            end)
        end
        -- Notrip
        do 
            local respawnCn
            
            p_notrip:Connect('Enabled', function()
                local function hook(h) 
                    h:SetStateEnabled(0, false)
                    h:SetStateEnabled(1, false)
                    h:SetStateEnabled(16, false)
                end
                if ( clientHumanoid ) then
                    hook(clientHumanoid)
                end
                
                respawnCn = clientPlayer.CharacterAdded:Connect(function(c) 
                    local hum = c:WaitForChild('Humanoid', 5)
                    hook(hum)
                end)
            end)
            p_notrip:Connect('Disabled',function() 
                respawnCn:Disconnect()
                
                if ( clientHumanoid ) then
                    clientHumanoid:SetStateEnabled(0, true)
                    clientHumanoid:SetStateEnabled(1, true)
                    clientHumanoid:SetStateEnabled(16, true) 
                end
            end)
        end
        -- Safe min
        do 
            local s_DetectMode = p_safemin:addDropdown('Detection mode', true):setTooltip('The method used to detect tabbing out. Leave on default unless detection stops working')
            s_DetectMode:addOption('Default'):setTooltip('Uses UserInputService to detect window minimizing. Some scripts may mess with this event!'):Select()
            s_DetectMode:addOption('Backup'):setTooltip('Uses isrbxactive to detect window minimizing. May not be compatible with every exploit')
            
            s_DetectMode:Connect('Changed', function()
                p_safemin:Reset()
            end)
            
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
                    
                    freezecon = servRun.Heartbeat:Connect(function() 
                        clientRoot.Anchored = false
                        if (not focused) then 
                            clientRoot.Anchored = true
                        end
                    end)
                elseif (mode == 'Backup') then 
                    freezecon = servRun.Heartbeat:Connect(function() 
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
                c.Name = randstr()
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
                
                table.insert(waypoints, new)
            end
            
            
            makewp:Connect('Unfocused',function(text) 
                if (not p_waypoints:isEnabled()) then p_waypoints:Enable() end
                
                for i = 1, #waypoints do
                    local wp = waypoints[i]
                    if (wp[1] == text) then
                        for i = 3, 5 do wp[i]:Destroy() end
                        table.remove(waypoints, i)
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
                        table.remove(waypoints, i)
                        break
                    end
                end 
            end)
            
            gotowp:Connect('Unfocused',function(text) 
                for i = 1, #waypoints do
                    local wp = waypoints[i]
                    if (wp[1] == text and clientRoot) then
                        disablecons(clientRoot.Changed, 'rp_changed')
                        disablecons(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                        
                        clientRoot.CFrame = wp[2]
                        
                        enablecons('rp_changed')
                        enablecons('rp_cframe')
                    end
                end 
            end)
            
            deleall:Connect('Clicked',function() 
                for i = 1, #waypoints do
                    local wp = waypoints[i]
                    for i = 3, 5 do wp[i]:Destroy() end
                    waypoints[i] = nil
                end
                table.clear(waypoints)
            end)
            
            p_waypoints:Connect('Enabled',function() 
                waypoints = {}
                
                folder = instNew('Folder')
                folder.Name = randstr()
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
            gotowp:setTooltip('Teleports you to the waypoint matching the name you type in')
        end
        
        p_animspeed:setTooltip('Increases the speed of your character animations. May mess with game logic')
        p_antiafk:setTooltip('Prevents you from being kicked for idling. Make sure to report any problems to me! <i>May not work in games with custom AFK mechanics</i>')
        p_anticrash:setTooltip('Prevents game scripts from while true do end\'ing you. Lets you bypass some clientside anticheats. <i>Doesn\'t work for certain uncommon methods</i>')
        p_antifling:setTooltip('Sorta scuffed anti-fling. Only works on players, not other things like NPCs or in game objects / parts.')
        p_antiplayer:setTooltip('Shows text above players that are within a certain distance. Also has the option to kick you if someone is close enough.')
        p_antiwarp:setTooltip('Prevents your character from being teleported (as in character movement, not a server change)')
        p_autoclick:setTooltip('Automatically clicks for you. Can get up to around 900 CPS (and higher!) with the right settings (60 fps * 15 clicks per frame)')
        p_flag:setTooltip('Makes your character look laggy. <b>Don\'t combine with blink!</b>')
        p_flashback:setTooltip('Teleports you back to your death point after you die. Also known as DiedTP')
        p_safemin:setTooltip('Freezes your character whenever you tab out of your screen. <i>Don\'t combine this with antifling, instead use the antifling \'safemin + anchor\' mode</i>')
        p_waypoints:setTooltip('Lets you save positions and teleport back to them later')
        p_notrip:setTooltip('Mostly prevents you from being knocked over / ragdolling. Useful for antiflings')

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
        local m_parkour   = m_movement:addMod('Parkour')
        --local m_phasewalk = m_movement:addMod('Phasewalk')
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
            local mode = m_blink:addDropdown('Mode', true):setTooltip('The method Blink uses')
            mode:addOption('Fakechar'):setTooltip('Clones a semi-working copy of your character and gives you control over it'):Select()
            mode:addOption('Weld'):setTooltip('Abuses a client-side welded seat part to confuse roblox into freezing you. Probably doesn\'t work - this method is very old')
            
            local fakechar
            local seat
            local oldchar
            
            m_blink:Connect('Enabled', function() 
                
                if ( mode:GetSelection() == 'Fakechar' ) then
                    if ( not clientChar ) then
                        ui:Notify('Oops', 'Wait until you\'re spawned in', 2, 'warning')
                        task.wait()
                        m_blink:Disable()
                    end
                    
                    oldchar = clientChar 
                    clientPlayer.Character = nil 
                    
                    oldchar.Archivable = true 
                    fakechar = oldchar:Clone()
                    fakechar.Parent = workspace 
                    
                    clientPlayer.Character = fakechar 
                    clientCamera.CameraSubject = fakechar.Humanoid 
                else
                    fakechar = getFakeChar()
                     -- Not my method, don't know the original creator
                    local position = clientRoot.CFrame
                    
                    seat = instNew('Seat')
                    seat.Transparency = 1
                    seat.CanTouch = false
                    seat.CanCollide = false
                    seat.CFrame = position
                    
                    local weld = instNew('Weld')
                    weld.Part0 = seat
                    weld.Part1 = clientRoot
                    weld.Parent = seat
                    
                    seat.Parent = workspace
                    
                    fakechar.HumanoidRootPart.CFrame = position
                    fakechar.Parent = workspace
                end
            end)
            
            m_blink:Connect('Disabled',function() 
                if ( seat ) then
                    seat:Destroy()
                    seat = nil 
                end
                if ( oldchar ) then
                    clientPlayer.Character = oldchar 
                    clientChar = oldchar
                    clientCamera.CameraSubject = clientHumanoid
                    
                    oldchar = nil 
                end 
                if ( fakechar ) then 
                    clientChar:PivotTo(fakechar:GetPivot())
                    
                    fakechar:Destroy()
                    fakechar = nil 
                end
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
                    
                    local c = CFrame.new(p, p+lv)
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
            local speedslider = m_flight:addSlider('Speed',{min=0,max=350,step=0.01,cur=30})
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
                
                disablecons(clientRoot.Changed, 'rp_changed')
                disablecons(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                disablecons(clientRoot:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
                
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
                            clientRoot.CFrame = CFrame.new(Position, Position + clv)
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
                            clientRoot.CFrame = CFrame.new(Position, Position + clv)
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
                            gyro.CFrame = CFrame.new(Position, Position + clv)
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
                            gyro.CFrame = CFrame.new(Position, Position + clv)
                            clientRoot.CFrame = fi1.CFrame                   
                        end)
                    end
                elseif (curmod == 'Vehicle') then
                    local base = clientRoot.CFrame
                    
                    disablecons(clientRoot.ChildAdded, 'rp_child')
                    disablecons(clientRoot.DescendantAdded, 'rp_desc')
                    disablecons(clientChar.DescendantAdded, 'chr_desc')
                    
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
                            fi2.CFrame = CFrame.new(Position, Position + clv)
                            
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
                            fi2.CFrame = CFrame.new(Position, Position + clv)      
                            
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
                
                
                enablecons('rp_changed')
                enablecons('rp_cframe')
                enablecons('rp_velocity')
                enablecons('rp_child')
                enablecons('rp_desc')
                enablecons('chr_desc')
                    
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
            mode:addOption('Direct'):setTooltip('Directly changes your velocity. Isn\'t perfect, but it\'s basically undetectable. Unlike Mover, Direct requires some fine tuning'):Select()
            mode:addOption('Mover'):setTooltip('Uses a bodymover. Has better results, but is easier to detect')
            
            local vel = m_float:addSlider('Velocity', { min = -10, cur = 0, max = 10, step = 0.1 }):setTooltip('The amount of velocity you\'ll have when floating')
            local amnt = vel:getValue()
            
            mode:Connect('Changed', function() 
                m_float:Reset()
            end)
            
            local fcon
            local finst
            
            local function directFunc(v) 
                amnt = v 
            end
            local function vec3Func(v) 
                finst.Velocity = vec3(0, v, 0) 
            end
            
            vel:Connect('Changed', directFunc)
            
            
            m_float:Connect('Enabled',function() 
                local mode = mode:GetSelection()
                if (mode == 'Direct') then
                    fcon = servRun.Heartbeat:Connect(function() 
                        local vel = clientRoot.Velocity
                        
                        clientRoot.Velocity = vec3(vel.X, amnt + 2.1, vel.Z)
                    end)
                elseif (mode == 'Mover') then
                    disablecons(clientRoot.ChildAdded, 'rp_child')
                    disablecons(clientRoot.DescendantAdded, 'rp_desc')
                    disablecons(clientChar.DescendantAdded, 'chr_desc')
                    
                    finst = instNew('BodyVelocity')
                    finst.MaxForce = vec3(0, 9e9, 0)
                    finst.Velocity = vec3(0, vel:getValue(), 0)
                    finst.Parent = clientRoot
                    
                    vel:Connect('Changed', vec3Func)
                end
            end)
            m_float:Connect('Disabled',function() 
                if (finst) then finst:Destroy(); finst = nil end
                if (fcon) then fcon:Disconnect() fcon = nil end
                
                vel:Connect('Changed', directFunc)
                
                enablecons('rp_child')
                enablecons('rp_desc')
                enablecons('chr_desc')
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
                    
                    disablecons(clientHumanoid:GetPropertyChangedSignal('JumpPower'), 'hum_jp')
                    disablecons(clientHumanoid:GetPropertyChangedSignal('UseJumpPower'), 'hum_ujp')
                    
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
                
                enablecons('hum_jp')
                enablecons('hum_ujp')
            end)
        end
        -- Noclip
        do 
            local s_Mode = m_noclip:addDropdown('Method', true):setTooltip('The method Noclip uses')
            s_Mode:addOption('Standard'):setTooltip('The average CanCollide noclip'):Select()
            s_Mode:addOption('Legacy'):setTooltip('Emulates the older HumanoidState noclip (Just standard, but with a float effect)')
            s_Mode:addOption('Teleport'):setTooltip('Teleports you through walls')
            --s_Mode:addOption('Bypass'):setTooltip('May bypass certain serverside anticheats that rely on the direction you\'re facing')
            
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
                loopid = math.random(1,999999)
                local mode = s_Mode:GetSelection()
                
                if (mode == 'Standard') then
                    local NoclipObjects = {}
                    
                    local c = clientChar:GetChildren()
                    for i = 1, #c do
                        local obj = c[i]
                        if ((obj == nil) or (obj:IsA('BasePart') == false)) then continue end 
                        table.insert(NoclipObjects, obj)
                    end
                    
                    
                    Con_Respawn = clientPlayer.CharacterAdded:Connect(function(chr) 
                        task.wait(0.15)
                        
                        table.clear(NoclipObjects)
                        local c = clientChar:GetChildren()
                        for i = 1, #c do
                            local obj = c[i]
                            if ((obj == nil) or (obj:IsA('BasePart') == false)) then continue end 
                            table.insert(NoclipObjects, obj)
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
                        table.insert(NoclipObjects, obj)
                    end
                    
                    
                    Con_Respawn = clientPlayer.CharacterAdded:Connect(function(chr) 
                        task.wait(0.15)
                        
                        table.clear(NoclipObjects)
                        local c = clientChar:GetChildren()
                        for i = 1, #c do
                            local obj = c[i]
                            if ((obj == nil) or (obj:IsA('BasePart') == false)) then continue end 
                            table.insert(NoclipObjects, obj)
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
                    
                    disablecons(clientRoot.Changed, 'rp_changed')
                    disablecons(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                    
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
                            
                            clientRoot.CFrame = CFrame.new(t, t + lv)
                        end
                    end)
                --[[elseif (mode == 'Bypass') then
                    local p = RaycastParams.new()
                    p.FilterDescendantsInstances = {clientChar}
                    p.FilterType = Enum.RaycastFilterType.Blacklist
                    
                    Con_Respawn = clientPlayer.CharacterAdded:Connect(function(c) 
                        p.FilterDescendantsInstances = {c}
                    end)
                    
                    disablecons(clientRoot.Changed, 'rp_changed')
                    disablecons(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                    
                    
                    
                    Con_Respawn = clientPlayer.CharacterAdded:Connect(function() 
                        m_noclip:Reset()
                    end)
                    
                    local lid = loopid
                    task.spawn(function()
                        while m_noclip:isEnabled() and lid == loopid do
                            local c = clientRoot.CFrame
                            local lv = c.LookVector
                            c = c.Position
                            local m = clientHumanoid.MoveDirection.Unit
                            
                            local j = workspace:Raycast(c, m*LookAhead, p)
                            if (j) then
                                clientRoot.CFrame = CFrame.new(c, c - lv)
                                clientRoot.Anchored = true
                                task.wait(0.1) 
                                clientRoot.Anchored = false
                                local t = j.Position + (m * (j.Distance/2))
                                clientRoot.CFrame = CFrame.new(t, t + lv)
                            end
                            task.wait()
                        end
                    end)]]
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
                
                enablecons('rp_changed')
                enablecons('rp_cframe')
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
                    disablecons(clientRoot.Changed, 'rp_changed')
                    disablecons(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
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
                                clientRoot.CFrame = CFrame.new(p, p + clientRoot.CFrame.LookVector)
                                clientRoot.Velocity = vec3(hv.X, 20, hv.Z)
                            end
                        end
                    end)
                elseif (CurrentMode == 'Decelerate') then
                    disablecons(clientRoot:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
                    disablecons(clientRoot.Changed, 'rp_changed')
                    
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
                                task.delay(0.5, function()
                                    holding = false
                                end)
                            end
                        end
                    end)
                end
            end)
            
            m_nofall:Connect('Disabled',function() 
                if ( rcon ) then 
                    rcon:Disconnect() 
                    rcon = nil 
                end
                if ( plrcon ) then 
                    plrcon:Disconnect() 
                    plrcon = nil 
                end
                
                enablecons('rp_velocity')
                enablecons('rp_changed')
                enablecons('rp_cframe')
            end)
        end
        -- Parkour
        do 
            local s_Delay = m_parkour:addSlider('Delay before jumping', {min = 0, max = 0.2, cur = 0, step = 0.01})
            s_Delay:setTooltip('How long to wait before jumping')
            
            local delay = 0 -- delay before jumping 
            local parkourConn -- main parkour connection
            local refreshConn -- refreshes parkour connection on death 
            
            s_Delay:Connect('Changed', function(value) 
                delay = value 
            end)
            
            m_parkour:Connect('Toggled',function(state) 
                if ( state ) then
                    local function refresh(character) 
                        local humanoid = character:WaitForChild('Humanoid')
                        
                        if ( not humanoid ) then
                            return
                        end 
                        
                        parkourConn = humanoid:GetPropertyChangedSignal('FloorMaterial'):Connect(function() 
                            if ( humanoid.FloorMaterial.Name == 'Air' ) then
                                if ( delay ~= 0 ) then
                                    task.wait(delay)
                                end
                                
                                if ( humanoid.Jump ) then
                                    return
                                end
                                
                                humanoid:ChangeState(3)
                            end
                        end)
                    end
                    
                    refreshConn = clientPlayer.CharacterAdded:Connect(refresh)
                    refresh(clientChar)
                else
                    if ( parkourConn ) then
                        parkourConn:Disconnect() 
                    end
                    if ( refreshConn ) then
                        refreshConn:Disconnect()
                    end
                end
            end)
        end
        --[[ Phasewalk
        do 
            -- s_ prefix for settings
            -- v_ prefix for setting values
            -- definitely not confusing 🤑
            
            local s_idlePhase = m_phasewalk:addToggle('Phase while idle'):setTooltip('Phases your character regardless if you\'re moving or not')
            local s_faceCenter = m_phasewalk:addToggle('Face center'):setTooltip('Faces your character towards the center of the phase location')
            local s_phaseMax = m_phasewalk:addSlider('Max distance', { min = 0, max = 50, step = 0.1, cur = 10 }):setTooltip('Maximum distance your character will phase')
            local s_phaseMin = m_phasewalk:addSlider('Min distance', { min = 0, max = 50, step = 0.1, cur = 10 }):setTooltip('Minimum distance your character will phase')
            
            local v_idlePhase = t_idlePhase:getValue()
            local v_faceCenter = t_faceCenter:getValue()
            local v_phaseMax = s_phaseMax:getValue()
            local v_phaseMin = s_phaseMin:getValue()
            
            s_idlePhase:Connect('Toggled', function(toggle) 
                v_idlePhase = toggle
            end)
            
            s_faceCenter:Connect('Toggled', function(toggle) 
                v_faceCenter = toggle
            end)
            
            s_phaseMax:Connect('Changed', function(value) 
                v_phaseMax = value 
            end)
            
            s_phaseMin:Connect('Changed', function(value) 
                v_phaseMin = value
            end)
            
            do
                local phaseCenter
                local phaseCn
                
                
                m_phasewalk:Connect('Enabled', function() 
                    if ( not clientRoot ) then
                        ui:Notify('Oops', 'You gotta be spawned in first', 3, 'warning')
                        task.wait()
                        m_phasewalk:Disable() 
                    end
                    
                    phaseCn = runService.Heartbeat:Connect(function(deltaTime) 
                        local moveDirection = clientHumanoid.MoveDirection
                        
                    end)
                end)
                
                
                m_phasewalk:Connect('Disabled', function() 
                    if ( phaseCn and phaseCn.Connected ) then
                        phaseCn:Disconnect()
                    end
                end)
                
            end
        end
        ]]
        -- Speed
        do 
            local mode = m_speed:addDropdown('Mode',true)
            mode:addOption('Standard'):setTooltip('Standard CFrame speed. Also called TPWalk or TPSpeed'):Select()
            mode:addOption('Velocity'):setTooltip('Changes your velocity, doesn\'t use any bodymovers. Because of friction, Velocity essentially requires the speed setting to be extremely high (unless you jump / are in the air)')
            mode:addOption('Bhop'):setTooltip('The exact same as Velocity, but it spam jumps. Useful for looking legit in games with bhop mechanics, like Arsenal')
            mode:addOption('Part'):setTooltip('Pushes you physically with a clientside part. Works well with the Notrip module enabled')
            mode:addOption('WalkSpeed'):setTooltip('It\'s highly recommended to not use this mode unless you know what you\'re doing')
            
            local speedslider = m_speed:addSlider('Speed',{min=0,max=250,cur=30,step=0.01})
            local speed = 30
            speedslider:Connect('Changed',function(v)speed=v;end)
            local part
            local scon
                    
            m_speed:Connect('Enabled',function() 
                local mode = mode:GetSelection()
                
                disablecons(clientHumanoid.Changed, 'hum_changed')
                disablecons(clientHumanoid:GetPropertyChangedSignal('Jump'), 'hum_jump')
                disablecons(clientRoot.Changed, 'rp_changed')
                disablecons(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
                disablecons(clientRoot:GetPropertyChangedSignal('Velocity'), 'rp_velocity')
                
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
                    part.Size = vec3(4, 4, 1)
                    part.CanTouch = false
                    part.CanCollide = true
                    part.Anchored = false
                    part.Name = randstr()
                    part.Parent = workspace
                    
                    scon = servRun.Heartbeat:Connect(function(dt) 
                        local md = clientHumanoid.MoveDirection
                        local p = clientRoot.Position
                        
                        part.CFrame = CFrame.new(p-(md), p)
                        part.Velocity = md * (dt * speed * 500)
                        
                        clientHumanoid:ChangeState(8)
                    end)
                elseif (mode == 'WalkSpeed') then
                    disablecons(clientHumanoid:GetPropertyChangedSignal('WalkSpeed'), 'hum_walk')
                    
                    scon = servRun.Heartbeat:Connect(function() 
                        clientHumanoid.WalkSpeed = speed
                    end)
                end
            end)
            
            m_speed:Connect('Disabled',function() 
                if (scon) then scon:Disconnect() scon = nil end
                if (part) then part:Destroy() end
                
                enablecons('hum_changed')
                enablecons('hum_jump')
                
                enablecons('hum_walk')
                
                enablecons('rp_changed')
                enablecons('rp_cframe')
                enablecons('rp_velocity')
                
                
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
                        math.clamp(v.X,-x,x),
                        math.clamp(v.Y,-y,y),
                        math.clamp(v.Z,-z,z)
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
        m_parkour:setTooltip('Jumps when you reach the end of a part')
        --m_phasewalk:setTooltip('Constantly teleports you around while you walk. This is a legacy module ported from Spectrum 😎')
        m_speed:setTooltip('Speedhacks with various bypasses and settings')
        m_velocity:setTooltip('Limits your velocity')
    end
    local m_render = ui:newMenu('Render') do 
        local CrosshairPosition
        
        
        local r_crosshair   = m_render:addMod('Crosshair')
        local r_esp         = m_render:addMod('ESP')
        local r_freecam     = m_render:addMod('Freecam')
        local r_fullbright  = m_render:addMod('Fullbright')
        local r_keystrokes  = m_render:addMod('Keystrokes')
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
                    OuterRing.Radius = 1
                    OuterRing.Thickness = 4
                    OuterRing.ZIndex = 50
                    
                    InnerRing.NumSides = 20
                    InnerRing.Position = OuterRing.Position
                    InnerRing.Radius = 1
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
                        
                        local c = RGBCOLOR
                        v = v + ((3 + (Accuracy and clientRoot and math.clamp(clientRoot.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
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
                        
                        InnerRing.Radius = size / 5
                        OuterRing.Radius = size / 5
                    
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
                        
                        local c = RGBCOLOR
                        
                        v = v + ((3 + (Accuracy and clientRoot and math.clamp(clientRoot.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
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
                        
                        InnerRing.Radius = size / 5 
                        OuterRing.Radius = size / 5 
                    
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
                        v = v + ((3 + (Accuracy and clientRoot and math.clamp(clientRoot.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
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
                        
                        InnerRing.Radius = size / 5 
                        OuterRing.Radius = size / 5 
                    
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
                        
                        local c = RGBCOLOR
                        v = v + ((3 + (Accuracy and clientRoot and math.clamp(clientRoot.Velocity.Magnitude*AccuracyMult, 0, 25) or 0)) - v) * (dt*10)
                        
                    
                        size = Size+(sin(t))
                    
                        local p = InnerRing.Position:lerp(AimbotTarget or vpcen, 0.2)
                        CrosshairPosition = p
                        InnerRing.Position = p
                        OuterRing.Position = p
                        
                        InnerRing.Radius = size / 5 
                        OuterRing.Radius = size / 5 
                    
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
            
            s_Status:Connect('Toggled',function(v)
                Status=v;
                local obj = objs[#objs]
                
                if (obj) then
                    obj.Visible = Status
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
            
            local fcampos = clientRoot and clientRoot.Position or Vector3.zero    
            local speed = 30 -- speed 
            
            local cambased = true 
            camera:Enable()
            resetonenable:Enable()
            
            ascend_h:Connect('HotkeySet',function(j)
                ask=j or 0
            end)
            descend_h:Connect('HotkeySet',function(k)
                dsk=k or 0
            end)
            camera:Connect('Toggled',function(t)
                cambased = t
                r_freecam:Reset()
            end)
            mode:Connect('Changed',function() 
                r_freecam:Reset()
            end)
            freezemode:Connect('Changed',function() 
                r_freecam:Reset()
            end)
            speedslider:Connect('Changed',function(v)
                speed = v
            end)
            
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
                                
                                (IsForwardPressed and vec3(0, normclv.Y , 0) or nonep) + -- If forward is pressed
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
                        local thej = CFrame.new(clientRoot.Position, clientRoot.Position + vec3(0, 0, 1))
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
                            
                            local normalized = CFrame.new(fcampos):ToObjectSpace(thej)
                            
                            clientHumanoid.CameraOffset = (normalized).Position
                        end)
                    else
                        local thej = CFrame.new(clientRoot.Position, clientRoot.Position + vec3(0, 0, 1))
                        fcon = servRun.Heartbeat:Connect(function(dt) 
                            clientRoot.CFrame = thej
                            
                            local up = servInput:IsKeyDown(ask)
                            local down = servInput:IsKeyDown(dsk)
                            
                            local movevec = (clientHumanoid.MoveDirection * dt * 3 * speed)
                            local upvec = (((up and upp or nonep) + (down and downp or nonep))*(dt*3*speed))
                            
                            fcampos += movevec
                            fcampos -= upvec
                            
                            local normalized = CFrame.new(fcampos):ToObjectSpace(thej)
                            
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
                    disablecons(clientRoot.Changed, 'rp_changed')
                    disablecons(clientRoot:GetPropertyChangedSignal('CFrame'), 'rp_cframe')
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
                    enablecons('rp_changed')
                    enablecons('rp_cframe')
                end
            end)
            
            gotocam:Connect('Clicked',function() 
                local pos = campart.Position
                local new = CFrame.new(pos, pos+clientRoot.CFrame.LookVector)
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
            local s_TeamCheck = r_esp:addToggle('Team check'):setTooltip('Skips over targets that are on your team')
            local s_DistCheck = r_esp:addToggle('Distance check'):setTooltip('Skips over targets that are further away than a set threshold')
            local s_Distance = r_esp:addSlider('Distance', { min = 1, max = 5000, cur = 3000, step = 1 }):setTooltip('How far someone away has to be to trigger the distance check and be hidden')
            local s_VisCheck = r_esp:addToggle('Visibility check'):setTooltip('Skips over targets that are behind walls. <b>May show targets behind extremely thin walls, and hide targets that are barely visible!</b>')
            local s_TeamColor = r_esp:addToggle('Team color'):setTooltip('Replaces the box color with their team color') 

            local s_Boxes = r_esp:addToggle('Boxes'):setTooltip('Shows a box around each target')
            local s_Nametags = r_esp:addToggle('Nametags'):setTooltip('Shows the targets\'s display name above their head')
            local s_Tracers = r_esp:addToggle('Tracers'):setTooltip('Shows a line connecting the target to your cursor. Doesn\'t support off-screen targets (which might kinda defeat the point of using tracers, oops)')
            local s_ShowDistance = r_esp:addToggle('Distance display'):setTooltip('Shows a display under each player indicating their distance to you')
            local s_ShowHealth = r_esp:addToggle('Health display'):setTooltip('Shows a health bar display on each player\'s left')   
            
            local s_UpdateDelay = r_esp:addSlider('Update delay', { min = 0, max = 0.1, cur = 0,step = 0.01 }):setTooltip('The delay (in seconds) between ESP updates. If set to 0 before esp is enabled, ESP will be updated on RenderStepped')
            local s_TracerVis = r_esp:addSlider('Tracer transparency', { min = 0, max = 1, cur = 1, step = 0.1 }):setTooltip('The visibility of the tracers - 0 is fully invisible and 1 is fully visible')
            local s_TextSize = r_esp:addSlider('Text size', { min = 10, max = 30, cur = 16, step = 1 }):setTooltip('The size of the text + distance display')
            local s_CornerSize = r_esp:addSlider('Corner size', { min = 1, max = 25, cur = 10, step = 0.1 }):setTooltip('The size / depth of the corners. Only used in the Corners 2d and Corners 3d box types.')
            
            local s_BoxType = r_esp:addDropdown('Box type', true):setTooltip('The type of box to use')
            local s_TracerPosition = r_esp:addDropdown('Tracer position'):setTooltip('Where the tracer is drawn')
            
            s_BoxType:addOption('Box 2d'):setTooltip('Uses a simple 2d box. This is by far the fastest ESP box style - it will definitely not lag'):Select()
            s_BoxType:addOption('Box 3d'):setTooltip('The classic Unnamed ESP style')
            s_BoxType:addOption('Corners 2d'):setTooltip('A 2d box style that only has the corners. Looks cool and is decently fast!')
            s_BoxType:addOption('Corners 3d'):setTooltip('A 3d box style that only has the corners. This is rather expensive, you should expect lag when using this on already slow games')
            
            s_TracerPosition:addOption('Crosshair'):setTooltip('Tracers are drawn at the crosshairs\'s position. If Crosshair is disabled, it resorts to your mouse.'):Select()
            s_TracerPosition:addOption('Character'):setTooltip('Tracers are drawn towards yourself')
            s_TracerPosition:addOption('Down'):setTooltip('Tracers are drawn towards the bottom of your screen')
            s_TracerPosition:addOption('Mouse'):setTooltip('Tracers are drawn at the mouse position')
            
            s_Nametags:Enable()
            s_Boxes:Enable()
            s_ShowHealth:Enable()
            s_ShowDistance:Enable()
            
            -- l_ = localization
            -- s_ = setting
            
            -- Bunch of locals for the extra speed 🤪🤪🤪🤪🤪🤪🤪🤪🤪🤪🤪🤪
            local l_TeamCheck = s_TeamCheck:getValue()
            local l_DistCheck = s_DistCheck:getValue()
            local l_Distance = s_Distance:getValue()
            local l_VisCheck = s_VisCheck:getValue()
            local l_TeamColor = s_TeamColor:getValue()
            
            local l_Boxes = s_Boxes:getValue()
            local l_Nametags = s_Nametags:getValue()
            local l_Tracers = s_Tracers:getValue()
            local l_ShowDistance = s_ShowDistance:getValue()
            local l_ShowHealth = s_ShowHealth:getValue()
            
            local l_UpdateDelay = s_UpdateDelay:getValue()
            local l_TracerVis = s_TracerVis:getValue()
            local l_TextSize = s_TextSize:getValue()
            local l_CornerSize = s_CornerSize:getValue() * 100
            
            local l_BoxType = s_BoxType:getValue()
            local l_TracerPosition = s_TracerPosition:getValue()
                        
            local espCons = {} 
            local espObjs = {} 
            
            local cornerLines = {
                -- bottom left 
               'LineBL1';
               'LineBL2';
                -- bottom right
               'LineBR1';
               'LineBR2';
                -- top left 
               'LineTL1';
               'LineTL2';
                -- top right 
               'LineTR1';
               'LineTR2';
           }
                       
            -- Localization shit
            -- God this is awful
            do
                s_TeamCheck:Connect('Toggled', function(t)
                    l_TeamCheck = t
                end)
                s_DistCheck:Connect('Toggled', function(t)
                    l_DistCheck = t
                end)
                s_Distance:Connect('Changed', function(v)
                    l_Distance = v
                end)
                s_VisCheck:Connect('Toggled', function(t)
                    l_VisCheck = t
                end)
                s_TeamColor:Connect('Toggled', function(t)
                    l_TeamColor = t
                    
                    if ( l_TeamColor ) then 
                        for _, name in ipairs( playerNames ) do 
                            local manager = playerManagers[name]
                            local newColor = manager.Player.TeamColor.Color
                            
                            local thisObjs = espObjs[name] 
                            
                            if ( l_BoxType == 'Box 2d' or l_BoxType == 'Box 3d' ) then
                                thisObjs.Box.Color = newColor
                            else
                                for _, line in ipairs( cornerLines ) do 
                                    thisObjs[line].Color = newColor 
                                end
                            end
                            
                            thisObjs.Tracer.Color = newColor
                        end 
                    end
                end)
                
                s_Boxes:Connect('Toggled', function(t)
                    l_Boxes = t
                end)
                s_Nametags:Connect('Toggled', function(t)
                    l_Nametags = t
                end)
                s_Tracers:Connect('Toggled', function(t)
                    l_Tracers = t
                end)
                s_ShowDistance:Connect('Toggled', function(t)
                    l_ShowDistance = t
                end)
                s_ShowHealth:Connect('Toggled', function(t)
                    l_ShowHealth = t
                end)
                                
                s_UpdateDelay:Connect('Changed', function(v) 
                    l_UpdateDelay = v
                end)
                
                s_TracerVis:Connect('Changed', function(v)
                    l_TracerVis = v
                end)
                
                s_TextSize:Connect('Changed', function(v)
                    l_TextSize = v
                end)
                
                s_CornerSize:Connect('Changed', function(v) 
                    l_CornerSize = v * 100
                end)
                
                s_BoxType:Connect('Changed',function(v)
                    l_BoxType = v
                    r_esp:Reset()
                end)
                
                s_TracerPosition:Connect('Changed',function(v)
                    l_TracerPosition = v
                    
                    r_esp:Reset()
                end)
            end
            
            local function roundVec2(vec2)
                return Vector2.new(math.round(vec2.X), math.round(vec2.Y))
            end
            
            local function addEsp(player) 
                local playerName = player.Name
                local teamColor = player.TeamColor.Color 
                
                local thisObjs = {} 
                local thisCons = {} 

                do 
                    if ( l_BoxType == 'Box 2d' ) then 
                        -- thisObjs.Box
                        do 
                            local Box = Drawing.new('Square')
                            Box.Color = teamColor
                            Box.Filled = false
                            Box.Thickness = 1 
                            Box.Transparency = 1
                            
                            thisObjs.Box = Box 
                        end
                        
                        -- thisObjs.BoxOutline
                        do 
                            local BoxOutline = Drawing.new('Square')
                            BoxOutline.Color = Color3.new(0, 0, 0)
                            BoxOutline.Filled = false
                            BoxOutline.Thickness = 3
                            BoxOutline.Transparency = 1
                            
                            thisObjs.BoxOutline = BoxOutline
                        end
                    elseif ( l_BoxType == 'Box 3d' ) then
                        -- thisObjs.Box
                        do 
                            local Box = Drawing.new('Quad')
                            Box.Color = teamColor
                            Box.Filled = false
                            Box.Thickness = 1 
                            Box.Transparency = 1
                            
                            thisObjs.Box = Box 
                        end
                        
                        -- thisObjs.BoxOutline
                        do 
                            local BoxOutline = Drawing.new('Quad')
                            BoxOutline.Color = Color3.new(0, 0, 0)
                            BoxOutline.Filled = false
                            BoxOutline.Thickness = 3
                            BoxOutline.Transparency = 1
                            
                            thisObjs.BoxOutline = BoxOutline
                        end
                    else
                        
                        for _, line in ipairs( cornerLines ) do 
                            local Line = Drawing.new('Line')
                            Line.Color = teamColor
                            Line.Thickness = 1 
                            Line.Transparency = 1
                            
                            thisObjs[line] = Line
                            
                            local LineO = Drawing.new('Line')
                            LineO.Color = Color3.new(0, 0, 0)
                            LineO.Thickness = 3
                            LineO.Transparency = 1
                            
                            thisObjs[line .. 'O'] = LineO
                        end
                    end
                     
                    -- thisObjs.HealthBar
                    do 
                        local HealthBar = Drawing.new('Line')
                        HealthBar.Color = Color3.new(0.5, 0.1, 0.1)
                        HealthBar.Thickness = 1
                        HealthBar.Visible = false
                        HealthBar.ZIndex = 3
                        
                        thisObjs.HealthBar = HealthBar 
                    end
                    
                    -- thisObjs.HealthBarO
                    do
                        local HealthBarO = Drawing.new('Line')
                        HealthBarO.Color = Color3.new(0, 0, 0)
                        HealthBarO.Thickness = 3
                        HealthBarO.Visible = false
                        HealthBarO.ZIndex = 2
                        
                        thisObjs.HealthBarO = HealthBarO 
                    end
                    
                    -- thisObjs.HealthFill
                    do 
                        local HealthFill = Drawing.new('Line')
                        HealthFill.Color = Color3.new(0, 1, 0)
                        HealthFill.Thickness = 1 
                        HealthFill.Visible = false
                        HealthFill.ZIndex = 4
                        
                        thisObjs.HealthFill = HealthFill 
                    end
                    
                    -- thisObjs.Nametag
                    do 
                        local Nametag = Drawing.new('Text')
                        Nametag.Center = true 
                        Nametag.Color = Color3.new(1, 1, 1)
                        Nametag.Font = Drawing.Fonts.UI
                        Nametag.Outline = true
                        Nametag.OutlineColor = Color3.new(0, 0, 0)
                        Nametag.Size = l_TextSize
                        Nametag.Text = player.DisplayName
                        Nametag.Visible = false
                        
                        thisObjs.Nametag = Nametag
                    end
                    
                    -- thisObjs.Distance
                    do 
                        local Distance = Drawing.new('Text')
                        Distance.Center = true 
                        Distance.Color = Color3.new(0.8, 0.8, 0.8)
                        Distance.Font = Drawing.Fonts.UI
                        Distance.Outline = true
                        Distance.OutlineColor = Color3.new(0, 0, 0)
                        Distance.Size = l_TextSize
                        Distance.Text = '[0]'
                        Distance.Visible = false
                        
                        thisObjs.Distance = Distance
                    end
                    
                    -- thisObjs.Tracer
                    do
                        local Tracer = Drawing.new('Line')
                        Tracer.Color = teamColor
                        Tracer.Thickness = 1
                        Tracer.Visible = false
                        Tracer.ZIndex = 9e6
                        
                        thisObjs.Tracer = Tracer 
                    end
                    
                    -- thisObjs.TracerO
                    do
                        local TracerO = Drawing.new('Line')
                        TracerO.Color = Color3.new(0, 0, 0)
                        TracerO.Thickness = 3
                        TracerO.Visible = false
                        TracerO.ZIndex = 9e6 - 1
                        
                        thisObjs.TracerO = TracerO 
                    end
                end
                
                thisCons.TeamChange = player:GetPropertyChangedSignal('TeamColor'):Connect(function() 
                    if ( l_TeamColor ) then 
                        local newColor = player.TeamColor.Color 
                        
                        if ( l_BoxType == 'Box 2d' or l_BoxType == 'Box 3d' ) then
                            thisObjs.Box.Color = newColor
                        else
                            for _, line in ipairs( cornerLines ) do 
                                thisObjs[line].Color = newColor 
                            end
                        end
                        
                        thisObjs.Tracer.Color = newColor
                    end
                end)
                
                espObjs[playerName] = thisObjs
                espCons[playerName] = thisCons
                
            end
            
            local function delEsp(player) 
                local playerName = player.Name 
                
                if ( not espObjs[playerName] ) then
                    return
                end
                
                for _, obj in pairs(espObjs[playerName]) do 
                    obj:Remove()
                end
                
                for _, con in pairs(espCons[playerName]) do 
                    con:Disconnect()
                end
                
                espObjs[playerName] = nil
                espCons[playerName] = nil
            end
            
            r_esp:Connect('Enabled',function()
                local boxSize = Vector2.new(3500, 4500)
                local raycastParams = RaycastParams.new()
                raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                raycastParams.FilterDescendantsInstances = { clientChar } 
                
                local cornerOffsets = {
                    -- health points
                    ['Health1'] = CFrame.new(2.3, 3, 0);
                    ['Health2'] = CFrame.new(2.3, -3, 0);
                    -- bot left points
                    ['LineBL1'] = CFrame.new(2, -2.75, 0);
                    ['LineBL2'] = CFrame.new(1.75, -3, 0);
                    ['PosBL']   = CFrame.new(2, -3, 0);
                    -- bot right
                    ['LineBR1'] = CFrame.new(-2, -2.75, 0);
                    ['LineBR2'] = CFrame.new(-1.75, -3, 0);
                    ['PosBR']   = CFrame.new(-2, -3, 0);
                    -- top left 
                    ['LineBR1'] = CFrame.new(2, 2.75, 0);
                    ['LineBR2'] = CFrame.new(1.75, 3, 0);
                    ['PosTL']   = CFrame.new(2, 3, 0);
                    -- top right 
                    ['LineTR1'] = CFrame.new(-2, 2.75, 0);
                    ['LineTR2'] = CFrame.new(-1.75, 3, 0);
                    ['PosTR']   = CFrame.new(-2, 3, 0);
                    -- nametag, disttag 
                    ['Nametag'] = CFrame.new(0, 3.2, 0);
                    ['Disttag'] = CFrame.new(0, -3.2, 0);
                    
               }
                
                espCons.playerAdd = servPlayers.PlayerAdded:Connect(addEsp)
                espCons.playerRemove = servPlayers.PlayerRemoving:Connect(delEsp)
                espCons.raycastUpd = clientPlayer.CharacterAdded:Connect(function(newChar) 
                    raycastParams.FilterDescendantsInstances = { newChar } 
                end)
                
                for _, manager in pairs(playerManagers) do 
                    addEsp(manager.Player)
                end
                
                local TracerPos = Vector2.new(0, 0) do 
                    if ( l_TracerPosition == 'Crosshair' ) then
                        local existingCn = espCons.TracerUpd
                        if ( existingCn and existingCn.Connected ) then
                            existingCn:Disconnect() 
                        end
                        
                        espCons.TracerUpd = servRun.Heartbeat:Connect(function() 
                            TracerPos = CrosshairPosition or servInput:GetMouseLocation()
                        end)
                        
                    elseif ( l_TracerPosition == 'Character' ) then
                        local existingCn = espCons.TracerUpd
                        if ( existingCn and existingCn.Connected ) then
                            existingCn:Disconnect() 
                        end
                        
                        espCons.TracerUpd = servRun.Heartbeat:Connect(function() 
                            local rootPos2d = clientCamera:WorldToViewportPoint(clientRoot.Position)
                            TracerPos = vec2(rootPos2d.X, rootPos2d.Y)
                        end)
                        
                    elseif ( l_TracerPosition == 'Down' ) then
                        local existingCn = espCons.TracerUpd
                        if ( existingCn and existingCn.Connected ) then
                            existingCn:Disconnect() 
                        end
                        
                        local screenSize = clientCamera.ViewportSize
                        TracerPos = vec2(screenSize.X / 2, screenSize.Y * 0.8)
                        
                        espCons.TracerUpd = clientCamera:GetPropertyChangedSignal('ViewportSize'):Connect(function() 
                            local screenSize = clientCamera.ViewportSize
                            
                            TracerPos = vec2(screenSize.X / 2, screenSize.Y * 0.8)
                        end)
                        
                    elseif ( l_TracerPosition == 'Mouse' ) then
                        local existingCn = espCons.TracerUpd
                        if ( existingCn and existingCn.Connected ) then
                            existingCn:Disconnect() 
                        end
                        
                        espCons.TracerUpd = servRun.Heartbeat:Connect(function() 
                            TracerPos = servInput:GetMouseLocation()
                        end)
                    end
                end
                
                local function updateEsp() 
                    if ( not isrbxactive() ) then
                        return
                    end
                    
                    local cameraPos = clientCamera.CFrame.Position
                    local localPos = clientRoot.Position
                    
                    local fovOffset = clientCamera.FieldOfView / 70
                    local resOffset = 1080 / clientCamera.ViewportSize.Y
                    
                    for name, manager in pairs(playerManagers) do 
                        local objs = espObjs[name]
                        
                        -- Safety check #1, this handles players that just joined and dont have an ESP object made for them
                        if ( not objs ) then
                            continue
                        end 
                        
                        local root, humanoid = manager.RootPart, manager.Humanoid
                        -- Safety check #2, this handles players that haven't spawned in
                        if ( root == nil or humanoid == nil ) then
                            if ( objs.Nametag.Visible ) then 
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                            end
                            continue
                        end
                        
                        local rootPos = root.Position
                        local rootDistance = ( localPos - rootPos).Magnitude
                        -- Distance check 
                        if ( l_DistCheck and rootDistance > l_Distance ) then
                            if ( objs.Nametag.Visible ) then 
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                            end
                            continue  
                        end 
                        
                        -- Team check 
                        if ( l_TeamCheck and manager.Team == clientTeam ) then
                            if ( objs.Nametag.Visible ) then 
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                            end
                            continue  
                        end 
                        
                        -- Visibility check
                        if ( l_VisCheck ) then
                            local direction = ( rootPos - cameraPos ).Unit * 12345
                            local raycast = workspace:Raycast(cameraPos, direction, raycastParams)
                            
                            if ( raycast ) then
                                
                                if ( ( raycast.Position - rootPos ).Magnitude > 5 ) then --  and raycast.Instance.Name ~= 'HumanoidRootPart' ) then
                                    if ( objs.Nametag.Visible ) then 
                                        for _, obj in pairs(objs) do 
                                            obj.Visible = false 
                                        end
                                    end
                                    continue
                                end
                                
                            else
                                if ( objs.Nametag.Visible ) then 
                                    for _, obj in pairs(objs) do 
                                        obj.Visible = false 
                                    end
                                end
                                continue
                            end 
                        end
                        
                        local pos3d = clientCamera:WorldToViewportPoint(rootPos)
                        
                        local depth = pos3d.Z * fovOffset * resOffset
                        local humHealth = humanoid.Health
                        -- Safety check #3, this handles players that are off screen 
                        if ( depth < 0 ) then
                            if ( objs.Nametag.Visible ) then 
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                            end
                            continue
                        end
                        
                        -- Get some values that will be used later
                        local pos2d = Vector2.new(pos3d.X, pos3d.Y)
                        local healthPercent = math.max(humHealth / humanoid.MaxHealth, 0)
                        
                        -- Localize some objects that will be frequently edited
                        local HealthBar = objs.HealthBar
                        local HealthBarO = objs.HealthBarO
                        local HealthFill = objs.HealthFill
                        local Nametag = objs.Nametag
                        local Distance = objs.Distance
                        local Tracer = objs.Tracer
                        local TracerO = objs.TracerO 
                        
                        -- Visiblity
                        HealthBar.Visible = l_ShowHealth
                        HealthBarO.Visible = l_ShowHealth
                        HealthFill.Visible = l_ShowHealth
                        
                        Distance.Visible = l_ShowDistance 
                        Nametag.Visible = l_Nametags  
                        
                        Tracer.Visible = l_Tracers
                        TracerO.Visible = l_Tracers

                        -- Text
                        Distance.Text = string.format('[%d]', rootDistance)
                        
                        -- Tracers
                        Tracer.Transparency = l_TracerVis
                        TracerO.Transparency = l_TracerVis
                        
                        Tracer.From = TracerPos 
                        Tracer.To = pos2d
                        TracerO.From = TracerPos 
                        TracerO.To = pos2d
                        
                        -- ZIndex
                        local zindexOffset = 1e6 - depth 
                        Distance.ZIndex = zindexOffset + 1
                        HealthBar.ZIndex = zindexOffset
                        HealthBarO.ZIndex = zindexOffset - 1
                        HealthFill.ZIndex = zindexOffset + 1
                        Nametag.ZIndex = zindexOffset + 3
                        
                        -- Box updating 
                        if ( l_BoxType == 'Box 2d' ) then
                            local boxSize = roundVec2(boxSize / depth)
                            local boxHeight = boxSize.Y
                            local textSize = math.max(1000 / depth, l_TextSize)
                            
                            local topLeft = roundVec2(pos2d - ( boxSize / 2 ))
                            
                            local Box = objs.Box
                            local BoxOutline = objs.BoxOutline
                            
                            Box.Position = topLeft
                            Box.Size = boxSize
                            Box.Visible = l_Boxes
                            Box.ZIndex = zindexOffset
                            
                            BoxOutline.Position = topLeft 
                            BoxOutline.Size = boxSize 
                            BoxOutline.Visible = l_Boxes
                            BoxOutline.ZIndex = zindexOffset - 1
                            
                            Distance.Position = roundVec2(pos2d + Vector2.new(0, boxHeight / 2 ))
                            Distance.Size = textSize
                            Nametag.Position = roundVec2(pos2d - Vector2.new(0, Nametag.TextBounds.Y + ( boxHeight / 2 )))
                            Nametag.Size = textSize
                            
                            -- Health bar 
                            do
                                local offset = Vector2.new( -( boxSize.X / 2 + 4 ), (boxHeight / 2 ) ) 
                                
                                local from = roundVec2(pos2d + offset)
                                local toBar = from - Vector2.new(0, boxHeight * healthPercent)
                                local to = from - Vector2.new(0, boxHeight)
                                
                                HealthBar.From = from
                                HealthBar.To = to
                                HealthBarO.From = from
                                HealthBarO.To = to
                                
                                HealthFill.From = from
                                HealthFill.To = toBar
                            end
                            
                        
                            if ( not l_TeamColor ) then
                                Box.Color = RGBCOLOR
                                Tracer.Color = RGBCOLOR
                            end
                            
                        elseif ( l_BoxType == 'Box 3d' ) then
                            local rootCf = root.CFrame
                            
                            local botLeft  = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.PosBL).Position )
                            if ( botLeft.Z < 0 ) then
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                                continue
                            end
                            
                            local botRight = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.PosBR).Position )
                            if ( botRight.Z < 0 ) then
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                                continue
                            end
                            
                            local topLeft  = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.PosTL).Position )
                            if ( topLeft.Z < 0 ) then
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                                continue
                            end
                            
                            local topRight = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.PosTR).Position )
                            if ( topRight.Z < 0 ) then
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                                continue
                            end
                            
                            local namePos = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.Nametag).Position )
                            if ( namePos.Z < 0 ) then
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                                continue
                            end
                            
                            botLeft = roundVec2(botLeft)
                            botRight = roundVec2(botRight)
                            topLeft = roundVec2(topLeft)
                            topRight = roundVec2(topRight)
                            
                            local Box = objs.Box
                            local BoxOutline = objs.BoxOutline
                            
                            Box.PointA = botLeft
                            Box.PointB = botRight 
                            Box.PointC = topRight 
                            Box.PointD = topLeft 
                            Box.Visible = l_Boxes
                            Box.ZIndex = zindexOffset
                            
                            BoxOutline.PointA = botLeft
                            BoxOutline.PointB = botRight 
                            BoxOutline.PointC = topRight 
                            BoxOutline.PointD = topLeft 
                            BoxOutline.Visible = l_Boxes
                            BoxOutline.ZIndex = zindexOffset - 1
                            
                            Nametag.Size = math.max(1000 / namePos.Z, l_TextSize)
                            Nametag.Position = roundVec2(namePos) - Vector2.new(0, Nametag.TextBounds.Y)
                            
                            -- Health bar 
                            do
                                if ( l_ShowHealth ) then 
                                    
                                    local from  = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.Health2).Position )
                                    if ( from.Z < 0 ) then
                                        for _, obj in pairs(objs) do 
                                            obj.Visible = false 
                                        end
                                        continue 
                                    end
                                    
                                    local to = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.Health1).Position )
                                    if ( to.Z < 0 ) then
                                        for _, obj in pairs(objs) do 
                                            obj.Visible = false 
                                        end
                                        continue 
                                    end
                                    
                                    local toBar = clientCamera:WorldToViewportPoint( (rootCf * CFrame.new(2.3, ( healthPercent * 6 ) - 3, 0)).Position )
                                    
                                    toBar = roundVec2(toBar)
                                    from = roundVec2(from)
                                    to = roundVec2(to)
                                    
                                    HealthBar.From = from
                                    HealthBar.To = to
                                    HealthBarO.From = from
                                    HealthBarO.To = to
                                    
                                    HealthFill.From = from
                                    HealthFill.To = toBar
                                end
                            end
                            
                            -- Distance display 
                            if ( l_ShowDistance ) then
                                local distPos = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.Disttag).Position )
                                
                                Distance.Size = math.max(1000 / distPos.Z, l_TextSize)
                                Distance.Position = roundVec2(distPos)
                            end
                            
                            if ( not l_TeamColor ) then
                                Box.Color = RGBCOLOR
                                Tracer.Color = RGBCOLOR
                            end
                            
                        elseif ( l_BoxType == 'Corners 2d' ) then
                            local boxSize = roundVec2(boxSize / depth)
                            local boxHeight = boxSize.Y
                            local textSize = math.max(1000 / depth, l_TextSize)
                            
                            local halfBoxSize = boxSize / 2
                            
                            -- yea i know this method looks awful
                            -- but the only other viable way is using a shit ton of tables / for loops / redundant indexing
                            -- even though this doesnt look good it probably runs the best 👍
                            do
                                local cornerBL  = pos2d + Vector2.new(-halfBoxSize.X, halfBoxSize.Y)
                                local cornerBR  = pos2d + halfBoxSize
                                local cornerTL  = pos2d - halfBoxSize
                                local cornerTR  = pos2d + Vector2.new(halfBoxSize.X, -halfBoxSize.Y)
                                
                                local cornerLen = l_CornerSize / depth
                                local cornerY = Vector2.new(0, cornerLen)
                                local cornerX = Vector2.new(cornerLen, 0)
                                
                                local posBL1 = cornerBL - cornerY
                                local posBL2 = cornerBL + cornerX
                                local posBR1 = cornerBR - cornerY
                                local posBR2 = cornerBR - cornerX
                                local posTL1 = cornerTL + cornerY
                                local posTL2 = cornerTL + cornerX
                                local posTR1 = cornerTR + cornerY
                                local posTR2 = cornerTR - cornerX
                                
                                local LineBL1 = objs.LineBL1
                                local LineBL2 = objs.LineBL2
                                local LineBR1 = objs.LineBR1
                                local LineBR2 = objs.LineBR2
                                local LineTL1 = objs.LineTL1
                                local LineTL2 = objs.LineTL2
                                local LineTR1 = objs.LineTR1
                                local LineTR2 = objs.LineTR2
                                
                                local LineBL1O = objs.LineBL1O
                                local LineBL2O = objs.LineBL2O
                                local LineBR1O = objs.LineBR1O
                                local LineBR2O = objs.LineBR2O
                                local LineTL1O = objs.LineTL1O
                                local LineTL2O = objs.LineTL2O
                                local LineTR1O = objs.LineTR1O
                                local LineTR2O = objs.LineTR2O
                                
                                LineBL1.From = cornerBL
                                LineBL2.From = cornerBL
                                LineBR1.From = cornerBR 
                                LineBR2.From = cornerBR 
                                LineTL1.From = cornerTL 
                                LineTL2.From = cornerTL 
                                LineTR1.From = cornerTR 
                                LineTR2.From = cornerTR 
                                LineBL1.To = posBL1
                                LineBL2.To = posBL2
                                LineBR1.To = posBR1
                                LineBR2.To = posBR2
                                LineTL1.To = posTL1
                                LineTL2.To = posTL2
                                LineTR1.To = posTR1
                                LineTR2.To = posTR2 
                                
                                LineBL1O.From = cornerBL
                                LineBL2O.From = cornerBL
                                LineBR1O.From = cornerBR 
                                LineBR2O.From = cornerBR 
                                LineTL1O.From = cornerTL 
                                LineTL2O.From = cornerTL 
                                LineTR1O.From = cornerTR 
                                LineTR2O.From = cornerTR 
                                LineBL1O.To = posBL1
                                LineBL2O.To = posBL2
                                LineBR1O.To = posBR1
                                LineBR2O.To = posBR2
                                LineTL1O.To = posTL1
                                LineTL2O.To = posTL2
                                LineTR1O.To = posTR1
                                LineTR2O.To = posTR2 
                            end
                            
                            for _, line in ipairs( cornerLines ) do 
                                local Box = objs[line]
                                local BoxOutline = objs[line .. 'O']
                                
                                Box.Visible = l_Boxes
                                Box.ZIndex = zindexOffset
                                BoxOutline.Visible = l_Boxes
                                BoxOutline.ZIndex = zindexOffset - 1 
                            end
                            
                            Distance.Position = roundVec2(pos2d + Vector2.new(0, boxHeight / 2 ))
                            Distance.Size = textSize
                            Nametag.Position = roundVec2(pos2d - Vector2.new(0, Nametag.TextBounds.Y + ( boxHeight / 2 )))
                            Nametag.Size = textSize
                            
                            -- Health bar 
                            do
                                local offset = Vector2.new( -( boxSize.X / 2 + 4 ), (boxHeight / 2 ) ) 
                                
                                local from = roundVec2(pos2d + offset)
                                local toBar = from - Vector2.new(0, boxHeight * healthPercent)
                                local to = from - Vector2.new(0, boxHeight)
                                
                                HealthBar.From = from
                                HealthBar.To = to
                                HealthBarO.From = from
                                HealthBarO.To = to
                                
                                HealthFill.From = from
                                HealthFill.To = toBar
                            end
                            
                            if ( not l_TeamColor ) then
                                for _, line in ipairs( cornerLines ) do 
                                    objs[line].Color = RGBCOLOR 
                                end
                                Tracer.Color = RGBCOLOR
                            end
                            
                        elseif ( l_BoxType == 'Corners 3d' ) then
                            local rootCf = root.CFrame
                            
                            local namePos = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.Nametag).Position )
                            if ( namePos.Z < 0 ) then
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                                continue
                            end
                            
                            local cornerBL = rootCf * cornerOffsets.PosBL
                            local cornerBR = rootCf * cornerOffsets.PosBR
                            local cornerTL = rootCf * cornerOffsets.PosTL
                            local cornerTR = rootCf * cornerOffsets.PosTR
                            
                            local cornerBL2d  = clientCamera:WorldToViewportPoint( cornerBL.Position )
                            if ( cornerBL2d.Z < 0 ) then
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                                continue
                            end
                            
                            local cornerBR2d = clientCamera:WorldToViewportPoint( cornerBR.Position )
                            if ( cornerBR2d.Z < 0 ) then
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                                continue
                            end
                            
                            local cornerTL2d  = clientCamera:WorldToViewportPoint( cornerTL.Position )
                            if ( cornerTL2d.Z < 0 ) then
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                                continue
                            end
                            
                            local cornerTR2d = clientCamera:WorldToViewportPoint( cornerTR.Position )
                            if ( cornerTR2d.Z < 0 ) then
                                for _, obj in pairs(objs) do 
                                    obj.Visible = false 
                                end
                                continue
                            end
                            
                            cornerBL2d = roundVec2(cornerBL2d)
                            cornerBR2d = roundVec2(cornerBR2d)
                            cornerTL2d = roundVec2(cornerTL2d)
                            cornerTR2d = roundVec2(cornerTR2d)
                            
                            do
                                local cornerLen = l_CornerSize / 1000
                                local cornerY = CFrame.new(0, -cornerLen, 0)
                                local cornerX = CFrame.new(-cornerLen, 0, 0)
                                local cornerY_M = CFrame.new(0, cornerLen, 0)
                                local cornerX_M = CFrame.new(cornerLen, 0, 0)
                                
                                local posBL1 = roundVec2( clientCamera:WorldToViewportPoint( ( cornerBL * cornerY_M ).Position ) )
                                local posBL2 = roundVec2( clientCamera:WorldToViewportPoint( ( cornerBL * cornerX ).Position ) )
                                local posBR1 = roundVec2( clientCamera:WorldToViewportPoint( ( cornerBR * cornerY_M ).Position ) )
                                local posBR2 = roundVec2( clientCamera:WorldToViewportPoint( ( cornerBR * cornerX_M ).Position ) )
                                local posTL1 = roundVec2( clientCamera:WorldToViewportPoint( ( cornerTL * cornerY ).Position ) )
                                local posTL2 = roundVec2( clientCamera:WorldToViewportPoint( ( cornerTL * cornerX ).Position ) )
                                local posTR1 = roundVec2( clientCamera:WorldToViewportPoint( ( cornerTR * cornerY ).Position ) )
                                local posTR2 = roundVec2( clientCamera:WorldToViewportPoint( ( cornerTR * cornerX_M ).Position ) )
                                
                                local LineBL1 = objs.LineBL1
                                local LineBL2 = objs.LineBL2
                                local LineBR1 = objs.LineBR1
                                local LineBR2 = objs.LineBR2
                                local LineTL1 = objs.LineTL1
                                local LineTL2 = objs.LineTL2
                                local LineTR1 = objs.LineTR1
                                local LineTR2 = objs.LineTR2
                                
                                local LineBL1O = objs.LineBL1O
                                local LineBL2O = objs.LineBL2O
                                local LineBR1O = objs.LineBR1O
                                local LineBR2O = objs.LineBR2O
                                local LineTL1O = objs.LineTL1O
                                local LineTL2O = objs.LineTL2O
                                local LineTR1O = objs.LineTR1O
                                local LineTR2O = objs.LineTR2O
                                
                                LineBL1.From = cornerBL2d
                                LineBL2.From = cornerBL2d
                                LineBR1.From = cornerBR2d
                                LineBR2.From = cornerBR2d
                                LineTL1.From = cornerTL2d
                                LineTL2.From = cornerTL2d
                                LineTR1.From = cornerTR2d
                                LineTR2.From = cornerTR2d
                                LineBL1.To = posBL1
                                LineBL2.To = posBL2
                                LineBR1.To = posBR1
                                LineBR2.To = posBR2
                                LineTL1.To = posTL1
                                LineTL2.To = posTL2
                                LineTR1.To = posTR1
                                LineTR2.To = posTR2
                                
                                LineBL1O.From = cornerBL2d
                                LineBL2O.From = cornerBL2d
                                LineBR1O.From = cornerBR2d
                                LineBR2O.From = cornerBR2d
                                LineTL1O.From = cornerTL2d
                                LineTL2O.From = cornerTL2d
                                LineTR1O.From = cornerTR2d
                                LineTR2O.From = cornerTR2d
                                LineBL1O.To = posBL1
                                LineBL2O.To = posBL2
                                LineBR1O.To = posBR1
                                LineBR2O.To = posBR2
                                LineTL1O.To = posTL1
                                LineTL2O.To = posTL2
                                LineTR1O.To = posTR1
                                LineTR2O.To = posTR2
                            end
                            
                            for _, line in ipairs( cornerLines ) do 
                                local Box = objs[line]
                                local BoxOutline = objs[line .. 'O']
                                
                                Box.Visible = l_Boxes
                                Box.ZIndex = zindexOffset
                                BoxOutline.Visible = l_Boxes
                                BoxOutline.ZIndex = zindexOffset - 1 
                            end     
                            
                            Nametag.Size = math.max(1000 / namePos.Z, l_TextSize)
                            Nametag.Position = roundVec2(namePos) - Vector2.new(0, Nametag.TextBounds.Y)
                            
                            -- Health bar 
                            do
                                if ( l_ShowHealth ) then 
                                    
                                    local from  = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.Health2).Position )
                                    if ( from.Z < 0 ) then
                                        for _, obj in pairs(objs) do 
                                            obj.Visible = false 
                                        end
                                        continue 
                                    end
                                    
                                    local to = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.Health1).Position )
                                    if ( to.Z < 0 ) then
                                        for _, obj in pairs(objs) do 
                                            obj.Visible = false 
                                        end
                                        continue 
                                    end
                                    
                                    local toBar = clientCamera:WorldToViewportPoint( (rootCf * CFrame.new(2.3, ( healthPercent * 6 ) - 3, 0)).Position )
                                    
                                    toBar = roundVec2(toBar)
                                    from = roundVec2(from)
                                    to = roundVec2(to)
                                    
                                    HealthBar.From = from
                                    HealthBar.To = to
                                    HealthBarO.From = from
                                    HealthBarO.To = to
                                    
                                    HealthFill.From = from
                                    HealthFill.To = toBar
                                end
                            end
                            
                            -- Distance display 
                            if ( l_ShowDistance ) then
                                local distPos = clientCamera:WorldToViewportPoint( (rootCf * cornerOffsets.Disttag).Position )
                                
                                Distance.Size = math.max(1000 / distPos.Z, l_TextSize)
                                Distance.Position = roundVec2(distPos)
                            end
                            
                            if ( not l_TeamColor ) then
                                for _, line in ipairs( cornerLines ) do 
                                    objs[line].Color = RGBCOLOR 
                                end
                                Tracer.Color = RGBCOLOR
                            end
                        end
                    end
                end
                
                if ( l_UpdateDelay == 0 ) then 
                    espCons.espLoop = servRun.RenderStepped:Connect(updateEsp) -- i would use Heartbeat but the frame delay is painful 😔
                else
                    task.spawn(function()
                        while ( r_esp:isEnabled() ) do 
                            updateEsp()
                            
                            task.wait(l_UpdateDelay)
                        end
                    end)
                end
            end)
            
            r_esp:Connect('Disabled',function() 
                for name, manager in pairs(playerManagers) do 
                    delEsp(manager.Player)
                end
                
                for name, cn in pairs(espCons) do -- pairs 
                    cn:Disconnect()
                end
                table.clear(espObjs)
                table.clear(espCons)                 
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
            s_mode:addOption('Bypass'):setTooltip('Soft, but it uses a special bypass setting that will work on more games')
            
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
                disablecons(lighting.Changed, 'li_changed')
                
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
                    
                    if ( loop ) then
                        servRun:BindToRenderStep('RL-Fullbright',9999,fb) 
                        steppedcon = servRun.Stepped:Connect(fb)
                    else
                        fb()   
                    end
                elseif ( mode == 'Bypass' ) then
                    local c1 = colNew(0.6, 0.6, 0.6)
                    local function fb() 
                        twn(lighting, {
                            Ambient = c1,
                            OutdoorAmbient = c1,
                            Brightness = 4,
                            FogEnd = 9e9,
                            FogStart = 9e9
                        }, true)
                    end
                    
                    if ( loop ) then
                        steppedcon = servRun.Heartbeat:Connect(fb)
                    else
                        fb()   
                    end
                end
            end)
            
            r_fullbright:Connect('Disabled',function() 
                servRun:UnbindFromRenderStep('RL-Fullbright')
                if ( steppedcon ) then 
                    steppedcon:Disconnect() 
                    steppedcon = nil
                end
                
                local lighting = game:GetService('Lighting')
                twn(lighting, {
                    Ambient = oldambient,
                    OutdoorAmbient = oldoutambient,
                    Brightness = oldbrightness,
                    FogEnd = oldfogend,
                    FogStart = oldfogstart
                })
                lighting.GlobalShadows   = oldshadows
                
                enablecons('li_changed')
            end)
            
        end
        -- Keystrokes 
        do 
            local kmframe
            
            local InputConnection
            local KSDrag
            
            r_keystrokes:Connect('Enabled',function() 
                kmframe = instNew('Frame')
                kmframe.BackgroundTransparency = 1
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
                disablecons(clientCamera:GetPropertyChangedSignal('FieldOfView'),'cam_fov')
                
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
                enablecons('cam_fov')
                
                if (KeyCon) then KeyCon:Disconnect() KeyCon = nil end
            end)

        end
        
        r_crosshair:setTooltip('Enables a crosshair overlay made in Drawing. Also has extra features for Aimbot')
        r_esp:setTooltip('Displays an overlay over every other player using Drawing. <b>Report any bugs to the Github or in the Discord.</b>')
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
            local updateConn
            local jeffs = {} 
            
            local scale = u_jeff:addSlider('Animation scale', { min = 0, max = 3, step = 0.05, cur = 1 })
            scale:setTooltip('The speed scale of the animation')
            
            u_jeff:Connect('Toggled', function(t) 
                if t then
                    
                    for i = 1, 25 do 
                        local size = math.random(25, 250)
                        local position = Vector2.new(math.random(), math.random())
                        
                        
                        jeff = instNew('ImageLabel')
                        jeff.Size = dimOffset(size, size)
                        jeff.BackgroundTransparency = 1
                        jeff.ImageTransparency = math.random()
                        jeff.Position = UDim2.fromScale(position.X, 5)
                        jeff.Image = 'rbxassetid://8723094657'
                        jeff.ResampleMode = 'Pixelated'
                        jeff.Rotation = math.random(1, 360)
                        jeff.Parent = ui:GetScreen()
                        
                        jeffs[i] = { 
                            image = jeff, 
                            curX = position.X, 
                            curY = position.Y, 
                            rotSpeed = math.random(), 
                            scale = size / 120 
                        } 
                    end
                    
                    local t = 0 
                    
                    if ( updateConn ) then
                        updateConn:Disconnect()
                    end 
                    
                    
                    updateConn = servRun.Heartbeat:Connect(function(deltaTime) 
                        if ( not isrbxactive() ) then
                            return
                        end
                        
                        deltaTime *= scale:getValue()
                        t += deltaTime
                        
                        for idx, jeff in ipairs(jeffs) do
                            -- get the stuff 
                            local image = jeff.image
                            local curX = jeff.curX
                            local curY = jeff.curY
                            local rotSpeed = jeff.rotSpeed 
                            local scale = jeff.scale 
                            
                            -- modify the stuff
                            local targetX = curX + ( deltaTime * scale ) / 7
                            if ( targetX > 1.1 ) then
                                targetX -= 1.3
                                shouldWarpBack = true 
                            end
                            
                            local targetY = curY + math.sin(t + idx) * scale * 0.1 
                            local yLerped = image.Position:Lerp(UDim2.fromScale(0, targetY), 1 - math.exp(-5 * deltaTime)) -- this is kinda scuffed but its simple 
                            image.Position = UDim2.fromScale(targetX, yLerped.Y.Scale)
                            
                            image.Rotation += ( rotSpeed * deltaTime * 15 )
                            
                            if ( image.Rotation > 360 ) then
                                image.Rotation -= 360 
                            end
                            
                            jeff.curX = targetX 
                        end
                    end)
                else
                    updateConn:Disconnect()
                    
                    for i, v in ipairs(jeffs) do
                        v.image:Destroy()
                    end
                    
                    table.clear(jeffs)
                end
            end)
        end
        -- plr
        do 
            local rfriends = u_plr:addToggle('Roblox friends only'):setTooltip('Only send notifications if they are your roblox friend')
            local sound = u_plr:addToggle('Play sound'):setTooltip('Play the notif sound'):Enable()
            
            local soundToggled = true
            sound:Connect('Toggled', function(state)
                soundToggled = state
            end)
            
            local join
            local leave 
            
            u_plr:Connect('Enabled',function() 
                join = servPlayers.PlayerAdded:Connect(function(p) 
                    local display, name = p.DisplayName, p.Name
                    
                    local isFriend = clientPlayer:IsFriendsWith(p.UserId)
                    if ( rfriends:isEnabled() and isFriend == false ) then
                        return
                    end
                    
                    local title = ( isFriend and 'Friend joined' or 'Player joined' )
                    local message 
                    if ( display == name ) then
                        message = string.format('%s has joined the server', name)
                    else
                        message = string.format('%s (%s) has joined the server', display, name) 
                    end
                    
                    local duration = 2.5 
                    local sound = ( soundToggled and 'high' or 'none' )
                    
                    ui:Notify(title, message, duration, sound)
                end)
                
                
                leave = servPlayers.PlayerRemoving:Connect(function(p) 
                    local display, name = p.DisplayName, p.Name
                    
                    local isFriend = clientPlayer:IsFriendsWith(p.UserId)
                    if ( rfriends:isEnabled() and isFriend == false ) then
                        return
                    end
                    
                    local title = ( isFriend and 'Friend left' or 'Player left' )
                    local message 
                    if ( display == name ) then
                        message = string.format('%s has left the server', name)
                    else
                        message = string.format('%s (%s) has left the server', display, name) 
                    end
                    
                    local duration = 2.5 
                    local sound = ( soundToggled and 'low' or 'none' )
                    
                    ui:Notify(title, message, duration, sound)
                end)
            end)
            
            u_plr:Connect('Disabled',function() 
                join:Disconnect()
                leave:Disconnect()
            end)
        end
        -- modlist
        do 
            --[[local corner = u_modlist:addDropdown('Corner'):setTooltip('The corner the modlist is in')
            corner:addOption('Top left'):setTooltip('Sets the modlist to be at the top left')
            corner:addOption('Top right'):setTooltip('Sets the modlist to be at the top right')
            corner:addOption('Bottom left'):setTooltip('Sets the modlist to be at the bottom left; default option'):Select()
            corner:addOption('Bottom right'):setTooltip('Sets the modlist to be at the bottom right')]]
            
            
            local objs = ui:manageml()
            local uiframe = objs[1]
            local uilist = objs[2]
            local uititle = objs[3]
            
            --[[corner:Connect('Changed',function() 
                u_modlist:Reset()
            end)]]
            
            u_modlist:Connect('Enabled',function() 
                --local s = corner:GetSelection()
                
                uiframe.Position = dimScale(0, 1)
                uiframe.AnchorPoint = vec2(0, 1)
                
                uilist.HorizontalAlignment = 'Left'
                uilist.VerticalAlignment = 'Bottom'
                
                ui:manageml(-100, 10, 'Left', 'PaddingLeft')
                
                --[[if (s == 'Top left') then
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
                end]]
                
                
                uiframe.Visible = true
            end)
            
            u_modlist:Connect('Disabled',function() 
                uiframe.Visible = false
            end)
        end
        u_modlist:Enable()
        -- theme
        do 
            
            local s_theme = u_theme:addDropdown('Theme'):setTooltip('The preset theme to use. If you want to make your own then edit the config')
            local s_save = u_theme:AddButton('Save'):setTooltip('Saves the selected theme to the theme config. Requires a restart to load the theme')
            local s_apply = u_theme:AddButton('Apply'):setTooltip('Saves the selected theme to the theme config. Automatically restarts')
            
            local themedata 
            
            s_theme:Connect('Changed', function(o) 
                task.spawn(function()
                    themedata = nil
                                
                    local worked = pcall(function()
                        themedata = game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/themes/'..o..'.json')
                    end)
                    
                    if ( not worked ) then
                        ui:Notify('Oops','Got an error while loading this theme. It may have been removed or modified.', 5, 'warn', true)
                    end
                end)
            end)
            
            s_save:Connect('Clicked',function()
                writefile('REDLINE/theme.json', themedata)
            end)
            s_apply:Connect('Clicked',function()
                writefile('REDLINE/theme.json', themedata)
                ui:Destroy()
                loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/loader.lua'))()
            end)
            
            task.spawn(function()
                local themes = game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/themes/themelist.txt')
                themes = themes:split(']')
                for i = 1, #themes do
                    local a = themes[i] -- insane variable names 
                    local b = a:match('([^|]+)|')
                    local c = a:match('|(.+)')
                    
                    local option = s_theme:addOption(b):setTooltip(c)
                    if ( i == 1 ) then 
                        option:Select() 
                    end
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
                    task.wait(1)
                    servGui:ClearError()
                    ui:Notify('Auto Hop', 'Auto hopping in a few seconds, hang tight', 5, 'high')
                    task.wait(1)
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
                    if ( curtime - kicktime < 10 ) then
                        return
                    end
                    kicktime = tick()
                    
                    -- Notify
                    task.wait(1)
                    servGui:ClearError()
                    ui:Notify('Auto Reconnect', 'Auto reconnecting in a few seconds, hang tight', 5, 'high')
                    task.wait(1)
                    
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
                task.spawn(function()
                    
                    local CurPlaceId = game.PlaceId
                    local CurJobId = game.JobId
                    
                    local APIURL = ('https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=Asc&limit=100'):format(CurPlaceId)
                    
                    
                    do
                        do
                            local Data = servHttp:JSONDecode(game:HttpGet(APIURL))
                            local Servers = Data.data
                            local TargetServers = {}
                            
                            if ( #Servers == 0 ) then
                                ui:Notify('Server hop', 'Roblox returned that there are no existing servers. This game is likely not compatible with Server hop', 5, 'low')
                                return 
                            end
                            
                            local j = 0
                            for i = 1, 200 do 
                                if ( j > 25 ) then 
                                    break 
                                end
                                
                                local Server = Servers[math.random(1,#Servers)]
                                if ( Server.playing == Server.maxPlayers or Server.id == CurJobId ) then 
                                    continue 
                                end
                                
                                table.insert(TargetServers, Server.id)
                                j += 1
                            end
                            
                            if ( #TargetServers == 0 ) then
                                -- search more here (adding that later)
                                ui:Notify('Server hop','Couldn\'t find a valid server; you may already be in the smallest one. Try again later',5, 'low')
                                
                            else
                                local serv = TargetServers[math.random(1,#TargetServers)]
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
            -- im pretty sure this doesn't work anymore 🤑🤑🤑🤑🤑🤑🤑
            
            s_priv:Connect('Clicked', function() 
                task.spawn(function()                    
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
                                    
                                    EstimatedServerCount = math.floor(((CurrentPlaying / MaxServers)*1.01)+1)
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
                                task.wait(0.1 + (math.random(10, 30)*0.01))
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
                                --task.wait()
                                
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
                                        task.wait(0.3)
                                        writefile('thegggj.json',OldData)
                                        local Servers = CurrentData.data
                                        -- for i,v in ipairs(Servers) do print(v.playing,v.maxPlayers) end
                                        local TargetServers = {}
                                        
                                        -- Save the 40 smallest servers
                                        for i = 0, 39 do 
                                            table.insert(TargetServers, Servers[#Servers-i])
                                        end
                                        
                                        -- Store a success variable (used to identify if it couldn't teleport to / find a server)
                                        local Worked = false
                                        for i = 1, 100 do 
                                            -- Increase progress bar to show progress
                                            --p_Progress2.Size = dimScale(0.8 + (i/100), 1)
                                            -- Update text
                                            p_Status.Text = ('Checking for a valid server (%s out of 100 tries)'):format(i)
                                            -- Yield to display text and progress
                                            task.wait()
                                            
                                            -- Get a random server (this is why there are 25 attempts)
                                            local Server = TargetServers[math.random(1, #TargetServers)]
                                            if (Server.id == CurJobId or Server.playing == Server.maxPlayers) then
                                                -- If the chosen server is the current one or if its full then continue
                                                continue
                                            else
                                                -- Otherwise teleport to this server
                                                p_Status.Text = 'Got a matching server! Teleporting...'
                                                Worked = true
                                                task.wait(0.5)
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
                    task.wait(3)
                    
                    p_Header.Text = ''
                    p_Status.Text = ''
                    twn(p_Progress2, {Size = dimScale(0, 1)}, true)
                    task.wait(0.1)
                    twn(p_Backframe, {Size = dimScale(0, 0)}, true).Completed:Wait()
                    p_Backframe:Destroy()
                    
                    -- Done
                end)
            end)
        end
        
        -- Rejoin
        do
            s_rejoin:Connect('Clicked', function() 
                if ( #servPlayers:GetPlayers() <= 1 ) then
                    clientPlayer:Kick('\nRejoining, one second...')
                    task.wait(0.3)
                    servTeleport:Teleport(game.PlaceId)
                else
                    servTeleport:TeleportToPlaceInstance(game.PlaceId, game.JobId)
                end
            end)
        end
        
        s_autohop:setTooltip('Automatically server hops whenever you get disconnected. Useful for server ban evading')
        s_autorec:setTooltip('Automatically rejoins whenever you get disconnected')
        s_hop:setTooltip('Teleports you to a random server')
        s_priv:setTooltip('Teleports you to one of the smallest servers possible. May take a bit of time to search, but atleast it has a snazzy progress bar')
        s_rejoin:setTooltip('Rejoins you into the current server. <b>Don\'t rejoin too many times, or you\'ll get error 268</b>')
    end
end
_G.RLLOADED = true

if ( game.PlaceId == 292439477 or game.PlaceId == 3233893879 ) then
    ui:Notify('Warning', 'Redline is not designed for games with custom character systems.', 5, 'warn', true)
    task.wait(3)
    ui:Notify('Warning', 'It may not function properly, or even function at all.', 5, 'warn', true)
    task.wait(3) 
end

if ( workspace.StreamingEnabled ) then
    ui:Notify('Warning', 'Redline is not designed for games with StreamingEnabled.', 5, 'warn', true)
    task.wait(3)
    ui:Notify('Warning', 'It may not function properly, or even function at all.', 5, 'warn', true)
    task.wait(3) 
end

do
    task.wait(1)
    local sound = Instance.new('Sound')
    sound.SoundId = 'rbxassetid://9009663963'--'rbxassetid://8781250986'
    sound.Volume = 1
    sound.TimePosition = 0.15
    sound.Parent = ui:GetScreen()
    sound.Playing = true
    do 
        local center = servGui:GetScreenResolution() / 2
        
        local col = RLTHEMEDATA['ge'][1]
        local function makeLine() 
            local newLine = drawNew('Line')
            newLine.Visible = true
            newLine.Color = col
            newLine.Thickness = 4
            
            return newLine
        end
        local lines = {}
        
        
        local SizeAnimation 
        local PositionAnim
        
        SizeAnimation = servRun.Heartbeat:Connect(function(deltaTime) 
            deltaTime *= 9
            for i,v in ipairs(lines) do 
                local obj = v[1]
                obj.To = obj.To:lerp(v[2], deltaTime)
            end
        end)
        do
            local up = center + vec2(0, -200)
            local down = center + vec2(0, 200)
        
            do
                local thisLine = makeLine()
                thisLine.From = up
                thisLine.To = up
                table.insert(lines, {thisLine, center + vec2(-200, 0), 0})
            end
            do
                local thisLine = makeLine()
                thisLine.From = up
                thisLine.To = up
                table.insert(lines, {thisLine, center + vec2(-66, 45), 0})
            end
            do
                local thisLine = makeLine()
                thisLine.From = up
                thisLine.To = up
                table.insert(lines, {thisLine, center + vec2(66, 45), 0})
            end
            do
                local thisLine = makeLine()
                thisLine.From = up
                thisLine.To = up
                table.insert(lines, {thisLine, center + vec2(200, 0), 0})
            end
            do
                local thisLine = makeLine()
                thisLine.From = center + vec2(-200, 0)
                thisLine.To = thisLine.From
                table.insert(lines, {thisLine, center + vec2(0, 66), 0})
            end
            do
                local thisLine = makeLine()
                thisLine.From = center + vec2(200, 0)
                thisLine.To = thisLine.From
                table.insert(lines, {thisLine, center + vec2(0, 66), 0})
            end
            do
                local thisLine = makeLine()
                thisLine.From = center + vec2(-200, 0)
                thisLine.To = thisLine.From
                table.insert(lines, {thisLine, down, 0})
            end
            do
                local thisLine = makeLine()
                thisLine.From = center + vec2(-66, 44)
                thisLine.To = thisLine.From
                table.insert(lines, {thisLine, down, 0})
            end
            do
                local thisLine = makeLine()
                thisLine.From = center + vec2(66, 44)
                thisLine.To = thisLine.From
                table.insert(lines, {thisLine, down, 0})
            end
            do
                local thisLine = makeLine()
                thisLine.From = center + vec2(200, 0)
                thisLine.To = thisLine.From
                table.insert(lines, {thisLine, down, 0})
            end
        end
        task.wait(1)
        SizeAnimation:Disconnect()
        task.wait(1)
        
        local y = 0
        PositionAnim = servRun.Heartbeat:Connect(function(deltaTime) 
            local delta1 = deltaTime * 15
            local delta2 = delta1 * 15
        
            y += delta2
            for i,v in ipairs(lines) do
                local obj = v[1]
                obj.From += vec2(0, y) * delta1
                obj.To += vec2(0, y) * delta1
        
                obj.Transparency -= deltaTime * 2
            end
        end)
        
        task.wait(0.5)
        
        PositionAnim:Disconnect()
        for i, v in ipairs(lines) do 
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
        
        twn(prism, {Position = dimOffset(25, 35)}, true)
        twn(redline, {Position = dimOffset(90, -5)}, true)
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
            '\nIf you cannot fix it then delete the file (workspace/REDLINE/theme.json) and reload Redline.'
        )
        
    elseif (err == 2) then
        ui:Notify('Redline got an error when loading','Couldn\'t load theme properly. Check console for more info', 5, 'warn', true)
        print('(Error code 2)')
        print(
            'An unknown error occured while loading the theme config.'..
            '\nMake sure that the theme config\'s values are formatted properly.'..
            '\nIf you cannot fix it then delete the file (workspace/REDLINE/theme.json) and reload Redline.'
        )
    end
else
    _G.RLLOADERROR = nil
    
    ui:Notify(('Redline %s loaded'):format(REDLINEVER), ('Press RightShift to open up the menu'), 7, 'high')
end

-- Teleport queueing (im like 99% confident this doesnt work anymore)
local tpQueue do 
    tpQueue = (typeof(syn) == 'table' and syn.queue_on_teleport) or 
        (typeof(fluxus) == 'table' and fluxus.queue_on_teleport) or 
        (queue_on_teleport)
end 

if ( isfile('REDLINE/Queued.txt') ) then
    _G.RLQUEUED = readfile('REDLINE/Queued.txt'):match('true') ~= nil
else
    _G.RLQUEUED = true
    writefile('REDLINE/Queued.txt', 'true')
end

if ( tpQueue and _G.RLQUEUED == false ) then
    tpQueue[[if(readfile('REDLINE/Queued.txt') == 'true')then loadstring(game:HttpGet('https://raw.githubusercontent.com/topitbopit/Redline/main/loader.lua'))()end]]
    writefile('REDLINE/Queued.txt', 'true')
    _G.RLQUEUED = true
end

function _G.RLNOTIF(...) 
    return ui:Notify(...)
end
