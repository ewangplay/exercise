#include <gtk/gtk.h>

void check_snap_to_ticks(GtkWidget *widget, gpointer data)
{
}

void calendar_callback(GtkWidget *widget, gpointer data)
{ 
    GtkWidget *dialog;

    gint result;

    /* create the popup dialog */
    dialog = gtk_dialog_new_with_buttons("calendar", GTK_WINDOW(data),
            GTK_DIALOG_MODAL | GTK_DIALOG_NO_SEPARATOR,
            GTK_STOCK_OK,
            GTK_RESPONSE_OK,
            GTK_STOCK_CANCEL,
            GTK_RESPONSE_CANCEL,
            NULL);

    /* set the default button for dialog */
    gtk_dialog_set_default_response(GTK_DIALOG(dialog), GTK_RESPONSE_OK);


    /* show the dialog */
    result = gtk_dialog_run(GTK_DIALOG(dialog));
    switch(result)
    {
        case GTK_RESPONSE_OK:
            break;
        case GTK_RESPONSE_CANCEL:
            /* do nothing since dialog is canceled */
            break;
        default:
            /* do nothing */
            break;
    }
    gtk_widget_destroy(dialog);
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
    gtk_window_set_title(GTK_WINDOW(window), "calendar");

    /* set border width for main window */
    gtk_container_set_border_width(GTK_CONTAINER(window), 10);
    
    /* create the box */
    box = gtk_hbox_new(TRUE, 3);

    /* add the box into the main window */
    gtk_container_add(GTK_CONTAINER(window), box);

    /* show the box */
    gtk_widget_show(box);

    /* create calendar button */
    button = gtk_button_new_with_label("calendar");

    /* set the signal for calendar button */
    g_signal_connect(G_OBJECT(button), "clicked", G_CALLBACK(calendar_callback), window);

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

