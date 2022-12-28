Select-AzSubscription -SubscriptionName '<Subscription Name>'  # Enter Subscription Name

$InputCSVFilePath = "Filename.csv" # Enter File name with path

################
#
# Bulk Tagging of Multiple Azure VM's with different Key & Value. 
#
################

$csvItems = Import-Csv $InputCSVFilePath

################

#Start loop

foreach ($item in $csvItems)
{
   
    Clear-Variable $r

    $r = Get-AzureRmResource -ResourceGroupName $item.ResourceGroup -Name $item.VMName -ErrorAction Continue

    ################ 

    if ($r -ne $null)
    {
        if ($r.Tags)
        {


            
            # Tag - CostCenter

            if ($r.Tags.ContainsKey("CostCenter"))
            {
                $r.Tags["CostCenter"] = $item.CostCenter
            }
            else
            {
                $r.Tags.Add("CostCenter", $item.CostCenter)
            }

             # Tag - Environment Type

             if ($r.Tags.ContainsKey("EnvironmentType"))
             {
                 $r.Tags["EnvironmentType"] = $item.EnvironmentType
             }
             else
             {
                 $r.Tags.Add("EnvironmentType", $item.EnvironmentType)
             }

            
           
            
            #Setting the tags on the resource

            Set-AzureRmResource -Tag $r.Tags -ResourceId $r.ResourceId -Force
        }

        else
        {
            #Setting the tags on a resource which doesn't have tags

            Set-AzureRmResource -Tag @{ CostCenter = $CostCenter; EnvironmentType = $EnvironmentType } -ResourceId $r.ResourceId -Force
        }
    }
    else
    {
        Write-Host "No VM found named $($item.VMName) in ResourceGroup $($item.ResourceGroup)!"
    }
}