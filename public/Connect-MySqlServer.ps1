function Connect-MySqlServer
{
	<#
	.SYNOPSIS
		Connect to a MySQL Server
	.DESCRIPTION
		This function will establish a connection to a local or remote instance of 
		a MySQL Server. By default it will connect to the local instance on the 
		default port.
	.PARAMETER ComputerName
		The name of the remote computer to connect to, otherwise default to localhost
	.PARAMETER Port
		By default this is 3306, otherwise specify the correct value
	.PARAMETER Credential
		Typically this may be your root credentials, or to work in a specific 
		database the credentials with appropriate rights to do work in that database.
	.PARAMETER Database
		An optional parameter that will connect you to a specific database
	.PARAMETER CommandTimeOut
		By default command timeout is set to 30, otherwise specify the correct value
	.PARAMETER ConnectionTimeOut
		By default connection timeout is set to 15, otherwise specify the correct value
	.EXAMPLE
		Connect-MySqlServer -Credential (Get-Credential)

		cmdlet Get-Credential at command pipeline position 1
		Supply values for the following parameters:
		Credential


		ServerThread      : 2
		DataSource        : localhost
		ConnectionTimeout : 15
		Database          :
		UseCompression    : False
		State             : Open
		ServerVersion     : 5.6.22-log
		ConnectionString  : server=localhost;port=3306;User Id=root
		IsPasswordExpired : False
		Site              :
		Container         :

		Description
		-----------
		Connect to the local mysql instance as root. This example uses the 
		Get-Credential cmdlet to prompt for username and password.
	.EXAMPLE
		Connect-MySqlServer -ComputerName db.company.com -Credential (Get-Credential)

		cmdlet Get-Credential at command pipeline position 1
		Supply values for the following parameters:
		Credential


		ServerThread      : 2
		DataSource        : db.company.com
		ConnectionTimeout : 15
		Database          :
		UseCompression    : False
		State             : Open
		ServerVersion     : 5.6.22-log
		ConnectionString  : server=db.company.com;port=3306;User Id=root
		IsPasswordExpired : False
		Site              :
		Container         :

		Description
		-----------
		Connect to a remote mysql instance as root. This example uses the 
		Get-Credential cmdlet to prompt for username and password.
	.EXAMPLE
		Connect-MySqlServer -Credential (Get-Credential) -CommandTimeOut 60 -ConnectionTimeOut 25

		cmdlet Get-Credential at command pipeline position 1
		Supply values for the following parameters:
		Credential


		ServerThread      : 2
		DataSource        : localhost
		ConnectionTimeout : 25
		Database          :
		UseCompression    : False
		State             : Open
		ServerVersion     : 5.6.22-log
		ConnectionString  : server=localhost;port=3306;User Id=root;defaultcommandtimeout=60;connectiontimeout=25
		IsPasswordExpired : False
		Site              :
		Container         :

		Description
		-----------
		This example set the Command Timout to 60 and the Connection Timeout to 25. Both are optional when calling the Connect-MySqlServer function.
	.NOTES
		FunctionName : Connect-MySqlServer
		Created by   : jspatton
		Date Coded   : 02/11/2015 09:19:10
	.LINK
		https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Connect-MySqlServer
	#>
	[OutputType('MySql.Data.MySqlClient.MySqlConnection')]
	[CmdletBinding()]
	Param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[pscredential]$Credential,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$ComputerName = $env:COMPUTERNAME,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[int]$Port = 3306,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Database,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[int]$CommandTimeOut = 30,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[int]$ConnectionTimeOut = 15
	)
	begin
	{
		$ErrorActionPreference = 'Stop'
		
		if ($PSBoundParameters.ContainsKey('Database')) {
			$connectionString = 'server={0};port={1};uid={2};pwd={3};database={4};' -f $ComputerName,$Port,$Credential.UserName, $Credential.GetNetworkCredential().Password,$Database
		}
		else
		{
			$connectionString = 'server={0};port={1};uid={2};pwd={3};' -f $ComputerName, $Port, $Credential.UserName, $Credential.GetNetworkCredential().Password
		}
		# Added
		$connectionString = $connectionString + "default command timeout=$CommandTimeOut; Connection Timeout=$ConnectionTimeOut;Allow User Variables=True"
	}
	process
	{
		try
		{
			[MySql.Data.MySqlClient.MySqlConnection]$conn = New-Object MySql.Data.MySqlClient.MySqlConnection($connectionString)
			$conn.Open()
			$Global:MySQLConnection = $conn
			if ($PSBoundParameters.ContainsKey('Database')) {
				$null =  New-Object MySql.Data.MySqlClient.MySqlCommand("USE $Database", $conn)
			}
			$conn
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}