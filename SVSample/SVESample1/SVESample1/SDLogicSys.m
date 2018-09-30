//
//  SDLogicSys.m
//  SVEDemo
//
//  Created by 李晓帆 on 2018/9/3.
//  Copyright © 2018年 李晓帆. All rights reserved.
//

#import "SDLogicSys.h"
#import "SVICamera.h"
#import "SDPreDef.h"
#import "SVIEffect.h"

@interface SDLogicSys(){
    EAGLContext* m_pGLContext;
}
@end

static SDLogicSys *mInst;

@implementation SDLogicSys

+(instancetype) getInst{
    if(mInst == nil){
        mInst = [SDLogicSys new];
    }
    return mInst;
}

- (void)initSys{
    self.pSVI = nil;
    //创建设备上下文
    m_pGLContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    //注册监听消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:@"didEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForeground) name:@"didEnterForeground" object:nil];
    //初始化引擎
    [self initSVE];
    //创建ViewControl
    self.m_pVC = [[ViewController alloc] init];
}

- (void)destroySys{
    //开启相机
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didEnterBackground" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"didEnterForeground" object:nil];
    //停止引擎并析构
    [self destroySVE];
}

- (void)initSVE {
    if(!self.pSVI) {
        //创建sv引擎对象
        self.pSVI = [[SVI alloc] init];
        //设置资源路径
        NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"sve" ofType:@"bundle"];
        bundlePath = [NSString stringWithFormat:@"%@/",bundlePath];
        [self.pSVI addResPath:bundlePath];
        [self.pSVI addResPath:@""];
        //开启引擎
        [self.pSVI startEngine];
        //创建渲染器
        [self.pSVI createRendererGL:3 Context:m_pGLContext Width:720 Height:1280];
        //创建场景
        [self.pSVI createScene:NULL msg:@""];
    }
}

- (void)destroySVE {
    //停止引擎并析构
    if( self.pSVI ) {
        [self.pSVI stopEngine];
        self.pSVI = nil;
    }
}

-(EAGLContext*)getGLContext{
    return m_pGLContext;
}

- (void)didEnterBackground{
    //如果有预览视频正在播放，那么暂停。
    [self.pSVI suspend];
}

- (void)didEnterForeground{
    //如果有预览视频正在播放，那么继续播放。
    [self.pSVI resume];
}

@end
