FROM quay.io/fedora/fedora-coreos:stable

# extra packages
COPY etc/yum.repos.d/ /etc/yum.repos.d
RUN rpm-ostree install \
        butane \
        dmidecode \
        etcd \
        kubeadm \
        kubectl \
        kubelet \
        iperf3 \
        man-db \
        man-pages \
        mtr \
        squid \
        tcpdump \
        usbip \
        usbutils \
        vim \
    && \
    ostree container commit

COPY etc/ /etc
COPY usr/ /usr

# enable services
RUN systemctl enable \
        containerd.service \
        etc-kubernetes.mount \
        kubelet.service \
        squid.service \
        usbip-server.service \
    && \
    ostree container commit

# Allow (default) lvm autodiscovery that CoreOS conservatively disables.
# Otherwise, re-provisions result in Ceph being unable to re-open the bluestore lvm2
# https://github.com/coreos/fedora-coreos-tracker/issues/1517
RUN rm /etc/lvm/devices/system.devices
