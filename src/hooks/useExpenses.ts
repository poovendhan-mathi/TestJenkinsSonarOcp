"use client";

import { useState, useEffect, useCallback, useMemo } from "react";
import { Expense } from "@/types/expense";
import { loadExpenses, saveExpenses } from "@/utils/storage";
import { v4 as uuidv4 } from "uuid";

export function useExpenses() {
  const [expenses, setExpenses] = useState<Expense[]>([]);
  const [filter, setFilter] = useState<string>("All");
  const [isLoaded, setIsLoaded] = useState(false);

  // Load from localStorage on mount
  useEffect(() => {
    setExpenses(loadExpenses());
    setIsLoaded(true);
  }, []);

  // Save to localStorage whenever expenses change
  useEffect(() => {
    if (isLoaded) {
      saveExpenses(expenses);
    }
  }, [expenses, isLoaded]);

  const addExpense = useCallback(
    (expense: Omit<Expense, "id">) => {
      const newExpense: Expense = { ...expense, id: uuidv4() };
      setExpenses((prev) => [newExpense, ...prev]);
    },
    []
  );

  const deleteExpense = useCallback((id: string) => {
    setExpenses((prev) => prev.filter((e) => e.id !== id));
  }, []);

  const filteredExpenses = useMemo(() => {
    if (filter === "All") return expenses;
    return expenses.filter((e) => e.category === filter);
  }, [expenses, filter]);

  const total = useMemo(() => {
    return filteredExpenses.reduce((sum, e) => sum + e.amount, 0);
  }, [filteredExpenses]);

  return {
    expenses: filteredExpenses,
    allExpenses: expenses,
    total,
    filter,
    setFilter,
    addExpense,
    deleteExpense,
    isLoaded,
  };
}
