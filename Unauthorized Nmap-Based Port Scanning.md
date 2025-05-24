# Threat Hunt Report: Unauthorized Nmap-Based Port Scanning Simulation

- [Scenario Creation](https://github.com/mervintab/threat-hunting-scenarios/blob/main/assets/Port-Scan-Simulation.md)

## Platforms and Tools Leveraged

- Windows 10/11 Virtual Machines (Microsoft Azure)
- EDR Platform: Microsoft Defender for Endpoint
- Kusto Query Language (KQL)
- Nmap (Network Mapper)

## Scenario

Management initiated a proactive investigation following alerts from the perimeter firewall and IDS regarding high-volume port scan activities targeting corporate systems. The goal is to detect unauthorized scanning attempts, identify targeted ports, and correlate these findings with known threat techniques. Specifically, we focus on Nmap-driven SYN scans with potential stealth techniques (e.g., fragmented packets) targeting sensitive services such as SSH, RDP, SMB, and web services.

---

## High-Level Threat Discovery Plan

- **Check** `DeviceNetworkEvents` for high-volume connection attempts targeting sensitive ports.
- **Check** `DeviceProcessEvents` for evidence of unauthorized scanning tools (e.g., Nmap, Masscan).
- **Check** firewall/IDS logs for multiple connection attempts from a single or spoofed source.
- **Investigate** for potential evasion techniques such as fragmented packets or randomized IP scan orders.

---

## Steps Taken

### 1. Searched `DeviceNetworkEvents` Table for High-Volume Port Scans

**Objective:** Identify high-frequency connection attempts to ports 22, 3389, 445, 80, and 443.

**Query used:**
```kql
DeviceNetworkEvents
| where Timestamp > ago(3h)
| where RemotePort in (22, 3389, 445, 80, 443)
| where ActionType == "Inbound"
| summarize connection_count = count() by DeviceName, RemoteIP, RemotePort, bin(Timestamp, 1m)
| where connection_count > 50
| order by connection_count desc
```

**Findings:**  
Detected multiple inbound connection attempts from IP `203.0.113.45`, with over 100 requests per minute to RDP (3389) and SMB (445).

---

### 2. Searched `DeviceProcessEvents` for Unauthorized Nmap Execution

**Objective:** Identify local execution of scanning tools (Nmap, Masscan).

**Query used:**
```kql
DeviceProcessEvents
| where Timestamp > ago(3h)
| where ProcessCommandLine has_any ("nmap", "masscan", "zmap")
| project Timestamp, DeviceName, AccountName, InitiatingProcessFileName, ProcessCommandLine
| order by Timestamp desc
```

**Findings:**  
Nmap was executed from the `C:\Tools\nmap` directory with SYN and fragmentation options:
```
nmap -sS -f -T4 --open --randomize-hosts -p 22,3389,445,80,443 203.0.113.1-254
```

---

### 3. Analyzed Firewall/IDS Logs for Correlation

**Objective:** Validate scan source and identify additional targets.

**Findings:**  
Firewall logs confirmed numerous connection attempts from `203.0.113.45` (external) and a secondary scan originating from internal IP `10.0.0.15`.  

---

## Chronological Event Timeline

| **Timestamp** | **Event**           | **Details**                                      |
|:--------------|:---------------------|:-------------------------------------------------|
| 2025-05-24 10:00 | Port Scan Initiated | Nmap scan initiated targeting `203.0.113.1-254`. |
| 2025-05-24 10:01 | High-Volume Detected | >100 RDP/SMB connections detected. |
| 2025-05-24 10:02 | Firewall Alert      | Perimeter firewall flagged excessive inbound connections. |
| 2025-05-24 10:03 | Local Process Execution | Nmap found running on internal device `EDR-VM-01`. |
| 2025-05-24 10:04 | IDS Alert           | Internal IDS flagged potential lateral scanning behavior. |

---

## Summary

The threat hunting operation confirmed:

- Unauthorized use of **Nmap** with stealth techniques targeting sensitive ports.
- High-frequency inbound connection attempts indicating aggressive scanning behavior.
- Evidence of **internal Nmap scans** originating from endpoint `EDR-VM-01`, suggesting lateral movement attempts.
- Firewall and IDS correlation confirmed the port scan originated both externally and internally.

This aligns with known tactics used in the **Reconnaissance** phase of adversary attacks (MITRE ATT&CK T1046).

---

## Response Taken

- Disabled network access for the compromised internal host (`EDR-VM-01`).
- Blocked IP `203.0.113.45` at the perimeter firewall.
- Conducted forensic collection from the internal host.
- Notified IT teams and implemented enhanced firewall rules.
- Scheduled user awareness sessions to mitigate future risks.

---

# End of Report
