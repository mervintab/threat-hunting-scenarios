# 🛑 Threat Event: Unauthorized TOR Usage

## 🔍 Overview
**Incident Type:** Unauthorized TOR Browser Installation and Use  
**Summary:** A user downloaded, installed, and accessed the TOR browser, visited hidden services, and created a local file related to illicit activity.  
**Date of Event:** _(Insert actual event date if known)_

---

## 🧑‍💻 Adversary Behavior & Steps to Create Logs and IoCs

1. **Downloaded the TOR browser installer** from:  
   https://www.torproject.org/download/

2. **Silently installed TOR** via PowerShell:
   ```powershell
   Start-Process -FilePath "C:\Users\labuser\Desktop\Installs\tor-browser-windows-x86_64-portable-14.5.exe" -ArgumentList "/silent /norestart" -Wait -NoNewWindow
   ```

3. **Launched TOR Browser** from the Desktop.

4. **Connected to TOR and visited hidden services**, including:
   - 🧵 Dread Forum:  
     `dreadytofatroptsdj6io7l3xptbet6onoyno2yv7jicoxknyazubrad.onion`
   - 🛒 Dark Markets Forum:  
     `dreadytofatroptsdj6io7l3xptbet6onoyno2yv7jicoxknyazubrad.onion/d/DarkNetMarkets`
   - 🌐 Elysium Market:  
     `elysiumutkwscnmdohj23gkcyp3ebrf4iio3sngc5tvcgyfp4nqqmwad.top/login`

5. **Created a file** on the desktop:
   ```
   tor-shopping-list.txt
   ```
   - Included fake (illicit) items.

6. **Deleted the file** afterward to evade detection.

---

## 📊 Microsoft Defender for Endpoint Tables Used

| Table Name             | Purpose                                                                 |
|------------------------|-------------------------------------------------------------------------|
| `DeviceFileEvents`     | Detects TOR downloads, file creation (shopping list), and deletion.     |
| `DeviceProcessEvents`  | Monitors silent TOR installation, and TOR/Firefox process launches.     |
| `DeviceNetworkEvents`  | Captures TOR-related network connections over known ports.              |

> 📚 Reference: [Microsoft Advanced Hunting Table Reference](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-overview)

---

## 🧪 Detection Queries

### 1. **Detect TOR Installer Download**
```kql
DeviceFileEvents
| where FileName startswith "tor"
```

### 2. **Detect Silent TOR Installation**
```kql
DeviceProcessEvents
| where ProcessCommandLine contains "tor-browser-windows-x86_64-portable-14.0.1.exe  /S"
| project Timestamp, DeviceName, ActionType, FileName, ProcessCommandLine
```

### 3. **Detect Presence of TOR Components**
```kql
DeviceFileEvents
| where FileName has_any ("tor.exe", "firefox.exe")
| project Timestamp, DeviceName, RequestAccountName, ActionType, InitiatingProcessCommandLine
```

### 4. **Detect TOR Launch Events**
```kql
DeviceProcessEvents
| where ProcessCommandLine has_any("tor.exe", "firefox.exe")
| project Timestamp, DeviceName, AccountName, ActionType, ProcessCommandLine
```

### 5. **Detect TOR Network Activity**
```kql
DeviceNetworkEvents
| where InitiatingProcessFileName in~ ("tor.exe", "firefox.exe")
| where RemotePort in (9001, 9030, 9040, 9050, 9051, 9150)
| project Timestamp, DeviceName, InitiatingProcessAccountName, InitiatingProcessFileName, RemoteIP, RemotePort, RemoteUrl
| order by Timestamp desc
```

### 6. **Detect Creation/Modification of Shopping List File**
```kql
DeviceFileEvents
| where FileName contains "shopping-list.txt"
```

---

## 👨‍💻 Created By
- **Author:** Mervin Tabernero  
- **LinkedIn:** [linkedin.com/in/mervintab](https://www.linkedin.com/in/mervintab/)  
- **Date Created:** April 24, 2025

## ✅ Validated By
- **Reviewer Name:** _[To be filled]_  
- **Reviewer Contact:** _[To be filled]_  
- **Validation Date:** _[To be filled]_

---

## 📝 Additional Notes
- Always validate network traffic and processes before taking enforcement action.
- Consider correlating with `AlertEvidence` and `DeviceEvents` for deeper investigation.
- Add TOR `.onion` domains to a custom block list if not used in your environment.

---
