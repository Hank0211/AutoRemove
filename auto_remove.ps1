echo "Starting PowerShell Script"
$filter="deviceid='e:'"
$cap_path="E:\Packet_Project_1"
$log_path=@("E:\log_dns","E:\log_http_extend","E:\log_http_apache")

$log_fils="d:\" + "$(Get-Date -Format 'yyyy-MM-dd HH：mm').txt"
$Totle_size = 0


#建立归档目录
$Archive_Dir = 'e:\Archive\'+((get-date).AddDays(-1).ToString('yyyy-MM-dd')+'\') 
$log_path | %{
mkdir ($_ -replace 'e:\\', $Archive_Dir)
}

#复制前一天的日志到归档目录
Get-ChildItem -File $log_path | ?{ $_.LastWriteTime.ToString('yyyy-MM-dd')  -eq (Get-Date).AddDays(-1).ToString('yyyy-MM-dd') } | %{
Move-Item $_.FullName -Destination ($_.FullName -replace 'e:\\',$Archive_Dir)
}

#磁盘剩余百分比
$disk_free_space=get-wmiobject win32_logicaldisk -filter $filter | % { $_.freespace/$_.Size }
if ( $disk_free_space -gt 0.06 ) 
{
        ac -Path $log_fils -Value "剩余空间大于6%，不执行删除"
}
else
{
     #删除最早的3天文件
     $oldest_day=Get-ChildItem $cap_path -File -Recurse | Measure-Object -Property LastWriteTime -Minimum | %{date($_.Minimum) -Format 'yyyy-MM-dd'}
     Get-ChildItem $cap_path -File |  where-object { $_.LastWriteTime -lt ($oldest_day | Get-Date).AddDays(3) } | %{
         #get-item $line
         ac -Path $log_fils -Value ("deleting ->" + $_.FullName)
         $Totle_size += $_.Length
         del $_.FullName
     }
     ac -Path $log_fils -Value ("共删除文件：" + ($Totle_size/1024mb) + "Gb")
     $Totle_size = 0
     #删除3个月前的日志
     Get-ChildItem 'e:\Archive\' | ?{ $_.BaseName -lt (get-date).AddMonths(-3).ToString('yyyy-MM-dd') } | %{
         $Totle_size+=Get-ChildItem $_.FullName -File -Recurse | Measure-Object -Property Length -Sum
         ac -Path $log_fils -Value ("deleting ->" + $_.FullName)
         del $_.FullName -Recurse
     }
     ac -Path $log_fils -Value ("共删除文件：" + ($Totle_size/1024mb) + "Gb")
}
