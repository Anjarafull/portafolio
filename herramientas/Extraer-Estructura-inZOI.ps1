<#
    Extraer-Estructura-inZOI.ps1

    Lee los mods instalados en ~mods y extrae la ESTRUCTURA de cada uno:
    que rutas de assets del juego sobrescribe. Con eso se sabe exactamente
    sobre que esta montado cada mod.

    No modifica nada. Solo lee y escribe un reporte.

    Uso:
        .\Extraer-Estructura-inZOI.ps1
        .\Extraer-Estructura-inZOI.ps1 -GamePath "D:\Steam\steamapps\common\inZOI"

    Deja el resultado en:  estructura-mods-inzoi.txt  (junto al script)
    Ese archivo es el que hay que mandar al chat.

    Compatible con Windows PowerShell 5.1 y PowerShell 7+.
#>

[CmdletBinding()]
param(
    [string]$GamePath,
    [string]$Salida,
    [int]$MaxRutasPorMod = 400
)

$ErrorActionPreference = 'Continue'
if (-not $Salida) { $Salida = Join-Path (Get-Location) "estructura-mods-inzoi.txt" }

$lineas = New-Object System.Collections.ArrayList
function Emit { param([string]$t = "") [void]$lineas.Add($t); Write-Host $t }

Emit "ESTRUCTURA DE MODS - inZOI"
Emit ("Generado: " + (Get-Date -Format 'yyyy-MM-dd HH:mm'))
Emit ("=" * 66)

# ---------------- localizar juego ----------------
function Get-SteamLibraries {
    $libs = New-Object System.Collections.ArrayList
    foreach ($r in @("${env:ProgramFiles(x86)}\Steam", "$env:ProgramFiles\Steam", "C:\Steam")) {
        if ([string]::IsNullOrWhiteSpace($r)) { continue }
        if (Test-Path -LiteralPath $r) {
            [void]$libs.Add($r)
            $vdf = Join-Path (Join-Path $r "steamapps") "libraryfolders.vdf"
            if (Test-Path -LiteralPath $vdf) {
                $txt = Get-Content -LiteralPath $vdf -Raw -ErrorAction SilentlyContinue
                if ($txt) {
                    foreach ($x in [regex]::Matches($txt, '"path"\s*"([^"]+)"')) {
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
    Emit "ERROR: no encontre el juego. Corre de nuevo con: -GamePath ""ruta\a\inZOI"""
    $lineas | Set-Content -LiteralPath $Salida -Encoding UTF8
    return
}
Emit ("Juego: " + $GamePath)

$paks = Join-Path (Join-Path (Join-Path $GamePath "BlueClient") "Content") "Paks"
$modsDir = $null
foreach ($n in @("~mods","mods~","mods","Mods")) {
    $p = Join-Path $paks $n
    if (Test-Path -LiteralPath $p) { $modsDir = $p; break }
}
if (-not $modsDir) {
    Emit "ERROR: no hay carpeta de mods dentro de Paks."
    $lineas | Set-Content -LiteralPath $Salida -Encoding UTF8
    return
}
Emit ("Carpeta de mods: " + $modsDir)
Emit ""

# ---------------- extractor de rutas ----------------
# Lee el binario por bloques y saca cadenas ASCII y UTF-16LE que parezcan
# rutas de assets de Unreal (/Game/..., /Content/..., BlueClient/...).
function Get-RutasDeAssets {
    param([string]$Archivo)

    $encontradas = New-Object 'System.Collections.Generic.HashSet[string]'
    $patron = '(?:/Game|/Content|/Engine|/BlueClient)/[A-Za-z0-9_\-/\.]{3,180}'

    # Los bytes vecinos pueden pegarse al final del match y producir rutas
    # falsas (".uasset4"). Si hay una extension conocida, cortar justo ahi.
    $exts = @('.uasset','.umap','.uexp','.ubulk','.uptnl','.ufont','.ini')
    function Limpiar([string]$ruta) {
        foreach ($e in $exts) {
            $i = $ruta.LastIndexOf($e, [StringComparison]::OrdinalIgnoreCase)
            if ($i -ge 0) { return $ruta.Substring(0, $i + $e.Length) }
        }
        return $ruta.TrimEnd('.', '/', '-', '_')
    }
    $bloque = 4MB
    $solape = 512

    try {
        $fs = [System.IO.File]::Open($Archivo, 'Open', 'Read', 'ReadWrite')
    } catch {
        return @("(no se pudo abrir: " + $_.Exception.Message + ")")
    }

    try {
        $buf = New-Object byte[] ($bloque + $solape)
        $pos = 0
        while ($pos -lt $fs.Length) {
            $fs.Position = $pos
            $leidos = $fs.Read($buf, 0, $buf.Length)
            if ($leidos -le 0) { break }

            # ASCII (1 byte por caracter)
            $ascii = [System.Text.Encoding]::ASCII.GetString($buf, 0, $leidos)
            foreach ($m in [regex]::Matches($ascii, $patron)) { [void]$encontradas.Add((Limpiar $m.Value)) }

            # UTF-16LE (Unreal guarda muchas cadenas asi)
            $par = $leidos - ($leidos % 2)
            if ($par -gt 0) {
                $wide = [System.Text.Encoding]::Unicode.GetString($buf, 0, $par)
                foreach ($m in [regex]::Matches($wide, $patron)) { [void]$encontradas.Add((Limpiar $m.Value)) }
            }

            $pos = $pos + $bloque
        }
    } finally {
        $fs.Close()
    }

    return ($encontradas | Sort-Object)
}

# ---------------- recorrer mods ----------------
$archivos = Get-ChildItem -LiteralPath $modsDir -Recurse -File -ErrorAction SilentlyContinue |
            Where-Object { $_.Extension -match '^\.(pak|ucas|utoc)$' }

if (-not $archivos -or $archivos.Count -eq 0) {
    Emit "No hay archivos .pak/.ucas/.utoc en la carpeta de mods."
    $lineas | Set-Content -LiteralPath $Salida -Encoding UTF8
    return
}

$porMod = @{}
foreach ($f in $archivos) {
    $base = [System.IO.Path]::GetFileNameWithoutExtension($f.Name)
    if (-not $porMod.ContainsKey($base)) { $porMod[$base] = New-Object System.Collections.ArrayList }
    [void]$porMod[$base].Add($f)
}

Emit ("Mods encontrados: " + $porMod.Count)
Emit ""

foreach ($nombre in ($porMod.Keys | Sort-Object)) {
    $grupo = $porMod[$nombre]
    $bytes = ($grupo | Measure-Object -Property Length -Sum).Sum
    $exts  = ($grupo | ForEach-Object { $_.Extension.TrimStart('.') } | Sort-Object -Unique) -join "+"
    $fecha = ($grupo | Sort-Object LastWriteTime -Descending | Select-Object -First 1).LastWriteTime

    Emit ("-" * 66)
    Emit ("MOD: " + $nombre)
    Emit ("  piezas : " + $exts)
    Emit ("  tamano : " + [math]::Round($bytes / 1MB, 2) + " MB")
    Emit ("  fecha  : " + $fecha.ToString('yyyy-MM-dd HH:mm'))

    $todas = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($f in $grupo) {
        foreach ($r in (Get-RutasDeAssets -Archivo $f.FullName)) { [void]$todas.Add($r) }
    }

    if ($todas.Count -eq 0) {
        Emit "  rutas  : (ninguna legible; probablemente comprimido o cifrado)"
        Emit ""
        continue
    }

    Emit ("  rutas  : " + $todas.Count + " referencias de assets")

    # Agrupar por carpeta raiz para ver sobre que sistema del juego monta
    $grupos = @{}
    foreach ($r in $todas) {
        $partes = $r.Trim('/').Split('/')
        $raiz = $partes[0]
        if ($partes.Length -ge 3) { $raiz = ($partes[0..2] -join '/') }
        elseif ($partes.Length -ge 2) { $raiz = ($partes[0..1] -join '/') }
        if (-not $grupos.ContainsKey($raiz)) { $grupos[$raiz] = 0 }
        $grupos[$raiz] = $grupos[$raiz] + 1
    }

    Emit "  sobrescribe:"
    foreach ($k in ($grupos.Keys | Sort-Object { -$grupos[$_] })) {
        Emit ("    " + $grupos[$k].ToString().PadLeft(5) + "  /" + $k)
    }

    Emit "  muestra de rutas:"
    $n = 0
    foreach ($r in $todas) {
        Emit ("    " + $r)
        $n++
        if ($n -ge $MaxRutasPorMod) { Emit ("    ... (" + ($todas.Count - $n) + " mas)"); break }
    }
    Emit ""
}

Emit ("=" * 66)
Emit "FIN"

$lineas | Set-Content -LiteralPath $Salida -Encoding UTF8
Write-Host ""
Write-Host ("Reporte guardado en: " + $Salida)
Write-Host "Manda ESE archivo al chat."
