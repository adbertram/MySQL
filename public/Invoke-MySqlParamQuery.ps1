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
            $cc=($parameters | Measure-Object).Count
            $i=0
            $parameters | ForEach-Object {
                if ($cc -eq 1)
                {
                    $vv=$values
                    $ff=$parameters
                }
                else
                {
                    $vv=$values[$i]
                    $ff=$parameters[$i]
                }
                Switch ($vv.GetType())
                {
                    System.IO.MemoryStream {
                        $stream=[System.IO.MemoryStream]$vv
                        $stream.Position=0
                        $ary=$stream.ToArray()
                        $p=[Mysql.Data.MySqlClient.MySqlParameter]::new()
                        $p.ParameterName=$ff
                        $p.DbType='Object'
                        $p.Value=[byte[]]$ary
                        $tmp = $command.Parameters.Add($p)
                    }
                    default {
                        $v=[string]$vv
                        $tmp = $command.Parameters.AddWithValue($ff, $v)
                    }
                }
                $i+=1                
            }
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