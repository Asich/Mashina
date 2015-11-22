//
// Created by Mustafin Askar on 07/10/2014.
//

#import "NewScene.h"
#import "HelloWorldLayer.h"


@implementation NewScene {

}

+ (id)scene {
    CCScene *scene = [CCScene node];
    NewScene *layer = [NewScene node];
    [scene addChild:layer];
    return scene;
}

- (id)init {
    if ((self = [super init])) {
        [self drawBodies];
    }
    return self;
}

#pragma mark -

- (void)drawBodies {
    /////////////////
    b2Body *baseBody;
    b2BodyDef baseBodyDef;
    b2PolygonShape baseShape;
    b2FixtureDef baseFixtureDef;

    baseBodyDef.type = b2_staticBody;
    baseBodyDef.position.Set(ptm(100), ptm(20));

    baseShape.SetAsBox(ptm(20), ptm(20));

    baseFixtureDef.shape = &baseShape;
    baseFixtureDef.density = 10.8f; //плотность
    baseFixtureDef.restitution = 0.2f; //возвращение
    baseFixtureDef.friction = 0.99f; //трение

    baseBody = _world->CreateBody(&baseBodyDef);
    baseBody->CreateFixture(&baseFixtureDef);

    /////////////////

    b2Body *barrelBody;
    b2BodyDef barrelBodyDef;
    b2PolygonShape barrelShape;
    b2FixtureDef barrelFixtureDef;

    barrelBodyDef.type = b2_dynamicBody;
    barrelBodyDef.position.Set(ptm(100), ptm(50));

    barrelShape.SetAsBox(ptm(5), ptm(40));

    barrelFixtureDef.shape = &barrelShape;
    barrelFixtureDef.density = 10.8f; //плотность
    barrelFixtureDef.restitution = 0.2f; //возвращение
    barrelFixtureDef.friction = 0.99f; //трение

    barrelBody = _world->CreateBody(&barrelBodyDef);
    barrelBody->CreateFixture(&barrelFixtureDef);

//
    //////joint
    b2RevoluteJointDef barrelJoinDef;
    barrelJoinDef.Initialize(baseBody, barrelBody, b2Vec2(ptm(100), ptm(20)));
    _world->CreateJoint(&barrelJoinDef);
}

@end