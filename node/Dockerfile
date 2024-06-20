FROM quay.io/fedora/fedora-coreos:stable

# extra packages
COPY etc/yum.repos.d/ /etc/yum.repos.d
RUN rpm-ostree install \
        dmidecode \
        etcd \
        haproxy \
        kubeadm \
        kubectl \
        kubelet \
        man-db \
        man-pages \
        tailscale \
        tcpdump \
        usbutils \
        vim \
    && \
    ostree container commit

COPY etc/ /etc
COPY usr/ /usr
RUN mkdir -p /etc/haproxy/conf.d && \
    chmod 700 /etc/kubeadm.conf.d && \
    ostree container commit

# enable services
RUN systemctl enable \
        containerd.service \
        etc-kubernetes.mount \
        haproxy.service \
        kubelet.service \
        tailscale-init.service \
        tailscaled.service \
    && \
    ostree container commit
