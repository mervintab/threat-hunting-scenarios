# 🛡️ Threat Hunting Scenarios Repository

Welcome to my **Threat Hunting Scenarios** repository! This project is a collection of real-world threat hunting exercises designed to simulate security incidents and enhance detection capabilities using the **Microsoft security stack**.

## 🔧 Tools & Technologies Used

- **Microsoft Sentinel** – SIEM for detection and response
- **Microsoft Defender for Endpoint (MDE)** – EDR for endpoint telemetry
- **Azure Virtual Machines** – Simulated enterprise infrastructure
- **Kusto Query Language (KQL)** – Querying and analytics

## 🎯 Purpose

This repository is intended for:
- Practicing detection engineering
- Building proactive threat hunting skills
- Testing hypotheses based on MITRE ATT&CK
- Demonstrating hands-on skills using Microsoft Security tools

## 📂 Repository Structure

```bash
threat-hunting-scenarios/
│
├── scenarios/
│   ├── unauthorized-tor-usage.md
│   ├── powershell-webrequest-download.md
│   ├── brute-force-login-investigation.md
│   └── ...
│
├── kql-queries/
│   ├── suspicious-processes.kql
│   ├── tor-exit-node-connections.kql
│   └── ...
│
├── assets/
│   └── images, diagrams, screenshots, guides
│
└── README.md
```

## 📘 Sample Scenarios

- **Unauthorized TOR Usage**  
  Detect employees bypassing network controls via the Tor browser.

- **PowerShell Suspicious Use**  
  Hunt for malicious `Invoke-WebRequest` activity on endpoints.

- **Brute Force Login Attempts**  
  Identify multiple failed logon attempts followed by success using Sentinel logs.

## 🧠 Learning Outcomes

- Advanced usage of KQL in Microsoft Sentinel
- Correlating events from Defender for Endpoint and Azure logs
- Mapping activities to MITRE ATT&CK techniques
- Reporting and documentation of hunting results

## 🚀 How to Use

1. Clone or download this repository.
2. Deploy an Azure lab or use existing resources.
3. Follow the scenario instructions to simulate and detect.
4. Use provided KQL queries in Microsoft Sentinel or Logs.
5. Document findings and repeat to reinforce concepts.

## 📌 Notes

- Each scenario is based on a hypothesis-driven hunting approach.
- Scenarios include background, objective, detection logic, and results.
- Images and diagrams enhance understanding of threat flow.

## 🤝 Contributions

Feel free to contribute your own scenarios or improve existing ones. Fork this repo and create a pull request!

## 📬 Contact

Created by **[Mervin Tabernero](https://www.linkedin.com/in/mervintab/)**  
Let’s connect on [GitHub](https://github.com/mervintab) and collaborate on security!

---

**🔒 Stay vigilant. Hunt threats. Learn continuously.**
