#!/bin/bash

read -p "Enter key:" key

read -p "Enter value:" value

base_url="http://localhost:8000"

echo "Storing value..."

curl -X POST "${base_url}/cache?key=${key}&value=${value}"

echo ""
echo "Retrieving value..."

curl "${base_url}/cache?key=${key}"

echo ""
echo "Done"
