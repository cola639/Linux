#!/usr/bin/env bash
set -Eeuo pipefail

# =========================
# One-file Let's Encrypt setup (Certbot + Auto-renew)
# Run: sudo ./setup.sh
# NOTE: This version DOES NOT generate/modify any Nginx conf.
# You must ensure your Nginx already serves:
#   /.well-known/acme-challenge/  ->  /var/www/letsencrypt
# =========================

log() { echo "[$(date '+%F %T')] $*"; }
die() { echo "ERROR: $*" >&2; exit 1; }

require_root() {
  [[ "${EUID}" -eq 0 ]] || die "Please run as root: sudo ./setup.sh"
}

install_certbot() {
  log "Installing certbot..."

  apt-get update -y
  if apt-get install -y certbot cron; then
    return
  fi

  log "APT certbot install failed. Trying snap certbot..."
  apt-get install -y snapd cron
  snap install core >/dev/null 2>&1 || true
  snap refresh core >/dev/null 2>&1 || true
  snap install --classic certbot
  ln -sf /snap/bin/certbot /usr/bin/certbot
}

read_inputs() {
  echo
  read -rp "Email for Let's Encrypt (e.g. you@example.com): " LE_EMAIL
  [[ -n "${LE_EMAIL}" ]] || die "Email is required."

  echo
  echo "Enter domains (space-separated), e.g.:"
  echo "  example.com www.example.com minio.example.com"
  read -rp "Domains: " LE_DOMAINS
  [[ -n "${LE_DOMAINS}" ]] || die "Domains are required."

  CERT_NAME="$(awk '{print $1}' <<<"${LE_DOMAINS}")"

  echo
  read -rp "Cert output dir (default /www/cert): " OUT_DIR
  OUT_DIR="${OUT_DIR:-/www/cert}"

  echo
  read -rp "Private key filename (default privkey.pem): " OUT_KEY_NAME
  OUT_KEY_NAME="${OUT_KEY_NAME:-privkey.pem}"

  read -rp "Certificate filename (default fullchain.pem): " OUT_CRT_NAME
  OUT_CRT_NAME="${OUT_CRT_NAME:-fullchain.pem}"

  KEY_OUT="${OUT_DIR}/${OUT_KEY_NAME}"
  CRT_OUT="${OUT_DIR}/${OUT_CRT_NAME}"

  echo
  read -rp "Reload command after renew (default: systemctl reload nginx). Use 'true' for none: " RELOAD_CMD
  RELOAD_CMD="${RELOAD_CMD:-systemctl reload nginx}"

  # Webroot used for HTTP-01 (must match your Nginx config)
  WEBROOT="/var/www/letsencrypt"

  log "Cert name: ${CERT_NAME}"
  log "Domains:   ${LE_DOMAINS}"
  log "Webroot:   ${WEBROOT}"
  log "Key out:   ${KEY_OUT}"
  log "Crt out:   ${CRT_OUT}"
  log "Reload:    ${RELOAD_CMD}"
}

ensure_webroot() {
  log "Creating webroot: /var/www/letsencrypt/.well-known/acme-challenge"
  mkdir -p /var/www/letsencrypt/.well-known/acme-challenge
  chmod 755 /var/www/letsencrypt
}

write_deploy_hook() {
  log "Creating deploy-hook: /usr/local/bin/le_deploy_copy.sh"
  cat > /usr/local/bin/le_deploy_copy.sh <<'HOOK'
#!/usr/bin/env bash
set -Eeuo pipefail

: "${OUT_DIR:?Missing OUT_DIR}"
: "${KEY_OUT:?Missing KEY_OUT}"
: "${CRT_OUT:?Missing CRT_OUT}"
: "${RELOAD_CMD:?Missing RELOAD_CMD}"
: "${RENEWED_LINEAGE:?This script must be called by certbot --deploy-hook}"

mkdir -p "${OUT_DIR}"
chmod 700 "${OUT_DIR}"

# Keep filenames consistent with Let's Encrypt names
cp -f "${RENEWED_LINEAGE}/privkey.pem"   "${KEY_OUT}"
cp -f "${RENEWED_LINEAGE}/fullchain.pem" "${CRT_OUT}"

chmod 600 "${KEY_OUT}"
chmod 644 "${CRT_OUT}"

bash -lc "${RELOAD_CMD}" || true
echo "[deploy-hook] Updated: ${KEY_OUT} and ${CRT_OUT}"
HOOK
  chmod +x /usr/local/bin/le_deploy_copy.sh
}

issue_cert() {
  log "Issuing certificate with Certbot (webroot)..."
  local domain_args=()
  for d in ${LE_DOMAINS}; do
    domain_args+=("-d" "${d}")
  done

  certbot certonly \
    --non-interactive --agree-tos -m "${LE_EMAIL}" \
    --webroot -w "${WEBROOT}" \
    --cert-name "${CERT_NAME}" \
    "${domain_args[@]}"

  log "Copying initial cert to output directory..."
  mkdir -p "${OUT_DIR}"
  chmod 700 "${OUT_DIR}"

  cp -f "/etc/letsencrypt/live/${CERT_NAME}/privkey.pem"   "${KEY_OUT}"
  cp -f "/etc/letsencrypt/live/${CERT_NAME}/fullchain.pem" "${CRT_OUT}"

  chmod 600 "${KEY_OUT}"
  chmod 644 "${CRT_OUT}"

  ls -l "${KEY_OUT}" "${CRT_OUT}"
}

install_cron() {
  log "Installing cron job: /etc/cron.d/certbot-renew"
  cat > /etc/cron.d/certbot-renew <<EOF
SHELL=/bin/bash
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin

# Twice daily; renew only runs when needed.
0 5,17 * * * root OUT_DIR="${OUT_DIR}" KEY_OUT="${KEY_OUT}" CRT_OUT="${CRT_OUT}" RELOAD_CMD="${RELOAD_CMD}" certbot renew --quiet --deploy-hook /usr/local/bin/le_deploy_copy.sh >> /var/log/cron_certbot.log 2>&1
EOF

  chmod 644 /etc/cron.d/certbot-renew
  systemctl enable --now cron
  log "Cron enabled. Logs: /var/log/cron_certbot.log"
}

main() {
  require_root
  install_certbot
  read_inputs
  ensure_webroot
  write_deploy_hook
  issue_cert
  install_cron

  log "Dry-run test (optional):"
  OUT_DIR="${OUT_DIR}" KEY_OUT="${KEY_OUT}" CRT_OUT="${CRT_OUT}" RELOAD_CMD="${RELOAD_CMD}" \
    certbot renew --dry-run --deploy-hook /usr/local/bin/le_deploy_copy.sh || true

  log "DONE."
  log "Your files:"
  log "  ${KEY_OUT}"
  log "  ${CRT_OUT}"
}

main "$@"
