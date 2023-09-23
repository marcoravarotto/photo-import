# photo-import



SHORT DESCRIPTION
PowerShell script written to make life easier when you want to transfer photo from your Apple device (iPad/iPhone, or commonly named iThing) to your Windows PC. It also convers .HEIC photos to .JPG (needs ImageMagick), and renames all photos and videos in YYYYMMDD_hhmmss_&lt;OriginalFileName>



LONG DESCRIPTION
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
[1]. copy photos and video from your iThing to your PC. You can choose to copy all photos and videos, or specify a date range you want
[2]. organize these copied photos and videos in 'Camera Roll', 'Screenshot', and 'Received' directories
[3]. convert all .HEIC images in .JPG
[4]. rename all photos and videos in YYYYMMDD_hhmmss_<OriginalFileName>
