//
// Created by Mustafin Askar on 07/10/2014.
//

#import <Foundation/Foundation.h>
#import "CCLayer.h"
#include "b2World.h"
#import "GLES-Render.h"


@interface BaseLayer : CCLayer {
    b2World *_world;
    GLESDebugDraw *m_debugDraw;

    // Body to hold one side of joint
    NSMutableArray *touchJointList;
    b2Body *_groundBody;
}

- (id)init;

@end