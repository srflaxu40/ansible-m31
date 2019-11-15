#!/bin/bash

source vars
./build-key client1

cd keys

cp ca.crt server.crt server.key ta.key dh2048.pem /etc/openvpn


