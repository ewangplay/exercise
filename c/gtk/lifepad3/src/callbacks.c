/* -*- Mode: C; indent-tabs-mode: t; c-basic-offset: 4; tab-width: 4 -*- */
/*
 * callbacks.c
 * Copyright (C) WangXiaohui 2009 <dahui@ewangplay.com>
 * 
 * callbacks.c is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License as published by the
 * Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * callbacks.c is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif

#include <gtk/gtk.h>

#include "callbacks.h"

void on_entry1_changed(GtkWidget * widget, gpointer data)
{
	g_print("entry context changed\n");
}

void on_notebook1_switch_page(GtkWidget * widget, gpointer data)
{
	g_print("notebook switch page\n");
}

void on_textview1_cut_clipboard(GtkWidget * widget, gpointer data)
{
	g_print("cut operation!\n");
}
