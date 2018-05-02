/* GStreamer
 * Copyright (C) 2015 Samsung Electronics. All rights reserved.
 * Author: Ravi Kiran K N <ravi.kiran@samsung.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Suite 500,
 * Boston, MA 02110-1335, USA.
 */

#ifndef _GST_PSEUDO_COLOR2_H_
#define _GST_PSEUDO_COLOR2_H_

#include <gst/video/video.h>
#include <gst/base/gstbasetransform.h>
#include <string.h>
#include <stdint.h>

G_BEGIN_DECLS

#define GST_TYPE_PSEUDO_COLOR2   (gst_pseudo_color2_get_type())
#define GST_PSEUDO_COLOR2(obj)   (G_TYPE_CHECK_INSTANCE_CAST((obj),GST_TYPE_PSEUDO_COLOR2,GstPseudoColor2))
#define GST_PSEUDO_COLOR2_CLASS(klass)   (G_TYPE_CHECK_CLASS_CAST((klass),GST_TYPE_PSEUDO_COLOR2,GstPseudoColorClass))
#define GST_IS_PSEUDO_COLOR2(obj)   (G_TYPE_CHECK_INSTANCE_TYPE((obj),GST_TYPE_PSEUDO_COLOR2))
#define GST_IS_PSEUDO_COLOR2_CLASS(obj)   (G_TYPE_CHECK_CLASS_TYPE((klass),GST_TYPE_PSEUDO_COLOR2))

typedef struct _GstPseudoColor2 GstPseudoColor2;
typedef struct _GstPseudoColor2Class GstPseudoColor2Class;

struct GstPseudoColorRGB
{
    uint8_t rgb[4];
};

struct _GstPseudoColor2
{
  GstBaseTransform	element;

  GMutex mutex;

  guint invert;

  struct {
    unsigned int        bpp;
    unsigned int	stride;
    unsigned int	pix_stride;
  }			in;

  struct {
    unsigned int        bpp;
    unsigned int	stride;
    unsigned int	pix_stride;

    unsigned int        r_idx;
    unsigned int        g_idx;
    unsigned int        b_idx;

    size_t              size;
  }			out;

  enum {
    TRANSFORM_MODE_LINEAR,
    TRANSFORM_MODE_TABLE,
    TRANSFORM_MODE_ALG,
  }                     mode;

  unsigned int          width;
  unsigned int          height;

  struct GstPseudoColorRGB      *table;

  gchar *location;
  guint hue;
  gdouble saturation;
};

struct _GstPseudoColor2Class
{
  GstVideoFilterClass base_pseudocolor2_class;
};

GType gst_pseudo_color2_get_type (void);

G_END_DECLS

#endif /* _GST_PSEUDO_COLOR_H_ */
