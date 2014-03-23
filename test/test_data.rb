class TestData
  def initialize()
    Random.srand(123456789)
  end

  def array_data()
    array = []
    100.times {array << 10*Random.rand}
    array
  end

  def xy_array()
    array = []
    100.times {|x| array << [x, 10*Random.rand()] }
  end

  def hash_data()
    hash = {}
    100.times {|x| hash[x] = x*Random.rand}
    hash
  end
end