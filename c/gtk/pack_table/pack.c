#include "gtk/gtk.h"

/* 当点击窗口的关闭按钮时会产生"delete _event"
 * 事件，这里设置对应的回调函数 */
gint delete_event( GtkWidget *widget,
                   GdkEvent  *event,
                   gpointer   data )
{
    gtk_main_quit ();
    return FALSE;
}

int main(int argc, char *argv[]) 
{
    GtkWidget *window;
    GtkWidget *table;
    GtkWidget *button1;
    GtkWidget *button2;
    GtkWidget *quit;
  
    /* 初始化  */
    gtk_init (&argc, &argv);
   
    /* 创建窗口 */
    window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

    /* 你应该总是记住连接 delete_event 信号到主窗口。这对
     * 适当的直觉行为很重要 */
    g_signal_connect (G_OBJECT (window), "delete_event",
		      G_CALLBACK (delete_event), NULL);
    gtk_container_set_border_width (GTK_CONTAINER (window), 10);
    
    /* Create the table */
    table = gtk_table_new(2, 2, FALSE);

    /* add the table on the main window */
    gtk_container_add(GTK_CONTAINER(window), table);

    /* Create the left-top button */
    button1 = gtk_button_new_with_label("button 1");

    /* Pack the button1 into table */
    gtk_table_attach_defaults(GTK_TABLE(table), button1, 0, 1, 0, 1);

    /* show the button1 */
    gtk_widget_show(button1);

    /* Create the right-top button */
    button2 = gtk_button_new_with_label("button 2");

    /* Pack the button2 into table */
    gtk_table_attach_defaults(GTK_TABLE(table), button2, 1, 2, 0, 1);

    /* show the button2 */
    gtk_widget_show(button2);

    /* create the quit button */
    quit = gtk_button_new_with_label("quit");
    g_signal_connect_swapped(G_OBJECT(quit), "clicked", G_CALLBACK(gtk_main_quit), G_OBJECT(window));

    /* pack the quit button into table */
    gtk_table_attach_defaults(GTK_TABLE(table), quit, 0, 2, 1, 2);
    
    /* show the quit button */
    gtk_widget_show(quit);
    
    /* show the table */
    gtk_widget_show(table);

    /* 最后显示窗口，这样所有东西一次性出现。 */
    gtk_widget_show (window);
    
    /* 当然，还有我们的主函数。 */
    gtk_main ();

    /* 当 gtk_main_quit() 被调用时控制权(Control)返回到
     * 这里，但当exit()被使用时并不会。 */
    
    return 0;
}
