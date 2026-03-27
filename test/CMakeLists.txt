# =============================================================================
# Test Configuration
# =============================================================================
add_executable(unit_tests
    test_calc.cpp
)

target_link_libraries(unit_tests
    PRIVATE 
        run_calc 
        GTest::gtest 
        GTest::gtest_main
)

include(GoogleTest)
gtest_discover_tests(unit_tests)