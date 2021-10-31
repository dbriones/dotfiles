function unifi-controller {
  for host in $(nmap -p 8443 -oG - 192.168.1.0/24 | grep 'open' | awk '{print $2;}')
    do /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome "https://$host:8443/"
  done
}