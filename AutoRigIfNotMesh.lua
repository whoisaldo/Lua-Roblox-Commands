-- Whoisaldo Github | https://github.com/whoisaldo
-- 

local model = game.Selection:Get()[1]

if model and model:IsA("Model") then
	print("🔧 Starting 'Deep Hub Rig' for " .. model.Name .. "...")

	-- 1. Cleanup (Remove old rig data if exists)
	local oldRoot = model:FindFirstChild("HumanoidRootPart")
	if oldRoot then oldRoot:Destroy() end
	
	-- 2. Find the "Main Body" (Scan EVERYTHING using GetDescendants)
	local mainPart = nil
	local maxVolume = 0
	local allParts = {} -- We need to save the parts list since we can't loop GetDescendants twice efficiently
	
	-- [[ CHANGE 1: Use GetDescendants() to find parts inside folders ]] --
	for _, v in pairs(model:GetDescendants()) do
		if v:IsA("BasePart") then
			table.insert(allParts, v)
			local vol = v.Size.X * v.Size.Y * v.Size.Z
			if vol > maxVolume then
				maxVolume = vol
				mainPart = v
			end
		end
	end

	if mainPart then
		mainPart.Name = "Torso" 
		print("📍 Main Body found: " .. mainPart.Name)
		
		-- 3. Create HumanoidRootPart
		local root = Instance.new("Part")
		root.Name = "HumanoidRootPart"
		root.Size = Vector3.new(2, 2, 1)
		root.Transparency = 1
		root.CanCollide = false
		root.Anchored = false
		root.CFrame = mainPart.CFrame
		root.Parent = model -- Put Root at the very top
		model.PrimaryPart = root
		
		-- 4. Create RootJoint (Root -> Torso)
		local rootJoint = Instance.new("Motor6D")
		rootJoint.Name = "RootJoint"
		rootJoint.Part0 = root
		rootJoint.Part1 = mainPart
		rootJoint.C0 = CFrame.new(0, 0, 0)
		rootJoint.C1 = CFrame.new(0, 0, 0)
		rootJoint.Parent = root 
		
		-- 5. Connect ALL other parts to Torso
		-- [[ CHANGE 2: Loop through our saved list of parts ]] --
		for _, part in pairs(allParts) do
			if part ~= root and part ~= mainPart then
				-- Create Motor6D
				local motor = Instance.new("Motor6D")
				motor.Name = part.Name 
				motor.Part0 = mainPart -- The Hub (Torso)
				motor.Part1 = part     -- The Spoke (Limb/Detail)
				
				-- Calculate Offset
				motor.C0 = mainPart.CFrame:Inverse() * part.CFrame
				motor.C1 = CFrame.new(0, 0, 0)
				
				motor.Parent = mainPart 
				
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
		
		print("✅ SUCCESS: " .. model.Name .. " is rigged (Deep Search Mode)!")
	else
		warn("❌ Could not find a Main Body part! Is the model empty?")
	end
else
	warn("❌ Please select a Model first!")
end
