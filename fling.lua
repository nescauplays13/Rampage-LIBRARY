-- =================================
-- DEV -- > R-77 ; DISCORD - tankuct.
-- =================================

local Targets = {}
local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local AllBool = false

local noclipEnabled = false
local noclipConnection = nil
local originalCanCollide = {}

local antiFallEnabled = false
local antiFallConnection = nil

local GetPlayer = function(Name)
    Name = Name:lower()
    if Name == "all" or Name == "others" then
        AllBool = true
        return
    elseif Name == "random" then
        local GetPlayers = Players:GetPlayers()
        if table.find(GetPlayers,Player) then
            table.remove(GetPlayers,table.find(GetPlayers,Player))
        end
        return GetPlayers[math.random(#GetPlayers)]
    elseif Name ~= "random" and Name ~= "all" and Name ~= "others" then
        for _,x in next, Players:GetPlayers() do
            if x ~= Player then
                if x.Name:lower():match("^"..Name) then
                    return x;
                elseif x.DisplayName:lower():match("^"..Name) then
                    return x;
                end
            end
        end
    else
        return
    end
end

local Message = function(_Title, _Text, Time)
    game:GetService("StarterGui"):SetCore("SendNotification", {Title = _Title, Text = _Text, Duration = Time})
end

local function toggleNoclip()
    noclipEnabled = not noclipEnabled
    
    if noclipEnabled then
        if Player.Character then
            for _, part in pairs(Player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    originalCanCollide[part] = part.CanCollide
                end
            end
        end
        
        noclipConnection = RunService.Stepped:Connect(function()
            if Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") then
                for _, part in pairs(Player.Character:GetChildren()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
        Message("Noclip", "Enabled", 3)
    else
        if noclipConnection then
            noclipConnection:Disconnect()
            noclipConnection = nil
        end
        
        if Player.Character then
            local humanoidRootPart = Player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart then
                local raycast = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -10, 0))
                if not raycast then
                    local downRay = workspace:Raycast(humanoidRootPart.Position, Vector3.new(0, -1000, 0))
                    if downRay then
                        humanoidRootPart.CFrame = CFrame.new(downRay.Position + Vector3.new(0, 5, 0))
                    end
                end
            end
            
            task.wait(0.1)
            
            for _, part in pairs(Player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    local originalValue = originalCanCollide[part]
                    if originalValue ~= nil then
                        part.CanCollide = originalValue
                    else
                        if part.Name == "HumanoidRootPart" then
                            part.CanCollide = false
                        else
                            part.CanCollide = true
                        end
                    end
                end
            end
            
            local humanoid = Player.Character:FindFirstChild("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
                task.wait(0.1)
                humanoid:ChangeState(Enum.HumanoidStateType.Running)
            end
        end
        
        originalCanCollide = {}
        Message("Noclip", "Disabled", 3)
    end
end

local function toggleAntiFallDamage()
    antiFallEnabled = not antiFallEnabled
    
    if antiFallEnabled then
        local pid = game.PlaceId
        if pid ~= 189707 then
            Message("Error", "Not Natural Disasters Survival!", 5)
            antiFallEnabled = false
            return
        end
        
        local rs = game:GetService("RunService")
        local hb = rs.Heartbeat
        local rsd = rs.RenderStepped
        local lp = game.Players.LocalPlayer
        local z = Vector3.zero
        
        local function f(c)
            local r = c:WaitForChild("HumanoidRootPart")
            if r then
                local con
                con = hb:Connect(function()
                    if not antiFallEnabled or not r.Parent then
                        con:Disconnect()
                        return
                    end
                    local v = r.AssemblyLinearVelocity
                    r.AssemblyLinearVelocity = z
                    rsd:Wait()
                    r.AssemblyLinearVelocity = v
                end)
                antiFallConnection = con
            end
        end
        
        f(lp.Character)
        lp.CharacterAdded:Connect(function(char)
            if antiFallEnabled then
                f(char)
            end
        end)
        
        Message("AntiFallDamage", "Enabled (NDS)", 3)
    else
        if antiFallConnection then
            antiFallConnection:Disconnect()
            antiFallConnection = nil
        end
        Message("AntiFallDamage", "Disabled", 3)
    end
end

local SkidFling = function(TargetPlayer)
    local Character = Player.Character
    local Humanoid = Character and Character:FindFirstChildOfClass("Humanoid")
    local RootPart = Humanoid and Humanoid.RootPart
    local TCharacter = TargetPlayer.Character
    local THumanoid
    local TRootPart
    local THead
    local Accessory
    local Handle

    if TCharacter:FindFirstChildOfClass("Humanoid") then
        THumanoid = TCharacter:FindFirstChildOfClass("Humanoid")
    end
    if THumanoid and THumanoid.RootPart then
        TRootPart = THumanoid.RootPart
    end
    if TCharacter:FindFirstChild("Head") then
        THead = TCharacter.Head
    end
    if TCharacter:FindFirstChildOfClass("Accessory") then
        Accessory = TCharacter:FindFirstChildOfClass("Accessory")
    end
    if Accessory and Accessory:FindFirstChild("Handle") then
        Handle = Accessory.Handle
    end

    if Character and Humanoid and RootPart then
        if RootPart.Velocity.Magnitude < 50 then
            getgenv().OldPos = RootPart.CFrame
        end
        if THumanoid and THumanoid.Sit and not AllBool then
            return Message("Error Occurred", "Targeting is sitting", 5)
        end

        if THead then
            workspace.CurrentCamera.CameraSubject = THead
        elseif not THead and Handle then
            workspace.CurrentCamera.CameraSubject = Handle
        elseif THumanoid and TRootPart then
            workspace.CurrentCamera.CameraSubject = THumanoid
        end

        if not TCharacter:FindFirstChildWhichIsA("BasePart") then
            return
        end

        local FPos = function(BasePart, Pos, Ang)
            RootPart.CFrame = CFrame.new(BasePart.Position) * Pos * Ang
            Character:SetPrimaryPartCFrame(CFrame.new(BasePart.Position) * Pos * Ang)
            RootPart.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            RootPart.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end

        local SFBasePart = function(BasePart)
            local TimeToWait = 2
            local Time = tick()
            local Angle = 0
            repeat
                if RootPart and THumanoid then
                    if BasePart.Velocity.Magnitude < 50 then
                        Angle = Angle + 100
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle),0 ,0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(2.25, 1.5, -2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(-2.25, -1.5, 2.25) + THumanoid.MoveDirection * BasePart.Velocity.Magnitude / 1.25, CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0) + THumanoid.MoveDirection,CFrame.Angles(math.rad(Angle), 0, 0))
                        task.wait()
                    else
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -THumanoid.WalkSpeed), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, THumanoid.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, -TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, 1.5, TRootPart.Velocity.Magnitude / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5 ,0), CFrame.Angles(math.rad(-90), 0, 0))
                        task.wait()
                        FPos(BasePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                        task.wait()
                    end
                else
                    break
                end
            until BasePart.Velocity.Magnitude > 500 or BasePart.Parent ~= TargetPlayer.Character or TargetPlayer.Parent ~= Players or not TargetPlayer.Character == TCharacter or THumanoid.Sit or Humanoid.Health <= 0 or tick() > Time + TimeToWait
        end

        workspace.FallenPartsDestroyHeight = 0/0
        local BV = Instance.new("BodyVelocity")
        BV.Name = "EpixVel"
        BV.Parent = RootPart
        BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
        BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, false)

        if TRootPart and THead then
            if (TRootPart.CFrame.p - THead.CFrame.p).Magnitude > 5 then
                SFBasePart(THead)
            else
                SFBasePart(TRootPart)
            end
        elseif TRootPart and not THead then
            SFBasePart(TRootPart)
        elseif not TRootPart and THead then
            SFBasePart(THead)
        elseif not TRootPart and not THead and Accessory and Handle then
            SFBasePart(Handle)
        else
            return Message("Error Occurred", "Target is missing everything", 5)
        end

        BV:Destroy()
        Humanoid:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = Humanoid

        repeat
            RootPart.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
            Character:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
            Humanoid:ChangeState("GettingUp")
            table.foreach(Character:GetChildren(), function(_, x)
                if x:IsA("BasePart") then
                    x.Velocity, x.RotVelocity = Vector3.new(), Vector3.new()
                end
            end)
            task.wait()
        until (RootPart.Position - getgenv().OldPos.p).Magnitude < 25
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
    else
        return Message("Error Occurred", "Random error", 5)
    end
end

-- UI (CLEAN MINIMAL)
do
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "FlingControlUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game:GetService("CoreGui") or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 290, 0, 170)
    frame.Position = UDim2.new(0.72, 0, 0.22, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20,20,20)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(45,45,45)
    stroke.Thickness = 1

    -- TITLE
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -10, 0, 24)
    title.Position = UDim2.new(0, 8, 0, 6)
    title.BackgroundTransparency = 1
    title.Text = "Fling Controller"
    title.Font = Enum.Font.GothamMedium
    title.TextSize = 13
    title.TextColor3 = Color3.fromRGB(220,220,220)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = frame

    -- CLOSE
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "Close"
    closeBtn.Size = UDim2.new(0, 20, 0, 20)
    closeBtn.Position = UDim2.new(1, -24, 0, 6)
    closeBtn.Text = "X"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 12
    closeBtn.BackgroundTransparency = 1
    closeBtn.TextColor3 = Color3.fromRGB(170,170,170)
    closeBtn.Parent = frame

    -- INPUT
    local input = Instance.new("TextBox")
    input.Name = "TargetBox"
    input.Size = UDim2.new(1, -12, 0, 28)
    input.Position = UDim2.new(0, 6, 0, 34)
    input.PlaceholderText = "target name"
    input.BackgroundColor3 = Color3.fromRGB(28,28,28)
    input.TextColor3 = Color3.fromRGB(220,220,220)
    input.Font = Enum.Font.Gotham
    input.TextSize = 13
    input.ClearTextOnFocus = false
    input.Parent = frame
    Instance.new("UICorner", input).CornerRadius = UDim.new(0,4)

    -- STYLE BUTTON
    local function style(btn)
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 13
        btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        btn.TextColor3 = Color3.fromRGB(210,210,210)
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,4)

        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(38,38,38)
        end)
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = Color3.fromRGB(30,30,30)
        end)
    end

    -- BUTTONS
    local attackBtn = Instance.new("TextButton")
    attackBtn.Name = "Attack"
    attackBtn.Size = UDim2.new(0.48, -4, 0, 30)
    attackBtn.Position = UDim2.new(0, 6, 0, 70)
    attackBtn.Text = "Attack"
    attackBtn.Parent = frame
    style(attackBtn)

    local allBtn = Instance.new("TextButton")
    allBtn.Name = "AllToggle"
    allBtn.Size = UDim2.new(0.48, -4, 0, 30)
    allBtn.Position = UDim2.new(0.52, 0, 0, 70)
    allBtn.Text = "Attack All: OFF"
    allBtn.Parent = frame
    style(allBtn)

    local noclipBtn = Instance.new("TextButton")
    noclipBtn.Name = "NoclipToggle"
    noclipBtn.Size = UDim2.new(0.48, -4, 0, 30)
    noclipBtn.Position = UDim2.new(0, 6, 0, 105)
    noclipBtn.Text = "Noclip: OFF"
    noclipBtn.Parent = frame
    style(noclipBtn)

    local antiFallBtn = Instance.new("TextButton")
    antiFallBtn.Name = "AntiFallToggle"
    antiFallBtn.Size = UDim2.new(0.48, -4, 0, 30)
    antiFallBtn.Position = UDim2.new(0.52, 0, 0, 105)
    antiFallBtn.Text = "AntiFallDamage: OFF"
    antiFallBtn.Parent = frame
    style(antiFallBtn)

    -- DRAG (original)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(inputPos)
        local delta = inputPos - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = inputObj.Position
            startPos = frame.Position

            inputObj.Changed:Connect(function()
                if inputObj.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(inputObj)
        if inputObj.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = inputObj
        end
    end)

    UserInputService.InputChanged:Connect(function(inputObj)
        if inputObj == dragInput and dragging then
            update(inputObj.Position)
        end
    end)

    -- EVENTOS (INALTERADOS)
    local allState = false

    allBtn.MouseButton1Click:Connect(function()
        allState = not allState
        allBtn.Text = allState and "Attack All: ON" or "Attack All: OFF"
    end)

    noclipBtn.MouseButton1Click:Connect(function()
        toggleNoclip()
        noclipBtn.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF"
    end)

    antiFallBtn.MouseButton1Click:Connect(function()
        toggleAntiFallDamage()
        antiFallBtn.Text = antiFallEnabled and "AntiFallDamage (NDS): ON" or "AntiFallDamage (NDS): OFF"
    end)

    closeBtn.MouseButton1Click:Connect(function()
        if noclipEnabled then
            toggleNoclip()
        end
        if antiFallEnabled then
            toggleAntiFallDamage()
        end
        screenGui:Destroy()
    end)

    attackBtn.MouseButton1Click:Connect(function()
        local name = tostring(input.Text or "")
        if name == "" then
            return Message("Error", "Enter a target name", 4)
        end

        Targets = {name}
        AllBool = false

        if allState or name:lower() == "all" or name:lower() == "others" then
            AllBool = true
        end

        if AllBool then
            for _, pl in next, Players:GetPlayers() do
                if pl ~= Player then
                    pcall(function()
                        SkidFling(pl)
                    end)
                end
            end
            return
        end

        local target = GetPlayer(name)
        if target and target ~= Player then
            if target.UserId ~= 1414978355 then
                pcall(function()
                    SkidFling(target)
                end)
            else
                Message("Error Occurred", "This user is whitelisted! (Owner)", 5)
            end
        else
            Message("Error Occurred", "Username Invalid", 5)
        end
    end)
end
