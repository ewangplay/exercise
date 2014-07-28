#include <gtk/gtk.h>

#include "textview.h"

static void insert_text(GtkTextBuffer *buffer);

/* create text view */
GtkWidget * create_text_view(void)
{
    GtkWidget *scroll_window;
    GtkWidget *text_view;
    GtkTextBuffer *buffer;

    /* create the scroll window */
    scroll_window = gtk_scrolled_window_new(NULL, NULL);
    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scroll_window), 
            GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);

    /* crewte the text view */
    text_view = gtk_text_view_new();
    gtk_text_view_set_editable(GTK_TEXT_VIEW(text_view), FALSE);
    buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(text_view));

    /* add the text view into the scroll window */
    gtk_container_add(GTK_CONTAINER(scroll_window), text_view);

    insert_text(buffer);

    gtk_widget_show(text_view);

    return scroll_window;
}

static void insert_text(GtkTextBuffer * buffer)
{
   GtkTextIter iter;
 
   gtk_text_buffer_get_iter_at_offset (buffer, &iter, 0);

   gtk_text_buffer_insert (buffer, &iter,   
    "From: pathfinder@nasa.gov\n"
    "To: mom@nasa.gov\n"
    "Subject: Made it!\n"
    "\n"
    "We just got in this morning. The weather has been\n"
    "great - clear but cold, and there are lots of fun sights.\n"
    "Sojourner says hi. See you soon.\n"
    " -Path\n", -1);
}


