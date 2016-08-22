require_relative "../config/environment.rb"
require 'active_support/inflector' #this is a ruby module

class InteractiveRecord           #this is a parent module

  def self.table_name
    self.to_s.downcase.pluralize
  end

  #this method creates the table. it calls on self which is the class name
  #to_s makes it into a string. downcase makes sure all the letters are lowercase
  #pluralize is a method from the active_support module for ruby which has a method
  #pluralize which ends up plurializeing the new string



  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

#We are creating column names for our table which we will creates
#we want the result to be in a hash because we want the column name to
#to be keys and the values to those keys are the values of our rows.
#sql = "pragma table_info('#{table_name}')" here we create a new table named after our class
#wit the given query statement.
#table_info is a variable given to the query statement since we will be returned a hash
#and the return value of table_info will be a hash with all the coloum names in the key name
#name is a string key and so we retrive each key name and retrieve its value which is the column name.
#we create an array in which we store all the keys as string and then compact that string to make sure
#we do not contain a nil. When we create a new ruby instance objct it is born with a nil for id.





  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

#self. is a class method which creates attributes for its attirbutes given at
#initialization. This is not so much of a method well it is but we can directly iterate over
#our method so for column names method which has a return value of an array of keys as strings,
#we create attr accessor for each one of those strings with the :symbol.








  def initialize(options={})
    options.each do |property, value|
      self.send("#{property}=", value)
    end
  end

  #this is the initialize method which takes an option as an argument. the argument is equal to a hash
  #we are metaprogramming here so the key and value of the hash are iterated on in which
  #we create a setter method for the value of the hashes. Values are what we give the hash



  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  #the save method uses the sql query and takes the table name method we create for the table
  #along with the column names for insert which is one giant string of key names and the values
  #is one giant string of values.
  #we then execute that sql statement and eqal the class id to the id of the new table instance.





  def table_name_for_insert
    self.class.table_name
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end
    #this methos goes into the column_name method which has a return value of
    #an array of strings itereates through it and grabs the values for those keys and stores them as a string into
    #the values array. rememeber in metaprogramming the key is a string so you have to reference it that way
    #and store each value as a string in that values array and then join the strings in the array
    #as long big string that is the return value.






  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  #this column name for insert takes in the class method column name which has
  #a return value of an array with strings inside of it with the keys and we delete an
  #key with the value id and we create the entire array into a string so now the
  #array looks like this "name, grade, ect" It converts the array of strings into
  #one giant string.





  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

end
