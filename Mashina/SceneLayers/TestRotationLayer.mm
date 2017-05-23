//
// Created by Askar Mustafin on 9/11/16.
//

#import "TestRotationLayer.h"
#import "b2World.h"
#import "Contants.h"
#import "CCDirector.h"
#import "GLES-Render.h"


#define DEGTORAD 0.0174

@implementation TestRotationLayer {
    b2World *_world;

    GLESDebugDraw *m_debugDraw;

    b2Body *dotBody;
    b2Body *dropBody;
}

+ (id)scene {
    CCScene *scene = [CCScene node];
    TestRotationLayer *layer = [TestRotationLayer node];
    [scene addChild:layer];
    return scene;
}

- (id)init {
    if ((self = [super init])) {

        self.isTouchEnabled = YES;

        b2Vec2 gravity = b2Vec2(0.0f, 0.0f);
        _world = new b2World(gravity);

        [self enableDebugMode];
        [self schedule:@selector(tick:)];

        [self test];
    }
    return self;
}

- (void)tick:(ccTime)dt {
    _world->Step(dt, 10, 10);
}

#pragma mark - main drawings

- (void)test {
    b2BodyDef myBodyDef;
    myBodyDef.type = b2_dynamicBody;

    //hexagonal shape definition
    b2PolygonShape polygonShape;
    b2Vec2 vertices[6];
    for (int i = 0; i < 6; i++) {

        float angle = (float) (-i/6.0 * 360 * DEGTORAD);
        vertices[i].Set(sinf(angle), cosf(angle));

    }
    vertices[0].Set( 0, 4 ); //change one vertex to be pointy
    polygonShape.Set(vertices, 6);

    //fixture definition
    b2FixtureDef myFixtureDef;
    myFixtureDef.shape = &polygonShape;
    myFixtureDef.density = 1;

    //create dynamic body
    myBodyDef.position.Set(8, 2);


    dropBody = _world->CreateBody(&myBodyDef);
    dropBody->CreateFixture(&myFixtureDef);

}

- (void)drawPointLocation:(b2Vec2)location {
    if (dotBody) {
        _world->DestroyBody(dotBody);
    }

    b2BodyDef buttonBodyDef;
    b2PolygonShape buttonShape;
    b2FixtureDef buttonFixtureDef;

    buttonBodyDef.type = b2_staticBody;
    buttonBodyDef.position = location;
    buttonShape.SetAsBox((float32) (1/PTM_RATIO/2), (float32) (1/PTM_RATIO/2));
    buttonFixtureDef.shape = &buttonShape;


    dotBody = _world->CreateBody(&buttonBodyDef);
    dotBody->CreateFixture(&buttonFixtureDef);
}

#pragma mark - touches

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    NSSet *allTouches = [event allTouches];
    for(UITouch *touch in allTouches) {
        CGPoint location = [touch locationInView:touch.view];
        location = [[CCDirector sharedDirector] convertToGL:location];
        b2Vec2 worldLoc = b2Vec2(ptm(location.x), ptm(location.y));
        NSLog(@"Touch locaiton: x: %f y: %f", ptm(location.x), ptm(location.y));
        [self drawPointLocation:worldLoc];


        float bodyAngle = dropBody->GetAngle();
        b2Vec2 toTarget = worldLoc - dropBody->GetPosition();
        float desiredAngle = atan2f(-toTarget.x, toTarget.y);
        dropBody->SetTransform(dropBody->GetPosition(), desiredAngle);
    }
}

#pragma mark - debug mode

- (void)enableDebugMode {
    m_debugDraw = new GLESDebugDraw( PTM_RATIO );
    uint32 flags = 0;
    flags += b2Draw::e_shapeBit;
    flags += b2Draw::e_jointBit;
    flags += b2Draw::e_centerOfMassBit;
//    flags += b2Draw::e_aabbBit;
//    flags += b2Draw::e_pairBit;
    m_debugDraw->SetFlags(flags);
    _world->SetDebugDraw(m_debugDraw);
}

- (void)draw {
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

#pragma mark - dealloc

- (void)dealloc {
    delete _world;
    [super dealloc];
}

@end