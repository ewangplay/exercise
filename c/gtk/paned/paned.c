#include <gtk/gtk.h>

/* Callback function */
gint close_event(GtkWidget * widget, GdkEvent * event, gpointer data)
{
    gtk_main_quit();
    return FALSE;
}

void icon_radio_event(GtkWidget *widget, gpointer data)
{
    if(GTK_TOGGLE_BUTTON(widget)->active)
    {
        gtk_toolbar_set_style(GTK_TOOLBAR(data), GTK_TOOLBAR_ICONS);
    }
}

void text_radio_event(GtkWidget *widget, gpointer data)
{
    if(GTK_TOGGLE_BUTTON(widget)->active)
    {
        gtk_toolbar_set_style(GTK_TOOLBAR(data), GTK_TOOLBAR_TEXT);
    }
}

void both_radio_event(GtkWidget *widget, gpointer data)
{
    if(GTK_TOGGLE_BUTTON(widget)->active)
    {
        gtk_toolbar_set_style(GTK_TOOLBAR(data), GTK_TOOLBAR_BOTH);
    }
}

void toggle_event(GtkWidget * widget, gpointer data)
{
    gtk_toolbar_set_tooltips(GTK_TOOLBAR(data), GTK_TOGGLE_BUTTON(widget)->active);
}


GtkWidget * create_toolbar(void)
{
    GtkWidget *handlebox;
    GtkWidget *toolbar;
    GtkWidget *icon;
    GtkWidget *close_button;
    GtkWidget *icon_radio_button;
    GtkWidget *text_radio_button;
    GtkWidget *both_radio_button;
    GtkWidget *tooltips_toggle_button;
    GtkWidget *entry;

    /* create handle box */
    handlebox = gtk_handle_box_new();

    /* create toolbar widget */
    toolbar = gtk_toolbar_new();
    gtk_toolbar_set_orientation(GTK_TOOLBAR(toolbar), GTK_ORIENTATION_HORIZONTAL);
    gtk_toolbar_set_style(GTK_TOOLBAR(toolbar), GTK_TOOLBAR_BOTH);
    gtk_toolbar_set_tooltips(GTK_TOOLBAR(toolbar), TRUE);
    gtk_container_set_border_width(GTK_CONTAINER(toolbar), 5);
    gtk_container_add(GTK_CONTAINER(handlebox), toolbar);

    /* add close button on the toolbar */
    icon = gtk_image_new_from_file("06.png");
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

    /* add radio button group */
    icon = gtk_image_new_from_file("icon.xpm");
    icon_radio_button = gtk_toolbar_append_element(
            GTK_TOOLBAR(toolbar),
            GTK_TOOLBAR_CHILD_RADIOBUTTON,
            NULL,
            "icon",
            "only icon on toolbar",
            "private",
            icon,
            GTK_SIGNAL_FUNC(icon_radio_event),
            toolbar
            );
    //gtk_toolbar_append_space(GTK_TOOLBAR(toolbar));

    icon = gtk_image_new_from_file("text.xpm");
    text_radio_button = gtk_toolbar_append_element(
            GTK_TOOLBAR(toolbar),
            GTK_TOOLBAR_CHILD_RADIOBUTTON,
            icon_radio_button,
            "text",
            "text only on toolbar",
            "private",
            icon,
            GTK_SIGNAL_FUNC(text_radio_event),
            toolbar
            );
    //gtk_toolbar_append_space(GTK_TOOLBAR(toolbar));

    icon = gtk_image_new_from_file("both.xpm");
    both_radio_button = gtk_toolbar_append_element(
            GTK_TOOLBAR(toolbar),
            GTK_TOOLBAR_CHILD_RADIOBUTTON,
            text_radio_button,
            "both",
            "both icon and text display on the toolbar",
            "private",
            icon,
            GTK_SIGNAL_FUNC(both_radio_event),
            toolbar
            );
    gtk_toolbar_append_space(GTK_TOOLBAR(toolbar));

    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(both_radio_button), TRUE);

    /* add tooltips toggle button on toolbar */
    icon = gtk_image_new_from_file("tooltips.xpm");
    tooltips_toggle_button = gtk_toolbar_append_element(
            GTK_TOOLBAR(toolbar),
            GTK_TOOLBAR_CHILD_TOGGLEBUTTON,
            NULL,
            "Tooltips",
            "Toolbar with or without tips",
            "Private",
            icon,
            GTK_SIGNAL_FUNC(toggle_event),
            toolbar
            );
    gtk_toolbar_append_space(GTK_TOOLBAR(toolbar));
    gtk_toggle_button_set_active(GTK_TOGGLE_BUTTON(tooltips_toggle_button), TRUE);

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

GtkWidget * create_list(void)
{
    GtkWidget *scroll_window;
    GtkWidget *tree_view;
    GtkListStore *model;
    GtkTreeIter iter;
    GtkTreeViewColumn * column;
    GtkCellRenderer * cell;
    int i;

    /* create the scroll window */
    scroll_window = gtk_scrolled_window_new(NULL, NULL);
    gtk_scrolled_window_set_policy(GTK_SCROLLED_WINDOW(scroll_window), 
            GTK_POLICY_AUTOMATIC, GTK_POLICY_AUTOMATIC);

    gtk_widget_set_size_request(scroll_window, 100, -1);

    /* append some messages to the list store */
    model = gtk_list_store_new(1, G_TYPE_STRING);
    for(i = 0; i < 10; i++)
    {
        gchar *msg = g_strdup_printf("message %d", i);
        gtk_list_store_append(model, &iter);
        gtk_list_store_set(model, &iter, 0, msg, -1);
        g_free(msg);
    }

    /* create the tree view */
    tree_view = gtk_tree_view_new();
    gtk_tree_view_set_model(GTK_TREE_VIEW(tree_view), GTK_TREE_MODEL(model));
    gtk_scrolled_window_add_with_viewport(GTK_SCROLLED_WINDOW(scroll_window), tree_view);
    gtk_widget_show(tree_view);

    /* append column to the tree view */
    cell = gtk_cell_renderer_text_new();
    column = gtk_tree_view_column_new_with_attributes("Message", cell, "text", 0, NULL);
    gtk_tree_view_append_column(GTK_TREE_VIEW(tree_view), column);

    return scroll_window; 
} 

void insert_text(GtkTextBuffer * buffer)
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

GtkWidget * create_text(void)
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
    buffer = gtk_text_view_get_buffer(GTK_TEXT_VIEW(text_view));

    /* add the text view into the scroll window */
    gtk_container_add(GTK_CONTAINER(scroll_window), text_view);

    insert_text(buffer);

    gtk_widget_show(text_view);

    return scroll_window;
}

int main(int argc, char *argv[])
{
    GtkWidget *window;
    GtkWidget *vbox;
    GtkWidget *toolbar;
    GtkWidget *paned;
    GtkWidget *list;
    GtkWidget *text;

    /* initialize */
    gtk_init(&argc, &argv);

    /* create the main window */
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);

    /* set signal for main window */
    g_signal_connect(G_OBJECT(window), "delete_event", G_CALLBACK(gtk_main_quit), NULL);

    /* set the title for main window */
    gtk_window_set_title(GTK_WINDOW(window), "paned");

    /* set border width for main window */
    gtk_container_set_border_width(GTK_CONTAINER(window), 10);
    gtk_widget_set_size_request(GTK_WIDGET(window), 800, 600);
    
    /* create the top vbox */
    vbox = gtk_vbox_new(FALSE, 5);
    gtk_container_add(GTK_CONTAINER(window), vbox);
    gtk_widget_show(vbox);

    /* create the toolbar */
    toolbar = create_toolbar();
    gtk_box_pack_start(GTK_BOX(vbox), toolbar, FALSE, FALSE, 5);
    gtk_widget_show(toolbar);

    /* create the paned */
    paned = gtk_hpaned_new();
    gtk_box_pack_start(GTK_BOX(vbox), paned, TRUE, TRUE, 5);
    gtk_widget_show(paned);

    /* add child widget into the each side of paned */
    list = create_list();
    gtk_paned_add1(GTK_PANED(paned), list);
    gtk_widget_show(list);

    text = create_text();
    gtk_paned_add2(GTK_PANED(paned), text);
    gtk_widget_show(text);
  
    /* show the main window */
    gtk_widget_show(window);

    /* main loop */;
    gtk_main();

    return 0;
}

