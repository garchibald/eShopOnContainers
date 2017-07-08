Param(
    [string] $repository,
    [string] $sourceTag = 'dev',
    [string] $destinationTag = 'latest',
    [bool] $tag = $true,
    [bool] $push = $false
)

if ( $repository.Length -gt 0 ) {
    $repository = $repository + "/"
}

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

$images  | foreach {
    $source = $_.name + ":" + $sourceTag
    $target = $repository + $_.name + ":" +$destinationTag
    if ( $tag ) {
        docker tag $source $target
    }

    if ( $push ) {
        docker push $target
    }
}
