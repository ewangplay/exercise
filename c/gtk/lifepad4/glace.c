#include <gtk/gtk.h>
#include <glade/glade.h>

#define GLADE_FILE "win.glade"

static void on_notebook1_switch_page(GtkWidget * widget, gpointer data);
static void on_entry1_changed(GtkWidget * widget, gpointer data);

GtkWidget * create_window()
{
    GtkWidget *window;
    GladeXML *gxml;

    gxml = glade_xml_new(GLADE_FILE, NULL, NULL);
    glade_xml_signal_autoconnect(gxml);
    window = glade_xml_get_widget(gxml, "topWindow");
    g_object_unref(G_OBJECT(gxml));
    return window;
}

int main(int argc, char *argv[])
{
    GtkWidget *window;

    gtk_set_locale();
    gtk_init(&argc, &argv);

    window = create_window();

    gtk_widget_show(window);

    gtk_main();

    return 0;
}


static void on_notebook1_switch_page(GtkWidget * widget, gpointer data)
{
    g_print("notebook switch page\n");
}

static void on_entry1_changed(GtkWidget * widget, gpointer data)
{
    g_print("entry context changed\n");
}


