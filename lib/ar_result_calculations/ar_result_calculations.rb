module ArResultCalculations
  module Calculations
    def self.included(base)
      base.class_eval do
        extend ClassMethods
        include InstanceMethods
      end
    end

    module InstanceMethods
      # Return the sum of a column from an active record result set
      # Calls super() if not a result set
      # 
      #   column:  The column name to sum
      def sum(column = nil)
        return super() unless column && first && first.class.respond_to?(:descends_from_active_record?)
        inject( 0 ) { |sum, x| x[column].nil? ? sum : sum + x[column] }
      end
      
      # Return the average of a column from an active record result set
      # Calls super() if not a result set
      # 
      #   column:  The column name to average
      def mean(column = nil)
        return super() unless column && first && first.class.respond_to?(:descends_from_active_record?)
        (length > 0) ? sum(column) / length : 0
      end
      alias :avg  :mean
      alias :average  :mean
      
      # Return the count of a column from an active record result set
      # Calls super() if not a result set.  nil values are not counted
      # 
      #   column:  The column name to count
      def count(column = nil)
        return super unless column && first && first.class.respond_to?(:descends_from_active_record?)         
        inject( 0 ) { |sum, x| x[column].nil? ? sum : sum + 1 }
      end
      
      # Return the max of a column from an active record result set
      # Calls super() if not a result set
      # 
      #   column:  The column name to max        
      def max(column = nil)
        return super() unless column && first && first.class.respond_to?(:descends_from_active_record?)  
        map(&column.to_sym).max
      end
      alias :maximum :max
      
      # Return the min of a column from an active record result set
      # Calls super() if not a result set
      # 
      #   column:  The column name to sum        
      def min(column = nil)
        return super() unless column && first && first.class.respond_to?(:descends_from_active_record?)  
        map(&column.to_sym).min
      end
      alias :minimum :min
      
      # Return a regression (OLS) of a column from an active record result set
      # Calls super() if not a result set
      # 
      #   column:  The column name to regress
      def regression(column = nil)
        return nil unless first
        unless is_numeric?(first)
          raise ArgumentError, "Regression needs an array of ActiveRecord objects" unless column && first && first.class.respond_to?(:descends_from_active_record?)  
          series = map { |x| x[column] }
        end
        Array::LinearRegression.new(series || self).fit
      end
      
      # Return the slope of a regression on a column from an active record result set
      # Calls super() if not a result set
      # 
      #   column:  The column name to regress        
      def slope(column = nil)
        return nil unless first
        unless is_numeric?(first)
          column ||= first_numeric_column
          series = map { |x| x[column] }
        end
        Array::LinearRegression.new(series || self).slope
      end
      alias :trend :slope
      
      # Force a column to be numeric.  Useful if you have derived
      # columns from a query that is not part of the base model.
      # 
      #   column:  The column name to sum
      #
      #   returns self so you can compose other methods.     
      def make_numeric(column)
        return self unless column && first && first.class.respond_to?(:descends_from_active_record?)
        each do |row|
          next if is_numeric?(row[column])
          row[column] = row[column] =~ /[-+]?[0-9]+(\.[0-9]+)/ ? row[column].to_f : row[column].to_i
        end
        self
      end
      alias :coerce_numeric :make_numeric 
      
    private
      def first_numeric_column
        raise ArgumentError, "Slope needs an array of ActiveRecord objects" unless first && first.class.respond_to?(:descends_from_active_record?)  
        first.attributes.each {|attribute, value| return attribute if is_numeric?(value) }
        raise ArgumentError, "Slope could not detect a numberic attribute.  Please provide an attribute name as an argument"
      end
      
      def is_numeric?(val)
        is_integer?(val) || is_float?(val)
      end
      
      def is_integer?(val)
        val.is_a?(Fixnum) || val.is_a?(Integer) || val.is_a?(Bignum)
      end
      
      def is_float?(val)
        val.is_a?(Float) || val.is_a?(Rational)
      end
    end
    
    module ClassMethods
      # Courtesy of http://blog.internautdesign.com/2008/4/21/simple-linear-regression-best-fit
      class Array::LinearRegression
        attr_accessor :slope, :offset

        def initialize dx, dy=nil
          @size = dx.size
          dy,dx = dx,axis() unless dy  # make 2D if given 1D
          raise ArgumentError, "[regression] Arguments are not same length!" unless @size == dy.size
          sxx = sxy = sx = sy = 0
          dx.zip(dy).each do |x,y|
            sxy += x*y
            sxx += x*x
            sx  += x
            sy  += y
          end
          @slope = ( @size * sxy - sx * sy ) / ( @size * sxx - sx * sx ) rescue 0
          @offset = (sy - @slope * sx) / @size
        end

        def fit
          return axis.map{|data| predict(data) }
        end

        def predict( x )
          y = @slope * x + @offset
        end

        def axis
          (0...@size).to_a
        end
      end

    end
  end
end

