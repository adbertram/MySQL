function Get-MySqlDatabase
{
    <#
        .SYNOPSIS
            Get one or more tables from a MySQL Server
        .DESCRIPTION
            This function returns one or more Database names from a MySQL Server
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Name
            An optional parameter that if provided will scope the output to the requested 
            DB. If blank this will return all the Datbases the user has the ability to 
            see based on their credentials.
        .EXAMPLE
            Get-MySqlDatabase -Connection $Connection

            Database
            --------
            information_schema
            mynewdb
            mysql
            performance_schema
            test
            testing
            wordpressdb
            wordpressdb1
            wordpressdb2

            Description
            -----------
            This example shows the output when the Name parameter is ommitted.
        .EXAMPLE
            Get-MySqlDatabase -Connection $Connection -Name mynewdb

            Database
            --------
            mynewdb

            Description
            -----------
            This example shows the output when passing in the name of a Database.
        .NOTES
            FunctionName : Get-MySqlDatabase
            Created by   : jspatton
            Date Coded   : 02/11/2015 10:05:20
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Get-MySqlDatabase
    #>
	[CmdletBinding()]
	Param
	(
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[MySql.Data.MySqlClient.MySqlConnection]$Connection = $MySQLConnection,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[string]$Name
	)
	process
	{
		try
		{
			if ($PSBoundParameters.ContainsKey('Name'))
			{
				$query = "SHOW DATABASES WHERE ``Database`` LIKE '$($Name)';"
			}
			else
			{
				$query = 'SHOW DATABASES;'
			}
			Invoke-MySqlQuery -Connection $Connection -Query $query -ErrorAction Stop
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}