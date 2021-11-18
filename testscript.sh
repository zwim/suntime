#!/bin/bash

echo "Testing the maximum error of suncal for different locations"

{ for i in {1..15}; do echo "lua test.lua $i"; done } | parallel

