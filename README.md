# SimplyCredential
PowerShell Module for working with Windows credentials

## Introduction
The purpose of this module is to make it easier to work with credentials on Windows. This means persisting credentials on disk and allowing you to use those credentials.  Using credentials inside powershell is typically straightforward, outside it can be more difficult.  This module also includes a wrapper around RunAs, thus allowing you to use credentials in launching a variety of programs.

## Status
In development, not yet released anywhere. Only tested on windows 10, no guarantees on other versions of windows.

## Documenation
**New/Save/Remove/Show/Use -Credential**  
Allows you to create, persist, remove, list and use credentials.

**Save/Remove/Show/Use -Application**  
Allows you persist, remove, list and use application references.  
Primarily this allows you to invoke an application and run it with a set of credentials from the commandline.

**Invoke-RemoteDesktop**  
Allows you to open an RDP session from commandline, includes the ability to handle authentication for you using the -Credential parameter.

**New-AzurePSSession**  
Creates a PSSession preconfigured to work with Azure.

**New-Password**  
Password generating function.