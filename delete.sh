# Delete
echo "sleep 500 seconds"
sleep 500
kubectl delete pod nginx -n kube-system 
kubectl delete -f priv-cont.yaml
kubectl delete rolebinding sa-default-admin 
kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl delete clusterrolebinding anonymous-view 
