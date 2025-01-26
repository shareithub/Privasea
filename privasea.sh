#!/bin/bash
echo "   ______ _____   ___  ____  __________  __ ____  _____ "
echo "  / __/ // / _ | / _ \/ __/ /  _/_  __/ / // / / / / _ )"
echo " _\ \/ _  / __ |/ , _/ _/  _/ /  / /   / _  / /_/ / _  |"
echo "/___/_//_/_/ |_/_/|_/___/ /___/ /_/   /_//_/\____/____/ "
echo "               SUBSCRIBE MY CHANNEL                     "
sleep 3

    echo "Mengatur Docker dalam rootless mode..."
    sudo apt-get update
    sudo apt-get install -y docker-ce-rootless-extras
    dockerd-rootless-setuptool.sh install

    echo "Menambahkan rootless Docker ke PATH Anda."
    echo "Tambahkan baris berikut ke file .bashrc Anda:"
    echo "export PATH=\$HOME/bin:\$PATH"
    echo "Lalu jalankan 'source ~/.bashrc'."

    echo "export PATH=\$HOME/bin:\$PATH" >> ~/.bashrc
    source ~/.bashrc

    echo "Selesaikan setup dengan menjalankan: docker info"
    echo "Rootless mode berhasil diatur!"

echo "Melanjutkan ke pengaturan Privasea Privanetix Node..."

echo "Installing Docker..."
sudo bash -c "source <(wget -O - https://raw.githubusercontent.com/shareithub/Privasea/refs/heads/main/docker.sh)"

echo "Pulling Privasea Docker image..."
sudo docker pull privasea/acceleration-node-beta:latest
echo "Waiting for 20 seconds to ensure the image is pulled properly..."
sleep 20

echo "Creating Privasea directory..."
sudo mkdir -p ~/privasea/config
cd ~/privasea

echo "Generating a new wallet keystore..."
sudo docker run --rm -it -v "$HOME/privasea/config:/app/config" privasea/acceleration-node-beta:latest ./node-calc new_keystore
echo "Please note down the node address and password displayed during this step."

echo "Moving the generated keystore file..."
sudo mv $HOME/privasea/config/UTC--* $HOME/privasea/config/wallet_keystore

echo "Visit the Privanetix Dashboard to configure your node:"
echo "🔹 Connect a wallet to receive rewards."
echo "🔹 Enter the node address you noted earlier."
echo "🔹 Set up the node name and commission (e.g., 1%)."
echo "Then, click 'Set up my node.'"

echo "Stopping the existing Privasea Privanetix Node if it is running..."
docker stop privanetix-node || true

echo "Removing the container and image..."
docker rm privanetix-node || true  
docker rmi privasea/acceleration-node-beta:latest || true  

echo "Removing old wallet keystore..."
cd ~/privasea/config
sudo rm -fr wallet_keystore

echo "Masukkan informasi keystore baru..."
echo "Masukkan password untuk keystore: "
read -sp "Password: " KEYSTORE_PASSWORD

echo "Masukkan isi untuk wallet_keystore.json (sebagai JSON):"
echo "Contoh format: {\"address\": \"your-address\", \"key\": \"your-key\"}"
echo "Masukkan informasi keystore:"
read -p "Masukkan JSON: " KEYS_CONTENT

echo "$KEYS_CONTENT" > wallet_keystore
echo "Keystore berhasil dibuat dan disimpan dalam wallet_keystore"

echo "Starting your Privasea Privanetix Node..."
sudo docker run -d --name privanetix-node -v "$HOME/privasea/config:/app/config" -e KEYSTORE_PASSWORD=$KEYSTORE_PASSWORD privasea/acceleration-node-beta:latest
sleep 5

sudo docker restart privanetix-node
sleep 5

sudo docker logs privanetix-node
sleep 1
echo "Node setup is complete! Your Privanetix Node is running."
