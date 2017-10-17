#-----------------------------------#
#----Product SKU Code Generator-----#
#-------Created By JD Keith---------#
#-----------10/16/2017--------------#
#-----------------------------------#


#Orchestrator sets variables from Request offering
$OGProductName = "Advanced Package"
$OGPlatform = "AccuNet"
$OGLengthofTime = "20"
$OGUnitofTime = "Year"
$OGDeliveryMethod = "HTTPGet"

#Set Path Variables
$PNPath = "D:\SKU Automation\ProductSKU.txt"
$PLPath = "D:\SKU Automation\PlatformSKU.txt"
$DMPath = "D:\SKU Automation\DeliveryMethodSKU.txt"


#------------------------------------------#
#-----------Start Time SKU-----------------#
#------------------------------------------#


#Set NA variables
if ($OGLengthofTime -eq "NA")
        {$LTime = "ZZ"}

#If not NA, proceed with creating time length skus
    else {
            

#Decide to insert 0 or 00
$x = $OGLengthofTime.length

if ($x -eq "1")  {$LTime = $OGLengthofTime.Insert(0, '00')}

if ($x -eq "2") {$LTime = $OGLengthofTime.Insert(0,'0')}

}

#Same for time unit skus
if ($OGUnitofTime -eq "NA")
       {$UTime = "ZZ"}

#If not NA, trim
    else {

#Trimming Units
if ($OGUnitofTime -eq "Day") 
        {$UTime = "D"}

if ($OGUnitofTime -eq "Week")
        {$UTime = "W"}

if ($OGUnitofTime -eq "Month")
        {$UTime = "M"}

if ($OGUnitofTime -eq "Year")
        {$UTime = "Y"}

}

#Combine Units for SKU
$TimeValue = $LTime+$UTime

#Check if Time Value is longer than 4 characters. If yes, trim to 4.
if ($TimeValue.Length -gt "4") 
        {$TrimValue = $TimeValue.Substring(0, [System.Math]::Min(4, $TimeValue.Length))}
    
    else {$TrimValue = $TimeValue
}

#Do the same if it's less than 4 characters            
if ($TrimValue.Length -lt "4")
        {$TrimValue = $TrimValue.Insert(0, 'Z')}

$StringExists = Select-String -Path "D:\SKU Automation\TimeSKU.txt" -Pattern "$TrimValue"
    if ($StringExists -eq $null) 
        {Add-Content "D:\SKU Automation\TimeSKU.txt" -value $TrimValue}
    else {$TrimValue = $StringExists.Pattern}

#End Time Value SKU


#------------------------------------------#
#--------Start Product Name Sku------------#
#------------------------------------------#


#Remove spaces from product name and generate random characters (can change to alpha-numeric if needed)
$ProductName = $OGProductName.Replace(' ','')
$PNRAddChar = -join ((65..90) | Get-Random -Count 4 | % {[char]$_})

#Find number of matching SKU objects
$StringCount = @(Get-Content $PNPath | Where-Object { $_.Contains($ProductName) }).Count

#Get matching SKU if it exists
if 

    ($StringCount -eq "1")
        
        {$ProductName = Get-Content $PNPath -Filter $ProductName | Where-Object {$_ -match $ProductName}

        }

#Generate new SKU
else

        {$ProductName = Add-Content $PNPath -value $ProductName-$PNRAddChar -PassThru
        
        }

#Trim dash and space
$ProductName = $ProductName.Split("-")[1].Split(" ") 

#End Product Name SKU


#------------------------------------------#
#-----------Start Platform Sku-------------#
#------------------------------------------#


#Set NA variable
if ($OGPlatform -eq "NA")
        {$Platform = "ZZZZ"}

#If not NA, proceed
    else {

$Platform = $OGPlatform.Replace(' ','')
$PLRAddChar = -join ((65..90) | Get-Random -Count 4 | % {[char]$_})

$StringCount = @(Get-Content $PLPath | Where-Object { $_.Contains($Platform) }).Count

if 

    ($StringCount -eq "1")
        
        {$Platform = Get-Content $PLPath -Filter $Platform | Where-Object {$_ -match $Platform}

        }


else

        {$Platform = Add-Content $PLPath -value $Platform-$PLRAddChar -PassThru
        
        }

$Platform = $Platform.Split("-")[1].Split(" ")

}
#End Platform SKU


#------------------------------------------#
#--------Start Delivery Method Sku---------#
#------------------------------------------#


#Set NA variable
if ($OGDeliveryMethod -eq "NA")
        {$DeliveryMethod = "ZZZZ"}

#If not NA, proceed
else {

$DeliveryMethod = $OGDeliveryMethod.Replace(' ','')
$DMRAddChar = -join ((65..90) | Get-Random -Count 4 | % {[char]$_})

$StringCount = @(Get-Content $DMPath | Where-Object { $_.Contains($DeliveryMethod) }).Count

if 

    ($StringCount -eq "1")
        
        {$DeliveryMethod = Get-Content $DMPath -Filter $DeliveryMethod | Where-Object {$_ -match $DeliveryMethod}

        }


else

        {$DeliveryMethod = Add-Content $DMPath -value $DeliveryMethod-$DMRAddChar -PassThru
        
        }

$DeliveryMethod = $DeliveryMethod.Split("-")[1].Split(" ")

}
#End Delivery Method SKU

#------------------------------------------#
#------------Final SKU Code----------------#
#------------------------------------------#


#Put new SKUs together for final SKU code
$OGSKU = "$ProductName-$Platform-$DeliveryMethod-"

#Insert Dashes and Time to OG SKU
$NEWSKU = $OGSKU.Insert(15, $TrimValue)
Add-Content -Path "D:\SKU Automation\SKUs.csv" -Value "$OGProductName,$OGPlatform,$OGLengthOfTime,$OGUnitOfTime,$OGDeliveryMethod,$NEWSKU"