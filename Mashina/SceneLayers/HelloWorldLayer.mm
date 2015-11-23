#import "HelloWorldLayer.h"

@interface HelloWorldLayer() {
    b2Body *_platformBody;
}

@end

@implementation HelloWorldLayer

+ (id)scene {
    CCScene *scene = [CCScene node];
    HelloWorldLayer *layer = [HelloWorldLayer node];
    [scene addChild:layer];
    return scene;
}

- (id)init {
    self = [super init];
    if (self) {
        [self drawVehicle];
        [self drawButton];
    }
    return self;
}

#pragma mark -
#pragma mark - DRAWINGS

- (void)drawButton {
    b2BodyDef buttonBodyDef;
    b2PolygonShape buttonShape;
    b2FixtureDef buttonFixtureDef;

    buttonBodyDef.type = b2_staticBody;
    buttonBodyDef.position.Set((float32) (25/PTM_RATIO), (float32) (25/PTM_RATIO));
    buttonShape.SetAsBox((float32) (50/PTM_RATIO/2), (float32) (50/PTM_RATIO/2));
    buttonFixtureDef.shape = &buttonShape;

    b2Body *bBody;
    bBody = _world->CreateBody(&buttonBodyDef);
    bBody->CreateFixture(&buttonFixtureDef);
}

- (void)drawVehicle {
////////Platform
    b2BodyDef platformBodyDef;
    platformBodyDef.type = b2_dynamicBody;
    platformBodyDef.position.Set(ptm(130), ptm(100));

    _platformBody = _world->CreateBody(&platformBodyDef);

    b2PolygonShape platformShape;
    platformShape.SetAsBox(ptm(100)/2, ptm(15)/2);


    b2FixtureDef platformFixtureDef;
    platformFixtureDef.shape = &platformShape;
    platformFixtureDef.density = 10.8f; //плотность
    platformFixtureDef.restitution = 0.2f; //возвращение
    platformFixtureDef.friction = 0.99f; //трение
    _platformBody->CreateFixture(&platformFixtureDef);


/////wheel1
    b2Body *_wheelOneBody;
    b2BodyDef wheelOneBodyDef;
    wheelOneBodyDef.type = b2_dynamicBody;
    wheelOneBodyDef.position.Set(ptm(60), ptm(100));

    _wheelOneBody = _world->CreateBody(&wheelOneBodyDef);

    b2CircleShape circleWheelOne;
    circleWheelOne.m_radius = ptm(25.0);


    b2FixtureDef wheelOneShapeDef;
    wheelOneShapeDef.shape = &circleWheelOne;
    wheelOneShapeDef.density = 10.8f;
    wheelOneShapeDef.restitution = 0.5f;
    wheelOneShapeDef.friction = 0.99f;
    _wheelOneBody->CreateFixture(&wheelOneShapeDef);

//////wheel2
    b2Body *_wheelTwoBody;
    b2BodyDef wheelTwoBodyDef;
    wheelTwoBodyDef.type = b2_dynamicBody;
    wheelTwoBodyDef.position.Set(ptm(200), ptm(100));
    //wheelTwoBodyDef.userData = wheelTwoSprite;

    _wheelTwoBody = _world->CreateBody(&wheelTwoBodyDef);

    b2CircleShape circleWheelTwo;
    circleWheelTwo.m_radius = ptm(25.0);

    b2FixtureDef wheelTwoShapeDef;
    wheelTwoShapeDef.shape = &circleWheelTwo;
    wheelTwoShapeDef.density = 10.8f;
    wheelTwoShapeDef.restitution = 0.5f;
    wheelTwoShapeDef.friction = 0.99f;
    _wheelTwoBody->CreateFixture(&wheelTwoShapeDef);


/////////Revolute joint1
    b2RevoluteJointDef wheelOneJointDef;
    wheelOneJointDef.Initialize(_platformBody, _wheelOneBody, b2Vec2(ptm(60), ptm(100)));
    _world->CreateJoint(&wheelOneJointDef);

//wheelOneJointDef.enableMotor = true;
//wheelOneJointDef.enableLimit = true;
//wheelOneJointDef.motorSpeed  = 10000;//-10;//-1260;
//wheelOneJointDef.lowerAngle  = CC_DEGREES_TO_RADIANS(0);
//wheelOneJointDef.upperAngle  = CC_DEGREES_TO_RADIANS(90);
//wheelOneJointDef.maxMotorTorque = 70000;//4800;

    /////Revolute joint2
    b2RevoluteJointDef wheelTwoJointDef;
    wheelTwoJointDef.Initialize(_platformBody, _wheelTwoBody, b2Vec2(ptm(200), ptm(100)));
    _world->CreateJoint(&wheelTwoJointDef);

//    b2Vec2 force = b2Vec2(1000, 0);
//    _platformBody->ApplyTorque(100);
}


- (void)dealloc {
    delete _world;
    [super dealloc];
}

@end