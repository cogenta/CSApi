//
//  CSApi.h
//  CSApi
//
//  Created by Will Harris on 28/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSCredential;

@protocol CSApplication;

@protocol CSUser;
@protocol CSMutableUser;

@protocol CSListPage;

@protocol CSRetailer;
@protocol CSRetailerList;
@protocol CSRetailerListPage;

@protocol CSLike;
@protocol CSMutableLike;
@protocol CSLikeList;
@protocol CSLikeListPage;

@protocol CSGroup;
@protocol CSMutableGroup;
@protocol CSGroupList;
@protocol CSGroupListPage;

@protocol CSPicture;
@protocol CSPictureListPage;
@protocol CSPictureList;

@protocol CSImage;
@protocol CSImageList;
@protocol CSImageListPage;

@protocol CSProductSummaryListPage;
@protocol CSProductSummaryList;
@protocol CSProductSummary;

/**
 Provides access to the Cogenta Shopping API.
 
 Once you have obtains a bookmark, username, and password for your application
 from Cogenta, use them to initialize a CSAPI object. Here's an example that
 initializes the API in the app's delegate:
 
    #define kAPIBookmark @"https://api.cogenta.com/apps/51139a687046797035ad6db6"
    #define kAPIUsername @"53a2abd8-5a96-47a8-8a1f-82cf4a462b57"
    #define kAPIPassword @"ecd50b80-f1f1-4500-816e-ae16f179dd98"
 
    @implementation MyAppDelegate
 
    - (BOOL)application:(UIApplication *)application
        didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
    {
        CSAPI *api = [CSAPI apiWithBookmark:kAPIBookmark
                                   username:kAPIUsername
                                   password:kAPIPassword];
        // ...
    }
 
    // ...
 
    @end
 
 Most applications should then use the convenience method login: to obtain a
 user object. login: creates a user if necessary and returns it via the callback
 provided by the app. login: also persists the URI and credentials of the user,
 so subsequent calls to the login: will get the same user.
 
 Apps that require more control over user creation (for example, to use more
 than one user resource) can obtain an application object with
 [getApplication:]([CSAPI getApplication:]), create users with
 [createUserWithChange:callback:]([CSApplication createUserWithChange:callback:]),
 and retrieve existing users with
 [getUser:credential:callback:]([CSAPI getUser:credential:callback:]).
 
 */
@interface CSAPI : NSObject

/** The bookmark for this endpoint. */
@property (readonly) NSString *bookmark;

/** The credential for this endpoint. */
@property (readonly) id<CSCredential> credential;

/** Returns an endpoint with the given settings.
 
 @param bookmark The bookmark identifying the application using the API.
 @param username The username used to authenticate API calls with the server.
 @param password The password used to authenticate API calls with the server.
 @return An API endpoint initialized with the given settings.
 */
+ (instancetype)apiWithBookmark:(NSString *)bookmark
                       username:(NSString *)username
                       password:(NSString *)password;

/** Tries to get an application object.
 
 This method uses the CSAPI's bookmark and credentials to fetch the application
 resource.
 
 Control returns from getApplication: immediately. If the operation is
 successful, callback is invoked with a non-nil
 [id\<CSApplication\>](CSApplication) in app and a nil error. If the operation
 fails, callback is invoked with a nil app and a non-nil error.
 
 @param callback The block to invoke when the application has been successfully
 obtained, or when the operation has failed.
 */
- (void)getApplication:(void (^)(id<CSApplication> app,
                                 NSError *error))callback;

/** Tries to get an arbitrary user object.
 
 Control returns from getUser:credential:callback: immediately. If the
 operation is successful, callback is invoked with a non-nil
 [id\<CSUser\>](CSUser) in user and a nil error. If the operation fails,
 callback is invoked with a nil user and a non-nil error.
 
 @param URL the URL of the user to fetch.
 @param credential the credential to use to get the user.
 @param callback The block to invoke when the user has been successfully
 obtained, or when the operation has failed.
 */
- (void)getUser:(NSURL *)URL
     credential:(id<CSCredential>)credential
       callback:(void (^)(id<CSUser> user, NSError *error))callback;

/** Tries to obtain a the app's user.
 
 If the app has not had a user for this CSAPI's bookmark before, login: will
 try to create a new user and, if successful, will persist the URI and
 credential of the new user. If the app has already created a user, login: will
 try to fetch the latest version of the user.
 
 Control returns from login: immediately. If the login operation is successful
 callback is invoked with a non-nil [id\<CSUser\>](CSUser) in user and a nil
 error. If the login operation fails, callback is invoked with a nil user and a
 non-nil error.
 
 Example:
 
    [self.api login:^(id<CSUser> user, NSError *error) {
    // do stuff with user
    }];
 
 @param callback The block to invoke when the user has been successfully
 obtained, or when the operation has failed.
    
 @see CSUser
 */
- (void)login:(void (^)(id<CSUser> user, NSError *error))callback;

@end

/** Protocol for interacting with an application resource. */
@protocol CSApplication <NSObject>

/** The application's name. */
@property (readonly) NSString *name;

/** Tries to create a user with the state defined by the given change.
 
 Control returns from createUserWithChange:callback: immediately after the
 block, change, finishes and an attempt is made to create the resource in the
 background. If the operation is successful, callback is invoked with a non-nil
 [id\<CSUser\>](CSUser) in user and a nil error. If the operation fails,
 callback is invoked with a nil user and a non-nil error.
  
 @param change A block accepting an object conforming to CSMutableUser that
 makes edits to that object.
 @param callback The block to invoke when the user has been successfully
 created, or when the operation has failed.
 */
- (void)createUserWithChange:(void (^)(id<CSMutableUser> user))change
                    callback:(void (^)(id<CSUser> user,
                                       NSError *error))callback;

/** Tries to get a list of retailers for the application.
 
 This method uses the application's credentials to fetch the retailers resource.
 
 Control returns from getRetailers: immediately. If the operation is
 successful, the given callback is invoked with a non-nil
 [id\<CSRetailerListPage\>](CSRetailerListPage) in firstPage and a nil error.
 firstPage is the first page of the result set. It is recommended that client
 code uses firstPage.retailerList to get an
 [id\<CSRetailerList\>](CSRetailerList), which provides convenient access to
 retailers in the list.
 
 If the operation fails, callback is invoked with a nil firstPage and a non-nil
 error.

 @param callback The block to invoke when the retailer list has been
 successfully obtained, or when the operation has failed.
 
 */
- (void)getRetailers:(void (^)(id<CSRetailerListPage> firstPage,
                               NSError *error))callback;

@end

/** Protocol for interacting with a user resource. */
@protocol CSUser <NSObject>

/** @name Bookkeeping */

/** URL of the user resource. */
@property (readonly) NSURL *URL;

/** Entity tag of the user resource. */
@property (readonly) id etag;

/** The user's credential. */
@property (readonly) id<CSCredential> credential;

/** @name User state */

/** The user's reference string.
 
 The reference is intended to be used to link the Cogenta Shopping API user
 with the developer's own system. The developer's administrative API provides
 a way to search for all that developer's users with a matching reference.
 */
@property (readonly) NSString *reference;

/** A dictionary of additional information about the user. */
@property (readonly) NSDictionary *meta;

/** @name Mutability */

/** Attempts to apply the given change to the user resource.
 
 change:callback: returns immediately after the block, change, finishes and an
 attempt is made to apply any edits in the background. If the user is found to
 be out of date, for example if another client has modified the underlying user
 since the user was obtained, the change block will be invoked again with the
 new user data.
 
 If the edits are applied successfully, this user object is made up-to-date then
 `callback(YES, nil)` is invoked. If an error is detected, callback will be
 invoked with `NO` in the first argument an the error in the second argument.

 @param change A block accepting an object conforming to CSMutableUser that
 makes edits to that object.
 
 @param callback A block accepting a boolean success value and an error object
 that is invoked when the API call has finished.
 
 @see CSMutableUser
 */
- (void)change:(void (^)(id<CSMutableUser> user))change
      callback:(void (^)(BOOL success, NSError *error))callback;

/** @name Likes */

/** Tries to get a list of likes for the user.
 
 This method uses the user's credentials to fetch the likes resource.
 
 Control returns from getLikes: immediately. If the operation is successful,
 the given callback is invoked with a non-nil
 [id\<CSLikesListPage\>](CSLikesListPage) in firstPage and a nil error.
 firstPage is the first page of the result set. It is recommended that client
 code uses firstPage.likesList to get an [id\<CSLikesList\>](CSLikesList), which
 provides convenient access to likes in the list.
 
 If the operation fails, callback is invoked with a nil firstPage and a non-nil
 error.
 
 @param callback The block to invoke when the likes list has been
 successfully obtained, or when the operation has failed.
 
 */
- (void)getLikes:(void (^)(id<CSLikeListPage> firstPage,
                           NSError *error))callback;

/** @name Groups */

/** Tries to create a group with the state defined by the given change.
 
 Control returns from createGroupWithChange:callback: immediately after the
 block, change, finishes and an attempt is made to create the resource in the
 background. If the operation is successful, callback is invoked with a non-nil
 [id\<CSGroup\>](CSGroup) in group and a nil error. If the operation fails,
 callback is invoked with a nil group and a non-nil error.
 
 @param change A block accepting an object conforming to CSMutableGroup that
 makes edits to that object.
 @param callback The block to invoke when the group has been successfully
 created, or when the operation has failed.
 */
- (void)createGroupWithChange:(void (^)(id<CSMutableGroup>))change
                     callback:(void (^)(id<CSGroup> group,
                                        NSError *error))callback;

/** Tries to get a list of groups for the user.
 
 This method uses the user's credentials to fetch the user's groups resource.
 
 Control returns from getGroups: immediately. If the operation is successful,
 the given callback is invoked with a non-nil
 [id\<CSGroupListPage\>](CSGroupListPage) in firstPage and a nil error.
 firstPage is the first page of the result set. It is recommended that client
 code uses firstPage.groupList to get an [id\<CSGroupList\>](CSGroupList), which
 provides convenient access to groups in the list.
 
 If the operation fails, callback is invoked with a nil firstPage and a non-nil
 error.
 
 @param callback The block to invoke when the groups list has been
 successfully obtained, or when the operation has failed.
 
 */
- (void)getGroups:(void (^)(id<CSGroupListPage> firstPage,
                            NSError *error))callback;

/** Searches for groups that match the given reference.
 
 This method uses the user's credentials to search for groups belonging to the
 user that match the given `reference`.
 
 Control returns from getGroups: immediately. If the operation is successful,
 the given callback is invoked with a non-nil
 [id\<CSGroupListPage\>](CSGroupListPage) in firstPage and a nil error.
 firstPage is the first page of the result set. It is recommended that client
 code uses firstPage.groupList to get an [id\<CSGroupList\>](CSGroupList), which
 provides convenient access to groups in the list.
 
 If the operation fails, callback is invoked with a nil firstPage and a non-nil
 error.
 
 @param reference The reference used to search for groups.
 @param callback The block to invoke when the groups list has been
 successfully obtained, or when the operation has failed.
 
 */
- (void)getGroupsWithReference:(NSString *)reference
                      callback:(void (^)(id<CSGroupListPage> firstPage,
                                         NSError *error))callback;
@end

/** Protocol for making changes to a user.
 
 See [CSUser change:callback:].
 */
@protocol CSMutableUser <NSObject>

/** URL for the user. */
@property (readonly) NSURL *URL;

/** The user's reference string. */
@property (nonatomic, strong) NSString *reference;

/** A dictionary of additional information about the user. */
@property (nonatomic, strong) NSMutableDictionary *meta;

@end


/** Protocol for accessing pages of items in a sequence of results.
 
 The API may break large lists of results (for example from a search) into
 a sequence of pages. Except for the first and last pages, every page has a link
 to the previous page in sequence and a link the the next page in sequence. The
 first and last pages lack links to the previous and next pages respectively. If
 there is only one page of results, that page will have neither a previous page
 nor a next page.
 
 */
@protocol CSListPage <NSObject>

/** URL for the page. */
@property (readonly) NSURL *URL;

/** The number of items in the entire result set. */
@property (readonly) NSUInteger count;

/** The items on this page.
 
 Each object in the array conforms to CSListItem.
 */
@property (readonly) NSArray *items;

/** Boolean indicating whether there is a page after this page. */
@property (readonly) BOOL hasNext;

/** Tries to fetch the page after this page in sequence.
 
 Control returns from getNext: immediately. If the operation is
 successful, the given callback is invoked with a non-nil
 [id\<CSListPage\>](CSListPage) in page and a nil error. If the operation fails,
 callback is invoked with a nil page and a non-nil error.

 The operation will fail if hasNext is false.
 
 @param callback The block to invoke when the next page has been
 successfully obtained, or when the operation has failed.
 */
- (void)getNext:(void (^)(id<CSListPage> page, NSError *error))callback;

/** Boolean indicating whether there is a page before this page. */
@property (readonly) BOOL hasPrev;

/** Tries to fetch the page before this page in sequence.
 
 Control returns from getPrev: immediately. If the operation is
 successful, the given callback is invoked with a non-nil
 [id\<CSListPage\>](CSListPage) in page and a nil error. If the operation fails,
 callback is invoked with a nil page and a non-nil error.
 
 The operation will fail if hasPrev is false.
 
 @param callback The block to invoke when the previous page has been
 successfully obtained, or when the operation has failed.
 */
- (void)getPrev:(void (^)(id<CSListPage> page, NSError *error))callback;

@end


/** Protocol for accessing an item in a sequence of results. */
@protocol CSListItem <NSObject>

/** A URL identifying the item. */
@property (readonly) NSURL *URL;

@end

/** Protocol for accessing a retailer. */
@protocol CSRetailer <NSObject>

/** The URL of the retailer. */
@property (readonly) NSURL *URL;

/** The name of the retailer. */
@property (readonly) NSString *name;

/** Tries to fetch a description of the retailer's logo.
 
 Control returns from getLogo: immediately. If the operation is
 successful, the given callback is invoked with a non-nil
 [id\<CSPicture\>](CSPicture) in picture and a nil error. If the operation
 fails, callback is invoked with a nil picture and a non-nil error.
 
 @param callback The block to invoke when the picture has been
 successfully obtained, or when the operation has failed.
 */
- (void)getLogo:(void (^)(id<CSPicture> picture, NSError *error))callback;

- (void)getProductSummaries:(void (^)(id<CSProductSummaryListPage> productSummaries,
                             NSError *error))callback;

@end

/** Protocol for accessing a list of items. */
@protocol CSList <NSObject>

/** The number of items in the list. */
@property (readonly) NSUInteger count;

@end

/** Protocol for accessing a list of retailers. */
@protocol CSRetailerList <CSList>

/** Tries to fetch the retailer at the given index.
 
 Control returns from getRetailerAtIndex:callback: immediately. If the operation
 is successful, the given callback is invoked with a non-nil
 [id\<CSRetailer\>](CSRetailer) in retailer and a nil error. If the operation
 fails, callback is invoked with a nil retailer and a non-nil error.
 
 @param index The index in the sequence of the retailer to retrieve.
 @param callback The block to invoke when the retailer has been successfully
 obtained, or when the operation has failed.
 */
- (void)getRetailerAtIndex:(NSUInteger)index
                  callback:(void (^)(id<CSRetailer> retailer,
                                     NSError *error))callback;

@end


/** Protocol for accessing a list of likes. */
@protocol CSLikeList <CSList>

/** Tries to fetch the like at the given index.
 
 Control returns from getLikeAtIndex:callback: immediately. If the operation
 is successful, the given callback is invoked with a non-nil
 [id\<CSLike\>](CSLike) in like and a nil error. If the operation
 fails, callback is invoked with a nil like and a non-nil error.
 
 @param index The index in the sequence of the like to retrieve.
 @param callback The block to invoke when the like has been successfully
 obtained, or when the operation has failed.
 */
- (void)getLikeAtIndex:(NSUInteger)index
              callback:(void (^)(id<CSLike> like, NSError *error))callback;

@end


/** Protocol for accessing a list of groups. */
@protocol CSGroupList <CSList>

/** Tries to fetch the groups at the given index.
 
 Control returns from getGroupAtIndex:callback: immediately. If the operation
 is successful, the given callback is invoked with a non-nil
 [id\<CSGroup\>](CSGroup) in group and a nil error. If the operation
 fails, callback is invoked with a nil group and a non-nil error.
 
 @param index The index in the sequence of the group to retrieve.
 @param callback The block to invoke when the group has been successfully
 obtained, or when the operation has failed.
 */
- (void)getGroupAtIndex:(NSUInteger)index
               callback:(void (^)(id<CSGroup> group, NSError *error))callback;

@end


/** Protocol for accessing pages of retailers in a sequence of results.
 
 Client code is expected to use this protocol's retailerList property to get
 an object conforming to CSRetailerList.
 
 */
@protocol CSRetailerListPage <CSListPage>

/** An object conforming to CSRetailerList that provides convenient access to
 the list of retailers.
 */
@property (readonly) id<CSRetailerList> retailerList;

@end

/** Protocol for accessing likes.
 
 A like is a record of the fact that a user is interested in a particular
 resource. Likes are created using the createLikeWithChange:callback: method
 on CSGroup.
 */
@protocol CSLike <NSObject>

/** The URL of the resource in which the user is interested. */
@property (readonly) NSURL *likedURL;

/** Tries to delete the like.
 
 Control returns from remove: immediately. If the operation is successful, the
 given callback is invoked with a YES in success and a nil error. If the
 operation fails, callback is invoked with a FALSE success value and a non-nil
 error.
 
 @param callback The block to invoke when the like has been successfully
 deleted, or when the operation has failed.
 */
- (void)remove:(void (^)(BOOL success, NSError *error))callback;

@end

/** Protocol for making changes to a like.
 
 See [CSGroup createLikeWithChange:callback:].
 */
@protocol CSMutableLike <NSObject>

/** The URL of the resource in which the user is interested. */
@property (nonatomic, strong) NSURL *likedURL;

@end

/** Protocol for accessing a group of likes.
 
 A group is a collection of likes with additional reference and meta data.
 Groups are created using the createGroupWithChange:callback: method on CSUser.
 */
@protocol CSGroup <NSObject>

/** URL of the user resource. */
@property (readonly) NSURL *URL;

/** The group's reference string.
 
 The reference is intended to be used to link the Cogenta Shopping API group
 with the developer's own system. A method on CSUser provides access to the
 user's groups that match a particular reference.
 */
@property (readonly) NSString *reference;

/** A dictionary of additional information about the group. */
@property (readonly) NSDictionary *meta;

/** Attempts to apply the given change to the group resource.
 
 change:callback: returns immediately after the block, change, finishes and an
 attempt is made to apply any edits in the background. If the group is found to
 be out of date, for example if another client has modified the underlying group
 since the group was obtained, the change block will be invoked again with the
 new user data.
 
 If the edits are applied successfully, this group object is made up-to-date
 then `callback(YES, nil)` is invoked. If an error is detected, callback will be
 invoked with `NO` in the first argument an the error in the second argument.
 
 @param change A block accepting an object conforming to CSMutableGroup that
 makes edits to that object.
 
 @param callback A block accepting a boolean success value and an error object
 that is invoked when the API call has finished.
 
 @see CSMutableGroup
 */
- (void)change:(void (^)(id<CSMutableGroup> group))change
      callback:(void (^)(BOOL success, NSError *error))callback;

/** Tries to get a list of likes for the group.
 
 This method uses the user's credentials to fetch the likes resource.
 
 Control returns from getLikes: immediately. If the operation is successful,
 the given callback is invoked with a non-nil
 [id\<CSLikeListPage\>](CSLikeListPage) in firstPage and a nil error.
 firstPage is the first page of the result set. It is recommended that client
 code uses firstPage.likesList to get an [id\<CSLikeList\>](CSLikeList), which
 provides convenient access to likes in the list.
 
 If the operation fails, callback is invoked with a nil firstPage and a non-nil
 error.
 
 @param callback The block to invoke when the likes list has been
 successfully obtained, or when the operation has failed.
 
 */
- (void)getLikes:(void (^)(id<CSLikeListPage> firstPage,
                           NSError *error))callback;

/** Tries to create a like with the state defined by the given change.
 
 Control returns from createLikeWithChange:callback: immediately after the
 block, change, finishes and an attempt is made to create the resource in the
 background. If the operation is successful, callback is invoked with a non-nil
 [id\<CSLike\>](CSLike) in like and a nil error. If the operation fails,
 callback is invoked with a nil like and a non-nil error.
 
 @param change A block accepting an object conforming to CSMutableLike that
 makes edits to that object.
 @param callback The block to invoke when the like has been successfully
 created, or when the operation has failed.
 */
- (void)createLikeWithChange:(void (^)(id<CSMutableLike>))change
                    callback:(void (^)(id<CSLike> like,
                                       NSError *error))callback;

/** Tries to delete the group.
 
 Control returns from remove: immediately. If the operation is successful, the
 given callback is invoked with a YES in success and a nil error. If the
 operation fails, callback is invoked with a FALSE success value and a non-nil
 error.
 
 @param callback The block to invoke when the group has been successfully
 deleted, or when the operation has failed.
 */
- (void)remove:(void (^)(BOOL success, NSError *error))callback;

@end

/** Protocol for making changes to a group.
 
 See [CSGroup change:callback:] and [CSUser createGroupWithChange:callback:].
 */
@protocol CSMutableGroup <NSObject>

/** URL for the group. */
@property (readonly) NSURL *URL;

/** The group's reference string. */
@property (nonatomic, strong) NSString *reference;

/** A dictionary of additional information about the group. */
@property (nonatomic, strong) NSMutableDictionary *meta;

@end

/** Protocol for accessing pages of likes in a sequence of results.
 
 Client code is expected to use this protocol's likeList property to get an
 object conforming to CSLikeList.
 */
@protocol CSLikeListPage <CSListPage>

/** An object conforming to CSLikeList that provides convenient access to the
 list of likes.
 */
@property (readonly) id<CSLikeList> likeList;

@end

/** Protocol for accessing pages of group in a sequence of results.
 
 Client code is expected to use this protocol's groupList property to get an
 object conforming to CSGroupList.
 */
@protocol CSGroupListPage <CSListPage>

/** An object conforming to CSGroupList that provides convenient access to the
 list of groups.
 */
@property (readonly) id<CSGroupList> groupList;

@end

/** Protocol for accessing pictures.
 
 Conceptually, a picture is a notional abstract element of visual information.
 Since the API is intended to be used with devices that cannot render abstract
 objects and by users who cannot perceive them, a picture also provides access
 to a collection of concrete images that approximate the true picture and can be
 rendered and perceived.
 
 Client code is expected to use this protocol's imageList property to get an
 object confirming to CSImageList.
 */
@protocol CSPicture <CSListPage>

/** An object confirming to CSImageList that provides convenient access to the
 list of images.
 */
@property (readonly) id<CSImageList> imageList;

@end

/** Protocol for accessing a list of images. */
@protocol CSImageList <CSList>

/** Tries to fetch the image at the given index.
 
 Control returns from getImageAtIndex:callback: immediately. If the operation
 is successful, the given callback is invoked with a non-nil
 [id\<CSImage\>](CSImage) in image and a nil error. If the operation
 fails, callback is invoked with a nil image and a non-nil error.
 
 @param index The index in the sequence of the image to retrieve.
 @param callback The block to invoke when the image has been successfully
 obtained, or when the operation has failed.
 */
- (void)getImageAtIndex:(NSUInteger)index
               callback:(void (^)(id<CSImage> image, NSError *error))callback;

@end

/** Protocol for accessing an image.
 
 An image is metadata about an raster image file.
 */
@protocol CSImage <NSObject>

/** The width of the raster image in pixels. */
@property (readonly) NSNumber *width;

/** The height of the raster image in pixels. */
@property (readonly) NSNumber *height;

/** A URL where the raster image file can be obtained. */
@property (readonly) NSURL *enclosureURL;

/** The content type of the raster image file at the URL. */
@property (readonly) NSString *enclosureType;

@end

@protocol CSProductSummaryListPage <CSListPage>

@property (readonly) id<CSProductSummaryList> productSummaryList;

@end

@protocol CSProductSummaryList <CSList>

- (void)getProductSummaryAtIndex:(NSUInteger)index
                        callback:(void (^)(id<CSProductSummary>, NSError *))callback;

@end

@protocol CSProductSummary <NSObject>

@property (readonly) NSString *name;

- (void)getPictures:(void (^)(id<CSPictureListPage> pictures, NSError *error))callback;

@end

@protocol CSPictureListPage <CSListPage>

@property (readonly) id<CSPictureList> pictureList;

@end

@protocol CSPictureList <CSList>

- (void)getPictureAtIndex:(NSUInteger)index
                 callback:(void (^)(id<CSPicture>, NSError *))callback;

@end
