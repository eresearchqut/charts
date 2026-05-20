#!/usr/bin/env bash
# Generate placeholder Kubernetes Secret YAML files for SOPS encryption.
#
# The chart uses <fullname> as the prefix for default secret names:
#   <fullname>-database   (for database.secretName)
#   <fullname>-secrets    (for component secretName)
#
# <fullname> is the chart fullname, typically <release>-component-based-app
# unless overridden via fullnameOverride or nameOverride.
#
# Usage:
#   ./generate-secrets.sh <fullname> [app-secret-keys...]
#
# Examples:
#   ./generate-secrets.sh myapp-component-based-app
#   ./generate-secrets.sh myapp-component-based-app django-secret-key api-token
#
#   # Pipe directly to SOPS:
#   ./generate-secrets.sh myapp-component-based-app | sops encrypt --input-type yaml --output-type yaml /dev/stdin > secrets.enc.yaml
#
# Edit the generated placeholders before encrypting.

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <fullname> [app-secret-keys...]"
  echo ""
  echo "  fullname          Chart fullname (e.g. myapp-component-based-app)"
  echo "  app-secret-keys   Secret key names for the application secret"
  echo ""
  echo "Examples:"
  echo "  $0 myapp-component-based-app"
  echo "  $0 myapp-component-based-app django-secret-key api-token redis-password"
  exit 1
fi

FULLNAME="$1"
shift

# --- Database secret ---
DB_SECRET="${FULLNAME}-database.yaml"
cat > "$DB_SECRET" <<YAML
apiVersion: v1
kind: Secret
metadata:
  name: ${FULLNAME}-database
  labels:
    app.kubernetes.io/name: ${FULLNAME}
type: Opaque
data:
  username: $(echo -n "CHANGE_ME" | base64)
  password: $(echo -n "CHANGE_ME" | base64)
YAML
echo "Created: $DB_SECRET"

# --- Application secret ---
if [ $# -gt 0 ]; then
  APP_SECRET="${FULLNAME}-secrets.yaml"
  {
    printf 'apiVersion: v1\n'
    printf 'kind: Secret\n'
    printf 'metadata:\n'
    printf '  name: %s-secrets\n' "$FULLNAME"
    printf '  labels:\n'
    printf '    app.kubernetes.io/name: %s\n' "$FULLNAME"
    printf 'type: Opaque\n'
    printf 'data:\n'
    for key in "$@"; do
      printf '  %s: %s\n' "$key" "$(echo -n "CHANGE_ME" | base64)"
    done
  } > "$APP_SECRET"
  echo "Created: $APP_SECRET"
fi

echo ""
echo "Next steps:"
echo "  1. Edit each file and replace CHANGE_ME values"
echo "  2. Encrypt with SOPS:"
echo "     sops encrypt --input-type yaml --output-type yaml ${FULLNAME}-database.yaml > ${FULLNAME}-database.enc.yaml"
echo "     sops encrypt --input-type yaml --output-type yaml ${FULLNAME}-secrets.yaml > ${FULLNAME}-secrets.enc.yaml"
echo "  3. Apply to cluster:"
echo "     kubectl apply -f ${FULLNAME}-database.enc.yaml"
echo "     kubectl apply -f ${FULLNAME}-secrets.enc.yaml"
