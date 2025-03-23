void glCullFace(GLenum mode) {}
void glFrontFace(GLenum mode) {}
void glHint(GLenum target, GLenum mode) {}
void glLineWidth(GLfloat width) {}
void glPointSize(GLfloat size) {}
void glPolygonMode(GLenum face, GLenum mode) {}
void glScissor(GLint x, GLint y, GLsizei width, GLsizei height) {}
void glTexParameterf(GLenum target, GLenum pname, GLfloat param) {}
void glTexParameterfv(GLenum target, GLenum pname, const GLfloat *params) {}
void glTexParameteri(GLenum target, GLenum pname, GLint param) {}
void glTexParameteriv(GLenum target, GLenum pname, const GLint *params) {}
void glTexImage1D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLint border, GLenum format, GLenum type, const void *pixels) {}
void glTexImage2D(GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const void *pixels) {}
void glDrawBuffer(GLenum buf) {}
void glClear(GLbitfield mask) {}
void glClearColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {}
void glClearStencil(GLint s) {}
void glClearDepth(GLdouble depth) {}
void glStencilMask(GLuint mask) {}
void glColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha) {}
void glDepthMask(GLboolean flag) {}
void glDisable(GLenum cap) {}
void glEnable(GLenum cap) {}
void glFinish(void) {}
void glFlush(void) {}
void glBlendFunc(GLenum sfactor, GLenum dfactor) {}
void glLogicOp(GLenum opcode) {}
void glStencilFunc(GLenum func, GLint ref, GLuint mask) {}
void glStencilOp(GLenum fail, GLenum zfail, GLenum zpass) {}
void glDepthFunc(GLenum func) {}
void glPixelStoref(GLenum pname, GLfloat param) {}
void glPixelStorei(GLenum pname, GLint param) {}
void glReadBuffer(GLenum src) {}
void glReadPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum format, GLenum type, void *pixels) {}
void glGetBooleanv(GLenum pname, GLboolean *data) {}
void glGetDoublev(GLenum pname, GLdouble *data) {}
GLenum glGetError(void);
void glGetFloatv(GLenum pname, GLfloat *data) {}
void glGetIntegerv(GLenum pname, GLint *data) {}
const GLubyte * glGetString(GLenum name);
void glGetTexImage(GLenum target, GLint level, GLenum format, GLenum type, void *pixels) {}
void glGetTexParameterfv(GLenum target, GLenum pname, GLfloat *params) {}
void glGetTexParameteriv(GLenum target, GLenum pname, GLint *params) {}
void glGetTexLevelParameterfv(GLenum target, GLint level, GLenum pname, GLfloat *params) {}
void glGetTexLevelParameteriv(GLenum target, GLint level, GLenum pname, GLint *params) {}
GLboolean glIsEnabled(GLenum cap);
void glDepthRange(GLdouble n, GLdouble f) {}
void glViewport(GLint x, GLint y, GLsizei width, GLsizei height) {}
void glNewList(GLuint list, GLenum mode) {}
void glEndList(void) {}
void glCallList(GLuint list) {}
void glCallLists(GLsizei n, GLenum type, const void *lists) {}
void glDeleteLists(GLuint list, GLsizei range) {}
GLuint glGenLists(GLsizei range);
void glListBase(GLuint base) {}
void glBegin(GLenum mode) {}
void glBitmap(GLsizei width, GLsizei height, GLfloat xorig, GLfloat yorig, GLfloat xmove, GLfloat ymove, const GLubyte *bitmap) {}
void glColor3b(GLbyte red, GLbyte green, GLbyte blue) {}
void glColor3bv(const GLbyte *v) {}
void glColor3d(GLdouble red, GLdouble green, GLdouble blue) {}
void glColor3dv(const GLdouble *v) {}
void glColor3f(GLfloat red, GLfloat green, GLfloat blue) {}
void glColor3fv(const GLfloat *v) {}
void glColor3i(GLint red, GLint green, GLint blue) {}
void glColor3iv(const GLint *v) {}
void glColor3s(GLshort red, GLshort green, GLshort blue) {}
void glColor3sv(const GLshort *v) {}
void glColor3ub(GLubyte red, GLubyte green, GLubyte blue) {}
void glColor3ubv(const GLubyte *v) {}
void glColor3ui(GLuint red, GLuint green, GLuint blue) {}
void glColor3uiv(const GLuint *v) {}
void glColor3us(GLushort red, GLushort green, GLushort blue) {}
void glColor3usv(const GLushort *v) {}
void glColor4b(GLbyte red, GLbyte green, GLbyte blue, GLbyte alpha) {}
void glColor4bv(const GLbyte *v) {}
void glColor4d(GLdouble red, GLdouble green, GLdouble blue, GLdouble alpha) {}
void glColor4dv(const GLdouble *v) {}
void glColor4f(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {}
void glColor4fv(const GLfloat *v) {}
void glColor4i(GLint red, GLint green, GLint blue, GLint alpha) {}
void glColor4iv(const GLint *v) {}
void glColor4s(GLshort red, GLshort green, GLshort blue, GLshort alpha) {}
void glColor4sv(const GLshort *v) {}
void glColor4ub(GLubyte red, GLubyte green, GLubyte blue, GLubyte alpha) {}
void glColor4ubv(const GLubyte *v) {}
void glColor4ui(GLuint red, GLuint green, GLuint blue, GLuint alpha) {}
void glColor4uiv(const GLuint *v) {}
void glColor4us(GLushort red, GLushort green, GLushort blue, GLushort alpha) {}
void glColor4usv(const GLushort *v) {}
void glEdgeFlag(GLboolean flag) {}
void glEdgeFlagv(const GLboolean *flag) {}
void glEnd(void) {}
void glIndexd(GLdouble c) {}
void glIndexdv(const GLdouble *c) {}
void glIndexf(GLfloat c) {}
void glIndexfv(const GLfloat *c) {}
void glIndexi(GLint c) {}
void glIndexiv(const GLint *c) {}
void glIndexs(GLshort c) {}
void glIndexsv(const GLshort *c) {}
void glNormal3b(GLbyte nx, GLbyte ny, GLbyte nz) {}
void glNormal3bv(const GLbyte *v) {}
void glNormal3d(GLdouble nx, GLdouble ny, GLdouble nz) {}
void glNormal3dv(const GLdouble *v) {}
void glNormal3f(GLfloat nx, GLfloat ny, GLfloat nz) {}
void glNormal3fv(const GLfloat *v) {}
void glNormal3i(GLint nx, GLint ny, GLint nz) {}
void glNormal3iv(const GLint *v) {}
void glNormal3s(GLshort nx, GLshort ny, GLshort nz) {}
void glNormal3sv(const GLshort *v) {}
void glRasterPos2d(GLdouble x, GLdouble y) {}
void glRasterPos2dv(const GLdouble *v) {}
void glRasterPos2f(GLfloat x, GLfloat y) {}
void glRasterPos2fv(const GLfloat *v) {}
void glRasterPos2i(GLint x, GLint y) {}
void glRasterPos2iv(const GLint *v) {}
void glRasterPos2s(GLshort x, GLshort y) {}
void glRasterPos2sv(const GLshort *v) {}
void glRasterPos3d(GLdouble x, GLdouble y, GLdouble z) {}
void glRasterPos3dv(const GLdouble *v) {}
void glRasterPos3f(GLfloat x, GLfloat y, GLfloat z) {}
void glRasterPos3fv(const GLfloat *v) {}
void glRasterPos3i(GLint x, GLint y, GLint z) {}
void glRasterPos3iv(const GLint *v) {}
void glRasterPos3s(GLshort x, GLshort y, GLshort z) {}
void glRasterPos3sv(const GLshort *v) {}
void glRasterPos4d(GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}
void glRasterPos4dv(const GLdouble *v) {}
void glRasterPos4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}
void glRasterPos4fv(const GLfloat *v) {}
void glRasterPos4i(GLint x, GLint y, GLint z, GLint w) {}
void glRasterPos4iv(const GLint *v) {}
void glRasterPos4s(GLshort x, GLshort y, GLshort z, GLshort w) {}
void glRasterPos4sv(const GLshort *v) {}
void glRectd(GLdouble x1, GLdouble y1, GLdouble x2, GLdouble y2) {}
void glRectdv(const GLdouble *v1, const GLdouble *v2) {}
void glRectf(GLfloat x1, GLfloat y1, GLfloat x2, GLfloat y2) {}
void glRectfv(const GLfloat *v1, const GLfloat *v2) {}
void glRecti(GLint x1, GLint y1, GLint x2, GLint y2) {}
void glRectiv(const GLint *v1, const GLint *v2) {}
void glRects(GLshort x1, GLshort y1, GLshort x2, GLshort y2) {}
void glRectsv(const GLshort *v1, const GLshort *v2) {}
void glTexCoord1d(GLdouble s) {}
void glTexCoord1dv(const GLdouble *v) {}
void glTexCoord1f(GLfloat s) {}
void glTexCoord1fv(const GLfloat *v) {}
void glTexCoord1i(GLint s) {}
void glTexCoord1iv(const GLint *v) {}
void glTexCoord1s(GLshort s) {}
void glTexCoord1sv(const GLshort *v) {}
void glTexCoord2d(GLdouble s, GLdouble t) {}
void glTexCoord2dv(const GLdouble *v) {}
void glTexCoord2f(GLfloat s, GLfloat t) {}
void glTexCoord2fv(const GLfloat *v) {}
void glTexCoord2i(GLint s, GLint t) {}
void glTexCoord2iv(const GLint *v) {}
void glTexCoord2s(GLshort s, GLshort t) {}
void glTexCoord2sv(const GLshort *v) {}
void glTexCoord3d(GLdouble s, GLdouble t, GLdouble r) {}
void glTexCoord3dv(const GLdouble *v) {}
void glTexCoord3f(GLfloat s, GLfloat t, GLfloat r) {}
void glTexCoord3fv(const GLfloat *v) {}
void glTexCoord3i(GLint s, GLint t, GLint r) {}
void glTexCoord3iv(const GLint *v) {}
void glTexCoord3s(GLshort s, GLshort t, GLshort r) {}
void glTexCoord3sv(const GLshort *v) {}
void glTexCoord4d(GLdouble s, GLdouble t, GLdouble r, GLdouble q) {}
void glTexCoord4dv(const GLdouble *v) {}
void glTexCoord4f(GLfloat s, GLfloat t, GLfloat r, GLfloat q) {}
void glTexCoord4fv(const GLfloat *v) {}
void glTexCoord4i(GLint s, GLint t, GLint r, GLint q) {}
void glTexCoord4iv(const GLint *v) {}
void glTexCoord4s(GLshort s, GLshort t, GLshort r, GLshort q) {}
void glTexCoord4sv(const GLshort *v) {}
void glVertex2d(GLdouble x, GLdouble y) {}
void glVertex2dv(const GLdouble *v) {}
void glVertex2f(GLfloat x, GLfloat y) {}
void glVertex2fv(const GLfloat *v) {}
void glVertex2i(GLint x, GLint y) {}
void glVertex2iv(const GLint *v) {}
void glVertex2s(GLshort x, GLshort y) {}
void glVertex2sv(const GLshort *v) {}
void glVertex3d(GLdouble x, GLdouble y, GLdouble z) {}
void glVertex3dv(const GLdouble *v) {}
void glVertex3f(GLfloat x, GLfloat y, GLfloat z) {}
void glVertex3fv(const GLfloat *v) {}
void glVertex3i(GLint x, GLint y, GLint z) {}
void glVertex3iv(const GLint *v) {}
void glVertex3s(GLshort x, GLshort y, GLshort z) {}
void glVertex3sv(const GLshort *v) {}
void glVertex4d(GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}
void glVertex4dv(const GLdouble *v) {}
void glVertex4f(GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}
void glVertex4fv(const GLfloat *v) {}
void glVertex4i(GLint x, GLint y, GLint z, GLint w) {}
void glVertex4iv(const GLint *v) {}
void glVertex4s(GLshort x, GLshort y, GLshort z, GLshort w) {}
void glVertex4sv(const GLshort *v) {}
void glClipPlane(GLenum plane, const GLdouble *equation) {}
void glColorMaterial(GLenum face, GLenum mode) {}
void glFogf(GLenum pname, GLfloat param) {}
void glFogfv(GLenum pname, const GLfloat *params) {}
void glFogi(GLenum pname, GLint param) {}
void glFogiv(GLenum pname, const GLint *params) {}
void glLightf(GLenum light, GLenum pname, GLfloat param) {}
void glLightfv(GLenum light, GLenum pname, const GLfloat *params) {}
void glLighti(GLenum light, GLenum pname, GLint param) {}
void glLightiv(GLenum light, GLenum pname, const GLint *params) {}
void glLightModelf(GLenum pname, GLfloat param) {}
void glLightModelfv(GLenum pname, const GLfloat *params) {}
void glLightModeli(GLenum pname, GLint param) {}
void glLightModeliv(GLenum pname, const GLint *params) {}
void glLineStipple(GLint factor, GLushort pattern) {}
void glMaterialf(GLenum face, GLenum pname, GLfloat param) {}
void glMaterialfv(GLenum face, GLenum pname, const GLfloat *params) {}
void glMateriali(GLenum face, GLenum pname, GLint param) {}
void glMaterialiv(GLenum face, GLenum pname, const GLint *params) {}
void glPolygonStipple(const GLubyte *mask) {}
void glShadeModel(GLenum mode) {}
void glTexEnvf(GLenum target, GLenum pname, GLfloat param) {}
void glTexEnvfv(GLenum target, GLenum pname, const GLfloat *params) {}
void glTexEnvi(GLenum target, GLenum pname, GLint param) {}
void glTexEnviv(GLenum target, GLenum pname, const GLint *params) {}
void glTexGend(GLenum coord, GLenum pname, GLdouble param) {}
void glTexGendv(GLenum coord, GLenum pname, const GLdouble *params) {}
void glTexGenf(GLenum coord, GLenum pname, GLfloat param) {}
void glTexGenfv(GLenum coord, GLenum pname, const GLfloat *params) {}
void glTexGeni(GLenum coord, GLenum pname, GLint param) {}
void glTexGeniv(GLenum coord, GLenum pname, const GLint *params) {}
void glFeedbackBuffer(GLsizei size, GLenum type, GLfloat *buffer) {}
void glSelectBuffer(GLsizei size, GLuint *buffer) {}
GLint glRenderMode(GLenum mode);
void glInitNames(void) {}
void glLoadName(GLuint name) {}
void glPassThrough(GLfloat token) {}
void glPopName(void) {}
void glPushName(GLuint name) {}
void glClearAccum(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha) {}
void glClearIndex(GLfloat c) {}
void glIndexMask(GLuint mask) {}
void glAccum(GLenum op, GLfloat value) {}
void glPopAttrib(void) {}
void glPushAttrib(GLbitfield mask) {}
void glMap1d(GLenum target, GLdouble u1, GLdouble u2, GLint stride, GLint order, const GLdouble *points) {}
void glMap1f(GLenum target, GLfloat u1, GLfloat u2, GLint stride, GLint order, const GLfloat *points) {}
void glMap2d(GLenum target, GLdouble u1, GLdouble u2, GLint ustride, GLint uorder, GLdouble v1, GLdouble v2, GLint vstride, GLint vorder, const GLdouble *points) {}
void glMap2f(GLenum target, GLfloat u1, GLfloat u2, GLint ustride, GLint uorder, GLfloat v1, GLfloat v2, GLint vstride, GLint vorder, const GLfloat *points) {}
void glMapGrid1d(GLint un, GLdouble u1, GLdouble u2) {}
void glMapGrid1f(GLint un, GLfloat u1, GLfloat u2) {}
void glMapGrid2d(GLint un, GLdouble u1, GLdouble u2, GLint vn, GLdouble v1, GLdouble v2) {}
void glMapGrid2f(GLint un, GLfloat u1, GLfloat u2, GLint vn, GLfloat v1, GLfloat v2) {}
void glEvalCoord1d(GLdouble u) {}
void glEvalCoord1dv(const GLdouble *u) {}
void glEvalCoord1f(GLfloat u) {}
void glEvalCoord1fv(const GLfloat *u) {}
void glEvalCoord2d(GLdouble u, GLdouble v) {}
void glEvalCoord2dv(const GLdouble *u) {}
void glEvalCoord2f(GLfloat u, GLfloat v) {}
void glEvalCoord2fv(const GLfloat *u) {}
void glEvalMesh1(GLenum mode, GLint i1, GLint i2) {}
void glEvalPoint1(GLint i) {}
void glEvalMesh2(GLenum mode, GLint i1, GLint i2, GLint j1, GLint j2) {}
void glEvalPoint2(GLint i, GLint j) {}
void glAlphaFunc(GLenum func, GLfloat ref) {}
void glPixelZoom(GLfloat xfactor, GLfloat yfactor) {}
void glPixelTransferf(GLenum pname, GLfloat param) {}
void glPixelTransferi(GLenum pname, GLint param) {}
void glPixelMapfv(GLenum map, GLsizei mapsize, const GLfloat *values) {}
void glPixelMapuiv(GLenum map, GLsizei mapsize, const GLuint *values) {}
void glPixelMapusv(GLenum map, GLsizei mapsize, const GLushort *values) {}
void glCopyPixels(GLint x, GLint y, GLsizei width, GLsizei height, GLenum type) {}
void glDrawPixels(GLsizei width, GLsizei height, GLenum format, GLenum type, const void *pixels) {}
void glGetClipPlane(GLenum plane, GLdouble *equation) {}
void glGetLightfv(GLenum light, GLenum pname, GLfloat *params) {}
void glGetLightiv(GLenum light, GLenum pname, GLint *params) {}
void glGetMapdv(GLenum target, GLenum query, GLdouble *v) {}
void glGetMapfv(GLenum target, GLenum query, GLfloat *v) {}
void glGetMapiv(GLenum target, GLenum query, GLint *v) {}
void glGetMaterialfv(GLenum face, GLenum pname, GLfloat *params) {}
void glGetMaterialiv(GLenum face, GLenum pname, GLint *params) {}
void glGetPixelMapfv(GLenum map, GLfloat *values) {}
void glGetPixelMapuiv(GLenum map, GLuint *values) {}
void glGetPixelMapusv(GLenum map, GLushort *values) {}
void glGetPolygonStipple(GLubyte *mask) {}
void glGetTexEnvfv(GLenum target, GLenum pname, GLfloat *params) {}
void glGetTexEnviv(GLenum target, GLenum pname, GLint *params) {}
void glGetTexGendv(GLenum coord, GLenum pname, GLdouble *params) {}
void glGetTexGenfv(GLenum coord, GLenum pname, GLfloat *params) {}
void glGetTexGeniv(GLenum coord, GLenum pname, GLint *params) {}
GLboolean glIsList(GLuint list);
void glFrustum(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar) {}
void glLoadIdentity(void) {}
void glLoadMatrixf(const GLfloat *m) {}
void glLoadMatrixd(const GLdouble *m) {}
void glMatrixMode(GLenum mode) {}
void glMultMatrixf(const GLfloat *m) {}
void glMultMatrixd(const GLdouble *m) {}
void glOrtho(GLdouble left, GLdouble right, GLdouble bottom, GLdouble top, GLdouble zNear, GLdouble zFar) {}
void glPopMatrix(void) {}
void glPushMatrix(void) {}
void glRotated(GLdouble angle, GLdouble x, GLdouble y, GLdouble z) {}
void glRotatef(GLfloat angle, GLfloat x, GLfloat y, GLfloat z) {}
void glScaled(GLdouble x, GLdouble y, GLdouble z) {}
void glScalef(GLfloat x, GLfloat y, GLfloat z) {}
void glTranslated(GLdouble x, GLdouble y, GLdouble z) {}
void glTranslatef(GLfloat x, GLfloat y, GLfloat z) {}
void glActiveTexture(GLenum texture) {}
void glSampleCoverage(GLfloat value, GLboolean invert) {}
void glCompressedTexImage3D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLsizei imageSize, const void *data) {}
void glCompressedTexImage2D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLsizei height, GLint border, GLsizei imageSize, const void *data) {}
void glCompressedTexImage1D(GLenum target, GLint level, GLenum internalformat, GLsizei width, GLint border, GLsizei imageSize, const void *data) {}
void glCompressedTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLsizei imageSize, const void *data) {}
void glCompressedTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLsizei imageSize, const void *data) {}
void glCompressedTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLsizei imageSize, const void *data) {}
void glGetCompressedTexImage(GLenum target, GLint level, void *img) {}
void glClientActiveTexture(GLenum texture) {}
void glMultiTexCoord1d(GLenum target, GLdouble s) {}
void glMultiTexCoord1dv(GLenum target, const GLdouble *v) {}
void glMultiTexCoord1f(GLenum target, GLfloat s) {}
void glMultiTexCoord1fv(GLenum target, const GLfloat *v) {}
void glMultiTexCoord1i(GLenum target, GLint s) {}
void glMultiTexCoord1iv(GLenum target, const GLint *v) {}
void glMultiTexCoord1s(GLenum target, GLshort s) {}
void glMultiTexCoord1sv(GLenum target, const GLshort *v) {}
void glMultiTexCoord2d(GLenum target, GLdouble s, GLdouble t) {}
void glMultiTexCoord2dv(GLenum target, const GLdouble *v) {}
void glMultiTexCoord2f(GLenum target, GLfloat s, GLfloat t) {}
void glMultiTexCoord2fv(GLenum target, const GLfloat *v) {}
void glMultiTexCoord2i(GLenum target, GLint s, GLint t) {}
void glMultiTexCoord2iv(GLenum target, const GLint *v) {}
void glMultiTexCoord2s(GLenum target, GLshort s, GLshort t) {}
void glMultiTexCoord2sv(GLenum target, const GLshort *v) {}
void glMultiTexCoord3d(GLenum target, GLdouble s, GLdouble t, GLdouble r) {}
void glMultiTexCoord3dv(GLenum target, const GLdouble *v) {}
void glMultiTexCoord3f(GLenum target, GLfloat s, GLfloat t, GLfloat r) {}
void glMultiTexCoord3fv(GLenum target, const GLfloat *v) {}
void glMultiTexCoord3i(GLenum target, GLint s, GLint t, GLint r) {}
void glMultiTexCoord3iv(GLenum target, const GLint *v) {}
void glMultiTexCoord3s(GLenum target, GLshort s, GLshort t, GLshort r) {}
void glMultiTexCoord3sv(GLenum target, const GLshort *v) {}
void glMultiTexCoord4d(GLenum target, GLdouble s, GLdouble t, GLdouble r, GLdouble q) {}
void glMultiTexCoord4dv(GLenum target, const GLdouble *v) {}
void glMultiTexCoord4f(GLenum target, GLfloat s, GLfloat t, GLfloat r, GLfloat q) {}
void glMultiTexCoord4fv(GLenum target, const GLfloat *v) {}
void glMultiTexCoord4i(GLenum target, GLint s, GLint t, GLint r, GLint q) {}
void glMultiTexCoord4iv(GLenum target, const GLint *v) {}
void glMultiTexCoord4s(GLenum target, GLshort s, GLshort t, GLshort r, GLshort q) {}
void glMultiTexCoord4sv(GLenum target, const GLshort *v) {}
void glLoadTransposeMatrixf(const GLfloat *m) {}
void glLoadTransposeMatrixd(const GLdouble *m) {}
void glMultTransposeMatrixf(const GLfloat *m) {}
void glMultTransposeMatrixd(const GLdouble *m) {}
void glBlendEquationSeparate(GLenum modeRGB, GLenum modeAlpha) {}
void glDrawBuffers(GLsizei n, const GLenum *bufs) {}
void glStencilOpSeparate(GLenum face, GLenum sfail, GLenum dpfail, GLenum dppass) {}
void glStencilFuncSeparate(GLenum face, GLenum func, GLint ref, GLuint mask) {}
void glStencilMaskSeparate(GLenum face, GLuint mask) {}
void glAttachShader(GLuint program, GLuint shader) {}
void glBindAttribLocation(GLuint program, GLuint index, const GLchar *name) {}
void glCompileShader(GLuint shader) {}
GLuint glCreateProgram(void);
GLuint glCreateShader(GLenum type);
void glDeleteProgram(GLuint program) {}
void glDeleteShader(GLuint shader) {}
void glDetachShader(GLuint program, GLuint shader) {}
void glDisableVertexAttribArray(GLuint index) {}
void glEnableVertexAttribArray(GLuint index) {}
void glGetActiveAttrib(GLuint program, GLuint index, GLsizei bufSize, GLsizei *length, GLint *size, GLenum *type, GLchar *name) {}
void glGetActiveUniform(GLuint program, GLuint index, GLsizei bufSize, GLsizei *length, GLint *size, GLenum *type, GLchar *name) {}
void glGetAttachedShaders(GLuint program, GLsizei maxCount, GLsizei *count, GLuint *shaders) {}
GLint glGetAttribLocation(GLuint program, const GLchar *name);
void glGetProgramiv(GLuint program, GLenum pname, GLint *params) {}
void glGetProgramInfoLog(GLuint program, GLsizei bufSize, GLsizei *length, GLchar *infoLog) {}
void glGetShaderiv(GLuint shader, GLenum pname, GLint *params) {}
void glGetShaderInfoLog(GLuint shader, GLsizei bufSize, GLsizei *length, GLchar *infoLog) {}
void glGetShaderSource(GLuint shader, GLsizei bufSize, GLsizei *length, GLchar *source) {}
GLint glGetUniformLocation(GLuint program, const GLchar *name);
void glGetUniformfv(GLuint program, GLint location, GLfloat *params) {}
void glGetUniformiv(GLuint program, GLint location, GLint *params) {}
void glGetVertexAttribdv(GLuint index, GLenum pname, GLdouble *params) {}
void glGetVertexAttribfv(GLuint index, GLenum pname, GLfloat *params) {}
void glGetVertexAttribiv(GLuint index, GLenum pname, GLint *params) {}
void glGetVertexAttribPointerv(GLuint index, GLenum pname, void **pointer) {}
GLboolean glIsProgram(GLuint program);
GLboolean glIsShader(GLuint shader);
void glLinkProgram(GLuint program) {}
void glShaderSource(GLuint shader, GLsizei count, const GLchar *const*string, const GLint *length) {}
void glUseProgram(GLuint program) {}
void glUniform1f(GLint location, GLfloat v0) {}
void glUniform2f(GLint location, GLfloat v0, GLfloat v1) {}
void glUniform3f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2) {}
void glUniform4f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3) {}
void glUniform1i(GLint location, GLint v0) {}
void glUniform2i(GLint location, GLint v0, GLint v1) {}
void glUniform3i(GLint location, GLint v0, GLint v1, GLint v2) {}
void glUniform4i(GLint location, GLint v0, GLint v1, GLint v2, GLint v3) {}
void glUniform1fv(GLint location, GLsizei count, const GLfloat *value) {}
void glUniform2fv(GLint location, GLsizei count, const GLfloat *value) {}
void glUniform3fv(GLint location, GLsizei count, const GLfloat *value) {}
void glUniform4fv(GLint location, GLsizei count, const GLfloat *value) {}
void glUniform1iv(GLint location, GLsizei count, const GLint *value) {}
void glUniform2iv(GLint location, GLsizei count, const GLint *value) {}
void glUniform3iv(GLint location, GLsizei count, const GLint *value) {}
void glUniform4iv(GLint location, GLsizei count, const GLint *value) {}
void glUniformMatrix2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value) {}
void glUniformMatrix3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value) {}
void glUniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value) {}
void glValidateProgram(GLuint program) {}
void glVertexAttrib1d(GLuint index, GLdouble x) {}
void glVertexAttrib1dv(GLuint index, const GLdouble *v) {}
void glVertexAttrib1f(GLuint index, GLfloat x) {}
void glVertexAttrib1fv(GLuint index, const GLfloat *v) {}
void glVertexAttrib1s(GLuint index, GLshort x) {}
void glVertexAttrib1sv(GLuint index, const GLshort *v) {}
void glVertexAttrib2d(GLuint index, GLdouble x, GLdouble y) {}
void glVertexAttrib2dv(GLuint index, const GLdouble *v) {}
void glVertexAttrib2f(GLuint index, GLfloat x, GLfloat y) {}
void glVertexAttrib2fv(GLuint index, const GLfloat *v) {}
void glVertexAttrib2s(GLuint index, GLshort x, GLshort y) {}
void glVertexAttrib2sv(GLuint index, const GLshort *v) {}
void glVertexAttrib3d(GLuint index, GLdouble x, GLdouble y, GLdouble z) {}
void glVertexAttrib3dv(GLuint index, const GLdouble *v) {}
void glVertexAttrib3f(GLuint index, GLfloat x, GLfloat y, GLfloat z) {}
void glVertexAttrib3fv(GLuint index, const GLfloat *v) {}
void glVertexAttrib3s(GLuint index, GLshort x, GLshort y, GLshort z) {}
void glVertexAttrib3sv(GLuint index, const GLshort *v) {}
void glVertexAttrib4Nbv(GLuint index, const GLbyte *v) {}
void glVertexAttrib4Niv(GLuint index, const GLint *v) {}
void glVertexAttrib4Nsv(GLuint index, const GLshort *v) {}
void glVertexAttrib4Nub(GLuint index, GLubyte x, GLubyte y, GLubyte z, GLubyte w) {}
void glVertexAttrib4Nubv(GLuint index, const GLubyte *v) {}
void glVertexAttrib4Nuiv(GLuint index, const GLuint *v) {}
void glVertexAttrib4Nusv(GLuint index, const GLushort *v) {}
void glVertexAttrib4bv(GLuint index, const GLbyte *v) {}
void glVertexAttrib4d(GLuint index, GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}
void glVertexAttrib4dv(GLuint index, const GLdouble *v) {}
void glVertexAttrib4f(GLuint index, GLfloat x, GLfloat y, GLfloat z, GLfloat w) {}
void glVertexAttrib4fv(GLuint index, const GLfloat *v) {}
void glVertexAttrib4iv(GLuint index, const GLint *v) {}
void glVertexAttrib4s(GLuint index, GLshort x, GLshort y, GLshort z, GLshort w) {}
void glVertexAttrib4sv(GLuint index, const GLshort *v) {}
void glVertexAttrib4ubv(GLuint index, const GLubyte *v) {}
void glVertexAttrib4uiv(GLuint index, const GLuint *v) {}
void glVertexAttrib4usv(GLuint index, const GLushort *v) {}
void glVertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void *pointer) {}
void glDrawArraysInstanced(GLenum mode, GLint first, GLsizei count, GLsizei instancecount) {}
void glDrawElementsInstanced(GLenum mode, GLsizei count, GLenum type, const void *indices, GLsizei instancecount) {}
void glTexBuffer(GLenum target, GLenum internalformat, GLuint buffer) {}
void glPrimitiveRestartIndex(GLuint index) {}
void glCopyBufferSubData(GLenum readTarget, GLenum writeTarget, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size) {}
void glGetUniformIndices(GLuint program, GLsizei uniformCount, const GLchar *const*uniformNames, GLuint *uniformIndices) {}
void glGetActiveUniformsiv(GLuint program, GLsizei uniformCount, const GLuint *uniformIndices, GLenum pname, GLint *params) {}
void glGetActiveUniformName(GLuint program, GLuint uniformIndex, GLsizei bufSize, GLsizei *length, GLchar *uniformName) {}
GLuint glGetUniformBlockIndex(GLuint program, const GLchar *uniformBlockName);
void glGetActiveUniformBlockiv(GLuint program, GLuint uniformBlockIndex, GLenum pname, GLint *params) {}
void glGetActiveUniformBlockName(GLuint program, GLuint uniformBlockIndex, GLsizei bufSize, GLsizei *length, GLchar *uniformBlockName) {}
void glUniformBlockBinding(GLuint program, GLuint uniformBlockIndex, GLuint uniformBlockBinding) {}
void glMinSampleShading(GLfloat value) {}
void glBlendEquationi(GLuint buf, GLenum mode) {}
void glBlendEquationSeparatei(GLuint buf, GLenum modeRGB, GLenum modeAlpha) {}
void glBlendFunci(GLuint buf, GLenum src, GLenum dst) {}
void glBlendFuncSeparatei(GLuint buf, GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha) {}
void glDrawArraysIndirect(GLenum mode, const void *indirect) {}
void glDrawElementsIndirect(GLenum mode, GLenum type, const void *indirect) {}
void glUniform1d(GLint location, GLdouble x) {}
void glUniform2d(GLint location, GLdouble x, GLdouble y) {}
void glUniform3d(GLint location, GLdouble x, GLdouble y, GLdouble z) {}
void glUniform4d(GLint location, GLdouble x, GLdouble y, GLdouble z, GLdouble w) {}
void glUniform1dv(GLint location, GLsizei count, const GLdouble *value) {}
void glUniform2dv(GLint location, GLsizei count, const GLdouble *value) {}
void glUniform3dv(GLint location, GLsizei count, const GLdouble *value) {}
void glUniform4dv(GLint location, GLsizei count, const GLdouble *value) {}
void glUniformMatrix2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}
void glUniformMatrix3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}
void glUniformMatrix4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}
void glUniformMatrix2x3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}
void glUniformMatrix2x4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}
void glUniformMatrix3x2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}
void glUniformMatrix3x4dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}
void glUniformMatrix4x2dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}
void glUniformMatrix4x3dv(GLint location, GLsizei count, GLboolean transpose, const GLdouble *value) {}
void glGetUniformdv(GLuint program, GLint location, GLdouble *params) {}
GLint glGetSubroutineUniformLocation(GLuint program, GLenum shadertype, const GLchar *name);
GLuint glGetSubroutineIndex(GLuint program, GLenum shadertype, const GLchar *name);
void glGetActiveSubroutineUniformiv(GLuint program, GLenum shadertype, GLuint index, GLenum pname, GLint *values) {}
void glGetActiveSubroutineUniformName(GLuint program, GLenum shadertype, GLuint index, GLsizei bufSize, GLsizei *length, GLchar *name) {}
void glGetActiveSubroutineName(GLuint program, GLenum shadertype, GLuint index, GLsizei bufSize, GLsizei *length, GLchar *name) {}
void glUniformSubroutinesuiv(GLenum shadertype, GLsizei count, const GLuint *indices) {}
void glGetUniformSubroutineuiv(GLenum shadertype, GLint location, GLuint *params) {}
void glGetProgramStageiv(GLuint program, GLenum shadertype, GLenum pname, GLint *values) {}
void glPatchParameteri(GLenum pname, GLint value) {}
void glPatchParameterfv(GLenum pname, const GLfloat *values) {}
void glBindTransformFeedback(GLenum target, GLuint id) {}
void glDeleteTransformFeedbacks(GLsizei n, const GLuint *ids) {}
void glGenTransformFeedbacks(GLsizei n, GLuint *ids) {}
GLboolean glIsTransformFeedback(GLuint id);
void glPauseTransformFeedback(void) {}
void glResumeTransformFeedback(void) {}
void glDrawTransformFeedback(GLenum mode, GLuint id) {}
void glDrawTransformFeedbackStream(GLenum mode, GLuint id, GLuint stream) {}
void glBeginQueryIndexed(GLenum target, GLuint index, GLuint id) {}
void glEndQueryIndexed(GLenum target, GLuint index) {}
void glGetQueryIndexediv(GLenum target, GLuint index, GLenum pname, GLint *params) {}
void glClearBufferData(GLenum target, GLenum internalformat, GLenum format, GLenum type, const void *data) {}
void glClearBufferSubData(GLenum target, GLenum internalformat, GLintptr offset, GLsizeiptr size, GLenum format, GLenum type, const void *data) {}
void glDispatchCompute(GLuint num_groups_x, GLuint num_groups_y, GLuint num_groups_z) {}
void glDispatchComputeIndirect(GLintptr indirect) {}
void glCopyImageSubData(GLuint srcName, GLenum srcTarget, GLint srcLevel, GLint srcX, GLint srcY, GLint srcZ, GLuint dstName, GLenum dstTarget, GLint dstLevel, GLint dstX, GLint dstY, GLint dstZ, GLsizei srcWidth, GLsizei srcHeight, GLsizei srcDepth) {}
void glFramebufferParameteri(GLenum target, GLenum pname, GLint param) {}
void glGetFramebufferParameteriv(GLenum target, GLenum pname, GLint *params) {}
void glGetInternalformati64v(GLenum target, GLenum internalformat, GLenum pname, GLsizei count, GLint64 *params) {}
void glInvalidateTexSubImage(GLuint texture, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth) {}
void glInvalidateTexImage(GLuint texture, GLint level) {}
void glInvalidateBufferSubData(GLuint buffer, GLintptr offset, GLsizeiptr length) {}
void glInvalidateBufferData(GLuint buffer) {}
void glInvalidateFramebuffer(GLenum target, GLsizei numAttachments, const GLenum *attachments) {}
void glInvalidateSubFramebuffer(GLenum target, GLsizei numAttachments, const GLenum *attachments, GLint x, GLint y, GLsizei width, GLsizei height) {}
void glMultiDrawArraysIndirect(GLenum mode, const void *indirect, GLsizei drawcount, GLsizei stride) {}
void glMultiDrawElementsIndirect(GLenum mode, GLenum type, const void *indirect, GLsizei drawcount, GLsizei stride) {}
void glGetProgramInterfaceiv(GLuint program, GLenum programInterface, GLenum pname, GLint *params) {}
GLuint glGetProgramResourceIndex(GLuint program, GLenum programInterface, const GLchar *name);
void glGetProgramResourceName(GLuint program, GLenum programInterface, GLuint index, GLsizei bufSize, GLsizei *length, GLchar *name) {}
void glGetProgramResourceiv(GLuint program, GLenum programInterface, GLuint index, GLsizei propCount, const GLenum *props, GLsizei count, GLsizei *length, GLint *params) {}
GLint glGetProgramResourceLocation(GLuint program, GLenum programInterface, const GLchar *name);
GLint glGetProgramResourceLocationIndex(GLuint program, GLenum programInterface, const GLchar *name);
void glShaderStorageBlockBinding(GLuint program, GLuint storageBlockIndex, GLuint storageBlockBinding) {}
void glTexBufferRange(GLenum target, GLenum internalformat, GLuint buffer, GLintptr offset, GLsizeiptr size) {}
void glTexStorage2DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLboolean fixedsamplelocations) {}
void glTexStorage3DMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth, GLboolean fixedsamplelocations) {}
void glTextureView(GLuint texture, GLenum target, GLuint origtexture, GLenum internalformat, GLuint minlevel, GLuint numlevels, GLuint minlayer, GLuint numlayers) {}
void glBindVertexBuffer(GLuint bindingindex, GLuint buffer, GLintptr offset, GLsizei stride) {}
void glVertexAttribFormat(GLuint attribindex, GLint size, GLenum type, GLboolean normalized, GLuint relativeoffset) {}
void glVertexAttribIFormat(GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset) {}
void glVertexAttribLFormat(GLuint attribindex, GLint size, GLenum type, GLuint relativeoffset) {}
void glVertexAttribBinding(GLuint attribindex, GLuint bindingindex) {}
void glVertexBindingDivisor(GLuint bindingindex, GLuint divisor) {}
void glDebugMessageControl(GLenum source, GLenum type, GLenum severity, GLsizei count, const GLuint *ids, GLboolean enabled) {}
void glDebugMessageInsert(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar *buf) {}
void glDebugMessageCallback(GLDEBUGPROC callback, const void *userParam) {}
GLuint glGetDebugMessageLog(GLuint count, GLsizei bufSize, GLenum *sources, GLenum *types, GLuint *ids, GLenum *severities, GLsizei *lengths, GLchar *messageLog);
void glPushDebugGroup(GLenum source, GLuint id, GLsizei length, const GLchar *message) {}
void glPopDebugGroup(void) {}
void glObjectLabel(GLenum identifier, GLuint name, GLsizei length, const GLchar *label) {}
void glGetObjectLabel(GLenum identifier, GLuint name, GLsizei bufSize, GLsizei *length, GLchar *label) {}
void glObjectPtrLabel(const void *ptr, GLsizei length, const GLchar *label) {}
void glGetObjectPtrLabel(const void *ptr, GLsizei bufSize, GLsizei *length, GLchar *label) {}
void glSpecializeShader(GLuint shader, const GLchar *pEntryPoint, GLuint numSpecializationConstants, const GLuint *pConstantIndex, const GLuint *pConstantValue) {}
void glMultiDrawArraysIndirectCount(GLenum mode, const void *indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride) {}
void glMultiDrawElementsIndirectCount(GLenum mode, GLenum type, const void *indirect, GLintptr drawcount, GLsizei maxdrawcount, GLsizei stride) {}
void glPolygonOffsetClamp(GLfloat factor, GLfloat units, GLfloat clamp) {}
