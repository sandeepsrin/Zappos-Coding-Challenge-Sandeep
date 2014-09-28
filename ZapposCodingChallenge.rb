require 'net/http'
require 'json'

def printCombinations(numProducts, totalPrice)
  puts "Desired number of products cannot be greater than 100" if numProducts > 100
  pageNo = (((totalPrice / numProducts) / 500.0) * 1100).round if (totalPrice / numProducts) < 500.0
  pageNo = 1100 if (totalPrice / numProducts) >= 500.0
  productArray = []
  greater = less = false #check if productArray sum is greater or less than specified total price
  while true do
    productArray = [] #reinitialize to empty array
    apiKey = "52ddafbe3ee659bad97fcce7c53592916a6bfd73"
    apiUrl = "http://api.zappos.com/Search?limit=100&sort={\"price\":\"asc\"}&page=#{pageNo}&key=#{apiKey}"
    url = URI.parse(URI.encode(apiUrl))
    req = Net::HTTP::Get.new(url.to_s)
    res = Net::HTTP.start(url.host, url.port) {|http|
      http.request(req)
    }
    results = JSON.parse(res.body)["results"]
    results.each_with_index do |result, index| #append items found on page to array of products to be printed
      break if index > numProducts - 1
      productArray << result
    end 
    sum = productArray.inject(0) { |sum, x| sum + x["price"][1..-1].to_f } #find current product array sum
    break if (sum - totalPrice).abs < (totalPrice / 100) || (less && greater) #make sure product array sum is as close as possible to specified total price
    pageNo = pageNo + 10 and less = true if sum < totalPrice
    pageNo = pageNo - 10 and greater = true if sum > totalPrice    
  end
  productArray.each { |el| puts "#{el["productName"]} #{el["price"]} #{el["productId"]} #{el["productUrl"]}" }
end
printCombinations(ARGV[0].to_f, ARGV[1].to_f)