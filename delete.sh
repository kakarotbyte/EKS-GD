# Delete
kubectl delete pod nginx -n kube-system 
kubectl delete -f priv-cont.yaml
kubectl delete rolebinding sa-default-admin 
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl delete clusterrolebinding anonymous-view 
