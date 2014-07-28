#include <gtk/gtk.h>

#include "mainmenu.h"
#include "toolbar.h"
#include "indexview.h"
#include "textview.h"

int main(int argc, char *argv[])
{
    GtkWidget *window;
    GtkWidget *vbox;
    GtkWidget *main_menu;
    GtkWidget *toolbar;
    GtkWidget *paned;
    GtkWidget *index_view;
    GtkWidget *text_view;

    /* initialize */
    gtk_init(&argc, &argv);

    /* create the main window */
    window = gtk_window_new(GTK_WINDOW_TOPLEVEL);
    g_signal_connect(G_OBJECT(window), "delete_event", G_CALLBACK(gtk_main_quit), NULL);
    gtk_window_set_title(GTK_WINDOW(window), "lifepad");
    gtk_widget_set_size_request(GTK_WIDGET(window), 800, 600);
    
    /* create the top vbox */
    vbox = gtk_vbox_new(FALSE, 0);
    gtk_container_add(GTK_CONTAINER(window), vbox);
    gtk_widget_show(vbox);

    /* create the main menu */
    main_menu = create_main_menu();
    gtk_box_pack_start(GTK_BOX(vbox), main_menu, FALSE, FALSE, 0);
    gtk_widget_show(main_menu);

    /* create the toolbar */
    toolbar = create_toolbar();
    gtk_box_pack_start(GTK_BOX(vbox), toolbar, FALSE, FALSE, 0);
    gtk_widget_show(toolbar);

    /* create the paned */
    paned = gtk_hpaned_new();
    gtk_box_pack_start(GTK_BOX(vbox), paned, TRUE, TRUE, 0);
    gtk_widget_show(paned);

    /* add child widget into the each side of paned */
    index_view = create_index_view();
    gtk_paned_add1(GTK_PANED(paned), index_view);
    gtk_widget_show(index_view);

    text_view = create_text_view();
    gtk_paned_add2(GTK_PANED(paned), text_view);
    gtk_widget_show(text_view);
  
    /* show the main window */
    gtk_widget_show(window);

    /* main loop */;
    gtk_main();

    return 0;
}

