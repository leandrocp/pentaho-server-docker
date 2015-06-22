#!/bin/bash

SITE=unix.stackexchange.com
IP=$(dig +short $SITE | head -n 1)

echo $IP
