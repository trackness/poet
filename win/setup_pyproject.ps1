param(
[Parameter(Mandatory=$true)][string]$ExtPrefix
)

$Prefix = $ExtPrefix+" -"
$SubPrefix = $Prefix+" -"

poetry remove --dev pytest --quiet

Write-Host $Prefix "prod dependencies"
# Write-Host $SubPrefix "___: ___"
# poetry add ___ --quiet

Write-Host $Prefix "dev dependencies"
Write-Host $SubPrefix "imports: isort"
poetry add --dev isort -E pyproject --quiet
Write-Host $SubPrefix "formatting: "
poetry add --dev black --allow-prereleases --quiet
Write-Host $SubPrefix "unit testing: "
poetry add --dev pytest pytest-mock xdoctest --quiet
Write-Host $SubPrefix "test coverage: "
poetry add pytest-cov coverage --quiet
Write-Host $SubPrefix "test automation: "
poetry add tox --quiet
Write-Host $SubPrefix "styling: "
poetry add flake8 flake8-docstrings darglint pydocstyle --quiet
Write-Host $SubPrefix "documentation: "
poetry add sphinx sphinx_rtd_theme --quiet
Write-Host $SubPrefix "release: "
poetry add towncrier --quiet
