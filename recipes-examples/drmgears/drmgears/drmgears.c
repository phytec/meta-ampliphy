/*
 * Copyright (C) 1999-2001  Brian Paul   All Rights Reserved.
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
 * BRIAN PAUL BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
 * AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
 * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

/* Changelog Phytec:
    2015-09-01: Stefan Christ <s.christ@phytec.de>
   - copy base file from src/egl/opengles2/es2gears.c in mesa-demos-8.2.0
     (License is MIT)
   - add i.MX6 and EGL initialization to main function
   - replace and remove some eglut stuff
   - add signal handler to exit on CTRL+C
    2016-06-09: Stefan Christ <s.christ@phytec.de>
   - Mask i.MX6 specific code in #ifdef's
   - Cleanup some whitespaces
    2016-07-11: Stefan Christ <s.christ@phytec.de>
   - Initialize eglSwapInterval to use double buffering.
     NOTE: For i.MX6/Freescale/NXP OpenGL libraries you must set the
     environment variable FB_MULTI_BUFFER, too. Example:
         $ FB_MULTI_BUFFER=2 es2gears
    2016-08-01: Wadim Egorov <w.egorov@phytec.de>
   - use GL_VIEWPORT to set the width and height of gears
    2016-11-22: Wadim Egorov <w.egorov@phytec.de>
   - Use drm/gbm libraries
*/

/*
 * Ported to GLES2.
 * Kristian Høgsberg <krh@bitplanet.net>
 * May 3, 2010
 * 
 * Improve GLES2 port:
 *   * Refactor gear drawing.
 *   * Use correct normals for surfaces.
 *   * Improve shader.
 *   * Use perspective projection transformation.
 *   * Add FPS count.
 *   * Add comments.
 * Alexandros Frantzis <alexandros.frantzis@linaro.org>
 * Jul 13, 2010
 */

#define GL_GLEXT_PROTOTYPES
#define EGL_EGLEXT_PROTOTYPES

#define _GNU_SOURCE

#include <errno.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/time.h>
#include <unistd.h>
#include <GLES2/gl2.h>
#include <EGL/egl.h>
#include <EGL/eglext.h>
#include <signal.h>

#include <xf86drm.h>
#include <xf86drmMode.h>
#include <gbm.h>

#define STRIPS_PER_TOOTH 7
#define VERTICES_PER_TOOTH 34
#define GEAR_VERTEX_STRIDE 6

static PFNEGLGETPLATFORMDISPLAYEXTPROC _eglGetPlatformDisplayEXT = NULL;

#define ARRAY_SIZE(arr) (sizeof(arr) / sizeof((arr)[0]))

static struct {
   struct gbm_device *dev;
   struct gbm_surface *surface;
} gbm;

static struct {
   int fd;
   drmModeModeInfo *mode;
   uint32_t crtc_id;
   uint32_t connector_id;
} drm;

struct drm_fb {
   struct gbm_bo *bo;
   uint32_t fb_id;
};

static uint32_t find_crtc_for_encoder(const drmModeRes *resources,
                  const drmModeEncoder *encoder) {
   int i;

   for (i = 0; i < resources->count_crtcs; i++) {
      /* possible_crtcs is a bitmask as described here:
       * https://dvdhrm.wordpress.com/2012/09/13/linux-drm-mode-setting-api
       */
      const uint32_t crtc_mask = 1 << i;
      const uint32_t crtc_id = resources->crtcs[i];
      if (encoder->possible_crtcs & crtc_mask) {
    return crtc_id;
      }
   }

   /* no match found */
   return -1;
}

static uint32_t find_crtc_for_connector(const drmModeRes *resources,
               const drmModeConnector *connector) {
   int i;

   for (i = 0; i < connector->count_encoders; i++) {
      const uint32_t encoder_id = connector->encoders[i];
      drmModeEncoder *encoder = drmModeGetEncoder(drm.fd, encoder_id);

      if (encoder) {
    const uint32_t crtc_id = find_crtc_for_encoder(resources, encoder);

    drmModeFreeEncoder(encoder);
    if (crtc_id != 0) {
       return crtc_id;
    }
      }
   }

   /* no match found */
   return -1;
}

static void page_flip_handler(int fd, unsigned int frame,
        unsigned int sec, unsigned int usec, void *data)
{
   int *waiting_for_flip = data;
   *waiting_for_flip = 0;
}

static void
drm_fb_destroy_callback(struct gbm_bo *bo, void *data)
{
   struct drm_fb *fb = data;
   struct gbm_device *gbm = gbm_bo_get_device(bo);

   if (fb->fb_id)
   drmModeRmFB(drm.fd, fb->fb_id);

   free(fb);
}

static struct drm_fb * drm_fb_get_from_bo(struct gbm_bo *bo)
{
   struct drm_fb *fb = gbm_bo_get_user_data(bo);
   uint32_t width, height, stride, handle;
   int ret;

   if (fb)
      return fb;

   fb = calloc(1, sizeof *fb);
   fb->bo = bo;

   width = gbm_bo_get_width(bo);
   height = gbm_bo_get_height(bo);
   stride = gbm_bo_get_stride(bo);
   handle = gbm_bo_get_handle(bo).u32;

   ret = drmModeAddFB(drm.fd, width, height, 24, 32, stride, handle, &fb->fb_id);
   if (ret) {
      printf("failed to create fb: %s\n", strerror(errno));
      free(fb);
      return NULL;
   }

   gbm_bo_set_user_data(bo, fb, drm_fb_destroy_callback);

   return fb;
}

static int init_drm(void)
{
   static const char *modules[] = {
      "exynos",
      "i915",
      "msm",
      "nouveau",
      "omapdrm",
      "radeon",
      "tegra",
      "vc4",
      "virtio_gpu",
      "vmwgfx",
      "rockchip",
   };
   drmModeRes *resources;
   drmModeConnector *connector = NULL;
   drmModeEncoder *encoder = NULL;
   int i, area;

   for (i = 0; i < ARRAY_SIZE(modules); i++) {
      printf("trying to load module %s...", modules[i]);
      drm.fd = drmOpen(modules[i], NULL);
      if (drm.fd < 0) {
         printf("failed.\n");
      } else {
         printf("success.\n");
         break;
      }
   }

   if (drm.fd < 0) {
      printf("could not open drm device\n");
      return -1;
   }

   resources = drmModeGetResources(drm.fd);
   if (!resources) {
      printf("drmModeGetResources failed: %s\n", strerror(errno));
      return -1;
   }

   /* find a connected connector: */
   for (i = 0; i < resources->count_connectors; i++) {
      connector = drmModeGetConnector(drm.fd, resources->connectors[i]);
      if (connector->connection == DRM_MODE_CONNECTED) {
         /* it's connected, let's use this! */
         break;
      }
      drmModeFreeConnector(connector);
      connector = NULL;
   }

   if (!connector) {
      /* we could be fancy and listen for hotplug events and wait for
       * a connector..
       */
      printf("no connected connector!\n");
      return -1;
   }

   /* find prefered mode or the highest resolution mode: */
   for (i = 0, area = 0; i < connector->count_modes; i++) {
      drmModeModeInfo *current_mode = &connector->modes[i];

      if (current_mode->type & DRM_MODE_TYPE_PREFERRED) {
         drm.mode = current_mode;
      }

      int current_area = current_mode->hdisplay * current_mode->vdisplay;
      if (current_area > area) {
         drm.mode = current_mode;
         area = current_area;
      }
   }

   if (!drm.mode) {
      printf("could not find mode!\n");
      return -1;
   }

   /* find encoder: */
   for (i = 0; i < resources->count_encoders; i++) {
      encoder = drmModeGetEncoder(drm.fd, resources->encoders[i]);
      if (encoder->encoder_id == connector->encoder_id)
         break;
      drmModeFreeEncoder(encoder);
      encoder = NULL;
   }

   if (encoder) {
      drm.crtc_id = encoder->crtc_id;
   } else {
      uint32_t crtc_id = find_crtc_for_connector(resources, connector);
      if (crtc_id == 0) {
         printf("no crtc found!\n");
         return -1;
      }

      drm.crtc_id = crtc_id;
   }

   drm.connector_id = connector->connector_id;

   return 0;
}


static int init_gbm(void)
{
   gbm.dev = gbm_create_device(drm.fd);

   gbm.surface = gbm_surface_create(gbm.dev,
         drm.mode->hdisplay, drm.mode->vdisplay,
         GBM_FORMAT_XRGB8888,
         GBM_BO_USE_SCANOUT | GBM_BO_USE_RENDERING);
   if (!gbm.surface) {
      printf("failed to create gbm surface\n");
      return -1;
   }

   return 0;
}

/**
 * Struct describing the vertices in triangle strip
 */
struct vertex_strip {
   /** The first vertex in the strip */
   GLint first;
   /** The number of consecutive vertices in the strip after the first */
   GLint count;
};

/* Each vertex consist of GEAR_VERTEX_STRIDE GLfloat attributes */
typedef GLfloat GearVertex[GEAR_VERTEX_STRIDE];

/**
 * Struct representing a gear.
 */
struct gear {
   /** The array of vertices comprising the gear */
   GearVertex *vertices;
   /** The number of vertices comprising the gear */
   int nvertices;
   /** The array of triangle strips comprising the gear */
   struct vertex_strip *strips;
   /** The number of triangle strips comprising the gear */
   int nstrips;
   /** The Vertex Buffer Object holding the vertices in the graphics card */
   GLuint vbo;
};

/** The view rotation [x, y, z] */
static GLfloat view_rot[3] = { 20.0, 30.0, 0.0 };
/** The gears */
static struct gear *gear1, *gear2, *gear3;
/** The current gear rotation angle */
static GLfloat angle = 0.0;
/** The location of the shader uniforms */
static GLuint ModelViewProjectionMatrix_location,
         NormalMatrix_location,
         LightSourcePosition_location,
         MaterialColor_location;
/** The projection matrix */
static GLfloat ProjectionMatrix[16];
/** The direction of the directional light for the scene */
static const GLfloat LightSourcePosition[4] = { 5.0, 5.0, 10.0, 1.0};

/** 
 * Fills a gear vertex.
 * 
 * @param v the vertex to fill
 * @param x the x coordinate
 * @param y the y coordinate
 * @param z the z coortinate
 * @param n pointer to the normal table 
 * 
 * @return the operation error code
 */
static GearVertex *
vert(GearVertex *v, GLfloat x, GLfloat y, GLfloat z, GLfloat n[3])
{
   v[0][0] = x;
   v[0][1] = y;
   v[0][2] = z;
   v[0][3] = n[0];
   v[0][4] = n[1];
   v[0][5] = n[2];

   return v + 1;
}

/**
 *  Create a gear wheel.
 * 
 *  @param inner_radius radius of hole at center
 *  @param outer_radius radius at center of teeth
 *  @param width width of gear
 *  @param teeth number of teeth
 *  @param tooth_depth depth of tooth
 *  
 *  @return pointer to the constructed struct gear
 */
static struct gear *
create_gear(GLfloat inner_radius, GLfloat outer_radius, GLfloat width,
      GLint teeth, GLfloat tooth_depth)
{
   GLfloat r0, r1, r2;
   GLfloat da;
   GearVertex *v;
   struct gear *gear;
   double s[5], c[5];
   GLfloat normal[3];
   int cur_strip = 0;
   int i;

   /* Allocate memory for the gear */
   gear = malloc(sizeof *gear);
   if (gear == NULL)
      return NULL;

   /* Calculate the radii used in the gear */
   r0 = inner_radius;
   r1 = outer_radius - tooth_depth / 2.0;
   r2 = outer_radius + tooth_depth / 2.0;

   da = 2.0 * M_PI / teeth / 4.0;

   /* Allocate memory for the triangle strip information */
   gear->nstrips = STRIPS_PER_TOOTH * teeth;
   gear->strips = calloc(gear->nstrips, sizeof (*gear->strips));

   /* Allocate memory for the vertices */
   gear->vertices = calloc(VERTICES_PER_TOOTH * teeth, sizeof(*gear->vertices));
   v = gear->vertices;

   for (i = 0; i < teeth; i++) {
      /* Calculate needed sin/cos for varius angles */
      sincos(i * 2.0 * M_PI / teeth, &s[0], &c[0]);
      sincos(i * 2.0 * M_PI / teeth + da, &s[1], &c[1]);
      sincos(i * 2.0 * M_PI / teeth + da * 2, &s[2], &c[2]);
      sincos(i * 2.0 * M_PI / teeth + da * 3, &s[3], &c[3]);
      sincos(i * 2.0 * M_PI / teeth + da * 4, &s[4], &c[4]);

      /* A set of macros for making the creation of the gears easier */
#define  GEAR_POINT(r, da) { (r) * c[(da)], (r) * s[(da)] }
#define  SET_NORMAL(x, y, z) do { \
   normal[0] = (x); normal[1] = (y); normal[2] = (z); \
} while(0)

#define  GEAR_VERT(v, point, sign) vert((v), p[(point)].x, p[(point)].y, (sign) * width * 0.5, normal)

#define START_STRIP do { \
   gear->strips[cur_strip].first = v - gear->vertices; \
} while(0);

#define END_STRIP do { \
   int _tmp = (v - gear->vertices); \
   gear->strips[cur_strip].count = _tmp - gear->strips[cur_strip].first; \
   cur_strip++; \
} while (0)

#define QUAD_WITH_NORMAL(p1, p2) do { \
   SET_NORMAL((p[(p1)].y - p[(p2)].y), -(p[(p1)].x - p[(p2)].x), 0); \
   v = GEAR_VERT(v, (p1), -1); \
   v = GEAR_VERT(v, (p1), 1); \
   v = GEAR_VERT(v, (p2), -1); \
   v = GEAR_VERT(v, (p2), 1); \
} while(0)

      struct point {
    GLfloat x;
    GLfloat y;
      };

      /* Create the 7 points (only x,y coords) used to draw a tooth */
      struct point p[7] = {
    GEAR_POINT(r2, 1), // 0
    GEAR_POINT(r2, 2), // 1
    GEAR_POINT(r1, 0), // 2
    GEAR_POINT(r1, 3), // 3
    GEAR_POINT(r0, 0), // 4
    GEAR_POINT(r1, 4), // 5
    GEAR_POINT(r0, 4), // 6
      };

      /* Front face */
      START_STRIP;
      SET_NORMAL(0, 0, 1.0);
      v = GEAR_VERT(v, 0, +1);
      v = GEAR_VERT(v, 1, +1);
      v = GEAR_VERT(v, 2, +1);
      v = GEAR_VERT(v, 3, +1);
      v = GEAR_VERT(v, 4, +1);
      v = GEAR_VERT(v, 5, +1);
      v = GEAR_VERT(v, 6, +1);
      END_STRIP;

      /* Inner face */
      START_STRIP;
      QUAD_WITH_NORMAL(4, 6);
      END_STRIP;

      /* Back face */
      START_STRIP;
      SET_NORMAL(0, 0, -1.0);
      v = GEAR_VERT(v, 6, -1);
      v = GEAR_VERT(v, 5, -1);
      v = GEAR_VERT(v, 4, -1);
      v = GEAR_VERT(v, 3, -1);
      v = GEAR_VERT(v, 2, -1);
      v = GEAR_VERT(v, 1, -1);
      v = GEAR_VERT(v, 0, -1);
      END_STRIP;

      /* Outer face */
      START_STRIP;
      QUAD_WITH_NORMAL(0, 2);
      END_STRIP;

      START_STRIP;
      QUAD_WITH_NORMAL(1, 0);
      END_STRIP;

      START_STRIP;
      QUAD_WITH_NORMAL(3, 1);
      END_STRIP;

      START_STRIP;
      QUAD_WITH_NORMAL(5, 3);
      END_STRIP;
   }

   gear->nvertices = (v - gear->vertices);

   /* Store the vertices in a vertex buffer object (VBO) */
   glGenBuffers(1, &gear->vbo);
   glBindBuffer(GL_ARRAY_BUFFER, gear->vbo);
   glBufferData(GL_ARRAY_BUFFER, gear->nvertices * sizeof(GearVertex),
    gear->vertices, GL_STATIC_DRAW);

   return gear;
}

/** 
 * Multiplies two 4x4 matrices.
 * 
 * The result is stored in matrix m.
 * 
 * @param m the first matrix to multiply
 * @param n the second matrix to multiply
 */
static void
multiply(GLfloat *m, const GLfloat *n)
{
   GLfloat tmp[16];
   const GLfloat *row, *column;
   div_t d;
   int i, j;

   for (i = 0; i < 16; i++) {
      tmp[i] = 0;
      d = div(i, 4);
      row = n + d.quot * 4;
      column = m + d.rem;
      for (j = 0; j < 4; j++)
    tmp[i] += row[j] * column[j * 4];
   }
   memcpy(m, &tmp, sizeof tmp);
}

/** 
 * Rotates a 4x4 matrix.
 * 
 * @param[in,out] m the matrix to rotate
 * @param angle the angle to rotate
 * @param x the x component of the direction to rotate to
 * @param y the y component of the direction to rotate to
 * @param z the z component of the direction to rotate to
 */
static void
rotate(GLfloat *m, GLfloat angle, GLfloat x, GLfloat y, GLfloat z)
{
   double s, c;

   sincos(angle, &s, &c);
   GLfloat r[16] = {
      x * x * (1 - c) + c,     y * x * (1 - c) + z * s, x * z * (1 - c) - y * s, 0,
      x * y * (1 - c) - z * s, y * y * (1 - c) + c,     y * z * (1 - c) + x * s, 0, 
      x * z * (1 - c) + y * s, y * z * (1 - c) - x * s, z * z * (1 - c) + c,     0,
      0, 0, 0, 1
   };

   multiply(m, r);
}


/** 
 * Translates a 4x4 matrix.
 * 
 * @param[in,out] m the matrix to translate
 * @param x the x component of the direction to translate to
 * @param y the y component of the direction to translate to
 * @param z the z component of the direction to translate to
 */
static void
translate(GLfloat *m, GLfloat x, GLfloat y, GLfloat z)
{
   GLfloat t[16] = { 1, 0, 0, 0,  0, 1, 0, 0,  0, 0, 1, 0,  x, y, z, 1 };

   multiply(m, t);
}

/** 
 * Creates an identity 4x4 matrix.
 * 
 * @param m the matrix make an identity matrix
 */
static void
identity(GLfloat *m)
{
   GLfloat t[16] = {
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      0.0, 0.0, 0.0, 1.0,
   };

   memcpy(m, t, sizeof(t));
}

/** 
 * Transposes a 4x4 matrix.
 *
 * @param m the matrix to transpose
 */
static void 
transpose(GLfloat *m)
{
   GLfloat t[16] = {
      m[0], m[4], m[8],  m[12],
      m[1], m[5], m[9],  m[13],
      m[2], m[6], m[10], m[14],
      m[3], m[7], m[11], m[15]};

   memcpy(m, t, sizeof(t));
}

/**
 * Inverts a 4x4 matrix.
 *
 * This function can currently handle only pure translation-rotation matrices.
 * Read http://www.gamedev.net/community/forums/topic.asp?topic_id=425118
 * for an explanation.
 */
static void
invert(GLfloat *m)
{
   GLfloat t[16];
   identity(t);

   // Extract and invert the translation part 't'. The inverse of a
   // translation matrix can be calculated by negating the translation
   // coordinates.
   t[12] = -m[12]; t[13] = -m[13]; t[14] = -m[14];

   // Invert the rotation part 'r'. The inverse of a rotation matrix is
   // equal to its transpose.
   m[12] = m[13] = m[14] = 0;
   transpose(m);

   // inv(m) = inv(r) * inv(t)
   multiply(m, t);
}

/** 
 * Calculate a perspective projection transformation.
 * 
 * @param m the matrix to save the transformation in
 * @param fovy the field of view in the y direction
 * @param aspect the view aspect ratio
 * @param zNear the near clipping plane
 * @param zFar the far clipping plane
 */
void perspective(GLfloat *m, GLfloat fovy, GLfloat aspect, GLfloat zNear, GLfloat zFar)
{
   GLfloat tmp[16];
   identity(tmp);

   double sine, cosine, cotangent, deltaZ;
   GLfloat radians = fovy / 2 * M_PI / 180;

   deltaZ = zFar - zNear;
   sincos(radians, &sine, &cosine);

   if ((deltaZ == 0) || (sine == 0) || (aspect == 0))
      return;

   cotangent = cosine / sine;

   tmp[0] = cotangent / aspect;
   tmp[5] = cotangent;
   tmp[10] = -(zFar + zNear) / deltaZ;
   tmp[11] = -1;
   tmp[14] = -2 * zNear * zFar / deltaZ;
   tmp[15] = 0;

   memcpy(m, tmp, sizeof(tmp));
}

/**
 * Draws a gear.
 *
 * @param gear the gear to draw
 * @param transform the current transformation matrix
 * @param x the x position to draw the gear at
 * @param y the y position to draw the gear at
 * @param angle the rotation angle of the gear
 * @param color the color of the gear
 */
static void
draw_gear(struct gear *gear, GLfloat *transform,
      GLfloat x, GLfloat y, GLfloat angle, const GLfloat color[4])
{
   GLfloat model_view[16];
   GLfloat normal_matrix[16];
   GLfloat model_view_projection[16];

   /* Translate and rotate the gear */
   memcpy(model_view, transform, sizeof (model_view));
   translate(model_view, x, y, 0);
   rotate(model_view, 2 * M_PI * angle / 360.0, 0, 0, 1);

   /* Create and set the ModelViewProjectionMatrix */
   memcpy(model_view_projection, ProjectionMatrix, sizeof(model_view_projection));
   multiply(model_view_projection, model_view);

   glUniformMatrix4fv(ModelViewProjectionMatrix_location, 1, GL_FALSE,
            model_view_projection);

   /* 
    * Create and set the NormalMatrix. It's the inverse transpose of the
    * ModelView matrix.
    */
   memcpy(normal_matrix, model_view, sizeof (normal_matrix));
   invert(normal_matrix);
   transpose(normal_matrix);
   glUniformMatrix4fv(NormalMatrix_location, 1, GL_FALSE, normal_matrix);

   /* Set the gear color */
   glUniform4fv(MaterialColor_location, 1, color);

   /* Set the vertex buffer object to use */
   glBindBuffer(GL_ARRAY_BUFFER, gear->vbo);

   /* Set up the position of the attributes in the vertex buffer object */
   glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE,
    6 * sizeof(GLfloat), NULL);
   glVertexAttribPointer(1, 3, GL_FLOAT, GL_FALSE,
    6 * sizeof(GLfloat), (GLfloat *) 0 + 3);

   /* Enable the attributes */
   glEnableVertexAttribArray(0);
   glEnableVertexAttribArray(1);

   /* Draw the triangle strips that comprise the gear */
   int n;
   for (n = 0; n < gear->nstrips; n++)
      glDrawArrays(GL_TRIANGLE_STRIP, gear->strips[n].first, gear->strips[n].count);

   /* Disable the attributes */
   glDisableVertexAttribArray(1);
   glDisableVertexAttribArray(0);
}

/** 
 * Draws the gears.
 */
static void
gears_draw(void)
{
   const static GLfloat red[4] = { 0.8, 0.1, 0.0, 1.0 };
   const static GLfloat green[4] = { 0.0, 0.8, 0.2, 1.0 };
   const static GLfloat blue[4] = { 0.2, 0.2, 1.0, 1.0 };
   GLfloat transform[16];
   identity(transform);

   glClearColor(0.0, 0.0, 0.0, 0.0);
   glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

   /* Translate and rotate the view */
   translate(transform, 0, 0, -20);
   rotate(transform, 2 * M_PI * view_rot[0] / 360.0, 1, 0, 0);
   rotate(transform, 2 * M_PI * view_rot[1] / 360.0, 0, 1, 0);
   rotate(transform, 2 * M_PI * view_rot[2] / 360.0, 0, 0, 1);

   /* Draw the gears */
   draw_gear(gear1, transform, -3.0, -2.0, angle, red);
   draw_gear(gear2, transform, 3.1, -2.0, -2 * angle - 9.0, green);
   draw_gear(gear3, transform, -3.1, 4.2, -2 * angle - 25.0, blue);
}

/** 
 * Handles a new window size or exposure.
 * 
 * @param width the window width
 * @param height the window height
 */
static void
gears_reshape(int width, int height)
{
   /* Update the projection matrix */
   perspective(ProjectionMatrix, 60.0, width / (float)height, 1.0, 1024.0);

   /* Set the viewport */
   glViewport(0, 0, (GLint) width, (GLint) height);
}

/** 
 * Handles special eglut events.
 * 
 * @param special the event to handle.
 */
/* s.christ@phytec.de: no keyboard handling for now
static void
gears_special(int special)
{
   switch (special) {
      case EGLUT_KEY_LEFT:
    view_rot[1] += 5.0;
    break;
      case EGLUT_KEY_RIGHT:
    view_rot[1] -= 5.0;
    break;
      case EGLUT_KEY_UP:
    view_rot[0] += 5.0;
    break;
      case EGLUT_KEY_DOWN:
    view_rot[0] -= 5.0;
    break;
   }
}
*/

/* copied from mesa-demos/src/egl/eglut/eglut.c */
static int start_time;
int _eglutNow(void)
{
   struct timeval tv;
#ifdef __VMS
   (void) gettimeofday(&tv, NULL );
#else
   struct timezone tz;
   (void) gettimeofday(&tv, &tz);
#endif
   return tv.tv_sec * 1000 + tv.tv_usec / 1000;
}


static void
gears_idle(void)
{
   static int frames = 0;
   static double tRot0 = -1.0, tRate0 = -1.0;
   double dt, t = (_eglutNow() - start_time) / 1000.0;

   if (tRot0 < 0.0)
      tRot0 = t;
   dt = t - tRot0;
   tRot0 = t;

   /* advance rotation for next frame */
   angle += 70.0 * dt;  /* 70 degrees per second */
   if (angle > 3600.0)
      angle -= 3600.0;

   frames++;

   if (tRate0 < 0.0)
      tRate0 = t;
   if (t - tRate0 >= 5.0) {
      GLfloat seconds = t - tRate0;
      GLfloat fps = frames / seconds;
      printf("%d frames in %3.1f seconds = %6.3f FPS\n", frames, seconds,
       fps);
      tRate0 = t;
      frames = 0;
   }
}

static const char vertex_shader[] =
"attribute vec3 position;\n"
"attribute vec3 normal;\n"
"\n"
"uniform mat4 ModelViewProjectionMatrix;\n"
"uniform mat4 NormalMatrix;\n"
"uniform vec4 LightSourcePosition;\n"
"uniform vec4 MaterialColor;\n"
"\n"
"varying vec4 Color;\n"
"\n"
"void main(void)\n"
"{\n"
"    // Transform the normal to eye coordinates\n"
"    vec3 N = normalize(vec3(NormalMatrix * vec4(normal, 1.0)));\n"
"\n"
"    // The LightSourcePosition is actually its direction for directional light\n"
"    vec3 L = normalize(LightSourcePosition.xyz);\n"
"\n"
"    // Multiply the diffuse value by the vertex color (which is fixed in this case)\n"
"    // to get the actual color that we will use to draw this vertex with\n"
"    float diffuse = max(dot(N, L), 0.0);\n"
"    Color = diffuse * MaterialColor;\n"
"\n"
"    // Transform the position to clip coordinates\n"
"    gl_Position = ModelViewProjectionMatrix * vec4(position, 1.0);\n"
"}";

static const char fragment_shader[] =
"precision mediump float;\n"
"varying vec4 Color;\n"
"\n"
"void main(void)\n"
"{\n"
"    gl_FragColor = Color;\n"
"}";

static void
gears_init(void)
{
   GLuint v, f, program;
   const char *p;
   char msg[512];

   glEnable(GL_CULL_FACE);
   glEnable(GL_DEPTH_TEST);

   /* Compile the vertex shader */
   p = vertex_shader;
   v = glCreateShader(GL_VERTEX_SHADER);
   glShaderSource(v, 1, &p, NULL);
   glCompileShader(v);
   glGetShaderInfoLog(v, sizeof msg, NULL, msg);
   printf("vertex shader info: %s\n", msg);

   /* Compile the fragment shader */
   p = fragment_shader;
   f = glCreateShader(GL_FRAGMENT_SHADER);
   glShaderSource(f, 1, &p, NULL);
   glCompileShader(f);
   glGetShaderInfoLog(f, sizeof msg, NULL, msg);
   printf("fragment shader info: %s\n", msg);

   /* Create and link the shader program */
   program = glCreateProgram();
   glAttachShader(program, v);
   glAttachShader(program, f);
   glBindAttribLocation(program, 0, "position");
   glBindAttribLocation(program, 1, "normal");

   glLinkProgram(program);
   glGetProgramInfoLog(program, sizeof msg, NULL, msg);
   printf("info: %s\n", msg);

   /* Enable the shaders */
   glUseProgram(program);

   /* Get the locations of the uniforms so we can access them */
   ModelViewProjectionMatrix_location = glGetUniformLocation(program, "ModelViewProjectionMatrix");
   NormalMatrix_location = glGetUniformLocation(program, "NormalMatrix");
   LightSourcePosition_location = glGetUniformLocation(program, "LightSourcePosition");
   MaterialColor_location = glGetUniformLocation(program, "MaterialColor");

   /* Set the LightSourcePosition uniform which is constant throught the program */
   glUniform4fv(LightSourcePosition_location, 1, LightSourcePosition);

   /* make the gears */
   gear1 = create_gear(1.0, 4.0, 1.0, 20, 0.7);
   gear2 = create_gear(0.5, 2.0, 2.0, 10, 0.7);
   gear3 = create_gear(1.3, 2.0, 0.5, 10, 0.7);
}


volatile int quit = 0;
void term(int signum)
{
   quit = 1;
}




int
main(int argc, char *argv[])
{
   int ret;
   GLint vp[4];
   EGLNativeWindowType native_window = 0;

   struct gbm_bo *bo;
   struct drm_fb *fb;
	EGLDisplay egl_display;
   fd_set fds;
   drmEventContext evctx = {
         .version = DRM_EVENT_CONTEXT_VERSION,
         .page_flip_handler = page_flip_handler,
   };


   ret = init_drm();
   if (ret) {
      printf("failed to initialize DRM\n");
      return ret;
   }


   FD_ZERO(&fds);
   FD_SET(0, &fds);
   FD_SET(drm.fd, &fds);

   ret = init_gbm();
   if (ret) {
      printf("failed to initialize GBM\n");
      return ret;
   }

   _eglGetPlatformDisplayEXT = (void *) eglGetProcAddress("eglGetPlatformDisplayEXT");
   if (!_eglGetPlatformDisplayEXT) {
      printf("could not get address of eglGetPlatformDisplayEXT\n");
      return -1;
   }

   /* generic EGL initialization */
   egl_display = _eglGetPlatformDisplayEXT(EGL_PLATFORM_GBM_KHR, gbm.dev, NULL);
   if (egl_display == EGL_NO_DISPLAY) {
      fprintf(stderr, "Got no EGL display.\n");
      return 1;
   }
   ret = eglInitialize(egl_display, NULL, NULL);
   if (!ret) {
      fprintf(stderr, "Unable to initialize EGL");
      return 1;
   }
 
   /* same attributes as in from mesa-demos/./src/egl/eglut/eglut.c */
   EGLint attr[] = {
     EGL_RED_SIZE,
     1,
     EGL_GREEN_SIZE,
     1,
     EGL_BLUE_SIZE,
     1,
     EGL_DEPTH_SIZE,
     1,
     EGL_SURFACE_TYPE,
     EGL_WINDOW_BIT, /* try same as x11 and wayland */
     EGL_RENDERABLE_TYPE,
     EGL_OPENGL_ES2_BIT,
     EGL_NONE
   };
 
   EGLConfig config;
   EGLint num_config;
   if (!eglChooseConfig(egl_display, attr, &config, 1, &num_config)) {
      fprintf(stderr, "Failed to choose config (eglError: %d)\n", eglGetError());
      return 1;
   }
 
   if (num_config != 1) {
      fprintf(stderr, "Wrong config\n");
      return 1;
   }
 
   EGLSurface egl_surface;
   egl_surface = eglCreateWindowSurface(egl_display, config, gbm.surface, NULL);
   if (egl_surface == EGL_NO_SURFACE) {
      fprintf(stderr, "Unable to create EGL surface (eglError: %d)\n", eglGetError());
      return 1;
   }
 
   /* egl-contexts collect all state descriptions needed required for operation */
   EGLint context_attribs[] = {
      EGL_CONTEXT_CLIENT_VERSION, 2,
      EGL_NONE
   };

   EGLContext egl_context = eglCreateContext(egl_display, config, EGL_NO_CONTEXT, context_attribs);
   if (egl_context == EGL_NO_CONTEXT) {
      fprintf(stderr, "Unable to create EGL context (eglError: %d)\n", eglGetError());
      return 1;
   }
 
   /* associate the egl-context with the egl-surface */
   eglMakeCurrent(egl_display, egl_surface, egl_surface, egl_context);

   /* Enable display synchronisation and buffering
    *    0 - no sync and no buffering
    *    1 - sync and double buffering
    *    2 - sync and triple buffering
    */
   if (eglSwapInterval(egl_display, 1) != EGL_TRUE) {
      fprintf(stderr, "Unable to initialize eglSwapInterval (eglError: %d)\n", eglGetError());
      return 1;
   }

   /* Setting up SIGTERM, SIGINT and SIGQUIT handler */
   struct sigaction action;
   memset(&action, 0, sizeof(struct sigaction));
   action.sa_handler = term;
   sigaction(SIGTERM, &action, NULL);
   sigaction(SIGQUIT, &action, NULL);
   sigaction(SIGINT, &action, NULL); /* for CTRL+C */

   /* Demo init stuff */
   gears_init();

   int width, height;
   glGetIntegerv(GL_VIEWPORT, vp);
   height = vp[3];
   width = vp[2];
   gears_reshape(width, height);

   /* Simple mainloop without keyboard events */
   start_time = _eglutNow();
   quit = 0;

     eglSwapBuffers(egl_display, egl_surface);
   bo = gbm_surface_lock_front_buffer(gbm.surface);
   fb = drm_fb_get_from_bo(bo);

   /* set mode: */
   ret = drmModeSetCrtc(drm.fd, drm.crtc_id, fb->fb_id, 0, 0,
         &drm.connector_id, 1, drm.mode);
   if (ret) {
      printf("failed to set mode: %s\n", strerror(errno));
      return ret;
   }


   while(!quit) {
      struct gbm_bo *next_bo;
      int waiting_for_flip = 1;

      gears_draw();
      gears_idle();
      eglSwapBuffers(egl_display, egl_surface);
      next_bo = gbm_surface_lock_front_buffer(gbm.surface);
      fb = drm_fb_get_from_bo(next_bo);
      /*
       * Here you could also update drm plane layers if you want
       * hw composition
       */

      ret = drmModePageFlip(drm.fd, drm.crtc_id, fb->fb_id,
            DRM_MODE_PAGE_FLIP_EVENT, &waiting_for_flip);
      if (ret) {
         printf("failed to queue page flip: %s\n", strerror(errno));
         return -1;
      }

      while (waiting_for_flip) {
         ret = select(drm.fd + 1, &fds, NULL, NULL, NULL);
         if (ret < 0) {
            printf("select err: %s\n", strerror(errno));
            return ret;
         } else if (ret == 0) {
            printf("select timeout!\n");
            return -1;
         } else if (FD_ISSET(0, &fds)) {
            printf("user interrupted!\n");
            break;
         }
         drmHandleEvent(drm.fd, &evctx);
      }
      /* release last buffer to render on again: */
      gbm_surface_release_buffer(gbm.surface, bo);
      bo = next_bo;
   }

   printf("Cleaning up!\n");

   /* EGL generic cleanup */
   eglDestroyContext(egl_display, egl_context);
   eglDestroySurface(egl_display, egl_surface);
   eglTerminate(egl_display);
   return 0;
}
