# Submission Notes for iPXE by Deployment Live.

## Background

iPXE is an open source Network Boot Loader by https://ipxe.org. It is a powerful alternative to regular PXE booting.

Regular PXE booting relies on the TFTP protocol to download files from a network server. TFTP is old and slow. 
iPXE uses the more modern HTTPS protocol, which is much faster and more secure, making true Internet/Cloud booting possible.

Unfortunately, iPXE is not SecureBoot signed by Microsoft by default, making it impractical for booting on most modern Windows Machines with SecureBoot turned ON.

### 2Pint Software

2Pint software has gone through the process of signing their version of the iPXE binaries.
So technically it is possible for Microsoft to sign an iPXE binary.

### iPXE Org

The iPXE.org (through Mr Michael Brown) has submitted an iPXE SHIM with Microsoft, so they can have the SHIM signed Once, and then use the SHIM key to sign regular builds of iPXE produced by them.

* https://github.com/ipxe/shim
* https://github.com/ipxe/shim-review

The challenge here is that Microsoft is somewhat reluctant to sign just *any* new SHIM. They have been bitten in the past by some Linux SHIM's, and are doing some extra due diligence with the iPXE shim.

### Deployment Live iPXE

My publicly stated goal is to produce two sets of binaries:

A Signed iPXE binary to release out publicly to the community for free (as in beer)
* The free binary will support HTTP, and HTTPS with the Deployment Live CA Cert only.
* The free binary will NOT have any peer to peer cache support.

A Signed iPXE binary for private (paid?) release:
* The paid version will support HTTPS with full iPXE.ca cert support.
* The paid version will have Branch Cache Peer to Peer support. 

Both x64 and arm64 builds

Both SNP and SNP+USB driver builds

## Reviewers notes

On May 7th 2025 I submitted 8 binaries to Microsoft for Secure Boot signing.

Microsoft has pushed back, asking for an audit (I was expecting this). Their e-mail so far stated:

```
PXE submissions require:

1. Results of a professional security audit.
2. Wireless functionality to be completely removed.
3. NFS functionality to be completely removed.
4. Non-UEFI loaders are not included.
```

In turn I have asked for clarification from Microsoft about point number 1:
```
To be clear, you are asking me to have a security audit performed against my changes to iPXE, 
to ensure that I have not added any new (read unsecure) functionality to the original iPXE project?
```

As of 5/15/2025, I have not recieved a Response.

### As for the points above:

1. Results of a professional security audit. 
   - Status: In progress
2. Wireless Functionality to be completely removed.
   - Status: DONE. Can be programmatically verified by searching for the string `iwlist` within each binary. `iwlist` is the command to initiate Wi-Fi connection, if it is missing, the test passes.
3. NFS functionality to be completely removed.
   - Status: DONE. Can be programmatically verified by searching for the string `NFS` within each binary. The string `NFS` is present in the iPXE Componet list when starting up.
4. Non-UEFI loaders are not included.
   - Status: DONE. Only *.efi files were included in the submission

## Other reviewer Notes:

In addition to the basic 4 requirements above, Microsoft has also written three documents outlining more of their specific requirements for iPXE binaries to be SecureBoot signed.

[Requirements.md](requirements.md)

For each of the three documents, I have gone through and marked each hard REQUIREMENT with a foot note, then listed the status in the foot note.

* For some of the requirements, we can???? ( asking Microsoft for clarification on this point ) assume that the previous submission by 2Pint Software has validated the core iPXE source.
* Some of the requirements from Microsoft demand the removal of some components, I have listed what compliance has been taken here.
* Some of the requirements from Microsoft can be easily verified by a simple programmatic test. The `test-submission.test.ps1` script is a PowerShell Pester test can do this.

## Current Set of binaries:

### Testing Notes:

* If you are running this within a Hyper-V Virtual Machine, you MUST turn off Secure boot.

Binary paths:

https://www.deploymentlive.com/boot/snp_aa64.efi
https://www.deploymentlive.com/boot/snp_x64.efi
https://www.deploymentlive.com/boot/snp_drv_aa64.efi
https://www.deploymentlive.com/boot/snp_drv_x64.efi

ISO images:

https://www.deploymentlive.com/iso/snp_DRV_aa64.efi.iso
https://www.deploymentlive.com/iso/snp_DRV_x64.efi.iso

