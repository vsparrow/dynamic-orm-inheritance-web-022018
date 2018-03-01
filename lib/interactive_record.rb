require_relative "../config/environment.rb"
require 'active_support/inflector'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |property,value|
      self.send("#{property}=",value)
    end
  end

  # def save
    # sql = "INSERT INTO table_name_for_insert(column_names_for_insert) VALUES (column_names.values_for_insert)"
  # end
  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.select { |col| col != "id"}.join(", ")
  end
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end
  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      # puts "******#{col}"
      # values << "#{send(col)}" unless send(col).nil?
      values << "'#{send(col)}'" unless send(col).nil?
    end
    # puts "*************#{values}"
    # puts "*************#{values.join(", ")}"
    # puts "*************#{values.join(", ").class}"

    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  #
  # def values_for_insert
  #   values = []
  #   self.class.column_names.each do |col_name|
  #     values << "'#{send(col_name)}'" unless send(col_name).nil?
  #   end
  #   values.join(", ")
  # end


  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} where name = '#{name}'"
    DB[:conn].execute(sql)
  end
  # def self.find_by_name(name)
  #   sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
  #   DB[:conn].execute(sql)
  # end

end
