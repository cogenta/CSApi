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

@protocol CSProductListPage;
@protocol CSProductList;
@protocol CSProduct;

@protocol CSPriceListPage;
@protocol CSPriceList;
@protocol CSPrice;

@protocol CSCategoryListPage;
@protocol CSCategoryList;
@protocol CSCategory;

@protocol CSSlice;
@protocol CSNarrow;
@protocol CSNarrowListPage;
@protocol CSNarrowList;

@protocol CSAuthor;
@protocol CSCoverType;
@protocol CSManufacturer;
@protocol CSSoftwarePlatform;

/**
 Provides a handle to the network request for an API invocation.
 
 Some API methods return an [id<CSAPIRequest>](CSAPIRequest) in addition to
 accepting a callback argument. This object may be used to cancel the API
 invocation's underlying network request.
 */
@protocol CSAPIRequest <NSObject>

/**
 Cancels the API invocation's underlying network request. If the request is in
 progress, the callback given to the API method will be invoked with an error.
 This method has no effect of the callback has already been invoked, or if the
 request has already been canceled.
 */
- (void)cancel;

@end

/** Protocol shared by server-side resource. */
@protocol CSEntity <NSObject, NSCoding>

/** URL of the resource. */
- (NSURL *)URL;

/** Entity tag of the resource. */
- (id)etag;

/** The credential used to get the resource. */
- (id<CSCredential>)credential;

@end

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

/** Tries to get an arbitrary retailer object.
 
 Control returns from getRetailer:callback: immediately. If the operation is
 successful, callback is invoked with a non-nil [id\<CSRetailer\>](CSRetailer)
 in retailer and a nil error. If the operation fails, callback is invoked with
 a nil retailer and a non-nil error.
 
 @param URL the URL of the user to fetch.
 @param callback The block to invoke when the retailer has been successfully
 obtained, or when the operation has failed.
 */
- (void)getRetailer:(NSURL *)URL
           callback:(void (^)(id<CSRetailer> retailer, NSError *error))callback;

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
@protocol CSApplication <CSEntity>

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
@protocol CSUser <CSEntity>

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

/** Tries to get a slice that provides access to all the content accessible to
 the user.
 
 Control returns from getSlice: immediately. If the operation is successful,
 the given callback is invoked with a non-nil [id\<CSSlice\>](CSSlice) in
 result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the slice has been successfully
 obtained, or when the operation has failed.
 */
- (void)getSlice:(void (^)(id<CSSlice> slice,
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
@protocol CSListPage <CSEntity>

/** The number of items in the entire result set. */
@property (readonly) NSUInteger count;

/** The number of pages in the entire result set.
 
 The value of this property may by nil if the list does not support random
 access.
 */
@property (readonly) NSNumber *pages;

/** The number of items in the pages in this result set.
 
 The value of this property may by nil if the list does not support random
 access.
 */
@property (readonly) NSNumber *size;

/** The index of this page in the result set.
 
 The value of this property may by nil if the list does not support random
 access.
 */
@property (readonly) NSNumber *page;

/** YES if the list supports random access, or NO if it does not. */
@property (readonly) BOOL supportsRandomAccess;

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

/** Tries to fetch the page with the given index in the sequence.
 
 Control returns from getPage:callback: immediately. If the operation is
 successful, the given callback is invoked with a non-nil
 [id\<CSListPage\>](CSListPage) in page and a nil error. If the operation fails,
 callback is invoked with a nil page and a non-nil error. If the list does not
 support random access, callback is invoked with a nil page and a nil error.
 
 The operation will fail if index is less than zero or greater than or equal to
 the number of pages in the list (available from the pages property).
 
 @param index The index of the page being requested.
 @param callback The block to invoke when the page has been successfully
 obtained, of when the list does not support random access, or when the
 operation has failed.
 */
- (void)getPage:(NSUInteger)index
       callback:(void (^)(id<CSListPage> page, NSError *error))callback;

@end


/** Protocol for accessing an item in a sequence of results. */
@protocol CSListItem <NSObject>

@end

/** Protocol for accessing a retailer. */
@protocol CSRetailer <CSEntity>

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

@end

/** Protocol for accessing a list of items. */
@protocol CSList <CSEntity>

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
@protocol CSLike <CSEntity>

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
@protocol CSGroup <CSEntity>

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

/** Tries to get a slice that only includes content relating to the likes in
 this group.
 
 Control returns from getSlice: immediately. If the operation is successful,
 the given callback is invoked with a non-nil [id\<CSSlice\>](CSSlice) in
 result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the slice has been successfully
 obtained, or when the operation has failed.
 */
- (void)getSlice:(void (^)(id<CSSlice> slice,
                           NSError *error))callback;

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
@protocol CSImage <CSEntity>

/** The width of the raster image in pixels. */
@property (readonly) NSNumber *width;

/** The height of the raster image in pixels. */
@property (readonly) NSNumber *height;

/** A URL where the raster image file can be obtained. */
@property (readonly) NSURL *enclosureURL;

/** The content type of the raster image file at the URL. */
@property (readonly) NSString *enclosureType;

@end

/** Protocol for accessing pages of products in a sequence of results.
 
 Client code is expected to use this protocol's productList property to
 get an object conforming to CSProductList.
 
 */
@protocol CSProductListPage <CSListPage>

/** An object conforming to CSProductList that provides convenient access
 to the list of products.
 */
@property (readonly) id<CSProductList> productList;

@end

/** Protocol for accessing a list of product. */
@protocol CSProductList <CSList>

/** Tries to fetch the product at the given index.
 
 Control returns from getProductAtIndex:callback: immediately. If the
 operation is successful, the given callback is invoked with a non-nil
 [id\<CSProduct\>](CSProduct) in result and a nil error. If the
 operation fails, callback is invoked with a nil result and a non-nil error.
 
 @param index The index in the sequence of the product to retrieve.
 @param callback The block to invoke when the product has been
 successfully obtained, or when the operation has failed.
 */
- (void)getProductAtIndex:(NSUInteger)index
                 callback:(void (^)(id<CSProduct> result,
                                    NSError *error))callback;

@end

/** Protocol for accessing products. */
@protocol CSProduct <CSEntity>

/** The name of the product. */
@property (readonly) NSString *name;

/** The description of the product. */
@property (readonly) NSString *description_;

/** The number of times a user has viewed this product. */
@property (readonly) NSNumber *views;

/* The last time this product resource was updated. */
@property (readonly) NSDate *lastUpdated;

/** Tries to get a list of pictures of the product.
 
 Control returns from getPictures: immediately. If the operation is successful,
 the given callback is invoked with a non-nil
 [id\<CSPictureListPage\>](CSPictureListPage) in firstPage and a nil error.
 firstPage is the first page of the result set. It is recommended that client
 code use pictureList to get an [id\<CSPictureList\>](CSPictureList), which
 provides convenient access to pictures in the list.
 
 If the operation fails, callback is invoked with a nil firstPage and a non-nil
 error.
 
 @param callback The block to invoke when the pictures list has been
 successfully obtained, or when the operation has failed.
 
 */
- (void)getPictures:(void (^)(id<CSPictureListPage> firstPage,
                              NSError *error))callback;

/** Tries to get a list of prices for the product.
 
 Control returns from getPrices: immediately. If the operation is successful,
 the given callback is invoked with a non-nil
 [id\<CSPriceListPage\>](CSPriceListPage) in firstPage and a nil error.
 firstPage is the first page of the result set. It is recommended that client
 code use priveList to get an [id\<CSPriceList\>](CSPriceList), which
 provides convenient access to prices in the list.
 
 If the operation fails, callback is invoked with a nil firstPage and a non-nil
 error.
 
 @param callback The block to invoke when the prices list has been
 successfully obtained, or when the operation has failed.
 
 */
- (void)getPrices:(void (^)(id<CSPriceListPage> firstPage,
                            NSError *error))callback;


/** Get the author of this product.
 
 Control returns from getAuthor: immediately. If the operation is successful,
 and the product has an author, the given callback is invoked with a non-nil
 [id\<CSAuthor\>](CSAuthor) in result and a nil error.
 
 If the product does not have an author, the callback is invoked with a nil
 result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the author has been successfully
 obtained, or when the product has no author, or when the operation has failed.
 
 */
- (void)getAuthor:(void (^)(id<CSAuthor> result, NSError *error))callback;

/** Get the cover type of this product.
 
 Control returns from getCoverType: immediately. If the operation is successful,
 and the product has a cover type, the given callback is invoked with a non-nil
 [id\<CSCoverType\>](CSCoverType) in result and a nil error.
 
 If the product does not have a cover type, the callback is invoked with a nil
 result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the cover type has been successfully
 obtained, or when the product has no cover type, or when the operation has
 failed.
 
 */
- (void)getCoverType:(void (^)(id<CSCoverType> result, NSError *error))callback;

/** Get the manufacturer of this product.
 
 Control returns from getManufacturer: immediately. If the operation is
 successful, and the product has a manufacturer, the given callback is invoked
 with a non-nil [id\<CSManufacturer\>](CSManufacturer) in result and a nil
 error.
 
 If the product does not have a manufacturer, the callback is invoked with a nil
 result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the manufacturer has been successfully
 obtained, or when the product has no manufacturer, or when the operation has
 failed.
 
 */
- (void)getManufacturer:(void (^)(id<CSManufacturer> result,
                                  NSError *error))callback;

/** Get the software platform of this product.
 
 Control returns from getSoftwarePlatform: immediately. If the operation is
 successful, and the product has a software platform, the given callback is
 invoked with a non-nil [id\<CSSoftwarePlatform\>](CSSoftwarePlatform) in result
 and a nil error.
 
 If the product does not have a software platform, the callback is invoked with
 a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the software platform has been
 successfully obtained, or when the product has no software platform, or when
 the operation has failed.
 
 */- (void)getSoftwarePlatform:(void (^)(id<CSSoftwarePlatform> result,
                                         NSError *error))callback;

@end

/** Protocol for accessing pages of pictures in a sequence of results.
 
 Client code is expected to use this protocol's pictureList property to
 get an object conforming to CSPictureList.
 
 */
@protocol CSPictureListPage <CSListPage>

/** An object conforming to CSPictureList that provides convenient access to the
 list of pictures.
 */
@property (readonly) id<CSPictureList> pictureList;

@end

/** Protocol for accessing a list of pictures. */
@protocol CSPictureList <CSList>

/** Tries to fetch the picture at the given index.
 
 Control returns from getPictureAtIndex:callback: immediately. If the
 operation is successful, the given callback is invoked with a non-nil
 [id\<CSPicture\>](CSPicture) in result and a nil error. If the
 operation fails, callback is invoked with a nil result and a non-nil error.
 
 @param index The index in the sequence of the picture to retrieve.
 @param callback The block to invoke when the picture has been successfully
 obtained, or when the operation has failed.
 */
- (void)getPictureAtIndex:(NSUInteger)index
                 callback:(void (^)(id<CSPicture> result,
                                    NSError *error))callback;

@end

/** Protocol for accessing pages of prices in a sequence of results.
 
 Client code is expected to use this protocol's priceList property to
 get an object conforming to CSPriceList.
 
 */
@protocol CSPriceListPage <CSListPage>

/** An object conforming to CSPriceList that provides convenient access to the
 list of prices.
 */
@property (readonly) id<CSPriceList> priceList;

@end

/** Protocol for accessing a list of prices. */
@protocol CSPriceList <CSList>

/** Tries to fetch the price at the given index.
 
 Control returns from getPriceAtIndex:callback: immediately. If the operation is
 successful, the given callback is invoked with a non-nil
 [id\<CSPrice\>](CSPrice) in result and a nil error. If the operation fails,
 callback is invoked with a nil result and a non-nil error.
 
 @param index The index in the sequence of the price to retrieve.
 @param callback The block to invoke when the price has been successfully
 obtained, or when the operation has failed.
 */
- (void)getPriceAtIndex:(NSUInteger)index
               callback:(void (^)(id<CSPrice> result, NSError *error))callback;

@end

/** Protocol for accessing a price. */
@protocol CSPrice <CSEntity>

/** The "final price you pay", inclusive of delivery and offer discounts. */
@property (readonly) NSNumber *effectivePrice;

/** Price exclusive of delivery and offer discounts. */
@property (readonly) NSNumber *price;

/** Delivery price. */
@property (readonly) NSNumber *deliveryPrice;

/** Symbol for the currency that denominates this price.
 For example "£" or "$". */
@property (readonly) NSString *currencySymbol;

/** ISO 4217 currency code for the currency that denominates this price.
 For example "GBP" or "USD". */
@property (readonly) NSString *currencyCode;

/** URL of the retailer that offers the product at this price. */
@property (readonly) NSURL *retailerURL;

/** Availibility of the product at this retailer. */
@property (readonly) NSString *stock;

/** URL of a web page where the retailer offers the product at this price. */
@property (readonly) NSURL *purchaseURL;

/** Tries to get the product that can be purchased at this price.
 
 Control returns from getProduct: immediately. If the operation is successful,
 the given callback is invoked with a non-nil
 [id\<CSProduct\>](CSProduct) in product and a nil error.
 
 If the operation fails, callback is invoked with a nil product and a non-nil
 error.
 
 @param callback The block to invoke when the product has been successfully
 obtained, or when the operation has failed.
 
 */
- (void)getProduct:(void (^)(id<CSProduct> product, NSError *error))callback;

/** Tries to get the retailer that offers the product at this price.
 
 Control returns from getRetailer: immediately. If the operation is successful,
 the given callback is invoked with a non-nil
 [id\<CSRetailer\>](CSRetailer) in retailer and a nil error.
 
 If the operation fails, callback is invoked with a nil retailer and a non-nil
 error.
 
 @param callback The block to invoke when the retailer has been successfully
 obtained, or when the operation has failed.
 
 */
- (void)getRetailer:(void (^)(id<CSRetailer> retailer, NSError *error))callback;

@end

/** Protocol for accessing pages of categories in a sequence of results.
 
 Client code is expected to use this protocol's categoryList property to get
 an object conforming to CSCategoryList.
 
 */
@protocol CSCategoryListPage <CSListPage>

/** An object conforming to CSCategoryList that provides convenient access to
 the list of categories.
 */
@property (readonly) id<CSCategoryList> categoryList;

@end

/** Protocol for accessing a list of categories. */
@protocol CSCategoryList <CSList>

/** Tries to fetch the category at the given index.
 
 Control returns from getCategoryAtIndex:callback: immediately. If the operation
 is successful, the given callback is invoked with a non-nil
 [id\<CSCategory\>](CSCategory) in result and a nil error. If the operation
 fails, callback is invoked with a nil result and a non-nil error.
 
 @param index The index in the sequence of the category to retrieve.
 @param callback The block to invoke when the category has been successfully
 obtained, or when the operation has failed.
 */
- (void)getCategoryAtIndex:(NSUInteger)index
                  callback:(void (^)(id<CSCategory> result,
                                     NSError *error))callback;

@end

/** Protocol for accessing a category. */
@protocol CSCategory <CSEntity>

/** The category's name. */
@property (readonly) NSString *name;

/** Tries to get a list of immediate subcategories of this category.
 
 The immediate subcategories of this category are the categories that have this
 category as their immediate parent.
 
 Control returns from getImmediateSubcategories: immediately. If the operation
 is successful,  the given callback is invoked with a non-nil
 [id\<CSCategoryListPage\>](CSCategoryListPage) in result and a nil error.
 result is the first page of the result set. It is recommended that client
 code use result.categoryList to get an [id\<CSCategoryList\>](CSCategoryList),
 which provides convenient access to categories in the list.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the categories list has been
 successfully obtained, or when the operation has failed.
 
 */
- (void)getImmediateSubcategories:(void (^)(id<CSCategoryListPage> result,
                                            NSError *error))callback;

@end

/** Protocol for accessing an author. */
@protocol CSAuthor <CSEntity>

/** The author's name. */
@property (nonatomic, readonly) NSString *name;

@end

/** Protocol for accessing a cover type. */
@protocol CSCoverType <CSEntity>

/** The name of the cover type. */
@property (nonatomic, readonly) NSString *name;

@end

/** Protocol for accessing a manufacturer. */
@protocol CSManufacturer <CSEntity>

/** The manufacturer's name. */
@property (nonatomic, readonly) NSString *name;

@end

/** Protocol for accessing a software platform. */
@protocol CSSoftwarePlatform <CSEntity>

/** The name of the software platform. */
@property (nonatomic, readonly) NSString *name;

@end

/** Protocol for accessing a Slice.
 
 A Slice represents a subset of the content available from the Cogenta Shopping
 API and can be used to list and search products. Slices may also provide lists
 of Narrows, which are used to obtain further-reduced Slices.
 */
@protocol CSSlice <CSEntity>

/** The URL of the list of products in this Slice.
 
 Clients are expected to use the Slice's getProducts: method instead of
 dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *productsURL;

/** The URL of the list of retailer narrows from this slice or nil if this
 slice cannot be narrowed by a retailer.
 
 Clients are expected to use the Slice's getRetailerNarrows: method instead of
 dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *retailerNarrowsURL;

/** The URL of the list of category narrows from this slice.
 
 Clients are expected to use the Slice's getCategoryNarrows: method instead of
 dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *categoryNarrowsURL;

/** The URL of the list of author narrows from this slice.
 
 Clients are expected to use the Slice's getAuthorNarrows: method instead of
 dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *authorNarrowsURL;

/** The URL of the list of cover type narrows from this slice.
 
 Clients are expected to use the Slice's getCoverTypeNarrows: method instead of
 dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *coverTypeNarrowsURL;

/** The URL of the list of manufacturer narrows from this slice.
 
 Clients are expected to use the Slice's getManufacturerNarrows: method instead
 of dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *manufacturerNarrowsURL;

/** The URL of the list of software platform narrows from this slice.
 
 Clients are expected to use the Slice's getSoftwarePlatformNarrows: method
 instead of dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *softwarePlatformNarrowsURL;

/** Tries to get a list of products in this slice.
 
 Control returns from getProducts: immediately. If the operation is successful,
 the given callback is invoked with a non-nil
 [id\<CSProductListPage\>](CSProductListPage) in result and a nil error.
 result is the first page of the result set. It is recommended that client
 code use result.productList to get an [id\<CSProductList\>](CSProductList),
 which provides convenient access to products in the list.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the products list has been
 successfully obtained, or when the operation has failed.
 @return an [id\<CSAPIRequest\>](CSAPIRequest) controlling the network request.
 
 */
- (id<CSAPIRequest>)getProducts:(void (^)(id<CSProductListPage> result,
                                          NSError *error))callback;

/** Tries to get a list of products in this slice that match a query.
 
 Control returns from getProductsWithQuery:callback: immediately. If the
 operation is successful, the given callback is invoked with a non-nil
 [id\<CSProductListPage\>](CSProductListPage) in result and a nil error.
 result is the first page of the result set. It is recommended that client
 code use result.productList to get an [id\<CSProductList\>](CSProductList),
 which provides convenient access to products in the list.
 
 If the operation fails, callback is invoked with a nil firstPage and a non-nil
 error.
 
 @param query A search query. For example, "apple ipod touch 16gb".
 @param callback The block to invoke when the products list has been
 successfully obtained, or when the operation has failed.
 @return an [id\<CSAPIRequest\>](CSAPIRequest) controlling the network request.
 
 */
- (id<CSAPIRequest>)getProductsWithQuery:(NSString *)query
                                callback:(void (^)(id<CSProductListPage> result,
                                                   NSError *error))callback;

/** Tries to get a list of retailer narrows.
 
 The retailer narrows each narrow this slice by a different retailer that
 supplies one or more products in this slice.
 
 Control returns from getRetailerNarrows: immediately. If the operation is
 successful, and the slice provides a list of retailer narrows, the given
 callback is invoked with a non-nil [id\<CSNarrowListPage\>](CSNarrowListPage)
 in result and a nil error. result is the first page of the result set.
 
 It is recommended that client code use result.narrowList to get an
 [id\<CSNarrowList\>](CSNarrowList), which provides convenient access to
 narrows in the list.
 
 If the slice does not provide a list of retailer narrows, the callback is
 invoked with a nil result and a nil error. Note that this is distinct from
 the slice providing an empty list of retailer narrows, in which case result
 will be a non-nil [id\<CSNarrowListPage\>](CSNarrowListPage) with a count of 0.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the narrow list has been successfully
 obtained, or when the slice provides no list of retailer narrows, or when the
 operation has failed.
 
 */
- (void)getRetailerNarrows:(void (^)(id<CSNarrowListPage> result,
                                     NSError *error))callback;

/** Tries to get a list of category narrows.
 
 The category narrows each narrow this slice by a different category that
 contains one or more products in this slice.
 
 Control returns from getCategoryNarrows: immediately. If the operation is
 successful, and the slice provides a list of category narrows, the given
 callback is invoked with a non-nil [id\<CSNarrowListPage\>](CSNarrowListPage)
 in result and a nil error. result is the first page of the result set.
 
 It is recommended that client code use result.narrowList to get an
 [id\<CSNarrowList\>](CSNarrowList), which provides convenient access to
 narrows in the list.
 
 If the slice does not provide a list of category narrows, the callback is
 invoked with a nil result and a nil error. Note that this is distinct from
 the slice providing an empty list of category narrows, in which case result
 will be a non-nil [id\<CSNarrowListPage\>](CSNarrowListPage) with a count of 0.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the narrow list has been successfully
 obtained, or when the slice provides no list of category narrows, or when the
 operation has failed.
 
 */
- (void)getCategoryNarrows:(void (^)(id<CSNarrowListPage> result,
                                     NSError *error))callback;

/** Tries to get a list of author narrows.
 
 The author narrows each narrow this slice by a different author that
 is associated with one or more products in this slice.
 
 Control returns from getAuthorNarrows: immediately. If the operation is
 successful, and the slice provides a list of author narrows, the given
 callback is invoked with a non-nil [id\<CSNarrowListPage\>](CSNarrowListPage)
 in result and a nil error. result is the first page of the result set.
 
 It is recommended that client code use result.narrowList to get an
 [id\<CSNarrowList\>](CSNarrowList), which provides convenient access to
 narrows in the list.
 
 If the slice does not provide a list of author narrows, the callback is
 invoked with a nil result and a nil error. Note that this is distinct from
 the slice providing an empty list of author narrows, in which case result
 will be a non-nil [id\<CSNarrowListPage\>](CSNarrowListPage) with a count of 0.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the narrow list has been successfully
 obtained, or when the slice provides no list of author narrows, or when the
 operation has failed.
 
 */
- (void)getAuthorNarrows:(void (^)(id<CSNarrowListPage> result,
                                   NSError *error))callback;

/** Tries to get a list of cover type narrows.
 
 The cover type narrows each narrow this slice by a different cover type that
 is associated with one or more products in this slice.
 
 Control returns from getCoverTypeNarrows: immediately. If the operation is
 successful, and the slice provides a list of cover type narrows, the given
 callback is invoked with a non-nil [id\<CSNarrowListPage\>](CSNarrowListPage)
 in result and a nil error. result is the first page of the result set.
 
 It is recommended that client code use result.narrowList to get an
 [id\<CSNarrowList\>](CSNarrowList), which provides convenient access to
 narrows in the list.
 
 If the slice does not provide a list of cover type narrows, the callback is
 invoked with a nil result and a nil error. Note that this is distinct from
 the slice providing an empty list of cover type narrows, in which case result
 will be a non-nil [id\<CSNarrowListPage\>](CSNarrowListPage) with a count of 0.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the narrow list has been successfully
 obtained, or when the slice provides no list of cover type narrows, or when the
 operation has failed.
 
 */
- (void)getCoverTypeNarrows:(void (^)(id<CSNarrowListPage> result,
                                      NSError *error))callback;

/** Tries to get a list of manufacturer narrows.
 
 The manufacturer narrows each narrow this slice by a different manufacturer that
 is associated with one or more products in this slice.
 
 Control returns from getManufacturerNarrows: immediately. If the operation is
 successful, and the slice provides a list of manufacturer narrows, the given
 callback is invoked with a non-nil [id\<CSNarrowListPage\>](CSNarrowListPage)
 in result and a nil error. result is the first page of the result set.
 
 It is recommended that client code use result.narrowList to get an
 [id\<CSNarrowList\>](CSNarrowList), which provides convenient access to
 narrows in the list.
 
 If the slice does not provide a list of manufacturer narrows, the callback is
 invoked with a nil result and a nil error. Note that this is distinct from
 the slice providing an empty list of manufacturer narrows, in which case result
 will be a non-nil [id\<CSNarrowListPage\>](CSNarrowListPage) with a count of 0.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the narrow list has been successfully
 obtained, or when the slice provides no list of manufacturer narrows, or when
 the operation has failed.
 
 */
- (void)getManufacturerNarrows:(void (^)(id<CSNarrowListPage> result,
                                         NSError *error))callback;

/** Tries to get a list of software platform narrows.
 
 The software platform narrows each narrow this slice by a different software
 platform that is associated with one or more products in this slice.
 
 Control returns from getSoftwarePlatformNarrows: immediately. If the operation
 is successful, and the slice provides a list of software platform narrows, the
 given callback is invoked with a non-nil
 [id\<CSNarrowListPage\>](CSNarrowListPage) in result and a nil error. result
 is the first page of the result set.
 
 It is recommended that client code use result.narrowList to get an
 [id\<CSNarrowList\>](CSNarrowList), which provides convenient access to
 narrows in the list.
 
 If the slice does not provide a list of software platform narrows, the
 callback is invoked with a nil result and a nil error. Note that this is
 distinct from the slice providing an empty list of software platform narrows,
 in which case result will be a non-nil
 [id\<CSNarrowListPage\>](CSNarrowListPage) with a count of 0.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the narrow list has been successfully
 obtained, or when the slice provides no list of software platform narrows, or
 when the operation has failed.
 
 */
- (void)getSoftwarePlatformNarrows:(void (^)(id<CSNarrowListPage> result,
                                             NSError *error))callback;

/** Get the retailer used to filter the content in this slice.
 
 Control returns from getFiltersByRetailer: immediately. If the operation is
 successful, and the slice's content is filtered by a retailer, the given
 callback is invoked with a non-nil [id\<CSRetailer\>](CSRetailer)
 in result and a nil error.
 
 If the slice's content is not filtered by a retailer, the callback is
 invoked with a nil result and a nil error. Note that filtering by a single
 retailer is distinct from filtering by a list of retailers. If a slice's
 content is filtered by a list of retailers, and not by a single retailer, the
 result will be nil.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the retailer has been successfully
 obtained, or when the slice's content is not filtered by a retailer, or when
 the operation has failed.

 */
- (void)getFiltersByRetailer:(void (^)(id<CSRetailer> result,
                                       NSError *error))callback;

/** Get the retailer list used to filter the content in this slice.
 
 Control returns from getFiltersByRetailerList: immediately. If the operation is
 successful, and the slice's content is filtered by a list of retailers, the
 given callback is invoked with a non-nil
 [id\<CSRetailerListPage\>](CSRetailerListPage) in result and a nil error.
 result is the first page of the result set. It is recommended that client
 code use result.retailerList to get an [id\<CSRetailerList\>](CSRetailerList),
 which provides convenient access to retailers in the list.
 
 If the slice's content is not filtered by a list of retailer, the callback is
 invoked with a nil result and a nil error. Note that filtering by a single
 retailer is distinct from filtering by a list of retailers. If a slice's
 content is filtered by a single retailer, and not by a list of retailers, the
 result will be nil.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the retailer list has been
 successfully obtained, or when the slice's content is not filtered by a list
 of retailers, or when the operation has failed.
 
 */
- (void)getFiltersByRetailerList:(void (^)(id<CSRetailerListPage> result,
                                           NSError *error))callback;

/** Get the category used to filter the content in this slice.
 
 Control returns from getFiltersByCategory: immediately. If the operation is
 successful, and the slice's content is filtered by a category, the given
 callback is invoked with a non-nil [id\<CSCategory\>](CSCategory)
 in result and a nil error.
 
 If the slice's content is not filtered by a category, the callback is
 invoked with a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the category has been successfully
 obtained, or when the slice's content is not filtered by a category, or when
 the operation has failed.
 
 */
- (void)getFiltersByCategory:(void (^)(id<CSCategory> result,
                                       NSError *error))callback;

/** Get the author used to filter the content in this slice.
 
 Control returns from getFiltersByAuthor: immediately. If the operation is
 successful, and the slice's content is filtered by an author, the given
 callback is invoked with a non-nil [id\<CSAuthor\>](CSAuthor)
 in result and a nil error.
 
 If the slice's content is not filtered by an author, the callback is
 invoked with a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the author has been successfully
 obtained, or when the slice's content is not filtered by a author, or when
 the operation has failed.
 
 */
- (void)getFiltersByAuthor:(void (^)(id<CSAuthor> result,
                                     NSError *error))callback;

/** Get the cover type used to filter the content in this slice.
 
 Control returns from getFiltersByCoverType: immediately. If the operation is
 successful, and the slice's content is filtered by a cover type, the given
 callback is invoked with a non-nil [id\<CSCoverType\>](CSCoverType)
 in result and a nil error.
 
 If the slice's content is not filtered by a cover type, the callback is
 invoked with a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the cover type has been successfully
 obtained, or when the slice's content is not filtered by a cover type, or when
 the operation has failed.
 
 */
- (void)getFiltersByCoverType:(void (^)(id<CSCoverType> result,
                                        NSError *error))callback;

/** Get the manufacturer used to filter the content in this slice.
 
 Control returns from getFiltersByManufacturer: immediately. If the operation
 is successful, and the slice's content is filtered by a manufacturer, the given
 callback is invoked with a non-nil [id\<CSManufacturer\>](CSManufacturer)
 in result and a nil error.
 
 If the slice's content is not filtered by a manufacturer, the callback is
 invoked with a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the manufacturer has been successfully
 obtained, or when the slice's content is not filtered by a manufacturer, or
 when the operation has failed.
 
 */
- (void)getFiltersByManufacturer:(void (^)(id<CSManufacturer> result,
                                           NSError *error))callback;;

/** Get the software platform used to filter the content in this slice.
 
 Control returns from getFiltersBySoftwarePlatform: immediately. If the
 operation is successful, and the slice's content is filtered by a software
 platform, the given callback is invoked with a non-nil
 [id\<CSSoftwarePlatform\>](CSSoftwarePlatform) in result and a nil error.
 
 If the slice's content is not filtered by an software platform, the callback is
 invoked with a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the software platform has been
 successfully obtained, or when the slice's content is not filtered by a
 software platform, or when the operation has failed.
 
 */
- (void)getFiltersBySoftwarePlatform:(void (^)(id<CSSoftwarePlatform> result,
                                               NSError *error))callback;

/** Tries to get a slice without an author filter.
 
 The resulting slice has the same filters as this slice, but without the filter
 by author.
 
 Control returns from getSliceWithoutAuthorFilter: immediately. If the
 operation is successful, the given callback is invoked with a non-nil
 [id\<CSSlice\>](CSSlice) in result and a nil error.
 
 If there is no such slice, the callback is invoked with a nil
 [id\<CSSlice\>](CSSlice) in result and a nil error.
 
 If the operation fails, the callback is invoked with a nil result and a
 non-nil error.
 
 @param callback The block to invoke when the slice has been successfully
 obtained, or when there is no such slice, or when the operation has failed.
 */
- (void)getSliceWithoutAuthorFilter:(void (^)(id<CSSlice> result,
                                              NSError *error))callback;

/** Tries to get a slice without a cover type filter.
 
 The resulting slice has the same filters as this slice, but without the filter
 by cover type.
 
 Control returns from getSliceWithoutCoverTypeFilter: immediately. If the
 operation is successful, the given callback is invoked with a non-nil
 [id\<CSSlice\>](CSSlice) in result and a nil error.
 
 If there is no such slice, the callback is invoked with a nil
 [id\<CSSlice\>](CSSlice) in result and a nil error.
 
 If the operation fails, the callback is invoked with a nil result and a
 non-nil error.
 
 @param callback The block to invoke when the slice has been successfully
 obtained, or when there is no such slice, or when the operation has failed.
 */
- (void)getSliceWithoutCoverTypeFilter:(void (^)(id<CSSlice> result,
                                                 NSError *error))callback;

/** Tries to get a slice without a manufacturer filter.
 
 The resulting slice has the same filters as this slice, but without the filter
 by manufacturer.
 
 Control returns from getSliceWithoutManufacturerFilter: immediately. If the
 operation is successful, the given callback is invoked with a non-nil
 [id\<CSSlice\>](CSSlice) in result and a nil error.
 
 If there is no such slice, the callback is invoked with a nil
 [id\<CSSlice\>](CSSlice) in result and a nil error.
 
 If the operation fails, the callback is invoked with a nil result and a
 non-nil error.
 
 @param callback The block to invoke when the slice has been successfully
 obtained, or when there is no such slice, or when the operation has failed.
 */
- (void)getSliceWithoutManufacturerFilter:(void (^)(id<CSSlice> result,
                                                    NSError *error))callback;

/** Tries to get a slice without a software platform filter.
 
 The resulting slice has the same filters as this slice, but without the filter
 by software platform.
 
 Control returns from getSliceWithoutSoftwarePlatformFilter: immediately. If the
 operation is successful, the given callback is invoked with a non-nil
 [id\<CSSlice\>](CSSlice) in result and a nil error.
 
 If there is no such slice, the callback is invoked with a nil
 [id\<CSSlice\>](CSSlice) in result and a nil error.
 
 If the operation fails, the callback is invoked with a nil result and a
 non-nil error.
 
 @param callback The block to invoke when the slice has been successfully
 obtained, or when there is no such slice, or when the operation has failed.
 */
- (void)getSliceWithoutSoftwarePlatformFilter:(void (^)(id<CSSlice> result,
                                                        NSError *error))callback;

@end


/** Protocol for accessing a Narrow.
 
 A Narrow represents the a transition from a slice to another slice and describe
 a the filter option that is applied to make that transition.
 
 Slices provide lists of Narrows that enumerate the options to drill down from
 that slice.
 */
@protocol CSNarrow <CSEntity>

/** A human-readable name to help identify the narrow. */
@property (nonatomic, readonly) NSString *title;

/** The URL of the slice that results from following this narrow.
 
 Clients are expected to use the Narrow's getSlice: method instead of
 dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *sliceURL;

/** The URL of a retailer by which the resulting slice filters its content.
 
 Clients are expected to use the Narrow's getNarrowsByRetailer: method instead
 of dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *narrowsByRetailerURL;

/** The URL of a category by which the resulting slice filters its content.
 
 Clients are expected to use the Narrow's getNarrowsByCategory: method instead
 of dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *narrowsByCategoryURL;

/** The URL of an author by which the resulting slice filters its content.
 
 Clients are expected to use the Narrow's getNarrowsByAuthor: method instead
 of dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *narrowsByAuthorURL;

/** The URL of a cover type by which the resulting slice filters its content.
 
 Clients are expected to use the Narrow's getNarrowsByCoverType: method instead
 of dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *narrowsByCoverTypeURL;

/** The URL of a manufacturer by which the resulting slice filters its content.
 
 Clients are expected to use the Narrow's getNarrowsByManufacturer: method
 instead of dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *narrowsByManufacturerURL;

/** The URL of a software platform by which the resulting slice filters its
 content.
 
 Clients are expected to use the Narrow's getNarrowsBySoftwarePlatform: method
 instead of dereferencing this URL.
 */
@property (nonatomic, readonly) NSURL *narrowsBySoftwarePlatformURL;

/** Tries to get the slice that results from following this narrow.
 
 Control returns from getSlice: immediately. If the operation is successful,
 the given callback is invoked with a non-nil [id\<CSSlice\>](CSSlice) in
 result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the slice has been successfully
 obtained, or when the operation has failed.
 */
- (void)getSlice:(void (^)(id<CSSlice> result, NSError *error))callback;

/** Tries to get the retailer by which the resulting slice filters its content.
 
 Control returns from getNarrowsByRetailer: immediately. If the operation is
 successful, the given callback is invoked with a non-nil
 [id\<CSRetailer\>](CSRetailer) in result and a nil error.
 
 If the resulting slice does not filter by a retailer, callback is invoked with
 a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the retailer has been successfully
 obtained, or when the resulting slice does not filter by a retailer, or when
 the operation has failed.
 */
- (void)getNarrowsByRetailer:(void (^)(id<CSRetailer> result,
                                       NSError *error))callback;

/** Tries to get the category by which the resulting slice filters its content.
 
 Control returns from getNarrowsByCategory: immediately. If the operation is
 successful, the given callback is invoked with a non-nil
 [id\<CSCategory\>](CSCategory) in result and a nil error.
 
 If the resulting slice does not filter by a category, callback is invoked with
 a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the category has been successfully
 obtained, or when the resulting slice does not filter by a category, or when
 the operation has failed.
 */
- (void)getNarrowsByCategory:(void (^)(id<CSCategory> result,
                                       NSError *error))callback;

/** Tries to get the author by which the resulting slice filters its content.
 
 Control returns from getNarrowsByAuthor: immediately. If the operation is
 successful, the given callback is invoked with a non-nil
 [id\<CSAuthor\>](CSAuthor) in result and a nil error.
 
 If the resulting slice does not filter by an author, callback is invoked with
 a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the author has been successfully
 obtained, or when the resulting slice does not filter by a author, or when
 the operation has failed.
 */
- (void)getNarrowsByAuthor:(void (^)(id<CSAuthor> result,
                                     NSError *error))callback;

/** Tries to get the cover type by which the resulting slice filters its
 content.
 
 Control returns from getNarrowsByCoverType: immediately. If the operation is
 successful, the given callback is invoked with a non-nil
 [id\<CSCoverType\>](CSCoverType) in result and a nil error.
 
 If the resulting slice does not filter by a cover type, callback is invoked
 with a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the cover type has been successfully
 obtained, or when the resulting slice does not filter by a cover type, or when
 the operation has failed.
 */
- (void)getNarrowsByCoverType:(void (^)(id<CSCoverType> result,
                                        NSError *error))callback;

/** Tries to get the manufacturer by which the resulting slice filters its
 content.
 
 Control returns from getNarrowsByManufacturer: immediately. If the operation is
 successful, the given callback is invoked with a non-nil
 [id\<CSManufacturer\>](CSManufacturer) in result and a nil error.
 
 If the resulting slice does not filter by a manufacturer, callback is invoked
 with a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the manufacturer has been successfully
 obtained, or when the resulting slice does not filter by a manufacturer, or
 when the operation has failed.
 */
- (void)getNarrowsByManufacturer:(void (^)(id<CSManufacturer> result,
                                           NSError *error))callback;

/** Tries to get the software platform by which the resulting slice filters its
 content.
 
 Control returns from getNarrowsBySoftwarePlatform: immediately. If the
 operation is successful, the given callback is invoked with a non-nil
 [id\<CSSoftwarePlatform\>](CSSoftwarePlatform) in result and a nil error.
 
 If the resulting slice does not filter by a software platform, callback is
 invoked with a nil result and a nil error.
 
 If the operation fails, callback is invoked with a nil result and a non-nil
 error.
 
 @param callback The block to invoke when the software platform has been
 successfully obtained, or when the resulting slice does not filter by a
 software platform, or when the operation has failed.
 */
- (void)getNarrowsBySoftwarePlatform:(void (^)(id<CSSoftwarePlatform> result,
                                               NSError *error))callback;

@end


/** Protocol for accessing pages of Narrows in a sequence of results.
 
 Client code is expected to use this protocol's narrowList property to get
 an object conforming to CSNarrowList.
 */
@protocol CSNarrowListPage <CSListPage>

/** An object conforming to CSNarrowList that provides convenient access to
 the list of Narrows.
 */
@property (readonly) id<CSNarrowList> narrowList;

@end


/** Protocol for accessing a list of Narrows. */
@protocol CSNarrowList <CSList>

/** Tries to fetch the Narrow at the given index.
 
 Control returns from getNarrowAtIndex:callback: immediately. If the operation
 is successful, the given callback is invoked with a non-nil
 [id\<CSNarrow\>](CSNarrow) in result and a nil error. If the operation
 fails, callback is invoked with a nil result and a non-nil error.
 
 @param index The index in the sequence of the Narrow to retrieve.
 @param callback The block to invoke when the Narrow has been successfully
 obtained, or when the operation has failed.
 */
- (void)getNarrowAtIndex:(NSUInteger)index
                callback:(void (^)(id<CSNarrow> narrow,
                                   NSError *error))callback;

@end


