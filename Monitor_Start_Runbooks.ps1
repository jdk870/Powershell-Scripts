#Runbook names here  
 $OpsMgrRunbooks =@('ADP Workflow', 'Exchange')  
 #$user = 'accu\keithj'  
 #$pass = ConvertTo-SecureString 'dog7wasa' -AsPlainText -Force  
 #$creds = New-Object System.Management.Automation.PsCredential($user,$pass)  
 foreach ($runbook in $OpsMgrRunbooks) {  
   $url = "http://scorch-v01.accu.accuwx.com:81/Orchestrator2012/Orchestrator.svc/Jobs()?`$expand=Runbook&`$filter=(Runbook/Name eq '$runbook')&`$select=Runbook/Name,Status"  
   $request = [System.Net.HttpWebRequest]::Create($url)  
   $request.UseDefaultCredentials = $true 
   $request.Timeout = 120000  
   $request.ContentType = 'application/atom+xml,application/xml'  
   $request.Headers.Add('DataServiceVersion', '2.0;NetFx')  
   $request.Method = 'GET'  
   $response = $request.GetResponse()  
   $requestStream = $response.GetResponseStream()  
   $readStream=new-object System.IO.StreamReader $requestStream  
   $Output = $readStream.ReadToEnd()  
   $readStream.Close()  
   $response.Close()  
   $Output > $env:TEMP\1.log  
   $htmlid = Get-Content -Path $env:TEMP\1.log | Select-String -pattern '<id>.*Runbooks.*'  
   $bookid = ($htmlid -split "'")[1]  
   $status = $Output -match "<d:Status>Running</d:Status>"  
   If ($Status -ne $True) {  
#Details of the runbook we are going to run
$rbid = $bookid  
$rbParameters = $null

#Create the request object
$request = [System.Net.HttpWebRequest]::Create("http://scorch-v01.accu.accuwx.com:81/Orchestrator2012/Orchestrator.svc/Jobs")

#Set the credentials to default or prompt for credentials
$request.UseDefaultCredentials = $true
#$request.Credentials = Get-Credential

#Build the request header
$request.Method = "POST"
$request.UserAgent = "Microsoft ADO.NET Data Services"
$request.Accept = "application/atom+xml,application/xml"
$request.ContentType = "application/atom+xml"
$request.KeepAlive = $true
$request.Headers.Add("Accept-Encoding","identity")
$request.Headers.Add("Accept-Language","en-US")
$request.Headers.Add("DataServiceVersion","1.0;NetFx")
$request.Headers.Add("MaxDataServiceVersion","2.0;NetFx")
$request.Headers.Add("Pragma","no-cache")

# If runbook servers are specified, format the string
$rbServerString = ""
if (-not [string]::IsNullOrEmpty($RunbookServers)) {
   $rbServerString = -join ("<d:RunbookServers>",$RunbookServers,"</d:RunbookServers>")
}

# Format the Runbook parameters, if any
$rbParamString = ""
if ($rbParameters -ne $null) {
   
   # Format the param string from the Parameters hashtable
   $rbParamString = "<d:Parameters><![CDATA[<Data>"
   foreach ($p in $rbParameters.GetEnumerator())
   {
      #$rbParamString = -join ($rbParamString,"&lt;Parameter&gt;&lt;ID&gt;{",$p.key,"}&lt;/ID&gt;&lt;Value&gt;",$p.value,"&lt;/Value&gt;&lt;/Parameter&gt;")         
      $rbParamString = -join ($rbParamString,"<Parameter><ID>{",$p.key,"}</ID><Value>",$p.value,"</Value></Parameter>")
   }
   $rbParamString += "</Data>]]></d:Parameters>"
}

# Build the request body
$requestBody = @"
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<entry xmlns:d="http://schemas.microsoft.com/ado/2007/08/dataservices" xmlns:m="http://schemas.microsoft.com/ado/2007/08/dataservices/metadata" xmlns="http://www.w3.org/2005/Atom">
    <content type="application/xml">
        <m:properties>
            <d:RunbookId m:type="Edm.Guid">$rbid</d:RunbookId>
            $rbserverstring
            $rbparamstring
        </m:properties>
    </content>
</entry>
"@

# Create a request stream from the request
$requestStream = new-object System.IO.StreamWriter $Request.GetRequestStream()
    
# Sends the request to the service
$requestStream.Write($RequestBody)
$requestStream.Flush()
$requestStream.Close()

# Get the response from the request
[System.Net.HttpWebResponse] $response = [System.Net.HttpWebResponse] $Request.GetResponse()

# Write the HttpWebResponse to String
$responseStream = $Response.GetResponseStream()
$readStream = new-object System.IO.StreamReader $responseStream
$responseString = $readStream.ReadToEnd()

# Close the streams
$readStream.Close()
$responseStream.Close()

# Get the ID of the resulting job
if ($response.StatusCode -eq 'Created')
{
    $xmlDoc = [xml]$responseString
    $jobId = $xmlDoc.entry.content.properties.Id.InnerText
    Write-Host "Successfully started runbook. Job ID: " $jobId
}
else
{
    Write-Host "Could not start runbook. Status: " $response.StatusCode
}

}

Else { "Runbook $runbook | $bookid - Already running" >> C:\Powershell\Log\RunbookManager.log } 
}