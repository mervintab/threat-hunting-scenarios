
# 🕵️‍♂️ Threat-Hunting Report: Unauthorized TOR Usage
![383d480974ce76619f0e4f765c37b900](https://github.com/user-attachments/assets/55a769e3-3bf4-4cac-ab55-8dd5d0058413)
---

## 🔗 Scenario Reference
- [Scenario Creation Guide](https://github.com/mervintab/threat-hunting-scenarios/blob/main/assets/threat-hunting-scenario-tor-event-creation.md)

---

## ⚙️ Platforms & Tools Used
- **Operating System:** Windows 10 Virtual Machines (Azure-hosted)
- **Security Stack:** Microsoft Defender for Endpoint (MDE), Microsoft Sentinel (optional extension)
- **Scripting & Querying:** Kusto Query Language (KQL)
- **Software in Scope:** Tor Browser Bundle (tor.exe, firefox.exe, tor-browser.exe)

---

## 🧠 Scenario Overview

**Suspicion:**  
Network security monitoring revealed unusual encrypted traffic patterns. Additionally, anonymous internal reports alleged that employees were discussing bypassing security controls to access restricted content, prompting concerns about TOR usage.

**Objective:**  
- Detect unauthorized use of the TOR browser.
- Confirm artifacts (files, processes, network traffic).
- Assess potential data exfiltration or policy violation risks.
- Report and initiate corrective actions immediately if validated.

---

## 🗺️ IoC Discovery Plan

- **DeviceFileEvents:** Search for TOR-related file downloads or artifacts.
- **DeviceProcessEvents:** Identify TOR installation and execution processes.
- **DeviceNetworkEvents:** Detect anomalous outbound network connections on TOR-specific ports (e.g., 9001, 9030, 9040, 9050, 9051, 9150).
- **Advanced:** (Optional) Hunt for signs of encrypted or anonymized traffic patterns.

---

## 🔍 Investigation Steps & Results

### 1. 🗂️ File Activity Search

**Observation:**  
User account `system` downloaded and extracted TOR browser components. Presence of a file `tor-shopping-list.txt` indicated potential preparation for hidden activities.

**KQL Query:**
```kql
DeviceFileEvents
| where DeviceName == "merv-winten-lab"
| where FileName has_any ("tor", "tor-browser", "firefox")
| order by Timestamp desc
| project Timestamp, DeviceName, ActionType, FileName, FolderPath, SHA256, Account = InitiatingProcessAccountName
```

**Result:**
- `tor-browser-windows-x86_64-portable-14.5.exe` downloaded to `Downloads` folder.
- `tor-shopping-list.txt` created on Desktop.

---

### 2. ⚙️ Silent TOR Installation

**Observation:**  
Installation was performed without significant user prompts, indicative of deliberate concealment.

**KQL Query:**
```kql
DeviceProcessEvents
| where DeviceName == "merv-winten-lab"
| where ProcessCommandLine contains "tor-browser-windows-x86_64-portable-14.5.exe"
| project Timestamp, DeviceName, AccountName, ActionType, FileName, FolderPath, SHA256, ProcessCommandLine
```

**Result:**
- TOR Browser was executed directly from the Downloads folder.

---

### 3. 🚀 TOR Browser Execution Detected

**Observation:**
Multiple TOR-related executables (tor.exe, firefox.exe) were launched post-installation.

**KQL Query:**
```kql
DeviceProcessEvents
| where DeviceName == "merv-winten-lab"
| where FileName has_any ("tor.exe", "firefox.exe", "tor-browser.exe")
| project Timestamp, DeviceName, AccountName, ActionType, FileName, FolderPath, SHA256, ProcessCommandLine
| order by Timestamp desc
```

**Result:**
- TOR browser was run almost immediately after installation.
- Launch occurred outside normal business hours.

---

### 4. 🌐 TOR Network Connections Established

**Observation:**
Outbound communications detected to TOR-related IPs and ports.

**KQL Query:**
```kql
DeviceNetworkEvents
| where DeviceName == "merv-winten-lab"
| where InitiatingProcessAccountName != "system"
| where InitiatingProcessFileName in ("tor.exe", "firefox.exe")
| where RemotePort in ("9001", "9030", "9040", "9050", "9051", "9150", "80", "443")
| project Timestamp, DeviceName, InitiatingProcessAccountName, ActionType, RemoteIP, RemotePort, RemoteUrl, InitiatingProcessFileName, InitiatingProcessFolderPath
| order by Timestamp desc
```

**Result:**
- Connections initiated to known TOR nodes at `65.21.219.130:443` and others.
- Connections to standard HTTPS (443) observed, blending into normal traffic.

---

### 5. 👉 Additional Checks (Recommended)
- Check `DeviceRegistryEvents` for TOR-related startup persistence.
- Check `DeviceLogonEvents` for user activity spike correlating to TOR usage.
- Investigate `DeviceImageLoadEvents` for additional malicious DLLs loaded during TOR session.

---

## 🕒 Event Timeline (Chronological)

| **Timestamp (UTC)**              | **Event Description**                                                     |
|-----------------------------------|---------------------------------------------------------------------------|
| Apr 24, 2025 5:12:01 PM           | TOR installer downloaded to `Downloads` folder                           |
| Apr 24, 2025 5:16:40 PM           | Silent installation of TOR initiated from executable                    |
| Apr 24, 2025 5:20:40 PM           | TOR browser launched via `tor.exe` and `firefox.exe`                     |
| Apr 24, 2025 5:20:40 PM           | Outbound connection to TOR entry node `65.21.219.130:443` established    |
| Apr 24, 2025 5:25:28 PM           | `tor-shopping-list.txt` file created and accessed on Desktop             |
| Apr 24, 2025 5:30:00 PM           | Additional TOR circuits built (multiple IPs contacted)                  |

---

## 📌 Summary of Findings

- **Confirmed:** TOR Browser installed and executed on corporate device `merv-winten-lab`.
- **Confirmed:** Unauthorized outbound TOR network connections observed.
- **Confirmed:** Downloaded TOR installer bypassed software policy.
- **Confirmed:** User engaged in TOR usage without company approval.

**No evidence** of immediate data exfiltration observed, but deeper forensic disk analysis is recommended.

---

## 🚨 Response Actions

- **Isolated** affected device `merv-winten-lab` from corporate network via MDE.
- **Disabled** user account pending HR and security review.
- **Notified** direct manager, HR, and IT compliance.
- **Collected** volatile memory snapshot for deeper forensic analysis.
- **Enabled** elevated monitoring on all endpoints for TOR-related indicators.
- **Submitted** SHA256 hashes of TOR files to corporate threat intelligence platform.
- **Drafted** incident notification for legal and compliance teams.

---

## 🔎 Recommended Next Steps

- Conduct a **full disk forensic image** of `merv-winten-lab`.
- Review **internal communications (email, chat)** for TOR-related planning.
- Implement **network egress filtering** to block known TOR nodes.
- Update **Acceptable Use Policies (AUP)** to explicitly prohibit anonymizers.
- Provide **employee cybersecurity awareness training**.
- Deploy **Sentinel Hunting Queries** for early detection of future anonymized traffic.

---

# 📅 Incident Closure Target: Within 5 Business Days  
**Owner:** Cybersecurity Incident Response Team (CSIRT)

---

# ✨ End of Report

---

