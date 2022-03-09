ifconfig | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' > local_ip
export LOCAL_IP=$(tail -n 1 local_ip)
sudo rm local_ip