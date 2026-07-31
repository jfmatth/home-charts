# Requires: Helm, PowerShell 7+, and a values.yaml for Cilium

# --- CONFIG ---
$CiliumVersion = "1.16.3"   # Example version
$ValuesFile    = ".\cilium-values.yaml"
$PatchOut      = ".\controlplane-cilium-patch.yaml"

# --- RENDER CILIUM MANIFEST ---
$Rendered = helm template cilium cilium/cilium `
    --version $CiliumVersion `
    --namespace kube-system `
    --set ipam.mode=kubernetes `
    --set kubeProxyReplacement=false `
    --set securityContext.capabilities.ciliumAgent="{CHOWN,KILL,NET_ADMIN,NET_RAW,IPC_LOCK,SYS_ADMIN,SYS_RESOURCE,DAC_OVERRIDE,FOWNER,SETGID,SETUID}" `
    --set securityContext.capabilities.cleanCiliumState="{NET_ADMIN,SYS_ADMIN,SYS_RESOURCE}" `
    --set cgroup.autoMount.enabled=false `
    --set cgroup.hostRoot=/sys/fs/cgroup

if (-not $Rendered) {
    Write-Error "Helm did not produce any output."
    exit 1
}

# --- ESCAPE YAML FOR INLINE MANIFEST ---
# Talos inlineManifests require literal block indentation.
# We indent every line by 6 spaces under `contents: |`
$Indented = ($Rendered -split "`n" | ForEach-Object { "      $_" }) -join "`n"

# --- BUILD TALOS PATCH ---
$Patch = @"
cluster:
  inlineManifests:
    - name: cilium
      contents: |
$Indented
"@

# --- WRITE FILE ---
Set-Content -Path $PatchOut -Value $Patch -Encoding UTF8

Write-Host "Generated patch file: $PatchOut"
