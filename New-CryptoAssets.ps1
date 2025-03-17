<#
.SYNOPSIS
    Build cryptographic assets required for iPXE
.DESCRIPTION
    Build self-signed CA ( certificate authority ) for iPXE
.NOTES
    Keys applied here come from Microsoft.PowerShell.SecretManagement.
    Your vault must be installed and configured for use.
#>

[CmdletBinding()]
param (
    [paramater(required)]
    [string] $Path,
    [paramater(required)]
    [securestring] $CAPassword,
    [stirng] $CASubject = '/C=US/ST=WA/L=Mercer Island/O=Deployment Live/OU=Dev/CN=DeploymentLive CA',
    [int] $Years = 10
)

#region Initialize 

$ScriptRoot = '.'
if (![string]::IsNullOrEmpty($PSscriptRoot)) { 
    $ScriptRoot = $PSScriptRoot
}

import-module DeploymentLiveModule -force -ErrorAction stop

if ( -not ( test-path $path )) {
    new-item -ItemType Directory -Path $path -ErrorAction SilentlyContinue | out-null
}

#endregion

#region Configure the SSL CA

invoke-openssl -PassOut $CAPassword -Commands @(
    "req","-x509","-newkey","rsa:2048"
    "-out","$Path\ca.crt"
    "-keyout","$Path\ca.key"
    "-days",(365*$Years)
    "-subj",$CASubject
    "-passout", "env:keypass" 
    "-verbose", "-batch"
)

# Output for debugging
Invoke-OpenSSL -commands ( "x509 -in $Path\ca.crt -text" -split ' ' ) | Write-Verbose

# Dell HTTPS will only import files named *.PEM
copy-item $Path\ca.crt $Path\ca.pem

#endregion 
