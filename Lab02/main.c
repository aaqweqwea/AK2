#include "samplestats.h"

#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv)
{
    struct sample_stats stats;

    if (argc < 2) {
        fprintf(stderr, "Usage: %s NUMBER [NUMBER ...]\n", argv[0]);
        return 2;
    }
    stats_reset(&stats);
    for (int i = 1; i < argc; ++i) {
        char *end;
        double value;

        errno = 0;
        value = strtod(argv[i], &end);
        if (end == argv[i] || *end || errno == ERANGE || !isfinite(value)) {
            fprintf(stderr, "Invalid finite number: %s\n", argv[i]);
            return 2;
        }
        stats_push(&stats, value);
        if (!isfinite(stats.mean) || !isfinite(stats.m2)) {
            fputs("Sample range exceeds floating-point capacity\n", stderr);
            return 2;
        }
    }
    printf("count=%zu mean=%.9g min=%.9g max=%.9g variance=%.9g\n",
           stats.count, stats.mean, stats.minimum, stats.maximum,
           stats_variance(&stats));
    return 0;
}
