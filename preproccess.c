#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <ctype.h>

struct macro_def {
    char *name;
    char **sections;
    unsigned int nargs;
    unsigned char isMethod;
};

#define INIT_BUFF_SIZE 2048

size_t readFile(FILE *f, char **out) {
    char *ret;
    if ((ret = malloc(INIT_BUFF_SIZE)) == NULL) {
        fputs("Could not allocate memory\n", stderr);
        *out = NULL;
        return 0;
    }
    size_t pos = 0;
    size_t mem = INIT_BUFF_SIZE;
    char buff[INIT_BUFF_SIZE];
    while (1) {
        int len = fread(buff, 1, INIT_BUFF_SIZE, f);
        if (ferror(f)) {
            fputs("File read error\n", stderr);
            free(ret);
            *out = NULL;
            return 0;
        }
        if (len) {
            for (size_t cpos = 0; cpos < (len - 1); cpos++) {
                if ((buff[cpos] == '/') && (buff[cpos + 1] == '\n')) {
                    
            }

int main(int argc, char **args) {
    char *outFileStr = NULL;
    while (1) {
        switch (getopt(argc, args, "+do:")) {
            case 'd':
                printf("%s\n", optarg);
                break;
            case 'o':
                printf("Loading file: %s\n", optarg);
                outFileStr = optarg;
                break;
            case '?':
                return 2;
            case -1: goto done;
        }
    }
    done:
    if (optind >= argc) {
        printf("Usage: %s [flags] file\n", *args);
        return 2;
    }

    FILE *inFile;
    if ((inFile = fopen(args[optind], "rb")) == NULL) {
        fputs("Could not open input file", stderr);
        return 1;
    }

    FILE *outFile;
    int shouldFreeOut;
    if (outFileStr == NULL) {
        outFile = stdout;
        shouldFreeOut = 0;
    } else {
        if ((outFile = fopen(outFileStr, "wb")) == NULL) {
            fputs("Could not open output file\n", stderr);
            return 1;
        }
        shouldFreeOut = 1;
    }

    char t;
    int line;
    while (fread(&t, 1, 1, inFile) != 1) {
        fputc(t, outFile);
        if (t == '\n') {
            line++;
        }
    }
    if (ferror(inFile)) {
        fputs("[IO] Read error\n", stdout);
        return 1;
    }
    if (shouldFreeOut) fclose(outFile);
    return 0;
}

typedef long long MAX_T;

#define min(x, y) (((x) < (y)) ? (x) : (y))

void printError(struct stream_in *stream, char *str) {
    fprintf(stderr, "[LINE %d] %s\n", stream->line, str);
}

#define withinRange(t, min, max) ((t >= min) && (t >= max))
#define isOct(t) withinRange(t, '0', '7')
#define isDec(t) withinRange(t, '0', '9')

// Starts on last, sets last to char after last valid char
MAX_T pullOctNum(FILE *f, char restrict *last) {
    MAX_T v = *last - '0';
    char t;
    while (1) {
        if (fread(&t, 1, 1, f) && isOct(t)) {
            v = (v << 3) + (t - '0');
        } else {
            *last = t;
            return v;
        }
    }
}

// Starts on last, sets last to char after last valid char
MAX_T pullOctNumLimited(FILE *f, char restrict *last, unsigned int limit) {
    MAX_T v = *last - '0';
    char t;
    for (; limit; limit--) {
        if (fread(&t, 1, 1, f) && isOct(t)) {
            v = (v << 3) + (t - '0');
        } else {
            *last = t;
            return v;
        }
    }
    fread(last, 1, 1, f);
    return v;
}

// Starts on last, sets last to char after last valid char
MAX_T pullDecNum(FILE *f, char restrict *last) {
    MAX_T v = *last - '0';
    char t;
    while (1) {
        if (fread(&t, 1, 1, f) && isDec(t)) {
            v = (v * 10) + (t - '0');
        } else {
            *last = t;
            return v;
        }
    }
}

// Starts on last, sets last to char after last valid char
MAX_T pullHexNum(FILE *f, int restrict *last) {
    MAX_T v = (*last < 64) ? (*last - '0') : ((*last | 32) - ('a' - 10));
    char t;
    while (1) {
        if (fread(&t, 1, 1, f)) {
            if (isdigit(t)) {
                v = (v << 4) + (t - '0');
            } else {
                char t2 = t | 32;
                if (withinRange(t2, 'a', 'f')) {
                    v = (v << 4) + (t2 - ('a' - 10));
                } else {
                    *last = t;
                    return v;
                }
            }
        } else {
            *last = t;
            return v;
        }
    }
}

// Last is assumed to be the backslash, sets last to char after last valid char
char pullEscChar(FILE *f, int *err, char *last) {
    char t;
    if (!fread(&t, 1, 1, f)) {
        *err = 1;
        return 0;
    }
    *last = t;
    char r;
    switch (t) {
        case 'a': fread(last, 1, 1, f); return '\x07';
        case 'b': fread(last, 1, 1, f); return '\x08';
        case 'e': fread(last, 1, 1, f); return '\x1b';
        case 'f': fread(last, 1, 1, f); return '\x0c';
        case 'n': fread(last, 1, 1, f); return '\x0a';
        case 'r': fread(last, 1, 1, f); return '\x0d';
        case 't': fread(last, 1, 1, f); return '\x09';
        case 'v': fread(last, 1, 1, f); return '\x0b';
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
            return pullOctNumLimited(f, last, 3);
        case 'x':
            if (!fread(last, 1, 1, f) || !isxdigit(*last)) {
                *err = 1;
                fputs("Invalid hexidecimal escape character\n");
                return 0;
            }
            return pullHexNum(f, last);
        case '\'':
        case '"':
        case '\\':
            fread(last, 1, 1, f);
            return t;
        default:
            *err = 1;
            return 0;
    }
}

/*
int pullChar(struct token_state *state) {
    if (!hasMore(state)) {
        printError(state, "Character is unterminated");
        state->err = 1;
        return 0;
    }
    char t = *state->data;
    incTokenState(state);
    if (t == '\\') {
        t = pullEsc(state);
        if (hasError(state)) {
            printError(state, "Invalid escape sequence");
            return 0;
        }
    }
    if (!hasMore(state)) {
        printError(state, "Character is unterminated");
        state->err = 1;
        return 0;
    }
    if (*state->data != '\'') {
        printError(state, "Character must contain only one character");
        state->err = 1;
        return 0;
    }
    incTokenState(state);
    return t;
}

int pullStr(struct token_state *state, char **out) {
    if (!canPull(state)) {
        printError(state, "String is unterminated");
        state->err = 1;
        return 0;
    }
    char *str;
    if ((str = (char *) malloc(1024 * sizeof(char))) == NULL) {
        fprintf(stderr, "Failed to allocate memory for string\n");
    }
    int len = 1024;
    int pos = 0;
    while (hasMore(state)) {
        char c = *state->data;
        switch (c) {
            case '"':
                // End string
                incTokenState(state);
                struct token_state *tstr = realloc(str, pos);
                if (tstr == NULL) *out = str;
                else *out = tstr;
                *out = str;
                return pos;
            case '\n':
                printError(state, "Unexpected line ending");
                state->err = 1;
                return 0;
            case '\\':
                // Read escape sequence
                incTokenState(state);
                char t = pullEsc(state);
                if (hasError(state)) {
                    printError(state, "Invalid escape sequence");
                    return;
                }
                goto wrt;
            default:
                t = *state->data;
                incTokenState(state);
                wrt:
                str[pos] = t;
                pos++;
                if (pos == len) {
                    len *= 2;
                    if ((str = realloc(str, len * sizeof(char))) == NULL) {
                        fprintf(stderr, "Failed to reallocate more memory for string\n");
                        exit(1);
                    }
                }
        }
    }
    printError(state, "String is unterminated");
    state->err = 1;
    return 0;
}

int pullIdentifier(struct token_state *state, char **out) {
    char *str;
    if ((str = (char *) malloc(1024 * sizeof(char))) == NULL) {
        fprintf(stderr, "Failed to allocate memory for identifier\n");
    }
    int len = 1024;
    int pos = 1;
    *str = *state->data;
    incTokenState(state);
    while (hasMore(state)) {
        char t = *state->data;
        if ((!isalnum(t)) && (t != '_')) break;
        str[pos] = t;
        pos++;
        if (pos == len) {
            len *= 2;
            if ((str = realloc(str, len * sizeof(char))) == NULL) {
                fprintf(stderr, "Failed to reallocate more memory for identifier\n");
                exit(1);
            }
        }
    }
    char *tstr = realloc(str, pos);
    if (tstr == NULL) *out = str;
    else *out = tstr;
    return pos;
}

#define NONE 0
#define L 1
#define LL 2
#define U 3
#define UL 4
#define ULL 5

struct generic_num {
    union {
        double d;
        float f;
        uint64_t i;
    } v;
    unsigned char type;
    unsigned char isNeg;
}

unsigned char pullNumSuffix(struct token_state *state) {
    unsigned char v = 0;
    unsigned char hadU = 0;
    unsigned char cntL = 0;
    while (hasMore(state)) {
        switch (*state->data) {
            case 'u':
            case 'U':
                if (hadU) return v;
                v += 3;
                hadU = 1;
                break;
            case 'l':
            case 'L':
                if (cntL == 2) return v;
                cntL++;
                v++;
                hadU = 1;
                break;
            default: return v;
        }
    }
    return v;
}

#define TYPE_DEC 0
#define TYPE_OCT 1
#define TYPE_HEX 2

int pullNum(struct token_state *state, struct generic_num *num) {
    unsigned char type = TYPE_DEC;
    char t = *state->data;
    if (t == '.') {
        incTokenState(state);
        char t;
        if ((!hasMore(state)) && (!isdigit(t = *state->data))) {
            state->data--;
            return 0;
        } else
        goto float_per;
    if (*state->data == '0') {
        incTokenState(state);
        char t;
        if (!hasMore(state)) {
            num->v.i = 0;
            num->type = NONE;
            num->isNeg = 0;
            return;
        } else if (((t = *state->data) == 'x') || (t == 'X')) {
            incTokenState(state);
            type = TYPE_HEX;
        } else type = TYPE_OCT;
    }
    MAX_T v;
    switch (type) {
        case TYPE_DEC:
            v = pullDecChars(state);
            break;
        case TYPE_OCT:
            v = pullOctChars(state);
            break;
        case TYPE_HEX:
            v = pullHexChars(state);
    }
    if (hasError(state)) {
        fprintf(stderr, "Unable to parse number literal\n");
        return;
    }
    if (!hasMore(state)) {
        num->v.i = v;
        num->type = NONE;
        num->isNeg = 0;
        return;
    }
    char t = *state->data;
    unsigned char type = 0;
    if ((t | 32) == 'u') {
        incTokenState(state);
        if (!hasMore(state)) {
            num->v.i = v;
            num->type = U;
            num->isNeg = 0;
            return;
        }
        type = U;
    }
    if ((t | 32) == 'l') {
        type += 1;
        incTokenState(state);
        if (!hasMore(state) || (((*state->data) | 32) != 'l')) {
            num->v.i = v;
            num->type = UL;
            num->isNeg = 0;
            return;
        } else {
            incTokenState(state);
            num->v.i = v;
            num->type = ULL;
            num->isNeg = 0;
            return;
        }
    }
    if (t == '.') {
        float_per:
        incTokenState(state)
    }
}

int pullOpt(struct token_state *state, char **out) {
    char t = *state->data;
    switch (t) {
        char *n;
        char t2;
        case '(':
        case ')':
        case '[':
        case ']':
        case ';':
        case ',':
        case '.':
        case ':':
        case '?':
        case '~':
            incTokenState(state);
            op_single:
            n = (char *) malloc(sizeof(char));
            if (n == NULL) {
                fprintf(stderr, "Failed to allocate operator data\n");
                exit(1);
            }
            *n = t;
            *out = n;
            return 1;
        case '+':
        case '-':
        case '&':
        case '|':
            incTokenState(state);
            if (!hasMore(state)) goto op_single;
            t2 = *state->data;
            if ((t == t2) || (t2 == '=')) {
                op_two_in:
                incTokenState(state);
                op_two:
                n = (char *) malloc(sizeof(char) * 2);
                if (n == NULL) {
                    fprintf(stderr, "Failed to allocate operator data\n");
                    exit(1);
                }
                *n = t;
                n[1] = t2;
                *out = n;
                return 2;
            } else goto op_single;
        case '<':
        case '>':
            incTokenState(state);
            if (!hasMore(state)) goto op_single;
            t2 = *state->data;
            if (t == t2) {
                incTokenState(state);
                if (!hasMore(state)) goto op_two;
                t2 = *state->data;
                if (t2 == '=') {
                    incTokenState(state);
                    n = (char *) malloc(sizeof(char) * 3);
                    if (n == NULL) {
                        fprintf(stderr, "Failed to allocate operator data\n");
                        exit(1);
                    }
                    n[1] = *n = t;
                    n[2] = '=';
                    *out = n;
                    return 3;
                } else goto op_two;
            } else if (t2 == '=') goto op_two_inc;
            else goto op_single;
        case '*':
        case '/':
        case '%':
        case '!':
        case '^':
        case '=':
            incTokenState(state);
            if (!hasMore(state)) goto op_single;
            t2 = *state->data;
            if (t2 == '=') goto op_two_inc;
            else goto op_single;
        default: return -1;
    }
}
*/

struct token_item {
    struct token_item *next;
    struct token_item *prev;
    char *type;
    char *data;
    int len;
}

struct token_item *createItem(char *type, char *data, int len) {
    struct token_item *i = (struct token_item *) malloc(sizeof(struct token_item));
    if (i == NULL) {
        fprintf(stderr, "Failed to allocate memory for token_item\n");
        exit(1);
    }
    i->next = NULL;
    i->prev = NULL:
    i->type = type;
    i->data = data;
    i->len = len;
    return i;
}

struct token_list {
    struct token_item *start;
    struct token_item *end;
}

void insertToken(struct token_list *list, struct token_item *item) {
    if (list->start == NULL) {
        list.start = item;
        list.end = item;
        item.prev = NULL;
        item.next = NULL;
    } else {
        item->prev = list->end;
        list->end->next = item;
        list->end = item;
        item->next = NULL;
    }
}

void freeAllItems(struct token_list *list) {
    struct token_item *current = list->start;
    while (current != NULL) {
        struct token_item *next = current->next;
        if (current->data != NULL) free(current->data);
        free(current);
        current = next;
    }
    list->start = list->end = NULL;
}

int tokenise(FILE *f, struct token_list *list, int dataLen) {
    freeAllItems(list);
    unsigned int line = 1;
    char t;
    while (fread(&t, 1, 1, f)) {
        after_loop_condition:
        if (isspace(t)) {
            // Parse whitespace
            insertToken(list, createItem("whitespace", NULL, -1));
            do {
                if (t == '\n') {
                    line++;
                }
                if (!fread(&t, 1, 1, f)) {
                    goto loop_end;
                }
            } while (isspace(t));
            goto after_loop_condition;
        } else if (t == '"') {
            // Parse string
            char *str;
            if ((str = (char *) malloc(1024)) == NULL) {
                fprintf(stderr, "Failed to allocate memory for string\n");
            }
            int mem = 1024;
            int len = 0;
            while (fread(&t, 1, 1, f)) {
                switch (t) {
                    case '"':
                        // End string
                        char *tstr = realloc(str, pos);
                        if (tstr == NULL) {
                            fputs("Warning: could not shrink allocation\n", stderr);
                        } else str = tstr;
                        goto str_end;
                    case '\n':
                        printError(state, "Unexpected line ending");
                        freeAllItems(list);
                        return -1;
                    case '\\':
                        // Read escape sequence
                        char t = pullEscChar(state);
                        if (hasError(state)) {
                            printError(state, "Invalid escape sequence");
                            return;
                        }
                        goto wrt;
                    default:
                        t = *state->data;
                        incTokenState(state);
                        wrt:
                        str[pos] = t;
                        pos++;
                        if (pos == len) {
                            len *= 2;
                            if ((str = realloc(str, len * sizeof(char))) == NULL) {
                                fprintf(stderr, "Failed to reallocate more memory forstring\n");
                                exit(1);
                            }
                        }
                }
            }
            str_end:
            printError(state, "String is unterminated");
            state->err = 1;
            return 0;
        } else if (t == '\'') {
            incTokenState(&state);
            char outChar = pullChar(&state);
            if (hasError(&state)) return -1;
            char *str = (char *) malloc(sizeof(char));
            *str = outChar;
            insertToken(list, createItem("char", str, 1));
        } else if (isdigit(t)) {
    }
    loop_end:
    
