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

#define DECOMPRESS_FFT_IQ_FILENAME "/tmp/decompress_fft.iq"

typedef struct {
  float real;
  float imag;
} complex_float;

typedef struct {
  int16_t real;
  int16_t imag;
} complex16;

typedef struct {
  int32_t freq;
  complex16 sample;
} compressed_sample;

void complex16_to_complex_float(complex_float* cf, complex16* cs, int n) {
  for (int i = 0; i < n; i++) {
    cf[i].real = (cs[i].real * SHRT_SCALE);
    cf[i].imag = (cs[i].imag * SHRT_SCALE);
  }
}

int main(int argc, char** argv) {
  int fft_iter = 0;
  compressed_sample cses[100];
  complex_float fft[N];

  memset(fft, 0, sizeof(fft));

  int r_fd;
  if ((r_fd = open(argv[1], O_RDONLY)) < 0) {
    perror("open() read file");
    exit(EXIT_FAILURE);
  }

  int w_fd;
  if ((w_fd = open(DECOMPRESS_FFT_IQ_FILENAME, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR)) < 0) {
    perror("open() write file");
    exit(EXIT_FAILURE);
  }

  do {
    // read samples
    int bytes_read = 0;
    if ((bytes_read = read(r_fd, &cses, sizeof(cses))) <= 0) {
      if (bytes_read == 0)
        goto end;

      perror("read()");
      exit(EXIT_FAILURE);
    }

    int num_cses = bytes_read/sizeof(compressed_sample);
    for (int i = 0; i < num_cses; i++) {
      complex_float cf;
      compressed_sample cs = cses[i];

      if (cs.freq == -1) {
        fft_iter++;
        // end of DFT samples, write samples
        if (write(w_fd, fft, sizeof(fft)) < 0) {
          perror("write()");
          exit(EXIT_FAILURE);
        }
        memset(fft, 0, sizeof(fft));
      } else {
        complex16_to_complex_float(&cf, &cs.sample, 1);
        fft[cs.freq] = cf;
      }
    }
  } while(1);

end:
  fprintf(stderr, "DECOMPRESSION fft_iter: %d\n", fft_iter);
  if (write(w_fd, fft, sizeof(fft)) < 0) {
    perror("write()");
    exit(EXIT_FAILURE);
  }

  close(r_fd);
  close(w_fd);
  return 0;
}
