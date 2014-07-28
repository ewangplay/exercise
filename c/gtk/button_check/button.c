#include <gtk/gtk.h>

void check_callback ( GtkWidget *widget, gpointer data )
{
    if(gtk_toggle_button_get_active(GTK_TOGGLE_BUTTON(widget)))
    {
        g_print ("%s has been selected.\n", (gchar *)data);
    }
    else
    {
        g_print ("%s has been unselected.\n", (gchar *)data);
    }
}

void ok_callback(GtkWidget *widget, gpointer data)
{
    g_print("apply to change.\n");
}

gint delete_event( GtkWidget *widget, GdkEvent *event, gpointer data )
{
	/* 如果在" d e l e t e _ e v e n t "处理程序中返回F A L S E，GTK 将引发一个"destroy"
	*  信号，返回T R U E意味着你不想关闭窗口。
	*  这些在弹出"你真的要退出? "对话框时很有作用 */
	g_print ("delete event occurred\n");
	/* 将T R U E改为F A L S E，主窗口就会用一个" d e l e t e _ e v e n t "信号，然后退出 */
	//return TRUE;
    return FALSE;
}

/* 另一个回调函数 */
void destroy( GtkWidget *widget, gpointer data )
{
	gtk_main_quit();
}

int main( int argc, char *argv[] )
{
	GtkWidget *window;
	GtkWidget *button;
    GtkWidget *box;
    GtkWidget *table;
    GtkWidget *box1;
	
	/* 在所有的G t k应用程序中都应该调用。它的作用是解析由命令行传递
	* 进来的参数并将它返回给应用程序
	*/
	gtk_init(&argc, &argv);
	
	/* 创建一个主窗口*/
	window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

	/* 当给窗口一个" d e l e t e _ e v e n t "信号时(这个信号是由窗口管
	* 理器发出的，通常是在点击窗口标题条右边的"×"按钮，或
	* 者在标题条的快捷菜单上选择" c l o s e "选项时发出的)，我们
	* 要求调用上面定义的d e l e t e _ e v e n t ( )函数传递给这个回调函数
	* 的数据是N U L L，回调函数会忽略这个参数*/
	g_signal_connect (G_OBJECT (window), "delete_event", G_CALLBACK (delete_event), NULL);

	/* 这里，我们给" d e s t o r y "事件连接一个信号处理函数，
	* 当我们在窗口上调用g t k _ w i d g e t _ d e s t r o y ( )函数
	* 或者在" d e l e t e _ e v e n t "事件的回调函数中返回F A L S E
	* 时会发生这个事件*/
	g_signal_connect (G_OBJECT (window), "destroy", G_CALLBACK (destroy), NULL);

	/* 设置窗口的边框宽度*/
	gtk_container_set_border_width (GTK_CONTAINER (window), 10);

    /* create the top box */
    box = gtk_vbox_new(FALSE, 0);
    gtk_container_set_border_width(GTK_CONTAINER(box), 3);

    /* create the table */
    table = gtk_table_new(2, 1, FALSE);

    /* create the first check button */
    button = gtk_check_button_new_with_label("Check button 1");
    g_signal_connect(G_OBJECT(button), "toggled", G_CALLBACK(check_callback), "check button 1");

    /* pack the check button into the table */
    gtk_table_attach_defaults(GTK_TABLE(table), button, 0, 1, 0, 1);

    /* show the check button */
    gtk_widget_show(button);

    /* create the second check button */
    button = gtk_check_button_new_with_label("Check button 2");
    g_signal_connect(G_OBJECT(button), "toggled", G_CALLBACK(check_callback), "check button 2");

    /* pack the check button into the table */
    gtk_table_attach_defaults(GTK_TABLE(table), button, 0, 1, 1, 2);

    /* show the check button */
    gtk_widget_show(button);

    /* pack the table into the top box */
    gtk_box_pack_start_defaults(GTK_BOX(box), table);

    /* show the table */
    gtk_widget_show(table);

    /* create the child box */
    box1 = gtk_hbox_new(TRUE, 10);

    /* create the ok button */
    button = gtk_button_new_with_label("Ok");
    g_signal_connect(G_OBJECT(button), "clicked", G_CALLBACK(ok_callback), NULL);

    /* pack the ok button into the child box */
    gtk_box_pack_start(GTK_BOX(box1), button, TRUE, TRUE, 3);

    /* show the ok button */
    gtk_widget_show(button);

    /* create the cancel button */
    button = gtk_button_new_with_label("Cancel");
    g_signal_connect_swapped(G_OBJECT(button), "clicked", G_CALLBACK(gtk_widget_destroy), G_OBJECT(window));

    /* pack the cancel button into the child box */
    gtk_box_pack_start(GTK_BOX(box1), button, TRUE, TRUE, 3);

    /* show the cancel button */
    gtk_widget_show(button);

    /* pack the child box into the top box */
    gtk_box_pack_start_defaults(GTK_BOX(box), box1);

    /* show the child box */
    gtk_widget_show(box1);

    /* pack the top box into the main window */
    gtk_container_add(GTK_CONTAINER(window), box);

	/* show the top box */
	gtk_widget_show (box);

	/* show the main window */
	gtk_widget_show (window);

	gtk_main ();
    
    return 0;
}
