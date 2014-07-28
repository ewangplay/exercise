#include <gtk/gtk.h>

int main(int argc, char *argv[])
{
    GtkWidget *window;
    GtkWidget *eventbox;
    GtkWidget *label;

    /* initialize */
    gtk_init(&argc, &argv);

    /* create the main window */
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);

    /* set signal for main window */
    g_signal_connect(G_OBJECT(window), "delete_event", G_CALLBACK(gtk_main_quit), NULL);

    /* set the title for main window */
    gtk_window_set_title(GTK_WINDOW(window), "event box demo");

    /* set border width for main window */
    gtk_container_set_border_width(GTK_CONTAINER(window), 10);
    
    /* create the event box */
    eventbox = gtk_event_box_new();

    /* add the event box into the main window */
    gtk_container_add(GTK_CONTAINER(window), eventbox);

    /* show the box */
    gtk_widget_show(eventbox);

    /* create the label */
    label = gtk_label_new("click to quit, quit, quit!");

    /* add the label into the event box */
    gtk_container_add(GTK_CONTAINER(eventbox), label);

    /* show the label */
    gtk_widget_show(label);

    /* cut out the label */
    gtk_widget_set_size_request(label, 200, 20);

    /* set event for event box */
    gtk_widget_set_events(eventbox, GDK_BUTTON_PRESS_MASK | GDK_ENTER_NOTIFY_MASK);
    g_signal_connect(G_OBJECT(eventbox), "button_press_event", G_CALLBACK(gtk_main_quit), NULL);

    /* set cursor style */
    gtk_widget_realize(eventbox);
    gdk_window_set_cursor(eventbox->window, gdk_cursor_new(GDK_HAND2));
    
    /* show the main window */
    gtk_widget_show(window);

    /* main loop */;
    gtk_main();

    return 0;
}

