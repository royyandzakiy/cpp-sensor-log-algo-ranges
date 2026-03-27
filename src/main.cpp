#include "sensor_log.hpp"
#include <chrono>
#include <print>
#include <random>
#include <vector>

using namespace std::chrono_literals;

auto generate_sample_data(size_t data_count = 100) {
	std::vector<std::string> sensors = {"temp_indoor", "temp_outdoor", "humidity"};
	std::vector<std::string> units = {"C", "C", "%"};
	auto start_time = std::chrono::system_clock::now() - 24h;

	// random value generator
	std::random_device rd;
	std::mt19937 gen(rd());
	std::uniform_real_distribution<> temp_dist(15.0, 25.0);
	std::uniform_real_distribution<> humidity_dist(30.0, 90.0);
	std::uniform_int_distribution<> sensor_choice(0, 2);

	// std::views::iota crates lazy view, no memory is allocated. only calculates once asked!
	// std::iota instead is an old func that fills in a container/vector
	auto idx_range_view = std::views::iota(size_t{0}, data_count);
	auto data_generator_view =
		idx_range_view | std::views::transform([&](size_t i) {
			int idx = sensor_choice(gen);
			return DataPoint{.timestamp = start_time + std::chrono::minutes(i * 30), // 30 min intervals
							 .name = sensors.at(idx),
							 .value = (idx == 2) ? humidity_dist(gen) : temp_dist(gen),
							 .unit = units.at(idx)};
		});

	return std::vector<DataPoint>(data_generator_view.begin(), data_generator_view.end());
}

auto main() -> int {
	auto sample_data = generate_sample_data(20);
	for (const auto &data : sample_data) {
		std::println("{}", data.value);
	}

	DataLog datalog{sample_data};
	datalog.print();
	datalog.save("my_saved_log.txt");
	return 0;
}