#ifndef SAMPLESTATS_H
#define SAMPLESTATS_H

#include <stddef.h>

struct sample_stats {
    size_t count;
    double mean;
    double m2;
    double minimum;
    double maximum;
};

void stats_reset(struct sample_stats *stats);
void stats_push(struct sample_stats *stats, double value);
double stats_variance(const struct sample_stats *stats);

#endif
