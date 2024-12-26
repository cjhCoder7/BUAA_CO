#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

void usage() {
    printf("Usage: ./csim -s <num> -E <num> -b <num> -t <file>\n");
    printf("Options:\n");
    printf("  -s <num>   Number of set index bits.\n");
    printf("  -E <num>   Number of lines per set.\n");
    printf("  -b <num>   Number of block offset bits.\n");
    printf("  -t <file>  Trace file.\n");
    printf("\n");
    printf("Examples:\n");
    printf("  linux>  ./csim -s 4 -E 1 -b 4 -t traces/yi.trace\n");
}

// 直接在控制台输入，便于调试运行
void parse_input(int *s, int *E, int *b, char *filename) {
    scanf("%d", s);
    scanf("%d", E);
    scanf("%d", b);
    scanf("%s", filename);
}

int parse_cmd(int args, char **argv, int *s, int *E, int *b, char *filename) {
    int flag[4] = {0};
    int flag_num = 4;

    for (int i = 0; i < args; i++) {
        char *str = argv[i];
        if (str[0] == '-') {
            if (str[1] == 's' && i < args) {
                i++;
                sscanf(argv[i], "%d", s);
                flag[0] = 1;
            } else if (str[1] == 'E' && i < args) {
                i++;
                sscanf(argv[i], "%d", E);
                flag[1] = 1;
            } else if (str[1] == 'b' && i < args) {
                i++;
                sscanf(argv[i], "%d", b);
                flag[2] = 1;
            } else if (str[1] == 't' && i < args) {
                i++;
                sscanf(argv[i], "%s", filename);
                flag[3] = 1;
            }
        }
    }
    for (int i = 0; i < flag_num; i++) {
        if (flag[i] == 0) {
            printf("./csim: Missing required command line argument\n");
            usage();
            return 1;
        }
    }
    return 0;
}

void printSummary(int hits, int misses, int evictions) {
    printf("hits:%d misses:%d evictions:%d\n", hits, misses, evictions);
}

int readline(FILE *trace, char *op, unsigned long long *address, int *request_length) {
    char str[30];
    if (fgets(str, 30, trace) == NULL) {
        return -1;
    }
    sscanf(str, " %c %llx,%d", op, address, request_length);
    return 0;
}

#pragma region Structures-And-Functions

// Cache line structure
typedef struct {
    int valid;
    unsigned long long tag;
    int last_used;
} cache_line_t;

// Cache set structure
typedef struct {
    cache_line_t *lines;
} cache_set_t;

// Cache structure
typedef struct {
    cache_set_t *sets;
    int s;
    int E;
    int b;
    int hits;
    int misses;
    int evictions;
    int timestamp;
} cache_t;

// Structure for parsed address
typedef struct {
    unsigned long long tag;    // Tag bits
    int set_index;             // Set index
    int block_offset;          // Block offset
} cache_addr_t;

cache_addr_t parse_address(unsigned long long address, int s, int b) {
    cache_addr_t addr;

    unsigned long long set_mask = (1ULL << s) - 1;
    unsigned long long block_mask = (1ULL << b) - 1;

    addr.block_offset = address & block_mask;
    addr.set_index = (address >> b) & set_mask;
    addr.tag = address >> (s + b);

    return addr;
}

cache_t* init_cache(int s, int E, int b) {
    cache_t *cache = (cache_t *)malloc(sizeof(cache_t));
    cache->s = s;
    cache->E = E;
    cache->b = b;
    cache->hits = 0;
    cache->misses = 0;
    cache->evictions = 0;
    cache->timestamp = 0;

    // Allocate sets
    int S = 1 << s;
    cache->sets = (cache_set_t *)malloc(sizeof(cache_set_t) * S);

    // Allocate lines for each set
    for (int i = 0; i < S; i++) {
        cache->sets[i].lines = (cache_line_t *)malloc(sizeof(cache_line_t) * E);
        // Initialize each line
        for (int j = 0; j < E; j++) {
            cache->sets[i].lines[j].valid = 0;
            cache->sets[i].lines[j].tag = 0;
            cache->sets[i].lines[j].last_used = 0;
        }
    }

    return cache;
}

void free_cache(cache_t *cache) {
    int S = 1 << cache->s;
    for (int i = 0; i < S; i++) {
        free(cache->sets[i].lines);
    }
    free(cache->sets);
    free(cache);
}

void access_cache(cache_t *cache, unsigned long long address) {
    cache->timestamp++;

    cache_addr_t addr = parse_address(address, cache->s, cache->b);

    cache_set_t *set = &cache->sets[addr.set_index];
    int empty_line = -1;
    int lru_line = -1;
    int hit_found = 0;
    unsigned long long min_timestamp = ~0ULL;  // 初始化为最大值

    for (int i = 0; i < cache->E; i++) {
        if (set->lines[i].valid) {
            if (set->lines[i].tag == addr.tag) {
                // Cache hit
                set->lines[i].last_used = cache->timestamp;
                cache->hits++;
                hit_found = 1;

                // printf("hit ");

                break;
            }
            // Track LRU line
            if (set->lines[i].last_used < min_timestamp) {
                min_timestamp = set->lines[i].last_used;
                lru_line = i;
            }
        } else if (empty_line == -1) {
            empty_line = i;
        }
    }

    if (!hit_found) {
        // Cache miss
        cache->misses++;

        // printf("miss ");

        if (empty_line != -1) {
            // Fill empty line
            set->lines[empty_line].valid = 1;
            set->lines[empty_line].tag = addr.tag;
            set->lines[empty_line].last_used = cache->timestamp;

            // printf("fill_line ");
        } else {
            cache->evictions++;
            set->lines[lru_line].tag = addr.tag;
            set->lines[lru_line].last_used = cache->timestamp;

            // printf("evictions ");
        }
    }
}

#pragma endregion

int main(int args, char **argv) {

#pragma region Parse
    int s, E, b;
    char filename[1024];
    if (parse_cmd(args, argv, &s, &E, &b, filename) != 0) {
        return 0;
    }
    // parse_input(&s, &E, &b, filename);
#pragma endregion

#pragma region Cache-Init
    cache_t *cache = init_cache(s, E, b);
#pragma endregion

#pragma region Handle-Trace
    FILE *trace = fopen(filename, "r");
    char op;
    unsigned long long address;
    int request_length;

    while (readline(trace, &op, &address, &request_length) != -1) {
        if (op == 'I') continue;  // Skip instruction loads

        // Handle data operations
        access_cache(cache, address);
        if (op == 'M') {
            // Modify operation = Load + Store
            access_cache(cache, address);
        }

        // printf("\n");
    }
#pragma endregion

    printSummary(cache->hits, cache->misses, cache->evictions);
    free_cache(cache);

    return 0;
}
