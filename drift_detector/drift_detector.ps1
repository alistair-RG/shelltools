$filename =$args[0]
$ip = Get-Content $filename -Raw | convertfrom-json
# Extract all the objects that are drift reports
$drifts = $ip.individualResults | where-Object operation -eq "drift"
# check if there is anything in the list and look at the status of the last item in the list (most recent drift report)
if ( ($null -ne $drifts ) -and ($drifts[-1].driftDetected -eq "True") )
{
    Write-Output "Drift detected"
    exit 1
} else {
    exit 0
}