#include <gtk/gtk.h>

void hello( GtkWidget *widget, gpointer data )
{
	g_print ("Hello again - %s was pressed.\n", (gchar *)data);
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

void destroy( GtkWidget *widget, gpointer data )
{
	gtk_main_quit();
}

int main( int argc, char *argv[] )
{
	GtkWidget *window;
	GtkWidget *button1;
    GtkWidget *button2;
    GtkWidget *quit;
    GtkWidget *box;
	
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

    /* 创建一个横向的Box */
    box = gtk_hbox_new(FALSE, 0);

    /* 把Box添加到主窗口中 */
    gtk_container_add(GTK_CONTAINER(window), box);

	/* 创建一个标题为"Hello one" 的按钮*/
	button1 = gtk_button_new_with_label ("Hello one");

	/* 当按钮接收到" c l i c k e d "时，它会调用h e l l o ( )函数，
	* 传递的参数为N U L L。函数h e l l o ( )是在上面定义的*/
	g_signal_connect (G_OBJECT (button1), "clicked", G_CALLBACK (hello), "button one");

    /* 我们把第一个按钮放入Box中 */
    gtk_box_pack_start(GTK_BOX(box), button1, TRUE, TRUE, 0);

    /* 同上创建第二个按钮 */
    button2 = gtk_button_new_with_label("Hello two");

    g_signal_connect (G_OBJECT (button2), "clicked", G_CALLBACK (hello), "button two");

    /* 把第二个按钮添加到Box中 */
    gtk_box_pack_start(GTK_BOX(box), button2, TRUE, TRUE, 0);

    /* Create the quit button. */
    quit = gtk_button_new_with_label("Quit");

    g_signal_connect_swapped(G_OBJECT(quit), "clicked", G_CALLBACK(gtk_main_quit), G_OBJECT(window));

    gtk_box_pack_start(GTK_BOX(box), quit, TRUE, TRUE, 0);

	/* 显示窗口*/
    gtk_widget_show_all(window);

	/* 所有的G T K应用程序都应该有一个g t k _ m a i n ( )函数。
	* 程序的控制权停在这里并等着事件的发生（比如一次按键或鼠标事件）*/
	gtk_main ();
    
    return 0;
}
