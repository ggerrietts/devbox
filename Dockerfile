FROM docker/sandbox-templates:claude-code-docker
USER root
RUN apt-get update && apt-get install -y protobuf-compiler
USER agent
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
RUN echo '. "$HOME/.cargo/env"' >> /etc/sandbox-persistent.sh
