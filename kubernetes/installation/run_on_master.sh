#Run this script on master node
sudo swapoff -a

#Ceating Kubernetes clusters using the basis kubeadm tool

if ! sudo kubeadm init; then
    echo "ERROR!!!! Fix the error first, quiting"
    exit
fi

#Copying kubeconfig file to user's home directory
mkdir -p ~/.kube 
sudo cp -i /etc/kubernetes/admin.conf ~/.kube/config 
sudo chown $(id -u):$(id -g) ~/.kube/config

#Deploying WeaveNet network plugin
wget https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n') -O wave.yaml

kubectl apply -f wave.yaml 

kubectl get pod -n kube-system
