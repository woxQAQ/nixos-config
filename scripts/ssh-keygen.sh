#!/bin/sh
echo "input username"
read -r username
echo "input domain"
read -r domain
ssh-keygen -t ed25519 -a 256 -C "$username@$domain"
