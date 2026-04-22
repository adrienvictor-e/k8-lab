#!/bin/bash
echo "Shutting down K3s workers first..."
ssh adrien@10.0.0.2 'sudo shutdown now' &
ssh adrien@10.0.0.3 'sudo shutdown now' &
wait
echo "Workers down. Shutting down control plane..."
sleep 5
sudo shutdown now
