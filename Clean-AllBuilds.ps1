
wsl.exe -- rm -r -f ~/ipxe/src/bin* 

while ( $true ) { try { stop-transcript } catch { break} }
if (![string]::IsNullOrEmpty($PSScriptRoot)) {
    remove-item -Recurse -Force $PSScriptRoot\Build
    remove-item -Recurse -force $PSScriptRoot\config\*\tmp
}
