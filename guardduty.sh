# kube-system exec
kubectl run nginx -n kube-system --image nginx
sleep 30
kubectl exec -it nginx -n kube-system -- ls
#
# # Privileged cont
kubectl apply -f priv-cont.yaml
#
#
# #admin access to SA
kubectl -n default create rolebinding sa-default-admin --clusterrole cluster-admin --serviceaccount default:default
#
# # exposed Dash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl -n kubernetes-dashboard patch svc kubernetes-dashboard -p='{"spec": {"type": "LoadBalancer"}}'
#
# # anonymous-view access to cluster.
kubectl create clusterrolebinding anonymous-view --clusterrole=view --user=system:anonymous --namespace=default
#
server=$(kubectl config view --minify -o jsonpath='{.clusters[*].cluster.server}')
#
curl -ivk $server/api/v1/pods
#
#
#
#
#
# ###run time findings 
#
# #crypto miner
kubectl run test --image public.ecr.aws/s0u1v2w0/miner-test:latest
#
# #dns
kubectl create cronjob dns-job  --schedule="0 */6 * * *" --image=nicolaka/netshoot -- dig awstest.duckdns.org
