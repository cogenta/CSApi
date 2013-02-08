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

/**
 CSAPI is used to access the Cogenta Shopping API.
 */
@interface CSAPI : NSObject

/**
 The bookmark for this endpoint.
 */
@property (readonly) NSString *bookmark;

/**
 The username used to authenticate with the server.
 */
@property (readonly) NSString *username;

/**
 The password used to authenticate with the server.
 */
@property (readonly) NSString *password;

/**
 Initializes a newly allocated API endpoint with the given settings.
 
 @param bookmark The bookmark identifying the application using the API.
 @param username The username used to authenticate API calls with the server.
 @param password The password used to authenticate API calls with the server.
 @return An API endpoint initialized with the given settings.
 */
- (id)initWithBookmark:(NSString *)bookmark
              username:(NSString *)username
              password:(NSString *)password;

- (void)getApplication:(NSURL *)url
              callback:(void (^)(id<CSApplication> app, NSError *error))callback;

- (void)getUser:(NSURL *)url
     credential:(id<CSCredential>)credential
       callback:(void (^)(id<CSUser>, NSError *))callback;

/**
 Tries to obtain a user from the endpoint and invokes the given callback on
 success or failure.
 
 Control returns from login: immediately. If the login operation is successful
 callback is invoked with a non-nil [id\<CSUser\>](CSUser) in user and a nil error. If the
 login operation fails, callback is invoked with a nil user and a non-nil error.
 
 @param callback The block to invoke when the user has been successfully
 obtained, or when the operation has failed.
    
 @see CSUser
 */
- (void)login:(void (^)(id<CSUser> user, NSError *error))callback;

@end


@protocol CSApplication <NSObject>

@property (readonly) NSString *name;

- (void)createUser:(void (^)(id<CSUser> user, NSError *error))callback;

- (void)createUserWithChange:(void (^)(id<CSMutableUser> user))change
                    callback:(void (^)(id<CSUser> user, NSError *error))callback;

@end

/**
 Protocol for interacting with the user resource.
 */
@protocol CSUser <NSObject>

/** @name Bookkeeping */

/**
 URL of the user resource.
 */
@property (readonly) NSURL *url;

/**
 Entity tag of the user resource.
 */
@property (readonly) id etag;

/**
 The user's credential.
 */
@property (readonly) id<CSCredential> credential;

/** @name User state */

/**
 The user's reference string.
 
 The reference is intended to be used to link the Cogenta Shopping API user
 with the developer's own system. The developer's administrative API provides
 a way to search for all that developer's users with a matching reference.
 */
@property (readonly) NSString *reference;

/**
 A dictionary of additional information about the user.
 */
@property (readonly) NSDictionary *meta;

/** @name Mutability */

/**
 Attempts to apply the given change to the user resource.
 
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

@end

/** Protocol for making changes to a user.
 
 See [CSUser change:callback:].
 */
@protocol CSMutableUser <NSObject>

/** URL for the user. */
@property (readonly, strong) NSURL *url;

/** The user's reference string. */
@property (nonatomic, strong) NSString *reference;

/** A dictionary of additional information about the user. */
@property (nonatomic, strong) NSMutableDictionary *meta;

@end