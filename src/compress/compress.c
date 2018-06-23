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

#define PRINT_AND_ROTATE_DFT_ITERS 50000

#define FFT_IQ_FILENAME "/tmp/compress_fft.iq"
#define COMPRESS_IQ_FILENAME "compress"
#define TEMP_COMPRESS_IQ_FILENAME "/tmp/compress_tmp.iqz"

#define COMPS_SAMPLE_BUFFER_LEN 1000

typedef struct {
  int16_t real;
  int16_t imag;
} complex16;

typedef struct {
  int32_t bin;
  complex16 sample;
} compressed_sample;

typedef struct {
  // Parameters, these must be set before initalizing iqz.
  int N;
  float THRESH_MAG;
  int HOLD_ITER;
  int START_FREQ;
  int SAMPLE_RATE;
  int AVG_ITER;

  int* bins_active;

  compressed_sample comps[COMPS_SAMPLE_BUFFER_LEN];
  int comps_idx;

  uint64_t iter;

  float complex** ffts;
  float** fft_abses;

  float* avg_sums;

  int* bin_counts;

  int64_t* last_overthresh_iter;

  int w_fd;
  uint64_t w_startsample;
  uint8_t* w_binstored;
  int w_binstored_len;
} iqz_state;

void usage(char* path) {
  printf("Usage: %s <N> <threshold magnitude> <iterations> <center frequency (in KHz)> <sample rate> <skip bins...>\n", path);
  printf("Output: %s/compress-*.iqz\n", dirname(path));
  exit(EXIT_SUCCESS);
}

void float_complex_to_complex16(complex16* cs, float complex* cd, int n) { //{{{
  for (int i = 0; i < n; i++) {
    cs[i].real = (int16_t)(creal(cd[i]) * SHRT_MAX);
    cs[i].imag = (int16_t)(cimag(cd[i]) * SHRT_MAX);
  }
} //}}}

uint32_t iqz_freq_bin_to_khz(iqz_state* st, int32_t bin_idx) {
  return st->START_FREQ + (bin_idx * (st->SAMPLE_RATE / st->N));
}

void iqz_init(iqz_state* st) {
  st->w_fd = -1;

  st->iter = 0;

  // Init the compressed samples
  memset(&st->comps, 0, sizeof(st->comps));
  st->comps_idx = 0;

  // Allocate and init ffts array.
  int ffts_iters = st->AVG_ITER + st->HOLD_ITER;
  st->ffts = malloc(ffts_iters * sizeof(float complex*));
  for (int i = 0; i < ffts_iters; i++) {
    st->ffts[i] = malloc(st->N * sizeof(float complex));
    memset(st->ffts[i], 0, (st->N * sizeof(float complex)));
  }

  // Allocate and init fft abs value array.
  st->fft_abses = malloc((st->AVG_ITER * sizeof(float*)));
  for (int i = 0; i < st->AVG_ITER; i++) {
    st->fft_abses[i] = malloc(st->N * sizeof(float));
    memset(st->fft_abses[i], 0, (st->N * sizeof(float)));
  }

  // Alloc and init avg array.
  st->avg_sums = malloc(st->N * sizeof(float));
  memset(st->avg_sums, 0, (st->N * sizeof(float)));

  // Alloc and init bin counts array.
  st->bin_counts = malloc(st->N * sizeof(int));
  memset(st->bin_counts, 0, (st->N * sizeof(int)));

  // Alloc and init bin active array.
  st->bins_active = malloc(st->N * sizeof(int));
  memset(st->bins_active, 1, (st->N * sizeof(int)));

  // Alloc and init last overthresh iter array.
  st->last_overthresh_iter = malloc(st->N * sizeof(int));
  for (int i = 0; i < st->N; i++)
    st->last_overthresh_iter[i] = -1;

  // Alloc and init write file bins stored array.
  st->w_binstored = malloc(st->N);
  memset(st->w_binstored, 0, st->N);
  st->w_binstored_len = 0;
}

void iqz_open_file(iqz_state* st) {
  // This is not accurate, it is offset by the number of samples buffered for HOLD_ITER and AVG_TER,
  // but we really don't care about the absolute starting value of the sample number.
  // We just care about the relative sample number between files.
  st->w_startsample = st->iter * st->N;

  memset(st->w_binstored, 0, st->N);
  st->w_binstored_len = 0;

  if ((st->w_fd = open(TEMP_COMPRESS_IQ_FILENAME,
                       O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR)) < 0) {
    perror("open() write file");
    exit(EXIT_FAILURE);
  }
}

void iqz_close_file(iqz_state* st) {
  // Close temporary file.
  close(st->w_fd);
  st->w_fd = -1;

  // Create filename that contains sample number and freqs stored.
  char filename[1024];
  sprintf(filename, "%s-%lu:", COMPRESS_IQ_FILENAME, st->w_startsample);

  if (st->w_binstored_len < 8) {
    for (int bin = 0; bin < st->N; bin++) {
      if (st->w_binstored[bin]) {
        sprintf(filename + strlen(filename), "_%u", iqz_freq_bin_to_khz(st, bin));
      }
    }
  } else {
    sprintf(filename + strlen(filename), "_+++");
  }

  sprintf(filename + strlen(filename), ".iqz");

  if (rename(TEMP_COMPRESS_IQ_FILENAME, filename) < 0) {
    perror("rename() write file");
    exit(EXIT_FAILURE);
  }
}

void iqz_store_sample(iqz_state* st, complex float* sample, int32_t bin) {
  // Note: Flush buffer to file if sample == NULL.

  // Add compressed sample to buffer.
  if (sample != NULL) {
    complex16 sample_c16;
    float_complex_to_complex16(&sample_c16, sample, 1);
    st->comps[st->comps_idx].bin = bin;
    st->comps[st->comps_idx].sample = sample_c16;
    st->comps_idx++;
    st->bin_counts[bin] += 1;

    if (!st->w_binstored[bin]) {
      st->w_binstored[bin] = 1;
      st->w_binstored_len++;
    }
  }

  // Compressed sample buffer is full, write it to the file.
  if (st->comps_idx >= COMPS_SAMPLE_BUFFER_LEN || sample == NULL) {
    // Open file if it is already not open.
    if (st->w_fd == -1) {
      iqz_open_file(st);
    }

    // Write to file.
    size_t write_len = st->comps_idx * sizeof(compressed_sample);
    if (write(st->w_fd, &st->comps, write_len) != write_len) {
      perror("write()");
      exit(EXIT_FAILURE);
    }
    st->comps_idx = 0;
  }
}

int read_next_dft_window(int fd, float complex* dft, int N) { //{{{
  int bytes_to_read = (N * sizeof(float complex));
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
  if (argc < 6)
    usage(argv[0]);

  iqz_state st;

  // Parse command line parameters.
  st.N = atoi(argv[1]);
  st.THRESH_MAG = atof(argv[2]);
  st.HOLD_ITER = atoi(argv[3]);
  st.START_FREQ = atoi(argv[4]) - atoi(argv[5])/2;
  st.SAMPLE_RATE = atoi(argv[5]);

  // set the squelch avg window to the same parameter as the hold iter after a transmission ends
  st.AVG_ITER = 100;

  // Now that the parameters are set, complete the iqz initialization.
  iqz_init(&st);

  // Create list of bins to skip
  for (int i = 6; i < argc; i++) {
     st.bins_active[atoi(argv[i])] = 0;
  }

  int r_fd;
  if ((r_fd = open(FFT_IQ_FILENAME, O_RDONLY)) < 0) {
    perror("open() read file");
    exit(EXIT_FAILURE);
  }

  int stored = 0;
  int ffts_iters = st.AVG_ITER + st.HOLD_ITER;

  do {
    // Init current iteration variables.
    int iter_ffts_idx = st.iter % ffts_iters;
    float complex* iter_fft = st.ffts[iter_ffts_idx];
    int iter_fft_abses_idx = st.iter % st.AVG_ITER;
    float* iter_fft_abs = st.fft_abses[iter_fft_abses_idx];
    stored = 0;

    // The ordering here is kinda funny, but it is for performance.
    // This ordering allows directly reading the new fft into the buffer.

    if (st.iter >= ffts_iters) {
      for (int bin = 0; bin < st.N; bin++) {
        // Skip bin if not active
        if (!st.bins_active[bin])
          continue;

        // Compute average power for triggering.
        float avg = st.avg_sums[bin] / st.AVG_ITER;

        // Triggering
        if (avg >= st.THRESH_MAG) {
          st.last_overthresh_iter[bin] = st.iter;
        }

        // Store oldest sample in fft buffer.
        if (st.last_overthresh_iter[bin] != -1 &&
          (st.iter - st.HOLD_ITER) <= (st.last_overthresh_iter[bin] + st.HOLD_ITER)) {
          float complex sample = iter_fft[bin];
          iqz_store_sample(&st, &sample, bin);
          stored = 1;
        }
      }

      if (stored) {
        // Add end-of-DFT marker.
        complex float zero_sample;
        memset(&zero_sample, 0, sizeof(zero_sample));
        iqz_store_sample(&st, &zero_sample, -1);
      } else {
        // Rotate the log file.
        if (st.w_fd != -1) {
          // Flush the file.
          iqz_store_sample(&st, NULL, 0);

          // Close file.
          iqz_close_file(&st);
        }
      }

      // Print the number of counts in the freq bins and rotate log file if needed
      if (st.iter % PRINT_AND_ROTATE_DFT_ITERS == 0) {
        fprintf(stderr, "\E[H\E[2JFreq. counts:\n");
        for (int i = 0; i < st.N; i++) {
          if (i % 10 == 0)
            fprintf(stderr, "\n");
          int32_t bin = (i / 10) + ((i % 10)*(st.N/10));
          fprintf(stderr, "%-6d %15d | ", iqz_freq_bin_to_khz(&st, bin), st.bin_counts[bin]);
        }
      }
    }

    // Remove oldest fft from averages.
    for (int bin = 0; bin < st.N; bin++)
      st.avg_sums[bin] -= iter_fft_abs[bin];

    if (!read_next_dft_window(r_fd, iter_fft, st.N))
      goto end;

    // Compute fft magnitudes of new fft.
     for (int bin = 0; bin < st.N; bin++)
      iter_fft_abs[bin] = cabsf(iter_fft[bin]);

    // Add newest fft magnitudes to averages.
    for (int bin = 0; bin < st.N; bin++)
      st.avg_sums[bin] += iter_fft_abs[bin];

    st.iter++;
  } while(1);

end:
  return 0;
}
