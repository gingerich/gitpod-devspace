#syntax=docker/dockerfile:1.2

ARG GITPOD_IMAGE=gitpod/workspace-base:latest
FROM ${GITPOD_IMAGE}

# Install DevSpace
RUN curl -s -L https://github.com/loft-sh/devspace/releases/latest | \
        sed -nE 's!.*"([^"]*devspace-linux-amd64)".*!https://github.com\1!p' | \
        xargs -n 1 curl -L -o devspace && chmod +x devspace && \
    sudo install devspace /usr/local/bin;

# Install Loft plugin
RUN devspace add plugin https://github.com/loft-sh/loft-devspace-plugin

ARG KUBECTL_VERSION

## Install Kubectl
RUN curl -LO https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

## Install Helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && \
    chmod 700 get_helm.sh && \
    ./get_helm.sh

## Install Kustomize
RUN curl -s https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh  | bash

# Install krew
RUN set -x; cd "$(mktemp -d)" && \
    OS="$(uname | tr '[:upper:]' '[:lower:]')" && \
    ARCH="$(uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$/arm64/')" && \
    KREW="krew-${OS}_${ARCH}" && \
    curl -fsSLO "https://github.com/kubernetes-sigs/krew/releases/latest/download/${KREW}.tar.gz" && \
    tar zxvf "${KREW}.tar.gz" && \
    ./"${KREW}" install krew

ENV PATH="${KREW_ROOT:-$HOME/.krew}:${PATH}"