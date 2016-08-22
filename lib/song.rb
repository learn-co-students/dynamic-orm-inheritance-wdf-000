require_relative "./interactive_record.rb"  #its one file up

class Song < InteractiveRecord  #inherates form its parent

  self.column_names.each do |col_name|
    attr_accessor col_name.to_sym
  end

end
