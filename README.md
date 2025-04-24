# 🕵️‍♂️ Threat-Hunting Scenarios: Unauthorized TOR Usage
<img width="400" src="https://github.com/user-attachments/assets/44bac428-01bb-4fe9-9d85-96cba7698bee" alt="Tor Logo with the onion and a crosshair on it"/>

## 🔗 Scenario Reference
- [Scenario Creation Guide](https://github.com/joshmadakor0/threat-hunting-scenario-tor/blob/main/threat-hunting-scenario-tor-event-creation.md)

---

## ⚙️ Platforms & Tools Used
- **Operating System:** Windows 10 Virtual Machines (Azure)
- **Security Stack:** Microsoft Defender for Endpoint (MDE)
- **Scripting & Querying:** Kusto Query Language (KQL)
- **Software in Scope:** Tor Browser

---

## 🧠 Scenario Overview

**Suspicion:**  
Unusual encrypted traffic patterns in the network and anonymous reports of employees discussing access to restricted sites have prompted management to suspect TOR browser usage on corporate endpoints.

**Objective:**  
Detect TOR usage, validate associated indicators of compromise (IoCs), and assess the scope of any malicious behavior. Immediate management notification if TOR activity is confirmed.

---

## 🗺️ IoC Discovery Plan

- **`DeviceFileEvents`:** Look for TOR-related files (`tor.exe`, `firefox.exe`, etc.)
- **`DeviceProcessEvents`:** Detect TOR browser installation or execution.
- **`DeviceNetworkEvents`:** Identify outbound connections on known TOR network ports.

---

## 🔍 Investigation Steps & Results

### 1. 🗂 File Activity Search

**Observation:**  
User "employee" downloaded and extracted TOR browser files, including `tor-shopping-list.txt`, onto the desktop.

**KQL Query:**
```kql
DeviceFileEvents
| where DeviceName == "threat-hunt-lab"
| where InitiatingProcessAccountName == "employee"
| where FileName contains "tor"
| where Timestamp >= datetime(2024-11-08T22:14:48.6065231Z)
| order by Timestamp desc
| project Timestamp, DeviceName, ActionType, FileName, FolderPath, SHA256, Account = InitiatingProcessAccountName
```

---

### 2. ⚙️ Silent TOR Installation

**Observation:**  
TOR was installed silently via an executable run from the Downloads folder.

**KQL Query:**
```kql
DeviceProcessEvents
| where DeviceName == "threat-hunt-lab"
| where ProcessCommandLine contains "tor-browser-windows-x86_64-portable-14.0.1.exe"
| project Timestamp, DeviceName, AccountName, ActionType, FileName, FolderPath, SHA256, ProcessCommandLine
```

---

### 3. 🚀 TOR Browser Execution Detected

**Observation:**  
The TOR browser and associated processes were launched, confirming execution.

**KQL Query:**
```kql
DeviceProcessEvents
| where DeviceName == "threat-hunt-lab"
| where FileName has_any ("tor.exe", "firefox.exe", "tor-browser.exe")
| project Timestamp, DeviceName, AccountName, ActionType, FileName, FolderPath, SHA256, ProcessCommandLine
| order by Timestamp desc
```

---

### 4. 🌐 TOR Network Connections Established

**Observation:**  
TOR browser initiated multiple connections to known TOR ports and IP addresses.

**KQL Query:**
```kql
DeviceNetworkEvents
| where DeviceName == "threat-hunt-lab"
| where InitiatingProcessAccountName != "system"
| where InitiatingProcessFileName in ("tor.exe", "firefox.exe")
| where RemotePort in ("9001", "9030", "9040", "9050", "9051", "9150", "80", "443")
| project Timestamp, DeviceName, InitiatingProcessAccountName, ActionType, RemoteIP, RemotePort, RemoteUrl, InitiatingProcessFileName, InitiatingProcessFolderPath
| order by Timestamp desc
```

---

## 🕓 Event Timeline (Chronological)

| **Timestamp (UTC)**              | **Event Description**                                                 |
|----------------------------------|------------------------------------------------------------------------|
| 2024-11-08T22:14:48              | TOR installer downloaded to `Downloads` folder                        |
| 2024-11-08T22:16:47              | Silent installation of TOR initiated                                  |
| 2024-11-08T22:17:21              | TOR browser launched via `firefox.exe` and `tor.exe`                  |
| 2024-11-08T22:18:01              | Connection to `176.198.159.33:9001` established via `tor.exe`         |
| 2024-11-08T22:18:08 - 22:18:16   | Additional connections to `194.164.169.85:443` and `127.0.0.1:9150`   |
| 2024-11-08T22:27:19              | `tor-shopping-list.txt` file created on Desktop                       |

---

## 📌 Summary of Findings

- The user `employee` on device `threat-hunt-lab` installed and ran the TOR browser.
- Multiple TOR-related processes were observed.
- Outbound TOR network traffic was confirmed.
- A text file possibly referencing TOR usage was found and later deleted.

This strongly confirms unauthorized TOR activity by the employee.

---

## 🚨 Response Actions

- Device `threat-hunt-lab` was isolated from the network.
- Direct manager of the user was notified.
- Additional monitoring was implemented for related systems.

---
