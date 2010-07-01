//
//  main.m
//  Test
//
//  Created by Jonathan Wight on 09/16/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
//

#import "CTester.h"

int main(int argc, char *argv[])
{
NSAutoreleasePool *thePool = [[NSAutoreleasePool alloc] init];

CTester *theTester = [[[CTester alloc] init] autorelease];
[theTester test];

[thePool release];
return(0);
}
