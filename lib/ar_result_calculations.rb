require File.dirname(__FILE__) + '/ar_result_calculations/ar_result_calculations.rb'
Array.send :include, ArResultCalculations::Calculations

module ArResultCalculations

end
