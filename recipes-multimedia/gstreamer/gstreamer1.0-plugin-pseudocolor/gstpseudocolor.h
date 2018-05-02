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

#ifndef _GST_PSEUDO_COLOR_H_
#define _GST_PSEUDO_COLOR_H_

#include <gst/video/video.h>
#include <gst/video/gstvideofilter.h>
#include <string.h>

G_BEGIN_DECLS

#define GST_TYPE_PSEUDO_COLOR   (gst_pseudo_color_get_type())
#define GST_PSEUDO_COLOR(obj)   (G_TYPE_CHECK_INSTANCE_CAST((obj),GST_TYPE_PSEUDO_COLOR,GstPseudoColor))
#define GST_PSEUDO_COLOR_CLASS(klass)   (G_TYPE_CHECK_CLASS_CAST((klass),GST_TYPE_PSEUDO_COLOR,GstPseudoColorClass))
#define GST_IS_PSEUDO_COLOR(obj)   (G_TYPE_CHECK_INSTANCE_TYPE((obj),GST_TYPE_PSEUDO_COLOR))
#define GST_IS_PSEUDO_COLOR_CLASS(obj)   (G_TYPE_CHECK_CLASS_TYPE((klass),GST_TYPE_PSEUDO_COLOR))

typedef struct _GstPseudoColor GstPseudoColor;
typedef struct _GstPseudoColorClass GstPseudoColorClass;

struct _GstPseudoColor
{
  GstVideoFilter base_pseudocolor;

  GMutex mutex;
  guint hue;
  gdouble saturation;

  void (*process)(GstPseudoColor* filter, GstVideoFrame * src_frame, GstVideoFrame * dest_frame);
};

struct _GstPseudoColorClass
{
  GstVideoFilterClass base_pseudocolor_class;
};

GType gst_pseudo_color_get_type (void);

G_END_DECLS

#endif /* _GST_PSEUDO_COLOR_H_ */
