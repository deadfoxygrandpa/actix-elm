FROM rust as cargo-build

# Install base dependencies

RUN apt-get update

RUN apt-get install musl-tools -y

# rust

RUN rustup target add x86_64-unknown-linux-musl

# elm

RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz

RUN gunzip elm.gz

RUN chmod +x elm

RUN mv elm /usr/local/bin/

# set up compile environment

WORKDIR /usr/src/dokku-test

COPY Cargo.toml Cargo.toml

RUN mkdir server/

RUN mkdir frontend/

RUN mkdir static/

COPY server/. server/.

COPY frontend/. frontend/.

COPY static/. static/.

COPY migrations/. migrations/.

COPY build.rs build.rs

COPY elm.json elm.json

RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl

RUN rm -f target/x86_64-unknown-linux-musl/release/deps/dokku-test*

COPY . .

RUN RUSTFLAGS=-Clinker=musl-gcc cargo build --release --target=x86_64-unknown-linux-musl

# uglifyjs build and generate css

FROM node:alpine as uglify-build

RUN npm install uglify-js -g

RUN npm install tailwindcss -g

RUN npm install purgecss -g

WORKDIR /usr/src/dokku-test

COPY frontend/style.css frontend/style.css

COPY package.json package.json

COPY tailwind.config.js tailwind.config.js

COPY purgecss.config.js purgecss.config.js

COPY --from=cargo-build /usr/src/dokku-test/static/elm.js static/elm.js

RUN npm run build:css

RUN npm run purgecss

RUN uglifyjs static/elm.js --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters=true,keep_fargs=false,unsafe_comps=true,unsafe=true,passes=2' --output=static/elm.js && uglifyjs static/elm.js --mangle --output=static/elm.js

# Final Stage

FROM alpine

RUN addgroup -g 1000 dokku-test

RUN adduser -D -s /bin/sh -u 1000 -G dokku-test dokku-test

WORKDIR /home/dokku-test/bin

COPY --from=cargo-build /usr/src/dokku-test/target/x86_64-unknown-linux-musl/release/dokku-test .

COPY --from=cargo-build /usr/src/dokku-test/static/. static/.

# Copy doesn't seem to overwrite, so I need to remove the file first
RUN rm static/elm.js

COPY --from=uglify-build /usr/src/dokku-test/static/elm.js static/elm.js

COPY --from=uglify-build /usr/src/dokku-test/static/style.css static/style.css

COPY --from=cargo-build /usr/src/dokku-test/migrations/. migrations/.

RUN chown dokku-test:dokku-test dokku-test

USER dokku-test


CMD ["./dokku-test"]
