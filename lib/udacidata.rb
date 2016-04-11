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

  # QUESTION: What is better(or best) way?   
  def self.first amount=1
    # get header row as array of fields
    header = CSV.read(@@data_path)[0]
    rows = CSV.read(@@data_path).drop(1)
    
    # create data with params of zipped header and a row
    res = rows.first(amount).map do |row|
        self.new(Hash[header.map(&:to_sym).zip row])
    end
        
    (amount == 1 ) ? res.first : res
  end
  
  # QUESTION: What is better(or best) way?   
  def self.last amount=1
    # get header row as array of fields
    header = CSV.read(@@data_path)[0]
    rows = CSV.read(@@data_path).drop(1)
    
    res = rows.last(amount).map do |row|
        self.new(Hash[header.map(&:to_sym).zip row])
    end
        
    (amount == 1 ) ? res.first : res
  end
  
  def self.find id
    # Option A - Not much effeciant because it creates all the objects before find by id
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
  end
  
  def self.destroy id
    # Option A:
    # found this solution from here: http://stackoverflow.com/questions/26707169/how-to-remove-a-row-from-a-csv-with-ruby
    # how good is this(table) solution?
    table = CSV.table(@@data_path)
    
    deleted_row = table.select do |row|
        row[:id].to_i == id
    end
    # how to remove this duplication
    table.delete_if do |row|
        row[:id].to_i == id
    end
    
    File.open(@@data_path, 'w') do |f|
        f.write(table.to_csv)
    end
    
    # puts "deleted_row: " + deleted_row.to_s
    # puts "deleted_row.to_hash: " + deleted_row.first.to_hash.to_s
    
    deleted_object = self.new(deleted_row.first.to_hash)
    return deleted_object
    
  end
  
  # What are the better solutions?   
  def update (opts={})
    opts.each do |name, value|
        puts "name: "+name.to_s+", value: "+value.to_s
        # self.instance_variable_set(name, value)
        self.send(name.to_s+"=", value)
    end
    
    update_db self
  end
  
  # get attribute array from instance
  def attrs
    instance_variables.map{|ivar| instance_variable_get ivar}
  end

  private
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
  
  # Inserts new instance of a data into database file
  def self.update_db data

    rows = CSV.read(@@data_path).drop(1)
    
    rows.each do |row|
        if(row[0].to_s == data.id.to_s)
            row
        end
    end


    table = CSV.table(@@data_path)
    
    updated_row = table.each do |row|
        if(row[:id].to_i == data.id)
            row  << data.attrs
        end
    end
    
    data
  end
  
end
