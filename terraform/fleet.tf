# Fleet Manager and members will be created via CLI after Terraform deploy
# (azurerm provider has a bug with hub_profile)
#
# CLI steps post-deploy:
#   az fleet create -g <rg> -n <fleet> -l australiaeast --enable-hub
#   az fleet member create ... (x3)
#   az fleet updatestrategy create ...
