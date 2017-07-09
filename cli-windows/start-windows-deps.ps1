Param(
[bool] $containersLoaded = $false
)

if ( $containersLoaded -eq $false )
{
    docker-compose -f docker-compose-windows-deps.yml  up --force-recreate
}
else
{
    $databases = "CatalogDb", "IdentityDb", "OrderingDb", "MarketingDb"

    Foreach ($d in $databases)
    {
        $drop = "IF ( NOT EXISTS ( SELECT * FROM sysdatabases WHERE name = '[Microsoft.eShopOnContainers.Services." + $d + "]' ) ) BEGIN DROP DATABASE [Microsoft.eShopOnContainers.Services." + $d + "] END"
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
}