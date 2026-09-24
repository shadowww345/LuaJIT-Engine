local ffi = require("ffi")
local bit = require("bit")
local gl = ffi.load("GL")
local glfw = ffi.load("glfw")

--Defines
local GLFW = {
    GLFW_CONTEXT_VERSION_MAJOR    = 0x00022002,
    GLFW_CONTEXT_VERSION_MINOR    = 0x00022003,
    GLFW_OPENGL_PROFILE           = 0x00022008,
    GLFW_OPENGL_CORE_PROFILE      = 0x00032001,
    GLFW_OPENGL_COMPAT_PROFILE    = 0x00032002,
    GLFW_OPENGL_FORWARD_COMPAT    = 0x00022006,
    GLFW_RESIZABLE                = 0x00020003,
    GLFW_VISIBLE                  = 0x00020004,
    GLFW_DECORATED                = 0x00020005,
    GLFW_FOCUSED                  = 0x00020001,
    GLFW_FLOATING                 = 0x00020007,
    GLFW_MAXIMIZED                = 0x00020008,
    GLFW_DOUBLEBUFFER             = 0x00021010,
    GLFW_SAMPLES                  = 0x0002100D,
    GLFW_DEPTH_BITS               = 0x00021005,
    GLFW_STENCIL_BITS             = 0x00021006,
    GLFW_RED_BITS                 = 0x00021001,
    GLFW_GREEN_BITS               = 0x00021002,
    GLFW_BLUE_BITS                = 0x00021003,
    GLFW_ALPHA_BITS               = 0x00021004,
    GLFW_REFRESH_RATE             = 0x0002100F,

    GLFW_CURSOR                   = 0x00033001,
    GLFW_STICKY_KEYS              = 0x00033002,
    GLFW_STICKY_MOUSE_BUTTONS     = 0x00033003,
    GLFW_LOCK_KEY_MODS            = 0x00033004,
    GLFW_RAW_MOUSE_MOTION         = 0x00033005,

    GLFW_CURSOR_NORMAL            = 0x00034001,
    GLFW_CURSOR_HIDDEN            = 0x00034002,
    GLFW_CURSOR_DISABLED          = 0x00034003,

    GLFW_PRESS                    = 1,
    GLFW_RELEASE                  = 0,
    GLFW_REPEAT                   = 2,

    GLFW_MOUSE_BUTTON_LEFT        = 0,
    GLFW_MOUSE_BUTTON_RIGHT       = 1,
    GLFW_MOUSE_BUTTON_MIDDLE      = 2,

    GLFW_KEY_UNKNOWN              = -1,
    GLFW_KEY_SPACE                = 32,
    GLFW_KEY_APOSTROPHE           = 39,
    GLFW_KEY_COMMA                = 44,
    GLFW_KEY_MINUS                = 45,
    GLFW_KEY_PERIOD               = 46,
    GLFW_KEY_SLASH                = 47,
    GLFW_KEY_0                    = 48,
    GLFW_KEY_1                    = 49,
    GLFW_KEY_2                    = 50,
    GLFW_KEY_3                    = 51,
    GLFW_KEY_4                    = 52,
    GLFW_KEY_5                    = 53,
    GLFW_KEY_6                    = 54,
    GLFW_KEY_7                    = 55,
    GLFW_KEY_8                    = 56,
    GLFW_KEY_9                    = 57,
    GLFW_KEY_SEMICOLON            = 59,
    GLFW_KEY_EQUAL                = 61,
    GLFW_KEY_A                    = 65,
    GLFW_KEY_B                    = 66,
    GLFW_KEY_C                    = 67,
    GLFW_KEY_D                    = 68,
    GLFW_KEY_E                    = 69,
    GLFW_KEY_F                    = 70,
    GLFW_KEY_G                    = 71,
    GLFW_KEY_H                    = 72,
    GLFW_KEY_I                    = 73,
    GLFW_KEY_J                    = 74,
    GLFW_KEY_K                    = 75,
    GLFW_KEY_L                    = 76,
    GLFW_KEY_M                    = 77,
    GLFW_KEY_N                    = 78,
    GLFW_KEY_O                    = 79,
    GLFW_KEY_P                    = 80,
    GLFW_KEY_Q                    = 81,
    GLFW_KEY_R                    = 82,
    GLFW_KEY_S                    = 83,
    GLFW_KEY_T                    = 84,
    GLFW_KEY_U                    = 85,
    GLFW_KEY_V                    = 86,
    GLFW_KEY_W                    = 87,
    GLFW_KEY_X                    = 88,
    GLFW_KEY_Y                    = 89,
    GLFW_KEY_Z                    = 90,
    GLFW_KEY_LEFT_BRACKET         = 91,
    GLFW_KEY_BACKSLASH            = 92,
    GLFW_KEY_RIGHT_BRACKET        = 93,
    GLFW_KEY_GRAVE_ACCENT         = 96,
    GLFW_KEY_ESCAPE               = 256,
    GLFW_KEY_ENTER                = 257,
    GLFW_KEY_TAB                  = 258,
    GLFW_KEY_BACKSPACE            = 259,
    GLFW_KEY_INSERT               = 260,
    GLFW_KEY_DELETE               = 261,
    GLFW_KEY_RIGHT                = 262,
    GLFW_KEY_LEFT                 = 263,
    GLFW_KEY_DOWN                 = 264,
    GLFW_KEY_UP                   = 265,
    GLFW_KEY_PAGE_UP              = 266,
    GLFW_KEY_PAGE_DOWN            = 267,
    GLFW_KEY_HOME                 = 268,
    GLFW_KEY_END                  = 269,
    GLFW_KEY_CAPS_LOCK            = 280,
    GLFW_KEY_SCROLL_LOCK          = 281,
    GLFW_KEY_NUM_LOCK             = 282,
    GLFW_KEY_PRINT_SCREEN         = 283,
    GLFW_KEY_PAUSE                = 284,
    GLFW_KEY_F1                   = 290,
    GLFW_KEY_F2                   = 291,
    GLFW_KEY_F3                   = 292,
    GLFW_KEY_F4                   = 293,
    GLFW_KEY_F5                   = 294,
    GLFW_KEY_F6                   = 295,
    GLFW_KEY_F7                   = 296,
    GLFW_KEY_F8                   = 297,
    GLFW_KEY_F9                   = 298,
    GLFW_KEY_F10                  = 299,
    GLFW_KEY_F11                  = 300,
    GLFW_KEY_F12                  = 301,
    GLFW_KEY_LEFT_SHIFT           = 340,
    GLFW_KEY_LEFT_CONTROL         = 341,
    GLFW_KEY_LEFT_ALT             = 342,
    GLFW_KEY_LEFT_SUPER           = 343,
    GLFW_KEY_RIGHT_SHIFT          = 344,
    GLFW_KEY_RIGHT_CONTROL        = 345,
    GLFW_KEY_RIGHT_ALT            = 346,
    GLFW_KEY_RIGHT_SUPER          = 347,
    GLFW_KEY_MENU                 = 348,

    GLFW_MOD_SHIFT                = 0x0001,
    GLFW_MOD_CONTROL              = 0x0002,
    GLFW_MOD_ALT                  = 0x0004,
    GLFW_MOD_SUPER                = 0x0008,
    GLFW_MOD_CAPS_LOCK            = 0x0010,
    GLFW_MOD_NUM_LOCK             = 0x0020,

    GLFW_JOYSTICK_1               = 0,
    GLFW_JOYSTICK_LAST            = 15,

    GLFW_CONNECTED                = 0x00040001,
    GLFW_DISCONNECTED             = 0x00040002,

    GLFW_ARROW_CURSOR             = 0x00036001,
    GLFW_IBEAM_CURSOR             = 0x00036002,
    GLFW_CROSSHAIR_CURSOR         = 0x00036003,
    GLFW_HAND_CURSOR              = 0x00036004,
    GLFW_HRESIZE_CURSOR           = 0x00036005,
    GLFW_VRESIZE_CURSOR           = 0x00036006,

    GLFW_TRUE                     = 1,
    GLFW_FALSE                    = 0,

    GLFW_NO_ERROR                 = 0,
    GLFW_NOT_INITIALIZED          = 0x00010001,
    GLFW_NO_CURRENT_CONTEXT       = 0x00010002,
    GLFW_INVALID_ENUM             = 0x00010003,
    GLFW_INVALID_VALUE            = 0x00010004,
    GLFW_OUT_OF_MEMORY            = 0x00010005,
    GLFW_API_UNAVAILABLE          = 0x00010006,
    GLFW_VERSION_UNAVAILABLE      = 0x00010007,
    GLFW_PLATFORM_ERROR           = 0x00010008,
    GLFW_FORMAT_UNAVAILABLE       = 0x00010009,
    GLFW_NO_WINDOW_CONTEXT        = 0x0001000A,
}
local GL_ARRAY_BUFFER           = 0x8892
local GL_ELEMENT_ARRAY_BUFFER   = 0x8893
local GL_STATIC_DRAW            = 0x88E4
local GL_FLOAT                  = 0x1406
local GL_UNSIGNED_INT           = 0x1405
local GL_FALSE                  = 0
local GL_TRUE                   = 1
local GL_TRIANGLES              = 0x0004
local GL_COLOR_BUFFER_BIT       = 0x00004000
local GL_DEPTH_BUFFER_BIT       = 0x00000100
local GL_DEPTH_TEST             = 0x0B71
local GL_LESS                   = 0x0201
local GL_CULL_FACE              = 0x0B44
local GL_BACK                   = 0x0405
local GL_VERTEX_SHADER          = 0x8B31
local GL_FRAGMENT_SHADER        = 0x8B30
local GL_COMPILE_STATUS         = 0x8B81
local GL_LINK_STATUS            = 0x8B82
-- All functions and types
ffi.cdef[[

typedef void            GLvoid;
typedef unsigned char   GLboolean;
typedef signed char     GLbyte;
typedef unsigned char   GLubyte;
typedef short           GLshort;
typedef unsigned short  GLushort;
typedef int             GLint;
typedef unsigned int    GLuint;
typedef int             GLsizei;
typedef unsigned int    GLenum;
typedef unsigned int    GLbitfield;
typedef float           GLfloat;
typedef float           GLclampf;
typedef double          GLdouble;
typedef double          GLclampd;
typedef char            GLchar;
typedef unsigned short  GLhalf;


typedef int64_t         GLint64;
typedef uint64_t        GLuint64;


typedef ptrdiff_t       GLintptr;
typedef ptrdiff_t       GLsizeiptr;
typedef ptrdiff_t       GLintptrARB;
typedef ptrdiff_t       GLsizeiptrARB;

typedef struct __GLsync *GLsync;
typedef void (*GLDEBUGPROC)(
    GLenum source,
    GLenum type,
    GLuint id,
    GLenum severity,
    GLsizei length,
    const GLchar *message,
    const void *userParam
);

typedef struct GLFWmonitor  GLFWmonitor;
typedef struct GLFWwindow   GLFWwindow;
typedef struct GLFWcursor   GLFWcursor;

typedef struct GLFWvidmode {
    int width;
    int height;
    int redBits;
    int greenBits;
    int blueBits;
    int refreshRate;
} GLFWvidmode;

typedef struct GLFWgammaramp {
    unsigned short *red;
    unsigned short *green;
    unsigned short *blue;
    unsigned int size;
} GLFWgammaramp;

typedef struct GLFWimage {
    int width;
    int height;
    unsigned char *pixels;
} GLFWimage;

typedef struct GLFWgamepadstate {
    unsigned char buttons[15];
    float axes[6];
} GLFWgamepadstate;

typedef void (*GLFWerrorfun)(int error_code, const char *description);

typedef void (*GLFWwindowposfun)(GLFWwindow *window, int xpos, int ypos);
typedef void (*GLFWwindowsizefun)(GLFWwindow *window, int width, int height);
typedef void (*GLFWwindowclosefun)(GLFWwindow *window);
typedef void (*GLFWwindowrefreshfun)(GLFWwindow *window);
typedef void (*GLFWwindowfocusfun)(GLFWwindow *window, int focused);
typedef void (*GLFWwindowiconifyfun)(GLFWwindow *window, int iconified);
typedef void (*GLFWwindowmaximizefun)(GLFWwindow *window, int maximized);
typedef void (*GLFWframebuffersizefun)(GLFWwindow *window, int width, int height);
typedef void (*GLFWwindowcontentscalefun)(GLFWwindow *window, float xscale, float yscale);

typedef void (*GLFWkeyfun)(GLFWwindow *window, int key, int scancode, int action, int mods);
typedef void (*GLFWcharfun)(GLFWwindow *window, unsigned int codepoint);
typedef void (*GLFWcharmodsfun)(GLFWwindow *window, unsigned int codepoint, int mods);

typedef void (*GLFWmousebuttonfun)(GLFWwindow *window, int button, int action, int mods);
typedef void (*GLFWcursorposfun)(GLFWwindow *window, double xpos, double ypos);
typedef void (*GLFWcursorenterfun)(GLFWwindow *window, int entered);
typedef void (*GLFWscrollfun)(GLFWwindow *window, double xoffset, double yoffset);
typedef void (*GLFWdropfun)(GLFWwindow *window, int path_count, const char *paths[]);

typedef void (*GLFWjoystickfun)(int jid, int event);
typedef void (*GLFWmonitorfun)(GLFWmonitor *monitor, int event);

typedef void (*GLFWglproc)(void);

void glGenBuffers(GLsizei n, GLuint *buffers);
void glBindBuffer(GLenum target, GLuint buffer);
void glBufferData(GLenum target, GLsizeiptr size, const void *data, GLenum usage);
void glBufferSubData(GLenum target, GLintptr offset, GLsizeiptr size, const void *data);
void glDeleteBuffers(GLsizei n, const GLuint *buffers);
void *glMapBuffer(GLenum target, GLenum access);
void *glMapBufferRange(GLenum target, GLintptr offset, GLsizeiptr length, GLbitfield access);
GLboolean glUnmapBuffer(GLenum target);
void glCopyBufferSubData(GLenum readTarget, GLenum writeTarget, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size);
void glGetBufferParameteriv(GLenum target, GLenum pname, GLint *params);
void glBindBufferBase(GLenum target, GLuint index, GLuint buffer);
void glBindBufferRange(GLenum target, GLuint index, GLuint buffer, GLintptr offset, GLsizeiptr size);
void glGenVertexArrays(GLsizei n, GLuint *arrays);
void glBindVertexArray(GLuint array);
void glDeleteVertexArrays(GLsizei n, const GLuint *arrays);
void glEnableVertexAttribArray(GLuint index);
void glDisableVertexAttribArray(GLuint index);
void glVertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void *pointer);
void glVertexAttribIPointer(GLuint index, GLint size, GLenum type, GLsizei stride, const void *pointer);
void glVertexAttribLPointer(GLuint index, GLint size, GLenum type, GLsizei stride, const void *pointer);
void glVertexAttribDivisor(GLuint index, GLuint divisor);
GLuint glCreateShader(GLenum shaderType);
void glShaderSource(GLuint shader, GLsizei count, const GLchar **string, const GLint *length);
void glCompileShader(GLuint shader);
void glGetShaderiv(GLuint shader, GLenum pname, GLint *params);
void glGetShaderInfoLog(GLuint shader, GLsizei maxLength, GLsizei *length, GLchar *infoLog);
void glDeleteShader(GLuint shader);

GLuint glCreateProgram(void);
void glAttachShader(GLuint program, GLuint shader);
void glDetachShader(GLuint program, GLuint shader);
void glLinkProgram(GLuint program);
void glUseProgram(GLuint program);
void glDeleteProgram(GLuint program);
void glGetProgramiv(GLuint program, GLenum pname, GLint *params);
void glGetProgramInfoLog(GLuint program, GLsizei maxLength, GLsizei *length, GLchar *infoLog);
void glValidateProgram(GLuint program);

void glBindAttribLocation(GLuint program, GLuint index, const GLchar *name);
GLint glGetAttribLocation(GLuint program, const GLchar *name);
GLint glGetUniformLocation(GLuint program, const GLchar *name);
GLuint glGetUniformBlockIndex(GLuint program, const GLchar *uniformBlockName);
void glUniformBlockBinding(GLuint program, GLuint uniformBlockIndex, GLuint uniformBlockBinding);
void glUniform1i(GLint location, GLint v0);
void glUniform2i(GLint location, GLint v0, GLint v1);
void glUniform3i(GLint location, GLint v0, GLint v1, GLint v2);
void glUniform4i(GLint location, GLint v0, GLint v1, GLint v2, GLint v3);

void glUniform1f(GLint location, GLfloat v0);
void glUniform2f(GLint location, GLfloat v0, GLfloat v1);
void glUniform3f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2);
void glUniform4f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3);

void glUniform1ui(GLint location, GLuint v0);
void glUniform2ui(GLint location, GLuint v0, GLuint v1);
void glUniform3ui(GLint location, GLuint v0, GLuint v1, GLuint v2);
void glUniform4ui(GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3);

void glUniform1iv(GLint location, GLsizei count, const GLint *value);
void glUniform2iv(GLint location, GLsizei count, const GLint *value);
void glUniform3iv(GLint location, GLsizei count, const GLint *value);
void glUniform4iv(GLint location, GLsizei count, const GLint *value);

void glUniform1fv(GLint location, GLsizei count, const GLfloat *value);
void glUniform2fv(GLint location, GLsizei count, const GLfloat *value);
void glUniform3fv(GLint location, GLsizei count, const GLfloat *value);
void glUniform4fv(GLint location, GLsizei count, const GLfloat *value);

void glUniformMatrix2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix2x3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix3x2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix2x4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix4x2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix3x4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix4x3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glGenTextures(GLsizei n, GLuint *textures);
void glBindTexture(GLenum target, GLuint texture);
void glDeleteTextures(GLsizei n, const GLuint *textures);
void glActiveTexture(GLenum texture);

void glTexImage1D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLint border, GLenum format, GLenum type, const void *data);
void glTexImage2D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const void *data);
void glTexImage3D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const void *data);

void glTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const void *pixels);
void glTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const void *pixels);
void glTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void *pixels);

void glTexParameteri(GLenum target, GLenum pname, GLint param);
void glTexParameterf(GLenum target, GLenum pname, GLfloat param);
void glTexParameteriv(GLenum target, GLenum pname, const GLint *params);
void glTexParameterfv(GLenum target, GLenum pname, const GLfloat *params);

void glGenerateMipmap(GLenum target);

void glTexStorage1D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width);
void glTexStorage2D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height);
void glTexStorage3D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth);

void glGetTexImage(GLenum target, GLint level, GLenum format, GLenum type, void *pixels);
void glGenFramebuffers(GLsizei n, GLuint *framebuffers);
void glBindFramebuffer(GLenum target, GLuint framebuffer);
void glDeleteFramebuffers(GLsizei n, const GLuint *framebuffers);
GLenum glCheckFramebufferStatus(GLenum target);

void glFramebufferTexture(GLenum target, GLenum attachment, GLuint texture, GLint level);
void glFramebufferTexture1D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level);
void glFramebufferTexture2D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level);
void glFramebufferTexture3D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint zoffset);
void glFramebufferTextureLayer(GLenum target, GLenum attachment, GLuint texture, GLint level, GLint layer);
void glFramebufferRenderbuffer(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer);

void glGenRenderbuffers(GLsizei n, GLuint *renderbuffers);
void glBindRenderbuffer(GLenum target, GLuint renderbuffer);
void glDeleteRenderbuffers(GLsizei n, const GLuint *renderbuffers);
void glRenderbufferStorage(GLenum target, GLenum internalformat, GLsizei width, GLsizei height);
void glRenderbufferStorageMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height);

void glBlitFramebuffer(GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter);
void glReadBuffer(GLenum mode);
void glDrawBuffer(GLenum mode);
void glDrawBuffers(GLsizei n, const GLenum *bufs);
void glDrawArrays(GLenum mode, GLint first, GLsizei count);
void glDrawElements(GLenum mode, GLsizei count, GLenum type, const void *indices);
void glDrawArraysInstanced(GLenum mode, GLint first, GLsizei count, GLsizei instancecount);
void glDrawElementsInstanced(GLenum mode, GLsizei count, GLenum type, const void *indices, GLsizei instancecount);
void glDrawArraysIndirect(GLenum mode, const void *indirect);
void glDrawElementsIndirect(GLenum mode, GLenum type, const void *indirect);
void glMultiDrawArrays(GLenum mode, const GLint *first, const GLsizei *count, GLsizei drawcount);
void glMultiDrawElements(GLenum mode, const GLsizei *count, GLenum type, const void *const *indices, GLsizei drawcount);
void glDrawElementsBaseVertex(GLenum mode, GLsizei count, GLenum type, const void *indices, GLint basevertex);
void glDrawRangeElements(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const void *indices);
void glEnable(GLenum cap);
void glDisable(GLenum cap);
GLboolean glIsEnabled(GLenum cap);

void glClear(GLbitfield mask);
void glClearColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
void glClearDepth(GLdouble depth);
void glClearDepthf(GLfloat depth);
void glClearStencil(GLint s);

void glViewport(GLint x, GLint y, GLsizei width, GLsizei height);
void glScissor(GLint x, GLint y, GLsizei width, GLsizei height);

void glDepthFunc(GLenum func);
void glDepthMask(GLboolean flag);
void glDepthRange(GLdouble nearVal, GLdouble farVal);

void glBlendFunc(GLenum sfactor, GLenum dfactor);
void glBlendFuncSeparate(GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha);
void glBlendEquation(GLenum mode);
void glBlendEquationSeparate(GLenum modeRGB, GLenum modeAlpha);
void glBlendColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);

void glCullFace(GLenum mode);
void glFrontFace(GLenum mode);
void glPolygonMode(GLenum face, GLenum mode);
void glPolygonOffset(GLfloat factor, GLfloat units);
void glLineWidth(GLfloat width);
void glPointSize(GLfloat size);

void glColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha);
void glStencilFunc(GLenum func, GLint ref, GLuint mask);
void glStencilFuncSeparate(GLenum face, GLenum func, GLint ref, GLuint mask);
void glStencilOp(GLenum sfail, GLenum dpfail, GLenum dppass);
void glStencilOpSeparate(GLenum face, GLenum sfail, GLenum dpfail, GLenum dppass);
void glStencilMask(GLuint mask);
void glStencilMaskSeparate(GLenum face, GLuint mask);
void glGenQueries(GLsizei n, GLuint *ids);
void glDeleteQueries(GLsizei n, const GLuint *ids);
void glBeginQuery(GLenum target, GLuint id);
void glEndQuery(GLenum target);
void glGetQueryObjectiv(GLuint id, GLenum pname, GLint *params);
void glGetQueryObjectuiv(GLuint id, GLenum pname, GLuint *params);
void glGetQueryObjecti64v(GLuint id, GLenum pname, GLint64 *params);
void glGetQueryObjectui64v(GLuint id, GLenum pname, GLuint64 *params);
void glQueryCounter(GLuint id, GLenum target);

GLsync glFenceSync(GLenum condition, GLbitfield flags);
GLenum glClientWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout);
void glWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout);
void glDeleteSync(GLsync sync);
void glDispatchCompute(GLuint num_groups_x, GLuint num_groups_y, GLuint num_groups_z);
void glDispatchComputeIndirect(GLintptr indirect);
void glMemoryBarrier(GLbitfield barriers);
void glGetIntegerv(GLenum pname, GLint *data);
void glGetFloatv(GLenum pname, GLfloat *data);
void glGetDoublev(GLenum pname, GLdouble *data);
void glGetBooleanv(GLenum pname, GLboolean *data);
void glGetInteger64v(GLenum pname, GLint64 *data);
const GLubyte *glGetString(GLenum name);
const GLubyte *glGetStringi(GLenum name, GLuint index);
GLenum glGetError(void);
void glFinish(void);
void glFlush(void);
void glGenTransformFeedbacks(GLsizei n, GLuint *ids);
void glBindTransformFeedback(GLenum target, GLuint id);
void glDeleteTransformFeedbacks(GLsizei n, const GLuint *ids);
void glBeginTransformFeedback(GLenum primitiveMode);
void glEndTransformFeedback(void);
void glPauseTransformFeedback(void);
void glResumeTransformFeedback(void);
void glTransformFeedbackVaryings(GLuint program, GLsizei count, const GLchar *const *varyings, GLenum bufferMode);
void glDrawTransformFeedback(GLenum mode, GLuint id);
void glDrawTransformFeedbackInstanced(GLenum mode, GLuint id, GLsizei instancecount);
void glGenSamplers(GLsizei n, GLuint *samplers);
void glDeleteSamplers(GLsizei n, const GLuint *samplers);
void glBindSampler(GLuint unit, GLuint sampler);
void glSamplerParameteri(GLuint sampler, GLenum pname, GLint param);
void glSamplerParameterf(GLuint sampler, GLenum pname, GLfloat param);
void glSamplerParameteriv(GLuint sampler, GLenum pname, const GLint *params);
void glSamplerParameterfv(GLuint sampler, GLenum pname, const GLfloat *params);
void glDebugMessageCallback(GLDEBUGPROC callback, const void *userParam);
void glDebugMessageControl(GLenum source, GLenum type, GLenum severity, GLsizei count, const GLuint *ids, GLboolean enabled);
void glDebugMessageInsert(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar *buf);
void glPushDebugGroup(GLenum source, GLuint id, GLsizei length, const GLchar *message);
void glPopDebugGroup(void);
void glObjectLabel(GLenum identifier, GLuint name, GLsizei length, const GLchar *label);
GLuint glGetDebugMessageLog(GLuint count, GLsizei bufSize, GLenum *sources, GLenum *types, GLuint *ids, GLenum *severities, GLsizei *lengths, GLchar *messageLog);
void glGenBuffers(GLsizei n, GLuint *buffers);
void glBindBuffer(GLenum target, GLuint buffer);
void glBufferData(GLenum target, GLsizeiptr size, const void *data, GLenum usage);
void glBufferSubData(GLenum target, GLintptr offset, GLsizeiptr size, const void *data);
void glDeleteBuffers(GLsizei n, const GLuint *buffers);
void *glMapBuffer(GLenum target, GLenum access);
void *glMapBufferRange(GLenum target, GLintptr offset, GLsizeiptr length, GLbitfield access);
GLboolean glUnmapBuffer(GLenum target);
void glCopyBufferSubData(GLenum readTarget, GLenum writeTarget, GLintptr readOffset, GLintptr writeOffset, GLsizeiptr size);
void glGetBufferParameteriv(GLenum target, GLenum pname, GLint *params);
void glBindBufferBase(GLenum target, GLuint index, GLuint buffer);
void glBindBufferRange(GLenum target, GLuint index, GLuint buffer, GLintptr offset, GLsizeiptr size);
void glGenVertexArrays(GLsizei n, GLuint *arrays);
void glBindVertexArray(GLuint array);
void glDeleteVertexArrays(GLsizei n, const GLuint *arrays);
void glEnableVertexAttribArray(GLuint index);
void glDisableVertexAttribArray(GLuint index);
void glVertexAttribPointer(GLuint index, GLint size, GLenum type, GLboolean normalized, GLsizei stride, const void *pointer);
void glVertexAttribIPointer(GLuint index, GLint size, GLenum type, GLsizei stride, const void *pointer);
void glVertexAttribLPointer(GLuint index, GLint size, GLenum type, GLsizei stride, const void *pointer);
void glVertexAttribDivisor(GLuint index, GLuint divisor);
GLuint glCreateShader(GLenum shaderType);
void glShaderSource(GLuint shader, GLsizei count, const GLchar **string, const GLint *length);
void glCompileShader(GLuint shader);
void glGetShaderiv(GLuint shader, GLenum pname, GLint *params);
void glGetShaderInfoLog(GLuint shader, GLsizei maxLength, GLsizei *length, GLchar *infoLog);
void glDeleteShader(GLuint shader);

GLuint glCreateProgram(void);
void glAttachShader(GLuint program, GLuint shader);
void glDetachShader(GLuint program, GLuint shader);
void glLinkProgram(GLuint program);
void glUseProgram(GLuint program);
void glDeleteProgram(GLuint program);
void glGetProgramiv(GLuint program, GLenum pname, GLint *params);
void glGetProgramInfoLog(GLuint program, GLsizei maxLength, GLsizei *length, GLchar *infoLog);
void glValidateProgram(GLuint program);

void glBindAttribLocation(GLuint program, GLuint index, const GLchar *name);
GLint glGetAttribLocation(GLuint program, const GLchar *name);
GLint glGetUniformLocation(GLuint program, const GLchar *name);
GLuint glGetUniformBlockIndex(GLuint program, const GLchar *uniformBlockName);
void glUniformBlockBinding(GLuint program, GLuint uniformBlockIndex, GLuint uniformBlockBinding);
void glUniform1i(GLint location, GLint v0);
void glUniform2i(GLint location, GLint v0, GLint v1);
void glUniform3i(GLint location, GLint v0, GLint v1, GLint v2);
void glUniform4i(GLint location, GLint v0, GLint v1, GLint v2, GLint v3);

void glUniform1f(GLint location, GLfloat v0);
void glUniform2f(GLint location, GLfloat v0, GLfloat v1);
void glUniform3f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2);
void glUniform4f(GLint location, GLfloat v0, GLfloat v1, GLfloat v2, GLfloat v3);

void glUniform1ui(GLint location, GLuint v0);
void glUniform2ui(GLint location, GLuint v0, GLuint v1);
void glUniform3ui(GLint location, GLuint v0, GLuint v1, GLuint v2);
void glUniform4ui(GLint location, GLuint v0, GLuint v1, GLuint v2, GLuint v3);

void glUniform1iv(GLint location, GLsizei count, const GLint *value);
void glUniform2iv(GLint location, GLsizei count, const GLint *value);
void glUniform3iv(GLint location, GLsizei count, const GLint *value);
void glUniform4iv(GLint location, GLsizei count, const GLint *value);

void glUniform1fv(GLint location, GLsizei count, const GLfloat *value);
void glUniform2fv(GLint location, GLsizei count, const GLfloat *value);
void glUniform3fv(GLint location, GLsizei count, const GLfloat *value);
void glUniform4fv(GLint location, GLsizei count, const GLfloat *value);

void glUniformMatrix2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix2x3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix3x2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix2x4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix4x2fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix3x4fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glUniformMatrix4x3fv(GLint location, GLsizei count, GLboolean transpose, const GLfloat *value);
void glGenTextures(GLsizei n, GLuint *textures);
void glBindTexture(GLenum target, GLuint texture);
void glDeleteTextures(GLsizei n, const GLuint *textures);
void glActiveTexture(GLenum texture);

void glTexImage1D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLint border, GLenum format, GLenum type, const void *data);
void glTexImage2D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const void *data);
void glTexImage3D(GLenum target, GLint level, GLint internalFormat, GLsizei width, GLsizei height, GLsizei depth, GLint border, GLenum format, GLenum type, const void *data);

void glTexSubImage1D(GLenum target, GLint level, GLint xoffset, GLsizei width, GLenum format, GLenum type, const void *pixels);
void glTexSubImage2D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLsizei width, GLsizei height, GLenum format, GLenum type, const void *pixels);
void glTexSubImage3D(GLenum target, GLint level, GLint xoffset, GLint yoffset, GLint zoffset, GLsizei width, GLsizei height, GLsizei depth, GLenum format, GLenum type, const void *pixels);

void glTexParameteri(GLenum target, GLenum pname, GLint param);
void glTexParameterf(GLenum target, GLenum pname, GLfloat param);
void glTexParameteriv(GLenum target, GLenum pname, const GLint *params);
void glTexParameterfv(GLenum target, GLenum pname, const GLfloat *params);

void glGenerateMipmap(GLenum target);

void glTexStorage1D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width);
void glTexStorage2D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height);
void glTexStorage3D(GLenum target, GLsizei levels, GLenum internalformat, GLsizei width, GLsizei height, GLsizei depth);

void glGetTexImage(GLenum target, GLint level, GLenum format, GLenum type, void *pixels);
void glGenFramebuffers(GLsizei n, GLuint *framebuffers);
void glBindFramebuffer(GLenum target, GLuint framebuffer);
void glDeleteFramebuffers(GLsizei n, const GLuint *framebuffers);
GLenum glCheckFramebufferStatus(GLenum target);

void glFramebufferTexture(GLenum target, GLenum attachment, GLuint texture, GLint level);
void glFramebufferTexture1D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level);
void glFramebufferTexture2D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level);
void glFramebufferTexture3D(GLenum target, GLenum attachment, GLenum textarget, GLuint texture, GLint level, GLint zoffset);
void glFramebufferTextureLayer(GLenum target, GLenum attachment, GLuint texture, GLint level, GLint layer);
void glFramebufferRenderbuffer(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer);

void glGenRenderbuffers(GLsizei n, GLuint *renderbuffers);
void glBindRenderbuffer(GLenum target, GLuint renderbuffer);
void glDeleteRenderbuffers(GLsizei n, const GLuint *renderbuffers);
void glRenderbufferStorage(GLenum target, GLenum internalformat, GLsizei width, GLsizei height);
void glRenderbufferStorageMultisample(GLenum target, GLsizei samples, GLenum internalformat, GLsizei width, GLsizei height);

void glBlitFramebuffer(GLint srcX0, GLint srcY0, GLint srcX1, GLint srcY1, GLint dstX0, GLint dstY0, GLint dstX1, GLint dstY1, GLbitfield mask, GLenum filter);
void glReadBuffer(GLenum mode);
void glDrawBuffer(GLenum mode);
void glDrawBuffers(GLsizei n, const GLenum *bufs);
void glDrawArrays(GLenum mode, GLint first, GLsizei count);
void glDrawElements(GLenum mode, GLsizei count, GLenum type, const void *indices);
void glDrawArraysInstanced(GLenum mode, GLint first, GLsizei count, GLsizei instancecount);
void glDrawElementsInstanced(GLenum mode, GLsizei count, GLenum type, const void *indices, GLsizei instancecount);
void glDrawArraysIndirect(GLenum mode, const void *indirect);
void glDrawElementsIndirect(GLenum mode, GLenum type, const void *indirect);
void glMultiDrawArrays(GLenum mode, const GLint *first, const GLsizei *count, GLsizei drawcount);
void glMultiDrawElements(GLenum mode, const GLsizei *count, GLenum type, const void *const *indices, GLsizei drawcount);
void glDrawElementsBaseVertex(GLenum mode, GLsizei count, GLenum type, const void *indices, GLint basevertex);
void glDrawRangeElements(GLenum mode, GLuint start, GLuint end, GLsizei count, GLenum type, const void *indices);
void glEnable(GLenum cap);
void glDisable(GLenum cap);
GLboolean glIsEnabled(GLenum cap);

void glClear(GLbitfield mask);
void glClearColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);
void glClearDepth(GLdouble depth);
void glClearDepthf(GLfloat depth);
void glClearStencil(GLint s);

void glViewport(GLint x, GLint y, GLsizei width, GLsizei height);
void glScissor(GLint x, GLint y, GLsizei width, GLsizei height);

void glDepthFunc(GLenum func);
void glDepthMask(GLboolean flag);
void glDepthRange(GLdouble nearVal, GLdouble farVal);

void glBlendFunc(GLenum sfactor, GLenum dfactor);
void glBlendFuncSeparate(GLenum srcRGB, GLenum dstRGB, GLenum srcAlpha, GLenum dstAlpha);
void glBlendEquation(GLenum mode);
void glBlendEquationSeparate(GLenum modeRGB, GLenum modeAlpha);
void glBlendColor(GLfloat red, GLfloat green, GLfloat blue, GLfloat alpha);

void glCullFace(GLenum mode);
void glFrontFace(GLenum mode);
void glPolygonMode(GLenum face, GLenum mode);
void glPolygonOffset(GLfloat factor, GLfloat units);
void glLineWidth(GLfloat width);
void glPointSize(GLfloat size);

void glColorMask(GLboolean red, GLboolean green, GLboolean blue, GLboolean alpha);
void glStencilFunc(GLenum func, GLint ref, GLuint mask);
void glStencilFuncSeparate(GLenum face, GLenum func, GLint ref, GLuint mask);
void glStencilOp(GLenum sfail, GLenum dpfail, GLenum dppass);
void glStencilOpSeparate(GLenum face, GLenum sfail, GLenum dpfail, GLenum dppass);
void glStencilMask(GLuint mask);
void glStencilMaskSeparate(GLenum face, GLuint mask);
void glGenQueries(GLsizei n, GLuint *ids);
void glDeleteQueries(GLsizei n, const GLuint *ids);
void glBeginQuery(GLenum target, GLuint id);
void glEndQuery(GLenum target);
void glGetQueryObjectiv(GLuint id, GLenum pname, GLint *params);
void glGetQueryObjectuiv(GLuint id, GLenum pname, GLuint *params);
void glGetQueryObjecti64v(GLuint id, GLenum pname, GLint64 *params);
void glGetQueryObjectui64v(GLuint id, GLenum pname, GLuint64 *params);
void glQueryCounter(GLuint id, GLenum target);

GLsync glFenceSync(GLenum condition, GLbitfield flags);
GLenum glClientWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout);
void glWaitSync(GLsync sync, GLbitfield flags, GLuint64 timeout);
void glDeleteSync(GLsync sync);
void glDispatchCompute(GLuint num_groups_x, GLuint num_groups_y, GLuint num_groups_z);
void glDispatchComputeIndirect(GLintptr indirect);
void glMemoryBarrier(GLbitfield barriers);
void glGetIntegerv(GLenum pname, GLint *data);
void glGetFloatv(GLenum pname, GLfloat *data);
void glGetDoublev(GLenum pname, GLdouble *data);
void glGetBooleanv(GLenum pname, GLboolean *data);
void glGetInteger64v(GLenum pname, GLint64 *data);
const GLubyte *glGetString(GLenum name);
const GLubyte *glGetStringi(GLenum name, GLuint index);
GLenum glGetError(void);
void glFinish(void);
void glFlush(void);
void glGenTransformFeedbacks(GLsizei n, GLuint *ids);
void glBindTransformFeedback(GLenum target, GLuint id);
void glDeleteTransformFeedbacks(GLsizei n, const GLuint *ids);
void glBeginTransformFeedback(GLenum primitiveMode);
void glEndTransformFeedback(void);
void glPauseTransformFeedback(void);
void glResumeTransformFeedback(void);
void glTransformFeedbackVaryings(GLuint program, GLsizei count, const GLchar *const *varyings, GLenum bufferMode);
void glDrawTransformFeedback(GLenum mode, GLuint id);
void glDrawTransformFeedbackInstanced(GLenum mode, GLuint id, GLsizei instancecount);
void glGenSamplers(GLsizei n, GLuint *samplers);
void glDeleteSamplers(GLsizei n, const GLuint *samplers);
void glBindSampler(GLuint unit, GLuint sampler);
void glSamplerParameteri(GLuint sampler, GLenum pname, GLint param);
void glSamplerParameterf(GLuint sampler, GLenum pname, GLfloat param);
void glSamplerParameteriv(GLuint sampler, GLenum pname, const GLint *params);
void glSamplerParameterfv(GLuint sampler, GLenum pname, const GLfloat *params);
void glDebugMessageCallback(GLDEBUGPROC callback, const void *userParam);
void glDebugMessageControl(GLenum source, GLenum type, GLenum severity, GLsizei count, const GLuint *ids, GLboolean enabled);
void glDebugMessageInsert(GLenum source, GLenum type, GLuint id, GLenum severity, GLsizei length, const GLchar *buf);
void glPushDebugGroup(GLenum source, GLuint id, GLsizei length, const GLchar *message);
void glPopDebugGroup(void);
void glObjectLabel(GLenum identifier, GLuint name, GLsizei length, const GLchar *label);
GLuint glGetDebugMessageLog(GLuint count, GLsizei bufSize, GLenum *sources, GLenum *types, GLuint *ids, GLenum *severities, GLsizei *lengths, GLchar *messageLog);

int glfwInit(void);
void glfwTerminate(void);
void glfwInitHint(int hint, int value);
void glfwGetVersion(int *major, int *minor, int *rev);
const char *glfwGetVersionString(void);
int glfwGetError(const char **description);
GLFWerrorfun glfwSetErrorCallback(GLFWerrorfun callback);

void glfwWindowHint(int hint, int value);
void glfwWindowHintString(int hint, const char *value);
void glfwDefaultWindowHints(void);

GLFWwindow *glfwCreateWindow(int width, int height, const char *title, GLFWmonitor *monitor, GLFWwindow *share);
void glfwDestroyWindow(GLFWwindow *window);

int glfwWindowShouldClose(GLFWwindow *window);
void glfwSetWindowShouldClose(GLFWwindow *window, int value);

void glfwSetWindowTitle(GLFWwindow *window, const char *title);
void glfwSetWindowIcon(GLFWwindow *window, int count, const GLFWimage *images);

void glfwGetWindowPos(GLFWwindow *window, int *xpos, int *ypos);
void glfwSetWindowPos(GLFWwindow *window, int xpos, int ypos);

void glfwGetWindowSize(GLFWwindow *window, int *width, int *height);
void glfwSetWindowSize(GLFWwindow *window, int width, int height);
void glfwSetWindowSizeLimits(GLFWwindow *window, int minwidth, int minheight, int maxwidth, int maxheight);
void glfwSetWindowAspectRatio(GLFWwindow *window, int numer, int denom);

void glfwGetFramebufferSize(GLFWwindow *window, int *width, int *height);
void glfwGetWindowFrameSize(GLFWwindow *window, int *left, int *top, int *right, int *bottom);
void glfwGetWindowContentScale(GLFWwindow *window, float *xscale, float *yscale);

float glfwGetWindowOpacity(GLFWwindow *window);
void glfwSetWindowOpacity(GLFWwindow *window, float opacity);

void glfwIconifyWindow(GLFWwindow *window);
void glfwRestoreWindow(GLFWwindow *window);
void glfwMaximizeWindow(GLFWwindow *window);
void glfwShowWindow(GLFWwindow *window);
void glfwHideWindow(GLFWwindow *window);
void glfwFocusWindow(GLFWwindow *window);
void glfwRequestWindowAttention(GLFWwindow *window);

GLFWmonitor *glfwGetWindowMonitor(GLFWwindow *window);
void glfwSetWindowMonitor(GLFWwindow *window, GLFWmonitor *monitor, int xpos, int ypos, int width, int height, int refreshRate);

int glfwGetWindowAttrib(GLFWwindow *window, int attrib);
void glfwSetWindowAttrib(GLFWwindow *window, int attrib, int value);

void glfwSetWindowUserPointer(GLFWwindow *window, void *pointer);
void *glfwGetWindowUserPointer(GLFWwindow *window);

GLFWwindowposfun glfwSetWindowPosCallback(GLFWwindow *window, GLFWwindowposfun callback);
GLFWwindowsizefun glfwSetWindowSizeCallback(GLFWwindow *window, GLFWwindowsizefun callback);
GLFWwindowclosefun glfwSetWindowCloseCallback(GLFWwindow *window, GLFWwindowclosefun callback);
GLFWwindowrefreshfun glfwSetWindowRefreshCallback(GLFWwindow *window, GLFWwindowrefreshfun callback);
GLFWwindowfocusfun glfwSetWindowFocusCallback(GLFWwindow *window, GLFWwindowfocusfun callback);
GLFWwindowiconifyfun glfwSetWindowIconifyCallback(GLFWwindow *window, GLFWwindowiconifyfun callback);
GLFWwindowmaximizefun glfwSetWindowMaximizeCallback(GLFWwindow *window, GLFWwindowmaximizefun callback);
GLFWframebuffersizefun glfwSetFramebufferSizeCallback(GLFWwindow *window, GLFWframebuffersizefun callback);
GLFWwindowcontentscalefun glfwSetWindowContentScaleCallback(GLFWwindow *window, GLFWwindowcontentscalefun callback);

void glfwPollEvents(void);
void glfwWaitEvents(void);
void glfwWaitEventsTimeout(double timeout);
void glfwPostEmptyEvent(void);

int glfwGetKey(GLFWwindow *window, int key);
const char *glfwGetKeyName(int key, int scancode);
int glfwGetKeyScancode(int key);

GLFWkeyfun glfwSetKeyCallback(GLFWwindow *window, GLFWkeyfun callback);
GLFWcharfun glfwSetCharCallback(GLFWwindow *window, GLFWcharfun callback);
GLFWcharmodsfun glfwSetCharModsCallback(GLFWwindow *window, GLFWcharmodsfun callback);

int glfwGetMouseButton(GLFWwindow *window, int button);
void glfwGetCursorPos(GLFWwindow *window, double *xpos, double *ypos);
void glfwSetCursorPos(GLFWwindow *window, double xpos, double ypos);

GLFWcursor *glfwCreateCursor(const GLFWimage *image, int xhot, int yhot);
GLFWcursor *glfwCreateStandardCursor(int shape);
void glfwDestroyCursor(GLFWcursor *cursor);
void glfwSetCursor(GLFWwindow *window, GLFWcursor *cursor);

int glfwGetInputMode(GLFWwindow *window, int mode);
void glfwSetInputMode(GLFWwindow *window, int mode, int value);

GLFWmousebuttonfun glfwSetMouseButtonCallback(GLFWwindow *window, GLFWmousebuttonfun callback);
GLFWcursorposfun glfwSetCursorPosCallback(GLFWwindow *window, GLFWcursorposfun callback);
GLFWcursorenterfun glfwSetCursorEnterCallback(GLFWwindow *window, GLFWcursorenterfun callback);
GLFWscrollfun glfwSetScrollCallback(GLFWwindow *window, GLFWscrollfun callback);
GLFWdropfun glfwSetDropCallback(GLFWwindow *window, GLFWdropfun callback);

int glfwJoystickPresent(int jid);
const float *glfwGetJoystickAxes(int jid, int *count);
const unsigned char *glfwGetJoystickButtons(int jid, int *count);
const unsigned char *glfwGetJoystickHats(int jid, int *count);
const char *glfwGetJoystickName(int jid);
const char *glfwGetJoystickGUID(int jid);
void glfwSetJoystickUserPointer(int jid, void *pointer);
void *glfwGetJoystickUserPointer(int jid);
int glfwJoystickIsGamepad(int jid);
int glfwUpdateGamepadMappings(const char *string);
const char *glfwGetGamepadName(int jid);
int glfwGetGamepadState(int jid, GLFWgamepadstate *state);
GLFWjoystickfun glfwSetJoystickCallback(GLFWjoystickfun callback);

GLFWmonitor **glfwGetMonitors(int *count);
GLFWmonitor *glfwGetPrimaryMonitor(void);
void glfwGetMonitorPos(GLFWmonitor *monitor, int *xpos, int *ypos);
void glfwGetMonitorWorkarea(GLFWmonitor *monitor, int *xpos, int *ypos, int *width, int *height);
void glfwGetMonitorPhysicalSize(GLFWmonitor *monitor, int *widthMM, int *heightMM);
void glfwGetMonitorContentScale(GLFWmonitor *monitor, float *xscale, float *yscale);
const char *glfwGetMonitorName(GLFWmonitor *monitor);
void glfwSetMonitorUserPointer(GLFWmonitor *monitor, void *pointer);
void *glfwGetMonitorUserPointer(GLFWmonitor *monitor);
const GLFWvidmode *glfwGetVideoModes(GLFWmonitor *monitor, int *count);
const GLFWvidmode *glfwGetVideoMode(GLFWmonitor *monitor);
void glfwSetGamma(GLFWmonitor *monitor, float gamma);
const GLFWgammaramp *glfwGetGammaRamp(GLFWmonitor *monitor);
void glfwSetGammaRamp(GLFWmonitor *monitor, const GLFWgammaramp *ramp);
GLFWmonitorfun glfwSetMonitorCallback(GLFWmonitorfun callback);

void glfwMakeContextCurrent(GLFWwindow *window);
GLFWwindow *glfwGetCurrentContext(void);
void glfwSwapBuffers(GLFWwindow *window);
void glfwSwapInterval(int interval);
int glfwExtensionSupported(const char *extension);
GLFWglproc glfwGetProcAddress(const char *procname);

double glfwGetTime(void);
void glfwSetTime(double time);
uint64_t glfwGetTimerValue(void);
uint64_t glfwGetTimerFrequency(void);
const char *glfwGetClipboardString(GLFWwindow *window);
void glfwSetClipboardString(GLFWwindow *window, const char *string);


]]
return {
    gl = gl,
    glfw = glfw,
    GLFW = GLFW,

    GL_ARRAY_BUFFER         = GL_ARRAY_BUFFER,
    GL_ELEMENT_ARRAY_BUFFER = GL_ELEMENT_ARRAY_BUFFER,
    GL_STATIC_DRAW          = GL_STATIC_DRAW,
    GL_FLOAT                = GL_FLOAT,
    GL_UNSIGNED_INT         = GL_UNSIGNED_INT,
    GL_FALSE                = GL_FALSE,
    GL_TRUE                 = GL_TRUE,
    GL_TRIANGLES            = GL_TRIANGLES,
    GL_COLOR_BUFFER_BIT     = GL_COLOR_BUFFER_BIT,
    GL_DEPTH_BUFFER_BIT     = GL_DEPTH_BUFFER_BIT,
    GL_DEPTH_TEST           = GL_DEPTH_TEST,
    GL_LESS                 = GL_LESS,
    GL_CULL_FACE            = GL_CULL_FACE,
    GL_BACK                 = GL_BACK,
    GL_VERTEX_SHADER        = GL_VERTEX_SHADER,
    GL_FRAGMENT_SHADER      = GL_FRAGMENT_SHADER,
    GL_COMPILE_STATUS       = GL_COMPILE_STATUS,
    GL_LINK_STATUS          = GL_LINK_STATUS,
}