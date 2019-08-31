#迁移数据到归档目录
$s_log_dir=@("E:\","e:\")
Get-ChildItem -File $s_log_dir | ?{$_.LastWriteTime.ToString('yyyy-MM-dd') -lt '2019-08-30'} | %{
    ac -Path (e:\filelist.txt) -Value $_.FullName 
} 

$s_log_files=@("E:\filelist.txt")
$d_log_dir

$s_log_files | %{ Get-Content $_ }| Get-childItem -file | %{
        $d_log_dir = $_.Directory -replace 'e:\\',('e:\Archive\' + $_.LastWriteTime.toString('yyyy-MM-dd') + '\')
        if ( -not(Test-Path $d_log_dir) ) {
            mkdir $d_log_dir
            move-Item $_.FullName -Destination $d_log_dir
        }
}