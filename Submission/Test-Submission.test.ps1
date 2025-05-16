<#
.SYNOPSIS
    iPXE Pester tests for SecureBoot signing
.DESCRIPTION
    A longer description of the function, its purpose, common use cases, etc.
.NOTES
    Information or caveats about the function e.g. 'This function is not supported in Linux'
.LINK
    https://techcommunity.microsoft.com/blog/hardwaredevcenter/updated-uefi-signing-requirements/1062916
    https://techcommunity.microsoft.com/blog/hardwaredevcenter/new-uefi-ca-memory-mitigation-requirements-for-signing/3608714
    https://techcommunity.microsoft.com/blog/hardwaredevcenter/ipxe-security-assurance-review/1062943
    https://techcommunity.microsoft.com/t5/windows-hardware-certification/pre-submission-testing-for-uefi-submissions/ba-p/364829
    https://www.tianocore.org/edk2-pytool-extensions/tools/using_image_validation_tool/
#>

[cmdletbinding()]
param(
    # [parameter(mandatory)]
    [string] $path = "$PSScriptRoot\..\Build\signed\snp_ca_x64.efi",
    [string] $WSLPathToiPXE = '~/ipxe'
)

#region Common routines

$Binary = get-content -Raw -path $Path
$VersionMatch = $binary | select-string -Pattern '[1-9]\.[0-9]{1,5}\.[0-9]{1,5}\+? \(g([0-9a-z]{4,5})\)' | % Matches

<#
Install python for testing ( un-elevated )
    choco install -y python
    pip install --upgrade edk2-pytool-extensions
#>

# See: https://www.tianocore.org/edk2-pytool-extensions/tools/using_image_validation_tool/
$ImageValidation = "~\AppData\Roaming\Python\Python313\site-packages\edk2toolext\image_validation.py" | get-item | % FullName

#endregion 

Describe "0. Control Tests" {

    it "0.1. Test iPXE file must exist" {
        $Path | should exist
    }

    it "0.2. Must be a Mark Zimbrowski" {
        $binary[0] | Should be 'M'
        $binary[1] | Should be 'Z'
    }

    it "0.3. Version" {
        write-verbose " Build: [$($VersionMatch.Value)]"
        $VersionMatch.Value | should NOT BeNullOrEmpty
    }
    it "0.4. Commit" {
        write-verbose " Build: [$($VersionMatch.groups[1].value)]"
        $VersionMatch.groups[1].value | should NOT BeNullOrEmpty
    }

    it "0.5 EDK Image Validation Test" {
        $ImageValidation | should exist 
    }

}

Describe "8. No EFI_RUNTIME_DRIVER" {

    it "8.a.1. Must be type Application" {
        # image_validation.py from EDK validates Application Types
        (py.exe $ImageValidation -i $Path -p APP) 2>&1 | should be "INFO - Overall Result: [PASS]"
    }

    it "8.a.2. Must Not be a Driver" {
        # image_validation.py from EDK validates Application Types
        (py.exe $ImageValidation -i $Path -p DRIVER) 2>&1 | should NOT be "INFO - Overall Result: [PASS]"
    }

 }

Describe "9. No EFI byte Code" {

    it "9.a. no EFI Byte Code" {
        # https://vzimmer.blogspot.com/2015/08/efi-byte-code.html
        # EFI Byte Code binaries report as IMAGE_SUBSYSTEM_EFI_BOOT_ SERVICE_DRIVER, so would NOT pass image_validation.py
        (py.exe $ImageValidation -i $Path -p DRIVER) 2>&1 | should NOT be "INFO - Overall Result: [PASS]"
    }

}

Describe "13 - Basic tests for iPXE" {

    it "13.0 HTTPS can be present" {
        # Control Case check for HTTPS string from feature table.
        $binary | select-string -Pattern '\bHTTPS\b' | should NOT BeNullOrEmpty
    }

    it "13.a. Must be After Commit 7428ab7" {
        # git log --format=format:'%h,%cs,%s'   Hash,Date,Description
        $requiredCommit = wsl --cd $WSLPathToiPXE -- git log 7428ab7 --format=format:'%cs' | select-object -first 1
        $VersionCommit = wsl --cd $WSLPathToiPXE -- git log $($VersionMatch.groups[1].value) --format=format:'%cs' | select-object -first 1

        write-verbose "Required: $requiredCommit     Version: $VersionCommit"
        [datetime]$VersionCommit | should BeGreaterThan ([datetime]$RequiredCommit)
        [datetime]$VersionCommit | should BeLessThan ([datetime]::now)
    }

    it "13.b. NFS must not be present" {
        # The string "NFS" would be present in builds with NFS for Feature Table.
        $binary | select-string -Pattern '\bNFS\b' | should BeNullOrEmpty
    }

    it "13.c. Wireless Functionality must not be present" {
        # The string "iwlist" would be present in builds with Wi-Fi
        $binary | select-string -Pattern '\biwlist\b' | should BeNullOrEmpty
    }

}

Describe "14. PE-COFF Metadata" {

    it "14.1. Binary must be aligned to 4kb pages" {
        # image_validation.py from EDK validates 4k Page Size
        (py.exe $ImageValidation -i $Path -p APP) 2>&1 | should be "INFO - Overall Result: [PASS]"
    }

    it "14.2. Binary must not combine Write and Execute" {
        # image_validation.py from EDK validates write / execute separation
        (py.exe $ImageValidation -i $Path -p APP) 2>&1 | should be "INFO - Overall Result: [PASS]"
    }

}

Describe "16. NX Compat" {

    it "16.a. Binary must have NX Compat bit set" {
        # image_validation.py from EDK validates NX Compat
        (py.exe $ImageValidation -i $Path -p APP --get-nx-compat ) 2>&1 | should be "INFO - True"
    }

}

Describe "21. Test Signed" {

    it "21.a.1 Sign with your test CERTIFICATE." {
        Get-AuthenticodeSignature $Path | % SignatureType | should be "Authenticode"
    }
    it "21.a.2 Sign with your TEST certificate." {
        Get-AuthenticodeSignature $Path  | % SIgnerCertificate |  % Issuer | Should belike '*test*'
    }
    it "21.a.2 Sign with YOUR test certificate." {
        Get-AuthenticodeSignature $Path  | % SIgnerCertificate |  % Issuer | Should belike '*DeploymentLive*'
    }

}

Describe "27. imgtrust not trusted" {

    it "27.a. verify imgtrust not present" {
        $binary | select-string -Pattern '\bimgtrust\b' -ErrorAction SilentlyContinue | should BeNullOrEmpty        
    }
    it "27.b. verify imgverify not present" {
        $binary | select-string -Pattern '\bimgverify\b' -ErrorAction SilentlyContinue | should BeNullOrEmpty        
    }

}

Describe "28. gdbstub not trusted" {

    it "27.a. verify gdbstub not present" {
        $binary | select-string -Pattern '\bgdbstub\b' | should BeNullOrEmpty        
    }

}
