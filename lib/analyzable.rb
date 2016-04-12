module Analyzable
  
  @@fields = ["brand", "name"]
  
  public def average_price product_list
    total = product_list.inject(0) {|sum, product| sum + product.price.to_f}
    (total / product_list.count).round(2)
  end
  
  def print_report product_list
    report = "Inventory by brand:"
    report += "\n"
    (count_by_brand Product.all).each do |brand, amount|
        report += "  - #{brand}: #{amount}"
        report += "\n"
    end
    report += "Inventory by name:"
    report += "\n"
    (count_by_name Product.all).each do |name, amount|
        report += "  - #{name}: #{amount}"
        report += "\n"
    end
    puts report
    report
  end
  
  # better solution?
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
      
end
