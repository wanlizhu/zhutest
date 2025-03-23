#include "glad.h"

#ifdef __cplusplus
extern "C" {
#endif

#undef glCullFace
void glCullFace(GLenum mode) {}

#undef glFrontFace
void glFrontFace(GLenum mode) {}

#undef glHint
void glHint(GLenum target, GLenum mode) {}

#undef glLineWidth
void glLineWidth(GLfloat width) {}

#undef glPointSize
void glPointSize(GLfloat size) {}

#undef glPolygonMode
void glPolygonMode(GLenum face, GLenum mode) {}

#undef glScissor
void glScissor(GLint x, GLint y, GLsizei width, GLsizei height) {}

#undef glTexParameterf
void glTexParameterf(GLenum target, GLenum pname, GLfloat param) {}

#undef glTexParameterfv
void glTexParameterfv(GLenum target, GLenum pname, const GLfloat *params) {}

#undef glTexParameteri
void glTexParameteri(GLenum target, GLenum pname, GLint param) {}

#undef glTexParameteriv
void glTexParameteriv(GLenum target, GLenum pname, const GLint *params) {}

#undef glTexImage1D
void glTexImage1D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, const void *pixels) {}

#undef glTexImage2D
void glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const void *pixels) {}

#undef glDrawBuffer
void glDrawBuffer(GLenum buf) {}

#undef glClear
void glClear(GLbitfield mask) {}

#undef glClearColor
void glClearColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {}

#undef glClearStencil
void glClearStencil(GLint s) {}

#undef glClearDepth
void glClearDepth(GLdouble depth) {}

#undef glStencilMask
void glStencilMask(GLuint mask) {}

#undef glColorMask
void glColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha) {}

#undef glDepthMask
void glDepthMask(GLboolean flag) {}

#undef glDisable
void glDisable(GLenum cap) {}

#undef glEnable
void glEnable(GLenum cap) {}

#undef glFinish
void glFinish(void) {}

#undef glFlush
void glFlush(void) {}

#undef glBlendFunc
void glBlendFunc(GLenum sfactor, GLenum dfactor) {}

#undef glLogicOp
void glLogicOp(GLenum opcode) {}

#undef glStencilFunc
void glStencilFunc(GLenum func, GLint ref, GLuint mask) {}

#undef glStencilOp
void glStencilOp(GLenum fail, GLenum zfail, GLenum zpass) {}

#undef glDepthFunc
void glDepthFunc(GLenum func) {}

#undef glPixelStoref
void glPixelStoref(GLenum pname, GLfloat param) {}

#undef glPixelStorei
void glPixelStorei(GLenum pname, GLint param) {}

#undef glReadBuffer
void glReadBuffer(GLenum src) {}

#undef glReadPixels
void glReadPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, void *pixels) {}

#undef glGetBooleanv
void glGetBooleanv(GLenum pname, GLboolean *data) {}

#undef glGetDoublev
void glGetDoublev(GLenum pname, GLdouble *data) {}

#undef glGetError
GLenum glGetError(void);

#undef glGetFloatv
void glGetFloatv(GLenum pname, GLfloat *data) {}

#undef glGetIntegerv
void glGetIntegerv(GLenum pname, GLint *data) {}

#undef glGetString
const GLubyte * glGetString(GLenum name);

#undef glGetTexImage
void glGetTexImage(GLenum target, GLint level, GLenum format, GLenum type, void *pixels) {}

#undef glGetTexParameterfv
void glGetTexParameterfv(GLenum target, GLenum pname, GLfloat *params) {}

#undef glGetTexParameteriv
void glGetTexParameteriv(GLenum target, GLenum pname, GLint *params) {}

#undef glGetTexLevelParameterfv
void glGetTexLevelParameterfv(GLenum target, GLint level, GLenum pname, GLfloat *params) {}

#undef glGetTexLevelParameteriv
void glGetTexLevelParameteriv(GLenum target, GLint level, GLenum pname, GLint *params) {}

#undef glIsEnabled
GLboolean glIsEnabled(GLenum cap);

#undef glDepthRange
void glDepthRange(GLdouble n, GLdouble f) {}

#undef glViewport
void glViewport(GLint x, GLint y, GLsizei width, GLsizei height) {}

#undef glNewList
void glNewList(GLuint list, GLenum mode) {}

#undef glEndList
void glEndList(void) {}

#undef glCallList
void glCallList(GLuint list) {}

#undef glCallLists
void glCallLists(GLsizei n, GLenum type, const void *lists) {}

#undef glDeleteLists
void glDeleteLists(GLuint list, GLsizei range) {}

#undef glGenLists
GLuint glGenLists(GLsizei range);

#undef glListBase
void glListBase(GLuint base) {}

#undef glBegin
void glBegin(GLenum mode) {}

#undef glBitmap
void glBitmap(GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove, const GLubyte *bitmap) {}

#undef glColor3b
void glColor3b(GLbyte red, GLbyte green, GLbyte blue) {}

#undef glColor3bv
void glColor3bv(const GLbyte *v) {}

#undef glColor3d
void glColor3d(GLdouble red, GLdouble green, GLdouble blue) {}

#undef glColor3dv
void glColor3dv(const GLdouble *v) {}

#undef glColor3f
void glColor3f(GLfloat red, GLfloat green, GLfloat blue) {}

#undef glColor3fv
void glColor3fv(const GLfloat *v) {}

#undef glColor3i
void glColor3i(GLint red, GLint green, GLint blue) {}

#undef glColor3iv
void glColor3iv(const GLint *v) {}

#undef glColor3s
void glColor3s(GLshort red, GLshort green, GLshort blue) {}

#undef glColor3sv
void glColor3sv(const GLshort *v) {}

#undef glColor3ub
void glColor3ub(GLubyte red, GLubyte green, GLubyte blue) {}

#undef glColor3ubv
void glColor3ubv(const GLubyte *v) {}

#undef glColor3ui
void glColor3ui(GLuint red, GLuint green, GLuint blue) {}

#undef glColor3uiv
void glColor3uiv(const GLuint *v) {}

#undef glColor3us
void glColor3us(GLushort red, GLushort green, GLushort blue) {}

#undef glColor3usv
void glColor3usv(const GLushort *v) {}

#undef glColor4b
void glColor4b(GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha) {}

#undef glColor4bv
void glColor4bv(const GLbyte *v) {}

#undef glColor4d
void glColor4d(GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha) {}

#undef glColor4dv
void glColor4dv(const GLdouble *v) {}

#undef glColor4f
void glColor4f(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {}

#undef glColor4fv
void glColor4fv(const GLfloat *v) {}

#undef glColor4i
void glColor4i(GLint red, GLint green, GLint blue, GLint alpha) {}

#undef glColor4iv
void glColor4iv(const GLint *v) {}

#undef glColor4s
void glColor4s(GLshort red, GLshort green, GLshort blue, GLshort alpha) {}

#undef glColor4sv
void glColor4sv(const GLshort *v) {}

#undef glColor4ub
void glColor4ub(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha) {}

#undef glColor4ubv
void glColor4ubv(const GLubyte *v) {}

#undef glColor4ui
void glColor4ui(GLuint red, GLuint green, GLuint blue, GLuint alpha) {}

#undef glColor4uiv
void glColor4uiv(const GLuint *v) {}

#undef glColor4us
void glColor4us(GLushort red, GLushort green, GLushort blue, GLushort alpha) {}

#undef glColor4usv
void glColor4usv(const GLushort *v) {}

#undef glEdgeFlag
void glEdgeFlag(GLboolean flag) {}

#undef glEdgeFlagv
void glEdgeFlagv(const GLboolean *flag) {}

#undef glEnd
void glEnd(void) {}

#undef glIndexd
void glIndexd(GLdouble c) {}

#undef glIndexdv
void glIndexdv(const GLdouble *c) {}

#undef glIndexf
void glIndexf(GLfloat c) {}

#undef glIndexfv
void glIndexfv(const GLfloat *c) {}

#undef glIndexi
void glIndexi(GLint c) {}

#undef glIndexiv
void glIndexiv(const GLint *c) {}

#undef glIndexs
void glIndexs(GLshort c) {}

#undef glIndexsv
void glIndexsv(const GLshort *c) {}

#undef glNormal3b
void glNormal3b(GLbyte nx, GLbyte ny, GLbyte nz) {}

#undef glNormal3bv
void glNormal3bv(const GLbyte *v) {}

#undef glNormal3d
void glNormal3d(GLdouble nx, GLdouble ny, GLdouble nz) {}

#undef glNormal3dv
void glNormal3dv(const GLdouble *v) {}

#undef glNormal3f
void glNormal3f(GLfloat nx, GLfloat ny, GLfloat nz) {}

#undef glNormal3fv
void glNormal3fv(const GLfloat *v) {}

#undef glNormal3i
void glNormal3i(GLint nx, GLint ny, GLint nz) {}

#undef glNormal3iv
void glNormal3iv(const GLint *v) {}

#undef glNormal3s
void glNormal3s(GLshort nx, GLshort ny, GLshort nz) {}

#undef glNormal3sv
void glNormal3sv(const GLshort *v) {}

#undef glRasterPos2d
void glRasterPos2d(GLdouble x, GLdouble y) {}

#undef glRasterPos2dv
void glRasterPos2dv(const GLdouble *v) {}

#undef glRasterPos2f
void glRasterPos2f(GLfloat x, GLfloat y) {}

#undef glRasterPos2fv
void glRasterPos2fv(const GLfloat *v) {}

#undef glRasterPos2i
void glRasterPos2i(GLint x, GLint y) {}

#undef glRasterPos2iv
void glRasterPos2iv(const GLint *v) {}

#undef glRasterPos2s
void glRasterPos2s(GLshort x, GLshort y) {}

#undef glRasterPos2sv
void glRasterPos2sv(const GLshort *v) {}

#undef glRasterPos3d
void glRasterPos3d(GLdouble x, GLdouble y, GLdouble z) {}

#undef glRasterPos3dv
void glRasterPos3dv(const GLdouble *v) {}

#undef glRasterPos3f
void glRasterPos3f(GLfloat x, GLfloat y, GLfloat z) {}

#undef glRasterPos3fv
void glRasterPos3fv(const GLfloat *v) {}

#undef glRasterPos3i
void glRasterPos3i(GLint x, GLint y, GLint z) {}

#undef glRasterPos3iv
void glRasterPos3iv(const GLint *v) {}

#undef glRasterPos3s
void glRasterPos3s(GLshort x, GLshort y, GLshort z) {}

#undef glRasterPos3sv
void glRasterPos3sv(const GLshort *v) {}

#undef glRasterPos4d
void glRasterPos4d(GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}

#undef glRasterPos4dv
void glRasterPos4dv(const GLdouble *v) {}

#undef glRasterPos4f
void glRasterPos4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}

#undef glRasterPos4fv
void glRasterPos4fv(const GLfloat *v) {}

#undef glRasterPos4i
void glRasterPos4i(GLint x, GLint y, GLint z, GLint w) {}

#undef glRasterPos4iv
void glRasterPos4iv(const GLint *v) {}

#undef glRasterPos4s
void glRasterPos4s(GLshort x, GLshort y, GLshort z, GLshort w) {}

#undef glRasterPos4sv
void glRasterPos4sv(const GLshort *v) {}

#undef glRectd
void glRectd(GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2) {}

#undef glRectdv
void glRectdv(const GLdouble *v1, const GLdouble *v2) {}

#undef glRectf
void glRectf(GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2) {}

#undef glRectfv
void glRectfv(const GLfloat *v1, const GLfloat *v2) {}

#undef glRecti
void glRecti(GLint x1, GLint y1, GLint x2, GLint y2) {}

#undef glRectiv
void glRectiv(const GLint *v1, const GLint *v2) {}

#undef glRects
void glRects(GLshort x1, GLshort y1, GLshort x2, GLshort y2) {}

#undef glRectsv
void glRectsv(const GLshort *v1, const GLshort *v2) {}

#undef glTexCoord1d
void glTexCoord1d(GLdouble s) {}

#undef glTexCoord1dv
void glTexCoord1dv(const GLdouble *v) {}

#undef glTexCoord1f
void glTexCoord1f(GLfloat s) {}

#undef glTexCoord1fv
void glTexCoord1fv(const GLfloat *v) {}

#undef glTexCoord1i
void glTexCoord1i(GLint s) {}

#undef glTexCoord1iv
void glTexCoord1iv(const GLint *v) {}

#undef glTexCoord1s
void glTexCoord1s(GLshort s) {}

#undef glTexCoord1sv
void glTexCoord1sv(const GLshort *v) {}

#undef glTexCoord2d
void glTexCoord2d(GLdouble s, GLdouble t) {}

#undef glTexCoord2dv
void glTexCoord2dv(const GLdouble *v) {}

#undef glTexCoord2f
void glTexCoord2f(GLfloat s, GLfloat t) {}

#undef glTexCoord2fv
void glTexCoord2fv(const GLfloat *v) {}

#undef glTexCoord2i
void glTexCoord2i(GLint s, GLint t) {}

#undef glTexCoord2iv
void glTexCoord2iv(const GLint *v) {}

#undef glTexCoord2s
void glTexCoord2s(GLshort s, GLshort t) {}

#undef glTexCoord2sv
void glTexCoord2sv(const GLshort *v) {}

#undef glTexCoord3d
void glTexCoord3d(GLdouble s, GLdouble t, GLdouble r) {}

#undef glTexCoord3dv
void glTexCoord3dv(const GLdouble *v) {}

#undef glTexCoord3f
void glTexCoord3f(GLfloat s, GLfloat t, GLfloat r) {}

#undef glTexCoord3fv
void glTexCoord3fv(const GLfloat *v) {}

#undef glTexCoord3i
void glTexCoord3i(GLint s, GLint t, GLint r) {}

#undef glTexCoord3iv
void glTexCoord3iv(const GLint *v) {}

#undef glTexCoord3s
void glTexCoord3s(GLshort s, GLshort t, GLshort r) {}

#undef glTexCoord3sv
void glTexCoord3sv(const GLshort *v) {}

#undef glTexCoord4d
void glTexCoord4d(GLdouble s, GLdouble t, GLdouble r, GLdouble q) {}

#undef glTexCoord4dv
void glTexCoord4dv(const GLdouble *v) {}

#undef glTexCoord4f
void glTexCoord4f(GLfloat s, GLfloat t, GLfloat r, GLfloat q) {}

#undef glTexCoord4fv
void glTexCoord4fv(const GLfloat *v) {}

#undef glTexCoord4i
void glTexCoord4i(GLint s, GLint t, GLint r, GLint q) {}

#undef glTexCoord4iv
void glTexCoord4iv(const GLint *v) {}

#undef glTexCoord4s
void glTexCoord4s(GLshort s, GLshort t, GLshort r, GLshort q) {}

#undef glTexCoord4sv
void glTexCoord4sv(const GLshort *v) {}

#undef glVertex2d
void glVertex2d(GLdouble x, GLdouble y) {}

#undef glVertex2dv
void glVertex2dv(const GLdouble *v) {}

#undef glVertex2f
void glVertex2f(GLfloat x, GLfloat y) {}

#undef glVertex2fv
void glVertex2fv(const GLfloat *v) {}

#undef glVertex2i
void glVertex2i(GLint x, GLint y) {}

#undef glVertex2iv
void glVertex2iv(const GLint *v) {}

#undef glVertex2s
void glVertex2s(GLshort x, GLshort y) {}

#undef glVertex2sv
void glVertex2sv(const GLshort *v) {}

#undef glVertex3d
void glVertex3d(GLdouble x, GLdouble y, GLdouble z) {}

#undef glVertex3dv
void glVertex3dv(const GLdouble *v) {}

#undef glVertex3f
void glVertex3f(GLfloat x, GLfloat y, GLfloat z) {}

#undef glVertex3fv
void glVertex3fv(const GLfloat *v) {}

#undef glVertex3i
void glVertex3i(GLint x, GLint y, GLint z) {}

#undef glVertex3iv
void glVertex3iv(const GLint *v) {}

#undef glVertex3s
void glVertex3s(GLshort x, GLshort y, GLshort z) {}

#undef glVertex3sv
void glVertex3sv(const GLshort *v) {}

#undef glVertex4d
void glVertex4d(GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}

#undef glVertex4dv
void glVertex4dv(const GLdouble *v) {}

#undef glVertex4f
void glVertex4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}

#undef glVertex4fv
void glVertex4fv(const GLfloat *v) {}

#undef glVertex4i
void glVertex4i(GLint x, GLint y, GLint z, GLint w) {}

#undef glVertex4iv
void glVertex4iv(const GLint *v) {}

#undef glVertex4s
void glVertex4s(GLshort x, GLshort y, GLshort z, GLshort w) {}

#undef glVertex4sv
void glVertex4sv(const GLshort *v) {}

#undef glClipPlane
void glClipPlane(GLenum plane, const GLdouble *equation) {}

#undef glColorMaterial
void glColorMaterial(GLenum face, GLenum mode) {}

#undef glFogf
void glFogf(GLenum pname, GLfloat param) {}

#undef glFogfv
void glFogfv(GLenum pname, const GLfloat *params) {}

#undef glFogi
void glFogi(GLenum pname, GLint param) {}

#undef glFogiv
void glFogiv(GLenum pname, const GLint *params) {}

#undef glLightf
void glLightf(GLenum light, GLenum pname, GLfloat param) {}

#undef glLightfv
void glLightfv(GLenum light, GLenum pname, const GLfloat *params) {}

#undef glLighti
void glLighti(GLenum light, GLenum pname, GLint param) {}

#undef glLightiv
void glLightiv(GLenum light, GLenum pname, const GLint *params) {}

#undef glLightModelf
void glLightModelf(GLenum pname, GLfloat param) {}

#undef glLightModelfv
void glLightModelfv(GLenum pname, const GLfloat *params) {}

#undef glLightModeli
void glLightModeli(GLenum pname, GLint param) {}

#undef glLightModeliv
void glLightModeliv(GLenum pname, const GLint *params) {}

#undef glLineStipple
void glLineStipple(GLint factor, GLushort pattern) {}

#undef glMaterialf
void glMaterialf(GLenum face, GLenum pname, GLfloat param) {}

#undef glMaterialfv
void glMaterialfv(GLenum face, GLenum pname, const GLfloat *params) {}

#undef glMateriali
void glMateriali(GLenum face, GLenum pname, GLint param) {}

#undef glMaterialiv
void glMaterialiv(GLenum face, GLenum pname, const GLint *params) {}

#undef glPolygonStipple
void glPolygonStipple(const GLubyte *mask) {}

#undef glShadeModel
void glShadeModel(GLenum mode) {}

#undef glTexEnvf
void glTexEnvf(GLenum target, GLenum pname, GLfloat param) {}

#undef glTexEnvfv
void glTexEnvfv(GLenum target, GLenum pname, const GLfloat *params) {}

#undef glTexEnvi
void glTexEnvi(GLenum target, GLenum pname, GLint param) {}

#undef glTexEnviv
void glTexEnviv(GLenum target, GLenum pname, const GLint *params) {}

#undef glTexGend
void glTexGend(GLenum coord, GLenum pname, GLdouble param) {}

#undef glTexGendv
void glTexGendv(GLenum coord, GLenum pname, const GLdouble *params) {}

#undef glTexGenf
void glTexGenf(GLenum coord, GLenum pname, GLfloat param) {}

#undef glTexGenfv
void glTexGenfv(GLenum coord, GLenum pname, const GLfloat *params) {}

#undef glTexGeni
void glTexGeni(GLenum coord, GLenum pname, GLint param) {}

#undef glTexGeniv
void glTexGeniv(GLenum coord, GLenum pname, const GLint *params) {}

#undef glFeedbackBuffer
void glFeedbackBuffer(GLsizei size, GLenum type, GLfloat *buffer) {}

#undef glSelectBuffer
void glSelectBuffer(GLsizei size, GLuint *buffer) {}

#undef glRenderMode
GLint glRenderMode(GLenum mode);

#undef glInitNames
void glInitNames(void) {}

#undef glLoadName
void glLoadName(GLuint name) {}

#undef glPassThrough
void glPassThrough(GLfloat token) {}

#undef glPopName
void glPopName(void) {}

#undef glPushName
void glPushName(GLuint name) {}

#undef glClearAccum
void glClearAccum(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {}

#undef glClearIndex
void glClearIndex(GLfloat c) {}

#undef glIndexMask
void glIndexMask(GLuint mask) {}

#undef glAccum
void glAccum(GLenum op, GLfloat value) {}

#undef glPopAttrib
void glPopAttrib(void) {}

#undef glPushAttrib
void glPushAttrib(GLbitfield mask) {}

#undef glMap1d
void glMap1d(GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order, const GLdouble *points) {}

#undef glMap1f
void glMap1f(GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order, const GLfloat *points) {}

#undef glMap2d
void glMap2d(GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, const GLdouble *points) {}

#undef glMap2f
void glMap2f(GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, const GLfloat *points) {}

#undef glMapGrid1d
void glMapGrid1d(GLint un, GLdouble u1, GLdouble u2) {}

#undef glMapGrid1f
void glMapGrid1f(GLint un, GLfloat u1, GLfloat u2) {}

#undef glMapGrid2d
void glMapGrid2d(GLint un, GLdouble u1, GLdouble u2, GLint vn, GLdouble v1, GLdouble v2) {}

#undef glMapGrid2f
void glMapGrid2f(GLint un, GLfloat u1, GLfloat u2, GLint vn, GLfloat v1, GLfloat v2) {}

#undef glEvalCoord1d
void glEvalCoord1d(GLdouble u) {}

#undef glEvalCoord1dv
void glEvalCoord1dv(const GLdouble *u) {}

#undef glEvalCoord1f
void glEvalCoord1f(GLfloat u) {}

#undef glEvalCoord1fv
void glEvalCoord1fv(const GLfloat *u) {}

#undef glEvalCoord2d
void glEvalCoord2d(GLdouble u, GLdouble v) {}

#undef glEvalCoord2dv
void glEvalCoord2dv(const GLdouble *u) {}

#undef glEvalCoord2f
void glEvalCoord2f(GLfloat u, GLfloat v) {}

#undef glEvalCoord2fv
void glEvalCoord2fv(const GLfloat *u) {}

#undef glEvalMesh1
void glEvalMesh1(GLenum mode, GLint i1, GLint i2) {}

#undef glEvalPoint1
void glEvalPoint1(GLint i) {}

#undef glEvalMesh2
void glEvalMesh2(GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2) {}

#undef glEvalPoint2
void glEvalPoint2(GLint i, GLint j) {}

#undef glAlphaFunc
void glAlphaFunc(GLenum func, GLfloat ref) {}

#undef glPixelZoom
void glPixelZoom(GLfloat xfactor, GLfloat yfactor) {}

#undef glPixelTransferf
void glPixelTransferf(GLenum pname, GLfloat param) {}

#undef glPixelTransferi
void glPixelTransferi(GLenum pname, GLint param) {}

#undef glPixelMapfv
void glPixelMapfv(GLenum map, GLsizei mapsize, const GLfloat *values) {}

#undef glPixelMapuiv
void glPixelMapuiv(GLenum map, GLsizei mapsize, const GLuint *values) {}

#undef glPixelMapusv
void glPixelMapusv(GLenum map, GLsizei mapsize, const GLushort *values) {}

#undef glCopyPixels
void glCopyPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum type) {}

#undef glDrawPixels
void glDrawPixels(GLsizei width, GLsizei height, GLenum format, GLenum type, const void *pixels) {}

#undef glGetClipPlane
void glGetClipPlane(GLenum plane, GLdouble *equation) {}

#undef glGetLightfv
void glGetLightfv(GLenum light, GLenum pname, GLfloat *params) {}

#undef glGetLightiv
void glGetLightiv(GLenum light, GLenum pname, GLint *params) {}

#undef glGetMapdv
void glGetMapdv(GLenum target, GLenum query, GLdouble *v) {}

#undef glGetMapfv
void glGetMapfv(GLenum target, GLenum query, GLfloat *v) {}

#undef glGetMapiv
void glGetMapiv(GLenum target, GLenum query, GLint *v) {}

#undef glGetMaterialfv
void glGetMaterialfv(GLenum face, GLenum pname, GLfloat *params) {}

#undef glGetMaterialiv
void glGetMaterialiv(GLenum face, GLenum pname, GLint *params) {}

#undef glGetPixelMapfv
void glGetPixelMapfv(GLenum map, GLfloat *values) {}

#undef glGetPixelMapuiv
void glGetPixelMapuiv(GLenum map, GLuint *values) {}

#undef glGetPixelMapusv
void glGetPixelMapusv(GLenum map, GLushort *values) {}

#undef glGetPolygonStipple
void glGetPolygonStipple(GLubyte *mask) {}

#undef glGetTexEnvfv
void glGetTexEnvfv(GLenum target, GLenum pname, GLfloat *params) {}

#undef glGetTexEnviv
void glGetTexEnviv(GLenum target, GLenum pname, GLint *params) {}

#undef glGetTexGendv
void glGetTexGendv(GLenum coord, GLenum pname, GLdouble *params) {}

#undef glGetTexGenfv
void glGetTexGenfv(GLenum coord, GLenum pname, GLfloat *params) {}

#undef glGetTexGeniv
void glGetTexGeniv(GLenum coord, GLenum pname, GLint *params) {}

#undef glIsList
GLboolean glIsList(GLuint list);

#undef glFrustum
void glFrustum(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar) {}

#undef glLoadIdentity
void glLoadIdentity(void) {}

#undef glLoadMatrixf
void glLoadMatrixf(const GLfloat *m) {}

#undef glLoadMatrixd
void glLoadMatrixd(const GLdouble *m) {}

#undef glMatrixMode
void glMatrixMode(GLenum mode) {}

#undef glMultMatrixf
void glMultMatrixf(const GLfloat *m) {}

#undef glMultMatrixd
void glMultMatrixd(const GLdouble *m) {}

#undef glOrtho
void glOrtho(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar) {}

#undef glPopMatrix
void glPopMatrix(void) {}

#undef glPushMatrix
void glPushMatrix(void) {}

#undef glRotated
void glRotated(GLdouble angle, GLdouble x, GLdouble y, GLdouble z) {}

#undef glRotatef
void glRotatef(GLfloat angle, GLfloat x, GLfloat y, GLfloat z) {}

#undef glScaled
void glScaled(GLdouble x, GLdouble y, GLdouble z) {}

#undef glScalef
void glScalef(GLfloat x, GLfloat y, GLfloat z) {}

#undef glTranslated
void glTranslated(GLdouble x, GLdouble y, GLdouble z) {}

#undef glTranslatef
void glTranslatef(GLfloat x, GLfloat y, GLfloat z) {}

#undef glActiveTexture
void glActiveTexture(GLenum texture) {}

#undef glSampleCoverage
void glSampleCoverage(GLfloat value, GLboolean invert) {}

#undef glCompressedTexImage3D
void glCompressedTexImage3D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, const void *data) {}

#undef glCompressedTexImage2D
void glCompressedTexImage2D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const void *data) {}

#undef glCompressedTexImage1D
void glCompressedTexImage1D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, const void *data) {}

#undef glCompressedTexSubImage3D
void glCompressedTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const void *data) {}

#undef glCompressedTexSubImage2D
void glCompressedTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const void *data) {}

#undef glCompressedTexSubImage1D
void glCompressedTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const void *data) {}

#undef glGetCompressedTexImage
void glGetCompressedTexImage(GLenum target, GLint level, void *img) {}

#undef glClientActiveTexture
void glClientActiveTexture(GLenum texture) {}

#undef glMultiTexCoord1d
void glMultiTexCoord1d(GLenum target, GLdouble s) {}

#undef glMultiTexCoord1dv
void glMultiTexCoord1dv(GLenum target, const GLdouble *v) {}

#undef glMultiTexCoord1f
void glMultiTexCoord1f(GLenum target, GLfloat s) {}

#undef glMultiTexCoord1fv
void glMultiTexCoord1fv(GLenum target, const GLfloat *v) {}

#undef glMultiTexCoord1i
void glMultiTexCoord1i(GLenum target, GLint s) {}

#undef glMultiTexCoord1iv
void glMultiTexCoord1iv(GLenum target, const GLint *v) {}

#undef glMultiTexCoord1s
void glMultiTexCoord1s(GLenum target, GLshort s) {}

#undef glMultiTexCoord1sv
void glMultiTexCoord1sv(GLenum target, const GLshort *v) {}

#undef glMultiTexCoord2d
void glMultiTexCoord2d(GLenum target, GLdouble s, GLdouble t) {}

#undef glMultiTexCoord2dv
void glMultiTexCoord2dv(GLenum target, const GLdouble *v) {}

#undef glMultiTexCoord2f
void glMultiTexCoord2f(GLenum target, GLfloat s, GLfloat t) {}

#undef glMultiTexCoord2fv
void glMultiTexCoord2fv(GLenum target, const GLfloat *v) {}

#undef glMultiTexCoord2i
void glMultiTexCoord2i(GLenum target, GLint s, GLint t) {}

#undef glMultiTexCoord2iv
void glMultiTexCoord2iv(GLenum target, const GLint *v) {}

#undef glMultiTexCoord2s
void glMultiTexCoord2s(GLenum target, GLshort s, GLshort t) {}

#undef glMultiTexCoord2sv
void glMultiTexCoord2sv(GLenum target, const GLshort *v) {}

#undef glMultiTexCoord3d
void glMultiTexCoord3d(GLenum target, GLdouble s, GLdouble t, GLdouble r) {}

#undef glMultiTexCoord3dv
void glMultiTexCoord3dv(GLenum target, const GLdouble *v) {}

#undef glMultiTexCoord3f
void glMultiTexCoord3f(GLenum target, GLfloat s, GLfloat t, GLfloat r) {}

#undef glMultiTexCoord3fv
void glMultiTexCoord3fv(GLenum target, const GLfloat *v) {}

#undef glMultiTexCoord3i
void glMultiTexCoord3i(GLenum target, GLint s, GLint t, GLint r) {}

#undef glMultiTexCoord3iv
void glMultiTexCoord3iv(GLenum target, const GLint *v) {}

#undef glMultiTexCoord3s
void glMultiTexCoord3s(GLenum target, GLshort s, GLshort t, GLshort r) {}

#undef glMultiTexCoord3sv
void glMultiTexCoord3sv(GLenum target, const GLshort *v) {}

#undef glMultiTexCoord4d
void glMultiTexCoord4d(GLenum target, GLdouble s, GLdouble t, GLdouble r, GLdouble q) {}

#undef glMultiTexCoord4dv
void glMultiTexCoord4dv(GLenum target, const GLdouble *v) {}

#undef glMultiTexCoord4f
void glMultiTexCoord4f(GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q) {}

#undef glMultiTexCoord4fv
void glMultiTexCoord4fv(GLenum target, const GLfloat *v) {}

#undef glMultiTexCoord4i
void glMultiTexCoord4i(GLenum target, GLint s, GLint t, GLint r, GLint q) {}

#undef glMultiTexCoord4iv
void glMultiTexCoord4iv(GLenum target, const GLint *v) {}

#undef glMultiTexCoord4s
void glMultiTexCoord4s(GLenum target, GLshort s, GLshort t, GLshort r, GLshort q) {}

#undef glMultiTexCoord4sv
void glMultiTexCoord4sv(GLenum target, const GLshort *v) {}

#undef glLoadTransposeMatrixf
void glLoadTransposeMatrixf(const GLfloat *m) {}

#undef glLoadTransposeMatrixd
void glLoadTransposeMatrixd(const GLdouble *m) {}

#undef glMultTransposeMatrixf
void glMultTransposeMatrixf(const GLfloat *m) {}

#undef glMultTransposeMatrixd
void glMultTransposeMatrixd(const GLdouble *m) {}

#undef glBlendEquationSeparate
void glBlendEquationSeparate(GLenum modeRGB, GLenum modeAlpha) {}

#undef glDrawBuffers
void glDrawBuffers(GLsizei n, const GLenum *bufs) {}

#undef glStencilOpSeparate
void glStencilOpSeparate(GLenum face, GLenum sfail, GLenum dpfail, GLenum dppass) {}

#undef glStencilFuncSeparate
void glStencilFuncSeparate(GLenum face, GLenum func, GLint ref, GLuint mask) {}

#undef glStencilMaskSeparate
void glStencilMaskSeparate(GLenum face, GLuint mask) {}

#undef glAttachShader
void glAttachShader(GLuint program, GLuint shader) {}

#undef glBindAttribLocation
void glBindAttribLocation(GLuint program, GLuint index, const GLchar *name) {}

#undef glCompileShader
void glCompileShader(GLuint shader) {}

#undef glCreateProgram
GLuint glCreateProgram(void);

#undef glCreateShader
GLuint glCreateShader(GLenum type);

#undef glDeleteProgram
void glDeleteProgram(GLuint program) {}

#undef glDeleteShader
void glDeleteShader(GLuint shader) {}

#undef glDetachShader
void glDetachShader(GLuint program, GLuint shader) {}

#undef glDisableVertexAttribArray
void glDisableVertexAttribArray(GLuint index) {}

#undef glEnableVertexAttribArray
void glEnableVertexAttribArray(GLuint index) {}

#undef glGetActiveAttrib
void glGetActiveAttrib(GLuint program, GLuint index, GLsizei bufSize, GLsizei *length, GLint *size, GLenum *type, GLchar *name) {}

#undef glGetActiveUniform
void glGetActiveUniform(GLuint program, GLuint index, GLsizei bufSize, GLsizei *length, GLint *size, GLenum *type, GLchar *name) {}

#undef glGetAttachedShaders
void glGetAttachedShaders(GLuint program, GLsizei maxCount, GLsizei *count, GLuint *shaders) {}

#undef glGetAttribLocation
GLint glGetAttribLocation(GLuint program, const GLchar *name);

#undef glGetProgramiv
void glGetProgramiv(GLuint program, GLenum pname, GLint *params) {}

#undef glGetProgramInfoLog
void glGetProgramInfoLog(GLuint program, GLsizei bufSize, GLsizei *length, GLchar *infoLog) {}

#undef glGetShaderiv
void glGetShaderiv(GLuint shader, GLenum pname, GLint *params) {}

#undef glGetShaderInfoLog
void glGetShaderInfoLog(GLuint shader, GLsizei bufSize, GLsizei *length, GLchar *infoLog) {}

#undef glGetShaderSource
void glGetShaderSource(GLuint shader, GLsizei bufSize, GLsizei *length, GLchar *source) {}

#undef glGetUniformLocation
GLint glGetUniformLocation(GLuint program, const GLchar *name);

#undef glGetUniformfv
void glGetUniformfv(GLuint program, GLint location, GLfloat *params) {}

#undef glGetUniformiv
void glGetUniformiv(GLuint program, GLint location, GLint *params) {}

#undef glGetVertexAttribdv
void glGetVertexAttribdv(GLuint index, GLenum pname, GLdouble *params) {}

#undef glGetVertexAttribfv
void glGetVertexAttribfv(GLuint index, GLenum pname, GLfloat *params) {}

#undef glGetVertexAttribiv
void glGetVertexAttribiv(GLuint index, GLenum pname, GLint *params) {}

#undef glGetVertexAttribPointerv
void glGetVertexAttribPointerv(GLuint index, GLenum pname, void **pointer) {}

#undef glIsProgram
GLboolean glIsProgram(GLuint program);

#undef glIsShader
GLboolean glIsShader(GLuint shader);

#undef glLinkProgram
void glLinkProgram(GLuint program) {}

#undef glShaderSource
void glShaderSource(GLuint shader, GLsizei count, const GLchar *const*string, const GLint *length) {}

#undef glUseProgram
void glUseProgram(GLuint program) {}

#undef glUniform1f
void glUniform1f(GLint location, GLfloat v0) {}

#undef glUniform2f
void glUniform2f(GLint location, GLfloat v0, GLfloat v1) {}

#undef glUniform3f
void glUniform3f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2) {}

#undef glUniform4f
void glUniform4f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3) {}

#undef glUniform1i
void glUniform1i(GLint location, GLint v0) {}

#undef glUniform2i
void glUniform2i(GLint location, GLint v0, GLint v1) {}

#undef glUniform3i
void glUniform3i(GLint location, GLint v0, GLint v1, GLint v2) {}

#undef glUniform4i
void glUniform4i(GLint location, GLint v0, GLint v1, GLint v2, GLint v3) {}

#undef glUniform1fv
void glUniform1fv(GLint location, GLsizei count, const GLfloat *value) {}

#undef glUniform2fv
void glUniform2fv(GLint location, GLsizei count, const GLfloat *value) {}

#undef glUniform3fv
void glUniform3fv(GLint location, GLsizei count, const GLfloat *value) {}

#undef glUniform4fv
void glUniform4fv(GLint location, GLsizei count, const GLfloat *value) {}

#undef glUniform1iv
void glUniform1iv(GLint location, GLsizei count, const GLint *value) {}

#undef glUniform2iv
void glUniform2iv(GLint location, GLsizei count, const GLint *value) {}

#undef glUniform3iv
void glUniform3iv(GLint location, GLsizei count, const GLint *value) {}

#undef glUniform4iv
void glUniform4iv(GLint location, GLsizei count, const GLint *value) {}

#undef glUniformMatrix2fv
void glUniformMatrix2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value) {}

#undef glUniformMatrix3fv
void glUniformMatrix3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value) {}

#undef glUniformMatrix4fv
void glUniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value) {}

#undef glValidateProgram
void glValidateProgram(GLuint program) {}

#undef glVertexAttrib1d
void glVertexAttrib1d(GLuint index, GLdouble x) {}

#undef glVertexAttrib1dv
void glVertexAttrib1dv(GLuint index, const GLdouble *v) {}

#undef glVertexAttrib1f
void glVertexAttrib1f(GLuint index, GLfloat x) {}

#undef glVertexAttrib1fv
void glVertexAttrib1fv(GLuint index, const GLfloat *v) {}

#undef glVertexAttrib1s
void glVertexAttrib1s(GLuint index, GLshort x) {}

#undef glVertexAttrib1sv
void glVertexAttrib1sv(GLuint index, const GLshort *v) {}

#undef glVertexAttrib2d
void glVertexAttrib2d(GLuint index, GLdouble x, GLdouble y) {}

#undef glVertexAttrib2dv
void glVertexAttrib2dv(GLuint index, const GLdouble *v) {}

#undef glVertexAttrib2f
void glVertexAttrib2f(GLuint index, GLfloat x, GLfloat y) {}

#undef glVertexAttrib2fv
void glVertexAttrib2fv(GLuint index, const GLfloat *v) {}

#undef glVertexAttrib2s
void glVertexAttrib2s(GLuint index, GLshort x, GLshort y) {}

#undef glVertexAttrib2sv
void glVertexAttrib2sv(GLuint index, const GLshort *v) {}

#undef glVertexAttrib3d
void glVertexAttrib3d(GLuint index, GLdouble x, GLdouble y, GLdouble z) {}

#undef glVertexAttrib3dv
void glVertexAttrib3dv(GLuint index, const GLdouble *v) {}

#undef glVertexAttrib3f
void glVertexAttrib3f(GLuint index, GLfloat x, GLfloat y, GLfloat z) {}

#undef glVertexAttrib3fv
void glVertexAttrib3fv(GLuint index, const GLfloat *v) {}

#undef glVertexAttrib3s
void glVertexAttrib3s(GLuint index, GLshort x, GLshort y, GLshort z) {}

#undef glVertexAttrib3sv
void glVertexAttrib3sv(GLuint index, const GLshort *v) {}

#undef glVertexAttrib4Nbv
void glVertexAttrib4Nbv(GLuint index, const GLbyte *v) {}

#undef glVertexAttrib4Niv
void glVertexAttrib4Niv(GLuint index, const GLint *v) {}

#undef glVertexAttrib4Nsv
void glVertexAttrib4Nsv(GLuint index, const GLshort *v) {}

#undef glVertexAttrib4Nub
void glVertexAttrib4Nub(GLuint index, GLubyte x, GLubyte y, GLubyte z, GLubyte w) {}

#undef glVertexAttrib4Nubv
void glVertexAttrib4Nubv(GLuint index, const GLubyte *v) {}

#undef glVertexAttrib4Nuiv
void glVertexAttrib4Nuiv(GLuint index, const GLuint *v) {}

#undef glVertexAttrib4Nusv
void glVertexAttrib4Nusv(GLuint index, const GLushort *v) {}

#undef glVertexAttrib4bv
void glVertexAttrib4bv(GLuint index, const GLbyte *v) {}

#undef glVertexAttrib4d
void glVertexAttrib4d(GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}

#undef glVertexAttrib4dv
void glVertexAttrib4dv(GLuint index, const GLdouble *v) {}

#undef glVertexAttrib4f
void glVertexAttrib4f(GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}

#undef glVertexAttrib4fv
void glVertexAttrib4fv(GLuint index, const GLfloat *v) {}

#undef glVertexAttrib4iv
void glVertexAttrib4iv(GLuint index, const GLint *v) {}

#undef glVertexAttrib4s
void glVertexAttrib4s(GLuint index, GLshort x, GLshort y, GLshort z, GLshort w) {}

#undef glVertexAttrib4sv
void glVertexAttrib4sv(GLuint index, const GLshort *v) {}

#undef glVertexAttrib4ubv
void glVertexAttrib4ubv(GLuint index, const GLubyte *v) {}

#undef glVertexAttrib4uiv
void glVertexAttrib4uiv(GLuint index, const GLuint *v) {}

#undef glVertexAttrib4usv
void glVertexAttrib4usv(GLuint index, const GLushort *v) {}

#undef glVertexAttribPointer
void glVertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void *pointer) {}

#undef glDrawArraysInstanced
void glDrawArraysInstanced(GLenum mode, GLint first, GLsizei count, GLsizei instancecount) {}

#undef glDrawElementsInstanced
void glDrawElementsInstanced(GLenum mode, GLsizei count, GLenum type, const void *indices, GLsizei instancecount) {}

#undef glTexBuffer
void glTexBuffer(GLenum target, GLenum internalformat, GLuint buffer) {}

#undef glPrimitiveRestartIndex
void glPrimitiveRestartIndex(GLuint index) {}

#undef glCopyBufferSubData
void glCopyBufferSubData(GLenum readTarget, GLenum writeTarget, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size) {}

#undef glGetUniformIndices
void glGetUniformIndices(GLuint program, GLsizei uniformCount, const GLchar *const*uniformNames, GLuint *uniformIndices) {}

#undef glGetActiveUniformsiv
void glGetActiveUniformsiv(GLuint program, GLsizei uniformCount, const GLuint *uniformIndices, GLenum pname, GLint *params) {}

#undef glGetActiveUniformName
void glGetActiveUniformName(GLuint program, GLuint uniformIndex, GLsizei bufSize, GLsizei *length, GLchar *uniformName) {}

#undef glGetUniformBlockIndex
GLuint glGetUniformBlockIndex(GLuint program, const GLchar *uniformBlockName);

#undef glGetActiveUniformBlockiv
void glGetActiveUniformBlockiv(GLuint program, GLuint uniformBlockIndex, GLenum pname, GLint *params) {}

#undef glGetActiveUniformBlockName
void glGetActiveUniformBlockName(GLuint program, GLuint uniformBlockIndex, GLsizei bufSize, GLsizei *length, GLchar *uniformBlockName) {}

#undef glUniformBlockBinding
void glUniformBlockBinding(GLuint program, GLuint uniformBlockIndex, GLuint uniformBlockBinding) {}

#undef glMinSampleShading
void glMinSampleShading(GLfloat value) {}

#undef glBlendEquationi
void glBlendEquationi(GLuint buf, GLenum mode) {}

#undef glBlendEquationSeparatei
void glBlendEquationSeparatei(GLuint buf, GLenum modeRGB, GLenum modeAlpha) {}

#undef glBlendFunci
void glBlendFunci(GLuint buf, GLenum src, GLenum dst) {}

#undef glBlendFuncSeparatei
void glBlendFuncSeparatei(GLuint buf, GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha) {}

#undef glDrawArraysIndirect
void glDrawArraysIndirect(GLenum mode, const void *indirect) {}

#undef glDrawElementsIndirect
void glDrawElementsIndirect(GLenum mode, GLenum type, const void *indirect) {}

#undef glUniform1d
void glUniform1d(GLint location, GLdouble x) {}

#undef glUniform2d
void glUniform2d(GLint location, GLdouble x, GLdouble y) {}

#undef glUniform3d
void glUniform3d(GLint location, GLdouble x, GLdouble y, GLdouble z) {}

#undef glUniform4d
void glUniform4d(GLint location, GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}

#undef glUniform1dv
void glUniform1dv(GLint location, GLsizei count, const GLdouble *value) {}

#undef glUniform2dv
void glUniform2dv(GLint location, GLsizei count, const GLdouble *value) {}

#undef glUniform3dv
void glUniform3dv(GLint location, GLsizei count, const GLdouble *value) {}

#undef glUniform4dv
void glUniform4dv(GLint location, GLsizei count, const GLdouble *value) {}

#undef glUniformMatrix2dv
void glUniformMatrix2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}

#undef glUniformMatrix3dv
void glUniformMatrix3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}

#undef glUniformMatrix4dv
void glUniformMatrix4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}

#undef glUniformMatrix2x3dv
void glUniformMatrix2x3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}

#undef glUniformMatrix2x4dv
void glUniformMatrix2x4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}

#undef glUniformMatrix3x2dv
void glUniformMatrix3x2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}

#undef glUniformMatrix3x4dv
void glUniformMatrix3x4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}

#undef glUniformMatrix4x2dv
void glUniformMatrix4x2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}

#undef glUniformMatrix4x3dv
void glUniformMatrix4x3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}

#undef glGetUniformdv
void glGetUniformdv(GLuint program, GLint location, GLdouble *params) {}

#undef glGetSubroutineUniformLocation
GLint glGetSubroutineUniformLocation(GLuint program, GLenum shadertype, const GLchar *name);

#undef glGetSubroutineIndex
GLuint glGetSubroutineIndex(GLuint program, GLenum shadertype, const GLchar *name);

#undef glGetActiveSubroutineUniformiv
void glGetActiveSubroutineUniformiv(GLuint program, GLenum shadertype, GLuint index, GLenum pname, GLint *values) {}

#undef glGetActiveSubroutineUniformName
void glGetActiveSubroutineUniformName(GLuint program, GLenum shadertype, GLuint index, GLsizei bufSize, GLsizei *length, GLchar *name) {}

#undef glGetActiveSubroutineName
void glGetActiveSubroutineName(GLuint program, GLenum shadertype, GLuint index, GLsizei bufSize, GLsizei *length, GLchar *name) {}

#undef glUniformSubroutinesuiv
void glUniformSubroutinesuiv(GLenum shadertype, GLsizei count, const GLuint *indices) {}

#undef glGetUniformSubroutineuiv
void glGetUniformSubroutineuiv(GLenum shadertype, GLint location, GLuint *params) {}

#undef glGetProgramStageiv
void glGetProgramStageiv(GLuint program, GLenum shadertype, GLenum pname, GLint *values) {}

#undef glPatchParameteri
void glPatchParameteri(GLenum pname, GLint value) {}

#undef glPatchParameterfv
void glPatchParameterfv(GLenum pname, const GLfloat *values) {}

#undef glBindTransformFeedback
void glBindTransformFeedback(GLenum target, GLuint id) {}

#undef glDeleteTransformFeedbacks
void glDeleteTransformFeedbacks(GLsizei n, const GLuint *ids) {}

#undef glGenTransformFeedbacks
void glGenTransformFeedbacks(GLsizei n, GLuint *ids) {}

#undef glIsTransformFeedback
GLboolean glIsTransformFeedback(GLuint id);

#undef glPauseTransformFeedback
void glPauseTransformFeedback(void) {}

#undef glResumeTransformFeedback
void glResumeTransformFeedback(void) {}

#undef glDrawTransformFeedback
void glDrawTransformFeedback(GLenum mode, GLuint id) {}

#undef glDrawTransformFeedbackStream
void glDrawTransformFeedbackStream(GLenum mode, GLuint id, GLuint stream) {}

#undef glBeginQueryIndexed
void glBeginQueryIndexed(GLenum target, GLuint index, GLuint id) {}

#undef glEndQueryIndexed
void glEndQueryIndexed(GLenum target, GLuint index) {}

#undef glGetQueryIndexediv
void glGetQueryIndexediv(GLenum target, GLuint index, GLenum pname, GLint *params) {}

#undef glClearBufferData
void glClearBufferData(GLenum target, GLenum internalformat, GLenum format, GLenum type, const void *data) {}

#undef glClearBufferSubData
void glClearBufferSubData(GLenum target, GLenum internalformat, GLintptr offset, GLsizeiptr size, GLenum format, GLenum type, const void *data) {}

#undef glDispatchCompute
void glDispatchCompute(GLuint num_groups_x, GLuint num_groups_y, GLuint num_groups_z) {}

#undef glDispatchComputeIndirect
void glDispatchComputeIndirect(GLintptr indirect) {}

#undef glCopyImageSubData
void glCopyImageSubData(GLuint srcName, GLenum srcTarget, GLint srcLevel, GLint srcX, GLint srcY, GLint srcZ, GLuint dstName, GLenum dstTarget, GLint dstLevel, GLint dstX, GLint dstY, GLint dstZ, GLsizei srcWidth, GLsizei srcHeight, GLsizei srcDepth) {}

#undef glFramebufferParameteri
void glFramebufferParameteri(GLenum target, GLenum pname, GLint param) {}

#undef glGetFramebufferParameteriv
void glGetFramebufferParameteriv(GLenum target, GLenum pname, GLint *params) {}

#undef glGetInternalformati64v
void glGetInternalformati64v(GLenum target, GLenum internalformat, GLenum pname, GLsizei count, GLint64 *params) {}

#undef glInvalidateTexSubImage
void glInvalidateTexSubImage(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth) {}

#undef glInvalidateTexImage
void glInvalidateTexImage(GLuint texture, GLint level) {}

#undef glInvalidateBufferSubData
void glInvalidateBufferSubData(GLuint buffer, GLintptr offset, GLsizeiptr length) {}

#undef glInvalidateBufferData
void glInvalidateBufferData(GLuint buffer) {}

#undef glInvalidateFramebuffer
void glInvalidateFramebuffer(GLenum target, GLsizei numAttachments, const GLenum *attachments) {}

#undef glInvalidateSubFramebuffer
void glInvalidateSubFramebuffer(GLenum target, GLsizei numAttachments, const GLenum *attachments, GLint x, GLint y, GLsizei width, GLsizei height) {}

#undef glMultiDrawArraysIndirect
void glMultiDrawArraysIndirect(GLenum mode, const void *indirect, GLsizei drawcount, GLsizei stride) {}

#undef glMultiDrawElementsIndirect
void glMultiDrawElementsIndirect(GLenum mode, GLenum type, const void *indirect, GLsizei drawcount, GLsizei stride) {}

#undef glGetProgramInterfaceiv
void glGetProgramInterfaceiv(GLuint program, GLenum programInterface, GLenum pname, GLint *params) {}

#undef glGetProgramResourceIndex
GLuint glGetProgramResourceIndex(GLuint program, GLenum programInterface, const GLchar *name);

#undef glGetProgramResourceName
void glGetProgramResourceName(GLuint program, GLenum programInterface, GLuint index, GLsizei bufSize, GLsizei *length, GLchar *name) {}

#undef glGetProgramResourceiv
void glGetProgramResourceiv(GLuint program, GLenum programInterface, GLuint index, GLsizei propCount, const GLenum *props, GLsizei count, GLsizei *length, GLint *params) {}

#undef glGetProgramResourceLocation
GLint glGetProgramResourceLocation(GLuint program, GLenum programInterface, const GLchar *name);

#undef glGetProgramResourceLocationIndex
GLint glGetProgramResourceLocationIndex(GLuint program, GLenum programInterface, const GLchar *name);

#undef glShaderStorageBlockBinding
void glShaderStorageBlockBinding(GLuint program, GLuint storageBlockIndex, GLuint storageBlockBinding) {}

#undef glTexBufferRange
void glTexBufferRange(GLenum target, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size) {}

#undef glTexStorage2DMultisample
void glTexStorage2DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations) {}

#undef glTexStorage3DMultisample
void glTexStorage3DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations) {}

#undef glTextureView
void glTextureView(GLuint texture, GLenum target, GLuint origtexture, GLenum internalformat, GLuint minlevel, GLuint numlevels, GLuint minlayer, GLuint numlayers) {}

#undef glBindVertexBuffer
void glBindVertexBuffer(GLuint bindingindex, GLuint buffer, GLintptr offset, GLsizei stride) {}

#undef glVertexAttribFormat
void glVertexAttribFormat(GLuint attribindex, GLint size, GLenum type, GLboolean normalized, GLuint relativeoffset) {}

#undef glVertexAttribIFormat
void glVertexAttribIFormat(GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset) {}

#undef glVertexAttribLFormat
void glVertexAttribLFormat(GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset) {}

#undef glVertexAttribBinding
void glVertexAttribBinding(GLuint attribindex, GLuint bindingindex) {}

#undef glVertexBindingDivisor
void glVertexBindingDivisor(GLuint bindingindex, GLuint divisor) {}

#undef glDebugMessageControl
void glDebugMessageControl(GLenum source, GLenum type, GLenum severity, GLsizei count, const GLuint *ids, GLboolean enabled) {}

#undef glDebugMessageInsert
void glDebugMessageInsert(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar *buf) {}

#undef glDebugMessageCallback
void glDebugMessageCallback(GLDEBUGPROC callback, const void *userParam) {}

#undef glGetDebugMessageLog
GLuint glGetDebugMessageLog(GLuint count, GLsizei bufSize, GLenum *sources, GLenum *types, GLuint *ids, GLenum *severities, GLsizei *lengths, GLchar *messageLog);

#undef glPushDebugGroup
void glPushDebugGroup(GLenum source, GLuint id, GLsizei length, const GLchar *message) {}

#undef glPopDebugGroup
void glPopDebugGroup(void) {}

#undef glObjectLabel
void glObjectLabel(GLenum identifier, GLuint name, GLsizei length, const GLchar *label) {}

#undef glGetObjectLabel
void glGetObjectLabel(GLenum identifier, GLuint name, GLsizei bufSize, GLsizei *length, GLchar *label) {}

#undef glObjectPtrLabel
void glObjectPtrLabel(const void *ptr, GLsizei length, const GLchar *label) {}

#undef glGetObjectPtrLabel
void glGetObjectPtrLabel(const void *ptr, GLsizei bufSize, GLsizei *length, GLchar *label) {}

#undef glSpecializeShader
void glSpecializeShader(GLuint shader, const GLchar *pEntryPoint, GLuint numSpecializationConstants, const GLuint *pConstantIndex, const GLuint *pConstantValue) {}

#undef glMultiDrawArraysIndirectCount
void glMultiDrawArraysIndirectCount(GLenum mode, const void *indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride) {}

#undef glMultiDrawElementsIndirectCount
void glMultiDrawElementsIndirectCount(GLenum mode, GLenum type, const void *indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride) {}

#undef glPolygonOffsetClamp
void glPolygonOffsetClamp(GLfloat factor, GLfloat units, GLfloat clamp) {}

#ifdef __cplusplus
}
#endif