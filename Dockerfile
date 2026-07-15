# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# ============================================================
# Dockerfile para MCP Toolbox for Databases (Google)
# Modificado para Railway:
#   - Incluye tools.yaml con configuracion MongoDB
#   - Entrypoint script con variables de entorno
#   - Toolbox UI habilitada
# ============================================================

FROM --platform=$BUILDPLATFORM golang:1 AS build

# Install Zig for CGO cross-compilation
RUN apt-get update && apt-get install -y xz-utils
RUN curl -fL "https://ziglang.org/download/0.15.2/zig-x86_64-linux-0.15.2.tar.xz" -o zig.tar.xz && \
    mkdir -p /zig && \
    tar -xf zig.tar.xz -C /zig --strip-components=1 && \
    rm zig.tar.xz

WORKDIR /go/src/mcp-toolbox
COPY . .
ARG TARGETOS
ARG TARGETARCH
ARG BUILD_TYPE="container.dev"
ARG COMMIT_SHA=""
RUN go get ./...
RUN export ZIG_TARGET="" && \
    case "${TARGETARCH}" in \
    ("amd64") ZIG_TARGET="x86_64-linux-gnu";; \
    ("arm64") ZIG_TARGET="aarch64-linux-gnu";; \
    (*) echo "Unsupported architecture: ${TARGETARCH}" && exit 1;; \
    esac && \
    CGO_ENABLED=1 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    CC="/zig/zig cc -target ${ZIG_TARGET}" \
    CXX="/zig/zig c++ -target ${ZIG_TARGET}" \
    go build \
    -ldflags "-X github.com/googleapis/mcp-toolbox/cmd.buildType=${BUILD_TYPE} -X github.com/googleapis/mcp-toolbox/cmd.commitSha=${COMMIT_SHA}" \
    -o mcp-toolbox .

# Final Stage - usando debian slim para tener shell y poder usar variables de entorno
FROM debian:bookworm-slim
WORKDIR /app

# Crear usuario no-root
RUN groupadd -r nonroot && useradd -r -g nonroot -d /app -s /sbin/nologin nonroot

# Copiar binario compilado
COPY --from=build /go/src/mcp-toolbox/mcp-toolbox /toolbox

# Copiar configuracion y entrypoint
COPY tools.yaml /app/tools.yaml
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Dar permisos al usuario nonroot
RUN chown -R nonroot:nonroot /app

USER nonroot
LABEL io.modelcontextprotocol.server.name="io.github.googleapis/mcp-toolbox"

ENTRYPOINT ["/app/entrypoint.sh"]