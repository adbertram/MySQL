function Invoke-MySqlParamQuery
{
    <#
        .SYNOPSIS
            Run a parameterized ad-hoc query against a MySQL Server
        .DESCRIPTION
            This function can be used to run parameterized ad-hoc queries against a MySQL Server. 
        .PARAMETER Connection
            A connection object that represents an open connection to MySQL Server
        .PARAMETER Query
            A valid MySQL query
        .PARAMETER Parameters
            An array of parameters
        .PARAMETER Values
            An array of values for the parameters
        .EXAMPLE
            Invoke-MySqlParamQuery -Connection $Connection -Query "INSERT INTO foo (Animal, Name) VALUES (@animal, @name);" -Parameters "@animal","@name" -Values "Bird","Poll"

            Description
            -----------
            Add data to a sql table
        .NOTES
            FunctionName : Invoke-MySqlParamQuery
            Created by   : ThatAstronautGuy
            Date Coded   : 25/07/2018
    #>
    [CmdletBinding()]
	Param
	(
		[Parameter(Mandatory)]
		[ValidateNotNullOrEmpty()]
		[string]$Query,
		
		[Parameter()]
		[ValidateNotNullOrEmpty()]
		[MySql.Data.MySqlClient.MySqlConnection]$Connection = $MySQLConnection,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Parameters,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        $Values
	)
	begin
	{
		$ErrorActionPreference = 'Stop'
	}
	Process
	{
		try

		{
			
			[MySql.Data.MySqlClient.MySqlCommand]$command = New-Object MySql.Data.MySqlClient.MySqlCommand
            $command.Connection = $Connection
			$command.CommandText = $Query
            for($i = 0; $i -lt $parameters.Count; $i++){
                Switch ($values[$i].GetType())
                {
                    System.IO.MemoryStream {
                        $stream=[System.IO.MemoryStream]$values[$i]
                        $stream.Position=0
                        $ary=$stream.ToArray()
                        $p=[Mysql.Data.MySqlClient.MySqlParameter]::new()
                        $p.ParameterName=$Parameters[$i]
                        $p.DbType='Object'
                        $p.Value=[byte[]]$ary
                        $tmp = $command.Parameters.Add($p)
                    }
                    default {
                        $v=[string]$values[$i]
                        $tmp = $command.Parameters.AddWithValue($Parameters[$i], $v)
                    }
                }
                
            }
            #$command.Prepare()
			[MySql.Data.MySqlClient.MySqlDataAdapter]$dataAdapter = New-Object MySql.Data.MySqlClient.MySqlDataAdapter($command)
			$dataSet = New-Object System.Data.DataSet
			$recordCount = $dataAdapter.Fill($dataSet)
			Write-Verbose "$($recordCount) records found"
			$dataSet.Tables.foreach{$_}
		}
		catch
		{
			Write-Error -Message $_.Exception.Message
		}
	}
}