require_relative 'find_by'
require_relative 'errors'
require 'csv'

class Udacidata
  
  @@data_path = File.dirname(__FILE__) + "/../data/data.csv"
  
  def self.create opts={}
    newObject = self.new(opts)
    
    return insert_into_db newObject
  end
  
  def self.all
    # get header row as array of fields
    header = CSV.read(@@data_path)[0]
    # get all rows except header
    CSV.read(@@data_path).drop(1).map{|row| self.new(Hash[header.map(&:to_sym).zip row])}
  end

#   First and Last method
  @@method_names = ["first", "last"]
   # better solution?
  @@method_names.each { |method_name|
        class_eval %Q"
            def self.#{method_name} amount=1
                # get header row as array of fields
                header = CSV.read(@@data_path)[0]
                rows = CSV.read(@@data_path).drop(1)
                
                res = rows.#{method_name}(amount).map do |row|
                    self.new(Hash[header.map(&:to_sym).zip row])
                end
                    
                (amount == 1 ) ? res.first : res
            end
          "
      }
  
  
  def self.find id
    # Option A - Not much effeciant because it creates all the objects before find by id. Am I right or it is OK?
    # all.each do |object|
    #     if(object.id == id)
    #         return object
    #     end 
    # end
    
    # Option B - Again duplication! Better solution? 
    header = CSV.read(@@data_path)[0]
    rows = CSV.read(@@data_path).drop(1)
    
    res = rows.map do |row|
        object = self.new(Hash[header.map(&:to_sym).zip row])
        return object if(object.id == id)
    end
    
    raise ToyStoreDBErrors::NoItemFoundError, "No Item with ID: #{id}"
    
  end
  
  def self.destroy id
    # Option A:
    # found this solution from here: http://stackoverflow.com/questions/26707169/how-to-remove-a-row-from-a-csv-with-ruby
    # how good is this(table) solution?
    table = CSV.table(@@data_path)
    
    deleted_row = table.select do |row|
        row[:id].to_i == id
    end
    
    if(deleted_row == nil || deleted_row.count == 0)
        raise ToyStoreDBErrors::NoItemFoundError, "No Item with ID: #{id}"
    end
    
    # how to remove this duplication
    table.delete_if do |row|
        row[:id].to_i == id
    end
    
    File.open(@@data_path, 'w') do |f|
        f.write(table.to_csv)
    end
    
    deleted_object = self.new(deleted_row.first.to_hash)
    return deleted_object
    
  end
  
  # What are the better solutions?   
  def update (opts={})
    opts.each do |name, value|
        # puts "name: "+name.to_s+", value: "+value.to_s
        self.instance_variable_set("@#{name.to_s}", value)
    end
    
    self.update_db self
  end
  
  def self.where fields = {}
    all_objects = self.all
    found = []
  
    fields.each do |key, value|
        found = all_objects.select {|object| object.send(key) == value}
    end
    
    found
  end
  
  # get attribute array from instance
  def attrs
    instance_variables.map{|ivar| instance_variable_get ivar}
  end
  
  def to_s
    string = "#{self.class.name}("
    instance_variables.each do |attr|
        value = instance_variable_get attr
        string += "#{attr} - #{value}, "
    end
    string + ")\n"
  end


  # Inserts new instance of a data into database file
  def self.insert_into_db data

    # if file doesn't exits create
    if !File.exist?(@@data_path)
        CSV.open(data_path, "wb") do |csv|
            csv << ["id", "brand", "name", "price"]
        end
    end
    
    # add object attributes into the file
    CSV.open(@@data_path, "a+") do |csv|
        csv << data.attrs
    end
    
    return data
  end
  
  # Updates data inside database file
  def update_db data

    header = CSV.read(@@data_path)[0]
    table = CSV.table(@@data_path)
    
    table.each do |row|
        if(row[:id].to_i == id)
            # data.attrs.each{|attr| }
            header.each do |field|
                row[field.to_s] = data.instance_variable_get("@#{field.to_s}")
            end
            
        end
    end
    
    File.open(@@data_path, 'w') do |f|
        f.write(table.to_csv)
    end

    data
  end
  
end
