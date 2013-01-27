//
//  LoadBalancerRequest.m
//  OpenStack
//
//  Created by Michael Mayo on 2/10/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "LoadBalancerRequest.h"
#import "OpenStackAccount.h"
#import "JSON.h"
#import "LoadBalancer.h"


@implementation LoadBalancerRequest

+ (id)request:(OpenStackAccount *)account method:(NSString *)method url:(NSURL *)url {
	LoadBalancerRequest *request = [[[LoadBalancerRequest alloc] initWithURL:url] autorelease];
    request.account = account;
	[request setRequestMethod:method];
	[request addRequestHeader:@"X-Auth-Token" value:[account authToken]];
    [request addRequestHeader:@"Content-Type" value:@"application/json"];
    [request setTimeOutSeconds:40];
	return request;
}

+ (id)lbRequest:(OpenStackAccount *)account method:(NSString *)method endpoint:(NSString *)endpoint path:(NSString *)path {
    NSString *now = [[[NSDate date] description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@.json?now=%@", endpoint, path, now]];
    
    NSLog(@"Load Balancer URL: %@", url);
    
    return [LoadBalancerRequest request:account method:method url:url];
}

+ (LoadBalancerRequest *)getLoadBalancersRequest:(OpenStackAccount *)account endpoint:(NSString *)endpoint {
    return [LoadBalancerRequest lbRequest:account method:@"GET" endpoint:endpoint path:@"/loadbalancers"];
}

/*
{"loadBalancers":[{"name":"a-new-loadbalancer","id":3181,"protocol":"HTTP","port":80,"algorithm":"RANDOM","status":"ACTIVE","virtualIps":[{"address":"184.106.101.30","id":227,"type":"PUBLIC","ipVersion":"IPV_4"}],"created":{"time":"2011-02-14T17:39:30.000+0000"},"updated":{"time":"2011-02-14T17:39:37.000+0000"}}]}
*/

/*
+ (LoadBalancerRequest *)createLoadBalancerRequest:(OpenStackAccount *)account loadBalancer:(LoadBalancer *)loadBalancer {
	NSString *body = [loadBalancer toJSON];
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/servers", account.serversURL]];
    NSLog(@"create server: %@", body);
    OpenStackRequest *request = [OpenStackRequest request:account method:@"POST" url:url];    
	NSData *data = [body dataUsingEncoding:NSUTF8StringEncoding];
	[request setPostBody:[NSMutableData dataWithData:data]];
	return request;
}
*/
 
- (NSMutableDictionary *)loadBalancers {
    SBJSON *parser = [[SBJSON alloc] init];
    NSArray *jsonObjects = [[parser objectWithString:[self responseString]] objectForKey:@"loadBalancers"];
    NSMutableDictionary *objects = [[[NSMutableDictionary alloc] initWithCapacity:[jsonObjects count]] autorelease];
    for (int i = 0; i < [jsonObjects count]; i++) {
        NSDictionary *dict = [jsonObjects objectAtIndex:i];
        LoadBalancer *loadBalancer = [LoadBalancer fromJSON:dict];
        [objects setObject:loadBalancer forKey:[NSNumber numberWithInt:loadBalancer.identifier]];
    }
    [parser release];
    return objects;
}
 
@end
