#ifndef GNOME_WATCHER_UTILS_H
#define ERROR(msg)                                                             \
  do {                                                                         \
    perror(msg);                                                               \
    exit(EXIT_FAILURE);                                                        \
  } while (0)

#endif // !DEBUG
