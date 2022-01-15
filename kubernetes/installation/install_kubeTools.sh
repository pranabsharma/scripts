# Turning swap off
sudo swapoff -a

#Installing kubelet, kubeadm and kubectl on Ubuntu

sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl

#Following command stops auto update or delete of any of these tool so that they have a consistent version
sudo apt-mark hold kubelet kubeadm kubectl

# Clearning any Iptable rules
sudo iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X
