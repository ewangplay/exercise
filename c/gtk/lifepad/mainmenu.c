#include <gtk/gtk.h>

#include "mainmenu.h"

/* menu item handler */
static void file_new_handler(gpointer data);
static void edit_undo_handler(gpointer data);
static void edit_redo_handler(gpointer data);
static void edit_selectall_handler(gpointer data);
static void search_find_handler(gpointer data);
static void search_replace_handler(gpointer data);
static void option_font_handler(gpointer data);
static void help_about_handler(GtkWidget *widget, gpointer data);

GtkWidget * create_main_menu(void)
{
    GtkWidget *menu_bar;
    GtkWidget *menu;
    GtkWidget *menu_item;

    /* create menu bar */
    menu_bar = gtk_menu_bar_new();

    /* create file menu */
    menu = gtk_menu_new();

    /* create file-new menu item */
    menu_item = gtk_menu_item_new_with_label("File");
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);
    g_signal_connect_swapped(G_OBJECT(menu_item), "activate",
            G_CALLBACK(file_new_handler), "file.new");
    gtk_widget_show(menu_item);

    /* create separator menu item */
    menu_item = gtk_separator_menu_item_new();
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);
    gtk_widget_show(menu_item);

    /* create file-close menu item */
    menu_item = gtk_menu_item_new_with_label("Close");
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);
    g_signal_connect_swapped(G_OBJECT(menu_item), "activate",
            G_CALLBACK(gtk_main_quit), "file.close");
    gtk_widget_show(menu_item);

    /* append the file menu on the menu bar */
    menu_item = gtk_menu_item_new_with_label("File");
    gtk_menu_item_set_submenu(GTK_MENU_ITEM(menu_item), menu);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu_bar), menu_item);
    gtk_widget_show(menu_item);
    
    /* create edit menu */
    menu = gtk_menu_new();

    /* create the edit-undo menu item */
    menu_item = gtk_menu_item_new_with_label("Undo");
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);
    g_signal_connect(G_OBJECT(menu_item), "activate",
            G_CALLBACK(edit_undo_handler), "edit.undo");
    gtk_widget_show(menu_item);

    /* create the edit-redo menu item */
    menu_item = gtk_menu_item_new_with_label("Redo");
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);
    g_signal_connect(G_OBJECT(menu_item), "activate",
            G_CALLBACK(edit_redo_handler), "edit.redo");
    gtk_widget_show(menu_item);

    /* create separator menu item */
    menu_item = gtk_separator_menu_item_new();
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);
    gtk_widget_show(menu_item);

    /* create edit-selectall menu item */
    menu_item = gtk_menu_item_new_with_label("Select all");
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);
    g_signal_connect(G_OBJECT(menu_item), "activate",
            G_CALLBACK(edit_selectall_handler), "edit.select_all");
    gtk_widget_show(menu_item);

   
    /* append the edit menu on the menu bar */
    menu_item = gtk_menu_item_new_with_label("Edit");
    gtk_menu_item_set_submenu(GTK_MENU_ITEM(menu_item), menu);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu_bar), menu_item);
    gtk_widget_show(menu_item);
 
    /* create search menu */
    menu = gtk_menu_new();

    /* create search-find menu item */
    menu_item = gtk_menu_item_new_with_label("Find...");
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);
    g_signal_connect(G_OBJECT(menu_item), "activate",
            G_CALLBACK(search_find_handler), "search.find");
    gtk_widget_show(menu_item);

    /* create search-replace menu item */
    menu_item = gtk_menu_item_new_with_label("Replace...");
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);
    g_signal_connect(G_OBJECT(menu_item), "activate",
            G_CALLBACK(search_replace_handler), "search.replace");
    gtk_widget_show(menu_item);

    /* append the search menu on the menu bar */
    menu_item = gtk_menu_item_new_with_label("Search");
    gtk_menu_item_set_submenu(GTK_MENU_ITEM(menu_item), menu);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu_bar), menu_item);
    gtk_widget_show(menu_item);
 
    /* create option menu */
    menu = gtk_menu_new();

    /* create option-font menu item */
    menu_item = gtk_menu_item_new_with_label("Font...");
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);
    g_signal_connect(G_OBJECT(menu_item), "activate",
            G_CALLBACK(option_font_handler), "option.font");
    gtk_widget_show(menu_item);

    /* append the option menu on the menu bar */
    menu_item = gtk_menu_item_new_with_label("Option");
    gtk_menu_item_set_submenu(GTK_MENU_ITEM(menu_item), menu);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu_bar), menu_item);
    gtk_widget_show(menu_item);
 
    /* create help menu */
    menu = gtk_menu_new();

    /* create help-about menu item */
    menu_item = gtk_menu_item_new_with_label("About");
    gtk_menu_shell_append(GTK_MENU_SHELL(menu), menu_item);
    g_signal_connect(G_OBJECT(menu_item), "activate",
            G_CALLBACK(help_about_handler), "help.about");
    gtk_widget_show(menu_item);

    /* append the help menu on the menu bar */
    menu_item = gtk_menu_item_new_with_label("Help");
    gtk_menu_item_set_submenu(GTK_MENU_ITEM(menu_item), menu);
    gtk_menu_shell_append(GTK_MENU_SHELL(menu_bar), menu_item);
    gtk_widget_show(menu_item);

    return menu_bar;
}

static void file_new_handler(gpointer data)
{
    g_print("%s", (gchar *)data);
}

static void edit_undo_handler(gpointer data)
{
}

static void edit_redo_handler(gpointer data)
{
}

static void edit_selectall_handler(gpointer data)
{
}

static void search_find_handler(gpointer data)
{
}

static void search_replace_handler(gpointer data)
{
}

static void option_font_handler(gpointer data)
{
}

static void help_about_handler(GtkWidget *widget, gpointer data)
{
    GtkWidget *about_dialog;
    GtkWidget *info;

    about_dialog = gtk_dialog_new_with_buttons("About lifepad",
            NULL,
            GTK_DIALOG_DESTROY_WITH_PARENT,
            GTK_STOCK_OK,
            GTK_RESPONSE_NONE,
            NULL);

    /* ensure the dialog is destroyed when user responses. */
    g_signal_connect_swapped(G_OBJECT(about_dialog), "response", 
            G_CALLBACK(gtk_widget_destroy), about_dialog);

    info = gtk_label_new("Lifepad 0.0.1\nCopyright @ 2009-2010 by ewangplay!");
    gtk_container_add(GTK_CONTAINER(GTK_DIALOG(about_dialog)->vbox), info);
    gtk_widget_show(info);

    gtk_widget_show(about_dialog);
}

