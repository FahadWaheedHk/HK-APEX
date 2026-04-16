#!/bin/bash

# ============================================================================================================
# SCRIPT:    HK-APEX_MASTER_v1.0.sh
# AUTHOR:    Fahad Waheed HK
# VERSION:   1.0 (MASTER FRAMEWORK - ENHANCED)
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

# --- Colour Definitions for Clean Professional Output ---
# These ANSI escape codes are used to format terminal output for better readability.
# Each colour serves a specific purpose in the output hierarchy.
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
# SECTION 2: GHOST PROTOCOL - SELF-PROTECTION & ANTI-FORENSICS
# ============================================================================================================

# --- Anti-Debug & Anti-Forensics Measures ---
# These measures prevent the script from being easily analyzed by defensive tools.
# 'alias strings' overrides the strings command to return "Access Denied" instead of extracting text.
alias strings='echo "Access Denied"' 2>/dev/null
# 'unset HISTFILE' prevents the shell from saving command history to disk.
unset HISTFILE
# 'set +o history' disables command history tracking for the current session.
set +o history

# --- Encrypted Payload (Base64 Obfuscation Layer 1) ---
# Critical Nmap commands are stored encrypted and decoded only at runtime.
# This prevents static analysis tools from identifying the exact attack patterns.
# The decoded string is: "nmap -sS -Pn -f --data-length 128 --source-port 53 -T2 --randomize-hosts --spoof-mac Cisco --scan-delay 1.5s -D RND:10,ME"
_ENCRYPTED_CONFIG="bm1hcCAtc1MgLVBuIC1mIC0tZGF0YS1sZW5ndGggMTI4IC0tc291cmNlLXBvcnQgNTMgLVQyIC0tcmFuZG9taXplLWhvc3RzIC0tc3Bvb2YtbWFjIENpc2NvIC0tc2Nhbi1kZWxheSAxLjVzIC1EIFJORDoxMCxNRQo="

# Second encrypted payload for Proxychains + TOR combo
# Decoded: "proxychains4 -q nmap -sS -Pn -T2 -f --mtu 24 --data-length 128 --source-port 53 --randomize-hosts --scan-delay 2s"
_PROXYCHAINS_PAYLOAD="cHJveHljaGFpbnM0IC1xIG5tYXAgLXNTIC1QbiAtVDIgLWYgLS1tdHUgMjQgLS1kYXRhLWxlbmd0aCAxMjggLS1zb3VyY2UtcG9ydCA1MyAtLXJhbmRvbWl6ZS1ob3N0cyAtLXNjYW4tZGVsYXkgMnMK"

# Helper function to decode Base64 strings at runtime.
_decrypt() { 
    echo "$1" | base64 -d 
}

# ============================================================================================================
# SECTION 3: PRIVILEGE & DEPENDENCY VERIFICATION
# ============================================================================================================

# --- Root Check (Mandatory for raw packet manipulation) ---
# The script requires root privileges because Nmap needs them for SYN scans (-sS),
# packet fragmentation (-f), MAC spoofing, and other raw socket operations.
# Without root, these stealth features simply will not work.
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}[!] ACCESS DENIED: This framework requires ROOT privileges (sudo).${NC}"
   exit 1
fi

# --- Tool Dependency Verification ---
# We iterate through a list of essential tools and verify each one is installed.
# If any tool is missing, the script exits with a clear error message.
# 'unbuffer' is required for live colored output (from the 'expect' package).
for tool in nmap dig timeout grep sed tr sort uniq wc tee unbuffer curl proxychains4 macchanger tor; do
    if ! command -v "$tool" &> /dev/null; then
        echo -e "${RED}[!] ERROR: '$tool' is not installed. Please install it first.${NC}"
        echo -e "${YELLOW}Hint: apt install expect curl tor proxychains4 macchanger${NC}"
        exit 1
    fi
done

# ============================================================================================================
# SECTION 4: VARIABLE INITIALISATION
# ============================================================================================================

TARGET_INPUT="$1"                                    # The first command-line argument (IP address or domain name)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)                     # Unique timestamp used to organise scan results chronologically
OUTPUT_DIR="HK-APEX_Scan_${TIMESTAMP}"               # Base directory where all scan output files will be stored
SUMMARY_FILE="$OUTPUT_DIR/00_MASTER_REPORT.txt"      # Path to the master summary report file
VULN_FILE="$OUTPUT_DIR/00_VULNERABILITIES_FOUND.txt" # Path to the detailed vulnerabilities report
CVE_FILE="$OUTPUT_DIR/00_CVE_LIST.txt"               # Path to the list of extracted CVE identifiers
PROXYCHAINS_CONF="/etc/proxychains4.conf"            # Proxychains configuration file path
BACKUP_MAC_FILE="/tmp/original_mac_${RANDOM}.txt"    # Backup file for original MAC address

# --- Process Name Spoofing (Ghost Protocol) ---
# This renames the script process in memory to look like a legitimate system update daemon.
# When someone runs 'ps aux', they will see 'systemd-update-RANDOM' instead of this script's name.
exec -a "systemd-update-${RANDOM}" bash "$0" "$@" &
MAIN_PID=$!

# ============================================================================================================
# SECTION 5: HELP FUNCTION
# ============================================================================================================

# --- Help Function ---
# This function is triggered when the user runs the script with '--help' or without a target.
# It displays the complete usage syntax, available scanning modes, and practical examples.
show_help() {
    echo -e "${CYAN}${BOLD}"
    echo "╔═══════════════════════════════════════════════════════════════════════════╗"
    echo "║                HK-APEX MASTER FRAMEWORK v1.0                              ║"
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

# ============================================================================================================
# SECTION 6: ARGUMENT PARSING & MODE SELECTION
# ============================================================================================================

# --- Argument Parsing & Mode Selection ---
# We iterate over all command-line arguments to determine the scanning mode.
# Boolean flags are set based on which mode the user selected.
STEALTH_MODE=false   # Flag for stealth mode (WAF/IDS evasion focus)
FULL_MODE=false      # Flag for full audit mode (all ports + complete vulnerability scan)
FAST_MODE=false      # Flag for fast reconnaissance mode (minimal intrusion)
GHOST_MODE=false     # Flag for Ghost Protocol (military-grade evasion with live output)
PROXY_MODE=false     # Flag for Proxychains mode (maximum anonymity through proxy chains)

for arg in "$@"; do
    case $arg in
        --stealth) STEALTH_MODE=true ;;
        --full)    FULL_MODE=true ;;
        --fast)    FAST_MODE=true ;;
        --ghost)   GHOST_MODE=true ;;
        --proxy)   PROXY_MODE=true ;;
        --help)    show_help ;;
        *)         TARGET_INPUT="$1" ;;  # The first non-flag argument is treated as the target
    esac
    shift
done

# If no target was provided, we display the help menu and exit gracefully.
if [ -z "$TARGET_INPUT" ]; then
    show_help
fi

# --- Auto-enable Ghost features when Proxy mode is active ---
if [ "$PROXY_MODE" = true ]; then
    GHOST_MODE=true
    echo -e "${CYAN}[PROXY] Proxychains mode activated - All Ghost features enabled + Dual-Layer Anonymity${NC}"
fi

# ============================================================================================================
# SECTION 7: OUTPUT ENVIRONMENT SETUP
# ============================================================================================================

# --- Setup Output Environment ---
# We create a dedicated timestamped directory to store all scan results.
# This keeps multiple scans organised and prevents file overwrites.
mkdir -p "$OUTPUT_DIR"

# We initialise the master report file with a header containing scan metadata.
{
    echo "============================================================================================================"
    echo "                     HK-APEX v1.0 - MASTER SCAN REPORT (FAHAD WAHEED HK)                                    "
    echo "============================================================================================================"
    echo " Target          : $TARGET_INPUT"
    echo " Scan Date       : $(date)"
    echo " Output Directory: $OUTPUT_DIR/"
    echo " Mode            : Stealth=$STEALTH_MODE | Full=$FULL_MODE | Fast=$FAST_MODE | Ghost=$GHOST_MODE | Proxy=$PROXY_MODE"
    echo "============================================================================================================"
    echo ""
} > "$SUMMARY_FILE"

# ============================================================================================================
# SECTION 8: ADVANCED FEATURES - MAC CHANGER & VPN KILL-SWITCH
# ============================================================================================================

# --- MAC Address Randomization ---
# Changes the MAC address of the specified interface to a random vendor MAC.
# This prevents tracking based on hardware address on local networks.
# Original MAC is saved and restored on script exit.
change_mac() {
    local interface="$1"
    if [ -n "$interface" ] && ip link show "$interface" &>/dev/null; then
        # Save original MAC address
        ip link show "$interface" | grep -oE "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}" | head -1 > "$BACKUP_MAC_FILE"
        echo -e "${CYAN}[GHOST] Original MAC saved: $(cat $BACKUP_MAC_FILE)${NC}"
        
        # Bring interface down, change MAC, bring it back up
        ip link set "$interface" down
        macchanger -r "$interface" >/dev/null 2>&1
        ip link set "$interface" up
        
        NEW_MAC=$(ip link show "$interface" | grep -oE "([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}" | head -1)
        echo -e "${GREEN}[GHOST] MAC Address changed to: $NEW_MAC${NC}"
    fi
}

# --- Restore Original MAC Address ---
# Called on script exit to restore the original MAC address.
restore_mac() {
    if [ -f "$BACKUP_MAC_FILE" ]; then
        local interface=$(ip link show | grep -B1 "$(cat $BACKUP_MAC_FILE)" | head -1 | awk -F': ' '{print $2}')
        if [ -n "$interface" ]; then
            ip link set "$interface" down
            macchanger -m "$(cat $BACKUP_MAC_FILE)" "$interface" >/dev/null 2>&1
            ip link set "$interface" up
            echo -e "${YELLOW}[GHOST] MAC Address restored to: $(cat $BACKUP_MAC_FILE)${NC}"
        fi
        rm -f "$BACKUP_MAC_FILE"
    fi
}

# --- VPN Kill-Switch (TOR Connection Monitor) ---
# Continuously monitors TOR connection status. If TOR disconnects, it immediately
# blocks all non-TOR traffic using iptables to prevent IP leaks.
vpn_kill_switch() {
    echo -e "${CYAN}[GHOST] VPN Kill-Switch engaged - Monitoring TOR connection...${NC}"
    while true; do
        if ! systemctl is-active --quiet tor; then
            echo -e "${RED}[KILL-SWITCH] TOR disconnected! Blocking all traffic...${NC}"
            # Block all outgoing traffic except loopback
            iptables -P OUTPUT DROP
            iptables -A OUTPUT -o lo -j ACCEPT
            echo -e "${RED}[KILL-SWITCH] Network locked. Press Ctrl+C to restore.${NC}"
            break
        fi
        # Check if TOR is actually routing traffic
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

# --- Restore Network (Disable Kill-Switch) ---
restore_network() {
    echo -e "${YELLOW}[GHOST] Restoring network rules...${NC}"
    iptables -P OUTPUT ACCEPT 2>/dev/null
    iptables -F OUTPUT 2>/dev/null
}

# ============================================================================================================
# SECTION 9: GHOST PROTOCOL - COVER TRAFFIC & IP ROTATION
# ============================================================================================================

# --- Ghost Protocol: Cover Traffic Generator ---
# This function runs in the background during the scan to generate legitimate-looking traffic.
# The purpose is to blend malicious scan packets with normal browsing activity,
# making detection by network monitoring tools significantly harder.
# It makes random DNS queries and visits legitimate news websites with real browser User-Agents.
generate_cover_traffic() {
    while true; do
        # Generate random DNS queries to Cloudflare (simulates normal browsing)
        dig @1.1.1.1 "random-${RANDOM}.com" +short >/dev/null 2>&1
        # Make HTTP requests to various legitimate sites with real browser User-Agents
        local sites=("https://news.ycombinator.com" "https://www.bbc.com" "https://github.com" "https://stackoverflow.com")
        local random_site=${sites[$RANDOM % ${#sites[@]}]}
        curl -s -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
             "$random_site" >/dev/null 2>&1
        # Random delay between 10 and 40 seconds to look more human-like
        sleep $((RANDOM % 30 + 10))
    done
}

# --- Ghost Protocol: IP Rotation via TOR ---
# This function requests a new TOR circuit, effectively changing the exit node IP address.
# IP rotation makes attribution and tracking extremely difficult for defenders.
# It requires the TOR service to be running with ControlPort 9051 enabled.
rotate_ip() {
    if systemctl is-active --quiet tor; then
        echo -e "${CYAN}[GHOST] Requesting New TOR Circuit...${NC}"
        # Send NEWNYM signal to TOR control port to request circuit renewal
        (echo authenticate \"\"; echo signal newnym; echo quit) | nc 127.0.0.1 9051 >/dev/null 2>&1
        sleep 5  # Allow time for the new circuit to establish
        # Verify the new IP address using torsocks
        NEW_IP=$(torsocks curl -s ifconfig.me)
        echo -e "${GREEN}[GHOST] New Exit IP: $NEW_IP${NC}"
    else
        echo -e "${YELLOW}[GHOST] TOR service not active. IP rotation skipped.${NC}"
    fi
}

# --- Ghost Protocol: Trap Handler for Clean Exit ---
# This trap ensures that background processes and system modifications are properly
# reverted when the script exits, preventing resource leaks and leaving no traces.
cleanup_ghost() {
    echo -e "${YELLOW}[GHOST] Cleaning up background processes...${NC}"
    # Kill the cover traffic generator if it's still running
    kill $COVER_PID 2>/dev/null
    # Kill the VPN kill-switch monitor if running
    kill $KILLSWITCH_PID 2>/dev/null
    # Restore original MAC address
    restore_mac
    # Restore network iptables rules
    restore_network
    # Kill the main script process if needed
    kill $MAIN_PID 2>/dev/null
}
# Register the cleanup function to run on script exit
trap cleanup_ghost EXIT

# ============================================================================================================
# SECTION 10: PROXYCHAINS CONFIGURATION & VERIFICATION
# ============================================================================================================

# --- Proxychains Configuration Check ---
# Verifies that proxychains is properly configured to use TOR SOCKS5 proxy.
# If not configured, it offers to automatically configure it.
check_proxychains() {
    if [ "$PROXY_MODE" = true ]; then
        echo -e "${CYAN}[PROXY] Verifying Proxychains configuration...${NC}"
        
        # Check if proxychains config exists
        if [ ! -f "$PROXYCHAINS_CONF" ]; then
            echo -e "${RED}[PROXY] ERROR: $PROXYCHAINS_CONF not found!${NC}"
            return 1
        fi
        
        # Check if TOR SOCKS5 is configured in proxychains
        if ! grep -q "socks5 127.0.0.1 9050" "$PROXYCHAINS_CONF"; then
            echo -e "${YELLOW}[PROXY] TOR SOCKS5 not configured in proxychains. Adding now...${NC}"
            # Backup original config
            cp "$PROXYCHAINS_CONF" "${PROXYCHAINS_CONF}.backup"
            # Add TOR SOCKS5 configuration
            echo "socks5 127.0.0.1 9050" >> "$PROXYCHAINS_CONF"
            echo -e "${GREEN}[PROXY] TOR SOCKS5 added to proxychains config.${NC}"
        fi
        
        # Test proxychains connectivity
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
# SECTION 11: SCAN MODULE EXECUTION ENGINE
# ============================================================================================================

# --- Ghost Protocol: Advanced Scan Module with Live Colored Output ---
# This is the core execution engine for Ghost Mode. It differs from standard scanning
# by providing real-time colored output to the terminal while simultaneously logging to file.
# Nmap output is parsed line-by-line and colour-coded for quick visual analysis.
ghost_scan_module() {
    local phase_id="$1"      # Unique identifier for this scan phase
    local description="$2"   # Human-readable description of what this phase does
    local command="$3"       # The complete Nmap command to execute
    local log_file="$OUTPUT_DIR/${phase_id}.txt"  # Path to the output log file
    
    # If Proxy mode is active, wrap the command with proxychains
    local final_command="$command"
    if [ "$PROXY_MODE" = true ] && [[ "$command" == *"nmap"* ]]; then
        # Don't double-wrap if already has proxychains
        if [[ "$command" != *"proxychains"* ]]; then
            final_command="proxychains4 -q $command"
            echo -e "${BLUE}[PROXY] Routing through Proxychains + TOR${NC}"
        fi
    fi
    
    # Print a formatted header for this scan phase
    echo -e "\n${CYAN}[$(date +%T)] [EXECUTING] ${phase_id}${NC}"
    echo -e "${BOLD}  ⚡ ${description}${NC}"
    echo -e "${DIM}  📡 $final_command${NC}"
    echo "------------------------------------------------------------------------------------------------------------"
    
    # Execute the command with 'unbuffer' to preserve Nmap's colours, pipe through while loop
    # to apply additional colour highlighting based on content.
    # 'tee' simultaneously writes output to both terminal and log file.
    timeout 600 unbuffer eval "$final_command" 2>&1 | while IFS= read -r line; do
        # Apply custom colour highlighting to important Nmap output patterns
        if [[ "$line" == *"open"* ]]; then
            echo -e "${GREEN}${line}${NC}"          # Open ports appear in green
        elif [[ "$line" == *"filtered"* ]] || [[ "$line" == *"closed"* ]]; then
            echo -e "${RED}${line}${NC}"            # Filtered/closed ports appear in red
        elif [[ "$line" == *"OS"* ]] || [[ "$line" == *"Running"* ]]; then
            echo -e "${YELLOW}${line}${NC}"         # OS detection results appear in yellow
        elif [[ "$line" == *"CVE-"* ]]; then
            echo -e "${RED}${BOLD}${line}${NC}"     # CVE identifiers appear in bold red
        elif [[ "$line" == *"Proxychains"* ]] || [[ "$line" == *"proxychains"* ]]; then
            echo -e "${BLUE}${line}${NC}"           # Proxychains messages in blue
        else
            echo "$line"                            # Normal output remains unchanged
        fi
    done | tee "$log_file"  # Save everything to the log file
    
    # Capture the exit code from the piped command (PIPESTATUS[0] holds the first command's status)
    local exit_code=${PIPESTATUS[0]}
    
    # Record the result in the master summary report
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

# --- Standard Module (Used for non-Ghost modes) ---
# This is the standard execution engine used when Ghost Mode is not active.
# It runs commands without live output parsing and simply logs results to file.
run_module() {
    local phase_id="$1"
    local description="$2"
    local command="$3"
    local log_file="$OUTPUT_DIR/${phase_id}.txt"
    
    echo -e "\n${CYAN}[$(date +%T)] [EXECUTING] ${phase_id}${NC}"
    echo -e "${BOLD}  ⚡ ${description}${NC}"
    echo -e "${DIM}  📡 $command${NC}"
    echo "------------------------------------------------------------------------------------------------------------"
    
    # Set timeout value - longer for full port scans
    local timeout_val=300
    if [[ "$FULL_MODE" == true && "$phase_id" == *"FULL"* ]]; then
        timeout_val=1800  # 30 minutes for full TCP/UDP port scan
    fi
    
    # Execute with timeout and capture output to log file
    timeout "$timeout_val" eval "$command" > "$log_file" 2>&1
    local exit_code=$?
    
    # Record result in summary report
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

# --- Smart Module Dispatcher ---
# This wrapper function automatically selects between ghost_scan_module and run_module
# based on whether Ghost Mode is active. This keeps the main code clean and modular.
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
# Clear the terminal for a clean start and display the ASCII art banner.
clear
echo -e "${PURPLE}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗"
echo "║     ███████╗ █████╗ ██╗  ██╗ █████╗ ██████╗                                                              ║"
echo "║     ██╔════╝██╔══██╗██║  ██║██╔══██╗██╔══██╗                                                             ║"
echo "║     █████╗  ███████║███████║███████║██║  ██║                                                             ║"
echo "║     ██╔══╝  ██╔══██║██╔══██║██╔══██║██║  ██║                                                             ║"
echo "║     ██║     ██║  ██║██║  ██║██║  ██║██████╔╝                                                             ║"
echo "║     ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝                                                              ║"
echo "║                                                                                                          ║"
echo "║                         H K - A P E X   M A S T E R   F R A M E W O R K   v 1 . 0                        ║"
echo "║                                      AUTHOR: FAHAD WAHEED HK                                              ║"
echo "║                                 [ ENHANCED GHOST PROTOCOL ]                                               ║"
echo "║                        [ PROXYCHAINS + TOR + MAC CHANGER + KILL-SWITCH ]                                  ║"
echo "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# --- Pre-flight Checks for Ghost/Proxy Mode ---
if [ "$GHOST_MODE" = true ]; then
    # Start TOR if not running
    if ! systemctl is-active --quiet tor; then
        echo -e "${YELLOW}[GHOST] Starting TOR service...${NC}"
        systemctl start tor
        sleep 3
    fi
    
    # Verify Proxychains if in Proxy mode
    if [ "$PROXY_MODE" = true ]; then
        if ! check_proxychains; then
            echo -e "${RED}[PROXY] Proxychains setup failed. Exiting.${NC}"
            exit 1
        fi
    fi
    
    # Change MAC address (find active interface)
    ACTIVE_IFACE=$(ip route | grep default | awk '{print $5}' | head -1)
    if [ -n "$ACTIVE_IFACE" ]; then
        change_mac "$ACTIVE_IFACE"
    fi
    
    # Start VPN Kill-Switch in background
    vpn_kill_switch &
    KILLSWITCH_PID=$!
fi

# --- DNS Resolution with Enhanced Privacy ---
# In Ghost Mode, we use DNS over HTTPS (Cloudflare) to prevent DNS query logging by ISPs.
# In standard modes, we fall back to the traditional 'dig' command.
if [ "$GHOST_MODE" = true ]; then
    echo -e "${CYAN}[GHOST] Using encrypted DNS over HTTPS for target resolution...${NC}"
    # Query Cloudflare's DoH API and extract the A record (IPv4 address)
    if [ "$PROXY_MODE" = true ]; then
        TARGET_IP=$(proxychains4 -q curl -s -H "accept: application/dns-json" "https://cloudflare-dns.com/dns-query?name=$TARGET_INPUT&type=A" | grep -oE '"data":"[0-9.]+"' | head -1 | cut -d'"' -f4)
    else
        TARGET_IP=$(curl -s -H "accept: application/dns-json" "https://cloudflare-dns.com/dns-query?name=$TARGET_INPUT&type=A" | grep -oE '"data":"[0-9.]+"' | head -1 | cut -d'"' -f4)
    fi
    # If DoH fails, fall back to the original input
    [ -z "$TARGET_IP" ] && TARGET_IP="$TARGET_INPUT"
else
    # Standard DNS resolution using dig
    TARGET_IP=$(dig +short "$TARGET_INPUT" | tail -n1)
    # If dig returns empty, check if the input is already a valid IPv4 address
    if [ -z "$TARGET_IP" ] && [[ "$TARGET_INPUT" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        TARGET_IP="$TARGET_INPUT"
    fi
fi

# If resolution completely failed, exit with a fatal error
if [ -z "$TARGET_IP" ]; then
    echo -e "${RED}[!] FATAL: Unable to resolve target. Exiting.${NC}"
    exit 1
fi
echo -e "${BOLD}🎯 TARGET IDENTIFIED: ${GREEN}$TARGET_IP${NC}"
echo ""

# --- Determine Scan Base & Port Range based on Mode ---
# Based on the user-selected mode, we build the discovery command and set port ranges.
if [ "$GHOST_MODE" = true ]; then
    # Ghost Protocol: Ultimate stealth with dynamic data-length and maximum evasion
    # -sS: SYN stealth scan
    # -Pn: Skip host discovery (assume host is up)
    # -T2: Polite timing (slower, less detectable)
    # -f: Fragment packets
    # --mtu 24: Very small MTU forces maximum fragmentation
    # --data-length: Random payload size to avoid signature detection
    # --source-port 53: Appear as DNS traffic (often allowed through firewalls)
    # --randomize-hosts: Shuffle scan order
    # --spoof-mac Cisco: Fake MAC address for local network scans
    # --scan-delay 1.5s: Pause between probes
    # -D RND:15,ME: Use 15 random decoy IP addresses plus the real one
    DISCOVERY_CMD="sudo nmap -sS -Pn -T2 -f --mtu 24 --data-length $((RANDOM%100+64)) --source-port 53 --randomize-hosts --spoof-mac Cisco --scan-delay 1.5s -D RND:15,ME"
    PORT_RANGE="-p-"
    TIMING="-T2"
    echo -e "${GREEN}[*] GHOST PROTOCOL ENGAGED: Live Output + Encryption + Anti-Forensics + TOR + Cover Traffic${NC}"
    [ "$PROXY_MODE" = true ] && echo -e "${BLUE}[*] PROXYCHAINS MODE: Dual-Layer Anonymity Active${NC}"
    
    # Start the cover traffic generator in the background
    generate_cover_traffic & 
    COVER_PID=$!  # Save the process ID so we can kill it later
    
    # Rotate TOR IP to get a fresh identity before scanning begins
    rotate_ip
    
elif [ "$STEALTH_MODE" = true ]; then
    # Stealth Mode: Focused on WAF/IDS evasion with fragmentation and decoys
    DISCOVERY_CMD="sudo nmap -Pn -sS -f --mtu 24 -D RND:10,ME --source-port 53 -T2 --max-retries 1 --scan-delay 1s"
    PORT_RANGE="--top-ports 1000"
    TIMING="-T2"
    echo -e "${GREEN}[*] STEALTH MODE ENGAGED: Fragmentation + Decoys + Source Port 53${NC}"
    
elif [ "$FULL_MODE" = true ]; then
    # Full Mode: Complete audit of all 65535 ports plus vulnerability scripts
    DISCOVERY_CMD="sudo nmap -Pn -sS -f --source-port 53 -T4"
    PORT_RANGE="-p-"
    TIMING="-T4"
    echo -e "${YELLOW}[*] FULL MODE ENGAGED: Scanning all 65535 ports + Complete Vulnerability Audit${NC}"
    
elif [ "$FAST_MODE" = true ]; then
    # Fast Mode: Quick scan of only the top 100 most common ports
    DISCOVERY_CMD="sudo nmap -Pn -sS -T4"
    PORT_RANGE="--top-ports 100"
    TIMING="-T4"
    echo -e "${CYAN}[*] FAST MODE ENGAGED: Quick reconnaissance (Top 100 ports)${NC}"
    
else
    # Default Balanced Mode: Top 1000 ports with moderate evasion
    DISCOVERY_CMD="sudo nmap -Pn -sS -f --source-port 53 -T3"
    PORT_RANGE="--top-ports 1000"
    TIMING="-T3"
    echo -e "${CYAN}[*] BALANCED MODE ENGAGED: Top 1000 ports with basic evasion${NC}"
fi

# --- Initial Port Discovery (Grepable output for dynamic data hand-off) ---
# This scan generates a grepable output file (-oG) which we will parse to extract open ports.
# The list of open ports is then passed to all subsequent scan modules.
execute_module "00_BRAIN_DISCOVERY" "Initial Stealth Port Mapping & Packet Frameworking" \
    "$DISCOVERY_CMD $PORT_RANGE $TARGET_IP -oG $OUTPUT_DIR/00_discovery.grep"

# --- DYNAMIC DATA HAND-OFF: Extract open ports from discovery scan ---
# We parse the grepable output to get a comma-separated list of open TCP ports.
# The regex \d+(?=/open) matches port numbers that are immediately followed by "/open".
OPEN_PORTS=""
if [ -f "$OUTPUT_DIR/00_discovery.grep" ]; then
    OPEN_PORTS=$(grep -E "Ports:" "$OUTPUT_DIR/00_discovery.grep" | grep -oP '\d+(?=/open)' | sort -n | uniq | head -50 | tr '\n' ',' | sed 's/,$//')
fi

# If the stealth scan failed to identify any open ports (possible due to a strong WAF or firewall),
# we fall back to a predefined list of the most common service ports.
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
# This phase executes all major TCP/UDP scanning techniques to comprehensively map open ports.
# Each technique sends different packet flags, which may bypass different firewall configurations.
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 1: ADVANCED PORT SCANNING & PACKET FRAMEWORKING TECHNIQUES                                      │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

# 01. SYN Stealth Scan (Half-open) – The default and most popular Nmap scan type.
# Sends SYN packet and waits for SYN-ACK. Never completes the TCP handshake.
execute_module "01_SYN_Stealth"      "SYN Stealth Scan (Half-open)"                                    "sudo nmap -sS -Pn -f $TIMING -p $OPEN_PORTS $TARGET_IP"

# 02. TCP Connect Scan – Completes the full TCP three-way handshake.
# Used when raw packet privileges are not available (though we run with sudo anyway).
execute_module "02_Connect_Scan"     "TCP Connect Scan (Full handshake)"                               "nmap -sT -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 03. UDP Scan – Scans the top 100 UDP ports. UDP scanning is slower and less reliable than TCP.
execute_module "03_UDP_Deep_Scan"    "UDP Scan (Top 100 ports)"                                        "sudo nmap -sU -Pn --top-ports 100 $TARGET_IP"

# 04. Null Scan – Sends TCP packets with no flags set whatsoever.
# Useful for bypassing stateless firewalls and determining OS type.
execute_module "04_Null_Scan"        "Null Scan (No flags set)"                                         "nmap -sN -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 05. FIN Scan – Sends packets with only the FIN flag set.
# Often bypasses firewalls that only block SYN packets.
execute_module "05_FIN_Scan"         "FIN Scan (Stealthy firewall bypass)"                              "nmap -sF -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 06. Xmas Scan – Sends packets with FIN, PSH, and URG flags set.
# Named because it "lights up like a Christmas tree" in packet captures.
execute_module "06_Xmas_Scan"        "Xmas Scan (FIN, PSH, URG flags)"                                  "nmap -sX -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 07. ACK Scan – Used exclusively to map out firewall rulesets.
# Determines whether ports are statefully filtered or unfiltered.
execute_module "07_ACK_Scan"         "ACK Scan (Firewall rule mapping)"                                 "nmap -sA -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 08. Window Scan – Similar to ACK scan but examines the TCP window field for anomalies.
execute_module "08_Window_Scan"      "Window Scan (TCP window analysis)"                                "nmap -sW -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 09. Maimon Scan – Sends a FIN/ACK probe. Named after its discoverer, Uriel Maimon.
execute_module "09_Maimon_Scan"      "Maimon Scan (FIN/ACK probe)"                                      "nmap -sM -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 10. IP Protocol Scan – Determines which IP protocols (TCP, ICMP, IGMP, etc.) the target supports.
execute_module "10_IP_Protocol_Scan" "IP Protocol Scan (Raw IP protocols)"                              "nmap -sO -Pn $TARGET_IP"

# 11. SCTP INIT Scan – Scans for services using the Stream Control Transmission Protocol.
execute_module "11_SCTP_Scan"        "SCTP INIT Scan (Stream Control Transmission Protocol)"            "nmap -sY -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# ============================================================================================================
# PHASE 2: FIREWALL / IDS EVASION & IDENTITY SPOOFING
# ============================================================================================================
# This phase tests various techniques to hide the scanner's true identity and evade detection systems.
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 2: FIREWALL / IDS EVASION & IDENTITY SPOOFING                                                  │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

# 12. Decoy Scan – Cloaks the real IP by mixing it with 10 randomly generated decoy IPs.
execute_module "12_Decoy_Scan"        "Decoy Scan (10 random decoys + real IP)"                        "nmap -D RND:10,ME -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 13. Packet Fragmentation (-f) – Splits the TCP header across multiple packets.
execute_module "13_Fragmentation"     "Packet Fragmentation (-f)"                                      "nmap -f -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 14. Double Fragmentation (-ff) – Further fragments packets to make IDS reassembly harder.
execute_module "14_Double_Frag"       "Double Fragmentation (-ff)"                                     "nmap -ff -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 15. MTU Manipulation – Sets a custom Maximum Transmission Unit size (24 bytes forces fragmentation).
execute_module "15_MTU_Manipulation"  "MTU Size Manipulation (MTU 24)"                                 "nmap --mtu 24 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 16. Data Length Padding – Appends random data to packets to obfuscate payload size patterns.
execute_module "16_Data_Length_Pad"   "Data Length Padding (Random payload size)"                      "nmap --data-length 128 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 17. Source Port Spoofing – Sets the source port to 53 (DNS), which is often allowed through firewalls.
execute_module "17_Source_Port_Spoof" "Source Port Spoofing (Port 53/DNS)"                             "nmap --source-port 53 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 18. MAC Address Spoofing – Uses a fake MAC address (from Apple's OUI) for local network scans.
execute_module "18_MAC_Spoofing"      "MAC Address Spoofing (Random Vendor)"                           "nmap --spoof-mac Apple -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 19. Bad Checksum – Sends packets with invalid checksums to test firewall responsiveness.
execute_module "19_Bad_Checksum"      "Bad Checksum (Detect unresponsive firewalls)"                   "nmap --badsum -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 20. TTL Manipulation – Sets a custom Time-To-Live value to evade detection based on hop count.
execute_module "20_TTL_Manipulation"  "TTL Manipulation (Set TTL to 50)"                               "nmap --ttl 50 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# 21. Randomize Hosts – Shuffles scan order (more useful when scanning multiple targets).
execute_module "21_Randomize_Hosts"   "Randomize Target Host Order"                                    "nmap --randomize-hosts -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# ============================================================================================================
# PHASE 3: SERVICE & OS FINGERPRINTING
# ============================================================================================================
# This phase identifies the exact software versions and operating system running on the target.
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 3: SERVICE VERSION DETECTION & OS FINGERPRINTING                                               │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

# 22. Service Version Detection – Probes open ports to determine exact service names and versions.
# Intensity 9 is the maximum, providing the most accurate results.
execute_module "22_Version_Detection"   "Service Version Detection (Intensity 9)"                      "nmap -sV --version-intensity 9 $TIMING -p $OPEN_PORTS $TARGET_IP"

# 23. OS Fingerprinting – Attempts to guess the operating system based on TCP/IP stack peculiarities.
execute_module "23_OS_Detection"        "OS Fingerprinting (Aggressive guess)"                         "sudo nmap -O --osscan-guess $TIMING $TARGET_IP"

# 24. Aggressive Scan (-A) – Enables OS detection, version detection, default scripts, and traceroute all at once.
execute_module "24_Aggressive_Scan"     "Aggressive Scan (-A: OS, version, scripts, traceroute)"       "sudo nmap -A $TIMING -p $OPEN_PORTS $TARGET_IP"

# 25. Traceroute – Maps the network path (hops) from the scanner to the target.
execute_module "25_Traceroute"          "Traceroute (Path discovery)"                                  "nmap --traceroute -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"

# ============================================================================================================
# PHASE 4: NSE SCRIPTING ENGINE (VULNERABILITY & EXPLOITATION)
# ============================================================================================================
# This phase leverages Nmap's Scripting Engine to identify vulnerabilities and potential exploits.
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 4: NSE SCRIPTING ENGINE - VULNERABILITY ASSESSMENT                                             │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

# 26. Default Safe Scripts (-sC) – Runs a standard set of non-intrusive discovery scripts.
execute_module "26_Default_Scripts"     "Default Safe Scripts (-sC)"                                   "nmap -sC $TIMING -p $OPEN_PORTS $TARGET_IP"

# 27. Vulnerability Scan – Runs all scripts in the 'vuln' category to check for known vulnerabilities.
execute_module "27_Vuln_Scan"           "Vulnerability Scan (vuln category)"                           "nmap --script vuln $TIMING -p $OPEN_PORTS $TARGET_IP"

# 28. Exploit Scripts – Runs scripts that actively attempt to exploit identified vulnerabilities.
execute_module "28_Exploit_Scan"        "Exploit Scripts (exploit category)"                           "nmap --script exploit $TIMING -p $OPEN_PORTS $TARGET_IP"

# 29. Authentication Bypass – Checks for weak authentication and authorization bypass techniques.
execute_module "29_Auth_Bypass"         "Authentication Bypass Scripts (auth category)"                "nmap --script auth $TIMING -p $OPEN_PORTS $TARGET_IP"

# 30. Brute Force – Attempts to brute-force credentials for various network services.
execute_module "30_Brute_Force"         "Brute Force Scripts (brute category)"                         "nmap --script brute $TIMING -p $OPEN_PORTS $TARGET_IP"

# 31. Malware Detection – Checks if the target shows signs of known malware infections.
execute_module "31_Malware_Detection"   "Malware Detection Scripts"                                    "nmap --script malware $TIMING -p $OPEN_PORTS $TARGET_IP"

# 32. All Safe Scripts – Runs every script that is classified as 'safe' (non-intrusive).
execute_module "32_Safe_Scripts"        "All Safe Scripts (non-intrusive)"                             "nmap --script safe $TIMING -p $OPEN_PORTS $TARGET_IP"

# 33. Discovery Scripts – Gathers extensive information about network configuration and services.
execute_module "33_Discovery_Scripts"   "Discovery Scripts (network info)"                             "nmap --script discovery $TIMING -p $OPEN_PORTS $TARGET_IP"

# --- Extract CVEs from vulnerability scan output ---
# We use grep with a regular expression to find any CVE identifiers (e.g., CVE-2021-44228) in the vuln scan log.
# The pattern matches "CVE-" followed by 4-digit year, hyphen, and at least 4 more digits.
grep -oE "CVE-[0-9]{4}-[0-9]{4,}" "$OUTPUT_DIR/27_Vuln_Scan.txt" 2>/dev/null | sort -u > "$CVE_FILE"

# Display immediate feedback about CVEs found
if [ -s "$CVE_FILE" ]; then
    echo -e "${RED}${BOLD}[!] CVEs DETECTED! Check $CVE_FILE${NC}"
    echo "⚠️  Vulnerabilities (CVEs) found: $(wc -l < $CVE_FILE)" >> "$SUMMARY_FILE"
else
    echo -e "${GREEN}[✓] No CVEs identified in scan.${NC}"
fi

# ============================================================================================================
# PHASE 5: PROTOCOL-SPECIFIC DEEP ENUMERATION
# ============================================================================================================
# This phase runs targeted enumeration against specific services detected on the target.
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 5: PROTOCOL-SPECIFIC DEEP ENUMERATION                                                           │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

# --- HTTP/HTTPS (ports 80, 443) ---
# Web servers are the most common attack surface. These scripts extract detailed information.
if [[ "$OPEN_PORTS" == *"80"* ]] || [[ "$OPEN_PORTS" == *"443"* ]]; then
    # 34. HTTP Enumeration – Extracts HTTP methods, headers, page titles, and common directories.
    execute_module "34_HTTP_Enum"          "HTTP Enumeration (methods, headers, title)"                "nmap --script http-enum,http-headers,http-title,http-methods $TIMING -p 80,443 $TARGET_IP"
    
    # 35. HTTP Shellshock – Checks for the Shellshock vulnerability (CVE-2014-6271) in CGI scripts.
    execute_module "35_HTTP_Shellshock"    "HTTP Shellshock Vulnerability Check"                        "nmap --script http-shellshock $TIMING -p 80,443 $TARGET_IP"
    
    # 36. SSL/TLS Audit – Examines SSL certificates, cipher suites, and checks for Heartbleed/POODLE.
    execute_module "36_SSL_TLS_Audit"      "SSL/TLS Audit (ciphers, heartbleed, poodle)"                "nmap --script ssl-cert,ssl-enum-ciphers,ssl-heartbleed,ssl-poodle $TIMING -p 443 $TARGET_IP"
fi

# --- SMB / NetBIOS (ports 139, 445) ---
# Windows file sharing services often reveal critical information.
if [[ "$OPEN_PORTS" == *"445"* ]] || [[ "$OPEN_PORTS" == *"139"* ]]; then
    # 37. SMB Enumeration – Lists available shares, users, and the operating system version.
    execute_module "37_SMB_Enum"           "SMB Share & User Enumeration"                               "nmap --script smb-enum-shares,smb-enum-users,smb-os-discovery $TIMING -p 139,445 $TARGET_IP"
    
    # 38. EternalBlue (MS17-010) – Checks for the critical SMBv1 vulnerability exploited by WannaCry.
    execute_module "38_SMB_EternalBlue"    "MS17-010 EternalBlue Vulnerability Check"                   "nmap --script smb-vuln-ms17-010 $TIMING -p 445 $TARGET_IP"
    
    # 39. SMB Brute Force – Attempts to guess SMB credentials (use only with explicit authorisation).
    execute_module "39_SMB_Brute"          "SMB Brute Force (if applicable)"                             "nmap --script smb-brute $TIMING -p 445 $TARGET_IP"
fi

# --- SSH (port 22) ---
if [[ "$OPEN_PORTS" == *"22"* ]]; then
    # 40. SSH Enumeration – Identifies supported authentication methods and retrieves the host key.
    execute_module "40_SSH_Enum"           "SSH Enumeration (auth methods, hostkey, algorithms)"        "nmap --script ssh-auth-methods,ssh-hostkey,ssh2-enum-algos $TIMING -p 22 $TARGET_IP"
fi

# --- FTP (port 21) ---
if [[ "$OPEN_PORTS" == *"21"* ]]; then
    # 41. FTP Enumeration – Tests for anonymous login, FTP bounce attacks, and system information.
    execute_module "41_FTP_Enum"           "FTP Enumeration (anonymous, bounce, syst)"                  "nmap --script ftp-anon,ftp-bounce,ftp-syst $TIMING -p 21 $TARGET_IP"
fi

# --- SNMP (port 161 UDP) ---
if [[ "$OPEN_PORTS" == *"161"* ]]; then
    # 42. SNMP Enumeration – Queries SNMP for system info, network interfaces, and listening ports.
    execute_module "42_SNMP_Enum"          "SNMP Enumeration (info, interfaces, netstat)"               "sudo nmap -sU --script snmp-info,snmp-interfaces,snmp-netstat -p 161 $TARGET_IP"
fi

# --- DNS (port 53) ---
# 43. DNS Subdomain Bruteforce – Attempts to discover subdomains using a built-in wordlist.
execute_module "43_DNS_Brute"          "DNS Subdomain Bruteforce"                                    "nmap --script dns-brute $TARGET_INPUT"

# 44. Reverse DNS Lookup – Performs a reverse DNS lookup to find hostnames associated with the IP.
execute_module "44_DNS_Reverse"        "Reverse DNS Lookup"                                          "nmap -R -sL $TARGET_IP"

# ============================================================================================================
# PHASE 6: PERFORMANCE TUNING & TIMING TEMPLATES
# ============================================================================================================
# This phase demonstrates the full spectrum of Nmap timing templates, from paranoid to insane.
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 6: PERFORMANCE TUNING & TIMING TEMPLATES                                                        │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

# 45. Timing Template T0 (Paranoid) – Extremely slow, used for extreme IDS evasion. Serial scanning.
execute_module "45_Timing_T0_Paranoid" "Timing Template T0 (Paranoid - IDS evasion)"                 "nmap -T0 -F $TARGET_IP"

# 46. Timing Template T1 (Sneaky) – Very slow, still useful for avoiding detection. 15-second intervals.
execute_module "46_Timing_T1_Sneaky"   "Timing Template T1 (Sneaky - slow scan)"                     "nmap -T1 -F $TARGET_IP"

# 47. Timing Template T2 (Polite) – Slower than normal, reduces bandwidth consumption.
execute_module "47_Timing_T2_Polite"   "Timing Template T2 (Polite - less aggressive)"               "nmap -T2 -F $TARGET_IP"

# 48. Timing Template T3 (Normal) – The default timing template when none is specified.
execute_module "48_Timing_T3_Normal"   "Timing Template T3 (Normal - default)"                       "nmap -T3 -F $TARGET_IP"

# 49. Timing Template T4 (Aggressive) – Fast scan, assumes a reliable and fast network connection.
execute_module "49_Timing_T4_Aggressive" "Timing Template T4 (Aggressive - fast scan)"                "nmap -T4 -F $TARGET_IP"

# 50. Timing Template T5 (Insane) – Maximum speed, may overwhelm targets or cause missed ports.
execute_module "50_Timing_T5_Insane"   "Timing Template T5 (Insane - maximum speed)"                  "nmap -T5 -F $TARGET_IP"

# 51. Rate Control – Manually defines the minimum and maximum packet rates per second.
execute_module "51_Rate_Control"       "Rate Control (min-rate 100, max-rate 500)"                    "nmap --min-rate 100 --max-rate 500 -F $TARGET_IP"

# ============================================================================================================
# PHASE 7: IPv6 SCANNING
# ============================================================================================================
# This phase checks if the target is accessible over IPv6.
echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
echo -e "${PURPLE}${BOLD}│  PHASE 7: IPv6 SCANNING                                                                                │${NC}"
echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

# 52. IPv6 Basic Scan – Scans the target over IPv6 if it has an AAAA record.
execute_module "52_IPv6_Basic"     "IPv6 Basic Scan"          "nmap -6 $TARGET_INPUT 2>/dev/null || echo 'IPv6 not available'"

# 53. IPv6 Ping Sweep – Discovers live hosts over IPv6 using ICMPv6 echo requests.
execute_module "53_IPv6_Discovery" "IPv6 Ping Sweep"          "nmap -6 -sn $TARGET_INPUT 2>/dev/null || echo 'IPv6 not available'"

# ============================================================================================================
# PHASE 8: DEEP EVASION & FRAGMENTATION ATTACKS (Ghost/Stealth/Full Mode Exclusive)
# ============================================================================================================
# This phase is only executed in high-evasion modes and contains the most aggressive techniques.
if [ "$GHOST_MODE" = true ] || [ "$STEALTH_MODE" = true ] || [ "$FULL_MODE" = true ]; then
    echo -e "\n${PURPLE}${BOLD}┌────────────────────────────────────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${PURPLE}${BOLD}│  PHASE 8: DEEP EVASION & FRAGMENTATION ATTACKS                                                         │${NC}"
    echo -e "${PURPLE}${BOLD}└────────────────────────────────────────────────────────────────────────────────────────────────────────┘${NC}"

    # 54. Extreme Fragmentation (MTU 8) – Maximum packet fragmentation to bypass even strict firewalls.
    execute_module "54_Deep_Frag_MTU8"   "Extreme Fragmentation (MTU 8)"                              "nmap -f --mtu 8 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
    
    # 55. Aggressive Fragmentation (MTU 16) – A balanced but still aggressive fragmentation level.
    execute_module "55_Deep_Frag_MTU16"  "Aggressive Fragmentation (MTU 16)"                          "nmap -f --mtu 16 -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
    
    # 56. Maximum Decoys – Uses 20 randomly generated decoy IP addresses to obscure the real source.
    execute_module "56_Decoy_Extreme"    "Maximum Decoys (20 random IPs)"                             "nmap -D RND:20,ME -Pn $TIMING -p $OPEN_PORTS $TARGET_IP"
    
    # 57. Ultimate Stealth Combo – Decrypts and executes the ultimate stealth command from Base64.
    # This combines all major evasion techniques into a single, highly evasive scan.
    ULTIMATE_CMD=$(_decrypt "$_ENCRYPTED_CONFIG")
    execute_module "57_Ultimate_Stealth" "Ultimate Stealth Combo (frag+decoy+source-port+delay)"     "sudo $ULTIMATE_CMD -p $OPEN_PORTS $TARGET_IP"
    
    # 58. Proxychains + TOR Ultimate Combo (Proxy Mode Exclusive)
    # This combines proxychains with all evasion techniques for maximum anonymity.
    if [ "$PROXY_MODE" = true ]; then
        PROXY_ULTIMATE=$(_decrypt "$_PROXYCHAINS_PAYLOAD")
        execute_module "58_Proxy_Ultimate" "PROXYCHAINS + TOR Ultimate Combo"                         "sudo $PROXY_ULTIMATE -D RND:15,ME -p $OPEN_PORTS $TARGET_IP"
    fi
fi

# ============================================================================================================
# FINAL REPORT GENERATION & SUMMARY
# ============================================================================================================
# Display a completion banner and compile the final scan statistics.
echo -e "\n${GREEN}${BOLD}"
echo "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════╗"
echo "║                                          🎉 SCAN COMPLETED                                               ║"
echo "║                                       HK-APEX MASTER FRAMEWORK v1.0                                      ║"
echo "║                                    [ ENHANCED GHOST PROTOCOL ]                                           ║"
echo "║                              [ PROXYCHAINS + TOR + MAC CHANGER + KILL-SWITCH ]                           ║"
echo "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Generate final summary and append it to the master report file.
# 'tee' displays the summary on the terminal while simultaneously writing to the file.
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

# Extract and display vulnerabilities summary for quick terminal review.
echo -e "${CYAN}${BOLD}📊 VULNERABILITY SUMMARY:${NC}"
if [ -s "$CVE_FILE" ]; then
    echo -e "${RED}[!] The following CVEs were identified:${NC}"
    cat "$CVE_FILE"
    echo ""
else
    echo -e "${GREEN}[✓] No known CVEs detected in scan output.${NC}"
    echo ""
fi

# Provide final instructions to the user on how to access the detailed results.
echo -e "${YELLOW}${BOLD}📁 RESULTS SAVED IN: $OUTPUT_DIR/${NC}"
echo -e "${DIM}Run the following commands to explore results:"
echo -e "  cd $OUTPUT_DIR && ls -la"
echo -e "  cat 00_MASTER_REPORT.txt"
echo -e "  grep 'open' 00_discovery.grep"
echo -e "${NC}"

# --- Ghost Protocol: Self-Destruct Countdown (Optional) ---
# In Ghost Mode, the user is given the option to wipe all evidence after 60 seconds.
if [ "$GHOST_MODE" = true ]; then
    echo ""
    echo -e "${RED}${BOLD}[GHOST] Self-destruct sequence initiated...${NC}"
    echo -e "${YELLOW}All scan files will be securely deleted in 60 seconds.${NC}"
    echo -e "${YELLOW}Press ${BOLD}Ctrl+C${NC}${YELLOW} NOW to abort deletion and keep the results.${NC}"
    sleep 60
    rm -rf "$OUTPUT_DIR"
    echo -e "${GREEN}[GHOST] All traces wiped. Evidence eliminated.${NC}"
fi

# Exit the script with a success status code.
exit 0
