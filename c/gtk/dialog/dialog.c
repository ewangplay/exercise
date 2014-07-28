#include <gtk/gtk.h>

void check_anonymous_login(GtkWidget *widget, gpointer data)
{
    if(gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(widget)))
    {
        g_print("select anonymous login\n");
    }
    else
    {
        g_print("unselect anonymouse login\n");
    }
}

void login_callback(GtkWidget *widget, gpointer data)
{
    GtkWidget *dialog;
    GtkWidget *label;
    GtkWidget *box;
    GtkWidget *user_entry;
    GtkWidget *passwd_entry;
    GtkWidget *button;
    gint result;

    /* create the popup dialog */
    dialog = gtk_dialog_new_with_buttons("login", GTK_WINDOW(data),
            GTK_DIALOG_MODAL | GTK_DIALOG_NO_SEPARATOR,
            GTK_STOCK_OK,
            GTK_RESPONSE_OK,
            GTK_STOCK_CANCEL,
            GTK_RESPONSE_CANCEL,
            NULL);

    /* set the default button for dialog */
    gtk_dialog_set_default_response(GTK_DIALOG(dialog), GTK_RESPONSE_OK);

    /* create the hbox */
    box = gtk_hbox_new(FALSE, 0);

    /* add the hbox into the dialog vbox */
    gtk_container_add(GTK_CONTAINER(GTK_DIALOG(dialog)->vbox), box);
    gtk_widget_show(box);

    /* create the user label */
    label = gtk_label_new("User: ");

    /* add the label into the hbox and show it. */
    gtk_box_pack_start_defaults(GTK_BOX(box), label);
    gtk_widget_show(label);

    /* create the user entry */
    user_entry = gtk_entry_new();

    /* add the user entry into the hbox and show it. */
    gtk_box_pack_start_defaults(GTK_BOX(box), user_entry);
    gtk_widget_show(user_entry);

    /* create the second hbox */
    box = gtk_hbox_new(FALSE, 0);

    /* add the box into the dialog vbox */
    gtk_container_add(GTK_CONTAINER(GTK_DIALOG(dialog)->vbox), box);
    gtk_widget_show(box);

    /* create the password label */
    label = gtk_label_new("Password: ");

    /* add the label into the hbox and show it. */
    gtk_box_pack_start_defaults(GTK_BOX(box), label);
    gtk_widget_show(label);

    /* create the password entry */
    passwd_entry = gtk_entry_new();

    /* set the password entry invisable */
    gtk_entry_set_visibility(GTK_ENTRY(passwd_entry), FALSE);

    /* add the password entry into the hbox and show it. */
    gtk_box_pack_start_defaults(GTK_BOX(box), passwd_entry);
    gtk_widget_show(passwd_entry);

    /* create the third hbox */
    box = gtk_hbox_new(FALSE, 0);

    /* add the hbox into the dialog vbox and show it */
    gtk_container_add(GTK_CONTAINER(GTK_DIALOG(dialog)->vbox), box);
    gtk_widget_show(box);

    /* create the anonymous check button */
    button = gtk_check_button_new_with_label("Anonymous login");

    /* set signal for check button */
    g_signal_connect(G_OBJECT(button), "clicked", G_CALLBACK(check_anonymous_login), NULL);

    /* add the check button into the box and show it */
    gtk_box_pack_start_defaults(GTK_BOX(box), button);
    gtk_widget_show(button);
    
    /* ensure the dialog is destroyed when user responses */
    /*
    g_signal_connect_swapped(G_OBJECT(dialog), "response",
            G_CALLBACK(gtk_widget_destroy), G_OBJECT(dialog));
    */

    /* show the dialog */
    //gtk_widget_show(dialog);
    result = gtk_dialog_run(GTK_DIALOG(dialog));
    switch(result)
    {
        case GTK_RESPONSE_OK:
            if(gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(button)))
            {
                g_print("Anonymous login.\n");
            }
            else
            {
                g_print("attemp to login.user: %s, password: %s  \n", 
                        gtk_entry_get_text(GTK_ENTRY(user_entry)),
                        gtk_entry_get_text(GTK_ENTRY(passwd_entry)));
            }
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
    gtk_window_set_title(GTK_WINDOW(window), "dialog demo");

    /* set border width for main window */
    gtk_container_set_border_width(GTK_CONTAINER(window), 10);
    
    /* create the box */
    box = gtk_hbox_new(TRUE, 3);

    /* add the box into the main window */
    gtk_container_add(GTK_CONTAINER(window), box);

    /* show the box */
    gtk_widget_show(box);

    /* create login button */
    button = gtk_button_new_with_label("login");

    /* set the signal for login button */
    g_signal_connect(G_OBJECT(button), "clicked", G_CALLBACK(login_callback), window);

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

