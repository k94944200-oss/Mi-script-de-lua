-- [[ CONFIGURACIÓN DE USUARIO ]]
getgenv().Mode = "OneClick"
getgenv().Setting = {
    ["Team"] = "Pirates", -- Opciones: "Pirates" o "Marines"
    ["FucusOnLevel"] = true,
    ["Fruits"] = { 
        ["Primary"] = { 
            "Dough-Dough",
            "Dragon-Dragon",
            "Buddha-Buddha",
        },
        ["Normal"] = { 
            "Flame-Flame",
            "Light-Light",
            "Magma-Magma",
        }
    },
    ["IdleCheck"] = 150, -- Segundos antes de reincorporarse por inactividad
}

-- [[ EJECUCIÓN DEL SCRIPT PRINCIPAL ]]
-- Compatible con Hydrogen, Delta, Fluxus y Wave.
-- Nota: Se utiliza el cargador oficial de Quartyz para asegurar actualizaciones.

task.spawn(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com"))()
end)
