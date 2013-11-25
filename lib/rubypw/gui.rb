require 'gtk2'

module RubyPw
module GUI
  def self.included base
    base.extend Mod
  end

  module Mod
    include Config

    USERNAME = 0
    PASSWORD = 1

    def start_gui(dir = RUBYPW_DIR)
      @@manager = Manager.new(dir)
      show_db_window

      Gtk.main
    end

    def show_db_window
      db_window                 = Gtk::Window.new
      db_window.title           = "RubyPW"
      db_window.window_position = Gtk::Window::POS_CENTER_ALWAYS
      db_window.set_size_request(240, 80)

      label = Gtk::Label.new("Enter DB password")

      password = Gtk::Entry.new
      password.visibility = false

      db_window.signal_connect("destroy") do
        Gtk.main_quit if not @starting_account_window
      end

      password.signal_connect("activate") do
        begin
          @@manager.load_db(password.text)

          @starting_account_window = true
          db_window.destroy
          account_window
        rescue
          label.text = "Wrong password, try again."
          password.text = ""
        end
      end

      vbox = Gtk::VBox.new(false, 0)
      vbox.pack_start(label, true, true, 0)
      vbox.pack_start(password, true, true, 0)

      db_window.add(vbox)
      db_window.show_all
    end

    def account_window
      window                 = Gtk::Window.new("RubyPW")
      window.border_width    = 10
      window.window_position = Gtk::Window::POS_CENTER_ALWAYS
      window.set_default_size(480, 600)

      treeview = Gtk::TreeView.new
      @store   = Gtk::ListStore.new(String, String)

      username_renderer = Gtk::CellRendererText.new
      password_renderer = Gtk::CellRendererText.new
      username_renderer.set_property('editable', true)
      password_renderer.set_property('editable', true)

      username_column = Gtk::TreeViewColumn.new("Username", username_renderer, :text => USERNAME)
      password_column = Gtk::TreeViewColumn.new("Password", password_renderer, :text => PASSWORD)
      password_column.set_visible(false)

      treeview.append_column(username_column)
      treeview.append_column(password_column)
      treeview.model = @store

      show_password = Gtk::CheckButton.new "Show Passwords"

      menu      = Gtk::Menu.new
      copy_menu = Gtk::MenuItem.new("Copy Password")
      menu.append(copy_menu)
      menu.show_all

      @@manager.pw.to_a.each do |p|
        iter = @store.append
        iter[USERNAME], iter[PASSWORD] = p[0] , p[1]
      end

      window.signal_connect('destroy') do
        @@manager.write_db
        Gtk.main_quit
      end

      # edit username column row
      username_renderer.signal_connect("edited") do |_a,n,new_username|
        iter = @store.get_iter(n)
        if iter[USERNAME] != new_username
          begin
            @@manager.upd_username(iter[USERNAME], new_username)
            iter[USERNAME] = new_username
          rescue
            md = Gtk::MessageDialog.new(window, Gtk::Dialog::MODAL |
                   Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::ERROR,
                   Gtk::MessageDialog::BUTTONS_CLOSE, "Username already exists.")
            md.run
            md.destroy
          end
        end
      end

      # edit password column row
      password_renderer.signal_connect("edited") do |_a,n,new_password|
        iter = @store.get_iter(n)
        if iter[PASSWORD] != new_password
          begin
            @@manager.upd_password(iter[USERNAME], new_password)
            iter[PASSWORD] = new_password
          rescue
            md = Gtk::MessageDialog.new(window, Gtk::Dialog::MODAL |
                   Gtk::Dialog::DESTROY_WITH_PARENT, Gtk::MessageDialog::ERROR,
                   Gtk::MessageDialog::BUTTONS_CLOSE, "Cannot update password.")
            md.run
            md.destroy
          end
        end
      end

      copy_menu.signal_connect("activate") do
        password = treeview.selection.selected[PASSWORD]
        [Gdk::Selection::CLIPBOARD, Gdk::Selection::PRIMARY].each do |w|
          Gtk::Clipboard.get(w).set_text(password).store
        end
      end

      treeview.signal_connect("button_press_event") do |widget, event|
        if event.kind_of?(Gdk::EventButton) and event.button == 3
          menu.popup(nil, nil, event.button, event.time)
        end
      end

      show_password.signal_connect("clicked") do |w|
        password_column.set_visible(w.active?)
      end

      scrolled_win = Gtk::ScrolledWindow.new
      scrolled_win.set_policy(Gtk::POLICY_AUTOMATIC, Gtk::POLICY_AUTOMATIC)
      scrolled_win.add(treeview)

      hbox = Gtk::VBox.new(false, 8)
      hbox.pack_start(scrolled_win, true, true, 0)
      hbox.pack_start(show_password, false, true, 0)

      window.add(hbox)
      window.show_all
    end
  end
end
end

