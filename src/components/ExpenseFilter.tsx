"use client";

import { CATEGORIES } from "@/types/expense";

interface ExpenseFilterProps {
  filter: string;
  onFilterChange: (filter: string) => void;
}

export default function ExpenseFilter({ filter, onFilterChange }: ExpenseFilterProps) {
  return (
    <div className="flex items-center gap-2 mb-4">
      <label htmlFor="filter" className="text-sm font-medium text-gray-700">
        Filter:
      </label>
      <select
        id="filter"
        value={filter}
        onChange={(e) => onFilterChange(e.target.value)}
        className="border border-gray-300 rounded-md px-3 py-1.5 text-sm focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-900"
      >
        <option value="All">All Categories</option>
        {CATEGORIES.map((cat) => (
          <option key={cat} value={cat}>
            {cat}
          </option>
        ))}
      </select>
    </div>
  );
}
