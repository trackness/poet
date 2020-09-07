param(
    [Parameter(Mandatory)][string]$ProjectName
)

Clear-Host

$Prefix = "Poet | $ProjectName |"
$StartDir = Get-Location

Write-Host $Prefix Creating new project at $StartDir\$ProjectName
poetry new $ProjectName | Out-Null
Set-Location $ProjectName

Write-Host $Prefix "Adding project dependencies"
$json = Get-Content -Raw -Path $PSScriptRoot/common/dependencies.json | ConvertFrom-Json
$quiet = If ($json.quiet -eq "true") {" --quiet"} Else {""}
$dependencies = @()
foreach ($env in $json.env.PSObject.Properties) {
    foreach ($action in $env.Value.PSObject.Properties) {
        $dev = If ($env.Name -eq "dev") {"--dev "} Else {""}
        foreach ($group in $action.Value.PSObject.Properties) {
            $dependencies += [PSCustomObject]@{
                Env = $env.Name
                Action = $action.Name
                Group = $group.Name
                Dependencies = $group.Value
            }
            Invoke-Expression -Command $("poetry {0} {1}{2}{3}" -f $action.Name, $dev, $group.Value, $quiet)
        }
    }
}
$dependencies | Format-Table -AutoSize 

mkdir tests\resources | Out-Null

Write-Host $Prefix "Setting license and readme"
Copy-Item $PSScriptRoot/common/LICENSE | Out-Null
Copy-Item $PSScriptRoot/common/README.md | Out-Null

Write-Host $Prefix "Initialising git repo"
poetry run git init | Out-Null
Remove-Item "README.rst" -Recurse -Force

Write-Host $Prefix "making initial commit"
poetry run git add . | Out-Null
poetry run git commit -m "initial commit" | Out-Null

$Poetryenv = poetry env info --path
Write-Host $Prefix "Virtualenv location:" $Poetryenv

# Get-Content -Raw -Path "pyproject.toml" | Write-Host
# Write-Host $Prefix "Output structure:"
# tree /f
# Set-Location $StartDir
# Remove-Item $ProjectName -Recurse -Force

Write-Host $Prefix "Composition complete."
