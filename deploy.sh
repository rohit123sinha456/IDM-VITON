#!/bin/bash

# Step 1: Check if conda is installed
if ! command -v conda &> /dev/null; then
    echo "Conda not found, installing Miniconda..."
    # Download and install Miniconda
    wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O Miniconda.sh
    bash Miniconda.sh -b -p $HOME/miniconda
    rm Miniconda.sh
    export PATH="$HOME/miniconda/bin:$PATH"
else
    echo "Conda is already installed."
fi

# Step 2: Create a conda environment from environment.yml
if [ -f "environment.yml" ]; then
    conda env create -f environment.yml
    if [ $? -ne 0 ]; then
        echo "Failed to create conda environment."
        exit 1
    fi
    echo "Conda environment created successfully."
else
    echo "environment.yml not found in the current directory."
    exit 1
fi

# Step 3: Activate the conda environment and locate gunicorn
source $(conda info --base)/etc/profile.d/conda.sh
conda activate $(head -n 1 environment.yml | cut -d ' ' -f2)
if [ $? -ne 0 ]; then
    echo "Failed to activate conda environment."
    exit 1
fi

# Store the path to gunicorn in $VITONGUNICORN
VITONGUNICORN=$(which gunicorn)
if [ -z "$VITONGUNICORN" ]; then
    echo "Gunicorn not found in the conda environment."
    exit 1
fi

echo "Gunicorn path: $VITONGUNICORN"

# Step 4: Export $VITONGUNICORN to /etc/environment for global access
echo "VITONGUNICORN=$VITONGUNICORN" | sudo tee -a /etc/environment > /dev/null
if [ $? -ne 0 ]; then
    echo "Failed to add VITONGUNICORN to /etc/environment."
    exit 1
fi

echo "VITONGUNICORN exported to /etc/environment."

# Step 5: Copy viton.service to /etc/systemd/system/
sudo cp viton.service /etc/systemd/system/
if [ $? -ne 0 ]; then
    echo "Failed to copy viton.service to /etc/systemd/system/"
    exit 1
fi

echo "Copied viton.service to /etc/systemd/system/"

# Step 6: Reload systemd to recognize the new service
sudo systemctl daemon-reload
if [ $? -ne 0 ]; then
    echo "Failed to reload systemd daemon."
    exit 1
fi

echo "Systemd daemon reloaded."

# Step 7: Enable the viton service to start at boot
sudo systemctl enable viton.service
if [ $? -ne 0 ]; then
    echo "Failed to enable viton.service."
    exit 1
fi

echo "viton.service enabled to start on boot."

# Step 8: Start the viton service
sudo systemctl start viton.service
if [ $? -ne 0 ]; then
    echo "Failed to start viton.service."
    exit 1
fi

echo "viton.service started successfully."
