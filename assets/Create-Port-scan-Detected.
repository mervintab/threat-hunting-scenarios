# Threat Event (Port Scan Detection)

**Suspicious Network Activity Detected: Port Scans on Corporate Perimeter**

## Steps the "Bad Actor" Took to Create Logs and IoCs:

1. **Initiated a Port Scan** targeting a corporate IP range (`203.0.113.0/24`) using automated scanning tools such as Nmap or Masscan.
2. **Targeted Services** commonly found open on corporate networks (e.g., SSH (22), RDP (3389), HTTP (80), HTTPS (443), SMB (445)).
3. **Conducted a Stealth Scan** (e.g., SYN scan or fragmented packets) to evade simple detection mechanisms.
4. **Generated Multiple Connection Attempts** in a short time frame (e.g., hundreds of connection requests per minute).
5. **Used a Spoofed or Anonymous Source IP Address** to obscure the attack origin.

---

## Reason for Hunt:

- **Network Monitoring Alert**: IDS/IPS and firewall logs indicated a high volume of inbound connection attempts targeting sensitive ports on multiple devices.
- **Threat Intelligence Correlation**: Recent industry reports indicate increased port scanning activity linked to ransomware and initial access campaigns.
- **Policy Compliance**: Internal security policy mandates investigation of all suspicious port scan activities to prevent data breaches.

---

## Tables Used to Detect IoCs:

| **Parameter** | **Description** |
| ------------- | ------------- |
| **Name** | DeviceNetworkEvents |
| **Info** | [https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-devicenetworkevents-table](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-devicenetworkevents-table) |
| **Purpose** | Identify multiple connection attempts to common service ports within a short period. |

| **Parameter** | **Description** |
| ------------- | ------------- |
| **Name** | DeviceProcessEvents |
| **Info** | [https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceprocessevents-table](https://learn.microsoft.com/en-us/defender-xdr/advanced-hunting-deviceprocessevents-table) |
| **Purpose** | Cross-reference processes initiating outbound scans, if performed internally. |

---

## Related Queries:

```kql
// Detect high-volume connection attempts to sensitive ports (e.g., SSH, RDP, SMB)
DeviceNetworkEvents
| where RemotePort in (22, 3389, 445, 80, 443)
| where ActionType == "Inbound"
| summarize connection_count = count() by DeviceName, RemoteIP, RemotePort, bin(Timestamp, 1m)
| where connection_count > 50

// Optional: Detect processes initiating outbound port scans (if originating from inside)
DeviceProcessEvents
| where ProcessCommandLine has_any ("nmap", "masscan", "zmap")
| project Timestamp, DeviceName, AccountName, InitiatingProcessFileName, ProcessCommandLine
```

---

## Created By:

- **Author Name**: ChatGPT (Generated for Mervin Tabernero)  
- **Author Contact**: [Mervin's LinkedIn](https://www.linkedin.com/in/mervintab/)  
- **Date**: May 24, 2025  

## Validated By:

- **Reviewer Name**:  
- **Reviewer Contact**:  
- **Validation Date**:  

---

## Additional Notes:

- **Evasion Techniques**: Port scans may utilize stealth techniques (fragmented packets, randomized intervals) to bypass basic monitoring.
- **Threat Context**: Port scans are often precursors to more sophisticated attacks, such as vulnerability exploitation or brute-force login attempts.
- **Mitigation Steps**: Implement rate-limiting, intrusion prevention, and close unused ports. Monitor for correlated suspicious logins or exploit attempts.

---

## Revision History:

| **Version** | **Changes** | **Date** | **Modified By** |
| ----------- | ------------- | -------------- | ------------------------------ |
| 1.0 | Initial draft | May 24, 2025 | ChatGPT (for Mervin Tabernero) |
