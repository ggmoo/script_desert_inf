
-- Auto Arise GUI: Anti-AFK + Auto Desert Infinite (bucle total)
local player = game.Players.LocalPlayer

-- Estado
local afkActivo = false
local desertActivo = false
local rondaObjetivo = 30
local afkThread = nil
local desertThread = nil

-- GUI
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ScreenGui.Name = "AutoGui"

local frame = Instance.new("Frame", ScreenGui)
frame.Size = UDim2.new(0, 250, 0, 200)
frame.Position = UDim2.new(0, 100, 0, 100)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local titulo = Instance.new("TextLabel", frame)
titulo.Size = UDim2.new(1, 0, 0, 30)
titulo.Text = "Auto Arise Tools"
titulo.TextColor3 = Color3.new(1, 1, 1)
titulo.BackgroundTransparency = 1
titulo.Font = Enum.Font.SourceSansBold
titulo.TextScaled = true

local btnAFK = Instance.new("TextButton", frame)
btnAFK.Position = UDim2.new(0, 10, 0, 40)
btnAFK.Size = UDim2.new(1, -20, 0, 40)
btnAFK.Text = "Anti-AFK: OFF"
btnAFK.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btnAFK.TextColor3 = Color3.new(1, 1, 1)
btnAFK.Font = Enum.Font.SourceSans
btnAFK.TextScaled = true

local rondaBox = Instance.new("TextBox", frame)
rondaBox.Position = UDim2.new(0, 10, 0, 90)
rondaBox.Size = UDim2.new(1, -20, 0, 30)
rondaBox.PlaceholderText = "Ronda objetivo (ej: 30)"
rondaBox.Text = ""
rondaBox.Font = Enum.Font.SourceSans
rondaBox.TextScaled = true
rondaBox.TextColor3 = Color3.new(1,1,1)
rondaBox.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local btnDesert = Instance.new("TextButton", frame)
btnDesert.Position = UDim2.new(0, 10, 0, 130)
btnDesert.Size = UDim2.new(1, -20, 0, 40)
btnDesert.Text = "Auto Desert: OFF"
btnDesert.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
btnDesert.TextColor3 = Color3.new(1, 1, 1)
btnDesert.Font = Enum.Font.SourceSans
btnDesert.TextScaled = true

-- Función para entrar al Desert desde cualquier parte
local function entrarADesert()
    local char = player.Character
    local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    -- Guardar posición original (opcional)
    local posicionOriginal = root.Position

    -- Teleport a zona del menú Desert (confirmada)
    root.CFrame = CFrame.new(Vector3.new(-351.3967, 51.7958, -2686.3682))
    wait(1.5)

    -- Esperar a que el menú aparezca
    local desertUI
    for i = 1, 100 do
        desertUI = player.PlayerGui:FindFirstChild("Infinite Desert")
        if desertUI then break end
        wait(0.1)
    end

    -- Usar UI Navigation Toggle para darle a "Join"
    if desertUI then
        local joinBtn = desertUI:FindFirstChild("Join", true)
        if joinBtn and joinBtn:IsA("GuiButton") then
            pcall(function()
                joinBtn:CaptureFocus()
                wait(0.2)
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                wait(0.1)
                vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            end)
        end
    end
end

-- Función Anti-AFK
local function toggleAFK()
    afkActivo = not afkActivo
    btnAFK.Text = "Anti-AFK: " .. (afkActivo and "ON" or "OFF")
    btnAFK.BackgroundColor3 = afkActivo and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)

    if afkActivo then
        for i,v in pairs(getconnections(player.Idled)) do v:Disable() end
        afkThread = task.spawn(function()
            while afkActivo do
                wait(60)
                pcall(function()
                    player.Character.Humanoid.Jump = true
                end)
            end
        end)
    else
        if afkThread then task.cancel(afkThread) end
    end
end

-- Función Auto Desert Loop
local function toggleDesert()
    desertActivo = not desertActivo
    btnDesert.Text = "Auto Desert: " .. (desertActivo and "ON" or "OFF")
    btnDesert.BackgroundColor3 = desertActivo and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)

    if desertActivo then
        local rondaNum = tonumber(rondaBox.Text)
        if rondaNum and rondaNum > 0 then rondaObjetivo = rondaNum end

        desertThread = task.spawn(function()
            while desertActivo do
                entrarADesert()

                -- Esperar a que entre al modo Desert
                repeat wait(1) until player.PlayerGui:FindFirstChild("WaveLabel") or not desertActivo
                wait(2)

                -- Avanzar unos pasos
                for i = 1, 6 do
                    if not desertActivo then return end
                    wait(0.5)
                    pcall(function()
                        player.Character:MoveTo(player.Character.HumanoidRootPart.Position + Vector3.new(0,0,-5))
                    end)
                end

                -- Esperar hasta alcanzar la ronda objetivo
                while desertActivo do
                    local waveGui = player.PlayerGui:FindFirstChild("WaveLabel")
                    if waveGui and waveGui:IsA("TextLabel") then
                        local num = tonumber(waveGui.Text:match("%d+"))
                        if num and num >= rondaObjetivo then
                            -- Salir usando UI Navigation
                            local leaveBtn = player.PlayerGui:FindFirstChild("Leave")
                            if leaveBtn and leaveBtn:IsA("GuiButton") then
                                pcall(function()
                                    leaveBtn:CaptureFocus()
                                    wait(0.2)
                                    local vim = game:GetService("VirtualInputManager")
                                    vim:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                                    wait(0.1)
                                    vim:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                                end)
                            end
                            break
                        end
                    end
                    wait(5)
                end

                -- Esperar a salir completamente del modo antes de reiniciar
                repeat wait(1) until not player.PlayerGui:FindFirstChild("WaveLabel") or not desertActivo
                wait(5)
            end
        end)
    else
        if desertThread then task.cancel(desertThread) end
    end
end

-- Eventos
btnAFK.MouseButton1Click:Connect(toggleAFK)
btnDesert.MouseButton1Click:Connect(toggleDesert)
