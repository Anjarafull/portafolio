<#
    Diagnostico-inZOI.ps1
    Revisa la instalacion de mods de inZOI y reporta que esta mal.
    No modifica nada: solo lee y reporta.

    Uso:
        .\Diagnostico-inZOI.ps1
        .\Diagnostico-inZOI.ps1 -GamePath "D:\Steam\steamapps\common\inZOI"

    Compatible con Windows PowerShell 5.1 y PowerShell 7+.
#>

[CmdletBinding()]
param(
    [string]$GamePath,
    [string]$DocsPath
)

$ErrorActionPreference = 'Continue'
$problemas = New-Object System.Collections.ArrayList
$avisos    = New-Object System.Collections.ArrayList

function Write-Seccion {
    param([string]$Titulo)
    Write-Host ""
    Write-Host ("=" * 62)
    Write-Host "  $Titulo"
    Write-Host ("=" * 62)
}

function Add-Problema { param([string]$t) [void]$problemas.Add($t); Write-Host "  [X] $t" }
function Add-Aviso    { param([string]$t) [void]$avisos.Add($t);    Write-Host "  [!] $t" }
function Add-Ok       { param([string]$t) Write-Host "  [OK] $t" }
function Add-Dato     { param([string]$t) Write-Host "      $t" }

Write-Host ""
Write-Host "DIAGNOSTICO DE MODS - inZOI"
Write-Host ("Fecha: " + (Get-Date -Format 'yyyy-MM-dd HH:mm'))

# ---------------------------------------------------------------
# 1. Localizar el juego
# ---------------------------------------------------------------
Write-Seccion "1. Instalacion del juego"

function Get-SteamLibraries {
    $libs = New-Object System.Collections.ArrayList
    $steamRoots = @(
        "${env:ProgramFiles(x86)}\Steam",
        "$env:ProgramFiles\Steam",
        "C:\Steam"
    )
    foreach ($r in $steamRoots) {
        if ([string]::IsNullOrWhiteSpace($r)) { continue }
        if (Test-Path -LiteralPath $r) {
            [void]$libs.Add($r)
            $vdf = Join-Path (Join-Path $r "steamapps") "libraryfolders.vdf"
            if (Test-Path -LiteralPath $vdf) {
                $txt = Get-Content -LiteralPath $vdf -Raw -ErrorAction SilentlyContinue
                if ($txt) {
                    $m = [regex]::Matches($txt, '"path"\s*"([^"]+)"')
                    foreach ($x in $m) {
                        $p = $x.Groups[1].Value -replace '\\\\', '\'
                        if (Test-Path -LiteralPath $p) { [void]$libs.Add($p) }
                    }
                }
            }
        }
    }
    return ($libs | Select-Object -Unique)
}

if (-not $GamePath) {
    foreach ($lib in (Get-SteamLibraries)) {
        $cand = Join-Path (Join-Path (Join-Path $lib "steamapps") "common") "inZOI"
        if (Test-Path -LiteralPath $cand) { $GamePath = $cand; break }
    }
}

if (-not $GamePath -or -not (Test-Path -LiteralPath $GamePath)) {
    Add-Problema "No encontre la carpeta del juego. Vuelve a correr con: -GamePath ""ruta\a\inZOI"""
    $GamePath = $null
} else {
    Add-Ok "Juego encontrado"
    Add-Dato $GamePath

    $exe = Get-ChildItem -LiteralPath $GamePath -Filter "*.exe" -Recurse -Depth 3 -ErrorAction SilentlyContinue |
           Where-Object { $_.Name -match 'inZOI|BlueClient' } | Select-Object -First 1
    if ($exe) {
        $v = $exe.VersionInfo.FileVersion
        if ([string]::IsNullOrWhiteSpace($v)) { $v = "(sin version en el archivo)" }
        Add-Dato ("Ejecutable: " + $exe.Name + "  version: " + $v)
    }
}

# ---------------------------------------------------------------
# 2. Carpeta de mods
# ---------------------------------------------------------------
Write-Seccion "2. Carpeta ~mods"

$paksDir = $null
$modsDir = $null

if ($GamePath) {
    $paksDir = Join-Path (Join-Path (Join-Path $GamePath "BlueClient") "Content") "Paks"
    if (-not (Test-Path -LiteralPath $paksDir)) {
        Add-Problema "No existe BlueClient\Content\Paks dentro del juego"
        $paksDir = $null
    } else {
        Add-Ok "Carpeta Paks encontrada"
        Add-Dato $paksDir

        $correcta = Join-Path $paksDir "~mods"
        $variantes = @("mods~", "mods", "Mods", "~Mods", "~mod")

        if (Test-Path -LiteralPath $correcta) {
            $modsDir = $correcta
            Add-Ok "Carpeta ~mods existe con el nombre correcto"
        } else {
            $encontrada = $null
            foreach ($v in $variantes) {
                $p = Join-Path $paksDir $v
                if (Test-Path -LiteralPath $p) { $encontrada = $p; break }
            }
            if ($encontrada) {
                $modsDir = $encontrada
                Add-Problema ("La carpeta se llama '" + (Split-Path $encontrada -Leaf) + "' y debe llamarse '~mods'. La tilde va AL INICIO: es lo que fuerza la carga despues de los archivos base. Con otro nombre los mods no sobrescriben nada.")
            } else {
                Add-Problema "No existe ninguna carpeta de mods dentro de Paks. Crea '~mods' ahi."
            }
        }
    }
}

# ---------------------------------------------------------------
# 3. Inventario de mods
# ---------------------------------------------------------------
Write-Seccion "3. Mods instalados"

if ($modsDir) {
    $todos = Get-ChildItem -LiteralPath $modsDir -Recurse -File -ErrorAction SilentlyContinue

    if (-not $todos -or $todos.Count -eq 0) {
        Add-Aviso "La carpeta de mods esta vacia. Si esperabas mods aqui, no estan instalados."
    } else {
        Add-Dato ("Archivos totales: " + $todos.Count)

        # comprimidos sin extraer
        $zips = $todos | Where-Object { $_.Extension -match '^\.(zip|rar|7z)$' }
        if ($zips) {
            Add-Problema ("Hay " + $zips.Count + " archivo(s) comprimido(s) sin extraer. El juego no lee .zip/.rar/.7z: hay que extraer el .pak y dejarlo suelto.")
            foreach ($z in $zips) { Add-Dato ("- " + $z.Name) }
        }

        # vacios
        $vacios = $todos | Where-Object { $_.Length -eq 0 }
        if ($vacios) {
            Add-Problema ("Hay " + $vacios.Count + " archivo(s) de 0 bytes (descarga truncada).")
            foreach ($z in $vacios) { Add-Dato ("- " + $z.Name) }
        }

        # agrupar paks por nombre base
        $paks = $todos | Where-Object { $_.Extension -match '^\.(pak|ucas|utoc)$' }
        if (-not $paks -or $paks.Count -eq 0) {
            Add-Problema "No hay ningun archivo .pak en la carpeta de mods."
        } else {
            $grupos = @{}
            foreach ($f in $paks) {
                $base = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
                if (-not $grupos.ContainsKey($base)) {
                    $grupos[$base] = [PSCustomObject]@{
                        Nombre = $base; Pak = $false; Ucas = $false; Utoc = $false
                        Bytes = 0; Fecha = $f.LastWriteTime; Carpeta = $f.DirectoryName
                    }
                }
                $g = $grupos[$base]
                switch ($f.Extension.ToLower()) {
                    '.pak'  { $g.Pak  = $true }
                    '.ucas' { $g.Ucas = $true }
                    '.utoc' { $g.Utoc = $true }
                }
                $g.Bytes = $g.Bytes + $f.Length
                if ($f.LastWriteTime -gt $g.Fecha) { $g.Fecha = $f.LastWriteTime }
            }

            Write-Host ""
            Add-Dato ("Mods detectados: " + $grupos.Count)
            Write-Host ""

            foreach ($k in ($grupos.Keys | Sort-Object)) {
                $g = $grupos[$k]
                $mb = [math]::Round($g.Bytes / 1MB, 2)
                $piezas = @()
                if ($g.Pak)  { $piezas += "pak" }
                if ($g.Ucas) { $piezas += "ucas" }
                if ($g.Utoc) { $piezas += "utoc" }

                # Un mod IoStore necesita los tres. Solo .pak es formato legacy y es valido.
                $roto = $false
                $motivo = ""
                if (($g.Ucas -or $g.Utoc) -and -not ($g.Pak -and $g.Ucas -and $g.Utoc)) {
                    $roto = $true; $motivo = "faltan piezas del trio pak+ucas+utoc"
                }
                if (-not $g.Pak) { $roto = $true; $motivo = "no tiene archivo .pak" }
                if ($g.Bytes -eq 0) { $roto = $true; $motivo = "pesa 0 bytes (descarga truncada)" }

                $marca = "[OK]"
                if ($roto) { $marca = "[X] " }
                Write-Host ("  $marca " + $g.Nombre + "  (" + ($piezas -join "+") + ")  " + $mb + " MB  " + $g.Fecha.ToString('yyyy-MM-dd'))

                if ($roto) {
                    [void]$problemas.Add("Mod roto: " + $g.Nombre + " -> " + $motivo)
                    Add-Dato ("    -> " + $motivo + "; el mod no carga")
                }

                $enSub = $false
                if ($g.Carpeta -ne $modsDir) { $enSub = $true }
                if ($enSub) {
                    Add-Dato ("    -> esta en subcarpeta: " + (Split-Path $g.Carpeta -Leaf))
                }
            }
        }
    }
} else {
    Add-Aviso "Sin carpeta de mods, no hay inventario que revisar."
}

# ---------------------------------------------------------------
# 4. Documentos y OneDrive
# ---------------------------------------------------------------
Write-Seccion "4. Carpeta de Documentos y OneDrive"

if (-not $DocsPath) {
    try { $DocsPath = [Environment]::GetFolderPath('MyDocuments') } catch { $DocsPath = $null }
}

if (-not $DocsPath -or -not (Test-Path -LiteralPath $DocsPath)) {
    Add-Aviso "No pude ubicar la carpeta Documentos."
} else {
    Add-Dato ("Documentos: " + $DocsPath)

    $enOneDrive = $false
    if ($DocsPath -match 'OneDrive') { $enOneDrive = $true }
    if ($env:OneDrive -and $DocsPath.StartsWith($env:OneDrive, [StringComparison]::OrdinalIgnoreCase)) { $enOneDrive = $true }

    if ($enOneDrive) {
        Add-Problema "Tu carpeta Documentos esta dentro de OneDrive. OneDrive sincroniza y bloquea los archivos de inZOI, y es causa documentada de que los mods no aparezcan. Cierra OneDrive y reinicia el juego para probar."
    } else {
        Add-Ok "Documentos no esta bajo OneDrive"
    }

    $inzoiDocs = Join-Path $DocsPath "inZOI"
    if (Test-Path -LiteralPath $inzoiDocs) {
        Add-Ok "Carpeta Documentos\inZOI existe"

        $printer = Join-Path (Join-Path $inzoiDocs "AIGenerated") "My3DPrinter"
        if (Test-Path -LiteralPath $printer) {
            $items = Get-ChildItem -LiteralPath $printer -Directory -ErrorAction SilentlyContinue
            $n = 0
            if ($items) { $n = $items.Count }
            Add-Dato ("My3DPrinter: " + $n + " objeto(s)")
            if ($n -gt 0) {
                Add-Aviso "Los objetos de My3DPrinter son DECORATIVOS por diseno. Ningun Zoi puede usarlos. Si tu problema es 'no se puede usar el item', y el item salio de aqui, no esta roto: asi funciona."
            }
        }
    } else {
        Add-Aviso "No existe Documentos\inZOI (el juego quiza no se ha ejecutado aun)"
    }
}

# ---------------------------------------------------------------
# Resumen
# ---------------------------------------------------------------
Write-Seccion "RESUMEN"

if ($problemas.Count -eq 0) {
    Write-Host "  No encontre problemas en los archivos."
    Write-Host ""
    Write-Host "  Si aun asi los mods no aparecen en el juego, revisa dentro de inZOI:"
    Write-Host "    - Configuracion: mods y contenido personalizado habilitados"
    Write-Host "    - Menu de mods: reactivalos (cada parche los apaga automaticamente)"
} else {
    Write-Host ("  " + $problemas.Count + " problema(s):")
    Write-Host ""
    $i = 1
    foreach ($p in $problemas) { Write-Host ("  " + $i + ". " + $p); $i++ }
}

if ($avisos.Count -gt 0) {
    Write-Host ""
    Write-Host ("  " + $avisos.Count + " aviso(s):")
    $i = 1
    foreach ($a in $avisos) { Write-Host ("  " + $i + ". " + $a); $i++ }
}

Write-Host ""
Write-Host "Copia todo este reporte y pegalo en el chat."
Write-Host ""
