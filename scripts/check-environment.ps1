# ShopyHapy - read-only development environment check (Windows PowerShell).
# Prints versions of the tools the project needs. Installs nothing, changes nothing.
#
# Run from the repository root:
#   powershell -ExecutionPolicy Bypass -File .\scripts\check-environment.ps1
#
# Required versions (see documentation\ENVIRONMENT_REPORT.md):
#   Java 21 LTS, Maven 3.9+, Node ^22.22.3 or ^24.15.0, npm 10+, MySQL 8.4 LTS or Docker Desktop,
#   Git, optionally Angular CLI 22.x, Ionic CLI, Capacitor CLI (project-local), Android SDK.
#   iOS builds require a Mac (Xcode) or a CI macOS runner.

function Check-Tool {
    param([string]$Label, [string]$Command, [string[]]$Arguments)
    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $cmd) {
        "{0,-22}NOT FOUND" -f $Label
        return
    }
    try {
        $output = & $Command @Arguments 2>&1 | Where-Object { $_ -notmatch '^Picked up' } | Select-Object -First 1
        "{0,-22}{1}" -f $Label, $output
    } catch {
        "{0,-22}ERROR: {1}" -f $Label, $_.Exception.Message
    }
}

"== ShopyHapy environment check =="
"OS: " + [System.Environment]::OSVersion.VersionString

Check-Tool "java"           "java"   @("-version")
Check-Tool "javac"          "javac"  @("-version")
Check-Tool "mvn"            "mvn"    @("-version")
Check-Tool "node"           "node"   @("-v")
Check-Tool "npm"            "npm"    @("-v")
Check-Tool "ng (Angular)"   "ng"     @("version")
Check-Tool "ionic"          "ionic"  @("--version")
Check-Tool "git"            "git"    @("--version")
Check-Tool "docker"         "docker" @("--version")
Check-Tool "mysql client"   "mysql"  @("--version")
Check-Tool "mysqld"         "mysqld" @("--version")

""
"JAVA_HOME=" + $(if ($env:JAVA_HOME) { $env:JAVA_HOME } else { "<unset>" })
"ANDROID_HOME=" + $(if ($env:ANDROID_HOME) { $env:ANDROID_HOME } else { "<unset>" }) +
    "  ANDROID_SDK_ROOT=" + $(if ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { "<unset>" })

if (Get-Command node -ErrorAction SilentlyContinue) {
    $v = [version]((node -v).TrimStart('v'))
    $ok = ($v.Major -eq 22 -and ($v.Minor -gt 22 -or ($v.Minor -eq 22 -and $v.Build -ge 3))) -or
          ($v.Major -eq 24 -and $v.Minor -ge 15) -or ($v.Major -ge 26)
    "Node satisfies Angular 22.2 requirement (^22.22.3 || ^24.15.0 || >=26): " + $(if ($ok) { "YES" } else { "NO" })
}
