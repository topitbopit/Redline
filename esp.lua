local serv_rs = game:GetService("RunService")
local l_cam = workspace.CurrentCamera

local drawnew = Drawing.new
local ins, rem = table.insert, table.remove
local vec2, vec3, cf = Vector2.new, Vector3.new, CFrame.new

local delay, spawn = task.delay, task.spawn

local lib = {} do
    -- 2D offset
    local offset2d = cf(-1, 1, 0)
    -- 3D offsets

    -- Hidden internal table
    local b = {}
    -- Object table
    b.objects = {}

    -- Local stuff
    local l_cam = workspace.CurrentCamera
    local screenx = l_cam.ViewportSize.X
    local screeny = l_cam.ViewportSize.Y

    -- Camera connections
    do 
        -- Camera viewport size updater function
        local function upd() 
            -- Disconnect existing camera connection (if it exists)
            if (b.CON_CAM2) then b.CON_CAM2:Disconnect() end 

            -- Hook ViewportSize changes and update the screenx & screeny vars
            b.CON_CAM2 = l_cam:GetPropertyChangedSignal('ViewportSize'):Connect(function() 
                local vp = l_cam.ViewportSize
                screenx = vp.X
                screeny = vp.Y
            end)
        end

        b.CON_CAM1 = workspace:GetPropertyChangedSignal('CurrentCamera'):Connect(function() 
            -- Camera changed, relocalize the new camera
            l_cam = workspace.CurrentCamera
            -- Update the viewport connection
            upd()

            -- // I don't think cameras can change / update and workspace.CurrentCamera is readonly, but
            -- // i dont really care.
            -- // This is a good failsafe to have anyways
        end)

        upd()
    end

    -- Runservice connections
    do  
        -- Setup the current RGB step
        local _ = 0
        local __ = Color3.fromHSV
        local ___ = 3
        b.CON_RS = serv_rs.RenderStepped:Connect(function(____) 
            local len = #objs
            if (len == 0) then return end
            _ = (_ > 1 and 0 or _ + ____*___)
            

            local color = __(_,1,1)
            local objs = b.objects

            for i = 1, len do 
                objs[i]['box1']['Color'] = color
            end
        end)
    end
    function b.create_2d(parent) 
        local obj = {}

        do 
            local _ = drawnew('Square')
            _.Visible = true
            _.Thickness = 1
            
            obj['box1'] = _
        end
        do 
            local _ = drawnew('Square')
            _.Visible = true
            _.Thickness = 3
            _.Color = Color3.new(0,0,0)

            obj['box2'] = _
        end
        do 
            local _ = drawnew('Text')
            _.Font = 1
            _.Size = 20
            _.Outline = true
            _.OutlineColor = Color3.new(0,0,0)
            _.Visible = true

            obj['tex1'] = _
        end
        obj['par'] = parent
        obj['des'] = false

        obj.Destroy = b.destroy
        obj.Update = b.update2d
        obj.SetParent = b.setpar

        ins(b.objects, obj)
    end

    b.setpar = function(self, parent) 
        self['par'] = parent
    end
    b.destroy = function(self) 
        self.des = true

        local objs = b.objects
        for i = 1, #objs do 
            local obj = objs[i]
            if (obj == self) then
                rem(objs, i)
                break
            end
        end


        self['box1']:Remove()
        self['box2']:Remove()
        self['tex1']:Remove()
    end
    b.update2d = function(self) 
        -- Get the parent
        local parent = self.par

        -- Check if...
        --   - The object is being destroyed (skip this update to not get "render object destroyed" errors)
        --   - If the object is on cooldown (skip this update for performance)
        --   - If the object doesn't have a parent (keep it alive so that it can be reparented later)
        -- If any of these conditions fail then dont update it
        if (self.des or self.cd or (not parent)) then 
            self['box1'].Visible = false
            self['box2'].Visible = false
            self['tex1'].Visible = false
            return 
        end
        -- Get the 3d cframe of the parent and multiply the offset
        local pos3d = parent.CFrame * offset2d
        -- Get the 2d position of the cframe
        local pos2d, visible = l_cam:WorldToViewportPoint(pos3d.Position)
    
        -- If the object is offscreen then don't finish updating it
        if (not visible) then 
            -- Cooldowns are used so it checks at a slower pace when offscreen

            -- Enable cooldown
            self.cd = true
            -- Wait .2 seconds to disable the cooldown
            delay(.2, function() 
                self.cd = false
            end)
            -- Hide stuff
            self['box1'].Visible = false
            self['box2'].Visible = false
            self['tex1'].Visible = false

            -- Don't update
            return 
        end

        -- Every check passed, so handle the instances
        -- Get every drawing component
        local box_inner = self['box1']
        local box_outer = self['box2']
        local text = self['tex1']

        -- Calculate where the box should be
        -- Depth is used to figure out approx where the other corners should be
        local depth = pos2d.Z
        -- Position of the boxes are just the 2d pos
        local box_pos = vec2(pos2d.X, pos2d.Y)
        -- The size takes the screen size - depth, so that the objects grow smaller the farther away they are
        -- The 0.1 and 0.25 are just arbitrary width / height values
        local box_size = vec2((screenx - depth) * 0.09, (screeny - depth) * 0.13)

        -- Update inner box
        box_inner.Size = box_size
        box_inner.Position = box_pos

        -- Update outer box
        box_outer.Size = box_size
        box_outer.Position = box_pos

        -- Update text
        text.Position = box_pos + vec2(box_size.X*.5, -18)

        text.Visible = true
        box_inner.Visible = true
        box_outer.Visible = true
    end

    lib.DestroyAll = function() 
        local objs = b.objects
        b.CON_CAM1:Disconnect()
        b.CON_CAM2:Disconnect()
        b.CON_RS:Disconnect()

        for i = 1, #objs do 
            objs[i]:Destroy()
        end
    end
    lib.GetObjectCount = function() return #b.objects end)
    lib.Create2d = b.create_2d
end


