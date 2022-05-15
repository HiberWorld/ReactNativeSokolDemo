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

typedef struct {
  float posX, posY, scale, rot, aspect;
} shader_data_t;

typedef struct {
  shader_data_t shader_data;
  float velocity;
  bool touchingLeft;
  bool touchingRight;
} player_t;

typedef struct {
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_bindings shipGeometry;
    player_t player;
} state_t;

static state_t state = {0};

typedef struct {
  float posX, posY, posZ;
  float colR, colG, colB;
} vertex_t;

/* a vertex buffer with 3 vertices */
static vertex_t shipVertices[] = {
    // positions        colors
     {
       .posX = 0.0f, .posY = 1.0f, .posZ = 0.0f,  
       .colR = 1.0f, .colG = 0.0f, .colB = 0.0f 
      },
      {
       .posX = -1.0f, .posY = -1.0f, .posZ = 0.0f,  
       .colR = 0.0f, .colG = 1.0f, .colB = 0.0f 
      },
      {
       .posX = 1.0f, .posY = -1.0f, .posZ = 0.0f, 
       .colR = 0.0f, .colG = 0.0f, .colB = 1.0f 
      }
};

static void init(void) {
    RCTLogInfo(@"Init");
    /* setup sokol */
    sg_setup(&(sg_desc){
        .context = sapp_sgcontext()
    });

    state = (state_t) {
      .player.shader_data = {
        .scale = 0.2f,
        .posX = 0.0f,
        .posY = -0.7f
      }
    };

    state.shipGeometry.vertex_buffers[0] = sg_make_buffer(&(sg_buffer_desc){
        .size = SG_RANGE(shipVertices).size,
        .data = SG_RANGE(shipVertices),
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

static void frame(void) {
  const float deltaTime = 1.0f / 60.0f;
  const float aspect = sapp_widthf() / sapp_heightf();

  state.player.shader_data.aspect = aspect;
  // state.player.shader_data.rot = frame_time;

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

  shader_data_t tmp = {
    .posX = 0.5f,
    .scale = 0.2f,
    .aspect = aspect,
    .rot = 3.1415f / 2.0f,
  };
  drawGeometry(state.shipGeometry, tmp, 1);
  drawGeometry(state.shipGeometry, state.player.shader_data, 1);
  
  sg_end_pass();
  sg_commit();
}

static void eventCallback(const sapp_event *event) {
  if (event->type == SAPP_EVENTTYPE_TOUCHES_BEGAN ||
      event->type == SAPP_EVENTTYPE_TOUCHES_ENDED) {

    RCTLogInfo(@"Event with %i tocuhes", event->num_touches);
    for (int i = 0; i < event->num_touches; i++) {
      sapp_touchpoint touch = event->touches[i];

      RCTLogInfo(@"Touch %i (changed:%s) x: %f, y: %f", i, touch.changed ? "true" : "false", touch.pos_x, touch.pos_y);
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
      RCTLogInfo(@"touchingLeft: %s", state.player.touchingLeft ? "true" : "false");
      RCTLogInfo(@"touchingRight: %s", state.player.touchingRight ? "true" : "false");
    }
  }
}

static void cleanupCallback(void) {
  sg_shutdown();
  [[UIApplication sharedApplication].delegate.window makeKeyAndVisible];
  [[UIApplication sharedApplication].delegate.window.rootViewController setNeedsUpdateOfScreenEdgesDeferringSystemGestures];
}

void _sapp_init_state(const sapp_desc* desc);
bool _sapp_app_delegate_didFinishLaunchingWithOptions(NSDictionary* launchOptions, UIViewController* viewController);

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

RCT_EXPORT_METHOD(
  startTriangle: (RCTResponseSenderBlock)callback)
{
  callback(@[@("you win!")]);
    
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
