<#
.SYNOPSIS
Shows when last your PC started up.
.DESCRIPTION
This is a WMI wrapper function to get the time that your PC last started up.
.PARAMETER ComputerName
The name of the Computer you want to run the command against.
.EXAMPLE
Get-LastBootTime -ComputerName localhost
.LINK
www.howtogeek.com
#>

param(
[Parameter(Mandatory=$true)][string]$ProjectName
)

clear

$Prefix = "New-Poem | " + $ProjectName + " |"
$CurrentDir = Get-Location

Write-Host $Prefix "Creating new project at" $CurrentDir"\"$ProjectName
poetry new $ProjectName | Out-Null
Set-Location $ProjectName

Write-Host $Prefix "Adding project dependencies"
Invoke-Expression -Command $PSScriptRoot/setup_pyproject.ps1 $Prefix

mkdir tests\resources | Out-Null

Write-Host $Prefix "Setting license"
Copy-Item $PSScriptRoot/LICENSE | Out-Null

Write-Host $Prefix "Initialising git repo"
poetry run git init | Out-Null

Write-Host $Prefix "making initial commit"
poetry run git add . | Out-Null
poetry run git commit -m "initial commit" | Out-Null

$PoetryEnv = poetry env info --path
Write-Host $Prefix "VirtualEnv location:" $PoetryEnv

# Write-Host $Prefix "Output structure:"
# tree /f
