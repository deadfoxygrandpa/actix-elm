FROM rust as cargo-build

RUN apt-get update

RUN apt-get install musl-tools -y

RUN rustup target add x86_64-unknown-linux-musl

RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz

RUN gunzip elm.gz

RUN chmod +x elm

RUN mv elm /usr/local/bin/

WORKDIR /usr/src/dokku-test

COPY Cargo.toml Cargo.toml

RUN mkdir server/

RUN mkdir frontend/

RUN mkdir static/

COPY server/. server/.

COPY frontend/. frontend/.

COPY static/. static/.

COPY build.rs build.rs

COPY elm.json elm.json

RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl

RUN rm -f target/x86_64-unknown-linux-musl/release/deps/dokku-test*

COPY . .

RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl

# Final Stage

FROM alpine

RUN addgroup -g 1000 dokku-test

RUN adduser -D -s /bin/sh -u 1000 -G dokku-test dokku-test

WORKDIR /home/dokku-test/bin

COPY --from=cargo-build /usr/src/dokku-test/target/x86_64-unknown-linux-musl/release/dokku-test .

COPY --from=cargo-build /usr/src/dokku-test/static/. static/.

RUN chown dokku-test:dokku-test dokku-test

USER dokku-test


CMD ["./dokku-test"]
