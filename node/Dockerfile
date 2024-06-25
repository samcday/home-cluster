FROM quay.io/fedora/fedora-coreos:stable

# extra packages
COPY etc/yum.repos.d/ /etc/yum.repos.d
RUN rpm-ostree install \
        dmidecode \
        etcd \
        kubeadm \
        kubectl \
        kubelet \
        iperf3 \
        man-db \
        man-pages \
        tcpdump \
        usbutils \
        vim \
    && \
    ostree container commit

COPY etc/ /etc
COPY usr/ /usr
RUN chmod 700 /etc/kubeadm.conf.d && \
    ostree container commit

# enable services
RUN systemctl enable \
        containerd.service \
        etc-kubernetes.mount \
        kubelet.service \
    && \
    ostree container commit
