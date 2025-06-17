#ifndef GNOME_WATCHER_PROCS_H
#define GNOME_WATCHER_PROCS_H
#include <dirent.h>
#include <stddef.h>
#include <stdint.h>
#include <sys/types.h>

#define INITIAL_CAPACITY 25

typedef struct {
  uint16_t *array;
  size_t size;
  size_t capacity;
} PIDS;

typedef struct {
  DIR *dir_fd;
  PIDS *pids;
  int current_index;
} PROCTAB;

typedef struct {
  int pid;       // Process ID
  char name[64]; // Process name
} PROCINFO;

PROCTAB *open_proc();
int read_proc(PROCTAB *proc_tab, PROCINFO *proc_info);
void init_pids(PIDS *pids);
void append_pid(PIDS *pids, uint16_t pid);
void free_pids(PIDS *pids);
void close_proc(PROCTAB *proc_tab);

#endif // GNOME_WATCHER_PROCS_H
