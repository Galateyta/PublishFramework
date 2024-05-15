#ifndef NfcConfig_h
#define NfcConfig_h

#import <Foundation/Foundation.h>

__attribute__((visibility("default")))
@interface NfcConfig : NSObject
{
    NSString* mUrl;
    BOOL mSaveAdditionalFiles;
    BOOL mSaveAuthResult;
    BOOL mSaveNfcResult;
    BOOL mShowProgress;
}

- (id)initWithData:(NSString*)url
         saveFiles:(BOOL)saveAdditionalFiles
          saveAuth:(BOOL)saveAuthResult
       saveNfcData:(BOOL)saveNfcResult
      showProgress:(BOOL)showProgress;

- (NSString*)getUrl;
- (void)setUrl:(NSString*)url;

- (BOOL)getSaveAdditionalFiles;
- (void)setSaveAdditionalFiles:(BOOL)saveAdditionalFiles;

- (BOOL)getSaveAuthResult;
- (void)setSaveAuthResult:(BOOL)saveAuthResult;

- (BOOL)getSaveNfcResult;
- (void)setSaveNfcResult:(BOOL)saveNfcResult;

- (BOOL)getShowProgress;
- (void)setShowProgress:(BOOL)showProgress;

@end

#endif /* NfcConfig_h */
