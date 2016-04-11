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
    CSV.read(@@data_path).drop(1).map{|row| self.new(Hash[header.zip row])}
  end

  # QUESTION: What is better(or best) way?   
  def self.first *args
    # get header row as array of fields
    header = CSV.read(@@data_path)[0]
    rows = CSV.read(@@data_path).drop(1)
    
    if(args.length == 0 )
        rows.first(1).map{|row| self.new(Hash[header.zip row])}.first
    else
        rows.first(args[0]).map{|row| self.new(Hash[header.zip row])}
    end
  end
  
  # get attribute array from instance 
  def attrs
    instance_variables.map{|ivar| instance_variable_get ivar}
  end
  
  def self.find id
    @@all.each do |data|
        return data if(id == data.id)
    end
    return nil
  end
  
  private
  # Inserts new instance of a data into database file
  def self.insert_into_db data

    # if file doesn't exits create
    if !File.exist?(@@data_path)
        CSV.open(data_path, "wb") do |csv|
            csv << ["id", "brand", "product", "price"]
        end
    end
    
    # add object attributes into the file
    CSV.open(@@data_path, "a+") do |csv|
        csv << data.attrs
    end
    
    return data
  end
  
end
