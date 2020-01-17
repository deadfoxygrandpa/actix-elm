FROM rust as cargo-build

RUN apt-get update

RUN apt-get install musl-tools -y

RUN rustup target add x86_64-unknown-linux-musl

WORKDIR /usr/src/dokku-test

COPY Cargo.toml Cargo.toml

RUN mkdir src/

COPY src/. src/.

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

RUN chown dokku-test:dokku-test dokku-test

USER dokku-test


CMD ["./dokku-test"]
