#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <inttypes.h>
#include <signal.h>
#include <limits.h>
#include <math.h>

#include <complex.h> // must include before FFTW to use the native complex type

#define N 400
#define SHRT_SCALE (1.0/SHRT_MAX)

#define COMPRESS_IQ_FILENAME "compress.iq"
#define DECOMPRESS_FFT_IQ_FILENAME "decompress_fft.iq"

typedef struct {
  float real;
  float imag;
} complex_float;

typedef struct {
  int16_t real;
  int16_t imag;
} complex16;

typedef struct {
  uint32_t freq;
  complex16 sample;
} compressed_sample;

void complex16_to_complex_float(complex_float* cf, complex16* cs, int n) {
  for (int i = 0; i < n; i++) {
    cf[i].real = (cs[i].real * SHRT_SCALE);
    cf[i].imag = (cs[i].imag * SHRT_SCALE);
  }
}

int main(int argc, char** argv) {
  compressed_sample cses[100];
  complex_float fft[N];

  memset(fft, 0, sizeof(fft));

  int r_fd;
  if ((r_fd = open(COMPRESS_IQ_FILENAME, O_RDONLY)) < 0) {
    perror("open() read file");
    exit(EXIT_FAILURE);
  }

  int w_fd;
  if ((w_fd = open(DECOMPRESS_FFT_IQ_FILENAME, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR)) < 0) {
    perror("open() write file");
    exit(EXIT_FAILURE);
  }

  int32_t freq_prev = -1;
  do {
    // read samples
    int bytes_to_read = sizeof(cses);
    while (bytes_to_read > 0) {
      int bytes_read = 0;
      if ((bytes_read = read(r_fd, ((void*)&cses) + bytes_read, bytes_to_read)) <= 0) {
        // EOF
        if (bytes_read == 0)
          goto end;

        perror("read()");
        exit(EXIT_FAILURE);
      }
      bytes_to_read -= bytes_read;
    }

    for (int i = 0; i < 100; i++) {
      complex_float cf;
      compressed_sample cs = cses[i];
      complex16_to_complex_float(&cf, &cs.sample, 1);

      // end of DFT samples, 
      if (cs.freq <= freq_prev) {
        if (write(w_fd, fft, sizeof(fft)) < 0) {
          perror("write()");
          exit(EXIT_FAILURE);
        }
        memset(fft, 0, sizeof(fft));
      }
      fft[cs.freq] = cf;
      freq_prev = cs.freq;
    }
  } while(1);

end:
  close(r_fd);
  close(w_fd);
  return 0;
}
