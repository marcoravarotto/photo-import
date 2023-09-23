
<#
    .SYNOPSIS
    This script has been written to make life easier when you want to transfer photo from your Apple device to your Windows PC. 
    I speak from experience: with Android you can plug your phone to your PC, and you can copy everything you want from your phone to PC, and vice-versa. This is a really satisfying experience!
    If you have an iPhone, you can't.
    If you want to pass something from PC or vice-versa to iThins you must deal with iTunes.
    You can use iTunes to 'synchronise' your PC photos with your iThings, i.e. you can copy photos from PC to your iThins, but then from your iThins you cannot delete them!! In order to do this you have to plug you iThings to the PC and then you can remove the synchronized PC directory...

    We live in $(Get-Date -Format "yyyy") and iThings behave the exactly same way! This is so frustrating.

    When you plug iThing to PC, you can see the DCIM directory content, but photos and videos are organized in sub-directories named with 'YYYYMM__' naming convention, and all files have strange names like IMG_1234.HEIC, KGVNWONG.JPG, AJFOWOKF.PNG, IMG_1465.MOV, ...
    What if I want to copy only images and videos from 31st December at 23:20 and 1st January at 23:10? 
    Android: you navigate DCIM directory and every file is named IMG-YYYYMMDD_hhmmss format, so you can easily select what you want, copy them, and paste in your PC. Simple.
    iPhone: try to navigate DCIM directory, and tell me if you can easily find what you want!
    'You should install iCloud and synchronize photos/videos with it' bla bla bla... I don't want iCloud! I have 512 GB iPhone, and should I use a 5 GB iCloud plan, or pay 2$ every month for 50 GB storage, all this only this to copy photos to PC?? Are we crazy?

    Then I discovered .HEIC format, that Windows doesn't support. You copy your wanderful .HEIC image to your PC, and then? Windows can't open it.
    Thank you ImageMagick.

    Videos suffer from the same problem: if you have recorded a IMG_1234.MOV with 'high efficiency', its codec is h265, and Windows can't open it.
    Thank you ffmpeg.

    For this reason I have chosen to write this program with which you can pass photos and video from your iThing to your PC.

    .DESCRIPTION
    This script has been written to make life easier when you want to transfer photo from your Apple device (iPad/iPhone, or commonly named iThing) to your Windows PC. You can use this program to:
    [1]. copy photos and video from your iThing to your PC. You can choose to copy all photos and videos, or specify a date range you want
    [2]. organize these copied photos and videos in 'Camera Roll', 'Screenshot', and 'Received' directories
    [3]. convert all .HEIC images in .JPG
    [4]. rename all photos and videos in YYYYMMDD_hhmmss_<OriginalFileName>
    [5]. convert all .HEIC images in .JPG in a specific directory of your PC.

    .PARAMETER PhoneName
    Name of your Apple Device, i.e. name you find in Removable Device when you plug it to PC
    Default: 'Apple iPhone' if nothing is specified.

    .PARAMETER From
    Date from which you want to copy photos/videos. You can specify this date in one of these formats:
    'saturday 1 january 2019 13:15:03'
    '1 january 2019 13:15:03'
    '1 jan 2019 13:15:03'
    '01/01/2019 13:15:03'
    If you don't specify the year and hours, it considers the current year, and 00:00:00 respectively.
    For example '1 jan' is Saturday 1st January 2022 at 00:00:00
    Default: today at 00:00:00 if nothing is specified.

    .PARAMETER To
    Date up to which you want to copy photos/videos. Same date format of [-from] parameter.
    Default: $date_import if nothing is specified.
    
    .PARAMETER All
    If you specify it, you select all photos and videos in your iThing.
    
    .PARAMETER Destination
    Destination directory in your PC.
    Default: if you don't specify a path, the program creates an 'IMPORT' directory in the same directory of this program.
    If there already is an 'IMPORT' directory, the program creates an 'IMPORT_<CurrentDate>' directory where <CurrentDate> is $date_importString
    
    .PARAMETER Import
    If specified, the program copies photos and videos of the specified date range to the specified destination folder.
    Other parameters you can add with [-Import] declared are [-Heic], [-Y], [-Folders]

    .PARAMETER Heic
    If it is passed with [-Import] specified, it converts images from .HEIC to .JPG formats. To do so you need to specify ImageMagick folder path with next parameter. This parameters invokes ImageMagick 'magick.exe' and it converts images with 97% quality.

    .PARAMETER MagickPath
    "magick.exe" folder path. You must specify it if you want to convert images from .HEIC to .JPG
    
    .PARAMETER Y
    If you specify it after [-Heic] all .HEIC images will be firstly converted to .JPG and then deleted.
    If you don't specify if, the program asks if you want to delete .HEIC images after their conversion to .JPG.
    
    .PARAMETER Folders
    If declared, the program organize all copied photos and videos in 'Camera Roll', 'Screenshot', and 'Received' directories.
    
    .EXAMPLE
    PS> .\photoimport.ps1
    It returns a full report of all photos/videos stored in your iThing from today at 00:00:00 to $($date_import).
    
    .EXAMPLE
    PS> .\photoimport.ps1 -import
    It copies all photos/videos from today at 00:00:00 to $($date_import) in defalut IMPORT directory
    
    .EXAMPLE
    PS> .\photoimport.ps1 -all -import
    It copies all photos/videos in default IMPORT directory
    
    .EXAMPLE
    PS> .\photoimport.ps1 -from '1 march 2019 13:20:10' -to '30 april' -import -heic -MagickPath "C:\Magick" -y -folders
    It copies photos/videos from 1st March 2019 at 13:20:10 to 30th april 2022 at 00:00:00, and all .HEIC images are converted to .JPG and then deleted. ImageMagick in "C:\Magick" folder do photo conversion from .HEIC to .JPG. All photos/videos are then organized in 'Camera Roll', 'Screenshot', and 'Received' directories.
#>


param (
    [string] $PhoneName = "Apple iPhone",
    [string] $From = "",
    [string] $To = "",
    [string] $Destination = "",
    [switch] $Import,
    [switch] $Heic,
    [string] $MagickPath = "${PSScriptRoot}",
    [switch] $Folders,
    [switch] $Y,
    [switch] $All
)

$date_import = $(Get-Date)
$date_importString = $(Get-Date -Date $date_import -Format "yyyyMMdd_HHmmss").ToString()


# From date format
if ($From -eq "") { 
    $date_from = Get-Date -Hour 0 -Minute 0 -Second 0
}
else { 
    if (!($From -as [DateTime])) { 
        Write-Host "Date format not valid. Execute 'Get-Help .\photoImport.ps1 -Full' for more info." -ForegroundColor Red
        break
    }
    $date_from = Get-Date $From 
}

# To date format
if ($To -eq "") { 
    $date_to = Get-Date
}
else { 
    if (!($From -as [DateTime])) { 
        Write-Host "Date format not valid. Execute 'Get-Help .\photoImport.ps1 -Full' for more info." -ForegroundColor Red
        break
    }
    $date_to = Get-Date $To 
}

# searching phone info
# when you plug iDevide to PC, under 'This PC' you see:
# 'Apple iPhone'
#       |__________'Internal Storage'
#                          |_____________ 'DCIM'
#                                            |______ Lots of directories containing photos and videos
#
# when you plug you device to your PC, you don't immediately see directories in DCIM folder
"Get info about your device..."
$Global:ShellProxy = New-Object -ComObject Shell.Application
$shell = $Global:ShellProxy
$phone = $shell.NameSpace(17).self.getfolder.items() | Where-Object {$_.name -eq $PhoneName}
if ($null -ne $phone) {
    Write-Host "$PhoneName connected!" -ForegroundColor Green
    $photoAreNotReady = $true
    while ($photoAreNotReady) {
        try {
            $internalStorage = $phone.getfolder.items() | Where-Object {$_.name -eq "Internal Storage"}
            $DCIM = $internalStorage.getfolder.items() | Where-Object {$_.name -eq "DCIM"}
            $photoAreNotReady = $false
            Write-Host "Photo available" -ForegroundColor "Green"
        } catch {
            Write-Host -NoNewline "`rPhoto/videos sill not available, please wait ... " -ForegroundColor "Yellow"
        }
    }

    if ($All) {
        " "
        "All photo/videos selected."
    }
    else {
        $temp_from = $date_from.GetDateTimeFormats()[12]
        $temp_to = $date_to.GetDateTimeFormats()[12]
        " "
        "Selected date: from $temp_from to $temp_to"
    }

    # photo/video search
    $count=0
    $size=0
    # progress info
    $countDirectories = 0
    $TotalDirectories = ($DCIM.GetFolder.Items() | Measure-Object).Count
    # this array collects a list of all files the program has to copy
    $FILES = @()
    # For every directory in "DCIM"
    foreach ($folder in $DCIM.GetFolder.Items()) {
        $items = $folder.GetFolder.Items()
        
        # For every item in each directory
        foreach ($item in $items) {
            
            $itemName = $item.Name

            # get the creation date of the item
            $itemCreatedDate = $item.ExtendedProperty("System.DateCreated")
            $itemAddHour = [int]$(Get-Date $itemCreatedDate -UFormat "%Z")
            $itemCreatedDate = $(Get-Date $itemCreatedDate.AddHours($itemAddHour))
            $itemCreatedDate = Get-Date -Date $itemCreatedDate
            
            # if -All is specified, you don't need to compare 'From' and 'To' date with $itemCreatedDate, because you consider all of them
            if ($All) {
                if ($itemName -notmatch ".AAE") {
                    ++$count
                    $size += $item.ExtendedProperty("System.Size")

                    $temp = New-Object System.Object
                    $temp | Add-Member -type NoteProperty -name 'Name' -Value $itemName
                    $temp | Add-Member -type NoteProperty -name 'ItemPath' -Value $item
                    $temp | Add-Member -type NoteProperty -name 'ItemDate' -Value $itemCreatedDate
                    $temp | Add-Member -type NoteProperty -name 'ItemAddHour' -Value $itemAddHour
                    $FILES += $temp
                }
            }
            # here you consider all items whose $itemCreatedDate lies between 'From' and 'To', and do not consider .AAE files
            elseif ($itemCreatedDate -ge $date_from -and $itemCreatedDate -le $date_to -and $itemName -notmatch ".AAE") {
                # Write-Host $itemName $itemCreatedDate 
                ++$count
                $size += $item.ExtendedProperty("System.Size")

                $temp = New-Object System.Object
                $temp | Add-Member -type NoteProperty -name 'Name' -Value $itemName
                $temp | Add-Member -type NoteProperty -name 'ItemPath' -Value $item
                $temp | Add-Member -type NoteProperty -name 'ItemDate' -Value $itemCreatedDate
                $temp | Add-Member -type NoteProperty -name 'ItemAddHour' -Value $itemAddHour
                $FILES += $temp
            }
        }

        $countDirectories++
        $percent = [int](($countDirectories * 100) / $TotalDirectories)
        Write-Progress -Activity "Collecting photos/videos info..." -status "Scanned directories ${countDirectories} / ${TotalDirectories}: ${percent}%"
    }
    if ($size -gt 1tb)          {$sizeStr = "$([math]::Round($size/1tb)) TB" }
    elseif ($size -gt 1gb)      {$sizeStr = "$([math]::Round($size/1gb)) GB" }
    elseif ($size -gt 1mb)      {$sizeStr = "$([math]::Round($size/1mb)) MB" }
    elseif ($size -gt 1kb)      {$sizeStr = "$([math]::Round($size/1kb)) kB" }
    else { $sizeStr = "${size} Bytes" }
    Write-Host "$count photos/videos found, size $sizeStr" -ForegroundColor Green

    $png_count = 0
    $jpg_count = 0
    $mov_count = 0
    $mp4_count = 0
    $Heic_count = 0
    $gif_count = 0
    $altro_count = 0
    foreach ($file in $FILES) {
        $ext = $file.Name.Substring($file.Name.Length-3,3)
        if ($ext -eq "PNG") { $png_count++ }
        elseif ($ext -eq "JPG") { $jpg_count++ }
        elseif ($ext -eq "MOV") { $mov_count++ }
        elseif ($ext -eq "MP4") { $mp4_count++ }
        elseif ($ext -eq "EIC") { $Heic_count++ }
        elseif ($ext -eq "GIF") { $gif_count++ }
        else { $altro_count++ }
    }
    Write-Host "PNG: $png_count"
    Write-Host "JPG: $jpg_count"
    Write-Host "MOV: $mov_count"
    Write-Host "MP4: $mp4_count"
    Write-Host "HEIC: $Heic_count"
    Write-Host "GIF: $gif_count"
    Write-Host "Other: $altro_count"

    if ($Import) {
        
        # default destination directory path
        if ($Destination -eq "") {
            $Destination = "${PSScriptRoot}\IMPORT"

            # it creates 'IMPORT' directory if there isn't in the program path
            if (-not $(Test-Path $Destination)) {
                mkdir $Destination > $null
            }

            # if the IMPORT directory already exists, and it is not empty, it does not return an error, but it creates another one with the format 'IMPORT_YYYYMMDD_hhmmss'
            if ($(Get-ChildItem -Path $Destination | Measure-Object).Count -ne 0) {
                Write-Host "$Destination not empty." -ForegroundColor Yellow
                $date_importString = $(Get-Date -Date $date_import -Format "yyyyMMdd_HHmmss").ToString()

                $Destination = "${PSScriptRoot}\IMPORT_$($date_importString)"
                mkdir $Destination > $null
                Write-Host "New directory IMPORT_$($date_importString) created!" -ForegroundColor Green
            }
        }

        # in this scenario you passed a 'Destination' path different from default behaviour. In this case, if 'Destination' path does not exists, or it is not empty, it throws an error and the program stops
        if (-not $(Test-Path $Destination)) {
            Write-Host "$Destination not exists." -ForegroundColor Red
            break
        }
        if ($(Get-ChildItem -Path $Destination | Measure-Object).Count -ne 0) {
            Write-Host "$Destination is not empty!" -ForegroundColor Red
            break
        }

        
        # If you are here you can start to import files!!
        " "
        "LET'S COPY FILES!"
        $DestinationFolder = $shell.Namespace($Destination).self
        $count=0
        $TotalItems = $FILES.Length
        for ($i=0; $i -lt $TotalItems; $i++) {
            ++$count
            $percent = [int](($count * 100) / $TotalItems)
            $itemName = $FILES[$i].Name
            # Write-Host "${count} / ${totalItems} (${percent}%): $itemName"
            Write-Progress -Activity "Copying files..." -status "Copied ${count} / ${totalItems}: ${percent}%"

            $targetFilePath = join-path -path $Destination -childPath $itemName
            if (!(test-path -path $targetFilePath)) { 
                $DestinationFolder.getFolder.CopyHere($FILES[$i].ItemPath)
                Start-Sleep -milliseconds 5
            }
        }
        Write-Host "All photos and videos copied successfully!" -ForegroundColor Green

        # file renaming
        Write-Host "Wait please: renaming all files..." -ForegroundColor Yellow
        for ($i=0; $i -lt $TotalItems; $i++) {

            $itemName = $FILES[$i].Name
            $targetFilePath = join-path -path $Destination -childPath $itemName

            # here it renames copied files in the Destination directory
            if (test-path -path $targetFilePath) {
                $itemCreatedDate = Get-Date -date $FILES[$i].ItemDate
                $itemNameNew = $(Get-Date -Date $itemCreatedDate -Format "yyyyMMdd_HHmmss").ToString()
                $itemNameNew += "_" + $itemName

                # All Metadata 'Time' are uniformed to $itemCreatedDate
                $(Get-ChildItem $targetFilePath).CreationTime = $itemCreatedDate
                $(Get-ChildItem $targetFilePath).LastAccessTime = $itemCreatedDate
                $(Get-ChildItem $targetFilePath).LastWriteTime = $itemCreatedDate

                Rename-Item -Path $targetFilePath -NewName $itemNameNew
            }
        }
        Write-Host "Renaming completed!" -ForegroundColor Green
        " "

        # HEIC images conversion if '-Heic' option is specified
        if ($Heic -and $Heic_count -gt 0) {
            # in order to convert images from .HEIC to .JPG you must have magick.exe (from ImageMagick) in program directory.
            # Otherwise it says 'I cannot convert images because there is no magick'

            if (Test-Path -Path "${MagickPath}\magick.exe") {

                "LET'S CONVERT .HEIC IMAGES to .JPGs!"

                $count=0
                Set-Location "${MagickPath}"
                Get-ChildItem -Path "${Destination}\*.HEIC" | ForEach-Object {
                    $oldName = $_.Name
                    $newName = $oldName.Substring(0,$oldName.Length-5)
                    $newName = "$newName.JPG"

                    $From = "$Destination\$oldName"
                    $To = "$Destination\$newName"

                    # Write-Host "Conversione immagine $j di ${heic_count}: $oldName"
                    .\magick.exe convert -quiet $From -quality 98 $To
                    # .\magick.exe convert $From $To

                    $count++
                    $percent = [int](($count * 100) / $Heic_count)
                    Write-Progress -Activity "Conversion from HEIC to JPG in progress..." -status "Converted ${count} / ${Heic_count}: ${percent}%"
                }
                Set-Location "${PSScriptRoot}"

                Write-Host "Conversion completed successfully!" -ForegroundColor Green
                " "

                # if you don't want HEIC images, since they have just been converted...
                if ($Y) {
                    Write-Host "Deleting .HEIC images..."
                    Remove-Item "$Destination/*.HEIC"
                    Write-Host "Deletion completed!" -ForegroundColor Green
                }
                # if -Y is not specified the program asks if you want to delete them
                else {
                    $isCorrect=$true
                    while ($isCorrect) {
                        $wantToDelete = Read-Host "Do you want to delete imported .HEIC images in '${Destination}' path? ['Y' to delete them; 'N' to keep them]"
                        if ($wantToDelete.ToLower() -eq "y") {
                            Write-Host "Deleting .HEIC images in '${Destination}' path..."
                            Remove-Item "$Destination/*.HEIC"
                            Write-Host "All .HEIC images deleted!" -ForegroundColor Green
                            $isCorrect=$false
                        }
                        elseif ($wantToDelete -eq "n") {
                            Write-Host "Ok, let's keep .HEIC images!" -ForegroundColor Green
                            $isCorrect=$false
                        }
                    }
                }
            }
            else {
                Write-Host "Ouch! I cannot convert .HEIC images into .JPG because I cannot find magick.exe in this path" -ForegroundColor Red
            }
        }

        " "
        if ($Folders) {
            # Images and videos are oranized into directories

            Set-Location $Destination
            "Let's divide photos and videos into directories!"

            mkdir "Camera Roll" > $null
            Move-Item "*IMG_*.JPG" "Camera Roll\"
            # there can still be .HEIC images
            Move-Item "*.HEIC" "Camera Roll\"
            Move-Item "*IMG_E*.JPG" "Camera Roll\"

            mkdir Screenshot > $null
            Move-Item "*IMG_*.PNG" "Screenshot\"

            mkdir "Received\" > $null
            Move-Item "*.JPG" "Received\"

            mkdir "Videos\" > $null
            Move-Item "*.MOV" "Videos\"
            Move-Item "*.MP4" "Videos\"

            mkdir "Other\" > $null
            Move-Item "*.MOV" "Other\"
            Move-Item "*.MP4" "Other\"
            Move-Item "*.JPG" "Other\"
            Move-Item "*.PNG" "Other\"
            Move-Item "*.HEIC" "Other\"
            Move-Item "*.JPEG" "Other\"

            Write-Host "Directories organization completed!" -ForegroundColor Green

            Set-Location $PSScriptRoot
        }

    }
}
else { Write-Host "'$PhoneName' is not connected!" -ForegroundColor Red }

