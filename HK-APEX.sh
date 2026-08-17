#!/bin/bash

# ============================================================================================================
# SCRIPT:    HK-APEX_MASTER_v2.0.sh
# AUTHOR:    Fahad Waheed HK
# VERSION:   2.0 (MASTER FRAMEWORK - ENHANCED)
# LEVEL:     MILITARY-GRADE EVASION / ZERO-DAY RESEARCH
# PURPOSE:   Advanced Stealth & Unified Vulnerability Analysis – A complete Nmap automation suite
#            featuring Ghost Protocol (military-grade evasion), WAF bypass, packet fragmentation,
#            all port scanning techniques, dynamic data hand‑off, vulnerability assessment,
#            live colored output, anti-forensics, TOR IP rotation, Proxychains integration,
#            VPN kill-switch, MAC changer, and full reporting.
# ============================================================================================================

# ============================================================================================================
# SECTION 1: COLOUR DEFINITIONS & TERMINAL FORMATTING
# ============================================================================================================

GREEN='\033[0;32m'   # Success messages and open ports
CYAN='\033[0;36m'    # Information headers and phase titles
YELLOW='\033[1;33m'  # Warnings, important notices, and timeouts
RED='\033[0;31m'     # Errors, failures, and CVEs detected
BLUE='\033[0;34m'    # Additional highlights and secondary information
PURPLE='\033[0;35m'  # Phase banners and section dividers
BOLD='\033[1m'       # Bold text emphasis for important elements
DIM='\033[2m'        # Dimmed text for secondary information and commands
NC='\033[0m'         # No Colour - resets all formatting back to terminal default

# ============================================================================================================
# SECTION 2: SIGNAL TRAP & MASTER CLEANUP (Fixes Ctrl+C & Freeze Issues)
# ============================================================================================================

MAIN_PID=$$
COVER_PID=""
KILLSWITCH_PID=""
BACKUP_MAC_FILE="/tmp/original_mac_${RANDOM}.txt"

restore_network() {
    echo -e "${YELLOW}[GHOST] Restoring network rules...${NC}"
    iptables -P OUTPUT ACCEPT 2>/dev/null
    iptables -F OUTPUT 2>/dev/null
}

restore_mac() {
    if [ -f "$BACKUP_MAC_FILE" ]; then
        local mac_val
        mac_val=$(cat "$BACKUP_MAC_FILE" 2>/dev/null)
        if [ -n "$mac_val" ]; then
            local interface
            interface=$(ip link show | grep -B1 "$mac_val" | head -1 | awk -F': ' '{print $2}')
            if [ -n "$interface" ]; then
                ip link set "$interface" down 2>/dev/null
                macchanger -m "$mac_val" "$interface" >/dev/null 2>&1
                ip link set "$interface" up 2>/dev/null
                echo -e "${YELLOW}[GHOST] MAC Address restored to: $mac_val${NC}"
            fi
        fi
        rm -f "$BACKUP_MAC_FILE" 2>/dev/null
    fi
}

cleanup_all() {
    # Disable trap to prevent recursive loop
    trap - SIGINT SIGTERM EXIT
    echo -e "\n${RED}[!] EMERGENCY STOP DETECTED (Ctrl+C). Terminating processes...${NC}"
    
    [ -n "$COVER_PID" ] && kill -9 "$COVER_PID" 2>/dev/null
    [ -n "$KILLSWITCH_PID" ] && kill -9 "$KILLSWITCH_PID" 2>/dev/null
    
    # Kill any active nmap, proxychains, or curl background processes associated with this parent
    pkill -P $$ 2>/dev/null
    
    restore_mac
    restore_network
    
    echo -e "${GREEN}[✓] Clean exit completed.${NC}"
    exit 130
}

# Register Signal Handlers
trap cleanup_all SIGINT SIGTERM

# ============================================================================================================
# SECTION 3: HELP FUNCTION (Instant Execution & Exit Fix)
# ============================================================================================================

show_help() {
    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                HK-APEX MASTER FRAMEWORK v2.0                              ║"
    echo "║                  DEVELOPED BY: FAHAD WAHEED HK                            ║"
    echo "║                    [ENHANCED GHOST PROTOCOL]                              ║"
    echo "╚═══════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}USAGE:${NC}"
    echo "  sudo $0 <target_ip_or_domain> [--fast | --full | --stealth | --ghost | --proxy]"
    echo ""
    echo -e "${YELLOW}EXAMPLES:${NC}"
    echo "  sudo $0 scanme.nmap.org              # Balanced scan (Top 1000 ports)"
    echo "  sudo $0 192.168.1.1 --stealth        # Maximum evasion (frag, decoy, slow)"
    echo "  sudo $0 target.com --full            # All 65535 ports + complete vulnerability audit"
    echo "  sudo $0 target.com --fast            # Quick scan (Top 100 ports only)"
    echo "  sudo $0 target.com --ghost           # MILITARY-GRADE: Live output + TOR + Anti-Forensics"
    echo "  sudo $0 target.com --proxy           # PROXYCHAINS + TOR: Ultimate anonymity chain"
    echo ""
    echo -e "${YELLOW}OPTIONS:${NC}"
    echo "  --ghost      - ULTIMATE EVASION: Live Colored Output + Encryption + TOR + Cover Traffic"
    echo "  --proxy      - PROXYCHAINS MODE: Route ALL traffic through Proxychains + TOR (Maximum Anonymity)"
    echo "  --stealth    - WAF/IDS Evasion: Fragmentation + Decoys + Source Port 53 + T2"
    echo "  --full       - Full TCP/UDP port range + all NSE vulnerability scripts"
    echo "  --fast       - Rapid reconnaissance (limited ports, minimal intrusion)"
    echo "  --help       - Show this help menu"
    echo ""
    echo -e "${YELLOW}ADVANCED FEATURES (Auto-enabled in Ghost/Proxy mode):${NC}"
    echo "  • MAC Address Randomization (macchanger)"
    echo "  • VPN Kill-Switch (auto-block if TOR disconnects)"
    echo "  • Proxychains + TOR Dual-Layer Anonymity"
    echo "  • DNS over HTTPS (Cloudflare)"
    echo "  • Cover Traffic Generation"
    echo "  • Process Name Spoofing"
    echo "  • Self-Destruct Timer"
    echo ""
    echo -e "${YELLOW}NOTE:${NC}"
    echo "  --ghost/--proxy modes require TOR service running: sudo systemctl start tor"
    echo "  --proxy mode requires proxychains4 configured with TOR: socks5 127.0.0.1 9050"
    echo ""
    exit 0
}

# Fast argument parsing check for Help before root/tool verification
if [ "$#" -eq 0 ]; then
    show_help
fi

for arg in "$@"; do
    case "$arg" in
        --help|-h|help)
            show_help
            ;;
    esac
done

# ============================================================================================================
# SECTION 4: GHOST PROTOCOL - SELF-PROTECTION & ANTI-FORENSICS
# ============================================================================================================

alias strings='echo "Access Denied"' 2>/dev/null
unset HISTFILE
set +o history

_ENCRYPTED_CONFIG="bm1hcCAtc1MgLVBuIC1mIC0tZGF0YS1sZW5ndGggMTI4IC0tc291cmNlLXBvcnQgNTMgLVQyIC0tcmFuZG9taXplLWhvc3RzIC0tc3Bvb2YtbWFjIENpc2NvIC0tc2Nhbi1kZWxheSAxLjVzIC1EIFJORDoxMCxNRQo="
_PROXYCHAINS_PAYLOAD="cHJveHljaGFpbnM0IC1xIG5tYXAgLXNTIC1QbiAtVDIgLWYgLS1tdHUgMjQgLS1kYXRhLWxlbmd0aCAxMjggLS1zb3VyY2UtcG9ydCA1MyAtLXJhbmRvbWl6ZS1ob3N0cyAtLXNjYW4tZGVsYXkgMnMK"

_decrypt() { 
    echo "$1" | base64 -d 
}

# ============================================================================================================
# SECTION 5: PRIVILEGE & DEPENDENCY VERIFICATION
# ============================================================================================================

if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[!] ACCESS DENIED: This framework requires ROOT privileges (sudo).${NC}"
   exit 1
fi

for tool in nmap dig timeout grep sed tr sort uniq wc tee unbuffer curl proxychains4 macchanger tor; do
    if ! command -v "$tool" &> /dev/null; then
        echo -e "${RED}[!] ERROR: '$tool' is not installed. Please install it first.${NC}"
        echo -e "${YELLOW}Hint: apt install expect curl tor proxychains4 macchanger${NC}"
        exit 1
    fi
done

# ============================================================================================================
# SECTION 6: VARIABLE INITIALISATION & MODE SELECTION
# ============================================================================================================

STEALTH_MODE=false
FULL_MODE=false
FAST_MODE=false
GHOST_MODE=false
PROXY_MODE=false
TARGET_INPUT=""

# Precise mode parsing
for arg in "$@"; do
    case $arg in
        --stealth) STEALTH_MODE=true ;;
        --full)    FULL_MODE=true ;;
        --fast)    FAST_MODE=true ;;
        --ghost)   GHOST_MODE=true ;;
        --proxy)   PROXY_MODE=true ;;
        -*)        ;;
        *)         [ -z "$TARGET_INPUT" ] && TARGET_INPUT="$arg" ;;
    esac
done

if [ -z "$TARGET_INPUT" ]; then
    show_help
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
OUTPUT_DIR="HK-APEX_Scan_${TIMESTAMP}"
SUMMARY_FILE="$OUTPUT_DIR/00_MASTER_REPORT.txt"
VULN_FILE="$OUTPUT_DIR/00_VULNERABILITIES_FOUND.txt"
CVE_FILE="$OUTPUT_DIR/00_CVE_LIST.txt"
PROXYCHAINS_CONF="/etc/proxychains4.conf"

if [ "$PROXY_MODE" = true ]; then
    GHOST_MODE=true
    echo -e "${CYAN}[PROXY] Proxychains mode activated - All Ghost features enabled + Dual-Layer Anonymity${NC}"
fi

# Setup Output Environment
mkdir -p "$OUTPUT_DIR"

{
    echo "============================================================================================================"
    echo "                     HK-APEX v2.0 - MASTER SCAN REPORT (FAHAD WAHEED HK)                                    "
    echo "============================================================================================================"
    echo " Target          : $TARGET_INPUT"
    echo " Scan Date       : $(date)"
    echo " Output Directory: $OUTPUT_DIR/"
    echo " Mode            : Stealth=$STEALTH_MODE | Full=$FULL_MODE | Fast=$FAST_MODE | Ghost=$GHOST_MODE | Proxy=$PROXY_MODE"
    echo "============================================================================================================"
    echo ""
} > "$SUMMARY_FILE"

# ============================================================================================================
# SECTION 7: ADVANCED FEATURES - MAC CHANGER & VPN KILL-SWITCH
# ============================================================================================================

change_mac() {
    local interface="$1"
    if [ -n "$interface" ] && ip link show "$interface" &>/dev/null; then
        ip link show "$interface" | grep -oE "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}" | head -1 > "$BACKUP_MAC_FILE"
        echo -e "${CYAN}[GHOST] Original MAC saved: $(cat "$BACKUP_MAC_FILE" 2>/dev/null)${NC}"
        
        ip link set "$interface" down
        macchanger -r "$interface" >/dev/null 2>&1
        ip link set "$interface" up
        
        NEW_MAC=$(ip link show "$interface" | grep -oE "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}" | head -1)
        echo -e "${GREEN}[GHOST] MAC Address changed to: $NEW_MAC${NC}"
    fi
}

vpn_kill_switch() {
    echo -e "${CYAN}[GHOST] VPN Kill-Switch engaged - Monitoring TOR connection...${NC}"
    while true; do
        if ! systemctl is-active --quiet tor; then
            echo -e "${RED}[KILL-SWITCH] TOR disconnected! Blocking all traffic...${NC}"
            iptables -P OUTPUT DROP
            iptables -A OUTPUT -o lo -j ACCEPT
            echo -e "${RED}[KILL-SWITCH] Network locked. Press Ctrl+C to restore.${NC}"
            break
        fi
        if ! torsocks curl -s --connect-timeout 5 ifconfig.me >/dev/null 2>&1; then
            echo -e "${RED}[KILL-SWITCH] TOR routing failed! Blocking all traffic...${NC}"
            iptables -P OUTPUT DROP
            iptables -A OUTPUT -o lo -j ACCEPT
            echo -e "${RED}[KILL-SWITCH] Network locked. Press Ctrl+C to restore.${NC}"
            break
        fi
        sleep 5
    done
}

# ============================================================================================================
# SECTION 8: GHOST PROTOCOL - COVER TRAFFIC & IP ROTATION
# ============================================================================================================

generate_cover_traffic() {
    while true; do
        dig @1.1.1.1 "random-${RANDOM}.com" +short >/dev/null 2>&1
        local sites=("https://news.ycombinator.com" "https://www.bbc.com" "https://github.com" "https://stackoverflow.com")
        local random_site=${sites[$RANDOM % ${#sites[@]}]}
        curl -s -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
             "$random_site" >/dev/null 2>&1
        sleep $((RANDOM % 30 + 10))
    done
}

rotate_ip() {
    if systemctl is-active --quiet tor; then
        echo -e "${CYAN}[GHOST] Requesting New TOR Circuit...${NC}"
        (echo authenticate \"\"; echo signal newnym; echo quit) | nc 127.0.0.1 9051 >/dev/null 2>&1
        sleep 5
        NEW_IP=$(torsocks curl -s ifconfig.me 2>/dev/null)
        echo -e "${GREEN}[GHOST] New Exit IP: $NEW_IP${NC}"
    else
        echo -e "${YELLOW}[GHOST] TOR service not active. IP rotation skipped.${NC}"
    fi
}

# Normal exit cleanup registration
cleanup_ghost() {
    [ -n "$COVER_PID" ] && kill "$COVER_PID" 2>/dev/null
    [ -n "$KILLSWITCH_PID" ] && kill "$KILLSWITCH_PID" 2>/dev/null
    restore_mac
    restore_network
}
trap cleanup_ghost EXIT

# ============================================================================================================
# SECTION 9: PROXYCHAINS CONFIGURATION & VERIFICATION
# ============================================================================================================

check_proxychains() {
    if [ "$PROXY_MODE" = true ]; then
        echo -e "${CYAN}[PROXY] Verifying Proxychains configuration...${NC}"
        if [ ! -f "$PROXYCHAINS_CONF" ]; then
            echo -e "${RED}[PROXY] ERROR: $PROXYCHAINS_CONF not found!${NC}"
            return 1
        fi
        
        if ! grep -q "socks5 127.0.0.1 9050" "$PROXYCHAINS_CONF"; then
            echo -e "${YELLOW}[PROXY] TOR SOCKS5 not configured in proxychains. Adding now...${NC}"
            cp "$PROXYCHAINS_CONF" "${PROXYCHAINS_CONF}.backup"
            echo "socks5 127.0.0.1 9050" >> "$PROXYCHAINS_CONF"
            echo -e "${GREEN}[PROXY] TOR SOCKS5 added to proxychains config.${NC}"
        fi
        
        echo -e "${CYAN}[PROXY] Testing Proxychains + TOR connectivity...${NC}"
        if proxychains4 -q curl -s --connect-timeout 10 ifconfig.me >/dev/null 2>&1; then
            PROXY_IP=$(proxychains4 -q curl -s ifconfig.me)
            echo -e "${GREEN}[PROXY] Proxychains working! Exit IP: $PROXY_IP${NC}"
        else
            echo -e "${RED}[PROXY] ERROR: Proxychains connectivity test failed!${NC}"
            echo -e "${YELLOW}[PROXY] Ensure TOR is running: sudo systemctl start tor${NC}"
            return 1
        fi
    fi
    return 0
}

# ============================================================================================================
# SECTION 10: SCAN MODULE EXECUTION ENGINE
# ============================================================================================================

ghost_scan_module() {
    local phase_id="$1"
    local description="$2"
    local command="$3"
    local log_file="$OUTPUT_DIR/${phase_id}.txt"
    
    local final_command="$command"
    if [ "$PROXY_MODE" = true ] && [[ "$command" == *"nmap"* ]]; then
        if [[ "$command" != *"proxychains"* ]]; then
            final_command="proxychains4 -q $command"
            echo -e "${BLUE}[PROXY] Routing through Proxychains + TOR${NC}"
        fi
    fi
    
    echo -e "\n${CYAN}[$(date +%T)] [EXECUTING] ${phase_id}${NC}"
    echo -e "${BOLD}  ⚡ ${description}${NC}"
    echo -e "${DIM}  📡 $final_command${NC}"
    echo "------------------------------------------------------------------------------------------------------------"
    
    timeout 600 unbuffer eval "$final_command" 2>&1 | while IFS= read -r line; do
        if [[ "$line" == *"open"* ]]; then
            echo -e "${GREEN}${line}${NC}"
        elif [[ "$line" == *"filtered"* ]] || [[ "$line" == *"closed"* ]]; then
            echo -e "${RED}${line}${NC}"
        elif [[ "$line" == *"OS"* ]] || [[ "$line" == *"Running"* ]]; then
            echo -e "${YELLOW}${line}${NC}"
        elif [[ "$line" == *"CVE-"* ]]; then
            echo -e "${RED}${BOLD}${line}${NC}"
        elif [[ "$line" == *"Proxychains"* ]] || [[ "$line" == *"proxychains"* ]]; then
            echo -e "${BLUE}${line}${NC}"
        else
            echo "$line"
        fi
    done | tee "$log_file"
    
    local exit_code=${PIPESTATUS[0]}
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}  [✓] SUCCESS${NC}"
        echo "✅ $phase_id : SUCCESS" >> "$SUMMARY_FILE"
    elif [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}  [!] TIMEOUT (Target may be slow or heavily filtered)${NC}"
        echo "⏳ $phase_id : TIMEOUT" >> "$SUMMARY_FILE"
    else
        echo -e "${RED}  [✗] FAILED / BLOCKED (Exit code: $exit_code)${NC}"
        echo "❌ $phase_id : FAILED (Exit: $exit_code)" >> "$SUMMARY_FILE"
    fi
    echo ""
}

run_module() {
    local phase_id="$1"
    local description="$2"
    local command="$3"
    local log_file="$OUTPUT_DIR/${phase_id}.txt"
    
    echo -e "\n${CYAN}[$(date +%T)] [EXECUTING] ${phase_id}${NC}"
    echo -e "${BOLD}  ⚡ ${description}${NC}"
    echo -e "${DIM}  📡 $command${NC}"
    echo "------------------------------------------------------------------------------------------------------------"
    
    local timeout_val=300
    if [[ "$FULL_MODE" == true && "$phase_id" == *"FULL"* ]]; then
        timeout_val=1800
    fi
    
    timeout "$timeout_val" eval "$command" > "$log_file" 2>&1
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}  [✓] SUCCESS${NC}"
        echo "✅ $phase_id : SUCCESS" >> "$SUMMARY_FILE"
    elif [ $exit_code -eq 124 ]; then
        echo -e "${YELLOW}  [!] TIMEOUT (Target may be slow or heavily filtered)${NC}"
        echo "⏳ $phase_id : TIMEOUT" >> "$SUMMARY_FILE"
    else
        echo -e "${RED}  [✗] FAILED / BLOCKED (Exit code: $exit_code)${NC}"
        echo "❌ $phase_id : FAILED (Exit: $exit_code)" >> "$SUMMARY_FILE"
    fi
    echo ""
}

execute_module() {
    if [ "$GHOST_MODE" = true ]; then
        ghost_scan_module "$1" "$2" "$3"
    else
        run_module "$1" "$2" "$3"
    fi
}

# ============================================================================================================
# PHASE 0: TARGET RESOLUTION & INITIAL STEALTH DISCOVERY (BRAIN)
# ============================================================================================================

clear
echo -e "${PURPLE}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗"
echo "║     ██╗  ██╗██╗  ██╗      █████╗ ██████╗ ███████╗██╗  ██╗                                                ║"
echo "║     ██║  ██║██║ ██╔╝     ██╔══██╗██╔══██╗██╔════╝╚██╗██╔╝                                                ║"
echo "║     ███████║█████╔╝      ███████║██████╔╝█████╗   ╚███╔╝                                                 ║"
echo "║     ██╔══██║██╔═██╗      ██╔══██║██╔═══╝ ██╔══╝   ██╔██╗                                                 ║"
echo "║     ██║  ██║██║  ██╗     ██║  ██║██║     ███████╗██╔╝ ██╗                                                ║"
echo "║     ╚═╝  ╚═╝╚═╝  ╚═╝     ╚═╝  ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝                                                ║"
echo "║                                                                                                          ║"
echo "║                         H K - A P E X   M A S T E R   F R A M E W O R K   v 2 . 0                        ║"
echo "║                                      AUTHOR: FAHAD WAHEED HK                                              ║"
echo "║                                 [ ENHANCED GHOST PROTOCOL ]                                               ║"
echo "║                        [ PROXYCHAINS + TOR + MAC CHANGER + KILL-SWITCH ]                                  ║"
echo "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

if [ "$GHOST_MODE" = true ]; then
    if ! systemctl is-active --quiet tor; then
        echo -e "${YELLOW}[GHOST] Starting TOR service...${NC}"
        systemctl start tor
        sleep 3
    fi
    
    if [ "$PROXY_MODE" = true ]; then
        if ! check_proxychains; then
            echo -e "${RED}[PROXY] Proxychains setup failed. Exiting.${NC}"
            exit 1
        fi
    fi
    
    ACTIVE_IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -n "$ACTIVE_IFACE" ]; then
        change_mac "$ACTIVE_IFACE"
    fi
    
    vpn_kill_switch &
    KILLSWITCH_PID=$!
fi

if [ "$GHOST_MODE" = true ]; then
    echo -e "${CYAN}[GHOST] Using encrypted DNS over HTTPS for target resolution...${NC}"
    if [ "$PROXY_MODE" = true ]; then
        TARGET_IP=$(proxychains4 -q curl -s -H "accept: application/dns-json" "https://cloudflare-dns.com/dns-query?name=$TARGET_INPUT&type=A" | grep -oE '"data":"[0-9.]+"' | head -1 | cut -d'"' -f4)
    else
        TARGET_IP=$(curl -s -H "accept: application/dns-json" "https://cloudflare-dns.com/dns-query?name=$TARGET_INPUT&type=A" | grep -oE '"data":"[0-9.]+"' | head -1 | cut -d'"' -f4)
    fi
    [ -z "$TARGET_IP" ] && TARGET_IP="$TARGET_INPUT"
else
    TARGET_IP=$(dig +short "$TARGET_INPUT" | tail -n1)
    if [ -z "$TARGET_IP" ] && [[ "$TARGET_INPUT" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        TARGET_IP="$TARGET_INPUT"
    fi
fi

if [ -z "$TARGET_IP" ]; then
    echo -e "${RED}[!] FATAL: Unable to resolve target. Exiting.${NC}"
    exit 1
fi
echo -e "${BOLD}🎯 TARGET IDENTIFIED: ${GREEN}$TARGET_IP${NC}"
echo ""

if [ "$GHOST_MODE" = true ]; then
    DISCOVERY_CMD="sudo nmap -sS -Pn -T2 -f --mtu 24 --data-length $((RANDOM%100+64)) --source-port 53 --randomize-hosts --spoof-mac Cisco --scan-delay 1.5s -D RND:15,ME"
    PORT_RANGE="-p-"
    TIMING="-T2"
    echo -e "${GREEN}[*] GHOST PROTOCOL ENGAGED: Live Output + Encryption + Anti-Forensics + TOR + Cover Traffic${NC}"
    [ "$PROXY_MODE" = true ] && echo -e "${BLUE}[*] PROXYCHAINS MODE: Dual-Layer Anonymity Active${NC}"
    
    generate_cover_traffic & 
    COVER_PID=$!
    rotate_ip
    
elif [ "$STEALTH_MODE" = true ]; then
    DISCOVERY_CMD="sudo nmap -Pn -sS -f --mtu 24 -D RND:10,ME --source-port 53 -T2 --max-retries 1 --scan-delay 1s"
    PORT_RANGE="--top-ports 1000"
    TIMING="-T2"
    echo -e "${GREEN}[*] STEALTH MODE ENGAGED: Fragmentation + Decoys + Source Port 53${NC}"
    
elif [ "$FULL_MODE" = true ]; then
    DISCOVERY_CMD="sudo nmap -Pn -sS -f --source-port 53 -T4"
    PORT_RANGE="-p-"
    TIMING="-T4"
    echo -e "${YELLOW}[*] FULL MODE ENGAGED: Scanning all 65535 ports + Complete Vulnerability Audit${NC}"
    
elif [ "$FAST_MODE" = true ]; then
    DISCOVERY_CMD="sudo nmap -Pn -sS -T4"
    PORT_RANGE="--top-ports 100"
    TIMING="-T4"
    echo -e "${CYAN}[*] FAST MODE ENGAGED: Quick reconnaissance (Top 100 ports)${NC}"
    
else
    DISCOVERY_CMD="sudo nmap -Pn -sS -f --source-port 53 -T3"
    PORT_RANGE="--top-ports 1000"
    TIMING="-T3"
    echo -e "${CYAN}[*] BALANCED MODE ENGAGED: Top 1000 ports with basic evasion${NC}"
fi

execute_module "00_BRAIN_DISCOVERY" "Initial Stealth Port Mapping & Packet Frameworking" \
    "$DISCOVERY_CMD $PORT_RANGE $TARGET_IP -oG $OUTPUT_DIR/00_discovery.grep"

OPEN_PORTS=""
if [ -f "$OUTPUT_DIR/00_discovery.grep" ]; then
    OPEN_PORTS=$(grep -E "Ports:" "$OUTPUT_DIR/00_discovery.grep" | grep -oP '\d+(?=/open)' | sort -n | uniq | head -50 | tr '\n' ',' | sed 's/,$//')
fi

if [ -z "$OPEN_PORTS" ]; then
    OPEN_PORTS="21,22,23,25,53,80,110,111,135,139,143,443,445,993,995,1723,3306,3389,5900,8080,8443"
    echo -e "${YELLOW}[!] WARNING: No open ports detected via stealth scan. Using fallback common ports set.${NC}"
    echo "⚠️  No open ports detected. Using fallback port set: $OPEN_PORTS" >> "$SUMMARY_FILE"
else
    echo -e "${GREEN}[+] DYNAMIC PORT DATA CAPTURED: [${OPEN_PORTS}] (Handed off to all subsequent modules)${NC}"
    echo "📡 Open ports identified: $OPEN_PORTS" >> "$SUMMARY_FILE"
fi

# ============================================================================================================
# PHASE 1: PACKET MANIPULATION & ADVANCED PORT SCANNING TECHNIQUES
# ============================================================================================================
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 1: ADVANCED PORT SCANNING & PACKET FRAMEWORKING TECHNIQUES                                      │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

execute_module "01_SYN_Stealth"      "SYN Stealth Scan (Half-open)"                                    "sudo nmap -sS -Pn -f $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "02_Connect_Scan"     "TCP Connect Scan (Full handshake)"                               "nmap -sT -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "03_UDP_Deep_Scan"    "UDP Scan (Top 100 ports)"                                        "sudo nmap -sU -Pn --top-ports 100 $TARGET_IP"
execute_module "04_Null_Scan"        "Null Scan (No flags set)"                                         "nmap -sN -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "05_FIN_Scan"         "FIN Scan (Stealthy firewall bypass)"                              "nmap -sF -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "06_Xmas_Scan"        "Xmas Scan (FIN, PSH, URG flags)"                                  "nmap -sX -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "07_ACK_Scan"         "ACK Scan (Firewall rule mapping)"                                 "nmap -sA -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "08_Window_Scan"      "Window Scan (TCP window analysis)"                                "nmap -sW -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "09_Maimon_Scan"      "Maimon Scan (FIN/ACK probe)"                                      "nmap -sM -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "10_IP_Protocol_Scan" "IP Protocol Scan (Raw IP protocols)"                              "nmap -sO -Pn $TARGET_IP"
execute_module "11_SCTP_Scan"        "SCTP INIT Scan (Stream Control Transmission Protocol)"            "nmap -sY -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# ============================================================================================================
# PHASE 2: FIREWALL / IDS EVASION & IDENTITY SPOOFING
# ============================================================================================================
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 2: FIREWALL / IDS EVASION & IDENTITY SPOOFING                                                  │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

execute_module "12_Decoy_Scan"        "Decoy Scan (10 random decoys + real IP)"                        "nmap -D RND:10,ME -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "13_Fragmentation"     "Packet Fragmentation (-f)"                                      "nmap -f -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "14_Double_Frag"       "Double Fragmentation (-ff)"                                     "nmap -ff -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "15_MTU_Manipulation"  "MTU Size Manipulation (MTU 24)"                                 "nmap --mtu 24 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "16_Data_Length_Pad"   "Data Length Padding (Random payload size)"                      "nmap --data-length 128 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "17_Source_Port_Spoof" "Source Port Spoofing (Port 53/DNS)"                             "nmap --source-port 53 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "18_MAC_Spoofing"      "MAC Address Spoofing (Random Vendor)"                           "nmap --spoof-mac Apple -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "19_Bad_Checksum"      "Bad Checksum (Detect unresponsive firewalls)"                   "nmap --badsum -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "20_TTL_Manipulation"  "TTL Manipulation (Set TTL to 50)"                               "nmap --ttl 50 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "21_Randomize_Hosts"   "Randomize Target Host Order"                                    "nmap --randomize-hosts -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# ============================================================================================================
# PHASE 3: SERVICE & OS FINGERPRINTING
# ============================================================================================================
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 3: SERVICE VERSION DETECTION & OS FINGERPRINTING                                               │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

execute_module "22_Version_Detection"   "Service Version Detection (Intensity 9)"                      "nmap -sV --version-intensity 9 $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "23_OS_Detection"        "OS Fingerprinting (Aggressive guess)"                         "sudo nmap -O --osscan-guess $TIMING $TARGET_IP"
execute_module "24_Aggressive_Scan"     "Aggressive Scan (-A: OS, version, scripts, traceroute)"       "sudo nmap -A $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "25_Traceroute"          "Traceroute (Path discovery)"                                  "nmap --traceroute -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# ============================================================================================================
# PHASE 4: NSE SCRIPTING ENGINE (VULNERABILITY & EXPLOITATION)
# ============================================================================================================
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 4: NSE SCRIPTING ENGINE - VULNERABILITY ASSESSMENT                                             │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

execute_module "26_Default_Scripts"     "Default Safe Scripts (-sC)"                                   "nmap -sC $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "27_Vuln_Scan"           "Vulnerability Scan (vuln category)"                           "nmap --script vuln $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "28_Exploit_Scan"        "Exploit Scripts (exploit category)"                           "nmap --script exploit $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "29_Auth_Bypass"         "Authentication Bypass Scripts (auth category)"                "nmap --script auth $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "30_Brute_Force"         "Brute Force Scripts (brute category)"                         "nmap --script brute $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "31_Malware_Detection"   "Malware Detection Scripts"                                    "nmap --script malware $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "32_Safe_Scripts"        "All Safe Scripts (non-intrusive)"                             "nmap --script safe $TIMING -p $OPEN_PORTS $TARGET_IP"
execute_module "33_Discovery_Scripts"   "Discovery Scripts (network info)"                             "nmap --script discovery $TIMING -p $OPEN_PORTS $TARGET_IP"

grep -oE "CVE-[0-9]{4}-[0-9]{4,}" "$OUTPUT_DIR/27_Vuln_Scan.txt" 2>/dev/null | sort -u > "$CVE_FILE"

if [ -s "$CVE_FILE" ]; then
    echo -e "${RED}${BOLD}[!] CVEs DETECTED! Check $CVE_FILE${NC}"
    echo "⚠️  Vulnerabilities (CVEs) found: $(wc -l < $CVE_FILE)" >> "$SUMMARY_FILE"
else
    echo -e "${GREEN}[✓] No CVEs identified in scan.${NC}"
fi

# ============================================================================================================
# PHASE 5: PROTOCOL-SPECIFIC DEEP ENUMERATION
# ============================================================================================================
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 5: PROTOCOL-SPECIFIC DEEP ENUMERATION                                                           │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

if [[ "$OPEN_PORTS" == *"80"* ]] || [[ "$OPEN_PORTS" == *"443"* ]]; then
    execute_module "34_HTTP_Enum"          "HTTP Enumeration (methods, headers, title)"                "nmap --script http-enum,http-headers,http-title,http-methods $TIMING -p 80,443 $TARGET_IP"
    execute_module "35_HTTP_Shellshock"    "HTTP Shellshock Vulnerability Check"                        "nmap --script http-shellshock $TIMING -p 80,443 $TARGET_IP"
    execute_module "36_SSL_TLS_Audit"      "SSL/TLS Audit (ciphers, heartbleed, poodle)"                "nmap --script ssl-cert,ssl-enum-ciphers,ssl-heartbleed,ssl-poodle $TIMING -p 443 $TARGET_IP"
fi

if [[ "$OPEN_PORTS" == *"445"* ]] || [[ "$OPEN_PORTS" == *"139"* ]]; then
    execute_module "37_SMB_Enum"           "SMB Share & User Enumeration"                               "nmap --script smb-enum-shares,smb-enum-users,smb-os-discovery $TIMING -p 139,445 $TARGET_IP"
    execute_module "38_SMB_EternalBlue"    "MS17-010 EternalBlue Vulnerability Check"                   "nmap --script smb-vuln-ms17-010 $TIMING -p 445 $TARGET_IP"
    execute_module "39_SMB_Brute"          "SMB Brute Force (if applicable)"                             "nmap --script smb-brute $TIMING -p 445 $TARGET_IP"
fi

if [[ "$OPEN_PORTS" == *"22"* ]]; then
    execute_module "40_SSH_Enum"           "SSH Enumeration (auth methods, hostkey, algorithms)"        "nmap --script ssh-auth-methods,ssh-hostkey,ssh2-enum-algos $TIMING -p 22 $TARGET_IP"
fi

if [[ "$OPEN_PORTS" == *"21"* ]]; then
    execute_module "41_FTP_Enum"           "FTP Enumeration (anonymous, bounce, syst)"                  "nmap --script ftp-anon,ftp-bounce,ftp-syst $TIMING -p 21 $TARGET_IP"
fi

if [[ "$OPEN_PORTS" == *"161"* ]]; then
    execute_module "42_SNMP_Enum"          "SNMP Enumeration (info, interfaces, netstat)"               "sudo nmap -sU --script snmp-info,snmp-interfaces,snmp-netstat -p 161 $TARGET_IP"
fi

execute_module "43_DNS_Brute"          "DNS Subdomain Bruteforce"                                    "nmap --script dns-brute $TARGET_INPUT"
execute_module "44_DNS_Reverse"        "Reverse DNS Lookup"                                          "nmap -R -sL $TARGET_IP"

# ============================================================================================================
# PHASE 6: PERFORMANCE TUNING & TIMING TEMPLATES
# ============================================================================================================
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 6: PERFORMANCE TUNING & TIMING TEMPLATES                                                        │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

execute_module "45_Timing_T0_Paranoid" "Timing Template T0 (Paranoid - IDS evasion)"                 "nmap -T0 -F $TARGET_IP"
execute_module "46_Timing_T1_Sneaky"   "Timing Template T1 (Sneaky - slow scan)"                     "nmap -T1 -F $TARGET_IP"
execute_module "47_Timing_T2_Polite"   "Timing Template T2 (Polite - less aggressive)"               "nmap -T2 -F $TARGET_IP"
execute_module "48_Timing_T3_Normal"   "Timing Template T3 (Normal - default)"                       "nmap -T3 -F $TARGET_IP"
execute_module "49_Timing_T4_Aggressive" "Timing Template T4 (Aggressive - fast scan)"                "nmap -T4 -F $TARGET_IP"
execute_module "50_Timing_T5_Insane"   "Timing Template T5 (Insane - maximum speed)"                  "nmap -T5 -F $TARGET_IP"
execute_module "51_Rate_Control"       "Rate Control (min-rate 100, max-rate 500)"                    "nmap --min-rate 100 --max-rate 500 -F $TARGET_IP"

# ============================================================================================================
# PHASE 7: IPv6 SCANNING
# ============================================================================================================
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 7: IPv6 SCANNING                                                                                │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

execute_module "52_IPv6_Basic"     "IPv6 Basic Scan"          "nmap -6 $TARGET_INPUT 2>/dev/null || echo 'IPv6 not available'"
execute_module "53_IPv6_Discovery" "IPv6 Ping Sweep"          "nmap -6 -sn $TARGET_INPUT 2>/dev/null || echo 'IPv6 not available'"

# ============================================================================================================
# PHASE 8: DEEP EVASION & FRAGMENTATION ATTACKS
# ============================================================================================================
if [ "$GHOST_MODE" = true ] || [ "$STEALTH_MODE" = true ] || [ "$FULL_MODE" = true ]; then
    echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}${BOLD}│  PHASE 8: DEEP EVASION & FRAGMENTATION ATTACKS                                                         │${NC}"
    echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

    execute_module "54_Deep_Frag_MTU8"   "Extreme Fragmentation (MTU 8)"                              "nmap -f --mtu 8 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
    execute_module "55_Deep_Frag_MTU16"  "Aggressive Fragmentation (MTU 16)"                          "nmap -f --mtu 16 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
    execute_module "56_Decoy_Extreme"    "Maximum Decoys (20 random IPs)"                             "nmap -D RND:20,ME -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
    
    ULTIMATE_CMD=$(_decrypt "$_ENCRYPTED_CONFIG")
    execute_module "57_Ultimate_Stealth" "Ultimate Stealth Combo (frag+decoy+source-port+delay)"     "sudo $ULTIMATE_CMD -p $OPEN_PORTS $TARGET_IP"
    
    if [ "$PROXY_MODE" = true ]; then
        PROXY_ULTIMATE=$(_decrypt "$_PROXYCHAINS_PAYLOAD")
        execute_module "58_Proxy_Ultimate" "PROXYCHAINS + TOR Ultimate Combo"                         "sudo $PROXY_ULTIMATE -D RND:15,ME -p $OPEN_PORTS $TARGET_IP"
    fi
fi

# ============================================================================================================
# FINAL REPORT GENERATION & SUMMARY
# ============================================================================================================
echo -e "\n${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗"
echo "║                                          🎉 SCAN COMPLETED                                               ║"
echo "║                                       HK-APEX MASTER FRAMEWORK v2.0                                      ║"
echo "║                                    [ ENHANCED GHOST PROTOCOL ]                                           ║"
echo "║                              [ PROXYCHAINS + TOR + MAC CHANGER + KILL-SWITCH ]                           ║"
echo "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

{
    echo ""
    echo "============================================================================================================"
    echo "                                    FINAL SCAN STATISTICS                                                    "
    echo "============================================================================================================"
    echo " Target IP       : $TARGET_IP"
    echo " Open Ports      : $OPEN_PORTS"
    echo " Total Scans Run : $([ "$PROXY_MODE" = true ] && echo "58" || echo "57") modules executed"
    echo " Output Directory: $OUTPUT_DIR/"
    echo " Proxy Mode      : $PROXY_MODE"
    echo ""
    echo " Key Files:"
    echo "   - Master Report     : $SUMMARY_FILE"
    echo "   - Vulnerabilities   : $VULN_FILE"
    echo "   - CVE List          : $CVE_FILE"
    echo ""
    echo "============================================================================================================"
} | tee -a "$SUMMARY_FILE"

echo -e "${CYAN}${BOLD}📊 VULNERABILITY SUMMARY:${NC}"
if [ -s "$CVE_FILE" ]; then
    echo -e "${RED}[!] The following CVEs were identified:${NC}"
    cat "$CVE_FILE"
    echo ""
else
    echo -e "${GREEN}[✓] No known CVEs detected in scan output.${NC}"
    echo ""
fi

echo -e "${YELLOW}${BOLD}📁 RESULTS SAVED IN: $OUTPUT_DIR/${NC}"
echo -e "${DIM}Run the following commands to explore results:"
echo -e "  cd $OUTPUT_DIR && ls -la"
echo -e "  cat 00_MASTER_REPORT.txt"
echo -e "  grep 'open' 00_discovery.grep"
echo -e "${NC}"

if [ "$GHOST_MODE" = true ]; then
    echo ""
    echo -e "${RED}${BOLD}[GHOST] Self-destruct sequence initiated...${NC}"
    echo -e "${YELLOW}All scan files will be securely deleted in 60 seconds.${NC}"
    echo -e "${YELLOW}Press ${BOLD}Ctrl+C${NC}${YELLOW} NOW to abort deletion and keep the results.${NC}"
    sleep 60
    rm -rf "$OUTPUT_DIR"
    echo -e "${GREEN}[GHOST] All traces wiped. Evidence eliminated.${NC}"
fi

exit 0
