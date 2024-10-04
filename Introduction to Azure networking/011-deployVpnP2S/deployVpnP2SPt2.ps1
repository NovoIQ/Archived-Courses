Write-Host "Creating variables"
$resourceGroupHubName = "rg-learn-hub"
$virtualNetworkGatewayName = "gw-learn-hub"
$pointToSiteAddress = "10.96.0.0/24"
$virtualNetwork01Address = "10.1.0.0/16"
$virtualNetwork02Address = "10.2.0.0/16"
$virtualNetwork03Address = "10.3.0.0/16"
$resourceGroupDcName = "rg-learn-dc"
$localNetworkGatewayHubName = "lng-learn-hub"
$virtualNetworkHubAddress = "10.0.0.0/16"

Write-Host "Retrieving tenant ID"
$tenantId = az account show `
  --only-show-errors `
  --query tenantId `
  --output tsv

Write-Host "Creating Entra ID variables"
$vpnTenant = "https://login.microsoftonline.com/$tenantId/"
$vpnIssuer = "https://sts.windows.net/$tenantId/"
$vpnAudience = "c632b3df-fb67-4d84-bdcf-b95ad541b5c8"

Write-Host "Configuring P2S VPN on: $virtualNetworkGatewayName"
az network vnet-gateway update `
  --name $virtualNetworkGatewayName `
  --resource-group $resourceGroupHubName `
  --aad-tenant $vpnTenant `
  --aad-issuer $vpnIssuer `
  --aad-audience $vpnAudience `
  --client-protocol OpenVPN `
  --address-prefix $pointToSiteAddress `
  --custom-routes $virtualNetwork01Address $virtualNetwork02Address $virtualNetwork03Address `
  --only-show-errors `
  --output None

Write-Host "Adding P2S VPN address pool to: $localNetworkGatewayHubName"
az network local-gateway update `
  --name $localNetworkGatewayHubName `
  --resource-group $resourceGroupDcName `
  --address-prefixes $virtualNetworkHubAddress $virtualNetwork01Address $virtualNetwork02Address $virtualNetwork03Address $pointToSiteAddress `
  --only-show-errors `
  --output None

Write-Host "Deployment complete"
