module MortgageCalc
  class MortgageUtil
    attr_accessor :loan_amount, :borrowed_fees, :interest_rate, :period, :fee

    def initialize(loan_amount, interest_rate, fee, period=360, borrowed_fees=0)
      self.loan_amount = Float(loan_amount.to_s)
      self.interest_rate = Float(interest_rate.to_s)
      self.period = Integer(period.to_s)
      self.fee = Float(fee.to_s)
      self.borrowed_fees = Float(borrowed_fees.to_s)
    end

    def apr
      @apr ||= calculate_apr
    end

    def monthly_payment
      @monthly_payment ||= calculate_monthly_payment(self.loan_amount + self.borrowed_fees, monthly_interest_rate, self.period)
    end

  private
    
    def monthly_interest_rate
      self.interest_rate / 100 / 12
    end

    def calculate_monthly_payment(amount, monthly_rate, period)
      amount * (monthly_rate/(1 - (1 + monthly_rate)**(-period)))
    end
    
    def monthly_payment_with_fees
      @monthly_payment_with_fees ||= calculate_monthly_payment(self.loan_amount + fee, monthly_interest_rate, self.period)
    end
    
    # solves APR
    # [a (1 + a)^N] / [(1 + a)^N - 1] - P/C = 0
    # where a = APR/1200, N = period, P = monthly payment, C = loan_amount
    # calculate APR uses the Newton-Raphson to find the root (the value for 'a' that makes f(a) = 0)
    def calculate_apr
      payment_ratio = monthly_payment_with_fees / loan_amount
      f = lambda {|k| (k**(self.period + 1) - (k**self.period * (payment_ratio + 1)) + payment_ratio)}
      f_deriv = lambda { |k| ((self.period + 1) * k**self.period) - (self.period * (payment_ratio + 1) * k**(self.period - 1))}

      root = newton_raphson(f, f_deriv, monthly_interest_rate + 1)
      100 * 12 * (root - 1).to_f
    end

    # if 'start' is the monthly_interest_rate, Newton Raphson will find the apr root very quickly
    # k1 = k0 - f(k0)/f'(k0)
    # k_plus_one = k - f(k)/f_deriv(k)
    # We find the k-intercept of the tangent line at point k_plus_one and compare k to k_plus_one.
    # This is repeated until a sufficiently accurate value is reached, which can be specified with the 'precision' parameter
    def newton_raphson(f, f_deriv, start, precision = 5)
      k_plus_one = start
      k = 0.0

      while ((k - 1) * 10**precision).to_f.floor !=  ((k_plus_one - 1) * 10**precision).to_f.floor
        k = k_plus_one
        k_plus_one = k - f.call(k) / f_deriv.call(k)
      end
      k_plus_one
    end
  end
end