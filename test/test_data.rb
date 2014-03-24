class TestData
  def initialize()
    Random.srand(123456789)
  end

  def array_data()
    array = []
    100.times {array << 10*Random.rand}
    array
  end

  def points_data()
    array = []
    100.times {|x| array << [x, 10*Random.rand()] }
    array
  end

  def xy_data()
    x = []
    y = []
    100.times do |i|
      x << i
      y << i
    end
    [x,y]
  end

  def hash_data()
    hash = {}
    100.times {|x| hash[x] = x*Random.rand}
    hash
  end
end