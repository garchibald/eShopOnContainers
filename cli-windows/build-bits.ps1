Param([string] $rootPath,
[bool] $deleteContainers = $False
)
$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path

Write-Host "Current script directory is $scriptPath" -ForegroundColor Yellow

if ([string]::IsNullOrEmpty($rootPath)) {
    $rootPath = "$scriptPath\.."
}
Write-Host "Root path used is $rootPath" -ForegroundColor Yellow

Write-Host "Restoring SNI dll" -ForegroundColor Yellow
If (Test-Path "nuget.exe") {
}
else
{
$sourceNugetExe = "https://dist.nuget.org/win-x86-commandline/latest/nuget.exe"
Invoke-WebRequest $sourceNugetExe -OutFile "nuget.exe"
}
.\nuget.exe install runtime.win7-x64.runtime.native.System.Data.SqlClient.sni -Version 4.4.0-beta-25007-02 -Source https://dotnet.myget.org/F/dotnet-core/api/v3/index.json
$patchSni = $scriptPath + "\runtime.win7-x64.runtime.native.System.Data.SqlClient.sni.4.4.0-beta-25007-02\runtimes\win7-x64\native\sni.dll"

$projectPaths = 
    @{Path="$rootPath\src\Web\WebMVC";Prj="WebMVC.csproj"},
    @{Path="$rootPath\src\Web\WebSPA";Prj="WebSPA.csproj"},
    @{Path="$rootPath\src\Services\Identity\Identity.API";Prj="Identity.API.csproj"},
    @{Path="$rootPath\src\Services\Catalog\Catalog.API";Prj="Catalog.API.csproj"},
    @{Path="$rootPath\src\Services\Ordering\Ordering.API";Prj="Ordering.API.csproj"},
    @{Path="$rootPath\src\Services\Basket\Basket.API";Prj="Basket.API.csproj"},
    @{Path="$rootPath\src\Services\Locations\Locations.API";Prj="Locations.API.csproj"},
    @{Path="$rootPath\src\Services\Marketing\Marketing.API";Prj="Marketing.API.csproj"},
    @{Path="$rootPath\src\Services\GracePeriod\GracePeriod.API";Prj="GracePeriod.API.csproj"},
    @{Path="$rootPath\src\Web\WebStatus";Prj="WebStatus.csproj"}

$projectPaths | foreach {
    $projectPath = $_.Path
    $projectFile = $_.Prj
    $outPath = $_.Path + "\obj\Docker\publish"
    $projectPathAndFile = "$projectPath\$projectFile"
    $sniFile = $_.Path + "\obj\Docker\publish\runtimes\win7-x64\native\sni.dll"
    Write-Host "Deleting old publish files in $outPath" -ForegroundColor Yellow
    remove-item -path $outPath -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "Publishing $projectPathAndFile to $outPath" -ForegroundColor Yellow
    dotnet restore $projectPathAndFile
    dotnet build $projectPathAndFile
    dotnet publish $projectPathAndFile -o $outPath
    if ( Test-path $sniFile ) {
        Write-Host "Applying Patch SNI dll  $sniFile" -ForegroundColor Yellow
        Copy-Item -path $patchSni -Destination $sniFile -Force
    }
}


########################################################################################
# Delete old eShop Docker images
########################################################################################

if ( $deleteContainers -eq $true )
{
    $imagesToDelete = docker images --filter=reference="eshop/*" -q

    If (-Not $imagesToDelete) {Write-Host "Not deleting eShop images as there are no eShop images in the current local Docker repo."} 
    Else 
    {
        # Delete all containers
        Write-Host "Deleting all containers in local Docker Host"
        docker rm $(docker ps -a -q) -f
    
        # Delete all eshop images
        Write-Host "Deleting eShop images in local Docker repo"
        Write-Host $imagesToDelete
        docker rmi $(docker images --filter=reference="eshop/*" -q) -f
    }
}

# WE DON'T NEED DOCKER BUILD AS WE CAN RUN "DOCKER-COMPOSE BUILD" OR "DOCKER-COMPOSE UP" AND IT WILL BUILD ALL THE IMAGES IN THE .YML FOR US
