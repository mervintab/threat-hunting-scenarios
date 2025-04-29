
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

## High-Level Malware Discovery Plan

- **Check** `DeviceFileEvents` for downloads of suspicious executables into the `Downloads` folder.
- **Check** `DeviceFileEvents` for unusual file renames using base64 encoding.
- **Check** `DeviceFileEvents` for movements into the `Temp` folder.
- **Check** `DeviceProcessEvents` for executions of renamed malicious scripts and suspicious popup messages.
- **Check** `DeviceRegistryEvents` and Task Scheduler for suspicious Scheduled Task creations.

---

## Steps Taken

### 1. Searched the `DeviceFileEvents` Table for Downloads

**Objective:** Identify downloads of suspicious installer files into the `Downloads` folder.

**Query used:**
```kql
DeviceFileEvents
| where DeviceName == "merv-stigs-vm"
| where Timestamp > ago(3h)
| where FolderPath has_any("Downloads")
| where FileName has_any ("malicious", "payload", "update", "script", "install")
   or FileName endswith ".ps1" or FileName endswith ".exe" or FileName endswith ".cmd" or FileName endswith ".bat" or FileName endswith ".vbs"
| where not(InitiatingProcessCommandLine has "svchost.exe")
| project Timestamp, ActionType, FileName, FolderPath, SHA256, InitiatingProcessAccountName, InitiatingProcessCommandLine
| order by Timestamp desc
```

**Findings:**  
A user downloaded a malicious PowerShell file named `malicious-countdown-test.ps1` from an unknown online source.
![Screenshot 2025-04-29 124056](https://github.com/user-attachments/assets/d873154c-c17c-42ba-8615-f3ab1be76d4f)

---

### 2. Searched for Base64-Renamed Executables

**Objective:** Find file renames indicative of obfuscation attempts (base64-like names).

**Query used:**
```kql
DeviceFileEvents
| where DeviceName == "merv-stigs-vm"
| where Timestamp > ago(3h)
| where FolderPath has_any("Downloads")
| where FileName matches regex "^[A-Za-z0-9+/=]{10,}\.(ps1|cmd|bat|vbs|js|exe|dll)$"
| project Timestamp, ActionType, FileName, FolderPath, SHA256, InitiatingProcessAccountName, InitiatingProcessCommandLine
| order by Timestamp desc
```

**Findings:**  
The PowerShell file was automatically renamed into its base64 equivalent: `bWFsaWNpb3VzLWNvdW50ZG93bi10ZXN0LnBzMQ==.ps1`. 
![Screenshot 2025-04-29 125028](https://github.com/user-attachments/assets/34c16d51-3e25-4c62-8125-a5b73e5b3b64)

---

### 3. Searched for Movement to Temp Folder

**Objective:** Detect file movement from `Downloads` to `Temp`.

**Query used:**
```kql
DeviceFileEvents
| where DeviceName == "merv-stigs-vm"
| where Timestamp > ago(3h)
| where PreviousFolderPath has_any("Downloads")
| where FolderPath has_any("Temp")
| where FileName matches regex "^[A-Za-z0-9+/=]{10,}\.(ps1|cmd|bat|vbs|js|exe|dll)$"
| project Timestamp, ActionType, FileName, FolderPath, SHA256, InitiatingProcessAccountName, InitiatingProcessCommandLine
| order by Timestamp desc
```

**Findings:**  
The obfuscated script was found moved to the Temp folder. Upon manual inspection of the powershell script, it was discovered that when the file is run, suspicious `eicar_file.txt` will be generated on the desktop on the Desktop.
![Screenshot 2025-04-29 140635](https://github.com/user-attachments/assets/fa772d4a-f189-49bf-b6c1-e2bebdaecbaf)

---

### 4. Searched the `DeviceProcessEvents` Table for Execution and Popup Messages

**Objective:** Detect popup messages signaling script execution.

**Query used:**
```kql
DeviceProcessEvents
| where InitiatingProcessFileName == "cmd.exe" or InitiatingProcessFileName endswith ".ps1" or InitiatingProcessFileName endswith ".cmd"
| where ProcessCommandLine matches regex ".*[A-Za-z0-9+/=]{10,}\.(ps1|cmd|bat|vbs|js|exe|dll).*"
| project Timestamp, DeviceName, AccountName, ActionType, InitiatingProcessFileName, ProcessCommandLine
```

**Findings:**  
The above query did not generate useful information. THe machine in question was manually checked for evidence. It was confirmed that the file executed successfully and triggered a popup that notified "Time's Up!" followed by EICAR file creation.

---

### 5. Searched for Scheduled Task Creation (Persistence)

**Objective:** Detect unauthorized Scheduled Tasks.

**Query used:**
```kql
DeviceRegistryEvents
| where RegistryKey has "TaskCache\Tasks"
| where Timestamp > ago(3h)
| project Timestamp, DeviceName, InitiatingProcessAccountName, RegistryKey, RegistryValueName, RegistryValueData
```

**Findings:**  
The above query did not generate useful information either. But manual inspection confirmed that a suspicious scheduled task named `MaliciousCountdownObfuscated` was created to repeatedly run the malicious script every 5 minutes.

---

## Chronological Event Timeline

| **Timestamp** | **Event**           | **Details**                                      |
|:--------------|:---------------------|:-------------------------------------------------|
| 2025-04-29 11:00 | File Download    | User downloaded `malicious-countdown-test.ps1`  |
| 2025-04-29 11:02 | File Rename      | Script renamed to base64 format                 |
| 2025-04-29 11:03 | File Move        | Moved to Temp folder                            |
| 2025-04-29 11:05 | Script Execution | Malicious countdown script executed             |
| 2025-04-29 11:06 | Scheduled Task   | Scheduled task created for persistent execution |

---

## Summary

The threat hunting operation successfully identified:

- Unauthorized download of a malicious PowerShell script.
- Obfuscation through base64 encoding.
- File movement to Temp folder to evade easy detection.
- Execution resulting in EICAR file creation.
- Scheduled task persistence to re-execute the malicious script repeatedly.

This confirms a clear attack chain designed to establish stealthy persistence using simple, highly obfuscated scripts.

---

## Response Taken

- Malicious scheduled task removed.
- Malicious files deleted from affected endpoint.
- Device isolated temporarily for deep forensic review.
- User educated about safe browsing and email handling practices.
- Full forensic image collected for evidence.

---

# End of Report
