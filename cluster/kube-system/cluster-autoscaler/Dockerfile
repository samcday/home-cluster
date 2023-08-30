FROM alpine:3
RUN apk add curl jq
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x kubectl && mv kubectl /bin
RUN wget -O- https://github.com/hetznercloud/cli/releases/download/v1.30.3/hcloud-linux-386.tar.gz | tar -C /bin -zxvf -
RUN wget -O- https://get.k3sup.dev | sh
RUN apk add openssh-client
