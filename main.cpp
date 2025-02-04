#include "glad.h"
#include <GLFW/glfw3.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <chrono>

void glfw_callback_fb_size(GLFWwindow* window, int width, int height) {
    glViewport(0, 0, width, height);
}

float rand01() {
    return float((rand() + 1.0) / ((double)RAND_MAX + 2.0));
}

GLuint compile_and_link_program()
{
    int success = 0;
    char logmsg[512];

    static const char* vscode = "#version 330 core \n\
    layout(location = 0) in vec3 inPos; \
    void main() { \
        gl_Position = vec4(inPos, 1.0); \
    }";
    GLuint vs = glCreateShader(GL_VERTEX_SHADER);
    glShaderSource(vs, 1, &vscode, NULL);
    glCompileShader(vs);

    glGetShaderiv(vs, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(vs, 512, NULL, logmsg);
        printf("%s\n", logmsg);
        exit(-1);
    }

    static const char* fscode = "#version 330 core \n\
    out vec4 fragColor; \
    void main() { \
        fragColor = vec4(1.0, 0.0, 0.0, 1.0); \
    }";
    GLuint fs = glCreateShader(GL_FRAGMENT_SHADER);
    glShaderSource(fs, 1, &fscode, NULL);
    glCompileShader(fs);

    glGetShaderiv(fs, GL_COMPILE_STATUS, &success);
    if (!success) {
        glGetShaderInfoLog(fs, 512, NULL, logmsg);
        printf("%s\n", logmsg);
        exit(-1);
    }

    GLuint program = glCreateProgram();
    glAttachShader(program, vs);
    glAttachShader(program, fs);
    glLinkProgram(program);

    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success) {
        glGetProgramInfoLog(program, 512, NULL, logmsg);
        printf("%s\n", logmsg);
        exit(-1);
    }

    glDeleteShader(vs);
    glDeleteShader(fs);
    return program;
}

GLuint upload_vertex_array(int count) {
    GLuint vao = 0;
    glGenVertexArrays(1, &vao);
    glBindVertexArray(vao);

    GLuint vbo = 0;
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, count * 3 * sizeof(float),  NULL, GL_STATIC_DRAW);

    float* vboptr;
    for (int i = 0; i < 10; i++) {
        auto start = std::chrono::high_resolution_clock::now();
        vboptr = (float *)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
        auto end = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::microseconds>(end - start).count();
        printf("glMapBuffer: %lld us\n", duration);
        for (int i = 0; i < count * 3; i++) {
            *vboptr++ = rand01() * (rand01() > 0.5 ? 1 : -1);
        }
        glUnmapBuffer(GL_ARRAY_BUFFER);
    }


    GLuint ebo = 0;
    glGenBuffers(1, &ebo);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ARRAY_BUFFER, count * 3 * sizeof(int),  NULL, GL_STATIC_DRAW);
    int* eboptr = (int*)glMapBuffer(GL_ARRAY_BUFFER, GL_WRITE_ONLY);
    for (int i = 0; i < count * 3; i++) {
        *eboptr++ = i;
    }
    glUnmapBuffer(GL_ELEMENT_ARRAY_BUFFER);

    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(float), NULL);
    glEnableVertexAttribArray(0);

    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindVertexArray(0);
    return vao;
}

int main() 
{
    srand((GLuint)time(NULL));

    if (!glfwInit()) {
        return -1;
    }

    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 3);
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE);
#ifdef __APPLE__
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GL_TRUE);
#endif 

    GLFWwindow* window = glfwCreateWindow(1920, 1080, "W.Zhu Test", NULL, NULL);
    if (!window) {
        glfwTerminate();
        return -1;
    }

    glfwMakeContextCurrent(window);

    if (!gladLoadGLLoader((GLADloadproc)glfwGetProcAddress)) {
        return -1;
    }

    glfwSetFramebufferSizeCallback(window, glfw_callback_fb_size);
    GLuint program = compile_and_link_program();
    GLuint vao = upload_vertex_array(900000);

    glViewport(0, 0, 1920, 1080);    
    glUseProgram(program);
    glBindVertexArray(vao);

    while (!glfwWindowShouldClose(window)) {
        glClearColor(0, 0, 0, 1);
        glClear(GL_COLOR_BUFFER_BIT);
        glDrawElements(GL_TRIANGLES, 900000, GL_UNSIGNED_INT, 0);

        glfwSwapBuffers(window);
        glfwPollEvents();
    }

    glfwDestroyWindow(window);
    glfwTerminate();
    return 0;
}
