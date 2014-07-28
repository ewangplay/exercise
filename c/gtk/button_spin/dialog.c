#include <gtk/gtk.h>

void check_snap_to_ticks(GtkWidget *widget, gpointer data)
{
    gtk_spin_button_set_snap_to_ticks(GTK_SPIN_BUTTON(data),
            gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(widget)));
}

void check_numeric_mode(GtkWidget *widget, gpointer data)
{
    gtk_spin_button_set_numeric(GTK_SPIN_BUTTON(data),
            gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(widget)));
}

void change_digits(GtkWidget *widget, gpointer data)
{
    gtk_spin_button_set_digits(GTK_SPIN_BUTTON(data),
            gtk_spin_button_get_value_as_int(GTK_SPIN_BUTTON(widget)));
}

void get_value(GtkWidget *widget, gpointer data)
{
    gchar buf[32];
    GtkLabel *label;
    GtkSpinButton *spin;

    label = GTK_LABEL(g_object_get_data(G_OBJECT(widget), "result_label"));
    spin = GTK_SPIN_BUTTON(g_object_get_data(G_OBJECT(widget), "spinner_button"));

    if(GPOINTER_TO_INT(data) == 1)
    {
        g_snprintf(buf, 32, "%d", gtk_spin_button_get_value_as_int(spin));
    }
    else
    {
        g_snprintf(buf, 32, "%0.*f", spin->digits, gtk_spin_button_get_value(spin));
    }
    gtk_label_set_text(label, buf);
}

void spin_callback(GtkWidget *widget, gpointer data)
{ 
    GtkWidget *dialog;
    GtkWidget *hbox;
    GtkWidget *vbox1;
    GtkWidget *vbox2;
    GtkWidget *frame;
    GtkWidget *label;
    GtkWidget *button;
    GtkWidget *val_label;
    GtkWidget *spinner;
    GtkWidget *spinner1;
    GtkWidget *spinner2;
    GtkAdjustment *adj;
    gint result;

    /* create the popup dialog */
    dialog = gtk_dialog_new_with_buttons("spinner", GTK_WINDOW(data),
            GTK_DIALOG_MODAL | GTK_DIALOG_NO_SEPARATOR,
            GTK_STOCK_OK,
            GTK_RESPONSE_OK,
            GTK_STOCK_CANCEL,
            GTK_RESPONSE_CANCEL,
            NULL);

    /* set the default button for dialog */
    gtk_dialog_set_default_response(GTK_DIALOG(dialog), GTK_RESPONSE_OK);

    /* create the top frame */
    frame = gtk_frame_new("Not accelerated");

    /* add the frame into the dialog vbox */
    gtk_container_add(GTK_CONTAINER(GTK_DIALOG(dialog)->vbox), frame);

    /* show the frame */
    gtk_widget_show(frame);

    /* create the hbox */
    hbox = gtk_hbox_new(FALSE, 0);

    /* add the hbox into the frame */
    gtk_container_add(GTK_CONTAINER(frame), hbox);

    /* show the hbox */
    gtk_widget_show(hbox);

    /* create the vbox1 */
    vbox1 = gtk_vbox_new(FALSE, 0);

    /* add the vbox1 into the hbox */
    gtk_box_pack_start(GTK_BOX(hbox), vbox1, TRUE, TRUE, 5);

    /* show the vbox1 */
    gtk_widget_show(vbox1);

    /* create the day label */
    label = gtk_label_new("Day:");

    /* set alignment for label */
    gtk_misc_set_alignment(GTK_MISC(label), 0, 0.5);

    /* add the label into the vbox1 */
    gtk_box_pack_start(GTK_BOX(vbox1), label, FALSE, TRUE, 0);

    /* show the label */
    gtk_widget_show(label);

    /* create the adjustment for spinner */
    adj = GTK_ADJUSTMENT(gtk_adjustment_new(1.0, 1.0, 31.0, 1.0, 5.0, 0.0));

    /* create the day spinner */
    spinner = gtk_spin_button_new(adj, 0, 0);

    /* add the day spinner into the vbox1 */
    gtk_box_pack_start(GTK_BOX(vbox1), spinner, FALSE, TRUE, 0);

    /* show the day spinner */
    gtk_widget_show(spinner);

    /* create the vbox1 */
    vbox1 = gtk_vbox_new(FALSE, 0);

    /* add the vbox1 into the hbox */
    gtk_box_pack_start(GTK_BOX(hbox), vbox1, TRUE, TRUE, 5);

    /* show the vbox1 */
    gtk_widget_show(vbox1);

    /* create the day label */
    label = gtk_label_new("Month:");

    /* set alignment for label */
    gtk_misc_set_alignment(GTK_MISC(label), 0, 0.5);

    /* add the label into the vbox1 */
    gtk_box_pack_start(GTK_BOX(vbox1), label, FALSE, TRUE, 0);

    /* show the label */
    gtk_widget_show(label);

    /* create the adjustment for spinner */
    adj = GTK_ADJUSTMENT(gtk_adjustment_new(1.0, 1.0, 12.0, 1.0, 3.0, 0.0));

    /* create the month spinner */
    spinner = gtk_spin_button_new(adj, 0, 0);

    /* add the month spinner into the vbox1 */
    gtk_box_pack_start(GTK_BOX(vbox1), spinner, FALSE, TRUE, 0);

    /* show the month spinner */
    gtk_widget_show(spinner);

    /* create the vbox1 */
    vbox1 = gtk_vbox_new(FALSE, 0);

    /* add the vbox1 into the hbox */
    gtk_box_pack_start(GTK_BOX(hbox), vbox1, TRUE, TRUE, 5);

    /* show the vbox1 */
    gtk_widget_show(vbox1);

    /* create the day label */
    label = gtk_label_new("Year:");

    /* set alignment for label */
    gtk_misc_set_alignment(GTK_MISC(label), 0, 0.5);

    /* add the label into the vbox1 */
    gtk_box_pack_start(GTK_BOX(vbox1), label, FALSE, TRUE, 0);

    /* show the label */
    gtk_widget_show(label);

    /* create the adjustment for spinner */
    adj = GTK_ADJUSTMENT(gtk_adjustment_new(1900.0, 1900.0, 2100.0, 1.0, 10.0, 0.0));

    /* create the year spinner */
    spinner = gtk_spin_button_new(adj, 0, 0);

    /* add the year spinner into the vbox1 */
    gtk_box_pack_start(GTK_BOX(vbox1), spinner, FALSE, TRUE, 0);

    /* show the year spinner */
    gtk_widget_show(spinner);

    /* create the frame for accelerated */
    frame = gtk_frame_new("Accelerated");

    /* add the frame into the dialog vbox */
    gtk_container_add(GTK_CONTAINER(GTK_DIALOG(dialog)->vbox), frame);

    /* show the frame */
    gtk_widget_show(frame);

    /* create the vbox1 */
    vbox1 = gtk_vbox_new(FALSE, 0);

    /* add the vbox1 into the frame */
    gtk_container_add(GTK_CONTAINER(frame), vbox1);

    /* show the vbox1 */
    gtk_widget_show(vbox1);

    /* create the hbox */
    hbox = gtk_hbox_new(FALSE, 0);

    /* add the hbox into the vbox1 */
    gtk_box_pack_start(GTK_BOX(vbox1), hbox, FALSE, TRUE, 0);

    /* show the hbox */
    gtk_widget_show(hbox);

    /* create the vbox2 */
    vbox2 = gtk_vbox_new(FALSE, 0);
    
    /* add the vbox2 into the hbox */
    gtk_box_pack_start(GTK_BOX(hbox), vbox2, FALSE, TRUE, 0);

    /* show the vbox2 */
    gtk_widget_show(vbox2);

    /* create the value label */
    label = gtk_label_new("Value:");

    /* set alignment for label */
    gtk_misc_set_alignment(GTK_MISC(label), 0, 0.5);

    /* add the label into the vbox2 */
    gtk_box_pack_start(GTK_BOX(vbox2), label, FALSE, TRUE, 0);

    /* show the label */
    gtk_widget_show(label);

    /* create the adjustment for spinner1 */
    adj = GTK_ADJUSTMENT(gtk_adjustment_new(0.0, -10000.0, 10000.0, 0.5, 100.0, 0));

    /* create the value spinner1 */
    spinner1 = gtk_spin_button_new(adj, 1.0, 2);

    /* set wrap for value spinner1 */
    gtk_spin_button_set_wrap(GTK_SPIN_BUTTON(spinner1), TRUE);

    /* set the size of the value spinner1 */
    gtk_widget_set_size_request(spinner1, 100, -1);

    /* add the value spinner1 into the vbox2 */
    gtk_box_pack_start(GTK_BOX(vbox2), spinner1, FALSE, TRUE, 0);

    /* show the spinner1 */
    gtk_widget_show(spinner1);

    /* create the vbox2 */
    vbox2 = gtk_vbox_new(FALSE, 0);
    
    /* add the vbox2 into the hbox */
    gtk_box_pack_start(GTK_BOX(hbox), vbox2, FALSE, TRUE, 0);

    /* show the vbox2 */
    gtk_widget_show(vbox2);

    /* create the value label */
    label = gtk_label_new("Digits:");

    /* set alignment for label */
    gtk_misc_set_alignment(GTK_MISC(label), 0, 0.5);

    /* add the label into the vbox2 */
    gtk_box_pack_start(GTK_BOX(vbox2), label, FALSE, TRUE, 0);

    /* show the label */
    gtk_widget_show(label);

    /* create the adjustment for spinner2 */
    adj = GTK_ADJUSTMENT(gtk_adjustment_new(2, 1, 5, 1, 1, 0));

    /* create the value spinner2 */
    spinner2 = gtk_spin_button_new(adj, 0.0, 0);

    /* set wrap for value spinner2 */
    gtk_spin_button_set_wrap(GTK_SPIN_BUTTON(spinner2), TRUE);

    /* set signal for spinner2 */
    g_signal_connect(G_OBJECT(spinner2), "value_changed", G_CALLBACK(change_digits), spinner1);

    /* add the value spinner2 into the vbox2 */
    gtk_box_pack_start(GTK_BOX(vbox2), spinner2, FALSE, TRUE, 0);

    /* show the spinner2 */
    gtk_widget_show(spinner2);

    /* create the vbox2 */
    vbox2 = gtk_vbox_new(FALSE, 0);

    /* add the vbox2 into the vbox1 */
    gtk_box_pack_start_defaults(GTK_BOX(vbox1), vbox2);

    /* show the vbox2 */
    gtk_widget_show(vbox2);

    /* create the first check button */
    button = gtk_check_button_new_with_label("Snap to 0.5-ticks");

    /* set signal for check button */
    g_signal_connect(G_OBJECT(button), "toggled", G_CALLBACK(check_snap_to_ticks), spinner1);

    /* add the check button into the vbox2 */
    gtk_box_pack_start(GTK_BOX(vbox2), button, FALSE, TRUE, 0);

    /* show the check button */
    gtk_widget_show(button);

    /* create the second check button */
    button = gtk_check_button_new_with_label("Numeric only input mode");

    /* set signal for check button */
    g_signal_connect(G_OBJECT(button), "toggled", G_CALLBACK(check_numeric_mode), spinner1);

    /* add the check button into the vbox2 */
    gtk_box_pack_start(GTK_BOX(vbox2), button, FALSE, TRUE, 0);

    /* show the check button */
    gtk_widget_show(button);

    /* create the result label */
    label = gtk_label_new("");

    /* create the hbox */
    hbox = gtk_hbox_new(FALSE, 0);

    /* add the hbox into vbox1 */
    gtk_box_pack_start_defaults(GTK_BOX(vbox1), hbox);

    /* show the hbox */
    gtk_widget_show(hbox);

    /* create the first normal button */
    button = gtk_button_new_with_label("Value as int");

    /* attach data to button */
    g_object_set_data(G_OBJECT(button), "result_label", label);
    g_object_set_data(G_OBJECT(button), "spinner_button", spinner1);

    /* set signal for button */
    g_signal_connect(G_OBJECT(button), "clicked", G_CALLBACK(get_value), GINT_TO_POINTER(1));

    /* add the button into the hbox */
    gtk_box_pack_start(GTK_BOX(hbox), button, TRUE, TRUE, 3);

    /* show the button */
    gtk_widget_show(button);

    /* create the second nomral button */
    button = gtk_button_new_with_label("Value as float");

    /* attach data to button */
    g_object_set_data(G_OBJECT(button), "result_label", label);
    g_object_set_data(G_OBJECT(button), "spinner_button", spinner1);

    /* set signal for button */
    g_signal_connect(G_OBJECT(button), "clicked", G_CALLBACK(get_value), GINT_TO_POINTER(2));

    /* add the button into the hbox */
    gtk_box_pack_start(GTK_BOX(hbox), button, TRUE, TRUE, 3);

    /* show the button */
    gtk_widget_show(button);

    /* set the default result */
    gtk_label_set_text(GTK_LABEL(label), "0");

    /* add the label into the vbox1 */
    gtk_box_pack_start(GTK_BOX(vbox1), label, TRUE, TRUE, 3);

    /* show the label */
    gtk_widget_show(label);

    /* show the dialog */
    result = gtk_dialog_run(GTK_DIALOG(dialog));
    switch(result)
    {
        case GTK_RESPONSE_OK:
            g_print("the result is %d\n",
                    gtk_spin_button_get_value_as_int(GTK_SPIN_BUTTON(spinner1)));
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
    gtk_window_set_title(GTK_WINDOW(window), "spin button demo");

    /* set border width for main window */
    gtk_container_set_border_width(GTK_CONTAINER(window), 10);
    
    /* create the box */
    box = gtk_hbox_new(TRUE, 3);

    /* add the box into the main window */
    gtk_container_add(GTK_CONTAINER(window), box);

    /* show the box */
    gtk_widget_show(box);

    /* create login button */
    button = gtk_button_new_with_label("spin buttton");

    /* set the signal for login button */
    g_signal_connect(G_OBJECT(button), "clicked", G_CALLBACK(spin_callback), window);

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

