#include <gtk/gtk.h>

#include "indexview.h"
#include "dateindexview.h"
#include "categoryindexview.h"

GtkWidget * create_index_view()
{
    GtkWidget *tab_index;
    GtkWidget *date_index_view;
    GtkWidget *category_index_view;
    GtkWidget *label;

    tab_index = gtk_notebook_new();
    gtk_notebook_set_tab_pos(GTK_NOTEBOOK(tab_index), GTK_POS_TOP);

    label = gtk_label_new("按日期");
    date_index_view = create_date_index_view();
    gtk_notebook_append_page(GTK_NOTEBOOK(tab_index), date_index_view, label);
    gtk_widget_show(date_index_view);

    label = gtk_label_new("按类别");
    category_index_view = create_category_index_view();
    gtk_notebook_append_page(GTK_NOTEBOOK(tab_index), category_index_view, label);
    gtk_widget_show(category_index_view);

    gtk_notebook_set_current_page(GTK_NOTEBOOK(tab_index), 0);

    return tab_index;
}

