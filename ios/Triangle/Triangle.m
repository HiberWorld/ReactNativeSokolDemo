#import <Foundation/Foundation.h>
#import <React/RCTLog.h>

/* Sokol */
#define SOKOL_IMPL
#define SOKOL_METAL
#define SOKOL_NO_ENTRY
#define SOKOL_LOG(msg) RCTLogInfo(@"%s", msg)
#include "sokol/sokol_app.h"
#include "sokol/sokol_gfx.h"
#include "sokol/sokol_glue.h"
#include "Triangle.h"

#include <math.h>
#include <stdlib.h>

typedef struct {
  float posX, posY, scale, rot, aspect;
} shader_data_t;

typedef struct {
  shader_data_t shader_data;
  float velocity;
  bool touchingLeft;
  bool touchingRight;
  int score;
} player_t;

static const int ASTEROID_COUNT = 2;
static const int STAR_COUNT = 9;

typedef struct {
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_bindings redTriangleGeometry;
    sg_bindings brownTriangleGeometry;
    sg_bindings whiteTriangleGeometry;
    player_t player;
    shader_data_t asteroids[ASTEROID_COUNT];
    shader_data_t stars[STAR_COUNT];
} state_t;

static state_t state = {0};

typedef struct {
  float posX, posY, posZ;
  float colR, colG, colB;
} vertex_t;

static vertex_t redTriangleVertices[] = {
  {
    .posX = 0.0f, .posY = 0.8f, .posZ = 0.0f,  
    .colR = 0.88f, .colG = 0.08f, .colB = 0.133f 
  },
  {
    .posX = -1.0f, .posY = -1.0f, .posZ = 0.0f,  
    .colR = 0.88f, .colG = 0.08f, .colB = 0.133f 
  },
  {
    .posX = 1.0f, .posY = -1.0f, .posZ = 0.0f, 
    .colR = 0.88f, .colG = 0.08f, .colB = 0.133f 
  }
};

static vertex_t brownTriangleVertices[] = {
  {
    .posX = 0.0f, .posY = 0.8f, .posZ = 0.0f,  
    .colR = 0.59f, .colG = 0.47f, .colB = 0.18f 
  },
  {
    .posX = -1.0f, .posY = -1.0f, .posZ = 0.0f,  
    .colR = 0.59f, .colG = 0.47f, .colB = 0.18f 
  },
  {
    .posX = 1.0f, .posY = -1.0f, .posZ = 0.0f, 
    .colR = 0.59f, .colG = 0.47f, .colB = 0.18f 
  }
};

static vertex_t whiteTriangleVertices[] = {
  {
    .posX = 0.0f, .posY = 0.8f, .posZ = 0.0f,  
    .colR = 0.9f, .colG = 0.9f, .colB = 0.9f
  },
  {
    .posX = -1.0f, .posY = -1.0f, .posZ = 0.0f,  
    .colR = 0.6f, .colG = 0.6f, .colB = 0.6f
  },
  {
    .posX = 1.0f, .posY = -1.0f, .posZ = 0.0f, 
    .colR = 0.3f, .colG = 0.3f, .colB = 0.3f
  }
};

static void init(void) {
    sg_setup(&(sg_desc){
        .context = sapp_sgcontext()
    });

    state = (state_t) {
      .pass_action = {
        .colors[0] = {
          .action = SG_ACTION_CLEAR,
          .value = { 0.0f, 0.0f, 0.0f, 1.0f }
        },
      },
      .player = {
        .score = 0,
        .shader_data = { 
        .scale = 0.2f, .posX = 0.0f, .posY = -0.7f 
        }
      },
      .asteroids = {
        { .scale = 0.2f, .posX = -0.7f, .posY = 0.7f },
        { .scale = 0.4f, .posX = 0.7f, .posY = 1.7f }
      },
      .stars = {
        { .scale =  0.1f, .posX = -0.4f, .posY = -0.3f },
        { .scale = 0.05f, .posX =  0.0f, .posY =  0.6f },
        { .scale = 0.03f, .posX =  0.4f, .posY =  0.3f },
        { .scale =  0.1f, .posX = -0.6f, .posY = -0.1f },
        { .scale = 0.05f, .posX =  0.2f, .posY =  0.2f },
        { .scale = 0.03f, .posX =  0.6f, .posY =  0.1f },
        { .scale =  0.1f, .posX = -0.8f, .posY = -0.2f },
        { .scale = 0.05f, .posX =  0.4f, .posY =  0.4f },
        { .scale = 0.03f, .posX =  0.8f, .posY =  0.2f }
      }
    };

    state.redTriangleGeometry.vertex_buffers[0] = sg_make_buffer(&(sg_buffer_desc){
      .size = SG_RANGE(redTriangleVertices).size,
      .data = SG_RANGE(redTriangleVertices)
    });

    state.brownTriangleGeometry.vertex_buffers[0] = sg_make_buffer(&(sg_buffer_desc) {
      .size = SG_RANGE(brownTriangleVertices).size,
      .data = SG_RANGE(brownTriangleVertices)
    });

    state.whiteTriangleGeometry.vertex_buffers[0] = sg_make_buffer(&(sg_buffer_desc) {
      .size = SG_RANGE(whiteTriangleVertices).size,
      .data = SG_RANGE(whiteTriangleVertices)
    });

  NSString* vsPath = [[NSBundle mainBundle] pathForResource:@"triangleVS" ofType:@"txt"];
  NSString* fsPath = [[NSBundle mainBundle] pathForResource:@"triangleFS" ofType:@"txt"];

  NSString* vertexShader = [NSString stringWithContentsOfFile:vsPath encoding:NSUTF8StringEncoding error:NULL];
  NSString* fragmentShader = [NSString stringWithContentsOfFile:fsPath encoding:NSUTF8StringEncoding error:NULL];

  sg_shader shd = sg_make_shader(&(sg_shader_desc){
    .vs.uniform_blocks[0].size = sizeof(shader_data_t),
    .vs.source = [vertexShader UTF8String],
    .fs.source = [fragmentShader UTF8String]
  });

  state.pip = sg_make_pipeline(&(sg_pipeline_desc){
      .layout = {
          .attrs = {
              [0] = { .format=SG_VERTEXFORMAT_FLOAT3 },
              [1] = { .format=SG_VERTEXFORMAT_FLOAT3 }
          },
      },
      .shader = shd
  });
}

static void drawGeometry(sg_bindings geometry, shader_data_t data, int triangleCount) {
  sg_apply_bindings(&geometry);
  sg_apply_uniforms(SG_SHADERSTAGE_VS, 0, &SG_RANGE(data));
  sg_draw(0, 3 * triangleCount, 1);
}

static RCTResponseSenderBlock gameEndCallback;

static bool intersect(shader_data_t a, shader_data_t b) {
  float x = a.posX - b.posX;
  float y = a.posY - b.posY;
  float distance = sqrt(x*x + y*y);
  if (distance < ((a.scale + b.scale) * 0.3f)) {
    return true;
  }
  return false;
}

void sendEvent(const char* name, const char* value) {
    if ([[TriangleModule sharedInstance] hasListeners]) {
        [[TriangleModule sharedInstance] 
          sendEventWithName:@"event" body:@{@"action": @(name), @"value": @(value)}];;
    }
}

static void frame(void) {
  const float aspect = sapp_widthf() / sapp_heightf();
  const float deltaTime = 1.0f / 60.0f;

  // move stars
  for (int i = 0; i < STAR_COUNT; i++) {
    shader_data_t* star = &state.stars[i];
    star->aspect = aspect;

    if (star->posY < -1.0f) {
      star->posX = ((float) rand() / (float) (RAND_MAX/2)) - 1.0f;
      star->posY = 1.2f;
    }

    star->posY -= 0.3f * deltaTime * (float) ((i % 4) + 1);
    star->rot += 2.0f * deltaTime;
  }

  // check if player is touching an asteroid, otherwise move asteroid up
  for (int i = 0; i < ASTEROID_COUNT; i++) {
    shader_data_t* asteroid = &state.asteroids[i];
    if (intersect(state.player.shader_data, *asteroid)) {
      // end the game

      NSString *score = [NSString stringWithFormat:@"%d", state.player.score];
      sendEvent("gameEnd", [score UTF8String]);

      if (gameEndCallback) {
        NSString *message = [NSString stringWithFormat:@"{ \"score\": %d}", state.player.score];
        gameEndCallback(@[message]);
      }

      sapp_request_quit();
    }

    asteroid->aspect = aspect;

    // move asteroid
    if (asteroid->posY < -1.0f) {
      asteroid->posX = ((float) rand() / (float) (RAND_MAX/2)) - 1.0f;
      asteroid->posY = 1.2f;
      state.player.score += 1;

      NSString *score = [NSString stringWithFormat:@"%d", state.player.score];
      sendEvent("point", [score UTF8String]);
    }

    asteroid->posY -= 1.0f * deltaTime;
    asteroid->rot += 2.0f * deltaTime;
  }

  state.player.shader_data.aspect = aspect;

  // adjust velocity if touching
  if (state.player.touchingLeft) {
    state.player.velocity -= 5.0f * deltaTime;
  }

  if (state.player.touchingRight) {
    state.player.velocity += 5.0f * deltaTime;
  }
  state.player.velocity *= 0.97f;

  if (state.player.shader_data.posX > 0.9f) {
    state.player.velocity *= -0.2f;
    state.player.shader_data.posX = 0.9f;
  }

  if (state.player.shader_data.posX < -0.9f) {
    state.player.velocity *= -0.2f;
    state.player.shader_data.posX = -0.9f;
  }

  state.player.shader_data.posX += state.player.velocity * deltaTime;
  
  sg_begin_default_pass(&state.pass_action, sapp_width(), sapp_height());

  sg_apply_pipeline(state.pip);

  for (int i = 0; i < STAR_COUNT; i++) {
    drawGeometry(state.whiteTriangleGeometry, state.stars[i], 1);
  }

  drawGeometry(state.redTriangleGeometry, state.player.shader_data, 1);

  for (int i = 0; i < ASTEROID_COUNT; i++) {
    drawGeometry(state.brownTriangleGeometry, state.asteroids[i], 1);
  }
  
  sg_end_pass();
  sg_commit();
}

static void eventCallback(const sapp_event *event) {
  if (event->type == SAPP_EVENTTYPE_TOUCHES_BEGAN ||
      event->type == SAPP_EVENTTYPE_TOUCHES_ENDED) {

    for (int i = 0; i < event->num_touches; i++) {
      sapp_touchpoint touch = event->touches[i];

      if (touch.pos_y < sapp_heightf() * 0.2f) {
        sapp_request_quit();
      }

      bool isPressed = event->type == SAPP_EVENTTYPE_TOUCHES_BEGAN;
      if (!touch.changed) {
        continue;
      }
      if (touch.pos_x < sapp_widthf() / 2.0f) {
        state.player.touchingLeft = isPressed;
      }
      else {
        state.player.touchingRight = isPressed;
      }
    }
  }
}

static void cleanupCallback(void) {
  sg_shutdown();
  [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
  [[UIApplication sharedApplication].delegate.window.rootViewController setNeedsUpdateOfScreenEdgesDeferringSystemGestures];
}

void _sapp_init_state(const sapp_desc* desc);
bool _sapp_app_delegate_didFinishLaunchingWithOptions(
  NSDictionary* launchOptions, 
  UIViewController* viewController
);

@implementation TriangleModule

- (void)startObserving {
    self.hasListeners = YES;
}

- (void)stopObserving {
    self.hasListeners = NO;
}

+ (id)sharedInstance {
  return [TriangleModule allocWithZone:nil];
}

+ (id)allocWithZone:(NSZone *)zone {
    static TriangleModule *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

- (NSArray<NSString *> *)supportedEvents {
  return @[@"event"];
}

RCT_EXPORT_METHOD(startTriangle: (RCTResponseSenderBlock)callback)
{
  gameEndCallback = callback;
    
  dispatch_async(dispatch_get_main_queue(), ^{
    
    sapp_desc desc = {};
    desc.high_dpi = true;
    desc.init_cb = init;
    desc.frame_cb = frame;
    desc.cleanup_cb = cleanupCallback;
    desc.event_cb = eventCallback;
    desc.window_title = "Triangle";
    desc.enable_clipboard = true;

    _sapp_init_state(&desc);
    _sapp_app_delegate_didFinishLaunchingWithOptions(nil, [[UIViewController alloc] init]);

    });
}

RCT_EXPORT_MODULE();

@end
