//
//  CSApi.h
//  CSApi
//
//  Created by Will Harris on 28/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSApplication;
@protocol CSUser;
@protocol CSMutableUser;
@protocol CSCredential;
@protocol CSListPage;
@protocol CSRetailer;
@protocol CSRetailerList;
@protocol CSRetailerListPage;
@protocol CSLike;
@protocol CSMutableLike;
@protocol CSLikeList;
@protocol CSLikeListPage;

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

- (void)createLikeWithChange:(void (^)(id<CSMutableLike>))change
                    callback:(void (^)(id<CSLike> like, NSError *error))callback;

- (void)getLikes:(void (^)(id<CSLikeListPage> firstPage, NSError *error))callback;

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

@end

/** Protocol for accessing a list of items. */
@protocol CSList <NSObject>

/** The number of items in the list. */
@property (readonly) NSUInteger count;

- (void)getItemAtIndex:(NSUInteger)index
              callback:(void (^)(id<CSListItem> item, NSError *error))callback;

@end

/** Protocol for accessing a list of retailers.
 */
@protocol CSRetailerList <CSList>

/** Tries to fetch the retailer at the given index.
 
 Control returns from getRetailerAtIndex:callback: immediately. If the operation
 is successful, the given callback is invoked with a non-nil
 [id\<CSRetailer\>](CSRetailer) in retailer and a nil error. If the operation
 fails, callback is invoked with a nil retailer and a non-nil error.
 
 @param index The index in the sequence of the retailer to retrieve.
 @param callback The block to invoke when the retailer has been
 successfully obtained, or when the operation has failed.
 */
- (void)getRetailerAtIndex:(NSUInteger)index
                  callback:(void (^)(id<CSRetailer> retailer,
                                     NSError *error))callback;

@end


@protocol CSLikeList <CSList>

- (void)getLikeAtIndex:(NSUInteger)index
              callback:(void (^)(id<CSLike> retailer, NSError *error))callback;

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

@protocol CSLike <NSObject>

@property (readonly) NSURL *retailerURL;

@end

@protocol CSMutableLike <NSObject>

@property (nonatomic, strong) id<CSRetailer> retailer;

@end


@protocol CSLikeListPage <CSListPage>

@property (readonly) id<CSLikeList> likeList;

@end