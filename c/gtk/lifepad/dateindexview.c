#include <gtk/gtk.h>

#include "dateindexview.h"

GtkWidget * create_date_index_view(void)
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

    gtk_widget_set_size_request(scroll_window, 150, -1);

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
    column = gtk_tree_view_column_new_with_attributes("日期", cell, "text", 0, NULL);
    gtk_tree_view_append_column(GTK_TREE_VIEW(tree_view), column);

    return scroll_window; 
} 


