[CmdletBinding()]
param(
    [int]$v4 = 0,
    [int]$v6 = 0,
    [string]$path = "evidence.yml"
)

# Function to generate a random IPv4 address
function New-IPv4 {
    $octets = @(
        (Get-Random -Minimum 1 -Maximum 255),
        (Get-Random -Minimum 0 -Maximum 255),
        (Get-Random -Minimum 0 -Maximum 255),
        (Get-Random -Minimum 1 -Maximum 255)
    )
    return $octets -join "."
}

# Function to generate a random IPv6 address in hexadecimal format
function New-IPv6 {
    $segments = @()
    for ($i = 0; $i -lt 8; $i++) {
        $segments += "{0:x4}" -f (Get-Random -Minimum 0 -Maximum 65535)
    }
    return $segments -join ":"
}

# Prepare YAML content
$yamlContent = "---`n"
$prefix = "server.client-ip"
for ($i = 0; $i -lt $v4; $i++) {
    $yamlContent += "${prefix}: $(New-IPv4)`n---`n"
}
for ($i = 0; $i -lt $v6; $i++) {
    $yamlContent += "${prefix}: $(New-IPv6)`n---`n"
}

# Write the YAML content to the specified file
Set-Content -Path $path -Value $yamlContent -NoNewline

Write-Host "YAML file created successfully at $path."
