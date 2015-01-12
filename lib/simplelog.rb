=begin
SimpleLog
   Copyright 2014 Austen Higgins-Cassidy

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
=end
require 'time'
class SimpleLog < SimpleOutput::SimpleOutputPlugin
   #Only supports annotation
   def initialize(name = "log", format="txt")
      filename = name + self.get_timestamp() + "." + format
      @file = File.new(filename, "w")
      @series_names = {}
      @data_id = 0
      @annotations = {}
      @current_name = ""
      @series_id = 0
   end

   def translate_name(name)
         if name == nil
            name = @current_name
         end
         
         return name
      end


   def set_x_Data(data, name, options={})
    
   end

   def set_y_data(data, name, options={})
     
   end

   def new_data( x=[], y=[],name=nil, options={})
     
   end

   #Interface Functions ===================================
   def append_xy( x=[], y=[],name=nil, options={})
      log_name(name)
      log_var(x, "Appending X Data")
      log_var(y, "Appending Y Data")
   end

   def set_xy(x=[], y=[], name=nil, options={})
      log_name(name)
      log_var(x, "Setting X Data")
      log_var(y, "Setting Y Data")
   end

   def append_points(points =[], name=nil, options={})
      log_name(name)
      log_var(points, "Appending (points)")
   end

   def set_points(points = [], name=nil, options={})
      log_name(name)
      log_var(points, "Setting (points)")
   end

   def append_hash(hash = {}, name=nil, options={})
      log_name(name)
      log_var(hash, "Appending (hash)")
   end

   def set_hash(hash ={}, name=nil, options={})
      log_name(name)
      log_var(hash, "Setting (hash)")
   end

      

   def set_options(name=nil, options = {})
      log_var(option, "Options")
   end

   def annotate(annotation, name=nil, options = {})
      name = translate_name(name)
      log(annotation, name)
      self.options_callback(options)
   end

   def log(content, name = nil)
      if name != nil
         logtext = self.get_timestamp() + " #{name}: #{content}"
      else
         logtext = self.get_timestamp() + " #{content}"
      end
      puts logtext
      @file.syswrite("#{logtext}\n") 
   end

   def log_name(name = nil)
      name = translate_name(name)
      log("<For #{name}>:")
   end

   def log_var(var, name=nil)
      log("value:", name)
      str = parse_var(var,1)
      puts str
      @file.syswrite("#{str}\n")
   end

   def parse_var(var, indent)
      string = "" 
      case var
      when Hash
         string += self.put_at_indent("Hash:", indent)
         var.each_pair do |(key, value)|
            string += self.put_at_indent(key.to_s, indent+1)
            string += self.parse_var(value, indent+1)
         end
      when Array
         string += self.put_at_indent("Array:", indent)
         var.each do |value|
            string += self.parse_var(value, indent+1)
         end
      when Numeric
         string += self.put_at_indent(var.to_s, indent)
      when String
         string += self.put_at_indent(var, indent)
      else
         string += self.put_at_indent(var.to_s, indent)
      end
      string
   end

   def put_at_indent(content, indent)
      string = ""
      indent.times { string += "  "}
      string += content + "\n"
   end



   def get_timestamp()
      Time.now.strftime("%Y-%m-%d-%H%M%S")
   end

   def get_data_as_points
      [[0,0]]
   end

   def get_data_as_xy
      [[0],[0]]
   end

   def get_series_hashes
      {0 => 0}
   end

   def save()
      @file.close
   end
end