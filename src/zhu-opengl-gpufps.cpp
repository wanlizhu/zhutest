#include <dlfcn.h>
#include <time.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include "glad.h"
#include <GL/glx.h>
#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <string>

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
            logfile = fopen("/tmp/fps.csv", "w");
            const char* header = "cpu fps, gpu fps, diff fps\n";
            fwrite(header, 1, strlen(header), logfile);
            fclose(logfile);
            logfile = fopen("/tmp/fps.csv", "a");
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
            
            snprintf(tmpstr, 100, "%07.2f, %07.2f, %07.2f\n", 
                float(1000.0 / cpu_time_ms),
                float(1000.0 / gpu_time_ms),
                float(1000.0 / cpu_time_ms) - float(1000.0 / gpu_time_ms));
            printf("%s", tmpstr);
            if (logfile) {
                fwrite(tmpstr, 1, strlen(tmpstr), logfile);
            }

            query_index = 0;
            cool_down_time = 0;
        }
    }
}

void __attribute__((destructor)) shutdown() {
    if (logfile) {
        fclose(logfile);

        std::vector<double> sums;
        std::vector<int> counts;
        std::vector<std::string> names;

        std::ifstream file("/tmp/fps.csv");
        std::string line;
        std::getline(file, line); // Ignore header line
        std::stringstream ss(line);
        while (std::getline(ss, line, ',')) {
            size_t start = line.find_first_not_of(" \t\r\n");
            size_t end = line.find_last_not_of(" \t\r\n");
            names.push_back(line.substr(start, end - start + 1));
        }

        while (std::getline(file, line)) {
            std::stringstream ss(line);
            for (int col = 0; ss.good(); col++) {
                if (col >= sums.size()) {
                    sums.push_back(0);
                    counts.push_back(0);
                }
                double val;
                ss >> val;
                ss.ignore(); // Ignore comma
                sums[col] += val;
                counts[col] += 1;
            }
        }

        for (int i = 0; i < sums.size(); i++) {
            printf("Avg of column %d: %07.2f  (%s)\n", i + 1, sums[i] / counts[i], names[i].c_str());
        }
    }
}