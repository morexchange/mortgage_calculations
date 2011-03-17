require File.dirname(__FILE__) + '/../spec_helper'
module MortgageCalc
  describe MortgageUtil do
    def assert_monthly_apr_payment_matches(loan_amount, rate, fee, period)
      mortgage_util = MortgageUtil.new(loan_amount, rate, fee, period)
      monthly_payment_with_fees = mortgage_util.monthly_payment_with_fees
      monthly_payment_from_apr = MortgageUtil.new(loan_amount, mortgage_util.apr, calc_total_fee(loan_amount, 0, 0), period).monthly_payment
      monthly_payment_with_fees.should be_within(0.01).of(monthly_payment_from_apr)
    end

    def calc_total_fee(loan_amount, points, fee)
      loan_amount * points/100 + fee
    end

    context "with valid MortgageUtil" do
      before(:all) do
        @mortgage_util = MortgageUtil.new(100_000, 6.0, calc_total_fee(100_000, 1.25, 1200), 360)
      end
      it "should have proper monthly interest rate" do
        @mortgage_util.send(:monthly_interest_rate).should == 0.005
      end
      it "should have proper monthly payment" do
        @mortgage_util.monthly_payment.should be_within(0.001).of(599.55)
      end
      it "should have proper total fees" do
        @mortgage_util.fee.should be_within(0.001).of(2450)
      end
      it "should have proper APR" do
        @mortgage_util.apr.should be_within(0.00001).of(6.22726)
      end
    end

    it "should calculate original monthly payment from APR" do
      assert_monthly_apr_payment_matches(300_000, 6.5, calc_total_fee(300_000, 1.25, 1200), 360)
      assert_monthly_apr_payment_matches(300_000, 6.5, calc_total_fee(300_000, 0, 0), 360)
      assert_monthly_apr_payment_matches(400_000, 1.1, calc_total_fee(400_000, 1.25, 1200), 180)
      assert_monthly_apr_payment_matches(300_000, 6.5, calc_total_fee(300_000, 7.25, 0), 360)
      assert_monthly_apr_payment_matches(300_000, 6.5, calc_total_fee(300_000, 7.25, 10000), 360)
    end

    # APR calculations from following web site are assumed to be accurate:
    # http://www.debtconsolidationcare.com/calculator/apr.html
    context "test apr calculation" do
      it "should calculate proper apr" do
        @mortgage_util = MortgageUtil.new(125000, 6.5, calc_total_fee(125_000, 0, 5000))
        @mortgage_util.apr.should be_within(0.001).of(6.881)
      end
      it "should calculate APR less than interest rate" do
        @mortgage_util =  MortgageUtil.new(100_000, 6.0, calc_total_fee(100_000, -11.25, 1200))
        @mortgage_util.fee.should eql -10050.0
        @mortgage_util.apr.should be_within(0.00001).of(5.04043)
      end
    end

    context "initialize convert to best types" do
      before(:all) do
        @mortgage_util =  MortgageUtil.new('100_000', '6.0', calc_total_fee(100_000, -1.25, 1200))
      end
      it "should convert rate to float if necessary" do
        @mortgage_util.interest_rate.class.should == Float
      end
      it "should convert fee to float if necessary" do
        @mortgage_util.fee.class.should == Float
      end
      it "should convert loan_amount to float if necessary" do
        @mortgage_util.loan_amount.class.should == Float
      end
      it "should convert period to integer if necessary" do
        @mortgage_util.period.class.should == Fixnum
      end
    end
    
    context "when borrowed_fees is specified" do
      before(:all) do
        @mortgage_util = MortgageUtil.new(100_000, 6.0, 2_000, 360, 2_000)
      end
      it "should not use the borrowed_fees in APR calculation" do
        @mortgage_util.apr.should be_within(0.00001).of(6.1857)
      end
      it "should use the borrowed_fees in monthly payment calculation" do
        @mortgage_util.monthly_payment.should be_within(0.002).of(611.54)
      end
    end
  end

end