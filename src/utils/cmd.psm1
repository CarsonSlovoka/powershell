function SetByPass {
    echo "Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -F"
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -F
}

# 注意@""@，前面@"之後一定要空行，之後"@也要在新的一行，且最後不能有多的空白！

Set-Alias byPass SetByPass -Description @"
Set Scope.Process.ExecutionPolicy=Bypass
如果是在powershell 7以上似乎可以不需要特別設定即可使用
"@ -Scope Global
