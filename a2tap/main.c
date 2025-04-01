

#include <err.h>
#include <stdio.h>
#include <unistd.h>

int debug, start, verbose;

int magic, dsize;
char *ofile = "o.tap";
FILE *ofd;

void rdhdr(void);
void wrfile(void);
void wrstart(void);
int rd2b(void);
void wrdblk(int addr, int sz);

/*
 * Convert an a.out nova binary to a simh tap file.
 */
int
main(int argc, char *argv[])
{
	int ch;

	while ((ch = getopt(argc, argv, "dsvo:")) != -1) {
		switch (ch) {
		case 'd': debug = 1; break;
		case 's': start = 1; break;
		case 'v': verbose = 1; break;
		case 'o': ofile = optarg; break;
		default:
			errx(1, "unknown arg '%c'", ch);
		}
	}
	argc -= optind;
	argv += optind;

	if (argc > 0) {
		if (freopen(argv[0], "r", stdin) == NULL)
			err(1, "freopen %s", argv[0]);
	}

	if ((ofd = fopen(ofile, "w")) == NULL)
		err(1, "fopen %s", ofile);

	rdhdr();

	putw(0, ofd);
	wrfile();
	return 0;
}

void rdhdr(void)
{
	magic = rd2b();
	dsize = rd2b();
	dsize += rd2b();
	rd2b();
	rd2b();
	rd2b();
	dsize += rd2b();
	rd2b();
	if (verbose) printf("read magic 0%o dsize 0%o\n", magic, dsize);
}

int
rd2b(void)
{
	int rv;

	rv = fgetc(stdin) & 0377;
	rv |= (fgetc(stdin) & 0377) << 8;
	return rv;
}

void
wrfile(void)
{
	int i;

	for (i = 0; i < dsize; i += 16) {
		int n = dsize - i < 16 ? dsize - i : 16;
		wrdblk(i, n);
	}
	wrstart();
}

static void
wrwd(int wd)
{
	fputc(wd & 0377, ofd);
	fputc((wd >> 8) & 0377, ofd);
}

void
wrdblk(int addr, int sz)
{
	unsigned short ary[16];
	unsigned short cksum;
	int i;

	if (verbose)
		printf("write 0%o chars at 0%o\n", sz, addr);
	cksum = -sz;
	wrwd(-sz);	/* -WD (words read) */
	cksum += addr;
	wrwd(addr);	/* loading address */
	
	for (i = 0; i < sz; i++) {
		ary[i] = rd2b();
		cksum += ary[i];
	}
	wrwd(0200000 - cksum);
	for (i = 0; i < sz; i++)
		wrwd(ary[i]);
	putw(0, ofd);
}

void
wrstart(void)
{
	unsigned short cksum;

	start = !start;
	wrwd(cksum = 1);
	wrwd(start << 15);
	cksum += (start << 15);
	wrwd(0200000 - cksum);
}
