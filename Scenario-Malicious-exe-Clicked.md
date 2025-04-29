
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

...

## End of Report

---
