function Save-ClipboardImage {
    <#
    .Synopsis
        找尋最近的剪貼簿內容，如果是圖片就會將其保存到指定的資料夾之中

        檔名使用md5來計算，避免重複的檔案不斷被保存
    .Description
        在powershell 5.1可以這樣保存圖片
        ```
        $img = Get-Clipboard -format image
        $img.save("c:\temp\temp.jpg")
        ```
    .Parameter outDir
        圖片要存放的目錄
    .Example
    .Link
        https://stackoverflow.com/a/55226209/9935654
    #>
    param (
    [Parameter(Mandatory)]
    [ValidateScript({
        # 確保至少是資料夾或者檔案;
        if(-Not ($_ | Test-Path) ){
            throw "File or folder does not exist"
        }
        if($_ | Test-Path -PathType Leaf) { # 如果有枝葉，就是檔案，我們只允許目錄;
            throw "The Path argument must be a folder, not the file."
        }
        return $true
    })][string]$outDir
    )

    Add-Type -AssemblyName System.Windows.Forms

    $clipboard = [System.Windows.Forms.Clipboard]::GetDataObject()
    if ($clipboard.ContainsImage()) {
        $bitmap = [System.Drawing.Bitmap]$clipboard.getimage()

        # 將 Bitmap 轉換為二進制數據
        $memoryStream = New-Object System.IO.MemoryStream
        $bitmap.Save($memoryStream, [System.Drawing.Imaging.ImageFormat]::Png)
        $binaryData = $memoryStream.ToArray()

        $md5 = [System.Security.Cryptography.MD5]::Create().ComputeHash($binaryData)
        $md5HexString = [System.BitConverter]::ToString($md5) -replace "-", ""

        $outPath = Join-Path $outDir "$md5HexString.png"

        if (Test-Path $outPath) {
            Write-Host "File already exits:" -NoNewLine
            Write-Host $outPath -ForegroundColor Yellow
            $memoryStream.Dispose()
            $bitmap.Dispose()
            return
        }
        $bitmap.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Output "clipboard content saved as $out"
        $memoryStream.Dispose()
        $bitmap.Dispose()
    } else {
        Write-Output "clipboard does not contains image data"
    }
}


function Show-ClipboardHistory {
    <#
        .SYNOPSIS
            UI that will display the history of clipboard items

        .DESCRIPTION
            UI that will display the history of clipboard items. Options include filtering for text by
            typing into the filter textbox, context menu for removing and copying text as well as a menu to
            clear all entries in the clipboard and clipboard history viewer.

            Use keyboard shortcuts to run common commands:

            Ctrl + C -> Copy selected text from viewer
            Ctrl + R -> Remove selected text from viewer
            Ctrl + E -> Exit the clipboard viewer

        .NOTES
            Author: Boe Prox
            Created: 10 July 2014
            Version History:
                1.0 - Boe Prox - 10 July 2014
                    - Initial Version
                1.1 - Boe Prox - 24 July 2014
                    - Moved Filter from timer to TextChanged Event
                    - Add capability to select multiple items to remove or add to clipboard
                    - Able to now use mouse scroll wheel to scroll when over listbox
                    - Added Keyboard shortcuts for common operations (copy, remove and exit)
                1.2 - Carson Tseng - 11 July 2023
                    - Make it to a function. (param.interval)
                    - Add_MouseLeftButtonUp for copy faster.
        .Link
            https://github.com/chrisdee/Scripts/blob/1a4bdb393b93e228b182ec3c057926e71687b20b/PowerShell/Working/Snippets/ClipboardHistoryViewer.ps1#L1-L215
    #>
    param (
        [Parameter()]
        [ValidateScript({
           if ($_ -lt 0 -or $_ -gt 60) {
            throw "interval range should be (0, 60)"
           }
           return $true
        })]
        [float]$interval = 0.5
    )

    <#
    TODO:
        - Add create time: add a column at the list box to show the create time.
        - image support: allow the history record of the image.
        - filter: filter can search {text, image, date}
        - hotkey support: add two(copy, paste) columns at the list box which allow the user to input the hotkey
            for example, you can set the hotkey on item1, and define {Ctrl+1} equal to copy item1, {Alt+1} equal to paste item1, etc.
    #>

    $runspaceHash = [hashtable]::Synchronized(@{}) # 建立同步的hashtable，它可以保證每個線程在調用它，都能得到相同的結果;
    # 我們會在此hashtable，建立資訊: {Host, runspace, Powershell, Handle}

    # Host
    $runspaceHash.Host = $Host

    # runspace
    $runspaceHash.runspace = [RunspaceFactory]::CreateRunspace()
    $runspaceHash.runspace.ApartmentState = "STA" # STA: Single-Threaded Apartment # MTA: Multi-Threaded Apartment
    $runspaceHash.runspace.Open()
    # $runspaceHash.runspace.AddScript("Set-Variable -Name 'Test' -Value 123") # 也可以用這種方法設定變數;
    $runspaceHash.runspace.SessionStateProxy.SetVariable("runspaceHash",$runspaceHash)
    $runspaceHash.runspace.SessionStateProxy.SetVariable("interval",$interval) # runspace是另一個空間，因此變數不共享，所以要重新指派

    # PowerShell
    $runspaceHash.PowerShell = {Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase}.GetPowerShell()
    # $runspaceHash.PowerShell = [PowerShell]::Create() # 別用這種方法建立與上面的方法還是有區別;
    $runspaceHash.PowerShell.Runspace = $runspaceHash.runspace
    $runspaceHash.Handle = $runspaceHash.PowerShell.AddScript({
        function Get-ClipBoard {
            [Windows.Clipboard]::GetText()
        }
        function Set-ClipBoard {
            # $Script:CopiedText 是一個用來記錄當前選擇到listbox中的哪一個項目;
            $Script:CopiedText = $($listbox.SelectedItems | Out-String) # $xxx: 代表命名空間，而Script表示當前的腳本作用域;
            [Windows.Clipboard]::SetText($Script:CopiedText)
        }
        function Clear-Viewer {
            [void]$Script:ObservableCollection.Clear()
            [Windows.Clipboard]::Clear()
        }
        # Build the GUI (xaml經常與這些技術框架WPF、UWP、Silverlight一起使用);
        [xml]$xaml = @"
        <Window
            xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            x:Name="Window" Title="Powershell Clipboard History Viewer" WindowStartupLocation = "CenterScreen"
            Width = "400" Height = "450" ShowInTaskbar = "True" Background = "White">
            <Grid >
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto" />
                    <RowDefinition Height="Auto" />
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <Grid.Resources>
                    <Style x:Key="AlternatingRowStyle" TargetType="{x:Type Control}" >
                        <Setter Property="Background" Value="LightGray"/>
                        <Setter Property="Foreground" Value="Black"/>
                        <Style.Triggers>
                            <Trigger Property="ItemsControl.AlternationIndex" Value="1">
                                <Setter Property="Background" Value="White"/>
                                <Setter Property="Foreground" Value="Black"/>
                            </Trigger>
                        </Style.Triggers>
                    </Style>
                </Grid.Resources>
                <Menu Width = 'Auto' HorizontalAlignment = 'Stretch' Grid.Row = '0'>
                <Menu.Background>
                    <LinearGradientBrush StartPoint='0,0' EndPoint='0,1'>
                        <LinearGradientBrush.GradientStops>
                        <GradientStop Color='#C4CBD8' Offset='0' />
                        <GradientStop Color='#E6EAF5' Offset='0.2' />
                        <GradientStop Color='#CFD7E2' Offset='0.9' />
                        <GradientStop Color='#C4CBD8' Offset='1' />
                        </LinearGradientBrush.GradientStops>
                    </LinearGradientBrush>
                </Menu.Background>
                    <MenuItem x:Name = 'FileMenu' Header = '_File'>
                        <MenuItem x:Name = 'Clear_Menu' Header = '_Clear' />
                    </MenuItem>
                </Menu>
                <GroupBox Header = "Filter"  Grid.Row = '2' Background = "White">
                    <TextBox x:Name="InputBox" Height = "25" Grid.Row="2" />
                </GroupBox>
                <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto"
                Grid.Row="3" Height = "Auto">
                    <ListBox x:Name="listbox" AlternationCount="2" ItemContainerStyle="{StaticResource AlternatingRowStyle}"
                    SelectionMode='Extended'>
                    <ListBox.Template>
                        <ControlTemplate TargetType="ListBox">
                            <Border BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderBrush}">
                                <ItemsPresenter/>
                            </Border>
                        </ControlTemplate>
                    </ListBox.Template>
                    <ListBox.ContextMenu>
                        <ContextMenu x:Name = 'ClipboardMenu'>
                            <MenuItem x:Name = 'Copy_Menu' Header = 'Copy'/>
                            <MenuItem x:Name = 'Remove_Menu' Header = 'Remove'/>
                        </ContextMenu>
                    </ListBox.ContextMenu>
                    </ListBox>
                </ScrollViewer >
            </Grid>
        </Window>
"@

        $reader=(New-Object System.Xml.XmlNodeReader $xaml)
        $Window=[Windows.Markup.XamlReader]::Load( $reader ) # 此視窗透過xaml所建立;

        # Connect to Controls
        $listbox = $Window.FindName('listbox') # 即xaml中的x:Name對象;
        $InputBox = $Window.FindName('InputBox')
        $Copy_Menu = $Window.FindName('Copy_Menu')
        $Remove_Menu = $Window.FindName('Remove_Menu')
        $Clear_Menu = $Window.FindName('Clear_Menu')

        # Events
        $Clear_Menu.Add_Click({
            Clear-Viewer
        })
        $Remove_Menu.Add_Click({
            @($listbox.SelectedItems) | ForEach {
                [void]$Script:ObservableCollection.Remove($_)
            }
        })
        $Copy_Menu.Add_Click({
            Set-ClipBoard
        })
        $Window.Add_Activated({
            $InputBox.Focus()
        })

        # 初始化視窗;
        $Window.Add_SourceInitialized({
            # Create observable collection
            $Script:ObservableCollection = New-Object System.Collections.ObjectModel.ObservableCollection[string] # 這個型別有一個好處，它可以設定一些事件，讓您能觀察到異動;
            $Listbox.ItemsSource = $Script:ObservableCollection

            # Create Timer object
            $Script:timer = new-object System.Windows.Threading.DispatcherTimer
            # $timer.Interval = 1000 # 1秒;
            # $timer.Interval = [TimeSpan]"0:0:.1" # 0.1秒;
            $timer.Interval = [TimeSpan]"0:0:$interval"

            # Add event per tick
            $timer.Add_Tick({
                $text = Get-Clipboard
                # 如果剪貼簿文字有內容, 且與之前的文字不同，就會新增;
                if (
                        ($text.length -gt 0) -and # 剪貼簿內容非空;
                        (
                            $Script:Previous -ne $text -AND # 不是之前已經複製過的內容;
                            $Script:CopiedText -ne $text # 以防我們在listbox中選擇該項目按下copy的時候，我們不想要讓剪貼簿新增這個我們主動選擇copy的項目;
                        )
                    ) {
                    [void]$Script:ObservableCollection.Add($text)
                    $Script:Previous = $text
                }
            })
            $timer.Start()
            if (-not $timer.IsEnabled) {
                $Window.Close()
            }
        })

        $Window.Add_Closed({
            $Script:timer.Stop()
            $Script:ObservableCollection.Clear()
            $runspaceHash.PowerShell.Dispose()
        })

        # Filter輸入的內容, 找出匹配的項目;
        $InputBox.Add_TextChanged({
            [System.Windows.Data.CollectionViewSource]::GetDefaultView($Listbox.ItemsSource).Filter = [Predicate[Object]]{
                Try {
                    $args[0] -match [regex]::Escape($InputBox.Text)
                } Catch {
                    $True
                }
            }
        })

        $listbox.Add_MouseRightButtonUp({
            # 在listbox中點擊右鍵，如果有任何項目(Count>0)就會顯示右鍵清單;
            if ($Script:ObservableCollection.Count -gt 0) {
                # Menu可見
                $Remove_Menu.IsEnabled = $True
                $Copy_Menu.IsEnabled = $True
            } else {
                # Menu不可見
                $Remove_Menu.IsEnabled = $False
                $Copy_Menu.IsEnabled = $False
            }
        })

        $listbox.Add_MouseLeftButtonUp({
            Set-ClipBoard
        })

        $Window.Add_KeyDown({
            $key = $_.Key
            if ([System.Windows.Input.Keyboard]::IsKeyDown("RightCtrl") -OR [System.Windows.Input.Keyboard]::IsKeyDown("LeftCtrl")) {
                switch ($Key) {
                "C" { # Copy
                    Set-ClipBoard
                }
                "R" { # Remove
                    @($listbox.SelectedItems) | ForEach { # 只會移除一個項目;
                        [void]$Script:ObservableCollection.Remove($_)
                    }
                }
                "E" { # Exit
                    $This.Close()
                }
                default {$Null}
                }
            }
        })
        [void]$Window.ShowDialog()
    }).BeginInvoke()
}

