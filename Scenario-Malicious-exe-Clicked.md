# Threat Hunt Report: Unauthorized Malicious PowerShell Script Execution
- [Scenario Creation](https://github.com/mervintab/threat-hunting-scenarios/blob/main/assets/Create-Malicious-link-malware.md)

## Platforms and Tools Leveraged
- Windows 10 Virtual Machines (Microsoft Azure)
- EDR Platform: Microsoft Defender for Endpoint
- Kusto Query Language (KQL)
- Windows Task Scheduler

## Scenario

Management has requested an urgent investigation after reports of users receiving suspicious links that could lead to unauthorized application installations. Additionally, unusual scheduled tasks were detected in several endpoints without known administrative approval. The goal is to detect any malicious file downloads, suspicious file renames, unauthorized scheduled task creations, and popup messages hinting at unauthorized installs.

The investigation will focus on tracing file creation, process executions, and persistence mechanisms related to the `malicious-countdown-test.ps1` file download.

---

## High-Level Calculator Malware Discovery Plan

- **Check `DeviceFileEvents`** for download of suspicious executables into the `Downloads` folder.
- **Check `DeviceFileEvents`** for unusual file renames using base64 encoding.
- **Check `DeviceFileEvents`** for movements into the `Temp` folder.
- **Check `DeviceProcessEvents`** for executions of renamed malicious-countdown-test.ps1 and popup messages.
- **Check `DeviceRegistryEvents`** for suspicious Scheduled Task creations.

---

## Steps Taken

### 1. Searched the `DeviceFileEvents` Table

**Objective:** Identify downloads of suspicious installer files into the `Downloads` folder.

**Query used:**
```kql
DeviceFileEvents
| where DeviceName == "merv-stigs-vm"
| where Timestamp > ago(1h)
| where FolderPath has_any("Downloads")
| where FileName has_any ("malicious*", "payload*", "update*", "script*", "install*")
   or FileName endswith ".ps1"
   or FileName endswith ".exe"
   or FileName endswith ".cmd"
   or FileName endswith ".bat"
   or FileName endswith ".vbs"
| where not(InitiatingProcessCommandLine has "svchost.exe")
| project Timestamp, ActionType, FileName, FolderPath, SHA256, InitiatingProcessAccountName, InitiatingProcessCommandLine
| order by Timestamp desc

```

**Findings:**  
*During the initial investigation and using the query above, it was found out that the user clicked and downloaded a powershell file named malicious-countdown-test.ps1 from an unknown online source.*
![Screenshot 2025-04-29 124056](https://github.com/user-attachments/assets/a93dc45d-1467-4841-9169-9096f727186c)


### 2. Searched for Base64-Renamed Executables

**Objective:** Find file renames indicative of obfuscation attempts (base64-like names).

**Query used:**
```kql
DeviceFileEvents
| where FolderPath endswith @"\\Downloads" or FolderPath endswith @"\\Temp"
| where FileName matches regex "^[A-Za-z0-9+/=]{10,}\\.(ps1|cmd|bat|vbs|js|exe|dll)$"
| project Timestamp, DeviceName, ActionType, FileName, FolderPath, InitiatingProcessAccountName


**Findings:**  
*Pending - to be filled after running the scenario.*

![Screenshot 2025-04-29 125028](https://github.com/user-attachments/assets/a943867a-e16b-44f8-8440-d0dd234f9485)

---

### 3. Searched for Movement to Temp Folder

**Objective:** Detect file movement from `Downloads` to `Temp`.

**Query used:**
```kql
DeviceFileEvents
| where PreviousFolderPath endswith @"\\Downloads"
| where FolderPath endswith @"\\Temp"
| project Timestamp, DeviceName, FileName, PreviousFolderPath, FolderPath, InitiatingProcessAccountName
```

**Findings:**  
*Pending - to be filled after running the scenario.*

---

### 4. Searched the `DeviceProcessEvents` Table for Installation and Popup

**Objective:** Detect popup messages signaling "successful" installation.

**Query used:**
```kql
DeviceProcessEvents
| where InitiatingProcessFileName == "cmd.exe" or InitiatingProcessFileName endswith ".ps1" or InitiatingProcessFileName endswith ".cmd"
| where ProcessCommandLine matches regex ".*[A-Za-z0-9+/=]{10,}\\.(ps1|cmd|bat|vbs|js|exe|dll).*"
| project Timestamp, DeviceName, AccountName, ActionType, InitiatingProcessFileName, ProcessCommandLine

```

**Findings:**  
*Pending - to be filled after running the scenario.*

---

### 5. Searched for Scheduled Task Persistence

**Objective:** Detect Scheduled Task entries created to maintain persistence.

**Query used:**
```kql
DeviceRegistryEvents
| where Timestamp > ago(24h)
| where RegistryKey endswith @"\\Microsoft\\Windows\\CurrentVersion\\TaskCache\\Tasks"
| project Timestamp, DeviceName, InitiatingProcessAccountName, RegistryKey, RegistryValueName, RegistryValueData

```

**Findings:**  
*Pending - to be filled after running the scenario.*

---

## Chronological Event Timeline

| **Timestamp** | **Event** | **Details** |  
|---------------|-----------|-------------|  
| _(To be filled)_ | File Download | User downloaded malicious PowerShell countdown script |  
| _(To be filled)_ | File Rename | File renamed to base64 format |  
| _(To be filled)_ | File Move | Moved to Temp folder |  
| _(To be filled)_ | Process Execution | Countdown script executed in PowerShell and displayed in cmd.exe |  
| _(To be filled)_ | Persistence | Scheduled Task created to maintain execution |

---

## Summary

Pending — will summarize if the unauthorized PowerShell script execution was successfully detected, and if persistence mechanisms were established.

---

## Response Taken

Pending — depending on findings. Might include device isolation, task removal, user education, forensic collection, etc.

---
