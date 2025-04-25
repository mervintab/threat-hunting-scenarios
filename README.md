# 🕵️‍♂️ Threat-Hunting Scenarios: Unauthorized TOR Usage
<img width="400" src="https://github.com/user-attachments/assets/44bac428-01bb-4fe9-9d85-96cba7698bee" alt="Tor Logo with the onion and a crosshair on it"/>

## 🔗 Scenario Reference
- [Scenario Creation Guide](https://github.com/mervintab/threat-hunting-scenarios/blob/main/threat-hunting-scenario-tor-event-creation.md)

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
| where DeviceName == "merv-winten-lab"
| where FileName has_any ("tor")
| order by Timestamp desc
| project Timestamp, DeviceName, ActionType, FileName, FolderPath, SHA256, Account = InitiatingProcessAccountName


```
![tor1](https://github.com/user-attachments/assets/2a84964f-00b0-4310-94f8-a79018e693ea)

---

### 2. ⚙️ Silent TOR Installation

**Observation:**  
TOR was installed silently via an executable run from the Downloads folder.

**KQL Query:**
```kql
DeviceProcessEvents
| where DeviceName == "merv-winten-lab"
| where ProcessCommandLine contains "tor-browser-windows-x86_64-portable-14.5.exe"
| project Timestamp, DeviceName, AccountName, ActionType, FileName, FolderPath, SHA256, ProcessCommandLine
```
![tor2](https://github.com/user-attachments/assets/15c8064b-bf99-436f-8a7d-a64a5d6bec0f)

---

### 3. 🚀 TOR Browser Execution Detected

**Observation:**  
The TOR browser and associated processes were launched, confirming execution.

**KQL Query:**
```kql
DeviceProcessEvents
| where DeviceName == "merv-winten-lab"
| where FileName has_any ("tor.exe", "firefox.exe", "tor-browser.exe")
| project Timestamp, DeviceName, AccountName, ActionType, FileName, FolderPath, SHA256, ProcessCommandLine
| order by Timestamp desc
```
![tor3](https://github.com/user-attachments/assets/4ed8415b-dfb0-4cd0-826a-52c01980664e)

---

### 4. 🌐 TOR Network Connections Established

**Observation:**  
TOR browser initiated multiple connections to known TOR ports and IP addresses.

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
![tor4](https://github.com/user-attachments/assets/e2086484-2f62-46ef-80c5-15b4c8452e1a)

---

## 🕓 Event Timeline (Chronological)

| **Timestamp (UTC)**              | **Event Description**                                                 |
|----------------------------------|------------------------------------------------------------------------|
| Apr 24, 2025 5:12:01 PM          | TOR installer downloaded to `Downloads` folder                        |
| Apr 24, 2025 5:16:40 PM          | Silent installation of TOR initiated                                  |
| Apr 24, 2025 5:20:40 PM          | TOR browser launched via `firefox.exe` and `tor.exe`                  |
| Apr 24, 2025 5:20:40 PM            | Connection to 65.21.219.130:443 established via tor.exe
| Apr 24, 2025 5:25:28 PM          | `tor-shopping-list.txt` file created on Desktop                       |

---

## 📌 Summary of Findings

- The user `system` on device `merv-winten-lab` installed and ran the TOR browser.
- Multiple TOR-related processes were observed.
- Outbound TOR network traffic was confirmed.
- A text file possibly referencing TOR usage was found and later deleted.

This strongly confirms unauthorized TOR activity by the employee.

---

## 🚨 Response Actions

- Device `merv-winten-lab` was isolated from the network.
- Direct manager of the user was notified.
- Additional monitoring was implemented for related systems.

---
