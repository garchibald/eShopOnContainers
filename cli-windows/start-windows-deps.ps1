Param(
[bool] $containersLoaded = $false,
[string] $rootPath
)
$scriptPath = Split-Path $script:MyInvocation.MyCommand.Path
if ([string]::IsNullOrEmpty($rootPath)) {
    $rootPath = "$scriptPath\.."
}
Write-Host "Root path used is $rootPath" -ForegroundColor Yellow

if ( $containersLoaded -eq $false )
{
    pushd $rootPath

    docker-compose -f docker-compose-windows-deps.yml  up --force-recreate

    popd
}
else
{
    $databases = "CatalogDb", "IdentityDb", "OrderingDb", "MarketingDb"

    Foreach ($d in $databases)
    {
        $drop = "IF ( NOT EXISTS ( SELECT * FROM sysdatabases WHERE name = '" + $d + "' ) ) BEGIN DROP DATABASE [Microsoft.eShopOnContainers.Services." + $d + "] END"
        Write-Host $drop
        docker exec -i sql.data "C:\Program Files\microsoft sql server\140\tools\binn\osql" -U sa -P Pass@word -Q $drop
        $create = "CREATE DATABASE [Microsoft.eShopOnContainers.Services." + $d + "]"
        Write-Host $create
        docker exec -i sql.data "C:\Program Files\microsoft sql server\140\tools\binn\osql" -U sa -P Pass@word -Q $create
    }

    $inspect = docker inspect rabbitmq | ConvertFrom-Json

    $rabbitIP = $inspect.NetWorkSettings.Networks.nat.IPAddress

    $rabbitAdmin = 'http://' + $rabbitIP + ":15672"

    Write-Host "Opening Rabbit Admin Page - Username/Password - guest/guest"
    start $rabbitAdmin

    $replace = $rabbitIP
    $envFile = $rootPath + "\.env"

    if ( Test-Path $envFile )
    {
        $data =[io.file]::ReadAllText($envFile)

        if ($data -match "ESHOP_EVENT_BUS_CONNECTION") 
        {
            $newIp = "ESHOP_EVENT_BUS_CONNECTION=" + $replace
	        $data = $data -replace 'ESHOP_EVENT_BUS_CONNECTION=(.*)',$newIp
        }

        $Utf8NoBomEncoding = New-Object System.Text.UTF8Encoding $False
        [System.IO.File]::WriteAllLines($envFile, $data, $Utf8NoBomEncoding)
    }
}