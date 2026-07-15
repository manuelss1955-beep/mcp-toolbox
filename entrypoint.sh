#!/bin/sh
# ============================================================
# Entrypoint para MCP Toolbox for Databases en Railway
# 
# Variables de entorno configurables:
#   PORT              - Puerto de escucha (default: 5000)
#   ADDRESS           - Dirección de escucha (default: 0.0.0.0)
#   ALLOWED_ORIGINS   - Orígenes CORS permitidos (default: *)
#   ALLOWED_HOSTS     - Hosts permitidos (default: *)
#   CONFIG_FILE       - Ruta del archivo de configuración (default: /app/tools.yaml)
# ============================================================

# Valores por defecto
PORT="${PORT:-5000}"
ADDRESS="${ADDRESS:-0.0.0.0}"
ALLOWED_ORIGINS="${ALLOWED_ORIGINS:-*}"
ALLOWED_HOSTS="${ALLOWED_HOSTS:-*}"
CONFIG_FILE="${CONFIG_FILE:-/app/tools.yaml}"

# Construir comando
CMD="/toolbox --config ${CONFIG_FILE} --ui --address ${ADDRESS} --port ${PORT} --allowed-origins ${ALLOWED_ORIGINS} --allowed-hosts ${ALLOWED_HOSTS}"

echo "🚀 Starting MCP Toolbox with:"
echo "   Config:      ${CONFIG_FILE}"
echo "   Address:     ${ADDRESS}"
echo "   Port:        ${PORT}"
echo "   Origins:     ${ALLOWED_ORIGINS}"
echo "   Hosts:       ${ALLOWED_HOSTS}"

exec ${CMD}