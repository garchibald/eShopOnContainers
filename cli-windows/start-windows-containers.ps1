Param([string] $rootPath,
[bool] $azure = $True,
[bool] $images = $True,
[bool] $build = $false,
[bool] $useEnvironment = $true
)
$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($rootPath)) {
    $rootPath = "$scriptPath\.."
}
Write-Host "Root path used is $rootPath" -ForegroundColor Yellow

if ( $build )
{
	& .\build-bits.ps1 -rootPath $rootPath
}

$composeFile = $rootPath + "\docker-compose-windows.yml"
$overrideFile = $rootPath + "\docker-compose-windows.override.yml"

if ( $azure ) {
	$errors = $false
	if ( Test-Path env:ESHOP_REDIS_CONNECTION ) {
		Write-Host "Using configured ESHOP_REDIS_CONNECTION"
	} else {
		Write-Host "Missing environment variable ESHOP_REDIS_CONNECTION" -ForegroundColor Yellow
		$errors = $True
	}
	
	if ( Test-Path env:ESHOP_EVENT_BUS_CONNECTION ) {
		Write-Host "Using configured ESHOP_EVENT_BUS_CONNECTION"
	} else {
		Write-Host "Missing environment variable ESHOP_EVENT_BUS_CONNECTION" -ForegroundColor Yellow
		$errors = $True
	}
	
	if ( Test-Path env:ESHOP_AZUREDB_CONNECTION ) {
		Write-Host "using configured ESHOP_AZUREDB_CONNECTION"
	} else {
		Write-Host "Missing environment variable ESHOP_AZUREDB_CONNECTION" -ForegroundColor Yellow
		$errors = $True
	}
	
	if ( Test-Path env:AZURE_COSMOSDB ) {
		Write-Host "using configured AZURE_COSMOSDB"
	} else {
		Write-Host "Missing environment variable AZURE_COSMOSDB" -ForegroundColor Yellow
		$errors = $True
	}
	
	if ( Test-Path env:ESHOP_REPOSITORY ) {
		Write-Host "Using configured ESHOP_REPOSITORY " + env:ESHOP_REPOSITORY
	} else {
		Write-Host "NOTE: Missing environment variable ESHOP_REPOSITORY" -ForegroundColor Yellow
	}
	
	if ( Test-Path env:ESHOP_AZURE_DB_PREFIX ) {
		Write-Host "Using configured ESHOP_AZURE_DB_PREFIX $env:ESHOP_AZURE_DB_PREFIX"
	} else {
		Write-Host "NOTE: Missing environment variable ESHOP_AZURE_DB_PREFIX" -ForegroundColor Yellow
	}

	$overrideFile = $rootPath + "\docker-compose-windows.azure.yml"
}

if ( $images ) {
	$composeFile = $rootPath + "\docker-compose-windows-image.yml"
}

Write-Host "Using Tag $env:TAG"
pushd ..

Write-Host "Compose $composeFile"
Write-Host "Compose $overrideFile"

docker-compose -f $composeFile -f $overrideFile  up --force-recreate

popd