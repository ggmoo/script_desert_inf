
-- Auto Arise Tools vFinal Fix: Clics simulados forzados para botones "Create", "Join" y "Leave"
-- Incluye: Anti-AFK, Auto Desert con retries y clic físico real

local player = game.Players.LocalPlayer
local vim = game:GetService("VirtualInputManager")

local function simulateClick(btn)
    if not btn then return end
    local absPos = btn.AbsolutePosition
    local absSize = btn.AbsoluteSize
    local center = Vector2.new(absPos.X + absSize.X / 2, absPos.Y + absSize.Y / 2)
    vim:SendMouseButtonEvent(center.X, center.Y, 0, true, game, 0)
    task.wait()
    vim:SendMouseButtonEvent(center.X, center.Y, 0, false, game, 0)
end

local function esperarBoton(nombre, timeout)
    timeout = timeout or 10
    local btn = nil
    for _ = 1, timeout * 10 do
        btn = player.PlayerGui:FindFirstChild(nombre, true)
        if btn and btn:IsA("TextButton") and btn.Visible and btn.Parent.Visible then break end
        task.wait(0.1)
    end
    return btn
end

local function forzarClic(nombreBtn)
    local btn = esperarBoton(nombreBtn, 15)
    if btn then
        for i = 1, 5 do
            simulateClick(btn)
            task.wait(0.5)
            if nombreBtn == "Join" and player.PlayerGui:FindFirstChild("WaveLabel") then
                break
            end
        end
    end
end

-- Simplificado para centrar en clics forzados (el resto se integraría igual al flujo anterior)
print("Listo para hacer clic en botones Create, Join y Leave con simulación física reforzada.")
forzarClic("Create")
task.wait(2)
forzarClic("Join")
