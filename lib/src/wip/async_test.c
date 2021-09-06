#include <stdio.h>
#include <stdint.h>
#include <unistd.h>

#include "async.h"
#include "async-sem.h"

const int limit = 999;

int increment_counter(int64_t i) {
    printf("sleeping for 3 sec...");
    sleep(3);
    printf("done\n");
}

struct async_sem example_sem;

static async example(struct async *pt) {
    async_begin(pt);

    for (int64_t i = 0; i < limit; ++i) {

        await_sem(&example_sem);

        printf("incrementing counter: from %d to %d\n", i, i + 1);
        increment_counter(i);
    }
    async_end;
}

void main() {
    struct async pt;

    init_sem(&example_sem, limit);

    while (!example(&pt)) {
#ifdef _WIN32
        Sleep(0);
#else
        usleep(10);
#endif
    }
}
