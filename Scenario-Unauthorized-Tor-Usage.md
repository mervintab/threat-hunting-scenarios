
# 🕵️ Threat-Hunting Report: Unauthorized TOR Usage (NIST Format)
![383d480974ce76619f0e4f765c37b900](https://github.com/user-attachments/assets/68b188e9-75c1-4bdc-a94d-51f711c9fafa)
---

## 1. Preparation

**Platforms & Tools Used:**
- **Operating System:** Windows 10 Virtual Machines (Azure-hosted)
- **Security Stack:** Microsoft Defender for Endpoint (MDE), Microsoft Sentinel
- **Scripting & Querying:** Kusto Query Language (KQL)
- **Software in Scope:** Tor Browser Bundle (tor.exe, firefox.exe, tor-browser.exe)

**Preparation Measures:**
- Baseline monitoring for anomalous encrypted traffic.
- Threat intelligence watchlist for known TOR nodes.
- Acceptable Use Policy (AUP) prohibiting anonymizer tools.

**Scenario Reference:**
- [Scenario Creation Guide](https://github.com/mervintab/threat-hunting-scenarios/blob/main/assets/threat-hunting-scenario-tor-event-creation.md)

---

## 2. Detection and Analysis

### Detection

**Suspicion:**  
Unusual encrypted traffic patterns detected, supported by anonymous employee reports.

**Detection Methods:**
- **DeviceFileEvents:** Searched for TOR-related file artifacts.
- **DeviceProcessEvents:** Monitored for TOR browser installation/execution.
- **DeviceNetworkEvents:** Inspected outbound connections to known TOR ports/IPs.

### Indicators of Compromise (IoCs)
- File downloads of `tor-browser-windows-x86_64-portable-14.5.exe`
- Execution of `tor.exe`, `firefox.exe`
- Outbound connections to TOR nodes (e.g., `65.21.219.130:443`)
- Presence of `tor-shopping-list.txt` file

### Investigation Steps & Results

#### 2.1 File Activity Search
```kql
DeviceFileEvents
| where DeviceName == "merv-winten-lab"
| where FileName has_any ("tor", "tor-browser", "firefox")
| order by Timestamp desc
| project Timestamp, DeviceName, ActionType, FileName, FolderPath, SHA256, Account = InitiatingProcessAccountName
```
- TOR installer downloaded.
- `tor-shopping-list.txt` created.

#### 2.2 Silent Installation
```kql
DeviceProcessEvents
| where DeviceName == "merv-winten-lab"
| where ProcessCommandLine contains "tor-browser-windows-x86_64-portable-14.5.exe"
| project Timestamp, DeviceName, AccountName, ActionType, FileName, FolderPath, SHA256, ProcessCommandLine
```
- Silent install detected without user prompts.

#### 2.3 Execution
```kql
DeviceProcessEvents
| where DeviceName == "merv-winten-lab"
| where FileName has_any ("tor.exe", "firefox.exe", "tor-browser.exe")
| project Timestamp, DeviceName, AccountName, ActionType, FileName, FolderPath, SHA256, ProcessCommandLine
| order by Timestamp desc
```
- TOR browser launched outside business hours.

#### 2.4 Network Activity
```kql
DeviceNetworkEvents
| where DeviceName == "merv-winten-lab"
| where InitiatingProcessAccountName != "system"
| where InitiatingProcessFileName in ("tor.exe", "firefox.exe")
| where RemotePort in ("9001", "9030", "9040", "9050", "9051", "9150", "80", "443")
| project Timestamp, DeviceName, InitiatingProcessAccountName, ActionType, RemoteIP, RemotePort, RemoteUrl, InitiatingProcessFileName, InitiatingProcessFolderPath
| order by Timestamp desc
```
- Outbound TOR connections confirmed.

### Event Timeline

| Timestamp (UTC)               | Event Description                                               |
|--------------------------------|-----------------------------------------------------------------|
| Apr 24, 2025 5:12:01 PM        | TOR installer downloaded                                        |
| Apr 24, 2025 5:16:40 PM        | Silent installation initiated                                   |
| Apr 24, 2025 5:20:40 PM        | TOR browser launched                                            |
| Apr 24, 2025 5:20:40 PM        | Outbound connection to TOR node 65.21.219.130:443 established    |
| Apr 24, 2025 5:25:28 PM        | `tor-shopping-list.txt` created                                 |
| Apr 24, 2025 5:30:00 PM        | Additional TOR circuits built                                   |

---

## 3. Containment, Eradication, and Recovery

### Containment Actions
- **Device Isolation:** Immediately isolated `merv-winten-lab` via MDE.
- **Account Suspension:** Disabled the user account pending investigation.

### Eradication Actions
- Deleted TOR executables and residual files.
- Removed suspicious text file artifacts (`tor-shopping-list.txt`).
- Blocked TOR node IP addresses at firewall level.

### Recovery Actions
- Re-imaged affected endpoint.
- Restored system from latest secure backup.
- Conducted credential reset for user accounts accessed from device.

---

## 4. Post-Incident Activity

### Lessons Learned
- **Gaps Identified:** No prior network egress filtering for anonymizers.
- **Policy Improvements:** Updated Acceptable Use Policy (AUP).
- **Technical Improvements:**
  - Implemented TOR node IP/Domain blocking lists.
  - Enhanced monitoring for anonymized traffic signatures.

### Recommended Follow-up
- Conduct a **full disk forensic analysis**.
- Review **internal communications**.
- Launch **awareness training** regarding the dangers of unauthorized software.
- Monitor for **recurrent anonymized traffic**.

### Documentation and Reporting
- Incident report submitted to CISO and Legal.
- Event and response archived according to compliance policy.
- Incident closure scheduled within **5 business days**.

**Incident Owner:** Cybersecurity Incident Response Team (CSIRT)

---

# ✨ End of Report

---
