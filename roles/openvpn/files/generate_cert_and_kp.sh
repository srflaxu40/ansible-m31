#!/bin/bash

source vars
./build-key global

cd keys

cp ca.crt server.crt server.key ta.key dh2048.pem /etc/openvpn


