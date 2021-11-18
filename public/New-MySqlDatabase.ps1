function New-MySqlDatabase
{
    <#
        .SYNOPSIS
            Create a new MySQL DB
        .DESCRIPTION
            This function will create a new Database on the server that you are 
            connected to.
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Name
            The name of the database to create
        .EXAMPLE
            New-MySqlDatabase -Connection $Connection -Name "MyNewDB"

            Database
            --------
            mynewdb

            Description
            -----------
            This example creates the MyNewDB database on a MySQL server.
        .NOTES
            FunctionName : New-MySqlDatabase
            Created by   : jspatton
            Date Coded   : 02/11/2015 09:35:02
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#New-MySqlDatabase
    #>
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Name,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[MySql.Data.MySqlClient.MySqlConnection]$Connection = $MySQLConnection
	)
	begin
	{
		$Query = "CREATE DATABASE $($Name);";
	}
	process
	{
		try
		{
			Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop
			Get-MySqlDatabase -Connection $Connection -Name $Name
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}