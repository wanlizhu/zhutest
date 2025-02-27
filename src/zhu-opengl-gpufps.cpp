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

// CPU timestamp
static struct timespec cpu_start, cpu_end;

// GPU timestamp query
static GLuint gpu_query_ids[2] = {0};
static bool glad_inited = false;
static long query_index = 0;
static long cool_down_time = 0;

// GPU elapsed time log file
static FILE *logfile = NULL;
static char tmpstr[100] = {0};

void glXSwapBuffers(Display *dpy, GLXDrawable drawable) {
    if (real_glXSwapBuffers == NULL) {
        real_glXSwapBuffers = (glXSwapBuffers_T)dlsym(RTLD_NEXT, "glXSwapBuffers");
        
        if (gladLoadGLLoader((GLADloadproc)glXGetProcAddress)) {
            printf("gladLoadGLLoader(...) success!\n");
            glad_inited = true;
            glGenQueries(2, gpu_query_ids);
            if (getenv("zhu_log_file")) { 
                logfile = fopen(getenv("zhu_log_file"), "a");
            }
        } else {
            printf("gladLoadGLLoader(...) failed!\n");
        }
    }

    if (getenv("zhu_force_glfinish")) {
        glFinish();
    }

    real_glXSwapBuffers(dpy, drawable); // Non-blocking (vsync off)
    if (cool_down_time++ < 500 || !glad_inited) {
        return;
    }

    if (query_index <= 1) {
        if (query_index == 0) {
            clock_gettime(CLOCK_MONOTONIC, &cpu_start);
        } else if (query_index == 1) {
            clock_gettime(CLOCK_MONOTONIC, &cpu_end);
        }
        glQueryCounter(gpu_query_ids[query_index++], GL_TIMESTAMP);
    } else {
        GLint gpu_query_finished = 0;
        glGetQueryObjectiv(gpu_query_ids[1], GL_QUERY_RESULT_AVAILABLE, &gpu_query_finished);
        if (gpu_query_finished) {
            GLuint64 gpu_start = 0, gpu_end = 0;
            glGetQueryObjectui64v(gpu_query_ids[0], GL_QUERY_RESULT, &gpu_start);
            glGetQueryObjectui64v(gpu_query_ids[1], GL_QUERY_RESULT, &gpu_end);
            double gpu_time_ms = (gpu_end - gpu_start) * 1.0 / 1e6;
            double cpu_time_ms = ((cpu_end.tv_sec - cpu_start.tv_sec) * 1e9 + (cpu_end.tv_nsec - cpu_start.tv_nsec)) * 1.0 / 1e6;
            snprintf(tmpstr, 100, "%07.2f cpufps (%06.3f ms)  -  %07.2f gpufps (%06.3f ms)  =  %07.2f fps (%06.3f ms)\n", 
                float(1000.0 / cpu_time_ms), (float)cpu_time_ms,
                float(1000.0 / gpu_time_ms), (float)gpu_time_ms,
                float(1000.0 / cpu_time_ms) - float(1000.0 / gpu_time_ms),
                float(cpu_time_ms - gpu_time_ms));

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