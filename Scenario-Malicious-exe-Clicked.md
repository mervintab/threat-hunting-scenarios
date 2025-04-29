
<img width="400" src="https://github.com/user-attachments/assets/44bac428-01bb-4fe9-9d85-96cba7698bee" alt="Calculator Icon with Warning"/>

# Threat Hunt Report: Unauthorized Malicious Calculator Installation
- [Scenario Creation](https://github.com/mervintab/threat-hunting-scenarios/blob/main/assets/Malicious-calc-Event_creation.md)

## Platforms and Tools Leveraged
- Windows 10 Virtual Machines (Microsoft Azure)
- EDR Platform: Microsoft Defender for Endpoint
- Kusto Query Language (KQL)
- Windows Task Scheduler

## Scenario

Management has requested an urgent investigation after reports of users receiving suspicious links that could lead to unauthorized application installations. Additionally, unusual scheduled tasks were detected in several endpoints without known administrative approval. The goal is to detect any malicious file downloads, suspicious file renames, unauthorized scheduled task creations, and popup messages hinting at unauthorized installs.

The investigation will focus on tracing file creation, process executions, and persistence mechanisms related to the fake `calculator.exe`.

---

## High-Level Calculator Malware Discovery Plan

- **Check `DeviceFileEvents`** for download of suspicious executables into the `Downloads` folder.
- **Check `DeviceFileEvents`** for unusual file renames using base64 encoding.
- **Check `DeviceFileEvents`** for movements into the `Temp` folder.
- **Check `DeviceProcessEvents`** for executions of renamed calculator.exe and popup messages.
- **Check `DeviceRegistryEvents`** for suspicious Scheduled Task creations.

---

## Steps Taken

### 1. Searched the `DeviceFileEvents` Table

**Objective:** Identify downloads of suspicious installer files into the `Downloads` folder.

**Query used:**
```kql
DeviceFileEvents
| where FolderPath endswith @"\\Downloads"
| where FileName has_any ("Windows Calculator Installer.exe", "Windows%20Calculator%20Installer.exe")
| project Timestamp, DeviceName, ActionType, FileName, FolderPath, SHA256, InitiatingProcessAccountName
```

**Findings:**  
*Pending - to be filled after running the scenario.*

---

### 2. Searched for Base64-Renamed Executables

**Objective:** Find file renames indicative of obfuscation attempts (base64-like names).

**Query used:**
```kql
DeviceFileEvents
| where FolderPath endswith @"\\Downloads" or FolderPath endswith @"\\Temp"
| where FileName matches regex "^[A-Za-z0-9+/=]{10,}\.exe$"
| project Timestamp, DeviceName, ActionType, FileName, FolderPath, InitiatingProcessAccountName
```

**Findings:**  
*Pending - to be filled after running the scenario.*

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
| where InitiatingProcessFileName == "cmd.exe"
| where ProcessCommandLine contains "Calculator successfully installed"
| project Timestamp, DeviceName, AccountName, ActionType, ProcessCommandLine
```

**Findings:**  
*Pending - to be filled after running the scenario.*

---

### 5. Searched for Scheduled Task Persistence

**Objective:** Detect Scheduled Task entries created to maintain persistence.

**Query used:**
```kql
DeviceRegistryEvents
| where RegistryKey endswith @"\\Microsoft\\Windows\\CurrentVersion\\TaskCache\\Tasks"
| where RegistryValueData has "calculator.exe"
| project Timestamp, DeviceName, InitiatingProcessAccountName, RegistryKey, RegistryValueName, RegistryValueData
```

**Findings:**  
*Pending - to be filled after running the scenario.*

---

## Chronological Event Timeline

| **Timestamp** | **Event** | **Details** |  
|---------------|-----------|-------------|  
| _(To be filled)_ | File Download | User downloaded calculator installer |  
| _(To be filled)_ | File Rename | File renamed to base64 format |  
| _(To be filled)_ | File Move | Moved to Temp folder |  
| _(To be filled)_ | Process Execution | Calculator installed and popup triggered |  
| _(To be filled)_ | Persistence | Scheduled Task created to maintain execution |

---

## Summary

Pending — will summarize if the unauthorized calculator installation was successfully detected, and if persistence mechanisms were established.

---

## Response Taken

Pending — depending on findings. Might include device isolation, task removal, user education, forensic collection, etc.

---
