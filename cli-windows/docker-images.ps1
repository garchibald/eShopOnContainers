Param(
    [string] $repository,
    [string] $sourceTag = 'dev',
    [string] $destinationTag = 'latest',
    [bool] $tag = $true,
    [string] $operation = "push",
	[string] $resources = "eshop"
)
#-----------------------------------------------------------------
# Docker Image Management script
#
# Common scenarios
#
# 1) Pull common windows container images
#
# .\docker-images.ps1 $null $null $null $false "pull" "common"
#
# 2) Shared container images
#
# .\docker-images.ps1 "your-repository.azurecr.io $null $null $false "pull" "shared"
#
# 3) eshop container images
#
# .\docker-images.ps1 "your-repository.azurecr.io "nanowin" $null $false "pull" "eshop"
#
#-----------------------------------------------------------------

if ( $repository.Length -gt 0 ) {
    $repository = $repository + "/"
}

switch ( $resources )
{
	 "eshop" {
		$images = 
		  @{ name = "eshop/catalog.api" },
		  @{ name = "eshop/ordering.api" },
		  @{ name = "eshop/marketing.api" },
		  @{ name = "eshop/webspa" },
		  @{ name = "eshop/webmvc" },
		  @{ name = "eshop/basket.api" },
		  @{ name = "eshop/identity.api" },
		  @{ name = "eshop/graceperiodmanager" },
		  @{ name = "eshop/payment.api" },
		  @{ name = "eshop/locations.api" },
		  @{ name = "eshop/webstatus" }
	}
	"shared" {
		$images =
		  @{ name = "mongodb" },
		  @{ name = "redis" },
		  @{ name = "rabbitmq" }
	}
	"common" {
		$images =
		  @{ name = "microsoft/windowsservercore" },
		  @{ name = "microsoft/nanoserver" },
		  @{ name = "microsoft/mssql-server-windows" }
	}
}


if ( $resources -eq "pull" ) {
	$tag = $false
}

Write-Host "Images:"

$images

$images  | foreach {
    $source = $_.name
	if ( $sourceTag.Length -gt 0 ) {
		$source = $source + ":" + $sourceTag
	}
	
    $target = $repository + $_.name
	if ( $destinationTag.Length -gt 0 ) {
		$target = $target + ":" +$destinationTag
	}
	
    if ( $tag ) {
        Write-Host "Tag $source $target"
        docker tag $source $target
    }

	switch ( $operation )
	{
		"push" {
            Write-Host "Push $target"
			docker push $target
		}
		
		"pull" {
            $source = $repository + $source
            Write-Host "Pull $source"
			docker pull $source
		}
	}
}
