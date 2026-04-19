#!/bin/bash

<<<<<<< HEAD
read -p "Enter key:" key

read -p "Enter value:" value
=======
read -p "Enter the key: " key
read -p "Enter the value: " value
>>>>>>> 8d74be2 (commit 2)

base_url="http://localhost:8000"

echo "Storing value..."
<<<<<<< HEAD

=======
>>>>>>> 8d74be2 (commit 2)
curl -X POST "${base_url}/cache?key=${key}&value=${value}"

echo ""
echo "Retrieving value..."
<<<<<<< HEAD

curl "${base_url}/cache?key=${key}"

echo ""
echo "Done"
=======
curl "${base_url}/cache?key=${key}"

echo ""
echo "Done."
>>>>>>> 8d74be2 (commit 2)
