$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'yaml'

module MortgageCalc
  VERSION = YAML.load_file(File.dirname(__FILE__) + "/../VERSION")
end

require 'mortgage_calc/mortgage_util'