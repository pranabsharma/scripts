#Run this script on master node

#Ceating Kubernetes clusters using the basis kubeadm tool
sudo kubeadm init

#Copying kubeconfig file to user's home directory
mkdir -p ~/.kube 
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config 
sudo chown $(id -u):$(id -g) ~/.kube/config

#Deploying WeaveNet network plugin
wget https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n') -O wave.yaml

kubectl apply -f wave.yaml 



