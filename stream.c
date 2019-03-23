#define STREAM_BUFF_SIZE 2048
#define STREAM_STATE_EOF 0
#define STREAM_STATE_ERR 1
#define STREAM_STATE_FIN 2
#define STREAM_STATE_INF 3

struct stream_in {
    FILE *file;
    char *data;
    unsigned int pos;
    unsigned int len;
    unsigned char state;
}

void initStream(struct stream_in *stream, FILE *file) {
    if ((stream->data = malloc(STREAM_BUFF_SIZE)) == NULL) {
        fputs("Could not allocate stream memory\n", stderr);
        exit(1);
    }
    stream->file = file;
    stream->pos = 0;
    stream->len = 0;
    stream->state = STREAM_STATE_INF;
}

char readChar(struct stream_in *stream, )
