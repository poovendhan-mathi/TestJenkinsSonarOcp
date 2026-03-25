"use client";

import { useExpenses } from "@/hooks/useExpenses";
import ExpenseForm from "@/components/ExpenseForm";
import ExpenseList from "@/components/ExpenseList";
import ExpenseFilter from "@/components/ExpenseFilter";
import ExpenseSummary from "@/components/ExpenseSummary";

export default function Home() {
  const { expenses, total, filter, setFilter, addExpense, deleteExpense, isLoaded } =
    useExpenses();

  if (!isLoaded) {
    return (
      <div className="text-center py-12 text-gray-500">Loading...</div>
    );
  }

  return (
    <>
      <ExpenseSummary total={total} count={expenses.length} filter={filter} />
      <ExpenseForm onAdd={addExpense} />
      <ExpenseFilter filter={filter} onFilterChange={setFilter} />
      <ExpenseList expenses={expenses} onDelete={deleteExpense} />
    </>
  );
}
