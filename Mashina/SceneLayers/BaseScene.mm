//
// Created by Mustafin Askar on 07/10/2014.
//

#import "BaseScene.h"
#import "HelloWorldLayer.h"
#import "Contants.h"
#import "CCTouchJoint.h"


@implementation BaseScene {
}

- (id)init {
    if ((self = [super init])) {
        self.isTouchEnabled = YES;
        touchJointList = [[NSMutableArray alloc] init];

        b2Vec2 gravity = b2Vec2(0.0f, -WORLDGRAVITY);
        _world = new b2World(gravity);

        CGSize winSize = [CCDirector sharedDirector].winSize;
        [self drawScreenBodyWithSize:winSize];

        [self enableDebugMode];
        [self schedule:@selector(tick:)];
    }
    return self;
}

- (void)tick:(ccTime)dt {
    _world->Step(dt, 10, 10);
}

#pragma mark - draw walls

- (void)drawScreenBodyWithSize:(CGSize)winSize {
    b2BodyDef groundBodyDef;
    b2EdgeShape groundBox;
    b2FixtureDef groundBoxFixtureDef;

    groundBodyDef.position.Set(0,0);
    _groundBody = _world->CreateBody(&groundBodyDef);
    groundBoxFixtureDef.shape = &groundBox;

    //bottom
    groundBox.Set(b2Vec2(0,0), b2Vec2((float32) (winSize.width/PTM_RATIO), 0));
    _groundBody->CreateFixture(&groundBoxFixtureDef);
    //left
    groundBox.Set(b2Vec2(0,0), b2Vec2(0, (float32) (winSize.height/PTM_RATIO)));
    _groundBody->CreateFixture(&groundBoxFixtureDef);
    //roof
    groundBox.Set(b2Vec2(0, (float32) (winSize.height/PTM_RATIO)),
            b2Vec2((float32) (winSize.width/PTM_RATIO), (float32) (winSize.height/PTM_RATIO)));
    _groundBody->CreateFixture(&groundBoxFixtureDef);
    //right
    groundBox.Set(b2Vec2((float32) (winSize.width/PTM_RATIO), (float32) (winSize.height/PTM_RATIO)),
            b2Vec2((float32) (winSize.width/PTM_RATIO), 0));
    _groundBody->CreateFixture(&groundBoxFixtureDef);
}

#pragma mark -
#pragma mark - DEDUG MODE

- (void)enableDebugMode {
    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    flags += b2Draw::e_jointBit;
//    flags += b2Draw::e_aabbBit;
//    flags += b2Draw::e_pairBit;
    flags += b2Draw::e_centerOfMassBit;
    m_debugDraw->SetFlags(flags);
    _world->SetDebugDraw(m_debugDraw);
}

- (void) draw {
    //
    // IMPORTANT:
    // This is only for debug purposes
    // It is recommend to disable it
    //
    [super draw];
    ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
    kmGLPushMatrix();
    _world->DrawDebugData();
    kmGLPopMatrix();
}

#pragma mark - accelerometer

- (void)accelerometer:(UIAccelerometer *)_accelerometer didAccelerate:(UIAcceleration *)_acceleration
{
    b2Vec2 gravity(_acceleration.y * -WORLDGRAVITY, _acceleration.x * WORLDGRAVITY);
    _world->SetGravity(gravity);
}

#pragma mark -
#pragma mark CCTargetedTouch Delegate Methods

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];

    for(UITouch *touch in allTouches)
    {
        CGPoint location = [touch locationInView:touch.view];

        location = [[CCDirector sharedDirector] convertToGL:location];
        b2Vec2 worldLoc = b2Vec2(ptm(location.x), ptm(location.y));

        for (b2Body *b = _world->GetBodyList(); b; b = b->GetNext())
        {
            if (b->GetType() == b2_dynamicBody)
            {
                for (b2Fixture *f = b->GetFixtureList(); f; f = f->GetNext())
                {
                    // Hit!
                    if (f->TestPoint(worldLoc))
                    {
                        b2MouseJointDef md;
                        md.bodyA = _groundBody;
                        md.bodyB = b;
                        md.target = worldLoc;
                        md.collideConnected = true;
                        md.maxForce = 1000.0f * b->GetMass();

                        b2MouseJoint *_mouseJoint;
                        _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
                        b->SetAwake(true);

                        CCTouchJoint *tj = [CCTouchJoint touch:touch withMouseJoint:_mouseJoint];
                        [touchJointList addObject:tj];

                        break;
                    }
                }
            }
        }
    }
}

- (void)ccTouchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (CCTouchJoint *tj in touchJointList)
    {
        if([tj.touch phase] == UITouchPhaseMoved)
        {
            // Update if it is moved
            CGPoint location = [tj.touch locationInView:tj.touch.view];
            location = [[CCDirector sharedDirector] convertToGL:location];

            b2Vec2 worldLocation = b2Vec2(ptm(location.x), ptm(location.y));
            tj.mouseJoint->SetTarget(worldLocation);
        }
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];

    NSMutableArray *discardedItems = [NSMutableArray array];

    for(UITouch *touch in allTouches)
    {
        for (CCTouchJoint *tj in touchJointList)
        {
            if (tj.touch == touch)
            {
                // Defensive programming - assertion
                NSAssert([tj isKindOfClass:[CCTouchJoint class]], @"node is not a touchJoint!");

                // If safe - loop through
                if ([tj.touch phase] == UITouchPhaseEnded)
                {
                    [discardedItems addObject:tj];

                    [tj destroyTouchJoint];
                    [tj release];
                }
            }
        }
    }

    [touchJointList removeObjectsInArray:discardedItems];
}

- (void)ccTouchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [touchJointList removeAllObjects];
}

#pragma mark -
#pragma mark - DEALLOC

- (void)dealloc {
    delete _world;
    _groundBody = NULL;
    [touchJointList release];
    [super dealloc];
}


@end