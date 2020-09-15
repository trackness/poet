param(
    [Parameter(Mandatory)][string]$ProjectName
)

Clear-Host

$Prefix = "Poet | $ProjectName |"
$StartDir = Get-Location

Write-Host $Prefix "Creating new project at $StartDir\$ProjectName"
poetry new $ProjectName | Out-Null
Set-Location $ProjectName
$Poetryenv = poetry env info --path
Write-Host $Prefix "Virtualenv location:" $Poetryenv

Write-Host $Prefix "Adding project dependencies"
$json = Get-Content -Raw -Path $PSScriptRoot/dependencies.json | ConvertFrom-Json
$quiet = If ($json.quiet -eq "true") { " --quiet" } Else { "" }
$dependencies = @()
foreach ($env in $json.env.PSObject.Properties) {
    foreach ($action in $env.Value.PSObject.Properties) {
        $dev = If ($env.Name -eq "dev") { "--dev " } Else { "" }
        foreach ($group in $action.Value.PSObject.Properties) {
            $dependencies += [PSCustomObject]@{
                Env          = $env.Name
                Action       = $action.Name
                Group        = $group.Name
                Dependencies = $group.Value
            }
            Invoke-Expression -Command $("poetry {0} {1}{2}{3}" -f $action.Name, $dev, $group.Value, $quiet)
        }
    }
}
$dependencies | Format-Table -AutoSize

mkdir tests\resources | Out-Null

Write-Host $Prefix "Setting license, readme, gitignore, pre-commit config"
Copy-Item $PSScriptRoot/common/* | Out-Null

Write-Host $Prefix "Initialising git repo"
poetry run git init | Out-Null

Write-Host $Prefix "Making initial commit"
poetry run git add . | Out-Null
poetry run git commit -m "initial commit" | Out-Null

Write-Host $Prefix "Installing pre-commit hooks"
poetry run pre-commit install | Out-Null
Write-Host $Prefix "Running pre-commit hooks"
poetry run pre-commit run --all-files

Set-Location $StartDir
Write-Host $Prefix "Composition complete."

# Remove-Item $ProjectName -Recurse -Force
