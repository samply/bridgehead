source ../functions.sh

test_setupProxy() {
  # simple logger for tests
  log() { :; }

  local failures=0
  local total=0

  assert_eq() {
    local label="$1" got="$2" expected="$3"
    total=$((total + 1))
    if [[ "$got" != "$expected" ]]; then
      failures=$((failures + 1))
      printf 'FAIL: %s\n  got:      %q\n  expected: %q\n\n' "$label" "$got" "$expected"
    else
      printf 'ok: %s\n' "$label"
    fi
  }

  run_case() {
    local name="$1"
    local url="$2"
    local u="$3"
    local p="$4"
    local exp_host="$5"
    local exp_port="$6"
    local exp_full="$7"

    HTTPS_PROXY_URL="$url"
    HTTPS_PROXY_USERNAME="$u"
    HTTPS_PROXY_PASSWORD="$p"

    setupProxy >/dev/null 2>&1

    assert_eq "$name host" "$HTTPS_PROXY_HOST" "$exp_host"
    assert_eq "$name port" "$HTTPS_PROXY_PORT" "$exp_port"
    assert_eq "$name full" "$HTTPS_PROXY_FULL_URL" "$exp_full"
  }

  echo "Running setupProxy tests..."
  echo

  # 1) Basic https host:port
  run_case "basic https" \
    "https://proxy.example.org:8443" "" "" \
    "proxy.example.org" "8443" \
    "https://proxy.example.org:8443"

  # 2) https without port -> default 443
  run_case "https no port" \
    "https://proxy.example.org" "" "" \
    "proxy.example.org" "443" \
    "https://proxy.example.org"

  # 3) no scheme, host:port -> defaults scheme=https
  run_case "no scheme hostport" \
    "proxy.example.org:3128" "" "" \
    "proxy.example.org" "3128" \
    "https://proxy.example.org:3128"

  # 4) URL with path/query/fragment
  run_case "ignores path" \
    "https://proxy.example.org:8443/some/path?x=1#y" "" "" \
    "proxy.example.org" "8443" \
    "https://proxy.example.org:8443"

  # 5) explicit env creds inserted
  run_case "env creds override" \
    "https://proxy.example.org:8443" "alice" "secret" \
    "proxy.example.org" "8443" \
    "https://alice:secret@proxy.example.org:8443"

  # 6) embedded creds used if env creds absent
  run_case "embedded creds" \
    "https://bob:pw@proxy.example.org:8443" "" "" \
    "proxy.example.org" "8443" \
    "https://bob:pw@proxy.example.org:8443"

  # 7) env creds override embedded creds
  run_case "env overrides embedded" \
    "https://bob:pw@proxy.example.org:8443" "alice" "secret" \
    "proxy.example.org" "8443" \
    "https://alice:secret@proxy.example.org:8443"

  # 8) IPv6 literal with port
  run_case "ipv6 with port" \
    "https://[2001:db8::1]:8080" "" "" \
    "2001:db8::1" "8080" \
    "https://[2001:db8::1]:8080"

  # 9) IPv6 literal without port -> default 443
  run_case "ipv6 no port" \
    "https://[2001:db8::1]" "" "" \
    "2001:db8::1" "443" \
    "https://[2001:db8::1]"

  # 10) http scheme rejected -> outputs empty
  HTTPS_PROXY_URL="http://proxy.example.org:8080"
  HTTPS_PROXY_USERNAME=""
  HTTPS_PROXY_PASSWORD=""
  setupProxy >/dev/null 2>&1
  assert_eq "http rejected host" "${HTTPS_PROXY_HOST:-}" ""
  assert_eq "http rejected port" "${HTTPS_PROXY_PORT:-}" ""
  assert_eq "http rejected full" "${HTTPS_PROXY_FULL_URL:-}" ""

  # 11) empty URL -> outputs empty but no failure
  HTTPS_PROXY_URL=""
  setupProxy >/dev/null 2>&1
  assert_eq "empty url host" "${HTTPS_PROXY_HOST:-}" ""
  assert_eq "empty url port" "${HTTPS_PROXY_PORT:-}" ""
  assert_eq "empty url full" "${HTTPS_PROXY_FULL_URL:-}" ""

  echo
  echo "Tests complete: $((total - failures))/$total passed."
  if (( failures > 0 )); then
    echo "Some tests failed."
    return 1
  fi
  return 0
}

test_setupProxy
