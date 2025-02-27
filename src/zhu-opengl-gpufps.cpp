#include <dlfcn.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "glad.h"
#include <GL/glx.h>

// Real glXSwapBuffers
typedef void (*glXSwapBuffers_T)(Display*, GLXDrawable);
static glXSwapBuffers_T real_glXSwapBuffers = NULL;

// GPU timestamp query
static GLuint gpu_query_ids[2] = {0};
static bool inited = false;
static long query_index = 0;
static long cool_down_time = 0;

// GPU elapsed time log file
static FILE *logfile = NULL;
static char tmpstr[100] = {0};

void glXSwapBuffers(Display *dpy, GLXDrawable drawable) {
    if (real_glXSwapBuffers == NULL) {
        real_glXSwapBuffers = (glXSwapBuffers_T)dlsym(RTLD_NEXT, "glXSwapBuffers");
        
        if (gladLoadGLLoader((GLADloadproc)glXGetProcAddress)) {
            inited = true;
            glGenQueries(1, gpu_query_ids);
            if (getenv("zhu_gpufps_log_file")) { 
                logfile = fopen(getenv("zhu_gpufps_log_file"), "a");
            }
        } else {
            printf("Failed to init glad!\n");
        }
    }

    real_glXSwapBuffers(dpy, drawable); // Non-blocking (vsync off)
    if (cool_down_time++ < 20 || !inited) {
        return;
    }

    if (query_index <= 1) {
        glQueryCounter(gpu_query_ids[query_index++], GL_TIMESTAMP);
    } else {
        GLint gpu_query_finished = 0;
        glGetQueryObjectiv(gpu_query_ids[1], GL_QUERY_RESULT_AVAILABLE, &gpu_query_finished);
        if (gpu_query_finished) {
            GLuint64 gpu_start = 0, gpu_end = 0;
            glGetQueryObjectui64v(gpu_query_ids[0], GL_QUERY_RESULT, &gpu_start);
            glGetQueryObjectui64v(gpu_query_ids[1], GL_QUERY_RESULT, &gpu_end);
            double gpu_time_ms = (gpu_end - gpu_start) * 1.0 / 1e6;
            snprintf(tmpstr, 100, "%.3f ms, %.2f gpufps\n", (float)gpu_time_ms, float(1000.0 / gpu_time_ms));

            if (logfile) {
                fwrite(tmpstr, 1, strlen(tmpstr), logfile);
            } else {
                printf("%s", tmpstr);
            }

            query_index = 0;
            cool_down_time = 0;
        }
    }
}