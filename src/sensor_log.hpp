#pragma once
#include <algorithm>
#include <chrono>
#include <fstream>
#include <iostream>
#include <numeric>
#include <print>
#include <ranges>
using namespace std::chrono_literals;

// data type
struct DataPoint {
	std::chrono::system_clock::time_point timestamp;
	std::string name;
	double value;
	std::string unit;

	auto operator<=>(const DataPoint &) const = default; // all member values are std, so all already has comparisons,
														 // so compiler auto generates 6 comparison operators
};

// data manager
class DataLog {
  private:
	std::vector<DataPoint> m_logs{};

  public:
	DataLog(std::vector<DataPoint> &logs) : m_logs(std::move(logs)) {
	}

	void add(DataPoint dataPoint) {
		m_logs.push_back(std::move(dataPoint));
		std::sort(m_logs.begin(), m_logs.end());
	}

	std::vector<DataPoint> get_by_name(const std::string &name) const {
		std::vector<DataPoint> result;
		std::copy_if(m_logs.begin(), m_logs.end(), std::back_inserter(result),
					 [&](const auto &d) { return d.name == name; });

		return result;
	}

	auto filter_by_name(const std::string &name) const {
		return m_logs | std::views::filter([&](const auto &d) { return d.name == name; });
	}

	double average(const std::string &id) const {
		auto specific_logs = get_by_name(id);
		if (specific_logs.empty())
			return 0;

		double sum =
			std::accumulate(m_logs.begin(), m_logs.end(), 0.0, [](double acc, const auto &d) { return acc + d.value; });

		return sum / m_logs.size();
	}

	void save(const std::string &filename) const {
		std::ofstream file(filename);

		if (!file.is_open()) {
			std::println("Error to open \"{}\"", filename);
			return;
		}

		for (const auto &d : m_logs) {
			file << std::format("{:%Y-%m-%d %H:%M:%S}", d.timestamp) << "," << d.name << "," << d.value << "\n";
		}

		std::println("Saved to \"{}\"", filename);
	}

	void print() const {
		for (const auto &d : m_logs) {
			std::cout << std::format("{:%Y-%m-%d %H:%M:%S}", d.timestamp) << "," << d.name << "," << d.value << "\n";
		}
	}

	size_t size() const {
		return m_logs.size();
	}
};