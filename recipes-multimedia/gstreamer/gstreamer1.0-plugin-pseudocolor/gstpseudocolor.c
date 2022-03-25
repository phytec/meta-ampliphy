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
/**
 * SECTION:element-gstpseudocolor
 *
 * The pseudocolor element applies pseudo-color effect on gray scale image.
 * http://en.wikipedia.org/wiki/False_color#Pseudocolor
 *
 * <refsect2>
 * <title>Example launch line</title>
 * |[
 * gst-launch -v videotestsrc ! pseudocolor hue=120 saturation=1.0 ! videoconvert ! autovideosink
 * ]|
 * This pipeline adds green color to input grayscale image.
 *
 * Hue in degrees : 0 - Red, 120 - Green, 240 - Blue : (HSL model)
 * Saturation : 0.0 - 1.0 indicate colorfulness.
 *
 * </refsect2>
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gst/gst.h>
#include <gst/video/video.h>
#include <gst/video/gstvideofilter.h>
#include "gstpseudocolor.h"

#define DEFAULT_HUE 100
#define DEFAULT_SATURATION 0.5

GST_DEBUG_CATEGORY_STATIC (gst_pseudo_color_debug_category);
#define GST_CAT_DEFAULT gst_pseudo_color_debug_category


static gboolean
gst_pseudo_color_set_info (GstVideoFilter * vfilter, GstCaps * in,
    GstVideoInfo * in_info, GstCaps * out, GstVideoInfo * out_info);

static GstFlowReturn gst_pseudo_color_transform_frame (GstVideoFilter * filter,
    GstVideoFrame * inframe, GstVideoFrame * outframe);

static void gst_pseudo_color_set_property (GObject * object, guint prop_id,
    const GValue * value, GParamSpec * pspec);

static void gst_pseudo_color_get_property (GObject * object, guint prop_id,
    GValue * value, GParamSpec * pspec);

static void gst_pseudo_color_process_rgb (GstPseudoColor * pseudocolor,
    GstVideoFrame * src_frame, GstVideoFrame * dest_frame);


enum
{
  PROP_0,
  PROP_HUE,
  PROP_SATURATION,
};

/* pad templates */

#define VIDEO_SRC_CAPS \
    GST_VIDEO_CAPS_MAKE("{ RGB }")

#define VIDEO_SINK_CAPS \
    GST_VIDEO_CAPS_MAKE("{ GRAY8 }")


/* class initialization */
#define gst_pseudo_color_parent_class parent_class
G_DEFINE_TYPE_WITH_CODE (GstPseudoColor, gst_pseudo_color,
    GST_TYPE_VIDEO_FILTER,
    GST_DEBUG_CATEGORY_INIT (gst_pseudo_color_debug_category, "pseudocolor", 0,
        "debug category for pseudocolor element"));


static void
gst_pseudo_color_finalize (GObject * object)
{
  GstPseudoColor *pseudocolor = GST_PSEUDO_COLOR (object);

  g_mutex_clear (&pseudocolor->mutex);

  G_OBJECT_CLASS (parent_class)->finalize (object);
}

static gboolean
gst_pseudo_color_set_info (GstVideoFilter * vfilter, GstCaps * in,
    GstVideoInfo * in_info, GstCaps * out, GstVideoInfo * out_info)
{
  GstPseudoColor *pseudocolor = GST_PSEUDO_COLOR (vfilter);

  g_mutex_lock (&pseudocolor->mutex);

  switch (GST_VIDEO_INFO_FORMAT (out_info)) {
    case GST_VIDEO_FORMAT_RGB:
      pseudocolor->process = gst_pseudo_color_process_rgb;
      break;
    default:
      pseudocolor->process = NULL;
      break;
  }

  g_mutex_unlock (&pseudocolor->mutex);

  return pseudocolor->process != NULL;
}

static gboolean
gst_pseudo_color_check_input_format (const GValue * val, gboolean * is_gray,
    gboolean * is_rgb)
{
  const gchar *str;
  if ((str = g_value_get_string (val))) {
    if (strcmp (str, "GRAY8") == 0) {
      *is_gray = TRUE;
    } else if (strcmp (str, "RGB") == 0) {
      *is_rgb = TRUE;
    }
  }
  return (*is_gray || *is_rgb);
}

static GstCaps *
gst_pseudo_color_transform_caps (GstBaseTransform * trans,
    GstPadDirection direction, GstCaps * from, GstCaps * filter)
{
  GstPseudoColor *pseudocolor = GST_PSEUDO_COLOR (trans);

  GstCaps *to, *ret;
  GstCaps *templ;
  GstStructure *structure;
  GstPad *other;
  gint i, j;

  to = gst_caps_new_empty ();
  for (i = 0; i < gst_caps_get_size (from); i++) {
    const GValue *fval, *lval;
    GValue list = { 0, };
    GValue val = { 0, };
    gboolean is_gray = FALSE, is_rgb = FALSE;

    structure = gst_structure_copy (gst_caps_get_structure (from, i));

    /* Supported conversions:
     * GRAY8->RGB
     */
    fval = gst_structure_get_value (structure, "format");
    if (fval && GST_VALUE_HOLDS_LIST (fval)) {
      for (j = 0; j < gst_value_list_get_size (fval); j++) {
        lval = gst_value_list_get_value (fval, j);
        if (gst_pseudo_color_check_input_format (lval, &is_gray, &is_rgb))
          break;
      }
    } else if (fval && G_VALUE_HOLDS_STRING (fval)) {
      gst_pseudo_color_check_input_format (fval, &is_gray, &is_rgb);
    }

    if (is_gray || is_rgb) {
      g_value_init (&list, GST_TYPE_LIST);
      g_value_init (&val, G_TYPE_STRING);

      if (is_gray) {
        g_value_set_string (&val, "RGB");
        gst_value_list_append_value (&list, &val);
        g_value_unset (&val);
      }
      if (is_rgb) {
        g_value_set_string (&val, "GRAY8");
        gst_value_list_append_value (&list, &val);
        g_value_unset (&val);
      }

      gst_value_list_merge (&val, fval, &list);
      gst_structure_set_value (structure, "format", &val);
      g_value_unset (&val);
      g_value_unset (&list);

    }

    gst_caps_append_structure (to, structure);
  }

  /* filter the 'to' caps (transform caps) against allowed caps on the pad */
  other = (direction == GST_PAD_SINK) ? trans->srcpad : trans->sinkpad;
  templ = gst_pad_get_pad_template_caps (other);

  ret = gst_caps_intersect (to, templ);

  gst_caps_unref (to);
  gst_caps_unref (templ);

  GST_DEBUG_OBJECT (pseudocolor, "direction %d, transformed %" GST_PTR_FORMAT
      " to %" GST_PTR_FORMAT, direction, from, ret);


  if (ret && filter) {
    GstCaps *intersection;

    GST_DEBUG_OBJECT (pseudocolor, "Using filter caps %" GST_PTR_FORMAT,
        filter);
    intersection =
        gst_caps_intersect_full (filter, ret, GST_CAPS_INTERSECT_FIRST);
    gst_caps_unref (ret);
    ret = intersection;
    GST_DEBUG_OBJECT (pseudocolor, "Intersection %" GST_PTR_FORMAT, ret);
  }

  return ret;
}

static void
gst_pseudo_color_class_init (GstPseudoColorClass * klass)
{
  GObjectClass *gobject_class = (GObjectClass *) klass;
  GstVideoFilterClass *video_filter_class = GST_VIDEO_FILTER_CLASS (klass);
  GstBaseTransformClass *trans_class = (GstBaseTransformClass *) klass;


  gst_element_class_add_pad_template (GST_ELEMENT_CLASS (klass),
      gst_pad_template_new ("src", GST_PAD_SRC, GST_PAD_ALWAYS,
          gst_caps_from_string (VIDEO_SRC_CAPS)));
  gst_element_class_add_pad_template (GST_ELEMENT_CLASS (klass),
      gst_pad_template_new ("sink", GST_PAD_SINK, GST_PAD_ALWAYS,
          gst_caps_from_string (VIDEO_SINK_CAPS)));

  video_filter_class->transform_frame =
      GST_DEBUG_FUNCPTR (gst_pseudo_color_transform_frame);
  video_filter_class->set_info = GST_DEBUG_FUNCPTR (gst_pseudo_color_set_info);

  trans_class->transform_caps =
      GST_DEBUG_FUNCPTR (gst_pseudo_color_transform_caps);

  gobject_class->set_property = gst_pseudo_color_set_property;
  gobject_class->get_property = gst_pseudo_color_get_property;
  gobject_class->finalize = gst_pseudo_color_finalize;

  g_object_class_install_property (G_OBJECT_CLASS (klass), PROP_HUE,
      g_param_spec_uint ("hue", "Hue",
          "Hue value in degree 0 to 359 (Default 100)", 0, 359,
          DEFAULT_HUE,
          G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS | GST_PARAM_CONTROLLABLE));

  g_object_class_install_property (G_OBJECT_CLASS (klass), PROP_SATURATION,
      g_param_spec_double ("saturation", "Saturation",
          "Saturation value 0.0 to 1.0 (Default 0.5)", 0.0, 1.0,
          DEFAULT_SATURATION,
          G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS | GST_PARAM_CONTROLLABLE));

  gst_element_class_set_static_metadata (GST_ELEMENT_CLASS (klass),
      "pseudocolor", "Transform/Effect/Video",
      "apply pseudo-color to grayscale image",
      "Ravi Kiran K N <ravi.kiran@samsung.com>");

}

static void
gst_pseudo_color_set_property (GObject * object, guint prop_id,
    const GValue * value, GParamSpec * pspec)
{
  GstPseudoColor *pcolor = GST_PSEUDO_COLOR (object);

  g_mutex_lock (&pcolor->mutex);
  switch (prop_id) {
    case PROP_HUE:
      pcolor->hue = g_value_get_uint (value);
      break;
    case PROP_SATURATION:
      pcolor->saturation = g_value_get_double (value);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
      break;
  }
  g_mutex_unlock (&pcolor->mutex);
}

static void
gst_pseudo_color_get_property (GObject * object, guint prop_id, GValue * value,
    GParamSpec * pspec)
{
  GstPseudoColor *pcolor = GST_PSEUDO_COLOR (object);

  switch (prop_id) {
    case PROP_HUE:
      g_value_set_uint (value, pcolor->hue);
      break;
    case PROP_SATURATION:
      g_value_set_double (value, pcolor->saturation);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
      break;
  }
}


static void
gst_pseudo_color_init (GstPseudoColor * pseudocolor)
{
  pseudocolor->saturation = DEFAULT_SATURATION;
  pseudocolor->hue = DEFAULT_HUE;
  pseudocolor->process = NULL;

  g_mutex_init (&pseudocolor->mutex);
}

/*  http://en.wikipedia.org/wiki/HSL_color_space */
#define HUE_TO_RGB(t1, t2, c, rgb) \
{ \
    if(c < 0.0) c += 1.0; \
    if(c > 1.0) c -= 1.0; \
    \
    if(c * 6 < 1.0) rgb = t2 + (t1 - t2) * 6.0 * c; \
    else if(c * 2 < 1.0) rgb = t1; \
    else if(c * 3 < 2.0) rgb = t2 + (t1 - t2) * (2.0/3 - c) * 6.0; \
    else rgb = t2; \
} \

static void
gst_pseudo_color_calc_rgb_color (guint graypix, guint hue, gdouble saturation,
    gint rgb[3])
{
  gdouble l = (gdouble) graypix / 255;
  gdouble temp1, temp2;
  gdouble r1, g1, b1;
  gdouble r = 0.0, g = 0.0, b = 0.0;
  gdouble h;

  if (l < 0.5)
    temp1 = l * (1.0 + saturation);
  else
    temp1 = l + saturation - l * saturation;

  temp2 = 2.0 * l - temp1;

  h = (gdouble) hue / 360;
  r1 = h + 0.33;
  g1 = h;
  b1 = h - 0.33;

  HUE_TO_RGB (temp1, temp2, r1, r);
  HUE_TO_RGB (temp1, temp2, g1, g);
  HUE_TO_RGB (temp1, temp2, b1, b);

  rgb[0] = CLAMP (r * 255, 0, 255);
  rgb[1] = CLAMP (g * 255, 0, 255);
  rgb[2] = CLAMP (b * 255, 0, 255);

}

static void
gst_pseudo_color_process_rgb (GstPseudoColor * pseudocolor,
    GstVideoFrame * src_frame, GstVideoFrame * dest_frame)
{
  gint i, j;
  gint w, h;
  guint8 *src, *dest;
  gint dest_stride, src_stride, src_pixel_stride, dest_pixel_stride;

  src = GST_VIDEO_FRAME_PLANE_DATA (src_frame, 0);
  src_stride = GST_VIDEO_FRAME_PLANE_STRIDE (src_frame, 0);
  src_pixel_stride = GST_VIDEO_FRAME_COMP_PSTRIDE (src_frame, 0);
  dest = GST_VIDEO_FRAME_PLANE_DATA (dest_frame, 0);
  dest_stride = GST_VIDEO_FRAME_PLANE_STRIDE (dest_frame, 0);
  dest_pixel_stride = GST_VIDEO_FRAME_COMP_PSTRIDE (dest_frame, 0);
  h = GST_VIDEO_FRAME_HEIGHT (src_frame);
  w = GST_VIDEO_FRAME_WIDTH (src_frame);

  for (i = 0; i < h; i++) {
    for (j = 0; j < w; j++) {
      gint rgb[3];

      gst_pseudo_color_calc_rgb_color ((guint) src[j * src_pixel_stride],
          pseudocolor->hue, pseudocolor->saturation, rgb);

      dest[j * dest_pixel_stride] = rgb[0];
      dest[j * dest_pixel_stride + 1] = rgb[1];
      dest[j * dest_pixel_stride + 2] = rgb[2];
    }
    dest += dest_stride;
    src += src_stride;
  }

}


static GstFlowReturn
gst_pseudo_color_transform_frame (GstVideoFilter * filter,
    GstVideoFrame * src_frame, GstVideoFrame * dest_frame)
{
  GstPseudoColor *pseudocolor = GST_PSEUDO_COLOR (filter);

  g_mutex_lock (&pseudocolor->mutex);

  if (pseudocolor->process)
    pseudocolor->process (pseudocolor, src_frame, dest_frame);

  g_mutex_unlock (&pseudocolor->mutex);

  return GST_FLOW_OK;
}

/* entry point to initialize the plug-in
 * initialize the plug-in itself
 * register the element factories and other features
 */
static gboolean pseudocolor_init(GstPlugin * plugin)
{
	return gst_element_register(plugin, "pseudocolor", GST_RANK_NONE,
				    GST_TYPE_PSEUDO_COLOR);
}

GST_PLUGIN_DEFINE(GST_VERSION_MAJOR,
		  GST_VERSION_MINOR,
		  pseudocolor,
		  "pseudocolor",
		  pseudocolor_init,
		  VERSION, "LGPL", "GStreamer", "http://gstreamer.net/")
