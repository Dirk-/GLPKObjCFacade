//
//  GLPKObjCFacadeTests.m
//  GLPKObjCFacadeTests
//
//  Created by Dirk Fröhling on 23.06.18.
//  
//  "Sometimes" this seems to cause a crash when testing. libobjc.A.dylib`objc_release: EXC_BAD_ACCESS.
//  Sometimes it is working for the iOS target, sometimes for macOS. Seems to depend on the order of the code here.
//  The thing is that the routines here are not part of the stack which crashes.
//  See a probably similar problem here: https://cjwirth.com/tech/xcode-7-3-crashing
//

#import <XCTest/XCTest.h>
#import "ObjCGLPK.h"

@interface GLPKObjCFacadeTests : XCTestCase

@end

@implementation GLPKObjCFacadeTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1 {
    ObjCGLPK *myGLPK = [[ObjCGLPK alloc] init];
    XCTAssertNotNil(myGLPK);
    [myGLPK addCols:5];
    [myGLPK addRows:5];
    int32_t r = myGLPK.countRows;
    int32_t c = myGLPK.countColumns;
    XCTAssertEqual(r, 5);
    XCTAssertEqual(c, 5);
}

/** @brief Test the sample problem from the GLPK docs.
 **/
- (void)test2 {
    ObjCGLPK *myGLPK = [[ObjCGLPK alloc] initWithName:@"sample" andDirection:GLPKMaximize];
    XCTAssertNotNil(myGLPK);
    myGLPK.direction = GLPKMaximize;
    [myGLPK addRowWithName:@"p" andBound:GLPKUpperBoundOnly lowerBound:0 upperBound:100];
    [myGLPK addRowWithName:@"q" andBound:GLPKUpperBoundOnly lowerBound:0 upperBound:600];
    [myGLPK addRowWithName:@"r" andBound:GLPKUpperBoundOnly lowerBound:0 upperBound:300];
    [myGLPK addColumnWithName:@"x1" andBound:GLPKLowerBoundOnly lowerBound:0 upperBound:0 usingCoefficient:10];
    [myGLPK addColumnWithName:@"x2" andBound:GLPKLowerBoundOnly lowerBound:0 upperBound:0 usingCoefficient:6];
    [myGLPK addColumnWithName:@"x3" andBound:GLPKLowerBoundOnly lowerBound:0 upperBound:0 usingCoefficient:4];
    NSArray *matrix = @[
                        @[@1, @1, @1],
                        @[@10, @4, @5],
                        @[@2, @2, @6],
                        ];
    [myGLPK loadConstraintMatrixWithValuesByRow:matrix];
    [myGLPK simplex];
    double z = [myGLPK functionValue];
    XCTAssertEqualWithAccuracy(z, 733.333, 0.01);
    double x1 = [myGLPK primalValueOfColumnWithName:@"x1"];
    XCTAssertEqualWithAccuracy(x1, 33.3333, 0.01);
    double x2 = [myGLPK primalValueOfColumnWithName:@"x2"];
    XCTAssertEqualWithAccuracy(x2, 66.6667, 0.01);
    double x3 = [myGLPK primalValueOfColumnWithName:@"x3"];
    XCTAssertEqualWithAccuracy(x3, 0.0, 0.01);
}

@end
