//
// Created by Mustafin Askar on 07/10/2014.
//


#define PTM_RATIO 32.0

/** Convert the given position into the box2d world. */
static inline float ptm(float d)
{
    return (float) (d / PTM_RATIO);
}

/** Convert the given position into the cocos2d world. */
static inline float mtp(float d)
{
    return (float) (d * PTM_RATIO);
}