#!/bin/bash

function argo() {
  local ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)
  echo "Username=admin, password=$ARGOCD_PASSWORD"


  if [[ $(uname) == "Linux" ]]; then
    xdg-open http://localhost:8080/argocd && kubectl -n argocd port-forward svc/argocd-server 8080:80
  else
    open http://localhost:8080/argocd && kubectl -n argocd port-forward svc/argocd-server 8080:80
  fi
}

function traefik() {
  local localhost_port="9000"
  echo "Open \"http://localhost:${localhost_port}/dashboard/#/\" to see your treafik dashboard"
  kubectl -n routing port-forward $(kubectl get pod -n routing -o jsonpath="{.items[0].metadata.name}") ${localhost_port}:9000
}

function cleanup_pods() {
    kubectl delete pods --field-selector=status.phase==Succeeded -A;
    kubectl delete pods --field-selector status.phase=Failed -A;
    kubectl delete pods $(kubectl get pod --all-namespaces -o jsonpath='{.items[?(@.status.containerStatuses[*].state.waiting.reason=="ImagePullBackOff")].metadata.name}')
}

function get_secrets() {
  kubectl get secrets $1 -o yaml | yq '.data | map_values(@base64d)'
}

function check_cluster_for_unsigned_images() {
  # Download public key for cosign verification
  curl -s https://raw.githubusercontent.com/iits-consulting/charts/main/charts/iits-kyverno-policies/pub-keys/pub.key -o ./pub.key

  # Get all pods excluding the kube-system namespace | Remove the headers | Print only the json path for the images
  images=$(kubectl get pods --all-namespaces --field-selector metadata.namespace!=kube-system,metadata.namespace!=kyverno -o jsonpath="{..image}" |\
               tr -s '[[:space:]]' '\n' |\
               sort |\
               uniq)

  # Iterate over all images
  for image in $images; do
      # Run cosign verify command for each image
      output=$(cosign verify --key pub.key "$image" 2>&1)
      if [[ $output == *"no matching signatures"* ]]; then
          echo "Image: $image No Cosign signature found"
      fi
  done
  rm pub.key
}

function list_iits_alias() {
    iits_alias=$(wget --no-cookies --no-cache -qO - https://raw.githubusercontent.com/victorgetz/common-bash-functions/main/bash-functions.sh)
    echo "Functions:"
    echo "${iits_alias}" | awk '/^function/ {print $2}' | cut -d'(' -f 1
    echo "---"
    echo "Aliases:"
    echo "${iits_alias}" | awk '/^alias/ {print $2}' | cut -d'=' -f 1
}

alias k="kubectl"
complete -F __start_kubectl k
alias kns="kubectl config set-context --current --namespace "
alias kenv="kubectl config current-context"
alias kubens='kubectl config set-context --current --namespace '
alias kubeEnv="kubectl config current-context"
alias updateArgoCharts="helm plugin update iits-argo-charts-updater && helm iits-argo-charts-updater"
alias updateCharter="helm plugin update iits-chart-creator && helm iits-chart-creator -v"
alias charter='helm iits-chart-creator infrastructure-charts'
alias fwd="sudo kubefwd svc -n $1"