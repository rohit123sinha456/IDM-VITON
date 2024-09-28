## TO Deploy
```
echo "PROJECT_LOG=<Log Direcotry>/output.log" | sudo tee -a /etc/environment > /dev/null
echo "PROJECT_DIR=<Project Directory/gradio_demo>" | sudo tee -a /etc/environment > /dev/null
echo "PROJECTHOME=<Project Directory>" | sudo tee -a /etc/environment > /dev/null
```
### Restart The SSH Terminal

Then run
./deploy.sh

### Restart The SSH Terminal
Then run
sudo systemctl start viton.service
sudo systemctl status viton.service

