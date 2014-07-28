#include <gtk/gtk.h>

#include "toolbar.h"

/* Callback function */
static gint close_event(GtkWidget *widget, GdkEvent *event, gpointer data);
static gint new_event(GtkWidget *widget, GdkEvent *event, gpointer data);

/* create toolbar */
GtkWidget * create_toolbar(void)
{
    GtkWidget *handlebox;
    GtkWidget *toolbar;
    GtkWidget *icon;
    GtkWidget *new_button;
    GtkWidget *close_button;
    GtkWidget *label;
    GtkWidget *entry;

    /* create handle box */
    handlebox = gtk_handle_box_new();

    /* create toolbar widget */
    toolbar = gtk_toolbar_new();
    gtk_toolbar_set_orientation(GTK_TOOLBAR(toolbar), GTK_ORIENTATION_HORIZONTAL);
    gtk_toolbar_set_style(GTK_TOOLBAR(toolbar), GTK_TOOLBAR_ICONS);
    gtk_toolbar_set_tooltips(GTK_TOOLBAR(toolbar), TRUE);
    gtk_container_set_border_width(GTK_CONTAINER(toolbar), 2);
    gtk_container_add(GTK_CONTAINER(handlebox), toolbar);

    /* add new button on the toolbar */
    icon = gtk_image_new_from_file("new.png");
    close_button = gtk_toolbar_append_item(
            GTK_TOOLBAR(toolbar),
            "New",
            "Create new note",
            "private",
            icon,
            GTK_SIGNAL_FUNC(new_event),
            NULL
            );
    gtk_toolbar_append_space(GTK_TOOLBAR(toolbar));

    /* add close button on the toolbar */
    icon = gtk_image_new_from_file("close.png");
    close_button = gtk_toolbar_append_item(
            GTK_TOOLBAR(toolbar),
            "close",
            "close application",
            "private",
            icon,
            GTK_SIGNAL_FUNC(close_event),
            NULL
            );
    gtk_toolbar_append_space(GTK_TOOLBAR(toolbar));

    /* add serach label on the toolbar */
    label = gtk_label_new("Search: ");
    gtk_toolbar_append_widget(
            GTK_TOOLBAR(toolbar),
            label,
            NULL,
            NULL
            );
    gtk_widget_show(label);

    /* add entry widget on the toolbar */
    entry = gtk_entry_new();
    gtk_toolbar_append_widget(
            GTK_TOOLBAR(toolbar),
            entry,
            "This is just an entry",
            "Private"
            );
    gtk_widget_show(entry);

    gtk_widget_show(toolbar);

    return handlebox;
}

static gint close_event(GtkWidget * widget, GdkEvent * event, gpointer data)
{
    gtk_main_quit();
    return FALSE;
}

static gint new_event(GtkWidget *widget, GdkEvent *event, gpointer data)
{
    return TRUE;
}

