# Threat Event (Malicious Calculator Installation)

**Unauthorized Download and Installation of a Malicious Calculator Application**

## Steps the "Bad Actor" Took to Create Logs and IoCs:

1. **User clicks on an unknown link** received via email, chat, or website.
2. **Download** a Calculator installer from:
   ```
   https://github.com/mervintab/threat-hunting-scenarios/blob/main/assets/Windows%20Calculator%20Installer.exe
   ```
   into the `Downloads` folder.
3. **Rename** the installer file using a **base64 encoded** filename to obscure its identity.
4. **Move** the renamed installer file from the `Downloads` folder to the `Temp` directory.
5. **Install** the calculator executable manually or via a script.
6. **Trigger** a `cmd.exe` popup with the message:
   ```
   "Calculator successfully installed"
   ```
7. **Create a Scheduled Task** to automatically execute the installed `calculator.exe` at system startup or user logon.

---

## Reason for Hunt:

- **Management Directive**: Following a recent phishing simulation, management requested an investigation into potential real-world infections caused by users interacting with suspicious links.
- **Unusual System Behavior**: IT helpdesk reported multiple systems exhibiting unexpected command-line popups and new scheduled tasks referencing unknown `.exe` files in unusual locations.
- **Cybersecurity News**: An uptick in malware campaigns leveraging renamed legitimate-looking installers (like "calculator.exe") to achieve persistence was highlighted in recent threat intel reports.

---

## Tables Used to Detect IoCs:

| **Parameter** | **Description**                                                                                                                                                                  |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Name**      | DeviceFileEvents                                                                                                                                                                 |
| **Info**      | [https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-devicefileevents-table](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-devicefileevents-table) |
| **Purpose**   | Detect file download into `Downloads`, renaming to base64 strings, and moving to `Temp` folder.                                                                                  |

| **Parameter** | **Description**                                                                                                                                                                        |
| ------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Name**      | DeviceProcessEvents                                                                                                                                                                    |
| **Info**      | [https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceprocessevents-table](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceprocessevents-table) |
| **Purpose**   | Detect execution of cmd.exe with unusual popup messages and installation of calculator.exe.                                                                                            |

| **Parameter** | **Description**                                                                                                                                                                          |
| ------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Name**      | DeviceRegistryEvents                                                                                                                                                                     |
| **Info**      | [https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceregistryevents-table](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceregistryevents-table) |
| **Purpose**   | Detect Scheduled Task creation related to calculator.exe persistence.                                                                                                                    |

---

## Related Queries:

```kql
// Detect the initial download of the Calculator installer
DeviceFileEvents
| where FolderPath endswith @"\Downloads"
| where FileName has_any ("Windows Calculator Installer.exe", "Windows%20Calculator%20Installer.exe")
| project Timestamp, DeviceName, InitiatingProcessAccountName, FileName, FolderPath

// Detect renaming of the file to a suspicious base64-like filename
DeviceFileEvents
| where FolderPath endswith @"\Downloads" or FolderPath endswith @"\Temp"
| where FileName matches regex @"^[A-Za-z0-9+/=]{10,}\.exe$"
| project Timestamp, DeviceName, InitiatingProcessAccountName, FileName, FolderPath

// Detect file moved from Downloads to Temp
DeviceFileEvents
| where PreviousFolderPath endswith @"\Downloads"
| where FolderPath endswith @"\Temp"
| project Timestamp, DeviceName, RequestAccountName, FileName, PreviousFolderPath, FolderPath

// Detect Calculator installation command and success message
DeviceProcessEvents
| where InitiatingProcessFileName == "cmd.exe"
| where ProcessCommandLine has "Calculator successfully installed"
| project Timestamp, DeviceName, AccountName, InitiatingProcessFileName, ProcessCommandLine

// Detect suspicious Scheduled Tasks creation related to calculator.exe
DeviceRegistryEvents
| where RegistryKey endswith @"\Microsoft\Windows\CurrentVersion\TaskCache\Tasks"
| where RegistryValueData has "calculator.exe"
| project Timestamp, DeviceName, InitiatingProcessAccountName, RegistryKey, RegistryValueName, RegistryValueData
```

---

## Created By:

- **Author Name**: ChatGPT (Generated for Mervin Tabernero)
- **Author Contact**: [Mervin's LinkedIn](https://www.linkedin.com/in/mervintab/)
- **Date**: April 29, 2025

## Validated By:

- **Reviewer Name**:
- **Reviewer Contact**:
- **Validation Date**:

---

## Additional Notes:

- **Persistence Mechanism**: Scheduled tasks are a common persistence technique for malware. Investigators should also check for the task name and execution frequency.
- **File Obfuscation**: Use of base64-encoded filenames is a tactic used to bypass casual inspection and evade simple detection rules.

---

## Revision History:

| **Version** | **Changes**   | **Date**       | **Modified By**                |
| ----------- | ------------- | -------------- | ------------------------------ |
| 1.0         | Initial draft | April 29, 2025 | ChatGPT (for Mervin Tabernero) |

