/*
 *  nandflipbits.c
 *
 *  Copyright (C) 2014 Free Electrons
 *
 *  Author: Boris Brezillon <boris.brezillon at free-electrons.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 * Overview:
 *   This utility manually flip specified bits in a NAND flash.
 *
 */

#define PROGRAM_NAME "nandwrite"
#define VERSION "1"

#include <ctype.h>
#include <errno.h>
#include <fcntl.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <getopt.h>

#include <asm/types.h>
#include "mtd/mtd-user.h"
#include "mtd/common.h"
#include "mtd/xalloc.h"
#include "mtd/libmtd.h"

struct bit_flip {
	int block;
	off_t offset;
	int bit;
	bool done;
};

static void display_help(int status)
{
	fprintf(status == EXIT_SUCCESS ? stdout : stderr,
"Usage: nandflipbits [OPTION] MTD_DEVICE <bit>@<address>[:<bit>@<address>]\n"
"Writes to the specified MTD device.\n"
"\n"
"  -o, --oob               Provided addresses take OOB area into account\n"
"  -q, --quiet             Don't display progress messages\n"
"  -h, --help              Display this help and exit\n"
"      --version           Output version information and exit\n"
	);
	exit(status);
}

static void display_version(void)
{
	printf("%1$s " VERSION "\n"
			"\n"
			"Copyright (C) 2014 Free Electrons \n"
			"\n"
			"%1$s comes with NO WARRANTY\n"
			"to the extent permitted by law.\n"
			"\n"
			"You may redistribute copies of %1$s\n"
			"under the terms of the GNU General Public Licence.\n"
			"See the file `COPYING' for more information.\n",
			PROGRAM_NAME);
	exit(EXIT_SUCCESS);
}

static const char	*mtd_device;
static bool		quiet = false;
static bool		oob_mode = false;
static struct bit_flip	*bits_to_flip;
static int		nbits_to_flip = 0;

static void process_options(int argc, char * const argv[])
{
	char *bits_to_flip_iter;
	int bit_idx = 0;
	int error = 0;

	for (;;) {
		int option_index = 0;
		static const char short_options[] = "hoq";
		static const struct option long_options[] = {
			/* Order of these args with val==0 matters; see option_index. */
			{"version", no_argument, 0, 0},
			{"help", no_argument, 0, 'h'},
			{"oob", no_argument, 0, 'o'},
			{"quiet", no_argument, 0, 'q'},
			{0, 0, 0, 0},
		};

		int c = getopt_long(argc, argv, short_options,
				long_options, &option_index);
		if (c == EOF)
			break;

		switch (c) {
		case 0:
			if (!option_index) {
				display_version();
				break;
			}
			break;
		case 'q':
			quiet = true;
			break;
		case 'o':
			oob_mode = true;
			break;
		case 'h':
			display_help(EXIT_SUCCESS);
			break;
		case '?':
			error++;
			break;
		}
	}

	argc -= optind;
	argv += optind;

	/*
	 * There must be at least the MTD device node path argument remaining
	 * and the 'bits-to-flip' description.
	 */

	if (argc != 2 || error)
		display_help(EXIT_FAILURE);

	mtd_device = argv[0];
	bits_to_flip_iter = argv[1];
	do {
		nbits_to_flip++;
		bits_to_flip_iter = strstr(bits_to_flip_iter, ":");
		if (bits_to_flip_iter)
			bits_to_flip_iter++;
	} while (bits_to_flip_iter);

	bits_to_flip = xmalloc(sizeof(*bits_to_flip) * nbits_to_flip);
	bits_to_flip_iter = argv[1];

	do {
		struct bit_flip	*bit_to_flip = &bits_to_flip[bit_idx++];

		bit_to_flip->bit = strtol(bits_to_flip_iter,
					  &bits_to_flip_iter, 0);
		if (errno || bit_to_flip->bit > 7)
			goto err_invalid_bit_desc;

		if (!bits_to_flip_iter || *bits_to_flip_iter++ != '@')
			goto err_invalid_bit_desc;

		bit_to_flip->offset = strtol(bits_to_flip_iter,
					     &bits_to_flip_iter, 0);

		if (!bits_to_flip_iter || errno)
			goto err_invalid_bit_desc;

		bits_to_flip_iter = strstr(bits_to_flip_iter, ":");
		if (bits_to_flip_iter)
			bits_to_flip_iter++;
	} while (bits_to_flip_iter);

	return;

err_invalid_bit_desc:
	fprintf(stderr, "Invalid bit description\n");
	exit(EXIT_FAILURE);
}
int main(int argc, char **argv)
{
	libmtd_t mtd_desc;
	struct mtd_dev_info mtd;
	int pagelen;
	int pages_per_blk;
	size_t blklen;
	long long mtdlen;
	int fd;
	int ret;
	uint8_t *buffer;
	int i;

	process_options(argc, argv);

	/* Open the device */
	if ((fd = open(mtd_device, O_RDWR)) == -1)
		sys_errmsg_die("%s", mtd_device);

	mtd_desc = libmtd_open();
	if (!mtd_desc)
		errmsg_die("can't initialize libmtd");

	ret = ioctl(fd, MTDFILEMODE, MTD_FILE_MODE_RAW);
	if (ret) {
		printf("Failed to set MTD in raw access mode\n");
		return -errno;
	}

	/* Fill in MTD device capability structure */
	if (mtd_get_dev_info(mtd_desc, mtd_device, &mtd) < 0)
		errmsg_die("mtd_get_dev_info failed");

	/* Select OOB write mode */
	ret = ioctl(fd, MTDFILEMODE, MTD_FILE_MODE_RAW);
	if (ret) {
		switch (errno) {
		case ENOTTY:
			errmsg_die("ioctl MTDFILEMODE is missing");
		default:
			sys_errmsg_die("MTDFILEMODE");
		}
	}

	pagelen = mtd.min_io_size + (oob_mode ? mtd.oob_size : 0);
	pages_per_blk = mtd.eb_size / mtd.min_io_size;
	blklen = pages_per_blk * pagelen;
	mtdlen = blklen * mtd.eb_cnt;
	buffer = xmalloc((mtd.min_io_size + mtd.oob_size) * pages_per_blk);

	for (i = 0; i < nbits_to_flip; i++) {
		int page;

		if (bits_to_flip[i].offset >= mtdlen)
			errmsg_die("Invalid bit offset");

		bits_to_flip[i].block = bits_to_flip[i].offset / blklen;
		bits_to_flip[i].offset %= blklen;
		page = bits_to_flip[i].offset / pagelen;
		bits_to_flip[i].offset = (page *
					  (mtd.min_io_size + mtd.oob_size)) +
					 (bits_to_flip[i].offset % pagelen);

	}

	while (1) {
		struct bit_flip	*bit_to_flip = NULL;
		int blkoffs;
		int bufoffs;

		for (i = 0; i < nbits_to_flip; i++) {
			if (bits_to_flip[i].done == false) {
				bit_to_flip = &bits_to_flip[i];
				break;
			}
		}

		if (!bit_to_flip)
			break;

		blkoffs = 0;
		bufoffs = 0;
		for (i = 0; i < pages_per_blk; i++) {
			ret = mtd_read(&mtd, fd, bit_to_flip->block, blkoffs,
				       buffer + bufoffs, mtd.min_io_size);
			if (ret) {
				sys_errmsg("%s: MTD Read failure", mtd_device);
				goto closeall;
			}

			bufoffs += mtd.min_io_size;

			ret = mtd_read_oob(mtd_desc, &mtd, fd, blkoffs,
					   mtd.oob_size, buffer + bufoffs);
			if (ret) {
				sys_errmsg("%s: MTD Read OOB failure", mtd_device);
				goto closeall;
			}

			bufoffs += mtd.oob_size;
			blkoffs += mtd.min_io_size;
		}

		for (i = 0; i < nbits_to_flip; i++) {
			unsigned char val, mask;

			if (bits_to_flip[i].block != bit_to_flip->block)
				continue;

			mask = 1 << bits_to_flip[i].bit;
			val = buffer[bits_to_flip[i].offset] & mask;
			if (val)
				buffer[bits_to_flip[i].offset] &= ~mask;
			else
				buffer[bits_to_flip[i].offset] |= mask;
		}

		ret = mtd_erase(mtd_desc, &mtd, fd, bit_to_flip->block);
		if (ret) {
			sys_errmsg("%s: MTD Erase failure", mtd_device);
			goto closeall;
		}

		blkoffs = 0;
		bufoffs = 0;
		for (i = 0; i < pages_per_blk; i++) {
			ret = mtd_write(mtd_desc, &mtd, fd, bit_to_flip->block,
					blkoffs, buffer + bufoffs, mtd.min_io_size,
					buffer + bufoffs + mtd.min_io_size,
					mtd.oob_size,
					MTD_OPS_RAW);
			if (ret) {
				sys_errmsg("%s: MTD Write failure", mtd_device);
				goto closeall;
			}

			blkoffs += mtd.min_io_size;
			bufoffs += mtd.min_io_size + mtd.oob_size;
		}

		for (i = 0; i < nbits_to_flip; i++) {
			if (bits_to_flip[i].block == bit_to_flip->block)
				bits_to_flip[i].done = true;
		}
	}

	return 0;

closeall:
	libmtd_close(mtd_desc);
	close(fd);
	free(buffer);
	exit(EXIT_FAILURE);
}
