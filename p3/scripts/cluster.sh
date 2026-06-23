#!/bin/bash

# IoT Project Part 3 - Helper Script
# Utility commands for managing the cluster

set -e

CLUSTER_NAME="iot-cluster"
ARGOCD_NS="argocd"
DEV_NS="dev"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    cat <<EOF
Usage: $0 [COMMAND]

Commands:
    setup               - Run the full setup (Docker, K3d, Argo CD)
    logs-argocd         - View Argo CD logs
    logs-app            - View application logs
    port-forward        - Start port-forwarding for Argo CD UI
    get-password        - Get Argo CD admin password
    status              - Show cluster status
    delete-cluster      - Delete the K3d cluster (DESTRUCTIVE)
    help                - Show this help message

Examples:
    $0 setup
    $0 port-forward
    $0 logs-argocd -f
EOF
}

cmd_setup() {
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    bash "$SCRIPT_DIR/setup.sh"
}

cmd_logs_argocd() {
    log_info "Following Argo CD logs..."
    kubectl logs -f -n "$ARGOCD_NS" -l app.kubernetes.io/part-of=argocd "$@"
}

cmd_logs_app() {
    log_info "Following application logs..."
    kubectl logs -f -n "$DEV_NS" -l app=playground "$@"
}

cmd_port_forward() {
    log_info "Starting port-forward for Argo CD (http://localhost:8080)..."
    kubectl port-forward -n "$ARGOCD_NS" svc/argocd-server 8080:443
}

cmd_get_password() {
    log_info "Retrieving Argo CD admin password..."
    kubectl -n "$ARGOCD_NS" get secret argocd-initial-admin-secret \
        -o jsonpath="{.data.password}" 2>/dev/null | base64 -d || \
        log_error "Could not retrieve password (may not be ready yet)"
    echo ""
}

cmd_status() {
    log_info "Cluster nodes:"
    kubectl get nodes

    log_info "Namespaces:"
    kubectl get ns | grep -E "($ARGOCD_NS|$DEV_NS)"

    log_info "Argo CD pods:"
    kubectl get pods -n "$ARGOCD_NS"

    log_info "Application deployment:"
    kubectl get deployment -n "$DEV_NS" || log_error "No deployments in $DEV_NS"

    log_info "Application pods:"
    kubectl get pods -n "$DEV_NS" || log_error "No pods in $DEV_NS"

    log_info "Argo CD Applications:"
    kubectl get applications -n "$ARGOCD_NS" || log_error "No applications found"
}

cmd_delete_cluster() {
    read -p "Are you sure you want to delete the cluster? This is DESTRUCTIVE. (yes/no): " confirm
    if [ "$confirm" = "yes" ]; then
        log_info "Deleting cluster '$CLUSTER_NAME'..."
        k3d cluster delete "$CLUSTER_NAME"
        log_info "Cluster deleted"
    else
        log_info "Cancelled"
    fi
}

# Main
case "${1:-help}" in
    setup)
        cmd_setup
        ;;
    logs-argocd)
        shift
        cmd_logs_argocd "$@"
        ;;
    logs-app)
        shift
        cmd_logs_app "$@"
        ;;
    port-forward)
        cmd_port_forward
        ;;
    get-password)
        cmd_get_password
        ;;
    status)
        cmd_status
        ;;
    delete-cluster)
        cmd_delete_cluster
        ;;
    help)
        usage
        ;;
    *)
        log_error "Unknown command: $1"
        usage
        exit 1
        ;;
esac
