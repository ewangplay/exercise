#include <gtk/gtk.h>

void file_ok_sel(GtkWidget *widget, GtkFileSelection * filew)
{
    g_print("%s\n", gtk_file_selection_get_filename(GTK_FILE_SELECTION(filew)));
}

void fileselection_callback(GtkWidget *widget, gpointer data)
{ 
    GtkWidget *fileselect;

    /* create the file selction */
    fileselect = gtk_file_selection_new("File selection");

    /* set callback function for ok button */
    g_signal_connect(G_OBJECT(GTK_FILE_SELECTION(fileselect)->ok_button), "clicked", G_CALLBACK(file_ok_sel), fileselect);

    /* set callback function for cancel button */
    g_signal_connect_swapped(G_OBJECT(GTK_FILE_SELECTION(fileselect)->cancel_button), "clicked", G_CALLBACK(gtk_widget_destroy), fileselect);

    /* show the file selection */
    gtk_widget_show(fileselect);
}

void destroy(GtkWidget *widget, gpointer data)
{
    gtk_main_quit();
}

int main(int argc, char *argv[])
{
    GtkWidget *window;
    GtkWidget *box;
    GtkWidget *button;

    /* initialize */
    gtk_init(&argc, &argv);

    /* create the main window */
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);

    /* set signal for main window */
    g_signal_connect(G_OBJECT(window), "delete_event", G_CALLBACK(gtk_main_quit), NULL);

    /* set the title for main window */
    gtk_window_set_title(GTK_WINDOW(window), "file selection");

    /* set border width for main window */
    gtk_container_set_border_width(GTK_CONTAINER(window), 10);
    
    /* create the box */
    box = gtk_hbox_new(TRUE, 3);

    /* add the box into the main window */
    gtk_container_add(GTK_CONTAINER(window), box);

    /* show the box */
    gtk_widget_show(box);

    /* create calendar button */
    button = gtk_button_new_with_label("file select...");

    /* set the signal for calendar button */
    g_signal_connect(G_OBJECT(button), "clicked", G_CALLBACK(fileselection_callback), window);

    /* pack the login button into the box */
    gtk_box_pack_start_defaults(GTK_BOX(box), button);

    /* show the login button */
    gtk_widget_show(button);

    /* create the close button */
    button = gtk_button_new_with_label("close");

    /* set the signal for close button */
    g_signal_connect_swapped(G_OBJECT(button), "clicked", G_CALLBACK(destroy), NULL);

    /* pack the close button into the hbox */
    gtk_box_pack_start_defaults(GTK_BOX(box), button);

    /* show the close button */
    gtk_widget_show(button);
    
    /* show the main window */
    gtk_widget_show(window);

    /* main loop */;
    gtk_main();

    return 0;
}

