#define STREAM_BUFF_SIZE 2048
#define STREAM_STATE_EOF 0
#define STREAM_STATE_FIN 2
#define STREAM_STATE_INF 3

#define canPull(s) ((s)->state != STREAM_STATE_EOF)

struct stream_in {
    FILE *file;
    char *data;
    unsigned int pos;
    unsigned int len;
    unsigned int line;
    unsigned char state;
};

void incStream(struct stream_in *stream) {
    stream->pos++;
    if (stream->pos < stream->len) return;
    switch (stream->state) {
        case STREAM_STATE_INF:
            stream->len = fread(stream->data, 1, STREAM_BUFF_SIZE, stream->file);
            if (ferror(stream->file)) {
                fputs("[IO] Read error\n", stderr);
                exit(1);
            } else if (feof(stream->file)) {
                if (!stream->len) {
                    stream->state = STREAM_STATE_EOF;
                    return;
                } else stream->state = STREAM_STATE_FIN;
            } else {
                stream->state = STREAM_STATE_INF;
            }
            stream->pos = 0;
            return;
        case STREAM_STATE_FIN:
            stream->state = STREAM_STATE_EOF;
        case STREAM_STATE_EOF:
            return;
    }
}

void initStream(struct stream_in *stream, FILE *file) {
    if ((stream->data = malloc(STREAM_BUFF_SIZE)) == NULL) {
        fputs("Could not allocate stream memory\n", stderr);
        exit(1);
    }
    stream->file = file;
    stream->pos = 0;
    stream->len = 0;
    stream->line = 1;
    stream->state = STREAM_STATE_INF;
    incStream(stream);
}
