#include <stdio.h>
#include <stdlib.h>
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

/* 生成一个填满按钮-标签的横向盒。我们将感兴趣的参数传递进了这个函数。
 * 我们不显示这个盒，但显示它内部的所有东西。 */
GtkWidget *make_box( gboolean homogeneous,
                     gint     spacing,
		     gboolean expand,
		     gboolean fill,
		     guint    padding ) 
{
    GtkWidget *box;
    GtkWidget *button;
    char padstr[80];
    
    /* 以合适的 homogeneous 和 spacing 设置创建一个新的横向盒 */
    box = gtk_hbox_new (homogeneous, spacing);
    
    /* 以合适的设置创建一系列的按钮 */
    button = gtk_button_new_with_label ("gtk_box_pack");
    gtk_box_pack_start (GTK_BOX (box), button, expand, fill, padding);
    gtk_widget_show (button);
    
    button = gtk_button_new_with_label ("(box,");
    gtk_box_pack_start (GTK_BOX (box), button, expand, fill, padding);
    gtk_widget_show (button);
    
    button = gtk_button_new_with_label ("button,");
    gtk_box_pack_start (GTK_BOX (box), button, expand, fill, padding);
    gtk_widget_show (button);
    
    /* 根据 expand 的值创建一个带标签的按钮 */
    if (expand == TRUE)
	    button = gtk_button_new_with_label ("TRUE,");
    else
	    button = gtk_button_new_with_label ("FALSE,");
    
    gtk_box_pack_start (GTK_BOX (box), button, expand, fill, padding);
    gtk_widget_show (button);
    
    /* 这个和上面根据 "expand" 创建按钮一样，不过用
     * 了简化的形式。 */
    button = gtk_button_new_with_label (fill ? "TRUE," : "FALSE,");
    gtk_box_pack_start (GTK_BOX (box), button, expand, fill, padding);
    gtk_widget_show (button);
    
    sprintf (padstr, "%d);", padding);
    
    button = gtk_button_new_with_label (padstr);
    gtk_box_pack_start (GTK_BOX (box), button, expand, fill, padding);
    gtk_widget_show (button);
    
    return box;
}

int main( int   argc,
          char *argv[]) 
{
    GtkWidget *window;
    GtkWidget *button;
    GtkWidget *box1;
    GtkWidget *box2;
    GtkWidget *separator;
    GtkWidget *label;
    GtkWidget *quitbox;
    int which;
    
    /* 初始化  */
    gtk_init (&argc, &argv);
    
    if (argc != 2) {
	fprintf (stderr, "usage: packbox num, where num is 1, 2, or 3.\n");
	/* 这个在对 GTK 进行收尾处理后以退出状态为 1 退出。 */
	exit (1);
    }
    
    which = atoi (argv[1]);

    /* 创建窗口 */
    window = gtk_window_new (GTK_WINDOW_TOPLEVEL);

    /* 你应该总是记住连接 delete_event 信号到主窗口。这对
     * 适当的直觉行为很重要 */
    g_signal_connect (G_OBJECT (window), "delete_event",
		      G_CALLBACK (delete_event), NULL);
    gtk_container_set_border_width (GTK_CONTAINER (window), 10);
    
    /* 我们创建一个纵向盒（vbox）把横向盒组装进来。
     * 这使我们可以将填满按钮的横向盒一个个堆叠到
     * 这个纵向盒里。 */
    box1 = gtk_vbox_new (FALSE, 0);
    
    /* 显示哪个示例。这些对应于上面的图片。 */
    switch (which) {
    case 1:
	/* 创建一个新标签。 */
	label = gtk_label_new ("gtk_hbox_new (FALSE, 0);");
	
	/* 使标签靠左排列。我们将在构件属性部分讨
	 * 论这个函数和其它的函数。 */
	gtk_misc_set_alignment (GTK_MISC (label), 0, 0);

	/* 将标签组装到纵向盒（vbox box1）里。记住加到纵向盒里的
	 * 构件将依次一个放在另一个上面地组装。 */
	gtk_box_pack_start (GTK_BOX (box1), label, FALSE, FALSE, 0);
	
	/* 显示标签 */
	gtk_widget_show (label);
	
	/* 调用我们生成盒的函数 - homogeneous = FALSE, spacing = 0,
	 * expand = FALSE, fill = FALSE, padding = 0 */
	box2 = make_box (FALSE, 0, FALSE, FALSE, 0);
	gtk_box_pack_start (GTK_BOX (box1), box2, FALSE, FALSE, 0);
	gtk_widget_show (box2);

	/* 调用我们生成盒的函数 - homogeneous = FALSE, spacing = 0,
	 * expand = TRUE, fill = FALSE, padding = 0 */
	box2 = make_box (FALSE, 0, TRUE, FALSE, 0);
	gtk_box_pack_start (GTK_BOX (box1), box2, FALSE, FALSE, 0);
	gtk_widget_show (box2);
	
	/* 参数是： homogeneous, spacing, expand, fill, padding */
	box2 = make_box (FALSE, 0, TRUE, TRUE, 0);
	gtk_box_pack_start (GTK_BOX (box1), box2, FALSE, FALSE, 0);
	gtk_widget_show (box2);
	
	/* 创建一个分隔线，以后我们会更详细地学习这些， 
	 * 但它们确实很简单。 */
	separator = gtk_hseparator_new ();
	
        /* 组装分隔线到纵向盒。记住这些构件每个都被组装
        进了一个纵向盒，所以它们被垂直地堆叠。 */
	gtk_box_pack_start (GTK_BOX (box1), separator, FALSE, TRUE, 5);
	gtk_widget_show (separator);
	
	/* 创建另一个新标签，并显示它。 */
	label = gtk_label_new ("gtk_hbox_new (TRUE, 0);");
	gtk_misc_set_alignment (GTK_MISC (label), 0, 0);
	gtk_box_pack_start (GTK_BOX (box1), label, FALSE, FALSE, 0);
	gtk_widget_show (label);
	
	/* 参数是： homogeneous, spacing, expand, fill, padding */
	box2 = make_box (TRUE, 0, TRUE, FALSE, 0);
	gtk_box_pack_start (GTK_BOX (box1), box2, FALSE, FALSE, 0);
	gtk_widget_show (box2);
	
	/* 参数是： homogeneous, spacing, expand, fill, padding */
	box2 = make_box (TRUE, 0, TRUE, TRUE, 0);
	gtk_box_pack_start (GTK_BOX (box1), box2, FALSE, FALSE, 0);
	gtk_widget_show (box2);
	
	/* 另一个新分隔线。 */
	separator = gtk_hseparator_new ();
	/* gtk_box_pack_start的最后三个参数是：
	 * expand, fill, padding. */
	gtk_box_pack_start (GTK_BOX (box1), separator, FALSE, TRUE, 5);
	gtk_widget_show (separator);
	
	break;

    case 2:

	/* 创建一个新标签，记住 box1 是一个纵向
	 * 盒，它在 main() 前面部分创建 */
	label = gtk_label_new ("gtk_hbox_new (FALSE, 10);");
	gtk_misc_set_alignment (GTK_MISC (label), 0, 0);
	gtk_box_pack_start (GTK_BOX (box1), label, FALSE, FALSE, 0);
	gtk_widget_show (label);
	
	/* 参数是： homogeneous, spacing, expand, fill, padding */
	box2 = make_box (FALSE, 10, TRUE, FALSE, 0);
	gtk_box_pack_start (GTK_BOX (box1), box2, FALSE, FALSE, 0);
	gtk_widget_show (box2);
	
	/* 参数是： homogeneous, spacing, expand, fill, padding */
	box2 = make_box (FALSE, 10, TRUE, TRUE, 0);
	gtk_box_pack_start (GTK_BOX (box1), box2, FALSE, FALSE, 0);
	gtk_widget_show (box2);
	
	separator = gtk_hseparator_new ();
	/* gtk_box_pack_start的最后三个参数是：
	 * expand, fill, padding. */
	gtk_box_pack_start (GTK_BOX (box1), separator, FALSE, TRUE, 5);
	gtk_widget_show (separator);
	
	label = gtk_label_new ("gtk_hbox_new (FALSE, 0);");
	gtk_misc_set_alignment (GTK_MISC (label), 0, 0);
	gtk_box_pack_start (GTK_BOX (box1), label, FALSE, FALSE, 0);
	gtk_widget_show (label);
	
	/* 参数是： homogeneous, spacing, expand, fill, padding */
	box2 = make_box (FALSE, 0, TRUE, FALSE, 10);
	gtk_box_pack_start (GTK_BOX (box1), box2, FALSE, FALSE, 0);
	gtk_widget_show (box2);
	
	/* 参数是： homogeneous, spacing, expand, fill, padding */
	box2 = make_box (FALSE, 0, TRUE, TRUE, 10);
	gtk_box_pack_start (GTK_BOX (box1), box2, FALSE, FALSE, 0);
	gtk_widget_show (box2);
	
	separator = gtk_hseparator_new ();
	/* gtk_box_pack_start的最后三个参数是： expand, fill, padding。 */
	gtk_box_pack_start (GTK_BOX (box1), separator, FALSE, TRUE, 5);
	gtk_widget_show (separator);
	break;
    
    case 3:

        /* 这个示范了用 gtk_box_pack_end() 来右对齐构
         * 件的能力。首先，我们像前面一样创建一个新盒。 */
	box2 = make_box (FALSE, 0, FALSE, FALSE, 0);

	/* 创建将放在末端的标签。 */
	label = gtk_label_new ("end");
	/* 用 gtk_box_pack_end()组装它，这样它被放到
	 * 在make_box()调用里创建的横向盒的右端。 */
	gtk_box_pack_end (GTK_BOX (box2), label, FALSE, FALSE, 0);
	/* 显示标签。 */
	gtk_widget_show (label);
	
	/* 将 box2 组装进 box1 */
	gtk_box_pack_start (GTK_BOX (box1), box2, FALSE, FALSE, 0);
	gtk_widget_show (box2);
	
	/* 放在底部的分隔线。 */
	separator = gtk_hseparator_new ();
	/* 这个明确地设置分隔线的宽度为400象素点和5象素点高。这样我们创建
	 * 的横向盒也将为400象素点宽，并且"end"标签将和横向盒里其它的标签
	 * 分开。否则，横向盒里的所有构件将尽量紧密地组装在一起。 */
	gtk_widget_set_size_request (separator, 400, 5);
	/* 将分隔线组装到在main()前面部分创建的纵向盒（box1）里。 */
	gtk_box_pack_start (GTK_BOX (box1), separator, FALSE, TRUE, 5);
	gtk_widget_show (separator);    
    }
    
    /* 创建另一个新的横向盒.. 记住我们要用多少就能用多少！ */
    quitbox = gtk_hbox_new (FALSE, 0);
    
    /* 退出按钮。 */
    button = gtk_button_new_with_label ("Quit");
    
    /* 设置这个信号以在按钮被点击时终止程序 */
    g_signal_connect_swapped (G_OBJECT (button), "clicked",
			      G_CALLBACK (gtk_main_quit),
			      window);
    /* 将按钮组装进quitbox。
     * gtk_box_pack_start的最后三个参数是：
     * expand, fill, padding. */
    gtk_box_pack_start (GTK_BOX (quitbox), button, TRUE, FALSE, 0);
    /* pack the quitbox into the vbox (box1) */
    gtk_box_pack_start (GTK_BOX (box1), quitbox, FALSE, FALSE, 0);
    
    /* 将现在包含了我们所有构件的纵向盒（box1）组装进主窗口。 */
    gtk_container_add (GTK_CONTAINER (window), box1);
    
    /* 并显示剩下的所有东西 */
    gtk_widget_show (button);
    gtk_widget_show (quitbox);
    
    gtk_widget_show (box1);
    /* 最后显示窗口，这样所有东西一次性出现。 */
    gtk_widget_show (window);
    
    /* 当然，还有我们的主函数。 */
    gtk_main ();

    /* 当 gtk_main_quit() 被调用时控制权(Control)返回到
     * 这里，但当exit()被使用时并不会。 */
    
    return 0;
}
