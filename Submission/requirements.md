This is a compiled list of all requirements set by Microsoft for UEFI 3rd Party SecureBoot Signing. 

All explicit requirements will be marked with a "Footnote" with the Status and any links listed at the bottom.

---
from: https://techcommunity.microsoft.com/blog/hardwaredevcenter/updated-uefi-signing-requirements/1062916
# UEFI Signing Requirements

kevintremblay
Microsoft
Jan 28, 2021

**Update: See Section `New UEFI CA memory mitigation requirements for signing` Below.**

UEFI signing is a service provided by the Windows Hardware Dev Center dashboard by which developers submit UEFI firmware binaries targeted to x86, x86-64, or ARM computers. After these binaries are approved through manual review, the owners can install them on PCs that have secure boot enabled with the Microsoft 3rd Party UEFI CA permitted.

While Microsoft reserves the right to sign or not sign submissions at its discretion, you should adhere to these requirements. Doing so will help you achieve faster turnaround times for getting a submission signed and help avoid revocation. Microsoft may conduct follow-up reviews, including but not limited to questionnaires, package testing, and other security testing of these requirements before signing.

The following list contains the latest requirements for the UEFI signing process. These requirements are to ensure the security promise of secure boot, and to help expedite the turnaround of signing submissions.

 

1. UEFI submissions require an EV certificate and an Azure Active Directory (AAD) account. [^1a][^1b]
2. Only production quality code (for example, “release to manufacturing” code, rather than test or debug modules) that will be released to customers (no internal-only code or tools) are eligible for UEFI signing. For internal-use code, you should add your own key to the Secure Boot database UEFI variable or turn off Secure Boot during development and testing. [^2]
3. Microsoft UEFI CA signs only those products that are for public availability and are needed for inter-operability across all UEFI Secure Boot supported devices. If a product is specific to a particular OEM or organization and is not available externally, you should sign it with your private key and add the certificate to Secure Boot database.[^3]
4. Code submitted for UEFI signing must not be subject to GPLv3 or any license that purports to give someone the right to demand authorization keys to be able to install modified forms of the code on a device. Code that is subject to such a license that has already been signed might have that signature revoked. For example, GRUB 2 is licensed under GPLv3 and will not be signed.[^4]
5. If there’s a known malware vector related to code that uses certain techniques, that code will not be signed and is subject to revocation. For example, the use of versions of GRUB that aren’t Secure Boot enlightened will not be signed.[^5]
6. If there are known security vulnerabilities in your submission code, the submission will not be signed, even if your functionality doesn’t expose that code. For example, the latest known secure versions of OpenSSL are 0.9.8za and 1.0.1h, so if your submission contains earlier versions that contain known vulnerabilities, the submission will not be signed.[^6]
7. You must test your product, following the [Pre-Submission testing document (for UEFI Submissions)](https://techcommunity.microsoft.com/t5/windows-hardware-certification/pre-submission-testing-for-uefi-submissions/ba-p/364829), before submitting for signing.[^7]
8. Microsoft will not sign EFI submissions that use EFI_IMAGE_SUBSYSTEM_EFI_RUNTIME_DRIVER. Instead, we recommend transitioning to EFI_IMAGE_SUBSYSTEM_EFI_BOOT_SERVICE_DRIVER. This prevents unnecessary use of runtime EFI drivers. [^8]
9. Use of EFI Byte Code (EBC): Microsoft will not sign EFI submissions that are EBC-based submissions.[^9]
10. If your submission is a DISK encryption or a File/Volume based encryption, then you MUST make sure that you either don’t encrypt the EFI system partition or if you do encrypt, be sure to decrypt it and make it available by the time Windows is ready to boot.[^10]
11. If your submission is comprised of many different EFI modules, multiple DXE drivers, and multiple boot applications, Microsoft may request that you consolidate your EFI files into a minimal format. An example may be a single boot application per architecture, and a consolidation of DXE drivers into one binary.[^11]
12. If your submission is a SHIM (handing off execution to another bootloader), then you must first submit to the SHIM review board and be approved before a submission will be signed. This review board will check to ensure the following:[^12]
  * Code signing keys must be backed up, stored, and recovered only by personnel in trusted roles, using at least dual-factor authorization in a physically secured environment.
        i. The private key must be protected with a hardware cryptography module. This includes but is not limited to HSMs, smart cards, smart card–like USB tokens, and TPMs.
        ii. The operating environment must achieve a level of security at least equal to FIPS 140-2 Level 2.
        iii. If embedded certificates are EV certificates, you should meet all of the above requirements. We recommend that you use an EV certificate because this will speed up UEFI CA signing turnaround. 
  * Submitter must design and implement a strong revocation mechanism for everything the shim loads, directly and subsequently.
  * If you lose keys or abuse the use of a key, or if a key is leaked, any submission relying on that key will be revoked.
  * Some shims are known to present weaknesses into the SecureBoot system. For a faster signing turnaround, we recommend that you use source code of 0.8 or higher from shim - GitHub branch.
13. If your submission contains iPXE functionality, then additional security steps are required. Previously, Microsoft has completed an in depth security review of 2Pint’s iPXE branch. In order for new submissions with iPXE to be signed, they must complete the following steps: [^13]
  * Pull and merge from 2Pint's commit: http://git.ipxe.org/ipxe.git/commitdiff/7428ab7  [^13a]
  * Get a security review from a verified vendor. Refer vendor to the [iPXE Security Assurance Review blog post](https://techcommunity.microsoft.com/t5/hardware-dev-center/ipxe-security-assurance-review/ba-p/1062943). Emphasis of the review should be on:
        i. NFS functionality being removed [^13b]
        ii. Wireless functionality being removed [^13c]
        iii. Non-UEFI loaders are not included [^13d]
        iv. Ensuring all known reported security problems are fixed (identified in the [iPXE Security Assurance Review blog post](https://techcommunity.microsoft.com/t5/hardware-dev-center/ipxe-security-assurance-review/ba-p/1062943)). [^13e]
  * Share the specific commits that are made to the project, allowing Microsoft to ensure the expected changes are made. [^13f]

For questions about the UEFI Signing process, contact uefisign@microsoft.com

----
From https://techcommunity.microsoft.com/blog/hardwaredevcenter/new-uefi-ca-memory-mitigation-requirements-for-signing/3608714

# New UEFI CA memory mitigation requirements for signing
kevintremblay
Microsoft
Aug 24, 2022

Microsoft, in conjuncture with partners in the PC ecosystem, has developed a set of capabilities and new operating environment conditions for UEFI based systems.  This environment will leverage common, architecturally defined mitigations to improve the device security and boot process.  For software running in this environment there are new requirements that must be adhered to.  For the continuity of our joint customers, it is critical we move the UEFI third-party ecosystem forward together. 

Starting November 30th, 2022 the memory mitigations described below will be required for all applications to be signed by the Microsoft third-party Unified Extensible Firmware Interface (UEFI) Certificate Authority (CA).  

## Requirements

_PE-COFF metadata_
1. Section Alignment of the submitted PE file must be aligned with page size.  This must be 4kb, or a larger power of 2 (ex 64kb) [^14a]
2. Section Flags must not combine IMAGE_SCN_MEM_WRITE and IMAGE_SCN_MEM_EXECUTE for any given section. [^14b]

If-implemented: PE-COFF DLL Attestation 
1. DLL Characteristics must include IMAGE_DLLCHARACTERISTICS_NX_COMPAT [^15]

If a developer is building full support for NX firmware, then they must follow the steps below to fully support and test. Then, since these app characteristics can not be detected statically, setting IMAGE_DLLCHARACTERISTICS_NX_COMPAT attests that the submitted application has successfully implemented and tested the following behavior:[^16]

1. The application must not run self-modifying code; meaning that the code sections of the application may not have the write attribute.  Any attempt to change values within the memory range will cause an execution fault.  [^17]
2. If the application attempts to load any internal code into memory for execution, or if it provides support for an external loader, then it must use the EFI_MEMORY_ATTRIBUTE_PROTOCOL appropriately.  This optional protocol allows the caller to get, set, and clear the read, write, and execute attributes of a well-defined memory range.  [^18]
    1. Loading internal code into memory must maintain WRITE and EXECUTE exclusivity. It must also change the attributes after loading the code to allow execution. [^18a]
    2. External loaders must support the protocol if available on the system. The loader must not assume newly allocated memory allows code execution (even of code types). [^18b]
3. The application must not assume all memory ranges are valid; specifically, page 0 (PA 0 – 4kb). [^19]
4. Stack space cannot be used for code execution [^20]

To assist with quickly testing the metadata requirements and setting the DLL characteristic bit, please use this provided [validation tool](https://github.com/tianocore/edk2-pytool-extensions/blob/master/docs/usability/using_image_validation_tool.md). 

The following links and FAQ are here to support the ecosystem and developers with learning about and implementing these new requirements. Thank you to all for continued collaboration. For any questions around signing, please contact uefisign@microsoft.com.  

## LINKS: 

* New Reqs doc: [UEFI CA Memory Mitigation Requirements for Signing - Windows drivers](https://docs.microsoft.com/en-us/windows-hardware/drivers/bringup/uefi-ca-memory-mitigation-requirements) 
* EFI_MEMORY_ATTRIBUTE_PROTOCOL definition: [3519 – Add Memory Protection proposal - UEFI_MEMORY_ATTRIBUTE protocol (tianocore.org)](https://bugzilla.tianocore.org/show_bug.cgi?id=3519)
* Section Alignment: https://docs.microsoft.com/windows/win32/debug/pe-format#optional-header-windows-specific-fields-image-only 
* Section Flags: https://docs.microsoft.com/windows/win32/debug/pe-format#section-flags 
* DLL Characteristics: https://docs.microsoft.com//windows/win32/debug/pe-format#dll-characteristics 
* Binary test tool documentation: [edk2-pytool-extensions/using_image_validation_tool.md at master · tianocore/edk2-pytool-extensions (github.com)](https://github.com/tianocore/edk2-pytool-extensions/blob/master/docs/usability/using_image_validation_tool.md)
* Binary test tool code: [edk2-pytool-extensions/image_validation.py at master · tianocore/edk2-pytool-extensions (github.com)](https://github.com/tianocore/edk2-pytool-extensions/blob/master/edk2toolext/image_validation.py)
* Open source QEMU based UEFI test environment: [mu_tiano_platforms/building.md at release/202202 · microsoft/mu_tiano_platforms (github.com)](https://github.com/microsoft/mu_tiano_platforms/blob/release/202202/Platforms/QemuQ35Pkg/Docs/Development/building.md)

---
From: https://techcommunity.microsoft.com/t5/windows-hardware-certification/pre-submission-testing-for-uefi-submissions/ba-p/364829

# Pre-submission testing for UEFI submissions

HWCert-Migrated
Mar 12, 2019

## 1 Introduction

This post provides guidance on how to test sign and verify UEFI modules before submitting them for signature by Microsoft UEFI CA. Before using the Windows Dev Center hardware dashboard to sign a UEFI driver or app, you should test sign your UEFI driver or app and verify it, following the guidelines provided here. Doing this helps you determine up front if your UEFI driver or app is signable and whether it works after being signed.

Doing QA on your product before having it signed by Microsoft UEFI CA reduces the likelihood of repeated submissions and so helps the Windows Dev Center hardware dashboard provide good turnaround time for signing, as each submission requires significant review resources from the dashboard.

Note: Don’t submit test signed UEFI modules to the dashboard. Submitted modules that are signed will fail.

## 2 Test sign and verify UEFI modules [^21]

Follow these steps to use and test your UEFI product before getting it signed by Microsoft UEFI CA:

1. Sign your product with your certificate (or a test certificate). [^21a]
2. Add this certificate to the SecureBoot database. [^21b]

## 3 Using Windows HCK to test sign and verify UEFI modules  [^22]

You can use Windows HCK on a device running Windows by following these steps:
  
1. Prepare the test system. [^22a]
2. Test sign the UEFI modules. [^22b]
3. Install the “Lost” test certificate into the secure boot allow database. [^22c]
4. Verify that test signed UEFI modules load and run successfully. [^22d]

### 3.1 Prepare the test system  [^22a]

To install test certificates, including the “Lost CA,” onto a UEFI secure boot system to prepare it to test UEFI modules that are test signed, follow these steps:

1. Procure a UEFI secure boot–capable system for testing. The firmware should comply with UEFI 2.3.1 Errata C or higher.
2. In the BIOS configuration, enable secure boot custom mode and clear all secure boot keys and certificates. Note that some firmware ignores authentication of certain image paths, such as option ROMs. This should be re-enabled if you’re testing these image paths.
3. Uncompress UefiSecureBootManualTests.zip to a USB drive. (This file is attached to this blog post.) If you have the Hardware Certification Kit installed, this file is also located at C:\Program Files (x86)\Windows Kits \8.0\Hardware Certification Kit\Tests\amd64\secureboot\UefiSecureBootManualTests.zip.
4. On the test system, boot to Windows, start Powershell as administrator, and execute Set-ExecutionPolicy Bypass –force .
5. Execute ManualTests\tests\00-EnableSecureBoot\EnableSecureBoot.ps1 and reboot the system. This enables secure boot with a test KEK that will be used later to install the “Lost” test key into database.


### 3.2 Test sign the UEFI modules  [^22b]

Follow the example at ManualTests\generate\TestCerts\Lost\signApps.bat to learn how to sign UEFI modules using the Lost certificate chain:
* You’ll need to set your system clock back to 1/1/2012 to sign using the Lost certificate C:\WINDOWS\system32>date 1-1-12.
* You might need to import the Lost*.cer into your certificate store. To do this, in File Explorer, go to ManualTests\generate\TestCerts\Lost\, right-click each .cer file, and click Install .
* Get signtool.exe, which is available as a part of the Windows SDK .
* Run signtool.exe sign /fd sha256 /a /f “ManualTests\generate\TestCerts\Lost\Lost.pfx” <your_module.efi>.

We recommend that you use a computer running Windows 8 or Windows 8.1 for signing. If the system used is running Windows Vista or a previous Windows operating system, you’ll need to run signtool.exe from the SDK directory where it is installed. On these versions of the operating system, signtool.exe depends on manifests and DLLs in that SDK directory for the /fd option to function properly.

Verify that secure boot is enabled : After you complete the steps in “Prepare the Test System” above, secure boot should be enabled, but the lost key isn’t yet installed into the database. If you try to load the test-signed UEFI driver or app, it should be blocked from execution. Some BIOS systems display a warning message, others fail silently. If execution is blocked, secure boot is correctly enabled for your module load path. If the test-signed UEFI module runs, secure boot is not correctly enabled.

### 3.3 Install the lost test certificate into the secure boot allow database  [^22c]

Open PowerShell as Administrator and run the following command:
`ManualTests\tests\01-AllowNewCertificate\append_LostCA_db.ps1`

This adds the “Lost” test certificate chain to the allow database. You can verify that the system is properly configured by trying to run the UEFI test modules in the HCK (for example, ManualTests\apps\<ARCH>\pressanykey1.efi) via a UEFI shell. It should display the test name and prompt you to press any key on the keyboard.

### 3.4 Verify that test-signed UEFI modules load & execute successfully  [^22d]

After the secure boot system is configured to trust the test certificates and the UEFI modules to be tested are signed by the test certificates, you are ready to begin testing. Install the UEFI modules, reboot, and determine if the modules load and execute successfully. You can test UEFI drivers for hardware either by installing them into your option ROM or via the DRIVER#### UEFI variables.

## 4 Using other tools

Here are a few links that might be helpful:

* Sourceforge - SecurityPkg
* Signing UEFI Applications and Drivers for UEFI Secure Boot

However, you have to clear secure boot in the BIOS, and then you have to either boot to Linux to run Linux tools, or you have to use SHIM with MokManager UI (which allows you to set the databases if the system is in SetupMode).

## 5 Troubleshooting

You can self-sign a UEFI shell by following the steps in section 3.2 above and use it to help troubleshoot problems in your EFI drivers/applications.

1. Go to the Files folder on the EDK II SourceForge project site: http://sourceforge.net/projects/edk2/files/ .
2. Look for and download the newest folder with “Releases” in the folder name.
Example: UDK2014.SP1.P1:  http://sourceforge.net/projects/edk2/files/UDK2014_Releases/UDK2014.SP1.P1/

The precompiled EFI shells are located under EdkShellBinPkg. You can use this to print errors to UEFI shell and debug your applications.

[UEFISecureBootManualTests.zip](https://download.microsoft.com/download/1/a/8/1a813a0e-1eb0-4906-ad29-172967086d33/UefiSecureBootManualTests.zip) (URL updated 3.28.2022)

---
From: https://techcommunity.microsoft.com/blog/hardwaredevcenter/ipxe-security-assurance-review/1062943

# iPXE Security Assurance Review
kevintremblay
Microsoft
Dec 12, 2019

## Review Summary
The  iPXE Anywhere software suite, manufactured by 2Pint, uses the open source network boot loader iPXE. In order for 2Pint to offer Secure Boot as a feature to this product suite, 2Pint had asked Microsoft to sign an image of iPXE. This review covers a code audit of the iPXE source that is to be included as part of the signed image, as well as a partial review of the iPXE Anywhere product suite.

## Security Guarantees
Microsoft agreed to sign the binary with the following security guarantees:

* All reported bugs that are part of this code review must be resolved, and Microsoft must agree with the resolution. All the fixes will be reviewed by Microsoft. [^23]
* If iPXE Anywhere provides a guarantee of EFI signature verification (loadimage, execimage) then they don’t need imgverify / imgtrust. Imgload should only take iPXE scripts and EFI images. [^24]
* The image should only contain needed components for 2Pint to operate. This means the suite should contain a restricted set of drivers loaded as well as use UNDI to handle network drivers. [^25]

## Review Details
iPXE is written in C, using the gcc compiler / gmake. The developer has provided a guarantee that the signed binary will be for amd64 and x86. iPXE is a relatively large codebase with approximately 500k lines of source code. Microsoft discovered that a large amount of this code constitutes network drivers and an 802.11 stack, contributing to a large amount of attack surface. After a series of meetings, the scope was narrowed down, specifically cutting most network drivers (accounting for about half of the codebase) and relying on UNDI (Universal Network Device Interface, a mini driver and network stack build right into some network cards, specifically for PXE). By and large the source code that touches the following components has been audited and will be part of the signed binary:[^26]

* Protocols: Arp, Eapol, Ethernet, Icmp, Ipv4, Ipv6, Ndp, Neighbor, Pccrc, Ping, Rarp, Stp, Tls, Vlan
* TCP: http, https, iscsi
* UDP: dhcp, dhcpv6, dns, slam, tftp
* Images Formats: efi, script
* Crypto: ALL
* Drivers: Usb, Infiniband, UNDI
* HCI: Login, Shell
* Interfaces: Efi, Hyperv, smbios
* Commands: Only commands that these features touch or are in 2pints config

This still left roughly 250k lines of code.

One of the things we noticed early on in the review were enormous fluctuations in code quality on a per-feature basis. We discovered that code written by the main author is of superior quality compared to the rest of the iPXE code written by others (areas such as Wifi Stack and nfs).

The code does not adhere to the Microsoft SDL and banned API list. Specifically, we observed the use of strcpy, memcpy, sprintf, and other such API. We noted that iPXE used no external libraries. All stdlib functions where created by the iPXE developer, using assembly in some cases, and with no dependency on any 3rd-party libc runtime. Crypto code was built from the ground up. It was reviewed for security issues (for example, buffer overflows and integer overflows) but not for cryptographic weaknesses. The latter is because all crypto of significance to Microsoft was done by UEFI Secure Boot mechanism (verify executable code), and not iPXE. iPXE’s use of the EFI boot services stack was exceptionally well documented, and we found the code to be of high quality.

The majority of the network entry points are defined in interface operation structures. For example, the Fibre Channel Over Ethernet uses the following:

![clipboard_image_0.png](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS0xMDYyOTQzLTE2MTQwNWk1NUIyMEE5ODc4NDE2RjE3?image-dimensions=450x450&revision=1)

This approach is true from the lowest layers of the stack all the way up to the highest, including network drivers, ethernet, ipv4/6, udp, tcp, http(s), ssl, BrancheCache, and more. Every structure that was used to store network layer data was packed properly.

iPXE allows for a scriptable interface that can be used on a per case basis. Entry points for the commands are defined as part of the command structure. For example, to register the DCHP command, iPXE  uses the following:

![clipboard_image_1.png](https://techcommunity.microsoft.com/t5/s/gxcuf89792/images/bS0xMDYyOTQzLTE2MTQwNmlDRTZGQ0FDQUU2REU3QzEz?image-dimensions=450x450&revision=1)

The command interface is very well written. Although we found many potential integer overflows, it turned out none of them could be triggered because they were based on string lengths (with 2-4gb strings being impossible).

The following commands were removed from the signed build because of security implications:

* Gdbstub allowed for remote debugging which allowed remote code execution by design
* Imgtrust allowed for images to be loaded that were self-signed by the developer[^27]
* Imgverify allowed for verification to be passed for the above command[^27]

Reviewers thoroughly reviewed both network and command parsers using both source code review and runtime testing. Code patterns with potential security issues that were observed during the review are:
* Integer overflows/underflows
* Out of bounds reads/writes
* Unbounded variable length arrays
* Null dereferences

# Evaluation
The overall observed code quality of the iPXE code base passes our criteria. As noted earlier, we saw a fairly wide difference in quality depending on the author of any particular code, with the main author writing higher quality code. While the SDL and banned API are not applied, most of the code written by the main developer is still of high quality.

Given the open-source nature of iPXE, should a security issues be reported in iPXE in the future, it will likely be a zero-day bug in the signed code. Updating signed blobs may very well lag behind in fixes compared to what’s in the open source code repository.  

For signing the iPXE blob in future iterations, verification needs to be done to make sure that bugs reported in the following sections are fixed if newly included:

* 802.11 stack (mostly RCE)
* Nfs (several read AVs)

# Security Review Guidance
When reviewing the iPXE-based project the security reviewer should focus on:

* Reducing attack surface.[^25]
* Ensuring signatures are verified correctly. [^21]
* That all input received from remote and local sources is properly validated.[^26f]

We observed some areas of the iPXE projects that contain common attack surfaces, and which may not be needed by the project. These include:  `icmp, ndp, neighbour, pccrc, rarp, stp, tls, http/s, ftp, iscsi, syslog, dns, tftp, oncrpc/NFS, infiniband, 802.11 WEP & WPA, file format parsers (efi, elf, png, pnm), ASN.1,` and a large number of HCI commands.

Previously observed security flaws have included incorrect file signature validation, integer over/underflows, out of bound reads, buffer overflows, and other potential memory corruption issues. The reviewer should pay particular attention to commonly vulnerable code sections such as ASN.1, memory allocation lifetime, and cryptographic verification. Any discovered vulnerabilities as a part of your audit should be securely reported to the iPXE maintainers and patched in your submission to the MS Hardware Dev Center.

---
# Footnotes:

[^1a]: EV Certificate </br>
[^1b]: Azure Active Directory Account </br>
