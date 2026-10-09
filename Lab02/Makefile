CC = cc
CPPFLAGS =
CFLAGS = -std=c11 -O2 -Wall -Wextra -Wpedantic
LDFLAGS =

.PHONY: all clean
all: stats-demo

libsamplestats.so: samplestats.o
	$(CC) $(LDFLAGS) -shared -o $@ $^

stats-demo: main.o libsamplestats.so
	$(CC) $(LDFLAGS) -o $@ main.o -L. -lsamplestats -Wl,-rpath,'$$ORIGIN'

samplestats.o: samplestats.c samplestats.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -fPIC -MMD -MP -c $< -o $@

main.o: main.c samplestats.h
	$(CC) $(CPPFLAGS) $(CFLAGS) -MMD -MP -c $< -o $@

-include main.d samplestats.d

clean:
	$(RM) stats-demo libsamplestats.so main.o samplestats.o main.d samplestats.d
