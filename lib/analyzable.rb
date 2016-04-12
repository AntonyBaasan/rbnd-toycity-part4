module Analyzable
  
  @@fields = ["brand", "name"]
  
  public def average_price product_list
    # why this one is not working? 
    # total = product_list.inject do |sum, product|
    #     sum + product.price
    # end
  
    total = 0
    product_list.each do |product|
        total += product.price
    end
    
    (total / product_list.count).round(2)
  end
  
  def print_report product_list
    report = capture_io do 
        puts "Inventory by brand:"
        (count_by_brand Product.all).each do |brand, amount|
            puts "  - #{brand}: #{amount}"
        end
        puts "Inventory by name:"
        (count_by_name Product.all).each do |name, amount|
            puts "  - #{name}: #{amount}"
        end
    end
    report
  end
  
  # how to write something like this?
  @@fields.each { |field|
        class_eval %Q"
        
          def count_by_#{field} product_list
            result = {}
            
            product_list.each do |product|
                if(result.has_key? product.#{field})
                    result[product.#{field}] += 1
                else
                    result.merge!(product.#{field} => 1)
                end
            end
            
            result
          end
          "
      }
      
#   def count_by_brand product_list
#     result = {}
    
#     product_list.each do |product|
#         if(result.has_key? product.brand)
#             result[product.brand] += 1
#         else
#             result.merge!(product.brand => 1)
#         end
#     end
    
#     result
#   end
  
#   def count_by_name product_list
#     result = {}
    
#     product_list.each do |product|
#         if(result.has_key? product.name.to_s)
#             result[product.name] += 1
#         else
#             result.merge!(product.name.to_s => 1)
#         end
#     end
    
#     result
#   end
end
