#!/bin/bash

ufw allow 443
ufw allow OpenSSH

ufw disable
ufw --force enable

