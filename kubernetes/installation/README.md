# Bootstrapping your own Kubernetes clusters for testing and development

In this document I am going to show you the simplest way to ready your own Kubernetes cluster that you can use for testing, learning and development purposes. It is not recommended for production scenarios. 
I will use one master node and two worker nodes for this demonstration. I am using Virtualbox VMs with all the nodes running Ubuntu 20.04 and the scripts that I am going to use are also for Ubuntu only. 

## Prerequisites:
* Minimum RAM per node should be 2 GB
* 2 CPU cores per node
* Swap off on all the nodes
  * Run swapoff command on each node:
  > ``` $ sudo swapoff -a ```
   * Disable any swap entry in /etc/fstab file



## Recommendation:
The nodes should probably be in the same local subnet, they should be able to communicate with each other without any firewall.
If you are using VMs in some cloud provider, ensure that the VMs are in the same VCN and subnet. You can configure the security list/cloud firewall so that the VMs can interact with each other for all the ports needed in a Kubernetes cluster.

## Initial Setup:
Suppose my VMs are named as this way:
```
Node        IP
master      192.168.0.51
worker1     192.168.0.52
worker2     192.168.0.53
```

You can add the entries in all the VMs hosts file, so that they can communicate with each other by hostnames. So edit /etc/hosts file on each VM and add the following lines:
```
192.168.0.51 master
192.168.0.52 worker1
192.168.0.53 worker2
```

Now we are ready to start the installation


### Master Node:
On the master node run the scripts step by step in the same order it is shown below:
#### Step 1:
 
Install container runtime containerd using the script:
https://github.com/pranabsharma/scripts/blob/master/kubernetes/installation/install_containerd.sh 

Download the script and run it
```
ubuntu@master:~$ ./install_containerd.sh
```

#### Step 2:
Install the kubectl, kubeadm and kubelet using the script:
https://github.com/pranabsharma/scripts/blob/master/kubernetes/installation/install_kubeTools.sh

Download the script and run it
```
ubuntu@master:~$ ./install_kubeTools.sh
```


#### Step 3: 
Download the below script and ***ONLY run on your master node***:
https://github.com/pranabsharma/scripts/blob/master/kubernetes/installation/run_on_master.sh 

Download the script and run it
```
ubuntu@master:~$ ./run_on_master.sh
```
This script does the following tasks:
* Run kubeadm to initialize a Kubernetes control-plane on the master node.
* Deploy Wavenet CNI plugin to manage the kubernetes pod networking. 
* Copy the kubeconfig file to the user's home directory location so that kubectl commands can be run without specifying the kubeconfig file.


Our master node and control-plane are ready. At this point we will get the following status of our cluster:


```
ubuntu@master:~$ kubectl get node
NAME     STATUS   ROLES                  AGE   VERSION
master   Ready    control-plane,master   50m   v1.23.2
```

```
ubuntu@master:~$ kubectl get pod -n kube-system
NAME                             READY       STATUS    RESTARTS               AGE
coredns-64897985d-fvnhj           1/1         Running       0                 51m
coredns-64897985d-wq6z5           1/1         Running       0                 51m
etcd-master                       1/1         Running       0                 51m
kube-apiserver-master             1/1         Running       0                 51m
kube-controller-manager-master    1/1         Running       0                 51m
kube-proxy-hnk2z                  1/1         Running       0                 51m
kube-scheduler-master             1/1         Running       0                 51m
weave-net-gjvqq                   2/2         Running       1 (50m ago)       51m
```



### Worker Node

Installation steps on worker nodes are the same as the master, the only difference is that we are going to skip the Step3 of the master node (step3 is for setting up the control plane). Run the scripts as shown in Step1 and Step2:
#### Step 1:
 
Install container runtime containerd using the script:
https://github.com/pranabsharma/scripts/blob/master/kubernetes/installation/install_containerd.sh 

Download the script and run it
```
ubuntu@worker1:~$ ./install_containerd.sh
```

#### Step 2:
Install the kubectl, kubeadm and kubelet using the script:
https://github.com/pranabsharma/scripts/blob/master/kubernetes/installation/install_kubeTools.sh

Download the script and run it
ubuntu@worker1:~$ ./install_kubeTools.sh


## Adding Worker Nodes to the cluster

At this point our required software and services for the Kubernetes cluster are ready. The final step is to add the worker nodes to the cluster. 

#### Step1: 

We are going to create a new token for the worker node to join the cluster.

Run the below command on **master node**:
```
ubuntu@master:~$ kubeadm token create --print-join-command
```
This command will output the command to join the cluster. The output will be something like this:

```
kubeadm join 192.168.0.51:6443 --token pk9v0f.o8valhztkblohsmu --discovery-token-ca-cert-hash sha256:9e046d3f15e49c7363ec7a762767b169a296d6af7150aad56d21d54399a2df6f
```
Copy the output, we will need it in the next step.

#### Step 2:

Run the copied output command on the **worker nodes**
```
ubuntu@worker1:~$ kubeadm join 192.168.0.51:6443 --token pk9v0f.o8valhztkblohsmu --discovery-token-ca-cert-hash sha256:9e046d3f15e49c7363ec7a762767b169a296d6af7150aad56d21d54399a2df6f
```

Immediately after running the above command on worker node, if we check the nodes in the cluster we may get the below output:
```
ubuntu@master:~$ kubectl get node
NAME          STATUS         ROLES                  AGE       VERSION
master        Ready          control-plane,master   54m       v1.23.2
worker1       NotReady       <none>                 39s       v1.23.2
```
After some time, the worker node will come into ready state.

The same way we can add the worker2 node also.

That’s it, and our kubernetes cluster is ready to rock!!! Super easy isn’t it?






