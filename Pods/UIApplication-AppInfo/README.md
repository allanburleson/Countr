## UIApplication+AppInfo

UIApplication+AppInfo is an easy to use UIApplication axtension that allows you to access basic information about your app, such as the current version, your build number and the size of your apps documents folder.

### Installation
-  Using [CocoaPods](http://cocoapods.org):  
``pod 'UIApplication-AppInfo', '~> 0.2'``
-  Manual installation:  
Copy the following files in your Xcode project:  
``UIApplication+AppInfo.m`` and 
``UIApplication+AppInfo.h``

### Usage
-  Get the current App version:

        NSString *appVersion = [[UIApplication sharedApplication] appVersion];
    
-  Get the current build number:

        NSString *appBuild = [[UIApplication sharedApplication] appBuild];
    
-  Get the size of the apps documents folder:
  -  As formatted string (this returns values like "1,4 MB"):

          NSString *documentsFolderSize = [[UIApplication sharedApplication] documentsFolderSizeAsString];

  -  As integer (in bytes):

          int documentsFolderSize = [[UIApplication sharedApplication] documentsFolderSizeInBytes];
      

### Future Goals
-  Folder size calculation for the temp and the caches folder
-  Folder size calculation for a specific folder inside the documents, temp or caches folder 
-  Calculation if folder size is under a specific limit
-  File size calculation
