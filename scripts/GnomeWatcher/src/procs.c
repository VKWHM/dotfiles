#include "procs.h"
#include "utils.h"
#include <dirent.h>
#include <fcntl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

void init_pids(PIDS *pids) {
  pids->array = calloc(INITIAL_CAPACITY, sizeof(uint16_t));
  if (pids->array == NULL)
    ERROR("Failed to allocate memory for PIDS array");
  pids->size = 0;
  pids->capacity = INITIAL_CAPACITY;
}

void append_pid(PIDS *pids, uint16_t pid) {
  if (pids->size >= pids->capacity) {
    size_t caps = pids->capacity * 2;
    uint16_t *newArray = reallocarray(pids->array, caps, sizeof(uint16_t));
    if (newArray == NULL) {
      perror("failed to reallocate memory for PIDS array");
      return;
    }
    pids->capacity = caps;
    pids->array = newArray;
  }
  pids->array[pids->size++] = pid;
}

void free_pids(PIDS *pids) {
  if (pids == NULL)
    return;
  free(pids->array);
  pids->array = NULL;
  pids->size = 0;
  pids->capacity = 0;
}

PROCTAB *open_proc() {
  PROCTAB *proc_tab;
  DIR *dir;
  struct dirent *dir_entires;

  proc_tab = malloc(sizeof(PROCTAB));
  if (proc_tab == NULL)
    ERROR("Failed to allocate memory for PROCTAB");

  dir = opendir("/proc");
  if (dir == NULL)
    ERROR("Failed to open /proc directory");

  uint16_t pid;
  PIDS *pids = malloc(sizeof(PIDS));
  init_pids(pids);

  while ((dir_entires = readdir(dir)) != NULL) {
    if (dir_entires->d_type != DT_DIR || (pid = atoi(dir_entires->d_name)) == 0)
      continue;
    append_pid(pids, pid);
  }

  proc_tab->dir_fd = dir;
  proc_tab->pids = pids;
  proc_tab->current_index = 0;
  return proc_tab;
}

int read_proc(PROCTAB *proc_tab, PROCINFO *proc_info) {
  if (proc_tab->current_index >= proc_tab->pids->size)
    return -1;
  uint16_t pid = proc_tab->pids->array[proc_tab->current_index++];
  char buf[64] = {0}, name[64] = {0};
  snprintf(buf, 64, "/proc/%d/comm", pid);
  int fd = open(buf, O_RDONLY);

  if (fd == -1)
    ERROR("Failed to open process file");

  if (-1 == read(fd, name, 64))
    ERROR("Failed to read process name");

  close(fd);

  strncpy(proc_info->name, name, 64);
  proc_info->pid = pid;
  return 0;
}

void close_proc(PROCTAB *proc_tab) {
  if (proc_tab == NULL)
    return;

  int status = closedir(proc_tab->dir_fd);
  if (status < 0)
    ERROR("Failed to close /proc directory");

  free_pids(proc_tab->pids);
  free(proc_tab->pids);
  free(proc_tab);
}
