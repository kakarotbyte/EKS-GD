#! /bin/bash

echo "Installing terraform"
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform

echo "Installing helm"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

echo "Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
echo "alias k=kubectl" >> /home/ec2-user/.bashrc
echo "alias kg='kubectl get'" >> /home/ec2-user/.bashrc
echo "alias kgp='kubectl get po'" >> /home/ec2-user/.bashrc
echo "alias kd='kubectl describe'" >> /home/ec2-user/.bashrc


echo "Installing kubectx"
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kctx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kns
sudo ln -s /usr/bin/terraform /usr/local/bin/t
sudo ln -s /usr/bin/kubectl /usr/local/bin/k


terraform init
terraform apply -auto-approve


#aws eks wait cluster-active --name two  --region us-east-1
aws eks wait cluster-active --name gdone --region us-east-1

#aws eks update-kubeconfig --name two  --region us-east-1
aws eks update-kubeconfig --name gdone  --region us-east-1

source /home/ec2-user/.bashrc
