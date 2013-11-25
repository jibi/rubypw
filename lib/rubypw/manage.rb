#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#

require 'yaml'
require 'ruport'
require 'io/console'

module RubyPw

class Manager
  include RandomChar
  include Dump
  include Config
  include CLI
  include GUI

  attr_reader :config, :pw

  def initialize(dir)
    @pw          = Hash.new
    @db_modified = false

    do_config(dir)

    Dir.mkdir(dir) if not Dir.exist?(dir)
  end

  def do_config(dir)
    conf_file = dir + CONF_FILE

    @config = File.exist?(conf_file) ?
      open(CONF_FILE) { |file| YAML.load(file) } : {}

    @config[:db_file] ||= dir + DB_FILE
    @config[:qr_file] ||= QR_FILE
    @config[:pw_len]  ||= PW_LENGTH

    @config[:db_file] = File.expand_path @config[:db_file]
    @config[:qr_file] = File.expand_path @config[:qr_file]
  end

  def add_password(username, password)
    set_password(username, password, false)
  end

  def upd_password(username, password)
    set_password(username, password, true)
  end

  def set_password(username, password, update)
    raise ArgumentError, 'Empty username.' if username.empty?

    if not @pw[username].nil? and not update
      raise "#{username} already exists.\nNot updating: please delete first."
    elsif @pw[username].nil? and update
      raise "#{username} does not exist.\nNot updating: please add first."
    end

    @pw[username] = password
    @db_modified = true
  end

  def get_password(username)

    if @pw[username].nil?
      raise "No user #{username} found."
    else
      @pw[username]
    end
  end

  def del_password(username)

    if @pw[username].nil?
      raise "No user #{username} found."
    else
      @pw.delete(username)
      @db_modified = true
    end
  end

  def upd_username(username, new_username)
    raise "No user #{username} found."  if @pw[username].nil?
    raise "#{new_username} already exists." if not @pw[new_username].nil?

    password = @pw[username]
    @pw.delete(username)
    @pw[new_username] = password

    @db_modified = true
  end

  def file_password(args)
    filename = args[0]

    File.open(File.expand_path(filename), "r").each_line { |l|
      l =~ /(.+) (.+)/
      set_password($1, $2, 0)
    }
  end

  def get_users_like(what)
    @pw.select { |k, v| k.match(what) }.keys
  end
end
end

