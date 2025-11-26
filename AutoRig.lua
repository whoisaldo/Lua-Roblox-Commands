-- Whoisaldo Github | https://github.com/whoisaldo
--Wisshz on Roblox
--Credit if used

local model = game.Selection:Get()[1]

if model and model:IsA("Model") then
    print("🔧 Starting 'Hub Rig' for " .. model.Name .. "...")

    -- 1. Cleanup (Remove old rig data if exists)
    local oldRoot = model:FindFirstChild("HumanoidRootPart")
    if oldRoot then oldRoot:Destroy() end
    
    -- 2. Find the "Main Body" (The biggest part becomes the Torso)
    local mainPart = nil
    local maxVolume = 0
    
    for _, v in pairs(model:GetChildren()) do
        if v:IsA("BasePart") then
            local vol = v.Size.X * v.Size.Y * v.Size.Z
            if vol > maxVolume then
                maxVolume = vol
                mainPart = v
            end
        end
    end

    if mainPart then
        mainPart.Name = "Torso" -- Rename biggest part to Torso like the example
        print("📍 Main Body found: " .. mainPart.Name)
        
        -- 3. Create HumanoidRootPart
        local root = Instance.new("Part")
        root.Name = "HumanoidRootPart"
        root.Size = Vector3.new(2, 2, 1)
        root.Transparency = 1
        root.CanCollide = false
        root.Anchored = false
        root.CFrame = mainPart.CFrame
        root.Parent = model
        model.PrimaryPart = root
        
        -- 4. Create RootJoint (Root -> Torso)
        local rootJoint = Instance.new("Motor6D")
        rootJoint.Name = "RootJoint"
        rootJoint.Part0 = root
        rootJoint.Part1 = mainPart
        rootJoint.C0 = CFrame.new(0, 0, 0)
        rootJoint.C1 = CFrame.new(0, 0, 0)
        rootJoint.Parent = root -- Standard R15 places RootJoint in HRP
        
        -- 5. Connect ALL other parts to Torso (The "Dad" Model Structure)
        for _, part in pairs(model:GetChildren()) do
            if part:IsA("BasePart") and part ~= root and part ~= mainPart then
                -- Create Motor6D
                local motor = Instance.new("Motor6D")
                motor.Name = part.Name -- Name the joint after the part it holds
                motor.Part0 = mainPart -- The Hub (Torso)
                motor.Part1 = part     -- The Spoke (Limb/Detail)
                
                -- Calculate Offset (So parts stay where they are and don't snap to center)
                motor.C0 = mainPart.CFrame:Inverse() * part.CFrame
                motor.C1 = CFrame.new(0, 0, 0)
                
                motor.Parent = mainPart -- Store joint inside Torso (Like the image!)
                
                -- Physics Cleanup
                part.Anchored = false
                part.CanCollide = false
                part.Massless = true
            end
        end
        
        -- 6. Final Cleanup
        mainPart.Anchored = false
        mainPart.CanCollide = false
        
        -- 7. Add Humanoid
        if not model:FindFirstChild("Humanoid") then
            local hum = Instance.new("Humanoid", model)
            hum.HipHeight = (mainPart.Size.Y / 2) + 0.5
        else
             model.Humanoid.HipHeight = (mainPart.Size.Y / 2) + 0.5
        end
        
        print("✅ SUCCESS: " .. model.Name .. " is rigged exactly like the example!")
    else
        warn("❌ Could not find a Main Body part! Is the model empty?")
    end
else
    warn("❌ Please select a Model first!")
end
