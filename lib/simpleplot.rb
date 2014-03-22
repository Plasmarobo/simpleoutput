module SimplePlot
  require 'gnuplot'

  Gnuplot.open do |gp|
    Gnuplot::Plot.new(gp) do |plot|
      plot.terminal "png"
      plot.output File.expand_path("#{output_path}.png", __FILE__)

      