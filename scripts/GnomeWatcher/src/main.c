#include "glib-object.h"
#include "glib.h"
#include <gio/gio.h>
#include <proc/readproc.h>
#include <signal.h>
#include <stdio.h>
#include <stdlib.h>

int notify_proc(short is_dark) { // 1 -> Dark, 0 -> Light
  PROCTAB *proc_tab;
  proc_t proc_info;

  proc_tab = openproc(PROC_FILLCOM | PROC_FILLSTAT);

  if (proc_tab == NULL) {
    perror("Failed to open process table");
    return -1;
  }

  while (1) {
    memset(&proc_info, 0, sizeof(proc_t));
    if (readproc(proc_tab, &proc_info) == NULL)
      break;

    if (strncmp(proc_info.cmd, "zsh", 3) == 0)
      kill(proc_info.tid, is_dark ? SIGUSR1 : SIGUSR2);
  }
  closeproc(proc_tab);
  return 0;
}

static void on_setting_changed(GSettings *settings, gchar *key,
                               gpointer user_data) {
  if (g_strcmp0(key, "color-scheme") == 0) {
    gchar *scheme = g_settings_get_string(settings, key);
    notify_proc(g_strcmp0(scheme, "prefer-dark") == 0 ||
                g_strcmp0(scheme, "dark") == 0);
    g_free(scheme);
  }
}

int main(int argc, char *argv[]) {

  GMainLoop *loop;
  GSettings *settings;

  settings = g_settings_new("org.gnome.desktop.interface");

  g_signal_connect(settings, "changed", G_CALLBACK(on_setting_changed), NULL);

  loop = g_main_loop_new(NULL, FALSE);

  g_main_loop_run(loop);

  g_object_unref(settings);
  g_main_loop_unref(loop);

  return EXIT_SUCCESS;
}
