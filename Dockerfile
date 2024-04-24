FROM --platform=linux/amd64 almalinux:9

RUN echo 'max_parallel_downloads=10' >> /etc/dnf/dnf.conf && \
	echo 'fastestmirror=True' >> /etc/dnf/dnf.conf && \
	echo 'install_weak_deps=False' >> /etc/dnf/dnf.conf

RUN dnf update -y && dnf clean all

RUN dnf install -y 'dnf-command(config-manager)'

RUN curl -sL https://rpm.nodesource.com/setup_20.x | bash -
RUN dnf config-manager --set-enabled crb

RUN dnf install -y git make cmake ninja-build gcc gcc-c++ clang llvm-toolset nodejs

WORKDIR /opt/gmt
ENTRYPOINT ["/bin/bash"]
