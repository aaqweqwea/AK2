#include "samplestats.h"

void stats_reset(struct sample_stats *stats)
{
    *stats = (struct sample_stats){0};
}

void stats_push(struct sample_stats *stats, double value)
{
    double delta = value - stats->mean;

    if (stats->count == 0) {
        stats->minimum = value;
        stats->maximum = value;
    } else {
        if (value < stats->minimum)
            stats->minimum = value;
        if (value > stats->maximum)
            stats->maximum = value;
    }
    ++stats->count;
    stats->mean += delta / (double)stats->count;
    stats->m2 += delta * (value - stats->mean);
}

double stats_variance(const struct sample_stats *stats)
{
    return stats->count ? stats->m2 / (double)stats->count : 0.0;
}
