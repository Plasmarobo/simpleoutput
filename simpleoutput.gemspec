Gem::Specification.new do |s|
  s.name = 'SimpleOutput'
  s.version = '1.0.6'
  s.licenses = ['Apache 2.0']
  s.summary = 'A Simple Engine to output data'
  s.description = 'A pluging based graphing and report rendering system with multiple simultanous output systems supported'
  s.author = ["Austen Higgins-Cassidy"]
  s.email = 'plasmarobo@gmail.com'
  s.files = ["lib/simpleoutput.rb", "lib/simplelog.rb", "lib/simpleplot.rb", "lib/simplechartkick.rb", "include/chartkick.js", "LICENSE"]
  s.homepage = 'https://github.com/Plasmarobo/simpleoutput'
  s.add_runtime_dependency "gnuplot", ["~> 2.6"," >= 2.6.2"]
  s.add_runtime_dependency "json", ["~> 1.7", ">= 1.7.7"]
end