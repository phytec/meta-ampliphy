/* GStreamer
 * Author: Matthias Rabe <matthias.rabe@sigma-chemnitz.de>
 *
 * based on pseudocode by
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
 * SECTION:element-gstpseudocolor2
 *
 * The pseudocolor2 element applies pseudo-color effect on gray scale image
 * but requires a lookup table
 *
 * <refsect2>
 * <title>Example launch line</title>
 * |[
 * gst-launch -v videotestsrc ! pseudocolor location=<fname> invert=<0/1> ! videoconvert ! autovideosink
 * ]|
 *
 * invert = invert graycolor
 *
 * </refsect2>
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gst/gst.h>
#include <gst/video/video.h>
#include "gstpseudocolor2.h"

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>

#ifndef PKG_DATADIR
#  define PKG_DATADIR   "/usr/share/gst-pseudocolor"
#endif

#define DEFAULT_HUE 100
#define DEFAULT_SATURATION 0.5
#define DEFAULT_INVERT 0

GST_DEBUG_CATEGORY_STATIC (gst_pseudo_color2_debug_category);
#define GST_CAT_DEFAULT gst_pseudo_color2_debug_category

enum
{
  PROP_0,
  PROP_LOCACTION,
  PROP_INVERT,
  PROP_MODE,
  PROP_HUE,
  PROP_SATURATION,
};

static GEnumValue const       transform_modes[] = {
    { TRANSFORM_MODE_LINEAR,  "linear",       "linear" },
    { TRANSFORM_MODE_TABLE,   "lookup table", "table" },
    { TRANSFORM_MODE_ALG,     "algorithm",    "alg" },
    { 0, NULL, NULL },
};

/* pad templates */

#define VIDEO_SRC_CAPS \
  GST_VIDEO_CAPS_MAKE("{ RGB, RGBA, RGBx, xRGB, ARGB }")

#define VIDEO_SINK_CAPS \
  GST_VIDEO_CAPS_MAKE("{ GRAY8, GRAY16_LE, GRAY10_LE, GRAY12_LE }")


/* class initialization */
#define gst_pseudo_color2_parent_class parent_class
G_DEFINE_TYPE_WITH_CODE(
  GstPseudoColor2, gst_pseudo_color2, GST_TYPE_BASE_TRANSFORM,
  GST_DEBUG_CATEGORY_INIT(gst_pseudo_color2_debug_category, "pseudocolor2",
                          0, "debug category for pseudocolor2 element"));

static void
gst_pseudo_color2_finalize (GObject * object)
{
  GstPseudoColor2	*pcolor = GST_PSEUDO_COLOR2 (object);

  g_mutex_clear (&pcolor->mutex);
  g_free(pcolor->table);
  g_free(pcolor->location);

  G_OBJECT_CLASS (parent_class)->finalize (object);
}

static GstCaps *
gst_pseudo_color2_transform_caps (GstBaseTransform * trans,
                                  GstPadDirection direction, GstCaps *from,
                                  GstCaps *filter)
{
  GstPseudoColor2	*pcolor = GST_PSEUDO_COLOR2(trans);
  GstStructure		*structure;
  GstCaps		*newcaps;
  GstStructure		*newstruct;

  structure = gst_caps_get_structure (from, 0);

  if (direction == GST_PAD_SRC)
    newcaps = gst_caps_from_string(VIDEO_SINK_CAPS);
  else
    newcaps = gst_caps_from_string(VIDEO_SRC_CAPS);

  if (filter) {
    newcaps = gst_caps_intersect(newcaps, filter);
    GST_DEBUG_OBJECT(newcaps, "filtered");
  }

  newstruct = gst_caps_get_structure(newcaps, 0);

  gst_structure_set_value(newstruct, "width",
                          gst_structure_get_value(structure, "width"));
  gst_structure_set_value(newstruct, "height",
                          gst_structure_get_value(structure, "height"));
  gst_structure_set_value(newstruct, "framerate",
                          gst_structure_get_value(structure, "framerate"));

  GST_DEBUG_OBJECT(pcolor, "%" GST_PTR_FORMAT " -> %" GST_PTR_FORMAT,
                   from, newcaps);

  return newcaps;
}

#define CONVERT(_src, _dst, _tbl, _bpp, _w, _h) do {            \
    unsigned int max_v = (1u << (_bpp)) - 1;                    \
                                                                \
    for (size_t y = (_h); y > 0; --y) {                         \
      __typeof__((_src))    in = (_src);                        \
      __typeof__((_dst))    out = (_dst);                       \
                                                                \
      for (size_t x = (_w); x > 0; --x) {                       \
        unsigned int pix = *in & max_v;                         \
                                                                \
        memcpy(out, (_tbl)[pix].rgb, dest_pixel_stride);        \
                                                                \
        out += dest_pixel_stride / sizeof *out;                 \
        in  += src_pixel_stride / sizeof *in;                   \
      }                                                         \
                                                                \
      (_src) += src_stride / sizeof (_src)[0];                  \
      (_dst) += dest_stride / sizeof (_dst)[0];                 \
    }                                                           \
  } while (0)


static void
gst_pseudo_color2_process_rgb (GstPseudoColor2 * pcolor,
                               void const *src_buf, void *dst_buf)
{
  gint w, h;
  void const *src_v;
  guint8 *dest;
  gint dest_stride, src_stride, src_pixel_stride, dest_pixel_stride;

  src_v = src_buf;
  src_stride = pcolor->in.stride;
  src_pixel_stride = pcolor->in.pix_stride;

  dest = dst_buf;
  dest_stride = pcolor->out.stride;
  dest_pixel_stride = pcolor->out.pix_stride;

  h = pcolor->height;
  w = pcolor->width;

  GST_DEBUG_OBJECT(pcolor, "processing... src=[%d/%d], dst=[%d/%d]",
                   src_stride, src_pixel_stride,
                   dest_stride, dest_pixel_stride);

  switch (pcolor->in.bpp) {
  case 8: {
    uint8_t const               *src = src_v;

    CONVERT(src, dest, pcolor->table, 8, w, h);
    break;
  }

  case 10: {
    uint16_t const               *src = src_v;

    CONVERT(src, dest, pcolor->table, 10, w, h);
    break;
  }

  case 12: {
    uint16_t const               *src = src_v;

    CONVERT(src, dest, pcolor->table, 12, w, h);
    break;
  }

  case 16: {
    uint16_t const               *src = src_v;

    CONVERT(src, dest, pcolor->table, 16, w, h);
    break;
  }

  default:
    GST_ERROR_OBJECT(pcolor, "bad bpp %u\n", pcolor->in.bpp);
    break;
  }
}

static GstFlowReturn
gst_pseudo_color2_transform(GstBaseTransform * base,
                            GstBuffer *inbuf, GstBuffer * outbuf)
{
  GstPseudoColor2	*pcolor = GST_PSEUDO_COLOR2(base);
  GstBaseTransform	*btrans = GST_BASE_TRANSFORM(pcolor);
  GstMapInfo		inmap_info;
  GstMapInfo		outmap_info;

  GST_DEBUG_OBJECT(pcolor, "transforming...");

  if (GST_CLOCK_TIME_IS_VALID(GST_BUFFER_TIMESTAMP(outbuf)))
    gst_object_sync_values(GST_OBJECT(pcolor),
                           GST_BUFFER_TIMESTAMP(outbuf));

  if (gst_base_transform_is_passthrough (btrans))
    return GST_FLOW_OK;

  if (!gst_buffer_map(inbuf, &inmap_info, GST_MAP_READ)) {
    GST_ERROR_OBJECT(pcolor, "failed to map inbuf");
    return GST_FLOW_ERROR;
  }

  if (!gst_buffer_map(outbuf, &outmap_info, GST_MAP_WRITE)) {
    GST_ERROR_OBJECT(pcolor, "failed to map outbuf");
    gst_buffer_unmap(inbuf, &inmap_info);
    return GST_FLOW_ERROR;
  }

  GST_DEBUG_OBJECT(pcolor, "inmap=[%p+%zu], outmap=[%p+%zu]",
                   inmap_info.data, inmap_info.size,
                   outmap_info.data, outmap_info.size);

  g_mutex_lock (&pcolor->mutex);

  gst_pseudo_color2_process_rgb(pcolor, inmap_info.data, outmap_info.data);

  g_mutex_unlock (&pcolor->mutex);

  gst_buffer_unmap(outbuf, &outmap_info);
  gst_buffer_unmap(inbuf, &inmap_info);

  return GST_FLOW_OK;
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
gst_pseudo_color_calc_rgb_color (double l, guint hue, gdouble saturation,
                                 uint8_t rgb[3])
{
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

static void set_table_entry(GstPseudoColor2 *pcolor,
                            struct GstPseudoColorRGB *table,
                            unsigned int idx,
                            unsigned int bpp,
                            uint8_t const rgb[3])
{
  unsigned int  r_idx = pcolor->out.r_idx;
  unsigned int	g_idx = pcolor->out.g_idx;
  unsigned int	b_idx = pcolor->out.b_idx;


  if (pcolor->invert)
    idx = (1u << bpp) - 1 - idx;

  memset(table[idx].rgb, 0, sizeof pcolor->table[idx].rgb);

  table[idx].rgb[r_idx] = rgb[0];
  table[idx].rgb[g_idx] = rgb[1];
  table[idx].rgb[b_idx] = rgb[2];
}

static gboolean fill_table_alg(GstPseudoColor2 *pcolor, unsigned int bpp,
                               struct GstPseudoColorRGB *tbl)
{
  for (unsigned int i = 0; i < (1u << bpp); ++i) {
    uint8_t    rgb[3];

    gst_pseudo_color_calc_rgb_color((double)i / ((1u << bpp) - 1),
                                    pcolor->hue,
                                    pcolor->saturation,
                                    rgb);

    set_table_entry(pcolor, tbl, i, bpp, rgb);
  }

  return true;
}

static gboolean fill_table_linear(GstPseudoColor2 *pcolor, unsigned int bpp,
                                  struct GstPseudoColorRGB *tbl)
{
  for (unsigned int i = 0; i < (1u << bpp); ++i) {
    unsigned int	v = i * 255 / ((1u << bpp) - 1);
    uint8_t		rgb[3] = { v, v, v };

    set_table_entry(pcolor, tbl, i, bpp, rgb);
  }

  return true;
}

static gboolean read_location(GstPseudoColor2 *pcolor,
                              char const *base, unsigned int bpp,
                              struct GstPseudoColorRGB *tbl)
{
  FILE *f = NULL;
  char *fname;
  int rc;
  bool res = FALSE;

  if (!base) {
    GST_ERROR_OBJECT(pcolor, "missing lookup table location");
    return FALSE;
  }

  rc = asprintf(&fname, "%s%d.rgb", base, bpp);
  if (rc < 0) {
    GST_ERROR_OBJECT(pcolor, "failed to allocate memory for rgb fname");
    return FALSE;
  }

  f = fopen(fname, "r");
  if (!f) {
    sprintf(fname, "%s.rgb", base);
    f = fopen(fname, "r");
  }
  if (!f)
    f = fopen(base, "r");

  if (!f) {
    GST_ERROR_OBJECT(pcolor, "failed to open lookup table '%s'", base);
    goto out;
  }

  for (unsigned int i = 0; i < (1u << bpp); ++i) {
    uint8_t                     rgb[3];

    rgb[0] = getc(f);
    rgb[1] = getc(f);
    rgb[2] = getc(f);

    set_table_entry(pcolor, tbl, i, bpp, rgb);
  }

  if (ferror(f)) {
    GST_ERROR_OBJECT(pcolor, "failed to read lookup table '%s'", fname);
    goto out;
  }

  res = TRUE;

out:
  if (f)
    fclose(f);

  free(fname);

  return res;
}

static void
gst_pseudo_color2_set_property (GObject * object, guint prop_id,
    const GValue * value, GParamSpec * pspec)
{
  GstPseudoColor2 *pcolor = GST_PSEUDO_COLOR2 (object);

  g_mutex_lock (&pcolor->mutex);
  switch (prop_id) {
    case PROP_LOCACTION:
      g_free(pcolor->location);
      pcolor->location = g_strdup(g_value_get_string (value));
      break;
    case PROP_INVERT:
      pcolor->invert = g_value_get_uint (value);
      break;
    case PROP_HUE:
      pcolor->hue = g_value_get_uint (value);
      break;
    case PROP_SATURATION:
      pcolor->saturation = g_value_get_double (value);
      break;
    case PROP_MODE:
      pcolor->mode = g_value_get_enum(value);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
      break;
  }
  g_mutex_unlock (&pcolor->mutex);
}

static void
gst_pseudo_color2_get_property (GObject * object, guint prop_id, GValue * value,
    GParamSpec * pspec)
{
  GstPseudoColor2 *pcolor = GST_PSEUDO_COLOR2 (object);

  switch (prop_id) {
    case PROP_HUE:
      g_value_set_uint (value, pcolor->hue);
      break;
    case PROP_LOCACTION:
      g_value_set_string (value, pcolor->location);
      break;
    case PROP_SATURATION:
      g_value_set_double (value, pcolor->saturation);
      break;
    case PROP_INVERT:
      g_value_set_uint (value, pcolor->invert);
      break;
    case PROP_MODE:
      g_value_set_enum (value, pcolor->mode);
      break;
    default:
      G_OBJECT_WARN_INVALID_PROPERTY_ID (object, prop_id, pspec);
      break;
  }
}

static gboolean
gst_pseudo_color2_get_unit_size(GstBaseTransform *trans, GstCaps *caps,
                                gsize *size)
{
  GstVideoInfo		info;

  if (!gst_video_info_from_caps(&info, caps)) {
    GST_ERROR_OBJECT(trans, "invalid caps: %" GST_PTR_FORMAT, caps);
    return FALSE;
  }

  *size = info.size;
  return TRUE;
}

static gboolean
gst_pseudo_color2_complete_setup(GstPseudoColor2 *pcolor)
{
  struct GstPseudoColorRGB      *table = NULL;
  gboolean                      res;

  GST_DEBUG_OBJECT(pcolor, "setup...");

  g_free(pcolor->table);
  pcolor->table = NULL;

  table = g_malloc(sizeof *table * (1u << pcolor->in.bpp));

  switch (pcolor->mode) {
  case TRANSFORM_MODE_TABLE:
    res = read_location(pcolor, pcolor->location, pcolor->in.bpp, table);
    break;
  case TRANSFORM_MODE_ALG:
    res = fill_table_alg(pcolor, pcolor->in.bpp, table);
    break;
  case TRANSFORM_MODE_LINEAR:
    res = fill_table_linear(pcolor, pcolor->in.bpp, table);
    break;
  default:
    GST_ERROR_OBJECT(pcolor, "bad mode");
    res = FALSE;
    break;
  }

  if (res) {
    pcolor->table = table;
    table = NULL;
  }

  g_free(table);

  return res;
}

static gboolean
gst_pseudo_color2_set_caps(GstBaseTransform *base, GstCaps *incaps,
                          GstCaps *outcaps)
{
  GstPseudoColor2	*pcolor = GST_PSEUDO_COLOR2(base);
  GstVideoInfo		in_info;
  GstVideoInfo		out_info;
  GstStructure		*in_structure;
  char const            *format;

  GST_DEBUG_OBJECT(pcolor, "set_caps %" GST_PTR_FORMAT " -> %" GST_PTR_FORMAT,
                   incaps, outcaps);

  if (!gst_video_info_from_caps(&in_info, incaps)) {
    GST_ERROR_OBJECT(pcolor, "invalid input caps: %"
                     GST_PTR_FORMAT, incaps);
    return FALSE;
  }

  if (!gst_video_info_from_caps(&out_info, outcaps) || !out_info.finfo) {
    GST_ERROR_OBJECT(pcolor, "invalid output caps: %"
                     GST_PTR_FORMAT, outcaps);
    return FALSE;
  }

  in_structure  = gst_caps_get_structure(incaps, 0);
  format = gst_structure_get_string(in_structure, "format");

  if (strcmp(format, "GRAY8") == 0) {
    pcolor->in.bpp = 8;
    pcolor->in.pix_stride = 1;
    pcolor->in.stride = in_info.width;
  } else if (strcmp(format, "GRAY10_LE") == 0) {
    pcolor->in.bpp = 10;
    pcolor->in.pix_stride = 2;
    pcolor->in.stride = in_info.width * 2;
  } else if (strcmp(format, "GRAY12_LE") == 0) {
    pcolor->in.bpp = 12;
    pcolor->in.pix_stride = 2;
    pcolor->in.stride = in_info.width * 2;
  } else if (strcmp(format, "GRAY16_LE") == 0) {
    pcolor->in.bpp = 16;
    pcolor->in.pix_stride = 2;
    pcolor->in.stride = in_info.width * 2;
  } else {
    GST_ERROR_OBJECT(pcolor, "invalid format in %" GST_PTR_FORMAT, incaps);
    return FALSE;
  }

  switch (out_info.finfo->format) {
  case GST_VIDEO_FORMAT_RGBx:
  case GST_VIDEO_FORMAT_RGBA:
    pcolor->out.bpp   = 32;
    pcolor->out.r_idx = 0;
    pcolor->out.g_idx = 1;
    pcolor->out.b_idx = 2;
    break;

  case GST_VIDEO_FORMAT_RGB:
    pcolor->out.bpp   = 24;
    pcolor->out.r_idx = 0;
    pcolor->out.g_idx = 1;
    pcolor->out.b_idx = 2;
    break;

  case GST_VIDEO_FORMAT_xRGB:
  case GST_VIDEO_FORMAT_ARGB:
    pcolor->out.bpp   = 32;
    pcolor->out.r_idx = 1;
    pcolor->out.g_idx = 2;
    pcolor->out.b_idx = 3;
    break;

  default:
    GST_ERROR_OBJECT(pcolor, "unsupported output format");
    break;
  }

  pcolor->out.size       = out_info.size;
  pcolor->out.stride     = out_info.stride[0];
  pcolor->out.pix_stride = pcolor->out.bpp / 8;

  pcolor->width = in_info.width;
  pcolor->height = in_info.height;

  GST_DEBUG_OBJECT(pcolor,
                   "set_caps done (in=[%d, %d, %d]/%zu, out=[%d, %d, %d, (%d,%d,%d)]/%zu",
                   pcolor->in.bpp, pcolor->in.stride, pcolor->in.pix_stride,
                   in_info.size,
                   pcolor->out.bpp, pcolor->out.stride, pcolor->out.pix_stride,
                   pcolor->out.r_idx, pcolor->out.g_idx, pcolor->out.b_idx,
                   out_info.size);

  return gst_pseudo_color2_complete_setup(pcolor);
}

static void
gst_pseudo_color2_class_init (GstPseudoColor2Class * klass)
{
  GObjectClass *gobject_class = (GObjectClass *) klass;
  GstBaseTransformClass *trans_class = (GstBaseTransformClass *) klass;
  GType transform_mode_type;

  gst_element_class_add_pad_template (GST_ELEMENT_CLASS (klass),
      gst_pad_template_new ("src", GST_PAD_SRC, GST_PAD_ALWAYS,
          gst_caps_from_string (VIDEO_SRC_CAPS)));
  gst_element_class_add_pad_template (GST_ELEMENT_CLASS (klass),
      gst_pad_template_new ("sink", GST_PAD_SINK, GST_PAD_ALWAYS,
          gst_caps_from_string (VIDEO_SINK_CAPS)));

  transform_mode_type = g_enum_register_static("transformmodes",
                                               transform_modes);

  trans_class->transform = GST_DEBUG_FUNCPTR (gst_pseudo_color2_transform);
  trans_class->set_caps = GST_DEBUG_FUNCPTR(gst_pseudo_color2_set_caps);

  trans_class->transform_caps =
      GST_DEBUG_FUNCPTR (gst_pseudo_color2_transform_caps);

  trans_class->get_unit_size =
      GST_DEBUG_FUNCPTR (gst_pseudo_color2_get_unit_size);

  gobject_class->set_property = gst_pseudo_color2_set_property;
  gobject_class->get_property = gst_pseudo_color2_get_property;
  gobject_class->finalize = gst_pseudo_color2_finalize;

  g_object_class_install_property (G_OBJECT_CLASS (klass), PROP_LOCACTION,
      g_param_spec_string ("location", "Location",
          "Location of pseudocolor look up table",
          NULL,
          G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS | GST_PARAM_CONTROLLABLE));

  g_object_class_install_property (G_OBJECT_CLASS (klass), PROP_INVERT,
      g_param_spec_uint ("invert", "invert",
          "invert graycolor", 0, 1,
          DEFAULT_INVERT,
          G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS | GST_PARAM_CONTROLLABLE));

  g_object_class_install_property (G_OBJECT_CLASS (klass), PROP_MODE,
      g_param_spec_enum ("mode", "mode",
          "mode", transform_mode_type, TRANSFORM_MODE_TABLE,
          G_PARAM_READWRITE | G_PARAM_STATIC_STRINGS | GST_PARAM_CONTROLLABLE));

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
      "pseudocolor2", "Transform/Effect/Video",
      "apply pseudo-color to grayscale image",
      "Matthias Rabe <matthias.rabe@sigma-chemnitz.de>");
}


static void
gst_pseudo_color2_init (GstPseudoColor2 * pcolor)
{
  pcolor->invert = DEFAULT_INVERT;
  pcolor->saturation = DEFAULT_SATURATION;
  pcolor->hue = DEFAULT_HUE;
  pcolor->mode = TRANSFORM_MODE_TABLE;
  pcolor->location = g_strdup(PKG_DATADIR "/rainbow");

  pcolor->table = NULL;

  g_mutex_init (&pcolor->mutex);
}

/* entry point to initialize the plug-in
 * initialize the plug-in itself
 * register the element factories and other features
 */
static gboolean pseudocolor2_init(GstPlugin * plugin)
{
	return gst_element_register(plugin, "pseudocolor2", GST_RANK_NONE,
                                    GST_TYPE_PSEUDO_COLOR2);
}


/* gstreamer looks for this structure to register bayer2rgbneons
 *
 * FIXME:exchange the string 'Template bayer2rgbneon' with you bayer2rgbneon description
 */
GST_PLUGIN_DEFINE(GST_VERSION_MAJOR,
                  GST_VERSION_MINOR,
                  pseudocolor2,
                  "pseudocolor",
                  pseudocolor2_init,
                  VERSION, "LGPL", "GStreamer", "http://gstreamer.net/")
