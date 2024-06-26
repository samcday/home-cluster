FROM ghcr.io/samcday/workstation-config:main

COPY etc/ /etc
COPY usr/ /usr

RUN systemctl enable \
        containerd.service \
        kubelet.service \
    && \
    ostree container commit

RUN systemctl disable \
    firewalld.service \
    && \
    ostree container commit
