#include <gtk/gtk.h>

int main(int argc, char *argv[])
{
    GtkWidget *window;
    GtkWidget *fixed;
    GtkWidget *button;
    int i;

    /* initialize */
    gtk_init(&argc, &argv);

    /* create the main window */
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);

    /* set signal for main window */
    g_signal_connect(G_OBJECT(window), "delete_event", G_CALLBACK(gtk_main_quit), NULL);

    /* set the title for main window */
    gtk_window_set_title(GTK_WINDOW(window), "fixed container");

    /* set border width for main window */
    gtk_container_set_border_width(GTK_CONTAINER(window), 10);
    
    /* create the fixed container */
    fixed = gtk_fixed_new();

    /* add the event box into the main window */
    gtk_container_add(GTK_CONTAINER(window), fixed);

    /* show the box */
    gtk_widget_show(fixed);

    /* create the buttons */
    for(i = 1; i <= 3; i++)
    {
        button = gtk_button_new_with_label("press me");
        gtk_fixed_put(GTK_FIXED(fixed), button, i*50, i*50);
        gtk_widget_show(button);
    }
   
    /* show the main window */
    gtk_widget_show(window);

    /* main loop */;
    gtk_main();

    return 0;
}

