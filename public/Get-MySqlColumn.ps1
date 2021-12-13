function Get-MySqlColumn
{
    <#
        .SYNOPSIS
            Get a list of columns in a table
        .DESCRIPTION
            This function will return a list of columns from a table. 
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Database
            The name of the database that contains the table
        .PARAMETER Table
            The name of the table to return columns from
        .EXAMPLE
            Get-MySqlColumn -Connection $Connection -Table sample_tbl


            Field   : id
            Type    : int(11)
            Null    : NO
            Key     : PRI
            Default :
            Extra   : auto_increment

            Field   : name
            Type    : varchar(10)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : age
            Type    : int(11)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Description
            -----------
            A list of fields from the sample_tbl in the current database
        .EXAMPLE
            Get-MySqlColumn -Connection $Connection -Database test -Table bar


            Field   : NAME
            Type    : varchar(20)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : OWNER
            Type    : varchar(20)
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : DEATH
            Type    : date
            Null    : YES
            Key     :
            Default :
            Extra   :

            Field   : BIRTH
            Type    : date
            Null    : YES
            Key     :
            Default :
            Extra   :

            Description
            -----------
            A list of fields from the bar table in the test database
        .NOTES
            FunctionName : Get-MySqlField
            Created by   : jspatton
            Date Coded   : 02/11/2015 13:17:25
        .LINK
            https://github.com/jeffpatton1971/mod-posh/wiki/MySQL#Get-MySqlField
    #>
	[CmdletBinding()]
	Param
	(
		[MySql.Data.MySqlClient.MySqlConnection]
		$Connection = $Global:MySQLConnection,
		
		[string]$Database,
		
		[parameter(Mandatory = $true)]
		[string]$Table
	)
	begin
	{
		try
		{
			$ErrorActionPreference = "Stop";
			if ($Database)
			{
				if (Get-MySqlDatabase -Connection $Connection -Name $Database)
				{
					$Connection.ChangeDatabase($Database);
				}
				else
				{
					throw "Unknown database $($Database)";
				}
			}
			else
			{
				if (!($Connection.Database))
				{
					throw "Please connect to a specific database";
				}
			}
		}
		catch
		{
			$Error[0];
			break
		}
		$Query = "DESC $($Table);";
	}
	Process
	{
		try
		{
			Write-Verbose "Invoking SQL";
			Invoke-MySqlQuery -Connection $Connection -Query $Query -ErrorAction Stop;
		}
		catch
		{
			$Error[0];
			break
		}
	}
	End
	{
	}
}