#include <gtk/gtk.h>

/* 这个函数连接到Close按钮或者从窗口管理器关闭窗口的事件上 */
gint delete_event (GtkWidget *widget, GdkEvent *event, gpointer data)
{
  gtk_main_quit ();
  return FALSE;
}

GtkWidget* close_button; /* 这个按钮将引发一个信号以
                          * 关闭应用程序 */
GtkWidget* tooltips_button; /* 启用/禁用工具提示 */
GtkWidget* text_button,
         * icon_button,
         * both_button; /* 切换工具栏风格的单选按钮 */
GtkWidget* entry; /* 一个文本输入构件，用于演示任何构件都可以组装到
                   * 工具栏里 */

/* 很简单...当按钮进行状态切换时，我们检查哪一个按钮是活动的，依此设置工具栏的式样
 * 注意，工具栏是作为用户数据传递到回调函数的！ */
void radio_event (GtkWidget *widget, gpointer data)
{
  if (GTK_TOGGLE_BUTTON (text_button)->active) 
    gtk_toolbar_set_style (GTK_TOOLBAR (data), GTK_TOOLBAR_TEXT);
  else if (GTK_TOGGLE_BUTTON (icon_button)->active)
    gtk_toolbar_set_style (GTK_TOOLBAR (data), GTK_TOOLBAR_ICONS);
  else if (GTK_TOGGLE_BUTTON (both_button)->active)
    gtk_toolbar_set_style (GTK_TOOLBAR (data), GTK_TOOLBAR_BOTH);
}

/* 更简单，检查给定开关按钮的状态，依此启用或禁用工具提示 */
void toggle_event (GtkWidget *widget, gpointer data)
{
  gtk_toolbar_set_tooltips (GTK_TOOLBAR (data),
                            GTK_TOGGLE_BUTTON (widget)->active );
}

int main (int argc, char *argv[])
{
  /* 下面是主窗口（一个对话框）和一个把柄盒(handlebox) */
  GtkWidget* dialog;
  GtkWidget* handlebox;

  /* 好了,我们需要一个工具栏,一个带掩码(mask)的图标（所有的按钮共用一个掩码）以及
   * 一个放图标的图标构件（但我们会为每个按钮创建一个分割构件） */
  GtkWidget * toolbar;
  GtkWidget * iconw;

  /* 这个在所有的 GTK 程序中都被调用。 */
  gtk_init (&argc, &argv);
  
  /* 用给定的标题和尺寸创建一个新窗口 */
  dialog = gtk_dialog_new ();
  gtk_window_set_title (GTK_WINDOW (dialog), "GTKToolbar Tutorial");
  gtk_widget_set_size_request (GTK_WIDGET (dialog), 600, 300);
  GTK_WINDOW (dialog)->allow_shrink = TRUE;

  /* 在关闭窗口时退出 */
  g_signal_connect (G_OBJECT (dialog), "delete_event",
                    G_CALLBACK (delete_event), NULL);

  /* 需要实例化窗口,因为我们要在它的内容中为工具栏设置图片 */
  gtk_widget_realize (dialog);

  /* 我们将工具栏放在一个手柄构件(handle box)上，
   * 这样它可以从主窗口上移开 */
  handlebox = gtk_handle_box_new ();
  gtk_box_pack_start (GTK_BOX (GTK_DIALOG (dialog)->vbox),
                      handlebox, FALSE, FALSE, 5);

    /* 工具栏设置为水平的，同时带有图标和文本
   * 在每个项之间有5像素的间距，
   * 并且，我们也将它放在手柄盒上 */
  toolbar = gtk_toolbar_new ();
  gtk_toolbar_set_orientation (GTK_TOOLBAR (toolbar), GTK_ORIENTATION_HORIZONTAL);
  gtk_toolbar_set_style (GTK_TOOLBAR (toolbar), GTK_TOOLBAR_BOTH);
  gtk_container_set_border_width (GTK_CONTAINER (toolbar), 5);
  gtk_container_add (GTK_CONTAINER (handlebox), toolbar);

    /* 工具栏上第一项是<close>按钮 */
  iconw = gtk_image_new_from_file ("gtk.xpm"); /* 图标构件 */
  close_button = 
    gtk_toolbar_append_item (GTK_TOOLBAR (toolbar), /* 工具栏 */
                             "Close",               /* 按钮标签 */
                             "Closes this app",     /* 按钮的工具提示 */
                             "Private",             /* 工具提示的私有信息 */
                             iconw,                 /* 图标构件 */
                             GTK_SIGNAL_FUNC (delete_event), /* 一个信号 */
                             NULL);
  gtk_toolbar_append_space (GTK_TOOLBAR (toolbar)); /* 工具栏项后的空白 */

 /* 现在，我们创建单选按钮组... */
  iconw = gtk_image_new_from_file ("gtk.xpm");
  icon_button = gtk_toolbar_append_element (
                    GTK_TOOLBAR (toolbar),
                    GTK_TOOLBAR_CHILD_RADIOBUTTON, /* 元素类型 */
                    NULL,                          /* 指向构件的指针 */
                    "Icon",                        /* 标签 */
                    "Only icons in toolbar",       /* 工具提示 */
                    "Private",                     /* 工具提示的私有字符串 */
                    iconw,                         /* 图标 */
                    GTK_SIGNAL_FUNC (radio_event), /* 信号 */
                    toolbar);                      /* 信号传递的数据 */
  //gtk_toolbar_append_space (GTK_TOOLBAR (toolbar));

   /* 后面的单选按钮引用前面创建的 */
  iconw = gtk_image_new_from_file ("gtk.xpm");
  text_button = 
    gtk_toolbar_append_element (GTK_TOOLBAR (toolbar),
                                GTK_TOOLBAR_CHILD_RADIOBUTTON,
                                icon_button,
                                "Text",
                                "Only texts in toolbar",
                                "Private",
                                iconw,
                                GTK_SIGNAL_FUNC (radio_event),
                                toolbar);
  //gtk_toolbar_append_space (GTK_TOOLBAR (toolbar));
                                          
  iconw = gtk_image_new_from_file ("gtk.xpm");
  both_button = 
    gtk_toolbar_append_element (GTK_TOOLBAR (toolbar),
                                GTK_TOOLBAR_CHILD_RADIOBUTTON,
                                text_button,
                                "Both",
                                "Icons and text in toolbar",
                                "Private",
                                iconw,
                                GTK_SIGNAL_FUNC (radio_event),
                                toolbar);
  gtk_toolbar_append_space (GTK_TOOLBAR (toolbar));
  gtk_toggle_button_set_active (GTK_TOGGLE_BUTTON (both_button), TRUE);

   /* 下面只是一个简单的开关按钮 */
  iconw = gtk_image_new_from_file ("gtk.xpm");
  tooltips_button = 
    gtk_toolbar_append_element (GTK_TOOLBAR (toolbar),
                                GTK_TOOLBAR_CHILD_TOGGLEBUTTON,
                                NULL,
                                "Tooltips",
                                "Toolbar with or without tips",
                                "Private",
                                iconw,
                                GTK_SIGNAL_FUNC (toggle_event),
                                toolbar);
  gtk_toolbar_append_space (GTK_TOOLBAR (toolbar));
  gtk_toggle_button_set_active (GTK_TOGGLE_BUTTON (tooltips_button), TRUE);

    /* 要将一个构件组装到工具栏上，只需创建它，然后将它追
   * 加到工具栏上，同时设置合适的工具提示 */
  entry = gtk_entry_new ();
  gtk_toolbar_append_widget (GTK_TOOLBAR (toolbar), 
                             entry, 
                             "This is just an entry", 
                             "Private");

  /* 因为它不是工具栏自己创建的，所以我们还需要显示它 */
  gtk_widget_show (entry);

    /* 好了，现在可以显示所有的东西了 */
  gtk_widget_show (toolbar);
  gtk_widget_show (handlebox);
  gtk_widget_show (dialog);

  /* 进入主循环，等待用户的操作 */
  gtk_main ();
  
  return 0;
}

