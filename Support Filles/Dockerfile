FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    build-essential \
    fonts-dejavu-core \
    fonts-noto \
    texlive-xetex \
    texlive-latex-recommended \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-lang-greek \
    latexmk \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

# Default command shows help; user normally will open a shell or build via Makefile
CMD ["/bin/bash"]
