#!/bin/bash

set -e
export TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

export VERSION="${VERSION:-main}"
export INJECTOR_VERSION_TAG="${INJECTOR_VERSION_TAG:-release-v0.5.0}"
export NAMESPACE="${NAMESPACE:-k8s-volume-injector}"

export REPO_RAW_BASE_URL="https://raw.githubusercontent.com/atorrescogollo/k8s-volume-injector/${VERSION}"
export INSTALLATION_TYPE="${INSTALLATION_TYPE:-remote}"


function main(){
    local installation_type="$1"
    case "$installation_type" in
        remote)
            downloadTemplates "$TMPDIR"
            renderAndApply    "$TMPDIR"
            ;;
        local)
            local rootdir="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." &> /dev/null && pwd )"
            [ ! -f "$rootdir/manifests/webhook.yaml.template" ] \
                && echo >&2 "ERR: Templates were not found" \
                && exit 1
            renderAndApply "$rootdir"
            ;;
    esac
}

function downloadTemplates(){
    local rootdir="$1"
    mkdir -p "$rootdir/manifests/"
    for i in namespace certificate deployment webhook
    do
        wget -qO "$rootdir/manifests/$i.yaml.template" \
            "$REPO_RAW_BASE_URL/manifests/$i.yaml.template"
    done
}


function renderAndApply(){
    local rootdir="$1"
    mkdir -p "$rootdir/_gen"

    cat "$rootdir/manifests/namespace.yaml.template" \
        | sed 's@${NAMESPACE}@'$NAMESPACE'@g' \
        > "$rootdir/_gen/namespace.yaml"
    cat "$rootdir/manifests/certificate.yaml.template" \
        | sed 's@${NAMESPACE}@'$NAMESPACE'@g' \
        > "$rootdir/_gen/certificate.yaml"
    cat "$rootdir/manifests/deployment.yaml.template" \
        | sed 's@${NAMESPACE}@'$NAMESPACE'@g' \
        | sed 's@${INJECTOR_VERSION_TAG}@'$INJECTOR_VERSION_TAG'@g' \
        > "$rootdir/_gen/deployment.yaml"

    kubectl apply -f "$rootdir/_gen/namespace.yaml"
    kubectl apply -f "$rootdir/_gen/certificate.yaml"
    kubectl apply -f "$rootdir/_gen/deployment.yaml"

    local caBundle=$( kubectl get secrets -n $NAMESPACE k8s-volume-injector-cert -o go-template="{{ index .data \"ca.crt\"}}" )
    cat "$rootdir/manifests/webhook.yaml.template" \
        | sed 's@${NAMESPACE}@'$NAMESPACE'@g' \
        | sed 's@${CABUNDLE}@'$caBundle'@g' \
        > "$rootdir/_gen/webhook.yaml"
    kubectl apply -f "$rootdir/_gen/webhook.yaml"

}


main "${INSTALLATION_TYPE}"
