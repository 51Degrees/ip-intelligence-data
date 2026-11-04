using namespace System.IO

[CmdletBinding()]
param(
    [switch]$Force,
    [switch]$Lite,
    [switch]$Asn
)

# The Distributor's free downloads, which need no License Key. The source
# value lets downloads be counted by where they come from.
$BaseUrl = "https://distributor.51degrees.com/api/v2/free/"
$Source = "ip-intelligence-data"

# Known files: download name + local .ipi name
$KnownFiles = @(
    [pscustomobject]@{ Key = "Lite"; Remote = "ipi-lite-v41"; Name = "51Degrees-LiteV41.ipi" }
    [pscustomobject]@{ Key = "Asn";  Remote = "ipi-asn-v41";  Name = "51Degrees-IPIV4AsnIpiV41.ipi" }
)

# Selection: if neither -Lite nor -Asn is passed, do all known files.
# Otherwise only the ones explicitly opted in.
$Selected = @($KnownFiles | Where-Object {
    ($_.Key -eq "Lite" -and $Lite) -or
    ($_.Key -eq "Asn"  -and $Asn)  -or
    $false
})
if (-not $Selected) { $Selected = $KnownFiles }

# Unpacks the gzip data at Start into Out, and returns the length unpacked
# as a gzip member records it, modulo 2^32.
function Copy-Gzip([string]$Path, [long]$Start, $Out) {
    $before = $Out.Position
    $in = [File]::OpenRead($Path)
    try {
        $in.Position = $Start
        $gzip = [Compression.GZipStream]::new($in, [Compression.CompressionMode]::Decompress)
        try { $gzip.CopyTo($Out) } finally { $gzip.Dispose() }
    } finally { $in.Dispose() }
    [uint32](($Out.Position - $before) % 4294967296)
}

# The length the last gzip member records, in the last 4 bytes of the file.
function Get-LastMemberSize([string]$Path) {
    $in = [File]::OpenRead($Path)
    try {
        $tail = New-Object byte[] 4
        $in.Position = $in.Length - 4
        [void]$in.Read($tail, 0, 4)
        [BitConverter]::ToUInt32($tail, 0)
    } finally { $in.Dispose() }
}

# Where the gzip member after one that unpacked to Size bytes starts, found
# as that length followed by the 1f 8b 08 that begins the next member, or
# -1 when there is none.
function Find-NextMember([string]$Path, [long]$From, [uint32]$Size) {
    [byte[]]$pattern = [BitConverter]::GetBytes($Size) + [byte[]](0x1f, 0x8b, 0x08)
    $in = [File]::OpenRead($Path)
    try {
        $buffer = New-Object byte[] (1MB)
        $position = $From
        while ($position -lt $in.Length) {
            $in.Position = $position
            $count = $in.Read($buffer, 0, $buffer.Length)
            if ($count -lt $pattern.Length) { break }
            $i = [Array]::IndexOf($buffer, $pattern[0], 0, $count)
            while ($i -ge 0 -and $i -le $count - $pattern.Length) {
                $match = $true
                for ($j = 1; $j -lt $pattern.Length; $j++) {
                    if ($buffer[$i + $j] -ne $pattern[$j]) { $match = $false; break }
                }
                if ($match) { return $position + $i + 4 }
                $i = [Array]::IndexOf($buffer, $pattern[0], $i + 1, $count - $i - 1)
            }
            $position += $count - ($pattern.Length - 1)
        }
    } finally { $in.Dispose() }
    -1
}

# The Distributor sends each file as more than one gzip member. PowerShell 7
# unpacks them all in one pass, but Windows PowerShell stops at the end of
# the first, so there each member is unpacked in turn.
function Expand-GzipFile {
    param(
        [Parameter(Mandatory)] [string]$ArchiveName,
        [Parameter(Mandatory)] [string]$ArchivedName
    )
    Write-Host "Extracting '$ArchiveName' to '$ArchivedName'..."
    $out = [File]::Create($ArchivedName)
    try {
        if ($PSVersionTable.PSEdition -eq 'Core') {
            $null = Copy-Gzip $ArchiveName 0 $out
            return
        }
        $lastSize = Get-LastMemberSize $ArchiveName
        $start = 0L
        while ($true) {
            $size = Copy-Gzip $ArchiveName $start $out
            if ($size -eq $lastSize) { return }
            # A member is at least 20 bytes, its length in the last 4.
            $start = Find-NextMember $ArchiveName ($start + 16) $size
            if ($start -lt 0) { throw "'$ArchiveName' did not unpack." }
        }
    } finally { $out.Dispose() }
}

foreach ($file in $Selected) {
    $ArchiveUrl = "$BaseUrl$($file.Remote)?source=$Source"
    $ArchivedName = (Join-Path (Get-Location) $file.Name)
    $ArchiveName = "$ArchivedName.gz"

    # Download/skip
    if ($Force -or !(Test-Path -Path $ArchiveName -PathType Leaf)) {
        Invoke-WebRequest -Uri $ArchiveUrl -OutFile $ArchiveName
    } else {
        Write-Debug "Archive found. Download skipped."
    }

    # MD5
    $ArchiveHash = (Get-FileHash -Algorithm MD5 -Path $ArchiveName).Hash
    Write-Output "MD5 (fetched $ArchiveName) = $ArchiveHash"

    # Unpack
    Write-Output "Extracting $ArchiveName"
    Expand-GzipFile -ArchiveName $ArchiveName -ArchivedName $ArchivedName
}
