class Module

  @@data_path = File.dirname(__FILE__) + "/../data/data.csv"

  def create_finder_methods(*attributes)
    # Your code goes here!
    # Hint: Remember attr_reader and class_eval
    
  end
  
  def method_missing(method_name, *arguments)
  
    if ((method_name.id2name.start_with?"find_by") && (arguments.length == 1))
        find_by_field (eval("{:"+method_name.to_s.sub("find_by_", "")+" => '"+arguments[0].to_s+"'}"))
    else
        super
    end
  end
  
  def find_by_field field = {}
    res = where field 
    # Better way?
    return (res.length == 1) ? res.first : res
    
    res = where field 
  end

  def where field = {}
    table = CSV.table(@@data_path)
    
    found_rows = table.select do |row|
        row.to_hash[field.keys[0]].to_s == field[field.keys[0]].to_s
    end
    
    res = found_rows.map do |row|
        self.new(row.to_hash)
    end
    
    # Better way?
    return res
  end
end
