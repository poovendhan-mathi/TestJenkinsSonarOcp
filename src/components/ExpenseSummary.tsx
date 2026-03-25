"use client";

import { formatCurrency } from "@/utils/format";

interface ExpenseSummaryProps {
  total: number;
  count: number;
  filter: string;
}

export default function ExpenseSummary({ total, count, filter }: ExpenseSummaryProps) {
  return (
    <div className="bg-gradient-to-r from-blue-600 to-blue-800 rounded-lg shadow p-6 mb-6 text-white">
      <div className="flex items-center justify-between">
        <div>
          <p className="text-sm opacity-80">
            {filter === "All" ? "Total Spending" : `Total: ${filter}`}
          </p>
          <p className="text-3xl font-bold mt-1">{formatCurrency(total)}</p>
        </div>
        <div className="text-right">
          <p className="text-sm opacity-80">Expenses</p>
          <p className="text-3xl font-bold mt-1">{count}</p>
        </div>
      </div>
    </div>
  );
}
