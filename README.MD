# Bash utility functions and aliases

This bash script provides several utility functions and aliases for Kubernetes and Argo CD tasks.

## Usage
adjust your ~/.bashrc and add this
```bash
source <(wget --no-cookies --no-cache -qO - https://raw.githubusercontent.com/iits-consulting/common-bash-functions/main/bash-functions.sh)
```

You can then list the alias like this:
```bash
$ list_iits_alias

Functions:
argo
traefik
cleanup_pods
get_secrets
check_cluster_for_unsigned_images
list_iits_alias
---
Aliases:
k
kns
kenv
kubens
kubeEnv
updateArgoCharts
updateCharter
charter
fwd
```

## Functions

### argo

Opens Argo CD in your preferred browser on Linux or MacOS and does port-forwarding for the Argo CD server. Also prints out the initial admin username and password.
### traefik

Does port forwarding for the first pod it finds in the routing namespace and also prints out the url to access the traefik dashboard.
### cleanup_pods

Cleans up K8s pods that are in either `Succeeded` or `Failed` phases or where all containers are in a `Waiting` state because of `ImageBackoffPull` reason.
### get_secrets

Prints out base64 decoded secret values for a given secret name.
### check_cluster_for_unsigned_images

Checks if any of the images used in the Kubernetes cluster are unsigned.
### list_iits_alias

Fetches and lists the functions and aliases from a bash script on GitHub.

## Aliases
Several aliases are also defined to simplify routine Kubernetes tasks.