//
//  Triangle.m
//  ReactNativeSokolDemo
//
//  Created by Wilhelm Berggren on 2022-04-25.
//

#import <Foundation/Foundation.h>
#define SOKOL_IMPL
#define SOKOL_METAL
#define SOKOL_NO_ENTRY
#include "sokol/sokol_app.h"
#include "sokol/sokol_gfx.h"
#include "sokol/sokol_glue.h"
#include "Triangle.h"

#include <math.h>

static struct {
    sg_pass_action pass_action;
    sg_pipeline pip;
    sg_buffer vertex_buffer;
    sg_bindings bind;
} state;

/* a vertex buffer with 3 vertices */
static float vertices[] = {
    // positions        colors
     0.0f, 0.5f, 0.5f,  1.0f, 0.0f, 0.0f, 1.0f,
     0.5f, -0.5f, 0.5f, 0.0f, 1.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f, 0.0f, 0.0f, 1.0f, 1.0f
};

static void init(void) {
    /* setup sokol */
    sg_setup(&(sg_desc){
        .context = sapp_sgcontext()
    });

    state.vertex_buffer = sg_make_buffer(&(sg_buffer_desc){
        // .data = SG_RANGE(vertices),
        .size = SG_RANGE(vertices).size,
        .usage = SG_USAGE_STREAM
    });

    state.bind.vertex_buffers[0] = state.vertex_buffer;

    /* a shader pair, compiled from source code */
    sg_shader shd = sg_make_shader(&(sg_shader_desc){
        /*
            The shader main() function cannot be called 'main' in
            the Metal shader languages, thus we define '_main' as the
            default function. This can be override with the
            sg_shader_desc.vs.entry and sg_shader_desc.fs.entry fields.
        */
        .vs.source =
            "#include <metal_stdlib>\n"
            "using namespace metal;\n"
            "struct vs_in {\n"
            "  float4 position [[attribute(0)]];\n"
            "  float4 color [[attribute(1)]];\n"
            "};\n"
            "struct vs_out {\n"
            "  float4 position [[position]];\n"
            "  float4 color;\n"
            "};\n"
            "vertex vs_out _main(vs_in inp [[stage_in]]) {\n"
            "  vs_out outp;\n"
            "  outp.position = inp.position;\n"
            "  outp.color = inp.color;\n"
            "  return outp;\n"
            "}\n",
        .fs.source =
            "#include <metal_stdlib>\n"
            "using namespace metal;\n"
            "fragment float4 _main(float4 color [[stage_in]]) {\n"
            "  return color;\n"
            "};\n"
    });

    /* create a pipeline object */
    state.pip = sg_make_pipeline(&(sg_pipeline_desc){
        /* Metal has explicit attribute locations, and the vertex layout
           has no gaps, so we don't need to provide stride, offsets
           or attribute names
        */
        .layout = {
            .attrs = {
                [0] = { .format=SG_VERTEXFORMAT_FLOAT3 },
                [1] = { .format=SG_VERTEXFORMAT_FLOAT4 }
            },
        },
        .shader = shd
    });
}

static float frame_time = 0.0f;

static void frame(void) {
    frame_time += 1.0f / 60.0f;

    vertices[0] = cosf(frame_time);
    
    sg_update_buffer(state.vertex_buffer, &SG_RANGE(vertices));
    sg_begin_default_pass(&state.pass_action, sapp_width(), sapp_height());
    sg_apply_pipeline(state.pip);
    sg_apply_bindings(&state.bind);
    sg_draw(0, 3, 1);
    sg_end_pass();
    sg_commit();
}

static void eventCallback(const sapp_event *event) {
    if (event->type == SAPP_EVENTTYPE_TOUCHES_BEGAN) {
        sapp_request_quit();
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
  startTriangle)
{
    
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
