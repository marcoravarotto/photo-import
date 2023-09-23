# photo-import


## Short Description
PowerShell script written to make life easier when you want to transfer photo from your Apple device (iPad/iPhone, or commonly named iThing) to your Windows PC. It also convers .HEIC photos to .JPG (needs ImageMagick), and renames all photos and videos in YYYYMMDD_hhmmss_&lt;OriginalFileName>

## Long description
This PowerShell script has been written to make life easier when you want to transfer photo from your Apple device to your Windows PC. 
I speak from experience: with Android you can plug your phone to your PC, and you can copy everything you want from your phone to PC, and vice-versa. This is a really satisfying experience!
If you have an iPhone, you can't.
If you want to pass something from PC or vice-versa to iThins you must deal with iTunes.
You can use iTunes to 'synchronise' your PC photos with your iThings, i.e. you can copy photos from PC to your iThins, but then from your iThings you cannot delete them! In order to do this you have to plug you iThings to the PC and then you can remove the synchronized PC directory...

This is so frustrating.

When you plug iThing to PC, you can see the DCIM directory content, but photos and videos are organized in sub-directories named with 'YYYYMM__' naming convention, and all files have strange names like IMG_1234.HEIC, KGVNWONG.JPG, AJFOWOKF.PNG, IMG_1465.MOV, ...
What if I want to copy only images and videos from 31st December at 23:20 and 1st January at 23:10? 
Android: you navigate DCIM directory and every file is named IMG-YYYYMMDD_hhmmss format, so you can easily select what you want, copy them, and paste in your PC. Simple.
iPhone: try to navigate DCIM directory, and tell me if you can easily find what you want!
'You should install iCloud and synchronize photos/videos with it' bla bla bla... I don't want iCloud! I have 512 GB iPhone, and should I use a 5 GB iCloud plan, or pay 2$ every month for 50 GB storage, all this only this to copy photos to PC? Are we crazy?

Then I discovered .HEIC format, that Windows doesn't support. You copy your wanderful .HEIC image to your PC, and then? Windows can't open it.
Thank you ImageMagick.

Videos suffer from the same problem: if you have recorded a IMG_1234.MOV with 'high efficiency', its codec is h265, and Windows can't open it.
Thank you ffmpeg.

For this reason I have chosen to write this program with which you can pass photos and video from your iThing to your PC, and do more things:
1. copy photos and video from your iThing to your PC. You can choose to copy all photos and videos, or specify a date range you want
2. organize these copied photos and videos in 'Camera Roll', 'Screenshot', and 'Received' directories
3. convert all .HEIC images in .JPG
4. rename all photos and videos in YYYYMMDD_hhmmss_OriginalFileName

## Usage
If you need help
```PowerShell
Get-Help photoImport.ps1
```

## Parameters
### -PhoneName
Name of your Apple Device, i.e. name you find in Removable Device when you plug it to PC\
Default: 'Apple iPhone' if nothing is specified.

### -From
Date from which you want to copy photos/videos. You can specify this date in one of these formats:\
'saturday 1 january 2019 13:15:03'\
'1 january 2019 13:15:03'\
'1 jan 2019 13:15:03'\
'01/01/2019 13:15:03'\
If you don't specify the year and hours, it considers the current year, and 00:00:00 respectively.\
For example '1 jan' is Saturday 1st January 2022 at 00:00:00\
Default: today at 00:00:00 if nothing is specified.

### -To
Date up to which you want to copy photos/videos. Same date format of [-From] parameter.\
Default: $date_import if nothing is specified.

### -All
If you specify it, you select all photos and videos in your iThing.

### -Destination
Destination directory in your PC.\
Default: if you don't specify a path, it creates an 'IMPORT' directory in the same directory of this script.\
If there already is an 'IMPORT' directory, the program creates an 'IMPORT_CurrentDate' directory.

### -Import
If specified, the program copies photos and videos of the specified date range to the specified destination folder.\
Other parameters you can add with [-Import] declared are [-Heic], [-Y], [-Folders]

### -Heic
If it is passed with [-Import] specified, it converts images from .HEIC to .JPG formats. To do so you need to specify ImageMagick folder path with next parameter. This parameters invokes ImageMagick 'magick.exe' and it converts images with 98% quality.

### -MagickPath
"magick.exe" folder path. You must specify it if you want to convert images from .HEIC to .JPG

### -Y
If you specify it after [-Heic] all .HEIC images will be firstly converted to .JPG and then deleted.\
If you don't specify if, the program asks if you want to delete .HEIC images after their conversion to .JPG.

### -Folders
If declared, the program organize all copied photos and videos in 'Camera Roll', 'Screenshot', and 'Received' directories.



# Examples
### Example 1
If an "Apple iPhone" is connected to PC, it returns a full report of all photos/videos stored in your iThing from today at 00:00:00
```PowerShell
.\photoImport.ps1
```
If Windows names your iThing with a different name, for example "EleanorPhone", you have to specify the actual name
```PowerShell
.\photoImport.ps1 -PhoneName "EleanorPhone"
```

### Example 2
It copies all photos/videos from today at 00:00:00 from your "Apple iPhone" (default name) to IMPORT directory, created in the same directory the script is
```PowerShell
.\photoImport.ps1 -Import
```

### Example 3
It copies all photos/videos from your "Apple iPhone" (default name) to IMPORT directory
```PowerShell
.\photoImport.ps1 -Import -All
```

### Example 4
It copies photos/videos you have taken from 1st March 2019 at 13:20:10 to 30th april 2022 at 00:00:00 to "C:\iPhoneImportPhotos" directory, and all .HEIC images are converted to .JPG and then deleted. 
ImageMagick in "C:\My Programs\ImageMagick-7.1.1-17-portable-Q16-HDRI-x64" folder do photo conversion from .HEIC to .JPG. 
All photos/videos are then organized in 'Camera Roll', 'Screenshot', and 'Received' directories.
```PowerShell
.\photoimport.ps1 -from '1 march 2019 13:20:10' -to '30 april' -import -Destination "C:\iPhoneImportPhotos" -heic -MagickPath "C:\My Programs\ImageMagick-7.1.1-17-portable-Q16-HDRI-x64" -y -folders
```


## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

Please make sure to update tests as appropriate.

