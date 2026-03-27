#include <gtest/gtest.h>
#include "../include/calculator.h"

class CalculatorTest : public ::testing::Test {
protected:
    Calculator calc;
};

TEST_F(CalculatorTest, Add) {
    EXPECT_EQ(calc.add(2, 3), 5);
    EXPECT_EQ(calc.add(-2, 3), 1);
    EXPECT_EQ(calc.add(0, 0), 0);
}

TEST_F(CalculatorTest, Subtract) {
    EXPECT_EQ(calc.subtract(5, 3), 2);
    EXPECT_EQ(calc.subtract(3, 5), -2);
    EXPECT_EQ(calc.subtract(0, 0), 0);
}

TEST_F(CalculatorTest, Multiply) {
    EXPECT_EQ(calc.multiply(2, 3), 6);
    EXPECT_EQ(calc.multiply(-2, 3), -6);
    EXPECT_EQ(calc.multiply(0, 5), 0);
}

TEST_F(CalculatorTest, Divide) {
    EXPECT_EQ(calc.divide(6, 3), 2);
    EXPECT_EQ(calc.divide(5, 2), 2);
}

TEST_F(CalculatorTest, DivideByZero) {
    EXPECT_THROW(calc.divide(5, 0), std::invalid_argument);
}

TEST_F(CalculatorTest, Modulus) {
    EXPECT_EQ(calc.modulus(6, 4), 2);
    EXPECT_EQ(calc.modulus(5, 2), 1);
}

TEST_F(CalculatorTest, ModulusByZero) {
    EXPECT_THROW(calc.modulus(5, 0), std::invalid_argument);
}