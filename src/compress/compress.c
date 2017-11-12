#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <inttypes.h>
#include <signal.h>
#include <libgen.h>
#include <limits.h>

#include <complex.h> // must include before FFTW to use the native complex type

#define FFT_IQ_FILENAME "compress_fft.iq"
#define COMPRESS_IQ_FILENAME "compress.iq"

#define AVG_WINDOW 10 

#define COMPS_SAMPLE_BUFFER_LEN 1000

int N;

typedef struct {
  int16_t real;
  int16_t imag;
} complex16;

typedef struct {
  uint32_t freq;
  complex16 sample;
} compressed_sample;

void usage(char* path) {
  printf("Usage: %s <N> <threshold magnitude> <iterations> <center frequency (in KHz)> <sample rate>\n", path);
  printf("Output: %s/compress.iq\n", dirname(path));
  exit(EXIT_SUCCESS);
}

void float_complex_to_complex16(complex16* cs, float complex* cd, int n) { //{{{
  for (int i = 0; i < n; i++) {
    cs[i].real = (int16_t)(creal(cd[i]) * SHRT_MAX);
    cs[i].imag = (int16_t)(cimag(cd[i]) * SHRT_MAX);
  }
} //}}}

int read_next_dft_window(int fd, float complex* dft) { //{{{
  int bytes_to_read = (N*sizeof(float complex));
  while (bytes_to_read > 0) {
    int bytes_read = 0;
    if ((bytes_read =
          read(fd,((void*)dft) + bytes_read, bytes_to_read)) <= 0) {

      // EOF
      if (bytes_read == 0)
        return 0;

      perror("read()");
      exit(EXIT_FAILURE);
    }
    bytes_to_read -= bytes_read;
  }
  
  return 1;
} //}}}

int main(int argc, char** argv) {
  if (argc != 6)
    usage(argv[0]);

  N = atoi(argv[1]);
  float THRESH_MAG = atof(argv[2]);
  int HOLD_ITER = atoi(argv[3]);
  int START_FREQ = atoi(argv[4]) - atoi(argv[5])/2;
  int SAMPLE_RATE = atoi(argv[5]);

  // Create fft array
  float complex** fft = malloc((AVG_WINDOW*sizeof(float complex*)));
  float ** fft_abs = malloc((AVG_WINDOW*sizeof(float complex*)));
  for (int i = 0; i < N; i++) {
    fft[i] = malloc(N*sizeof(float complex));
    memset(fft[i], 0, (N*sizeof(float complex)));
    fft_abs[i] = malloc(N*sizeof(float));
    memset(fft_abs[i], 0, (N*sizeof(float)));
  }

  // Create avg array
  float* avg_sums = malloc(N*sizeof(float));

  compressed_sample comps[COMPS_SAMPLE_BUFFER_LEN];
  int comps_idx = 0;

  int* freq_counts = malloc(N*sizeof(int));
  memset(freq_counts, 0, sizeof(N*sizeof(int)));

  uint64_t dft_iter = 0;
  int64_t last_overthresh_iter[N];
  for (int i = 0; i < N; i++)
    last_overthresh_iter[i] = -1;

  int r_fd, w_fd;
  if ((r_fd = open(FFT_IQ_FILENAME, O_RDONLY)) < 0) {
    perror("open() read file");
    exit(EXIT_FAILURE);
  }
  if ((w_fd = open(COMPRESS_IQ_FILENAME, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR)) < 0) {
    perror("open() write file");
    exit(EXIT_FAILURE);
  }

  do {
    int fft_idx = dft_iter % AVG_WINDOW;
    float complex* iter_fft = fft[fft_idx];
    float* iter_fft_abs = fft_abs[fft_idx];

    // Remove oldest fft from averages
    for (int freq = 0; freq < N; freq++)
      avg_sums[freq] -= iter_fft_abs[freq];

    if (!read_next_dft_window(r_fd, iter_fft))
      goto end;

    // Compute fft magnitudes
     for (int freq = 0; freq < N; freq++)
      iter_fft_abs[freq] = cabsf(iter_fft[freq]); 

    // Add newest fft magnitudes to averages
    for (int freq = 0; freq < N; freq++)
      avg_sums[freq] += iter_fft_abs[freq];

    // Compute average power for triggering
    for (int freq = 0; freq < N; freq++) {
      float avg = avg_sums[freq] / AVG_WINDOW;

      // Triggering
      if (avg >= THRESH_MAG)
        last_overthresh_iter[freq] = dft_iter;

      // Store sample
      if (dft_iter <= (last_overthresh_iter[freq] + HOLD_ITER) &&
          last_overthresh_iter[freq] != -1) {
        float complex sample = fft[fft_idx][freq];
        complex16 sample_c16;
        float_complex_to_complex16(&sample_c16, &sample, 1);
        comps[comps_idx].freq = freq;
        comps[comps_idx].sample = sample_c16;
        comps_idx++;
        freq_counts[freq] += 1;

        // Compressed sample buffer is full, write it
        if (comps_idx >= COMPS_SAMPLE_BUFFER_LEN) {
          if (write(w_fd, &comps, sizeof(comps)) != sizeof(comps)) {
            perror("write()");
            exit(EXIT_FAILURE);
          }
          comps_idx = 0;
        }
      }
    }

    // print the number of counts in the freq bins
    if (dft_iter % 100000 == 0) {
      fprintf(stderr, "\E[H\E[2JFreq. counts:\n");
      for (int i = 0; i < N; i++) {
        if (i % 10 == 0)
          fprintf(stderr, "\n");
        int idx = (i / 10) + ((i % 10)*(N/10));
        int freq_khz = START_FREQ + (idx * (SAMPLE_RATE/N));
        fprintf(stderr, "%-6d %15d | ", freq_khz, freq_counts[idx]);
      }
    }

    dft_iter++;
  } while(1);

end:
  return 0;
}
