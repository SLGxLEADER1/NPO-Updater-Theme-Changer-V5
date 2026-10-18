# Switch the default theme every NP Optimizer user sees (they pick it up within ~20 minutes).
# (NPO Admin does the same thing with buttons, and can also schedule themes by date.)
#   .\Set-Theme.ps1 Vesak
#   .\Set-Theme.ps1 Halloween -Message "Happy Halloween!" -Push
param([Parameter(Mandatory)][string]$Name, [string]$Message = "", [switch]$Push)
$root = $PSScriptRoot
$src = Join-Path $root "themes\$($Name -replace '\.NPO$','').NPO"
if (!(Test-Path $src)) {
    Write-Host "No theme called '$Name'. Available:"
    Get-ChildItem (Join-Path $root "themes") -Filter *.NPO | ForEach-Object { "  " + $_.BaseName }
    exit 1
}
$live = Join-Path $root "theme.json"
$cur = 0
if (Test-Path $live) { try { $cur = [int](Get-Content $live -Raw | ConvertFrom-Json).version } catch {} }
$t = Get-Content $src -Raw -Encoding UTF8 | ConvertFrom-Json
$t.version = $cur + 1                      # the app re-applies whenever version or name changes
if ($Message) { $t.message = $Message }
[IO.File]::WriteAllText($live, ($t | ConvertTo-Json -Depth 6), (New-Object Text.UTF8Encoding($false)))
Write-Host "theme.json is now '$($t.name)' (version $($t.version))"
if ($Push) {
    git -C $root add theme.json
    git -C $root commit -m "Theme: $($t.name) v$($t.version)"
    git -C $root push
} else { Write-Host "Now: git add theme.json; git commit -m ""theme""; git push   (or re-run with -Push)" }
