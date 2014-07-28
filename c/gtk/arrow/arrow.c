#include <gtk/gtk.h>

GtkTooltips *tooltips;

GtkWidget *create_arrow_button(GtkArrowType arrow_type, GtkShadowType shadow_type)
{
    GtkWidget *button;
    GtkWidget *arrow;

    /* create the tooltips */
    tooltips = gtk_tooltips_new();

    /* create the button */
    button = gtk_button_new();

    /* attach the tooltips to button */
    switch(arrow_type)
    {
        case GTK_ARROW_UP:
            gtk_tooltips_set_tip(tooltips, button, "up arrow button", NULL);
            break;
        case GTK_ARROW_DOWN:
            gtk_tooltips_set_tip(tooltips, button, "down arrow button", NULL);
            break;
        case GTK_ARROW_LEFT:
            gtk_tooltips_set_tip(tooltips, button, "left arrow button", NULL);
            break;
        case GTK_ARROW_RIGHT:
            gtk_tooltips_set_tip(tooltips, button, "right arrow button", NULL);
            break;
        default:
            break;
    }

    /* create the arrow */
    arrow = gtk_arrow_new(arrow_type, shadow_type);

    /* pack the arrow into the button */
    gtk_container_add(GTK_CONTAINER(button), arrow);

    /* show the arrow and button */
    gtk_widget_show(arrow);
    gtk_widget_show(button);

    return button;
}

void check_callback(GtkWidget *widget, gpointer data)
{
    if(gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(widget)))
    {
        g_print("tooltips enabled!\n");

        gtk_tooltips_enable(tooltips);
    }
    else
    {
        g_print("tooltips disabled!\n");

        gtk_tooltips_disable(tooltips);
    }
}

void destroy(GtkWidget *widget, gpointer data)
{
    gtk_main_quit();
}

int main(int argc, char *argv[])
{
    GtkWidget *window;
    GtkWidget *topbox;
    GtkWidget *box;
    GtkWidget *button;
    GtkWidget *frame;

    /* initialize */
    gtk_init(&argc, &argv);

    /* create the main window */
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);

    /* set signal for main window */
    g_signal_connect(G_OBJECT(window), "delete_event", G_CALLBACK(gtk_main_quit), NULL);

    /* set the title for main window */
    gtk_window_set_title(GTK_WINDOW(window), "arrow button");

    /* set border width for main window */
    gtk_container_set_border_width(GTK_CONTAINER(window), 10);
    
    /* create the top box */
    topbox = gtk_vbox_new(FALSE, 0);

    /* pack the box into the main window */
    gtk_container_add(GTK_CONTAINER(window), topbox);

    /* show the box */
    gtk_widget_show(topbox);

    /* create the first hbox */
    box = gtk_hbox_new(TRUE, 3);

    /* pack the hbox into the top box */
    gtk_box_pack_start_defaults(GTK_BOX(topbox), box);

    /* show the hbox */
    gtk_widget_show(box);

    /* create the first arrow button */
    button = create_arrow_button(GTK_ARROW_UP, GTK_SHADOW_IN);

    /* pack the button into box */
    gtk_box_pack_start_defaults(GTK_BOX(box), button);

    /* create the second arrow button */
    button = create_arrow_button(GTK_ARROW_LEFT, GTK_SHADOW_OUT);

    /* pack the button into box */
    gtk_box_pack_start_defaults(GTK_BOX(box), button);

    /* create the third arrow button */
    button = create_arrow_button(GTK_ARROW_DOWN, GTK_SHADOW_ETCHED_IN);

    /* pack the button into box */
    gtk_box_pack_start_defaults(GTK_BOX(box), button);

    /* create the forth arrow button */
    button = create_arrow_button(GTK_ARROW_RIGHT, GTK_SHADOW_ETCHED_OUT);

    /* pack the button into box */
    gtk_box_pack_start_defaults(GTK_BOX(box), button);

    /* create the second hbox */
    box = gtk_hbox_new(FALSE, 3);

    /* pack the hbox into the top box */
    gtk_box_pack_start_defaults(GTK_BOX(topbox), box);

    /* show the hbox */
    gtk_widget_show(box);

    /* create the frame */
    frame = gtk_frame_new("Options");

    /* pack the frame into the hbox */
    gtk_box_pack_start_defaults(GTK_BOX(box), frame);

    /* show the frame */
    gtk_widget_show(frame);

    /* create the check button */
    button = gtk_check_button_new_with_label("Enable tooltips");

    /* set signal for check button */
    g_signal_connect(G_OBJECT(button), "toggled", G_CALLBACK(check_callback), NULL);

    /* set the default status */
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(button), TRUE);

    /* pack the check button into the frame */
    gtk_container_add(GTK_CONTAINER(frame), button);

    /* show the check button */
    gtk_widget_show(button);

    /* create the third hbox */
    box = gtk_hbox_new(FALSE, 3);

    /* pack the hbox into the top box */
    gtk_box_pack_start_defaults(GTK_BOX(topbox), box);

    /* show the hbox */
    gtk_widget_show(box);

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

