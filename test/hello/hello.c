typedef struct {
	unsigned char empty;
	unsigned char full;
	unsigned short count;
} buf_status_t;

typedef struct {
	unsigned int tx_data;
	buf_status_t tx_status;
	unsigned int rx_data;
	buf_status_t rx_status;
} buffer_t;

#define BUFFER ((volatile buffer_t*)0xA2000000)


int main()
{
	char* msg = "Hello, World!\n";

	do {
		if (!BUFFER->tx_status.full) {
			BUFFER->tx_data = *msg;
		}
	} while (*msg++);

	return 0;
}
