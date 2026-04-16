# HK-APEX MASTER FRAMEWORK v1.0

<div align="center">

```

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║     ██╗  ██╗██╗  ██╗       █████╗ ██████╗ ███████╗██╗  ██╗                 ║
║     ██║  ██║██║ ██╔╝      ██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝                 ║
║     ███████║█████╔╝       ███████║██████╔╝█████╗   ╚███╔╝                  ║
║     ██╔══██║██╔═██╗       ██╔══██║██╔═══╝ ██╔══╝   ██╔██╗                  ║
║     ██║  ██║██║  ██╗      ██║  ██║██║     ███████╗██╔╝ ██╗                 ║
║     ╚═╝  ╚═╝╚═╝  ╚═╝      ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝                 ║
║                                                                              ║
║                         HK-APEX MASTER FRAMEWORK                             ║
║                              V E R S I O N   1 . 0                           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

```

**Military-Grade Nmap Automation Suite | Offensive Security | Zero-Day Research**

</div>

---

## EDUCATIONAL PURPOSE DISCLAIMER

```

╔══════════════════════════════════════════════════════════════════════════════╗
║                         EDUCATIONAL PURPOSE ONLY                             ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  This software is created STRICTLY for educational purposes.                 ║
║                                                                              ║
║  📚 EDUCATIONAL PURPOSES                                                     ║
║  🔬 SECURITY RESEARCH                                                        ║
║  🎓 LEARNING ETHICAL HACKING                                                 ║
║  🏫 ACADEMIC STUDY                                                           ║
║  📖 UNDERSTANDING NETWORK SECURITY                                           ║
║                                                                              ║
║  This tool helps students and researchers understand:                         ║
║                                                                              ║
║  • How network scanning works                                                ║
║  • How firewalls and IDS can be bypassed                                     ║
║  • How anonymity tools like TOR protect privacy                              ║
║  • How vulnerabilities are discovered                                        ║
║                                                                              ║
║  ❌ THIS TOOL IS NOT FOR ILLEGAL ACTIVITIES                                  ║
║  ❌ DO NOT USE AGAINST SYSTEMS YOU DO NOT OWN                                ║
║  ❌ DO NOT USE WITHOUT WRITTEN PERMISSION                                    ║
║                                                                              ║
║  The developer is NOT responsible for any misuse of this software.           ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

```

---

## Table of Contents

1. [Overview](#overview)
2. [What is HK-APEX](#what-is-hk-apex)
3. [Features](#features)
4. [Step-by-Step Installation](#step-by-step-installation)
5. [Step-by-Step TOR and Proxychains Setup](#step-by-step-tor-and-proxychains-setup)
6. [How to Use](#how-to-use)
7. [All Commands and Modes](#all-commands-and-modes)
8. [Output and Results](#output-and-results)
9. [How It Works](#how-it-works)
10. [Frequently Asked Questions](#frequently-asked-questions)
11. [Legal Disclaimer](#legal-disclaimer)
12. [Author](#author)

---

## Overview

HK-APEX (Advanced Penetration and Exploitation Framework) is a military-grade Nmap automation suite designed for educational purposes, security research, and authorized penetration testing.

### What You Will Learn

| Topic | What HK-APEX Teaches You |
|-------|--------------------------|
| Network Scanning | Eleven different port scanning techniques |
| Firewall Evasion | Ten methods to bypass IDS and WAF |
| OS Fingerprinting | How to identify operating systems remotely |
| Vulnerability Assessment | How to find and document CVE vulnerabilities |
| Anonymity | How TOR and Proxychains work together |
| Anti-Forensics | How to avoid leaving digital traces |

---

## What is HK-APEX

HK-APEX is a Bash-based automation wrapper around Nmap. It transforms a standard port scanner into a complete offensive security learning framework.

### The Main Script File

The main script file is called `HK-APEX.sh`

This single file contains fifty-eight automated scanning modules and all the Ghost Protocol features.

### Core Components

```

HK-APEX.sh
├── Discovery Engine
├── Scanning Engine (58 techniques)
├── Ghost Protocol (evasion)
├── Anonymity Layer (TOR + Proxychains)
├── Live Output (colored terminal)
├── Reporting (CVE extraction)
└── Cleanup (anti-forensics)

```

---

## Features

### Ghost Protocol Features

| Feature | Purpose |
|---------|---------|
| Live Colored Output | View scan results in real-time with color coding |
| Anti-Forensics | Prevent the script from leaving traces |
| Encrypted Payloads | Commands are obfuscated using Base64 |
| Process Name Spoofing | Script disguises itself as a system process |
| Cover Traffic | Generates legitimate traffic to blend with scans |
| Self-Destruct Timer | Automatically deletes all evidence after sixty seconds |

### Anonymity Features

| Feature | Purpose |
|---------|---------|
| TOR Integration | Route all traffic through the TOR network |
| Proxychains Support | Dual-layer proxy chaining |
| IP Rotation | Automatically request new TOR circuits |
| DNS over HTTPS | Encrypted DNS queries through Cloudflare |
| MAC Changer | Randomize MAC address before scanning |
| VPN Kill-Switch | Block all traffic if TOR disconnects |

### Scanning Features (58 Modules)

| Phase | Modules | Techniques Covered |
|-------|---------|-------------------|
| Phase 0 | 1 | Target Discovery |
| Phase 1 | 11 | SYN, Connect, UDP, Null, FIN, Xmas, ACK, Window, Maimon, IP Protocol, SCTP |
| Phase 2 | 10 | Decoy, Fragmentation, MTU, Data Length, Source Port, MAC Spoof, Bad Checksum, TTL |
| Phase 3 | 4 | Version Detection, OS Detection, Aggressive Scan, Traceroute |
| Phase 4 | 8 | Vulnerability, Exploit, Authentication, Brute Force, Malware, Safe, Discovery |
| Phase 5 | 11 | HTTP, HTTPS, SMB, SSH, FTP, SNMP, DNS Enumeration |
| Phase 6 | 7 | T0 through T5 Timing Templates, Rate Control |
| Phase 7 | 2 | IPv6 Basic Scan, IPv6 Discovery |
| Phase 8 | 5 | Deep Fragmentation, Extreme Decoys, Ultimate Stealth, Proxy Ultimate |

---

## Step-by-Step Installation

Follow these steps in order. Type each command and press Enter.

---

### Step 1: Update System Package List

```bash
sudo apt update
```

---

Step 2: Upgrade Installed Packages

```bash
sudo apt upgrade -y
```

---

Step 3: Install Nmap

```bash
sudo apt install -y nmap
```

---

Step 4: Install DNS Utilities

```bash
sudo apt install -y dnsutils
```

---

Step 5: Install Expect

```bash
sudo apt install -y expect
```

---

Step 6: Install Curl

```bash
sudo apt install -y curl
```

---

Step 7: Install Git

```bash
sudo apt install -y git
```

---

Step 8: Clone the Repository

```bash
git clone https://github.com/FahadWaheedHk/HK-APEX.git
```

---

Step 9: Navigate into Directory

```bash
cd HK-APEX
```

---

Step 10: Make Script Executable

```bash
chmod +x HK-APEX.sh
```

---

Step 11: Verify Installation

```bash
./HK-APEX.sh --help
```

---

Step-by-Step TOR and Proxychains Setup

What is TOR

TOR (The Onion Router) routes your internet traffic through a worldwide network of volunteer servers, hiding your real IP address.

What is Proxychains

Proxychains forces any program's network traffic through a proxy server or chain of proxy servers.

---

Step 12: Install TOR

```bash
sudo apt update
```

```bash
sudo apt install -y tor
```

---

Step 13: Start TOR Service

```bash
sudo systemctl start tor
```

---

Step 14: Enable TOR Auto-Start

```bash
sudo systemctl enable tor
```

---

Step 15: Check TOR Status

```bash
sudo systemctl status tor
```

---

Step 16: Verify TOR is Working

```bash
torsocks curl ifconfig.me
```

---

Step 17: Install Proxychains

```bash
sudo apt update
```

```bash
sudo apt install -y proxychains4
```

---

Step 18: Configure Proxychains

```bash
sudo nano /etc/proxychains4.conf
```

Add this line at the bottom:

```
socks5 127.0.0.1 9050
```

Save: Ctrl+X then Y then Enter

---

Step 19: Verify Proxychains Configuration

```bash
cat /etc/proxychains4.conf | grep socks5
```

---

Step 20: Test Proxychains with TOR

```bash
proxychains4 curl ifconfig.me
```

---

Step 21: Configure TOR Control Port

```bash
sudo nano /etc/tor/torrc
```

Uncomment these lines (remove #):

```
ControlPort 9051
CookieAuthentication 1
```

Save: Ctrl+X then Y then Enter

---

Step 22: Restart TOR

```bash
sudo systemctl restart tor
```

---

Step 23: Verify Control Port

```bash
echo -e "authenticate \"\"\nsignal newnym\nquit" | nc 127.0.0.1 9051
```

---

Step 24: Install MAC Changer

```bash
sudo apt update
```

```bash
sudo apt install -y macchanger
```

---

Step 25: Verify MAC Changer

```bash
macchanger --version
```

---

How to Use

Basic command structure:

```bash
sudo ./HK-APEX.sh <target> [mode]
```

---

Step 26: Basic Scan

```bash
sudo ./HK-APEX.sh scanme.nmap.org
```

---

Step 27: Fast Scan

```bash
sudo ./HK-APEX.sh scanme.nmap.org --fast
```

---

Step 28: Stealth Scan

```bash
sudo ./HK-APEX.sh scanme.nmap.org --stealth
```

---

Step 29: Full Audit Scan

```bash
sudo ./HK-APEX.sh scanme.nmap.org --full
```

---

Step 30: Ghost Protocol Scan

```bash
sudo ./HK-APEX.sh scanme.nmap.org --ghost
```

---

Step 31: Proxy Mode Scan

```bash
sudo ./HK-APEX.sh scanme.nmap.org --proxy
```

---

Step 32: Combined Mode Scan

```bash
sudo ./HK-APEX.sh scanme.nmap.org --full --proxy
```

---

Step 33: View Results

```bash
cd HK-APEX_Scan_*/
```

```bash
cat 00_MASTER_REPORT.txt
```

```bash
cat 00_CVE_LIST.txt
```

---

All Commands and Modes

Mode Command Ports
Default sudo ./HK-APEX.sh target Top 1000
Fast sudo ./HK-APEX.sh target --fast Top 100
Stealth sudo ./HK-APEX.sh target --stealth Top 1000
Full sudo ./HK-APEX.sh target --full All 65535
Ghost sudo ./HK-APEX.sh target --ghost All 65535
Proxy sudo ./HK-APEX.sh target --proxy All 65535

---

Output and Results

After each scan, a new folder is created:

```
HK-APEX_Scan_YYYYMMDD_HHMMSS/
├── 00_MASTER_REPORT.txt
├── 00_VULNERABILITIES_FOUND.txt
├── 00_CVE_LIST.txt
├── 00_discovery.grep
├── 00_BRAIN_DISCOVERY.txt
├── 01_SYN_Stealth.txt
├── ( ... 58 files total ... )
└── 58_Proxy_Ultimate.txt
```

---

How It Works

```
User executes: sudo ./HK-APEX.sh target.com --ghost
                    │
Script checks root and dependencies
                    │
Target resolved to IP address
                    │
Discovery scan finds open ports
                    │
58 modules executed one by one
                    │
CVE identifiers extracted
                    │
Master report generated
                    │
Results displayed
                    │
Self-destruct countdown (Ghost/Proxy mode)
```

---

Frequently Asked Questions

Why is sudo required

Nmap requires root privileges for SYN scanning, packet fragmentation, and MAC spoofing.

How long does a full scan take

A full scan takes fifteen to forty-five minutes depending on network speed.

Can I use HK-APEX without TOR

Yes. Only --ghost and --proxy modes use TOR and Proxychains.

Is this legal to use

Legal uses include:

· Scanning your own systems
· Scanning with written permission
· Educational purposes
· CTF competitions

Illegal uses include:

· Scanning without permission
· Any illegal activity

TOR is not working

```bash
sudo systemctl start tor
sudo systemctl status tor
torsocks curl ifconfig.me
```

Proxychains timeout errors

```bash
sudo nano /etc/proxychains4.conf
```

Ensure this line exists: socks5 127.0.0.1 9050

"unbuffer: command not found"

```bash
sudo apt install -y expect
```

---

Legal Disclaimer

```
╔══════════════════════════════════════════════════════════════════════════════╗
║                            LEGAL DISCLAIMER                                  ║
╠══════════════════════════════════════════════════════════════════════════════╣
║                                                                              ║
║  HK-APEX is created for EDUCATIONAL PURPOSES ONLY.                          ║
║                                                                              ║
║  ALLOWED USE:                                                               ║
║  - Educational learning and academic study                                  ║
║  - Security research in controlled environments                             ║
║  - Testing systems that you personally own                                  ║
║  - Capture The Flag (CTF) competitions                                      ║
║  - Authorized penetration testing with written permission                   ║
║                                                                              ║
║  PROHIBITED USE:                                                            ║
║  - Unauthorized scanning of third-party systems                             ║
║  - Any illegal activity                                                     ║
║  - Use without written permission                                           ║
║                                                                              ║
║  The developer assumes NO liability for misuse of this software.            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝
```

---

Author

Fahad Waheed HK

· GitHub: https://github.com/FahadWaheedHk

---

<div align="center">HK-APEX - Learn Network Security. Stay Ethical.

</div>
```---

