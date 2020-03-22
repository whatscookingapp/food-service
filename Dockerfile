# Build image
FROM swiftlang/swift:nightly-5.2-xenial as builder
RUN apt-get -qq update && apt-get install -y \
  libssl-dev libicu-dev zlib1g-dev
WORKDIR /App
COPY . .

RUN mkdir -p /build/lib && cp -R /usr/lib/swift/linux/*.so* /build/lib
RUN swift build -c release && mv `swift build -c release --show-bin-path` /build/bin

# Slim image
FROM ubuntu:18.04
RUN apt-get -qq update && apt-get install -y \
  libicu60 libxml2 libbsd0 libcurl4 libatomic1 libssl1.1 \
  tzdata \
  && rm -r /var/lib/apt/lists/*
WORKDIR /App
COPY --from=builder /build/bin/Run .
COPY --from=builder /build/lib/* /usr/lib/
EXPOSE 8080
ENTRYPOINT ./Run serve --auto-migrate -e prod -b 0.0.0.0