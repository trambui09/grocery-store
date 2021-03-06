class Order
  attr_reader :id
  attr_accessor :products, :customer, :fulfillment_status

  def initialize (id, products, customer, fulfillment_status = :pending )
    # REMEMBER: to set default value do ()fulfillment_status = :pending) in the params of the initialize method
    @id = id
    @products = products
    @customer = customer
    @fulfillment_status = validate_fulfillment_status(fulfillment_status)
  end

  def validate_fulfillment_status(status)
    until %i[pending paid processing shipped complete].include?(status)
      raise ArgumentError.new("invalid fullfillment status, #{status}")
    end
    return status
  end

  def total
    return 0 if @products.empty?

    products_total = @products.sum { |product, cost| cost }
    final_total = (products_total * 1.075).round(2)
    return final_total
  end

  def add_product(name, price)
    if @products.key?(name)
      raise ArgumentError.new("We already have the product name")
    else
      return @products[name] = price
    end
  end

  #optional remove_product method
  def remove_product(name)

    if !@products.key?(name)
      raise ArgumentError.new("No product with that name was found")
    else
      return @products.delete(name)
    end
  end

  def self.to_hash(products)
    product = {}
    array = products.split(";")

    array.each do |e|
      key_value = e.split(":")
      product[key_value[0]] = key_value[1].to_f
    end
    return product
  end

  # returns an array of all the order instance in the csv file
  def self.all
    all_orders = CSV.read('data/orders.csv').map do |order|
      id = order[0].to_i
      products = to_hash(order[1])
      customer = Customer.find(order[2].to_i)
      status = order[3].to_sym

      Order.new(id, products, customer, status)
    end
    return all_orders
  end

  def self.find(id)
    return all.find {|order| order.id == id}
  end

  # TO DO: OPTIONAL
  #returns a list of Order instance where the value of the customer's ID matches the passed parameter
  def self.find_by_customer(customer_id)
    orders_of_customer = all.find_all {|order| order.customer.id == customer_id}
    return orders_of_customer
  end
end