#import "nfc_config.h"

@implementation NfcConfig

- (id)initWithData:(NSString*)url
         saveFiles:(BOOL)saveAdditionalFiles
          saveAuth:(BOOL)saveAuthResult
       saveNfcData:(BOOL)saveNfcResult
      showProgress:(BOOL)showProgress
{
    if (![super init])
        return nil;

    mUrl = url;
    mSaveAdditionalFiles = saveAdditionalFiles;
    mSaveAuthResult = saveAuthResult;
    mSaveNfcResult = saveNfcResult;
    mShowProgress = showProgress;

    return self;
}

- (NSString*)getUrl
{
    return mUrl;
}

- (void)setUrl:(NSString*)url
{
    mUrl = url;
}

- (BOOL)getSaveAdditionalFiles
{
    return mSaveAdditionalFiles;
}

- (void)setSaveAdditionalFiles:(BOOL)saveAdditionalFiles
{
    mSaveAdditionalFiles = saveAdditionalFiles;
}

- (BOOL)getSaveAuthResult
{
    return mSaveAuthResult;
}

- (void)setSaveAuthResult:(BOOL)saveAuthResult
{
    mSaveAuthResult = saveAuthResult;
}

- (BOOL)getSaveNfcResult
{
    return mSaveNfcResult;
}

- (void)setSaveNfcResult:(BOOL)saveNfcResult
{
    mSaveNfcResult = saveNfcResult;
}

- (BOOL)getShowProgress
{
    return mShowProgress;
}

- (void)setShowProgress:(BOOL)showProgress
{
    mShowProgress = showProgress;
}

@end
