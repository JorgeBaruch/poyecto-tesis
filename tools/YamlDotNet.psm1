
# ConvertFrom-Yaml (versión mínima, PowerShell puro, sin dependencias externas)
# Soporta YAML simple (listas, diccionarios, strings, números, booleanos)

# ConvertFrom-Yaml (soporta listas de objetos YAML simples)
function ConvertFrom-Yaml {
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Yaml
    )
    $lines = $Yaml -split "`n"
    $result = @{}
    $currentKey = $null
    $currentList = $null
    $currentObj = $null
    $inObjList = $false
    $indentStack = @()
    $lastIndent = 0
    foreach ($line in $lines) {
        $raw = $line
        $trim = $line.Trim()
        $indent = ($line -replace "[^ ].*$", "").Length
        if ($trim -eq "" -or $trim -like '#*') { continue }
        if ($trim -match '^([\w_\-]+):\s*(.*)$' -and $line -notmatch '^\s+- ') {
            $key = $matches[1]
            $val = $matches[2]
            if ($val -match '^("|")(.*)("|")$') { $val = $val.Trim('"') }
            if ($val -eq "") {
                $currentKey = $key
                $currentList = @()
                $result[$key] = $currentList
                $inObjList = $false
            } else {
                $result[$key] = $val
                $currentKey = $null
                $currentList = $null
                $inObjList = $false
            }
        } elseif ($null -ne $currentKey -and $line -match '^\s+- ') {
            # Nuevo objeto en lista
            $currentObj = @{}
            $objLine = $line.TrimStart() -replace '^- ', ''
            if ($objLine -match '^([\w_\-]+):\s*(.*)$') {
                $objKey = $matches[1]
                $objVal = $matches[2]
                if ($objVal -match '^("|")(.*)("|")$') { $objVal = $objVal.Trim('"') }
                $currentObj[$objKey] = $objVal
            }
            $result[$currentKey] += $currentObj
            $inObjList = $true
            $indentStack = @($currentObj)
            $lastIndent = $indent
        } elseif ($inObjList -and $line -match '^\s{2,}([\w_\-]+):\s*(.*)$') {
            # Campo adicional para el objeto actual (soporte 2+ espacios)
            $objKey = $matches[1]
            $objVal = $matches[2]
            if ($objVal -match '^("|")(.*)("|")$') { $objVal = $objVal.Trim('"') }
            if ($null -ne $currentObj) {
                $currentObj[$objKey] = $objVal
            }
        } elseif ($inObjList -and $indent -gt $lastIndent -and $trim -match '^([\w_\-]+):\s*(.*)$') {
            # Campo adicional indentado para el objeto actual
            $objKey = $matches[1]
            $objVal = $matches[2]
            if ($objVal -match '^("|")(.*)("|")$') { $objVal = $objVal.Trim('"') }
            if ($null -ne $currentObj) {
                $currentObj[$objKey] = $objVal
            }
        } elseif ($null -ne $currentKey -and $trim -match '^- (.+)') {
            # Lista de strings
            $item = $trim.Substring(2).Trim()
            if ($item -match '^("|")(.*)("|")$') { $item = $item.Trim('"') }
            $result[$currentKey] += $item
        }
    }
    return $result
}
