#!/usr/bin/env bash
# ShopyHapy – read-only development environment check (macOS / Linux).
# Prints versions of the tools the project needs. Installs nothing, changes nothing.
#
# Required versions (see documentation/ENVIRONMENT_REPORT.md):
#   Java 21 LTS, Maven 3.9+, Node ^22.22.3 or ^24.15.0, npm 10+, MySQL 8.4 LTS or Docker,
#   Git, optionally Angular CLI 22.x, Ionic CLI, Capacitor CLI (project-local), Android SDK, Xcode (macOS only).

check() {
  local label="$1"; shift
  printf '%-22s' "$label"
  if command -v "$1" >/dev/null 2>&1; then
    "$@" 2>&1 | grep -v '^Picked up' | head -n 1
  else
    echo "NOT FOUND"
  fi
}

echo "== ShopyHapy environment check =="
echo "OS: $(uname -sr)"
check "java"            java -version
check "javac"           javac -version
check "mvn"             mvn -version
check "node"            node -v
check "npm"             npm -v
check "ng (Angular)"    ng version
check "ionic"           ionic --version
check "git"             git --version
check "docker"          docker --version
check "docker compose"  docker compose version
check "mysql client"    mysql --version
check "mysqld"          mysqld --version
check "redis-server"    redis-server --version
check "nginx"           nginx -v

echo
echo "JAVA_HOME=${JAVA_HOME:-<unset>}"
echo "ANDROID_HOME=${ANDROID_HOME:-<unset>}  ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-<unset>}"

if command -v node >/dev/null 2>&1; then
  node -e '
    const [maj, min, pat] = process.versions.node.split(".").map(Number);
    const ok = (maj === 22 && (min > 22 || (min === 22 && pat >= 3))) ||
               (maj === 24 && min >= 15) || maj >= 26;
    console.log("Node satisfies Angular 22.2 requirement (^22.22.3 || ^24.15.0 || >=26): " + (ok ? "YES" : "NO"));
  '
fi

if [ "$(uname -s)" = "Darwin" ]; then
  check "xcodebuild" xcodebuild -version
fi
