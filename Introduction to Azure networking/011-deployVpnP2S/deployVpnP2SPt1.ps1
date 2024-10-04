Write-Host "Creating variables"
$resourceGroupName = "rg-learn-home"
$resourceGroupLocation = "uksouth"
$virtualNetworkName = "vnet-learn-home"
$virtualNetworkAddress = "192.168.0.0/16"
$subnetName = "snet-learn-home"
$subnetNsgName = "nsg-$subnetName"
$subnetAddress = "192.168.1.0/24"
$virtualMachineName = "vm-learn-home"
$virtualMachineIpName = "$virtualMachineName-ip"
$virtualMachineNicName = "$virtualMachineName-nic"
$virtualMachineDiskName = "$virtualMachineName-disk-os"
$virtualMachineSize = "Standard_B2ms"
$virtualMachineImage = "MicrosoftWindowsDesktop:windows-11:win11-23h2-pro:latest"
$virtualMachineUsername = "learnadmin"
$virtualMachinePassword = "ReplaceMe24!"

Write-Host "Creating resource group: $resourceGroupName"
az group create `
  --name $resourceGroupName `
  --location $resourceGroupLocation `
  --only-show-errors `
  --output None

Write-Host "Creating network security group: $subnetNsgName"
az network nsg create `
  --name $subnetNsgName `
  --resource-group $resourceGroupName `
  --location $resourceGroupLocation `
  --only-show-errors `
  --output None

Write-Host "Retrieving your public IP address"
$yourPublicIp = Invoke-WebRequest -Uri https://ipinfo.io | ConvertFrom-Json

Write-Host "Creating security rule: allow-rdp-inbound"
az network nsg rule create `
  --nsg-name $subnetNsgName `
  --resource-group $resourceGroupName `
  --name allow-rdp-inbound `
  --direction Inbound `
  --priority 100 `
  --access Allow `
  --source-address-prefixes $yourPublicIp.ip `
  --destination-address-prefixes "*" `
  --protocol TCP `
  --destination-port-ranges 3389 `
  --only-show-errors `
  --output None

Write-Host "Creating virtual network: $virtualNetworkName"
az network vnet create `
  --name $virtualNetworkName `
  --resource-group $resourceGroupName `
  --location $resourceGroupLocation `
  --address-prefixes $virtualNetworkAddress `
  --only-show-errors `
  --output None

Write-Host "Creating subnet: $subnetName"
az network vnet subnet create `
  --vnet-name $virtualNetworkName `
  --resource-group $resourceGroupName `
  --name $subnetName `
  --address-prefixes $subnetAddress `
  --network-security-group $subnetNsgName `
  --only-show-errors `
  --output None

Write-Host "Creating public IP address: $virtualMachineIpName"
az network public-ip create `
  --name $virtualMachineIpName `
  --resource-group $resourceGroupName `
  --location $resourceGroupLocation `
  --sku Standard `
  --allocation-method Static `
  --only-show-errors `
  --output None

Write-Host "Creating network interface: $virtualMachineNicName"
az network nic create `
  --name $virtualMachineNicName `
  --resource-group $resourceGroupName `
  --location $resourceGroupLocation `
  --vnet-name $virtualNetworkName `
  --subnet $subnetName `
  --public-ip-address $virtualMachineIpName `
  --only-show-errors `
  --output None

Write-Host "Creating virtual machine: $virtualMachineName"
az vm create `
  --name $virtualMachineName `
  --resource-group $resourceGroupName `
  --location $resourceGroupLocation `
  --size $virtualMachineSize `
  --admin-username $virtualMachineUsername `
  --admin-password $virtualMachinePassword `
  --image $virtualMachineImage `
  --os-disk-name $virtualMachineDiskName `
  --storage-sku StandardSSD_LRS `
  --nics $virtualMachineNicName `
  --no-wait `
  --only-show-errors `
  --output None

Write-Host "Deployment complete"