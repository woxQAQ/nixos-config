#!/usr/bin/env bash
set -e

echo "=== Clash Verge Rev TUN Debug Script ==="
echo ""

echo "1. Checking clash-verge-rev services..."
echo "----------------------------------------"
systemctl status clash-verge-rev.service --no-pager -l || true
echo ""
systemctl status clash-verge-rev-verge-mihomo.service --no-pager -l || true
echo ""

echo "2. Checking TUN devices..."
echo "----------------------------------------"
ip tuntap show 2>/dev/null || echo "No TUN devices found"
echo ""
ip addr show | grep -E "(tun|meta|clash)" || echo "No clash-related interfaces"
echo ""

echo "3. Checking routes..."
echo "----------------------------------------"
ip route show | head -20
echo ""
ip route show table all | grep -E "(tun|meta|clash)" || echo "No TUN routes found"
echo ""

echo "4. Checking DNS configuration..."
echo "----------------------------------------"
cat /etc/resolv.conf
echo ""

echo "5. Checking listening ports (53, 1053, 7874, 7890, 9090)..."
echo "----------------------------------------"
ss -tlnp 2>/dev/null | grep -E ':(53|1053|7874|7890|9090)' || echo "No relevant ports found"
echo ""

echo "6. Checking nftables rules..."
echo "----------------------------------------"
nft list ruleset 2>/dev/null | grep -E "(tun|meta|clash|dns)" | head -20 || echo "No nftables rules or nftables not available"
echo ""

echo "7. Checking iptables NAT rules..."
echo "----------------------------------------"
iptables -t nat -L 2>/dev/null | head -30 || echo "iptables not available"
echo ""

echo "8. Testing connectivity with explicit proxy..."
echo "----------------------------------------"
HTTPS_PROXY=http://127.0.0.1:7890 curl -s -o /dev/null -w "%{http_code}" https://ipinfo.io || echo "Failed"
echo " (should be 200 if proxy works)"
echo ""

echo "9. Checking kernel modules..."
echo "----------------------------------------"
lsmod | grep -E "(tun|nf_)" | head -10
echo ""

echo "=== Debug Complete ==="
